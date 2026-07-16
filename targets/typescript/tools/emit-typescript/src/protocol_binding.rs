//! The **protocol qualifier**, resolved once — does `id<P>` type as the interface `P`, or
//! does the qualifier drop and the slot stay `NSObject`? (ADR-0055 §4b, `protocol-binding-surface-k89`.)
//!
//! The third instance of the shape [`crate::class_binding`] (k66) and
//! [`crate::ffi_type_mapping::pod_type_name`] (k73) already carry: **one predicate, N readers.**
//! The type surface, the import set, and — later — [`DelegateSpec`](ADR-0059) all decide protocol
//! membership here and nowhere else. A body that renders `NSApplicationDelegate` while its import
//! block spells something else is the drift this module exists to make impossible.
//!
//! ## Why a qualifier can fail to bind — one guard, counted
//!
//! **Conformance honesty** — the dual of k66's import honesty. A conforming class emits
//! `implements P` only when [`ProtocolModuleResolver::is_known`](crate::protocol_graph::ProtocolModuleResolver::is_known)
//! recognises `P` ([`crate::class_surface::implemented_protocols`]); a marker protocol, a
//! non-identifier name, and an unrecognised cross-framework base are all dropped from the clause
//! "safely". Binding such a name in a *type* position would then reject a **legal** call — a
//! wrapped `NSString` into an `id<NSCopying>` slot — because the class carries no `implements
//! NSCopying` to satisfy it. So the bind arm reads the **same** recognition set the clause is
//! filtered on: one set, so the two cannot admit different calls.
//!
//! Because the drop *is* today's behaviour, degrading is always safe: unlike k66's `Class{…}`
//! overload there is **no defer arm** — no member is ever removed by this predicate.
//!
//! ## The class-name collapse — resolved by rendering, not by dropping
//!
//! ObjC has **two namespaces**, TypeScript has one: five names in the corpus are declared as
//! *both* a class and an emittable protocol (`CIFilter`, `NSAccessibilityElement`,
//! `NSTextAttachmentCell`, `AVVideoCompositionInstruction`, `FIFinderSync`). Left alone, the
//! interface and the class would both export the same identifier from their own module, and the
//! framework barrel's `export * from` of each makes that ambiguous (TS2308) —
//! `protocol-class-name-collapse-k90`. k89 only **guarded**: it degraded and counted such a
//! qualifier rather than binding it. k90 **resolves** it instead of dropping it: [`protocol_type_name`]
//! re-encodes the interface's own rendered identifier as `<Name>Protocol` — the `NSObjectProtocol`
//! convention Swift's own ObjC importer already uses for exactly this clash — so the qualifier binds
//! like any other, just under a different token. One predicate, five readers: the interface
//! declaration itself ([`crate::emit_protocol::render_one_interface`]), a protocol `extends` base, a
//! class `implements` clause, this module's bound-token rendering ([`id_surface_type`]), and every
//! type-only import of the interface ([`crate::imports::protocol_type_imports`]).
//!
//! ## The variance fact — a bound slot is a *yield* position too
//!
//! ADR-0055 §4b argued the bind arm from what a slot **accepts**: typing `setDelegate_(d: P)`
//! admits both a JS object literal implementing `P` and a wrapped ObjC object whose class
//! `implements P`. It never asked what a slot **yields**. 253 corpus returns are `id<P>`, and a
//! *return* typed bare `P` would be **narrower than the value**: `arr.addObject_(app.delegate())` —
//! a legal ObjC call whose `addObject:(id)` param renders `NSObject` — would stop compiling,
//! because a bare interface is not assignable to `NSObject`.
//!
//! So the two positions render differently, and the difference is exactly ordinary variance:
//!
//! | position | token | why |
//! |---|---|---|
//! | **param** (contravariant — what we accept) | `P`, or `P1 & P2` | the widest thing that satisfies the API: a plain JS object suffices |
//! | **return** (covariant — what we promise) | `P & NSObject` | what the value **is**: [`dynamic-class-wrap-k88`] mints it into its real ObjC class, so it carries `P`'s members *and* the object root's |
//!
//! The intersection is not a fudge — it is the honest type, and it is honest **only because of
//! k88**. Before the dynamic wrap, `__wrapRetained(NSObject, id)` minted a bare root object with
//! none of `P`'s members, and any bound return would have been a fresh lie.

use std::collections::{BTreeMap, BTreeSet};
use std::sync::Arc;

use apianyware_types::ir::{Framework, Method};
use apianyware_types::type_ref::{TypeRef, TypeRefKind};

use crate::class_graph::declared_classes;
use crate::ffi_type_mapping::TsFfiTypeMapper;
use crate::protocol_graph::ProtocolRegistry;

/// The runtime-owned object root. A degraded qualifier renders as it (the prior behaviour), and a
/// **bound** one in a return position intersects with it (the variance rule, module doc). Same
/// constant as [`crate::class_graph::RUNTIME_ROOT`]; named here so both rules read locally.
const OBJECT_ROOT: &str = "NSObject";

/// How one protocol name in an `id<…>` qualifier binds on the TS surface (module doc).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ProtocolBinding {
    /// The emitter emits this interface and every IR-declared conformer carries its `implements`
    /// clause — so the name may type a slot, rendered by [`protocol_type_name`] (its own name,
    /// unless a declared class collides with it — module doc).
    Bound,
    /// No interface is emitted for this name (not a proven protocol, no bindable surface, or an
    /// unresolvable cross-framework reference): the qualifier drops and the slot stays `NSObject`
    /// — the prior behaviour, hence always safe.
    Degraded,
}

/// Classify **one** protocol name. The single site that decides protocol membership; never
/// re-derive it, or a rendered token and its import will drift. Whether the bound name renders
/// under its own identifier or a re-encoded one (the class-name collapse) is
/// [`protocol_type_name`]'s question, not this one — a name that collides with a class is still
/// `Bound`, just rendered differently.
pub fn protocol_binding(name: &str, mapper: &TsFfiTypeMapper) -> ProtocolBinding {
    if mapper.is_known_protocol(name) {
        ProtocolBinding::Bound
    } else {
        ProtocolBinding::Degraded
    }
}

/// The TS **interface identifier** a bound protocol renders as (module doc, "the class-name
/// collapse"): its own ObjC name, unless a **declared class** also carries that name, in which
/// case it re-encodes as `<Name>Protocol`. Whole-program, exactly like
/// [`crate::class_binding::surface_class_name`]'s degrade rule — `mapper.is_bound_class` already
/// carries the whole corpus's declared classes, not just the current framework's, so the answer
/// cannot depend on which framework happens to be rendering.
///
/// The one place the rename happens; every reader of a bound protocol's identifier — the
/// interface declaration, an `extends` base, an `implements` clause, [`id_surface_type`]'s token,
/// and the type-only import set — calls this rather than spelling `proto.name` directly.
pub fn protocol_type_name(name: &str, mapper: &TsFfiTypeMapper) -> String {
    if mapper.is_bound_class(name) {
        format!("{name}Protocol")
    } else {
        name.to_string()
    }
}

/// The **bindable** protocol names a type reference carries — the qualifier list of an
/// [`TypeRefKind::Id`], filtered to the names that [`protocol_binding`] binds, in IR order, first
/// occurrence winning. Empty for every other kind, and for an unqualified `id`.
///
/// Filtering **per name** (rather than degrading the whole slot when any name fails) is what makes
/// the bind arm agree with the `implements` clause: a class conforming to `<NSCopying, NSTableViewDelegate>`
/// emits `implements NSTableViewDelegate` alone — `NSCopying` has no emittable surface — so an
/// `id<NSCopying, NSTableViewDelegate>` slot must type as `NSTableViewDelegate` alone too. Anything
/// wider would reject that very class.
pub fn bound_protocols<'t>(t: &'t TypeRef, mapper: &TsFfiTypeMapper) -> Vec<&'t str> {
    let TypeRefKind::Id { protocols } = &t.kind else {
        return Vec::new();
    };
    let mut out: Vec<&str> = Vec::new();
    for name in protocols {
        if protocol_binding(name, mapper) == ProtocolBinding::Bound && !out.contains(&name.as_str())
        {
            out.push(name.as_str());
        }
    }
    out
}

/// The TS type token a **protocol-qualified `id`** renders as, or `None` when the reference is not
/// an `Id`, carries no qualifier, or every name in it degrades (the caller then falls back to the
/// runtime root, exactly as before k89).
///
/// `is_return` picks the variance arm (module doc): a param yields `P` / `P1 & P2`, a return
/// additionally intersects the object root — `P & NSObject` — because that is what the value is.
///
/// **The one place the token is spelled.** [`TsFfiTypeMapper::map_type`] renders the signature from
/// it, [`referenced_protocol_types`] collects the import set from the same predicate, and
/// [`crate::emit_class`] passes it to the wrap primitive as an explicit type argument — so a
/// declared return type, its import, and the wrap that produces it are one string by construction.
/// Each bound name renders through [`protocol_type_name`], so a class-name collision (module doc)
/// carries its `Protocol` suffix here too.
pub fn id_surface_type(t: &TypeRef, mapper: &TsFfiTypeMapper, is_return: bool) -> Option<String> {
    let bound = bound_protocols(t, mapper);
    if bound.is_empty() {
        return None;
    }
    let mut token = bound
        .iter()
        .map(|name| protocol_type_name(name, mapper))
        .collect::<Vec<_>>()
        .join(" & ");
    if is_return {
        token.push_str(" & ");
        token.push_str(OBJECT_ROOT);
    }
    Some(token)
}

/// The set of **protocol interface names** a surface references and must import — every bound
/// qualifier over the given type positions. The protocol sibling of
/// [`crate::class_surface::referenced_class_types`] / [`referenced_pod_types`](crate::class_surface::referenced_pod_types),
/// and — like a POD and unlike a class — always **type-only**: an interface is erased at compile,
/// so it forms no runtime edge and no barrel cycle ([`crate::imports::protocol_type_imports`]).
///
/// Position-blind on purpose: *which* protocols a signature names does not depend on whether they
/// sit in a param or a return (only the `& NSObject` intersection does, and `NSObject` is a class
/// reference, collected by [`crate::class_surface::object_class_name`]).
pub fn referenced_protocol_types<'t>(
    types: impl IntoIterator<Item = &'t TypeRef>,
    mapper: &TsFfiTypeMapper,
) -> BTreeSet<String> {
    let mut set: BTreeSet<String> = BTreeSet::new();
    for t in types {
        for name in bound_protocols(t, mapper) {
            set.insert(name.to_string());
        }
    }
    set
}

// --- the whole-program degradation report ------------------------------------------------

/// What the corpus's protocol qualifiers did — for the generate pass log, so **no degradation is
/// silent** (k57).
#[derive(Debug, Clone, Default)]
pub struct DegradationReport {
    /// Occurrences of a qualifier name that bound.
    pub bound: usize,
    /// Each degraded name (not a proven emittable protocol) → how many positions named it.
    pub degraded: BTreeMap<String, usize>,
}

impl DegradationReport {
    /// Total degraded occurrences (over every degraded name).
    pub fn degraded_occurrences(&self) -> usize {
        self.degraded.values().sum()
    }

    /// `name×N, …` — the pass-log rendering, deterministically ordered.
    pub fn summary(&self) -> String {
        if self.degraded.is_empty() {
            return "none".to_string();
        }
        self.degraded
            .iter()
            .map(|(name, n)| format!("{name}×{n}"))
            .collect::<Vec<_>>()
            .join(", ")
    }
}

/// Walk every declared `id<…>` position in the corpus and count what the [`protocol_binding`]
/// predicate did with each qualifier name. Builds its recognition sets the **one** way the
/// emitters do — the whole-program declared classes ([`declared_classes`]) and the protocol
/// registry's owned (i.e. emittable) protocols — so the report cannot disagree with the surface it
/// describes.
///
/// Counted over **every declared** method / protocol member / free function, not only those the
/// method frontier admits: an over-count is loud (it also tells you what widening the frontier
/// would gain), whereas filtering could hide a name entirely.
pub fn degradation_report(
    frameworks: &[&Framework],
    protocol_registry: &ProtocolRegistry,
) -> DegradationReport {
    let mapper = TsFfiTypeMapper::with_known(
        Arc::default(),
        declared_classes(frameworks.iter().copied()),
        Arc::new(protocol_registry.names()),
    );

    fn count(report: &mut DegradationReport, mapper: &TsFfiTypeMapper, t: &TypeRef) {
        let TypeRefKind::Id { protocols } = &t.kind else {
            return;
        };
        for name in protocols {
            match protocol_binding(name, mapper) {
                ProtocolBinding::Bound => report.bound += 1,
                ProtocolBinding::Degraded => {
                    *report.degraded.entry(name.clone()).or_insert(0) += 1;
                }
            }
        }
    }
    fn count_method(report: &mut DegradationReport, mapper: &TsFfiTypeMapper, m: &Method) {
        for p in &m.params {
            count(report, mapper, &p.param_type);
        }
        count(report, mapper, &m.return_type);
    }

    let mut report = DegradationReport::default();
    for fw in frameworks {
        for cls in &fw.classes {
            for m in &cls.methods {
                count_method(&mut report, &mapper, m);
            }
        }
        for proto in &fw.protocols {
            for m in proto
                .required_methods
                .iter()
                .chain(proto.optional_methods.iter())
            {
                count_method(&mut report, &mapper, m);
            }
        }
        for f in &fw.functions {
            for p in &f.params {
                count(&mut report, &mapper, &p.param_type);
            }
            count(&mut report, &mapper, &f.return_type);
        }
    }
    report
}

/// Every emittable protocol name a declared class also carries — the whole-program **k90
/// collapse**, counted once per *name* (a declaration-level fact, unlike [`DegradationReport`]'s
/// per-`id<P>`-occurrence walk: a colliding protocol still needs re-encoding even if nothing ever
/// references it through a qualifier). Built the same whole-program way [`protocol_type_name`]
/// resolves it — the registry's owned (i.e. emittable) protocols against the whole-program
/// declared-class set — so this count cannot disagree with what actually renders. For the generate
/// pass log, so a re-encoded interface is never silent (k57, and k90's own "Done when").
pub fn renamed_protocols(
    frameworks: &[&Framework],
    protocol_registry: &ProtocolRegistry,
) -> BTreeSet<String> {
    let classes = declared_classes(frameworks.iter().copied());
    protocol_registry
        .names()
        .into_iter()
        .filter(|name| classes.contains(name))
        .collect()
}

#[cfg(test)]
mod tests {
    use super::*;

    /// A mapper knowing `classes` and `protocols` — the shape every emitter builds
    /// ([`crate::emit_framework`]).
    fn mapper(classes: &[&str], protocols: &[&str]) -> TsFfiTypeMapper {
        TsFfiTypeMapper::with_known(
            Arc::default(),
            Arc::new(classes.iter().map(|s| s.to_string()).collect()),
            Arc::new(protocols.iter().map(|s| s.to_string()).collect()),
        )
    }

    fn id(protocols: &[&str]) -> TypeRef {
        TypeRef {
            nullable: false,
            kind: TypeRefKind::Id {
                protocols: protocols.iter().map(|s| s.to_string()).collect(),
            },
        }
    }

    #[test]
    fn an_emittable_protocol_binds() {
        let m = mapper(&["NSApplication"], &["NSApplicationDelegate"]);
        assert_eq!(
            protocol_binding("NSApplicationDelegate", &m),
            ProtocolBinding::Bound
        );
        // Param — contravariant: the bare interface, so a JS object literal is admissible.
        assert_eq!(
            id_surface_type(&id(&["NSApplicationDelegate"]), &m, false).as_deref(),
            Some("NSApplicationDelegate")
        );
        // Return — covariant: what the value *is* after k88's dynamic wrap. Without the `& NSObject`
        // the return would be narrower than the value, and passing it into any `id`-typed slot
        // (rendered `NSObject`) would stop compiling.
        assert_eq!(
            id_surface_type(&id(&["NSApplicationDelegate"]), &m, true).as_deref(),
            Some("NSApplicationDelegate & NSObject")
        );
    }

    #[test]
    fn an_unemittable_protocol_degrades() {
        // THE CONFORMANCE-HONESTY GUARD. `NSCopying` has no bindable surface (its `copyWithZone:`
        // takes a raw `NSZone *`), so no interface is emitted and no conformer carries
        // `implements NSCopying`. Binding it would reject a legal call — a wrapped NSString into
        // an `id<NSCopying>` slot — because the class cannot satisfy the interface.
        let m = mapper(&["NSString"], &["NSApplicationDelegate"]);
        assert_eq!(protocol_binding("NSCopying", &m), ProtocolBinding::Degraded);
        assert_eq!(id_surface_type(&id(&["NSCopying"]), &m, false), None);
        assert_eq!(id_surface_type(&id(&["NSCopying"]), &m, true), None);
    }

    #[test]
    fn a_protocol_whose_name_a_class_also_declares_binds_under_the_renamed_identifier() {
        // THE k90 RESOLUTION. ObjC has two namespaces, TypeScript one: `NSTextAttachmentCell` is
        // both a class and an emittable protocol, so its interface re-encodes as
        // `NSTextAttachmentCellProtocol` rather than dropping — still bound, just under a
        // collision-safe identifier (`protocol_type_name`).
        let m = mapper(
            &["NSTextAttachmentCell"],
            &["NSTextAttachmentCell", "NSApplicationDelegate"],
        );
        assert_eq!(
            protocol_binding("NSTextAttachmentCell", &m),
            ProtocolBinding::Bound
        );
        assert_eq!(
            protocol_type_name("NSTextAttachmentCell", &m),
            "NSTextAttachmentCellProtocol"
        );
        assert_eq!(
            id_surface_type(&id(&["NSTextAttachmentCell"]), &m, false).as_deref(),
            Some("NSTextAttachmentCellProtocol")
        );
        // A non-colliding name renders under its own identifier, unchanged.
        assert_eq!(
            protocol_type_name("NSApplicationDelegate", &m),
            "NSApplicationDelegate"
        );
    }

    #[test]
    fn a_multi_qualifier_binds_the_bindable_names_and_drops_the_rest() {
        // Per **name**, never per slot. A class conforming to <NSCopying, NSTableViewDelegate>
        // emits `implements NSTableViewDelegate` alone, so the slot must type as
        // `NSTableViewDelegate` alone — intersecting `NSCopying` in would reject that very class,
        // and degrading the whole slot would throw away a bind the clause honours.
        let m = mapper(
            &["NSTableView"],
            &["NSTableViewDelegate", "NSTableViewDataSource"],
        );
        let two = id(&["NSTableViewDelegate", "NSTableViewDataSource"]);
        assert_eq!(
            id_surface_type(&two, &m, false).as_deref(),
            Some("NSTableViewDelegate & NSTableViewDataSource")
        );
        assert_eq!(
            id_surface_type(&two, &m, true).as_deref(),
            Some("NSTableViewDelegate & NSTableViewDataSource & NSObject")
        );
        // The mixed case: the unemittable name drops, the emittable one still binds.
        let mixed = id(&["NSCopying", "NSTableViewDelegate"]);
        assert_eq!(
            id_surface_type(&mixed, &m, false).as_deref(),
            Some("NSTableViewDelegate")
        );
        // IR order is preserved and a repeated name appears once.
        let dup = id(&[
            "NSTableViewDataSource",
            "NSTableViewDelegate",
            "NSTableViewDataSource",
        ]);
        assert_eq!(
            id_surface_type(&dup, &m, false).as_deref(),
            Some("NSTableViewDataSource & NSTableViewDelegate")
        );
    }

    #[test]
    fn an_unqualified_id_and_every_other_kind_carry_no_binding() {
        let m = mapper(&["NSString"], &["NSApplicationDelegate"]);
        assert_eq!(id_surface_type(&id(&[]), &m, false), None);
        for kind in [
            TypeRefKind::Instancetype,
            TypeRefKind::ClassRef,
            TypeRefKind::Selector,
            TypeRefKind::Class {
                name: "NSString".into(),
                framework: None,
                params: vec![],
            },
            TypeRefKind::Primitive {
                name: "int64".into(),
            },
        ] {
            let t = TypeRef {
                nullable: false,
                kind,
            };
            assert!(bound_protocols(&t, &m).is_empty());
            assert_eq!(id_surface_type(&t, &m, true), None);
        }
    }

    #[test]
    fn an_empty_recognition_set_binds_nothing() {
        // "Empty means empty" (the mapper's settled posture): a protocol-blind mapper degrades every
        // qualifier — which is exactly the pre-k89 surface. Degrading is always safe, so unlike the
        // k66 class set this cannot be unsound; but it is why every emitter builds all three sets.
        let m = mapper(&[], &[]);
        assert_eq!(
            protocol_binding("NSApplicationDelegate", &m),
            ProtocolBinding::Degraded
        );
        assert_eq!(
            id_surface_type(&id(&["NSApplicationDelegate"]), &m, true),
            None
        );
    }

    #[test]
    fn referenced_protocol_types_collects_only_bound_names() {
        let m = mapper(
            &["NSTextAttachmentCell"],
            &["NSApplicationDelegate", "NSTextAttachmentCell"],
        );
        let types = [
            id(&["NSApplicationDelegate"]),
            id(&["NSCopying"]),            // not emittable → no import
            id(&["NSTextAttachmentCell"]), // k90 collision → binds, imports under its own (raw) name
            id(&[]),                       // bare id → no import
        ];
        let set = referenced_protocol_types(types.iter(), &m);
        let names: Vec<&str> = set.iter().map(String::as_str).collect();
        // `referenced_protocol_types` collects the RAW names for import *routing*
        // (`ProtocolModuleResolver::owner`/`module_for` are keyed on them); the rendered import
        // *identifier* is `protocol_type_name`'s job, applied by
        // [`crate::imports::protocol_type_imports`] at the point it writes the literal specifier.
        assert_eq!(names, vec!["NSApplicationDelegate", "NSTextAttachmentCell"]);
    }

    #[test]
    fn the_import_set_and_the_rendered_token_are_the_same_strings() {
        // THE ONE-DECISION INVARIANT (k73's `pod_type_name`, k66's `surface_class_name`, here for
        // protocols). Whatever `id_surface_type` renders, `referenced_protocol_types` imports —
        // because both are `bound_protocols`. They cannot disagree: same input, same predicate.
        let m = mapper(&[], &["TKRefreshing", "TKScrolling"]);
        let t = id(&["TKRefreshing", "TKScrolling"]);
        let rendered = id_surface_type(&t, &m, false).unwrap();
        for name in referenced_protocol_types(std::iter::once(&t), &m) {
            assert!(
                rendered.split(" & ").any(|tok| tok == name),
                "every imported protocol must appear in the rendered token `{rendered}`"
            );
        }
        // And the return arm names the object root, which is a *class* reference — collected by
        // `object_class_name`, not here.
        assert_eq!(
            id_surface_type(&t, &m, true).unwrap(),
            "TKRefreshing & TKScrolling & NSObject"
        );
    }

    #[test]
    fn degradation_report_counts_every_drop_by_reason() {
        use apianyware_types::ir::{Class, Method, Param, Protocol};

        fn m(sel: &str, params: Vec<Param>, ret: TypeRef) -> Method {
            Method {
                selector: sel.into(),
                class_method: false,
                init_method: false,
                params,
                return_type: ret,
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
        fn p(name: &str, t: TypeRef) -> Param {
            Param {
                name: name.into(),
                param_type: t,
            }
        }

        let proto = Protocol {
            name: "TKRefreshing".into(),
            inherits: vec![],
            required_methods: vec![m("refresh", vec![], TypeRef::void())],
            optional_methods: vec![],
            properties: vec![],
            source: None,
            provenance: None,
            doc_refs: None,
            objc_exposed: true,
        };
        // A class whose name a protocol also carries — the k90 shape.
        let collide = Protocol {
            name: "TKWidget".into(),
            required_methods: vec![m("go", vec![], TypeRef::void())],
            ..proto.clone()
        };
        let cls = Class {
            name: "TKWidget".into(),
            superclass: "NSObject".into(),
            protocols: vec![],
            properties: vec![],
            methods: vec![
                m(
                    "setDelegate:",
                    vec![p("delegate", id(&["TKRefreshing"]))],
                    TypeRef::void(),
                ),
                // Two degradations: an unknown protocol, and the class-name collision.
                m(
                    "setOther:",
                    vec![p("other", id(&["NSCopying", "TKWidget"]))],
                    TypeRef::void(),
                ),
                m("delegate", vec![], id(&["TKRefreshing"])),
            ],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
            swift_name: None,
        };
        let fw = Framework {
            format_version: "1.0".into(),
            checkpoint: "resolved".into(),
            name: "TestKit".into(),
            sdk_version: None,
            collected_at: None,
            depends_on: vec![],
            skipped_symbols: vec![],
            classes: vec![cls],
            protocols: vec![proto, collide],
            enums: vec![],
            structs: vec![],
            functions: vec![],
            constants: vec![],
            class_annotations: vec![],
            patterns: vec![],
            enrichment: None,
            verification: None,
        };
        let refs = [&fw];
        let registry = ProtocolRegistry::from_framework_refs(&refs);
        let report = degradation_report(&refs, &registry);

        // TKRefreshing binds twice (the param and the return); TKWidget — a declared class AND an
        // emittable protocol — now binds too (k90 re-encodes rather than drops), so only NSCopying
        // (not a proven emittable protocol at all) degrades.
        assert_eq!(report.bound, 3);
        assert_eq!(report.degraded_occurrences(), 1);
        assert_eq!(report.degraded.get("NSCopying").copied(), Some(1));
        assert_eq!(
            report.degraded.get("TKWidget"),
            None,
            "TKWidget binds now (k90) — it never degrades"
        );
        assert_eq!(report.summary(), "NSCopying×1");

        // The k90 collapse itself is a DECLARATION-level fact, separate from how many `id<P>`
        // positions reference it: TKWidget is both a declared class and an emittable protocol, so
        // its interface re-encodes as `TKWidgetProtocol` regardless.
        let renamed = renamed_protocols(&refs, &registry);
        assert_eq!(renamed, ["TKWidget".to_string()].into_iter().collect());
    }
}
