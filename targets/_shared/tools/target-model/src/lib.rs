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
//!   focused validator, and the directory registry. *(This child —
//!   `target-descriptor-k51`. Named `descriptor` rather than `target` because the
//!   stock Rust `target/` build-dir gitignore would otherwise swallow the source.)*
//!
//! Later ws6 children add `capability/`, `idioms/`, `policy/`, `adapter_spec/`, and
//! `conformance/` submodules + a shared `vocab` (§20 capability dimensions +
//! `weirdness → capability` map) and `derive` (representability floor + conformance
//! coverage) to **this same crate**.
//!
//! Each entity follows the three-layer validation the platform-model crates
//! established (ADR-0046 §3): **structural** against a language-neutral
//! `schemas/spec-format/<entity>.kdl-schema` via the generic engine in
//! `apianyware-spec-format`, then **semantic** in-crate checks the schema cannot
//! state, then a **registry** identity check (`<entity> "<id>"` == containing
//! directory). The Rust types are *one* conforming implementation of the schema, not
//! its source of truth; **ws8** owns the *machine* JSON Schema + validation tooling/CI.

pub mod descriptor;
pub mod error;

pub use descriptor::{
    parse_target, validate_target, RuntimeModel, TargetDescriptor, TargetRegistry,
};
pub use error::{Result, TargetModelError};
