//! High-level framework extraction orchestrator.
//!
//! Coordinates SDK discovery, libclang parsing, and IR assembly to extract
//! all declarations from a macOS framework into an [`ir::Framework`] value.

use std::path::Path;

use anyhow::Result;
use chrono::Utc;

use apianyware_types::ir;

use crate::extract_declarations::extract_from_translation_unit;
use crate::sdk::{FrameworkInfo, SdkInfo};

/// Extract a single framework's API declarations into an IR [`Framework`].
///
/// Accepts a pre-created `clang::Index` to allow reuse across multiple
/// framework extractions (the `Clang` singleton can only be initialized once).
pub fn extract_framework(
    index: &clang::Index<'_>,
    framework: &FrameworkInfo,
    sdk: &SdkInfo,
) -> Result<ir::Framework> {
    tracing::info!(framework = %framework.name, "extracting framework");

    let translation_unit = parse_umbrella_header(index, framework, &sdk.path)?;
    let entity = translation_unit.get_entity();

    let result = extract_from_translation_unit(&entity, &framework.name, &sdk.path);

    tracing::info!(
        framework = %framework.name,
        classes = result.classes.len(),
        protocols = result.protocols.len(),
        enums = result.enums.len(),
        structs = result.structs.len(),
        functions = result.functions.len(),
        constants = result.constants.len(),
        "extraction complete"
    );

    Ok(ir::Framework {
        format_version: "1.0".to_string(),
        checkpoint: "extracted".to_string(),
        name: framework.name.clone(),
        sdk_version: Some(sdk.version.clone()),
        collected_at: Some(Utc::now().to_rfc3339()),
        depends_on: Vec::new(),
        skipped_symbols: result.skipped_symbols,
        classes: result.classes,
        protocols: result.protocols,
        enums: result.enums,
        structs: result.structs,
        functions: result.functions,
        constants: result.constants,
        class_annotations: vec![],
        patterns: vec![],
        enrichment: None,
        verification: None,
    })
}

/// Initialize the libclang runtime and create a reusable `Clang` instance.
///
/// Call this once, then create an `Index` from it for framework extraction.
/// The `Clang` value must outlive all `Index` and `TranslationUnit` values.
pub fn init_clang() -> Result<clang::Clang> {
    clang::Clang::new().map_err(|e| anyhow::anyhow!("failed to initialize clang: {e}"))
}

/// Create a libclang index for parsing translation units.
pub fn create_index(clang: &clang::Clang) -> clang::Index<'_> {
    clang::Index::new(clang, false, true)
}

/// Parse a framework's umbrella header with libclang.
fn parse_umbrella_header<'a>(
    index: &'a clang::Index<'a>,
    framework: &FrameworkInfo,
    sdk_path: &Path,
) -> Result<clang::TranslationUnit<'a>> {
    let header_path = &framework.umbrella_header;

    // Build clang arguments for ObjC parsing with SDK paths
    let sdk_path_str = sdk_path.to_string_lossy();
    let args = [
        "-x".to_string(),
        "objective-c".to_string(),
        "-isysroot".to_string(),
        sdk_path_str.to_string(),
        format!("-F{}/System/Library/Frameworks", sdk_path_str),
        "-mmacosx-version-min=10.15".to_string(),
        // Suppress warnings during parsing
        "-w".to_string(),
    ];

    let arg_refs: Vec<&str> = args.iter().map(|s| s.as_str()).collect();

    tracing::debug!(
        header = %header_path.display(),
        "parsing umbrella header"
    );

    let tu = index
        .parser(header_path)
        .arguments(&arg_refs)
        .detailed_preprocessing_record(true)
        .skip_function_bodies(true)
        .parse()
        .map_err(|_| anyhow::anyhow!("libclang failed to parse {}", header_path.display()))?;

    // Check for fatal parsing errors
    let diagnostics = tu.get_diagnostics();
    let fatal_count = diagnostics
        .iter()
        .filter(|d| d.get_severity() == clang::diagnostic::Severity::Fatal)
        .count();

    if fatal_count > 0 {
        for diag in diagnostics
            .iter()
            .filter(|d| d.get_severity() == clang::diagnostic::Severity::Fatal)
        {
            tracing::error!(
                framework = %framework.name,
                error = %diag.get_text(),
                "fatal parsing error"
            );
        }
        anyhow::bail!(
            "framework {} had {} fatal parsing error(s)",
            framework.name,
            fatal_count
        );
    }

    Ok(tu)
}
