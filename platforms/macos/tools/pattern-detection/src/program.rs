//! Ascent Datalog program for the convention-tier **pattern detection** (ADR-0048
//! D3, ADR-0047).
//!
//! Re-expresses the (retired) imperative `annotate/pattern_detection.rs`
//! heuristics — `detect_factory_clusters` / `detect_observer_pairs` /
//! `detect_paired_state` / `detect_delegate_protocols` /
//! `detect_resource_lifecycles` — as declarative `ascent` rules over a
//! per-framework fact base, the same engine as the `conventions`, `resolve`, and
//! `enrich` programs. Each derived tuple names the **rule** that produced it (a
//! `&'static str`), so the per-instance `convention:<rule>` provenance (ADR-0046
//! §4) falls out of the derivation trace — exactly the `conventions` precedent.
//!
//! The program derives only the *structural facts* (which classes / selectors /
//! protocols play which roles); the multi-role assembly into a typed
//! [`apianyware_types::pattern_instance::PatternInstance`] — binding each role,
//! resolving the DP3 home, computing the DP4 content id, and validating against
//! the authored kind registry — is the [`crate::readback`] layer's concern.
//!
//! Detection is **per framework** (the old `detect_patterns(framework)` granularity
//! — clusters, observer pairs, delegate protocols and brackets never cross a
//! framework boundary), so one program runs per framework and every participant
//! homes to that one framework.

// The `ascent!` macro expands rule bodies into code that clones Copy-typed
// relation fields, produces `()` tail expressions, and stamps explicit
// lifetimes on index iterators. Clippy cannot see past macro boundaries, so
// these lints fire on generated code we don't own.
#![allow(
    clippy::clone_on_copy,
    clippy::unused_unit,
    clippy::needless_lifetimes,
    clippy::let_unit_value
)]

use ascent::ascent;

ascent! {
    pub struct PatternProgram;

    // =======================================================================
    // Base facts (loaded from the linked IR — one framework per program)
    // =======================================================================

    /// class(name) — one tuple per class the framework declares. Carries the
    /// mutable/immutable cluster pairing and the existence test the delegate
    /// rule needs.
    relation class(String);

    /// class_selector(class, selector) — one tuple per selector reachable on a
    /// class via its **direct** methods (which already carries its category
    /// methods, extraction merges them in — the legacy `collect_all_selectors`
    /// set; *not* the inheritance-flattened `all_methods`). The four
    /// selector-shaped detectors (observer / paired-state / delegate / bracket)
    /// key on this; none needs the `class_method` / `init_method` flags.
    relation class_selector(String, String);

    /// class_factory_op(class, selector) — one tuple per **direct, non-category
    /// class method** that is not an initializer (`class_method && !init_method
    /// && method.category.is_none()`), the factory operations the
    /// factory-cluster's `factory` role binds. Loaded separately from
    /// `class_selector` because (a) only this detector consults the method kind
    /// and (b) the legacy `detect_factory_clusters` scanned the immutable
    /// class's **direct** `methods` only, never its category methods.
    relation class_factory_op(String, String);

    /// protocol(name) — one tuple per protocol the framework declares (the
    /// delegate rule's `{Class}Delegate` existence test).
    relation protocol(String);

    /// protocol_selector(protocol, selector) — one tuple per protocol method
    /// (required + optional), the delegate callbacks.
    relation protocol_selector(String, String);

    // =======================================================================
    // Factory-cluster facet (legacy `detect_factory_clusters`)
    //
    // An `NSMutable<X>` class paired with its immutable `NS<X>` sibling is a
    // class cluster: the immutable class is the abstract public type, the mutable
    // class the concrete variant, and the immutable class's factory class methods
    // select the (opaque) concrete subclass.
    // =======================================================================

    /// factory_cluster(abstract_type, concrete_type, rule)
    ///
    /// `abstract_type` is the immutable `NS<X>` class, `concrete_type` the mutable
    /// `NSMutable<X>` class. Both must exist in the framework (the two `class`
    /// atoms); the guard reproduces the legacy `replacen("NSMutable", "NS", 1)`
    /// pairing.
    relation factory_cluster(String, String, &'static str);

    factory_cluster(immutable.clone(), mutable.clone(), "factory-cluster") <--
        class(mutable),
        if mutable.starts_with("NSMutable"),
        class(immutable),
        if is_immutable_variant(mutable, immutable);

    /// factory_op(abstract_type, selector) — a factory class method on the
    /// abstract (immutable) class of a detected cluster. The readback collects
    /// these into the cluster's `factory` role (cardinality `+`).
    relation factory_op(String, String);

    factory_op(immutable.clone(), selector.clone()) <--
        factory_cluster(immutable, _mutable, _rule),
        class_factory_op(immutable, selector);

    // =======================================================================
    // Observer facet (legacy `detect_observer_pairs`)
    //
    // A class declaring both an `addObserver…` and a `removeObserver…` selector
    // supports the observer pattern. The kind binds a single `register` /
    // `unregister` (cardinality 1), so the readback selects one of each
    // deterministically (the lexicographically-smallest); the `callback` role
    // (cardinality `*`) stays empty — convention detection cannot identify the
    // callbacks structurally.
    // =======================================================================

    /// add_observer(class, selector) — an `addObserver…` registration selector.
    relation add_observer(String, String);
    add_observer(class.clone(), selector.clone()) <--
        class_selector(class, selector),
        if selector.starts_with("addObserver");

    /// remove_observer(class, selector) — a `removeObserver…` unregistration selector.
    relation remove_observer(String, String);
    remove_observer(class.clone(), selector.clone()) <--
        class_selector(class, selector),
        if selector.starts_with("removeObserver");

    /// observer_pair(subject, rule) — a class with both registration and
    /// unregistration selectors (the legacy `!add.is_empty() && !remove.is_empty()`).
    relation observer_pair(String, &'static str);
    observer_pair(class.clone(), "observer-pair") <--
        add_observer(class, _add),
        remove_observer(class, _remove);

    // =======================================================================
    // Paired-state facet (legacy `detect_paired_state`)
    //
    // Two complementary operations toggle a binary state. The legacy detector had
    // a `lock`/`unlock` special case plus a generic `begin*`/`end*` scan (which
    // also covered `beginEditing`/`endEditing` and `beginUndoGrouping`/
    // `endUndoGrouping`). Datalog dedups for free, so the explicit verb table for
    // the begin-prefixed pairs is unnecessary — the generic rule derives them.
    // =======================================================================

    /// paired_op(class, enter, exit, rule) — a complementary operation pair on a
    /// class. `rule` distinguishes the two derivations for provenance.
    relation paired_op(String, String, String, &'static str);

    // lock / unlock — both selectors present on the class.
    paired_op(class.clone(), enter.clone(), exit.clone(), "paired-state-lock-unlock") <--
        class_selector(class, enter),
        if enter == "lock",
        class_selector(class, exit),
        if exit == "unlock";

    // Generic `begin<X>` / `end<X>` — the two selectors join on the class, the
    // guard reproduces the legacy `begin_sel.replacen("begin", "end", 1)` match.
    paired_op(class.clone(), enter.clone(), exit.clone(), "paired-state-begin-end") <--
        class_selector(class, enter),
        if enter.starts_with("begin"),
        class_selector(class, exit),
        if is_begin_end_pair(enter, exit);

    // =======================================================================
    // Delegate facet (legacy `detect_delegate_protocols`)
    //
    // A class declaring `setDelegate:` paired with a same-named `{Class}Delegate`
    // (or `{Class}Delegating`) protocol. The protocol's methods are the callbacks.
    // =======================================================================

    /// has_set_delegate(class) — the class declares the canonical `setDelegate:`.
    relation has_set_delegate(String);
    has_set_delegate(class.clone()) <--
        class_selector(class, selector),
        if selector == "setDelegate:";

    /// delegate_match(delegator, protocol, rule) — a `setDelegate:` class paired
    /// with its declared delegate protocol.
    relation delegate_match(String, String, &'static str);
    delegate_match(class.clone(), protocol.clone(), "delegate-protocol") <--
        has_set_delegate(class),
        protocol(protocol),
        if is_delegate_protocol(class, protocol);

    /// delegate_callback(delegator, protocol, selector) — a callback method
    /// declared on a matched delegate protocol. The readback collects these into
    /// the delegate's `callback` role (cardinality `*`).
    relation delegate_callback(String, String, String);
    delegate_callback(class.clone(), protocol.clone(), selector.clone()) <--
        delegate_match(class, protocol, _rule),
        protocol_selector(protocol, selector);

    // =======================================================================
    // Bracket facet (legacy `detect_resource_lifecycles`)
    //
    // The on-demand resource-access pair: `beginAccessingResources…` acquires,
    // `endAccessingResources` releases. (`beginEditing`-style pairs are caught by
    // paired-state; this is the lifecycle-shaped acquire/release.)
    // =======================================================================

    /// bracket_op(class, acquire, release, rule) — an acquire/release operation
    /// pair on a class.
    relation bracket_op(String, String, String, &'static str);
    bracket_op(class.clone(), acquire.clone(), release.clone(), "resource-lifecycle") <--
        class_selector(class, acquire),
        if acquire == "beginAccessingResourcesWithCompletionHandler:",
        class_selector(class, release),
        if release == "endAccessingResources";
}

// ---------------------------------------------------------------------------
// Detection predicates — ported from the retired `annotate/pattern_detection.rs`
// so the rule set reproduces the legacy structural detections. Kept as free
// functions (rather than inlined into the guards) to keep each rule legible.
// ---------------------------------------------------------------------------

/// `immutable` is the immutable sibling of the `NSMutable<X>` class `mutable`.
/// Mirrors `detect_factory_clusters`' `class.name.replacen("NSMutable", "NS", 1)`.
fn is_immutable_variant(mutable: &str, immutable: &str) -> bool {
    *immutable == mutable.replacen("NSMutable", "NS", 1)
}

/// `exit` is the `end<X>` partner of the `begin<X>` selector `enter`. Mirrors
/// `detect_paired_state`'s generic `begin_sel.replacen("begin", "end", 1)` match.
/// `enter` is already gated to a `begin`-prefix by the rule, so the replacement
/// rewrites the prefix.
fn is_begin_end_pair(enter: &str, exit: &str) -> bool {
    *exit == enter.replacen("begin", "end", 1)
}

/// `protocol` is the delegate protocol of the delegator class `class`. Mirrors
/// `detect_delegate_protocols`' `{Class}Delegate` / `{Class}Delegating` candidates.
fn is_delegate_protocol(class: &str, protocol: &str) -> bool {
    protocol == format!("{class}Delegate") || protocol == format!("{class}Delegating")
}

#[cfg(test)]
mod tests {
    use super::*;

    /// A program seeded with one class and its selectors (direct/category),
    /// run to fixpoint.
    fn run(classes: &[&str], selectors: &[(&str, &str)]) -> PatternProgram {
        let mut prog = PatternProgram::default();
        for c in classes {
            prog.class.push((c.to_string(),));
        }
        for (c, s) in selectors {
            prog.class_selector.push((c.to_string(), s.to_string()));
        }
        prog.run();
        prog
    }

    #[test]
    fn factory_cluster_pairs_mutable_and_immutable() {
        let mut prog = PatternProgram::default();
        prog.class.push(("NSArray".to_string(),));
        prog.class.push(("NSMutableArray".to_string(),));
        prog.class_factory_op
            .push(("NSArray".to_string(), "array".to_string()));
        prog.class_factory_op
            .push(("NSArray".to_string(), "arrayWithObject:".to_string()));
        prog.run();

        assert_eq!(
            prog.factory_cluster,
            vec![(
                "NSArray".to_string(),
                "NSMutableArray".to_string(),
                "factory-cluster"
            )]
        );
        let mut ops: Vec<&str> = prog.factory_op.iter().map(|(_, s)| s.as_str()).collect();
        ops.sort();
        assert_eq!(ops, vec!["array", "arrayWithObject:"]);
    }

    #[test]
    fn factory_cluster_without_immutable_sibling_does_not_pair() {
        let mut prog = PatternProgram::default();
        prog.class.push(("NSMutableThing".to_string(),)); // no NSThing
        prog.run();
        assert!(prog.factory_cluster.is_empty());
    }

    #[test]
    fn observer_pair_needs_both_add_and_remove() {
        let with_both = run(
            &["NSNotificationCenter"],
            &[
                ("NSNotificationCenter", "addObserver:selector:name:object:"),
                ("NSNotificationCenter", "removeObserver:"),
            ],
        );
        assert_eq!(
            with_both.observer_pair,
            vec![("NSNotificationCenter".to_string(), "observer-pair")]
        );

        let add_only = run(&["C"], &[("C", "addObserver:")]);
        assert!(add_only.observer_pair.is_empty());
    }

    #[test]
    fn paired_state_detects_lock_unlock() {
        let prog = run(&["NSLock"], &[("NSLock", "lock"), ("NSLock", "unlock")]);
        assert_eq!(
            prog.paired_op,
            vec![(
                "NSLock".to_string(),
                "lock".to_string(),
                "unlock".to_string(),
                "paired-state-lock-unlock"
            )]
        );
    }

    #[test]
    fn paired_state_detects_begin_end_generically() {
        let prog = run(
            &["NSUndoManager"],
            &[
                ("NSUndoManager", "beginUndoGrouping"),
                ("NSUndoManager", "endUndoGrouping"),
            ],
        );
        assert_eq!(
            prog.paired_op,
            vec![(
                "NSUndoManager".to_string(),
                "beginUndoGrouping".to_string(),
                "endUndoGrouping".to_string(),
                "paired-state-begin-end"
            )]
        );
    }

    #[test]
    fn paired_state_begin_without_end_does_not_match() {
        let prog = run(&["C"], &[("C", "beginThing")]); // no endThing
        assert!(prog.paired_op.is_empty());
    }

    #[test]
    fn delegate_matches_named_protocol_and_collects_callbacks() {
        let mut prog = PatternProgram::default();
        prog.class.push(("NSCache".to_string(),));
        prog.class_selector
            .push(("NSCache".to_string(), "setDelegate:".to_string()));
        prog.protocol.push(("NSCacheDelegate".to_string(),));
        prog.protocol_selector.push((
            "NSCacheDelegate".to_string(),
            "cache:willEvictObject:".to_string(),
        ));
        prog.run();

        assert_eq!(
            prog.delegate_match,
            vec![(
                "NSCache".to_string(),
                "NSCacheDelegate".to_string(),
                "delegate-protocol"
            )]
        );
        assert_eq!(
            prog.delegate_callback,
            vec![(
                "NSCache".to_string(),
                "NSCacheDelegate".to_string(),
                "cache:willEvictObject:".to_string()
            )]
        );
    }

    #[test]
    fn delegate_without_protocol_does_not_match() {
        let prog = run(&["NSFoo"], &[("NSFoo", "setDelegate:")]); // no NSFooDelegate
        assert!(prog.delegate_match.is_empty());
    }

    #[test]
    fn bracket_detects_resource_access_pair() {
        let prog = run(
            &["NSBundleResourceRequest"],
            &[
                (
                    "NSBundleResourceRequest",
                    "beginAccessingResourcesWithCompletionHandler:",
                ),
                ("NSBundleResourceRequest", "endAccessingResources"),
            ],
        );
        assert_eq!(
            prog.bracket_op,
            vec![(
                "NSBundleResourceRequest".to_string(),
                "beginAccessingResourcesWithCompletionHandler:".to_string(),
                "endAccessingResources".to_string(),
                "resource-lifecycle"
            )]
        );
    }
}
