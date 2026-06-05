//! Compute an app's binding-library **compile closure** in topological order.
//!
//! `gxc -exe` does **not** recursively compile the modules an entry imports
//! (app README; spec §3) — they must already be compiled into the
//! `GERBIL_PATH` cache. So the bundler walks the closure itself: starting
//! from the app's `(import …)` form, it follows every `:gerbil-bindings/…`
//! reference transitively and returns the `.ss` files ordered so each
//! module's dependencies precede it (the order `gxc -O` wants).
//!
//! The closure for a typical app =
//!   runtime modules (`runtime/ffi`, `runtime/native-core`, `runtime/objc`,
//!   `runtime/cocoa`) + the shared `generics` module + each imported class
//!   module's superclass chain (e.g. `nstextfield → nscontrol → nsview →
//!   nsresponder`), all terminating at the leaf modules with no
//!   `:gerbil-bindings/` imports of their own (`ffi`, `generics`, the
//!   constant-only `enums`).
//!
//! Only `:gerbil-bindings/…` references matter: `:std/foreign`,
//! `:std/generic`, `:gerbil/gambit` and the like are part of the gerbil
//! distribution and are already compiled — they are not in the closure.
//!
//! The walk is **pure Rust** (no shell-out to gerbil): the import syntax the
//! emitter writes is a flat list of module references, far simpler than the
//! R6RS wrapper forms (`only`/`except`/`prefix`/`rename`) that made chez's
//! dep walker shell out to chez's own reader.

use std::collections::HashSet;
use std::path::{Path, PathBuf};

use crate::bundle::BundleError;

/// The package prefix every generated/runtime binding module is referenced
/// by (`(package: gerbil-bindings)` in `lib/gerbil.pkg`). A reference
/// `:gerbil-bindings/appkit/nswindow` maps to `<lib_root>/appkit/nswindow.ss`.
const PACKAGE_PREFIX: &str = ":gerbil-bindings/";

/// Compute the transitive compile closure of `entry`, in topological order
/// (dependencies before dependents), as absolute `.ss` paths under
/// `lib_root`. The app entry itself is **not** included — it is linked
/// separately by `gxc -exe`; only the modules it (transitively) imports are.
///
/// `lib_root` is the `gerbil-bindings` package root (`<source_root>/lib`).
pub fn collect_closure(entry: &Path, lib_root: &Path) -> Result<Vec<PathBuf>, BundleError> {
    let source = std::fs::read_to_string(entry)?;
    let roots = resolve_references(&parse_gerbil_imports(&source), entry, lib_root)?;

    let mut order = Vec::new();
    let mut visited = HashSet::new();
    let mut on_stack = HashSet::new();
    for root in roots {
        visit(&root, lib_root, &mut order, &mut visited, &mut on_stack)?;
    }
    Ok(order)
}

/// Depth-first post-order visit: append a module to `order` only after all
/// of its dependencies have been appended, yielding a deps-first topological
/// order. `on_stack` detects the (illegal) import cycle.
fn visit(
    module: &Path,
    lib_root: &Path,
    order: &mut Vec<PathBuf>,
    visited: &mut HashSet<PathBuf>,
    on_stack: &mut HashSet<PathBuf>,
) -> Result<(), BundleError> {
    if visited.contains(module) {
        return Ok(());
    }
    if !on_stack.insert(module.to_path_buf()) {
        return Err(BundleError::ImportCycle(module.to_path_buf()));
    }

    let source = std::fs::read_to_string(module)?;
    let deps = resolve_references(&parse_gerbil_imports(&source), module, lib_root)?;
    for dep in deps {
        visit(&dep, lib_root, order, visited, on_stack)?;
    }

    on_stack.remove(module);
    visited.insert(module.to_path_buf());
    order.push(module.to_path_buf());
    Ok(())
}

/// Map each `:gerbil-bindings/<rel>` reference to `<lib_root>/<rel>.ss`,
/// erroring if the file does not exist.
fn resolve_references(
    references: &[String],
    referrer: &Path,
    lib_root: &Path,
) -> Result<Vec<PathBuf>, BundleError> {
    references
        .iter()
        .map(|rel| {
            let path = lib_root.join(format!("{rel}.ss"));
            if path.is_file() {
                Ok(path)
            } else {
                Err(BundleError::ImportNotFound {
                    reference: format!("{PACKAGE_PREFIX}{rel}"),
                    referrer: referrer.to_path_buf(),
                    lib_root: lib_root.to_path_buf(),
                    expected: path,
                })
            }
        })
        .collect()
}

/// Extract the `:gerbil-bindings/…` module references from a source file's
/// `(import …)` forms, returning each reference's path *relative to the
/// package* (the part after `:gerbil-bindings/`), de-duplicated in
/// first-seen order.
///
/// Robustness notes:
/// - Line comments (`; …`) are stripped first so a prose mention like
///   `;; declared once in :gerbil-bindings/generics` in the module body is
///   never mistaken for a dependency.
/// - References are collected only from inside balanced `(import …)` forms,
///   not the whole file — the same defence against body references.
/// - `(import: …)` re-export forms inside `(export …)` are harmless: they
///   name modules already in the import form, so collecting from them only
///   ever yields duplicates (dropped by the de-dup).
pub fn parse_gerbil_imports(source: &str) -> Vec<String> {
    let stripped = strip_line_comments(source);
    let mut refs = Vec::new();
    let mut seen = HashSet::new();
    for form in import_forms(&stripped) {
        for r in gerbil_refs_in(&form) {
            if seen.insert(r.clone()) {
                refs.push(r);
            }
        }
    }
    refs
}

/// Remove `;`-to-end-of-line comments. Good enough for the generated and
/// hand-written binding modules: their `(import …)` forms contain no string
/// or char literals, so no real token is lost.
fn strip_line_comments(source: &str) -> String {
    source
        .lines()
        .map(|line| match line.find(';') {
            Some(i) => &line[..i],
            None => line,
        })
        .collect::<Vec<_>>()
        .join("\n")
}

/// Return the text of each `(import …)` form in `source`. An import form is
/// `(import` followed immediately by whitespace or `(` — this excludes the
/// `(import: …)` re-export head (a `:` follows `import`) and any longer
/// identifier that merely starts with `import`.
fn import_forms(source: &str) -> Vec<String> {
    let bytes = source.as_bytes();
    let mut forms = Vec::new();
    let mut search_from = 0;
    while let Some(rel) = source[search_from..].find("(import") {
        let open = search_from + rel;
        let after = open + "(import".len();
        let next = bytes.get(after).copied();
        let is_form_head = matches!(next, Some(b) if b.is_ascii_whitespace() || b == b'(');
        if is_form_head {
            if let Some(form) = balanced_form(source, open) {
                let end = open + form.len();
                forms.push(form);
                search_from = end;
                continue;
            }
        }
        search_from = after;
    }
    forms
}

/// Given `source` and the index of an opening `(`, return the substring
/// spanning the balanced paren form (inclusive of both parens). Returns
/// `None` if the parens never balance.
fn balanced_form(source: &str, open: usize) -> Option<String> {
    let mut depth = 0usize;
    for (i, c) in source[open..].char_indices() {
        match c {
            '(' => depth += 1,
            ')' => {
                depth -= 1;
                if depth == 0 {
                    return Some(source[open..open + i + 1].to_string());
                }
            }
            _ => {}
        }
    }
    None
}

/// Collect the package-relative references from a single import form's text:
/// for each `:gerbil-bindings/<rel>` token, yield `<rel>`.
fn gerbil_refs_in(form: &str) -> Vec<String> {
    let mut out = Vec::new();
    let mut rest = form;
    while let Some(i) = rest.find(PACKAGE_PREFIX) {
        let after = &rest[i + PACKAGE_PREFIX.len()..];
        let rel: String = after
            .chars()
            .take_while(|&c| c.is_ascii_alphanumeric() || c == '/' || c == '-' || c == '_')
            .collect();
        if !rel.is_empty() {
            out.push(rel);
        }
        rest = &after[..];
    }
    out
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::fs;
    use tempfile::TempDir;

    #[test]
    fn parses_flat_reference_list() {
        let src = "\
(import :gerbil-bindings/runtime/objc
        :gerbil-bindings/appkit/nswindow
        :gerbil-bindings/appkit/enums)
(export main)
";
        assert_eq!(
            parse_gerbil_imports(src),
            vec!["runtime/objc", "appkit/nswindow", "appkit/enums"]
        );
    }

    #[test]
    fn ignores_std_and_gambit_imports() {
        let src = "\
(import :std/foreign
        (rename-in :std/generic (defgeneric g:defgeneric) (defmethod g:defmethod))
        :gerbil/gambit
        :gerbil-bindings/generics
        :gerbil-bindings/appkit/nsresponder
        :gerbil-bindings/runtime/objc)
(export NSWindow)
";
        // The rename-in form closes early — a naive line-range parser would
        // miss everything after it; the balanced-form scan does not.
        assert_eq!(
            parse_gerbil_imports(src),
            vec!["generics", "appkit/nsresponder", "runtime/objc"]
        );
    }

    #[test]
    fn ignores_body_comment_references() {
        let src = "\
(import :gerbil-bindings/runtime/objc)
(export foo)
;; the generic is declared once in :gerbil-bindings/generics and extended here
(define (foo) 1)
";
        assert_eq!(parse_gerbil_imports(src), vec!["runtime/objc"]);
    }

    #[test]
    fn handles_export_import_reexport_form_without_extra_dep() {
        // objc.ss shape: re-exports ffi via (export (import: …)); ffi is
        // already a real import, so it appears once.
        let src = "\
(import :std/foreign
        :gerbil/gambit
        :gerbil-bindings/runtime/ffi
        :gerbil-bindings/runtime/native-core)
(export (import: :gerbil-bindings/runtime/ffi))
(define x 1)
";
        assert_eq!(
            parse_gerbil_imports(src),
            vec!["runtime/ffi", "runtime/native-core"]
        );
    }

    #[test]
    fn constant_only_module_has_no_imports() {
        // enums.ss: a bare (export …), no import form at all.
        let src = "\
;;; Generated enum definitions for AppKit — do not edit
(export NSWindowStyleMaskTitled NSWindowStyleMaskClosable)
(define NSWindowStyleMaskTitled 1)
";
        assert_eq!(parse_gerbil_imports(src), Vec::<String>::new());
    }

    /// Build a miniature lib/ tree mirroring the real dependency shape and
    /// assert the closure is a valid topological order.
    #[test]
    fn collect_closure_orders_dependencies_first() {
        let dir = TempDir::new().unwrap();
        let lib = dir.path().join("lib");
        let mk = |rel: &str, body: &str| {
            let p = lib.join(format!("{rel}.ss"));
            fs::create_dir_all(p.parent().unwrap()).unwrap();
            fs::write(&p, body).unwrap();
        };
        mk("runtime/ffi", "(import :std/foreign)\n(export ffi)\n");
        mk(
            "runtime/native-core",
            "(import :gerbil-bindings/runtime/ffi)\n(export nc)\n",
        );
        mk(
            "runtime/objc",
            "(import :gerbil-bindings/runtime/ffi :gerbil-bindings/runtime/native-core)\n(export objc)\n",
        );
        mk("generics", "(import :std/generic)\n(export g)\n");
        mk(
            "appkit/nsresponder",
            "(import :gerbil-bindings/generics :gerbil-bindings/runtime/objc)\n(export r)\n",
        );
        mk(
            "appkit/nsview",
            "(import :gerbil-bindings/generics :gerbil-bindings/appkit/nsresponder :gerbil-bindings/runtime/objc)\n(export v)\n",
        );

        let entry = dir.path().join("app.ss");
        fs::write(
            &entry,
            "(import :gerbil-bindings/appkit/nsview :gerbil-bindings/runtime/objc)\n(main)\n",
        )
        .unwrap();

        let order = collect_closure(&entry, &lib).unwrap();
        let pos = |rel: &str| {
            order
                .iter()
                .position(|p| p == &lib.join(format!("{rel}.ss")))
                .unwrap_or_else(|| panic!("{rel} missing from closure"))
        };

        // Every edge: dependency strictly before dependent.
        assert!(pos("runtime/ffi") < pos("runtime/native-core"));
        assert!(pos("runtime/native-core") < pos("runtime/objc"));
        assert!(pos("runtime/ffi") < pos("runtime/objc"));
        assert!(pos("generics") < pos("appkit/nsresponder"));
        assert!(pos("runtime/objc") < pos("appkit/nsresponder"));
        assert!(pos("appkit/nsresponder") < pos("appkit/nsview"));
        // The app entry itself is not part of the closure.
        assert!(!order.iter().any(|p| p == &entry));
        // No duplicates (objc reached via two paths appears once).
        let unique: HashSet<_> = order.iter().collect();
        assert_eq!(unique.len(), order.len());
    }

    #[test]
    fn missing_import_is_an_error() {
        let dir = TempDir::new().unwrap();
        let lib = dir.path().join("lib");
        fs::create_dir_all(&lib).unwrap();
        let entry = dir.path().join("app.ss");
        fs::write(&entry, "(import :gerbil-bindings/appkit/nope)\n(main)\n").unwrap();

        let err = collect_closure(&entry, &lib).unwrap_err();
        assert!(matches!(err, BundleError::ImportNotFound { .. }));
    }

    #[test]
    fn import_cycle_is_detected() {
        let dir = TempDir::new().unwrap();
        let lib = dir.path().join("lib");
        fs::create_dir_all(&lib).unwrap();
        fs::write(
            lib.join("a.ss"),
            "(import :gerbil-bindings/b)\n(export a)\n",
        )
        .unwrap();
        fs::write(
            lib.join("b.ss"),
            "(import :gerbil-bindings/a)\n(export b)\n",
        )
        .unwrap();
        let entry = dir.path().join("app.ss");
        fs::write(&entry, "(import :gerbil-bindings/a)\n(main)\n").unwrap();

        let err = collect_closure(&entry, &lib).unwrap_err();
        assert!(matches!(err, BundleError::ImportCycle(_)));
    }
}
