//! The **shared class-declaration surface** — the single place the `.ts` class body
//! ([`crate::emit_class`]) and the co-generated `.d.ts` type surface
//! ([`crate::emit_dts`]) derive *what* to emit and *how each method's signature
//! reads*, so the two artifacts provably cannot drift (ADR-0055 §2: one IR pass
//! drives runtime **and** types — the drift NativeScript's `.d.ts`-only model risks).
//!
//! Both emitters project the same class through these helpers:
//! - [`bound_methods`] — the class's own bindable methods, split static / instance,
//!   in source order. Same frontier ⇒ the `.d.ts` declares *exactly* the methods the
//!   `.ts` implements, no more, no fewer.
//! - [`class_header`] — the `export class <Name> extends <Super>` line (the runtime
//!   root `NSObject` for an empty/`NSObject` superclass).
//! - [`method_header`] — a method's `<static?> name(params): ret` signature; the
//!   `.ts` appends a body block, the `.d.ts` a `;`.
//!
//! ## `instancetype`: the concrete class only when the receiver *is* the class
//!
//! A parameter list and every non-`instancetype` return render identically for the
//! `.ts` and the `.d.ts` (`method_header` needs no artifact discriminator). `instancetype`
//! resolves per ADR-0055 §6:
//! - a **static factory** resolves it to the **concrete class** — the receiver *is* the
//!   class (`Widget.widgetWithName_(…): Widget`);
//! - an **instance method** resolves it to the polymorphic **`this`**, in *both* the `.ts`
//!   and the `.d.ts` (`override-signature-mismatch-k100`). A prior revision rendered the
//!   concrete class in the `.ts` alone (cast-free body typing, k18) — but the very same
//!   `.ts` file also declares the class's `implements`/`extends` clauses, so a `this`-typed
//!   ancestor/interface member (an inherited `initWithCoder_(): this` flattened from
//!   `NSCoding`, say) saw the concrete return and TypeScript rejected the override
//!   (TS2416: a concrete type is never assignable to `this` — a future subclass could
//!   narrow `this` further). `this` uniformly is also the more *faithful* reading of
//!   `instancetype` itself: it means "whatever `self`'s real dynamic class is," which the
//!   wrap primitive now honors by resolving through the ctor registry ([`crate::emit_class::wrap_class`])
//!   rather than hard-coding the declaring class — so a JS subclass calling an inherited
//!   `init` now wraps into its own real class, not the ancestor's.

use std::collections::{BTreeSet, HashSet};

use apianyware_emit::ffi_type_mapping::FfiTypeMapper;
use apianyware_types::ir::{Class, Method, Param};
use apianyware_types::type_ref::{TypeRef, TypeRefKind};

use crate::class_binding::surface_class_name;
use crate::ffi_type_mapping::{pod_type_name, TsFfiTypeMapper};
use crate::method_filter::{
    is_error_out_method, is_supported_method_ctx, is_supported_method_ctx_modulo_deprecation,
};
use crate::naming::{class_type_name, method_name, param_identifier};
use crate::override_widening::OverrideWidenings;
use crate::protocol_binding;
use crate::protocol_graph::{ProtocolModuleResolver, ProtocolRegistry};

/// The class's **own** declared, bindable methods **plus** its conformed-protocol
/// required-method flattening — split `(static, instance)`, each in source order (own
/// methods first, flattened ones after) — the identical frontier both artifacts emit.
/// Keeps only ObjC-exposed methods the current machinery supports in this class's error
/// context ([`is_supported_method_ctx`]): a plain bindable method, **or** a fallible
/// `…error:` method whose *visible* signature (minus the trailing `NSError**` cell) is
/// bindable — the latter emits a `Result<T>` (ADR-0058). `error_selectors` is the class's
/// enrichment-derived NSError out-param selector set
/// ([`apianyware_emit::enrichment::class_error_selectors`]). Ancestor-inherited methods
/// ride `extends` and are never re-emitted; Swift-native (`objc_exposed == false`) methods
/// have no ObjC selector so they defer (ADR-0059); a method naming a **Swift nominal type** —
/// a `.swiftinterface`-sourced `Class{…}` the IR never declares — defers too, since it is not an
/// object at all ([`crate::class_binding`], k66).
///
/// ## Conformed-protocol required-method flattening (`protocol-required-method-flattening-k102`)
///
/// ObjC lets a class declare `<Protocol>` conformance without redeclaring the protocol's
/// required members in its own header (`NSURL <NSCoding>` never restates
/// `encodeWithCoder:`) — the resolve phase already flattens these real, working methods
/// onto `Class::all_methods` (`origin` = the declaring protocol's name; own methods carry
/// `origin: None`). This walks those entries too: an `all_methods` member whose `origin` is
/// in this class's own [`ProtocolRegistry::conformance_closure`] (its **own** direct
/// `Class.protocols`, not the ancestor chain's — see the closure's own doc for why that is
/// what avoids re-flattening something an ancestor already provides via `extends`) **and**
/// is a **required** member of **some** protocol in that closure is added, deduplicated by
/// `(selector, is_class_method)` against the class's own methods (which always win a tie —
/// the Datalog resolve phase already guarantees no overlap: a selector the class declares
/// itself never gets a protocol-origin `all_methods` entry). The flattened `Method` carries
/// its own selector/params/return-type independent of which entity declared it, so it needs
/// no new body codegen — the same per-method dispatch the class's own methods use applies
/// unchanged.
///
/// **Required-ness is asked of every conformed protocol, never only the surviving `origin`**
/// (`typecheck-gate-post-k86-residuals-k110`). `resolve`'s `effective_method` carries no
/// required/optional distinction at all (it flattens both alike so *any* conformer's
/// declaration is available to look up) — the residual same-selector, same-deprecation-status
/// dedup in `checkpoint.rs` picks exactly **one** surviving origin per `(class, selector,
/// is_class_method)`, deterministically but blind to which protocol calls the selector
/// required. `NSTextView` conforms to three protocols all declaring `doCommandBySelector:`
/// (`NSTextInputClient` — required, `NSTextInput` — deprecated, `NSStandardKeyBindingResponding`
/// — **optional**); the surviving origin (alphabetically first, non-deprecated) happens to be
/// the one where it is optional, even though a *different* conformed protocol requires it.
/// Checking [`ProtocolRegistry::is_required_method`] against only that one surviving origin
/// would silently drop a member the `implements` clause promises — checking it against **every**
/// name in `conformed` is what makes "required in some conformed protocol" the honest question,
/// independent of which one `resolve`'s dedup happened to keep.
///
/// This is **the** frontier: the `.ts` call sites, the `.d.ts` declarations, and every native
/// table's collection all walk it, so they cannot disagree about which methods exist. That is why
/// `mapper` must carry the same whole-program class knowledge on both sides — an emitter with it
/// and a collector without it would defer different methods and break the mirror invariant.
pub fn bound_methods<'a>(
    cls: &'a Class,
    mapper: &TsFfiTypeMapper,
    error_selectors: &HashSet<String>,
    protocol_registry: &ProtocolRegistry,
) -> (Vec<&'a Method>, Vec<&'a Method>) {
    let conformed = protocol_registry.conformance_closure(&cls.protocols);
    let mut seen: HashSet<(&str, bool)> = HashSet::new();
    let mut effective: Vec<&'a Method> = Vec::new();
    for m in &cls.methods {
        if seen.insert((m.selector.as_str(), m.class_method)) {
            effective.push(m);
        }
    }
    for m in &cls.all_methods {
        let Some(origin) = m.origin.as_deref() else {
            continue; // own declaration (already covered above) or ancestor-inherited
        };
        if !conformed.contains(origin) {
            continue; // not this class's own conformance closure — an ancestor's to flatten
        }
        let required_by_some_conformed_protocol = conformed
            .iter()
            .any(|p| protocol_registry.is_required_method(p, &m.selector, m.class_method));
        if !required_by_some_conformed_protocol {
            continue; // optional in every conformed protocol (module doc)
        }
        if seen.insert((m.selector.as_str(), m.class_method)) {
            effective.push(m);
        }
    }
    let admitted = |m: &&'a Method| {
        m.objc_exposed
            && (is_supported_method_ctx(m, mapper, error_selectors)
                || deprecated_conformance_carveout(
                    m,
                    &conformed,
                    protocol_registry,
                    mapper,
                    error_selectors,
                ))
    };
    let statics = effective
        .iter()
        .copied()
        .filter(|m| m.class_method && admitted(m))
        .collect();
    let instances = effective
        .iter()
        .copied()
        .filter(|m| !m.class_method && admitted(m))
        .collect();
    (statics, instances)
}

/// The **deprecated-conformance carve-out** (`deprecated-protocol-member-policy-k111`,
/// ADR-0055 §4b's member-level rule): a class's **own** deprecated method is emitted anyway
/// — tagged `@deprecated` at render — when it is the sole source of a member some conformed
/// protocol **requires**. Without it the class reads `implements NSLocking` with neither
/// `lock` nor `unlock` anywhere in its body (a TS2420): Apple deprecated direct locking on
/// `NSManagedObjectContext`/`NSPersistentStoreCoordinator` in 10.10 but never removed the
/// methods, so the classes genuinely still conform at the ObjC runtime. Conformance honesty
/// (§4b) extends to members — dropping the member breaks a promise the `implements` clause
/// makes, and dropping the *clause* instead would reject a legal `id<NSLocking>` call, the
/// exact bug shape §4b's guard exists to prevent.
///
/// Narrowest scope, each condition load-bearing:
/// - `deprecated` — everything else is the blanket filter's business, not ours;
/// - `origin.is_none()` — an **own** declaration only. A flattened protocol-origin member
///   whose declaration is deprecated *in the protocol* is filtered symmetrically with its
///   interface member ([`crate::emit_protocol`] runs the same [`is_supported_method`]
///   (crate::method_filter::is_supported_method) over interface members), so no static
///   promise exists and there is nothing to carve out (corpus population: zero);
/// - `!class_method` — a TS `implements` check reads **instance** members only (the
///   interface renders no statics), so only an instance member can carry a promise;
/// - required by **some conformed protocol** — the same
///   [`ProtocolRegistry::is_required_method`]-over-`conformed` question the flattening path
///   above asks (one predicate, N readers). The registry's required set is unfiltered by
///   interface *rendering*; measured corpus-wide (2026-07-15, 252 frameworks) the rendered
///   and unfiltered spellings admit the identical population, and an unrendered promise
///   cannot produce a TS2420, so the simpler shared predicate is used;
/// - deprecation is the **sole blocker**
///   ([`is_supported_method_ctx_modulo_deprecation`]) — a deprecated method whose
///   signature also defers stays deferred; emitting it would reference dispatch entries
///   that cannot exist.
///
/// Corpus-wide population (2026-07-15): exactly 4 members — `lock`/`unlock` on
/// `NSManagedObjectContext` and `NSPersistentStoreCoordinator`, all required by `NSLocking`.
fn deprecated_conformance_carveout(
    m: &Method,
    conformed: &BTreeSet<String>,
    protocol_registry: &ProtocolRegistry,
    mapper: &TsFfiTypeMapper,
    error_selectors: &HashSet<String>,
) -> bool {
    m.deprecated
        && m.origin.is_none()
        && !m.class_method
        && conformed
            .iter()
            .any(|p| protocol_registry.is_required_method(p, &m.selector, m.class_method))
        && is_supported_method_ctx_modulo_deprecation(m, mapper, error_selectors)
}

/// Whether this class emits **at least one fallible `…error:` method** — a bound method
/// ([`bound_methods`]) whose selector is in `error_selectors` (ADR-0058). Drives the
/// framework barrel's re-export of the runtime error surface (`Result` / `unwrap` / the
/// `ObjCError` hierarchy), so a consumer of the framework can name the fallible methods'
/// return types and handlers from the same package.
pub fn has_emitted_error_method(
    cls: &Class,
    mapper: &TsFfiTypeMapper,
    error_selectors: &HashSet<String>,
    protocol_registry: &ProtocolRegistry,
) -> bool {
    if error_selectors.is_empty() {
        return false;
    }
    let (statics, instances) = bound_methods(cls, mapper, error_selectors, protocol_registry);
    statics
        .iter()
        .chain(instances.iter())
        .any(|m| is_error_out_method(m, error_selectors))
}

/// Whether `cls` already has a **bindable, zero-arg instance `init`** reachable through the
/// emitted `extends` chain — either its own declaration or one some real ancestor redeclares
/// (`NSResponder.init()`, e.g.), which [`Class::all_methods`] carries as a flattened entry
/// regardless of which class in the chain actually declares it (`bound_methods`'s own doc: an
/// ancestor-inherited method "rides `extends`" and is never re-emitted for the descendant). Read
/// through the same [`is_supported_method_ctx`] admission gate every other method answers to, so a
/// deprecated or otherwise-unsupported ancestor `init` does not count as coverage it cannot
/// actually provide.
///
/// The true ObjC root `NSObject` is never itself extracted as a declared entity (ADR-0055 §1/§7),
/// so a class whose real ancestry never redeclares `-init` has **no** entry here at all —
/// [`crate::emit_class`]/[`crate::emit_dts`] give exactly those classes a synthetic `init(): this`
/// calling the runtime's universal `__init` primitive, the instance-side dual of `__alloc`
/// (`nsobject-plain-init-surface-gap-k122`).
pub fn has_bindable_init(
    cls: &Class,
    mapper: &TsFfiTypeMapper,
    error_selectors: &HashSet<String>,
) -> bool {
    cls.all_methods.iter().any(|m| {
        m.selector == "init"
            && !m.class_method
            && m.objc_exposed
            && is_supported_method_ctx(m, mapper, error_selectors)
    })
}

/// A method's **visible** parameters — the JS-facing arg list. For a fallible `…error:`
/// method (`fallible == true`) the trailing `NSError**` cell is dropped (the runtime
/// allocates it and passes `&err`, ADR-0058); otherwise every param is visible. The
/// single place the out-param drop lives, so the signature, the body, and the dispatch
/// entry all agree on the arg list.
pub fn visible_params(method: &Method, fallible: bool) -> &[Param] {
    if fallible && !method.params.is_empty() {
        &method.params[..method.params.len() - 1]
    } else {
        &method.params
    }
}

/// The `export class <Name> extends <Super>[ implements <I>[, …]]` declaration header
/// (without the trailing `{`), shared by both artifacts (a class `implements` clause is a
/// type-level construct, erased at runtime, so the `.ts` and `.d.ts` headers are identical —
/// ADR-0055 §4). An empty or `NSObject` superclass resolves to the runtime-owned root
/// `NSObject`; any other superclass keeps its TS name. The `implements` list is the class's
/// emittable conformed protocols ([`implemented_protocols`], routed through the
/// `protocol_resolver`); each conformed interface is imported type-only by the caller (the
/// same name it appears under here).
pub fn class_header(
    cls: &Class,
    protocol_resolver: &ProtocolModuleResolver<'_>,
    mapper: &TsFfiTypeMapper,
) -> String {
    let extends = superclass_name(cls);
    let protocols: Vec<String> = implemented_protocols(cls, protocol_resolver)
        .into_iter()
        .map(|name| protocol_binding::protocol_type_name(&name, mapper))
        .collect();
    let implements = if protocols.is_empty() {
        String::new()
    } else {
        format!(" implements {}", protocols.join(", "))
    };
    format!(
        "export class {} extends {}{}",
        class_type_name(&cls.name),
        extends,
        implements
    )
}

/// The class's **emittable conformed protocols** — the `Class.protocols` names the
/// `protocol_resolver` recognises as real interfaces ([`ProtocolModuleResolver::is_known`]),
/// preserving IR order (ADR-0055 §4's conforming-class half). A marker / all-Swift-native
/// protocol (no bindable surface) or an unresolvable cross-framework reference is filtered
/// out — it contributes no `implements` and no import. This single set drives **both** the
/// `implements` clause ([`class_header`]) and the class's type-only protocol imports
/// ([`crate::imports::protocol_type_imports`]), so the clause and its imports cannot drift.
///
/// Returns the **raw** ObjC protocol names — the registry's routing key
/// ([`ProtocolModuleResolver::module_for`] is keyed on them) — never the rendered identifier:
/// ObjC's two namespaces (a class and a protocol may share a name) collapse to TypeScript's
/// one, so a name a declared class also carries renders as `<Name>Protocol`
/// (`protocol_binding::protocol_type_name`, `protocol-class-name-collapse-k90`), but only each
/// *caller* applies that — [`class_header`] for the `implements` clause text,
/// [`crate::imports::protocol_type_imports`] for the import identifier — so routing never sees
/// a name its registry does not hold.
pub fn implemented_protocols(
    cls: &Class,
    protocol_resolver: &ProtocolModuleResolver<'_>,
) -> Vec<String> {
    cls.protocols
        .iter()
        .filter(|name| protocol_resolver.is_known(name))
        .map(String::clone)
        .collect()
}

/// The `extends` target: the runtime-owned root `NSObject` for an empty or `NSObject`
/// superclass, else the superclass's TS name. Exposed so [`referenced_class_types`] can
/// add the superclass to its import set (the same name it appears under in the header).
pub fn superclass_name(cls: &Class) -> String {
    if cls.superclass.is_empty() || cls.superclass == "NSObject" {
        "NSObject".to_string()
    } else {
        class_type_name(&cls.superclass)
    }
}

/// The set of **class type names** this class's surface references and must import —
/// the `extends` superclass plus every object-typed parameter/return class, minus the
/// class being declared (defined in its own file, never imported). The single shared
/// computation both artifacts route through, so the `.ts` and `.d.ts` — and, once
/// grouped by owning module ([`crate::imports`]), their import blocks — provably cannot
/// drift (ADR-0055 §2). The `.ts` references exactly this set: the `extends` target, the
/// object param/return types in each signature, and the wrap-primitive class of each
/// object return (`id` → `NSObject`, a concrete class → itself); the `.d.ts` the same,
/// as its declared types. `instancetype` is the declaring class itself (or `this`) so it
/// never enters the set; scalars, structs, strings, blocks, and pointers carry no class
/// reference.
pub fn referenced_class_types(
    cls: &Class,
    class_methods: &[&Method],
    instance_methods: &[&Method],
    mapper: &TsFfiTypeMapper,
    widenings: &OverrideWidenings,
) -> BTreeSet<String> {
    let mut set: BTreeSet<String> = BTreeSet::new();
    set.insert(superclass_name(cls));
    for m in class_methods.iter().chain(instance_methods.iter()) {
        for p in &m.params {
            if let Some(name) = object_class_name(&p.param_type, mapper, false) {
                set.insert(name);
            }
        }
        if let Some(name) = object_class_name(&m.return_type, mapper, true) {
            set.insert(name);
        }
    }
    // A widened-in ancestor union member is a referenced type like any declared one
    // (`crate::override_widening`) — its class contribution imports identically.
    for t in widenings.type_refs() {
        if let Some(name) = object_class_name(t, mapper, false) {
            set.insert(name);
        }
    }
    // The class being declared is defined in this file, not imported.
    set.remove(&class_type_name(&cls.name));
    set
}

/// The set of **protocol interface names** this class's surface references and must import — every
/// bound `id<P>` qualifier in a method param or return ([`crate::protocol_binding`], ADR-0055 §4b).
/// The protocol analogue of [`referenced_class_types`], routed by
/// [`crate::imports::protocol_type_imports`] to each interface's owning module and rendered
/// **type-only** (an interface is erased, so it forms no runtime edge and no barrel cycle) — the
/// exact sibling of [`referenced_pod_types`].
///
/// The class's **conformed** protocols (its `implements` clause, [`implemented_protocols`]) are a
/// separate source of the same import kind; the emitters union the two before grouping, so a
/// protocol that is both conformed and referenced imports once.
pub fn referenced_protocol_types(
    class_methods: &[&Method],
    instance_methods: &[&Method],
    mapper: &TsFfiTypeMapper,
    widenings: &OverrideWidenings,
) -> BTreeSet<String> {
    protocol_binding::referenced_protocol_types(
        class_methods
            .iter()
            .chain(instance_methods.iter())
            .flat_map(|m| {
                m.params
                    .iter()
                    .map(|p| &p.param_type)
                    .chain(std::iter::once(&m.return_type))
            })
            // A widened-in ancestor union member names its protocols exactly like a
            // declared qualifier (`crate::override_widening`).
            .chain(widenings.type_refs()),
        mapper,
    )
}

/// Every **protocol interface name** this class's artifacts import — the union of its *conformed*
/// protocols ([`implemented_protocols`], the `implements` clause) and the protocols its signatures
/// *name* through a bound `id<P>` qualifier ([`referenced_protocol_types`]). Both are type-only
/// imports of the same interfaces, so unioning them before grouping means a protocol that is both
/// conformed and referenced imports **once**.
///
/// The single shared computation the `.ts` ([`crate::emit_class`]) and the `.d.ts`
/// ([`crate::emit_dts`]) both route through — so their protocol import blocks provably cannot
/// drift (ADR-0055 §2), exactly as [`referenced_class_types`] does for class types.
pub fn protocol_import_names(
    cls: &Class,
    class_methods: &[&Method],
    instance_methods: &[&Method],
    mapper: &TsFfiTypeMapper,
    protocol_resolver: &ProtocolModuleResolver<'_>,
    widenings: &OverrideWidenings,
) -> BTreeSet<String> {
    let mut set = referenced_protocol_types(class_methods, instance_methods, mapper, widenings);
    set.extend(implemented_protocols(cls, protocol_resolver));
    set
}

/// The set of **enum type names** this class's surface references and must import — every
/// method param/return whose `Alias` the `mapper` proves a known `NS_ENUM`/`NS_OPTIONS`
/// ([`TsFfiTypeMapper::known_enum_name`]). The enum analogue of [`referenced_class_types`]:
/// the single shared computation both artifacts route through (grouped by owning module in
/// [`crate::imports::enum_type_imports`], rendered as `import type` blocks), so the `.ts`
/// and `.d.ts` enum imports provably cannot drift. An enum is never the declaring class, so
/// nothing is removed; a non-enum alias, scalar, object, struct, or string carries no enum
/// reference. `TypeRefKind::Alias` params/returns are the only carriers.
pub fn referenced_enum_types(
    class_methods: &[&Method],
    instance_methods: &[&Method],
    mapper: &TsFfiTypeMapper,
) -> BTreeSet<String> {
    let mut set: BTreeSet<String> = BTreeSet::new();
    for m in class_methods.iter().chain(instance_methods.iter()) {
        for p in &m.params {
            if let Some(name) = mapper.known_enum_name(&p.param_type) {
                set.insert(name.to_string());
            }
        }
        if let Some(name) = mapper.known_enum_name(&m.return_type) {
            set.insert(name.to_string());
        }
    }
    set
}

/// The set of **POD geometry type names** this class's surface references and must import —
/// every method param/return the shared predicate ([`pod_type_name`]) resolves to one of the nine
/// by-value aggregates (ADR-0055 §5). The POD analogue of [`referenced_class_types`]: the single
/// shared computation both artifacts route through (grouped in
/// [`crate::imports::pod_type_imports`], rendered as `import type` blocks), so the `.ts` and
/// `.d.ts` POD imports provably cannot drift.
///
/// **Type-only, and no transitive closure.** A POD type is a plain object — the runtime declares
/// it and no module exports a runtime *value* for it, so the reference erases at emit. Only the
/// names a signature spells enter the set: a method taking a `CGRect` imports `CGRect` alone, even
/// though `CGRect`'s own fields are a `CGPoint` and a `CGSize` — `tsc` reaches those through the
/// runtime's declaration, not through this artifact's imports.
pub fn referenced_pod_types(
    class_methods: &[&Method],
    instance_methods: &[&Method],
) -> BTreeSet<String> {
    let mut set: BTreeSet<String> = BTreeSet::new();
    for m in class_methods.iter().chain(instance_methods.iter()) {
        for p in &m.params {
            if let Some(name) = pod_type_name(&p.param_type) {
                set.insert(name.to_string());
            }
        }
        if let Some(name) = pod_type_name(&m.return_type) {
            set.insert(name.to_string());
        }
    }
    set
}

/// The **class type name** an object-typed [`TypeRef`] references for import purposes —
/// `NSObject` for `id` and the `Class` metatype (`typeof NSObject`), and for a concrete `Class`
/// type whatever the surface renders it as ([`surface_class_name`]: the class itself when the IR
/// declares it, else the degraded runtime root). `instancetype` is the declaring class itself (or
/// `this`) so it is never an import; scalars, structs, strings, and the rest carry no
/// class reference. Shared with [`crate::emit_protocol`], whose interface members route
/// their class-typed params/returns to the same owning-module import blocks.
///
/// Routing the degrade through the **same** [`surface_class_name`] the type surface uses is what
/// makes the import block and the rendered signature agree by construction: a name the IR does
/// not declare renders `NSObject` *and* imports `NSObject` — never a value import of a symbol no
/// module exports (`swift-nominal-type-surface-k66`).
///
/// **`is_return` is load-bearing for a protocol-qualified `id`** — the one kind whose token differs
/// by position (the variance rule, [`crate::protocol_binding`]). A bound `id<P>` **param** renders
/// `P` and names no class at all; the same qualifier in a **return** renders `P & NSObject` and so
/// does name the root. Passing the wrong position here would either import a class the signature
/// never spells (an unused import) or spell one it never imports (a dangling reference) — the drift
/// this whole family of predicates exists to prevent. Every other kind ignores it.
pub fn object_class_name(t: &TypeRef, mapper: &TsFfiTypeMapper, is_return: bool) -> Option<String> {
    match &t.kind {
        TypeRefKind::Id { .. } => {
            if protocol_binding::id_surface_type(t, mapper, is_return).is_some() {
                // Bound: the token names the root only in the covariant (return) arm.
                is_return.then(|| "NSObject".to_string())
            } else {
                // Degraded, or a bare `id` — the root, in both positions (the prior behaviour).
                Some("NSObject".to_string())
            }
        }
        TypeRefKind::ClassRef => Some("NSObject".to_string()),
        TypeRefKind::Class { name, .. } => Some(surface_class_name(name, mapper)),
        _ => None,
    }
}

/// The full method signature header both artifacts share: `<static?> name(params):
/// ret` (no trailing `{`/`;` — the caller appends the `.ts` body or the `.d.ts` `;`).
/// The one place param + return rendering lives, so a change to either moves the
/// `.ts` and the `.d.ts` in lockstep. `error_selectors` is the class's NSError
/// out-param selector set: a fallible `…error:` method drops its trailing `NSError**`
/// cell from the rendered params and returns `Result<T>` (ADR-0058).
///
/// A param the SDK redeclares incompatibly with its ancestor's declaration renders as the
/// union `Own | Ancestor` — SDK-intended type first ([`crate::override_widening`],
/// ADR-0055 §4b) — so the member stays an expressible TS override of the inherited one.
/// The JSDoc line an **admitted** deprecated member carries — and the
/// [`deprecated_conformance_carveout`] is the only way a deprecated member is ever
/// admitted. Emitting the member honours the `implements` promise; this tag keeps the
/// deprecation fact visible in the type surface (editors strike the member through and
/// flag usage), so neither fact is erased. Shared by the `.ts` and `.d.ts` renderers,
/// like [`method_header`], so the pair cannot drift.
pub fn deprecation_doc(method: &Method) -> Option<&'static str> {
    method.deprecated.then_some("/** @deprecated */")
}

pub fn method_header(
    cls: &Class,
    method: &Method,
    mapper: &TsFfiTypeMapper,
    error_selectors: &HashSet<String>,
    widenings: &OverrideWidenings,
) -> String {
    let fallible = is_error_out_method(method, error_selectors);
    let static_kw = if method.class_method { "static " } else { "" };
    let params = visible_params(method, fallible)
        .iter()
        .enumerate()
        .map(|(idx, p)| {
            let own = format!(
                "{}: {}",
                param_identifier(&p.name),
                mapper.map_type(&p.param_type, false)
            );
            match widenings.widened(method, idx) {
                Some(anc) => format!("{own} | {}", mapper.map_type(anc, false)),
                None => own,
            }
        })
        .collect::<Vec<_>>()
        .join(", ");
    format!(
        "{static_kw}{}({}): {}",
        method_name(&method.selector),
        params,
        return_type(cls, method, mapper, fallible, widenings)
    )
}

/// The rendered parameter list of a method's **own** params — `name: Type, …` —
/// identical for both artifacts (a param's type surface never depends on the receiver
/// context). Shared with the protocol-member surface ([`crate::emit_protocol`]); the
/// class method header renders the *visible* list ([`visible_params`]) so a fallible
/// method's trailing `NSError**` cell is dropped.
pub fn render_params(method: &Method, mapper: &TsFfiTypeMapper) -> String {
    render_param_list(&method.params, mapper)
}

/// Render a param slice as `name: Type, …`. The primitive both [`render_params`] (all
/// params) and [`method_header`] (visible params) build on. The identifier goes
/// through [`param_identifier`] (never the bare `p.name`) so a reserved-word ObjC
/// param name (`arguments`, `function`, …) renders as a valid binding — every body
/// expression that reads the same parameter must call the same function, or the
/// declaration and the read drift apart ([`crate::emit_class::emit_body`]).
fn render_param_list(params: &[Param], mapper: &TsFfiTypeMapper) -> String {
    params
        .iter()
        .map(|p| {
            format!(
                "{}: {}",
                param_identifier(&p.name),
                mapper.map_type(&p.param_type, false)
            )
        })
        .collect::<Vec<_>>()
        .join(", ")
}

/// The rendered return type. `instancetype` resolves to the **concrete class** only when
/// the receiver *is* the class — a static factory; an instance method's `instancetype`
/// is always the polymorphic `this` (module doc, `override-signature-mismatch-k100`) —
/// identical in the `.ts` and the `.d.ts`. Nullability rides the annotation; every other
/// kind defers to [`TsFfiTypeMapper`].
///
/// A **fallible** method (`fallible == true`, ADR-0058) wraps its primary return in
/// `Result<T>`, and `T` is rendered **non-null**: the API's nil/`NO`-on-failure is the
/// `ok: false` arm, not part of the success value, so a nullable `NSData*` primary
/// surfaces as `Result<NSData>` (not `Result<NSData | null>`).
///
/// A method whose own return the SDK declares as an uninformative bare `id`, overriding an
/// ancestor's more specific one, renders the ancestor's return instead
/// ([`crate::override_widening`], `text-undo-surface-gap-k121`) — a return cannot **widen**
/// (covariant), only narrow to a strictly more informative type, which a bare `id` never is.
pub fn return_type(
    cls: &Class,
    method: &Method,
    mapper: &TsFfiTypeMapper,
    fallible: bool,
    widenings: &OverrideWidenings,
) -> String {
    let effective_return = widenings
        .narrowed_return(method)
        .unwrap_or(&method.return_type);
    let inner =
        if matches!(method.return_type.kind, TypeRefKind::Instancetype) && method.class_method {
            let base = class_type_name(&cls.name);
            if method.return_type.nullable && !fallible {
                format!("{base} | null")
            } else {
                base
            }
        } else if fallible {
            // Strip nullability — the nil-on-failure is the error arm (above).
            let nonnull = TypeRef {
                nullable: false,
                kind: effective_return.kind.clone(),
            };
            mapper.map_type(&nonnull, true)
        } else {
            mapper.map_type(effective_return, true)
        };
    if fallible {
        format!("Result<{inner}>")
    } else {
        inner
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::protocol_graph::ProtocolRegistry;
    use apianyware_types::ir::{Class, Method, Param};
    use apianyware_types::type_ref::TypeRef;
    use std::sync::Arc;

    /// A protocol resolver for framework `fw` backed by `reg`, recognising `known` as
    /// emittable interfaces — the shape [`crate::emit_framework`] builds. Borrows `reg`, so
    /// the caller keeps the registry alive for the test.
    fn protocol_resolver<'a>(
        fw: &str,
        reg: &'a ProtocolRegistry,
        known: &[&str],
    ) -> ProtocolModuleResolver<'a> {
        let set: BTreeSet<String> = known.iter().map(|s| s.to_string()).collect();
        ProtocolModuleResolver::new(fw, reg, Arc::new(set))
    }

    /// A mapper over the whole-program declared-class set — the shape
    /// [`crate::emit_framework`] builds. A `Class{name}` outside it is not a class the emitter
    /// emits, so the k66 rule degrades it (or defers the member).
    fn known(classes: &[&str]) -> TsFfiTypeMapper {
        TsFfiTypeMapper::with_known_classes(Arc::new(
            classes.iter().map(|s| s.to_string()).collect(),
        ))
    }

    fn ty(kind: TypeRefKind) -> TypeRef {
        TypeRef {
            nullable: false,
            kind,
        }
    }

    fn nullable(kind: TypeRefKind) -> TypeRef {
        TypeRef {
            nullable: true,
            kind,
        }
    }

    fn param(name: &str, param_type: TypeRef) -> Param {
        Param {
            name: name.into(),
            param_type,
        }
    }

    fn method(
        selector: &str,
        class_method: bool,
        params: Vec<Param>,
        return_type: TypeRef,
    ) -> Method {
        Method {
            selector: selector.into(),
            class_method,
            init_method: false,
            params,
            return_type,
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

    #[test]
    fn params_render_uniformly_for_both_artifacts() {
        let mapper = TsFfiTypeMapper::new();
        let m = method(
            "insertObject:atIndex:",
            false,
            vec![
                param(
                    "object",
                    ty(TypeRefKind::Id {
                        protocols: Vec::new(),
                    }),
                ),
                param(
                    "index",
                    ty(TypeRefKind::Primitive {
                        name: "NSUInteger".into(),
                    }),
                ),
            ],
            TypeRef::void(),
        );
        assert_eq!(
            render_params(&m, &mapper),
            "object: NSObject, index: number"
        );
    }

    #[test]
    fn empty_param_list_renders_empty() {
        let mapper = TsFfiTypeMapper::new();
        let m = method(
            "length",
            false,
            vec![],
            ty(TypeRefKind::Id {
                protocols: Vec::new(),
            }),
        );
        assert_eq!(render_params(&m, &mapper), "");
    }

    #[test]
    fn static_factory_instancetype_is_the_concrete_class() {
        // The receiver of a static factory *is* the class, so `instancetype` is the
        // concrete class (ADR-0055 §6).
        let mapper = TsFfiTypeMapper::new();
        let cls = class("Widget", "NSObject", vec![]);
        let m = method(
            "widgetWithName:",
            true,
            vec![param(
                "name",
                ty(TypeRefKind::Id {
                    protocols: Vec::new(),
                }),
            )],
            ty(TypeRefKind::Instancetype),
        );
        assert_eq!(
            return_type(&cls, &m, &mapper, false, &OverrideWidenings::empty()),
            "Widget"
        );
    }

    #[test]
    fn instance_instancetype_is_polymorphic_this() {
        // override-signature-mismatch-k100: an instance method's `instancetype` is `this`
        // — identically in the `.ts` and the `.d.ts` — so it stays assignable to a
        // `this`-returning ancestor/interface member (e.g. a flattened `NSCoding`
        // requirement). A concrete return here is what TS2416 caught.
        let mapper = TsFfiTypeMapper::new();
        let cls = class("Widget", "NSObject", vec![]);
        let m = method(
            "initWithName:",
            false,
            vec![param(
                "name",
                ty(TypeRefKind::Id {
                    protocols: Vec::new(),
                }),
            )],
            nullable(TypeRefKind::Instancetype),
        );
        assert_eq!(
            return_type(&cls, &m, &mapper, false, &OverrideWidenings::empty()),
            "this | null"
        );
    }

    #[test]
    fn non_instancetype_return_defers_to_the_mapper() {
        let mapper = TsFfiTypeMapper::new();
        let cls = class("Widget", "NSObject", vec![]);
        let scalar = method(
            "length",
            false,
            vec![],
            ty(TypeRefKind::Primitive {
                name: "NSUInteger".into(),
            }),
        );
        let object = method(
            "delegate",
            false,
            vec![],
            nullable(TypeRefKind::Id {
                protocols: Vec::new(),
            }),
        );
        assert_eq!(
            return_type(&cls, &scalar, &mapper, false, &OverrideWidenings::empty()),
            "number"
        );
        assert_eq!(
            return_type(&cls, &object, &mapper, false, &OverrideWidenings::empty()),
            "NSObject | null"
        );
    }

    #[test]
    fn method_header_composes_static_name_params_and_return() {
        let mapper = TsFfiTypeMapper::new();
        let cls = class("Widget", "NSObject", vec![]);
        let m = method(
            "widgetWithName:",
            true,
            vec![param(
                "name",
                ty(TypeRefKind::Id {
                    protocols: Vec::new(),
                }),
            )],
            ty(TypeRefKind::Instancetype),
        );
        assert_eq!(
            method_header(
                &cls,
                &m,
                &mapper,
                &HashSet::new(),
                &OverrideWidenings::empty()
            ),
            "static widgetWithName_(name: NSObject): Widget"
        );
    }

    #[test]
    fn fallible_method_header_drops_out_param_and_wraps_result() {
        // ADR-0058: a fallible `…error:` method drops its trailing NSError** cell from the
        // rendered params and returns `Result<T>` with T non-null (the nil-on-failure is
        // the error arm). The `_error_` name is retained by the injective rule (naming).
        let mapper = known(&["NSData"]);
        let cls = class("NSData", "NSObject", vec![]);
        let m = method(
            "writeToFile:error:",
            false,
            vec![
                param(
                    "path",
                    ty(TypeRefKind::Id {
                        protocols: Vec::new(),
                    }),
                ),
                param("error", ty(TypeRefKind::Pointer)),
            ],
            ty(TypeRefKind::Primitive {
                name: "bool".into(),
            }),
        );
        let errs: HashSet<String> = ["writeToFile:error:".to_string()].into_iter().collect();
        // BOOL primary → Result<boolean>; the NSError** param is gone from the arg list.
        assert_eq!(
            method_header(&cls, &m, &mapper, &errs, &OverrideWidenings::empty()),
            "writeToFile_error_(path: NSObject): Result<boolean>"
        );
        // A nullable-object primary drops the `| null` — it is the error arm, not part of T.
        let obj = method(
            "dataWithContentsOfFile:error:",
            false,
            vec![
                param(
                    "path",
                    ty(TypeRefKind::Id {
                        protocols: Vec::new(),
                    }),
                ),
                param("error", ty(TypeRefKind::Pointer)),
            ],
            nullable(TypeRefKind::Class {
                name: "NSData".into(),
                framework: None,
                params: vec![],
            }),
        );
        let errs2: HashSet<String> = ["dataWithContentsOfFile:error:".to_string()]
            .into_iter()
            .collect();
        assert_eq!(
            method_header(&cls, &obj, &mapper, &errs2, &OverrideWidenings::empty()),
            "dataWithContentsOfFile_error_(path: NSObject): Result<NSData>"
        );
    }

    #[test]
    fn bound_methods_split_static_instance_filter_unsupported_and_swift_native() {
        let mapper = TsFfiTypeMapper::new();
        let mut swift_native = method(
            "data",
            false,
            vec![],
            ty(TypeRefKind::Id {
                protocols: Vec::new(),
            }),
        );
        swift_native.objc_exposed = false; // no ObjC selector — deferred (ADR-0059)
        let mut variadic = method(
            "format:",
            true,
            vec![],
            ty(TypeRefKind::Id {
                protocols: Vec::new(),
            }),
        );
        variadic.variadic = true; // unsupported frontier — deferred
        let cls = class(
            "Widget",
            "NSObject",
            vec![
                method("alloc", true, vec![], ty(TypeRefKind::Instancetype)),
                method(
                    "length",
                    false,
                    vec![],
                    ty(TypeRefKind::Id {
                        protocols: Vec::new(),
                    }),
                ),
                swift_native,
                variadic,
            ],
        );
        let (statics, instances) =
            bound_methods(&cls, &mapper, &HashSet::new(), &ProtocolRegistry::new());
        assert_eq!(statics.len(), 1, "only `alloc` survives among statics");
        assert_eq!(statics[0].selector, "alloc");
        assert_eq!(instances.len(), 1, "only `length` survives among instances");
        assert_eq!(instances[0].selector, "length");
    }

    /// An `all_methods` entry the resolve phase attributes to a protocol conformance —
    /// `origin` set, everything else as [`method`] builds it.
    fn protocol_flattened_method(
        selector: &str,
        class_method: bool,
        origin: &str,
        return_type: TypeRef,
    ) -> Method {
        Method {
            origin: Some(origin.to_string()),
            ..method(selector, class_method, vec![], return_type)
        }
    }

    fn id_ty() -> TypeRef {
        ty(TypeRefKind::Id {
            protocols: Vec::new(),
        })
    }

    #[test]
    fn has_bindable_init_false_with_no_init_anywhere_in_all_methods() {
        // NSAlert's own shape: extends NSObject directly, no ancestor ever redeclares `-init`.
        let cls = class("NSAlert", "NSObject", vec![]);
        let mapper = TsFfiTypeMapper::new();
        assert!(!has_bindable_init(&cls, &mapper, &HashSet::new()));
    }

    #[test]
    fn has_bindable_init_true_for_the_classs_own_declared_init() {
        let mut cls = class("Widget", "NSObject", vec![]);
        cls.all_methods = vec![method(
            "init",
            false,
            vec![],
            ty(TypeRefKind::Instancetype),
        )];
        let mapper = TsFfiTypeMapper::new();
        assert!(has_bindable_init(&cls, &mapper, &HashSet::new()));
    }

    #[test]
    fn has_bindable_init_true_when_a_real_ancestor_redeclares_it() {
        // NSView extends NSResponder, which redeclares `-init` itself; the flattened entry
        // carries the ancestor's name as `origin` (`bound_methods`'s own module doc) — the
        // TS `extends` chain already provides it, so no synthetic init is needed.
        let mut cls = class("NSView", "NSResponder", vec![]);
        cls.all_methods = vec![protocol_flattened_method(
            "init",
            false,
            "NSResponder",
            ty(TypeRefKind::Instancetype),
        )];
        let mapper = TsFfiTypeMapper::new();
        assert!(has_bindable_init(&cls, &mapper, &HashSet::new()));
    }

    #[test]
    fn has_bindable_init_ignores_a_class_method_named_init() {
        // Selector identity alone is not enough — "init" must be an *instance* method.
        let mut cls = class("Widget", "NSObject", vec![]);
        cls.all_methods = vec![method(
            "init",
            true,
            vec![],
            ty(TypeRefKind::Instancetype),
        )];
        let mapper = TsFfiTypeMapper::new();
        assert!(!has_bindable_init(&cls, &mapper, &HashSet::new()));
    }

    #[test]
    fn has_bindable_init_ignores_an_unrelated_initwith_selector() {
        // A designated `initWith…:` does not satisfy the *plain* `alloc`/`init` contract.
        let mut cls = class("Widget", "NSObject", vec![]);
        cls.all_methods = vec![method(
            "initWithName:",
            false,
            vec![param("name", id_ty())],
            ty(TypeRefKind::Instancetype),
        )];
        let mapper = TsFfiTypeMapper::new();
        assert!(!has_bindable_init(&cls, &mapper, &HashSet::new()));
    }

    #[test]
    fn has_bindable_init_false_when_the_only_init_is_deprecated() {
        // The same admission gate every other method answers to (`is_supported_method_ctx`):
        // a deprecated ancestor `init` cannot actually provide the coverage it appears to.
        let mut cls = class("Widget", "NSObject", vec![]);
        cls.all_methods = vec![Method {
            deprecated: true,
            ..method("init", false, vec![], ty(TypeRefKind::Instancetype))
        }];
        let mapper = TsFfiTypeMapper::new();
        assert!(!has_bindable_init(&cls, &mapper, &HashSet::new()));
    }

    #[test]
    fn has_bindable_init_false_for_a_swift_native_init_with_no_objc_selector() {
        // ADR-0026: `objc_exposed == false` means no ObjC message-send path exists for this
        // declaration at all — it can never actually be dispatched, so it must not count as
        // coverage `bound_methods`' own admission gate (`m.objc_exposed && …`) would refuse too.
        let mut cls = class("Widget", "NSObject", vec![]);
        cls.all_methods = vec![Method {
            objc_exposed: false,
            ..method("init", false, vec![], ty(TypeRefKind::Instancetype))
        }];
        let mapper = TsFfiTypeMapper::new();
        assert!(!has_bindable_init(&cls, &mapper, &HashSet::new()));
    }

    #[test]
    fn bound_methods_flattens_a_conformed_protocols_required_method() {
        // NSURL<NSCoding> never restates encodeWithCoder: in its own header (k99's headline
        // case) — the resolve phase already flattens it onto all_methods with origin=NSCoding.
        let mapper = TsFfiTypeMapper::new();
        let mut cls = class("NSURL", "NSObject", vec![]);
        cls.protocols = vec!["NSCoding".to_string()];
        cls.all_methods = vec![protocol_flattened_method(
            "encodeWithCoder:",
            false,
            "NSCoding",
            TypeRef::void(),
        )];
        let mut reg = ProtocolRegistry::new();
        reg.insert_conformance(
            "NSCoding",
            vec![],
            [("encodeWithCoder:".to_string(), false)],
        );
        let (statics, instances) = bound_methods(&cls, &mapper, &HashSet::new(), &reg);
        assert!(statics.is_empty());
        assert_eq!(instances.len(), 1);
        assert_eq!(instances[0].selector, "encodeWithCoder:");
    }

    #[test]
    fn bound_methods_flattens_when_class_and_protocol_share_a_name() {
        // typecheck-gate-post-k86-residuals-k110 item (3): the NSTextAttachmentCell shape
        // (`@interface NSTextAttachmentCell : NSCell <NSTextAttachmentCell>` — k90's
        // namespace-collision species, 5 corpus occurrences). Given a well-formed `all_methods`
        // entry (this crate's `resolve` dependency is responsible for that half — see the
        // `checkpoint.rs` fix in `apianyware-resolve`), `bound_methods` itself must not special-case
        // "origin string equals class name" as if it disqualified the entry from flattening.
        let mapper = TsFfiTypeMapper::new();
        let mut cls = class("Thing", "NSObject", vec![]);
        cls.protocols = vec!["Thing".to_string()];
        cls.all_methods = vec![protocol_flattened_method(
            "requiredThing",
            false,
            "Thing",
            TypeRef::void(),
        )];
        let mut reg = ProtocolRegistry::new();
        reg.insert_conformance("Thing", vec![], [("requiredThing".to_string(), false)]);
        let (_statics, instances) = bound_methods(&cls, &mapper, &HashSet::new(), &reg);
        assert_eq!(
            instances.len(),
            1,
            "a class conforming to a same-named protocol should still flatten its required \
             method, got {instances:?}"
        );
    }

    #[test]
    fn bound_methods_never_flattens_an_optional_protocol_method() {
        // The protocol is known and conformed, but the selector is one of ITS optional
        // members — an all_methods entry the flattening rule must still reject (module doc:
        // an optional member is not guaranteed implemented by every conformer).
        let mapper = TsFfiTypeMapper::new();
        let mut cls = class("Thing", "NSObject", vec![]);
        cls.protocols = vec!["NSCoding".to_string()];
        cls.all_methods = vec![protocol_flattened_method(
            "someOptionalHook:",
            false,
            "NSCoding",
            TypeRef::void(),
        )];
        let mut reg = ProtocolRegistry::new();
        // Registered with a DIFFERENT selector as required — "someOptionalHook:" is absent
        // from the required set, exactly as an optional member would be.
        reg.insert_conformance(
            "NSCoding",
            vec![],
            [("encodeWithCoder:".to_string(), false)],
        );
        let (_statics, instances) = bound_methods(&cls, &mapper, &HashSet::new(), &reg);
        assert!(
            instances.is_empty(),
            "an optional protocol member must never be flattened onto the class"
        );
    }

    #[test]
    fn bound_methods_flattens_a_selector_required_by_a_different_conformed_protocol_than_the_surviving_origin(
    ) {
        // typecheck-gate-post-k86-residuals-k110: the real NSTextView shape.
        // `doCommandBySelector:` is required in `NSTextInputClient` but merely optional in
        // `NSStandardKeyBindingResponding` — two DIFFERENT protocols NSTextView conforms to
        // directly, both declaring the same selector. `resolve`'s residual same-selector dedup
        // (`checkpoint.rs`) keeps exactly one origin — deterministically, but blind to which
        // protocol calls it required — and here it happens to keep the OPTIONAL one
        // (`all_methods` carries only the `NSStandardKeyBindingResponding`-origin row). Checking
        // required-ness against every name in `conformed`, not just the surviving `origin`, is
        // what still flattens the member correctly.
        let mapper = TsFfiTypeMapper::new();
        let mut cls = class("Thing", "NSObject", vec![]);
        cls.protocols = vec![
            "NSStandardKeyBindingResponding".to_string(),
            "NSTextInputClient".to_string(),
        ];
        cls.all_methods = vec![protocol_flattened_method(
            "doCommandBySelector:",
            false,
            "NSStandardKeyBindingResponding", // the surviving origin — optional there
            TypeRef::void(),
        )];
        let mut reg = ProtocolRegistry::new();
        reg.insert_conformance("NSStandardKeyBindingResponding", vec![], []); // optional there
        reg.insert_conformance(
            "NSTextInputClient",
            vec![],
            [("doCommandBySelector:".to_string(), false)], // required there
        );
        let (_statics, instances) = bound_methods(&cls, &mapper, &HashSet::new(), &reg);
        assert_eq!(
            instances.len(),
            1,
            "required-in-some-conformed-protocol must still flatten the member even though the \
             surviving all_methods origin has it as optional, got {instances:?}"
        );
        assert_eq!(instances[0].selector, "doCommandBySelector:");
    }

    #[test]
    fn bound_methods_defers_to_the_ancestor_that_actually_conforms() {
        // A subclass whose OWN header does not restate the protocol (`cls.protocols` empty)
        // must not re-flatten a method an ancestor already flattens onto itself and passes
        // down via `extends` — even though the propagated `all_methods` entry (as the resolve
        // phase would produce it) still names the protocol as origin.
        let mapper = TsFfiTypeMapper::new();
        let mut cls = class("NSView", "NSResponder", vec![]);
        // cls.protocols left empty: NSView's own header does not conform directly.
        cls.all_methods = vec![protocol_flattened_method(
            "encodeWithCoder:",
            false,
            "NSCoding",
            TypeRef::void(),
        )];
        let mut reg = ProtocolRegistry::new();
        reg.insert_conformance(
            "NSCoding",
            vec![],
            [("encodeWithCoder:".to_string(), false)],
        );
        let (_statics, instances) = bound_methods(&cls, &mapper, &HashSet::new(), &reg);
        assert!(
            instances.is_empty(),
            "a class that does not itself conform must defer to the conforming ancestor"
        );
    }

    #[test]
    fn bound_methods_own_declaration_wins_over_a_flattened_duplicate() {
        // The Datalog resolve phase guarantees no overlap (a selector the class declares
        // itself never gets a protocol-origin all_methods entry) — this pins the defensive
        // dedup that holds even if that invariant were ever violated.
        let mapper = known(&["NSURL"]);
        let mut cls = class(
            "NSURL",
            "NSObject",
            vec![method(
                "initWithCoder:",
                false,
                vec![],
                nullable(TypeRefKind::Instancetype),
            )],
        );
        cls.protocols = vec!["NSCoding".to_string()];
        cls.all_methods = vec![protocol_flattened_method(
            "initWithCoder:",
            false,
            "NSCoding",
            id_ty(),
        )];
        let mut reg = ProtocolRegistry::new();
        reg.insert_conformance("NSCoding", vec![], [("initWithCoder:".to_string(), false)]);
        let (_statics, instances) = bound_methods(&cls, &mapper, &HashSet::new(), &reg);
        assert_eq!(instances.len(), 1, "own declaration wins the selector tie");
        assert!(matches!(
            instances[0].return_type.kind,
            TypeRefKind::Instancetype
        ));
    }

    #[test]
    fn bound_methods_admits_a_deprecated_own_method_a_conformed_protocol_requires() {
        // deprecated-protocol-member-policy-k111: NSManagedObjectContext<NSLocking> declares
        // lock/unlock itself, both deprecated (10.10, never removed) — the ONLY source of the
        // members its `implements NSLocking` promises. The carve-out admits them (rendered
        // with `/** @deprecated */`); without it the class fails TS2420.
        let mapper = TsFfiTypeMapper::new();
        let mut cls = class(
            "NSManagedObjectContext",
            "NSObject",
            vec![Method {
                deprecated: true,
                ..method("lock", false, vec![], TypeRef::void())
            }],
        );
        cls.protocols = vec!["NSLocking".to_string()];
        let mut reg = ProtocolRegistry::new();
        reg.insert_conformance("NSLocking", vec![], [("lock".to_string(), false)]);
        let (statics, instances) = bound_methods(&cls, &mapper, &HashSet::new(), &reg);
        assert!(statics.is_empty());
        assert_eq!(
            instances.len(),
            1,
            "the sole source of a promised conformance member must be admitted, got {instances:?}"
        );
        assert_eq!(instances[0].selector, "lock");
    }

    #[test]
    fn bound_methods_still_defers_a_deprecated_method_no_conformed_protocol_requires() {
        // The blanket deprecated filter is otherwise untouched: the identical method with no
        // conformance promising it stays deferred, even though the registry knows the
        // protocol requires the selector — the CLASS does not conform.
        let mapper = TsFfiTypeMapper::new();
        let cls = class(
            "NSManagedObjectContext",
            "NSObject",
            vec![Method {
                deprecated: true,
                ..method("lock", false, vec![], TypeRef::void())
            }],
        );
        let mut reg = ProtocolRegistry::new();
        reg.insert_conformance("NSLocking", vec![], [("lock".to_string(), false)]);
        let (statics, instances) = bound_methods(&cls, &mapper, &HashSet::new(), &reg);
        assert!(statics.is_empty());
        assert!(
            instances.is_empty(),
            "no conformance ⇒ no promise ⇒ the blanket filter stands, got {instances:?}"
        );
    }

    #[test]
    fn bound_methods_still_defers_a_deprecated_required_method_with_another_blocker() {
        // Deprecation must be the SOLE blocker: a deprecated required member whose signature
        // also defers (variadic here) stays deferred — admitting it would emit a call site
        // naming a dispatch entry no table can provide.
        let mapper = TsFfiTypeMapper::new();
        let mut cls = class(
            "Widget",
            "NSObject",
            vec![Method {
                deprecated: true,
                variadic: true,
                ..method("lock", false, vec![], TypeRef::void())
            }],
        );
        cls.protocols = vec!["NSLocking".to_string()];
        let mut reg = ProtocolRegistry::new();
        reg.insert_conformance("NSLocking", vec![], [("lock".to_string(), false)]);
        let (_statics, instances) = bound_methods(&cls, &mapper, &HashSet::new(), &reg);
        assert!(
            instances.is_empty(),
            "deprecation-plus-another-blocker must stay deferred, got {instances:?}"
        );
    }

    #[test]
    fn bound_methods_never_carves_out_a_deprecated_static() {
        // A TS `implements` check reads INSTANCE members only (the interface renders no
        // statics), so a static carries no promise and the blanket filter stands.
        let mapper = TsFfiTypeMapper::new();
        let mut cls = class(
            "Widget",
            "NSObject",
            vec![Method {
                deprecated: true,
                ..method("lockAll", true, vec![], TypeRef::void())
            }],
        );
        cls.protocols = vec!["Locker".to_string()];
        let mut reg = ProtocolRegistry::new();
        reg.insert_conformance("Locker", vec![], [("lockAll".to_string(), true)]);
        let (statics, _instances) = bound_methods(&cls, &mapper, &HashSet::new(), &reg);
        assert!(
            statics.is_empty(),
            "no static promise exists, so no static carve-out, got {statics:?}"
        );
    }

    #[test]
    fn referenced_class_types_gathers_super_and_object_refs_minus_self() {
        // The whole-program set the orchestrator would build: this framework's classes.
        let mapper = known(&["Gadget", "Widget", "NSColor", "NSString"]);
        // Gadget extends Widget (same fw); a param typed NSColor, a return typed
        // NSString, an `id` return (→ NSObject), and a self-typed param (Gadget →
        // excluded). instancetype and scalars carry no reference.
        let cls = class(
            "Gadget",
            "Widget",
            vec![
                method(
                    "paintWith:",
                    false,
                    vec![param(
                        "c",
                        ty(TypeRefKind::Class {
                            name: "NSColor".into(),
                            framework: None,
                            params: vec![],
                        }),
                    )],
                    ty(TypeRefKind::Class {
                        name: "NSString".into(),
                        framework: None,
                        params: vec![],
                    }),
                ),
                method(
                    "delegate",
                    false,
                    vec![],
                    ty(TypeRefKind::Id {
                        protocols: Vec::new(),
                    }),
                ),
                method(
                    "sibling:",
                    false,
                    vec![param(
                        "g",
                        ty(TypeRefKind::Class {
                            name: "Gadget".into(),
                            framework: None,
                            params: vec![],
                        }),
                    )],
                    ty(TypeRefKind::Instancetype),
                ),
            ],
        );
        let (statics, instances) =
            bound_methods(&cls, &mapper, &HashSet::new(), &ProtocolRegistry::new());
        let refs = referenced_class_types(
            &cls,
            &statics,
            &instances,
            &mapper,
            &OverrideWidenings::empty(),
        );
        let names: Vec<&str> = refs.iter().map(String::as_str).collect();
        // Sorted (BTreeSet); Widget (super), NSColor/NSString (refs), NSObject (id);
        // Gadget (self) removed, instancetype/scalars absent.
        assert_eq!(names, vec!["NSColor", "NSObject", "NSString", "Widget"]);
    }

    #[test]
    fn referenced_class_types_never_escape_the_declared_set() {
        // THE IMPORT-HONESTY INVARIANT (`swift-nominal-type-surface-k66`). Every name this set
        // yields becomes a **value import** — `import { X } from '@apianyware/<fw>'` — so if a
        // name is not a class the emitter emits, no module exports it and the artifact does not
        // compile. The invariant: the set is always a subset of the declared classes ∪ the two
        // names the runtime provides (`NSObject`, and the superclass, which the orchestrator
        // backs with a synthesized bare node when the IR does not declare it).
        //
        // This is the emitter-side half of the corpus-wide check. The full check — that the
        // emitted files really export what the emitted files import — is `tsc --noEmit` over the
        // corpus (`corpus-typecheck-gate-k75`), which subsumes it.
        let mapper = known(&["Gadget", "NSString"]);
        let cls = class(
            "Gadget",
            "Widget",
            vec![
                // Declared → binds. Undeclared, ObjC-sourced → degrades to NSObject.
                method(
                    "paintWith:",
                    false,
                    vec![param(
                        "loc",
                        ty(TypeRefKind::Class {
                            name: "CLLocation".into(),
                            framework: None,
                            params: vec![],
                        }),
                    )],
                    ty(TypeRefKind::Class {
                        name: "NSString".into(),
                        framework: None,
                        params: vec![],
                    }),
                ),
            ],
        );
        let (statics, instances) =
            bound_methods(&cls, &mapper, &HashSet::new(), &ProtocolRegistry::new());
        let refs = referenced_class_types(
            &cls,
            &statics,
            &instances,
            &mapper,
            &OverrideWidenings::empty(),
        );
        let allowed: BTreeSet<String> = ["Gadget", "NSString", "NSObject", "Widget"]
            .iter()
            .map(|s| s.to_string())
            .collect();
        assert!(
            refs.is_subset(&allowed),
            "an emitted surface may only import a declared class, the runtime root, or its \
             superclass — got {refs:?}"
        );
        // Specifically: the undeclared `CLLocation` never appears; it arrives as `NSObject`.
        assert!(!refs.contains("CLLocation"));
        assert!(refs.contains("NSObject"));
    }

    #[test]
    fn referenced_pod_types_gathers_geometry_from_params_and_returns() {
        // The hole `pod-struct-types-k73` closes: before this, a geometry-carrying signature
        // rendered `CGRect` and imported nothing, so the artifact referenced an undefined type.
        let mapper = known(&["NSWindow"]);
        let cls = class(
            "NSWindow",
            "NSObject",
            vec![
                // A rect param + a rect return (the hello-window shape), and a scalar param that
                // contributes nothing.
                method(
                    "initWithContentRect:styleMask:",
                    false,
                    vec![
                        param(
                            "contentRect",
                            ty(TypeRefKind::Struct {
                                name: "NSRect".into(), // canonicalises to CGRect
                            }),
                        ),
                        param(
                            "style",
                            ty(TypeRefKind::Primitive {
                                name: "NSUInteger".into(),
                            }),
                        ),
                    ],
                    ty(TypeRefKind::Instancetype),
                ),
                method(
                    "frame",
                    false,
                    vec![],
                    ty(TypeRefKind::Struct {
                        name: "CGRect".into(),
                    }),
                ),
                // A geometry *alias* (libclang's spelling) on a static, and a point param.
                method(
                    "windowWithRange:origin:",
                    true,
                    vec![
                        param(
                            "range",
                            ty(TypeRefKind::Alias {
                                name: "NSRange".into(),
                                framework: None,
                                underlying_primitive: None,
                            }),
                        ),
                        param(
                            "origin",
                            ty(TypeRefKind::Struct {
                                name: "NSPoint".into(), // canonicalises to CGPoint
                            }),
                        ),
                    ],
                    ty(TypeRefKind::Instancetype),
                ),
            ],
        );
        let (statics, instances) =
            bound_methods(&cls, &mapper, &HashSet::new(), &ProtocolRegistry::new());
        let pods = referenced_pod_types(&statics, &instances);
        let names: Vec<&str> = pods.iter().map(String::as_str).collect();
        // Sorted (BTreeSet), canonicalised (NSRect→CGRect, NSPoint→CGPoint), deduped (CGRect twice).
        assert_eq!(names, vec!["CGPoint", "CGRect", "NSRange"]);
    }

    #[test]
    fn referenced_pod_types_is_empty_for_a_geometry_free_class() {
        // Empty in, empty out — a geometry-free class's imports stay byte-identical, which is what
        // lets this arm land without churning every golden.
        let mapper = known(&["Widget", "NSString"]);
        let cls = class(
            "Widget",
            "NSObject",
            vec![
                method(
                    "length",
                    false,
                    vec![],
                    ty(TypeRefKind::Id {
                        protocols: Vec::new(),
                    }),
                ),
                method(
                    "name",
                    false,
                    vec![],
                    ty(TypeRefKind::Class {
                        name: "NSString".into(),
                        framework: None,
                        params: vec![],
                    }),
                ),
            ],
        );
        let (statics, instances) =
            bound_methods(&cls, &mapper, &HashSet::new(), &ProtocolRegistry::new());
        assert!(referenced_pod_types(&statics, &instances).is_empty());
    }

    #[test]
    fn class_header_roots_at_the_runtime_nsobject() {
        let reg = ProtocolRegistry::new();
        let pr = protocol_resolver("Foundation", &reg, &[]);
        let mapper = TsFfiTypeMapper::new();
        assert_eq!(
            class_header(&class("Widget", "NSObject", vec![]), &pr, &mapper),
            "export class Widget extends NSObject"
        );
        // An empty superclass also roots at the runtime NSObject.
        assert_eq!(
            class_header(&class("NSString", "", vec![]), &pr, &mapper),
            "export class NSString extends NSObject"
        );
        // A non-NSObject superclass keeps its TS name.
        assert_eq!(
            class_header(&class("NSMutableString", "NSString", vec![]), &pr, &mapper),
            "export class NSMutableString extends NSString"
        );
    }

    #[test]
    fn class_header_appends_implements_for_emittable_conformances() {
        // ADR-0055 §4's conforming-class half: a class conforming to emittable protocols emits
        // `implements <I>[, …]` in IR order; a marker / unresolvable protocol is filtered out.
        let mut cls = class("NSTableView", "NSView", vec![]);
        // Conforms to two known interfaces plus one the resolver does not recognise (a marker
        // or an unconfigured cross-framework reference) — the latter must be dropped.
        cls.protocols = vec![
            "NSTableViewDelegate".into(),
            "NSObject".into(), // a marker protocol here — not in the known set
            "NSTableViewDataSource".into(),
        ];
        let reg = ProtocolRegistry::new();
        let pr = protocol_resolver(
            "AppKit",
            &reg,
            &["NSTableViewDelegate", "NSTableViewDataSource"],
        );
        assert_eq!(
            class_header(&cls, &pr, &TsFfiTypeMapper::new()),
            "export class NSTableView extends NSView \
             implements NSTableViewDelegate, NSTableViewDataSource"
        );
        // The `implemented_protocols` set (the import driver) matches — order preserved, the
        // unknown name dropped. Raw ObjC names: the rename (if any) is `class_header`'s own job.
        assert_eq!(
            implemented_protocols(&cls, &pr),
            vec![
                "NSTableViewDelegate".to_string(),
                "NSTableViewDataSource".to_string()
            ]
        );
    }

    #[test]
    fn class_header_renames_a_conformance_whose_name_a_declared_class_also_carries() {
        // k90: ObjC has two namespaces, TypeScript one. `AppView` is both a class this program
        // declares and a protocol `NSResponder` conforms to — the `implements` clause must name
        // the RE-ENCODED interface identifier, not the bare name a sibling module's `export class
        // AppView` already owns.
        let mut cls = class("NSResponder", "NSObject", vec![]);
        cls.protocols = vec!["AppView".into()];
        let reg = ProtocolRegistry::new();
        let pr = protocol_resolver("AppKit", &reg, &["AppView"]);
        let mapper = TsFfiTypeMapper::with_known(
            Arc::default(),
            Arc::new(["AppView".to_string()].into_iter().collect()),
            Arc::new(["AppView".to_string()].into_iter().collect()),
        );
        assert_eq!(
            class_header(&cls, &pr, &mapper),
            "export class NSResponder extends NSObject implements AppViewProtocol"
        );
        // `implemented_protocols` itself still reports the raw name — the registry's routing key.
        assert_eq!(
            implemented_protocols(&cls, &pr),
            vec!["AppView".to_string()]
        );
    }

    #[test]
    fn class_header_omits_implements_when_no_emittable_conformance() {
        // A class with no conformances, or only unrecognised ones, emits a bare header.
        let mut cls = class("NSView", "NSResponder", vec![]);
        cls.protocols = vec!["NSCoding".into()]; // not in the known set → dropped
        let reg = ProtocolRegistry::new();
        let pr = protocol_resolver("AppKit", &reg, &[]);
        assert_eq!(
            class_header(&cls, &pr, &TsFfiTypeMapper::new()),
            "export class NSView extends NSResponder"
        );
        assert!(implemented_protocols(&cls, &pr).is_empty());
    }
}
