//! Cocoa naming-convention heuristics as declarative `ascent` datalog rules
//! (ADR-0047).
//!
//! This crate re-expresses the imperative classifiers in
//! `platforms/macos/tools/annotate/src/heuristics.rs` as legible, auditable
//! `ascent` rules — the same engine as the `resolve` and `enrich` passes — so
//! each derived fact records the rule that produced it (the `convention:<rule>`
//! provenance of ADR-0046 §4 falls out of the derivation trace).
//!
//! **Status (k24):** the **parameter-ownership** (k22), **block-invocation**
//! (k23), and **threading** (k24) facets are ported. The error-pattern facet is
//! a later sibling, and the analysis pipeline is **not yet wired** to this crate
//! — `annotate` still runs the imperative heuristics. The flip child swaps the
//! pipeline over once every facet is ported and characterization-equivalent.
//! Until then this crate is exercised only by its tests, which assert
//! rule-for-rule equivalence against the legacy classifiers (goldens-as-truth).

pub mod fact_loader;
pub mod program;
pub mod readback;

use std::collections::BTreeMap;

use apianyware_types::ir::Framework;

pub use readback::{BlockInvocationFacet, MethodKey, OwnershipFacet, ThreadingFacet};

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

/// Derive the block-invocation facet for every method across `frameworks`,
/// keyed by `(receiver, selector)`.
///
/// Mirrors `heuristics::derive_block_parameters`: every block-typed parameter
/// resolves to one `BlockInvocationStyle` via the program's 6-level precedence
/// cascade, the lowest-priority candidate winning (see [`program`]).
pub fn derive_block_invocations(
    frameworks: &[Framework],
) -> BTreeMap<MethodKey, BlockInvocationFacet> {
    let mut prog = program::ConventionProgram::default();
    for framework in frameworks {
        fact_loader::load_framework_facts(&mut prog, framework);
    }
    prog.run();
    tracing::info!(
        properties = prog.property.len(),
        candidates = prog.block_candidate.len(),
        "convention block-invocation facet derived"
    );
    readback::block_invocation_facets(&prog)
}

/// Derive the threading facet for every method across `frameworks`, keyed by
/// `(receiver, selector)`.
///
/// Mirrors `heuristics::derive_threading`: a method is `MainThreadOnly` when any
/// of the three signals fires (class-level `@MainActor`, the hardcoded UIKit
/// class list, or the UI selector list). The facet is a simple disjunction with
/// no precedence ladder, so a method may carry several `convention:<rule>`
/// stamps (see [`ThreadingFacet`]); methods with no signal are absent from the
/// map (the legacy `None`).
pub fn derive_threading(frameworks: &[Framework]) -> BTreeMap<MethodKey, ThreadingFacet> {
    let mut prog = program::ConventionProgram::default();
    for framework in frameworks {
        fact_loader::load_framework_facts(&mut prog, framework);
    }
    prog.run();
    tracing::info!(
        methods = prog.receiver_method.len(),
        attributes = prog.swift_attribute.len(),
        main_thread = prog.main_thread.len(),
        "convention threading facet derived"
    );
    readback::threading_facets(&prog)
}
