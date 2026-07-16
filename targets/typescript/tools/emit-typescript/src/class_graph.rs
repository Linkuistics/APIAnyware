//! The resolved ObjC class graph (ADR-0055 §1/§2) — the parent links, the
//! superclass-before-subclass load order, and the **class→module resolver** the
//! per-class emitters ([`crate::emit_class`] / [`crate::emit_dts`]) route their
//! cross-class imports through.
//!
//! TypeScript mirrors the ObjC graph as **real ES6 classes** (`class NSString extends
//! NSObject`), one file per class in per-framework modules (ADR-0055 §1). A real graph
//! is load-bearing for three things this module computes, all **pure and IR-only**:
//!
//! 1. **Parent resolution** — each class's `extends` target: the runtime-owned root
//!    `NSObject`, a same-framework sibling, or a class owned by another framework
//!    (resolved via the injected [`ClassRegistry`]). [`build_class_graph`].
//! 2. **Load order** — a superclass-before-subclass emit order so the barrel re-exports
//!    a superclass's module before a subclass's, which is what keeps a same-framework
//!    `extends` chain **cycle-safe under ESM evaluation** (the barrel is a package
//!    import cycle; the subclass's `extends` binding is live only if the superclass
//!    module evaluated first). [`ordered_classes`].
//! 3. **The class→module resolver** — where a referenced class type is imported from:
//!    `NSObject` → the runtime module, a bound class → its owning `@apianyware/<fw>`
//!    package (`naming::module_specifier`). [`ClassModuleResolver`].
//!
//! ## The parent-resolution rules
//!
//! `NSObject` is the single runtime-owned root (the branded-handle base defined once in
//! the runtime, Step 3); the emitter never re-declares it. For every other class, the
//! immediate `superclass` (the only reliable link — `ancestors` is sorted
//! alphabetically, not in chain order) resolves to one of:
//!
//! - [`ParentRef::RuntimeRoot`] — empty `superclass` (an independent ObjC root like
//!   `NSProxy`, rooted on the runtime `NSObject` for the shared handle) or an explicit
//!   `NSObject` parent.
//! - [`ParentRef::Local`] — a same-framework class (the common case).
//! - [`ParentRef::CrossFramework`] — a parent owned by another framework (resolved via
//!   the injected [`ClassRegistry`]).
//!
//! A superclass that is neither local, nor `NSObject`, nor resolvable through the
//! registry is treated as a **same-framework gap**: a bare node is synthesized for it
//! (the orchestrator emits it as `class Gap extends NSObject {}` so the chain does not
//! dangle). In real SDK data this is essentially empty — every same-framework
//! intermediate is a collected class — but the rule keeps the emitted graph
//! self-consistent under any IR.
//!
//! A superclass string that is not itself a valid TS identifier never reaches a gap: it is
//! **degraded** straight to [`ParentRef::RuntimeRoot`] instead of being synthesized as a bare
//! node under an unparseable name (`generic-class-name-surface-k78` — a printed Swift generic
//! instantiation such as `EntityQueryComparator<τ_0_0, …>`, once `extract_simple_name`
//! (`extract-swift`) is fixed, is no longer the shape `Class::superclass` carries; this is the
//! belt-and-suspenders floor for any *other* unparseable shape a future SDK might print).
//! [`ClassGraph::degraded`] records every degradation, measured rather than assumed absent.
//!
//! This is the TS analogue of `emit-sbcl/src/class_graph.rs`: the parent-resolution
//! logic is target-neutral (the ADR-0034 metaclass graph ≡ this graph in *shape*); only
//! the rendered projection differs (real ES6 classes + `@apianyware/<fw>` module
//! specifiers here, vs sbcl's `ns:`-qualified CLOS names). **No emitter changes ride
//! this leaf** — the orchestrator + import rerouting are the sibling
//! `framework-orchestration-and-goldens` leaf.

use std::collections::{BTreeSet, HashMap};
use std::sync::Arc;

use apianyware_types::ir::{Class, Framework};
use apianyware_types::type_ref::TypeRefKind;

use crate::naming::{is_valid_ts_identifier, module_specifier};

/// The runtime-owned root class every chain bottoms out in — the branded-handle base
/// defined once in the runtime library (Step 3); the emitter references it but never
/// declares it.
pub const RUNTIME_ROOT: &str = "NSObject";

/// The module the runtime-owned root and the seam primitives are imported from
/// (ADR-0055 §2). `NSObject` is not a framework class, so it does not resolve through
/// [`naming::module_specifier`](crate::naming::module_specifier) — the resolver returns
/// this constant for it directly.
pub const RUNTIME_MODULE: &str = "@apianyware/runtime";

/// Maps an ObjC class name to the lowercase directory of the framework that **owns**
/// (declares) it, for resolving cross-framework parents and import paths.
///
/// The per-framework emitter only sees one framework, so it cannot place a parent or a
/// referenced type that lives elsewhere. This registry is the seam: the Step-5 CLI
/// pre-pass builds it once over every loaded framework and threads it in (the sbcl /
/// gerbil whole-program shape). Empty by default — same-framework classes still resolve
/// from the framework's own class set (parents) or fall back to the current framework
/// (the resolver) — so an unconfigured emitter still produces a self-consistent graph.
#[derive(Debug, Clone, Default)]
pub struct ClassRegistry {
    owners: HashMap<String, String>,
}

impl ClassRegistry {
    pub fn new() -> Self {
        Self::default()
    }

    /// Build the global class→owning-framework map across every loaded framework. First
    /// framework to declare a class owns it (matches the dependency-ordered load: a base
    /// framework is seen before its dependents).
    pub fn from_frameworks(frameworks: &[Framework]) -> Self {
        let refs: Vec<&Framework> = frameworks.iter().collect();
        Self::from_framework_refs(&refs)
    }

    /// Like [`Self::from_frameworks`] but over borrowed frameworks — the shape the
    /// generate pipeline already holds (`ordered_frameworks: Vec<&Framework>`), so the
    /// CLI pre-pass builds the registry without cloning every framework.
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

    /// The lowercase framework dir that owns `class_name`, if known.
    pub fn owner(&self, class_name: &str) -> Option<&str> {
        self.owners.get(class_name).map(String::as_str)
    }

    /// Every class name the registry knows — the **ObjC-class recognition set**, the
    /// counterpart of [`EnumRegistry::names`](crate::enum_graph::EnumRegistry::names).
    /// It separates a real ObjC class from a `.swiftinterface`-lowered Swift nominal
    /// type: the IR spells both `TypeRefKind::Class`, but only the former has an ObjC
    /// class declaration (`CGFloat` and `Tuple` are `Class` type-refs in CoreGraphics,
    /// whose IR declares exactly eight classes, none of them either).
    pub fn names(&self) -> BTreeSet<String> {
        self.owners.keys().cloned().collect()
    }
}

/// The whole-program **declared-class recognition set** — every class name the IR declares
/// across `frameworks`, which is exactly the set of classes the emitter emits (every collected
/// class gets a file, [`crate::emit_framework`]).
///
/// This is what [`crate::class_binding`] resolves a `Class{name}` against, so it must be
/// **identical** on both sides of the mirror invariant: the emitters get it from the CLI-built
/// [`ClassRegistry`] (∪ the framework's own classes), while each table collector
/// ([`crate::dispatch_table`], [`crate::inbound_table`], [`crate::function_table`]) and
/// [`ProtocolRegistry`](crate::protocol_graph::ProtocolRegistry) builds it here from the same
/// `ordered_frameworks` the CLI hands them. One builder, so the two cannot drift into deferring
/// different methods.
pub fn declared_classes<'a>(
    frameworks: impl IntoIterator<Item = &'a Framework>,
) -> Arc<BTreeSet<String>> {
    Arc::new(
        frameworks
            .into_iter()
            .flat_map(|fw| fw.classes.iter().map(|c| c.name.clone()))
            .collect(),
    )
}

/// The whole-program set of class names that must **not** receive the synthetic plain
/// `init(): this` ([`crate::class_surface::has_bindable_init`],
/// `nsobject-plain-init-surface-gap-k122`), because a real descendant somewhere in the corpus
/// already has its **own** ObjC-exposed, bindable `-init` override whose return type is not
/// `instancetype` (a genuine SDK fact — several NetworkExtension/Intents "provider"/"response"
/// families mark the bare `-init` `NS_UNAVAILABLE` in favor of a required-argument designated
/// initializer, which this pipeline does not yet track as a distinct "unavailable" concept;
/// tracking that is separate, out-of-scope future work). TypeScript's override-compatibility rule
/// requires a subclass's declared return to be `this`-or-narrower, and nothing is narrower than
/// `this`, so no return-type choice on the ancestor's synthetic member can admit such a
/// descendant — the ancestor is simply left with **no** synthetic member, exactly its pre-fix
/// posture (it keeps whatever bindable `init` — none — it already had).
///
/// Pure and whole-program: every class's own `ancestors` list (populated by the resolve phase,
/// [`Class::ancestors`]) is walked once, independent of per-framework emission order — the same
/// shape as [`declared_classes`]/[`ClassRegistry`], built once by the CLI over every loaded
/// framework and threaded into each per-framework render pass.
pub fn synthetic_init_blocklist(frameworks: &[&Framework]) -> BTreeSet<String> {
    let mut blocked = BTreeSet::new();
    for fw in frameworks {
        for cls in &fw.classes {
            let has_incompatible_own_init = cls.methods.iter().any(|m| {
                m.selector == "init"
                    && !m.class_method
                    && m.objc_exposed
                    && !matches!(m.return_type.kind, TypeRefKind::Instancetype)
            });
            if has_incompatible_own_init {
                blocked.extend(cls.ancestors.iter().cloned());
            }
        }
    }
    blocked
}

/// The class a bound ES6 class `extends`, and how to reach it.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum ParentRef {
    /// Extend the runtime-owned `NSObject` root (already provided by the runtime — no
    /// extra framework dependency).
    RuntimeRoot,
    /// Extend a sibling class in the same framework.
    Local(String),
    /// Extend a class owned by another framework; `fw_low` is its lowercase directory.
    CrossFramework { name: String, fw_low: String },
}

impl ParentRef {
    /// The ObjC class name of the parent (`NSObject` for the runtime root). The TS class
    /// identifier is computed by the emitter via
    /// [`naming::class_type_name`](crate::naming::class_type_name); this returns the raw
    /// ObjC name the naming pass maps from.
    pub fn objc_name(&self) -> &str {
        match self {
            ParentRef::RuntimeRoot => RUNTIME_ROOT,
            ParentRef::Local(name) => name,
            ParentRef::CrossFramework { name, .. } => name,
        }
    }
}

/// The resolved class graph for one framework: every collected class's parent, plus any
/// bare intermediate nodes that had to be synthesized.
#[derive(Debug, Clone, Default)]
pub struct ClassGraph {
    /// Collected class name → its resolved parent.
    pub parents: HashMap<String, ParentRef>,
    /// Names of synthesized bare intermediate nodes (deterministically sorted), each
    /// emitted by the orchestrator as its own minimal `class … extends NSObject {}`
    /// rooted on [`RUNTIME_ROOT`].
    pub synthesized: Vec<String>,
    /// `(class, raw_superclass)` pairs where a declared class's superclass string was not a
    /// valid TS identifier and was **degraded** to [`ParentRef::RuntimeRoot`] rather than
    /// synthesized as an unparseable bare node (module doc; `generic-class-name-surface-k78`).
    /// Measured, not assumed empty — over the real macOS SDK corpus this is empty once
    /// `extract-swift`'s `extract_simple_name` is fixed; a future non-empty value here is a
    /// *new* malformed shape, not a regression of this one.
    pub degraded: Vec<(String, String)>,
}

/// Resolve the class graph for one framework against the cross-framework ownership
/// registry. Pure and deterministic.
pub fn build_class_graph(fw: &Framework, registry: &ClassRegistry) -> ClassGraph {
    let local: BTreeSet<&str> = fw.classes.iter().map(|c| c.name.as_str()).collect();

    let mut parents: HashMap<String, ParentRef> = HashMap::new();
    let mut synthesized: BTreeSet<String> = BTreeSet::new();
    let mut degraded: Vec<(String, String)> = Vec::new();

    for cls in &fw.classes {
        let parent = resolve_parent(&cls.superclass, &local, registry, &mut synthesized);
        let parent = match parent {
            Some(p) => p,
            None => {
                degraded.push((cls.name.clone(), cls.superclass.clone()));
                ParentRef::RuntimeRoot
            }
        };
        parents.insert(cls.name.clone(), parent);
    }

    ClassGraph {
        parents,
        synthesized: synthesized.into_iter().collect(),
        degraded,
    }
}

/// Resolve one class's immediate superclass to a [`ParentRef`], synthesizing a bare local
/// node for an unresolvable same-framework gap. Returns `None` — a degradation, not a gap —
/// when `superclass` is non-empty and not a valid TS identifier (module doc): an unparseable
/// name must never become a bare node's name, so it is never inserted into `synthesized`.
fn resolve_parent(
    superclass: &str,
    local: &BTreeSet<&str>,
    registry: &ClassRegistry,
    synthesized: &mut BTreeSet<String>,
) -> Option<ParentRef> {
    if superclass.is_empty() || superclass == RUNTIME_ROOT {
        return Some(ParentRef::RuntimeRoot);
    }
    if local.contains(superclass) {
        return Some(ParentRef::Local(superclass.to_string()));
    }
    if let Some(fw_low) = registry.owner(superclass) {
        return Some(ParentRef::CrossFramework {
            name: superclass.to_string(),
            fw_low: fw_low.to_string(),
        });
    }
    if !is_valid_ts_identifier(superclass) {
        return None;
    }
    // Same-framework gap: not collected, not owned elsewhere. Synthesize a bare node for
    // it locally and link the child to that node.
    synthesized.insert(superclass.to_string());
    Some(ParentRef::Local(superclass.to_string()))
}

/// Order a framework's collected classes **superclass-before-subclass** (a stable DFS
/// post-order over the same-framework `Local` parent edges). Cross-framework and
/// runtime-root parents impose no local ordering; a `Local` parent that is a synthesized
/// bare node (not itself collected) has no edge here, so the orchestrator emits it ahead
/// of all collected classes. Ties break by IR order (the DFS visits in IR order),
/// keeping goldens deterministic.
pub fn ordered_classes<'a>(fw: &'a Framework, graph: &ClassGraph) -> Vec<&'a Class> {
    let index: HashMap<&str, usize> = fw
        .classes
        .iter()
        .enumerate()
        .map(|(i, c)| (c.name.as_str(), i))
        .collect();
    let mut visited = vec![false; fw.classes.len()];
    let mut order: Vec<&Class> = Vec::with_capacity(fw.classes.len());
    for i in 0..fw.classes.len() {
        visit_class(i, fw, graph, &index, &mut visited, &mut order);
    }
    order
}

fn visit_class<'a>(
    i: usize,
    fw: &'a Framework,
    graph: &ClassGraph,
    index: &HashMap<&str, usize>,
    visited: &mut [bool],
    order: &mut Vec<&'a Class>,
) {
    if visited[i] {
        return;
    }
    visited[i] = true;
    if let Some(ParentRef::Local(parent)) = graph.parents.get(&fw.classes[i].name) {
        if let Some(&pi) = index.get(parent.as_str()) {
            visit_class(pi, fw, graph, index, visited, order);
        }
    }
    order.push(&fw.classes[i]);
}

/// Resolves the **module specifier** a referenced class type is imported from — the seam
/// the per-class emitters route their cross-class imports through (ADR-0055 §2), in
/// place of the k18/k19 hardcoded `@apianyware/runtime`.
///
/// - `NSObject` (the runtime root) → [`RUNTIME_MODULE`].
/// - a class the [`ClassRegistry`] owns → its owning `@apianyware/<fw>` package
///   ([`naming::module_specifier`](crate::naming::module_specifier)).
/// - any other class → the **same-framework fallback**: the current framework's module.
///   A same-framework sibling therefore imports through *its own* framework's package
///   barrel (`@apianyware/foundation`), which is cycle-safe under ESM only because the
///   barrel re-exports superclass-before-subclass ([`ordered_classes`]). In an
///   unconfigured (empty-registry) emitter every non-root class hits this fallback —
///   correct for same-framework refs, and the documented degradation for an unresolvable
///   cross-framework ref (mirrors [`build_class_graph`]'s same-framework-gap rule); the
///   Step-5 CLI pre-pass populates the registry so genuine cross-framework refs resolve.
///
/// It also carries the **known-class recognition set** — every class the IR declares,
/// whole-program — the third of the class/enum/protocol resolvers to do so (its
/// [`EnumModuleResolver`](crate::enum_graph::EnumModuleResolver) and
/// [`ProtocolModuleResolver`](crate::protocol_graph::ProtocolModuleResolver) siblings already
/// pair a registry with a recognition set). The emitters build their
/// [`TsFfiTypeMapper`](crate::ffi_type_mapping::TsFfiTypeMapper) from it, so a `Class{name}` the
/// IR never declares degrades to the runtime root instead of routing a value import through
/// `module_for`'s same-framework fallback to a barrel that cannot export it — the dangling
/// import `swift-nominal-type-surface-k66` closes. **A name reaching [`Self::module_for`] is
/// therefore always bound**; the fallback survives only for the unconfigured (recognition-free)
/// emitter.
#[derive(Debug, Clone)]
pub struct ClassModuleResolver<'a> {
    framework: String,
    registry: &'a ClassRegistry,
    known_classes: Arc<BTreeSet<String>>,
}

impl<'a> ClassModuleResolver<'a> {
    /// A resolver for the framework currently being emitted, backed by the cross-framework
    /// ownership registry and the whole-program declared-class recognition set (struct doc).
    pub fn new(
        framework: &str,
        registry: &'a ClassRegistry,
        known_classes: Arc<BTreeSet<String>>,
    ) -> Self {
        Self {
            framework: framework.to_string(),
            registry,
            known_classes,
        }
    }

    /// The display name of the framework being emitted — the banner text and the
    /// same-framework fallback module ([`Self::module_for`]). Lets the per-class
    /// emitters carry only the resolver, not a redundant `framework` argument.
    pub fn framework(&self) -> &str {
        &self.framework
    }

    /// The whole-program set of classes the IR declares — the recognition set the emitters'
    /// [`TsFfiTypeMapper`](crate::ffi_type_mapping::TsFfiTypeMapper) and the
    /// [`class_binding`](crate::class_binding) rule read (struct doc). Shared cheaply (`Arc`),
    /// exactly as [`EnumModuleResolver::known_enums`](crate::enum_graph::EnumModuleResolver::known_enums)
    /// is.
    pub fn known_classes(&self) -> Arc<BTreeSet<String>> {
        Arc::clone(&self.known_classes)
    }

    /// The module specifier `class_name` is imported from (module doc).
    pub fn module_for(&self, class_name: &str) -> String {
        if class_name == RUNTIME_ROOT {
            return RUNTIME_MODULE.to_string();
        }
        match self.registry.owner(class_name) {
            Some(fw_low) => module_specifier(fw_low),
            None => module_specifier(&self.framework),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use apianyware_types::ir::Method;
    use apianyware_types::type_ref::TypeRef;

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

    /// `cls`, plus an `ancestors` list (the resolve-phase fact
    /// [`synthetic_init_blocklist`] walks — never derived from `superclass` here).
    fn cls_with_ancestors(name: &str, superclass: &str, ancestors: &[&str]) -> Class {
        Class {
            ancestors: ancestors.iter().map(|s| s.to_string()).collect(),
            ..cls(name, superclass)
        }
    }

    fn bare_init(return_kind: TypeRefKind, objc_exposed: bool) -> Method {
        Method {
            selector: "init".into(),
            class_method: false,
            init_method: true,
            params: vec![],
            return_type: TypeRef {
                nullable: false,
                kind: return_kind,
            },
            deprecated: false,
            variadic: false,
            source: None,
            provenance: None,
            doc_refs: None,
            origin: None,
            category: None,
            overrides: None,
            returns_retained: None,
            satisfies_protocol: None,
            objc_exposed,
            swift_fn: None,
        }
    }

    fn fw(name: &str, classes: Vec<Class>) -> Framework {
        Framework {
            format_version: "1.0".into(),
            checkpoint: "resolved".into(),
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
            patterns: vec![],
            enrichment: None,
            verification: None,
        }
    }

    // --- parent resolution ----------------------------------------------------------

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
        // NSProxy is an independent ObjC root; we root it on the runtime NSObject for the
        // shared branded handle.
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
        // A chain Leaf -> Mid -> NSObject where Mid is referenced but not collected and
        // not owned elsewhere: Mid is synthesized as a bare node and Leaf links to it
        // locally.
        let f = fw("Widgets", vec![cls("Leaf", "Mid")]);
        let g = build_class_graph(&f, &ClassRegistry::new());
        assert_eq!(g.parents["Leaf"], ParentRef::Local("Mid".into()));
        assert_eq!(g.synthesized, vec!["Mid".to_string()]);
        assert!(g.degraded.is_empty());
    }

    #[test]
    fn unparseable_superclass_degrades_to_runtime_root_not_a_bare_node() {
        // generic-class-name-surface-k78's belt-and-suspenders floor: a superclass string
        // that is not a valid TS identifier (e.g. a leaked printed generic instantiation)
        // must never become a bare node's name — it degrades straight to the runtime root,
        // and is recorded (never dropped silently), instead of being synthesized into
        // `Gap.ts` under an unparseable name.
        let f = fw(
            "AppIntents",
            vec![cls(
                "ContainsComparator",
                "EntityQueryComparator<τ_0_0, τ_0_1, τ_0_2, τ_0_3>",
            )],
        );
        let g = build_class_graph(&f, &ClassRegistry::new());
        assert_eq!(g.parents["ContainsComparator"], ParentRef::RuntimeRoot);
        assert!(
            g.synthesized.is_empty(),
            "an unparseable name must never be synthesized as a bare node"
        );
        assert_eq!(
            g.degraded,
            vec![(
                "ContainsComparator".to_string(),
                "EntityQueryComparator<τ_0_0, τ_0_1, τ_0_2, τ_0_3>".to_string()
            )]
        );
    }

    #[test]
    fn synthesized_nodes_are_sorted_deterministically() {
        // Two same-framework gaps, referenced in reverse alphabetical IR order, come back
        // sorted (the BTreeSet), so goldens stay deterministic.
        let f = fw(
            "Widgets",
            vec![cls("AThing", "ZParent"), cls("BThing", "MParent")],
        );
        let g = build_class_graph(&f, &ClassRegistry::new());
        assert_eq!(
            g.synthesized,
            vec!["MParent".to_string(), "ZParent".to_string()]
        );
    }

    #[test]
    fn parent_ref_objc_name() {
        assert_eq!(ParentRef::RuntimeRoot.objc_name(), "NSObject");
        assert_eq!(ParentRef::Local("NSView".into()).objc_name(), "NSView");
        assert_eq!(
            ParentRef::CrossFramework {
                name: "NSString".into(),
                fw_low: "foundation".into()
            }
            .objc_name(),
            "NSString"
        );
    }

    // --- load order -----------------------------------------------------------------

    #[test]
    fn ordered_classes_place_superclass_before_subclass() {
        // IR order deliberately reversed (subclass first) — `ordered_classes` must still
        // place NSResponder before NSView before NSControl (the barrel re-export order
        // that keeps a same-framework extends chain ESM-cycle-safe).
        let f = fw(
            "AppKit",
            vec![
                cls("NSControl", "NSView"),
                cls("NSView", "NSResponder"),
                cls("NSResponder", "NSObject"),
            ],
        );
        let g = build_class_graph(&f, &ClassRegistry::new());
        let order: Vec<&str> = ordered_classes(&f, &g)
            .iter()
            .map(|c| c.name.as_str())
            .collect();
        assert_eq!(order, vec!["NSResponder", "NSView", "NSControl"]);
    }

    #[test]
    fn ordered_classes_ties_break_by_ir_order() {
        // Two independent runtime-rooted chains: no cross edges, so the DFS visits in IR
        // order and preserves it.
        let f = fw(
            "Foundation",
            vec![
                cls("NSString", "NSObject"),
                cls("NSArray", "NSObject"),
                cls("NSMutableArray", "NSArray"),
            ],
        );
        let g = build_class_graph(&f, &ClassRegistry::new());
        let order: Vec<&str> = ordered_classes(&f, &g)
            .iter()
            .map(|c| c.name.as_str())
            .collect();
        assert_eq!(order, vec!["NSString", "NSArray", "NSMutableArray"]);
    }

    #[test]
    fn ordered_classes_ignore_cross_framework_and_root_parents() {
        // A cross-framework parent imposes no local order — the single class comes back
        // as-is (no attempt to visit a parent that is not in this framework).
        let mut reg = ClassRegistry::new();
        reg.insert("NSMutableAttributedString", "foundation");
        let f = fw(
            "AppKit",
            vec![cls("NSTextStorage", "NSMutableAttributedString")],
        );
        let g = build_class_graph(&f, &reg);
        let order: Vec<&str> = ordered_classes(&f, &g)
            .iter()
            .map(|c| c.name.as_str())
            .collect();
        assert_eq!(order, vec!["NSTextStorage"]);
    }

    // --- the registry ----------------------------------------------------------------

    #[test]
    fn from_frameworks_first_owner_wins() {
        let foundation = fw("Foundation", vec![cls("NSValue", "NSObject")]);
        let appkit = fw("AppKit", vec![cls("NSView", "NSObject")]);
        let reg = ClassRegistry::from_frameworks(&[foundation, appkit]);
        assert_eq!(reg.owner("NSValue"), Some("foundation"));
        assert_eq!(reg.owner("NSView"), Some("appkit"));
        assert_eq!(reg.owner("DoesNotExist"), None);
    }

    #[test]
    fn from_framework_refs_matches_owned_variant() {
        let foundation = fw("Foundation", vec![cls("NSValue", "NSObject")]);
        let appkit = fw("AppKit", vec![cls("NSView", "NSObject")]);
        let refs = vec![&foundation, &appkit];
        let reg = ClassRegistry::from_framework_refs(&refs);
        assert_eq!(reg.owner("NSValue"), Some("foundation"));
        assert_eq!(reg.owner("NSView"), Some("appkit"));
    }

    // --- the class→module resolver ---------------------------------------------------

    #[test]
    fn resolver_routes_the_runtime_root_to_the_runtime_module() {
        let reg = ClassRegistry::new();
        let r = ClassModuleResolver::new("Foundation", &reg, Arc::new(reg.names()));
        assert_eq!(r.module_for("NSObject"), "@apianyware/runtime");
    }

    #[test]
    fn resolver_routes_a_same_framework_class_to_its_own_module() {
        // Empty registry (unconfigured emitter): a same-framework sibling falls back to
        // the current framework's package barrel.
        let reg = ClassRegistry::new();
        let r = ClassModuleResolver::new("Foundation", &reg, Arc::new(reg.names()));
        assert_eq!(r.module_for("NSString"), "@apianyware/foundation");
        assert_eq!(r.module_for("NSMutableString"), "@apianyware/foundation");
    }

    #[test]
    fn resolver_routes_a_cross_framework_class_via_the_registry() {
        // A populated registry (the CLI pre-pass shape): a referenced class owned
        // elsewhere routes to that framework's module, even while emitting AppKit.
        let mut reg = ClassRegistry::new();
        reg.insert("NSString", "foundation");
        let r = ClassModuleResolver::new("AppKit", &reg, Arc::new(reg.names()));
        assert_eq!(r.module_for("NSString"), "@apianyware/foundation");
    }

    #[test]
    fn resolver_falls_back_to_current_framework_for_an_unknown_class() {
        // An unresolvable class (not the root, not registry-owned) degrades to the
        // current framework — the resolver analogue of the same-framework-gap rule.
        let mut reg = ClassRegistry::new();
        reg.insert("NSString", "foundation");
        let r = ClassModuleResolver::new("AppKit", &reg, Arc::new(reg.names()));
        assert_eq!(r.module_for("NSSomethingUncollected"), "@apianyware/appkit");
    }

    #[test]
    fn resolver_module_specifier_is_lowercased_regardless_of_input_case() {
        // The current-framework fallback lowercases the display name (module_specifier
        // is idempotent under case), and a registry owner is already lowercase.
        let reg = ClassRegistry::new();
        let r = ClassModuleResolver::new("WebKit", &reg, Arc::new(reg.names()));
        assert_eq!(r.module_for("WKWebView"), "@apianyware/webkit");
    }

    #[test]
    fn resolver_carries_the_display_framework_name() {
        // The banner + same-framework fallback read the display name back off the
        // resolver, so the per-class emitters need no redundant framework argument.
        let reg = ClassRegistry::new();
        let r = ClassModuleResolver::new("Foundation", &reg, Arc::new(reg.names()));
        assert_eq!(r.framework(), "Foundation");
    }

    // --- synthetic-init blocklist (nsobject-plain-init-surface-gap-k122) -------------

    #[test]
    fn blocklists_every_ancestor_of_a_class_with_an_incompatible_own_init() {
        // INAnswerCallIntentResponse's real shape: `- (id)init NS_UNAVAILABLE;` (own,
        // objc-exposed, non-instancetype) — both its ancestors must be blocked, not just
        // the immediate parent, since the synthetic member could land on either.
        let mut leaf = cls_with_ancestors(
            "INAnswerCallIntentResponse",
            "INIntentResponse",
            &["INIntentResponse", "NSObject"],
        );
        leaf.methods = vec![bare_init(TypeRefKind::Id { protocols: vec![] }, true)];
        let f = fw("Intents", vec![cls("INIntentResponse", "NSObject"), leaf]);
        let blocked = synthetic_init_blocklist(&[&f]);
        assert!(blocked.contains("INIntentResponse"));
        assert!(blocked.contains("NSObject"));
    }

    #[test]
    fn does_not_blocklist_an_ordinary_instancetype_init() {
        // The overwhelmingly common case (`initWith…:`-family designated initializers all
        // return instancetype) must never block anything.
        let mut leaf = cls_with_ancestors("Widget", "NSObject", &["NSObject"]);
        leaf.methods = vec![bare_init(TypeRefKind::Instancetype, true)];
        let f = fw("TestKit", vec![leaf]);
        assert!(synthetic_init_blocklist(&[&f]).is_empty());
    }

    #[test]
    fn ignores_a_swift_native_own_init_with_no_objc_selector() {
        // `objc_exposed == false` (ADR-0026): no ObjC message-send path exists for this
        // declaration, so it can never conflict with a dispatched synthetic `init(): this`.
        let mut leaf = cls_with_ancestors("SwiftOnly", "NSObject", &["NSObject"]);
        leaf.methods = vec![bare_init(TypeRefKind::Class {
            name: "NSObject".into(),
            framework: None,
            params: vec![],
        }, false)];
        let f = fw("SwiftKit", vec![leaf]);
        assert!(synthetic_init_blocklist(&[&f]).is_empty());
    }

    #[test]
    fn ignores_a_class_method_named_init() {
        // Selector identity alone is not enough — the conflict is specifically an
        // *instance* method override.
        let mut leaf = cls_with_ancestors("Widget", "NSObject", &["NSObject"]);
        leaf.methods = vec![bare_init(TypeRefKind::Id { protocols: vec![] }, true)];
        leaf.methods[0].class_method = true;
        let f = fw("TestKit", vec![leaf]);
        assert!(synthetic_init_blocklist(&[&f]).is_empty());
    }

    #[test]
    fn walks_every_loaded_framework_not_just_one() {
        // The whole-program shape ([`ClassRegistry::from_framework_refs`]'s own sibling):
        // the conflicting class and its blocked ancestor may live in different frameworks.
        let mut leaf = cls_with_ancestors("NEAppProxyProvider", "NEProvider", &["NEProvider", "NSObject"]);
        leaf.methods = vec![bare_init(TypeRefKind::Id { protocols: vec![] }, true)];
        let base = fw("NetworkExtension", vec![cls("NEProvider", "NSObject")]);
        let derived = fw("NetworkExtension2", vec![leaf]);
        let blocked = synthetic_init_blocklist(&[&base, &derived]);
        assert!(blocked.contains("NEProvider"));
    }
}
