//! The §21 **idiom catalogue** entity (`targets/<t>/idioms/catalogue.apiw`; node-brief
//! D3) — the authored, per-target answer to "*when the platform docs say X, how does that
//! appear in this target?*", and the **data-driven dispatch** the shared
//! `emit/pattern_dispatch` classifier consumes in place of its former hardcoded match.
//!
//! A catalogue maps a §21 idiom **category** ([`crate::vocab::IDIOM_CATEGORIES`]) to this
//! target's construct, and — for the minority of categories with an emit projection —
//! maps the ws3 pattern-**kinds** that category projects to an [`EmitConstruct`] + a
//! generated identifier. Two axes meet here: the *source-concept* category (coarse, §21)
//! and the *pattern-kind* projection (finer, ws3); a category may project several kinds.
//!
//! Authoring the catalogue is **golden-neutral** (node-brief D3): `classify_pattern` has
//! zero callers and every emitter is pattern-blind today, so relocating its mapping from
//! Rust into authored `.apiw` data moves no generated output. *Applying* projection
//! (emitters consuming pattern-instances to emit wrappers) is the deferred,
//! golden-INTENTIONAL follow-on.
//!
//! The concerns, one per module — the same three-layer structure as the sibling
//! `descriptor` / `capability` submodules:
//!
//! - [`model`] — the typed [`IdiomCatalogue`] + its [`Idiom`] / [`Projection`] entries and
//!   the closed [`EmitConstruct`] taxonomy. The §21 idiom *categories* are a controlled
//!   *vocab* in [`crate::vocab`].
//! - [`schema`] — **structural** validation against the language-neutral
//!   `schemas/spec-format/idioms.kdl-schema`, via the generic KDL-Schema engine.
//! - [`apiw`] — the `.apiw` (KDL 2.0) parser + the **semantic** checks the schema cannot
//!   state (the §21 category vocabulary, category uniqueness, per-catalogue kind
//!   uniqueness).
//! - [`registry`] — [`IdiomCatalogueRegistry`]: load a tree of
//!   `targets/<id>/idioms/catalogue.apiw`, each asserting `idiom-catalogue "<id>"` matches
//!   its target directory (the grandparent of the file — the one identity divergence the
//!   `idioms/docs/` layout forces).

pub mod apiw;
pub mod model;
pub mod registry;
pub mod schema;

pub use apiw::parse_idioms;
pub use model::{EmitConstruct, Idiom, IdiomCatalogue, Projection};
pub use registry::IdiomCatalogueRegistry;
pub use schema::validate_idioms;
