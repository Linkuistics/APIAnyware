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

/// The source tree(s) the chez bundler stages into one whole-program-compile
/// tree, resolved in **logical** path space.
///
/// The staged `tree/` (and the bundle's import resolution) is always a single
/// colocated shape — `apps/<app>/`, `apianyware/`, `lib/` as siblings — which
/// is also where the dep walker's `(import (apianyware …))` resolution and the
/// collision probe expect the libraries to live. [`SourceRoots`] lets the
/// bundler honour that shape whether the source is genuinely colocated
/// ([`single`]) or physically split across the §18 domain tree ([`split`]).
///
/// In the split case the **logical root is the bindings root** — `apianyware/`
/// and `lib/` are already its real children — and the one redirect is
/// `<logical_root>/apps/…`, which maps to the physically-separate
/// app-implementations tree.
///
/// [`single`]: SourceRoots::single
/// [`split`]: SourceRoots::split
#[derive(Debug, Clone)]
pub struct SourceRoots {
    logical_root: PathBuf,
    apps_root: Option<PathBuf>,
}

impl SourceRoots {
    /// A single colocated root: `apps/`, `apianyware/`, `lib/` are real
    /// siblings. Logical and physical paths are identical.
    pub fn single(root: &Path) -> Result<Self, BundleError> {
        Ok(Self {
            logical_root: absolutize(root)
                .map_err(|e| BundleError::ResolveSourceRoot(root.to_path_buf(), e))?,
            apps_root: None,
        })
    }

    /// The §18 split: app-implementations under `apps_root`, the binding
    /// package (`apianyware/` + `lib/`) under `bindings_root`. The logical
    /// root is the bindings root; logical `apps/…` paths redirect to
    /// `apps_root`.
    pub fn split(apps_root: &Path, bindings_root: &Path) -> Result<Self, BundleError> {
        Ok(Self {
            logical_root: absolutize(bindings_root)
                .map_err(|e| BundleError::ResolveSourceRoot(bindings_root.to_path_buf(), e))?,
            apps_root: Some(
                absolutize(apps_root)
                    .map_err(|e| BundleError::ResolveSourceRoot(apps_root.to_path_buf(), e))?,
            ),
        })
    }

    /// The logical root the staged tree mirrors (absolute). Doubles as the
    /// physical registry root the deps walker scans for `(apianyware …)`
    /// libraries — they are real children of the bindings root.
    pub(crate) fn logical_root(&self) -> &Path {
        &self.logical_root
    }

    /// Map a logical path (under [`logical_root`]) to the physical file on
    /// disk. Identity for a single root; for a split root, logical `apps/…`
    /// paths redirect to the apps root.
    ///
    /// [`logical_root`]: SourceRoots::logical_root
    pub(crate) fn to_physical(&self, logical: &Path) -> PathBuf {
        if let Some(apps_root) = &self.apps_root {
            if let Ok(rest) = logical.strip_prefix(self.logical_root.join("apps")) {
                return apps_root.join(rest);
            }
        }
        logical.to_path_buf()
    }

    /// Map a physical path the deps walker returned back to its logical path
    /// under the logical root. A file under the apps root becomes
    /// `<logical_root>/apps/…`; a file already under the logical (bindings)
    /// root is itself; anything else is outside the bundle.
    fn to_logical(&self, physical: &Path) -> Option<PathBuf> {
        if let Some(apps_root) = &self.apps_root {
            if let Ok(rest) = physical.strip_prefix(apps_root) {
                return Some(self.logical_root.join("apps").join(rest));
            }
        }
        physical
            .starts_with(&self.logical_root)
            .then(|| physical.to_path_buf())
    }
}

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

    let mut deps = HashSet::new();
    for path in run_extract_deps(&abs_root, &abs_entry, chez_bin)? {
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

/// Transitive set of `.sls` files reachable from the app entry, returned as
/// absolute **logical** paths under `roots.logical_root()` — the shape the
/// staged whole-program-compile tree mirrors.
///
/// The deps walker scans the bindings root for `(library (apianyware …))`
/// declarations and BFS-walks the entry's imports against them; the returned
/// physical paths (the entry under the apps root, the libraries under the
/// bindings root) are mapped back into logical space via the split.
pub fn collect_dependencies_split(
    entry: &Path,
    roots: &SourceRoots,
    chez_bin: &str,
) -> Result<HashSet<PathBuf>, BundleError> {
    let abs_entry =
        absolutize(entry).map_err(|e| BundleError::ResolveEntry(entry.to_path_buf(), e))?;
    if !abs_entry.exists() {
        return Err(BundleError::EntryMissing { entry: abs_entry });
    }

    let mut deps = HashSet::new();
    for path in run_extract_deps(roots.logical_root(), &abs_entry, chez_bin)? {
        let logical = roots
            .to_logical(&path)
            .ok_or_else(|| BundleError::DepOutsideRoot {
                target: path.clone(),
                root: roots.logical_root().to_path_buf(),
            })?;
        deps.insert(logical);
    }
    Ok(deps)
}

/// Run `extract-deps.ss` with the given registry root and entry, returning the
/// raw physical `.sls` paths it prints (one per line).
fn run_extract_deps(
    registry_root: &Path,
    entry: &Path,
    chez_bin: &str,
) -> Result<Vec<PathBuf>, BundleError> {
    let script_path = write_script_to_tempfile()?;

    let output = Command::new(chez_bin)
        .arg("--script")
        .arg(script_path.path())
        .arg(registry_root)
        .arg(entry)
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

    Ok(stdout
        .lines()
        .filter(|l| !l.is_empty())
        .map(PathBuf::from)
        .collect())
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

    /// The §18 split: the entry lives under the apps root, the `(apianyware …)`
    /// libraries under a *separate* bindings root. [`collect_dependencies_split`]
    /// builds the registry from the bindings root, BFS-walks the entry's
    /// imports, and maps the physical paths back to logical paths under the
    /// bindings root — the colocated shape the staged whole-program tree
    /// mirrors. This is the native replacement for the directory-symlink fixture
    /// the bundler test used to stitch.
    #[test]
    fn collect_split_resolves_across_apps_and_bindings_roots() {
        if !chez_available() {
            eprintln!("SKIPPED: chez not available");
            return;
        }
        let dir = TempDir::new().unwrap();
        let apps = dir.path().join("app-implementations/macos");
        let bindings = dir.path().join("bindings/macos");

        write(
            &bindings,
            "apianyware/runtime/ffi.sls",
            "(library (apianyware runtime ffi) (export f) (import (chezscheme)) (define (f) 1))",
        );
        write(
            &bindings,
            "apianyware/appkit/nswindow.sls",
            "(library (apianyware appkit nswindow) (export w) \
             (import (chezscheme) (apianyware runtime ffi)) (define (w) (f)))",
        );
        let entry = write(
            &apps,
            "demo/demo.sls",
            "(import (apianyware appkit nswindow)) (w)",
        );

        let roots = SourceRoots::split(&apps, &bindings).unwrap();
        let deps = collect_dependencies_split(&entry, &roots, DEFAULT_CHEZ_BIN).unwrap();

        // Logical paths under the bindings root — the colocated shape staged
        // into `tree/`: the entry at `apps/…`, the libraries at `apianyware/…`.
        assert_eq!(
            rel_names(&deps, roots.logical_root()),
            vec![
                "apianyware/appkit/nswindow.sls".to_string(),
                "apianyware/runtime/ffi.sls".to_string(),
                "apps/demo/demo.sls".to_string(),
            ]
        );
        // Every logical dep maps to a real file across the two physical roots.
        for d in &deps {
            assert!(
                roots.to_physical(d).is_file(),
                "physical file missing for logical {d:?}"
            );
        }
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
