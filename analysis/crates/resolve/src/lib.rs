//! Datalog pass 1: inheritance resolution, effective methods, ownership families.
//!
//! Reads collected IR checkpoints and computes derived relations via Datalog (ascent crate):
//! - `ancestor` — transitive inheritance closure
//! - `effective_method` — inheritance-flattened methods with override detection
//! - `effective_property` — inheritance-flattened properties
//! - `returns_retained_method` — Cocoa ownership family detection
//! - `satisfies_protocol_method` — protocol conformance matching

pub mod checkpoint;
pub mod fact_loader;
pub mod program;

use std::path::Path;

use anyhow::{Context, Result};
use apianyware_datalog::loading;
use apianyware_types::Framework;

/// Resolve all collected frameworks: load, run Datalog, write resolved checkpoints.
///
/// Loads all frameworks from `input_dir` into a single Datalog program (cross-framework
/// resolution), runs the rules, then writes resolved checkpoints to `output_dir`.
pub fn resolve_frameworks(
    input_dir: &Path,
    output_dir: &Path,
    only: Option<&[String]>,
) -> Result<Vec<Framework>> {
    let frameworks = loading::load_all_frameworks(input_dir, only)?;
    if frameworks.is_empty() {
        anyhow::bail!("no frameworks found in {}", input_dir.display());
    }

    tracing::info!(count = frameworks.len(), "loaded frameworks for resolution");

    let resolved = resolve_loaded_frameworks(&frameworks)?;

    std::fs::create_dir_all(output_dir).with_context(|| {
        format!(
            "failed to create output directory: {}",
            output_dir.display()
        )
    })?;

    for framework in &resolved {
        checkpoint::write_resolved_checkpoint(framework, output_dir)?;
    }

    Ok(resolved)
}

/// Run resolution on already-loaded frameworks.
///
/// All frameworks are loaded into a single Datalog program so cross-framework
/// inheritance (e.g., AppKit classes inheriting Foundation classes) is resolved.
pub fn resolve_loaded_frameworks(frameworks: &[Framework]) -> Result<Vec<Framework>> {
    let mut prog = program::ResolutionProgram::default();

    for framework in frameworks {
        fact_loader::load_framework_facts(&mut prog, framework);
    }

    tracing::info!("running Datalog resolution");
    prog.run();
    tracing::info!(
        ancestors = prog.ancestor.len(),
        effective_methods = prog.effective_method.len(),
        effective_properties = prog.effective_property.len(),
        returns_retained = prog.returns_retained_method.len(),
        satisfies_protocol = prog.satisfies_protocol_method.len(),
        "resolution complete"
    );

    let mut resolved = Vec::with_capacity(frameworks.len());
    for framework in frameworks {
        let enriched = checkpoint::build_resolved_framework(framework, &prog, frameworks);
        resolved.push(enriched);
    }

    Ok(resolved)
}
