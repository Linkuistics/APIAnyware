//! `apianyware-analyze annotations` — the LLM analysis side-channel workflow
//! commands (ADR-0050).
//!
//! The group hosts the lean mechanism over the committed `annotations.apiw`
//! overlay: `stale` (ws5 `staleness-regen-k46`) reports slots that have drifted
//! from the current resolved API surface; `audit` (ws5 `disagreement-report-k47`)
//! reads the resolved-only `fact_provenance` carriage k45 landed and reports the
//! disagreements + per-tier win distribution. Orthogonal inputs (resolved surface
//! vs the overlay, vs the resolved-only provenance), shared subcommand group.

pub mod audit;
pub mod stale;

use anyhow::Result;
use clap::{Args, Subcommand};

/// `annotations <command>` argument group.
#[derive(Args)]
pub struct AnnotationsArgs {
    #[command(subcommand)]
    pub command: AnnotationsCommand,
}

/// The annotation workflow subcommands.
#[derive(Subcommand)]
pub enum AnnotationsCommand {
    /// Report annotation slots that have drifted from the current resolved
    /// API surface (orphaned / new-surface / shape-changed).
    Stale(stale::StaleArgs),

    /// Report resolve-time annotation disagreements + the per-tier win
    /// distribution from each family's `fact_provenance` carriage.
    Audit(audit::AuditArgs),
}

/// Dispatch an `annotations` subcommand. A `stale` run that finds any stale
/// family exits the process with status 1 so the command gates in CI/Make
/// (ADR-0050 §4); `audit` is informational and always exits 0. An I/O failure
/// propagates as an `Err`.
pub fn run(args: AnnotationsArgs) -> Result<()> {
    match args.command {
        AnnotationsCommand::Stale(stale_args) => {
            if stale::run(&stale_args)? {
                std::process::exit(1);
            }
            Ok(())
        }
        AnnotationsCommand::Audit(audit_args) => audit::run(&audit_args),
    }
}
