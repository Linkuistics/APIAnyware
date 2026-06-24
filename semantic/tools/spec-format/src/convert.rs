//! Migration converter: `_llm-annotations/*.llm.json` → `annotations.apiw`.
//!
//! Today's committed `_llm-annotations/<Framework>.llm.json` files are the only
//! human/LLM-authored input to the pipeline. ADR-0046 folds them into the **one**
//! authored overlay (`annotations.apiw`), converted once. The conversion is a
//! straight deserialize-then-emit: the `.llm.json` already deserializes to
//! [`FrameworkAnnotations`], and [`crate::apiw::write_apiw`] emits the KDL overlay.
//! The actual file moves into the per-family triad happen in the pipeline cutover
//! (k20); this module is the pure transform it calls.

use std::path::Path;

use apianyware_types::annotation::FrameworkAnnotations;

use crate::apiw::write_apiw;
use crate::error::{Result, SpecFormatError};

/// Convert one `_llm-annotations` JSON document into `.apiw` (KDL) text.
pub fn llm_annotations_to_apiw(json_text: &str) -> Result<String> {
    let annotations: FrameworkAnnotations =
        serde_json::from_str(json_text).map_err(|source| SpecFormatError::Json {
            path: "<_llm-annotations input>".to_string(),
            source,
        })?;
    Ok(write_apiw(&annotations))
}

/// Convert an `_llm-annotations/<Framework>.llm.json` file to an
/// `annotations.apiw` file on disk.
pub fn convert_llm_file(src: &Path, dst: &Path) -> Result<()> {
    let json = std::fs::read_to_string(src).map_err(|source| SpecFormatError::Io {
        path: src.display().to_string(),
        source,
    })?;
    let apiw_text = llm_annotations_to_apiw(&json).map_err(|e| match e {
        // Re-label the JSON error with the real source path.
        SpecFormatError::Json { source, .. } => SpecFormatError::Json {
            path: src.display().to_string(),
            source,
        },
        other => other,
    })?;
    std::fs::write(dst, apiw_text).map_err(|source| SpecFormatError::Io {
        path: dst.display().to_string(),
        source,
    })
}
