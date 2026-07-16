//! The emitted **per-protocol `DelegateSpec`** — `delegates.ts` (ADR-0059 §3/§8,
//! `emitted-delegate-spec-k84`), and the per-slot facts a bound `id<P>` call site needs to use one.
//!
//! ADR-0055 §4b types every `id<P>` slot by its interface, and a bound **param** is deliberately the
//! *bare* interface, so a plain JS object literal satisfies it. Until this module, nothing turned
//! that literal into anything ObjC could send to: the emitted body only `__unwrap`ped, and the
//! runtime's `DelegateSpec`/forwarder machinery ([`inbound-value-kinds-k79`], k38) was reachable only
//! from hand-written tests. This module closes it — the emitter derives one spec per protocol from
//! the IR, and every bound param routes through `__protocolArg`.
//!
//! ## What a spec is, and what it is *not*
//!
//! A spec is **per protocol**: its identity (the forwarder-class memo key), its ordered method list
//! (selector + ObjC type encoding — a method's *position is its responds-bit index*), and its inbound
//! value surface (ADR-0059 §8 — one arg kind per param, one return kind, per selector).
//!
//! It carries **no setter, no property key and no associate flag**. Those describe a *slot*, and one
//! protocol types many slots — so the call site passes them. That split is what let k84 cover all
//! **122** bound param sites rather than only the 73 that happen to be one-arg setters (the shape the
//! k38 `bindDelegate` compound op fitted): see [`crate::emit_class`] for the three call-site shapes
//! (instance / static / `init…`) and `delegate.ts` for the one keep-alive rule they share.
//!
//! ## One decision, N readers — again
//!
//! Every fact here is read from a predicate that already exists, never re-derived:
//!
//! - **which protocols bind** — [`crate::protocol_binding`] (k89). A spec is emitted for exactly the
//!   protocols whose *interfaces* are emitted, so `ProtocolBinding::Bound` ⟺ `SPEC_<P>` exists. A
//!   second recognition set here would let a call site name a spec no module exports.
//! - **which of a protocol's methods a forwarder can install** — [`InboundSig`] (k61). The IMP table
//!   is generated from that same signature model over that same [`bound_protocol_methods`] frontier,
//!   so an encoding in a spec's `methods` **has** a trampoline by construction. A member outside the
//!   inbound alphabet (a geometry struct, a C string) is *omitted and counted*, never emitted as an
//!   encoding the native side would silently refuse to install.
//! - **the value kinds** — [`PtrValue`] (k72) and [`method_retain_axis`] (k70), the very predicates the
//!   outbound call sites and the dispatch table read. A `SEL` arg is a `string` inbound exactly as it
//!   is outbound; a returned object follows the same three-state retain axis.
//!
//! ## Why the module imports nothing but the runtime
//!
//! An `obj` arg kind carries **no class** — ADR-0059 §8 reconciled in place, because
//! [`dynamic-class-wrap-k88`] made the class-less wrap climb to the nearest bound ancestor (see
//! `marshal.ts`). So a spec is strings and constants: `delegates.ts` value-imports only
//! `@apianyware/runtime`, and therefore forms **no** edge into a class module. Had it carried
//! `OBJ(NSNotification)`, a same-framework protocol/class pair would have been an ES-module cycle
//! whose spec `const` initializes in the TDZ of a class not yet defined — a load-order landmine under
//! every barrel.

use std::collections::{BTreeSet, HashSet};
use std::sync::Arc;

use apianyware_emit::code_writer::CodeWriter;
use apianyware_emit::enrichment::class_retaining_params;
use apianyware_emit::ffi_type_mapping::FfiTypeMapper;
use apianyware_emit::write_line;
use apianyware_types::ir::{Framework, Method, Protocol};
use apianyware_types::type_ref::TypeRef;

use crate::class_graph::declared_classes;
use crate::class_surface::bound_methods;
use crate::emit_class::method_retain_axis;
use crate::emit_protocol::{bound_protocol_methods, transitively_emittable_protocols};
use crate::ffi_type_mapping::TsFfiTypeMapper;
use crate::inbound_table::InboundSig;
use crate::method_filter::is_error_out_method;
use crate::naming::module_specifier;
use crate::native_dispatch::RetainAxis;
use crate::protocol_binding::bound_protocols;
use crate::protocol_graph::ProtocolRegistry;
use crate::ptr_value::PtrValue;

/// The `.ts`/`.d.ts` module stem the specs live in — reserved against class file stems
/// ([`crate::naming::RESERVED_MODULE_STEMS`]).
pub const DELEGATES_STEM: &str = "delegates";

/// The exported symbol naming protocol `P`'s spec: `SPEC_<P>`. A protocol name is already a valid TS
/// identifier ([`transitively_emittable_protocols`] guarantees it), so the prefix is all that is
/// needed — and `SPEC_` cannot collide with a class, an enum or an interface, none of which the
/// emitter ever names with it.
pub fn spec_symbol(protocol: &str) -> String {
    format!("SPEC_{protocol}")
}

/// The inbound value kind of one **argument** (ADR-0059 §8), rendered as the `marshal.ts` constant.
/// Read off the *same* [`PtrValue`] / `is_object_type` split the outbound param arm uses
/// ([`crate::emit_class::emit_body`]), so a `SEL` that crosses out as a `string` crosses back in as
/// one.
pub(crate) fn arg_kind(t: &TypeRef, mapper: &TsFfiTypeMapper) -> &'static str {
    match PtrValue::of(t) {
        Some(PtrValue::Selector) => "SEL",
        Some(PtrValue::ClassRef) => "CLS",
        None if mapper.is_object_type(t) => "OBJ",
        None => "RAW",
    }
}

/// The inbound value kind of a **return** (ADR-0059 §8), rendered as the `marshal.ts` expression. The
/// object arms carry the ADR-0057 §4 retain axis — the *same* [`method_retain_axis`] the outbound
/// table, the emitted call sites and the `$super` entries read: a `+0`-convention selector hands back
/// `objc_retainAutorelease`, a `+1`-convention one (an overridden `copyWithZone:`/`init` reached
/// inbound) `objc_retain`, and a `SEL`/`Class` neither.
pub(crate) fn ret_kind(m: &Method, mapper: &TsFfiTypeMapper) -> &'static str {
    match PtrValue::of(&m.return_type) {
        Some(PtrValue::Selector) => "SEL",
        Some(PtrValue::ClassRef) => "CLS",
        None => match method_retain_axis(m, mapper) {
            Some(RetainAxis::Owned) => "RET_OBJ('owned')",
            Some(RetainAxis::FoldRetain) => "RET_OBJ()",
            Some(RetainAxis::NoWrap) | None => "RET_RAW",
        },
    }
}

/// One method of an emitted spec: the raw selector, the ObjC type encoding that content-addresses its
/// inbound trampoline, and its value surface.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct SpecMethod {
    pub selector: String,
    pub encoding: String,
    /// One kind per C-ABI argument — **all** of `Method::params`, since that is what the trampoline
    /// delivers (a fallible member's trailing `NSError**` cell is a plain pointer arg at the IMP ABI,
    /// exactly as [`InboundSig::from_method`] treats it).
    pub args: Vec<&'static str>,
    pub ret: &'static str,
}

/// A protocol member the forwarder **cannot** install — its signature falls outside the inbound
/// alphabet (a geometry struct, a C string). Omitted from the spec and counted, never emitted as an
/// encoding the native side would refuse: `respondsToSelector:` then answers NO for it, so a JS
/// delegate may declare it and it simply never fires (an `@optional` member's normal fate; a
/// `@required` one would `doesNotRecognizeSelector:` if ObjC ever sent it).
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct DeferredSpecMethod {
    pub protocol: String,
    pub selector: String,
}

/// Derive protocol `proto`'s spec methods, in the [`bound_protocol_methods`] order the interface
/// declares them (so a method's index **is** its responds-bit index), plus the members that defer.
pub fn spec_methods(
    proto: &Protocol,
    mapper: &TsFfiTypeMapper,
) -> (Vec<SpecMethod>, Vec<DeferredSpecMethod>) {
    let mut methods = Vec::new();
    let mut deferred = Vec::new();
    for m in bound_protocol_methods(proto, mapper) {
        let Some(sig) = InboundSig::from_method(m) else {
            deferred.push(DeferredSpecMethod {
                protocol: proto.name.clone(),
                selector: m.selector.clone(),
            });
            continue;
        };
        methods.push(SpecMethod {
            selector: m.selector.clone(),
            encoding: sig.type_encoding(),
            args: m
                .params
                .iter()
                .map(|p| arg_kind(&p.param_type, mapper))
                .collect(),
            ret: ret_kind(m, mapper),
        });
    }
    (methods, deferred)
}

/// The protocols this framework emits a spec for — **exactly** the ones it emits an `interface` for
/// ([`transitively_emittable_protocols`]). Keeping the two sets identical is what makes
/// `ProtocolBinding::Bound` ⟺ "`SPEC_<P>` is exported": a call site can never name a spec that does
/// not exist, and no bound slot is left with a type that admits a literal it cannot bridge.
///
/// A protocol every one of whose members defers still gets a spec (with an empty `methods`): its
/// forwarder is a real conforming object that responds to nothing — which is the honest surface, and
/// strictly better than degrading the slot's *type* and losing the wrapped-object path with it. A
/// protocol emittable only via an inherited ancestor's surface (k106) is no different: its own
/// members still all defer (or there are none), so it too gets an empty-`methods` spec.
pub fn spec_protocols<'p>(
    protocols: &'p [Protocol],
    mapper: &TsFfiTypeMapper,
) -> Vec<&'p Protocol> {
    let emittable = transitively_emittable_protocols(protocols.iter(), mapper);
    protocols
        .iter()
        .filter(|p| emittable.contains(&p.name))
        .collect()
}

/// The number of specs this framework emits — drives the orchestrator's write decision and the
/// barrel re-export, off the one predicate [`spec_protocols`] uses.
pub fn emitted_spec_count(protocols: &[Protocol], mapper: &TsFfiTypeMapper) -> usize {
    spec_protocols(protocols, mapper).len()
}

/// The bound protocol a **slot** (a param's type) names, or `None` when it names none.
///
/// A slot binding *two* protocols has no single forwarder class to build — a forwarder conforms to
/// one ObjC `Protocol` — so it is **deferred** (`None`, counted by the caller) rather than guessed at.
/// The corpus has zero such params today; the deferral is what keeps that a measured fact rather than
/// an assumption baked into a body.
pub fn slot_protocol<'t>(t: &'t TypeRef, mapper: &TsFfiTypeMapper) -> Option<&'t str> {
    match bound_protocols(t, mapper).as_slice() {
        [one] => Some(one),
        _ => None,
    }
}

// --- the per-slot facts a call site needs ------------------------------------------------------

/// One bound `id<P>` **slot** on a class method — everything the emitted body needs beyond the spec
/// itself (module doc: a spec is per *protocol*; these are per *slot*).
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct BoundSlot {
    /// The parameter's index in the method's C-ABI argument list.
    pub index: usize,
    /// The protocol whose `SPEC_<P>` bridges a JS literal reaching this slot.
    pub protocol: String,
    /// The association key, `<selector>#<index>` — unique per slot, stable across regeneration, and
    /// for a property setter exactly the "per delegate-property" key ADR-0059 §6 asks for. Re-setting
    /// the slot releases the forwarder previously held under it, so a hot call site holds at most one.
    pub key: String,
    /// Install the ADR-0059 §6 keep-alive association? The **resolved three-state ownership** decides
    /// (`class_retaining_params`, k82): a declared-retaining slot is held by the framework already, so
    /// skip; `weak`/`assign` and an *absent* qualifier both associate (§6's default arm — over-holding
    /// a retaining slot merely over-retains, under-holding a non-retaining one dangles).
    pub associate: bool,
}

/// Whether a method's bound slots are owned by the object it **returns** rather than by its receiver —
/// i.e. whether it is an initializer. `[[NSFilePromiseProvider alloc] initWithFileType:delegate:]`
/// stores its delegate on the object `init` hands back, and ObjC permits that to be a *different*
/// object than `alloc` produced, so the owner genuinely does not exist until the call returns.
///
/// Reads the same `init` family test the +1 retain axis does ([`method_returns_retained`]), plus the
/// IR's own `init_method` flag — one fact, not two derivations of it.
pub fn is_initializer(m: &Method) -> bool {
    !m.class_method && (m.init_method || crate::emit_class::is_init_family(&m.selector))
}

/// The bound `id<P>` slots of one class method, in parameter order. `retaining` is the class's
/// declared-retaining `(selector, param_index)` set
/// ([`apianyware_emit::enrichment::class_retaining_params`]).
///
/// A param whose qualifier does not resolve to exactly one bound protocol carries no slot — an
/// unqualified `id`, a qualifier every name of which degrades (`protocol_binding`, so the slot is
/// typed `NSObject` and admits no literal anyway), or a multi-protocol qualifier
/// ([`slot_protocol`], deferred and counted).
pub fn bound_slots(
    m: &Method,
    mapper: &TsFfiTypeMapper,
    retaining: &HashSet<(String, usize)>,
) -> Vec<BoundSlot> {
    m.params
        .iter()
        .enumerate()
        .filter_map(|(i, p)| {
            let protocol = slot_protocol(&p.param_type, mapper)?;
            Some(BoundSlot {
                index: i,
                protocol: protocol.to_string(),
                key: format!("{}#{i}", m.selector),
                associate: !retaining.contains(&(m.selector.clone(), i)),
            })
        })
        .collect()
}

/// The protocols whose specs a class's emitted bodies name — the value-import set
/// ([`crate::imports::protocol_spec_imports`]). Exactly the protocols its bound slots bridge, so a
/// class that bridges none imports none.
pub fn referenced_spec_types(
    methods: &[&Method],
    mapper: &TsFfiTypeMapper,
    retaining: &HashSet<(String, usize)>,
) -> BTreeSet<String> {
    methods
        .iter()
        .flat_map(|m| bound_slots(m, mapper, retaining))
        .map(|s| s.protocol)
        .collect()
}

// --- the whole-corpus slot report ---------------------------------------------------------------

/// What the corpus's bound `id<P>` **slots** did — the pass-log dual of
/// [`crate::protocol_binding::DegradationReport`], so no bridge and no deferral is silent (k57).
#[derive(Debug, Clone, Default)]
pub struct SlotReport {
    /// Slots that bridge a JS literal through a spec.
    pub bridged: usize,
    /// …of which take the ADR-0059 §6 association (the rest are declared-retaining — the skip arm).
    pub associated: usize,
    /// …of which are owned by the initializer's **result** rather than its receiver.
    pub init_owned: usize,
    /// Params whose qualifier binds more than one protocol: a forwarder conforms to ONE ObjC
    /// `Protocol`, so there is no single class to synthesize. Named, never guessed at.
    pub multi_protocol: Vec<String>,
    /// **Fallible initializers** carrying a bound slot: the `Result<T>` body exposes no raw `__ret`
    /// handle to adopt the forwarder onto, so such a slot would fall back to associating on the
    /// *receiver* — right whenever `init` returns self, silently no-firing when it does not. Zero in
    /// the corpus; this count is what would say otherwise.
    pub fallible_init: Vec<String>,
    /// Protocol members with no installable inbound trampoline — omitted from their spec's `methods`,
    /// so `respondsToSelector:` answers NO and they never fire ([`DeferredSpecMethod`]).
    pub deferred_members: Vec<DeferredSpecMethod>,
}

impl SlotReport {
    /// `12 multi-protocol, 0 fallible-init, 340 members` — the pass-log rendering.
    pub fn summary(&self) -> String {
        format!(
            "{} multi-protocol, {} fallible-init, {} un-installable members",
            self.multi_protocol.len(),
            self.fallible_init.len(),
            self.deferred_members.len()
        )
    }
}

/// Walk every class method and protocol member in the corpus and count what the slot machinery did.
/// Builds its recognition sets the **one** way the emitters do, so the report cannot disagree with the
/// surface it describes.
pub fn slot_report(
    frameworks: &[&Framework],
    protocol_registry: &ProtocolRegistry,
    error_selectors_for: impl Fn(&Framework, &str) -> HashSet<String>,
) -> SlotReport {
    let mapper = TsFfiTypeMapper::with_known(
        Arc::default(),
        declared_classes(frameworks.iter().copied()),
        Arc::new(protocol_registry.names()),
    );
    let mut report = SlotReport::default();
    for fw in frameworks {
        for cls in &fw.classes {
            let retaining = class_retaining_params(&fw.class_annotations, &cls.name);
            let errors = error_selectors_for(fw, &cls.name);
            let (statics, instances) = bound_methods(cls, &mapper, &errors, protocol_registry);
            for m in statics.iter().chain(instances.iter()) {
                for p in &m.params {
                    if bound_protocols(&p.param_type, &mapper).len() > 1 {
                        report
                            .multi_protocol
                            .push(format!("{}.{}", cls.name, m.selector));
                    }
                }
                let slots = bound_slots(m, &mapper, &retaining);
                if slots.is_empty() {
                    continue;
                }
                let initializer = is_initializer(m);
                if initializer && is_error_out_method(m, &errors) {
                    report
                        .fallible_init
                        .push(format!("{}.{}", cls.name, m.selector));
                }
                report.bridged += slots.len();
                report.associated += slots.iter().filter(|s| s.associate).count();
                if initializer {
                    report.init_owned += slots.len();
                }
            }
        }
        for proto in spec_protocols(&fw.protocols, &mapper) {
            let (_, deferred) = spec_methods(proto, &mapper);
            report.deferred_members.extend(deferred);
        }
    }
    report
}

/// Render `delegates.ts` — the framework's per-protocol specs. Its **only** import is the runtime
/// (module doc), so it never participates in a barrel cycle.
pub fn render_delegates_module(
    protocols: &[Protocol],
    framework: &str,
    mapper: &TsFfiTypeMapper,
) -> String {
    let specs = spec_protocols(protocols, mapper);
    let mut w = CodeWriter::new();
    w.line("// Generated by apianyware emit-typescript — DO NOT EDIT.");
    write_line!(
        w,
        "// Delegate specs: {framework} (module {})",
        module_specifier(framework)
    );
    w.line("//");
    w.line("// One `DelegateSpec` per emitted protocol (ADR-0059 §3/§8): the forwarder-class memo key,");
    w.line("// the installable methods (selector + ObjC type encoding; a method's POSITION is its");
    w.line(
        "// respondsToSelector: bit index), and the inbound value surface — one kind per argument,",
    );
    w.line(
        "// one for the return. A JS object literal reaching any `id<P>` slot is bridged through",
    );
    w.line("// the spec for P (`__protocolArg`, ADR-0055 §4b).");
    w.line("//");
    w.line("// A spec is per PROTOCOL, never per slot: the setter, the association key and the");
    w.line(
        "// associate/skip arm describe a *slot*, and one protocol types many — so the call site",
    );
    w.line("// passes those. And an `obj` kind carries no class (ADR-0059 §8, reconciled by k88's");
    w.line("// dynamic wrap), which is why this module imports nothing but the runtime.");
    w.blank_line();
    render_spec_imports(&mut w, &specs, mapper);
    for (i, proto) in specs.iter().enumerate() {
        if i > 0 {
            w.blank_line();
        }
        render_one_spec(&mut w, proto, mapper);
    }
    w.finish()
}

/// Render the co-generated `delegates.d.ts` — the declaration surface of the same specs (ADR-0055 §2,
/// one pass drives both). Unlike `protocols.d.ts` the body is **not** identical to the `.ts`: a spec is
/// runtime *data*, so the `.ts` defines it and the `.d.ts` declares its type. That is precisely why
/// the specs are their own module rather than living in `protocols.ts`, whose byte-identical bodies
/// are a property worth keeping (ADR-0055 §4/§4b — a protocol reference is type-only, so it forms no
/// runtime edge and no barrel cycle; a `const` in there would have broken both).
pub fn render_delegates_dts(
    protocols: &[Protocol],
    framework: &str,
    mapper: &TsFfiTypeMapper,
) -> String {
    let specs = spec_protocols(protocols, mapper);
    let mut w = CodeWriter::new();
    w.line("// Generated by apianyware emit-typescript — DO NOT EDIT.");
    write_line!(w, "// Type surface: delegate specs ({framework})");
    w.line("//");
    w.line("// Declaration-only .d.ts, co-generated with delegates.ts from the same IR pass");
    w.line("// (ADR-0055 §2). A spec is runtime data, so — unlike protocols.d.ts — this declares");
    w.line("// what that module defines rather than repeating it.");
    w.blank_line();
    if !specs.is_empty() {
        w.line("import type { DelegateSpec } from '@apianyware/runtime';");
        w.blank_line();
        for proto in &specs {
            write_line!(
                w,
                "export declare const {}: DelegateSpec;",
                spec_symbol(&proto.name)
            );
        }
    }
    w.finish()
}

/// The runtime symbols the rendered specs actually use — the `DelegateSpec` type, the marshal builder,
/// and exactly the value kinds that appear. Computed from the rendered specs, not assumed, so the
/// import block and the bodies cannot drift (and `verbatimModuleSyntax` stays happy: no unused import).
fn render_spec_imports(w: &mut CodeWriter, specs: &[&Protocol], mapper: &TsFfiTypeMapper) {
    if specs.is_empty() {
        w.line("export {};");
        return;
    }
    let mut kinds: BTreeSet<&'static str> = BTreeSet::new();
    let mut has_marshal = false;
    for proto in specs {
        let (methods, _) = spec_methods(proto, mapper);
        has_marshal = has_marshal || !methods.is_empty();
        for m in &methods {
            kinds.extend(m.args.iter().copied());
            kinds.insert(if m.ret.starts_with("RET_OBJ") {
                "RET_OBJ"
            } else {
                m.ret
            });
        }
    }
    w.line("import {");
    w.line("  type DelegateSpec,");
    if has_marshal {
        w.line("  __methodMarshal,");
    }
    for k in &kinds {
        write_line!(w, "  {k},");
    }
    w.line("} from '@apianyware/runtime';");
    w.blank_line();
}

/// Render one `export const SPEC_<P>: DelegateSpec = { … }`.
fn render_one_spec(w: &mut CodeWriter, proto: &Protocol, mapper: &TsFfiTypeMapper) {
    let (methods, _) = spec_methods(proto, mapper);
    write_line!(
        w,
        "export const {}: DelegateSpec = {{",
        spec_symbol(&proto.name)
    );
    w.indent();
    write_line!(w, "protocol: '{}',", proto.name);
    if methods.is_empty() {
        // Every member's signature is outside the inbound alphabet (counted in the pass log). The
        // forwarder is still a real object conforming to the protocol — it just responds to nothing.
        w.line("methods: [],");
    } else {
        w.line("methods: [");
        w.indent();
        for m in &methods {
            write_line!(w, "['{}', '{}'],", m.selector, m.encoding);
        }
        w.dedent();
        w.line("],");
        w.line("marshal: __methodMarshal({");
        w.indent();
        for m in &methods {
            write_line!(
                w,
                "'{}': {{ args: [{}], ret: {} }},",
                m.selector,
                m.args.join(", "),
                m.ret
            );
        }
        w.dedent();
        w.line("}),");
    }
    w.dedent();
    w.line("};");
}

#[cfg(test)]
mod tests {
    use super::*;
    use apianyware_types::ir::{Param, Protocol};
    use apianyware_types::type_ref::{TypeRef, TypeRefKind};
    use std::sync::Arc;

    fn ty(kind: TypeRefKind) -> TypeRef {
        TypeRef {
            nullable: false,
            kind,
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

    fn p(name: &str, t: TypeRef) -> Param {
        Param {
            name: name.into(),
            param_type: t,
        }
    }

    fn proto(name: &str, required: Vec<Method>, optional: Vec<Method>) -> Protocol {
        Protocol {
            name: name.into(),
            inherits: vec![],
            required_methods: required,
            optional_methods: optional,
            properties: vec![],
            source: None,
            provenance: None,
            doc_refs: None,
            objc_exposed: true,
        }
    }

    fn mapper(classes: &[&str], protocols: &[&str]) -> TsFfiTypeMapper {
        TsFfiTypeMapper::with_known(
            Arc::default(),
            Arc::new(classes.iter().map(|s| s.to_string()).collect()),
            Arc::new(protocols.iter().map(|s| s.to_string()).collect()),
        )
    }

    fn obj(name: &str) -> TypeRef {
        ty(TypeRefKind::Class {
            name: name.into(),
            framework: None,
            params: vec![],
        })
    }

    #[test]
    fn a_spec_carries_the_encoding_the_imp_table_installs_and_the_kinds_the_seam_converts() {
        // THE MIRROR: the encoding is `InboundSig::type_encoding()` — the very string the generated
        // IMP map switches on (k61) — so a spec's method always HAS a trampoline. And the value kinds
        // come off the same PtrValue / retain-axis predicates the outbound bodies read (k70/k72), so
        // a SEL crosses back in as the `string` it crossed out as.
        let pr = proto(
            "TKSourcing",
            vec![m(
                "source:didLoad:",
                vec![
                    p("source", obj("TKSource")),
                    p(
                        "count",
                        ty(TypeRefKind::Primitive {
                            name: "NSInteger".into(),
                        }),
                    ),
                ],
                TypeRef::void(),
            )],
            vec![
                m(
                    "actionFor:",
                    vec![p("s", obj("TKSource"))],
                    ty(TypeRefKind::Selector),
                ),
                m(
                    "classFor:",
                    vec![p("s", obj("TKSource"))],
                    ty(TypeRefKind::ClassRef),
                ),
                m("copyOf:", vec![p("s", obj("TKSource"))], obj("TKSource")),
                m("makeThing", vec![], obj("TKSource")),
            ],
        );
        let mp = mapper(&["TKSource"], &["TKSourcing"]);
        let (methods, deferred) = spec_methods(&pr, &mp);
        assert!(deferred.is_empty());
        let by = |sel: &str| {
            methods
                .iter()
                .find(|s| s.selector == sel)
                .expect(sel)
                .clone()
        };

        let required = by("source:didLoad:");
        assert_eq!(required.encoding, "v@:@q");
        assert_eq!(required.args, vec!["OBJ", "RAW"]);
        assert_eq!(required.ret, "RET_RAW");

        assert_eq!(by("actionFor:").ret, "SEL");
        assert_eq!(by("classFor:").ret, "CLS");
        // `copyOf:` is the `copy` family → +1 owned; a plain object return is +0.
        assert_eq!(by("copyOf:").ret, "RET_OBJ('owned')");
        assert_eq!(by("makeThing").ret, "RET_OBJ()");

        // Order is the interface's own (required then optional) — a method's index IS its responds bit.
        assert_eq!(methods[0].selector, "source:didLoad:");
    }

    #[test]
    fn a_struct_param_member_is_admitted_a_struct_return_member_is_omitted_and_counted() {
        // DEFER NOTHING SILENTLY (k57). `inbound-struct-arg-surface-k123` widened
        // `InboundSig::from_method` to admit a struct-typed PARAMETER (the shared frontier every
        // reader here reads from — one decision, N readers) — a geometry-struct-typed RETURN
        // still has no installable trampoline, so emitting its encoding would hand the native
        // side a string it refuses, and the delegate would silently never fire. It alone is
        // dropped from `methods` and NAMED.
        let pr = proto(
            "TKLaying",
            vec![m("didLay", vec![], TypeRef::void())],
            vec![
                m(
                    "boundsFor:",
                    vec![p(
                        "r",
                        ty(TypeRefKind::Struct {
                            name: "CGRect".into(),
                        }),
                    )],
                    TypeRef::void(),
                ),
                m(
                    "frameForLaying",
                    vec![],
                    ty(TypeRefKind::Struct {
                        name: "CGRect".into(),
                    }),
                ),
            ],
        );
        let mp = mapper(&[], &["TKLaying"]);
        let (methods, deferred) = spec_methods(&pr, &mp);
        assert_eq!(methods.len(), 2);
        let selectors: Vec<&str> = methods.iter().map(|m| m.selector.as_str()).collect();
        assert!(selectors.contains(&"didLay"));
        assert!(selectors.contains(&"boundsFor:"));
        assert_eq!(deferred.len(), 1);
        assert_eq!(deferred[0].selector, "frameForLaying");
        assert_eq!(deferred[0].protocol, "TKLaying");
    }

    #[test]
    fn the_spec_set_is_the_interface_set() {
        // ProtocolBinding::Bound ⟺ SPEC_<P> exists. A second recognition set here would let a bound
        // slot name a spec no module exports — the corpus would stop compiling, or (worse) the slot
        // would keep a type that admits a literal it cannot bridge.
        let good = proto(
            "TKRefreshing",
            vec![m("refresh", vec![], TypeRef::void())],
            vec![],
        );
        let marker = proto("TKMarker", vec![], vec![]);
        let mp = mapper(&[], &["TKRefreshing", "TKMarker"]);
        let protocols = [good, marker];
        let names: Vec<&str> = spec_protocols(&protocols, &mp)
            .iter()
            .map(|p| p.name.as_str())
            .collect();
        assert_eq!(names, vec!["TKRefreshing"]);
        assert_eq!(emitted_spec_count(&protocols, &mp), 1);
    }

    #[test]
    fn a_slot_binding_two_protocols_defers_rather_than_guessing_a_forwarder() {
        // A forwarder conforms to ONE ObjC Protocol, so a slot naming two has no single class to
        // synthesize. Zero such params in the corpus — this keeps that a measured fact.
        let mp = mapper(&[], &["TKRefreshing", "TKSourcing"]);
        let one = ty(TypeRefKind::Id {
            protocols: vec!["TKRefreshing".into()],
        });
        let two = ty(TypeRefKind::Id {
            protocols: vec!["TKRefreshing".into(), "TKSourcing".into()],
        });
        let bare = ty(TypeRefKind::Id { protocols: vec![] });
        assert_eq!(slot_protocol(&one, &mp), Some("TKRefreshing"));
        assert_eq!(slot_protocol(&two, &mp), None);
        assert_eq!(slot_protocol(&bare, &mp), None);
        // A qualifier naming an unemittable protocol degrades in `protocol_binding` — so the slot is
        // typed NSObject and never routes here either. One predicate, both readers.
        let unknown = ty(TypeRefKind::Id {
            protocols: vec!["NSCopying".into()],
        });
        assert_eq!(slot_protocol(&unknown, &mp), None);
    }

    #[test]
    fn the_module_imports_only_the_runtime_and_only_the_kinds_it_renders() {
        // The whole reason the specs are their own module: no class import, so no barrel cycle and no
        // TDZ on the const (module doc). And the import block is computed from the rendered kinds, so
        // it can neither dangle nor go unused.
        let pr = proto(
            "TKSourcing",
            vec![m(
                "didLoad:",
                vec![p("s", obj("TKSource"))],
                TypeRef::void(),
            )],
            vec![],
        );
        let mp = mapper(&["TKSource"], &["TKSourcing"]);
        let out = render_delegates_module(&[pr], "TestKit", &mp);
        assert!(out.contains("} from '@apianyware/runtime';"), "{out}");
        // The whole point: the ONLY import is the runtime. `TKSource` is an argument's declared class,
        // and pre-k88 it would have had to be value-imported here — closing a cycle with its own
        // framework's barrel and putting this `const` in its TDZ.
        let imports: Vec<&str> = out
            .lines()
            .filter(|l| l.trim_start().starts_with("} from"))
            .collect();
        assert_eq!(imports, vec!["} from '@apianyware/runtime';"], "{out}");
        assert!(out.contains("  OBJ,"), "{out}");
        assert!(out.contains("  RET_RAW,"), "{out}");
        assert!(
            !out.contains("  SEL,"),
            "an unused kind is not imported:\n{out}"
        );
        assert!(
            out.contains("export const SPEC_TKSourcing: DelegateSpec = {"),
            "{out}"
        );
        assert!(out.contains("['didLoad:', 'v@:@'],"), "{out}");
        assert!(
            out.contains("'didLoad:': { args: [OBJ], ret: RET_RAW },"),
            "{out}"
        );
    }

    #[test]
    fn the_dts_declares_what_the_ts_defines() {
        let pr = proto(
            "TKRefreshing",
            vec![m("refresh", vec![], TypeRef::void())],
            vec![],
        );
        let mp = mapper(&[], &["TKRefreshing"]);
        let dts = render_delegates_dts(&[pr], "TestKit", &mp);
        assert!(dts.contains("import type { DelegateSpec } from '@apianyware/runtime';"));
        assert!(dts.contains("export declare const SPEC_TKRefreshing: DelegateSpec;"));
        assert!(
            !dts.contains("__methodMarshal"),
            "no bodies in a .d.ts:\n{dts}"
        );
    }

    #[test]
    fn a_framework_with_no_emittable_protocol_renders_a_valid_empty_module() {
        let mp = mapper(&[], &[]);
        let out = render_delegates_module(&[], "TestKit", &mp);
        assert!(out.contains("export {};"), "still an ES module:\n{out}");
        assert_eq!(emitted_spec_count(&[], &mp), 0);
    }
}
