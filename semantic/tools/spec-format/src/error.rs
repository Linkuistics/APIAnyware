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

    /// serde (de)serialization error bridging a machine artifact
    /// (`extracted.kdl` / `resolved.kdl`) through `serde_json::Value`, or a JSON
    /// `_llm-annotations` input. The value model is JSON's; only the on-disk
    /// encoding is KDL (via the [`jik`](crate::jik) codec).
    #[error("serde error for {path}")]
    Json {
        /// The path (or logical name) that failed.
        path: String,
        /// The underlying `serde_json` error.
        #[source]
        source: serde_json::Error,
    },

    /// Machine-IR KDL codec error: the JiK-encoded text of `extracted.kdl` /
    /// `resolved.kdl` was malformed (a container/scalar mismatch, a bad escape,
    /// trailing input). Distinct from [`SpecFormatError::Kdl`], which forwards
    /// the format-preserving `kdl` crate's diagnostics for authored `.apiw`.
    #[error("machine-KDL codec error for {path}: {message}")]
    MachineKdl {
        /// The path (or logical name) that failed.
        path: String,
        /// The codec's human-readable failure message.
        message: String,
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
    /// Localise a path-less codec error to a real path. The `machine`
    /// text-codec helpers (`framework_from_kdl` / `framework_to_kdl`) tag their
    /// `Json` / `MachineKdl` errors with the placeholder `"<kdl>"`; the
    /// filesystem seam (`read_framework` / `write_framework`) swaps in the file
    /// path so diagnostics point at the artifact. Other variants pass through.
    pub(crate) fn with_path(self, new_path: String) -> Self {
        match self {
            SpecFormatError::Json { source, .. } => SpecFormatError::Json {
                path: new_path,
                source,
            },
            SpecFormatError::MachineKdl { message, .. } => SpecFormatError::MachineKdl {
                path: new_path,
                message,
            },
            other => other,
        }
    }

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
