//! CLI for the analysis pipeline: resolve, annotate, enrich.
//!
//! Usage:
//!   apianyware-macos-analyze                       # run full pipeline
//!   apianyware-macos-analyze resolve               # Datalog pass 1 only
//!   apianyware-macos-analyze annotate              # heuristics + LLM merge only
//!   apianyware-macos-analyze enrich                # Datalog pass 2 only
//!   apianyware-macos-analyze resolve --only Foundation

use std::path::{Path, PathBuf};

use anyhow::Result;
use clap::{Parser, Subcommand};

#[derive(Parser)]
#[command(name = "apianyware-macos-analyze")]
#[command(about = "Analyze collected macOS API metadata: resolve → annotate → enrich")]
struct Cli {
    #[command(subcommand)]
    command: Option<Command>,

    /// Process only specific framework(s) (comma-separated or repeated).
    #[arg(long, global = true, value_delimiter = ',')]
    only: Vec<String>,
}

#[derive(Subcommand)]
enum Command {
    /// Datalog pass 1: inheritance resolution, effective methods, ownership families.
    Resolve {
        /// Directory containing collected IR JSON files.
        #[arg(long, default_value = "collection/ir/collected")]
        input_dir: PathBuf,

        /// Output directory for resolved checkpoints.
        #[arg(long, default_value = "analysis/ir/resolved")]
        output_dir: PathBuf,
    },

    /// Heuristic classification and LLM annotation merge.
    Annotate {
        /// Directory containing resolved IR JSON files.
        #[arg(long, default_value = "analysis/ir/resolved")]
        input_dir: PathBuf,

        /// Output directory for annotated checkpoints.
        #[arg(long, default_value = "analysis/ir/annotated")]
        output_dir: PathBuf,

        /// Directory containing .llm.json files from LLM annotation.
        /// If provided, LLM annotations are loaded from here instead of
        /// from existing annotated checkpoints.
        #[arg(long)]
        llm_dir: Option<PathBuf>,
    },

    /// Extract interesting methods for LLM annotation.
    ///
    /// Writes per-framework method summaries to output_dir as
    /// {Framework}.methods.json, containing only methods that need
    /// LLM classification (block params, error out-params, delegate patterns).
    LlmExtract {
        /// Directory containing resolved IR JSON files.
        #[arg(long, default_value = "analysis/ir/resolved")]
        input_dir: PathBuf,

        /// Output directory for method summary files.
        #[arg(long, default_value = "analysis/ir/llm-summaries")]
        output_dir: PathBuf,
    },

    /// Validate a `.llm.json` file produced by a Claude Code subagent against
    /// its source `.methods.json` summary.
    ///
    /// Surfaces semantic errors that JSON-schema validation cannot see:
    /// references to classes/selectors/parameters that do not exist in the
    /// summary, block annotations on non-block parameters, or annotations
    /// whose `source` is not `"llm"`. Exits non-zero on any validation error.
    LlmValidate {
        /// Path to the source `.methods.json` summary.
        #[arg(long)]
        methods_file: PathBuf,

        /// Path to the `.llm.json` annotations to validate.
        #[arg(long)]
        llm_file: PathBuf,
    },

    /// Datalog pass 2: annotation-derived enrichment and verification.
    Enrich {
        /// Directory containing annotated IR JSON files.
        #[arg(long, default_value = "analysis/ir/annotated")]
        input_dir: PathBuf,

        /// Output directory for enriched checkpoints.
        #[arg(long, default_value = "analysis/ir/enriched")]
        output_dir: PathBuf,
    },
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

    match cli.command {
        Some(Command::Resolve {
            input_dir,
            output_dir,
        }) => run_resolve(&input_dir, &output_dir, only),

        Some(Command::Annotate {
            input_dir,
            output_dir,
            llm_dir,
        }) => run_annotate(&input_dir, &output_dir, only, llm_dir.as_deref()),

        Some(Command::LlmExtract {
            input_dir,
            output_dir,
        }) => run_llm_extract(&input_dir, &output_dir, only),

        Some(Command::LlmValidate {
            methods_file,
            llm_file,
        }) => run_llm_validate(&methods_file, &llm_file),

        Some(Command::Enrich {
            input_dir,
            output_dir,
        }) => run_enrich(&input_dir, &output_dir, only),

        None => {
            // Full pipeline: resolve → annotate → enrich
            tracing::info!("running full analysis pipeline");

            let collected_dir = PathBuf::from("collection/ir/collected");
            let resolved_dir = PathBuf::from("analysis/ir/resolved");

            run_resolve(&collected_dir, &resolved_dir, only)?;

            let annotated_dir = PathBuf::from("analysis/ir/annotated");
            run_annotate(&resolved_dir, &annotated_dir, only, None)?;

            let enriched_dir = PathBuf::from("analysis/ir/enriched");
            run_enrich(&annotated_dir, &enriched_dir, only)
        }
    }
}

fn run_resolve(input_dir: &Path, output_dir: &Path, only: Option<&[String]>) -> Result<()> {
    tracing::info!(
        input = %input_dir.display(),
        output = %output_dir.display(),
        "starting resolution"
    );

    let resolved = apianyware_macos_resolve::resolve_frameworks(input_dir, output_dir, only)?;

    tracing::info!(frameworks = resolved.len(), "resolution complete");

    // Print summary
    for fw in &resolved {
        let class_count = fw.classes.len();
        let methods_with_ancestors: usize = fw
            .classes
            .iter()
            .filter(|c| !c.ancestors.is_empty())
            .count();
        let total_effective_methods: usize = fw.classes.iter().map(|c| c.all_methods.len()).sum();
        let total_effective_properties: usize =
            fw.classes.iter().map(|c| c.all_properties.len()).sum();

        tracing::info!(
            framework = %fw.name,
            classes = class_count,
            classes_with_ancestors = methods_with_ancestors,
            effective_methods = total_effective_methods,
            effective_properties = total_effective_properties,
            "resolved"
        );
    }

    Ok(())
}

fn run_annotate(
    input_dir: &Path,
    output_dir: &Path,
    only: Option<&[String]>,
    llm_dir: Option<&Path>,
) -> Result<()> {
    tracing::info!(
        input = %input_dir.display(),
        output = %output_dir.display(),
        llm_dir = ?llm_dir.map(|d| d.display().to_string()),
        "starting annotation"
    );

    let annotated =
        apianyware_macos_annotate::annotate_frameworks(input_dir, output_dir, only, llm_dir)?;

    tracing::info!(frameworks = annotated.len(), "annotation complete");

    for fw in &annotated {
        let annotation_count: usize = fw.class_annotations.iter().map(|c| c.methods.len()).sum();

        tracing::info!(
            framework = %fw.name,
            classes_annotated = fw.class_annotations.len(),
            method_annotations = annotation_count,
            "annotated"
        );
    }

    Ok(())
}

fn run_llm_extract(input_dir: &Path, output_dir: &Path, only: Option<&[String]>) -> Result<()> {
    tracing::info!(
        input = %input_dir.display(),
        output = %output_dir.display(),
        "extracting methods for LLM annotation"
    );

    let summaries =
        apianyware_macos_annotate::llm::extract_all_frameworks(input_dir, output_dir, only)?;

    let total_methods: usize = summaries.iter().map(|s| s.method_count).sum();

    tracing::info!(
        frameworks = summaries.len(),
        methods = total_methods,
        "LLM extraction complete"
    );

    Ok(())
}

fn run_llm_validate(methods_file: &Path, llm_file: &Path) -> Result<()> {
    let report = apianyware_macos_annotate::llm::validate_llm_file(methods_file, llm_file)?;

    for warning in &report.warnings {
        tracing::warn!("{}", warning);
    }

    if report.is_ok() {
        tracing::info!(
            methods = %methods_file.display(),
            llm = %llm_file.display(),
            warnings = report.warnings.len(),
            "LLM annotations validated"
        );
        return Ok(());
    }

    for err in &report.errors {
        tracing::error!("{}", err);
    }
    anyhow::bail!(
        "LLM annotations failed validation ({} error{})",
        report.errors.len(),
        if report.errors.len() == 1 { "" } else { "s" }
    )
}

fn run_enrich(input_dir: &Path, output_dir: &Path, only: Option<&[String]>) -> Result<()> {
    tracing::info!(
        input = %input_dir.display(),
        output = %output_dir.display(),
        "starting enrichment"
    );

    let enriched = apianyware_macos_enrich::enrich_frameworks(input_dir, output_dir, only)?;

    tracing::info!(frameworks = enriched.len(), "enrichment complete");

    for fw in &enriched {
        if let Some(ref enrichment) = fw.enrichment {
            tracing::info!(
                framework = %fw.name,
                sync_blocks = enrichment.sync_block_methods.len(),
                async_blocks = enrichment.async_block_methods.len(),
                stored_blocks = enrichment.stored_block_methods.len(),
                delegate_protocols = enrichment.delegate_protocols.len(),
                error_methods = enrichment.convenience_error_methods.len(),
                iterables = enrichment.collection_iterables.len(),
                scoped_resources = enrichment.scoped_resources.len(),
                main_thread_classes = enrichment.main_thread_classes.len(),
                "enriched"
            );
        }

        if let Some(ref verification) = fw.verification {
            if verification.passed {
                tracing::info!(framework = %fw.name, "verification passed");
            } else {
                tracing::warn!(
                    framework = %fw.name,
                    violations = verification.violations.len(),
                    "verification found violations"
                );
                for v in &verification.violations {
                    tracing::warn!(
                        rule = %v.rule,
                        class = %v.class,
                        selector = %v.selector,
                        "{}",
                        v.description
                    );
                }
            }
        }
    }

    Ok(())
}
