//! Error type for the app-kind registry crate.
//!
//! NOTE: `miette-derive` (7.x) generates `Display`/`labels()` code for the
//! `#[source_code]` / `#[label]` / `#[error]` fields that trips a spurious
//! `unused_assignments` lint, attributed back to the field declarations. The
//! fields are genuinely read by the generated impls. This module is pure type
//! definitions plus one trivial constructor, so a module-scoped `allow` is a
//! tight, safe place to suppress the false positive without masking real ones.
#![allow(unused_assignments)]
//!
//! The failure shapes mirror the sibling `apianyware-patterns` and
//! `apianyware-platform-manifest` crates: a filesystem error loading a kind file
//! or its directory; a *syntactic* KDL error (forwarded from the `kdl` crate,
//! which produces rich `miette` diagnostics); a *structural* schema violation
//! (forwarded from `spec-format`'s generic KDL-Schema validator run against
//! `app-kind.kdl-schema`); and a *semantic* app-kind error — a structurally-valid
//! document that breaks a rule the generic schema cannot state (`bundle "none"`
//! carrying metadata, an `extension-point` on a non-hosted bundle, a duplicate
//! `require` key or `test-obligation`, a kind name not matching its containing
//! directory). The last carries the source text and the offending node's span for
//! a labelled diagnostic.

use miette::{Diagnostic, NamedSource, SourceSpan};
use thiserror::Error;

/// Convenience alias for fallible app-kind operations.
pub type Result<T> = std::result::Result<T, AppKindError>;

/// Everything that can go wrong loading, parsing, or validating an app-kind.
#[derive(Debug, Error, Diagnostic)]
pub enum AppKindError {
    /// Filesystem error reading a `kind.apiw` file or the `app-kinds/` directory.
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
    /// KDL-Schema validator run against `app-kind.kdl-schema`.
    #[error(transparent)]
    #[diagnostic(transparent)]
    Schema(#[from] apianyware_spec_format::SpecFormatError),

    /// The app-kind name does not match its containing directory
    /// (`app-kinds/<name>/kind.apiw`), which `app-kind.kdl-schema` requires the
    /// conforming loader to check. Raised by the registry (the path-aware entry).
    #[error("app-kind name `{name}` does not match its directory `{dir}` (expected `app-kind \"{dir}\"`)")]
    #[diagnostic(code(apianyware::app_kinds::name_mismatch))]
    NameMismatch {
        /// The name authored in `kind.apiw`.
        name: String,
        /// The containing directory's name.
        dir: String,
    },

    /// A structurally-valid document that violates an app-kind semantic rule the
    /// generic schema cannot express (`bundle "none"` carrying metadata, an
    /// `extension-point` on a non-hosted bundle, a duplicate `require` key or
    /// `test-obligation`).
    #[error("{}", .message)]
    #[diagnostic(code(apianyware::app_kinds))]
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

impl AppKindError {
    /// Build a located app-kind semantic error against a node span.
    pub(crate) fn apiw(
        source_name: &str,
        source_text: &str,
        span: SourceSpan,
        message: impl Into<String>,
    ) -> Self {
        AppKindError::Apiw {
            message: message.into(),
            src: NamedSource::new(source_name, source_text.to_string()),
            span,
        }
    }
}
