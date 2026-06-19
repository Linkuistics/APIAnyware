//! Core generation orchestration — loads enriched IR, invokes emitters,
//! writes output to `generation/targets/{target}/generated/`.

use std::path::{Path, PathBuf};

use anyhow::{bail, Context, Result};
use apianyware_macos_emit::framework_ordering::topological_sort;
use apianyware_macos_emit::target_emitter::{EmitResult, TargetEmitter, TargetInfo};

use crate::registry::EmitterRegistry;

/// Result of generating bindings for one target across all frameworks.
#[derive(Debug, Default)]
pub struct GenerationSummary {
    pub target_id: String,
    pub frameworks_generated: usize,
    pub total_files_written: usize,
    pub total_classes: usize,
    pub total_protocols: usize,
    pub total_enums: usize,
}

impl GenerationSummary {
    fn accumulate(&mut self, result: &EmitResult) {
        self.frameworks_generated += 1;
        self.total_files_written += result.files_written;
        self.total_classes += result.classes_emitted;
        self.total_protocols += result.protocols_emitted;
        self.total_enums += result.enums_emitted;
    }
}

/// Build the output directory path for a target.
///
/// Pattern: `{base_output_dir}/{info.id}/{info.generated_subdir}/`.
/// Most targets use the conventional `generated` subdir; the chez target
/// uses `apianyware` so Chez's default library-name resolution finds the
/// emitted files with `--libdirs generation/targets/chez`.
pub fn output_dir_for_target(base_output_dir: &Path, info: &TargetInfo) -> PathBuf {
    base_output_dir.join(info.id).join(info.generated_subdir)
}

/// Generate bindings for the specified targets (or all if none specified).
///
/// For each target, generates all enriched frameworks. Reads enriched IR
/// from `input_dir`, writes to `{base_output_dir}/{target}/generated/`.
pub fn run_generation(
    registry: &EmitterRegistry,
    input_dir: &Path,
    base_output_dir: &Path,
    target_filter: Option<&[String]>,
) -> Result<Vec<GenerationSummary>> {
    // Load all enriched frameworks
    let frameworks = apianyware_macos_datalog::loading::load_all_frameworks(input_dir, None)?;

    if frameworks.is_empty() {
        bail!("no enriched IR found in {}", input_dir.display());
    }

    // Sort frameworks in dependency order
    let order = topological_sort(&frameworks);
    let ordered_frameworks: Vec<_> = order
        .iter()
        .filter_map(|name| frameworks.iter().find(|fw| &fw.name == name))
        .collect();

    tracing::info!(frameworks = ordered_frameworks.len(), "loaded enriched IR");

    // Determine which emitters to run
    let emitters: Vec<&dyn TargetEmitter> = if let Some(targets) = target_filter {
        let mut found = Vec::new();
        for target in targets {
            match registry.get(target) {
                Some(emitter) => found.push(emitter),
                None => bail!(
                    "unknown target: '{}'. Use --list-targets to see available emitters.",
                    target
                ),
            }
        }
        found
    } else {
        registry.all().collect()
    };

    let mut summaries = Vec::new();

    for emitter in &emitters {
        let info = emitter.target_info();
        let out_dir = output_dir_for_target(base_output_dir, info);

        tracing::info!(
            target = info.id,
            output = %out_dir.display(),
            "generating bindings"
        );

        let mut summary = GenerationSummary {
            target_id: info.id.to_string(),
            ..Default::default()
        };

        // Gerbil's manifest class graph (ADR-0020) places a class's parent in
        // whichever framework *owns* it — a cross-framework fact — but
        // `emit_framework` runs per framework and cannot see the others. So
        // build the global class→owning-framework `ClassRegistry` once over
        // every loaded framework and run a program-configured emitter, the
        // same whole-program shape as racket's native-dispatch pass. Every
        // other target uses the registry instance unchanged.
        let gerbil_configured;
        let active: &dyn TargetEmitter = if info.id
            == apianyware_macos_emit_gerbil::GERBIL_TARGET_INFO.id
        {
            let reg = apianyware_macos_emit_gerbil::class_graph::ClassRegistry::from_framework_refs(
                &ordered_frameworks,
            );
            // Protocol-inheritance registry (leaf 120): the same whole-program
            // shape, backing conformed-protocol method flattening — a class's
            // conformance closure follows protocol `inherits` edges that cross
            // frameworks.
            let protos =
                    apianyware_macos_emit_gerbil::protocol_registry::ProtocolRegistry::from_framework_refs(
                        &ordered_frameworks,
                    );
            // Same whole-program shape: the shared global generics module
            // (`generics.ss`) holds one `:std/generic` generic per distinct
            // instance-surface selector across every framework, so a selector
            // shared by unrelated classes is one generic they all extend
            // (cross-module unification fix). Written once, here.
            apianyware_macos_emit_gerbil::write_global_generics_module(
                &ordered_frameworks,
                &out_dir,
            )?;
            gerbil_configured =
                apianyware_macos_emit_gerbil::GerbilEmitter::with_registries(reg, protos);
            &gerbil_configured
        } else {
            *emitter
        };

        for fw in &ordered_frameworks {
            let result = active
                .emit_framework(fw, &out_dir)
                .with_context(|| format!("failed to emit {} for {}", fw.name, info.id))?;

            tracing::info!(
                framework = %fw.name,
                files = result.files_written,
                classes = result.classes_emitted,
                "emitted"
            );

            summary.accumulate(&result);
        }

        tracing::info!(
            target = info.id,
            frameworks = summary.frameworks_generated,
            files = summary.total_files_written,
            "target complete"
        );

        summaries.push(summary);
    }

    Ok(summaries)
}

/// Generate the racket target's typed native dispatch table (ADR-0013) into the
/// `APIAnywareRacket` Swift target, then `swift build` compiles it into the dylib.
///
/// This is a **global** pass (the dispatch entries are deduplicated across every
/// framework, unlike the per-framework `.rkt` bindings), so it runs once after
/// [`run_generation`] rather than per-framework. The build order is therefore
/// `generate -> swift build` (the dispatch `.swift` must exist before the dylib
/// is built). Returns the number of distinct entries written.
///
/// The collapsed-ABI signatures are derived from the `ffi/unsafe` spellings, so
/// the mapper here is [`RacketFfiTypeMapper`] (not the ffi2 one): `native_dispatch`
/// parses `_id`/`_uint64`/`_NSRect` tokens and collapses pointer-likes itself.
pub fn run_racket_native_dispatch(input_dir: &Path, swift_out: &Path) -> Result<usize> {
    use apianyware_macos_emit::ffi_type_mapping::RacketFfiTypeMapper;
    use apianyware_macos_emit_racket::native_dispatch::{
        collect_global_signatures, generate_dispatch_swift,
    };

    let frameworks = apianyware_macos_datalog::loading::load_all_frameworks(input_dir, None)?;
    if frameworks.is_empty() {
        bail!("no enriched IR found in {}", input_dir.display());
    }

    let sigs = collect_global_signatures(&frameworks, &RacketFfiTypeMapper);
    let swift = generate_dispatch_swift(&sigs);

    if let Some(parent) = swift_out.parent() {
        std::fs::create_dir_all(parent)
            .with_context(|| format!("creating {}", parent.display()))?;
    }
    std::fs::write(swift_out, swift).with_context(|| format!("writing {}", swift_out.display()))?;

    tracing::info!(
        entries = sigs.len(),
        output = %swift_out.display(),
        "generated native dispatch table"
    );
    Ok(sigs.len())
}

/// Generate the racket target's Swift-native **trampolines** (ADR-0027) into the
/// `APIAnywareRacket` Swift target; `swift build` then compiles them into the dylib.
///
/// Like the native dispatch table this is a **global** pass — the trampolines are
/// collected across every framework and emitted into one file — so it runs once
/// after [`run_generation`], before `swift build`. Every retained
/// `objc_exposed == false` declaration is either trampolined or recorded as
/// deferred (with a reason); the per-reason counts are logged so a clean generate
/// reports what was bound and what was not (spec §5, "defer nothing, but be
/// honest"). Returns the number of trampoline entries written.
pub fn run_racket_trampolines(input_dir: &Path, swift_out: &Path) -> Result<usize> {
    use apianyware_macos_emit_racket::trampoline::{
        collect_trampolines, generate_trampolines_swift,
    };

    let frameworks = apianyware_macos_datalog::loading::load_all_frameworks(input_dir, None)?;
    if frameworks.is_empty() {
        bail!("no enriched IR found in {}", input_dir.display());
    }

    let set = collect_trampolines(&frameworks);
    let entries = set.functions.len() + set.constants.len() + set.inits.len() + set.methods.len();
    let swift = generate_trampolines_swift(&set);

    if let Some(parent) = swift_out.parent() {
        std::fs::create_dir_all(parent)
            .with_context(|| format!("creating {}", parent.display()))?;
    }
    std::fs::write(swift_out, swift).with_context(|| format!("writing {}", swift_out.display()))?;

    let deferred: Vec<String> = set
        .defer_counts()
        .iter()
        .map(|(reason, n)| format!("{n} {reason}"))
        .collect();
    tracing::info!(
        functions = set.functions.len(),
        constants = set.constants.len(),
        inits = set.inits.len(),
        methods = set.methods.len(),
        deferred = %if deferred.is_empty() { "none".to_string() } else { deferred.join(", ") },
        output = %swift_out.display(),
        "generated Swift-native trampolines"
    );
    Ok(entries)
}

/// Generate the **chez** target's Swift-native trampolines (ADR-0027 ported to
/// chez, leaf 060) into the `APIAnywareChez` Swift target; `swift build` then
/// compiles them into `libAPIAnywareChez`.
///
/// A **global** pass like the racket trampolines: the residual is collected across
/// every framework into one `Generated/Trampolines.swift`. Per ADR-0011 the chez
/// trampoline layer shares no native substrate with racket — only the
/// classification taxonomy (a property of the shared IR) is duplicated. Every
/// retained `objc_exposed == false` declaration is either trampolined or recorded
/// as deferred with a reason; the per-reason counts are logged (spec §5). Returns
/// the number of trampoline entries written.
pub fn run_chez_trampolines(input_dir: &Path, swift_out: &Path) -> Result<usize> {
    use apianyware_macos_emit_chez::trampoline::{collect_trampolines, generate_trampolines_swift};

    let frameworks = apianyware_macos_datalog::loading::load_all_frameworks(input_dir, None)?;
    if frameworks.is_empty() {
        bail!("no enriched IR found in {}", input_dir.display());
    }

    let set = collect_trampolines(&frameworks);
    // Match racket's accounting: the method frontier (ADR-0030) adds init producers
    // + receiver-handle methods to the free-function/constant residual, so the
    // entry total and the log report all four kinds (the §6c invariant is checked
    // by reproducing racket's per-kind + per-reason counts).
    let entries =
        set.functions.len() + set.constants.len() + set.inits.len() + set.methods.len();
    let swift = generate_trampolines_swift(&set);

    if let Some(parent) = swift_out.parent() {
        std::fs::create_dir_all(parent)
            .with_context(|| format!("creating {}", parent.display()))?;
    }
    std::fs::write(swift_out, swift).with_context(|| format!("writing {}", swift_out.display()))?;

    let deferred: Vec<String> = set
        .defer_counts()
        .iter()
        .map(|(reason, n)| format!("{n} {reason}"))
        .collect();
    tracing::info!(
        functions = set.functions.len(),
        constants = set.constants.len(),
        inits = set.inits.len(),
        methods = set.methods.len(),
        deferred = %if deferred.is_empty() { "none".to_string() } else { deferred.join(", ") },
        output = %swift_out.display(),
        "generated chez Swift-native trampolines"
    );
    Ok(entries)
}

/// Generate the **gerbil** target's Swift-native trampolines (ADR-0027 racket /
/// ADR-0028 chez, ported to gerbil under ADR-0029, leaf 070) into the
/// `APIAnywareGerbil` Swift target; `swift build` then compiles them into
/// `libAPIAnywareGerbil` — the deliberate ADR-0017 deviation (gerbil grows a
/// `swift build` step) the dylib trampoline requires.
///
/// A **global** pass like the racket/chez trampolines: the residual is collected
/// across every framework into one `Generated/Trampolines.swift`. Per ADR-0011
/// the gerbil trampoline layer shares no native substrate with racket/chez — only
/// the classification taxonomy (a property of the shared IR) is duplicated, so the
/// residual reproduces exactly (51 functions, 7 constants). Every retained
/// `objc_exposed == false` declaration is either trampolined or recorded as
/// deferred with a reason; the per-reason counts are logged (spec §5). Returns the
/// number of trampoline entries written.
pub fn run_gerbil_trampolines(input_dir: &Path, swift_out: &Path) -> Result<usize> {
    use apianyware_macos_emit_gerbil::trampoline::{
        collect_trampolines, generate_trampolines_swift,
    };

    let frameworks = apianyware_macos_datalog::loading::load_all_frameworks(input_dir, None)?;
    if frameworks.is_empty() {
        bail!("no enriched IR found in {}", input_dir.display());
    }

    let set = collect_trampolines(&frameworks);
    let entries =
        set.functions.len() + set.constants.len() + set.inits.len() + set.methods.len();
    let swift = generate_trampolines_swift(&set);

    if let Some(parent) = swift_out.parent() {
        std::fs::create_dir_all(parent)
            .with_context(|| format!("creating {}", parent.display()))?;
    }
    std::fs::write(swift_out, swift).with_context(|| format!("writing {}", swift_out.display()))?;

    let deferred: Vec<String> = set
        .defer_counts()
        .iter()
        .map(|(reason, n)| format!("{n} {reason}"))
        .collect();
    tracing::info!(
        functions = set.functions.len(),
        constants = set.constants.len(),
        inits = set.inits.len(),
        methods = set.methods.len(),
        deferred = %if deferred.is_empty() { "none".to_string() } else { deferred.join(", ") },
        output = %swift_out.display(),
        "generated gerbil Swift-native trampolines"
    );
    Ok(entries)
}

#[cfg(test)]
mod tests {
    use super::*;
    use apianyware_macos_emit::test_fixtures::build_snapshot_test_framework;
    use apianyware_macos_types::ir::{Class, Framework, Method};
    use apianyware_macos_types::type_ref::{TypeRef, TypeRefKind};

    fn make_test_framework(name: &str) -> Framework {
        Framework {
            format_version: "1.0".to_string(),
            checkpoint: "enriched".to_string(),
            name: name.to_string(),
            sdk_version: None,
            collected_at: None,
            depends_on: vec![],
            skipped_symbols: vec![],
            classes: vec![Class {
                name: "NSObject".to_string(),
                superclass: String::new(),
                protocols: vec![],
                properties: vec![],
                methods: vec![Method {
                    selector: "init".to_string(),
                    class_method: false,
                    init_method: true,
                    params: vec![],
                    return_type: TypeRef {
                        nullable: false,
                        kind: TypeRefKind::Instancetype,
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
                }],
                category_methods: vec![],
                swift_attributes: vec![],
                ancestors: vec![],
                all_methods: vec![],
                all_properties: vec![],
                objc_exposed: true,
            }],
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

    fn write_test_framework(dir: &Path, fw: &Framework) {
        std::fs::create_dir_all(dir).unwrap();
        let path = dir.join(format!("{}.json", fw.name));
        let json = serde_json::to_string_pretty(fw).unwrap();
        std::fs::write(path, json).unwrap();
    }

    #[test]
    fn output_dir_for_target_builds_correct_path() {
        let base = Path::new("/out/targets");
        let racket = TargetInfo {
            id: "racket",
            display_name: "Racket",
            generated_subdir: "generated",
        };
        assert_eq!(
            output_dir_for_target(base, &racket),
            PathBuf::from("/out/targets/racket/generated")
        );

        let chez = TargetInfo {
            id: "chez",
            display_name: "Chez Scheme",
            generated_subdir: "apianyware",
        };
        assert_eq!(
            output_dir_for_target(base, &chez),
            PathBuf::from("/out/targets/chez/apianyware")
        );
    }

    #[test]
    fn generate_single_target() {
        let tmp = tempfile::tempdir().unwrap();
        let input_dir = tmp.path().join("enriched");
        let output_dir = tmp.path().join("targets");

        let fw = make_test_framework("TestKit");
        write_test_framework(&input_dir, &fw);

        let registry = EmitterRegistry::new();
        let targets = vec!["racket".to_string()];
        let summaries = run_generation(&registry, &input_dir, &output_dir, Some(&targets)).unwrap();

        assert_eq!(summaries.len(), 1);
        assert_eq!(summaries[0].target_id, "racket");
        assert!(summaries[0].total_files_written > 0);

        // Verify output structure
        assert!(output_dir
            .join("racket/generated/testkit/main.rkt")
            .exists());
    }

    #[test]
    fn generate_multiple_frameworks() {
        let tmp = tempfile::tempdir().unwrap();
        let input_dir = tmp.path().join("enriched");
        let output_dir = tmp.path().join("targets");

        write_test_framework(&input_dir, &make_test_framework("Foundation"));
        write_test_framework(&input_dir, &make_test_framework("AppKit"));

        let registry = EmitterRegistry::new();
        let targets = vec!["racket".to_string()];
        let summaries = run_generation(&registry, &input_dir, &output_dir, Some(&targets)).unwrap();

        // Both frameworks generated
        assert_eq!(summaries[0].frameworks_generated, 2);
        assert!(output_dir.join("racket/generated/foundation").exists());
        assert!(output_dir.join("racket/generated/appkit").exists());
    }

    #[test]
    fn generate_all_targets() {
        let tmp = tempfile::tempdir().unwrap();
        let input_dir = tmp.path().join("enriched");
        let output_dir = tmp.path().join("targets");

        write_test_framework(&input_dir, &make_test_framework("TestKit"));

        let registry = EmitterRegistry::new();
        let summaries = run_generation(&registry, &input_dir, &output_dir, None).unwrap();

        // Should generate for all registered targets (currently just racket)
        assert!(!summaries.is_empty());
        assert_eq!(summaries[0].target_id, "racket");
    }

    #[test]
    fn generate_unknown_target_returns_error() {
        let tmp = tempfile::tempdir().unwrap();
        let input_dir = tmp.path().join("enriched");
        let output_dir = tmp.path().join("targets");

        write_test_framework(&input_dir, &make_test_framework("TestKit"));

        let registry = EmitterRegistry::new();
        let targets = vec!["unknown".to_string()];
        let result = run_generation(&registry, &input_dir, &output_dir, Some(&targets));

        assert!(result.is_err());
        let err = result.unwrap_err().to_string();
        assert!(err.contains("unknown target"));
    }

    #[test]
    fn generate_empty_input_dir_returns_error() {
        let tmp = tempfile::tempdir().unwrap();
        let input_dir = tmp.path().join("enriched");
        std::fs::create_dir_all(&input_dir).unwrap();
        let output_dir = tmp.path().join("targets");

        let registry = EmitterRegistry::new();
        let result = run_generation(&registry, &input_dir, &output_dir, None);

        assert!(result.is_err());
        let err = result.unwrap_err().to_string();
        assert!(err.contains("no enriched IR"));
    }

    // -----------------------------------------------------------------------
    // Integration tests — rich synthetic IR through full pipeline
    // -----------------------------------------------------------------------

    #[test]
    fn rich_framework_reports_correct_emit_statistics() {
        let tmp = tempfile::tempdir().unwrap();
        let input_dir = tmp.path().join("enriched");
        let output_dir = tmp.path().join("targets");

        write_test_framework(&input_dir, &build_snapshot_test_framework());

        let registry = EmitterRegistry::new();
        let targets = vec!["racket".to_string()];
        let summaries = run_generation(&registry, &input_dir, &output_dir, Some(&targets)).unwrap();

        let summary = &summaries[0];
        assert_eq!(summary.frameworks_generated, 1);
        assert_eq!(summary.total_classes, 5, "TestKit has 5 classes");
        assert_eq!(summary.total_protocols, 2, "TestKit has 2 protocols");
        assert_eq!(summary.total_enums, 1, "TestKit has 1 enum");
    }

    #[test]
    fn rich_framework_creates_expected_file_structure() {
        let tmp = tempfile::tempdir().unwrap();
        let input_dir = tmp.path().join("enriched");
        let output_dir = tmp.path().join("targets");

        write_test_framework(&input_dir, &build_snapshot_test_framework());

        let registry = EmitterRegistry::new();
        let targets = vec!["racket".to_string()];
        run_generation(&registry, &input_dir, &output_dir, Some(&targets)).unwrap();

        let testkit_dir = output_dir.join("racket/generated/testkit");

        // Per-class files
        for name in &["tkobject", "tkview", "tkbutton", "tkmanager", "tkhelper"] {
            assert!(
                testkit_dir.join(format!("{name}.rkt")).exists(),
                "missing class file: {name}.rkt"
            );
        }

        // Aggregate files
        assert!(testkit_dir.join("main.rkt").exists(), "missing main.rkt");
        assert!(testkit_dir.join("enums.rkt").exists(), "missing enums.rkt");
        assert!(
            testkit_dir.join("constants.rkt").exists(),
            "missing constants.rkt"
        );

        // Protocol directory
        assert!(
            testkit_dir.join("protocols").is_dir(),
            "missing protocols/ directory"
        );
    }

    #[test]
    fn rich_framework_output_contains_expected_content() {
        let tmp = tempfile::tempdir().unwrap();
        let input_dir = tmp.path().join("enriched");
        let output_dir = tmp.path().join("targets");

        write_test_framework(&input_dir, &build_snapshot_test_framework());

        let registry = EmitterRegistry::new();
        let targets = vec!["racket".to_string()];
        run_generation(&registry, &input_dir, &output_dir, Some(&targets)).unwrap();

        let testkit_dir = output_dir.join("racket/generated/testkit");

        // main.rkt re-exports submodules
        let main = std::fs::read_to_string(testkit_dir.join("main.rkt")).unwrap();
        assert!(
            main.contains("require"),
            "main.rkt should require submodules"
        );

        // Class file references its class name
        let tkview = std::fs::read_to_string(testkit_dir.join("tkview.rkt")).unwrap();
        assert!(
            tkview.contains("TKView"),
            "tkview.rkt should reference TKView"
        );

        // Enum file contains enum values
        let enums = std::fs::read_to_string(testkit_dir.join("enums.rkt")).unwrap();
        assert!(
            enums.contains("TKAlignment"),
            "enums.rkt should contain TKAlignment"
        );
        assert!(
            enums.contains("TKAlignmentLeft"),
            "enums.rkt should contain TKAlignmentLeft"
        );

        // Constants file references the framework
        let constants = std::fs::read_to_string(testkit_dir.join("constants.rkt")).unwrap();
        assert!(
            constants.contains("TestKit"),
            "constants.rkt should reference the TestKit framework"
        );
    }

    #[test]
    fn all_emitters_handle_rich_framework() {
        let tmp = tempfile::tempdir().unwrap();
        let input_dir = tmp.path().join("enriched");
        let output_dir = tmp.path().join("targets");

        write_test_framework(&input_dir, &build_snapshot_test_framework());

        let registry = EmitterRegistry::new();
        let summaries = run_generation(&registry, &input_dir, &output_dir, None).unwrap();

        // Every registered emitter should produce results without error.
        assert_eq!(
            summaries.len(),
            3,
            "should run racket + chez + gerbil emitters"
        );

        for s in &summaries {
            assert!(
                s.total_files_written > 0,
                "{} should produce files",
                s.target_id
            );
            assert_eq!(s.total_classes, 5, "{} class count", s.target_id);
        }
    }

    fn bare_class(name: &str, superclass: &str) -> Class {
        Class {
            name: name.into(),
            superclass: superclass.into(),
            protocols: vec![],
            properties: vec![],
            methods: vec![],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
        }
    }

    #[test]
    fn gerbil_cross_framework_parent_import_resolves_through_registry() {
        // The end-to-end proof that the CLI pre-pass builds and threads gerbil's
        // cross-framework ClassRegistry: Foundation owns
        // NSMutableAttributedString; AppKit's NSTextStorage derives from it.
        // `emit_framework` sees only AppKit, so it can place that parent
        // precisely only because the pre-pass built the registry over both.
        let tmp = tempfile::tempdir().unwrap();
        let input_dir = tmp.path().join("enriched");
        let output_dir = tmp.path().join("targets");

        let mut foundation = make_test_framework("Foundation");
        foundation.classes = vec![bare_class("NSMutableAttributedString", "NSObject")];

        let mut appkit = make_test_framework("AppKit");
        appkit.depends_on = vec!["Foundation".to_string()];
        appkit.classes = vec![bare_class("NSTextStorage", "NSMutableAttributedString")];

        write_test_framework(&input_dir, &foundation);
        write_test_framework(&input_dir, &appkit);

        let registry = EmitterRegistry::new();
        let targets = vec!["gerbil".to_string()];
        run_generation(&registry, &input_dir, &output_dir, Some(&targets)).unwrap();

        // `generated_subdir = "lib"` (the gerbil package root).
        let storage =
            std::fs::read_to_string(output_dir.join("gerbil/lib/appkit/nstextstorage.ss")).unwrap();
        assert!(
            storage.contains("(defclass (NSTextStorage NSMutableAttributedString)"),
            "child derives from the cross-framework parent:\n{storage}"
        );
        assert!(
            storage.contains(":gerbil-bindings/foundation/nsmutableattributedstring"),
            "cross-framework parent import should resolve through the wired registry:\n{storage}"
        );
    }

    fn class_with_method(name: &str, selector: &str) -> Class {
        Class {
            name: name.into(),
            superclass: "NSObject".into(),
            protocols: vec![],
            properties: vec![],
            methods: vec![Method {
                selector: selector.into(),
                class_method: false,
                init_method: false,
                params: vec![],
                return_type: TypeRef {
                    nullable: false,
                    kind: TypeRefKind::Primitive {
                        name: "uint64".into(),
                    },
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
            }],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
        }
    }

    #[test]
    fn gerbil_shared_generic_declared_once_across_unrelated_classes() {
        // Two unrelated classes in two frameworks both expose `count`. The CLI
        // pre-pass writes a single shared generics.ss with ONE (g:defgeneric
        // count); each class module imports it rather than re-declaring — the
        // cross-module generic-unification fix, proven end-to-end.
        let tmp = tempfile::tempdir().unwrap();
        let input_dir = tmp.path().join("enriched");
        let output_dir = tmp.path().join("targets");

        let mut foundation = make_test_framework("Foundation");
        foundation.classes = vec![class_with_method("NSArray", "count")];
        let mut coredata = make_test_framework("CoreData");
        coredata.depends_on = vec!["Foundation".to_string()];
        coredata.classes = vec![class_with_method("NSFetchRequest", "count")];

        write_test_framework(&input_dir, &foundation);
        write_test_framework(&input_dir, &coredata);

        let registry = EmitterRegistry::new();
        let targets = vec!["gerbil".to_string()];
        run_generation(&registry, &input_dir, &output_dir, Some(&targets)).unwrap();

        let lib = output_dir.join("gerbil/lib");
        // The facade re-exports the sharded declarations (ADR-0023): the
        // `(g:defgeneric …)` forms live in `generics/NNN.ss`, one site total.
        let facade = std::fs::read_to_string(lib.join("generics.ss")).unwrap();
        assert!(
            facade.contains(":gerbil-bindings/generics/000"),
            "facade re-exports the shards:\n{facade}"
        );
        let mut shards = String::new();
        for entry in std::fs::read_dir(lib.join("generics")).unwrap().flatten() {
            shards.push_str(&std::fs::read_to_string(entry.path()).unwrap());
        }
        assert_eq!(
            shards.matches("(g:defgeneric count)").count(),
            1,
            "single declaration site for the shared generic across shards:\n{shards}"
        );

        // Both class modules import the shared module and do NOT declare the generic.
        for module in ["foundation/nsarray.ss", "coredata/nsfetchrequest.ss"] {
            let body = std::fs::read_to_string(lib.join(module)).unwrap();
            assert!(
                body.contains(":gerbil-bindings/generics"),
                "{module} should import the shared generics module:\n{body}"
            );
            assert!(
                !body.contains("(g:defgeneric count)"),
                "{module} must not re-declare the shared generic:\n{body}"
            );
            assert!(
                body.contains("(g:defmethod (count "),
                "{module} should extend the shared generic:\n{body}"
            );
        }
    }

    #[test]
    fn dependent_frameworks_both_generate_correctly() {
        let tmp = tempfile::tempdir().unwrap();
        let input_dir = tmp.path().join("enriched");
        let output_dir = tmp.path().join("targets");

        let mut foundation = make_test_framework("Foundation");
        foundation.depends_on = vec![];

        let mut appkit = make_test_framework("AppKit");
        appkit.depends_on = vec!["Foundation".to_string()];

        write_test_framework(&input_dir, &foundation);
        write_test_framework(&input_dir, &appkit);

        let registry = EmitterRegistry::new();
        let targets = vec!["racket".to_string()];
        let summaries = run_generation(&registry, &input_dir, &output_dir, Some(&targets)).unwrap();

        assert_eq!(summaries[0].frameworks_generated, 2);

        // Both output directories should exist with correct content
        let generated_dir = output_dir.join("racket/generated");
        assert!(
            generated_dir.join("foundation/main.rkt").exists(),
            "Foundation output should exist"
        );
        assert!(
            generated_dir.join("appkit/main.rkt").exists(),
            "AppKit output should exist"
        );
    }

    #[test]
    fn multiple_rich_frameworks_accumulate_statistics() {
        let tmp = tempfile::tempdir().unwrap();
        let input_dir = tmp.path().join("enriched");
        let output_dir = tmp.path().join("targets");

        // Write the same rich framework under two names
        let mut fw1 = build_snapshot_test_framework();
        fw1.name = "FrameworkA".to_string();
        let mut fw2 = build_snapshot_test_framework();
        fw2.name = "FrameworkB".to_string();

        write_test_framework(&input_dir, &fw1);
        write_test_framework(&input_dir, &fw2);

        let registry = EmitterRegistry::new();
        let targets = vec!["racket".to_string()];
        let summaries = run_generation(&registry, &input_dir, &output_dir, Some(&targets)).unwrap();

        let summary = &summaries[0];
        assert_eq!(summary.frameworks_generated, 2);
        assert_eq!(summary.total_classes, 10, "5 classes x 2 frameworks");
        assert_eq!(summary.total_protocols, 4, "2 protocols x 2 frameworks");
        assert_eq!(summary.total_enums, 2, "1 enum x 2 frameworks");
    }
}
