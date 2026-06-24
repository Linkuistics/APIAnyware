//! CLI for the analysis pipeline: the in-process *resolve* flow that produces a
//! family's `resolved.json` from its `extracted.json` + `annotations.apiw`.
//!
//! Usage:
//!   apianyware-analyze                       # resolve all families
//!   apianyware-analyze --only Foundation     # one (or more) families
//!
//! The four phase-shaped, gitignored on-disk checkpoints (collected → resolved →
//! annotated → enriched) collapsed to the per-family spec triad (ADR-0046,
//! `pipeline-cutover-k20`): the machine `extracted.json` (written by collect) and
//! `resolved.json` (written here) bracket the one authored overlay
//! `annotations.apiw`. The datalog cross-reference pass — formerly the on-disk
//! `resolved` stage, whose name collided with the final `resolved.json` — is
//! renamed **`linked`**, and it, the annotate merge, and the enrichment pass all
//! run **in-process**, so only `extracted.json` and `resolved.json` touch disk.

use std::path::{Path, PathBuf};

use anyhow::{Context, Result};
use apianyware_types::annotation::FrameworkAnnotations;
use clap::Parser;

#[derive(Parser)]
#[command(name = "apianyware-analyze")]
#[command(about = "Resolve the macOS API spec: extracted.json + annotations.apiw -> resolved.json")]
struct Cli {
    /// `api/` root holding the per-family spec triad
    /// (`<api-root>/<Framework>/{extracted.json,annotations.apiw,resolved.json}`).
    #[arg(long, default_value = "platforms/macos/api")]
    api_root: PathBuf,

    /// Process only specific framework(s) (comma-separated or repeated).
    #[arg(long, value_delimiter = ',')]
    only: Vec<String>,
}

fn main() -> Result<()> {
    tracing_subscriber::fmt()
        .with_env_filter(
            tracing_subscriber::EnvFilter::try_from_default_env()
                .unwrap_or_else(|_| tracing_subscriber::EnvFilter::new("info")),
        )
        .init();

    let cli = Cli::parse();
    let only = if cli.only.is_empty() {
        None
    } else {
        Some(cli.only.as_slice())
    };

    run_pipeline(&cli.api_root, only)
}

/// The full in-process resolve. Loads `extracted.json` per family, runs the
/// datalog `linked` pass (pass 1: inheritance resolution, effective methods,
/// ownership families), merges the authored `annotations.apiw` overlay applying
/// §28 precedence (`manual > accepted-LLM > convention > extraction`), runs the
/// enrichment pass (pass 2: annotation-derived relations + verification), and
/// writes `resolved.json` per family — the generator input.
fn run_pipeline(api_root: &Path, only: Option<&[String]>) -> Result<()> {
    let extracted =
        apianyware_datalog::loading::load_all_family_artifacts(api_root, "extracted.json", only)?;
    if extracted.is_empty() {
        anyhow::bail!(
            "no extracted.json found under {} (run `apianyware-collect` first)",
            api_root.display()
        );
    }
    tracing::info!(count = extracted.len(), "loaded extracted IR");

    // Pass 1 — `linked`: all families share one Datalog program so cross-framework
    // inheritance (e.g. AppKit classes inheriting Foundation) resolves.
    let linked = apianyware_resolve::resolve_loaded_frameworks(&extracted)?;
    tracing::info!(frameworks = linked.len(), "linked");

    // Merge each family's authored overlay (heuristics + accepted-LLM facts; LLM
    // precedence on conflict). A family with no `annotations.apiw` is heuristics-only.
    let mut annotated = Vec::with_capacity(linked.len());
    for fw in &linked {
        let overlay = load_overlay(api_root, &fw.name)?;
        annotated.push(apianyware_annotate::annotate_framework(
            fw,
            overlay.as_ref(),
        ));
    }
    tracing::info!(frameworks = annotated.len(), "annotated");

    // Pass 2 — enrichment + verification → the resolved graph.
    let resolved = apianyware_enrich::enrich_loaded_frameworks(&annotated)?;

    for fw in &resolved {
        let path = api_root.join(&fw.name).join("resolved.json");
        apianyware_spec_format::machine::write_framework(fw, &path)
            .with_context(|| format!("failed to write {}", path.display()))?;
        let annotation_count: usize = fw.class_annotations.iter().map(|c| c.methods.len()).sum();
        tracing::info!(
            framework = %fw.name,
            classes = fw.classes.len(),
            method_annotations = annotation_count,
            output = %path.display(),
            "wrote resolved.json"
        );
    }

    tracing::info!(frameworks = resolved.len(), "resolution complete");
    Ok(())
}

/// Load a family's authored overlay (`<api_root>/<Framework>/annotations.apiw`),
/// or `None` if the family carries no overlay.
fn load_overlay(api_root: &Path, framework: &str) -> Result<Option<FrameworkAnnotations>> {
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
