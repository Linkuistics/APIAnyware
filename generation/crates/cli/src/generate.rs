//! Core generation orchestration — loads enriched IR, invokes emitters,
//! writes output to `generation/targets/{lang}/generated/`.

use std::path::{Path, PathBuf};

use anyhow::{bail, Context, Result};
use apianyware_macos_emit::binding_style::{EmitResult, LanguageEmitter, LanguageInfo};
use apianyware_macos_emit::framework_ordering::topological_sort;

use crate::registry::EmitterRegistry;

/// Result of generating bindings for one language across all frameworks.
#[derive(Debug, Default)]
pub struct GenerationSummary {
    pub language_id: String,
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

/// Build the output directory path for a language.
///
/// Pattern: `{base_output_dir}/{info.id}/{info.generated_subdir}/`.
/// Most targets use the conventional `generated` subdir; the chez target
/// uses `apianyware` so Chez's default library-name resolution finds the
/// emitted files with `--libdirs generation/targets/chez`.
pub fn output_dir_for_language(base_output_dir: &Path, info: &LanguageInfo) -> PathBuf {
    base_output_dir.join(info.id).join(info.generated_subdir)
}

/// Generate bindings for the specified languages (or all if none specified).
///
/// For each language, generates all enriched frameworks. Reads enriched IR
/// from `input_dir`, writes to `{base_output_dir}/{lang}/generated/`.
pub fn run_generation(
    registry: &EmitterRegistry,
    input_dir: &Path,
    base_output_dir: &Path,
    language_filter: Option<&[String]>,
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
    let emitters: Vec<&dyn LanguageEmitter> = if let Some(langs) = language_filter {
        let mut found = Vec::new();
        for lang in langs {
            match registry.get(lang) {
                Some(emitter) => found.push(emitter),
                None => bail!(
                    "unknown language: '{}'. Use --list-languages to see available emitters.",
                    lang
                ),
            }
        }
        found
    } else {
        registry.all().collect()
    };

    let mut summaries = Vec::new();

    for emitter in &emitters {
        let info = emitter.language_info();
        let out_dir = output_dir_for_language(base_output_dir, info);

        tracing::info!(
            language = info.id,
            output = %out_dir.display(),
            "generating bindings"
        );

        let mut summary = GenerationSummary {
            language_id: info.id.to_string(),
            ..Default::default()
        };

        for fw in &ordered_frameworks {
            let result = emitter
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
            language = info.id,
            frameworks = summary.frameworks_generated,
            files = summary.total_files_written,
            "language complete"
        );

        summaries.push(summary);
    }

    Ok(summaries)
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
                }],
                category_methods: vec![],
                swift_attributes: vec![],
                ancestors: vec![],
                all_methods: vec![],
                all_properties: vec![],
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
    fn output_dir_for_language_builds_correct_path() {
        let base = Path::new("/out/targets");
        let racket = LanguageInfo {
            id: "racket",
            display_name: "Racket",
            generated_subdir: "generated",
        };
        assert_eq!(
            output_dir_for_language(base, &racket),
            PathBuf::from("/out/targets/racket/generated")
        );

        let chez = LanguageInfo {
            id: "chez",
            display_name: "Chez Scheme",
            generated_subdir: "apianyware",
        };
        assert_eq!(
            output_dir_for_language(base, &chez),
            PathBuf::from("/out/targets/chez/apianyware")
        );
    }

    #[test]
    fn generate_single_language() {
        let tmp = tempfile::tempdir().unwrap();
        let input_dir = tmp.path().join("enriched");
        let output_dir = tmp.path().join("targets");

        let fw = make_test_framework("TestKit");
        write_test_framework(&input_dir, &fw);

        let registry = EmitterRegistry::new();
        let langs = vec!["racket".to_string()];
        let summaries = run_generation(&registry, &input_dir, &output_dir, Some(&langs)).unwrap();

        assert_eq!(summaries.len(), 1);
        assert_eq!(summaries[0].language_id, "racket");
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
        let langs = vec!["racket".to_string()];
        let summaries = run_generation(&registry, &input_dir, &output_dir, Some(&langs)).unwrap();

        // Both frameworks generated
        assert_eq!(summaries[0].frameworks_generated, 2);
        assert!(output_dir
            .join("racket/generated/foundation")
            .exists());
        assert!(output_dir.join("racket/generated/appkit").exists());
    }

    #[test]
    fn generate_all_languages() {
        let tmp = tempfile::tempdir().unwrap();
        let input_dir = tmp.path().join("enriched");
        let output_dir = tmp.path().join("targets");

        write_test_framework(&input_dir, &make_test_framework("TestKit"));

        let registry = EmitterRegistry::new();
        let summaries = run_generation(&registry, &input_dir, &output_dir, None).unwrap();

        // Should generate for all registered languages (currently just racket)
        assert!(!summaries.is_empty());
        assert_eq!(summaries[0].language_id, "racket");
    }

    #[test]
    fn generate_unknown_language_returns_error() {
        let tmp = tempfile::tempdir().unwrap();
        let input_dir = tmp.path().join("enriched");
        let output_dir = tmp.path().join("targets");

        write_test_framework(&input_dir, &make_test_framework("TestKit"));

        let registry = EmitterRegistry::new();
        let langs = vec!["unknown".to_string()];
        let result = run_generation(&registry, &input_dir, &output_dir, Some(&langs));

        assert!(result.is_err());
        let err = result.unwrap_err().to_string();
        assert!(err.contains("unknown language"));
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
        let langs = vec!["racket".to_string()];
        let summaries = run_generation(&registry, &input_dir, &output_dir, Some(&langs)).unwrap();

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
        let langs = vec!["racket".to_string()];
        run_generation(&registry, &input_dir, &output_dir, Some(&langs)).unwrap();

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
        let langs = vec!["racket".to_string()];
        run_generation(&registry, &input_dir, &output_dir, Some(&langs)).unwrap();

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
            2,
            "should run racket + chez emitters"
        );

        for s in &summaries {
            assert!(
                s.total_files_written > 0,
                "{} should produce files",
                s.language_id
            );
            assert_eq!(s.total_classes, 5, "{} class count", s.language_id);
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
        let langs = vec!["racket".to_string()];
        let summaries = run_generation(&registry, &input_dir, &output_dir, Some(&langs)).unwrap();

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
        let langs = vec!["racket".to_string()];
        let summaries = run_generation(&registry, &input_dir, &output_dir, Some(&langs)).unwrap();

        let summary = &summaries[0];
        assert_eq!(summary.frameworks_generated, 2);
        assert_eq!(summary.total_classes, 10, "5 classes x 2 frameworks");
        assert_eq!(summary.total_protocols, 4, "2 protocols x 2 frameworks");
        assert_eq!(summary.total_enums, 2, "1 enum x 2 frameworks");
    }
}
