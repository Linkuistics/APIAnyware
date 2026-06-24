//! Assemble derived structural facts into typed, validated
//! [`PatternInstance`]s — the multi-role assembly layer (ADR-0048 D3).
//!
//! For each detected pattern the readback binds the kind's roles to concrete
//! [`Participant`]s (every participant stamped with the one framework being
//! processed, so the DP3 home resolves to it), computes the DP4 content id,
//! resolves the home via the kind's designated primary role, and **validates the
//! instance against the authored kind registry** (`validate_instance`) — the
//! producer-side gate child 2 deliberately left to the producer. An instance that
//! fails validation (e.g. a class cluster whose immutable class exposes no public
//! factory class methods, leaving the cardinality-`+` `factory` role unfilled) is
//! dropped, not emitted: convention detection contributes only *well-formed*
//! instances.

use std::collections::BTreeMap;

use apianyware_patterns::PatternKindRegistry;
use apianyware_types::pattern_instance::{InstanceSource, Participant, PatternInstance};

use crate::program::PatternProgram;

/// Assemble every detected pattern in a run program into validated
/// [`PatternInstance`]s for framework `fw`, in a stable id order. Instances that
/// fail registry validation are dropped (logged); the returned count summary is
/// emitted here.
pub fn assemble(
    prog: &PatternProgram,
    fw: &str,
    registry: &PatternKindRegistry,
) -> Vec<PatternInstance> {
    let mut dropped = 0usize;
    let mut instances = Vec::new();

    instances.extend(factory_clusters(prog, fw, registry, &mut dropped));
    instances.extend(observers(prog, fw, registry, &mut dropped));
    instances.extend(paired_states(prog, fw, registry, &mut dropped));
    instances.extend(delegates(prog, fw, registry, &mut dropped));
    instances.extend(brackets(prog, fw, registry, &mut dropped));

    // Stable, content-id order for resolved.json determinism; dedup defensively
    // (distinct detectors cannot collide — different kinds — but identical
    // `(kind, roles)` would, and that is a true duplicate to fold).
    instances.sort_by(|a, b| a.id.cmp(&b.id));
    instances.dedup_by(|a, b| a.id == b.id);

    tracing::info!(
        framework = fw,
        instances = instances.len(),
        dropped,
        "assembled convention pattern-instances"
    );
    instances
}

// ---------------------------------------------------------------------------
// Per-kind assembly
// ---------------------------------------------------------------------------

/// factory-cluster: abstract (immutable) type + concrete (mutable) type + the
/// abstract type's factory class methods (cardinality `+`).
fn factory_clusters(
    prog: &PatternProgram,
    fw: &str,
    registry: &PatternKindRegistry,
    dropped: &mut usize,
) -> Vec<PatternInstance> {
    let mut ops: BTreeMap<&str, Vec<&str>> = BTreeMap::new();
    for (immutable, selector) in &prog.factory_op {
        ops.entry(immutable).or_default().push(selector);
    }

    let mut out = Vec::new();
    for (immutable, mutable, rule) in &prog.factory_cluster {
        let mut factory = ops.get(immutable.as_str()).cloned().unwrap_or_default();
        factory.sort();
        let mut roles = roles_map();
        roles.insert("abstract-type".to_string(), vec![ty(fw, immutable)]);
        roles.insert("concrete-type".to_string(), vec![ty(fw, mutable)]);
        roles.insert(
            "factory".to_string(),
            factory.iter().map(|s| op(fw, immutable, s)).collect(),
        );
        push_if_valid(
            "factory-cluster",
            roles,
            rule,
            fw,
            registry,
            dropped,
            &mut out,
        );
    }
    out
}

/// observer: the subject type + one register + one unregister selector. The kind
/// binds a single register/unregister (cardinality 1); the lexicographically
/// smallest of each is chosen deterministically. The `callback` role (`*`) is
/// left empty — convention detection cannot identify callbacks structurally.
fn observers(
    prog: &PatternProgram,
    fw: &str,
    registry: &PatternKindRegistry,
    dropped: &mut usize,
) -> Vec<PatternInstance> {
    let adds = group_selectors(&prog.add_observer);
    let removes = group_selectors(&prog.remove_observer);

    let mut out = Vec::new();
    for (class, rule) in &prog.observer_pair {
        let (Some(register), Some(unregister)) = (
            adds.get(class.as_str())
                .and_then(|v| v.iter().min())
                .copied(),
            removes
                .get(class.as_str())
                .and_then(|v| v.iter().min())
                .copied(),
        ) else {
            continue;
        };
        let mut roles = roles_map();
        roles.insert("subject".to_string(), vec![ty(fw, class)]);
        roles.insert("register".to_string(), vec![op(fw, class, register)]);
        roles.insert("unregister".to_string(), vec![op(fw, class, unregister)]);
        push_if_valid("observer", roles, rule, fw, registry, dropped, &mut out);
    }
    out
}

/// paired-state: two complementary operations (`enter` / `exit`).
fn paired_states(
    prog: &PatternProgram,
    fw: &str,
    registry: &PatternKindRegistry,
    dropped: &mut usize,
) -> Vec<PatternInstance> {
    let mut out = Vec::new();
    for (class, enter, exit, rule) in &prog.paired_op {
        let mut roles = roles_map();
        roles.insert("enter".to_string(), vec![op(fw, class, enter)]);
        roles.insert("exit".to_string(), vec![op(fw, class, exit)]);
        push_if_valid("paired-state", roles, rule, fw, registry, dropped, &mut out);
    }
    out
}

/// delegate: delegator type + protocol type + `setDelegate:` + the protocol's
/// callback methods (cardinality `*`). The callbacks are owned by the protocol,
/// so their `Operation` participant names the protocol as the class.
fn delegates(
    prog: &PatternProgram,
    fw: &str,
    registry: &PatternKindRegistry,
    dropped: &mut usize,
) -> Vec<PatternInstance> {
    let mut callbacks: BTreeMap<(&str, &str), Vec<&str>> = BTreeMap::new();
    for (class, protocol, selector) in &prog.delegate_callback {
        callbacks
            .entry((class, protocol))
            .or_default()
            .push(selector);
    }

    let mut out = Vec::new();
    for (class, protocol, rule) in &prog.delegate_match {
        let mut cbs = callbacks
            .get(&(class.as_str(), protocol.as_str()))
            .cloned()
            .unwrap_or_default();
        cbs.sort();
        let mut roles = roles_map();
        roles.insert("delegator".to_string(), vec![ty(fw, class)]);
        roles.insert("protocol".to_string(), vec![ty(fw, protocol)]);
        roles.insert(
            "set-delegate".to_string(),
            vec![op(fw, class, "setDelegate:")],
        );
        if !cbs.is_empty() {
            roles.insert(
                "callback".to_string(),
                cbs.iter().map(|s| op(fw, protocol, s)).collect(),
            );
        }
        push_if_valid("delegate", roles, rule, fw, registry, dropped, &mut out);
    }
    out
}

/// bracket: the acquire/release operation pair (the `operation` role `*` stays
/// empty — convention detection does not enumerate the bracketed work).
fn brackets(
    prog: &PatternProgram,
    fw: &str,
    registry: &PatternKindRegistry,
    dropped: &mut usize,
) -> Vec<PatternInstance> {
    let mut out = Vec::new();
    for (class, acquire, release, rule) in &prog.bracket_op {
        let mut roles = roles_map();
        roles.insert("acquire".to_string(), vec![op(fw, class, acquire)]);
        roles.insert("release".to_string(), vec![op(fw, class, release)]);
        push_if_valid("bracket", roles, rule, fw, registry, dropped, &mut out);
    }
    out
}

// ---------------------------------------------------------------------------
// Shared assembly helpers
// ---------------------------------------------------------------------------

/// Group `(receiver, selector)` tuples into `receiver -> [selector]` (borrowed).
fn group_selectors(tuples: &[(String, String)]) -> BTreeMap<&str, Vec<&str>> {
    let mut map: BTreeMap<&str, Vec<&str>> = BTreeMap::new();
    for (receiver, selector) in tuples {
        map.entry(receiver).or_default().push(selector);
    }
    map
}

/// An empty role map (the kind of `BTreeMap` `PatternInstance::roles` expects).
fn roles_map() -> BTreeMap<String, Vec<Participant>> {
    BTreeMap::new()
}

/// A type participant in framework `fw`.
fn ty(fw: &str, name: &str) -> Participant {
    Participant::Type {
        framework: Some(fw.to_string()),
        name: name.to_string(),
    }
}

/// An operation participant (`selector` on `class`) in framework `fw`.
fn op(fw: &str, class: &str, selector: &str) -> Participant {
    Participant::Operation {
        framework: Some(fw.to_string()),
        class: Some(class.to_string()),
        selector: selector.to_string(),
    }
}

/// Finalize a candidate instance — DP4 id, DP3 home, `source=convention` +
/// `convention:<rule>` provenance — and push it to `out` iff it validates against
/// the authored kind registry; otherwise count the drop.
#[allow(clippy::too_many_arguments)]
fn push_if_valid(
    kind: &str,
    roles: BTreeMap<String, Vec<Participant>>,
    rule: &str,
    fw: &str,
    registry: &PatternKindRegistry,
    dropped: &mut usize,
    out: &mut Vec<PatternInstance>,
) {
    let id = PatternInstance::compute_id(kind, &roles);
    let mut instance = PatternInstance {
        id,
        kind: kind.to_string(),
        home: String::new(),
        roles,
        source: InstanceSource::Convention,
        confidence: None,
        provenance: Some(format!("convention:{rule}")),
    };
    // No kind declares a primary role today, so the home resolves to the single
    // framework every participant carries; fall back to it explicitly.
    instance.home = registry
        .instance_home(&instance)
        .unwrap_or_else(|| fw.to_string());

    match registry.validate_instance(&instance) {
        Ok(()) => out.push(instance),
        Err(err) => {
            *dropped += 1;
            tracing::debug!(kind, %err, "dropping invalid convention pattern-instance");
        }
    }
}
