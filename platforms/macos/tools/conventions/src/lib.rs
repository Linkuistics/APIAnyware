//! Cocoa naming-convention heuristics as declarative `ascent` datalog rules
//! (ADR-0047).
//!
//! This crate re-expresses the imperative classifiers in
//! `platforms/macos/tools/annotate/src/heuristics.rs` as legible, auditable
//! `ascent` rules — the same engine as the `resolve` and `enrich` passes — so
//! each derived fact records the rule that produced it (the `convention:<rule>`
//! provenance of ADR-0046 §4 falls out of the derivation trace).
//!
//! **Status (k22):** only the **parameter-ownership** facet is ported. The
//! block-invocation, threading, and error-pattern facets are later siblings,
//! and the analysis pipeline is **not yet wired** to this crate — `annotate`
//! still runs the imperative heuristics. The flip child swaps the pipeline over
//! once every facet is ported and characterization-equivalent. Until then this
//! crate is exercised only by its tests, which assert rule-for-rule equivalence
//! against the legacy classifiers (goldens-as-truth).

pub mod fact_loader;
pub mod program;
pub mod readback;

use std::collections::BTreeMap;

use apianyware_types::ir::Framework;

pub use readback::{MethodKey, OwnershipFacet};

/// Derive the parameter-ownership facet for every method across `frameworks`,
/// keyed by `(receiver, selector)`.
///
/// All frameworks load into one program so a single run covers the whole set
/// (the convention rules are per-method and do not cross frameworks, but this
/// matches the `resolve`/`enrich` "one program, all frameworks" shape).
pub fn derive_ownership(frameworks: &[Framework]) -> BTreeMap<MethodKey, OwnershipFacet> {
    let mut prog = program::ConventionProgram::default();
    for framework in frameworks {
        fact_loader::load_framework_facts(&mut prog, framework);
    }
    prog.run();
    tracing::info!(
        params = prog.param.len(),
        weak = prog.weak_param.len(),
        copy = prog.copy_param.len(),
        "convention ownership facet derived"
    );
    readback::ownership_facets(&prog)
}
