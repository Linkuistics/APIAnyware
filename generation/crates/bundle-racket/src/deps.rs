//! Walk a `(require ...)` tree to find every `.rkt` file an entry script
//! transitively pulls in.
//!
//! Racket modules use literal string paths inside `(require ...)` for
//! filesystem-relative imports. Symbol forms (`ffi/unsafe`,
//! `racket/contract`, `(rename-in racket/contract ...)`) are collection
//! references and don't translate to file paths — those are skipped.
//!
//! The walker is intentionally tiny: it scans for string literals matching
//! `"...\.rkt"` anywhere in the source. In a normal racket file that
//! pattern only ever appears inside a `require` form, so a full s-expr
//! parser would be over-engineering. Strings that contain `.rkt` for
//! reasons other than file imports would be a false positive — the
//! racket emitter doesn't produce any.
//!
//! ## Symlinks and logical paths
//!
//! The walker works in **logical** path space — absolutize the entry, then
//! resolve `.`/`..` components without following symlinks. Bundle layout
//! is driven by the logical tree: a symlinked subdirectory appears in the
//! output bundle at its symlinked (logical) location, populated with real
//! copies of the symlink targets' content. This is what makes bundles
//! self-contained even when the source tree stitches in external
//! resources via symlinks (Modaliser-Racket's `bindings/` →
//! `APIAnyware/generation/targets/racket/` is the motivating
//! case). Reading file content still transparently follows symlinks,
//! because `fs::read_to_string` and `fs::copy` do.

use std::collections::HashSet;
use std::fs;
use std::path::{Component, Path, PathBuf};

use crate::bundle::BundleError;

/// Transitive set of `.rkt` files reachable from `entry`, returned as
/// absolute **logical** paths under `source_root`.
///
/// `source_root` is the directory the generated bundle's `racket-app/`
/// will mirror — e.g. `generation/targets/racket/` for the APIAnyware
/// sample apps, or the project root for a Modaliser-style layout whose
/// entry lives at `main.rkt`. Any discovered file whose logical path
/// escapes `source_root` is rejected as a bundle-layout error.
pub fn collect_dependencies(
    entry: &Path,
    source_root: &Path,
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

    let mut visited: HashSet<PathBuf> = HashSet::new();
    let mut queue: Vec<PathBuf> = vec![abs_entry];

    while let Some(file) = queue.pop() {
        if !visited.insert(file.clone()) {
            continue;
        }

        let content =
            fs::read_to_string(&file).map_err(|e| BundleError::ReadSource(file.clone(), e))?;
        let parent = file.parent().expect("source file has parent");

        for raw in scan_rkt_string_literals(&content) {
            let logical = logical_normalize(&parent.join(raw));

            if !logical.starts_with(&abs_root) {
                return Err(BundleError::RequireOutsideRoot {
                    referrer: file.clone(),
                    target: logical,
                    root: abs_root.clone(),
                });
            }

            if !logical.exists() {
                return Err(BundleError::ResolveRequire {
                    referrer: file.clone(),
                    target: raw.to_string(),
                    source: std::io::Error::new(
                        std::io::ErrorKind::NotFound,
                        format!("{} does not exist", logical.display()),
                    ),
                });
            }

            queue.push(logical);
        }
    }

    Ok(visited)
}

/// Return an absolute, `.`/`..`-normalized form of `path` without
/// following symlinks.
///
/// This is the key difference from `Path::canonicalize`, which resolves
/// every symlink and can drag a path out of `source_root` when an
/// in-tree directory symlinks to an external target.
pub(crate) fn absolutize(path: &Path) -> std::io::Result<PathBuf> {
    Ok(logical_normalize(&std::path::absolute(path)?))
}

/// Collapse `.` / `..` components without touching the filesystem.
///
/// `..` pops the last `Normal` component. Against a root or prefix it
/// is preserved verbatim (so `/..` stays `/..` rather than silently
/// lying about what the path refers to).
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

/// Find every double-quoted string literal in `content` ending in `.rkt`.
///
/// State machine over chars: skips `;`-to-EOL comments (so doc-comment
/// examples like `(require "../runtime/foo.rkt")` don't become fake
/// require targets), then scans for `"..."` literals and yields the ones
/// whose tail is `.rkt`. Handles `\"` and `\\` escapes inside strings.
/// Block comments (`#|...|#`) and datum comments (`#;`) are uncommon in
/// generated or hand-written racket files and are not parsed; if they
/// ever start carrying `.rkt`-tailed string literals, extend here.
fn scan_rkt_string_literals(content: &str) -> Vec<&str> {
    let bytes = content.as_bytes();
    let mut out = Vec::new();
    let mut i = 0;
    let n = bytes.len();
    while i < n {
        if bytes[i] == b';' {
            while i < n && bytes[i] != b'\n' {
                i += 1;
            }
            continue;
        }
        if bytes[i] == b'"' {
            let start = i + 1;
            let mut j = start;
            let mut escaped = false;
            while j < n {
                let c = bytes[j];
                if escaped {
                    escaped = false;
                } else if c == b'\\' {
                    escaped = true;
                } else if c == b'"' {
                    break;
                }
                j += 1;
            }
            if j < n {
                let lit = &content[start..j];
                if lit.ends_with(".rkt") {
                    out.push(lit);
                }
                i = j + 1;
                continue;
            }
        }
        i += 1;
    }
    out
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::fs;
    use tempfile::TempDir;

    fn write(dir: &Path, rel: &str, content: &str) -> PathBuf {
        let p = dir.join(rel);
        fs::create_dir_all(p.parent().unwrap()).unwrap();
        fs::write(&p, content).unwrap();
        p
    }

    #[test]
    fn scans_string_literals_ending_in_rkt() {
        let lits = scan_rkt_string_literals(
            r#"(require ffi/unsafe
                       "../runtime/objc-base.rkt"
                       "../runtime/coerce.rkt")"#,
        );
        assert_eq!(
            lits,
            vec!["../runtime/objc-base.rkt", "../runtime/coerce.rkt"]
        );
    }

    #[test]
    fn ignores_strings_without_rkt_extension() {
        let lits = scan_rkt_string_literals(r#"(displayln "hello world")"#);
        assert!(lits.is_empty());
    }

    #[test]
    fn ignores_collection_paths() {
        // ffi/unsafe is a symbol, not a string — never picked up.
        let lits = scan_rkt_string_literals("(require ffi/unsafe racket/format)");
        assert!(lits.is_empty());
    }

    #[test]
    fn handles_multiple_requires() {
        let lits = scan_rkt_string_literals(
            r#"(require "a.rkt")
               (require "b.rkt" "c.rkt")"#,
        );
        assert_eq!(lits, vec!["a.rkt", "b.rkt", "c.rkt"]);
    }

    #[test]
    fn skips_rkt_literals_inside_line_comments() {
        // A doc-comment example like the one in runtime/objc-interop.rkt
        // must not be treated as a require target.
        let lits = scan_rkt_string_literals(
            r#";; Consumers write `(require "../runtime/objc-interop.rkt")` instead.
(require "../runtime/real-dep.rkt")"#,
        );
        assert_eq!(lits, vec!["../runtime/real-dep.rkt"]);
    }

    #[test]
    fn semicolon_inside_string_stays_in_string() {
        // A `;` inside a string literal must not enter comment mode —
        // the string literal scanner takes precedence.
        let lits = scan_rkt_string_literals(r#"(require "path;foo.rkt" "good.rkt")"#);
        assert_eq!(lits, vec!["path;foo.rkt", "good.rkt"]);
    }

    #[test]
    fn handles_escaped_quotes() {
        // Path contains a literal escaped quote — not realistic, but we
        // shouldn't trip on it.
        let lits = scan_rkt_string_literals(r#"(require "weird\"name.rkt" "normal.rkt")"#);
        assert_eq!(lits, vec![r#"weird\"name.rkt"#, "normal.rkt"]);
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
    fn collect_walks_transitively() {
        let dir = TempDir::new().unwrap();
        let root = dir.path();

        write(root, "apps/my/my.rkt", r#"(require "../../runtime/a.rkt")"#);
        write(
            root,
            "runtime/a.rkt",
            r#"(require "b.rkt" "../generated/c.rkt")"#,
        );
        write(root, "runtime/b.rkt", "");
        write(root, "generated/c.rkt", "");

        let deps = collect_dependencies(&root.join("apps/my/my.rkt"), root).unwrap();
        assert_eq!(
            rel_names(&deps, root),
            vec![
                "apps/my/my.rkt".to_string(),
                "generated/c.rkt".to_string(),
                "runtime/a.rkt".to_string(),
                "runtime/b.rkt".to_string(),
            ]
        );
    }

    #[test]
    fn collect_handles_cycles() {
        let dir = TempDir::new().unwrap();
        let root = dir.path();

        write(root, "a.rkt", r#"(require "b.rkt")"#);
        write(root, "b.rkt", r#"(require "a.rkt")"#);

        let deps = collect_dependencies(&root.join("a.rkt"), root).unwrap();
        assert_eq!(deps.len(), 2);
    }

    #[test]
    fn collect_rejects_requires_outside_root() {
        let dir = TempDir::new().unwrap();
        let root = dir.path().join("project");
        let outside = dir.path().join("other");
        fs::create_dir_all(&root).unwrap();
        fs::create_dir_all(&outside).unwrap();

        write(&outside, "x.rkt", "");
        write(&root, "entry.rkt", r#"(require "../other/x.rkt")"#);

        let err = collect_dependencies(&root.join("entry.rkt"), &root).unwrap_err();
        match err {
            BundleError::RequireOutsideRoot { .. } => {}
            other => panic!("expected RequireOutsideRoot, got {other:?}"),
        }
    }

    /// Modaliser-Racket's layout: an in-tree directory (`bindings/`) is a
    /// symlink pointing outside the project root to APIAnyware's
    /// generated bindings. The walker must accept this and preserve the
    /// logical (in-tree) path in its returned set, so the copy step
    /// produces a self-contained bundle without leaking the external
    /// target path into the result.
    #[test]
    fn collect_walks_through_symlinked_subdir_pointing_outside_root() {
        let dir = TempDir::new().unwrap();
        let project = dir.path().join("project");
        let external = dir.path().join("external");
        fs::create_dir_all(&project).unwrap();
        fs::create_dir_all(&external).unwrap();

        write(
            &project,
            "entry.rkt",
            r#"(require "bindings/runtime/a.rkt")"#,
        );
        write(&external, "runtime/a.rkt", r#"(require "b.rkt")"#);
        write(&external, "runtime/b.rkt", "");

        std::os::unix::fs::symlink(&external, project.join("bindings")).unwrap();

        let deps = collect_dependencies(&project.join("entry.rkt"), &project).unwrap();

        assert_eq!(
            rel_names(&deps, &project),
            vec![
                "bindings/runtime/a.rkt".to_string(),
                "bindings/runtime/b.rkt".to_string(),
                "entry.rkt".to_string(),
            ]
        );

        for p in &deps {
            assert!(
                !p.starts_with(&external),
                "leaked external path into deps set: {p:?}"
            );
        }
    }

    /// Requires that traverse **upward** across a symlink boundary must
    /// resolve to the logical location in the project, not to the
    /// external target's siblings. Example: `bindings/runtime/x.rkt`
    /// requires `"../other/y.rkt"` → logical = `bindings/other/y.rkt`,
    /// which is under the project root even though the underlying file
    /// lives at `$external/other/y.rkt`.
    #[test]
    fn collect_preserves_logical_path_on_parent_traversal_through_symlink() {
        let dir = TempDir::new().unwrap();
        let project = dir.path().join("project");
        let external = dir.path().join("external");
        fs::create_dir_all(&project).unwrap();
        fs::create_dir_all(&external).unwrap();

        write(
            &project,
            "entry.rkt",
            r#"(require "bindings/runtime/x.rkt")"#,
        );
        write(&external, "runtime/x.rkt", r#"(require "../other/y.rkt")"#);
        write(&external, "other/y.rkt", "");

        std::os::unix::fs::symlink(&external, project.join("bindings")).unwrap();

        let deps = collect_dependencies(&project.join("entry.rkt"), &project).unwrap();

        assert_eq!(
            rel_names(&deps, &project),
            vec![
                "bindings/other/y.rkt".to_string(),
                "bindings/runtime/x.rkt".to_string(),
                "entry.rkt".to_string(),
            ]
        );
    }

    #[test]
    fn logical_normalize_resolves_dot_and_dotdot() {
        assert_eq!(
            logical_normalize(Path::new("/a/b/./c/../d")),
            PathBuf::from("/a/b/d"),
        );
    }

    #[test]
    fn logical_normalize_preserves_dotdot_at_root() {
        assert_eq!(logical_normalize(Path::new("/..")), PathBuf::from("/.."));
    }
}
