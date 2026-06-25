//! `apianyware-analyze annotations audit` — the resolve-time disagreement /
//! precedence report (ADR-0050 §3 / ws5 `disagreement-report-k47`).
//!
//! A **pure read** over each family's `resolved.json` `fact_provenance` carriage
//! (landed by `precedence-audit-k45`): no resolve pass, no overlay re-derivation
//! beyond loading `resolved.json`. Per family it reports, from the per-fact-slot
//! [`MethodFactProvenance`]:
//! - **disagreements** — every fact-slot whose winner superseded ≥1 *disagreeing*
//!   lower tier (`superseded_by` non-empty): the winning `{source, value}` plus
//!   each loser `{source, value}`. These are the high-value review targets.
//! - **win distribution** — how many producing slots each §28 tier won
//!   (`manual` / `llm` / `convention` / `extraction` / `unknown`).
//!
//! Redundancy is reported the only way the carriage faithfully supports it
//! (`disagreement-report-k47`, user-confirmed pin). k45's audit records only
//! *disagreeing* losers — when a lower tier **agrees** with the winner it is
//! redundant and dropped (ADR-0050 §3). So `resolved.json` cannot distinguish
//! "LLM won, convention agreed (redundant)" from "LLM won, convention silent":
//! both are an `llm`-won slot with an empty `superseded_by`. The audit therefore
//! reports the two carriage-derivable signals and is explicit about the gap:
//! - **convention-won** — slots `convention` won outright (no higher tier
//!   produced): convention sufficed, the LLM annotation was unneeded. The
//!   strongest carriage-faithful "redundancy" signal.
//! - **uncontested-llm** — `llm`-won slots with no disagreement. This bucket
//!   *conflates* LLM-original facts with LLM facts that merely reproduce
//!   convention; separating them would need agreeing-tier carriage k45 does not
//!   keep (a future k45 extension or a resolve-pass re-derivation — out of scope
//!   for this read-only report).
//!
//! `audit` is **informational** — it always exits 0 (ADR-0050 §4 reserves the
//! gating exit code for `stale`). The `stale` sibling reads the resolved surface
//! vs the overlay; `audit` reads the resolved-only `fact_provenance` — orthogonal
//! inputs, shared subcommand group.

use std::path::PathBuf;

use anyhow::{Context, Result};
use apianyware_types::annotation::{
    AnnotationSource, MethodAnnotation, SlotProvenance, SupersededFact,
};
use apianyware_types::ir::Framework;
use clap::Args;
use serde::Serialize;

const EXAMPLES: &str = "\
EXAMPLES:
  # Disagreement + provenance report across every family
  apianyware-analyze annotations audit

  # One family, machine-readable
  apianyware-analyze annotations audit --only Foundation --json

PRECONDITION:
  Reads each family's resolved.json fact_provenance carriage (written by the
  resolve-time precedence audit). Regenerate it first with a plain
  `apianyware-analyze` (resolve) run after an SDK bump / annotation change.

EXIT CODES:
  0  always (audit is informational, never a gate)
  2  usage error";

/// `annotations audit` arguments.
#[derive(Args)]
#[command(after_help = EXAMPLES)]
pub struct AuditArgs {
    /// `api/` root holding the per-family spec triad
    /// (`<api-root>/<Framework>/{extracted.json,annotations.apiw,resolved.json}`).
    #[arg(long, default_value = "platforms/macos/api")]
    pub api_root: PathBuf,

    /// Restrict to specific framework(s) (comma-separated or repeated).
    #[arg(long, value_delimiter = ',')]
    pub only: Vec<String>,

    /// Emit a stable-schema JSON report on stdout instead of human-readable text.
    #[arg(long)]
    pub json: bool,
}

/// Which fact-slot a [`SlotProvenance`] belongs to — determined by *which*
/// [`MethodFactProvenance`] field carries it, not stored on the slot itself.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum SlotKind {
    Ownership,
    Block,
    Threading,
    Error,
}

impl SlotKind {
    /// Stable report token.
    fn label(self) -> &'static str {
        match self {
            SlotKind::Ownership => "ownership",
            SlotKind::Block => "block",
            SlotKind::Threading => "threading",
            SlotKind::Error => "error",
        }
    }
}

/// Per-§28-tier win counts over a family's producing fact-slots.
#[derive(Debug, Clone, Default, Serialize, PartialEq, Eq)]
pub struct TierWins {
    pub manual: usize,
    pub llm: usize,
    pub convention: usize,
    pub extraction: usize,
    pub unknown: usize,
}

impl TierWins {
    fn record(&mut self, source: AnnotationSource) {
        match source {
            AnnotationSource::Manual => self.manual += 1,
            AnnotationSource::Llm => self.llm += 1,
            AnnotationSource::Convention => self.convention += 1,
            AnnotationSource::Extraction => self.extraction += 1,
            AnnotationSource::Unknown => self.unknown += 1,
        }
    }

    fn merge(&mut self, other: &TierWins) {
        self.manual += other.manual;
        self.llm += other.llm;
        self.convention += other.convention;
        self.extraction += other.extraction;
        self.unknown += other.unknown;
    }

    /// Total producing slots (every win is one producing slot).
    pub fn total(&self) -> usize {
        self.manual + self.llm + self.convention + self.extraction + self.unknown
    }
}

/// One disagreeing fact-slot: the winner and the disagreeing losers it superseded.
#[derive(Debug, Clone, Serialize, PartialEq, Eq)]
pub struct Disagreement {
    /// Receiver (class or protocol) the method keys on.
    pub class: String,
    /// Method selector.
    pub selector: String,
    /// Instance method (`true`) vs class method (`false`).
    pub is_instance: bool,
    /// Fact-slot kind: `ownership` / `block` / `threading` / `error`.
    pub slot: &'static str,
    /// `param_index` for per-parameter slots (ownership / block); absent for the
    /// method-level scalar slots (threading / error).
    #[serde(skip_serializing_if = "Option::is_none")]
    pub param_index: Option<usize>,
    /// The §28 tier that won the slot.
    pub winner: AnnotationSource,
    /// The winning value rendered to its serde token (e.g. `"async_copied"`).
    pub winner_value: String,
    /// `convention:<rule>` stamp(s) backing a `convention` win; empty otherwise.
    #[serde(skip_serializing_if = "Vec::is_empty")]
    pub rules: Vec<String>,
    /// Each disagreeing loser: its tier + rendered value (ADR-0050 §3).
    pub superseded_by: Vec<SupersededFact>,
}

/// A family's audit result: win distribution + the disagreeing slots. Pure data
/// (the carriage-faithful redundancy framing is derived at report time).
#[derive(Debug, Clone, Serialize, PartialEq, Eq)]
pub struct FamilyAudit {
    pub family: String,
    pub wins: TierWins,
    pub disagreements: Vec<Disagreement>,
}

impl FamilyAudit {
    /// Producing fact-slots (one per win).
    pub fn producing_slots(&self) -> usize {
        self.wins.total()
    }

    /// `convention`-won slots: convention sufficed, the LLM annotation was
    /// unneeded — the strongest carriage-faithful redundancy signal.
    pub fn convention_won(&self) -> usize {
        self.wins.convention
    }

    /// `llm`-won slots with no recorded disagreement. Conflates LLM-original with
    /// convention-agreed facts (k45 drops agreeing tiers; ADR-0050 §3).
    pub fn uncontested_llm(&self) -> usize {
        let llm_disagreements = self
            .disagreements
            .iter()
            .filter(|d| d.winner == AnnotationSource::Llm)
            .count();
        self.wins.llm.saturating_sub(llm_disagreements)
    }
}

/// Render a fact value to its serde token (e.g. `Strong` → `"strong"`), matching
/// how the audit rendered the [`SupersededFact`] losers, so winner and loser
/// values are spelled identically.
fn token<T: Serialize>(value: &T) -> String {
    serde_json::to_value(value)
        .ok()
        .and_then(|v| v.as_str().map(str::to_string))
        .unwrap_or_default()
}

/// The winning value for a slot, read back from the resolved fact in `method`
/// (the carriage stamps provenance beside, not in, the fact). Empty when the
/// fact is unexpectedly absent (a malformed carriage; never in practice).
fn winner_value(method: &MethodAnnotation, kind: SlotKind, param_index: Option<usize>) -> String {
    match kind {
        SlotKind::Ownership => method
            .parameter_ownership
            .iter()
            .find(|p| Some(p.param_index) == param_index)
            .map(|p| token(&p.ownership))
            .unwrap_or_default(),
        SlotKind::Block => method
            .block_parameters
            .iter()
            .find(|b| Some(b.param_index) == param_index)
            .map(|b| token(&b.invocation))
            .unwrap_or_default(),
        SlotKind::Threading => method.threading.as_ref().map(token).unwrap_or_default(),
        SlotKind::Error => method.error_pattern.as_ref().map(token).unwrap_or_default(),
    }
}

/// Audit one family from its resolved `class_annotations`. Pure — no I/O — so it
/// is unit-testable against hand-built fixtures.
pub fn compute_audit(framework: &Framework) -> FamilyAudit {
    let mut wins = TierWins::default();
    let mut disagreements = Vec::new();

    for class in &framework.class_annotations {
        for method in &class.methods {
            let Some(prov) = &method.fact_provenance else {
                continue;
            };
            record_group(
                &class.class_name,
                method,
                SlotKind::Ownership,
                &prov.parameter_ownership,
                &mut wins,
                &mut disagreements,
            );
            record_group(
                &class.class_name,
                method,
                SlotKind::Block,
                &prov.block_parameters,
                &mut wins,
                &mut disagreements,
            );
            for slot in prov.threading.iter() {
                record_slot(
                    &class.class_name,
                    method,
                    SlotKind::Threading,
                    slot,
                    &mut wins,
                    &mut disagreements,
                );
            }
            for slot in prov.error_pattern.iter() {
                record_slot(
                    &class.class_name,
                    method,
                    SlotKind::Error,
                    slot,
                    &mut wins,
                    &mut disagreements,
                );
            }
        }
    }

    sort_disagreements(&mut disagreements);
    FamilyAudit {
        family: framework.name.clone(),
        wins,
        disagreements,
    }
}

fn record_group(
    class: &str,
    method: &MethodAnnotation,
    kind: SlotKind,
    slots: &[SlotProvenance],
    wins: &mut TierWins,
    out: &mut Vec<Disagreement>,
) {
    for slot in slots {
        record_slot(class, method, kind, slot, wins, out);
    }
}

fn record_slot(
    class: &str,
    method: &MethodAnnotation,
    kind: SlotKind,
    slot: &SlotProvenance,
    wins: &mut TierWins,
    out: &mut Vec<Disagreement>,
) {
    wins.record(slot.source);
    if slot.superseded_by.is_empty() {
        return;
    }
    out.push(Disagreement {
        class: class.to_string(),
        selector: method.selector.clone(),
        is_instance: method.is_instance,
        slot: kind.label(),
        param_index: slot.param_index,
        winner: slot.source,
        winner_value: winner_value(method, kind, slot.param_index),
        rules: slot.rules.clone(),
        superseded_by: slot.superseded_by.clone(),
    });
}

fn sort_disagreements(disagreements: &mut [Disagreement]) {
    disagreements.sort_by(|a, b| {
        (
            a.class.as_str(),
            a.selector.as_str(),
            a.is_instance,
            a.slot,
            a.param_index,
        )
            .cmp(&(
                b.class.as_str(),
                b.selector.as_str(),
                b.is_instance,
                b.slot,
                b.param_index,
            ))
    });
}

/// Run the `audit` command: load each family's `resolved.json`, audit its
/// `fact_provenance`, and print the report. Always `Ok(())` — informational.
pub fn run(args: &AuditArgs) -> Result<()> {
    let only = if args.only.is_empty() {
        None
    } else {
        Some(args.only.as_slice())
    };

    let resolved = apianyware_datalog::loading::load_all_family_artifacts(
        &args.api_root,
        "resolved.json",
        only,
    )?;
    if resolved.is_empty() {
        anyhow::bail!(
            "no resolved.json found under {} — run `apianyware-analyze` (resolve) first to \
             generate the resolved surface",
            args.api_root.display()
        );
    }

    let mut audits: Vec<FamilyAudit> = resolved.iter().map(compute_audit).collect();
    audits.sort_by(|a, b| a.family.cmp(&b.family));

    if args.json {
        print_json(&audits)?;
    } else {
        print_human(&audits);
    }
    Ok(())
}

/// The carriage caveat, surfaced in the JSON so a machine consumer sees why
/// `uncontested_llm` is not a true LLM-vs-convention redundancy count.
const REDUNDANCY_NOTE: &str = "uncontested_llm conflates LLM-original facts with LLM facts that \
    reproduce convention: the resolve-time audit drops agreeing lower tiers (ADR-0050 §3), so \
    true LLM-vs-convention redundancy is not derivable from resolved.json. convention_won is the \
    carriage-faithful 'convention sufficed' signal.";

/// Stable JSON report. Lists every family with producing slots; `wins` and
/// `disagreement_slots` are grand totals.
#[derive(Serialize)]
struct AuditReport<'a> {
    total_families: usize,
    producing_slots: usize,
    wins: TierWins,
    disagreement_slots: usize,
    disagreement_families: Vec<&'a str>,
    redundancy_note: &'static str,
    families: Vec<FamilyReport<'a>>,
}

/// Per-family JSON record with the carriage-faithful redundancy framing inlined
/// (so a consumer never has to recompute it).
#[derive(Serialize)]
struct FamilyReport<'a> {
    family: &'a str,
    producing_slots: usize,
    wins: &'a TierWins,
    disagreement_slots: usize,
    convention_won: usize,
    uncontested_llm: usize,
    disagreements: &'a [Disagreement],
}

fn family_report(audit: &FamilyAudit) -> FamilyReport<'_> {
    FamilyReport {
        family: &audit.family,
        producing_slots: audit.producing_slots(),
        wins: &audit.wins,
        disagreement_slots: audit.disagreements.len(),
        convention_won: audit.convention_won(),
        uncontested_llm: audit.uncontested_llm(),
        disagreements: &audit.disagreements,
    }
}

fn print_json(audits: &[FamilyAudit]) -> Result<()> {
    let mut wins = TierWins::default();
    let mut disagreement_slots = 0;
    let mut disagreement_families = Vec::new();
    for a in audits {
        wins.merge(&a.wins);
        disagreement_slots += a.disagreements.len();
        if !a.disagreements.is_empty() {
            disagreement_families.push(a.family.as_str());
        }
    }
    let report = AuditReport {
        total_families: audits.len(),
        producing_slots: wins.total(),
        wins,
        disagreement_slots,
        disagreement_families,
        redundancy_note: REDUNDANCY_NOTE,
        families: audits.iter().map(family_report).collect(),
    };
    let json = serde_json::to_string_pretty(&report).context("failed to serialize audit report")?;
    println!("{json}");
    Ok(())
}

/// How many disagreement slots to list per family before truncating.
const SAMPLE_LIMIT: usize = 8;

fn print_human(audits: &[FamilyAudit]) {
    let producing: Vec<&FamilyAudit> = audits.iter().filter(|a| a.producing_slots() > 0).collect();
    if producing.is_empty() {
        println!(
            "no annotation provenance found across {} families — run `apianyware-analyze` \
             (resolve) first to write the fact_provenance carriage",
            audits.len()
        );
        return;
    }

    let mut totals = TierWins::default();
    let mut disagreement_slots = 0;
    let mut disagreement_families = 0;
    for a in &producing {
        totals.merge(&a.wins);
        disagreement_slots += a.disagreements.len();
        if !a.disagreements.is_empty() {
            disagreement_families += 1;
        }

        println!(
            "{}: {} producing slots ({}); {} disagreements",
            a.family,
            a.producing_slots(),
            render_wins(&a.wins),
            a.disagreements.len(),
        );
        for d in a.disagreements.iter().take(SAMPLE_LIMIT) {
            print_disagreement(d);
        }
        if a.disagreements.len() > SAMPLE_LIMIT {
            println!(
                "    disagreement: ... and {} more",
                a.disagreements.len() - SAMPLE_LIMIT
            );
        }
        println!(
            "    redundancy: {} convention-won (LLM not needed); {} uncontested LLM (cannot \
             split original vs convention-agreed — k45 drops agreement)",
            a.convention_won(),
            a.uncontested_llm(),
        );
    }

    println!();
    println!(
        "audit: {} families, {} producing slots ({}); {} disagreements across {} families",
        producing.len(),
        totals.total(),
        render_wins(&totals),
        disagreement_slots,
        disagreement_families,
    );
    println!("note: {REDUNDANCY_NOTE}");
}

/// Compact non-zero tier breakdown, e.g. `llm 425, convention 327`.
fn render_wins(wins: &TierWins) -> String {
    let parts = [
        ("manual", wins.manual),
        ("llm", wins.llm),
        ("convention", wins.convention),
        ("extraction", wins.extraction),
        ("unknown", wins.unknown),
    ];
    let rendered: Vec<String> = parts
        .iter()
        .filter(|(_, n)| *n > 0)
        .map(|(label, n)| format!("{label} {n}"))
        .collect();
    if rendered.is_empty() {
        "none".to_string()
    } else {
        rendered.join(", ")
    }
}

fn print_disagreement(d: &Disagreement) {
    let kind = if d.is_instance { "-" } else { "+" };
    let slot = match d.param_index {
        Some(i) => format!("{}[{i}]", d.slot),
        None => d.slot.to_string(),
    };
    let losers: Vec<String> = d
        .superseded_by
        .iter()
        .map(|s| format!("{}={}", token(&s.source), s.value))
        .collect();
    println!(
        "    disagreement: {kind}[{}] {} {slot} {}={} superseded-by {}",
        d.class,
        d.selector,
        token(&d.winner),
        d.winner_value,
        losers.join(", "),
    );
}

#[cfg(test)]
mod tests {
    use super::*;
    use apianyware_types::annotation::{
        BlockInvocationStyle, BlockParamAnnotation, ClassAnnotations, MethodAnnotation,
        MethodFactProvenance, OwnershipKind, ParamOwnership, ThreadingConstraint,
    };

    /// A resolved method annotation carrying the given fact-provenance.
    fn method(selector: &str, prov: MethodFactProvenance) -> MethodAnnotation {
        MethodAnnotation {
            selector: selector.to_string(),
            is_instance: true,
            parameter_ownership: vec![],
            block_parameters: vec![],
            threading: None,
            error_pattern: None,
            source: AnnotationSource::Llm,
            confidence: None,
            provenance: None,
            fact_provenance: Some(prov),
        }
    }

    fn framework(name: &str, classes: Vec<ClassAnnotations>) -> Framework {
        Framework {
            format_version: "1.0".to_string(),
            checkpoint: "resolved".to_string(),
            name: name.to_string(),
            sdk_version: None,
            collected_at: None,
            depends_on: vec![],
            skipped_symbols: vec![],
            classes: vec![],
            protocols: vec![],
            enums: vec![],
            structs: vec![],
            functions: vec![],
            constants: vec![],
            class_annotations: classes,
            patterns: vec![],
            enrichment: None,
            verification: None,
        }
    }

    fn class(name: &str, methods: Vec<MethodAnnotation>) -> ClassAnnotations {
        ClassAnnotations {
            class_name: name.to_string(),
            methods,
        }
    }

    fn slot(source: AnnotationSource, superseded_by: Vec<SupersededFact>) -> SlotProvenance {
        SlotProvenance {
            param_index: None,
            source,
            rules: vec![],
            superseded_by,
        }
    }

    #[test]
    fn wins_are_counted_by_tier() {
        // Two slots: a threading slot won by convention, an error slot won by llm.
        let mut m = method(
            "doThing",
            MethodFactProvenance {
                threading: Some(slot(AnnotationSource::Convention, vec![])),
                error_pattern: Some(slot(AnnotationSource::Llm, vec![])),
                ..Default::default()
            },
        );
        m.threading = Some(ThreadingConstraint::MainThreadOnly);
        m.error_pattern = Some(apianyware_types::annotation::ErrorPattern::ErrorOutParam);

        let fw = framework("TestFW", vec![class("NSThing", vec![m])]);
        let a = compute_audit(&fw);
        assert_eq!(a.wins.convention, 1);
        assert_eq!(a.wins.llm, 1);
        assert_eq!(a.producing_slots(), 2);
        assert!(a.disagreements.is_empty(), "{a:?}");
    }

    #[test]
    fn agreeing_slot_has_no_disagreement_and_is_uncontested() {
        // An llm-won slot with empty superseded_by → counted as a win, no
        // disagreement, and folded into the uncontested-llm bucket (the carriage
        // cannot tell this from a convention-agreed slot — the whole point).
        let mut m = method(
            "doThing",
            MethodFactProvenance {
                threading: Some(slot(AnnotationSource::Llm, vec![])),
                ..Default::default()
            },
        );
        m.threading = Some(ThreadingConstraint::AnyThread);

        let fw = framework("TestFW", vec![class("NSThing", vec![m])]);
        let a = compute_audit(&fw);
        assert!(a.disagreements.is_empty());
        assert_eq!(a.uncontested_llm(), 1);
        assert_eq!(a.convention_won(), 0);
    }

    #[test]
    fn disagreeing_slot_records_winner_value_and_losers() {
        // A block slot at param 2: llm winner (async_copied) supersedes a
        // disagreeing convention loser (synchronous).
        let mut prov = MethodFactProvenance::default();
        prov.block_parameters.push(SlotProvenance {
            param_index: Some(2),
            source: AnnotationSource::Llm,
            rules: vec![],
            superseded_by: vec![SupersededFact {
                source: AnnotationSource::Convention,
                value: "synchronous".to_string(),
            }],
        });
        let mut m = method("enumerate:opts:test:", prov);
        m.block_parameters = vec![BlockParamAnnotation {
            param_index: 2,
            invocation: BlockInvocationStyle::AsyncCopied,
        }];

        let fw = framework("TestFW", vec![class("NSArray", vec![m])]);
        let a = compute_audit(&fw);
        assert_eq!(a.disagreements.len(), 1);
        let d = &a.disagreements[0];
        assert_eq!(d.slot, "block");
        assert_eq!(d.param_index, Some(2));
        assert_eq!(d.winner, AnnotationSource::Llm);
        assert_eq!(d.winner_value, "async_copied");
        assert_eq!(d.superseded_by.len(), 1);
        assert_eq!(d.superseded_by[0].value, "synchronous");
        // The disagreeing llm win is NOT uncontested.
        assert_eq!(a.uncontested_llm(), 0);
    }

    #[test]
    fn convention_win_carries_rules_and_renders_ownership_value() {
        // A convention-won ownership slot at param 0 that supersedes a disagreeing
        // llm loser; the winning ownership value renders from the fact, and the
        // convention rule rides along.
        let mut prov = MethodFactProvenance::default();
        prov.parameter_ownership.push(SlotProvenance {
            param_index: Some(0),
            source: AnnotationSource::Convention,
            rules: vec!["convention:delegate-weak".to_string()],
            superseded_by: vec![SupersededFact {
                source: AnnotationSource::Llm,
                value: "strong".to_string(),
            }],
        });
        let mut m = method("setDelegate:", prov);
        m.parameter_ownership = vec![ParamOwnership {
            param_index: 0,
            ownership: OwnershipKind::Weak,
        }];

        let fw = framework("TestFW", vec![class("NSThing", vec![m])]);
        let a = compute_audit(&fw);
        assert_eq!(a.convention_won(), 1);
        let d = &a.disagreements[0];
        assert_eq!(d.slot, "ownership");
        assert_eq!(d.winner, AnnotationSource::Convention);
        assert_eq!(d.winner_value, "weak");
        assert_eq!(d.rules, vec!["convention:delegate-weak".to_string()]);
        assert_eq!(d.superseded_by[0].source, AnnotationSource::Llm);
    }

    #[test]
    fn method_without_provenance_is_ignored() {
        let m = MethodAnnotation {
            selector: "plain".to_string(),
            is_instance: true,
            parameter_ownership: vec![],
            block_parameters: vec![],
            threading: None,
            error_pattern: None,
            source: AnnotationSource::Unknown,
            confidence: None,
            provenance: None,
            fact_provenance: None,
        };
        let fw = framework("TestFW", vec![class("NSThing", vec![m])]);
        let a = compute_audit(&fw);
        assert_eq!(a.producing_slots(), 0);
        assert!(a.disagreements.is_empty());
    }

    #[test]
    fn disagreements_are_sorted_deterministically() {
        let mk = |sel: &str| {
            let mut prov = MethodFactProvenance::default();
            prov.threading = Some(SlotProvenance {
                param_index: None,
                source: AnnotationSource::Llm,
                rules: vec![],
                superseded_by: vec![SupersededFact {
                    source: AnnotationSource::Convention,
                    value: "any_thread".to_string(),
                }],
            });
            let mut m = method(sel, prov);
            m.threading = Some(ThreadingConstraint::MainThreadOnly);
            m
        };
        // Insert out of order; expect selector-sorted output.
        let fw = framework(
            "TestFW",
            vec![class(
                "NSThing",
                vec![mk("zebra"), mk("alpha"), mk("mango")],
            )],
        );
        let a = compute_audit(&fw);
        let selectors: Vec<&str> = a
            .disagreements
            .iter()
            .map(|d| d.selector.as_str())
            .collect();
        assert_eq!(selectors, vec!["alpha", "mango", "zebra"]);
    }
}
