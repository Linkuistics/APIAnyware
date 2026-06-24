//! The typed pattern-kind model (ADR-0048): the reusable, framework- and
//! target-independent *definition* of a pattern or relationship.
//!
//! A [`PatternKind`] is a set of [`Role`]s (typed participant slots) and a set of
//! [`Law`]s (constraints drawn from REFACTOR §30's controlled vocabularies), plus
//! optional behavioral [`Ordering`] (a happens-before graph over role names). One
//! entity covers both *behavioral* contracts (`bracket`, `observer` — operation
//! roles + ordering/threading laws, §32) and *structural* relationships
//! (`parent-child`, `callback-destroy-notifier` — type/parameter roles +
//! ownership/lifetime/relationship laws, §31): relationships are the degenerate
//! case (no `ordering`), folded in rather than a sibling entity (D4).
//!
//! These are *kinds* only. Binding a kind's roles to a concrete framework's
//! participants — the *instance*, with its provenance stamp — is platform
//! knowledge carried in the machine triad, and is workstream-3 child 2's concern
//! (ADR-0048 D1); nothing here references a framework.

use serde::{Deserialize, Serialize};

/// A reusable pattern/relationship definition (`semantic/pattern-kinds/<name>.apiw`).
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct PatternKind {
    /// The kind's stable authored name (matches the file stem). The kind's
    /// identity; no content hash is needed (instance identity is a separate
    /// concern — ADR-0048).
    pub name: String,
    /// One-line human description. The only free prose at the kind top level.
    pub doc: Option<String>,
    /// The kind's roles, in declaration order. Role names are unique.
    pub roles: Vec<Role>,
    /// Behavioral sequencing over roles, if any (absent on structural kinds).
    pub ordering: Option<Ordering>,
    /// The kind's laws (§30-vocabulary constraints), in declaration order.
    pub laws: Vec<Law>,
}

impl PatternKind {
    /// The role with this name, if declared.
    pub fn role(&self, name: &str) -> Option<&Role> {
        self.roles.iter().find(|r| r.name == name)
    }

    /// Whether the kind declares any behavioral ordering — the structural-vs-
    /// behavioral distinction is "has operation roles + ordering" (§32) vs "only
    /// typed/parameter roles + relationship laws" (§31), unified under one type.
    pub fn is_behavioral(&self) -> bool {
        self.ordering.is_some() || self.roles.iter().any(|r| r.binds == RoleBinds::Operation)
    }
}

/// A named, typed participant slot in a pattern-kind.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Role {
    /// The role name (unique within its kind), e.g. `acquire`, `parent`.
    pub name: String,
    /// What kind of participant binds to this role at instance time.
    pub binds: RoleBinds,
    /// How many participants fill this role in an instance.
    pub cardinality: Cardinality,
}

/// What kind of participant a role binds to (ADR-0048 D5 — polymorphic
/// participants make composition uniform).
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum RoleBinds {
    /// A class / struct / protocol type.
    Type,
    /// A method / function / selector.
    Operation,
    /// A parameter of one operation — a single-operation-scoped relationship
    /// (DP2: `callback-destroy-notifier`'s roles all bind to one operation's
    /// parameters).
    Parameter,
    /// Another pattern-instance — composition (DP5: a `subscription`'s `destroy`
    /// role binds to a `callback-destroy-notifier` relationship-instance).
    Pattern,
}

/// How many participants fill a role in an instance.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum Cardinality {
    /// Exactly one.
    #[serde(rename = "1")]
    One,
    /// Zero or one.
    #[serde(rename = "?")]
    Optional,
    /// Zero or more.
    #[serde(rename = "*")]
    Many,
    /// One or more.
    #[serde(rename = "+")]
    AtLeastOne,
}

/// Behavioral sequencing: a happens-before graph over role names. Present on
/// behavioral kinds (`bracket`, `builder`), absent on structural relationships.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Ordering {
    /// The happens-before edges. Each names two declared roles.
    pub before: Vec<BeforeEdge>,
}

/// A single happens-before edge: `earlier` precedes `later` (both role names).
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct BeforeEdge {
    /// The role that must happen first.
    pub earlier: String,
    /// The role that must happen after.
    pub later: String,
}

/// A constraint drawn from one of REFACTOR §30's controlled weirdness
/// vocabularies. The [`category`](Law::category) selects the vocabulary; the
/// [`tokens`](Law::tokens) carry the controlled values (each ∈ the category's
/// §30 set — see [`crate::vocab`]); [`doc`](Law::doc) carries human nuance the
/// controlled tokens cannot.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Law {
    /// Which §30 vocabulary this law draws from.
    pub category: LawCategory,
    /// The controlled tokens asserted (each is a member of the category's set).
    pub tokens: Vec<String>,
    /// Human nuance the controlled tokens cannot capture. Optional.
    pub doc: Option<String>,
}

/// The §30 weirdness vocabulary a [`Law`] draws from. DP1: a law is non-vacuous
/// precisely because its tokens come from one of these controlled sets, not free
/// prose.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum LawCategory {
    /// §30 *ownership* weirdness (`owned`, `borrowed`, `weak`, …).
    Ownership,
    /// §30 *lifetime* weirdness (`call-lifetime`, `scope-lifetime`, …).
    Lifetime,
    /// §30 *threading* weirdness (`main-thread-only`, `not-reentrant`, …).
    Threading,
    /// §30 *error* weirdness (`nserror-out-param`, `return-null-means-failure`, …).
    Error,
    /// §30 *callback* weirdness (`synchronous-callback`, `escaping-callback`, …).
    Callback,
    /// §30 *buffer* weirdness (`two-call-sizing-pattern`, `caller-provides-buffer`, …).
    Buffer,
    /// §30 *relationship* weirdness (`parent-owns-child`, `delegate-weakly-held`, …).
    Relationship,
}
