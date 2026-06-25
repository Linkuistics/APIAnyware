//! The macOS **app-kind registry** (`structural-refactoring` grove, workstream 4;
//! node-brief decision D2).
//!
//! An **app-kind** is the authored, projection-free definition of one *kind* of
//! macOS application — `cli-tool`, `gui-app`, `menu-bar-daemon`, `launch-agent`,
//! `spotlight-importer`, `quicklook-extension`, `finder-sync-extension` — as
//! **process-model truth**: how a program of this kind starts, runs, and stops
//! (`process`); how it presents to the window server (`activation`); what on-disk
//! container + Info.plist keys it requires (`bundle`); and which platform-level
//! test obligations it carries (`test-obligation`). It states what the kind *is*,
//! never how any target language builds it (REFACTOR §13/§14; the domain rule).
//!
//! An app-kind is a **distinct entity** from a semantic pattern-kind (an API-usage
//! axis, `semantic/`) and from a common app-spec (one concrete app that *names* its
//! kind, `apps/macos/`, workstream 7). This crate mirrors the `apianyware-patterns`
//! mechanism — parse + KDL-Schema + controlled vocab + focused validator + a
//! directory registry — without reusing its entity.
//!
//! Each kind is one directory `app-kinds/<kind>/kind.apiw`; the kind's stable
//! identity is its **containing directory** name (every file is named `kind.apiw`).
//! The concerns, one per module:
//!
//! - [`kind`] — the typed model: [`AppKind`], [`ProcessModel`], [`BundleModel`],
//!   and the controlled-vocabulary enums ([`EntryModel`], [`RunLoopModel`],
//!   [`TerminationModel`], [`ActivationPolicy`], [`BundleType`]).
//! - [`schema`] — **structural** validation against the language-neutral
//!   `app-kind.kdl-schema`, reusing `apianyware-spec-format`'s generic KDL-Schema
//!   engine (ADR-0046 §3).
//! - [`apiw`] — the `.apiw` (KDL 2.0) parser + the **semantic** checks the schema
//!   cannot state (`bundle "none"` carries no metadata; `extension-point` implies a
//!   hosted bundle; `require` / `test-obligation` uniqueness).
//! - [`registry`] — [`AppKindRegistry`]: load a directory of authored kinds, each
//!   asserting `app-kind "<name>"` matches its containing directory.

pub mod apiw;
pub mod error;
pub mod kind;
pub mod registry;
pub mod schema;

pub use apiw::parse_kind;
pub use error::{AppKindError, Result};
pub use kind::{
    ActivationPolicy, AppKind, BundleModel, BundleType, EntryModel, ProcessModel, RunLoopModel,
    TerminationModel,
};
pub use registry::AppKindRegistry;
pub use schema::validate_app_kind;
