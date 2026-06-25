//! The §24–§26 **adapter spec** entity (`targets/<t>/adapters/<platform>/spec.apiw`;
//! node-brief D1, child `policy-adapter-k54`) — the authored description of one target's
//! *existing* native adapter library (the dylib the target grove built, sitting beside its
//! `sources/`).
//!
//! The spec states the library `output`, the §26 adapter **roles** it provides, the §26
//! runtime **services** it offers (each with a [`ServiceStatus`]), and the §26
//! **direct-call policy** (which API categories may bypass the adapter vs must route through
//! it). It *documents* the existing library — it does not author adapter code or redesign the
//! §25 ABI (node-brief D6). Authoring it is **golden-neutral** (no emit consumer reads it).
//!
//! The concerns, one per module — the same three-layer structure as the sibling `policy` /
//! `idioms` / `capability` submodules:
//!
//! - [`model`] — the typed [`AdapterSpec`] + its [`AdapterOutput`] / [`AdapterRole`] /
//!   [`RuntimeService`] / [`DirectCallPolicy`] entries and the closed [`ServiceStatus`]
//!   taxonomy. The §26 role + service *vocabularies* are in [`crate::vocab`].
//! - [`schema`] — **structural** validation against the language-neutral
//!   `schemas/spec-format/adapter-spec.kdl-schema`, via the generic KDL-Schema engine.
//! - [`apiw`] — the `.apiw` (KDL 2.0) parser + the **semantic** checks the schema cannot
//!   state (the §26 role/service vocabularies, their uniqueness, allow∩deny disjointness).
//! - [`registry`] — [`AdapterSpecRegistry`]: load a tree of
//!   `targets/<id>/adapters/<platform>/spec.apiw`, each asserting its id matches its target
//!   directory (the great-grandparent) and its `platform` matches the platform directory (the
//!   parent).

pub mod apiw;
pub mod model;
pub mod registry;
pub mod schema;

pub use apiw::parse_adapter_spec;
pub use model::{
    AdapterOutput, AdapterRole, AdapterSpec, DirectCallPolicy, DirectCallRule, RuntimeService,
    ServiceStatus,
};
pub use registry::AdapterSpecRegistry;
pub use schema::validate_adapter_spec;
