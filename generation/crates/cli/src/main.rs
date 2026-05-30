//! CLI for the generation pipeline: emit language bindings from enriched IR.
//!
//! Usage:
//!   apianyware-macos-generate                              # generate all languages
//!   apianyware-macos-generate --lang racket             # generate Racket only
//!   apianyware-macos-generate --list-languages             # show available emitters

mod generate;
mod registry;

use std::path::PathBuf;

use anyhow::Result;
use clap::Parser;

#[derive(Parser)]
#[command(name = "apianyware-macos-generate")]
#[command(about = "Generate language bindings from enriched macOS API IR")]
struct Cli {
    /// Language(s) to generate bindings for (comma-separated or repeated).
    /// Default: all registered languages.
    #[arg(long, value_delimiter = ',')]
    lang: Vec<String>,

    /// Directory containing enriched IR JSON files.
    #[arg(long, default_value = "analysis/ir/enriched")]
    input_dir: PathBuf,

    /// Base output directory for generated targets.
    /// Output goes to `{output-dir}/{lang}/generated/`.
    #[arg(long, default_value = "generation/targets")]
    output_dir: PathBuf,

    /// List available language emitters.
    #[arg(long)]
    list_languages: bool,
}

fn main() -> Result<()> {
    tracing_subscriber::fmt()
        .with_env_filter(
            tracing_subscriber::EnvFilter::try_from_default_env()
                .unwrap_or_else(|_| tracing_subscriber::EnvFilter::new("info")),
        )
        .init();

    let cli = Cli::parse();
    let registry = registry::EmitterRegistry::new();

    if cli.list_languages {
        println!("Available language emitters:\n");
        println!("{}", registry.format_language_list());
        return Ok(());
    }

    let lang_filter = if cli.lang.is_empty() {
        None
    } else {
        Some(cli.lang.as_slice())
    };

    let summaries =
        generate::run_generation(&registry, &cli.input_dir, &cli.output_dir, lang_filter)?;

    // Print final summary
    for summary in &summaries {
        tracing::info!(
            language = %summary.language_id,
            frameworks = summary.frameworks_generated,
            files = summary.total_files_written,
            classes = summary.total_classes,
            protocols = summary.total_protocols,
            enums = summary.total_enums,
            "generation complete"
        );
    }

    Ok(())
}
