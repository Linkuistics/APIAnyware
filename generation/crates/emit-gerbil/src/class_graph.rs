//! The manifest ObjC class graph (ADR-0020) — the structural foundation the
//! dispatch surfaces (leaf 040) and error model (leaf 050) hang on.
//!
//! ObjC dispatch is dynamic, but a Scheme class graph is *not* redundant here:
//! it gives the two consumption surfaces real types to dispatch on (a single
//! opaque handle makes receiver-only generic dispatch vacuous, ADR-0020) and it
//! lets user subclasses (`(defclass (MyView NSView) …)`) be *real* ObjC
//! subclasses the frameworks call back into. So the emitter reifies the full
//! ObjC ancestor chain as a Gerbil `defclass` hierarchy.
//!
//! ## What this module computes (pure, IR-only)
//!
//! For one framework, [`build_class_graph`] resolves, per class, the **Gerbil
//! parent** its `defclass` derives from — and synthesizes **bare nodes** for any
//! same-framework intermediate ancestor that is referenced as a superclass but
//! not itself collected as a class. The graph builder is deterministic and
//! pure; [`crate::emit_class`] renders it and [`crate::emit_framework`] writes
//! one `.ss` module per node.
//!
//! ## The parent-resolution rules
//!
//! `NSObject` is the single runtime-owned root (it holds the `ptr` slot + the
//! ADR-0019 lifetime will, defined once in `:gerbil-bindings/runtime/objc`); the
//! emitter never re-defines it. For every other class, the immediate
//! `superclass` (the only reliable link — `ancestors` is sorted alphabetically,
//! not in chain order) resolves to one of:
//!
//! - [`ParentRef::RuntimeRoot`] — empty `superclass` (an independent ObjC root
//!   like `NSProxy`, rooted on `NSObject` for the shared `ptr` slot) or an
//!   explicit `NSObject` parent.
//! - [`ParentRef::Local`] — a same-framework class (the common case); the child
//!   module imports the parent's sibling module.
//! - [`ParentRef::CrossFramework`] — a parent owned by another framework
//!   (resolved via the injected [`ClassRegistry`]); the child module imports the
//!   parent's module under its owning package path.
//!
//! A superclass that is neither local, nor `NSObject`, nor resolvable through
//! the registry is treated as a **same-framework gap**: a bare `defclass` node
//! is synthesized for it (deriving from the runtime root, since its own parent
//! is unknowable from an unordered ancestor set) and the child links to it
//! locally. In real SDK data this is essentially empty — every same-framework
//! intermediate is a collected class — but the rule keeps the emitted graph
//! self-consistent (no dangling parent reference) under any IR.

use std::collections::{BTreeSet, HashMap};

use apianyware_types::ir::Framework;

/// The runtime-owned root class every chain bottoms out in. Defined once in the
/// runtime module (leaf 050); the emitter references it but never defines it.
pub const RUNTIME_ROOT: &str = "NSObject";

/// Maps an ObjC class name to the lowercase module directory of the framework
/// that **owns** it (defines it), for resolving cross-framework parent imports.
///
/// The per-framework [`crate::emit_framework`] entry point only sees one
/// framework, so it cannot place a parent that lives elsewhere. This registry is
/// the seam: built once over every loaded framework by the CLI pre-pass
/// (leaf 060, via [`ClassRegistry::from_frameworks`]) and threaded in. Empty by
/// default — same-framework parents still resolve from the framework's own class
/// set, and an unresolved cross-framework parent degrades to the runtime root
/// with the true ObjC super name preserved in the registration.
#[derive(Debug, Clone, Default)]
pub struct ClassRegistry {
    owners: HashMap<String, String>,
}

impl ClassRegistry {
    pub fn new() -> Self {
        Self::default()
    }

    /// Build the global class→owning-framework map across every loaded
    /// framework. First framework to declare a class owns it (matches the
    /// dependency-ordered load: a base framework is seen before its dependents).
    pub fn from_frameworks(frameworks: &[Framework]) -> Self {
        let refs: Vec<&Framework> = frameworks.iter().collect();
        Self::from_framework_refs(&refs)
    }

    /// Like [`Self::from_frameworks`] but over borrowed frameworks — the shape the
    /// generate pipeline already holds (`ordered_frameworks: Vec<&Framework>`), so
    /// the CLI pre-pass builds the registry without cloning every framework.
    pub fn from_framework_refs(frameworks: &[&Framework]) -> Self {
        let mut owners = HashMap::new();
        for fw in frameworks {
            let fw_low = fw.name.to_ascii_lowercase();
            for cls in &fw.classes {
                owners
                    .entry(cls.name.clone())
                    .or_insert_with(|| fw_low.clone());
            }
        }
        Self { owners }
    }

    /// Register one class→framework ownership (test helper / incremental build).
    pub fn insert(&mut self, class_name: impl Into<String>, framework_low: impl Into<String>) {
        self.owners.insert(class_name.into(), framework_low.into());
    }

    /// The lowercase framework module dir that owns `class_name`, if known.
    pub fn owner(&self, class_name: &str) -> Option<&str> {
        self.owners.get(class_name).map(String::as_str)
    }
}

/// The Gerbil class a `defclass` derives from, and how to reach it.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum ParentRef {
    /// Derive from the runtime-owned `NSObject` root (already imported via the
    /// runtime module — no extra import).
    RuntimeRoot,
    /// Derive from a sibling class in the same framework.
    Local(String),
    /// Derive from a class owned by another framework; `fw_low` is its package
    /// module dir.
    CrossFramework { name: String, fw_low: String },
}

impl ParentRef {
    /// The Gerbil class identifier spelled in the `(defclass (Self Parent) …)`
    /// head.
    pub fn gerbil_name(&self) -> &str {
        match self {
            ParentRef::RuntimeRoot => RUNTIME_ROOT,
            ParentRef::Local(name) => name,
            ParentRef::CrossFramework { name, .. } => name,
        }
    }
}

/// The resolved class graph for one framework: every collected class's Gerbil
/// parent, plus any bare intermediate nodes that had to be synthesized.
#[derive(Debug, Clone, Default)]
pub struct ClassGraph {
    /// Collected class name → its resolved Gerbil parent.
    pub parents: HashMap<String, ParentRef>,
    /// Names of synthesized bare intermediate nodes (deterministically sorted),
    /// each emitted as its own minimal `defclass`-only module rooted on
    /// [`RUNTIME_ROOT`].
    pub synthesized: Vec<String>,
}

/// Resolve the manifest class graph for one framework against the cross-framework
/// ownership registry. Pure and deterministic.
pub fn build_class_graph(fw: &Framework, registry: &ClassRegistry) -> ClassGraph {
    let local: BTreeSet<&str> = fw.classes.iter().map(|c| c.name.as_str()).collect();

    let mut parents: HashMap<String, ParentRef> = HashMap::new();
    let mut synthesized: BTreeSet<String> = BTreeSet::new();

    for cls in &fw.classes {
        let parent = resolve_parent(&cls.superclass, &local, registry, &mut synthesized);
        parents.insert(cls.name.clone(), parent);
    }

    ClassGraph {
        parents,
        synthesized: synthesized.into_iter().collect(),
    }
}

/// Resolve one class's immediate superclass to a [`ParentRef`], synthesizing a
/// bare local node for an unresolvable same-framework gap.
fn resolve_parent(
    superclass: &str,
    local: &BTreeSet<&str>,
    registry: &ClassRegistry,
    synthesized: &mut BTreeSet<String>,
) -> ParentRef {
    if superclass.is_empty() || superclass == RUNTIME_ROOT {
        return ParentRef::RuntimeRoot;
    }
    if local.contains(superclass) {
        return ParentRef::Local(superclass.to_string());
    }
    if let Some(fw_low) = registry.owner(superclass) {
        return ParentRef::CrossFramework {
            name: superclass.to_string(),
            fw_low: fw_low.to_string(),
        };
    }
    // Same-framework gap: not collected, not owned elsewhere. Synthesize a bare
    // node for it locally and link the child to that node.
    synthesized.insert(superclass.to_string());
    ParentRef::Local(superclass.to_string())
}

#[cfg(test)]
mod tests {
    use super::*;
    use apianyware_types::ir::Class;

    fn cls(name: &str, superclass: &str) -> Class {
        Class {
            name: name.into(),
            superclass: superclass.into(),
            protocols: vec![],
            properties: vec![],
            methods: vec![],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
            swift_name: None,
        }
    }

    fn fw(name: &str, classes: Vec<Class>) -> Framework {
        Framework {
            format_version: "1.0".into(),
            checkpoint: "enriched".into(),
            name: name.into(),
            sdk_version: None,
            collected_at: None,
            depends_on: vec![],
            skipped_symbols: vec![],
            classes,
            protocols: vec![],
            enums: vec![],
            structs: vec![],
            functions: vec![],
            constants: vec![],
            class_annotations: vec![],
            api_patterns: vec![],
            enrichment: None,
            verification: None,
        }
    }

    #[test]
    fn root_and_local_chain() {
        // NSResponder -> NSObject (root); NSView -> NSResponder (local);
        // NSControl -> NSView (local). A complete same-framework chain.
        let f = fw(
            "AppKit",
            vec![
                cls("NSResponder", "NSObject"),
                cls("NSView", "NSResponder"),
                cls("NSControl", "NSView"),
            ],
        );
        let g = build_class_graph(&f, &ClassRegistry::new());
        assert_eq!(g.parents["NSResponder"], ParentRef::RuntimeRoot);
        assert_eq!(g.parents["NSView"], ParentRef::Local("NSResponder".into()));
        assert_eq!(g.parents["NSControl"], ParentRef::Local("NSView".into()));
        assert!(g.synthesized.is_empty());
    }

    #[test]
    fn empty_superclass_roots_on_runtime() {
        // NSProxy is an independent ObjC root; we root it on NSObject for the
        // shared ptr slot.
        let f = fw("Foundation", vec![cls("NSProxy", "")]);
        let g = build_class_graph(&f, &ClassRegistry::new());
        assert_eq!(g.parents["NSProxy"], ParentRef::RuntimeRoot);
    }

    #[test]
    fn cross_framework_parent_resolves_via_registry() {
        let mut reg = ClassRegistry::new();
        reg.insert("NSMutableAttributedString", "foundation");
        let f = fw(
            "AppKit",
            vec![cls("NSTextStorage", "NSMutableAttributedString")],
        );
        let g = build_class_graph(&f, &reg);
        assert_eq!(
            g.parents["NSTextStorage"],
            ParentRef::CrossFramework {
                name: "NSMutableAttributedString".into(),
                fw_low: "foundation".into(),
            }
        );
        assert!(g.synthesized.is_empty());
    }

    #[test]
    fn unbound_intermediate_is_synthesized_as_bare_node() {
        // A 3-deep chain Leaf -> Mid -> NSObject where Mid is referenced but not
        // collected and not owned elsewhere: Mid is synthesized as a bare node
        // (rooted on the runtime root) and Leaf links to it locally.
        let f = fw("Widgets", vec![cls("Leaf", "Mid")]);
        let g = build_class_graph(&f, &ClassRegistry::new());
        assert_eq!(g.parents["Leaf"], ParentRef::Local("Mid".into()));
        assert_eq!(g.synthesized, vec!["Mid".to_string()]);
    }

    #[test]
    fn from_frameworks_first_owner_wins() {
        let foundation = fw("Foundation", vec![cls("NSObject2", "")]);
        let appkit = fw("AppKit", vec![cls("NSView", "NSObject")]);
        let reg = ClassRegistry::from_frameworks(&[foundation, appkit]);
        assert_eq!(reg.owner("NSObject2"), Some("foundation"));
        assert_eq!(reg.owner("NSView"), Some("appkit"));
        assert_eq!(reg.owner("DoesNotExist"), None);
    }

    #[test]
    fn from_framework_refs_matches_owned_variant() {
        // The borrowed-slice variant the CLI pre-pass uses agrees with the
        // owned-slice one (same first-owner-wins semantics).
        let foundation = fw("Foundation", vec![cls("NSObject2", "")]);
        let appkit = fw("AppKit", vec![cls("NSView", "NSObject")]);
        let refs = vec![&foundation, &appkit];
        let reg = ClassRegistry::from_framework_refs(&refs);
        assert_eq!(reg.owner("NSObject2"), Some("foundation"));
        assert_eq!(reg.owner("NSView"), Some("appkit"));
        assert_eq!(reg.owner("DoesNotExist"), None);
    }
}
