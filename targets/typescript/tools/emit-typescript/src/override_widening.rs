//! **Override param widening** — the rendering policy for a member the SDK redeclares with a
//! parameter type TypeScript cannot accept as an override of its ancestor's
//! (`sdk-override-incompatibility-policy-k105`, ADR-0055 §4b).
//!
//! ObjC does not enforce override covariance, and Apple's own headers exploit that:
//! `NSOutlineView` narrows `setDataSource:` to `id<NSOutlineViewDataSource>` where its ancestor
//! `NSTableView` declared `id<NSTableViewDataSource>` — two protocols with **no** `inherits`
//! relation — and `NSSavePanel` does the same to `NSWindow`'s `setDelegate:`. TypeScript's
//! structural override check (TS2416) compares method params **bivariantly**: the override is
//! legal iff either param type is assignable to the other. Two unrelated all-`@optional`
//! interfaces fail both directions (the weak-type overlap rule), so the emitted class would not
//! compile.
//!
//! Within a real `extends` chain the only expressible-compatible rendering is one where the
//! ancestor's type is assignable to the override's — the override must **admit** the ancestor's
//! type. So the policy is a **union, SDK-intended type first**:
//! `setDataSource_(dataSource: NSOutlineViewDataSource | NSTableViewDataSource)`. This admits
//! nothing inheritance did not already admit — `(ov as NSTableView).setDataSource_(x)` accepts
//! the ancestor's type today, exactly as ObjC's own receiver upcast does — it just spells the
//! inherited contract on the member itself. The body is untouched: a wrapped ObjC object (the
//! common case) unwraps identically, and a JS literal still bridges through the override's own
//! `SPEC_<P>` (ADR-0059 §3).
//!
//! A return position cannot **widen** the same way (returns are covariant — a union is a
//! supertype, the wrong direction) — the measured population of genuine SDK-authored return
//! incompatibilities was zero when this module was designed, and the corpus typecheck gate
//! (`corpus-typecheck-gate-k75`) is the guard for if that ever changes. It did
//! (`text-undo-surface-gap-k121`): merging category methods into `Class::methods` newly surfaces
//! `NSControl.selectedCell` (`NSCell`, a category method), which `NSBrowser` overrides with a bare
//! `id`. The narrow, sound fix is **narrowing**, not widening: a bare `id` return carries no
//! information a typed ancestor return doesn't already provide, so rendering the ancestor's own
//! type instead (`OverrideWidenings::narrowed_return`) is never a lie — the dispatch entry is
//! unchanged (same selector, same ABI shape), only the declared TS type gets more precise.
//!
//! ## The compatibility predicate is nominal and conservative-to-no-change
//!
//! The emitter cannot run `tsc`'s structural check, so [`param_compatible`] approximates it with
//! the facts the emitter already owns, defaulting to **compatible (change nothing)** wherever it
//! cannot prove trouble — a false "compatible" is caught by the corpus gate, while a false
//! "incompatible" would silently widen a signature that was fine:
//!
//! - identical rendered tokens → compatible (scalars, same class, same qualifier list);
//! - two **bound protocol-qualifier** sets → compatible iff either set subsumes the other over
//!   the protocol `inherits` closure (the bivariant check on the one axis the emitter can prove;
//!   `NSMachPortDelegate` vs `NSPortDelegate` stays unwidened because the closure relates them —
//!   the k104 shape);
//! - anything else (class narrowings ride the branded `extends` chain structurally; mixed shapes
//!   have zero corpus occurrences) → compatible.
//!
//! ## Scope limits (documented, gate-guarded)
//!
//! The ancestor walk sees the **current framework's** classes only (the per-framework emit has
//! no cross-framework `Class` data — the same scope limit ADR-0055 §4b's per-framework
//! transitive-emittability callers carry); both corpus occurrences are AppKit-internal. It
//! consults the ancestor's **own declared** methods (`Class::methods`), not its
//! protocol-flattened frontier — a flattened-vs-flattened conflict (`accessibilityRows`) is an
//! upstream IR mis-classification tracked by `protocol-optionality-mis-extraction-k99`, not a
//! rendering-policy case.

use std::collections::BTreeMap;

use apianyware_emit::ffi_type_mapping::FfiTypeMapper;
use apianyware_types::ir::{Class, Method};
use apianyware_types::type_ref::{TypeRef, TypeRefKind};

use crate::ffi_type_mapping::TsFfiTypeMapper;
use crate::protocol_binding::bound_protocols;
use crate::protocol_graph::ProtocolRegistry;

/// Per-class map of the params whose rendered type must union in the ancestor's —
/// `(selector, class_method, param_index)` → the nearest declaring ancestor's param `TypeRef`.
/// Computed once per class ([`override_param_widenings`]) and read by every renderer and import
/// walker (`method_header`, `referenced_class_types`, `referenced_protocol_types`), so the
/// signature token and its imports cannot drift (the k57 "one decision, N readers" discipline).
///
/// Also carries the rare **return-narrowing** case (`text-undo-surface-gap-k121`): a return is
/// covariant, so a union (the param policy) cannot make an incompatible override expressible —
/// only the ancestor's return itself can. That is sound *only* when the class's own declared
/// return is a bare, unqualified `id` (`is_bare_id_return`): a bare `id` carries no information a
/// typed ancestor return doesn't already provide (the same "a lossy map/fact loses to a typed
/// one" rule `checkpoint::is_bare_id_return` already applies to protocol-origin collisions), so
/// rendering the ancestor's type instead is never a lie, and the dispatch entry is unchanged
/// (same selector, same zero-arg object-return ABI shape) — only the declared TS type gets more
/// precise. First measured instance: `NSBrowser.selectedCell` (bare `id`) overriding
/// `NSControl.selectedCell` (`NSCell`, a category method — invisible before category methods
/// were merged into `Class::methods`).
#[derive(Debug, Default)]
pub struct OverrideWidenings {
    map: BTreeMap<(String, bool, usize), TypeRef>,
    return_map: BTreeMap<(String, bool), TypeRef>,
}

impl OverrideWidenings {
    /// No widenings — the correct value for surfaces with no class ancestry (protocol members)
    /// and for tests exercising unrelated concerns.
    pub fn empty() -> Self {
        Self::default()
    }

    /// The ancestor param type `method`'s param `idx` must union in, if its own declared type
    /// is not an expressible TS override of it.
    pub fn widened(&self, method: &Method, idx: usize) -> Option<&TypeRef> {
        self.map
            .get(&(method.selector.clone(), method.class_method, idx))
    }

    /// The ancestor's return type to render instead of `method`'s own bare `id` — `None` for
    /// every method whose own return already carries real information.
    pub fn narrowed_return(&self, method: &Method) -> Option<&TypeRef> {
        self.return_map
            .get(&(method.selector.clone(), method.class_method))
    }

    /// Every widened-in ancestor `TypeRef` — the import walkers' input: a union member (or a
    /// narrowed return) is a referenced type exactly like a declared one, so its class/protocol
    /// names join the same import sets the signature's own types do.
    pub fn type_refs(&self) -> impl Iterator<Item = &TypeRef> {
        self.map.values().chain(self.return_map.values())
    }
}

/// A bare, unqualified `id` return (`TypeRefKind::Id` with no protocol qualifiers) — the least
/// specific object type a declaration can carry. Mirrors `resolve`'s own
/// `checkpoint::is_bare_id_return` (a different crate, the same type-shape test applied to a
/// different decision — dedup vs. render-time narrowing — so it is duplicated here rather than
/// shared across a crate boundary neither module otherwise needs).
fn is_bare_id_return(t: &TypeRef) -> bool {
    matches!(&t.kind, TypeRefKind::Id { protocols } if protocols.is_empty())
}

/// Compute the widenings for `cls`'s emitted methods (`class_methods` + `instance_methods`,
/// the [`crate::class_surface::bound_methods`] frontier — only a rendered member can need one).
/// `class_index` is the current framework's classes by ObjC name (the ancestor walk's world —
/// see the module doc's scope limits).
pub fn override_param_widenings(
    cls: &Class,
    class_methods: &[&Method],
    instance_methods: &[&Method],
    class_index: &BTreeMap<&str, &Class>,
    mapper: &TsFfiTypeMapper,
    registry: &ProtocolRegistry,
) -> OverrideWidenings {
    let mut map = BTreeMap::new();
    let mut return_map = BTreeMap::new();
    for m in class_methods.iter().chain(instance_methods.iter()) {
        let Some(anc) = nearest_declaring_ancestor(cls, m, class_index) else {
            continue;
        };
        // Same selector ⇒ same arity in ObjC; zip is defensive against a malformed IR pair.
        for (idx, (own_p, anc_p)) in m.params.iter().zip(anc.params.iter()).enumerate() {
            if !param_compatible(&own_p.param_type, &anc_p.param_type, mapper, registry) {
                map.insert(
                    (m.selector.clone(), m.class_method, idx),
                    anc_p.param_type.clone(),
                );
            }
        }
        // Returns are covariant, so a union cannot make an incompatible override expressible
        // (module doc) — only when the class's own return is an uninformative bare `id` can the
        // ancestor's own (strictly more specific) return be rendered instead, soundly.
        if is_bare_id_return(&m.return_type) && !is_bare_id_return(&anc.return_type) {
            return_map.insert(
                (m.selector.clone(), m.class_method),
                anc.return_type.clone(),
            );
        }
    }
    OverrideWidenings { map, return_map }
}

/// The nearest ancestor (walking `Class::superclass` through `class_index`) that **declares**
/// `m`'s selector itself — the member TS compares the override against. `None` when no indexed
/// ancestor declares it (including a chain that leaves the framework — the scope limit).
fn nearest_declaring_ancestor<'i>(
    cls: &Class,
    m: &Method,
    class_index: &BTreeMap<&str, &'i Class>,
) -> Option<&'i Method> {
    let mut cur = cls.superclass.as_str();
    while !cur.is_empty() && cur != "NSObject" {
        let anc = class_index.get(cur)?;
        if let Some(am) = anc.methods.iter().find(|am| {
            am.selector == m.selector && am.class_method == m.class_method && am.objc_exposed
        }) {
            return Some(am);
        }
        cur = anc.superclass.as_str();
    }
    None
}

/// Whether `own` is an expressible TS override of an inherited param declared `anc` — the
/// nominal, conservative approximation of `tsc`'s bivariant param check (module doc).
fn param_compatible(
    own: &TypeRef,
    anc: &TypeRef,
    mapper: &TsFfiTypeMapper,
    registry: &ProtocolRegistry,
) -> bool {
    if mapper.map_type(own, false) == mapper.map_type(anc, false) {
        return true;
    }
    let own_ps = bound_protocols(own, mapper);
    let anc_ps = bound_protocols(anc, mapper);
    if own_ps.is_empty() || anc_ps.is_empty() {
        // Not two bound qualifier sets — no measured incompatibility outside that shape
        // (module doc); stay conservative, the corpus gate is the guard.
        return true;
    }
    protocol_set_subsumes(&own_ps, &anc_ps, registry)
        || protocol_set_subsumes(&anc_ps, &own_ps, registry)
}

/// Whether an interface typed by `sub`'s intersection is assignable to one typed by `sup`'s —
/// every name in `sup` reachable from `sub` over the protocol `inherits` closure
/// ([`ProtocolRegistry::conformance_closure`], which contains its registry-known seeds).
fn protocol_set_subsumes(sub: &[&str], sup: &[&str], registry: &ProtocolRegistry) -> bool {
    let seeds: Vec<String> = sub.iter().map(|s| s.to_string()).collect();
    let closure = registry.conformance_closure(&seeds);
    sup.iter().all(|q| closure.contains(*q))
}

#[cfg(test)]
mod tests {
    use super::*;
    use apianyware_types::ir::{Framework, Param, Protocol};
    use apianyware_types::type_ref::TypeRefKind;
    use std::collections::BTreeSet;
    use std::sync::Arc;

    fn qualified_id(protocols: &[&str]) -> TypeRef {
        TypeRef {
            nullable: false,
            kind: TypeRefKind::Id {
                protocols: protocols.iter().map(|s| s.to_string()).collect(),
            },
        }
    }

    fn method(selector: &str, params: Vec<Param>) -> Method {
        Method {
            selector: selector.into(),
            class_method: false,
            init_method: false,
            params,
            return_type: TypeRef::void(),
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
            objc_exposed: true,
            swift_fn: None,
        }
    }

    fn param(name: &str, param_type: TypeRef) -> Param {
        Param {
            name: name.into(),
            param_type,
        }
    }

    fn class(name: &str, superclass: &str, methods: Vec<Method>) -> Class {
        Class {
            name: name.into(),
            superclass: superclass.into(),
            protocols: vec![],
            properties: vec![],
            methods,
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
            swift_name: None,
        }
    }

    fn protocol(name: &str, inherits: &[&str]) -> Protocol {
        Protocol {
            name: name.into(),
            inherits: inherits.iter().map(|s| s.to_string()).collect(),
            required_methods: vec![method("go", vec![])],
            optional_methods: vec![],
            properties: vec![],
            source: None,
            provenance: None,
            doc_refs: None,
            objc_exposed: true,
        }
    }

    fn framework(name: &str, protocols: Vec<Protocol>) -> Framework {
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

    /// A mapper recognising the given protocols (so their qualifiers bind) and no classes.
    fn mapper(protocols: &[&str]) -> TsFfiTypeMapper {
        let protos: BTreeSet<String> = protocols.iter().map(|s| s.to_string()).collect();
        TsFfiTypeMapper::with_known(
            Arc::new(BTreeSet::new()),
            Arc::new(BTreeSet::new()),
            Arc::new(protos),
        )
    }

    fn compute(
        base: &Class,
        sub: &Class,
        m: &TsFfiTypeMapper,
        reg: &ProtocolRegistry,
    ) -> OverrideWidenings {
        let index: BTreeMap<&str, &Class> =
            [(base.name.as_str(), base), (sub.name.as_str(), sub)].into();
        let instance_methods: Vec<&Method> = sub.methods.iter().collect();
        override_param_widenings(sub, &[], &instance_methods, &index, m, reg)
    }

    /// The NSOutlineView shape: the override narrows to a protocol **unrelated** to the
    /// ancestor's — TS accepts neither direction, so the param widens to the union.
    #[test]
    fn unrelated_protocol_redeclaration_widens_to_the_ancestors_type() {
        let base = class(
            "Table",
            "",
            vec![method(
                "setDataSource:",
                vec![param("d", qualified_id(&["TableSource"]))],
            )],
        );
        let sub = class(
            "Outline",
            "Table",
            vec![method(
                "setDataSource:",
                vec![param("d", qualified_id(&["OutlineSource"]))],
            )],
        );
        let fw = framework(
            "AppKit",
            vec![protocol("TableSource", &[]), protocol("OutlineSource", &[])],
        );
        let reg = ProtocolRegistry::from_framework_refs(&[&fw]);
        let m = mapper(&["TableSource", "OutlineSource"]);
        let w = compute(&base, &sub, &m, &reg);
        let anc = w
            .widened(&sub.methods[0], 0)
            .expect("unrelated redeclaration must widen");
        assert_eq!(m.map_type(anc, false), "TableSource");
        assert_eq!(w.type_refs().count(), 1);
    }

    /// The NSMachPortDelegate shape (k104): the override's protocol **inherits** the
    /// ancestor's — assignable over the closure, a legal TS narrowing, no widening.
    #[test]
    fn an_inheriting_protocol_redeclaration_stays_unwidened() {
        let base = class(
            "Port",
            "",
            vec![method(
                "setDelegate:",
                vec![param("d", qualified_id(&["PortDelegate"]))],
            )],
        );
        let sub = class(
            "MachPort",
            "Port",
            vec![method(
                "setDelegate:",
                vec![param("d", qualified_id(&["MachPortDelegate"]))],
            )],
        );
        let fw = framework(
            "Foundation",
            vec![
                protocol("PortDelegate", &[]),
                protocol("MachPortDelegate", &["PortDelegate"]),
            ],
        );
        let reg = ProtocolRegistry::from_framework_refs(&[&fw]);
        let m = mapper(&["PortDelegate", "MachPortDelegate"]);
        let w = compute(&base, &sub, &m, &reg);
        assert!(w.widened(&sub.methods[0], 0).is_none());
    }

    /// An identical redeclaration (the overwhelmingly common case) renders the same token and
    /// never widens; the widening walk also skips the trailing identical cells of a multi-param
    /// selector whose first param alone diverges.
    #[test]
    fn identical_types_never_widen() {
        let base = class(
            "Base",
            "",
            vec![method("setThing:", vec![param("t", qualified_id(&["P"]))])],
        );
        let sub = class(
            "Sub",
            "Base",
            vec![method("setThing:", vec![param("t", qualified_id(&["P"]))])],
        );
        let fw = framework("F", vec![protocol("P", &[])]);
        let reg = ProtocolRegistry::from_framework_refs(&[&fw]);
        let m = mapper(&["P"]);
        let w = compute(&base, &sub, &m, &reg);
        assert!(w.widened(&sub.methods[0], 0).is_none());
    }

    /// No indexed ancestor declares the selector (fresh member, or the chain leaves the
    /// framework) — nothing to compare against, nothing widens.
    #[test]
    fn a_fresh_member_or_unindexed_chain_never_widens() {
        let base = class("Base", "Elsewhere", vec![]);
        let sub = class(
            "Sub",
            "Base",
            vec![method("setThing:", vec![param("t", qualified_id(&["P"]))])],
        );
        let fw = framework("F", vec![protocol("P", &[])]);
        let reg = ProtocolRegistry::from_framework_refs(&[&fw]);
        let m = mapper(&["P"]);
        let w = compute(&base, &sub, &m, &reg);
        assert!(w.widened(&sub.methods[0], 0).is_none());
    }
}
