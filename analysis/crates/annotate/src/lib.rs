//! Heuristic annotation classification and LLM annotation merge.
//!
//! Annotations classify ObjC/Swift API methods with semantic metadata
//! (parameter ownership, block invocation style, threading constraints,
//! error patterns). Two sources produce annotations:
//!
//! 1. **Heuristics** (`heuristics`) — naming convention classifiers that
//!    run in Rust as part of the annotate step. Fast, deterministic,
//!    always available. Handle clear cases (enumerate = sync, setDelegate = weak).
//!
//! 2. **LLM analysis** — an external process reads Apple documentation and
//!    produces structured annotations for ambiguous cases. Output is checked
//!    into `analysis/ir/annotated/*.json`.
//!
//! The `validate` module compares heuristic and LLM annotations, flags
//! disagreements for human review, and merges the two sources with LLM
//! taking precedence.

pub mod heuristics;
pub mod llm;
pub mod pattern_detection;
pub mod validate;

use std::collections::HashMap;
use std::path::Path;

use anyhow::{Context, Result};
use apianyware_macos_datalog::loading;
use apianyware_macos_types::annotation::{
    AnnotationOverrides, ClassAnnotations, FrameworkAnnotations, MethodAnnotation,
};
use apianyware_macos_types::ir::Framework;

/// Annotate all resolved frameworks: load, run heuristics, merge with existing LLM annotations.
///
/// Loads resolved frameworks from `input_dir`, runs heuristic classification on all methods,
/// merges with LLM annotations (from `llm_dir` if provided, otherwise from existing annotated
/// checkpoints in `output_dir`), and writes annotated checkpoints to `output_dir`.
pub fn annotate_frameworks(
    input_dir: &Path,
    output_dir: &Path,
    only: Option<&[String]>,
    llm_dir: Option<&Path>,
) -> Result<Vec<Framework>> {
    let frameworks = loading::load_all_frameworks(input_dir, only)?;
    if frameworks.is_empty() {
        anyhow::bail!("no frameworks found in {}", input_dir.display());
    }

    tracing::info!(count = frameworks.len(), "loaded frameworks for annotation");

    std::fs::create_dir_all(output_dir).with_context(|| {
        format!(
            "failed to create output directory: {}",
            output_dir.display()
        )
    })?;

    let mut annotated = Vec::with_capacity(frameworks.len());

    for framework in &frameworks {
        // Load LLM annotations: prefer dedicated llm_dir, fall back to LLM-sourced
        // entries from the prior annotated checkpoint (so heuristic-only baselines
        // produce only Heuristic-tagged annotations).
        let llm_annotations = if let Some(dir) = llm_dir {
            match llm::load_llm_annotations(dir, &framework.name) {
                Ok(ann) => ann,
                Err(e) => {
                    tracing::warn!(
                        framework = %framework.name,
                        error = %e,
                        "failed to load LLM annotations, using heuristics only"
                    );
                    None
                }
            }
        } else {
            load_existing_llm_annotations(output_dir, &framework.name)
        };

        let result = annotate_framework(framework, llm_annotations.as_ref());
        write_annotated_checkpoint(&result, output_dir)?;
        annotated.push(result);
    }

    Ok(annotated)
}

/// Annotate a single framework: run heuristics on all methods, merge with existing LLM annotations.
pub fn annotate_framework(
    framework: &Framework,
    existing_annotations: Option<&FrameworkAnnotations>,
) -> Framework {
    // Build index of existing LLM annotations: (class_name, selector) → MethodAnnotation
    let llm_index = build_llm_annotation_index(existing_annotations);

    let mut class_annotations = Vec::new();

    for class in &framework.classes {
        let mut method_annotations = Vec::new();

        // Annotate methods in all_methods (inheritance-flattened, from resolve step).
        // If all_methods is empty (pre-resolve), fall back to direct methods.
        let methods = if class.all_methods.is_empty() {
            &class.methods
        } else {
            &class.all_methods
        };

        for method in methods {
            annotate_and_push(class, method, &llm_index, &mut method_annotations);
        }

        // Also annotate category methods (e.g., NSExtendedArray on NSArray).
        for category_group in &class.category_methods {
            for method in &category_group.methods {
                annotate_and_push(class, method, &llm_index, &mut method_annotations);
            }
        }

        if !method_annotations.is_empty() {
            class_annotations.push(ClassAnnotations {
                class_name: class.name.clone(),
                methods: method_annotations,
            });
        }
    }

    // Annotate protocol methods (required + optional). Protocol-only
    // frameworks such as CoreTransferable — and the protocol API surface of
    // every other framework — would otherwise receive zero annotations
    // (FU-1). Protocol annotations share the `class_annotations` list, keyed
    // by protocol name. Structs and enums carry no methods in the IR, so
    // there is nothing to annotate on them.
    for protocol in &framework.protocols {
        let mut method_annotations = Vec::new();
        for method in protocol
            .required_methods
            .iter()
            .chain(&protocol.optional_methods)
        {
            annotate_protocol_method_and_push(
                protocol,
                method,
                &llm_index,
                &mut method_annotations,
            );
        }

        if !method_annotations.is_empty() {
            class_annotations.push(ClassAnnotations {
                class_name: protocol.name.clone(),
                methods: method_annotations,
            });
        }
    }

    // Detect heuristic patterns
    let heuristic_patterns = pattern_detection::detect_patterns(framework);

    let mut annotated = framework.clone();
    annotated.checkpoint = "annotated".to_string();
    annotated.class_annotations = class_annotations;
    annotated.api_patterns = heuristic_patterns;
    annotated
}

/// Run heuristics on a class method, merge with its LLM annotation if
/// available, and push to results.
fn annotate_and_push(
    class: &apianyware_macos_types::ir::Class,
    method: &apianyware_macos_types::ir::Method,
    llm_index: &HashMap<(&str, &str), &MethodAnnotation>,
    results: &mut Vec<MethodAnnotation>,
) {
    let heuristic = heuristics::annotate_method_heuristic(class, method);
    merge_and_push(&class.name, method, heuristic, llm_index, results);
}

/// Run heuristics on a protocol method, merge with its LLM annotation if
/// available, and push to results.
fn annotate_protocol_method_and_push(
    protocol: &apianyware_macos_types::ir::Protocol,
    method: &apianyware_macos_types::ir::Method,
    llm_index: &HashMap<(&str, &str), &MethodAnnotation>,
    results: &mut Vec<MethodAnnotation>,
) {
    let heuristic = heuristics::annotate_protocol_method_heuristic(protocol, method);
    merge_and_push(&protocol.name, method, heuristic, llm_index, results);
}

/// Merge a method's heuristic annotation with its LLM annotation — looked up
/// by `(receiver_name, selector)`, where `receiver_name` is the class or
/// protocol name — and push the merged result.
fn merge_and_push(
    receiver_name: &str,
    method: &apianyware_macos_types::ir::Method,
    heuristic: MethodAnnotation,
    llm_index: &HashMap<(&str, &str), &MethodAnnotation>,
    results: &mut Vec<MethodAnnotation>,
) {
    let llm_ann = llm_index
        .get(&(receiver_name, method.selector.as_str()))
        .copied();

    let overrides = AnnotationOverrides::default();
    let merged = validate::merge_annotations(&heuristic, llm_ann, &overrides);

    results.push(merged);
}

/// Load LLM-sourced annotations from a previously-written annotated checkpoint.
///
/// Filters out entries with `source = Heuristic` so a heuristic-only baseline
/// rerun does not have its annotations re-tagged as `Llm` by `merge_annotations`.
/// `Llm` and `HumanReviewed` entries are retained — heuristics re-run fresh on
/// every method anyway, so dropping prior heuristic entries is information-
/// preserving.
fn load_existing_llm_annotations(
    output_dir: &Path,
    framework_name: &str,
) -> Option<FrameworkAnnotations> {
    let path = output_dir.join(format!("{framework_name}.json"));
    if !path.exists() {
        return None;
    }

    match std::fs::read_to_string(&path) {
        Ok(content) => match serde_json::from_str::<Framework>(&content) {
            Ok(fw) => {
                let classes = retain_llm_sourced(fw.class_annotations);
                if classes.is_empty() {
                    None
                } else {
                    Some(FrameworkAnnotations {
                        framework: framework_name.to_string(),
                        classes,
                        subagent_report: None,
                    })
                }
            }
            Err(e) => {
                tracing::warn!(
                    framework = framework_name,
                    error = %e,
                    "failed to parse existing annotated checkpoint, ignoring"
                );
                None
            }
        },
        Err(e) => {
            tracing::warn!(
                framework = framework_name,
                error = %e,
                "failed to read existing annotated checkpoint, ignoring"
            );
            None
        }
    }
}

/// Keep only methods whose `source` is `Llm` or `HumanReviewed`; drop classes
/// that end up with no methods.
fn retain_llm_sourced(classes: Vec<ClassAnnotations>) -> Vec<ClassAnnotations> {
    classes
        .into_iter()
        .filter_map(|mut class| {
            class.methods.retain(|m| {
                matches!(
                    m.source,
                    apianyware_macos_types::annotation::AnnotationSource::Llm
                        | apianyware_macos_types::annotation::AnnotationSource::HumanReviewed
                )
            });
            if class.methods.is_empty() {
                None
            } else {
                Some(class)
            }
        })
        .collect()
}

/// Build a lookup index from existing LLM/human annotations: (class_name, selector) → MethodAnnotation.
fn build_llm_annotation_index(
    annotations: Option<&FrameworkAnnotations>,
) -> HashMap<(&str, &str), &MethodAnnotation> {
    let mut index = HashMap::new();
    if let Some(fa) = annotations {
        for class in &fa.classes {
            for method in &class.methods {
                index.insert(
                    (class.class_name.as_str(), method.selector.as_str()),
                    method,
                );
            }
        }
    }
    index
}

/// Write an annotated framework checkpoint to disk.
fn write_annotated_checkpoint(framework: &Framework, output_dir: &Path) -> Result<()> {
    let path = output_dir.join(format!("{}.json", framework.name));
    let json = serde_json::to_string_pretty(framework)
        .with_context(|| format!("failed to serialize {}", framework.name))?;
    std::fs::write(&path, json).with_context(|| format!("failed to write {}", path.display()))?;

    let annotation_count: usize = framework
        .class_annotations
        .iter()
        .map(|c| c.methods.len())
        .sum();

    tracing::info!(
        framework = %framework.name,
        classes_annotated = framework.class_annotations.len(),
        method_annotations = annotation_count,
        path = %path.display(),
        "wrote annotated checkpoint"
    );

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use apianyware_macos_types::annotation::AnnotationSource;

    fn method(selector: &str, source: AnnotationSource) -> MethodAnnotation {
        MethodAnnotation {
            selector: selector.to_string(),
            is_instance: true,
            parameter_ownership: vec![],
            block_parameters: vec![],
            threading: None,
            error_pattern: None,
            source,
        }
    }

    fn class(name: &str, methods: Vec<MethodAnnotation>) -> ClassAnnotations {
        ClassAnnotations {
            class_name: name.to_string(),
            methods,
        }
    }

    #[test]
    fn retain_llm_sourced_keeps_llm_and_human_reviewed_drops_heuristic() {
        let input = vec![class(
            "NSString",
            vec![
                method("length", AnnotationSource::Heuristic),
                method("compare:", AnnotationSource::Llm),
                method("hash", AnnotationSource::HumanReviewed),
            ],
        )];

        let kept = retain_llm_sourced(input);

        assert_eq!(kept.len(), 1);
        let selectors: Vec<&str> = kept[0]
            .methods
            .iter()
            .map(|m| m.selector.as_str())
            .collect();
        assert_eq!(selectors, vec!["compare:", "hash"]);
    }

    #[test]
    fn retain_llm_sourced_drops_classes_with_only_heuristic_methods() {
        let input = vec![
            class(
                "NSObject",
                vec![method("description", AnnotationSource::Heuristic)],
            ),
            class("NSArray", vec![method("count", AnnotationSource::Llm)]),
        ];

        let kept = retain_llm_sourced(input);

        assert_eq!(kept.len(), 1);
        assert_eq!(kept[0].class_name, "NSArray");
    }

    #[test]
    fn retain_llm_sourced_returns_empty_when_no_llm_sourced_entries() {
        let input = vec![class(
            "NSObject",
            vec![
                method("description", AnnotationSource::Heuristic),
                method("hash", AnnotationSource::Heuristic),
            ],
        )];

        let kept = retain_llm_sourced(input);

        assert!(kept.is_empty());
    }

    #[test]
    fn retain_llm_sourced_returns_empty_for_empty_input() {
        let kept = retain_llm_sourced(vec![]);
        assert!(kept.is_empty());
    }

    fn write_checkpoint(dir: &Path, name: &str, classes: serde_json::Value) {
        let body = serde_json::json!({
            "name": name,
            "checkpoint": "annotated",
            "class_annotations": classes,
        });
        std::fs::write(dir.join(format!("{name}.json")), body.to_string())
            .expect("test setup: write checkpoint");
    }

    fn make_temp_dir(tag: &str) -> std::path::PathBuf {
        let dir = std::env::temp_dir().join(format!(
            "apianyware-annotate-test-{}-{}-{}",
            tag,
            std::process::id(),
            // Nanos disambiguate parallel tests in the same process.
            std::time::SystemTime::now()
                .duration_since(std::time::UNIX_EPOCH)
                .map(|d| d.as_nanos())
                .unwrap_or(0)
        ));
        std::fs::create_dir_all(&dir).expect("test setup: create temp dir");
        dir
    }

    #[test]
    fn load_existing_llm_annotations_returns_none_when_only_heuristic_entries_present() {
        // End-to-end check that a heuristic-only checkpoint cannot poison a
        // heuristic-only baseline rerun by being re-treated as LLM source.
        let dir = make_temp_dir("heuristic-only");
        write_checkpoint(
            &dir,
            "TestFW",
            serde_json::json!([
                {
                    "class_name": "TestClass",
                    "methods": [
                        {"selector": "foo", "is_instance": true, "source": "heuristic"}
                    ]
                }
            ]),
        );

        let result = load_existing_llm_annotations(&dir, "TestFW");

        std::fs::remove_dir_all(&dir).ok();

        assert!(
            result.is_none(),
            "checkpoint with only Heuristic entries must not be re-presented as LLM source"
        );
    }

    #[test]
    fn load_existing_llm_annotations_returns_only_llm_entries_from_mixed_checkpoint() {
        let dir = make_temp_dir("mixed");
        write_checkpoint(
            &dir,
            "TestFW",
            serde_json::json!([
                {
                    "class_name": "TestClass",
                    "methods": [
                        {"selector": "heuristicOnly", "is_instance": true, "source": "heuristic"},
                        {"selector": "fromLlm", "is_instance": true, "source": "llm"}
                    ]
                }
            ]),
        );

        let result = load_existing_llm_annotations(&dir, "TestFW");

        std::fs::remove_dir_all(&dir).ok();

        let fa = result.expect("checkpoint with an LLM entry should yield Some");
        assert_eq!(fa.classes.len(), 1);
        assert_eq!(fa.classes[0].methods.len(), 1);
        assert_eq!(fa.classes[0].methods[0].selector, "fromLlm");
    }

    /// Build a framework whose only API is one protocol with one block method —
    /// the CoreTransferable shape (zero classes, protocol-only surface).
    fn protocol_only_framework() -> Framework {
        use apianyware_macos_types::ir::{Method as IrMethod, Param, Protocol};
        use apianyware_macos_types::type_ref::{TypeRef, TypeRefKind};

        let block_method = IrMethod {
            selector: "enumerateItemsUsingBlock:".to_string(),
            class_method: false,
            init_method: false,
            params: vec![Param {
                name: "block".to_string(),
                param_type: TypeRef {
                    nullable: false,
                    kind: TypeRefKind::Block {
                        params: vec![],
                        return_type: Box::new(TypeRef::void()),
                    },
                },
            }],
            return_type: TypeRef::void(),
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
        };

        Framework {
            format_version: "1.0".to_string(),
            checkpoint: "resolved".to_string(),
            name: "TestTransferable".to_string(),
            sdk_version: None,
            collected_at: None,
            depends_on: vec![],
            skipped_symbols: vec![],
            classes: vec![],
            protocols: vec![Protocol {
                name: "ItemIterating".to_string(),
                inherits: vec![],
                required_methods: vec![block_method],
                optional_methods: vec![],
                properties: vec![],
                source: None,
                provenance: None,
                doc_refs: None,
            }],
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
    fn annotate_framework_annotates_protocol_methods() {
        // FU-1: a protocol-only framework must still receive annotations.
        // Before the fix, `annotate_framework` iterated only `classes`, so a
        // zero-class framework produced an empty `class_annotations`.
        let result = annotate_framework(&protocol_only_framework(), None);

        let proto = result
            .class_annotations
            .iter()
            .find(|c| c.class_name == "ItemIterating")
            .expect("protocol methods must appear in class_annotations");
        assert_eq!(proto.methods.len(), 1);
        assert_eq!(proto.methods[0].selector, "enumerateItemsUsingBlock:");
        assert_eq!(
            proto.methods[0].block_parameters.len(),
            1,
            "the protocol method's block parameter must be classified"
        );
    }
}
