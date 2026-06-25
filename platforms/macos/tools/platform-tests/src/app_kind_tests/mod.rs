//! The **app-kind test-obligation** family: the obligation bodies that resolve the
//! `test-obligation` refs the seven app-kinds declare.
//!
//! One file per kind, `platforms/macos/tests/app-kinds/<kind>.apiw`, declaring the
//! `obligation` bodies — each a set of projection-free `expect`ations of what a
//! program of that kind must satisfy, plus the `fixture`s it reads. Identity is the
//! file **stem** (these are flat files; every kind's obligations live in one file
//! named for the kind), and the obligations a file declares must **exactly resolve**
//! the `test-obligation` refs in `app-kinds/<kind>/kind.apiw` (ADR-0049 ws9 seam) —
//! a cross-entity invariant the standing `tests/` guard checks against the
//! `apianyware-app-kinds` registry.
//!
//! The three concerns mirror `apianyware-app-kinds`, one per module:
//!
//! - [`model`] — the typed model: [`AppKindTests`], [`Obligation`], [`Expectation`].
//! - [`schema`] — **structural** validation against the language-neutral
//!   `app-kind-tests.kdl-schema` (the generic KDL-Schema engine, ADR-0046 §3).
//! - [`apiw`] — the `.apiw` (KDL 2.0) parser + the **semantic** checks the schema
//!   cannot state (`obligation` names unique; `expect` ids unique within an
//!   obligation).
//! - [`registry`] — [`AppKindTestsRegistry`]: load a directory of authored
//!   `<kind>.apiw` files, each asserting `app-kind-tests "<name>"` matches its stem.

pub mod apiw;
pub mod model;
pub mod registry;
pub mod schema;

pub use apiw::parse_app_kind_tests;
pub use model::{AppKindTests, Expectation, Obligation};
pub use registry::AppKindTestsRegistry;
pub use schema::validate_app_kind_tests;
