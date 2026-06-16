//! CLI for the generation pipeline: emit target bindings from enriched IR.
//!
//! Usage:
//!   apianyware-macos-generate                              # generate all targets
//!   apianyware-macos-generate --target racket             # generate Racket only
//!   apianyware-macos-generate --list-targets             # show available emitters

mod generate;
mod registry;

use std::path::PathBuf;

use anyhow::Result;
use clap::Parser;

#[derive(Parser)]
#[command(name = "apianyware-macos-generate")]
#[command(about = "Generate target bindings from enriched macOS API IR")]
struct Cli {
    /// Target(s) to generate bindings for (comma-separated or repeated).
    /// Default: all registered targets.
    #[arg(long, value_delimiter = ',')]
    target: Vec<String>,

    /// Directory containing enriched IR JSON files.
    #[arg(long, default_value = "analysis/ir/enriched")]
    input_dir: PathBuf,

    /// Base output directory for generated targets.
    /// Output goes to `{output-dir}/{target}/generated/`.
    #[arg(long, default_value = "generation/targets")]
    output_dir: PathBuf,

    /// List available target emitters.
    #[arg(long)]
    list_targets: bool,

    /// Output path for the racket target's generated native dispatch table
    /// (ADR-0013). Written when racket is among the generated targets; `swift
    /// build` then compiles it into `libAPIAnywareRacket`.
    #[arg(
        long,
        default_value = "swift/Sources/APIAnywareRacket/Generated/Dispatch.swift"
    )]
    racket_dispatch_out: PathBuf,

    /// Skip generating the racket native dispatch table (useful when only the
    /// `.rkt` bindings are wanted, or the Swift target is unavailable).
    #[arg(long)]
    no_racket_dispatch: bool,

    /// Output path for the racket target's generated Swift-native trampolines
    /// (ADR-0027). Written when racket is among the generated targets; `swift
    /// build` then compiles it into `libAPIAnywareRacket`.
    #[arg(
        long,
        default_value = "swift/Sources/APIAnywareRacket/Generated/Trampolines.swift"
    )]
    racket_trampolines_out: PathBuf,

    /// Skip generating the racket Swift-native trampolines.
    #[arg(long)]
    no_racket_trampolines: bool,
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

    if cli.list_targets {
        println!("Available target emitters:\n");
        println!("{}", registry.format_target_list());
        return Ok(());
    }

    let target_filter = if cli.target.is_empty() {
        None
    } else {
        Some(cli.target.as_slice())
    };

    let summaries =
        generate::run_generation(&registry, &cli.input_dir, &cli.output_dir, target_filter)?;

    // Generate the racket native dispatch table (ADR-0013) when racket was among
    // the targets. It is a global pass over all frameworks, so it runs once here
    // rather than per-framework. Build order: generate (here) -> swift build.
    let racket_generated = summaries.iter().any(|s| s.target_id == "racket");
    if racket_generated && !cli.no_racket_dispatch {
        let entries =
            generate::run_racket_native_dispatch(&cli.input_dir, &cli.racket_dispatch_out)?;
        tracing::info!(
            entries,
            output = %cli.racket_dispatch_out.display(),
            "racket native dispatch table generated — run `swift build` to compile it"
        );
    }

    // Generate the racket Swift-native trampolines (ADR-0027) — also a global
    // pass over all frameworks, run alongside the dispatch table. Build order is
    // the same: generate (here) -> swift build.
    if racket_generated && !cli.no_racket_trampolines {
        let entries =
            generate::run_racket_trampolines(&cli.input_dir, &cli.racket_trampolines_out)?;
        tracing::info!(
            entries,
            output = %cli.racket_trampolines_out.display(),
            "racket Swift-native trampolines generated — run `swift build` to compile them"
        );
    }

    // Print final summary
    for summary in &summaries {
        tracing::info!(
            target = %summary.target_id,
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
