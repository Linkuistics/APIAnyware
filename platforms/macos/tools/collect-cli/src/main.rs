//! CLI for extracting macOS API metadata from SDK headers and Swift modules.
//!
//! Usage:
//!   apianyware-collect                    # extract all SDK frameworks
//!   apianyware-collect --only Foundation   # extract specific framework(s)
//!   apianyware-collect --list              # list available frameworks
//!   apianyware-collect --no-swift          # skip Swift extraction

use std::collections::HashMap;
use std::fs;
use std::path::PathBuf;

use anyhow::{Context, Result};
use clap::Parser;

use apianyware_extract_objc::{
    create_index, discover_frameworks, discover_sdk, extract_framework, init_clang,
};
use apianyware_extract_swift::{
    digester::{discover_swift_modules, SwiftModuleInfo},
    extract_swift_framework,
    merge::merge_swift_into_objc,
};

#[derive(Parser)]
#[command(name = "apianyware-collect")]
#[command(about = "Extract macOS API metadata from SDK headers and Swift modules")]
struct Cli {
    /// List available frameworks and exit.
    #[arg(long)]
    list: bool,

    /// Extract only specific framework(s) (comma-separated or repeated).
    #[arg(long, value_delimiter = ',')]
    only: Vec<String>,

    /// `api/` root: the extracted IR is written per family to
    /// `<output-dir>/<Framework>/extracted.json` (ADR-0046 spec triad).
    #[arg(long, default_value = "platforms/macos/api")]
    output_dir: PathBuf,

    /// Skip Swift module extraction (ObjC headers only).
    #[arg(long)]
    no_swift: bool,
}

fn main() -> Result<()> {
    tracing_subscriber::fmt()
        .with_env_filter(
            tracing_subscriber::EnvFilter::try_from_default_env()
                .unwrap_or_else(|_| tracing_subscriber::EnvFilter::new("info")),
        )
        .init();

    let cli = Cli::parse();

    let sdk = discover_sdk().context("failed to discover macOS SDK")?;
    tracing::info!(sdk_path = %sdk.path.display(), version = %sdk.version, "discovered SDK");

    let frameworks = discover_frameworks(&sdk.path).context("failed to discover frameworks")?;
    tracing::info!(count = frameworks.len(), "discovered ObjC frameworks");

    // Discover Swift modules
    let swift_modules = if cli.no_swift {
        Vec::new()
    } else {
        discover_swift_modules(&sdk.path).unwrap_or_else(|e| {
            tracing::warn!(error = %e, "failed to discover Swift modules, continuing without");
            Vec::new()
        })
    };

    if !swift_modules.is_empty() {
        tracing::info!(count = swift_modules.len(), "discovered Swift modules");
    }

    // Build a lookup of Swift modules by framework name
    let swift_module_map: HashMap<&str, &SwiftModuleInfo> =
        swift_modules.iter().map(|m| (m.name.as_str(), m)).collect();

    if cli.list {
        // Combine ObjC and Swift framework names
        let mut all_names: std::collections::BTreeSet<String> = std::collections::BTreeSet::new();
        for fw in &frameworks {
            all_names.insert(fw.name.clone());
        }
        for m in &swift_modules {
            all_names.insert(m.name.clone());
        }
        for name in &all_names {
            let has_objc = frameworks.iter().any(|f| f.name == *name);
            let has_swift = swift_module_map.contains_key(name.as_str());
            let tag = match (has_objc, has_swift) {
                (true, true) => " [objc+swift]",
                (true, false) => " [objc]",
                (false, true) => " [swift]",
                (false, false) => "",
            };
            println!("{name}{tag}");
        }
        return Ok(());
    }

    // Filter frameworks if --only is specified
    let only_set: std::collections::HashSet<&str> = cli.only.iter().map(|s| s.as_str()).collect();

    let frameworks_to_extract: Vec<_> = if only_set.is_empty() {
        frameworks.iter().collect()
    } else {
        frameworks
            .iter()
            .filter(|f| only_set.contains(f.name.as_str()))
            .collect()
    };

    // Also find Swift-only frameworks (no ObjC headers)
    let objc_names: std::collections::HashSet<&str> =
        frameworks.iter().map(|f| f.name.as_str()).collect();

    let swift_only_modules: Vec<&SwiftModuleInfo> = swift_modules
        .iter()
        .filter(|m| !objc_names.contains(m.name.as_str()))
        .filter(|m| only_set.is_empty() || only_set.contains(m.name.as_str()))
        .collect();

    if frameworks_to_extract.is_empty() && swift_only_modules.is_empty() && !cli.only.is_empty() {
        anyhow::bail!(
            "no frameworks matched --only {:?}. Use --list to see available frameworks.",
            cli.only
        );
    }

    // Ensure output directory exists
    fs::create_dir_all(&cli.output_dir).with_context(|| {
        format!(
            "failed to create output directory: {}",
            cli.output_dir.display()
        )
    })?;

    // Initialize clang once for all frameworks
    let clang = init_clang().context("failed to initialize libclang")?;
    let index = create_index(&clang);

    let total = frameworks_to_extract.len() + swift_only_modules.len();
    let mut success_count = 0;
    let mut error_count = 0;

    // Extract ObjC frameworks (with optional Swift merge)
    for (i, framework) in frameworks_to_extract.iter().enumerate() {
        tracing::info!(
            progress = format!("[{}/{}]", i + 1, total),
            framework = %framework.name,
            "extracting ObjC"
        );

        match extract_framework(&index, framework, &sdk) {
            Ok(mut ir) => {
                // Merge Swift declarations if module exists
                if let Some(swift_module) = swift_module_map.get(framework.name.as_str()) {
                    tracing::info!(framework = %framework.name, "merging Swift declarations");
                    match extract_swift_framework(swift_module, &sdk.path, &sdk.version) {
                        Ok(swift_ir) => {
                            let swift_classes = swift_ir.classes.len();
                            let swift_protocols = swift_ir.protocols.len();
                            merge_swift_into_objc(&mut ir, swift_ir);
                            tracing::info!(
                                framework = %framework.name,
                                swift_classes,
                                swift_protocols,
                                "merged Swift declarations"
                            );
                        }
                        Err(e) => {
                            tracing::warn!(
                                framework = %framework.name,
                                error = %e,
                                "Swift extraction failed, using ObjC only"
                            );
                        }
                    }
                }

                write_framework_json(&ir, &cli.output_dir)?;
                success_count += 1;
            }
            Err(e) => {
                tracing::error!(framework = %framework.name, error = %e, "ObjC extraction failed");
                error_count += 1;
            }
        }
    }

    // Extract Swift-only frameworks
    for (i, swift_module) in swift_only_modules.iter().enumerate() {
        let progress_idx = frameworks_to_extract.len() + i + 1;
        tracing::info!(
            progress = format!("[{}/{}]", progress_idx, total),
            framework = %swift_module.name,
            "extracting Swift-only"
        );

        match extract_swift_framework(swift_module, &sdk.path, &sdk.version) {
            Ok(ir) => {
                write_framework_json(&ir, &cli.output_dir)?;
                success_count += 1;
            }
            Err(e) => {
                tracing::error!(
                    framework = %swift_module.name,
                    error = %e,
                    "Swift extraction failed"
                );
                error_count += 1;
            }
        }
    }

    tracing::info!(
        success = success_count,
        errors = error_count,
        "collection complete"
    );

    if error_count > 0 {
        anyhow::bail!("{} framework(s) failed to extract", error_count);
    }

    Ok(())
}

fn write_framework_json(
    ir: &apianyware_types::ir::Framework,
    output_dir: &std::path::Path,
) -> Result<()> {
    // Per-family spec triad (ADR-0046): `<api_root>/<Framework>/extracted.json`.
    let family_dir = output_dir.join(&ir.name);
    fs::create_dir_all(&family_dir)
        .with_context(|| format!("failed to create {}", family_dir.display()))?;
    let output_path = family_dir.join("extracted.json");
    apianyware_spec_format::machine::write_framework(ir, &output_path)
        .with_context(|| format!("failed to write {}", output_path.display()))?;
    tracing::info!(
        framework = %ir.name,
        classes = ir.classes.len(),
        protocols = ir.protocols.len(),
        enums = ir.enums.len(),
        structs = ir.structs.len(),
        functions = ir.functions.len(),
        output = %output_path.display(),
        "wrote checkpoint"
    );
    Ok(())
}
