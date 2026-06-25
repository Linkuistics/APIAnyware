//! The shared **target-model** layer (`structural-refactoring` grove, workstream 6;
//! node-brief decisions D1–D7).
//!
//! `targets/<t>/` carries an authored knowledge layer over each already-built,
//! VM-verified binding (racket / chez / gerbil / sbcl): a per-implementation
//! **descriptor**, a **capability profile**, an **idiom catalogue**, **projection
//! policies**, an **adapter spec**, and a **conformance report** (REFACTOR §17–§27,
//! §37). The *schema* of each entity is **target-independent** — only the authored
//! `.apiw` *data* differs across targets — so all of it lives in **one** shared crate
//! (decision D5; the ws4 one-crate/submodules `apianyware-platform-tests` precedent),
//! with the per-target `.apiw` files as data under `targets/<t>/`.
//!
//! Projection lives **here**, never in `platforms/` or `semantic/` (the domain rule):
//! the target model is ws6's one new surface — it *consumes* the semantic pattern
//! model, the platform app-kinds, and the platform §30 source-weirdness, and authors
//! none of them.
//!
//! ## Submodules (one per entity, grown lazily)
//!
//! - [`descriptor`] — the §17 per-implementation **target descriptor**
//!   (`target.apiw`): the `family` / `dialect` / `implementation` / `ffi-backend` /
//!   `runtime-model` / `projection-policy` / `adapter-strategy` facets, their parser,
//!   focused validator, and the directory registry. *(Child `target-descriptor-k51`.
//!   Named `descriptor` rather than `target` because the stock Rust `target/`
//!   build-dir gitignore would otherwise swallow the source.)*
//! - [`capability`] — the §20 per-implementation **capability profile**
//!   (`capability.apiw`): the authored `dimension → rung` ratings across the two faces
//!   (semantic + app-form), their parser, focused validator, and registry. *(Child
//!   `capability-k52`.)* Backed by two shared crate-level modules:
//!   - [`vocab`] — the §20 capability dimensions (the two faces' controlled
//!     vocabularies) + the target-independent `weirdness → capability` map.
//!   - [`derive`] — the unified 7-rung [`Representability`](derive::Representability)
//!     ladder + the **representability floor** that derives a per-API status from a
//!     profile and the platform §30 weirdness an API carries.
//!
//! - [`idioms`] — the §21 per-implementation **idiom catalogue**
//!   (`idioms/catalogue.apiw`): the source-concept → target-construct map + the
//!   per-pattern-kind emit dispatch the shared `emit/pattern_dispatch` classifier
//!   consumes, their parser, focused validator, and registry. The §21 idiom *categories*
//!   are a controlled vocab in [`vocab`]. *(Child `idioms-k53`.)*
//!
//! Later ws6 children add `policy/`, `adapter_spec/`, and `conformance/` submodules
//! (extending `derive` with conformance-coverage derivation) to **this same crate**.
//!
//! Each entity follows the three-layer validation the platform-model crates
//! established (ADR-0046 §3): **structural** against a language-neutral
//! `schemas/spec-format/<entity>.kdl-schema` via the generic engine in
//! `apianyware-spec-format`, then **semantic** in-crate checks the schema cannot
//! state, then a **registry** identity check (`<entity> "<id>"` == containing
//! directory). The Rust types are *one* conforming implementation of the schema, not
//! its source of truth; **ws8** owns the *machine* JSON Schema + validation tooling/CI.

pub mod capability;
pub mod derive;
pub mod descriptor;
pub mod error;
pub mod idioms;
pub mod vocab;

pub use capability::{
    parse_capability, validate_capability, CapabilityEntry, CapabilityProfile, CapabilityRegistry,
};
pub use derive::{representability, Representability};
pub use descriptor::{
    parse_target, validate_target, RuntimeModel, TargetDescriptor, TargetRegistry,
};
pub use error::{Result, TargetModelError};
pub use idioms::{
    parse_idioms, validate_idioms, EmitConstruct, Idiom, IdiomCatalogue, IdiomCatalogueRegistry,
    Projection,
};
pub use vocab::{capability_for, is_valid_dimension, is_valid_idiom_category, Face};
