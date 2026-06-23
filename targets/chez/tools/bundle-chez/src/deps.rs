//! Walk `(import ...)` forms to find every `.sls` file an entry script
//! transitively pulls in.
//!
//! Unlike racket bundles (which use literal string paths like
//! `(require "../runtime/foo.rkt")`), chez bindings import by library
//! name — `(import (apianyware runtime ffi))`. Resolving those names
//! to file paths requires parsing R6RS import-spec wrappers
//! (`only`, `except`, `prefix`, `rename`, `for`, `library`) and
//! knowing which file declares which library.
//!
//! Rather than hand-roll an s-expression reader in Rust, we shell out
//! to chez itself — `chez --script scripts/extract-deps.ss`. Chez is
//! already a mandatory dependency of the chez target (the bundled app
//! invokes `chez --script` at runtime); using it at bundle time costs
//! one extra process invocation per bundle and buys correctness on the
//! lexical edge cases (block comments, datum comments, character
//! literals, bytevector syntax).
//!
//! The script reads source_root for every `.sls` file's
//! `(library NAME ...)` declaration to build a `name → path` registry,
//! then BFS-walks imports from the entry. Built-in libraries
//! (`(chezscheme)`, `(rnrs ...)`) aren't in the registry and are
//! silently skipped — they ship with the runtime, not the bundle.
//!
//! ## Bundle-path semantics
//!
//! Returned paths are the **absolute logical paths** under source_root.
//! Chez's directory walk follows symlinks transparently when reading
//! file contents, but builds the descended path from directory names
//! it sees — so a symlinked subdirectory's contents appear at the
//! symlinked (logical) location, matching the bundle layout exactly.

use std::collections::HashSet;
use std::fs;
use std::path::{Component, Path, PathBuf};
use std::process::Command;

use crate::bundle::BundleError;

/// Chez binary used to run the deps walker. Matches what the chez
/// target's runtime tests and `verify.ss` invoke — same install on the
/// dev host.
pub const DEFAULT_CHEZ_BIN: &str = "chez";

/// Transitive set of `.sls` files reachable from `entry`, returned as
/// absolute paths under `source_root`.
pub fn collect_dependencies(
    entry: &Path,
    source_root: &Path,
) -> Result<HashSet<PathBuf>, BundleError> {
    collect_dependencies_with_chez(entry, source_root, DEFAULT_CHEZ_BIN)
}

/// Variant that lets callers override the chez binary — used by tests
/// that want to assert behaviour when chez is absent.
pub fn collect_dependencies_with_chez(
    entry: &Path,
    source_root: &Path,
    chez_bin: &str,
) -> Result<HashSet<PathBuf>, BundleError> {
    let abs_root = absolutize(source_root)
        .map_err(|e| BundleError::ResolveSourceRoot(source_root.to_path_buf(), e))?;
    let abs_entry =
        absolutize(entry).map_err(|e| BundleError::ResolveEntry(entry.to_path_buf(), e))?;

    if !abs_entry.starts_with(&abs_root) {
        return Err(BundleError::EntryOutsideRoot {
            entry: abs_entry,
            root: abs_root,
        });
    }
    if !abs_entry.exists() {
        return Err(BundleError::EntryMissing { entry: abs_entry });
    }

    let script_path = write_script_to_tempfile()?;

    let output = Command::new(chez_bin)
        .arg("--script")
        .arg(script_path.path())
        .arg(&abs_root)
        .arg(&abs_entry)
        .output()
        .map_err(|e| BundleError::ChezNotAvailable {
            chez_bin: chez_bin.to_string(),
            source: e,
        })?;

    if !output.status.success() {
        return Err(BundleError::DepsExtractFailed {
            stderr: String::from_utf8_lossy(&output.stderr).into_owned(),
        });
    }

    let stdout = String::from_utf8(output.stdout).map_err(|e| BundleError::DepsExtractFailed {
        stderr: format!("non-utf8 path in chez stdout: {e}"),
    })?;

    let mut deps = HashSet::new();
    for line in stdout.lines() {
        if line.is_empty() {
            continue;
        }
        let path = PathBuf::from(line);
        if !path.starts_with(&abs_root) {
            return Err(BundleError::DepOutsideRoot {
                target: path,
                root: abs_root.clone(),
            });
        }
        deps.insert(path);
    }
    Ok(deps)
}

/// The embedded deps walker. Materialized to a tempfile per invocation
/// so a binary install (where the source tree is absent) still works.
const EXTRACT_DEPS_SS: &str = include_str!("../scripts/extract-deps.ss");

struct ScriptFile {
    _dir: tempfile::TempDir,
    path: PathBuf,
}

impl ScriptFile {
    fn path(&self) -> &Path {
        &self.path
    }
}

fn write_script_to_tempfile() -> Result<ScriptFile, BundleError> {
    let dir = tempfile::tempdir()?;
    let path = dir.path().join("extract-deps.ss");
    fs::write(&path, EXTRACT_DEPS_SS)?;
    Ok(ScriptFile { _dir: dir, path })
}

/// Absolute, `.`/`..`-normalized form without following symlinks.
pub(crate) fn absolutize(path: &Path) -> std::io::Result<PathBuf> {
    Ok(logical_normalize(&std::path::absolute(path)?))
}

fn logical_normalize(path: &Path) -> PathBuf {
    let mut out = PathBuf::new();
    for comp in path.components() {
        match comp {
            Component::CurDir => {}
            Component::ParentDir => match out.components().next_back() {
                Some(Component::Normal(_)) => {
                    out.pop();
                }
                _ => out.push(comp),
            },
            _ => out.push(comp),
        }
    }
    out
}

#[cfg(test)]
mod tests {
    use super::*;
    use tempfile::TempDir;

    fn chez_available() -> bool {
        Command::new(DEFAULT_CHEZ_BIN)
            .arg("--version")
            .output()
            .map(|o| o.status.success())
            .unwrap_or(false)
    }

    fn write(dir: &Path, rel: &str, content: &str) -> PathBuf {
        let p = dir.join(rel);
        fs::create_dir_all(p.parent().unwrap()).unwrap();
        fs::write(&p, content).unwrap();
        p
    }

    fn rel_names(deps: &HashSet<PathBuf>, root: &Path) -> Vec<String> {
        let abs_root = absolutize(root).unwrap();
        let mut names: Vec<String> = deps
            .iter()
            .map(|p| {
                p.strip_prefix(&abs_root)
                    .unwrap_or_else(|_| panic!("{p:?} not under {abs_root:?}"))
                    .to_string_lossy()
                    .into_owned()
            })
            .collect();
        names.sort();
        names
    }

    #[test]
    fn collect_walks_transitively_through_library_registry() {
        if !chez_available() {
            eprintln!("SKIPPED: chez not available");
            return;
        }
        let dir = TempDir::new().unwrap();
        let root = dir.path();

        write(
            root,
            "runtime/ffi.sls",
            "(library (apianyware runtime ffi) (export f) (import (chezscheme)) (define (f) 1))",
        );
        write(
            root,
            "runtime/objc.sls",
            "(library (apianyware runtime objc) (export o) \
             (import (chezscheme) (apianyware runtime ffi)) (define (o) (f)))",
        );
        write(
            root,
            "generated/appkit/nswindow.sls",
            "(library (apianyware appkit nswindow) (export w) \
             (import (chezscheme) (apianyware runtime ffi) (apianyware runtime objc)) \
             (define (w) (o)))",
        );
        let entry = write(
            root,
            "apps/demo/demo.sls",
            "(import (apianyware appkit nswindow)) (w)",
        );

        let deps = collect_dependencies(&entry, root).unwrap();
        assert_eq!(
            rel_names(&deps, root),
            vec![
                "apps/demo/demo.sls".to_string(),
                "generated/appkit/nswindow.sls".to_string(),
                "runtime/ffi.sls".to_string(),
                "runtime/objc.sls".to_string(),
            ]
        );
    }

    #[test]
    fn collect_handles_import_wrappers() {
        if !chez_available() {
            eprintln!("SKIPPED: chez not available");
            return;
        }
        let dir = TempDir::new().unwrap();
        let root = dir.path();

        write(
            root,
            "runtime/objc.sls",
            "(library (apianyware runtime objc) (export o nserror?) \
             (import (chezscheme)) (define (o) 1) (define (nserror? x) #f))",
        );
        // Use every wrapper form chez supports; each must still resolve
        // to the underlying (apianyware runtime objc) library.
        let entry = write(
            root,
            "apps/demo/demo.sls",
            "(import (except (apianyware runtime objc) nserror?) \
                     (only (apianyware runtime objc) o) \
                     (prefix (apianyware runtime objc) p:) \
                     (rename (apianyware runtime objc) (o oo)) \
                     (for (apianyware runtime objc) expand)) (o)",
        );

        let deps = collect_dependencies(&entry, root).unwrap();
        assert_eq!(
            rel_names(&deps, root),
            vec![
                "apps/demo/demo.sls".to_string(),
                "runtime/objc.sls".to_string(),
            ]
        );
    }

    #[test]
    fn collect_skips_builtin_libraries() {
        if !chez_available() {
            eprintln!("SKIPPED: chez not available");
            return;
        }
        let dir = TempDir::new().unwrap();
        let root = dir.path();

        // Only (chezscheme) and (rnrs base) are imported — neither is
        // declared by any .sls under root, so the dep set is just the
        // entry itself. No error.
        let entry = write(
            root,
            "main.sls",
            "(import (chezscheme) (rnrs base (6))) (display 'ok)",
        );

        let deps = collect_dependencies(&entry, root).unwrap();
        assert_eq!(rel_names(&deps, root), vec!["main.sls".to_string()]);
    }

    #[test]
    fn collect_handles_cycles() {
        if !chez_available() {
            eprintln!("SKIPPED: chez not available");
            return;
        }
        let dir = TempDir::new().unwrap();
        let root = dir.path();

        // Two libraries that import each other — pathological for Chez
        // at load time but the dep walker still terminates.
        write(
            root,
            "a.sls",
            "(library (a) (export x) (import (chezscheme) (b)) (define x 1))",
        );
        write(
            root,
            "b.sls",
            "(library (b) (export y) (import (chezscheme) (a)) (define y 2))",
        );
        let entry = write(root, "main.sls", "(import (a)) (display x)");

        let deps = collect_dependencies(&entry, root).unwrap();
        assert_eq!(
            rel_names(&deps, root),
            vec![
                "a.sls".to_string(),
                "b.sls".to_string(),
                "main.sls".to_string()
            ]
        );
    }

    #[test]
    fn collect_rejects_entry_outside_root() {
        let dir = TempDir::new().unwrap();
        let root = dir.path().join("project");
        let outside = dir.path().join("other");
        fs::create_dir_all(&root).unwrap();
        fs::create_dir_all(&outside).unwrap();
        let entry = write(&outside, "x.sls", "(import (chezscheme))");

        let err = collect_dependencies(&entry, &root).unwrap_err();
        match err {
            BundleError::EntryOutsideRoot { .. } => {}
            other => panic!("expected EntryOutsideRoot, got {other:?}"),
        }
    }

    #[test]
    fn collect_reports_missing_chez_distinctly() {
        let dir = TempDir::new().unwrap();
        let root = dir.path();
        let entry = write(root, "main.sls", "(import (chezscheme))");

        let err =
            collect_dependencies_with_chez(&entry, root, "definitely-not-a-binary-on-this-machine")
                .unwrap_err();
        match err {
            BundleError::ChezNotAvailable { .. } => {}
            other => panic!("expected ChezNotAvailable, got {other:?}"),
        }
    }
}
