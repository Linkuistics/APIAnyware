//! Error type for the platform-manifest crate.
//!
//! NOTE: `miette-derive` (7.x) generates `Display`/`labels()` code for the
//! `#[source_code]` / `#[label]` / `#[error]` fields that trips a spurious
//! `unused_assignments` lint, attributed back to the field declarations. The
//! fields are genuinely read by the generated impls. This module is pure type
//! definitions plus one trivial constructor, so a module-scoped `allow` is a
//! tight, safe place to suppress the false positive without masking real ones.
#![allow(unused_assignments)]
//!
//! The failure shapes mirror the sibling `apianyware-patterns` crate: a
//! filesystem error loading the manifest file; a *syntactic* KDL error (forwarded
//! from the `kdl` crate, which produces rich `miette` diagnostics); a *structural*
//! schema violation (forwarded from `spec-format`'s generic KDL-Schema validator
//! run against `platform.kdl-schema`); and a *semantic* manifest error — a
//! structurally-valid document that breaks a rule the generic schema cannot state
//! (a duplicate `ignore` framework name). The last carries the source text and the
//! offending node's span for a labelled diagnostic.

use miette::{Diagnostic, NamedSource, SourceSpan};
use thiserror::Error;

/// Convenience alias for fallible platform-manifest operations.
pub type Result<T> = std::result::Result<T, PlatformManifestError>;

/// Everything that can go wrong loading, parsing, or validating a platform manifest.
#[derive(Debug, Error, Diagnostic)]
pub enum PlatformManifestError {
    /// Filesystem error reading a `platform.apiw` manifest file.
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
    /// KDL-Schema validator run against `platform.kdl-schema`.
    #[error(transparent)]
    #[diagnostic(transparent)]
    Schema(#[from] apianyware_spec_format::SpecFormatError),

    /// The platform name does not match its containing directory
    /// (`platforms/<name>/`), which `platform.kdl-schema` requires the conforming
    /// loader to check. Raised only by [`crate::load`] (the path-aware entry);
    /// [`crate::load_str`] cannot check it.
    #[error("platform name `{name}` does not match its directory `{dir}` (expected `platform \"{dir}\"`)")]
    #[diagnostic(code(apianyware::platform_manifest::name_mismatch))]
    NameMismatch {
        /// The name authored in the manifest.
        name: String,
        /// The containing directory's name.
        dir: String,
    },

    /// A structurally-valid document that violates a manifest semantic rule the
    /// generic schema cannot express (a duplicate `ignore` framework name, a
    /// duplicate `subframework-allow`, or a framework in both `ignore` and
    /// `subframework-allow`).
    #[error("{}", .message)]
    #[diagnostic(code(apianyware::platform_manifest))]
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

impl PlatformManifestError {
    /// Build a located manifest semantic error against a node span.
    pub(crate) fn apiw(
        source_name: &str,
        source_text: &str,
        span: SourceSpan,
        message: impl Into<String>,
    ) -> Self {
        PlatformManifestError::Apiw {
            message: message.into(),
            src: NamedSource::new(source_name, source_text.to_string()),
            span,
        }
    }
}
