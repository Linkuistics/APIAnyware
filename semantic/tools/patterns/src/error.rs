//! Error type for the pattern-kind registry crate.
//!
//! NOTE: `miette-derive` (7.x) generates `Display`/`labels()` code for the
//! `#[source_code]` / `#[label]` / `#[error]` fields that trips a spurious
//! `unused_assignments` lint, attributed back to the field declarations. The
//! fields are genuinely read by the generated impls. This module is pure type
//! definitions plus one trivial constructor, so a module-scoped `allow` is a
//! tight, safe place to suppress the false positive without masking real ones.
#![allow(unused_assignments)]
//!
//! The failure shapes mirror the sibling `apianyware-spec-format` crate: a
//! filesystem error loading a kind file; a *syntactic* KDL error (forwarded from
//! the `kdl` crate, which produces rich `miette` diagnostics); a *structural*
//! schema violation (forwarded from `spec-format`'s generic KDL-Schema
//! validator); and a *semantic* pattern-kind error — a structurally-valid
//! document that breaks a rule the generic schema cannot state (a law token
//! outside its §30 category, an `ordering` edge naming an undeclared role, a
//! duplicate role name, a kind name not matching its file stem). The last carries
//! the source text and the offending node's span for a labelled diagnostic.

use miette::{Diagnostic, NamedSource, SourceSpan};
use thiserror::Error;

/// Convenience alias for fallible pattern-registry operations.
pub type Result<T> = std::result::Result<T, PatternError>;

/// Everything that can go wrong loading, parsing, or validating a pattern-kind.
#[derive(Debug, Error, Diagnostic)]
pub enum PatternError {
    /// Filesystem error reading a `.apiw` kind file or its directory.
    #[error("I/O error for {path}")]
    Io {
        /// The path that failed.
        path: String,
        /// The underlying OS error.
        #[source]
        source: std::io::Error,
    },

    /// Syntactic KDL parse failure. Forwards the `kdl` crate's diagnostic
    /// (source span + help) unchanged.
    #[error(transparent)]
    #[diagnostic(transparent)]
    Kdl(#[from] kdl::KdlError),

    /// Structural schema violation, forwarded from the `spec-format` generic
    /// KDL-Schema validator run against `pattern-kinds.kdl-schema`.
    #[error(transparent)]
    #[diagnostic(transparent)]
    Schema(#[from] apianyware_spec_format::SpecFormatError),

    /// A structurally-valid document that violates a pattern-kind semantic rule
    /// the generic schema cannot express (controlled-vocabulary membership,
    /// role-reference resolution, role-name uniqueness, kind-name/file-stem
    /// agreement).
    #[error("{}", .message)]
    #[diagnostic(code(apianyware::patterns::kind))]
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

impl PatternError {
    /// Build a located pattern-kind semantic error against a node span.
    pub(crate) fn apiw(
        source_name: &str,
        source_text: &str,
        span: SourceSpan,
        message: impl Into<String>,
    ) -> Self {
        PatternError::Apiw {
            message: message.into(),
            src: NamedSource::new(source_name, source_text.to_string()),
            span,
        }
    }
}
