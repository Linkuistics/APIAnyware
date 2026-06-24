//! Cross-framework protocol-inheritance registry — the protocol analogue of
//! [`crate::class_graph::ClassRegistry`], backing **conformed-protocol method
//! flattening** (leaf 040/030; the SBCL peer of `emit-gerbil/protocol_registry.rs`).
//!
//! ## Why SBCL needs flattening at all (the leaf's open question, decided)
//!
//! The CLOS class graph ([`crate::class_graph`]) reifies *class* inheritance: a
//! `defmethod` specialized on `ns:ns-view` is inherited by `ns:ns-control`
//! instances through ordinary CLOS dispatch, so the emitter never re-emits a
//! superclass's methods on its subclasses (ADR-0034 §2 — the same win gerbil's
//! manifest `defclass` graph buys, ADR-0020). **Protocol conformance is
//! orthogonal to that graph:** ADR-0034 projects only the ObjC *superclass* chain
//! into `defclass`es — a conformed protocol is **not** a CLOS superclass — so a
//! protocol's methods (`NSData`'s `copyWithZone:` from `NSCopying`) live on no
//! ancestor class and would never be reachable through inheritance. They must be
//! flattened onto each conforming class as receiver-specialized `defmethod`s. The
//! CLOS model therefore makes flattening **no lighter** than gerbil's leaf-120
//! shape; the rule below is the same.
//!
//! (A CLOS-mixin alternative — modelling each protocol as an extra `defclass`
//! superclass so one `defmethod` covers all conformers — was considered and
//! rejected: it would change ADR-0034's settled "ObjC ancestor chain only" graph,
//! force the `objc-class` metaclass to validate superclasses with no ObjC class
//! behind them, and re-open a closed design. The own-conformance-closure flatten
//! is the in-scope, design-faithful choice.)
//!
//! ## Why flattening needs a registry
//!
//! The resolve phase already merges protocol-declared methods into each class's
//! `all_methods`, stamping `origin` with the **declaring protocol's name**. But
//! `all_methods` also carries superclass-inherited entries (protocol *and* class
//! origins propagate down the inheritance rule), and the CLOS class graph makes
//! re-emitting inherited surfaces redundant (above). So the emitter must take
//! exactly the entries whose origin is a protocol **this class itself conforms
//! to** — `Class::protocols` (the direct conformance list) closed over protocol
//! `inherits` edges. Those edges cross frameworks (`NSSecureCoding` → `NSCoding`
//! lives in Foundation while the conforming class may live in SceneKit), and the
//! per-framework emitter sees only one framework — hence this registry, built once
//! over every loaded framework by the CLI pre-pass and threaded in, exactly like
//! `ClassRegistry`.
//!
//! ## The closure is registry-known-only, and excludes `NSObject`
//!
//! - A protocol absent from every loaded framework is **excluded** from the
//!   closure: its methods exist in `all_methods` only as resolve-time minimal
//!   stubs (no params, `void` return — the checkpoint's cross-framework
//!   fallback), and emitting a stubbed signature would produce a wrong-arity
//!   `objc_msgSend` crossing. Skipping the protocol defers its methods, which is
//!   the safe direction.
//! - The `NSObject` *protocol* (root of most protocol-inheritance chains) is
//!   excluded by name: its name collides with the `NSObject` *class*, so an
//!   `origin: "NSObject"` entry in `all_methods` is ambiguous between
//!   "protocol-declared" and "inherited from the root class" — and either way the
//!   runtime root (`ns:ns-object`) already owns that surface.

use std::collections::{BTreeSet, HashMap};

use apianyware_types::ir::Framework;

use crate::class_graph::RUNTIME_ROOT;

/// Maps a protocol name to the protocols it `inherits` from, across every loaded
/// framework. Empty by default — an empty registry yields empty conformance
/// closures, degrading emission to the class's own methods (the pre-flattening
/// behaviour), never to broken stubs.
#[derive(Debug, Clone, Default)]
pub struct ProtocolRegistry {
    inherits: HashMap<String, Vec<String>>,
}

impl ProtocolRegistry {
    pub fn new() -> Self {
        Self::default()
    }

    /// Build the global protocol→inherits map across every loaded framework. First
    /// framework to declare a protocol owns its entry (matches the
    /// dependency-ordered load, mirroring `ClassRegistry`).
    pub fn from_frameworks(frameworks: &[Framework]) -> Self {
        let refs: Vec<&Framework> = frameworks.iter().collect();
        Self::from_framework_refs(&refs)
    }

    /// Like [`Self::from_frameworks`] but over borrowed frameworks — the shape the
    /// generate pipeline already holds (`ordered_frameworks: Vec<&Framework>`), so
    /// the CLI pre-pass builds the registry without cloning every framework.
    pub fn from_framework_refs(frameworks: &[&Framework]) -> Self {
        let mut inherits = HashMap::new();
        for fw in frameworks {
            for proto in &fw.protocols {
                inherits
                    .entry(proto.name.clone())
                    .or_insert_with(|| proto.inherits.clone());
            }
        }
        Self { inherits }
    }

    /// Register one protocol→inherits edge set (test helper / incremental build).
    pub fn insert(&mut self, protocol_name: impl Into<String>, inherits: Vec<String>) {
        self.inherits.insert(protocol_name.into(), inherits);
    }

    /// The set of protocols whose methods a class with direct conformance list
    /// `direct` should flatten: the closure of `direct` over `inherits` edges,
    /// restricted to registry-known protocols, excluding the `NSObject` protocol
    /// (see the module doc for both rules). Sorted for determinism.
    pub fn conformance_closure(&self, direct: &[String]) -> BTreeSet<String> {
        let mut out = BTreeSet::new();
        let mut stack: Vec<&str> = direct.iter().map(String::as_str).collect();
        while let Some(p) = stack.pop() {
            if p == RUNTIME_ROOT || out.contains(p) {
                continue;
            }
            let Some(parents) = self.inherits.get(p) else {
                continue; // unknown protocol: stub metadata only — defer it
            };
            out.insert(p.to_string());
            stack.extend(parents.iter().map(String::as_str));
        }
        out
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn registry(edges: &[(&str, &[&str])]) -> ProtocolRegistry {
        let mut r = ProtocolRegistry::new();
        for (name, parents) in edges {
            r.insert(*name, parents.iter().map(|s| s.to_string()).collect());
        }
        r
    }

    fn names(v: &[&str]) -> Vec<String> {
        v.iter().map(|s| s.to_string()).collect()
    }

    #[test]
    fn closure_follows_protocol_inheritance() {
        // NSSecureCoding -> NSCoding -> (none): conforming to the child pulls in
        // the parent.
        let r = registry(&[("NSSecureCoding", &["NSCoding"]), ("NSCoding", &[])]);
        let c = r.conformance_closure(&names(&["NSSecureCoding"]));
        assert!(c.contains("NSSecureCoding"));
        assert!(c.contains("NSCoding"));
        assert_eq!(c.len(), 2);
    }

    #[test]
    fn nsobject_protocol_excluded() {
        // Nearly every protocol inherits the NSObject protocol; it must never enter
        // the closure (name-collision with the root class ns:ns-object).
        let r = registry(&[("NSWindowDelegate", &["NSObject"])]);
        let c = r.conformance_closure(&names(&["NSWindowDelegate"]));
        assert!(c.contains("NSWindowDelegate"));
        assert!(!c.contains("NSObject"));
    }

    #[test]
    fn unknown_protocol_excluded() {
        // A protocol from an unloaded framework has only stub metadata in
        // all_methods — it must not contribute (wrong-arity crossings).
        let r = registry(&[("Known", &[])]);
        let c = r.conformance_closure(&names(&["Known", "CALayerDelegate"]));
        assert!(c.contains("Known"));
        assert!(!c.contains("CALayerDelegate"));
        assert_eq!(c.len(), 1);
    }

    #[test]
    fn diamond_inheritance_dedups() {
        // P1 and P2 both inherit Base: the closure holds Base once.
        let r = registry(&[("P1", &["Base"]), ("P2", &["Base"]), ("Base", &[])]);
        let c = r.conformance_closure(&names(&["P1", "P2"]));
        assert_eq!(
            c.iter().collect::<Vec<_>>(),
            vec!["Base", "P1", "P2"],
            "diamond base appears exactly once"
        );
    }

    #[test]
    fn empty_registry_yields_empty_closure() {
        let r = ProtocolRegistry::new();
        assert!(r.conformance_closure(&names(&["Anything"])).is_empty());
    }

    #[test]
    fn from_framework_refs_first_owner_wins() {
        use apianyware_types::ir::Protocol;
        fn proto(name: &str, inherits: &[&str]) -> Protocol {
            Protocol {
                name: name.into(),
                inherits: inherits.iter().map(|s| s.to_string()).collect(),
                required_methods: vec![],
                optional_methods: vec![],
                properties: vec![],
                source: None,
                provenance: None,
                doc_refs: None,
                objc_exposed: true,
            }
        }
        fn fw(name: &str, protocols: Vec<Protocol>) -> Framework {
            Framework {
                format_version: "1.0".into(),
                checkpoint: "resolved".into(),
                name: name.into(),
                sdk_version: None,
                collected_at: None,
                depends_on: vec![],
                skipped_symbols: vec![],
                classes: vec![],
                protocols,
                enums: vec![],
                structs: vec![],
                functions: vec![],
                constants: vec![],
                class_annotations: vec![],
                patterns: vec![],
                enrichment: None,
                verification: None,
            }
        }
        // Foundation declares NSCoding; a later framework re-declaring it does not
        // overwrite the first owner's edge set.
        let foundation = fw(
            "Foundation",
            vec![
                proto("NSSecureCoding", &["NSCoding"]),
                proto("NSCoding", &[]),
            ],
        );
        let appkit = fw("AppKit", vec![proto("NSCoding", &["ShouldNotWin"])]);
        let reg = ProtocolRegistry::from_framework_refs(&[&foundation, &appkit]);
        let c = reg.conformance_closure(&names(&["NSSecureCoding"]));
        assert!(c.contains("NSCoding"));
        // ShouldNotWin would only appear if AppKit's later NSCoding edge had won.
        assert!(!c.contains("ShouldNotWin"));
    }
}
