//! The shared global generics module (`generics.ss`) — the cross-module
//! generic-unification fix (escalated from leaf 050/040).
//!
//! ## The problem
//!
//! The dual-surface emission (ADR-0020) gives each class a `:std/generic` surface:
//! `(g:defmethod (count (o NSArray)) …)`. Originally each class module also
//! *declared* its own `(g:defgeneric count)`. Two **unrelated** classes that
//! happen to share a selector name (`count`, `title`, `name`, …) therefore each
//! exported a **distinct** generic of the same name from a **different** module;
//! when the framework facade re-exported both, those coincidental collisions
//! clashed (ambiguous re-export) — and even absent the clash, the two classes'
//! methods would hang off *different* generic objects, so dispatch would split.
//! This is unsound, and it only surfaces at the full emitted-framework build
//! (single-class runtime smokes can't see it).
//!
//! ## The fix
//!
//! Declare every distinct instance-surface selector **once**, in one shared module
//! at the package root (`:gerbil-bindings/generics`), and have every class module
//! *import* it and extend the single shared generic with `g:defmethod`. One
//! selector → one generic → no facade clash, and all classes' methods dispatch on
//! the same generic. This is the exact analogue of the cross-framework
//! [`crate::class_graph::ClassRegistry`]: a whole-program fact computed once, in
//! the CLI pre-pass, and threaded into per-framework emission.
//!
//! The module is written once by the generate pipeline (not per-framework
//! `emit_framework`), via [`write_global_generics_module`], alongside the
//! `ClassRegistry` build.

use std::collections::BTreeSet;
use std::io;
use std::path::Path;

use apianyware_macos_emit::code_writer::CodeWriter;
use apianyware_macos_emit::enrichment::class_error_selectors;
use apianyware_macos_emit::write_line;
use apianyware_macos_types::ir::Framework;

use crate::emit_class::{class_surface_selectors, GENERIC_IMPORT};

/// The on-disk stem + import-path tail of the shared generics module. Lives at the
/// package root next to the framework facades, so its import path is
/// `:gerbil-bindings/generics` (see `emit_class::GENERICS_MODULE_IMPORT`).
pub const GENERICS_MODULE_STEM: &str = "generics";

/// The union of every distinct instance-surface selector across all loaded
/// frameworks, sorted and deduped — one `g:defgeneric` per entry. Computed with
/// each class's enrichment error-selectors so it stays in lock-step with what the
/// per-class surface emits.
pub fn collect_global_surface_selectors(frameworks: &[&Framework]) -> Vec<String> {
    let mut set: BTreeSet<String> = BTreeSet::new();
    for fw in frameworks {
        for cls in &fw.classes {
            let error_selectors = class_error_selectors(fw.enrichment.as_ref(), &cls.name);
            for sel in class_surface_selectors(cls, &error_selectors) {
                set.insert(sel);
            }
        }
    }
    set.into_iter().collect()
}

/// Render the shared `generics.ss` module text: import `:std/generic` (renamed),
/// declare one `(g:defgeneric <sel>)` per global selector, and export them all.
/// An empty selector set yields `None` — there is nothing to declare and no class
/// will import the module (so it must not be written, or the import would dangle).
pub fn generate_generics_module(selectors: &[String]) -> Option<String> {
    if selectors.is_empty() {
        return None;
    }
    let mut w = CodeWriter::new();
    w.line(";;; Generated gerbil-bindings global generics — do not edit");
    w.line(";; One :std/generic generic per distinct instance-surface selector across");
    w.line(";; every framework, declared ONCE so a selector shared by unrelated classes");
    w.line(";; is a single generic they all extend — not N colliding per-module generics");
    w.line(";; that clash at the framework facade.");
    write_line!(w, "(import {})", GENERIC_IMPORT);

    w.line("(export");
    for sel in selectors {
        write_line!(w, "  {}", sel);
    }
    w.line("  )");
    w.blank_line();

    for sel in selectors {
        write_line!(w, "(g:defgeneric {})", sel);
    }
    Some(w.finish())
}

/// Compute the global selector set and write `generics.ss` into the gerbil package
/// root (`output_dir`). Called once by the generate pipeline, before/independent of
/// the per-framework loop. A no-op when no framework has an instance surface.
pub fn write_global_generics_module(
    frameworks: &[&Framework],
    output_dir: &Path,
) -> io::Result<bool> {
    let selectors = collect_global_surface_selectors(frameworks);
    match generate_generics_module(&selectors) {
        None => Ok(false),
        Some(content) => {
            std::fs::create_dir_all(output_dir)?;
            std::fs::write(output_dir.join(format!("{GENERICS_MODULE_STEM}.ss")), content)?;
            Ok(true)
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use apianyware_macos_types::ir::{Class, Method};
    use apianyware_macos_types::type_ref::{TypeRef, TypeRefKind};

    fn method(sel: &str, ret: &str) -> Method {
        Method {
            selector: sel.into(),
            class_method: false,
            init_method: false,
            params: vec![],
            return_type: TypeRef {
                nullable: false,
                kind: TypeRefKind::Primitive { name: ret.into() },
            },
            deprecated: false,
            variadic: false,
            source: None,
            provenance: None,
            doc_refs: None,
            origin: None,
            category: None,
            overrides: None,
            returns_retained: None,
            satisfies_protocol: None,
        }
    }

    fn class_with_methods(name: &str, methods: Vec<Method>) -> Class {
        Class {
            name: name.into(),
            superclass: "NSObject".into(),
            protocols: vec![],
            properties: vec![],
            methods,
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
        }
    }

    fn fw_with(name: &str, classes: Vec<Class>) -> Framework {
        Framework {
            format_version: "1.0".into(),
            checkpoint: "enriched".into(),
            name: name.into(),
            sdk_version: None,
            collected_at: None,
            depends_on: vec![],
            skipped_symbols: vec![],
            classes,
            protocols: vec![],
            enums: vec![],
            structs: vec![],
            functions: vec![],
            constants: vec![],
            class_annotations: vec![],
            api_patterns: vec![],
            enrichment: None,
            verification: None,
        }
    }

    #[test]
    fn shared_selector_declared_once_across_unrelated_classes() {
        // Two unrelated classes in two frameworks both expose `count` (a method
        // whose kebab surface selector is `count`). The global set must hold a
        // SINGLE `count`, declared once.
        let foundation = fw_with(
            "Foundation",
            vec![class_with_methods("NSArray", vec![method("count", "uint64")])],
        );
        let coredata = fw_with(
            "CoreData",
            vec![class_with_methods(
                "NSFetchRequest",
                vec![method("count", "uint64")],
            )],
        );
        let refs = vec![&foundation, &coredata];
        let selectors = collect_global_surface_selectors(&refs);
        assert_eq!(
            selectors.iter().filter(|s| s.as_str() == "count").count(),
            1,
            "the shared selector is unified to a single global entry: {selectors:?}"
        );

        let module = generate_generics_module(&selectors).unwrap();
        assert_eq!(
            module.matches("(g:defgeneric count)").count(),
            1,
            "exactly one declaration site for the shared generic:\n{module}"
        );
        // The module imports :std/generic (renamed) and exports the generic name.
        assert!(module.contains("(rename-in :std/generic"));
        assert!(module.contains("(export"));
        assert!(module.contains("count"));
    }

    #[test]
    fn empty_program_writes_no_module() {
        let fw = fw_with("Empty", vec![]);
        let refs = vec![&fw];
        assert!(collect_global_surface_selectors(&refs).is_empty());
        assert!(generate_generics_module(&[]).is_none());

        let tmp = tempfile::tempdir().unwrap();
        let wrote = write_global_generics_module(&refs, tmp.path()).unwrap();
        assert!(!wrote);
        assert!(!tmp.path().join("generics.ss").exists());
    }

    #[test]
    fn write_emits_generics_file() {
        let foundation = fw_with(
            "Foundation",
            vec![class_with_methods("NSArray", vec![method("count", "uint64")])],
        );
        let refs = vec![&foundation];
        let tmp = tempfile::tempdir().unwrap();
        let wrote = write_global_generics_module(&refs, tmp.path()).unwrap();
        assert!(wrote);
        let body = std::fs::read_to_string(tmp.path().join("generics.ss")).unwrap();
        assert!(body.contains("(g:defgeneric count)"));
    }
}
