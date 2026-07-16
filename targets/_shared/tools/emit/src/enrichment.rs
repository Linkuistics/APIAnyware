//! Target-neutral helpers over [`EnrichmentData`] — the analysis-stage relations
//! emitters key idiomatic emission off.
//!
//! Lifted here so every target keying off the same enrichment relation computes
//! the same set, never drifting. The first such helper is
//! [`class_error_selectors`] (the `NSError**` out-param convenience methods),
//! shared by `emit-racket` (native `…_e` dispatch entry) and `emit-gerbil`
//! (in-Gerbil out-param crossing). See `adr/0006-chez-nserror-shape.md`.

use std::collections::HashSet;

use apianyware_types::annotation::{ClassAnnotations, OwnershipKind};
use apianyware_types::enrichment::EnrichmentData;

/// The `(selector, param_index)` slots of `class_name` whose parameter the receiver **retains** — the
/// declared-or-derived ownership resolved by the analysis stage's three-level cascade (declared
/// attribute → delegate/observer name sniff → block-copy default; `property-ownership-ir-k82`), read
/// here and nowhere else.
///
/// This is a **three-state** fact reduced to the question its readers actually ask. `Strong` means the
/// receiver keeps the argument alive on its own. `Weak` and `UnsafeUnretained` are one arm — the
/// *retain axis*, never one spelling of it: 17 pre-ARC delegate slots (`NSXMLParser`, `NSStream`, …)
/// declare `assign`, and a reader testing only for `weak` silently drops them. `Copy` and an **absent**
/// annotation both fall outside the set, so both take the caller's default arm — which for a delegate
/// keep-alive is *associate* (ADR-0059 §6: over-associating a retaining slot merely over-retains;
/// under-associating a non-retaining one dangles).
///
/// Read the *resolved* annotation rather than the enrichment's `weak_param_methods`, because that
/// relation is a **boolean projection** — it records only the non-retaining slots, so it cannot tell a
/// declared-`strong` slot from an unannotated one, and ADR-0059 §6 has distinct arms for those two.
/// Empty when the framework carries no annotations.
pub fn class_retaining_params(
    annotations: &[ClassAnnotations],
    class_name: &str,
) -> HashSet<(String, usize)> {
    annotations
        .iter()
        .filter(|a| a.class_name == class_name)
        .flat_map(|a| a.methods.iter())
        .flat_map(|m| {
            m.parameter_ownership
                .iter()
                .filter(|p| p.ownership == OwnershipKind::Strong)
                .map(|p| (m.selector.clone(), p.param_index))
        })
        .collect()
}

/// The set of selectors for a class that the analysis stage classified as
/// **NSError out-param** convenience methods (`ErrorPattern::ErrorOutParam` →
/// [`EnrichmentData::convenience_error_methods`]). Every target keys error-out
/// routing off this one set, so they classify the same methods and never drift.
/// Empty when there is no enrichment.
pub fn class_error_selectors(
    enrichment: Option<&EnrichmentData>,
    class_name: &str,
) -> HashSet<String> {
    match enrichment {
        None => HashSet::new(),
        Some(data) => data
            .convenience_error_methods
            .iter()
            .filter(|e| e.class == class_name)
            .map(|e| e.selector.clone())
            .collect(),
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use apianyware_types::enrichment::ClassSelectorEntry;

    #[test]
    fn filters_convenience_error_methods_by_class() {
        let data = EnrichmentData {
            convenience_error_methods: vec![
                ClassSelectorEntry {
                    class: "NSData".into(),
                    selector: "writeToFile:options:error:".into(),
                },
                ClassSelectorEntry {
                    class: "NSString".into(),
                    selector: "writeToURL:atomically:encoding:error:".into(),
                },
            ],
            ..Default::default()
        };
        let sel = class_error_selectors(Some(&data), "NSData");
        assert_eq!(sel.len(), 1);
        assert!(sel.contains("writeToFile:options:error:"));
        // A different class's error selector is not included.
        assert!(!sel.contains("writeToURL:atomically:encoding:error:"));
    }

    #[test]
    fn empty_without_enrichment() {
        assert!(class_error_selectors(None, "NSData").is_empty());
    }

    #[test]
    fn retaining_params_are_the_declared_strong_slots_only() {
        use apianyware_types::annotation::{AnnotationSource, MethodAnnotation, ParamOwnership};

        fn method(selector: &str, ownership: Vec<(usize, OwnershipKind)>) -> MethodAnnotation {
            MethodAnnotation {
                selector: selector.into(),
                is_instance: true,
                parameter_ownership: ownership
                    .into_iter()
                    .map(|(param_index, ownership)| ParamOwnership {
                        param_index,
                        ownership,
                    })
                    .collect(),
                block_parameters: vec![],
                threading: None,
                error_pattern: None,
                source: AnnotationSource::Convention,
                confidence: None,
                provenance: None,
                fact_provenance: None,
            }
        }

        let annotations = vec![
            ClassAnnotations {
                class_name: "NSURLSessionTask".into(),
                // The one slot in AppKit + Foundation whose declaration flips the retain axis: the
                // name sniff called it weak, the header says strong (k82).
                methods: vec![method("setDelegate:", vec![(0, OwnershipKind::Strong)])],
            },
            ClassAnnotations {
                class_name: "NSXMLParser".into(),
                // Pre-ARC `assign` — non-retaining, and it must NOT read as retaining just because
                // it is not spelled `weak`.
                methods: vec![
                    method("setDelegate:", vec![(0, OwnershipKind::UnsafeUnretained)]),
                    method("setThing:", vec![(0, OwnershipKind::Copy)]),
                    method("setOther:", vec![]),
                ],
            },
        ];

        let task = class_retaining_params(&annotations, "NSURLSessionTask");
        assert!(task.contains(&("setDelegate:".to_string(), 0)));

        let parser = class_retaining_params(&annotations, "NSXMLParser");
        assert!(parser.is_empty(), "assign, copy and absent all fall outside");

        // A class the annotations do not mention has no retaining slot — every slot takes the
        // caller's default arm.
        assert!(class_retaining_params(&annotations, "NSApplication").is_empty());
        assert!(class_retaining_params(&[], "NSApplication").is_empty());
    }
}
