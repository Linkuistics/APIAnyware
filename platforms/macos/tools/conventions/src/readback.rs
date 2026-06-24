//! Read derived ownership facts back out of a run [`ConventionProgram`] into
//! the per-method ownership facet the annotate step consumes.
//!
//! Each `(receiver, selector)` method maps to its `parameter_ownership` list
//! (sorted ascending by index, matching the legacy imperative iteration order)
//! plus the per-index `convention:<rule>` provenance stamp.

use std::collections::BTreeMap;

use apianyware_types::annotation::{OwnershipKind, ParamOwnership};

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
