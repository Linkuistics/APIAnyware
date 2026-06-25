//! The §17 **target descriptor** entity (`targets/<t>/target.apiw`; node-brief D4).
//!
//! A descriptor is the per-*implementation* model of one target: the seven §17
//! distinguishing facets — `family` / `dialect` / `implementation` / `ffi-backend` /
//! `runtime-model` / `projection-policy` / `adapter-strategy` — stated as authored
//! data. `targets/<t>/` is **one implementation**; the directory is flat and no
//! `implementations/` subdir is materialized until a *second* implementation of one
//! language lands (lazy — D4). Family grouping (e.g. the CL-family interface
//! contract) is the `family` facet plus the `_shared` family doc, not a
//! `targets/<family>/<impl>/` directory.
//!
//! The concerns, one per module:
//!
//! - [`model`] — the typed [`TargetDescriptor`] + the one controlled-vocabulary enum
//!   [`RuntimeModel`] (the ADR-0015 interpreted-vs-compiled FFI execution model).
//! - [`schema`] — **structural** validation against the language-neutral
//!   `schemas/spec-format/target.kdl-schema`, via the generic KDL-Schema engine.
//! - [`apiw`] — the `.apiw` (KDL 2.0) parser + the **semantic** checks the schema
//!   cannot state (non-blank facet tokens).
//! - [`registry`] — [`TargetRegistry`]: load a tree of `targets/<id>/target.apiw`,
//!   each asserting `target "<id>"` matches its containing directory.

pub mod apiw;
pub mod model;
pub mod registry;
pub mod schema;

pub use apiw::parse_target;
pub use model::{RuntimeModel, TargetDescriptor};
pub use registry::TargetRegistry;
pub use schema::validate_target;
