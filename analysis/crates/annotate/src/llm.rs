//! LLM annotation support: extraction of interesting methods and loading of LLM results.
//!
//! Two main operations:
//! 1. **Extract** — filter a framework's methods to those needing LLM classification
//!    (block params, error out-params, delegate patterns) and write a compact summary
//!    for Claude Code subagents to analyze.
//! 2. **Load** — read `.llm.json` files produced by subagents and convert to
//!    `FrameworkAnnotations` for merge with heuristic results.

use std::path::Path;

use anyhow::{Context, Result};
use serde::{Deserialize, Serialize};

use apianyware_macos_types::annotation::{
    BlockInvocationStyle, FrameworkAnnotations, ThreadingConstraint,
};
use apianyware_macos_types::ir::Framework;
use apianyware_macos_types::type_ref::TypeRefKind;

/// Compact summary of a framework's methods needing LLM annotation.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FrameworkSummary {
    /// Framework name.
    pub framework: String,
    /// Classes containing interesting methods.
    pub classes: Vec<ClassSummary>,
    /// Total number of methods across all classes.
    pub method_count: usize,
}

/// Compact class summary for LLM consumption.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ClassSummary {
    /// Class name.
    pub class_name: String,
    /// Methods needing LLM classification.
    pub methods: Vec<MethodSummary>,
}

/// Compact method summary for LLM consumption.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MethodSummary {
    /// Selector name (e.g., `"dataTaskWithURL:completionHandler:"`).
    pub selector: String,
    /// `true` for instance methods, `false` for class methods.
    pub is_instance: bool,
    /// Parameter summaries.
    pub params: Vec<ParamSummary>,
    /// Return type description.
    pub return_type: String,
    /// Why this method was flagged for LLM review.
    pub reasons: Vec<String>,
}

/// Compact parameter summary for LLM consumption.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ParamSummary {
    /// Parameter name.
    pub name: String,
    /// Type kind description (e.g., `"block"`, `"id"`, `"pointer"`).
    pub type_kind: String,
}

/// Extract methods needing LLM classification from a resolved framework.
///
/// A method is "interesting" if it has:
/// - Block-typed parameters (invocation style may be ambiguous)
/// - A likely error out-param (last param named `error` with pointer type)
/// - A selector suggesting delegate/observer/target patterns
pub fn extract_interesting_methods(framework: &Framework) -> FrameworkSummary {
    let mut classes = Vec::new();
    let mut total_methods = 0;

    for class in &framework.classes {
        let mut methods = Vec::new();

        // Use effective methods if available, else direct methods
        let method_list = if class.all_methods.is_empty() {
            &class.methods
        } else {
            &class.all_methods
        };

        for method in method_list {
            let reasons = classify_interest(method);
            if reasons.is_empty() {
                continue;
            }

            methods.push(MethodSummary {
                selector: method.selector.clone(),
                is_instance: !method.class_method,
                params: method
                    .params
                    .iter()
                    .map(|p| ParamSummary {
                        name: p.name.clone(),
                        type_kind: describe_type_kind(&p.param_type.kind),
                    })
                    .collect(),
                return_type: describe_type_kind(&method.return_type.kind),
                reasons,
            });
        }

        // Also check category methods
        for category_group in &class.category_methods {
            for method in &category_group.methods {
                let reasons = classify_interest(method);
                if reasons.is_empty() {
                    continue;
                }

                methods.push(MethodSummary {
                    selector: method.selector.clone(),
                    is_instance: !method.class_method,
                    params: method
                        .params
                        .iter()
                        .map(|p| ParamSummary {
                            name: p.name.clone(),
                            type_kind: describe_type_kind(&p.param_type.kind),
                        })
                        .collect(),
                    return_type: describe_type_kind(&method.return_type.kind),
                    reasons,
                });
            }
        }

        if !methods.is_empty() {
            total_methods += methods.len();
            classes.push(ClassSummary {
                class_name: class.name.clone(),
                methods,
            });
        }
    }

    FrameworkSummary {
        framework: framework.name.clone(),
        classes,
        method_count: total_methods,
    }
}

/// Determine why a method is "interesting" for LLM annotation.
fn classify_interest(method: &apianyware_macos_types::ir::Method) -> Vec<String> {
    let mut reasons = Vec::new();
    let sel_lower = method.selector.to_lowercase();

    // Block parameters — invocation style may be ambiguous
    let has_block = method
        .params
        .iter()
        .any(|p| matches!(p.param_type.kind, TypeRefKind::Block { .. }));
    if has_block {
        reasons.push("has_block_params".to_string());
    }

    // Error out-param — last param named "error" with pointer type
    if let Some(last) = method.params.last() {
        let name_lower = last.name.to_lowercase();
        if (name_lower == "error" || name_lower.ends_with("error"))
            && matches!(last.param_type.kind, TypeRefKind::Pointer)
        {
            reasons.push("error_out_param".to_string());
        }
    }

    // Delegate/observer/target patterns in selector
    if sel_lower.contains("delegate")
        || sel_lower.contains("datasource")
        || sel_lower.contains("observer")
    {
        reasons.push("delegate_observer_pattern".to_string());
    }

    reasons
}

/// Produce a human-readable description of a type kind for LLM context.
fn describe_type_kind(kind: &TypeRefKind) -> String {
    match kind {
        TypeRefKind::Id => "id".to_string(),
        TypeRefKind::Class { name, .. } => format!("class:{name}"),
        TypeRefKind::ClassRef => "Class".to_string(),
        TypeRefKind::Selector => "SEL".to_string(),
        TypeRefKind::CString => "c_string".to_string(),
        TypeRefKind::Pointer => "pointer".to_string(),
        TypeRefKind::Primitive { name } => name.clone(),
        TypeRefKind::Struct { name } => format!("struct:{name}"),
        TypeRefKind::Alias { name, .. } => format!("alias:{name}"),
        TypeRefKind::Block { .. } => "block".to_string(),
        TypeRefKind::FunctionPointer { .. } => "function_pointer".to_string(),
        TypeRefKind::Instancetype => "instancetype".to_string(),
    }
}

/// Extract interesting methods from all resolved frameworks and write summaries.
///
/// Loads all frameworks from `input_dir`, extracts interesting methods, and
/// writes per-framework `.methods.json` files to `output_dir`. Frameworks
/// with no interesting methods are skipped.
pub fn extract_all_frameworks(
    input_dir: &Path,
    output_dir: &Path,
    only: Option<&[String]>,
) -> Result<Vec<FrameworkSummary>> {
    let frameworks = apianyware_macos_datalog::loading::load_all_frameworks(input_dir, only)?;
    if frameworks.is_empty() {
        anyhow::bail!("no frameworks found in {}", input_dir.display());
    }

    tracing::info!(
        count = frameworks.len(),
        "loaded frameworks for LLM extraction"
    );

    let mut summaries = Vec::new();

    for framework in &frameworks {
        let summary = extract_interesting_methods(framework);
        if summary.method_count == 0 {
            tracing::info!(framework = %framework.name, "no interesting methods, skipping");
            continue;
        }

        write_method_summary(&summary, output_dir)?;
        summaries.push(summary);
    }

    Ok(summaries)
}

/// Write a framework method summary to a JSON file.
pub fn write_method_summary(summary: &FrameworkSummary, output_dir: &Path) -> Result<()> {
    std::fs::create_dir_all(output_dir)
        .with_context(|| format!("failed to create {}", output_dir.display()))?;

    let path = output_dir.join(format!("{}.methods.json", summary.framework));
    let json = serde_json::to_string_pretty(summary)
        .with_context(|| format!("failed to serialize summary for {}", summary.framework))?;
    std::fs::write(&path, json).with_context(|| format!("failed to write {}", path.display()))?;

    tracing::info!(
        framework = %summary.framework,
        classes = summary.classes.len(),
        methods = summary.method_count,
        path = %path.display(),
        "wrote method summary"
    );

    Ok(())
}

/// Load LLM annotations from a `.llm.json` file.
///
/// Returns `None` if the file doesn't exist. Returns an error if the file
/// exists but is malformed.
pub fn load_llm_annotations(
    llm_dir: &Path,
    framework_name: &str,
) -> Result<Option<FrameworkAnnotations>> {
    let path = llm_dir.join(format!("{framework_name}.llm.json"));
    if !path.exists() {
        return Ok(None);
    }

    let content = std::fs::read_to_string(&path)
        .with_context(|| format!("failed to read {}", path.display()))?;

    let annotations: FrameworkAnnotations = serde_json::from_str(&content)
        .with_context(|| format!("failed to parse LLM annotations from {}", path.display()))?;

    let method_count: usize = annotations.classes.iter().map(|c| c.methods.len()).sum();
    tracing::info!(
        framework = framework_name,
        classes = annotations.classes.len(),
        methods = method_count,
        "loaded LLM annotations"
    );

    Ok(Some(annotations))
}

/// Semantic mismatch between an LLM annotations file and its source method summary.
///
/// Serde already enforces JSON shape and enum-variant validity; these errors cover
/// what serde cannot see — references to classes/selectors/parameters that do not
/// exist in the original `.methods.json` summary, or annotations whose `source`
/// is not `Llm`.
#[derive(Debug, thiserror::Error)]
pub enum ValidationError {
    #[error("framework name mismatch: summary has {expected:?}, annotations have {actual:?}")]
    FrameworkMismatch { expected: String, actual: String },

    #[error("class {class:?} in annotations not found in methods summary")]
    UnknownClass { class: String },

    #[error("class {class:?}: selector {selector:?} not found in methods summary")]
    UnknownSelector { class: String, selector: String },

    #[error(
        "class {class:?} selector {selector:?}: is_instance ({actual}) does not match \
         summary ({expected})"
    )]
    IsInstanceMismatch {
        class: String,
        selector: String,
        expected: bool,
        actual: bool,
    },

    #[error(
        "class {class:?} selector {selector:?}: parameter_ownership param_index {index} \
         out of range (params: {n_params})"
    )]
    ParamOwnershipOutOfRange {
        class: String,
        selector: String,
        index: usize,
        n_params: usize,
    },

    #[error(
        "class {class:?} selector {selector:?}: block_parameters param_index {index} \
         out of range (params: {n_params})"
    )]
    BlockParamOutOfRange {
        class: String,
        selector: String,
        index: usize,
        n_params: usize,
    },

    #[error(
        "class {class:?} selector {selector:?}: block_parameters param_index {index} \
         refers to non-block param of type {kind:?}"
    )]
    BlockParamNotBlockType {
        class: String,
        selector: String,
        index: usize,
        kind: String,
    },

    #[error("class {class:?} selector {selector:?}: source must be \"llm\", got {actual:?}")]
    WrongSource {
        class: String,
        selector: String,
        actual: String,
    },
}

/// Non-fatal divergence between the subagent's self-reported counts and the
/// actual aggregate counts in the `.llm.json` file. The file content is
/// authoritative for downstream merge — these warnings exist to flag the
/// CoreData-style discrepancy where a subagent's narrative report disagrees
/// with what it wrote (e.g. report claims `async_copied=18 / stored=8`,
/// `jq` of the file finds `15 / 11`).
#[derive(Debug, thiserror::Error)]
pub enum ValidationWarning {
    #[error("subagent_report.{field} = {reported} but file contains {actual}")]
    SubagentReportMismatch {
        field: &'static str,
        reported: usize,
        actual: usize,
    },
}

/// Aggregated validation result. Holds every error found so subagents can fix
/// all problems in one pass instead of one-at-a-time. Warnings are non-fatal
/// signals (e.g. subagent self-report divergence) that surface alongside errors
/// but do not affect `is_ok()`.
#[derive(Debug, Default)]
pub struct ValidationReport {
    pub errors: Vec<ValidationError>,
    pub warnings: Vec<ValidationWarning>,
}

impl ValidationReport {
    pub fn is_ok(&self) -> bool {
        self.errors.is_empty()
    }
}

/// Aggregate counts computed by walking the actual content of a
/// `FrameworkAnnotations`. Used to reconcile against `SubagentReport`.
#[derive(Debug, Default, Clone, PartialEq, Eq)]
struct ActualCounts {
    block_synchronous: usize,
    block_async_copied: usize,
    block_stored: usize,
    parameter_ownership: usize,
    threading_main_thread_only: usize,
    threading_any_thread: usize,
    error_pattern: usize,
}

fn aggregate_actual_counts(annotations: &FrameworkAnnotations) -> ActualCounts {
    let mut counts = ActualCounts::default();
    for class in &annotations.classes {
        for method in &class.methods {
            for block in &method.block_parameters {
                match block.invocation {
                    BlockInvocationStyle::Synchronous => counts.block_synchronous += 1,
                    BlockInvocationStyle::AsyncCopied => counts.block_async_copied += 1,
                    BlockInvocationStyle::Stored => counts.block_stored += 1,
                }
            }
            counts.parameter_ownership += method.parameter_ownership.len();
            if let Some(t) = method.threading {
                match t {
                    ThreadingConstraint::MainThreadOnly => counts.threading_main_thread_only += 1,
                    ThreadingConstraint::AnyThread => counts.threading_any_thread += 1,
                }
            }
            if method.error_pattern.is_some() {
                counts.error_pattern += 1;
            }
        }
    }
    counts
}

/// Cross-validate `.llm.json` annotations against the corresponding `.methods.json`
/// summary that the subagent was asked to annotate.
///
/// Validates that:
/// - the `framework` names match,
/// - every class in the annotations exists in the summary,
/// - every selector in those classes exists in the summary,
/// - `is_instance` agrees with the summary,
/// - every `parameter_ownership.param_index` and `block_parameters.param_index`
///   is in range,
/// - every `block_parameters.param_index` points at a parameter whose `type_kind`
///   is `"block"`,
/// - every annotation has `source: "llm"`.
pub fn validate_llm_annotations(
    summary: &FrameworkSummary,
    annotations: &FrameworkAnnotations,
) -> ValidationReport {
    let mut report = ValidationReport::default();

    if summary.framework != annotations.framework {
        report.errors.push(ValidationError::FrameworkMismatch {
            expected: summary.framework.clone(),
            actual: annotations.framework.clone(),
        });
    }

    for class_ann in &annotations.classes {
        let Some(class_summary) = summary
            .classes
            .iter()
            .find(|c| c.class_name == class_ann.class_name)
        else {
            report.errors.push(ValidationError::UnknownClass {
                class: class_ann.class_name.clone(),
            });
            continue;
        };

        for method_ann in &class_ann.methods {
            let Some(method_summary) = class_summary
                .methods
                .iter()
                .find(|m| m.selector == method_ann.selector)
            else {
                report.errors.push(ValidationError::UnknownSelector {
                    class: class_ann.class_name.clone(),
                    selector: method_ann.selector.clone(),
                });
                continue;
            };

            if method_summary.is_instance != method_ann.is_instance {
                report.errors.push(ValidationError::IsInstanceMismatch {
                    class: class_ann.class_name.clone(),
                    selector: method_ann.selector.clone(),
                    expected: method_summary.is_instance,
                    actual: method_ann.is_instance,
                });
            }

            let n_params = method_summary.params.len();

            for ownership in &method_ann.parameter_ownership {
                if ownership.param_index >= n_params {
                    report
                        .errors
                        .push(ValidationError::ParamOwnershipOutOfRange {
                            class: class_ann.class_name.clone(),
                            selector: method_ann.selector.clone(),
                            index: ownership.param_index,
                            n_params,
                        });
                }
            }

            for block in &method_ann.block_parameters {
                if block.param_index >= n_params {
                    report.errors.push(ValidationError::BlockParamOutOfRange {
                        class: class_ann.class_name.clone(),
                        selector: method_ann.selector.clone(),
                        index: block.param_index,
                        n_params,
                    });
                    continue;
                }
                let kind = &method_summary.params[block.param_index].type_kind;
                if kind != "block" {
                    report.errors.push(ValidationError::BlockParamNotBlockType {
                        class: class_ann.class_name.clone(),
                        selector: method_ann.selector.clone(),
                        index: block.param_index,
                        kind: kind.clone(),
                    });
                }
            }

            if !matches!(
                method_ann.source,
                apianyware_macos_types::annotation::AnnotationSource::Llm
            ) {
                report.errors.push(ValidationError::WrongSource {
                    class: class_ann.class_name.clone(),
                    selector: method_ann.selector.clone(),
                    actual: format!("{:?}", method_ann.source).to_lowercase(),
                });
            }
        }
    }

    if let Some(subagent) = &annotations.subagent_report {
        let actual = aggregate_actual_counts(annotations);
        let checks: [(Option<usize>, &'static str, usize); 7] = [
            (
                subagent.block_synchronous,
                "block_synchronous",
                actual.block_synchronous,
            ),
            (
                subagent.block_async_copied,
                "block_async_copied",
                actual.block_async_copied,
            ),
            (subagent.block_stored, "block_stored", actual.block_stored),
            (
                subagent.parameter_ownership,
                "parameter_ownership",
                actual.parameter_ownership,
            ),
            (
                subagent.threading_main_thread_only,
                "threading_main_thread_only",
                actual.threading_main_thread_only,
            ),
            (
                subagent.threading_any_thread,
                "threading_any_thread",
                actual.threading_any_thread,
            ),
            (
                subagent.error_pattern,
                "error_pattern",
                actual.error_pattern,
            ),
        ];
        for (reported_opt, field, actual_count) in checks {
            if let Some(reported) = reported_opt {
                if reported != actual_count {
                    report
                        .warnings
                        .push(ValidationWarning::SubagentReportMismatch {
                            field,
                            reported,
                            actual: actual_count,
                        });
                }
            }
        }
    }

    report
}

/// Validate a `.llm.json` file against its source `.methods.json` summary.
///
/// Returns the validation report. Returns an error only for I/O or JSON-parse
/// failures — semantic mismatches are surfaced via `ValidationReport.errors`.
pub fn validate_llm_file(methods_path: &Path, llm_path: &Path) -> Result<ValidationReport> {
    let methods_json = std::fs::read_to_string(methods_path)
        .with_context(|| format!("failed to read {}", methods_path.display()))?;
    let summary: FrameworkSummary = serde_json::from_str(&methods_json)
        .with_context(|| format!("failed to parse {}", methods_path.display()))?;

    let llm_json = std::fs::read_to_string(llm_path)
        .with_context(|| format!("failed to read {}", llm_path.display()))?;
    let annotations: FrameworkAnnotations = serde_json::from_str(&llm_json)
        .with_context(|| format!("failed to parse {}", llm_path.display()))?;

    Ok(validate_llm_annotations(&summary, &annotations))
}

/// Scan an LLM annotations directory and return framework names that have `.llm.json` files.
pub fn discover_llm_annotations(llm_dir: &Path) -> Result<Vec<String>> {
    if !llm_dir.exists() {
        return Ok(Vec::new());
    }

    let mut frameworks = Vec::new();
    for entry in std::fs::read_dir(llm_dir)
        .with_context(|| format!("failed to read {}", llm_dir.display()))?
    {
        let entry = entry?;
        let name = entry.file_name();
        let name_str = name.to_string_lossy();
        if let Some(fw_name) = name_str.strip_suffix(".llm.json") {
            frameworks.push(fw_name.to_string());
        }
    }

    frameworks.sort();
    Ok(frameworks)
}

#[cfg(test)]
mod tests {
    use super::*;
    use apianyware_macos_types::annotation::{
        AnnotationSource, BlockInvocationStyle, BlockParamAnnotation, ClassAnnotations,
        MethodAnnotation, OwnershipKind, ParamOwnership, SubagentReport,
    };
    use apianyware_macos_types::ir::{CategoryGroup, Class, Method, Param};
    use apianyware_macos_types::type_ref::TypeRef;

    fn void_type() -> TypeRef {
        TypeRef {
            nullable: false,
            kind: TypeRefKind::Primitive {
                name: "void".to_string(),
            },
        }
    }

    fn id_type() -> TypeRef {
        TypeRef {
            nullable: false,
            kind: TypeRefKind::Id,
        }
    }

    fn block_type() -> TypeRef {
        TypeRef {
            nullable: false,
            kind: TypeRefKind::Block {
                params: vec![],
                return_type: Box::new(void_type()),
            },
        }
    }

    fn pointer_type() -> TypeRef {
        TypeRef {
            nullable: false,
            kind: TypeRefKind::Pointer,
        }
    }

    fn make_method(selector: &str, params: Vec<Param>, return_type: TypeRef) -> Method {
        Method {
            selector: selector.to_string(),
            class_method: false,
            init_method: false,
            params,
            return_type,
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

    fn make_class(name: &str, methods: Vec<Method>) -> Class {
        Class {
            name: name.to_string(),
            superclass: String::new(),
            protocols: vec![],
            properties: vec![],
            methods,
            category_methods: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
        }
    }

    fn make_framework(name: &str, classes: Vec<Class>) -> Framework {
        Framework {
            format_version: String::new(),
            checkpoint: "resolved".to_string(),
            name: name.to_string(),
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
    fn extract_method_with_block_param() {
        let method = make_method(
            "performWithCompletion:",
            vec![Param {
                name: "handler".to_string(),
                param_type: block_type(),
            }],
            void_type(),
        );
        let fw = make_framework("TestKit", vec![make_class("TKFoo", vec![method])]);

        let summary = extract_interesting_methods(&fw);

        assert_eq!(summary.framework, "TestKit");
        assert_eq!(summary.classes.len(), 1);
        assert_eq!(summary.classes[0].methods.len(), 1);
        assert_eq!(
            summary.classes[0].methods[0].selector,
            "performWithCompletion:"
        );
        assert!(summary.classes[0].methods[0]
            .reasons
            .contains(&"has_block_params".to_string()));
    }

    #[test]
    fn extract_method_with_error_outparam() {
        let method = make_method(
            "writeToURL:error:",
            vec![
                Param {
                    name: "url".to_string(),
                    param_type: id_type(),
                },
                Param {
                    name: "error".to_string(),
                    param_type: pointer_type(),
                },
            ],
            id_type(),
        );
        let fw = make_framework("TestKit", vec![make_class("TKWriter", vec![method])]);

        let summary = extract_interesting_methods(&fw);

        assert_eq!(summary.classes.len(), 1);
        assert!(summary.classes[0].methods[0]
            .reasons
            .contains(&"error_out_param".to_string()));
    }

    #[test]
    fn extract_method_with_delegate_selector() {
        let method = make_method(
            "setDelegate:",
            vec![Param {
                name: "delegate".to_string(),
                param_type: id_type(),
            }],
            void_type(),
        );
        let fw = make_framework("TestKit", vec![make_class("TKView", vec![method])]);

        let summary = extract_interesting_methods(&fw);

        assert_eq!(summary.classes.len(), 1);
        assert!(summary.classes[0].methods[0]
            .reasons
            .contains(&"delegate_observer_pattern".to_string()));
    }

    #[test]
    fn skip_boring_method() {
        let method = make_method(
            "count",
            vec![],
            TypeRef {
                nullable: false,
                kind: TypeRefKind::Primitive {
                    name: "NSUInteger".to_string(),
                },
            },
        );
        let fw = make_framework("TestKit", vec![make_class("TKArray", vec![method])]);

        let summary = extract_interesting_methods(&fw);

        assert_eq!(summary.classes.len(), 0);
        assert_eq!(summary.method_count, 0);
    }

    #[test]
    fn multiple_reasons_on_same_method() {
        // A method with both a block param and delegate in the selector
        let method = make_method(
            "addObserverWithBlock:",
            vec![Param {
                name: "block".to_string(),
                param_type: block_type(),
            }],
            void_type(),
        );
        let fw = make_framework("TestKit", vec![make_class("TKCenter", vec![method])]);

        let summary = extract_interesting_methods(&fw);

        assert_eq!(summary.classes[0].methods[0].reasons.len(), 2);
        assert!(summary.classes[0].methods[0]
            .reasons
            .contains(&"has_block_params".to_string()));
        assert!(summary.classes[0].methods[0]
            .reasons
            .contains(&"delegate_observer_pattern".to_string()));
    }

    #[test]
    fn method_count_tracks_total() {
        let methods = vec![
            make_method(
                "setDelegate:",
                vec![Param {
                    name: "d".to_string(),
                    param_type: id_type(),
                }],
                void_type(),
            ),
            make_method(
                "doBlock:",
                vec![Param {
                    name: "b".to_string(),
                    param_type: block_type(),
                }],
                void_type(),
            ),
        ];
        let fw = make_framework("TestKit", vec![make_class("TKFoo", methods)]);

        let summary = extract_interesting_methods(&fw);

        assert_eq!(summary.method_count, 2);
    }

    #[test]
    fn category_methods_included() {
        let mut class = make_class("TKBase", vec![]);
        class.category_methods.push(CategoryGroup {
            category: "TKExtension".to_string(),
            origin_framework: "TestKit".to_string(),
            methods: vec![make_method(
                "performBlock:",
                vec![Param {
                    name: "block".to_string(),
                    param_type: block_type(),
                }],
                void_type(),
            )],
        });
        let fw = make_framework("TestKit", vec![class]);

        let summary = extract_interesting_methods(&fw);

        assert_eq!(summary.classes.len(), 1);
        assert_eq!(summary.classes[0].methods.len(), 1);
        assert_eq!(summary.classes[0].methods[0].selector, "performBlock:");
    }

    #[test]
    fn type_kind_descriptions() {
        assert_eq!(describe_type_kind(&TypeRefKind::Id), "id");
        assert_eq!(describe_type_kind(&TypeRefKind::Pointer), "pointer");
        assert_eq!(
            describe_type_kind(&TypeRefKind::Primitive {
                name: "BOOL".to_string()
            }),
            "BOOL"
        );
        assert_eq!(
            describe_type_kind(&TypeRefKind::Struct {
                name: "CGRect".to_string()
            }),
            "struct:CGRect"
        );
        assert_eq!(describe_type_kind(&block_type().kind), "block");
    }

    #[test]
    fn load_nonexistent_llm_file_returns_none() {
        let dir = std::env::temp_dir().join("test_llm_load_none");
        let _ = std::fs::create_dir_all(&dir);
        let result = load_llm_annotations(&dir, "Nonexistent").unwrap();
        assert!(result.is_none());
    }

    #[test]
    fn load_valid_llm_file() {
        let dir = std::env::temp_dir().join("test_llm_load_valid");
        let _ = std::fs::create_dir_all(&dir);

        let annotations = FrameworkAnnotations {
            framework: "TestKit".to_string(),
            classes: vec![ClassAnnotations {
                class_name: "TKFoo".to_string(),
                methods: vec![],
            }],
            subagent_report: None,
        };

        let path = dir.join("TestKit.llm.json");
        std::fs::write(&path, serde_json::to_string(&annotations).unwrap()).unwrap();

        let result = load_llm_annotations(&dir, "TestKit").unwrap();
        assert!(result.is_some());
        let fa = result.unwrap();
        assert_eq!(fa.framework, "TestKit");
        assert_eq!(fa.classes.len(), 1);

        // Cleanup
        let _ = std::fs::remove_dir_all(&dir);
    }

    #[test]
    fn load_malformed_llm_file_returns_error() {
        let dir = std::env::temp_dir().join("test_llm_load_bad");
        let _ = std::fs::create_dir_all(&dir);

        let path = dir.join("BadKit.llm.json");
        std::fs::write(&path, "not valid json {{{").unwrap();

        let result = load_llm_annotations(&dir, "BadKit");
        assert!(result.is_err());

        let _ = std::fs::remove_dir_all(&dir);
    }

    #[test]
    fn discover_llm_annotations_finds_files() {
        let dir = std::env::temp_dir().join("test_llm_discover");
        let _ = std::fs::create_dir_all(&dir);

        std::fs::write(dir.join("Foundation.llm.json"), "{}").unwrap();
        std::fs::write(dir.join("AppKit.llm.json"), "{}").unwrap();
        std::fs::write(dir.join("other.json"), "{}").unwrap(); // not .llm.json

        let result = discover_llm_annotations(&dir).unwrap();
        assert_eq!(result, vec!["AppKit", "Foundation"]);

        let _ = std::fs::remove_dir_all(&dir);
    }

    #[test]
    fn discover_nonexistent_dir_returns_empty() {
        let dir = std::env::temp_dir().join("test_llm_discover_none_12345");
        let result = discover_llm_annotations(&dir).unwrap();
        assert!(result.is_empty());
    }

    fn make_summary(framework: &str, classes: Vec<ClassSummary>) -> FrameworkSummary {
        let method_count = classes.iter().map(|c| c.methods.len()).sum();
        FrameworkSummary {
            framework: framework.to_string(),
            classes,
            method_count,
        }
    }

    fn block_method_summary(selector: &str, is_instance: bool) -> MethodSummary {
        MethodSummary {
            selector: selector.to_string(),
            is_instance,
            params: vec![ParamSummary {
                name: "handler".to_string(),
                type_kind: "block".to_string(),
            }],
            return_type: "void".to_string(),
            reasons: vec!["has_block_params".to_string()],
        }
    }

    fn delegate_method_summary(selector: &str) -> MethodSummary {
        MethodSummary {
            selector: selector.to_string(),
            is_instance: true,
            params: vec![ParamSummary {
                name: "delegate".to_string(),
                type_kind: "id".to_string(),
            }],
            return_type: "void".to_string(),
            reasons: vec!["delegate_observer_pattern".to_string()],
        }
    }

    fn block_annotation(selector: &str, index: usize) -> MethodAnnotation {
        MethodAnnotation {
            selector: selector.to_string(),
            is_instance: true,
            parameter_ownership: vec![],
            block_parameters: vec![BlockParamAnnotation {
                param_index: index,
                invocation: BlockInvocationStyle::AsyncCopied,
            }],
            threading: None,
            error_pattern: None,
            source: AnnotationSource::Llm,
        }
    }

    #[test]
    fn validate_passes_for_well_formed_annotations() {
        let summary = make_summary(
            "TestKit",
            vec![ClassSummary {
                class_name: "TKFoo".to_string(),
                methods: vec![block_method_summary("doBlock:", true)],
            }],
        );
        let annotations = FrameworkAnnotations {
            framework: "TestKit".to_string(),
            classes: vec![ClassAnnotations {
                class_name: "TKFoo".to_string(),
                methods: vec![block_annotation("doBlock:", 0)],
            }],
            subagent_report: None,
        };

        let report = validate_llm_annotations(&summary, &annotations);

        assert!(report.is_ok(), "expected ok, got {:?}", report.errors);
    }

    #[test]
    fn validate_rejects_framework_name_mismatch() {
        let summary = make_summary("TestKit", vec![]);
        let annotations = FrameworkAnnotations {
            framework: "WrongKit".to_string(),
            classes: vec![],
            subagent_report: None,
        };

        let report = validate_llm_annotations(&summary, &annotations);

        assert!(!report.is_ok());
        assert!(matches!(
            report.errors[0],
            ValidationError::FrameworkMismatch { .. }
        ));
    }

    #[test]
    fn validate_rejects_unknown_class() {
        let summary = make_summary(
            "TestKit",
            vec![ClassSummary {
                class_name: "TKFoo".to_string(),
                methods: vec![block_method_summary("doBlock:", true)],
            }],
        );
        let annotations = FrameworkAnnotations {
            framework: "TestKit".to_string(),
            classes: vec![ClassAnnotations {
                class_name: "TKBar".to_string(),
                methods: vec![block_annotation("doBlock:", 0)],
            }],
            subagent_report: None,
        };

        let report = validate_llm_annotations(&summary, &annotations);

        assert!(!report.is_ok());
        assert!(report
            .errors
            .iter()
            .any(|e| matches!(e, ValidationError::UnknownClass { class } if class == "TKBar")));
    }

    #[test]
    fn validate_rejects_unknown_selector() {
        let summary = make_summary(
            "TestKit",
            vec![ClassSummary {
                class_name: "TKFoo".to_string(),
                methods: vec![block_method_summary("doBlock:", true)],
            }],
        );
        let annotations = FrameworkAnnotations {
            framework: "TestKit".to_string(),
            classes: vec![ClassAnnotations {
                class_name: "TKFoo".to_string(),
                methods: vec![block_annotation("notARealSelector:", 0)],
            }],
            subagent_report: None,
        };

        let report = validate_llm_annotations(&summary, &annotations);

        assert!(!report.is_ok());
        assert!(report.errors.iter().any(|e| matches!(
            e,
            ValidationError::UnknownSelector { selector, .. } if selector == "notARealSelector:"
        )));
    }

    #[test]
    fn validate_rejects_param_ownership_index_out_of_range() {
        let summary = make_summary(
            "TestKit",
            vec![ClassSummary {
                class_name: "TKFoo".to_string(),
                methods: vec![delegate_method_summary("setDelegate:")],
            }],
        );
        let annotations = FrameworkAnnotations {
            framework: "TestKit".to_string(),
            classes: vec![ClassAnnotations {
                class_name: "TKFoo".to_string(),
                methods: vec![MethodAnnotation {
                    selector: "setDelegate:".to_string(),
                    is_instance: true,
                    parameter_ownership: vec![ParamOwnership {
                        param_index: 5,
                        ownership: OwnershipKind::Weak,
                    }],
                    block_parameters: vec![],
                    threading: None,
                    error_pattern: None,
                    source: AnnotationSource::Llm,
                }],
            }],
            subagent_report: None,
        };

        let report = validate_llm_annotations(&summary, &annotations);

        assert!(!report.is_ok());
        assert!(report.errors.iter().any(|e| matches!(
            e,
            ValidationError::ParamOwnershipOutOfRange {
                index: 5,
                n_params: 1,
                ..
            }
        )));
    }

    #[test]
    fn validate_rejects_block_param_index_out_of_range() {
        let summary = make_summary(
            "TestKit",
            vec![ClassSummary {
                class_name: "TKFoo".to_string(),
                methods: vec![block_method_summary("doBlock:", true)],
            }],
        );
        let annotations = FrameworkAnnotations {
            framework: "TestKit".to_string(),
            classes: vec![ClassAnnotations {
                class_name: "TKFoo".to_string(),
                methods: vec![block_annotation("doBlock:", 7)],
            }],
            subagent_report: None,
        };

        let report = validate_llm_annotations(&summary, &annotations);

        assert!(!report.is_ok());
        assert!(report.errors.iter().any(|e| matches!(
            e,
            ValidationError::BlockParamOutOfRange {
                index: 7,
                n_params: 1,
                ..
            }
        )));
    }

    #[test]
    fn validate_rejects_block_param_index_pointing_to_non_block() {
        // Method has one id param, not a block — annotation says param 0 is a block.
        let summary = make_summary(
            "TestKit",
            vec![ClassSummary {
                class_name: "TKFoo".to_string(),
                methods: vec![delegate_method_summary("setDelegate:")],
            }],
        );
        let annotations = FrameworkAnnotations {
            framework: "TestKit".to_string(),
            classes: vec![ClassAnnotations {
                class_name: "TKFoo".to_string(),
                methods: vec![block_annotation("setDelegate:", 0)],
            }],
            subagent_report: None,
        };

        let report = validate_llm_annotations(&summary, &annotations);

        assert!(!report.is_ok());
        assert!(report.errors.iter().any(|e| matches!(
            e,
            ValidationError::BlockParamNotBlockType { kind, .. } if kind == "id"
        )));
    }

    #[test]
    fn validate_rejects_wrong_source() {
        let summary = make_summary(
            "TestKit",
            vec![ClassSummary {
                class_name: "TKFoo".to_string(),
                methods: vec![block_method_summary("doBlock:", true)],
            }],
        );
        let annotations = FrameworkAnnotations {
            framework: "TestKit".to_string(),
            classes: vec![ClassAnnotations {
                class_name: "TKFoo".to_string(),
                methods: vec![MethodAnnotation {
                    selector: "doBlock:".to_string(),
                    is_instance: true,
                    parameter_ownership: vec![],
                    block_parameters: vec![BlockParamAnnotation {
                        param_index: 0,
                        invocation: BlockInvocationStyle::AsyncCopied,
                    }],
                    threading: None,
                    error_pattern: None,
                    source: AnnotationSource::Heuristic,
                }],
            }],
            subagent_report: None,
        };

        let report = validate_llm_annotations(&summary, &annotations);

        assert!(!report.is_ok());
        assert!(report
            .errors
            .iter()
            .any(|e| matches!(e, ValidationError::WrongSource { .. })));
    }

    #[test]
    fn validate_rejects_is_instance_mismatch() {
        let summary = make_summary(
            "TestKit",
            vec![ClassSummary {
                class_name: "TKFoo".to_string(),
                // Class method in summary
                methods: vec![block_method_summary("doBlock:", false)],
            }],
        );
        let annotations = FrameworkAnnotations {
            framework: "TestKit".to_string(),
            classes: vec![ClassAnnotations {
                class_name: "TKFoo".to_string(),
                // Annotation says instance method
                methods: vec![block_annotation("doBlock:", 0)],
            }],
            subagent_report: None,
        };

        let report = validate_llm_annotations(&summary, &annotations);

        assert!(!report.is_ok());
        assert!(report
            .errors
            .iter()
            .any(|e| matches!(e, ValidationError::IsInstanceMismatch { .. })));
    }

    #[test]
    fn validate_llm_file_happy_path() {
        let dir = std::env::temp_dir().join("test_llm_validate_files_ok");
        let _ = std::fs::remove_dir_all(&dir);
        std::fs::create_dir_all(&dir).unwrap();

        let summary = make_summary(
            "TestKit",
            vec![ClassSummary {
                class_name: "TKFoo".to_string(),
                methods: vec![block_method_summary("doBlock:", true)],
            }],
        );
        let methods_path = dir.join("TestKit.methods.json");
        std::fs::write(&methods_path, serde_json::to_string(&summary).unwrap()).unwrap();

        let annotations = FrameworkAnnotations {
            framework: "TestKit".to_string(),
            classes: vec![ClassAnnotations {
                class_name: "TKFoo".to_string(),
                methods: vec![block_annotation("doBlock:", 0)],
            }],
            subagent_report: None,
        };
        let llm_path = dir.join("TestKit.llm.json");
        std::fs::write(&llm_path, serde_json::to_string(&annotations).unwrap()).unwrap();

        let report = validate_llm_file(&methods_path, &llm_path).unwrap();
        assert!(report.is_ok(), "expected ok, got {:?}", report.errors);

        let _ = std::fs::remove_dir_all(&dir);
    }

    #[test]
    fn validate_llm_file_surfaces_semantic_errors() {
        let dir = std::env::temp_dir().join("test_llm_validate_files_bad");
        let _ = std::fs::remove_dir_all(&dir);
        std::fs::create_dir_all(&dir).unwrap();

        let summary = make_summary(
            "TestKit",
            vec![ClassSummary {
                class_name: "TKFoo".to_string(),
                methods: vec![block_method_summary("doBlock:", true)],
            }],
        );
        std::fs::write(
            dir.join("TestKit.methods.json"),
            serde_json::to_string(&summary).unwrap(),
        )
        .unwrap();

        let annotations = FrameworkAnnotations {
            framework: "TestKit".to_string(),
            classes: vec![ClassAnnotations {
                class_name: "TKBar".to_string(), // unknown class
                methods: vec![block_annotation("doBlock:", 0)],
            }],
            subagent_report: None,
        };
        std::fs::write(
            dir.join("TestKit.llm.json"),
            serde_json::to_string(&annotations).unwrap(),
        )
        .unwrap();

        let report = validate_llm_file(
            &dir.join("TestKit.methods.json"),
            &dir.join("TestKit.llm.json"),
        )
        .unwrap();

        assert!(!report.is_ok());
        assert!(report
            .errors
            .iter()
            .any(|e| matches!(e, ValidationError::UnknownClass { .. })));

        let _ = std::fs::remove_dir_all(&dir);
    }

    #[test]
    fn validate_llm_file_returns_io_error_for_missing_file() {
        let result = validate_llm_file(
            Path::new("/nonexistent/methods.json"),
            Path::new("/nonexistent/llm.json"),
        );
        assert!(result.is_err());
    }

    #[test]
    fn validate_collects_multiple_errors() {
        let summary = make_summary(
            "TestKit",
            vec![ClassSummary {
                class_name: "TKFoo".to_string(),
                methods: vec![block_method_summary("doBlock:", true)],
            }],
        );
        let annotations = FrameworkAnnotations {
            framework: "WrongKit".to_string(),
            classes: vec![ClassAnnotations {
                class_name: "TKBar".to_string(),
                methods: vec![block_annotation("nope:", 99)],
            }],
            subagent_report: None,
        };

        let report = validate_llm_annotations(&summary, &annotations);

        assert!(!report.is_ok());
        // FrameworkMismatch + UnknownClass at minimum.
        assert!(report.errors.len() >= 2);
        assert!(report
            .errors
            .iter()
            .any(|e| matches!(e, ValidationError::FrameworkMismatch { .. })));
        assert!(report
            .errors
            .iter()
            .any(|e| matches!(e, ValidationError::UnknownClass { .. })));
    }

    fn ownership_method(selector: &str) -> MethodAnnotation {
        MethodAnnotation {
            selector: selector.to_string(),
            is_instance: true,
            parameter_ownership: vec![ParamOwnership {
                param_index: 0,
                ownership: OwnershipKind::Weak,
            }],
            block_parameters: vec![],
            threading: None,
            error_pattern: None,
            source: AnnotationSource::Llm,
        }
    }

    fn block_method_with_invocation(
        selector: &str,
        invocation: BlockInvocationStyle,
    ) -> MethodAnnotation {
        MethodAnnotation {
            selector: selector.to_string(),
            is_instance: true,
            parameter_ownership: vec![],
            block_parameters: vec![BlockParamAnnotation {
                param_index: 0,
                invocation,
            }],
            threading: None,
            error_pattern: None,
            source: AnnotationSource::Llm,
        }
    }

    /// Build a CoreData-shaped summary covering every selector that the
    /// reconciliation tests below want to annotate. Adding selectors here
    /// rather than per-test keeps the fixtures honest: every annotation
    /// the test emits will pass the unknown-selector check.
    fn coredata_summary_fixture() -> FrameworkSummary {
        make_summary(
            "CoreData",
            vec![
                ClassSummary {
                    class_name: "NSManagedObjectContext".to_string(),
                    methods: vec![
                        block_method_summary("performBlockAndWait:", true),
                        block_method_summary("performBlock:", true),
                    ],
                },
                ClassSummary {
                    class_name: "NSBatchInsertRequest".to_string(),
                    methods: vec![
                        block_method_summary("setDictionaryHandler:", true),
                        delegate_method_summary("setDelegate:"),
                    ],
                },
            ],
        )
    }

    #[test]
    fn validate_emits_no_warning_when_subagent_report_absent() {
        let summary = coredata_summary_fixture();
        let annotations = FrameworkAnnotations {
            framework: "CoreData".to_string(),
            classes: vec![],
            subagent_report: None,
        };

        let report = validate_llm_annotations(&summary, &annotations);

        assert!(report.is_ok());
        assert!(report.warnings.is_empty());
    }

    #[test]
    fn validate_emits_no_warning_when_reported_counts_match_actual() {
        let summary = coredata_summary_fixture();
        let annotations = FrameworkAnnotations {
            framework: "CoreData".to_string(),
            classes: vec![
                ClassAnnotations {
                    class_name: "NSManagedObjectContext".to_string(),
                    methods: vec![
                        block_method_with_invocation(
                            "performBlockAndWait:",
                            BlockInvocationStyle::Synchronous,
                        ),
                        block_method_with_invocation(
                            "performBlock:",
                            BlockInvocationStyle::AsyncCopied,
                        ),
                    ],
                },
                ClassAnnotations {
                    class_name: "NSBatchInsertRequest".to_string(),
                    methods: vec![
                        block_method_with_invocation(
                            "setDictionaryHandler:",
                            BlockInvocationStyle::Stored,
                        ),
                        ownership_method("setDelegate:"),
                    ],
                },
            ],
            subagent_report: Some(SubagentReport {
                block_synchronous: Some(1),
                block_async_copied: Some(1),
                block_stored: Some(1),
                parameter_ownership: Some(1),
                threading_main_thread_only: None,
                threading_any_thread: None,
                error_pattern: Some(0),
            }),
        };

        let report = validate_llm_annotations(&summary, &annotations);

        assert!(report.is_ok(), "errors: {:?}", report.errors);
        assert!(
            report.warnings.is_empty(),
            "unexpected warnings: {:?}",
            report.warnings
        );
    }

    #[test]
    fn validate_emits_warning_per_diverging_count() {
        // Mirrors the CoreData incident: subagent reported 18/8/7,
        // file contains 1/1/1.
        let summary = coredata_summary_fixture();
        let annotations = FrameworkAnnotations {
            framework: "CoreData".to_string(),
            classes: vec![
                ClassAnnotations {
                    class_name: "NSManagedObjectContext".to_string(),
                    methods: vec![block_method_with_invocation(
                        "performBlock:",
                        BlockInvocationStyle::AsyncCopied,
                    )],
                },
                ClassAnnotations {
                    class_name: "NSBatchInsertRequest".to_string(),
                    methods: vec![
                        block_method_with_invocation(
                            "setDictionaryHandler:",
                            BlockInvocationStyle::Stored,
                        ),
                        ownership_method("setDelegate:"),
                    ],
                },
            ],
            subagent_report: Some(SubagentReport {
                block_synchronous: None,
                block_async_copied: Some(18),
                block_stored: Some(8),
                parameter_ownership: Some(7),
                threading_main_thread_only: None,
                threading_any_thread: None,
                error_pattern: None,
            }),
        };

        let report = validate_llm_annotations(&summary, &annotations);

        // No errors — content is structurally valid; only warnings.
        assert!(report.errors.is_empty(), "errors: {:?}", report.errors);
        assert_eq!(report.warnings.len(), 3);

        let mut fields: Vec<&str> = report
            .warnings
            .iter()
            .map(|w| match w {
                ValidationWarning::SubagentReportMismatch { field, .. } => *field,
            })
            .collect();
        fields.sort_unstable();
        assert_eq!(
            fields,
            vec!["block_async_copied", "block_stored", "parameter_ownership"]
        );

        let async_warn = report
            .warnings
            .iter()
            .find_map(|w| {
                let ValidationWarning::SubagentReportMismatch {
                    field,
                    reported,
                    actual,
                } = w;
                if *field == "block_async_copied" {
                    Some((*reported, *actual))
                } else {
                    None
                }
            })
            .expect("async_copied warning present");
        assert_eq!(async_warn, (18, 1));
    }

    #[test]
    fn validate_warnings_do_not_make_report_fail() {
        // A divergent subagent_report should leave is_ok() true — the file
        // content is the source of truth for downstream merge.
        let summary = coredata_summary_fixture();
        let annotations = FrameworkAnnotations {
            framework: "CoreData".to_string(),
            classes: vec![ClassAnnotations {
                class_name: "NSManagedObjectContext".to_string(),
                methods: vec![block_method_with_invocation(
                    "performBlock:",
                    BlockInvocationStyle::AsyncCopied,
                )],
            }],
            subagent_report: Some(SubagentReport {
                block_async_copied: Some(99),
                ..SubagentReport::default()
            }),
        };

        let report = validate_llm_annotations(&summary, &annotations);

        assert!(report.is_ok());
        assert_eq!(report.warnings.len(), 1);
    }

    #[test]
    fn validate_skips_unset_report_fields_even_if_actual_nonzero() {
        // Subagent only tracks block invocations — it should not be
        // warned about the actual ownership count it never reported on.
        let summary = coredata_summary_fixture();
        let annotations = FrameworkAnnotations {
            framework: "CoreData".to_string(),
            classes: vec![ClassAnnotations {
                class_name: "NSBatchInsertRequest".to_string(),
                methods: vec![ownership_method("setDelegate:")],
            }],
            subagent_report: Some(SubagentReport {
                block_async_copied: Some(0),
                ..SubagentReport::default()
            }),
        };

        let report = validate_llm_annotations(&summary, &annotations);

        assert!(report.is_ok(), "errors: {:?}", report.errors);
        assert!(
            report.warnings.is_empty(),
            "unexpected warnings: {:?}",
            report.warnings
        );
    }

    #[test]
    fn write_and_read_summary_roundtrip() {
        let method = make_method(
            "doBlock:",
            vec![Param {
                name: "handler".to_string(),
                param_type: block_type(),
            }],
            void_type(),
        );
        let fw = make_framework("TestKit", vec![make_class("TKFoo", vec![method])]);
        let summary = extract_interesting_methods(&fw);

        let dir = std::env::temp_dir().join("test_llm_roundtrip");
        write_method_summary(&summary, &dir).unwrap();

        let path = dir.join("TestKit.methods.json");
        let content = std::fs::read_to_string(&path).unwrap();
        let loaded: FrameworkSummary = serde_json::from_str(&content).unwrap();

        assert_eq!(loaded.framework, "TestKit");
        assert_eq!(loaded.method_count, 1);
        assert_eq!(loaded.classes[0].methods[0].selector, "doBlock:");

        let _ = std::fs::remove_dir_all(&dir);
    }
}
