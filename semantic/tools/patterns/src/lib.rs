//! The semantic **pattern-kind registry** (ADR-0048, workstream 3).
//!
//! A **pattern-kind** is the reusable, framework- *and* target-independent
//! definition of a semantic shape — a set of roles + a set of laws — authored
//! once as `semantic/pattern-kinds/<name>.apiw`. One entity covers both
//! *behavioral* contracts (`bracket`, `observer`) and *structural* relationships
//! (`parent-child`, `callback-destroy-notifier`): relationships are the
//! degenerate case, folded in rather than a sibling entity (D4). This crate is
//! the *kind* layer only — binding a kind to a concrete framework (the
//! *instance*, with provenance) is platform knowledge, carried elsewhere (D1).
//!
//! The concerns, one per module:
//!
//! - [`kind`] — the typed model: [`PatternKind`], [`Role`], [`Law`], … .
//! - [`vocab`] — REFACTOR §30's controlled law vocabularies (the DP1 spine: a
//!   law is non-vacuous because its tokens come from these fixed sets).
//! - [`schema`] — **structural** validation against the language-neutral
//!   `pattern-kinds.kdl-schema`, reusing `apianyware-spec-format`'s generic
//!   KDL-Schema engine (ADR-0048 D7; ADR-0046 §3).
//! - [`apiw`] — the `.apiw` (KDL 2.0) parser + the **semantic** checks the schema
//!   cannot state (token∈category, ordering-edge role resolution, role-name
//!   uniqueness, at-most-one primary role).
//! - [`registry`] — [`PatternKindRegistry`]: load a directory of authored kinds.
//! - [`instance`] — validate a `PatternInstance` (the carriage, in
//!   `apianyware-types`) against the registry, and resolve its DP3 home via the
//!   kind's designated primary role (workstream-3 child 2).

pub mod apiw;
pub mod error;
pub mod instance;
pub mod kind;
pub mod registry;
pub mod schema;
pub mod vocab;

pub use error::{PatternError, Result};
pub use instance::InstanceError;
pub use kind::{BeforeEdge, Cardinality, Law, LawCategory, Ordering, PatternKind, Role, RoleBinds};
pub use registry::PatternKindRegistry;
pub use schema::validate_pattern_kind;
