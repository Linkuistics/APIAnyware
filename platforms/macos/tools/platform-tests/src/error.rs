//! Error type for the platform test-declaration crate.
//!
//! NOTE: `miette-derive` (7.x) generates `Display`/`labels()` code for the
//! `#[source_code]` / `#[label]` / `#[error]` fields that trips a spurious
//! `unused_assignments` lint, attributed back to the field declarations. The fields
//! are genuinely read by the generated impls. This module is pure type definitions
//! plus one trivial constructor, so a module-scoped `allow` is a tight, safe place
//! to suppress the false positive without masking real ones.
#![allow(unused_assignments)]
//!
//! The failure shapes mirror the sibling `apianyware-app-kinds` and
//! `apianyware-platform-manifest` crates: a filesystem error loading a declaration
//! file or its directory; a *syntactic* KDL error (forwarded from the `kdl` crate,
//! which produces rich `miette` diagnostics); a *structural* schema violation
//! (forwarded from `spec-format`'s generic KDL-Schema validator run against a
//! family's `.kdl-schema`); and a *semantic* error — a structurally-valid document
//! that breaks a rule the generic schema cannot state (a duplicate `obligation`
//! name or `expect` id, a declaration name not matching its file stem). The last
//! carries the source text and the offending node's span for a labelled diagnostic.

use miette::{Diagnostic, NamedSource, SourceSpan};
use thiserror::Error;

/// Convenience alias for fallible platform-test operations.
pub type Result<T> = std::result::Result<T, PlatformTestError>;

/// Everything that can go wrong loading, parsing, or validating a platform test
/// declaration.
#[derive(Debug, Error, Diagnostic)]
pub enum PlatformTestError {
    /// Filesystem error reading a declaration `.apiw` file or a `tests/` directory.
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
    /// KDL-Schema validator run against a family's `.kdl-schema`.
    #[error(transparent)]
    #[diagnostic(transparent)]
    Schema(#[from] apianyware_spec_format::SpecFormatError),

    /// The declaration's name does not match its file stem — an app-kind-tests
    /// `tests/app-kinds/<kind>.apiw` whose `<kind>` ≠ stem, or an api-semantics
    /// `tests/api-semantics/<facet>.apiw` whose `<facet>` ≠ stem. Raised by either
    /// registry (the path-aware entry), since identity is the flat-file stem (each
    /// file is named for the kind / facet it declares).
    #[error(
        "declaration name `{name}` does not match its file stem `{stem}` (expected `\"{stem}\"`)"
    )]
    #[diagnostic(code(apianyware::platform_tests::name_mismatch))]
    NameMismatch {
        /// The name authored in the declaration.
        name: String,
        /// The file stem it should match.
        stem: String,
    },

    /// A structurally-valid document that violates a semantic rule the generic
    /// schema cannot express (a duplicate `obligation` name or `expect` id).
    #[error("{}", .message)]
    #[diagnostic(code(apianyware::platform_tests))]
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

impl PlatformTestError {
    /// Build a located semantic error against a node span.
    pub(crate) fn apiw(
        source_name: &str,
        source_text: &str,
        span: SourceSpan,
        message: impl Into<String>,
    ) -> Self {
        PlatformTestError::Apiw {
            message: message.into(),
            src: NamedSource::new(source_name, source_text.to_string()),
            span,
        }
    }
}
