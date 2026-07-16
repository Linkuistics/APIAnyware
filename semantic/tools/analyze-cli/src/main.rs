//! CLI for the analysis pipeline: the in-process *resolve* flow that produces a
//! family's `resolved.kdl` from its `extracted.kdl` + `annotations.apiw`.
//!
//! Usage:
//!   apianyware-analyze                       # resolve all families
//!   apianyware-analyze --only Foundation     # one (or more) families
//!
//! The four phase-shaped, gitignored on-disk checkpoints (collected → resolved →
//! annotated → enriched) collapsed to the per-family spec triad (ADR-0046,
//! `pipeline-cutover-k20`): the machine `extracted.kdl` (written by collect) and
//! `resolved.kdl` (written here) bracket the one authored overlay
//! `annotations.apiw`. The datalog cross-reference pass — formerly the on-disk
//! `resolved` stage, whose name collided with the final `resolved.kdl` — is
//! renamed **`linked`**, and it, the annotate merge, and the enrichment pass all
//! run **in-process**, so only `extracted.kdl` and `resolved.kdl` touch disk.

use std::path::{Path, PathBuf};

use anyhow::{Context, Result};
use apianyware_types::annotation::FrameworkAnnotations;
use clap::{Args, Parser, Subcommand};

mod annotations;

#[derive(Parser)]
#[command(name = "apianyware-analyze")]
#[command(about = "Resolve the macOS API spec and run annotation side-channel workflows")]
#[command(
    long_about = "Resolve extracted.kdl + annotations.apiw -> resolved.kdl (the default \
                  when no subcommand is given), plus the LLM analysis side-channel workflows \
                  under `annotations` (ADR-0050)."
)]
struct Cli {
    #[command(subcommand)]
    command: Option<Command>,

    /// Resolve arguments for the default (no-subcommand) invocation.
    #[command(flatten)]
    resolve: ResolveArgs,
}

#[derive(Subcommand)]
enum Command {
    /// Resolve extracted.kdl + annotations.apiw -> resolved.kdl. This is the
    /// default behaviour when no subcommand is given; the explicit `resolve`
    /// form exists for clarity and discoverability.
    Resolve(ResolveArgs),

    /// LLM analysis side-channel workflows over the annotations.apiw overlay
    /// (staleness detection; disagreement/provenance audit; ADR-0050).
    Annotations(annotations::AnnotationsArgs),
}

/// Arguments for the resolve flow (the default / `resolve` subcommand).
#[derive(Args)]
struct ResolveArgs {
    /// `api/` root holding the per-family spec triad
    /// (`<api-root>/<Framework>/{extracted.kdl,annotations.apiw,resolved.kdl}`).
    #[arg(long, default_value = "platforms/macos/api")]
    api_root: PathBuf,

    /// Directory of authored pattern-kind definitions
    /// (`semantic/pattern-kinds/*.apiw`) the convention-tier detector binds and
    /// validates instances against (ADR-0048).
    #[arg(long, default_value = "semantic/pattern-kinds")]
    pattern_kinds_dir: PathBuf,

    /// Process only specific framework(s) (comma-separated or repeated).
    #[arg(long, value_delimiter = ',')]
    only: Vec<String>,
}

fn main() -> Result<()> {
    // Diagnostics to stderr so command stdout stays a clean data channel — in
    // particular `annotations stale --json` must emit parseable JSON, never
    // interleaved log lines ([[cli-tool-design]]).
    tracing_subscriber::fmt()
        .with_writer(std::io::stderr)
        .with_env_filter(
            tracing_subscriber::EnvFilter::try_from_default_env()
                .unwrap_or_else(|_| tracing_subscriber::EnvFilter::new("info")),
        )
        .init();

    let cli = Cli::parse();
    match cli.command {
        None => run_resolve(&cli.resolve),
        Some(Command::Resolve(args)) => run_resolve(&args),
        Some(Command::Annotations(args)) => annotations::run(args),
    }
}

/// Drive the resolve flow from its parsed arguments.
fn run_resolve(args: &ResolveArgs) -> Result<()> {
    let only = if args.only.is_empty() {
        None
    } else {
        Some(args.only.as_slice())
    };
    run_pipeline(&args.api_root, &args.pattern_kinds_dir, only)
}

/// The full in-process resolve. Loads `extracted.kdl` per family, runs the
/// datalog `linked` pass (pass 1: inheritance resolution, effective methods,
/// ownership families), merges the authored `annotations.apiw` overlay applying
/// §28 precedence (`manual > extraction > accepted-LLM > convention`), runs the
/// enrichment pass (pass 2: annotation-derived relations + verification), and
/// writes `resolved.kdl` per family — the generator input.
fn run_pipeline(api_root: &Path, pattern_kinds_dir: &Path, only: Option<&[String]>) -> Result<()> {
    let extracted =
        apianyware_datalog::loading::load_all_family_artifacts(api_root, "extracted.kdl", only)?;
    if extracted.is_empty() {
        anyhow::bail!(
            "no extracted.kdl found under {} (run `apianyware-collect` first)",
            api_root.display()
        );
    }
    tracing::info!(count = extracted.len(), "loaded extracted IR");

    // The authored pattern-kind registry: the convention-tier detector binds and
    // validates its instances against it (ADR-0048). Loaded once for the run.
    let pattern_kinds = apianyware_patterns::PatternKindRegistry::load_dir(pattern_kinds_dir)
        .with_context(|| {
            format!(
                "failed to load pattern-kinds from {}",
                pattern_kinds_dir.display()
            )
        })?;
    tracing::info!(kinds = pattern_kinds.len(), "loaded pattern-kind registry");

    // Pass 1 — `linked`: all families share one Datalog program so cross-framework
    // inheritance (e.g. AppKit classes inheriting Foundation) resolves.
    let linked = apianyware_resolve::resolve_loaded_frameworks(&extracted)?;
    tracing::info!(frameworks = linked.len(), "linked");

    // Merge each family's authored overlay (heuristics + accepted-LLM facts; LLM
    // precedence on conflict). A family with no `annotations.apiw` is heuristics-only.
    // Then run the convention-tier pattern detector, populating the first-class
    // `patterns` carriage (ADR-0048) with `source=convention` instances.
    let mut annotated = Vec::with_capacity(linked.len());
    for fw in &linked {
        let overlay = load_overlay(api_root, &fw.name)?;
        let mut result = apianyware_annotate::annotate_framework(fw, overlay.as_ref());
        result.patterns =
            apianyware_pattern_detection::detect_pattern_instances(&result, &pattern_kinds);
        annotated.push(result);
    }
    tracing::info!(frameworks = annotated.len(), "annotated");

    // Pass 2 — enrichment + verification → the resolved graph.
    let resolved = apianyware_enrich::enrich_loaded_frameworks(&annotated)?;

    for fw in &resolved {
        let path = api_root.join(&fw.name).join("resolved.kdl");
        apianyware_spec_format::machine::write_framework(fw, &path)
            .with_context(|| format!("failed to write {}", path.display()))?;
        let annotation_count: usize = fw.class_annotations.iter().map(|c| c.methods.len()).sum();
        tracing::info!(
            framework = %fw.name,
            classes = fw.classes.len(),
            method_annotations = annotation_count,
            output = %path.display(),
            "wrote resolved.kdl"
        );
    }

    tracing::info!(frameworks = resolved.len(), "resolution complete");
    Ok(())
}

/// Load a family's authored overlay (`<api_root>/<Framework>/annotations.apiw`),
/// or `None` if the family carries no overlay. Shared with the `annotations`
/// subcommands (e.g. `stale`).
pub(crate) fn load_overlay(
    api_root: &Path,
    framework: &str,
) -> Result<Option<FrameworkAnnotations>> {
    let path = api_root.join(framework).join("annotations.apiw");
    if !path.exists() {
        return Ok(None);
    }
    let text = std::fs::read_to_string(&path)
        .with_context(|| format!("failed to read {}", path.display()))?;
    let overlay = apianyware_spec_format::apiw::parse_apiw(&path.to_string_lossy(), &text)
        .with_context(|| format!("failed to parse {}", path.display()))?;
    let method_count: usize = overlay.classes.iter().map(|c| c.methods.len()).sum();
    tracing::info!(
        framework,
        classes = overlay.classes.len(),
        methods = method_count,
        "loaded authored overlay"
    );
    Ok(Some(overlay))
}
