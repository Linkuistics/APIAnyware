//! The §23 **projection policy** entity (`targets/<t>/policies/<platform>/projection.apiw`;
//! node-brief D1, child `policy-adapter-k54`) — the authored, per-platform statement of "*how
//! does this target map source semantics into target idioms?*", as a set of choices mapping a
//! projection concern to a point on the REFACTOR §24 direct-call-vs-adapter spectrum.
//!
//! Projection lives in `targets/`, never `platforms/` (the domain rule). The policy is
//! authored knowledge: which spectrum point a concern gets is a target-policy decision (the
//! racket trampoline-elision posture, the sbcl direct-msgSend posture), grounded in the
//! target's shipped binding + ADRs. Authoring it is **golden-neutral** — no emit consumer
//! reads it yet (a future projection-policy consumer would be golden-intentional, like the
//! deferred idiom apply-projection follow-on).
//!
//! The concerns, one per module — the same three-layer structure as the sibling `idioms` /
//! `capability` submodules:
//!
//! - [`model`] — the typed [`ProjectionPolicy`] + its [`ProjectionChoice`] entries and the
//!   closed [`SpectrumPoint`] taxonomy.
//! - [`schema`] — **structural** validation against the language-neutral
//!   `schemas/spec-format/policy.kdl-schema`, via the generic KDL-Schema engine.
//! - [`apiw`] — the `.apiw` (KDL 2.0) parser + the **semantic** check the schema cannot state
//!   (per-policy concern uniqueness).
//! - [`registry`] — [`ProjectionPolicyRegistry`]: load a tree of
//!   `targets/<id>/policies/<platform>/projection.apiw`, each asserting its id matches its
//!   target directory (the great-grandparent) and its `platform` matches the platform
//!   directory (the parent).

pub mod apiw;
pub mod model;
pub mod registry;
pub mod schema;

pub use apiw::parse_policy;
pub use model::{ProjectionChoice, ProjectionPolicy, SpectrumPoint};
pub use registry::ProjectionPolicyRegistry;
pub use schema::validate_policy;
