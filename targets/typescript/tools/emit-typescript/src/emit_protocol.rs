//! Protocol emission — each ObjC `@protocol` → a real TS **`interface`** (ADR-0055 §4).
//!
//! TypeScript is the first target that can express an ObjC protocol *faithfully*: the
//! objc2 "separate interface" model — `@required` methods → members, `@optional` methods
//! → **optional members** (`method?()`), inherited protocols → **`extends`** — a fidelity
//! the CL/Scheme targets cannot reach (sbcl projects a protocol to a `register-objc-protocol`
//! table + delegate-only generics; there is no `interface` construct). An `interface` is
//! **type-only** — it carries no runtime object at all (unlike an `enum`, which carries
//! both) — so a protocol is primarily a **`.d.ts` deliverable**. Three idiom choices fix
//! the output:
//!
//! 1. **Both `protocols.ts` and `protocols.d.ts`, identical bodies.** An interface erases
//!    at compile, so its `.ts` and `.d.ts` bodies are **byte-identical** — the same
//!    trivially-non-drifting realization of ADR-0055 §2's one-pass-drives-both invariant
//!    that [`crate::emit_enums`] gets for free (an enum member *is* its value). The `.ts`
//!    is emitted even though it compiles to an (essentially empty) runtime module because
//!    the barrel's `export * from './protocols'` compiles to a **runtime** re-export that
//!    must resolve to a real `protocols.js`; a `.d.ts`-only module would leave that
//!    re-export dangling at run time. `export *` carries both the value and the type
//!    bindings, so the barrel re-exports the interface **type** with no runtime footprint
//!    (valid under `isolatedModules`). Considered and rejected: a `.d.ts`-only module with
//!    a barrel `export type * from './protocols'` — it diverges the barrel's re-export
//!    logic from the class/enum path for a marginal saving (one empty runtime module).
//!
//! 2. **Required vs optional = the `?` marker.** A required method renders `name(…): T;`,
//!    an optional one `name?(…): T;` — a distinction TS expresses cleanly and no prior
//!    target has. The member signature reuses the same [`crate::class_surface`] /
//!    [`crate::naming`] primitives the class surface uses (the injective `:`→`_` selector
//!    rule via [`method_name`], [`render_params`], the [`TsFfiTypeMapper`] return mapping),
//!    dropping the `static`/body and gaining the `?`. So a delegate method reads the same
//!    on the interface as on a class that implements it — no drift.
//!
//! 3. **`extends` resolves both same- and cross-framework inheritance.** A protocol
//!    inheriting another in the **same** framework keeps its `extends` with no import (the
//!    inherited interface is declared in this very `protocols.ts`). A protocol inheriting one
//!    owned by **another** framework (the near-universal `<NSObject>` / `<NSCopying>` case)
//!    now resolves through the injected
//!    [`ProtocolModuleResolver`](crate::protocol_graph::ProtocolModuleResolver) (the third of
//!    the class/enum/protocol ownership-registry family, populated by the Step-5 CLI
//!    pre-pass): it joins `extends` and imports its interface **type-only** (an interface
//!    `extends` is erased, so — like an enum reference — it forms no runtime cycle through the
//!    barrel). A base the resolver cannot recognise (a marker protocol, or an unconfigured
//!    emitter's cross-framework reference) is still dropped, safely (the interface stays valid
//!    TS, missing only those inherited members). Class-typed member params/returns route
//!    through the [`ClassModuleResolver`] the class emitters use, so a member's `NSString`
//!    return imports from `@apianyware/foundation`.
//!
//! Protocol methods with `objc_exposed == false` carry no ObjC selector and defer (ADR-0026
//! §3, the same split class methods take); empty marker protocols (no bindable surface) and
//! non-identifier names are skipped so the module is always valid TS. The **conforming
//! class's `implements`** clause is the [`crate::class_surface`] half of ADR-0055 §4, driven
//! by the same [`ProtocolModuleResolver`].
//!
//! ## Protocol-qualified members (ADR-0055 §4b)
//!
//! A member's own `id<P>` slots are now typed by their interface
//! ([`crate::protocol_binding`]) — 77 corpus positions, the densest inbound population after class
//! methods, and exactly the shape a delegate protocol has (`- didRefresh:(id<TKSource>)`). Contravariant
//! and covariant positions render differently, and that difference is the whole variance argument:
//! a **param** is the bare interface `P` (so a plain JS object literal satisfies it), a **return**
//! intersects the object root (`P & NSObject` — what the value *is*, once
//! `dynamic-class-wrap-k88` mints it into its real class).
//!
//! One thing here differs from a class file: a **same-framework** interface is declared in this very
//! `protocols.ts`, so a bound reference to it is named **in-file and never imported** — importing a
//! module's own declaration is a redeclaration ([`referenced_cross_framework_protocol_types`]). A
//! cross-framework one imports type-only, exactly like an inherited `extends` base.
//!
//! Pure codegen — the delegate *bridge* (object→ObjC forwarding class) is ADR-0059 /
//! [`emitted-delegate-spec-k84`], not here.

use std::collections::{BTreeSet, HashMap, HashSet};

use apianyware_emit::code_writer::CodeWriter;
use apianyware_emit::ffi_type_mapping::FfiTypeMapper;
use apianyware_emit::write_line;
use apianyware_types::ir::{Method, Protocol};
use apianyware_types::type_ref::TypeRef;

use crate::class_graph::ClassModuleResolver;
use crate::class_surface::{object_class_name, render_params};
use crate::enum_graph::EnumModuleResolver;
use crate::ffi_type_mapping::{pod_type_name, TsFfiTypeMapper};
use crate::imports::{
    class_type_imports, enum_type_imports, merge_type_imports, pod_type_imports,
    protocol_type_imports, render_import_blocks, render_type_import_blocks,
};
use crate::method_filter::is_supported_method;
use crate::naming::{is_valid_ts_identifier, method_name, module_specifier};
use crate::protocol_binding;
use crate::protocol_graph::ProtocolModuleResolver;

/// One protocol interface member: the method plus whether the protocol declares it
/// **optional** (`@optional` → the `?` marker).
struct Member<'a> {
    method: &'a Method,
    optional: bool,
}

/// A protocol's declared **interface members** — required first then optional, each in
/// source order — the frontier both `protocols.ts` and `protocols.d.ts` emit.
///
/// Kept only for the `objc_exposed`, **instance**, supported methods:
/// - `objc_exposed == false` methods carry no ObjC selector (ADR-0026 §3) and defer;
/// - **class** (`+`) protocol requirements have no place on a TS *instance* interface —
///   vanishingly rare on real (delegate) protocols — so they defer with the rest of the
///   `implements`/param-typing frontier;
/// - unsupported signatures ([`is_supported_method`]: variadic, blocks, raw pointers,
///   non-geometry structs) defer exactly as they do on a class, so an interface declares
///   only members a conforming class could also implement — no drift.
fn interface_members<'a>(proto: &'a Protocol, mapper: &TsFfiTypeMapper) -> Vec<Member<'a>> {
    proto
        .required_methods
        .iter()
        .map(|m| Member {
            method: m,
            optional: false,
        })
        .chain(proto.optional_methods.iter().map(|m| Member {
            method: m,
            optional: true,
        }))
        .filter(|mb| {
            mb.method.objc_exposed
                && !mb.method.class_method
                && is_supported_method(mb.method, mapper)
        })
        .collect()
}

/// The protocol's bindable **instance methods** — the exact frontier
/// [`interface_members`] projects into `protocols.ts`/`protocols.d.ts`, shared with the
/// inbound IMP table ([`crate::inbound_table`]) so the interface surface and the
/// generated inbound trampoline set walk **one** frontier (the k58 mirror discipline):
/// a method the interface declares is a method a JS delegate can implement, so its
/// signature must have (or defer visibly from) an installable trampoline.
pub fn bound_protocol_methods<'a>(
    proto: &'a Protocol,
    mapper: &TsFfiTypeMapper,
) -> Vec<&'a Method> {
    interface_members(proto, mapper)
        .into_iter()
        .map(|mb| mb.method)
        .collect()
}

/// Whether a protocol carries a bindable interface surface of its **own** — at least one
/// emittable member ([`interface_members`]). A pure-inheritance shell or an all-Swift-native
/// requirement has none; whether it still emits depends on its ancestors too
/// ([`transitively_emittable_protocols`]) — this is only the base case of that fixed point.
pub fn has_surface(proto: &Protocol, mapper: &TsFfiTypeMapper) -> bool {
    !interface_members(proto, mapper).is_empty()
}

/// Whether a protocol emits a TS `interface` on its **own** surface alone — a valid
/// TS-identifier name ([`is_valid_ts_identifier`], the same guard [`crate::emit_enums`]
/// applies) **and** a bindable surface of its own ([`has_surface`]). The base case
/// [`transitively_emittable_protocols`] widens over `inherits` (ADR-0055 §4b,
/// `transitive-protocol-emittability-k106`); every reader that decides whether a *set* of
/// protocols emits interfaces calls the widened function, not this one directly.
pub fn is_emittable_protocol(proto: &Protocol, mapper: &TsFfiTypeMapper) -> bool {
    is_valid_ts_identifier(&proto.name) && has_surface(proto, mapper)
}

/// Whether `name`'s `inherits` closure reaches a real bindable surface — its own
/// ([`is_emittable_protocol`]), or (transitively) an ancestor's. `by_name` must carry every
/// protocol the chain might cross, **including ones that fail their own [`has_surface`]** — an
/// ancestor two hops up is invisible past a non-emittable middle link otherwise
/// (`NSMachPortDelegate`'s sole member takes an unsupported raw pointer, no surface of its own,
/// but it inherits the fully-bindable `NSPortDelegate`). Guards `inherits` cycles the same way
/// [`crate::protocol_graph::ProtocolRegistry::conformance_closure`] does (a `visiting` set).
///
/// An ancestor **absent from `by_name`** — a per-framework caller's own scope limit
/// (`typecheck-gate-post-k86-residuals-k110`): `by_name` only carries the protocols *handed to
/// this call*, and a per-framework caller hands only its own framework's slice, so an ancestor
/// owned by a different framework (`CNKeyDescriptor`'s `NSSecureCoding`/`NSCopying`, both
/// Foundation) is invisible to the local walk. Falls back to [`TsFfiTypeMapper::is_known_protocol`]:
/// a whole-program-aware mapper (the registry itself, or a per-framework mapper seeded from
/// [`ProtocolRegistry::names`](crate::protocol_graph::ProtocolRegistry::names)) has already
/// resolved that name transitively; an unconfigured/local-only mapper carries no known protocols
/// of its own, so this degrades to `false` — the pre-k110 behaviour. Sound, not circular: by the
/// time a per-framework mapper reaches this call it was built *after* the whole-program registry,
/// and the registry's own call passes every framework's protocols into `by_name` up front, so its
/// own fallback here is moot.
fn reaches_bindable_surface<'a>(
    name: &'a str,
    by_name: &HashMap<&'a str, &'a Protocol>,
    mapper: &TsFfiTypeMapper,
    visiting: &mut HashSet<&'a str>,
) -> bool {
    let Some(&proto) = by_name.get(name) else {
        return mapper.is_known_protocol(name);
    };
    if is_emittable_protocol(proto, mapper) {
        return true;
    }
    if !is_valid_ts_identifier(&proto.name) || !visiting.insert(name) {
        return false;
    }
    let reached = proto
        .inherits
        .iter()
        .any(|ancestor| reaches_bindable_surface(ancestor.as_str(), by_name, mapper, visiting));
    visiting.remove(name);
    reached
}

/// Every protocol in `all_protocols` that is emittable **transitively over `inherits`**
/// (ADR-0055 §4b, `transitive-protocol-emittability-k106`): a valid TS identifier with a real
/// bindable surface, own ([`has_surface`]) or inherited. Computed as a fixed point over the
/// **whole** set handed in — not just the protocols that already pass their own `has_surface` —
/// so an ancestor's surface is visible past a middle link that has none of its own.
///
/// The one widened predicate every reader of protocol emittability agrees on in place of the
/// old own-surface-only [`is_emittable_protocol`]:
/// [`ProtocolRegistry::from_framework_refs`](crate::protocol_graph::ProtocolRegistry::from_framework_refs)
/// calls it over the **whole program** (`inherits` can cross framework boundaries); every
/// per-framework reader — [`crate::emit_framework`]'s same-framework fallback,
/// [`emitted_protocol_count`], [`render_protocol_bodies`]'s `emittable` filter, and
/// [`crate::delegate_spec::spec_protocols`] — calls it over its own framework's protocol slice.
/// A protocol whose *only* bindable ancestor lives in a different framework than a
/// per-framework caller can see (`CNKeyDescriptor`'s `NSSecureCoding`, both real corpus members —
/// `typecheck-gate-post-k86-residuals-k110`, confirming the scope limit k106 left unverified) is
/// recovered by [`reaches_bindable_surface`]'s mapper fallback: a per-framework caller's `mapper`
/// already carries the whole-program registry's recognition set by the time it renders
/// ([`crate::emit_framework`] seeds `known_protocols` from
/// [`ProtocolRegistry::names`](crate::protocol_graph::ProtocolRegistry::names) before building
/// it), so the local, framework-scoped `by_name` walk defers to that set exactly where it would
/// otherwise go blind.
pub fn transitively_emittable_protocols<'a>(
    all_protocols: impl IntoIterator<Item = &'a Protocol>,
    mapper: &TsFfiTypeMapper,
) -> BTreeSet<String> {
    let by_name: HashMap<&'a str, &'a Protocol> = all_protocols
        .into_iter()
        .map(|p| (p.name.as_str(), p))
        .collect();
    let mut out = BTreeSet::new();
    for &name in by_name.keys() {
        if reaches_bindable_surface(name, &by_name, mapper, &mut HashSet::new()) {
            out.insert(name.to_string());
        }
    }
    out
}

/// The number of protocols this framework actually emits as interfaces. Drives the
/// orchestrator's write decision, its `EmitResult::protocols_emitted` count, and the barrel
/// re-export — all three off this one predicate, so they agree with [`render_protocol_bodies`].
pub fn emitted_protocol_count(protocols: &[Protocol], mapper: &TsFfiTypeMapper) -> usize {
    let emittable = transitively_emittable_protocols(protocols.iter(), mapper);
    protocols
        .iter()
        .filter(|p| emittable.contains(&p.name))
        .count()
}

/// Render the **`protocols.ts`** module — the banner plus the shared imports-and-interfaces
/// body ([`render_protocol_bodies`]). Emitted as a real (interface-only, so essentially
/// empty at runtime) module so the barrel's runtime `export * from './protocols'` resolves.
pub fn render_protocols_module(
    protocols: &[Protocol],
    framework: &str,
    resolver: &ClassModuleResolver<'_>,
    enum_resolver: &EnumModuleResolver<'_>,
    protocol_resolver: &ProtocolModuleResolver<'_>,
) -> String {
    let mut w = CodeWriter::new();
    w.line("// Generated by apianyware emit-typescript — DO NOT EDIT.");
    write_line!(
        w,
        "// Protocols: {framework} (module {})",
        module_specifier(framework)
    );
    w.line("//");
    w.line("// Real TS interfaces (ADR-0055 §4): @required → members, @optional → `?` members,");
    w.line("// inherited protocols → `extends` (same-framework in-file; cross-framework imported");
    w.line("// type-only). An interface is type-only, so this module is (essentially) empty at");
    w.line("// runtime — emitted so the barrel's `export *` resolves; its .d.ts is co-generated");
    w.line("// from the same pass with a byte-identical body.");
    w.blank_line();
    w.raw(&render_protocol_bodies(
        protocols,
        resolver,
        enum_resolver,
        protocol_resolver,
    ));
    w.finish()
}

/// Render the co-generated **`protocols.d.ts`** — the same [`render_protocol_bodies`] the
/// `.ts` carries (an interface has no runtime, so the two bodies are byte-identical; only
/// the banner differs), the interface realization of ADR-0055 §2's non-drift invariant.
pub fn render_protocols_dts(
    protocols: &[Protocol],
    framework: &str,
    resolver: &ClassModuleResolver<'_>,
    enum_resolver: &EnumModuleResolver<'_>,
    protocol_resolver: &ProtocolModuleResolver<'_>,
) -> String {
    let mut w = CodeWriter::new();
    w.line("// Generated by apianyware emit-typescript — DO NOT EDIT.");
    write_line!(w, "// Type surface: protocols ({framework})");
    w.line("//");
    w.line("// Declaration-only .d.ts, co-generated with protocols.ts from the same IR pass");
    w.line("// (ADR-0055 §2). An interface is type-only, so this body is identical to the");
    w.line("// protocols.ts body — runtime and types cannot drift.");
    w.blank_line();
    w.raw(&render_protocol_bodies(
        protocols,
        resolver,
        enum_resolver,
        protocol_resolver,
    ));
    w.finish()
}

/// The shared body both artifacts carry — the per-module class-type imports (a member's
/// object-typed param/return routed to its owning module through the `resolver`, the same
/// grouping the class emitters use) followed by one `export interface …` per **emittable**
/// protocol ([`is_emittable_protocol`]), blank-line-separated, in IR order. Empty for an
/// empty (or all-skipped) protocol list. This is the single source both
/// [`render_protocols_module`] and [`render_protocols_dts`] concatenate onto their banner,
/// so the `.ts` and `.d.ts` bodies provably cannot drift.
fn render_protocol_bodies(
    protocols: &[Protocol],
    resolver: &ClassModuleResolver<'_>,
    enum_resolver: &EnumModuleResolver<'_>,
    protocol_resolver: &ProtocolModuleResolver<'_>,
) -> String {
    // All three recognition sets, exactly as the class emitters build them (`emit_class`): an enum
    // alias upgrades off `number`, an unbound `Class{…}` degrades to the root, a member naming a
    // `.swiftinterface` nominal type defers (`class_binding`, k66) — so an interface declares only
    // members a conforming class could also implement — and a bound `id<P>` qualifier types its slot
    // by the interface (`protocol_binding`, k89). A delegate protocol whose members take *other*
    // protocol-qualified objects is the corpus's densest inbound population, so this is where the
    // qualifier earns its keep on the receive side.
    let mapper = TsFfiTypeMapper::with_known(
        enum_resolver.known_enums(),
        resolver.known_classes(),
        protocol_resolver.known_protocols(),
    );
    let emittable_set = transitively_emittable_protocols(protocols.iter(), &mapper);
    let emittable: Vec<&Protocol> = protocols
        .iter()
        .filter(|p| emittable_set.contains(&p.name))
        .collect();
    if emittable.is_empty() {
        return String::new();
    }
    // A same-framework emittable protocol is `extends`-eligible in-file (no import); a
    // cross-framework inherited protocol resolves through `protocol_resolver` and imports
    // type-only; a non-emittable / unresolvable one is dropped ([`extends_bases`]).
    let emittable_names: BTreeSet<&str> = emittable.iter().map(|p| p.name.as_str()).collect();

    let mut w = CodeWriter::new();

    // Class-typed member params/returns → per-module *value* import blocks (the same
    // resolver-routed grouping the class `.ts`/`.d.ts` use). Then the **type-only** section:
    // enum-typed member params/returns (enum-alias-typing) merged with the cross-framework protocol
    // interfaces this module names — through an `extends` base *or* a bound `id<P>` qualifier in a
    // member signature (both erased at compile, so both type-only) — and the POD geometry types the
    // members reference (runtime-owned plain object types, ADR-0055 §5). One combined section per
    // module, so an enum and a protocol owned by the same framework coalesce into a single
    // `import type` block, as do the runtime's PODs.
    let map = class_type_imports(&referenced_class_types(&emittable, &mapper), resolver);
    let enum_map = enum_type_imports(&referenced_enum_types(&emittable, &mapper), enum_resolver);
    let mut protocol_refs =
        referenced_cross_framework_bases(&emittable, &emittable_names, protocol_resolver);
    protocol_refs.extend(referenced_cross_framework_protocol_types(
        &emittable,
        &emittable_names,
        &mapper,
    ));
    let proto_map = protocol_type_imports(&protocol_refs, protocol_resolver, &mapper);
    let pod_map = pod_type_imports(&referenced_pod_types(&emittable, &mapper));
    let type_map = merge_type_imports(merge_type_imports(enum_map, proto_map), pod_map);
    render_import_blocks(&map, &mut w);
    render_type_import_blocks(&type_map, &mut w);
    if !map.is_empty() || !type_map.is_empty() {
        w.blank_line();
    }

    for (i, proto) in emittable.iter().enumerate() {
        if i > 0 {
            w.blank_line();
        }
        render_one_interface(&mut w, proto, &emittable_names, &mapper, protocol_resolver);
    }
    w.finish()
}

/// Render one protocol as `export interface <Name>[ extends <Bases>] { <members> }`. The
/// declared name is [`protocol_binding::protocol_type_name`] — its own ObjC name, unless a
/// declared class also carries it, in which case it re-encodes as `<Name>Protocol`
/// (`protocol-class-name-collapse-k90`): the one place the interface's own identifier is
/// spelled, so a colliding name never makes the framework barrel export one symbol twice.
fn render_one_interface(
    w: &mut CodeWriter,
    proto: &Protocol,
    emittable_names: &BTreeSet<&str>,
    mapper: &TsFfiTypeMapper,
    protocol_resolver: &ProtocolModuleResolver<'_>,
) {
    let bases = extends_bases(proto, emittable_names, protocol_resolver, mapper);
    let extends = if bases.is_empty() {
        String::new()
    } else {
        format!(" extends {}", bases.join(", "))
    };
    write_line!(
        w,
        "export interface {}{} {{",
        protocol_binding::protocol_type_name(&proto.name, mapper),
        extends
    );
    w.indent();
    for mb in interface_members(proto, mapper) {
        let optional = if mb.optional { "?" } else { "" };
        write_line!(
            w,
            "{}{}({}): {};",
            method_name(&mb.method.selector),
            optional,
            render_params(mb.method, mapper),
            mapper.map_type(&mb.method.return_type, true)
        );
    }
    w.dedent();
    w.line("}");
}

/// The inherited protocols this interface `extends`, preserving `inherits` order (ADR-0055
/// §4). A base is kept when it is a real interface the emitter can reach:
/// - **same-framework** (in `emittable_names`) — declared in this very `protocols.ts`, so it
///   joins `extends` with no import (the in-file case);
/// - **cross-framework** (the `protocol_resolver` recognises it via the ownership registry) —
///   joins `extends` and is imported type-only ([`referenced_cross_framework_bases`] collects
///   the import side).
///
/// A base neither same-framework-emittable nor registry-known (a marker protocol, or an
/// unconfigured emitter's cross-framework reference) is **dropped** — keeping it would dangle
/// (`extends NSObject` with no import); the interface stays valid TS, missing only those
/// inherited members. The same-framework check precedes the registry check, so a protocol the
/// whole-program registry happens to own under the *current* framework is still treated as
/// in-file.
///
/// Each kept base renders through [`protocol_binding::protocol_type_name`], so an inherited
/// base whose name a declared class also carries `extends`-joins under its re-encoded identifier
/// — the same one its own declaration and its import (if cross-framework) use.
fn extends_bases(
    proto: &Protocol,
    emittable_names: &BTreeSet<&str>,
    protocol_resolver: &ProtocolModuleResolver<'_>,
    mapper: &TsFfiTypeMapper,
) -> Vec<String> {
    proto
        .inherits
        .iter()
        .filter(|name| {
            emittable_names.contains(name.as_str()) || protocol_resolver.owner(name).is_some()
        })
        .map(|name| protocol_binding::protocol_type_name(name, mapper))
        .collect()
}

/// The union of **cross-framework** inherited protocol names every emittable protocol
/// references — an inherited base that is registry-owned by *another* framework (not in
/// `emittable_names`). These join `extends` and must be imported type-only (an interface
/// `extends` is erased); a same-framework base is in-file and never enters this set. The
/// protocol analogue of [`referenced_class_types`] for the inheritance edge.
fn referenced_cross_framework_bases(
    emittable: &[&Protocol],
    emittable_names: &BTreeSet<&str>,
    protocol_resolver: &ProtocolModuleResolver<'_>,
) -> BTreeSet<String> {
    let mut set: BTreeSet<String> = BTreeSet::new();
    for proto in emittable {
        for base in &proto.inherits {
            if !emittable_names.contains(base.as_str()) && protocol_resolver.owner(base).is_some() {
                set.insert(base.clone());
            }
        }
    }
    set
}

/// The union of **class type names** every emittable protocol's members reference — each
/// member param/return object type ([`object_class_name`]: `id`/`Class` → `NSObject`, a
/// concrete class → itself). The set the module's import blocks are grouped from. Protocol
/// names are a separate namespace (a protocol and a class may share a name, e.g. `NSObject`),
/// so an inherited protocol never enters this set; `this`/scalars/structs carry no reference.
fn referenced_class_types(emittable: &[&Protocol], mapper: &TsFfiTypeMapper) -> BTreeSet<String> {
    let mut set: BTreeSet<String> = BTreeSet::new();
    for proto in emittable {
        for mb in interface_members(proto, mapper) {
            for p in &mb.method.params {
                if let Some(name) = object_class_name(&p.param_type, mapper, false) {
                    set.insert(name);
                }
            }
            if let Some(name) = object_class_name(&mb.method.return_type, mapper, true) {
                set.insert(name);
            }
        }
    }
    set
}

/// The **cross-framework** protocol interfaces every emittable protocol's members reference through
/// a bound `id<P>` qualifier ([`crate::protocol_binding`], ADR-0055 §4b) — the type-position sibling
/// of [`referenced_cross_framework_bases`]'s inheritance edge.
///
/// A **same-framework** interface is declared in this very `protocols.ts`, so it is named in-file
/// and must **not** be imported — importing a module's own declaration is a redeclaration. That is
/// the one way this differs from the class emitters' [`crate::class_surface::referenced_protocol_types`],
/// whose file never declares an interface and so imports every bound name.
fn referenced_cross_framework_protocol_types<'p>(
    emittable: &[&'p Protocol],
    emittable_names: &BTreeSet<&str>,
    mapper: &TsFfiTypeMapper,
) -> BTreeSet<String> {
    let mut types: Vec<&'p TypeRef> = Vec::new();
    for proto in emittable {
        for mb in interface_members(proto, mapper) {
            for p in &mb.method.params {
                types.push(&p.param_type);
            }
            types.push(&mb.method.return_type);
        }
    }
    protocol_binding::referenced_protocol_types(types, mapper)
        .into_iter()
        .filter(|name| !emittable_names.contains(name.as_str()))
        .collect()
}

/// The union of **POD geometry type names** every emittable protocol's members reference — each
/// member param/return the shared predicate ([`pod_type_name`]) resolves to one of the nine
/// by-value aggregates (ADR-0055 §5). The protocol analogue of
/// [`crate::class_surface::referenced_pod_types`], grouped into the runtime's type-only import
/// block ([`pod_type_imports`] — a POD needs no resolver: the runtime owns all nine). Takes the
/// `mapper` only to walk the same member frontier the interface renders ([`interface_members`]),
/// so a member the interface does not declare never contributes an import.
fn referenced_pod_types(emittable: &[&Protocol], mapper: &TsFfiTypeMapper) -> BTreeSet<String> {
    let mut set: BTreeSet<String> = BTreeSet::new();
    for proto in emittable {
        for mb in interface_members(proto, mapper) {
            for p in &mb.method.params {
                if let Some(name) = pod_type_name(&p.param_type) {
                    set.insert(name.to_string());
                }
            }
            if let Some(name) = pod_type_name(&mb.method.return_type) {
                set.insert(name.to_string());
            }
        }
    }
    set
}

/// The union of **enum type names** every emittable protocol's members reference — each
/// member param/return whose `Alias` the `mapper` proves an enum
/// ([`TsFfiTypeMapper::known_enum_name`]). The enum analogue of [`referenced_class_types`],
/// grouped into type-only import blocks (an interface member typed by an enum is a pure type
/// reference — no runtime footprint at all, unlike a class). An interface has no bodies, so —
/// unlike the class `.ts` — there is no `as`-cast counterpart; only the imports.
fn referenced_enum_types(emittable: &[&Protocol], mapper: &TsFfiTypeMapper) -> BTreeSet<String> {
    let mut set: BTreeSet<String> = BTreeSet::new();
    for proto in emittable {
        for mb in interface_members(proto, mapper) {
            for p in &mb.method.params {
                if let Some(name) = mapper.known_enum_name(&p.param_type) {
                    set.insert(name.to_string());
                }
            }
            if let Some(name) = mapper.known_enum_name(&mb.method.return_type) {
                set.insert(name.to_string());
            }
        }
    }
    set
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::class_graph::ClassRegistry;
    use crate::enum_graph::EnumRegistry;
    use crate::protocol_graph::ProtocolRegistry;
    use apianyware_types::ir::{Method, Param, Protocol};
    use apianyware_types::type_ref::{TypeRef, TypeRefKind};
    use std::sync::Arc;

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

    fn proto(
        name: &str,
        inherits: Vec<&str>,
        required: Vec<Method>,
        optional: Vec<Method>,
    ) -> Protocol {
        Protocol {
            name: name.into(),
            inherits: inherits.into_iter().map(String::from).collect(),
            required_methods: required,
            optional_methods: optional,
            properties: vec![],
            source: None,
            provenance: None,
            doc_refs: None,
            objc_exposed: true,
        }
    }

    /// Render `protocols.ts` for framework `fw` aware of `known_enums`, with empty
    /// registries (same-framework fallback for any class/enum refs; no cross-framework
    /// inherited protocols).
    fn render_ts_with_enums(protocols: &[Protocol], fw: &str, known_enums: &[&str]) -> String {
        render_ts_full(protocols, fw, known_enums, &ProtocolRegistry::new())
    }

    /// Render `protocols.ts` for framework `fw` aware of `known_enums`, with the given
    /// cross-framework protocol ownership registry (`proto_reg`) driving inherited-protocol
    /// `extends` resolution, and an **empty** protocol recognition set — so no `id<P>` qualifier
    /// binds and every one degrades to `NSObject` (the pre-k89 surface these `extends`-focused
    /// fixtures were written against).
    fn render_ts_full(
        protocols: &[Protocol],
        fw: &str,
        known_enums: &[&str],
        proto_reg: &ProtocolRegistry,
    ) -> String {
        render_ts_known(protocols, fw, known_enums, proto_reg, &[], &[])
    }

    /// The full per-framework render the orchestrator performs: the protocol resolver carries the
    /// recognition set (`known_protocols`) that gates both the `implements`/`extends` clauses **and**
    /// the `id<P>` bind arm ([`crate::protocol_binding`]), and the class registry carries
    /// `known_classes` — the k90 two-namespace collision is expressed by naming something in both.
    fn render_ts_known(
        protocols: &[Protocol],
        fw: &str,
        known_enums: &[&str],
        proto_reg: &ProtocolRegistry,
        known_protocols: &[&str],
        known_classes: &[&str],
    ) -> String {
        let mut reg = ClassRegistry::new();
        for c in known_classes {
            reg.insert(*c, fw.to_ascii_lowercase());
        }
        let enum_reg = EnumRegistry::new();
        let known: Arc<BTreeSet<String>> =
            Arc::new(known_enums.iter().map(|s| s.to_string()).collect());
        let enum_resolver = EnumModuleResolver::new(fw, &enum_reg, known);
        let known_p: Arc<BTreeSet<String>> =
            Arc::new(known_protocols.iter().map(|s| s.to_string()).collect());
        let protocol_resolver = ProtocolModuleResolver::new(fw, proto_reg, known_p);
        render_protocols_module(
            protocols,
            fw,
            &ClassModuleResolver::new(fw, &reg, Arc::new(reg.names())),
            &enum_resolver,
            &protocol_resolver,
        )
    }

    fn qualified_id(protocols: &[&str]) -> TypeRef {
        TypeRef {
            nullable: false,
            kind: TypeRefKind::Id {
                protocols: protocols.iter().map(|s| s.to_string()).collect(),
            },
        }
    }

    #[test]
    fn a_protocol_member_binds_its_qualified_slots_by_position() {
        // The inbound half of `protocol-binding-surface-k89`, and the corpus's densest population
        // after class methods: a delegate protocol whose members take and yield *other*
        // protocol-qualified objects (77 positions). Same variance rule as a class method — a param
        // is the bare interface, a return intersects the object root.
        let protos = vec![
            proto(
                "TKRefreshing",
                vec![],
                vec![m(
                    "didRefresh:",
                    vec![Param {
                        name: "source".into(),
                        param_type: qualified_id(&["TKSource"]),
                    }],
                    TypeRef::void(),
                )],
                vec![m("sourceFor:", vec![], qualified_id(&["TKSource"]))],
            ),
            proto(
                "TKSource",
                vec![],
                vec![m("load", vec![], TypeRef::void())],
                vec![],
            ),
        ];
        let out = render_ts_known(
            &protos,
            "TestKit",
            &[],
            &ProtocolRegistry::new(),
            &["TKRefreshing", "TKSource"],
            &[],
        );
        assert!(
            out.contains("didRefresh_(source: TKSource): void;"),
            "a qualified member param types by its interface:\n{out}"
        );
        assert!(
            out.contains("sourceFor_?(): TKSource & NSObject;"),
            "a qualified member return intersects the object root:\n{out}"
        );
        // TKSource is declared in THIS very protocols.ts, so it is named in-file and must NOT be
        // imported — importing a module's own declaration is a redeclaration. This is the one way
        // the protocol module's import rule differs from a class file's.
        assert!(
            !out.contains("import type"),
            "a same-framework interface is in-file, never imported:\n{out}"
        );
    }

    #[test]
    fn a_cross_framework_qualified_slot_imports_its_interface_type_only() {
        let mut proto_reg = ProtocolRegistry::new();
        proto_reg.insert("NSCopying", "foundation");
        let protos = vec![proto(
            "TKRefreshing",
            vec![],
            vec![m(
                "didRefresh:",
                vec![Param {
                    name: "source".into(),
                    param_type: qualified_id(&["NSCopying"]),
                }],
                TypeRef::void(),
            )],
            vec![],
        )];
        let out = render_ts_known(
            &protos,
            "TestKit",
            &[],
            &proto_reg,
            &["TKRefreshing", "NSCopying"],
            &[],
        );
        assert!(
            out.contains("didRefresh_(source: NSCopying): void;"),
            "{out}"
        );
        assert!(
            out.contains("import type {\n  NSCopying,\n} from '@apianyware/foundation';"),
            "a cross-framework interface imports type-only from its owner:\n{out}"
        );
    }

    #[test]
    fn emittability_is_recognition_blind() {
        // THE BOOTSTRAP GUARD. `emit_framework` and `ProtocolRegistry::from_framework_refs` *compute*
        // the protocol recognition set, so they must run `is_emittable_protocol` on a mapper that does
        // not yet hold it. That is sound only because emittability runs the **method frontier**, and
        // the frontier reads class membership and the ABI shape — never enums, never protocols. Pin
        // it: were it ever to consult either, the orchestrator would silently admit a different
        // interface set than the renderer, and the two would drift with nothing to catch it.
        let p = proto(
            "TKRefreshing",
            vec![],
            vec![m(
                "didRefresh:",
                vec![Param {
                    name: "source".into(),
                    param_type: qualified_id(&["TKSource"]),
                }],
                qualified_id(&["TKSource"]),
            )],
            vec![],
        );
        let blind = TsFfiTypeMapper::new();
        let classes: Arc<BTreeSet<String>> =
            Arc::new(["TKThing".to_string()].into_iter().collect());
        let enums: Arc<BTreeSet<String>> =
            Arc::new(["TKAlignment".to_string()].into_iter().collect());
        let protocols: Arc<BTreeSet<String>> = Arc::new(
            ["TKRefreshing".to_string(), "TKSource".to_string()]
                .into_iter()
                .collect(),
        );
        let aware = TsFfiTypeMapper::with_known(enums, Arc::clone(&classes), protocols);
        let frontier_only = TsFfiTypeMapper::with_known_classes(classes);
        assert_eq!(
            is_emittable_protocol(&p, &blind),
            is_emittable_protocol(&p, &aware)
        );
        assert_eq!(
            is_emittable_protocol(&p, &frontier_only),
            is_emittable_protocol(&p, &aware)
        );
        assert!(is_emittable_protocol(&p, &aware));
    }

    /// Render `protocols.ts` for framework `fw` with an empty registry (same-framework
    /// fallback for any class refs) and no known enums.
    fn render_ts(protocols: &[Protocol], fw: &str) -> String {
        render_ts_with_enums(protocols, fw, &[])
    }

    fn class_ty(name: &str) -> TypeRef {
        ty(TypeRefKind::Class {
            name: name.into(),
            framework: None,
            params: vec![],
        })
    }

    #[test]
    fn geometry_carrying_members_type_import_their_pod_types_from_the_runtime() {
        // The third emitter rides the same arm (k73's "all three emitters"): a delegate whose
        // members take/return geometry — `-[NSTableViewDelegate tableView:heightOfRow:]`-shaped —
        // must import the POD it declares, or the interface names an undefined type. Routes to the
        // runtime, exactly as the class and function emitters do.
        let p = proto(
            "TKLayoutDelegate",
            vec![],
            vec![m(
                "layoutRectForBounds:",
                vec![param(
                    "bounds",
                    ty(TypeRefKind::Struct {
                        name: "NSRect".into(),
                    }),
                )],
                ty(TypeRefKind::Struct {
                    name: "CGRect".into(),
                }),
            )],
            vec![m(
                "insetsForBounds:",
                vec![param(
                    "bounds",
                    ty(TypeRefKind::Struct {
                        name: "CGRect".into(),
                    }),
                )],
                ty(TypeRefKind::Struct {
                    name: "NSEdgeInsets".into(),
                }),
            )],
        );
        let out = render_ts(&[p], "TestKit");
        assert!(
            out.contains(
                "import type {\n  CGRect,\n  NSEdgeInsets,\n} from '@apianyware/runtime';"
            ),
            "the members' PODs import type-only from the runtime, deduped and canonicalised:\n{out}"
        );
        assert!(
            out.contains("  layoutRectForBounds_(bounds: CGRect): CGRect;"),
            "required member declared with the POD it imports:\n{out}"
        );
        assert!(
            out.contains("  insetsForBounds_?(bounds: CGRect): NSEdgeInsets;"),
            "optional member too:\n{out}"
        );
    }

    #[test]
    fn required_and_optional_members_render_with_the_optional_marker() {
        // The ADR-0055 §4 headline: @required → `name(): T;`, @optional → `name?(): T;`.
        let p = proto(
            "TKRefreshing",
            vec![],
            vec![m("refresh", vec![], TypeRef::void())],
            vec![m(
                "refreshInterval",
                vec![],
                ty(TypeRefKind::Primitive {
                    name: "NSInteger".into(),
                }),
            )],
        );
        let out = render_ts(&[p], "TestKit");
        assert!(out.contains("export interface TKRefreshing {"), "{out}");
        assert!(
            out.contains("  refresh(): void;"),
            "required member:\n{out}"
        );
        assert!(
            out.contains("  refreshInterval?(): number;"),
            "optional member gains the `?`:\n{out}"
        );
        // A real `interface`, never a `class` (type-only, no runtime).
        assert!(!out.contains("export class"), "{out}");
    }

    #[test]
    fn same_framework_inheritance_becomes_extends_no_import() {
        // A protocol inheriting a same-framework emittable protocol keeps `extends` — the
        // base is declared in this very file, so no import is needed.
        let base = proto(
            "TKRefreshing",
            vec![],
            vec![m("refresh", vec![], TypeRef::void())],
            vec![],
        );
        let derived = proto(
            "TKButtonDelegate",
            vec!["TKRefreshing"],
            vec![m("didClick", vec![], TypeRef::void())],
            vec![],
        );
        let out = render_ts(&[base, derived], "TestKit");
        assert!(
            out.contains("export interface TKButtonDelegate extends TKRefreshing {"),
            "same-fw inherited protocol → extends:\n{out}"
        );
        // No import block — the base is in-file.
        assert!(
            !out.contains("import {"),
            "no import for same-fw extends:\n{out}"
        );
    }

    #[test]
    fn unrecognised_cross_framework_inherited_protocol_is_dropped() {
        // An unconfigured emitter (empty protocol registry): inheriting a protocol neither
        // defined in this framework nor registry-owned (e.g. the `<NSObject>` protocol) is
        // dropped from `extends` — keeping it would dangle. The interface stays valid TS,
        // missing only those inherited members (the blessed degradation).
        let p = proto(
            "TKButtonDelegate",
            vec!["NSObject", "NSCopying"],
            vec![m("didClick", vec![], TypeRef::void())],
            vec![],
        );
        let out = render_ts(&[p], "TestKit");
        assert!(
            out.contains("export interface TKButtonDelegate {"),
            "unrecognised cross-fw inherited protocols dropped from extends:\n{out}"
        );
        // No `extends` on the interface declaration itself (the banner mentions the word).
        assert!(
            !out.contains("interface TKButtonDelegate extends"),
            "no dangling extends on the interface:\n{out}"
        );
    }

    #[test]
    fn cross_framework_inherited_protocol_resolves_via_registry_and_imports_type_only() {
        // The k27 close: a populated protocol registry (the CLI pre-pass shape) — NSCopying
        // owned by Foundation — lets a cross-framework inherited protocol join `extends`,
        // imported **type-only** (an interface `extends` is erased). A same-framework base
        // (TKRefreshing) stays in-file (no import); an unrecognised one (NSObject marker) is
        // still dropped.
        let base = proto(
            "TKRefreshing",
            vec![],
            vec![m("refresh", vec![], TypeRef::void())],
            vec![],
        );
        let derived = proto(
            "TKButtonDelegate",
            vec!["TKRefreshing", "NSCopying", "NSObject"],
            vec![m("didClick", vec![], TypeRef::void())],
            vec![],
        );
        let mut proto_reg = ProtocolRegistry::new();
        proto_reg.insert("NSCopying", "foundation");
        let out = render_ts_full(&[base, derived], "TestKit", &[], &proto_reg);
        // Same-fw + cross-fw bases both join `extends`, in `inherits` order; the unrecognised
        // NSObject is dropped.
        assert!(
            out.contains("export interface TKButtonDelegate extends TKRefreshing, NSCopying {"),
            "cross-fw base resolves and joins extends (unknown dropped):\n{out}"
        );
        // The cross-fw base imports type-only from its owner; the same-fw base needs none.
        assert!(
            out.contains("import type {\n  NSCopying,\n} from '@apianyware/foundation';"),
            "cross-fw base imported type-only from its owner:\n{out}"
        );
        assert!(
            !out.contains("TKRefreshing,\n} from"),
            "same-fw base is in-file, not imported:\n{out}"
        );
    }

    #[test]
    fn class_typed_member_params_and_returns_import_from_owning_module() {
        // A member param typed `id` (→ NSObject, runtime) and a return typed NSString
        // (owned by Foundation) route through the resolver to their owning modules — the
        // same import grouping the class emitters use.
        let p = proto(
            "TKButtonDelegate",
            vec![],
            vec![m(
                "titleForButton:",
                vec![param(
                    "button",
                    ty(TypeRefKind::Id {
                        protocols: Vec::new(),
                    }),
                )],
                nullable(TypeRefKind::Class {
                    name: "NSString".into(),
                    framework: None,
                    params: vec![],
                }),
            )],
            vec![],
        );
        let mut reg = ClassRegistry::new();
        reg.insert("NSString", "foundation");
        let enum_reg = EnumRegistry::new();
        let enum_resolver = EnumModuleResolver::new("AppKit", &enum_reg, Arc::default());
        let proto_reg = ProtocolRegistry::new();
        let protocol_resolver = ProtocolModuleResolver::new("AppKit", &proto_reg, Arc::default());
        let out = render_protocols_module(
            &[p],
            "AppKit",
            &ClassModuleResolver::new("AppKit", &reg, Arc::new(reg.names())),
            &enum_resolver,
            &protocol_resolver,
        );
        assert!(
            out.contains("import {\n  NSString,\n} from '@apianyware/foundation';"),
            "cross-fw class return imports from its owning module:\n{out}"
        );
        assert!(
            out.contains("import {\n  NSObject,\n} from '@apianyware/runtime';"),
            "an id param imports the runtime NSObject:\n{out}"
        );
        assert!(
            out.contains("titleForButton_(button: NSObject): NSString | null;"),
            "member signature reuses the shared param/return rendering:\n{out}"
        );
    }

    #[test]
    fn objc_exposed_false_and_class_methods_are_excluded() {
        // A Swift-native (`objc_exposed == false`) requirement and a `+` class requirement
        // both defer — neither belongs on a TS instance interface.
        let mut native = m(
            "nativeRequirement",
            vec![],
            ty(TypeRefKind::Id {
                protocols: Vec::new(),
            }),
        );
        native.objc_exposed = false;
        let mut classy = m(
            "sharedThing",
            vec![],
            ty(TypeRefKind::Id {
                protocols: Vec::new(),
            }),
        );
        classy.class_method = true;
        let p = proto(
            "TKMixed",
            vec![],
            vec![native, classy, m("realOne", vec![], TypeRef::void())],
            vec![],
        );
        let out = render_ts(&[p], "TestKit");
        assert!(out.contains("  realOne(): void;"), "{out}");
        assert!(
            !out.contains("nativeRequirement"),
            "swift-native excluded:\n{out}"
        );
        assert!(
            !out.contains("sharedThing"),
            "class requirement excluded:\n{out}"
        );
    }

    #[test]
    fn empty_marker_and_non_identifier_protocols_are_skipped() {
        // A protocol with no bindable surface (pure marker) is not emittable; a synthetic
        // libclang name is not a valid TS identifier and is skipped.
        let marker = proto("NSObjectMarker", vec![], vec![], vec![]);
        let mapper = &TsFfiTypeMapper::new();
        assert!(!has_surface(&marker, mapper));
        assert!(!is_emittable_protocol(&marker, mapper));

        let mut anon = proto(
            "real",
            vec![],
            vec![m("go", vec![], TypeRef::void())],
            vec![],
        );
        anon.name = "(anonymous at Foo.h:1:1)".into();
        assert!(
            !is_emittable_protocol(&anon, mapper),
            "non-identifier name skipped"
        );

        let good = proto(
            "TKGood",
            vec![],
            vec![m("go", vec![], TypeRef::void())],
            vec![],
        );
        assert_eq!(emitted_protocol_count(&[marker, anon, good], mapper), 1);
    }

    #[test]
    fn all_swift_native_protocol_has_no_surface() {
        let mut native = m(
            "nativeOnly",
            vec![],
            ty(TypeRefKind::Id {
                protocols: Vec::new(),
            }),
        );
        native.objc_exposed = false;
        let p = proto("TKAllNative", vec![], vec![native], vec![]);
        assert!(!has_surface(&p, &TsFfiTypeMapper::new()));
        assert_eq!(emitted_protocol_count(&[p], &TsFfiTypeMapper::new()), 0);
    }

    #[test]
    fn a_protocol_with_no_own_surface_but_a_bindable_ancestor_still_emits_transitively() {
        // transitive-protocol-emittability-k106 / ADR-0055 §4b: the real-corpus shape is
        // `NSMachPortDelegate` — its sole member takes an unsupported raw pointer (no bindable
        // surface of its own), but it inherits the fully-bindable `NSPortDelegate` — so it
        // still emits, as an empty-bodied interface `extends`ing the ancestor, rather than
        // being skipped as an (apparent) empty marker.
        let ancestor = proto(
            "TKPortDelegate",
            vec![],
            vec![m("handleMessage", vec![], TypeRef::void())],
            vec![],
        );
        let derived = proto(
            "TKMachPortDelegate",
            vec!["TKPortDelegate"],
            vec![m(
                "handleRawMessage:",
                vec![param("msg", ty(TypeRefKind::Pointer))],
                TypeRef::void(),
            )],
            vec![],
        );
        let mapper = TsFfiTypeMapper::new();
        assert!(
            !has_surface(&derived, &mapper),
            "own member takes a raw pointer — no surface of its own"
        );
        let emittable = transitively_emittable_protocols([&ancestor, &derived], &mapper);
        assert!(
            emittable.contains("TKMachPortDelegate"),
            "reaches a bindable surface transitively via its ancestor: {emittable:?}"
        );

        let out = render_ts(&[ancestor, derived], "TestKit");
        assert!(
            out.contains("export interface TKMachPortDelegate extends TKPortDelegate {\n}"),
            "no own surface, but a bindable ancestor still emits an (empty-bodied) interface:\n{out}"
        );
        // The raw-pointer-taking member itself never renders — it has no bindable surface.
        assert!(!out.contains("handleRawMessage"), "{out}");
    }

    #[test]
    fn a_protocol_with_no_own_surface_but_a_cross_framework_bindable_ancestor_still_emits() {
        // typecheck-gate-post-k86-residuals-k110 / the k106 scope limit, now a confirmed real-corpus
        // shape: `CNKeyDescriptor` (Contacts) has zero own members but `<NSObject, NSSecureCoding,
        // NSCopying>` — its only bindable ancestor, `NSSecureCoding`, is owned by **Foundation**, a
        // different framework. A per-framework render call's `by_name` only ever carries its OWN
        // framework's protocols, so `NSSecureCoding` is invisible to a purely local walk — the gap
        // [`reaches_bindable_surface`]'s mapper fallback closes.
        let derived = proto(
            "TKKeyDescriptor",
            vec!["TKSecureCoding"],
            vec![], // zero own members, exactly like CNKeyDescriptor
            vec![],
        );
        // `TKSecureCoding` is NOT passed to `render_ts_known`'s `protocols` — it lives in a
        // different framework, so it never enters this call's `by_name`. Only the mapper's
        // recognition set (the pre-k110 gap) can carry it — seeded here exactly as
        // `crate::emit_framework` seeds `known_protocols` from `ProtocolRegistry::names()`.
        let mut proto_reg = ProtocolRegistry::new();
        proto_reg.insert("TKSecureCoding", "otherkit");
        let out = render_ts_known(
            &[derived],
            "TestKit",
            &[],
            &proto_reg,
            &["TKKeyDescriptor", "TKSecureCoding"],
            &[],
        );
        assert!(
            out.contains("export interface TKKeyDescriptor extends TKSecureCoding {\n}"),
            "no own surface, but a cross-framework bindable ancestor still emits an \
             (empty-bodied) interface:\n{out}"
        );
        assert!(
            out.contains("import type {\n  TKSecureCoding,\n} from '@apianyware/otherkit';"),
            "the cross-framework ancestor imports type-only from its real owner:\n{out}"
        );
    }

    #[test]
    fn a_protocol_whose_whole_inherits_chain_has_no_surface_stays_unemittable() {
        // The negative control: an `inherits` edge alone proves nothing — the ancestor must
        // itself (transitively) reach a real surface, or the chain stays a marker shell.
        let mut raw_only = m(
            "handleRaw",
            vec![param("msg", ty(TypeRefKind::Pointer))],
            TypeRef::void(),
        );
        raw_only.objc_exposed = true;
        let root_marker = proto("TKMarkerRoot", vec![], vec![], vec![]);
        let derived = proto("TKMarkerLeaf", vec!["TKMarkerRoot"], vec![raw_only], vec![]);
        let mapper = TsFfiTypeMapper::new();
        let emittable = transitively_emittable_protocols([&root_marker, &derived], &mapper);
        assert!(emittable.is_empty(), "{emittable:?}");
        assert_eq!(emitted_protocol_count(&[root_marker, derived], &mapper), 0);
    }

    #[test]
    fn multiple_protocols_blank_line_separated_in_ir_order() {
        let a = proto(
            "TKAlpha",
            vec![],
            vec![m("a", vec![], TypeRef::void())],
            vec![],
        );
        let b = proto(
            "TKBeta",
            vec![],
            vec![m("b", vec![], TypeRef::void())],
            vec![],
        );
        let out = render_ts(&[a, b], "TestKit");
        let first = out.find("export interface TKAlpha {").expect("alpha");
        let second = out.find("export interface TKBeta {").expect("beta");
        assert!(first < second, "IR order preserved:\n{out}");
        assert!(
            out.contains("}\n\nexport interface TKBeta {"),
            "blank-separated:\n{out}"
        );
    }

    #[test]
    fn ts_and_dts_bodies_are_identical() {
        // The ADR-0055 §2 non-drift invariant for protocols, made observable: an interface
        // is type-only, so both artifacts concatenate the SAME body onto their banner.
        let base = proto(
            "TKRefreshing",
            vec![],
            vec![m("refresh", vec![], TypeRef::void())],
            vec![],
        );
        let derived = proto(
            "TKButtonDelegate",
            vec!["TKRefreshing"],
            vec![m(
                "titleFor:",
                vec![param("b", class_ty("NSString"))],
                nullable(TypeRefKind::Class {
                    name: "NSString".into(),
                    framework: None,
                    params: vec![],
                }),
            )],
            vec![],
        );
        let mut reg = ClassRegistry::new();
        reg.insert("NSString", "foundation");
        let resolver = ClassModuleResolver::new("TestKit", &reg, Arc::new(reg.names()));
        let enum_reg = EnumRegistry::new();
        let enum_resolver = EnumModuleResolver::new("TestKit", &enum_reg, Arc::default());
        let proto_reg = ProtocolRegistry::new();
        let protocol_resolver = ProtocolModuleResolver::new("TestKit", &proto_reg, Arc::default());
        let protocols = [base, derived];
        let body =
            render_protocol_bodies(&protocols, &resolver, &enum_resolver, &protocol_resolver);
        assert!(!body.is_empty());
        let ts = render_protocols_module(
            &protocols,
            "TestKit",
            &resolver,
            &enum_resolver,
            &protocol_resolver,
        );
        let dts = render_protocols_dts(
            &protocols,
            "TestKit",
            &resolver,
            &enum_resolver,
            &protocol_resolver,
        );
        assert!(ts.ends_with(&body), "the .ts body:\n{ts}");
        assert!(dts.ends_with(&body), "the .d.ts body:\n{dts}");
        // The banners genuinely differ.
        assert!(ts.contains("// Protocols: TestKit"));
        assert!(dts.contains("// Type surface: protocols (TestKit)"));
        // The .d.ts uses the no-`declare` style (ambient-implicit in a declaration file).
        assert!(!dts.contains("declare"), "{dts}");
    }

    #[test]
    fn empty_protocol_list_renders_no_body() {
        let reg = ClassRegistry::new();
        let resolver = ClassModuleResolver::new("TestKit", &reg, Arc::new(reg.names()));
        let enum_reg = EnumRegistry::new();
        let enum_resolver = EnumModuleResolver::new("TestKit", &enum_reg, Arc::default());
        let proto_reg = ProtocolRegistry::new();
        let protocol_resolver = ProtocolModuleResolver::new("TestKit", &proto_reg, Arc::default());
        assert_eq!(
            render_protocol_bodies(&[], &resolver, &enum_resolver, &protocol_resolver),
            ""
        );
        assert_eq!(emitted_protocol_count(&[], &TsFfiTypeMapper::new()), 0);
        let out = render_protocols_module(
            &[],
            "TestKit",
            &resolver,
            &enum_resolver,
            &protocol_resolver,
        );
        assert!(out.contains("// Protocols: TestKit"));
        assert!(!out.contains("export interface"));
    }

    #[test]
    fn instancetype_member_return_is_this() {
        // A protocol member returning `instancetype` (e.g. NSCopying's copy) → the
        // polymorphic `this` (the mapper's declaration-surface reading), no concrete class.
        let p = proto(
            "TKCopying",
            vec![],
            vec![m("copy", vec![], ty(TypeRefKind::Instancetype))],
            vec![],
        );
        let out = render_ts(&[p], "TestKit");
        assert!(
            out.contains("  copy(): this;"),
            "instancetype → this:\n{out}"
        );
    }

    #[test]
    fn proven_enum_member_types_the_interface_and_imports_type_only() {
        // A protocol member param/return typed by a proven NS_ENUM alias renders as the enum
        // type name and imports type-only from the framework barrel (enum-alias-typing).
        let enum_alias = ty(TypeRefKind::Alias {
            name: "TKAlignment".into(),
            framework: None,
            underlying_primitive: Some("int64".into()),
        });
        let p = proto(
            "TKAligning",
            vec![],
            vec![m(
                "setAlignment:",
                vec![param("alignment", enum_alias.clone())],
                TypeRef::void(),
            )],
            vec![m("alignment", vec![], enum_alias)],
        );
        let out = render_ts_with_enums(&[p], "TestKit", &["TKAlignment"]);
        assert!(
            out.contains("  setAlignment_(alignment: TKAlignment): void;"),
            "enum param types the member:\n{out}"
        );
        assert!(
            out.contains("  alignment?(): TKAlignment;"),
            "enum return types the optional member:\n{out}"
        );
        assert!(
            out.contains("import type {\n  TKAlignment,\n} from '@apianyware/testkit';"),
            "enum imported type-only from its owning barrel:\n{out}"
        );
    }
}
