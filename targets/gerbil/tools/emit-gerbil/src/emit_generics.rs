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

use apianyware_emit::code_writer::CodeWriter;
use apianyware_emit::enrichment::class_error_selectors;
use apianyware_emit::write_line;
use apianyware_types::ir::Framework;

use crate::emit_class::{class_surface_selectors, GENERICS_MODULE_IMPORT, GENERIC_IMPORT};
use crate::protocol_registry::ProtocolRegistry;

/// The on-disk stem + import-path tail of the shared generics module. The facade
/// lives at the package root next to the framework facades (`generics.ss`, import
/// path `:gerbil-bindings/generics`), and its shards live in the sibling
/// `generics/` directory (`generics/NNN.ss`, import path
/// `:gerbil-bindings/generics/NNN`). See `emit_class::GENERICS_MODULE_IMPORT`.
pub const GENERICS_MODULE_STEM: &str = "generics";

/// Selectors per generics **shard** module. The monolithic `generics.ss`
/// (6,496 selectors → a ~54 MB macro-expanded Scheme unit) made Gambit's
/// `gsc -target C` pathologically slow — **superlinear in module size,
/// independent of `-O`** (a 37.8 MB unit ran >67 min unfinished; ADR-0023).
/// Sharding into bounded modules keeps each `gsc` unit small *and* lets the
/// shards compile in parallel (they have no cross-shard deps). Tunable: lower it
/// if a shard's `gsc` time is still too high (`gsc` may be worse than O(n²)).
pub const GENERICS_SHARD_SIZE: usize = 256;

/// The union of every distinct instance-surface selector across all loaded
/// frameworks, sorted and deduped — one `g:defgeneric` per entry. Computed with
/// each class's enrichment error-selectors **and** the cross-framework
/// [`ProtocolRegistry`] (built here over the same framework set the per-class
/// emission sees) so it stays in lock-step with what the per-class surface
/// emits — including conformed-protocol methods (leaf 120).
pub fn collect_global_surface_selectors(frameworks: &[&Framework]) -> Vec<String> {
    let protocols = ProtocolRegistry::from_framework_refs(frameworks);
    let mut set: BTreeSet<String> = BTreeSet::new();
    for fw in frameworks {
        for cls in &fw.classes {
            let error_selectors = class_error_selectors(fw.enrichment.as_ref(), &cls.name);
            for sel in class_surface_selectors(cls, &error_selectors, &protocols) {
                set.insert(sel);
            }
        }
    }
    set.into_iter().collect()
}

/// Render one generics **shard** module: import `:std/generic` (renamed), declare
/// one `(g:defgeneric <sel>)` per selector in this shard's slice, and export them.
/// A shard is never empty (callers chunk a non-empty selector set).
pub fn generate_shard_module(selectors: &[String]) -> String {
    let mut w = CodeWriter::new();
    w.line(";;; Generated gerbil-bindings generics shard — do not edit");
    w.line(";; One :std/generic generic per selector in this shard's slice of the");
    w.line(";; global instance-surface selector set. Sharded to bound each gsc unit");
    w.line(";; (ADR-0023); the facade :gerbil-bindings/generics re-exports every shard.");
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
    w.finish()
}

/// Render the facade `generics.ss`: import every shard and re-export it, so the
/// single import path `:gerbil-bindings/generics` presents the full global
/// generic set unchanged for class modules. Each selector is declared in exactly
/// one shard, so re-exporting all shards yields one generic per selector — the
/// cross-module unification invariant (ADR-0020) the monolith provided.
pub fn generate_facade_module(shard_count: usize) -> String {
    let mut w = CodeWriter::new();
    w.line(";;; Generated gerbil-bindings generics facade — do not edit");
    w.line(";; Re-exports every sharded generics module so :gerbil-bindings/generics");
    w.line(";; presents the full global generic set as one import. The shards");
    w.line(";; (generics/NNN.ss) bound each gsc compilation unit (ADR-0023).");

    w.line("(import");
    for i in 0..shard_count {
        write_line!(w, "  {GENERICS_MODULE_IMPORT}/{i:03}");
    }
    w.line("  )");

    w.line("(export");
    for i in 0..shard_count {
        write_line!(w, "  (import: {GENERICS_MODULE_IMPORT}/{i:03})");
    }
    w.line("  )");
    w.finish()
}

/// Compute the global selector set and write the sharded generics into the gerbil
/// package root (`output_dir`): the facade `generics.ss` plus `generics/NNN.ss`
/// shards of [`GENERICS_SHARD_SIZE`] selectors each. Called once by the generate
/// pipeline, before/independent of the per-framework loop. A no-op (returns
/// `false`, writes nothing) when no framework has an instance surface.
///
/// The `generics/` shard directory is cleared first so a regeneration with fewer
/// shards leaves no stale `generics/NNN.ss` behind.
pub fn write_global_generics_module(
    frameworks: &[&Framework],
    output_dir: &Path,
) -> io::Result<bool> {
    let selectors = collect_global_surface_selectors(frameworks);
    if selectors.is_empty() {
        return Ok(false);
    }

    let shard_dir = output_dir.join(GENERICS_MODULE_STEM);
    if shard_dir.exists() {
        std::fs::remove_dir_all(&shard_dir)?;
    }
    std::fs::create_dir_all(&shard_dir)?;

    let chunks: Vec<&[String]> = selectors.chunks(GENERICS_SHARD_SIZE).collect();
    for (i, chunk) in chunks.iter().enumerate() {
        std::fs::write(
            shard_dir.join(format!("{i:03}.ss")),
            generate_shard_module(chunk),
        )?;
    }

    std::fs::write(
        output_dir.join(format!("{GENERICS_MODULE_STEM}.ss")),
        generate_facade_module(chunks.len()),
    )?;
    Ok(true)
}

#[cfg(test)]
mod tests {
    use super::*;
    use apianyware_types::ir::{Class, Method};
    use apianyware_types::type_ref::{TypeRef, TypeRefKind};

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
            objc_exposed: true,
            swift_fn: None,
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
            objc_exposed: true,
            swift_name: None,
        }
    }

    fn fw_with(name: &str, classes: Vec<Class>) -> Framework {
        Framework {
            format_version: "1.0".into(),
            checkpoint: "resolved".into(),
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
            patterns: vec![],
            enrichment: None,
            verification: None,
        }
    }

    /// Read every shard file under `<root>/generics/` concatenated — the union of
    /// what all shards declare/export.
    fn read_all_shards(root: &Path) -> String {
        let mut all = String::new();
        let dir = root.join("generics");
        let mut entries: Vec<_> = std::fs::read_dir(&dir)
            .unwrap()
            .flatten()
            .map(|e| e.path())
            .collect();
        entries.sort();
        for p in entries {
            all.push_str(&std::fs::read_to_string(&p).unwrap());
        }
        all
    }

    #[test]
    fn shared_selector_declared_once_across_unrelated_classes() {
        // Two unrelated classes in two frameworks both expose `count` (a method
        // whose kebab surface selector is `count`). The global set must hold a
        // SINGLE `count`, declared once — across ALL shards, not per-module.
        let foundation = fw_with(
            "Foundation",
            vec![class_with_methods(
                "NSArray",
                vec![method("count", "uint64")],
            )],
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

        let tmp = tempfile::tempdir().unwrap();
        assert!(write_global_generics_module(&refs, tmp.path()).unwrap());
        let shards = read_all_shards(tmp.path());
        assert_eq!(
            shards.matches("(g:defgeneric count)").count(),
            1,
            "exactly one declaration site for the shared generic across shards:\n{shards}"
        );
        // Each shard imports :std/generic (renamed).
        assert!(shards.contains("(rename-in :std/generic"));
    }

    #[test]
    fn protocol_contributed_selectors_join_the_global_set() {
        // A conformed-protocol method flattened into all_methods (leaf 120)
        // gets a `{}`/generic surface, so its selector must be declared in the
        // shared generics module too — the registry is built from the same
        // framework set inside collect_global_surface_selectors.
        let mut cls = class_with_methods("SCNNode", vec![]);
        cls.protocols = vec!["SCNActionable".into()];
        let mut run_action = method("runAction:", "void");
        run_action.origin = Some("SCNActionable".into());
        run_action.params = vec![apianyware_types::ir::Param {
            name: "action".into(),
            param_type: TypeRef {
                nullable: false,
                kind: TypeRefKind::Id {
                    protocols: Vec::new(),
                },
            },
        }];
        cls.all_methods = vec![run_action];

        let mut fw = fw_with("SceneKit", vec![cls]);
        fw.protocols = vec![apianyware_types::ir::Protocol {
            name: "SCNActionable".into(),
            inherits: vec!["NSObject".into()],
            required_methods: vec![],
            optional_methods: vec![],
            properties: vec![],
            source: None,
            provenance: None,
            doc_refs: None,
            objc_exposed: true,
        }];

        let refs = vec![&fw];
        let selectors = collect_global_surface_selectors(&refs);
        assert!(
            selectors.contains(&"run-action".to_string()),
            "protocol-contributed surface selector in the global set: {selectors:?}"
        );
    }

    #[test]
    fn empty_program_writes_no_module() {
        let fw = fw_with("Empty", vec![]);
        let refs = vec![&fw];
        assert!(collect_global_surface_selectors(&refs).is_empty());

        let tmp = tempfile::tempdir().unwrap();
        let wrote = write_global_generics_module(&refs, tmp.path()).unwrap();
        assert!(!wrote);
        assert!(!tmp.path().join("generics.ss").exists());
        assert!(!tmp.path().join("generics").exists());
    }

    #[test]
    fn write_emits_facade_and_shards() {
        // Enough distinct selectors to span more than one shard, so the facade's
        // re-export of multiple shards is exercised.
        let n = GENERICS_SHARD_SIZE + 5;
        let methods: Vec<Method> = (0..n)
            .map(|i| method(&format!("sel{i:04}"), "uint64"))
            .collect();
        let foundation = fw_with("Foundation", vec![class_with_methods("NSThing", methods)]);
        let refs = vec![&foundation];
        let tmp = tempfile::tempdir().unwrap();
        assert!(write_global_generics_module(&refs, tmp.path()).unwrap());

        // Two shards (n = SHARD_SIZE + 5): generics/000.ss and generics/001.ss.
        assert!(tmp.path().join("generics/000.ss").is_file());
        assert!(tmp.path().join("generics/001.ss").is_file());
        assert!(!tmp.path().join("generics/002.ss").exists());

        // The facade imports and re-exports exactly those two shards.
        let facade = std::fs::read_to_string(tmp.path().join("generics.ss")).unwrap();
        assert!(facade.contains(":gerbil-bindings/generics/000"));
        assert!(facade.contains(":gerbil-bindings/generics/001"));
        assert!(facade.contains("(import:"));

        // Every selector is declared exactly once across the shards.
        let shards = read_all_shards(tmp.path());
        assert_eq!(shards.matches("(g:defgeneric sel0000)").count(), 1);
        assert_eq!(
            shards.matches("(g:defgeneric ").count(),
            n,
            "all {n} selectors declared once across the shards"
        );
    }

    #[test]
    fn regeneration_clears_stale_shards() {
        let tmp = tempfile::tempdir().unwrap();
        // First gen: many selectors -> several shards.
        let many: Vec<Method> = (0..GENERICS_SHARD_SIZE * 2 + 1)
            .map(|i| method(&format!("a{i:04}"), "uint64"))
            .collect();
        let big = fw_with("Foundation", vec![class_with_methods("NSBig", many)]);
        write_global_generics_module(&[&big], tmp.path()).unwrap();
        assert!(tmp.path().join("generics/002.ss").is_file());

        // Second gen: few selectors -> one shard. Stale 001/002 must be gone.
        let small = fw_with(
            "Foundation",
            vec![class_with_methods(
                "NSSmall",
                vec![method("count", "uint64")],
            )],
        );
        write_global_generics_module(&[&small], tmp.path()).unwrap();
        assert!(tmp.path().join("generics/000.ss").is_file());
        assert!(!tmp.path().join("generics/001.ss").exists());
        assert!(!tmp.path().join("generics/002.ss").exists());
    }
}
