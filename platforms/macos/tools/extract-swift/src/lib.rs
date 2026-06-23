//! Swift API extraction via swift-api-digester -dump-sdk.
//!
//! This crate extracts Swift API metadata from macOS SDK frameworks using
//! `swift-api-digester -dump-sdk`. It parses the ABIRoot JSON tree and maps
//! Swift declarations to the shared IR types for downstream analysis.

pub mod abi_types;
pub mod declaration_mapping;
pub mod digester;
pub mod merge;
pub mod type_mapping;

use std::path::Path;

use anyhow::Result;
use apianyware_types::ir;

use crate::digester::SwiftModuleInfo;

/// Extract Swift API metadata for a framework that has a `.swiftmodule`.
///
/// Invokes `swift-api-digester -dump-sdk`, parses the ABIRoot JSON, and maps
/// declarations to IR types with `source: SwiftInterface`.
pub fn extract_swift_framework(
    module: &SwiftModuleInfo,
    sdk_path: &Path,
    sdk_version: &str,
) -> Result<ir::Framework> {
    let abi_json = digester::run_swift_api_digester(&module.name, sdk_path)?;
    let doc: abi_types::AbiDocument = serde_json::from_str(&abi_json)?;
    let framework = declaration_mapping::map_abi_to_framework(&doc, sdk_version);
    Ok(framework)
}
