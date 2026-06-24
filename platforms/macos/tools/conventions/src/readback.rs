//! Read derived ownership facts back out of a run [`ConventionProgram`] into
//! the per-method ownership facet the annotate step consumes.
//!
//! Each `(receiver, selector)` method maps to its `parameter_ownership` list
//! (sorted ascending by index, matching the legacy imperative iteration order)
//! plus the per-index `convention:<rule>` provenance stamp.

use std::collections::BTreeMap;

use apianyware_types::annotation::{
    BlockInvocationStyle, BlockParamAnnotation, ErrorPattern, OwnershipKind, ParamOwnership,
    ThreadingConstraint,
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

/// The threading facet derived for one method.
///
/// A **class/receiver-level** facet (not per-parameter): the value is the
/// method's single threading constraint. The heuristic only ever derives
/// `MainThreadOnly` (it never emits `AnyThread`), so the constraint field is
/// `MainThreadOnly` for every method present — a method's *absence* from the map
/// is "no constraint" (the legacy `None`).
///
/// `provenance` carries the `convention:<rule>` stamp(s) (ADR-0046 §4) of every
/// signal that fired. Unlike block-invocation (one winning rule per parameter),
/// threading is a **disjunction** with no precedence ladder, so several rules
/// may agree on `MainThreadOnly` and the list holds **all** of them, sorted and
/// de-duplicated.
#[derive(Debug, Clone)]
pub struct ThreadingFacet {
    /// The threading constraint — always `MainThreadOnly` (the only value the
    /// convention rules derive).
    pub threading: ThreadingConstraint,
    /// Sorted, de-duplicated `convention:<rule>` stamps for the signals that
    /// fired (≥ 1 entry).
    pub provenance: Vec<String>,
}

/// Collect the threading facet for every method that derived a main-thread
/// constraint, keyed by `(receiver, selector)`.
///
/// The program emits one `main_thread` fact per signal that fired; this unions
/// them into one facet per method, recording every firing rule's
/// `convention:<rule>` stamp. Methods with no `main_thread` fact are absent —
/// the legacy `None`.
pub fn threading_facets(prog: &ConventionProgram) -> BTreeMap<MethodKey, ThreadingFacet> {
    let mut stamps: BTreeMap<MethodKey, Vec<String>> = BTreeMap::new();

    for (receiver, selector, rule) in &prog.main_thread {
        stamps
            .entry((receiver.clone(), selector.clone()))
            .or_default()
            .push(format!("convention:{rule}"));
    }

    stamps
        .into_iter()
        .map(|(key, mut provenance)| {
            provenance.sort();
            provenance.dedup();
            (
                key,
                ThreadingFacet {
                    threading: ThreadingConstraint::MainThreadOnly,
                    provenance,
                },
            )
        })
        .collect()
}

/// The error-pattern facet derived for one method.
///
/// A **method-level** facet (not per-parameter): the value is the method's
/// single error pattern. The heuristic only ever derives `ErrorOutParam` (it
/// never emits `ThrowsException` / `NilOnFailure`), so the pattern field is
/// `ErrorOutParam` for every method present — a method's *absence* from the map
/// is "no error pattern" (the legacy `None`).
///
/// `provenance` carries the `convention:<rule>` stamp (ADR-0046 §4) — see
/// [`OwnershipFacet`] for the carriage rationale; the on-disk stamp is finalized
/// in the flip child. The single rule fires at most once per method, so the list
/// holds exactly one entry (`convention:error-out-param`).
#[derive(Debug, Clone)]
pub struct ErrorPatternFacet {
    /// The error pattern — always `ErrorOutParam` (the only value the convention
    /// rule derives).
    pub error_pattern: ErrorPattern,
    /// `convention:<rule>` stamp for the rule that fired (exactly one entry).
    pub provenance: Vec<String>,
}

/// Collect the error-pattern facet for every method that derived an
/// `ErrorOutParam` fact, keyed by `(receiver, selector)`.
///
/// The program emits one `error_out_param` fact per matching method (the rule
/// fires at most once — there is exactly one last parameter); this maps each to
/// its facet, recording the firing rule's `convention:<rule>` stamp. Methods
/// with no `error_out_param` fact are absent — the legacy `None`.
pub fn error_pattern_facets(prog: &ConventionProgram) -> BTreeMap<MethodKey, ErrorPatternFacet> {
    let mut stamps: BTreeMap<MethodKey, Vec<String>> = BTreeMap::new();

    for (receiver, selector, rule) in &prog.error_out_param {
        stamps
            .entry((receiver.clone(), selector.clone()))
            .or_default()
            .push(format!("convention:{rule}"));
    }

    stamps
        .into_iter()
        .map(|(key, mut provenance)| {
            provenance.sort();
            provenance.dedup();
            (
                key,
                ErrorPatternFacet {
                    error_pattern: ErrorPattern::ErrorOutParam,
                    provenance,
                },
            )
        })
        .collect()
}
