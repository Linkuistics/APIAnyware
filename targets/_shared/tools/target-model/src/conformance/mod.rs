//! The §37 **conformance report** entity (`targets/<t>/conformance/<platform>.apiw` + derived;
//! node-brief D1, child `conformance-k55`) — the last authored target-model entity and the
//! first **hybrid** one: part authored *judgment*, part *derived* reality.
//!
//! - The **authored judgment slice** ([`ConformanceReport`], committed `.apiw`) carries the
//!   §37 per-app-kind `app-support` call, the `unsupported` features, the `research` items, and
//!   the `known issues` — what a human (or accepted-LLM) decides, which a machine cannot derive.
//! - The **derived slice** ([`crate::derive`], uncommitted) is the §37 per-API *coverage*
//!   (the [`representability_histogram`](crate::derive::representability_histogram) over the
//!   platform's weird-API surface) and the common *app-implementation status*
//!   ([`derive_app_statuses`](crate::derive::derive_app_statuses) over the shipped
//!   `app-implementations/` + VM-verify `reports/`). It is recomputable, so it is never
//!   committed (constraint 4, no rot).
//! - [`crosscheck`] reconciles the two — the novel bit of this entity — catching an authored
//!   claim that contradicts the derived reality (the brief's example: an authored `unsupported`
//!   against a passing VM-verify report).
//!
//! Projection / representability lives in `targets/`, never `platforms/` (the domain rule):
//! the report's derived slice *consumes* the platform §30 weirdness (via the
//! [`crate::derive`] floor) and the platform never carries a status. The report-generating CLI
//! `apianyware-conformance` is the consumer that wires the platform api-semantics registry to
//! this crate (the seam ADR-0051 §5 named).
//!
//! The authored slice follows the same three-layer structure as the sibling `policy` /
//! `adapter_spec` / `capability` submodules:
//!
//! - [`model`] — the typed [`ConformanceReport`] + its [`AppSupport`] / [`JudgmentItem`]
//!   entries. The support [`status`](AppSupport::status) re-uses the §37
//!   [`ConformanceStatus`](crate::derive::ConformanceStatus) ladder from [`crate::derive`].
//! - [`schema`] — **structural** validation against the language-neutral
//!   `schemas/spec-format/conformance.kdl-schema`, via the generic KDL-Schema engine.
//! - [`apiw`] — the `.apiw` (KDL 2.0) parser + the **semantic** checks the schema cannot state
//!   (the §36 app-kind vocabulary, per-report / per-entry uniqueness).
//! - [`registry`] — [`ConformanceRegistry`]: load a tree of
//!   `targets/<id>/conformance/<platform>.apiw`, each asserting its id matches its target
//!   directory (the grandparent) and its `platform` matches the file stem.
//! - [`crosscheck`] — the authored-vs-derived reconciliation.

pub mod apiw;
pub mod crosscheck;
pub mod model;
pub mod registry;
pub mod schema;

pub use apiw::parse_conformance;
pub use crosscheck::{crosscheck, Contradiction};
pub use model::{AppSupport, ConformanceReport, JudgmentItem};
pub use registry::ConformanceRegistry;
pub use schema::validate_conformance;
