//! Machine interchange — the JSON serde seam for `extracted.json` / `resolved.json`.
//!
//! Both machine artifacts are an [`apianyware_types::ir::Framework`] serialized
//! with `serde_json`. The k17 spike (ADR-0046 §5) measured the official
//! document-model `kdl` crate at ~80–100× slower than `serde_json` to parse the
//! real multi-MB IR, so the JSON retreat was invoked: the machine side stays
//! JSON, and only the authored `.apiw` overlay is KDL. These helpers are the
//! single read/write seam the pipeline cutover (k20) rewires onto.

use std::path::Path;

use apianyware_types::ir::Framework;

use crate::error::{Result, SpecFormatError};

/// Read a machine IR artifact (`extracted.json` or `resolved.json`) from disk.
pub fn read_framework(path: &Path) -> Result<Framework> {
    let text = std::fs::read_to_string(path).map_err(|source| SpecFormatError::Io {
        path: path.display().to_string(),
        source,
    })?;
    framework_from_json(&text).map_err(|source| SpecFormatError::Json {
        path: path.display().to_string(),
        source,
    })
}

/// Write a machine IR artifact to disk as pretty, newline-terminated JSON.
///
/// Pretty-printed because the machine files are read by hand under
/// goldens-as-truth review; the trailing newline matches the existing
/// checkpoint files and keeps diffs clean.
pub fn write_framework(framework: &Framework, path: &Path) -> Result<()> {
    let mut text =
        serde_json::to_string_pretty(framework).map_err(|source| SpecFormatError::Json {
            path: path.display().to_string(),
            source,
        })?;
    text.push('\n');
    std::fs::write(path, text).map_err(|source| SpecFormatError::Io {
        path: path.display().to_string(),
        source,
    })
}

/// Parse a machine IR artifact from a JSON string (no filesystem).
pub fn framework_from_json(text: &str) -> std::result::Result<Framework, serde_json::Error> {
    serde_json::from_str(text)
}
