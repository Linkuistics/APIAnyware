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
//! `APIAnyware/targets/racket/bindings/macos/` is the motivating
//! case). Reading file content still transparently follows symlinks,
//! because `fs::read_to_string` and `fs::copy` do.

use std::collections::HashSet;
use std::fs;
use std::path::{Component, Path, PathBuf};

use crate::bundle::BundleError;

/// The source tree(s) the bundle's `racket-app/` mirrors, resolved in
/// **logical** path space.
///
/// The bundle layout is always a single colocated tree —
/// `racket-app/{apps,runtime,generated,lib}` — and the sample apps' relative
/// `(require "../../{generated,runtime}/…")` lines are written against that
/// shape. [`SourceRoots`] is what lets the bundler honour those requires
/// whether the source is genuinely colocated (Modaliser-style, [`single`]) or
/// physically split across the §18 domain tree ([`split`]).
///
/// In the split case the **logical root is the bindings root** — `runtime/`,
/// `generated/`, and `lib/` are already its real children, so they need no
/// redirect. The one redirect is `<logical_root>/apps/…`, which maps to the
/// physically-separate app-implementations tree. Everything the walker does is
/// in logical space; [`to_physical`] is consulted only to read or stat a file.
///
/// [`single`]: SourceRoots::single
/// [`split`]: SourceRoots::split
/// [`to_physical`]: SourceRoots::to_physical
#[derive(Debug, Clone)]
pub struct SourceRoots {
    /// The logical colocated root the bundle's `racket-app/` mirrors.
    logical_root: PathBuf,
    /// Physical home of the `apps/` subtree when it is split out from the
    /// bindings root; `None` for a genuinely colocated single root.
    apps_root: Option<PathBuf>,
}

impl SourceRoots {
    /// A single colocated root (Modaliser-style projects, or any tree whose
    /// `apps/`, `runtime/`, `generated/`, `lib/` are real siblings). Logical
    /// and physical paths are identical.
    pub fn single(root: &Path) -> Result<Self, BundleError> {
        Ok(Self {
            logical_root: absolutize(root)
                .map_err(|e| BundleError::ResolveSourceRoot(root.to_path_buf(), e))?,
            apps_root: None,
        })
    }

    /// The §18 split: app-implementations under `apps_root`, the binding
    /// package (runtime / generated / lib) under `bindings_root`. The logical
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

    /// The logical root the bundle layout mirrors (absolute).
    pub(crate) fn logical_root(&self) -> &Path {
        &self.logical_root
    }

    /// Map a logical path (under [`logical_root`]) to the physical file on
    /// disk. Identity for a single root; for a split root, logical `apps/…`
    /// paths redirect to the apps root and everything else stays put.
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
}

/// Transitive set of `.rkt` files reachable from `entry`, returned as
/// absolute **logical** paths under the source root.
///
/// `source_root` is the directory the generated bundle's `racket-app/`
/// will mirror — the project root for a Modaliser-style layout whose entry
/// lives at `main.rkt`. Any discovered file whose logical path escapes
/// `source_root` is rejected as a bundle-layout error. For the §18 split
/// (apps and bindings in separate trees) use [`collect_dependencies_in`] with
/// a [`SourceRoots::split`].
pub fn collect_dependencies(
    entry: &Path,
    source_root: &Path,
) -> Result<HashSet<PathBuf>, BundleError> {
    collect_dependencies_in(entry, &SourceRoots::single(source_root)?)
}

/// Transitive set of `.rkt` files reachable from `entry` (a **logical** path
/// under `roots.logical_root()`), returned as absolute logical paths.
///
/// Resolution is in logical space; the walker reads and stats each file
/// through [`SourceRoots::to_physical`], so a split apps-root / bindings-root
/// layout walks exactly as a colocated one would.
pub fn collect_dependencies_in(
    entry: &Path,
    roots: &SourceRoots,
) -> Result<HashSet<PathBuf>, BundleError> {
    let abs_root = roots.logical_root().to_path_buf();
    let abs_entry =
        absolutize(entry).map_err(|e| BundleError::ResolveEntry(entry.to_path_buf(), e))?;

    if !abs_entry.starts_with(&abs_root) {
        return Err(BundleError::EntryOutsideRoot {
            entry: abs_entry,
            root: abs_root,
        });
    }

    if !roots.to_physical(&abs_entry).exists() {
        return Err(BundleError::EntryMissing { entry: abs_entry });
    }

    let mut visited: HashSet<PathBuf> = HashSet::new();
    let mut queue: Vec<PathBuf> = vec![abs_entry];

    while let Some(file) = queue.pop() {
        if !visited.insert(file.clone()) {
            continue;
        }

        let physical = roots.to_physical(&file);
        let content = fs::read_to_string(&physical)
            .map_err(|e| BundleError::ReadSource(physical.clone(), e))?;
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

            if !roots.to_physical(&logical).exists() {
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

    /// The §18 split: the entry lives under the apps root while its
    /// `(require "../../{generated,runtime}/…")` lines (written against the
    /// pre-split colocated layout) must resolve into the *separate* bindings
    /// root. The virtual colocated root ([`SourceRoots::split`]) makes that
    /// transparent — deps come back as logical paths under the bindings root,
    /// each mapping to the right physical file. This is the native replacement
    /// for the directory-symlink fixture the bundler tests used to stitch.
    #[test]
    fn collect_in_split_resolves_across_apps_and_bindings_roots() {
        let dir = TempDir::new().unwrap();
        let apps = dir.path().join("app-implementations/macos");
        let bindings = dir.path().join("bindings/macos");

        // Entry with the real sample-app require shape.
        write(
            &apps,
            "hello/hello.rkt",
            "(require \"../../generated/appkit/nswindow.rkt\"\n\
             \"../../runtime/objc-base.rkt\")",
        );
        // A transitive require inside the bindings tree, traversing up and back
        // down within the bindings root.
        write(
            &bindings,
            "generated/appkit/nswindow.rkt",
            "(require \"../../runtime/coerce.rkt\")",
        );
        write(&bindings, "runtime/objc-base.rkt", "");
        write(&bindings, "runtime/coerce.rkt", "");

        let roots = SourceRoots::split(&apps, &bindings).unwrap();
        let entry = roots.logical_root().join("apps/hello/hello.rkt");
        let deps = collect_dependencies_in(&entry, &roots).unwrap();

        // Deps are logical paths under the bindings root (= the logical root),
        // which is exactly the colocated shape the bundle's racket-app/ mirrors.
        assert_eq!(
            rel_names(&deps, roots.logical_root()),
            vec![
                "apps/hello/hello.rkt".to_string(),
                "generated/appkit/nswindow.rkt".to_string(),
                "runtime/coerce.rkt".to_string(),
                "runtime/objc-base.rkt".to_string(),
            ]
        );

        // Every logical dep maps to a real file across the two physical roots.
        for d in &deps {
            assert!(
                roots.to_physical(d).is_file(),
                "physical file missing for logical {d:?}"
            );
        }
        // The entry's physical home is the apps root, not the bindings root.
        let entry_phys = roots.to_physical(&entry);
        assert!(entry_phys.starts_with(&apps), "entry must map to apps root");
        assert!(entry_phys.is_file());
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
