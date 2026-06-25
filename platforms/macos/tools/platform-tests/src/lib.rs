//! The macOS **platform test-declaration registry** (`structural-refactoring`
//! grove, workstream 4; node-brief decisions D3/D6).
//!
//! A platform test declaration is the **declaration half** of a platform-level
//! semantic test (REFACTOR §14/§33): projection-free, target-independent statements
//! of what a macOS API semantic or app-kind obligation *must hold*. They are
//! authored and schema-validated here but **not executed** — the runner and the
//! TestAnyware/AppSpec integration that drive a declaration against a *running*
//! target binding are workstream 9 (the declare-now / execute-later seam, node-brief
//! D3). They are platform truth, never a target projection (`targets/`, ws6) and
//! never a representability status (ws6/§20, node-brief D4).
//!
//! There are **two declaration families** — distinct entities sharing only this
//! mechanism (node-brief D6, the ADR-0049 distinct-entity precedent), each
//! contracted by its own sibling KDL-Schema under `schemas/spec-format/` and
//! validated by its own focused validator in its own submodule:
//!
//! - [`app_kind_tests`] — the obligation **bodies** that resolve the
//!   `test-obligation` refs the seven app-kinds declare
//!   (`tests/app-kinds/<kind>.apiw`; `app-kind-tests.kdl-schema`).
//! - [`api_semantics`] — per convention facet (ownership / callbacks / threading /
//!   errors), the §30 source-semantic weirdness a concrete `(receiver, selector)`
//!   shape exhibits plus the projection-free expectations a binding must preserve
//!   (`tests/api-semantics/<facet>.apiw`; `api-semantics.kdl-schema`). The §30
//!   `weirdness` vocabulary is facet-conditional, so it is a semantic-layer check
//!   ([`api_semantics::vocab`]), not a schema `enum`.
//!
//! Each family follows the same three-layer template as `apianyware-app-kinds` and
//! `apianyware-patterns`: **structural** validation against the embedded KDL-Schema
//! (the generic engine `apianyware-spec-format` exposes), **semantic** checks the
//! generic schema cannot state, and a **registry** that loads a directory of
//! authored declarations. The app-kind-tests cross-entity invariant — an app-kind's
//! obligation bodies exactly resolve its `kind.apiw` `test-obligation` refs — lives
//! in the standing `tests/` guard, which loads the `apianyware-app-kinds` registry
//! too; api-semantics files are self-contained (no cross-entity ref).
//!
//! Both families carry an `Expectation` (`{id, doc}`) — the same shape, but distinct
//! entities (node-brief D6), so each owns its own type. To keep the crate root
//! unambiguous, only [`app_kind_tests::Expectation`] is re-exported here; the
//! api-semantics one is reached as [`api_semantics::Expectation`].

pub mod api_semantics;
pub mod app_kind_tests;
pub mod error;

pub use api_semantics::{
    parse_api_semantics, validate_api_semantics, Api, ApiSemantics, ApiSemanticsRegistry, Facet,
};
pub use app_kind_tests::{
    parse_app_kind_tests, validate_app_kind_tests, AppKindTests, AppKindTestsRegistry, Expectation,
    Obligation,
};
pub use error::{PlatformTestError, Result};
