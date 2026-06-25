//! The §20 **capability profile** entity (`targets/<t>/capability.apiw`; node-brief
//! D2) — the authored, **platform-independent** statement of what one implementation
//! *can express*, and the input to the derived representability status.
//!
//! A profile maps a §20 capability **dimension** to a [`Representability`](crate::derive)
//! ladder rung across two faces (a per-API **semantic** face that feeds the
//! representability floor, and an **app-form** face that feeds per-app-kind
//! feasibility). It describes the *implementation*, so it is reusable across platforms;
//! the macOS binding happens in [`crate::derive`] (which reads platform §30 weirdness),
//! never here.
//!
//! The concerns, one per module — the same three-layer structure as the sibling
//! `descriptor` submodule:
//!
//! - [`model`] — the typed [`CapabilityProfile`] + its [`CapabilityEntry`] ratings. The
//!   one controlled-vocabulary enum, [`Representability`](crate::derive), lives in
//!   [`crate::derive`] (it is shared with the floor); the §20 capability dimensions are
//!   a controlled *vocab* in [`crate::vocab`].
//! - [`schema`] — **structural** validation against the language-neutral
//!   `schemas/spec-format/capability.kdl-schema`, via the generic KDL-Schema engine.
//! - [`apiw`] — the `.apiw` (KDL 2.0) parser + the **semantic** checks the schema
//!   cannot state (face-conditional dimension vocabulary, per-face uniqueness).
//! - [`registry`] — [`CapabilityRegistry`]: load a tree of
//!   `targets/<id>/capability.apiw`, each asserting `capability "<id>"` matches its
//!   containing directory.

pub mod apiw;
pub mod model;
pub mod registry;
pub mod schema;

pub use apiw::parse_capability;
pub use model::{CapabilityEntry, CapabilityProfile};
pub use registry::CapabilityRegistry;
pub use schema::validate_capability;
