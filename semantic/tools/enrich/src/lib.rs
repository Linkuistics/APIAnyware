//! Datalog pass 2: annotation-derived enrichment and verification.
//!
//! Reads annotated IR checkpoints and computes generation-facing derived
//! relations via Datalog (ascent crate):
//!
//! **Annotation-derived relations:**
//! - `sync_block_method` — synchronous block (caller frees)
//! - `async_block_method` — async-copied block (runtime-managed)
//! - `stored_block_method` — stored block (called multiple times)
//! - `delegate_protocol` — protocol suitable for typed delegate builder
//! - `convenience_error_method` — method with NSError** out-param
//! - `collection_iterable` — class with indexed access + count
//! - `scoped_resource` — begin/end or open/close pairs (from api_patterns)
//! - `main_thread_class` — class with main-thread-only methods
//!
//! **Verification rules:**
//! - `violation_unclassified_block` — block param without classification
//! - `violation_flag_mismatch` — returns_retained flag vs naming convention

pub mod checkpoint;
pub mod fact_loader;
pub mod program;

use std::path::Path;

use anyhow::{Context, Result};
use apianyware_datalog::loading;
use apianyware_types::Framework;

/// Enrich all annotated frameworks: load, run Datalog, write enriched checkpoints.
///
/// Loads all frameworks from `input_dir` into a single Datalog program,
/// runs enrichment rules, then writes enriched checkpoints to `output_dir`.
pub fn enrich_frameworks(
    input_dir: &Path,
    output_dir: &Path,
    only: Option<&[String]>,
) -> Result<Vec<Framework>> {
    let frameworks = loading::load_all_frameworks(input_dir, only)?;
    if frameworks.is_empty() {
        anyhow::bail!("no frameworks found in {}", input_dir.display());
    }

    tracing::info!(count = frameworks.len(), "loaded frameworks for enrichment");

    let enriched = enrich_loaded_frameworks(&frameworks)?;

    std::fs::create_dir_all(output_dir).with_context(|| {
        format!(
            "failed to create output directory: {}",
            output_dir.display()
        )
    })?;

    for framework in &enriched {
        checkpoint::write_resolved_checkpoint(framework, output_dir)?;
    }

    Ok(enriched)
}

/// Run enrichment on already-loaded annotated frameworks.
///
/// All frameworks are loaded into a single Datalog program so cross-framework
/// facts (e.g., protocol conformance across frameworks) are available.
pub fn enrich_loaded_frameworks(frameworks: &[Framework]) -> Result<Vec<Framework>> {
    let mut prog = program::EnrichmentProgram::default();

    for framework in frameworks {
        fact_loader::load_framework_facts(&mut prog, framework);
    }

    tracing::info!("running Datalog enrichment");
    prog.run();

    tracing::info!(
        sync_blocks = prog.sync_block_method.len(),
        async_blocks = prog.async_block_method.len(),
        stored_blocks = prog.stored_block_method.len(),
        delegate_protocols = prog.delegate_protocol.len(),
        error_methods = prog.convenience_error_method.len(),
        iterables = prog.collection_iterable.len(),
        main_thread_classes = prog.main_thread_class.len(),
        unclassified_blocks = prog.violation_unclassified_block.len(),
        flag_mismatches = prog.violation_flag_mismatch.len(),
        "enrichment complete (global totals)"
    );

    let mut enriched = Vec::with_capacity(frameworks.len());
    for framework in frameworks {
        let result = checkpoint::build_resolved_framework(framework, &prog);
        if let Some(ref e) = result.enrichment {
            tracing::info!(
                framework = %result.name,
                sync_blocks = e.sync_block_methods.len(),
                async_blocks = e.async_block_methods.len(),
                stored_blocks = e.stored_block_methods.len(),
                delegate_protocols = e.delegate_protocols.len(),
                error_methods = e.convenience_error_methods.len(),
                iterables = e.collection_iterables.len(),
                scoped_resources = e.scoped_resources.len(),
                main_thread_classes = e.main_thread_classes.len(),
                "enriched"
            );
        }
        if let Some(ref v) = result.verification {
            if v.passed {
                tracing::info!(framework = %result.name, "verification passed");
            } else {
                tracing::warn!(
                    framework = %result.name,
                    violations = v.violations.len(),
                    "verification FAILED"
                );
            }
        }
        enriched.push(result);
    }

    Ok(enriched)
}
