//! The shared error type for the target-model crate.
//!
//! NOTE: `miette-derive` (7.x) generates `Display`/`labels()` code for the
//! `#[source_code]` / `#[label]` / `#[error]` fields that trips a spurious
//! `unused_assignments` lint, attributed back to the field declarations. The fields
//! are genuinely read by the generated impls, so a module-scoped `allow` is a tight,
//! safe place to suppress the false positive without masking real ones (the sibling
//! `apianyware-app-kinds` / `apianyware-platform-tests` crates do the same).
#![allow(unused_assignments)]
//!
//! The failure shapes mirror those sibling crates: a filesystem error loading an
//! authored `.apiw` file or its directory; a *syntactic* KDL error (forwarded from
//! the `kdl` crate's rich `miette` diagnostics); a *structural* schema violation
//! (forwarded from `spec-format`'s generic KDL-Schema validator run against the
//! entity's `.kdl-schema`); a *registry* identity mismatch (`<entity> "<id>"` does
//! not match its containing directory); and a *semantic* error — a structurally-valid
//! document that breaks a coherence rule the generic schema cannot state — carrying
//! the source text and the offending node's span for a labelled diagnostic.

use miette::{Diagnostic, NamedSource, SourceSpan};
use thiserror::Error;

/// Convenience alias for fallible target-model operations.
pub type Result<T> = std::result::Result<T, TargetModelError>;

/// Everything that can go wrong loading, parsing, or validating a target-model
/// `.apiw` entity.
#[derive(Debug, Error, Diagnostic)]
pub enum TargetModelError {
    /// Filesystem error reading an authored `.apiw` file or a target directory.
    #[error("I/O error for {path}")]
    Io {
        /// The path that failed.
        path: String,
        /// The underlying OS error.
        #[source]
        source: std::io::Error,
    },

    /// Syntactic KDL parse failure. Forwards the `kdl` crate's diagnostic (source
    /// span + help) unchanged.
    #[error(transparent)]
    #[diagnostic(transparent)]
    Kdl(#[from] kdl::KdlError),

    /// Structural schema violation, forwarded from the `spec-format` generic
    /// KDL-Schema validator run against the entity's `.kdl-schema`.
    #[error(transparent)]
    #[diagnostic(transparent)]
    Schema(#[from] apianyware_spec_format::SpecFormatError),

    /// The authored id does not match its containing directory
    /// (e.g. `targets/<id>/target.apiw` whose `target "<name>"` ≠ `<id>`). Raised by
    /// the registry (the path-aware entry).
    #[error(
        "{entity} id `{name}` does not match its directory `{dir}` (expected `{entity} \"{dir}\"`)"
    )]
    #[diagnostic(code(apianyware::target_model::id_mismatch))]
    IdMismatch {
        /// The entity kind (e.g. `"target"`), for the message.
        entity: &'static str,
        /// The id authored in the `.apiw` file.
        name: String,
        /// The containing directory's name.
        dir: String,
    },

    /// A structurally-valid document that violates a target-model semantic rule the
    /// generic schema cannot express (a missing required facet, a blank token, an
    /// unexpected node). Carries the source span for a labelled diagnostic.
    #[error("{}", .message)]
    #[diagnostic(code(apianyware::target_model))]
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

impl TargetModelError {
    /// Build a located target-model semantic error against a node span.
    pub(crate) fn apiw(
        source_name: &str,
        source_text: &str,
        span: SourceSpan,
        message: impl Into<String>,
    ) -> Self {
        TargetModelError::Apiw {
            message: message.into(),
            src: NamedSource::new(source_name, source_text.to_string()),
            span,
        }
    }
}
