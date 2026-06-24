//! First-class **pattern-instances** (ADR-0048 D1; workstream-3 child 2).
//!
//! A [`PatternInstance`] is a concrete occurrence of an authored *pattern-kind*
//! (`semantic/pattern-kinds/<kind>.apiw`) in a specific framework: it binds the
//! kind's roles to concrete [`Participant`]s and carries the ADR-0046 §4
//! provenance stamp ([`InstanceSource`] / [`Confidence`] / `provenance`). An
//! instance is *platform knowledge*, so it rides in the platform spec triad
//! (`platforms/macos/api/<F>/resolved.json`, the [`crate::ir::Framework::patterns`]
//! list), not in `semantic/` — the kind is the reusable definition, the instance
//! is the binding (D1). This module is the **carriage** only: the typed model +
//! the two determinism rules (DP3 home, DP4 identity). Validation against the
//! authored kind registry lives in `apianyware-patterns` (which owns the
//! registry); *detection* — the convention producer — is a later child (D3).

use std::collections::BTreeMap;

use serde::{Deserialize, Serialize};

use crate::annotation::Confidence;

/// A concrete occurrence of a pattern-kind in a framework (ADR-0048 D1).
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct PatternInstance {
    /// Content-derived identity (DP4): a stable function of `(kind, sorted
    /// role-bindings)` — see [`PatternInstance::compute_id`]. Never a sequential
    /// label like `"AppKit#notif-destroy-1"`, so re-detection / SDK-drift yields
    /// the same id and D5 pattern-refs stay stable.
    pub id: String,

    /// The authored pattern-kind this instantiates, by name. Validated against
    /// the `apianyware-patterns` registry.
    pub kind: String,

    /// The deterministic home framework (DP3): the framework whose `resolved.json`
    /// owns this instance, even when its roles span frameworks. See
    /// [`PatternInstance::home_framework`].
    pub home: String,

    /// Role name → the participant(s) bound to it. A role with cardinality `*`/`+`
    /// may bind several participants; `1`/`?` bind at most one.
    pub roles: BTreeMap<String, Vec<Participant>>,

    /// Which ADR-0046 §4 provenance tier produced this instance (precedence
    /// `manual > llm > convention > extraction`).
    pub source: InstanceSource,

    /// Coarse confidence for authored (`llm`/`manual`) instances; absent for
    /// mechanically-derived ones.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub confidence: Option<Confidence>,

    /// Provenance detail: the `convention:<rule>` rule name, a documentation
    /// URL/section, or a manual rationale.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub provenance: Option<String>,
}

/// What a role binds to in an instance (ADR-0048 D5 — polymorphic participants
/// make composition uniform). The kind's `role.binds` fixes which variant is
/// admissible at validation time.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(tag = "participant", rename_all = "snake_case")]
pub enum Participant {
    /// A class / struct / protocol type.
    Type {
        /// The framework that declares the type (the DP3 home input).
        #[serde(default, skip_serializing_if = "Option::is_none")]
        framework: Option<String>,
        /// The type name.
        name: String,
    },
    /// A method / function / selector.
    Operation {
        /// The framework that declares the operation.
        #[serde(default, skip_serializing_if = "Option::is_none")]
        framework: Option<String>,
        /// The owning class (absent for free functions).
        #[serde(default, skip_serializing_if = "Option::is_none")]
        class: Option<String>,
        /// The selector or function name.
        selector: String,
    },
    /// A parameter of one operation — a single-operation-scoped relationship
    /// (DP2: `callback-destroy-notifier`'s roles bind to one register call's
    /// parameters).
    Parameter {
        /// The framework that declares the operation.
        #[serde(default, skip_serializing_if = "Option::is_none")]
        framework: Option<String>,
        /// The operation whose parameter this is.
        selector: String,
        /// The parameter name.
        param: String,
    },
    /// Another pattern-instance, referenced by its content id (D5 composition):
    /// a `subscription`'s `destroy` role binds to a `callback-destroy-notifier`
    /// relationship-instance.
    Pattern {
        /// The referenced instance's [`PatternInstance::id`] (a DP4 content hash).
        id: String,
    },
}

/// The ADR-0046 §4 provenance tier that produced a pattern-instance. Precedence
/// (applied by ws5's workflow, not here): `manual > llm > convention > extraction`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum InstanceSource {
    /// Mechanical extraction (lowest precedence).
    Extraction,
    /// Convention-tier datalog detection; the `convention:<rule>` rule name is
    /// carried in [`PatternInstance::provenance`].
    Convention,
    /// LLM analysis of documentation.
    Llm,
    /// Human-authored override (highest precedence).
    Manual,
}

impl PatternInstance {
    /// The DP4 content-derived id for a kind + its role-bindings: a stable
    /// function of `(kind, sorted role-bindings)`. Stable across runs *and* Rust
    /// versions (a hand-rolled FNV-1a over a canonical string, not `Hash`), so
    /// re-detection of the same occurrence yields the same id.
    pub fn compute_id(kind: &str, roles: &BTreeMap<String, Vec<Participant>>) -> String {
        format!(
            "{kind}-{:016x}",
            fnv1a_64(canonical_form(kind, roles).as_bytes())
        )
    }

    /// The DP3 home framework: the deterministic owner framework for an instance
    /// whose roles may span frameworks. When `primary_role` is the kind's
    /// designated primary role, the home is drawn from *that* role's participants'
    /// frameworks; otherwise from all participants'. Ties break to the
    /// lexicographically-smallest framework name. `None` if no participant carries
    /// a framework.
    pub fn home_framework(
        roles: &BTreeMap<String, Vec<Participant>>,
        primary_role: Option<&str>,
    ) -> Option<String> {
        // Candidate frameworks come from the designated primary role when it
        // names a role that actually carries frameworks; otherwise from every
        // participant. Either way the home is the lexicographically-smallest
        // candidate, so it is deterministic even when the roles span frameworks.
        let from_primary = primary_role
            .and_then(|name| roles.get(name))
            .map(frameworks_of)
            .filter(|fws| !fws.is_empty());

        let mut candidates =
            from_primary.unwrap_or_else(|| frameworks_of(roles.values().flatten()));
        candidates.sort();
        candidates.into_iter().next()
    }
}

/// Collect the (owning) frameworks of a set of participants, in iteration order.
fn frameworks_of<'a>(participants: impl IntoIterator<Item = &'a Participant>) -> Vec<String> {
    participants
        .into_iter()
        .filter_map(|p| p.framework().map(str::to_string))
        .collect()
}

/// A canonical, collision-resistant string of `(kind, sorted role-bindings)` for
/// the DP4 content hash. Role names are already sorted (the `BTreeMap`); the
/// participants within a role are sorted here so their authoring order does not
/// perturb the id. Field separators are ASCII control bytes that never appear in
/// framework/type/selector names.
fn canonical_form(kind: &str, roles: &BTreeMap<String, Vec<Participant>>) -> String {
    const ROLE: char = '\u{1e}'; // record separator
    const FIELD: char = '\u{1f}'; // unit separator
    let mut out = kind.to_string();
    for (role_name, participants) in roles {
        out.push(ROLE);
        out.push_str(role_name);
        let mut canon: Vec<String> = participants.iter().map(participant_token).collect();
        canon.sort();
        for token in canon {
            out.push(FIELD);
            out.push_str(&token);
        }
    }
    out
}

/// A canonical token for one participant (variant-tagged; `None` framework → empty).
fn participant_token(p: &Participant) -> String {
    let f = |o: &Option<String>| o.clone().unwrap_or_default();
    match p {
        Participant::Type { framework, name } => format!("t:{}:{name}", f(framework)),
        Participant::Operation {
            framework,
            class,
            selector,
        } => format!("o:{}:{}:{selector}", f(framework), f(class)),
        Participant::Parameter {
            framework,
            selector,
            param,
        } => format!("p:{}:{selector}:{param}", f(framework)),
        Participant::Pattern { id } => format!("r:{id}"),
    }
}

/// FNV-1a (64-bit). A *stable* hash — unlike [`std::hash::Hash`] / `DefaultHasher`,
/// its output is fixed across Rust versions and platforms, which is what content
/// identity (DP4) requires.
fn fnv1a_64(bytes: &[u8]) -> u64 {
    let mut hash: u64 = 0xcbf2_9ce4_8422_2325;
    for &b in bytes {
        hash ^= u64::from(b);
        hash = hash.wrapping_mul(0x0000_0100_0000_01b3);
    }
    hash
}

impl Participant {
    /// The framework that owns this participant, if known. A `Pattern` ref has no
    /// framework of its own (follow the ref to read the referenced instance).
    pub fn framework(&self) -> Option<&str> {
        match self {
            Participant::Type { framework, .. }
            | Participant::Operation { framework, .. }
            | Participant::Parameter { framework, .. } => framework.as_deref(),
            Participant::Pattern { .. } => None,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn op(framework: &str, selector: &str) -> Participant {
        Participant::Operation {
            framework: Some(framework.to_string()),
            class: None,
            selector: selector.to_string(),
        }
    }

    fn roles(pairs: &[(&str, Vec<Participant>)]) -> BTreeMap<String, Vec<Participant>> {
        pairs
            .iter()
            .map(|(name, ps)| (name.to_string(), ps.clone()))
            .collect()
    }

    #[test]
    fn compute_id_is_stable_for_same_bindings() {
        let r = roles(&[
            ("acquire", vec![op("CoreGraphics", "CGPathCreateMutable")]),
            ("release", vec![op("CoreGraphics", "CGPathRelease")]),
        ]);
        let a = PatternInstance::compute_id("bracket", &r);
        let b = PatternInstance::compute_id("bracket", &r);
        assert_eq!(a, b, "same (kind, bindings) must yield the same id");
        assert!(!a.is_empty(), "id must not be empty");
    }

    #[test]
    fn compute_id_is_insensitive_to_participant_order_within_a_role() {
        let r1 = roles(&[("operation", vec![op("F", "useA"), op("F", "useB")])]);
        let r2 = roles(&[("operation", vec![op("F", "useB"), op("F", "useA")])]);
        assert_eq!(
            PatternInstance::compute_id("bracket", &r1),
            PatternInstance::compute_id("bracket", &r2),
            "participant order within a role must not change the id (sorted bindings)"
        );
    }

    #[test]
    fn compute_id_differs_for_different_kind() {
        let r = roles(&[("acquire", vec![op("F", "open")])]);
        assert_ne!(
            PatternInstance::compute_id("bracket", &r),
            PatternInstance::compute_id("observer", &r),
            "the kind name is part of the identity"
        );
    }

    #[test]
    fn compute_id_differs_for_different_bindings() {
        let r1 = roles(&[("acquire", vec![op("F", "open")])]);
        let r2 = roles(&[("acquire", vec![op("F", "openOther")])]);
        assert_ne!(
            PatternInstance::compute_id("bracket", &r1),
            PatternInstance::compute_id("bracket", &r2),
            "different bindings must yield different ids"
        );
    }

    #[test]
    fn home_is_the_primary_role_framework() {
        let r = roles(&[
            ("parent", vec![op("AppKit", "NSView")]),
            ("child", vec![op("CoreAudio", "AUNode")]),
        ]);
        assert_eq!(
            PatternInstance::home_framework(&r, Some("parent")).as_deref(),
            Some("AppKit"),
            "home is the framework of the designated primary role's participant"
        );
    }

    #[test]
    fn home_breaks_primary_role_ties_lexicographically() {
        let r = roles(&[(
            "anchor",
            vec![op("Zoo", "z"), op("AppKit", "a"), op("Foundation", "f")],
        )]);
        assert_eq!(
            PatternInstance::home_framework(&r, Some("anchor")).as_deref(),
            Some("AppKit"),
            "a primary role spanning frameworks breaks the tie to the smallest name"
        );
    }

    #[test]
    fn home_falls_back_to_all_participants_without_a_primary_role() {
        let r = roles(&[("a", vec![op("Zoo", "z")]), ("b", vec![op("AppKit", "x")])]);
        assert_eq!(
            PatternInstance::home_framework(&r, None).as_deref(),
            Some("AppKit"),
            "with no primary role, the home is the smallest framework among all participants"
        );
    }

    #[test]
    fn home_is_none_when_no_participant_carries_a_framework() {
        let r = roles(&[("ref", vec![Participant::Pattern { id: "x".into() }])]);
        assert_eq!(PatternInstance::home_framework(&r, None), None);
    }
}
