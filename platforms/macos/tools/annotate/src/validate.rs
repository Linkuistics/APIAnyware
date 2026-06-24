//! Validation: compare heuristic and LLM annotations, flag disagreements.
//!
//! Disagreements are surfaced for human review. Agreements increase confidence.

use apianyware_types::annotation::{
    AnnotationDisagreement, AnnotationOverride, AnnotationOverrides, AnnotationSource,
    BlockInvocationStyle, ErrorPattern, MethodAnnotation, OwnershipKind, ThreadingConstraint,
};

/// Compare heuristic and LLM annotations for a single method.
/// Returns a list of disagreements (empty if they agree).
pub fn compare_annotations(
    class_name: &str,
    heuristic: &MethodAnnotation,
    llm: &MethodAnnotation,
) -> Vec<AnnotationDisagreement> {
    let mut disagreements = Vec::new();

    // Compare parameter ownership
    for h_param in &heuristic.parameter_ownership {
        if let Some(l_param) = llm
            .parameter_ownership
            .iter()
            .find(|p| p.param_index == h_param.param_index)
        {
            if h_param.ownership != l_param.ownership {
                disagreements.push(AnnotationDisagreement {
                    class_name: class_name.to_string(),
                    selector: heuristic.selector.clone(),
                    heuristic_value: format!("{:?}", h_param.ownership),
                    llm_value: format!("{:?}", l_param.ownership),
                    field: format!("parameter_ownership[{}]", h_param.param_index),
                    resolution: None,
                });
            }
        }
    }

    // Check for LLM-only ownership annotations (heuristic missed)
    for l_param in &llm.parameter_ownership {
        if !heuristic
            .parameter_ownership
            .iter()
            .any(|p| p.param_index == l_param.param_index)
        {
            disagreements.push(AnnotationDisagreement {
                class_name: class_name.to_string(),
                selector: heuristic.selector.clone(),
                heuristic_value: format!("{:?}", OwnershipKind::Strong),
                llm_value: format!("{:?}", l_param.ownership),
                field: format!("parameter_ownership[{}]", l_param.param_index),
                resolution: None,
            });
        }
    }

    // Compare block invocation style
    for h_block in &heuristic.block_parameters {
        if let Some(l_block) = llm
            .block_parameters
            .iter()
            .find(|b| b.param_index == h_block.param_index)
        {
            if h_block.invocation != l_block.invocation {
                disagreements.push(AnnotationDisagreement {
                    class_name: class_name.to_string(),
                    selector: heuristic.selector.clone(),
                    heuristic_value: format!("{:?}", h_block.invocation),
                    llm_value: format!("{:?}", l_block.invocation),
                    field: format!("block_invocation[{}]", h_block.param_index),
                    resolution: None,
                });
            }
        }
    }

    // Compare threading (only flag if both have values and differ)
    if heuristic.threading != llm.threading
        && heuristic.threading.is_some()
        && llm.threading.is_some()
    {
        disagreements.push(AnnotationDisagreement {
            class_name: class_name.to_string(),
            selector: heuristic.selector.clone(),
            heuristic_value: format!("{:?}", heuristic.threading),
            llm_value: format!("{:?}", llm.threading),
            field: "threading".to_string(),
            resolution: None,
        });
    }

    // Compare error pattern (only flag if both have values and differ)
    if heuristic.error_pattern != llm.error_pattern
        && heuristic.error_pattern.is_some()
        && llm.error_pattern.is_some()
    {
        disagreements.push(AnnotationDisagreement {
            class_name: class_name.to_string(),
            selector: heuristic.selector.clone(),
            heuristic_value: format!("{:?}", heuristic.error_pattern),
            llm_value: format!("{:?}", llm.error_pattern),
            field: "error_pattern".to_string(),
            resolution: None,
        });
    }

    disagreements
}

/// Merge heuristic and LLM annotations, preferring LLM where both exist.
pub fn merge_annotations(
    heuristic: &MethodAnnotation,
    llm: Option<&MethodAnnotation>,
    _overrides: &AnnotationOverrides,
) -> MethodAnnotation {
    match llm {
        Some(llm_ann) => {
            // LLM takes precedence; fill in gaps from heuristic
            let mut merged = llm_ann.clone();

            // Per-param union for ownership: LLM output is typically sparse (only
            // params it has high-confidence calls on), so a whole-list clone would
            // silently drop heuristic-classified copy/weak params the LLM didn't
            // touch. For each heuristic entry whose param_index isn't already in
            // the LLM list, append it. LLM entries keep precedence on conflicts
            // because they're already in `merged`.
            for h_param in &heuristic.parameter_ownership {
                if !merged
                    .parameter_ownership
                    .iter()
                    .any(|p| p.param_index == h_param.param_index)
                {
                    merged.parameter_ownership.push(h_param.clone());
                }
            }

            // If LLM has no block annotations but heuristic does, use heuristic
            if merged.block_parameters.is_empty() && !heuristic.block_parameters.is_empty() {
                merged.block_parameters = heuristic.block_parameters.clone();
            }

            // If LLM has no threading but heuristic does, use heuristic
            if merged.threading.is_none() && heuristic.threading.is_some() {
                merged.threading = heuristic.threading;
            }

            // If LLM has no error pattern but heuristic does, use heuristic
            if merged.error_pattern.is_none() && heuristic.error_pattern.is_some() {
                merged.error_pattern = heuristic.error_pattern;
            }

            merged.source = AnnotationSource::Llm;
            merged
        }
        None => {
            // No LLM annotation — use heuristic as-is
            heuristic.clone()
        }
    }
}

/// Apply human-reviewed overrides to a merged annotation.
pub fn apply_overrides(annotation: &mut MethodAnnotation, overrides: &[AnnotationOverride]) {
    for ov in overrides {
        if ov.selector != annotation.selector {
            continue;
        }

        match ov.field.as_str() {
            "threading" => {
                if let Some(s) = ov.value.as_str() {
                    annotation.threading = match s {
                        "main_thread_only" => Some(ThreadingConstraint::MainThreadOnly),
                        "any_thread" => Some(ThreadingConstraint::AnyThread),
                        _ => annotation.threading,
                    };
                }
            }
            "error_pattern" => {
                if let Some(s) = ov.value.as_str() {
                    annotation.error_pattern = match s {
                        "error_out_param" => Some(ErrorPattern::ErrorOutParam),
                        "throws_exception" => Some(ErrorPattern::ThrowsException),
                        "nil_on_failure" => Some(ErrorPattern::NilOnFailure),
                        _ => annotation.error_pattern,
                    };
                }
            }
            field if field.starts_with("block_invocation[") => {
                if let (Some(idx_str), Some(val)) = (
                    field
                        .strip_prefix("block_invocation[")
                        .and_then(|s| s.strip_suffix(']')),
                    ov.value.as_str(),
                ) {
                    if let Ok(idx) = idx_str.parse::<usize>() {
                        let invocation = match val {
                            "synchronous" => BlockInvocationStyle::Synchronous,
                            "stored" => BlockInvocationStyle::Stored,
                            _ => BlockInvocationStyle::AsyncCopied,
                        };
                        if let Some(bp) = annotation
                            .block_parameters
                            .iter_mut()
                            .find(|b| b.param_index == idx)
                        {
                            bp.invocation = invocation;
                        }
                    }
                }
            }
            field if field.starts_with("parameter_ownership[") => {
                if let (Some(idx_str), Some(val)) = (
                    field
                        .strip_prefix("parameter_ownership[")
                        .and_then(|s| s.strip_suffix(']')),
                    ov.value.as_str(),
                ) {
                    if let Ok(idx) = idx_str.parse::<usize>() {
                        let ownership = match val {
                            "weak" => OwnershipKind::Weak,
                            "copy" => OwnershipKind::Copy,
                            "unsafe_unretained" => OwnershipKind::UnsafeUnretained,
                            _ => OwnershipKind::Strong,
                        };
                        if let Some(po) = annotation
                            .parameter_ownership
                            .iter_mut()
                            .find(|p| p.param_index == idx)
                        {
                            po.ownership = ownership;
                        }
                    }
                }
            }
            _ => {}
        }

        annotation.source = AnnotationSource::HumanReviewed;
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use apianyware_types::annotation::*;

    fn make_annotation(
        selector: &str,
        param_ownership: Vec<ParamOwnership>,
        block_params: Vec<BlockParamAnnotation>,
        threading: Option<ThreadingConstraint>,
        error_pattern: Option<ErrorPattern>,
        source: AnnotationSource,
    ) -> MethodAnnotation {
        MethodAnnotation {
            selector: selector.to_string(),
            is_instance: true,
            parameter_ownership: param_ownership,
            block_parameters: block_params,
            threading,
            error_pattern,
            source,
            confidence: None,
            provenance: None,
        }
    }

    #[test]
    fn test_agreement_no_disagreements() {
        let heuristic = make_annotation(
            "setDelegate:",
            vec![ParamOwnership {
                param_index: 0,
                ownership: OwnershipKind::Weak,
            }],
            vec![],
            None,
            None,
            AnnotationSource::Heuristic,
        );

        let llm = make_annotation(
            "setDelegate:",
            vec![ParamOwnership {
                param_index: 0,
                ownership: OwnershipKind::Weak,
            }],
            vec![],
            None,
            None,
            AnnotationSource::Llm,
        );

        let disagreements = compare_annotations("NSWindow", &heuristic, &llm);
        assert!(disagreements.is_empty());
    }

    #[test]
    fn test_ownership_disagreement() {
        let heuristic = make_annotation(
            "setTarget:",
            vec![],
            vec![],
            None,
            None,
            AnnotationSource::Heuristic,
        );

        let llm = make_annotation(
            "setTarget:",
            vec![ParamOwnership {
                param_index: 0,
                ownership: OwnershipKind::Weak,
            }],
            vec![],
            None,
            None,
            AnnotationSource::Llm,
        );

        let disagreements = compare_annotations("NSControl", &heuristic, &llm);
        assert_eq!(disagreements.len(), 1);
        assert_eq!(disagreements[0].field, "parameter_ownership[0]");
    }

    #[test]
    fn test_merge_prefers_llm() {
        let heuristic = make_annotation(
            "enumerateObjectsUsingBlock:",
            vec![],
            vec![BlockParamAnnotation {
                param_index: 0,
                invocation: BlockInvocationStyle::Synchronous,
            }],
            None,
            None,
            AnnotationSource::Heuristic,
        );

        let llm = make_annotation(
            "enumerateObjectsUsingBlock:",
            vec![],
            vec![BlockParamAnnotation {
                param_index: 0,
                invocation: BlockInvocationStyle::Synchronous,
            }],
            Some(ThreadingConstraint::AnyThread),
            None,
            AnnotationSource::Llm,
        );

        let overrides = AnnotationOverrides::default();
        let merged = merge_annotations(&heuristic, Some(&llm), &overrides);
        assert_eq!(merged.threading, Some(ThreadingConstraint::AnyThread));
        assert_eq!(merged.source, AnnotationSource::Llm);
    }

    #[test]
    fn test_merge_fills_gaps_from_heuristic() {
        let heuristic = make_annotation(
            "writeToFile:atomically:error:",
            vec![],
            vec![],
            None,
            Some(ErrorPattern::ErrorOutParam),
            AnnotationSource::Heuristic,
        );

        let llm = make_annotation(
            "writeToFile:atomically:error:",
            vec![],
            vec![],
            Some(ThreadingConstraint::AnyThread),
            None, // LLM didn't annotate error pattern
            AnnotationSource::Llm,
        );

        let overrides = AnnotationOverrides::default();
        let merged = merge_annotations(&heuristic, Some(&llm), &overrides);
        // Error pattern filled from heuristic
        assert_eq!(merged.error_pattern, Some(ErrorPattern::ErrorOutParam));
        // Threading from LLM
        assert_eq!(merged.threading, Some(ThreadingConstraint::AnyThread));
        assert_eq!(merged.source, AnnotationSource::Llm);
    }

    #[test]
    fn test_merge_parameter_ownership_per_param_union() {
        // Heuristic annotates params 0 and 2; LLM annotates only param 1.
        // Without the per-param union, the LLM list clobbers heuristic entries
        // and params 0/2 silently disappear from the merged annotation.
        let heuristic = make_annotation(
            "setDelegate:dataSource:options:",
            vec![
                ParamOwnership {
                    param_index: 0,
                    ownership: OwnershipKind::Weak,
                },
                ParamOwnership {
                    param_index: 2,
                    ownership: OwnershipKind::Copy,
                },
            ],
            vec![],
            None,
            None,
            AnnotationSource::Heuristic,
        );

        let llm = make_annotation(
            "setDelegate:dataSource:options:",
            vec![ParamOwnership {
                param_index: 1,
                ownership: OwnershipKind::Strong,
            }],
            vec![],
            None,
            None,
            AnnotationSource::Llm,
        );

        let overrides = AnnotationOverrides::default();
        let merged = merge_annotations(&heuristic, Some(&llm), &overrides);

        assert_eq!(merged.parameter_ownership.len(), 3);
        let by_index = |idx: usize| -> OwnershipKind {
            merged
                .parameter_ownership
                .iter()
                .find(|p| p.param_index == idx)
                .unwrap_or_else(|| panic!("param {idx} missing from merged annotation"))
                .ownership
        };
        assert_eq!(by_index(0), OwnershipKind::Weak);
        assert_eq!(by_index(1), OwnershipKind::Strong);
        assert_eq!(by_index(2), OwnershipKind::Copy);
        assert_eq!(merged.source, AnnotationSource::Llm);
    }

    #[test]
    fn test_merge_parameter_ownership_llm_precedence_on_conflict() {
        // When both sources annotate the same param_index, LLM wins.
        let heuristic = make_annotation(
            "setTarget:",
            vec![ParamOwnership {
                param_index: 0,
                ownership: OwnershipKind::Strong,
            }],
            vec![],
            None,
            None,
            AnnotationSource::Heuristic,
        );

        let llm = make_annotation(
            "setTarget:",
            vec![ParamOwnership {
                param_index: 0,
                ownership: OwnershipKind::Weak,
            }],
            vec![],
            None,
            None,
            AnnotationSource::Llm,
        );

        let overrides = AnnotationOverrides::default();
        let merged = merge_annotations(&heuristic, Some(&llm), &overrides);

        assert_eq!(merged.parameter_ownership.len(), 1);
        assert_eq!(merged.parameter_ownership[0].param_index, 0);
        assert_eq!(merged.parameter_ownership[0].ownership, OwnershipKind::Weak);
    }

    #[test]
    fn test_merge_heuristic_only_when_no_llm() {
        let heuristic = make_annotation(
            "setDelegate:",
            vec![ParamOwnership {
                param_index: 0,
                ownership: OwnershipKind::Weak,
            }],
            vec![],
            Some(ThreadingConstraint::MainThreadOnly),
            None,
            AnnotationSource::Heuristic,
        );

        let overrides = AnnotationOverrides::default();
        let merged = merge_annotations(&heuristic, None, &overrides);
        assert_eq!(merged.source, AnnotationSource::Heuristic);
        assert_eq!(merged.parameter_ownership.len(), 1);
        assert_eq!(merged.threading, Some(ThreadingConstraint::MainThreadOnly));
    }

    #[test]
    fn test_apply_threading_override() {
        let mut annotation = make_annotation(
            "doSomething",
            vec![],
            vec![],
            Some(ThreadingConstraint::MainThreadOnly),
            None,
            AnnotationSource::Llm,
        );

        let overrides = vec![AnnotationOverride {
            class_name: "NSFoo".to_string(),
            selector: "doSomething".to_string(),
            field: "threading".to_string(),
            value: serde_json::Value::String("any_thread".to_string()),
            reason: "Actually thread-safe per Apple docs".to_string(),
        }];

        apply_overrides(&mut annotation, &overrides);
        assert_eq!(annotation.threading, Some(ThreadingConstraint::AnyThread));
        assert_eq!(annotation.source, AnnotationSource::HumanReviewed);
    }

    #[test]
    fn test_apply_block_invocation_override() {
        let mut annotation = make_annotation(
            "performWithBlock:",
            vec![],
            vec![BlockParamAnnotation {
                param_index: 0,
                invocation: BlockInvocationStyle::AsyncCopied,
            }],
            None,
            None,
            AnnotationSource::Heuristic,
        );

        let overrides = vec![AnnotationOverride {
            class_name: "NSFoo".to_string(),
            selector: "performWithBlock:".to_string(),
            field: "block_invocation[0]".to_string(),
            value: serde_json::Value::String("synchronous".to_string()),
            reason: "Block is called synchronously per Apple docs".to_string(),
        }];

        apply_overrides(&mut annotation, &overrides);
        assert_eq!(
            annotation.block_parameters[0].invocation,
            BlockInvocationStyle::Synchronous
        );
        assert_eq!(annotation.source, AnnotationSource::HumanReviewed);
    }

    #[test]
    fn test_block_invocation_disagreement() {
        let heuristic = make_annotation(
            "performWithBlock:",
            vec![],
            vec![BlockParamAnnotation {
                param_index: 0,
                invocation: BlockInvocationStyle::AsyncCopied,
            }],
            None,
            None,
            AnnotationSource::Heuristic,
        );

        let llm = make_annotation(
            "performWithBlock:",
            vec![],
            vec![BlockParamAnnotation {
                param_index: 0,
                invocation: BlockInvocationStyle::Synchronous,
            }],
            None,
            None,
            AnnotationSource::Llm,
        );

        let disagreements = compare_annotations("NSFoo", &heuristic, &llm);
        assert_eq!(disagreements.len(), 1);
        assert_eq!(disagreements[0].field, "block_invocation[0]");
    }

    #[test]
    fn test_threading_disagreement() {
        let heuristic = make_annotation(
            "display",
            vec![],
            vec![],
            Some(ThreadingConstraint::MainThreadOnly),
            None,
            AnnotationSource::Heuristic,
        );

        let llm = make_annotation(
            "display",
            vec![],
            vec![],
            Some(ThreadingConstraint::AnyThread),
            None,
            AnnotationSource::Llm,
        );

        let disagreements = compare_annotations("NSView", &heuristic, &llm);
        assert_eq!(disagreements.len(), 1);
        assert_eq!(disagreements[0].field, "threading");
    }

    #[test]
    fn test_no_threading_disagreement_when_one_is_none() {
        let heuristic = make_annotation(
            "count",
            vec![],
            vec![],
            None, // heuristic has no opinion
            None,
            AnnotationSource::Heuristic,
        );

        let llm = make_annotation(
            "count",
            vec![],
            vec![],
            Some(ThreadingConstraint::AnyThread),
            None,
            AnnotationSource::Llm,
        );

        let disagreements = compare_annotations("NSArray", &heuristic, &llm);
        assert!(disagreements.is_empty());
    }
}
