//! Machine interchange — the KDL serde seam for `extracted.kdl` / `resolved.kdl`.
//!
//! Both machine artifacts are an [`apianyware_types::ir::Framework`] on disk. The
//! encoding is **KDL 2.0** via a machine-oriented (non-format-preserving) codec:
//! the typed `Framework` bridges through `serde_json::Value` (`to_value` /
//! `from_value`, reusing the existing serde derives) and the `Value` is
//! encoded/decoded by the hand-written [`jik`](crate::jik) codec. ADR-0046 §5.
//!
//! The `k150` spike measured this Value-bridge path at ~2.4–2.5× `serde_json`
//! read / ~2.9–3.2× write on the real multi-MB IR — well under the perf bar,
//! and losslessly round-tripping both shapes. The format-preserving `kdl` crate
//! (used for the authored `.apiw` overlay) is ~84× and is deliberately **not**
//! on this path. These helpers are the single read/write seam the pipeline uses.

use std::path::Path;

use apianyware_types::ir::Framework;

use crate::error::{Result, SpecFormatError};
use crate::jik;

/// Read a machine IR artifact (`extracted.kdl` or `resolved.kdl`) from disk.
pub fn read_framework(path: &Path) -> Result<Framework> {
    let text = std::fs::read_to_string(path).map_err(|source| SpecFormatError::Io {
        path: path.display().to_string(),
        source,
    })?;
    framework_from_kdl(&text).map_err(|e| e.with_path(path.display().to_string()))
}

/// Write a machine IR artifact to disk as JiK KDL text.
///
/// The codec's emitter ends the document with a trailing newline, and
/// `serde_json::Value`'s object keys are sorted — so the output is stable and
/// readable under goldens-as-truth review.
pub fn write_framework(framework: &Framework, path: &Path) -> Result<()> {
    let text = framework_to_kdl(framework).map_err(|e| e.with_path(path.display().to_string()))?;
    std::fs::write(path, text).map_err(|source| SpecFormatError::Io {
        path: path.display().to_string(),
        source,
    })
}

/// Decode a machine IR artifact from JiK KDL text (no filesystem).
///
/// Bridges through `serde_json::Value`: [`jik::parse`] the text, then
/// `from_value` into the typed [`Framework`]. Errors carry the logical name
/// `"<kdl>"` until [`SpecFormatError::with_path`] localises them.
pub fn framework_from_kdl(text: &str) -> Result<Framework> {
    let value = jik::parse(text).map_err(|message| SpecFormatError::MachineKdl {
        path: "<kdl>".to_string(),
        message,
    })?;
    serde_json::from_value(value).map_err(|source| SpecFormatError::Json {
        path: "<kdl>".to_string(),
        source,
    })
}

/// Encode a [`Framework`] as JiK KDL text (no filesystem).
///
/// Bridges through `serde_json::Value`: `to_value` the typed framework, then
/// [`jik::emit`] the value.
pub fn framework_to_kdl(framework: &Framework) -> Result<String> {
    let value = serde_json::to_value(framework).map_err(|source| SpecFormatError::Json {
        path: "<kdl>".to_string(),
        source,
    })?;
    Ok(jik::emit(&value))
}
