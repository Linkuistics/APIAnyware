//! Read derived ownership facts back out of a run [`ConventionProgram`] into
//! the per-method ownership facet the annotate step consumes.
//!
//! Each `(receiver, selector)` method maps to its `parameter_ownership` list
//! (sorted ascending by index, matching the legacy imperative iteration order)
//! plus the per-index `convention:<rule>` provenance stamp.

use std::collections::BTreeMap;

use apianyware_types::annotation::{
    BlockInvocationStyle, BlockParamAnnotation, OwnershipKind, ParamOwnership,
};

use crate::program::ConventionProgram;

/// Identifies a method within the loaded frameworks: `(receiver, selector)`,
/// where `receiver` is a class or protocol name.
pub type MethodKey = (String, String);

/// The parameter-ownership facet derived for one method.
///
/// `provenance` carries, per parameter index, the `convention:<rule>` stamp(s)
/// that derived the entry (ADR-0046 §4). The stamp's *on-disk* carriage is
/// finalized in the flip child; here it exists so the characterization test can
/// pin its shape while the pipeline still runs on `heuristics.rs`.
#[derive(Debug, Clone, Default)]
pub struct OwnershipFacet {
    /// Ownership entries, ascending by `param_index`.
    pub parameter_ownership: Vec<ParamOwnership>,
    /// `param_index` → sorted, de-duplicated `convention:<rule>` stamps.
    pub provenance: BTreeMap<u32, Vec<String>>,
}

/// Collect the ownership facet for every method that derived at least one
/// ownership fact, keyed by `(receiver, selector)`.
///
/// `weak` wins over `copy` for a given index — but the program already encodes
/// that precedence (`copy_param` requires `!is_weak`), so the two fact sets are
/// disjoint per index and the readback simply unions them.
pub fn ownership_facets(prog: &ConventionProgram) -> BTreeMap<MethodKey, OwnershipFacet> {
    // index -> (kind, rule stamps) accumulated per method.
    let mut acc: BTreeMap<MethodKey, BTreeMap<u32, (OwnershipKind, Vec<String>)>> = BTreeMap::new();

    for (receiver, selector, index, rule) in &prog.weak_param {
        record(
            &mut acc,
            receiver,
            selector,
            *index,
            OwnershipKind::Weak,
            rule,
        );
    }
    for (receiver, selector, index, rule) in &prog.copy_param {
        record(
            &mut acc,
            receiver,
            selector,
            *index,
            OwnershipKind::Copy,
            rule,
        );
    }

    acc.into_iter()
        .map(|(key, by_index)| {
            let mut parameter_ownership = Vec::with_capacity(by_index.len());
            let mut provenance = BTreeMap::new();
            for (index, (ownership, mut stamps)) in by_index {
                parameter_ownership.push(ParamOwnership {
                    param_index: index as usize,
                    ownership,
                });
                stamps.sort();
                stamps.dedup();
                provenance.insert(index, stamps);
            }
            (
                key,
                OwnershipFacet {
                    parameter_ownership,
                    provenance,
                },
            )
        })
        .collect()
}

/// Record one derived fact, stamping the rule as `convention:<rule>`.
fn record(
    acc: &mut BTreeMap<MethodKey, BTreeMap<u32, (OwnershipKind, Vec<String>)>>,
    receiver: &str,
    selector: &str,
    index: u32,
    ownership: OwnershipKind,
    rule: &str,
) {
    let entry = acc
        .entry((receiver.to_string(), selector.to_string()))
        .or_default()
        .entry(index)
        .or_insert((ownership, Vec::new()));
    // Disjoint by construction, but be explicit: weak dominates copy.
    if ownership == OwnershipKind::Weak {
        entry.0 = OwnershipKind::Weak;
    }
    entry.1.push(format!("convention:{rule}"));
}

/// The block-invocation facet derived for one method.
///
/// `provenance` carries, per parameter index, the `convention:<rule>` stamp of
/// the winning candidate (ADR-0046 §4) — see [`OwnershipFacet`] for the carriage
/// rationale; the on-disk stamp is finalized in the flip child.
#[derive(Debug, Clone, Default)]
pub struct BlockInvocationFacet {
    /// Block-parameter invocation entries, ascending by `param_index`.
    pub block_parameters: Vec<BlockParamAnnotation>,
    /// `param_index` → the winning `convention:<rule>` stamp (one rule wins per
    /// parameter, so each list holds exactly one entry).
    pub provenance: BTreeMap<u32, Vec<String>>,
}

/// Collect the block-invocation facet for every method with at least one block
/// parameter, keyed by `(receiver, selector)`.
///
/// The program emits a `block_candidate` per precedence level a parameter
/// matches; this resolves the legacy "first match wins" ladder by keeping the
/// **lowest-priority** candidate per `(receiver, selector, param_index)`.
/// Priorities are unique per parameter (one rule per level), so there is no tie
/// to break.
pub fn block_invocation_facets(
    prog: &ConventionProgram,
) -> BTreeMap<MethodKey, BlockInvocationFacet> {
    // (receiver, selector) -> param_index -> (priority, style, rule) winner.
    let mut winners: BTreeMap<MethodKey, BTreeMap<u32, (u32, &'static str, &'static str)>> =
        BTreeMap::new();

    for (receiver, selector, index, priority, style, rule) in &prog.block_candidate {
        let by_index = winners
            .entry((receiver.clone(), selector.clone()))
            .or_default();
        let entry = by_index.entry(*index).or_insert((*priority, *style, *rule));
        if *priority < entry.0 {
            *entry = (*priority, *style, *rule);
        }
    }

    winners
        .into_iter()
        .map(|(key, by_index)| {
            // `by_index` is a BTreeMap, so iteration is ascending by index.
            let mut block_parameters = Vec::with_capacity(by_index.len());
            let mut provenance = BTreeMap::new();
            for (index, (_priority, style, rule)) in by_index {
                block_parameters.push(BlockParamAnnotation {
                    param_index: index as usize,
                    invocation: style_from_code(style),
                });
                provenance.insert(index, vec![format!("convention:{rule}")]);
            }
            (
                key,
                BlockInvocationFacet {
                    block_parameters,
                    provenance,
                },
            )
        })
        .collect()
}

/// Map the candidate's `snake_case` style code to the typed enum. The codes are
/// produced only by the program's own rules, so an unknown value is a bug.
fn style_from_code(style: &str) -> BlockInvocationStyle {
    match style {
        "synchronous" => BlockInvocationStyle::Synchronous,
        "async_copied" => BlockInvocationStyle::AsyncCopied,
        "stored" => BlockInvocationStyle::Stored,
        other => unreachable!("unknown block invocation style code: {other}"),
    }
}
