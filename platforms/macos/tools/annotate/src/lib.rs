//! Convention-facet assembly and LLM annotation merge.
//!
//! Annotations classify ObjC/Swift API methods with semantic metadata
//! (parameter ownership, block invocation style, threading constraints,
//! error patterns). Two sources produce annotations:
//!
//! 1. **Convention facets** ([`apianyware_conventions`]) — the Cocoa
//!    naming-convention rules, expressed as declarative `ascent` datalog rules
//!    (ADR-0047) rather than the imperative classifiers they replaced. Run once
//!    per framework, keyed by `(receiver, selector)`, and assembled per method
//!    into a `MethodAnnotation` ([`ConventionFacets`]). Fast, deterministic,
//!    always available. Handle clear cases (enumerate = sync, setDelegate = weak).
//!
//! 2. **LLM analysis** — an external process reads Apple documentation and
//!    produces the authored `annotations.apiw` overlay for ambiguous cases.
//!
//! The `validate` module runs the resolve-time **precedence audit**: per
//! fact-slot it applies §28 precedence (`manual > extraction > accepted-LLM >
//! convention > unknown`), stamps the winning tier's `source`, and retains each
//! disagreeing loser as a `superseded-by` record (ADR-0046 §4 / ADR-0050 §3).
//!
//! The per-fact `convention:<rule>` stamps the [`apianyware_conventions`] facets
//! compute — formerly discarded by the k26 cutover — are carried here into the
//! convention tier's `fact_provenance` so the audit can attribute a
//! convention-won slot to its backing rule. **A rule whose sole premises are
//! compiler declarations stamps `Extraction`, not `Convention`**
//! (`declared-fact-precedence-k87`, ADR-0047 §4) — see
//! [`EXTRACTION_TIER_RULES`] — so such a fact reaches the audit already
//! outranking the LLM tier. The audit itself stamps *provenance* only; the
//! winning *value* of every slot is byte-identical to the legacy
//! `llm`-over-convention merge (modulo the k87 re-rank), so provenance is
//! emit-invisible and the goldens cannot move (ADR-0050 D4).

pub mod llm;
pub mod surface;
pub mod validate;

use std::collections::{BTreeMap, HashMap};
use std::path::Path;

use anyhow::{Context, Result};
use apianyware_conventions::{
    derive_block_invocations, derive_error_pattern, derive_ownership, derive_threading,
    BlockInvocationFacet, ErrorPatternFacet, MethodKey, OwnershipFacet, ThreadingFacet,
};
use apianyware_datalog::loading;
use apianyware_types::annotation::{
    AnnotationSource, ClassAnnotations, FrameworkAnnotations, MethodAnnotation,
    MethodFactProvenance, SlotProvenance,
};
use apianyware_types::ir::{Framework, Method};

/// The four convention facets derived once over a framework set, each keyed by
/// `(receiver, selector)` ([`MethodKey`]).
///
/// Replaces the per-method imperative `heuristics.rs` classifiers (ADR-0047):
/// the convention rules now live in [`apianyware_conventions`] as `ascent`
/// datalog rules; this bundle runs them once and exposes the result as the
/// per-method `MethodAnnotation` the annotate step consumes. A method absent
/// from a facet map gets that facet's empty/`None` default — exactly the legacy
/// per-method result for a method with no signal.
///
/// Derivation is **per framework** (`derive(std::slice::from_ref(fw))`): the
/// convention rules are per-method and never cross frameworks, so per-framework
/// derivation matches the characterization tests that gated each facet port, and
/// — since `annotate` runs only once per SDK update — the four independent
/// program runs are not worth consolidating.
struct ConventionFacets {
    ownership: BTreeMap<MethodKey, OwnershipFacet>,
    block: BTreeMap<MethodKey, BlockInvocationFacet>,
    threading: BTreeMap<MethodKey, ThreadingFacet>,
    error: BTreeMap<MethodKey, ErrorPatternFacet>,
}

/// `convention:<rule>` names whose *sole* premises are compiler declarations
/// (ADR-0047 §4, `declared-fact-precedence-k87`) — such a rule's fact stamps
/// [`AnnotationSource::Extraction`], not [`AnnotationSource::Convention`], even
/// though it runs in the same `apianyware-conventions` datalog engine as every
/// other rule here. Membership is mechanical: could the rule fire on a corpus
/// with all names stripped? The declared-property-attribute ownership rule
/// (one name per [`apianyware_types::annotation::OwnershipKind`], from
/// `conventions::program::rule_for_declared`) and `block-copy-property-setter`
/// pass; every name-sniff / positional-default rule stays `Convention` — the
/// fallback for the undeclared case.
const EXTRACTION_TIER_RULES: &[&str] = &[
    "weak-property-attribute",
    "strong-property-attribute",
    "copy-property-attribute",
    "unsafe-unretained-property-attribute",
    "block-copy-property-setter",
];

/// The producing tier for a fact-slot given its winning `convention:<rule>`
/// stamp(s). A slot's stamps are homogeneous — the conventions-crate readback
/// cascade resolves to one priority level's rule(s) per slot — so any one
/// stamp settles it.
fn tier_for_rules(rules: &[String]) -> AnnotationSource {
    let is_declared = rules.iter().any(|r| {
        r.strip_prefix("convention:")
            .is_some_and(|rule| EXTRACTION_TIER_RULES.contains(&rule))
    });
    if is_declared {
        AnnotationSource::Extraction
    } else {
        AnnotationSource::Convention
    }
}

impl ConventionFacets {
    /// Run the convention rules over `frameworks` and collect the four facets.
    fn derive(frameworks: &[Framework]) -> Self {
        Self {
            ownership: derive_ownership(frameworks),
            block: derive_block_invocations(frameworks),
            threading: derive_threading(frameworks),
            error: derive_error_pattern(frameworks),
        }
    }

    /// Assemble the convention `MethodAnnotation` for `method` on `receiver`
    /// (class or protocol name) by looking its `(receiver, selector)` up in the
    /// four facet maps. The fact *values* are byte-identical to the legacy
    /// `heuristics.rs` output; ws5's `precedence-audit-k45` lands the per-fact
    /// `convention:<rule>` stamps the facets compute (formerly discarded by
    /// k26) into `fact_provenance`, so the resolve-time audit can stamp a
    /// convention-won slot with its backing rule. Every ownership/block slot is
    /// tagged `Convention` or `Extraction` by [`tier_for_rules`] — a
    /// declaration-premised rule stamps `Extraction` even here, before the
    /// slot ever reaches the audit (ADR-0047 §4, k87); threading/error have no
    /// declaration-premised rule today and stay `Convention`. No slot carries a
    /// loser yet — the audit reconciles against the authored overlay (ADR-0046
    /// §4 / ADR-0050 §3).
    fn annotation_for(&self, receiver: &str, method: &Method) -> MethodAnnotation {
        let key = (receiver.to_string(), method.selector.clone());

        let ownership_facet = self.ownership.get(&key);
        let block_facet = self.block.get(&key);
        let threading_facet = self.threading.get(&key);
        let error_facet = self.error.get(&key);

        let parameter_ownership = ownership_facet
            .map(|f| f.parameter_ownership.clone())
            .unwrap_or_default();
        let block_parameters = block_facet
            .map(|f| f.block_parameters.clone())
            .unwrap_or_default();
        let threading = threading_facet.map(|f| f.threading);
        let error_pattern = error_facet.map(|f| f.error_pattern);

        // Build the convention tier's per-slot provenance. The facet
        // `provenance` maps are keyed by `param_index` (`u32`); the scalar
        // facets carry a method-level stamp list.
        let mut prov = MethodFactProvenance::default();
        for po in &parameter_ownership {
            let rules = ownership_facet
                .and_then(|f| f.provenance.get(&(po.param_index as u32)))
                .cloned()
                .unwrap_or_default();
            prov.parameter_ownership.push(SlotProvenance {
                param_index: Some(po.param_index),
                source: tier_for_rules(&rules),
                rules,
                superseded_by: Vec::new(),
            });
        }
        for bp in &block_parameters {
            let rules = block_facet
                .and_then(|f| f.provenance.get(&(bp.param_index as u32)))
                .cloned()
                .unwrap_or_default();
            prov.block_parameters.push(SlotProvenance {
                param_index: Some(bp.param_index),
                source: tier_for_rules(&rules),
                rules,
                superseded_by: Vec::new(),
            });
        }
        if threading.is_some() {
            prov.threading = Some(SlotProvenance {
                param_index: None,
                source: AnnotationSource::Convention,
                rules: threading_facet
                    .map(|f| f.provenance.clone())
                    .unwrap_or_default(),
                superseded_by: Vec::new(),
            });
        }
        if error_pattern.is_some() {
            prov.error_pattern = Some(SlotProvenance {
                param_index: None,
                source: AnnotationSource::Convention,
                rules: error_facet
                    .map(|f| f.provenance.clone())
                    .unwrap_or_default(),
                superseded_by: Vec::new(),
            });
        }

        MethodAnnotation {
            selector: method.selector.clone(),
            is_instance: !method.class_method,
            parameter_ownership,
            block_parameters,
            threading,
            error_pattern,
            source: AnnotationSource::Convention,
            confidence: None,
            provenance: None,
            fact_provenance: Some(prov),
        }
    }
}

/// Annotate all resolved frameworks: load, run convention rules, merge with existing LLM annotations.
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
        // entries from the prior annotated checkpoint (so convention-only baselines
        // produce only Convention-tagged annotations).
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

/// Annotate a single framework: derive the convention facets, assemble per-method
/// annotations, and merge with existing LLM annotations.
pub fn annotate_framework(
    framework: &Framework,
    existing_annotations: Option<&FrameworkAnnotations>,
) -> Framework {
    // Build index of existing LLM annotations: (class_name, selector) → MethodAnnotation
    let llm_index = build_llm_annotation_index(existing_annotations);

    // Run the convention rules once over this framework (ADR-0047). The facet
    // maps are keyed by (receiver, selector); the per-method assembly below
    // looks each method up in them, replacing the per-method `heuristics.rs`
    // calls this leaf retired.
    let facets = ConventionFacets::derive(std::slice::from_ref(framework));

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

        // `methods`/`all_methods` already carry category methods (extraction merges
        // `class.category_methods` into `class.methods`, `text-undo-surface-gap-k121`) —
        // a separate category loop here would double-annotate the same selector.
        for method in methods {
            annotate_and_push(class, method, &facets, &llm_index, &mut method_annotations);
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
    // by protocol name. Swift-native struct methods (leaf 020) are recovered
    // for the receiver-handle trampoline but not LLM-annotated here — the
    // trampoline binding is structural, not annotation-driven (mirrors the
    // free-function trampoline). Enums carry no methods in the IR.
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
                &facets,
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

    // Pattern-instances are now first-class (ADR-0048): authored kinds bound to
    // concrete participants, produced by the convention (datalog)/llm/manual
    // tiers — a later child. The imperative `detect_patterns` heuristic detector
    // is retired here; `annotate` emits no pattern-instances until a producer
    // lands, so `Framework.patterns` stays empty (carriage replaces the old
    // `api_patterns` list; emit goldens are unaffected — nothing projected them).
    let mut annotated = framework.clone();
    annotated.checkpoint = "annotated".to_string();
    annotated.class_annotations = class_annotations;
    annotated
}

/// Assemble a class method's convention annotation, merge with its LLM
/// annotation if available, and push to results.
fn annotate_and_push(
    class: &apianyware_types::ir::Class,
    method: &apianyware_types::ir::Method,
    facets: &ConventionFacets,
    llm_index: &HashMap<(&str, &str), &MethodAnnotation>,
    results: &mut Vec<MethodAnnotation>,
) {
    let convention = facets.annotation_for(&class.name, method);
    merge_and_push(&class.name, method, convention, llm_index, results);
}

/// Assemble a protocol method's convention annotation, merge with its LLM
/// annotation if available, and push to results.
fn annotate_protocol_method_and_push(
    protocol: &apianyware_types::ir::Protocol,
    method: &apianyware_types::ir::Method,
    facets: &ConventionFacets,
    llm_index: &HashMap<(&str, &str), &MethodAnnotation>,
    results: &mut Vec<MethodAnnotation>,
) {
    let convention = facets.annotation_for(&protocol.name, method);
    merge_and_push(&protocol.name, method, convention, llm_index, results);
}

/// Audit a method's convention annotation against its authored-overlay
/// annotation — looked up by `(receiver_name, selector)`, where `receiver_name`
/// is the class or protocol name — applying §28 precedence per fact-slot, and
/// push the resolved (provenance-stamped) result.
fn merge_and_push(
    receiver_name: &str,
    method: &apianyware_types::ir::Method,
    convention: MethodAnnotation,
    llm_index: &HashMap<(&str, &str), &MethodAnnotation>,
    results: &mut Vec<MethodAnnotation>,
) {
    let overlay = llm_index
        .get(&(receiver_name, method.selector.as_str()))
        .copied();

    results.push(validate::audit_annotations(&convention, overlay));
}

/// Load LLM-sourced annotations from a previously-written annotated checkpoint.
///
/// Filters out entries with `source = Convention` so a convention-only baseline
/// rerun does not have its annotations re-tagged as `Llm` by `merge_annotations`.
/// `Llm` and `Manual` entries are retained — conventions re-run fresh on
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

/// Keep only methods whose `source` is `Llm` or `Manual`; drop classes
/// that end up with no methods.
fn retain_llm_sourced(classes: Vec<ClassAnnotations>) -> Vec<ClassAnnotations> {
    classes
        .into_iter()
        .filter_map(|mut class| {
            class.methods.retain(|m| {
                matches!(
                    m.source,
                    apianyware_types::annotation::AnnotationSource::Llm
                        | apianyware_types::annotation::AnnotationSource::Manual
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
    use apianyware_types::annotation::AnnotationSource;

    fn method(selector: &str, source: AnnotationSource) -> MethodAnnotation {
        MethodAnnotation {
            selector: selector.to_string(),
            is_instance: true,
            parameter_ownership: vec![],
            block_parameters: vec![],
            threading: None,
            error_pattern: None,
            source,
            confidence: None,
            provenance: None,
            fact_provenance: None,
        }
    }

    fn class(name: &str, methods: Vec<MethodAnnotation>) -> ClassAnnotations {
        ClassAnnotations {
            class_name: name.to_string(),
            methods,
        }
    }

    #[test]
    fn retain_llm_sourced_keeps_llm_and_manual_drops_convention() {
        let input = vec![class(
            "NSString",
            vec![
                method("length", AnnotationSource::Convention),
                method("compare:", AnnotationSource::Llm),
                method("hash", AnnotationSource::Manual),
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
                vec![method("description", AnnotationSource::Convention)],
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
                method("description", AnnotationSource::Convention),
                method("hash", AnnotationSource::Convention),
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
    fn load_existing_llm_annotations_returns_none_when_only_convention_entries_present() {
        // End-to-end check that a convention-only checkpoint cannot poison a
        // convention-only baseline rerun by being re-treated as LLM source.
        let dir = make_temp_dir("convention-only");
        write_checkpoint(
            &dir,
            "TestFW",
            serde_json::json!([
                {
                    "class_name": "TestClass",
                    "methods": [
                        {"selector": "foo", "is_instance": true, "source": "convention"}
                    ]
                }
            ]),
        );

        let result = load_existing_llm_annotations(&dir, "TestFW");

        std::fs::remove_dir_all(&dir).ok();

        assert!(
            result.is_none(),
            "checkpoint with only Convention entries must not be re-presented as LLM source"
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
                        {"selector": "heuristicOnly", "is_instance": true, "source": "convention"},
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
        use apianyware_types::ir::{Method as IrMethod, Param, Protocol};
        use apianyware_types::type_ref::{TypeRef, TypeRefKind};

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
            objc_exposed: true,
            swift_fn: None,
        };

        Framework {
            format_version: "1.0".to_string(),
            checkpoint: "linked".to_string(),
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
                objc_exposed: true,
            }],
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
