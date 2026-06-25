//! The resolve-time precedence audit (ADR-0046 §4 / ADR-0050 §3).
//!
//! Per `(receiver, selector)` fact-slot — each [`ParamOwnership`], each
//! [`BlockParamAnnotation`], the method-level threading and error-pattern — the
//! audit gathers every producing tier, applies §28 precedence
//! (`manual > accepted-LLM > convention > extraction > unknown`), **stamps the
//! winner's source** on the resolved fact, and records each *disagreeing* loser
//! as a [`SupersededFact`]. A slot with no producer gets no provenance entry
//! (its unknown-ness is the absence); a method with no producing fact at all
//! carries the method-level `source = Unknown` rather than a silent `Convention`.
//!
//! **Golden-neutral by construction.** The audit stamps *provenance* only — the
//! winning *value* of every slot is byte-identical to the legacy
//! `llm`-over-convention merge it replaces (overlay wins a contested slot;
//! convention fills the gaps; block invocations are all-or-nothing). Emit reads
//! fact *values* (via the enrichment pass), never `source`, so provenance is
//! emit-invisible and the goldens cannot move (ADR-0050 D4).

use apianyware_types::annotation::{
    AnnotationOverride, AnnotationSource, BlockInvocationStyle, BlockParamAnnotation, ErrorPattern,
    MethodAnnotation, MethodFactProvenance, OwnershipKind, ParamOwnership, SlotProvenance,
    SupersededFact, ThreadingConstraint,
};
use serde::Serialize;

/// Render a fact value to its serde token (e.g. `Strong` → `"strong"`), so a
/// [`SupersededFact`] reads without the producing enum. Drives off the same
/// `#[serde(rename_all = "snake_case")]` the on-disk format uses, so the token
/// can never drift from the serialized value.
fn token<T: Serialize>(value: &T) -> String {
    serde_json::to_value(value)
        .ok()
        .and_then(|v| v.as_str().map(str::to_string))
        .unwrap_or_default()
}

/// Audit one method's fact-slots: reconcile the convention tier with the
/// authored overlay (`Some` when the overlay annotates this `(receiver,
/// selector)`), applying §28 precedence per slot.
///
/// `convention` is the convention-tier annotation assembled from the datalog
/// facets — its [`MethodAnnotation::fact_provenance`] already carries the
/// per-slot `convention:<rule>` stamps. The returned annotation is the resolved
/// fact (winning values) plus its audited [`MethodFactProvenance`].
pub fn audit_annotations(
    convention: &MethodAnnotation,
    overlay: Option<&MethodAnnotation>,
) -> MethodAnnotation {
    // The overlay's method-level source is the tier its facts belong to —
    // `Llm` (accepted-LLM) or `Manual`. Both outrank `Convention` (§28), so a
    // present overlay fact always wins its slot; convention fills the gaps.
    let overlay_tier = overlay.map(|o| o.source);
    let conv_prov = convention.fact_provenance.clone().unwrap_or_default();

    let mut prov = MethodFactProvenance::default();

    let parameter_ownership =
        audit_ownership(convention, overlay, overlay_tier, &conv_prov, &mut prov);
    let block_parameters = audit_blocks(convention, overlay, overlay_tier, &conv_prov, &mut prov);
    let threading = audit_threading(convention, overlay, overlay_tier, &conv_prov, &mut prov);
    let error_pattern = audit_error(convention, overlay, overlay_tier, &conv_prov, &mut prov);

    // Method-level source: the coarsest producing tier. Overlay present → its
    // tier; else convention if it produced any fact; else explicitly `Unknown`
    // (never silently `Convention` for a fact-less method — ADR-0050 §3).
    let has_fact = !parameter_ownership.is_empty()
        || !block_parameters.is_empty()
        || threading.is_some()
        || error_pattern.is_some();
    let source = match overlay_tier {
        Some(tier) => tier,
        None if has_fact => AnnotationSource::Convention,
        None => AnnotationSource::Unknown,
    };

    MethodAnnotation {
        selector: convention.selector.clone(),
        is_instance: convention.is_instance,
        parameter_ownership,
        block_parameters,
        threading,
        error_pattern,
        source,
        // `confidence`/`provenance` are authored-overlay fields; carry the
        // overlay's when present (they describe the winning authored fact).
        confidence: overlay.and_then(|o| o.confidence),
        provenance: overlay.and_then(|o| o.provenance.clone()),
        fact_provenance: Some(prov),
    }
}

/// Resolve one fact-slot by §28 precedence. `conv` is the convention candidate
/// (tier [`AnnotationSource::Convention`]); `over` the authored-overlay candidate
/// carried with its own tier. The lower [`AnnotationSource::precedence`] rank
/// wins; the *other* producing tier becomes a [`SupersededFact`] **iff its value
/// differs** (an agreeing tier is redundant, not superseded — ADR-0050 §3).
/// Returns the winning value and its [`SlotProvenance`], or `None` when neither
/// tier produced the slot.
///
/// For the `{llm, manual}` overlay vocabulary (ADR-0050 D3) the overlay always
/// outranks convention, so this reproduces the legacy `overlay-over-convention`
/// merge exactly (golden-neutral); the rank comparison only changes the outcome
/// for a hypothetical sub-convention overlay tier, which §28 says must lose.
fn resolve_slot<T: Copy + PartialEq>(
    param_index: Option<usize>,
    conv: Option<T>,
    conv_rules: Vec<String>,
    over: Option<(T, AnnotationSource)>,
    render: impl Fn(&T) -> String,
) -> Option<(T, SlotProvenance)> {
    match (conv, over) {
        (None, None) => None,
        (Some(c), None) => Some((
            c,
            SlotProvenance {
                param_index,
                source: AnnotationSource::Convention,
                rules: conv_rules,
                superseded_by: Vec::new(),
            },
        )),
        (None, Some((o, tier))) => Some((
            o,
            SlotProvenance {
                param_index,
                source: tier,
                rules: Vec::new(),
                superseded_by: Vec::new(),
            },
        )),
        (Some(c), Some((o, tier))) => {
            let overlay_wins = tier.precedence() <= AnnotationSource::Convention.precedence();
            let disagrees = c != o;
            if overlay_wins {
                // Overlay wins; convention is the loser, recorded iff it differs.
                let superseded = if disagrees {
                    vec![SupersededFact {
                        source: AnnotationSource::Convention,
                        value: render(&c),
                    }]
                } else {
                    Vec::new()
                };
                Some((
                    o,
                    SlotProvenance {
                        param_index,
                        source: tier,
                        rules: Vec::new(),
                        superseded_by: superseded,
                    },
                ))
            } else {
                // Convention outranks this overlay tier (§28); overlay is the loser.
                let superseded = if disagrees {
                    vec![SupersededFact {
                        source: tier,
                        value: render(&o),
                    }]
                } else {
                    Vec::new()
                };
                Some((
                    c,
                    SlotProvenance {
                        param_index,
                        source: AnnotationSource::Convention,
                        rules: conv_rules,
                        superseded_by: superseded,
                    },
                ))
            }
        }
    }
}

/// Ownership is a **per-`param_index` union**: every param either source
/// annotates survives; the higher-precedence tier wins a param both annotate
/// (§28). Mirrors the legacy merge's per-param union exactly (overlay wins for
/// the `{llm, manual}` vocabulary).
fn audit_ownership(
    convention: &MethodAnnotation,
    overlay: Option<&MethodAnnotation>,
    overlay_tier: Option<AnnotationSource>,
    conv_prov: &MethodFactProvenance,
    prov: &mut MethodFactProvenance,
) -> Vec<ParamOwnership> {
    let conv_rules = |i: usize| {
        conv_prov
            .parameter_ownership
            .iter()
            .find(|s| s.param_index == Some(i))
            .map(|s| s.rules.clone())
            .unwrap_or_default()
    };
    let overlay_params = overlay
        .map(|o| o.parameter_ownership.as_slice())
        .unwrap_or(&[]);

    // Union of param indices, ascending — deterministic output ordering.
    let mut indices: Vec<usize> = convention
        .parameter_ownership
        .iter()
        .chain(overlay_params)
        .map(|p| p.param_index)
        .collect();
    indices.sort_unstable();
    indices.dedup();

    let mut result = Vec::with_capacity(indices.len());
    for i in indices {
        let conv = convention
            .parameter_ownership
            .iter()
            .find(|p| p.param_index == i)
            .map(|p| p.ownership);
        let over = overlay_params
            .iter()
            .find(|p| p.param_index == i)
            .zip(overlay_tier)
            .map(|(p, tier)| (p.ownership, tier));

        if let Some((ownership, slot)) = resolve_slot(Some(i), conv, conv_rules(i), over, token) {
            result.push(ParamOwnership {
                param_index: i,
                ownership,
            });
            prov.parameter_ownership.push(slot);
        }
    }
    result
}

/// Block invocations are **all-or-nothing**: a non-empty overlay block list
/// replaces the convention list wholesale (the legacy merge's behaviour — *not*
/// a per-param union, to stay golden-neutral). The audit therefore records
/// `superseded_by` only for a param both tiers annotate with a *differing*
/// invocation; a convention block on a param the overlay omits is dropped by the
/// all-or-nothing rule and has no winning slot to attach to.
fn audit_blocks(
    convention: &MethodAnnotation,
    overlay: Option<&MethodAnnotation>,
    overlay_tier: Option<AnnotationSource>,
    conv_prov: &MethodFactProvenance,
    prov: &mut MethodFactProvenance,
) -> Vec<BlockParamAnnotation> {
    let conv_rules = |i: usize| {
        conv_prov
            .block_parameters
            .iter()
            .find(|s| s.param_index == Some(i))
            .map(|s| s.rules.clone())
            .unwrap_or_default()
    };

    let overlay_blocks = overlay
        .map(|o| o.block_parameters.as_slice())
        .filter(|b| !b.is_empty());

    match (overlay_blocks, overlay_tier) {
        // Overlay wins the block slot-group wholesale.
        (Some(blocks), Some(tier)) => {
            for b in blocks {
                let superseded = convention
                    .block_parameters
                    .iter()
                    .find(|c| c.param_index == b.param_index && c.invocation != b.invocation)
                    .map(|c| {
                        vec![SupersededFact {
                            source: AnnotationSource::Convention,
                            value: token(&c.invocation),
                        }]
                    })
                    .unwrap_or_default();
                prov.block_parameters.push(SlotProvenance {
                    param_index: Some(b.param_index),
                    source: tier,
                    rules: Vec::new(),
                    superseded_by: superseded,
                });
            }
            blocks.to_vec()
        }
        // Convention-only blocks.
        _ => {
            for c in &convention.block_parameters {
                prov.block_parameters.push(SlotProvenance {
                    param_index: Some(c.param_index),
                    source: AnnotationSource::Convention,
                    rules: conv_rules(c.param_index),
                    superseded_by: Vec::new(),
                });
            }
            convention.block_parameters.clone()
        }
    }
}

/// Threading is a method-level scalar slot resolved by §28 precedence: the
/// higher-precedence tier wins, else absent (no producer → no provenance entry).
fn audit_threading(
    convention: &MethodAnnotation,
    overlay: Option<&MethodAnnotation>,
    overlay_tier: Option<AnnotationSource>,
    conv_prov: &MethodFactProvenance,
    prov: &mut MethodFactProvenance,
) -> Option<ThreadingConstraint> {
    let conv_rules = conv_prov
        .threading
        .as_ref()
        .map(|s| s.rules.clone())
        .unwrap_or_default();
    let over = overlay.and_then(|o| o.threading).zip(overlay_tier);
    let resolved = resolve_slot(None, convention.threading, conv_rules, over, token);
    let (value, slot) = split(resolved);
    prov.threading = slot;
    value
}

/// Error pattern is a method-level scalar slot — same precedence shape as
/// threading.
fn audit_error(
    convention: &MethodAnnotation,
    overlay: Option<&MethodAnnotation>,
    overlay_tier: Option<AnnotationSource>,
    conv_prov: &MethodFactProvenance,
    prov: &mut MethodFactProvenance,
) -> Option<ErrorPattern> {
    let conv_rules = conv_prov
        .error_pattern
        .as_ref()
        .map(|s| s.rules.clone())
        .unwrap_or_default();
    let over = overlay.and_then(|o| o.error_pattern).zip(overlay_tier);
    let resolved = resolve_slot(None, convention.error_pattern, conv_rules, over, token);
    let (value, slot) = split(resolved);
    prov.error_pattern = slot;
    value
}

/// Split a `resolve_slot` result into the optional winning value and optional
/// provenance entry — the shape the two scalar slots store.
fn split<T>(resolved: Option<(T, SlotProvenance)>) -> (Option<T>, Option<SlotProvenance>) {
    match resolved {
        Some((v, s)) => (Some(v), Some(s)),
        None => (None, None),
    }
}

/// Apply human-reviewed overrides to a merged annotation.
///
/// Dead in the in-process resolve flow today (the overlay's `manual` facts are
/// authored directly in `annotations.apiw`); retained for the standalone
/// override path. Its disposition belongs to ws5 `retire-tooling`.
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

        annotation.source = AnnotationSource::Manual;
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    /// A convention-tier annotation as `annotate::ConventionFacets::annotation_for`
    /// hands it to the audit: facts plus a `fact_provenance` whose every slot is
    /// `Convention` with the given rule stamps.
    fn convention(
        selector: &str,
        param_ownership: Vec<(usize, OwnershipKind, Vec<&str>)>,
        block_params: Vec<(usize, BlockInvocationStyle, Vec<&str>)>,
        threading: Option<(ThreadingConstraint, Vec<&str>)>,
        error_pattern: Option<(ErrorPattern, Vec<&str>)>,
    ) -> MethodAnnotation {
        let mut prov = MethodFactProvenance::default();
        let parameter_ownership = param_ownership
            .into_iter()
            .map(|(i, k, rules)| {
                prov.parameter_ownership.push(SlotProvenance {
                    param_index: Some(i),
                    source: AnnotationSource::Convention,
                    rules: rules.into_iter().map(String::from).collect(),
                    superseded_by: vec![],
                });
                ParamOwnership {
                    param_index: i,
                    ownership: k,
                }
            })
            .collect();
        let block_parameters = block_params
            .into_iter()
            .map(|(i, inv, rules)| {
                prov.block_parameters.push(SlotProvenance {
                    param_index: Some(i),
                    source: AnnotationSource::Convention,
                    rules: rules.into_iter().map(String::from).collect(),
                    superseded_by: vec![],
                });
                BlockParamAnnotation {
                    param_index: i,
                    invocation: inv,
                }
            })
            .collect();
        let threading_val = threading.map(|(t, rules)| {
            prov.threading = Some(SlotProvenance {
                param_index: None,
                source: AnnotationSource::Convention,
                rules: rules.into_iter().map(String::from).collect(),
                superseded_by: vec![],
            });
            t
        });
        let error_val = error_pattern.map(|(e, rules)| {
            prov.error_pattern = Some(SlotProvenance {
                param_index: None,
                source: AnnotationSource::Convention,
                rules: rules.into_iter().map(String::from).collect(),
                superseded_by: vec![],
            });
            e
        });
        MethodAnnotation {
            selector: selector.to_string(),
            is_instance: true,
            parameter_ownership,
            block_parameters,
            threading: threading_val,
            error_pattern: error_val,
            // The audit recomputes the method-level source; the convention
            // input's tag is the convention tier regardless.
            source: AnnotationSource::Convention,
            confidence: None,
            provenance: None,
            fact_provenance: Some(prov),
        }
    }

    /// An authored-overlay annotation (no `fact_provenance`; method-level
    /// `source` is the authored tier).
    fn overlay(
        selector: &str,
        source: AnnotationSource,
        param_ownership: Vec<(usize, OwnershipKind)>,
        block_params: Vec<(usize, BlockInvocationStyle)>,
        threading: Option<ThreadingConstraint>,
        error_pattern: Option<ErrorPattern>,
    ) -> MethodAnnotation {
        MethodAnnotation {
            selector: selector.to_string(),
            is_instance: true,
            parameter_ownership: param_ownership
                .into_iter()
                .map(|(param_index, ownership)| ParamOwnership {
                    param_index,
                    ownership,
                })
                .collect(),
            block_parameters: block_params
                .into_iter()
                .map(|(param_index, invocation)| BlockParamAnnotation {
                    param_index,
                    invocation,
                })
                .collect(),
            threading,
            error_pattern,
            source,
            confidence: None,
            provenance: None,
            fact_provenance: None,
        }
    }

    fn owned(prov: &MethodFactProvenance, i: usize) -> &SlotProvenance {
        prov.parameter_ownership
            .iter()
            .find(|s| s.param_index == Some(i))
            .expect("ownership slot present")
    }

    // ---- Golden-neutrality: winning VALUES match the legacy merge -----------

    #[test]
    fn overlay_value_wins_contested_threading_slot() {
        let conv = convention(
            "display",
            vec![],
            vec![],
            Some((
                ThreadingConstraint::MainThreadOnly,
                vec!["convention:ui-main"],
            )),
            None,
        );
        let ov = overlay(
            "display",
            AnnotationSource::Llm,
            vec![],
            vec![],
            Some(ThreadingConstraint::AnyThread),
            None,
        );

        let r = audit_annotations(&conv, Some(&ov));
        // Winning value is the overlay's — unchanged from the legacy merge.
        assert_eq!(r.threading, Some(ThreadingConstraint::AnyThread));
    }

    #[test]
    fn convention_fills_threading_gap_when_overlay_silent() {
        let conv = convention(
            "writeToFile:atomically:error:",
            vec![],
            vec![],
            None,
            Some((
                ErrorPattern::ErrorOutParam,
                vec!["convention:error-outparam"],
            )),
        );
        let ov = overlay(
            "writeToFile:atomically:error:",
            AnnotationSource::Llm,
            vec![],
            vec![],
            Some(ThreadingConstraint::AnyThread),
            None, // overlay silent on error pattern
        );

        let r = audit_annotations(&conv, Some(&ov));
        assert_eq!(r.error_pattern, Some(ErrorPattern::ErrorOutParam));
        assert_eq!(r.threading, Some(ThreadingConstraint::AnyThread));
    }

    #[test]
    fn ownership_is_per_param_union_overlay_wins_conflict() {
        // Convention annotates params 0 and 2; overlay annotates only param 1
        // plus a conflicting param 0. Legacy union: 0←overlay, 1←overlay,
        // 2←convention.
        let conv = convention(
            "setDelegate:dataSource:options:",
            vec![
                (0, OwnershipKind::Strong, vec!["convention:default-strong"]),
                (2, OwnershipKind::Copy, vec!["convention:options-copy"]),
            ],
            vec![],
            None,
            None,
        );
        let ov = overlay(
            "setDelegate:dataSource:options:",
            AnnotationSource::Llm,
            vec![(0, OwnershipKind::Weak), (1, OwnershipKind::Strong)],
            vec![],
            None,
            None,
        );

        let r = audit_annotations(&conv, Some(&ov));
        let by = |i: usize| {
            r.parameter_ownership
                .iter()
                .find(|p| p.param_index == i)
                .unwrap()
                .ownership
        };
        assert_eq!(r.parameter_ownership.len(), 3);
        assert_eq!(by(0), OwnershipKind::Weak); // overlay wins conflict
        assert_eq!(by(1), OwnershipKind::Strong); // overlay-only
        assert_eq!(by(2), OwnershipKind::Copy); // convention-only
    }

    #[test]
    fn blocks_are_all_or_nothing_overlay_replaces_whole_list() {
        // Convention annotates block params 0 and 1; overlay annotates only
        // param 0. Legacy all-or-nothing: overlay's single block replaces the
        // convention list entirely (param 1 is dropped — NOT a union).
        let conv = convention(
            "enumerate:options:usingBlock:",
            vec![],
            vec![
                (
                    0,
                    BlockInvocationStyle::Synchronous,
                    vec!["convention:enumerate-sync"],
                ),
                (
                    1,
                    BlockInvocationStyle::Synchronous,
                    vec!["convention:enumerate-sync"],
                ),
            ],
            None,
            None,
        );
        let ov = overlay(
            "enumerate:options:usingBlock:",
            AnnotationSource::Llm,
            vec![],
            vec![(0, BlockInvocationStyle::AsyncCopied)],
            None,
            None,
        );

        let r = audit_annotations(&conv, Some(&ov));
        assert_eq!(
            r.block_parameters.len(),
            1,
            "overlay list replaces convention's wholesale"
        );
        assert_eq!(r.block_parameters[0].param_index, 0);
        assert_eq!(
            r.block_parameters[0].invocation,
            BlockInvocationStyle::AsyncCopied
        );
    }

    #[test]
    fn convention_only_method_is_unchanged_in_value() {
        let conv = convention(
            "setDelegate:",
            vec![(0, OwnershipKind::Weak, vec!["convention:delegate-weak"])],
            vec![],
            Some((
                ThreadingConstraint::MainThreadOnly,
                vec!["convention:ui-main"],
            )),
            None,
        );

        let r = audit_annotations(&conv, None);
        assert_eq!(r.parameter_ownership.len(), 1);
        assert_eq!(r.parameter_ownership[0].ownership, OwnershipKind::Weak);
        assert_eq!(r.threading, Some(ThreadingConstraint::MainThreadOnly));
    }

    // ---- Provenance: per-fact source stamping -------------------------------

    #[test]
    fn winning_overlay_fact_is_stamped_with_overlay_tier() {
        let conv = convention(
            "setDelegate:",
            vec![(0, OwnershipKind::Strong, vec!["convention:default-strong"])],
            vec![],
            None,
            None,
        );
        let ov = overlay(
            "setDelegate:",
            AnnotationSource::Llm,
            vec![(0, OwnershipKind::Weak)],
            vec![],
            None,
            None,
        );

        let r = audit_annotations(&conv, Some(&ov));
        let prov = r.fact_provenance.unwrap();
        let slot = owned(&prov, 0);
        assert_eq!(slot.source, AnnotationSource::Llm);
        // The overlay winner carries no convention rules.
        assert!(slot.rules.is_empty());
    }

    #[test]
    fn winning_convention_fact_carries_its_rule_stamps() {
        let conv = convention(
            "setDelegate:",
            vec![(0, OwnershipKind::Weak, vec!["convention:delegate-weak"])],
            vec![],
            None,
            None,
        );

        let r = audit_annotations(&conv, None);
        let prov = r.fact_provenance.unwrap();
        let slot = owned(&prov, 0);
        assert_eq!(slot.source, AnnotationSource::Convention);
        assert_eq!(slot.rules, vec!["convention:delegate-weak".to_string()]);
        assert!(slot.superseded_by.is_empty());
    }

    // ---- Provenance: ONLY disagreements become superseded-by ----------------

    #[test]
    fn disagreeing_convention_loser_is_recorded_superseded_by() {
        let conv = convention(
            "setTarget:",
            vec![(0, OwnershipKind::Strong, vec!["convention:default-strong"])],
            vec![],
            None,
            None,
        );
        let ov = overlay(
            "setTarget:",
            AnnotationSource::Llm,
            vec![(0, OwnershipKind::Weak)],
            vec![],
            None,
            None,
        );

        let r = audit_annotations(&conv, Some(&ov));
        let prov = r.fact_provenance.unwrap();
        let slot = owned(&prov, 0);
        assert_eq!(slot.source, AnnotationSource::Llm);
        assert_eq!(slot.superseded_by.len(), 1);
        assert_eq!(slot.superseded_by[0].source, AnnotationSource::Convention);
        assert_eq!(slot.superseded_by[0].value, "strong");
    }

    #[test]
    fn agreeing_loser_is_not_recorded() {
        // Convention and overlay AGREE on param 0 (both weak) → redundant, not a
        // disagreement → no superseded-by entry (ADR-0050 §3).
        let conv = convention(
            "setDelegate:",
            vec![(0, OwnershipKind::Weak, vec!["convention:delegate-weak"])],
            vec![],
            None,
            None,
        );
        let ov = overlay(
            "setDelegate:",
            AnnotationSource::Llm,
            vec![(0, OwnershipKind::Weak)],
            vec![],
            None,
            None,
        );

        let r = audit_annotations(&conv, Some(&ov));
        let prov = r.fact_provenance.unwrap();
        let slot = owned(&prov, 0);
        assert_eq!(slot.source, AnnotationSource::Llm);
        assert!(
            slot.superseded_by.is_empty(),
            "an agreeing tier is redundant, not superseded"
        );
    }

    #[test]
    fn disagreeing_threading_loser_renders_serde_token() {
        let conv = convention(
            "display",
            vec![],
            vec![],
            Some((
                ThreadingConstraint::MainThreadOnly,
                vec!["convention:ui-main"],
            )),
            None,
        );
        let ov = overlay(
            "display",
            AnnotationSource::Llm,
            vec![],
            vec![],
            Some(ThreadingConstraint::AnyThread),
            None,
        );

        let r = audit_annotations(&conv, Some(&ov));
        let slot = r.fact_provenance.unwrap().threading.unwrap();
        assert_eq!(slot.source, AnnotationSource::Llm);
        assert_eq!(slot.superseded_by.len(), 1);
        assert_eq!(slot.superseded_by[0].value, "main_thread_only");
    }

    #[test]
    fn sub_convention_overlay_tier_loses_to_convention() {
        // The §28 ladder is *enforced by rank*, not assumed: an overlay fact
        // sourced below convention (here `Extraction`, rank 3 > convention's 2)
        // must LOSE — convention wins the value and the overlay becomes the
        // disagreeing loser. (Real overlays are `{llm, manual}`, both of which
        // outrank convention; this guards the ladder against a future tier.)
        let conv = convention(
            "display",
            vec![],
            vec![],
            Some((
                ThreadingConstraint::MainThreadOnly,
                vec!["convention:ui-main"],
            )),
            None,
        );
        let ov = overlay(
            "display",
            AnnotationSource::Extraction,
            vec![],
            vec![],
            Some(ThreadingConstraint::AnyThread),
            None,
        );

        let r = audit_annotations(&conv, Some(&ov));
        assert_eq!(
            r.threading,
            Some(ThreadingConstraint::MainThreadOnly),
            "convention outranks a sub-convention overlay tier"
        );
        let slot = r.fact_provenance.unwrap().threading.unwrap();
        assert_eq!(slot.source, AnnotationSource::Convention);
        assert_eq!(slot.superseded_by.len(), 1);
        assert_eq!(slot.superseded_by[0].source, AnnotationSource::Extraction);
        assert_eq!(slot.superseded_by[0].value, "any_thread");
    }

    // ---- Method-level source: explicit unknown, never silent convention -----

    #[test]
    fn factless_method_is_explicit_unknown_not_convention() {
        // No convention facts, no overlay — the method-level source must be
        // `Unknown`, not a silently-defaulted `Convention` (ADR-0050 §3).
        let conv = convention("hash", vec![], vec![], None, None);
        let r = audit_annotations(&conv, None);
        assert_eq!(r.source, AnnotationSource::Unknown);
        assert_eq!(r.fact_provenance.unwrap(), MethodFactProvenance::default());
    }

    #[test]
    fn convention_method_keeps_convention_source() {
        let conv = convention(
            "count",
            vec![],
            vec![],
            Some((ThreadingConstraint::AnyThread, vec!["convention:any"])),
            None,
        );
        let r = audit_annotations(&conv, None);
        assert_eq!(r.source, AnnotationSource::Convention);
    }

    #[test]
    fn overlay_method_takes_overlay_tier_source() {
        let conv = convention("compare:", vec![], vec![], None, None);
        let ov = overlay(
            "compare:",
            AnnotationSource::Manual,
            vec![(0, OwnershipKind::Strong)],
            vec![],
            None,
            None,
        );
        let r = audit_annotations(&conv, Some(&ov));
        assert_eq!(r.source, AnnotationSource::Manual);
    }

    // ---- apply_overrides (retained legacy path) -----------------------------

    #[test]
    fn apply_threading_override_sets_manual_source() {
        let mut annotation = overlay(
            "doSomething",
            AnnotationSource::Llm,
            vec![],
            vec![],
            Some(ThreadingConstraint::MainThreadOnly),
            None,
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
        assert_eq!(annotation.source, AnnotationSource::Manual);
    }
}
