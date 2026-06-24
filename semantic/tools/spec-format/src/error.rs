//! Error type for the spec-format crate.
//!
//! NOTE: `miette-derive` (7.x) generates `Display`/`labels()` code for the
//! `#[source_code]` / `#[label]` / `#[error]` fields that trips a spurious
//! `unused_assignments` lint, attributed back to the field declarations. The
//! fields are genuinely read by the generated impls. This module is pure type
//! definitions plus one trivial constructor, so a module-scoped `allow` is a
//! tight, safe place to suppress the false positive without masking real ones.
#![allow(unused_assignments)]
//!
//! Two failure shapes matter: *syntactic* KDL errors (forwarded from the `kdl`
//! crate, which already produces rich `miette` diagnostics with a source span
//! and help text), and *schematic* `.apiw` errors — a well-formed KDL document
//! that violates the authored-overlay shape (a missing required node, an
//! unknown enum value, a malformed argument). The latter carry the source text
//! and the offending node's span so the caller can render a labelled diagnostic.

use miette::{Diagnostic, NamedSource, SourceSpan};
use thiserror::Error;

/// Convenience alias for fallible spec-format operations.
pub type Result<T> = std::result::Result<T, SpecFormatError>;

/// Everything that can go wrong loading, parsing, or converting a spec artifact.
#[derive(Debug, Error, Diagnostic)]
pub enum SpecFormatError {
    /// Filesystem error reading or writing an artifact.
    #[error("I/O error for {path}")]
    Io {
        /// The path that failed.
        path: String,
        /// The underlying OS error.
        #[source]
        source: std::io::Error,
    },

    /// JSON (de)serialization error for a machine artifact (`extracted.json` /
    /// `resolved.json`) or an `_llm-annotations` input.
    #[error("JSON error for {path}")]
    Json {
        /// The path (or logical name) that failed.
        path: String,
        /// The underlying `serde_json` error.
        #[source]
        source: serde_json::Error,
    },

    /// Syntactic KDL parse failure. Forwards the `kdl` crate's diagnostic
    /// (source span + help) unchanged.
    #[error(transparent)]
    #[diagnostic(transparent)]
    Kdl(#[from] kdl::KdlError),

    /// A structurally-valid KDL document that violates the `.apiw` schema.
    #[error("{}", .message)]
    #[diagnostic(code(apianyware::spec_format::apiw))]
    Apiw {
        /// What is wrong.
        message: String,
        /// The source `.apiw` text, for rendering.
        #[source_code]
        src: NamedSource<String>,
        /// The offending node's span, labelled `here` in the rendered diagnostic.
        #[label("here")]
        span: SourceSpan,
    },
}

impl SpecFormatError {
    /// Build a located `.apiw` schema error against a node span.
    pub(crate) fn apiw(
        source_name: &str,
        source_text: &str,
        span: SourceSpan,
        message: impl Into<String>,
    ) -> Self {
        SpecFormatError::Apiw {
            message: message.into(),
            src: NamedSource::new(source_name, source_text.to_string()),
            span,
        }
    }
}
