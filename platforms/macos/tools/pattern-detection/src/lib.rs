//! Convention-tier **pattern-instance detection** (ADR-0048 D3, ADR-0047).
//!
//! The cheap structural producer of first-class pattern-*instances*: the
//! (retired) imperative `annotate/pattern_detection.rs` heuristics re-expressed as
//! declarative `ascent` datalog rules over a per-framework fact base. It is the
//! first real *producer* of the carriage workstream-3 child 2 shipped
//! ([`apianyware_types::pattern_instance`]) — patterns become live for the real
//! corpus, stamped `source=convention` with a `convention:<rule>` provenance that
//! falls out of the derivation trace (the `apianyware-conventions` precedent).
//!
//! Pattern detection is **Cocoa-specific knowledge**, so it lives here in
//! `platforms/macos/tools/` beside `apianyware-conventions` (ADR-0047), *not* in
//! the shared `semantic/tools/datalog` engine. The authored kind *definitions*
//! and the *registry* it validates against live in `apianyware-patterns`
//! (`semantic/tools/patterns`); this crate is the platform-side detection that
//! binds those kinds to concrete framework participants.
//!
//! The concerns, one per module:
//!
//! - [`program`] — the `ascent!` rules: the five detectors (factory-cluster,
//!   observer, paired-state, delegate, bracket) deriving rule-stamped structural
//!   tuples.
//! - [`fact_loader`] — load a linked IR [`Framework`] into the program's base facts.
//! - [`readback`] — assemble the tuples into typed, content-id'd, home-resolved,
//!   **registry-validated** [`PatternInstance`]s.

pub mod fact_loader;
pub mod program;
pub mod readback;

use apianyware_patterns::PatternKindRegistry;
use apianyware_types::ir::Framework;
use apianyware_types::pattern_instance::PatternInstance;

/// Detect every convention-tier pattern-instance in one framework, validated
/// against the authored kind `registry`.
///
/// Loads the framework's structural facts, runs the datalog detectors to
/// fixpoint, and assembles the derived tuples into well-formed
/// [`PatternInstance`]s (each `source=convention`, `convention:<rule>`-stamped,
/// DP4 content-id'd, DP3 home-resolved). Returns them in a stable content-id
/// order; the caller assigns them to [`Framework::patterns`]. Run per framework
/// (clusters, observer pairs, delegate protocols and brackets never cross a
/// framework boundary), so every instance homes to `framework.name`.
pub fn detect_pattern_instances(
    framework: &Framework,
    registry: &PatternKindRegistry,
) -> Vec<PatternInstance> {
    let mut prog = program::PatternProgram::default();
    fact_loader::load_framework_facts(&mut prog, framework);
    prog.run();
    readback::assemble(&prog, &framework.name, registry)
}
