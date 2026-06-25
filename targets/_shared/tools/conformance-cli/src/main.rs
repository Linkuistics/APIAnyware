//! CLI: `apianyware-conformance` — render the REFACTOR §37 conformance report for one or more
//! live targets, combining the **authored judgment** slice
//! (`targets/<id>/conformance/macos.apiw`) with the **derived** slice and cross-checking the
//! two.
//!
//! This is the ws6 consumer that *wires together the two domains* the model deliberately keeps
//! apart (ADR-0051 §5): it loads the targets-domain capability + conformance registries AND the
//! platforms-domain api-semantics registry, feeds each API's §30 weirdness through the
//! `apianyware-target-model` representability floor to derive a §37 coverage histogram, scans
//! each target's shipped apps for the common app-implementation status, and reconciles the
//! authored claims against that derived reality. The crate libraries stay domain-pure; this
//! *application* is allowed to bridge.
//!
//! Nothing here is committed: the derived slice is recomputed on every run (constraint 4).
//!
//! ## Usage
//!
//!   apianyware-conformance                      # §37 report for all four live targets (text)
//!   apianyware-conformance --target racket      # one target
//!   apianyware-conformance --json               # machine-readable, stable schema (one record per target)
//!   apianyware-conformance --check              # exit non-zero if any authored claim contradicts derived reality
//!
//! ## Exit codes
//!
//!   0  success — report rendered (and, under --check, no contradictions)
//!   1  a target failed to load/validate, or --check found contradictions
//!   2  usage error (bad flags) — emitted by the argument parser

use std::collections::BTreeMap;
use std::path::PathBuf;

use anyhow::{Context, Result};
use apianyware_platform_tests::ApiSemanticsRegistry;
use apianyware_target_model::{
    crosscheck, derive_app_statuses, representability_histogram, AppImplStatus, CapabilityRegistry,
    ConformanceRegistry, ConformanceReport, Contradiction, Representability,
};
use clap::Parser;
use serde::Serialize;

/// The four live targets, in canonical order (the default selection).
const LIVE_TARGETS: [&str; 4] = ["racket", "chez", "gerbil", "sbcl"];

/// The representability ladder, best → worst, for stable report ordering.
const LADDER: [Representability; 7] = [
    Representability::ExactStatic,
    Representability::ExactRuntime,
    Representability::IdiomaticConventional,
    Representability::LossyButDocumented,
    Representability::UnsafeOnly,
    Representability::NotRepresentable,
    Representability::Research,
];

#[derive(Parser)]
#[command(name = "apianyware-conformance")]
#[command(
    about = "Render the REFACTOR §37 conformance report (authored judgment + derived coverage/app-status) and cross-check the two",
    long_about = "Render the REFACTOR §37 conformance report for the live targets.\n\n\
        Each report combines the AUTHORED judgment slice (targets/<id>/conformance/macos.apiw — \
        the per-app-kind support call, unsupported features, research items, known issues) with \
        the DERIVED slice computed fresh on every run: the per-API representability coverage \
        (the capability profile floored against the platform's §30 weird-API surface) and the \
        common app-implementation status (the shipped app-implementations/ + their VM-verify \
        reports/). It then cross-checks the authored exemplar claims against that derived \
        reality.\n\n\
        EXAMPLES:\n\
        \x20 apianyware-conformance\n\
        \x20     §37 report for all four live targets, human-readable\n\
        \x20 apianyware-conformance --target racket --target sbcl\n\
        \x20     just those two targets\n\
        \x20 apianyware-conformance --json | jq '.reports[] | {target, contradictions}'\n\
        \x20     machine-readable; one stable record per target\n\
        \x20 apianyware-conformance --check\n\
        \x20     exit 1 if any authored claim contradicts the derived VM-verify reality (CI gate)\n\n\
        EXIT CODES: 0 success · 1 load/validate error or --check contradictions · 2 usage error"
)]
struct Cli {
    /// Target id(s) to report on (comma-separated or repeated). Default: all four live targets.
    #[arg(long, value_delimiter = ',')]
    target: Vec<String>,

    /// The `targets/` tree root (holds `<id>/conformance/macos.apiw`, `<id>/capability.apiw`,
    /// and each target's `app-implementations/` + `bindings/<platform>/reports/`).
    #[arg(long, default_value = "targets")]
    targets_dir: PathBuf,

    /// The platform api-semantics directory (the §30 weirdness the coverage floor reads).
    #[arg(long, default_value = "platforms/macos/tests/api-semantics")]
    api_semantics_dir: PathBuf,

    /// Emit machine-readable JSON (one stable record per target) instead of text.
    #[arg(long)]
    json: bool,

    /// Exit non-zero if any authored claim contradicts the derived reality (a CI gate).
    #[arg(long)]
    check: bool,
}

// ───────────────────────── serializable report view (the --json schema) ─────────────────────
//
// The CLI owns its own output shape; the library model stays serde-free (the *machine* JSON
// Schema is ws8's, not this tool's). These view structs are populated from the library types.

#[derive(Serialize)]
struct Output {
    reports: Vec<TargetReport>,
    contradictions_total: usize,
}

#[derive(Serialize)]
struct TargetReport {
    target: String,
    platform: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    doc: Option<String>,
    app_support: Vec<AppSupportView>,
    unsupported: Vec<ItemView>,
    research: Vec<ItemView>,
    known_issues: Vec<ItemView>,
    /// Derived §37 coverage: count of declared weird APIs at each representability rung
    /// (best → worst). The vast non-weird surface is `exact-static` by construction and not
    /// counted here.
    coverage: Vec<CoverageBucket>,
    coverage_total: usize,
    /// Derived common app-implementation status (one record per shipped app).
    app_implementation_status: Vec<AppImplView>,
    /// Authored-vs-derived contradictions (empty when consistent).
    contradictions: Vec<ContradictionView>,
}

#[derive(Serialize)]
struct AppSupportView {
    app_kind: String,
    status: &'static str,
    #[serde(skip_serializing_if = "Option::is_none")]
    doc: Option<String>,
    exemplars: Vec<String>,
}

#[derive(Serialize)]
struct ItemView {
    name: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    doc: Option<String>,
}

#[derive(Serialize)]
struct CoverageBucket {
    rung: String,
    count: usize,
}

#[derive(Serialize)]
struct AppImplView {
    app: String,
    implemented: bool,
    vm_verified: bool,
    status: &'static str,
}

#[derive(Serialize)]
struct ContradictionView {
    app_kind: String,
    app: String,
    authored: &'static str,
    #[serde(skip_serializing_if = "Option::is_none")]
    derived: Option<&'static str>,
    message: String,
}

fn main() {
    let cli = Cli::parse();
    match run(&cli) {
        Ok(contradictions_total) => {
            // Under --check a contradiction is a failure; otherwise it is informational.
            if cli.check && contradictions_total > 0 {
                std::process::exit(1);
            }
        }
        Err(err) => {
            eprintln!("error: {err:#}");
            std::process::exit(1);
        }
    }
}

/// Build and emit the report(s); returns the total contradiction count across all targets.
fn run(cli: &Cli) -> Result<usize> {
    let conformance = ConformanceRegistry::load_dir(&cli.targets_dir).with_context(|| {
        format!(
            "loading conformance reports under {}",
            cli.targets_dir.display()
        )
    })?;
    let capabilities = CapabilityRegistry::load_dir(&cli.targets_dir).with_context(|| {
        format!(
            "loading capability profiles under {}",
            cli.targets_dir.display()
        )
    })?;
    let api_semantics =
        ApiSemanticsRegistry::load_dir(&cli.api_semantics_dir).with_context(|| {
            format!(
                "loading api-semantics under {}",
                cli.api_semantics_dir.display()
            )
        })?;

    // Flatten the platform's declared weird-API surface into one weirdness-list per API — the
    // input the representability floor histograms over.
    let weird_surface: Vec<Vec<String>> = api_semantics
        .all()
        .flat_map(|facet| facet.apis.iter().map(|api| api.weirdness.clone()))
        .collect();

    let selected = resolve_targets(cli, &conformance)?;

    let mut reports = Vec::new();
    let mut contradictions_total = 0;
    for id in &selected {
        let report = conformance
            .get(id)
            .with_context(|| format!("no authored conformance report for target `{id}`"))?;
        let profile = capabilities.get(id).with_context(|| {
            format!("no capability profile for target `{id}` (needed to derive coverage)")
        })?;

        let coverage = representability_histogram(profile, &weird_surface);
        let app_status = derive_app_statuses(&cli.targets_dir.join(id), &report.platform);
        let contradictions = crosscheck(report, &app_status);
        contradictions_total += contradictions.len();

        reports.push(build_view(report, &coverage, &app_status, &contradictions));
    }

    if cli.json {
        let output = Output {
            reports,
            contradictions_total,
        };
        println!(
            "{}",
            serde_json::to_string_pretty(&output).context("serializing report to JSON")?
        );
    } else {
        print_text(&reports, contradictions_total, cli.check);
    }

    Ok(contradictions_total)
}

/// Resolve the requested target ids, validating each is an authored target; default to the four
/// live targets (those actually present in the registry, in canonical order).
fn resolve_targets(cli: &Cli, conformance: &ConformanceRegistry) -> Result<Vec<String>> {
    if cli.target.is_empty() {
        return Ok(LIVE_TARGETS
            .iter()
            .filter(|id| conformance.get(id).is_some())
            .map(|id| id.to_string())
            .collect());
    }
    for id in &cli.target {
        anyhow::ensure!(
            conformance.get(id).is_some(),
            "unknown or unauthored target `{id}` (no targets/{id}/conformance/macos.apiw)"
        );
    }
    Ok(cli.target.clone())
}

/// Populate the serializable view for one target from the library types.
fn build_view(
    report: &ConformanceReport,
    coverage: &BTreeMap<Representability, usize>,
    app_status: &[AppImplStatus],
    contradictions: &[Contradiction],
) -> TargetReport {
    let coverage_buckets: Vec<CoverageBucket> = LADDER
        .iter()
        .map(|rung| CoverageBucket {
            rung: rung_token(*rung).to_string(),
            count: *coverage.get(rung).unwrap_or(&0),
        })
        .collect();
    let coverage_total = coverage_buckets.iter().map(|b| b.count).sum();

    TargetReport {
        target: report.id.clone(),
        platform: report.platform.clone(),
        doc: report.doc.clone(),
        app_support: report
            .app_support
            .iter()
            .map(|s| AppSupportView {
                app_kind: s.app_kind.clone(),
                status: s.status.as_str(),
                doc: s.doc.clone(),
                exemplars: s.exemplars.clone(),
            })
            .collect(),
        unsupported: items(&report.unsupported),
        research: items(&report.research),
        known_issues: items(&report.known_issues),
        coverage: coverage_buckets,
        coverage_total,
        app_implementation_status: app_status
            .iter()
            .map(|s| AppImplView {
                app: s.app.clone(),
                implemented: s.implemented,
                vm_verified: s.vm_verified,
                status: s.status.as_str(),
            })
            .collect(),
        contradictions: contradictions
            .iter()
            .map(|c| ContradictionView {
                app_kind: c.app_kind.clone(),
                app: c.app.clone(),
                authored: c.authored.as_str(),
                derived: c.derived.map(|d| d.as_str()),
                message: c.message.clone(),
            })
            .collect(),
    }
}

fn items(list: &[apianyware_target_model::JudgmentItem]) -> Vec<ItemView> {
    list.iter()
        .map(|i| ItemView {
            name: i.name.clone(),
            doc: i.doc.clone(),
        })
        .collect()
}

/// The `.apiw` token for a representability rung (its serde spelling).
fn rung_token(rung: Representability) -> &'static str {
    match rung {
        Representability::ExactStatic => "exact-static",
        Representability::ExactRuntime => "exact-runtime",
        Representability::IdiomaticConventional => "idiomatic-conventional",
        Representability::LossyButDocumented => "lossy-but-documented",
        Representability::UnsafeOnly => "unsafe-only",
        Representability::NotRepresentable => "not-representable",
        Representability::Research => "research",
    }
}

/// Render the human-readable §37 report.
fn print_text(reports: &[TargetReport], contradictions_total: usize, check: bool) {
    for r in reports {
        println!("═══ conformance · {} · {} ═══", r.target, r.platform);
        if let Some(doc) = &r.doc {
            println!("  {doc}");
        }

        println!("\n  §37 app-kind support (authored):");
        for s in &r.app_support {
            let exemplars = if s.exemplars.is_empty() {
                String::new()
            } else {
                format!("  [{}]", s.exemplars.join(", "))
            };
            println!("    {:<22} {}{}", s.app_kind, s.status, exemplars);
        }

        print_items("unsupported features", &r.unsupported);
        print_items("research items", &r.research);
        print_items("known issues", &r.known_issues);

        println!(
            "\n  §37 API representability coverage (derived, over {} declared weird APIs):",
            r.coverage_total
        );
        for b in &r.coverage {
            if b.count > 0 {
                println!("    {:<24} {}", b.rung, b.count);
            }
        }

        println!("\n  §37 common app-implementation status (derived):");
        for a in &r.app_implementation_status {
            let verify = if a.vm_verified {
                "VM-verified"
            } else {
                "not VM-verified"
            };
            println!("    {:<22} {}  ({verify})", a.app, a.status);
        }

        if r.contradictions.is_empty() {
            println!("\n  cross-check: authored judgment consistent with derived reality ✓");
        } else {
            println!(
                "\n  cross-check: {} CONTRADICTION(S):",
                r.contradictions.len()
            );
            for c in &r.contradictions {
                println!("    ✗ {}", c.message);
            }
        }
        println!();
    }

    if contradictions_total == 0 {
        println!("All targets: authored conformance consistent with derived reality.");
    } else {
        let gate = if check { " (--check → exit 1)" } else { "" };
        println!("Total contradictions across all targets: {contradictions_total}{gate}");
    }
}

fn print_items(label: &str, items: &[ItemView]) {
    if items.is_empty() {
        return;
    }
    println!("\n  §37 {label} (authored):");
    for i in items {
        match &i.doc {
            Some(doc) => println!("    {} — {doc}", i.name),
            None => println!("    {}", i.name),
        }
    }
}
