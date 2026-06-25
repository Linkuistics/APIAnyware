//! The **api-semantics** family: per convention facet (ownership / callbacks /
//! threading / errors), the §30 source-semantic weirdness a concrete macOS API shape
//! exhibits plus the projection-free expectations a binding must preserve.
//!
//! One file per facet, `platforms/macos/tests/api-semantics/<facet>.apiw`, declaring
//! `api "<receiver>" "<selector>"` shapes — each carrying its §30 `weirdness` tag(s)
//! and `expect` bodies. Identity is the file **stem** (these are flat files, one per
//! facet, named for the facet). An api-semantics declaration is a **distinct entity**
//! from an app-kind-tests declaration — an API-facet property, not a process/bundle
//! obligation — sharing only this crate's three-layer mechanism (node-brief D6,
//! ADR-0049 distinct-entity precedent).
//!
//! The four concerns mirror the sibling [`super::app_kind_tests`] family, one per
//! module:
//!
//! - [`model`] — the typed model: [`ApiSemantics`], [`Api`], [`Expectation`],
//!   [`Facet`].
//! - [`vocab`] — the facet-conditional §30 `weirdness` controlled vocabulary (the
//!   semantic check the language-neutral schema cannot state).
//! - [`schema`] — **structural** validation against the language-neutral
//!   `api-semantics.kdl-schema` (the generic KDL-Schema engine, ADR-0046 §3).
//! - [`apiw`] — the `.apiw` (KDL 2.0) parser + the **semantic** checks the schema
//!   cannot state (facet-conditional `weirdness` membership + de-duplication;
//!   `(receiver, selector)` unique; `expect` ids unique within a shape).
//! - [`registry`] — [`ApiSemanticsRegistry`]: load a directory of authored
//!   `<facet>.apiw` files, each asserting `api-semantics "<facet>"` matches its stem.

pub mod apiw;
pub mod model;
pub mod registry;
pub mod schema;
pub mod vocab;

pub use apiw::parse_api_semantics;
pub use model::{Api, ApiSemantics, Expectation, Facet};
pub use registry::ApiSemanticsRegistry;
pub use schema::validate_api_semantics;
