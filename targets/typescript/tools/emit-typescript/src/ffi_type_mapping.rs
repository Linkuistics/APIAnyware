//! IR type → TypeScript **type-surface** token mapping (the `.d.ts` idiom).
//!
//! ## Two surfaces, one settled here
//!
//! TypeScript is the first target with a static type system, so each bound method
//! has **two** type projections (ADR-0055, root brief's "second alien axis"):
//!
//! 1. the **type surface** — the idiomatic TS type that appears in the generated
//!    `class` bodies and the co-generated `.d.ts` (`NSString | null`, `number`,
//!    `boolean`, a POD `CGRect` object) — what a developer sees and `tsc` checks;
//! 2. the **dispatch shape** — the ABI token the emitted method body passes to the
//!    N-API addon's per-signature dispatch entry (ADR-0054): objects/pointers cross
//!    as `bigint` handles, scalars as their marshalled JS primitive.
//!
//! [`TsFfiTypeMapper`] is the **type-surface** mapper (the natural reading of the
//! shared [`FfiTypeMapper::map_type`] for TS). The dispatch-shape mapper is a thin
//! sibling introduced in `emit-class`, where the addon call sites are generated;
//! keeping them separate is the clean seam that lets the `.d.ts` stay idiomatic
//! while the runtime call stays coercion-free. **This module owns only the type
//! surface.**
//!
//! ## First-pass calls recorded for later leaves
//!
//! A few tokens are deliberate first-pass choices the sibling leaves refine — each
//! flagged inline:
//! - **64-bit integers** (`int64`/`uint64`/`NSInteger`) → `number`. Idiomatic and
//!   correct for the overwhelmingly common count/index/enum use (< 2^53); full
//!   64-bit fidelity via `bigint` is a runtime/dispatch decision to confirm at the
//!   native-adapter leaf, not a type-surface fact.
//! - **enum-typed aliases** (`NSStringEncoding`) → the **TS `enum` type name** once the
//!   mapper can *prove* the alias names a known `NS_ENUM`/`NS_OPTIONS` (it carries the
//!   framework's enum set, [`crate::enum_graph`]); an alias it cannot prove an enum still
//!   emits the safe underlying `number` (ADR-0055 §6, the second half — realised by
//!   `enum-alias-typing`). This is the one field that makes the mapper **stateful**.
//! - **`instancetype`** → `this` (return) / `NSObject` (param). `emit-class`
//!   substitutes the concrete class name in static-factory returns (`alloc`), where
//!   the receiver is known.
//! - **raw pointers / function pointers / blocks** → opaque (`bigint`) or `Function`.
//!   Methods carrying these are largely deferred by [`crate::method_filter`]; the
//!   typed callback surface is ADR-0059 (`emit-class` / a callbacks leaf).

use std::collections::BTreeSet;
use std::sync::Arc;

use apianyware_emit::ffi_type_mapping::{is_generic_type_param, FfiTypeMapper};
use apianyware_types::type_ref::{TypeRef, TypeRefKind};

use crate::class_binding::surface_class_name;
use crate::protocol_binding::id_surface_type;

/// TypeScript type-surface mapper — maps an IR [`TypeRef`] to the idiomatic TS
/// type token that appears in generated class bodies and the `.d.ts`.
///
/// **Enum-, class- and protocol-aware, so stateful.** Three things a context-free mapper cannot
/// decide, because in each case the IR spells two unrelated concepts with one kind:
///
/// 1. whether an `Alias` names an `NS_ENUM`/`NS_OPTIONS` (an enum typedef) or a scalar typedef
///    — both arrive as [`TypeRefKind::Alias`]. The **known-enum recognition set**
///    ([`crate::enum_graph::EnumModuleResolver::known_enums`]) settles it: an alias in the set
///    upgrades to its TS enum type name, every other alias falls through to the safe underlying
///    `number` (ADR-0055 §6).
/// 2. whether a `Class{name}` names a real ObjC class or a `.swiftinterface`-lowered Swift
///    nominal type (`Tuple`, `KeyPath`, `CGFloat`) — both arrive as [`TypeRefKind::Class`]. The
///    **known-class recognition set** ([`crate::class_graph::ClassModuleResolver::known_classes`])
///    settles it: a name the IR declares is that class, and anything else degrades to the runtime
///    root `NSObject` (`swift-nominal-type-surface-k66`; the full three-way rule, and the
///    deferral that makes the degrade sound, live in [`crate::class_binding`]).
/// 3. whether a protocol name in an `id<P>` qualifier is an interface the emitter emits — the
///    **known-protocol recognition set**
///    ([`crate::protocol_graph::ProtocolModuleResolver::known_protocols`], the very set the class
///    `implements` clause is filtered on). A name it recognises types the slot; anything else
///    degrades to `NSObject` (`protocol-binding-surface-k89`; the two guards and the
///    param/return variance rule live in [`crate::protocol_binding`]).
///
/// All three sets are shared cheaply (`Arc`) so the per-class/per-protocol mappers the emitters
/// construct do not clone them.
///
/// **Every set means exactly what it says — empty means empty.** An unconfigured mapper
/// ([`Self::new`]) proves nothing an enum, nothing a class and nothing a protocol, so every alias
/// is a `number`, every `Class{name}` degrades to `NSObject`, and every qualifier drops. There is
/// deliberately no "no knowledge ⇒ assume everything" reading: it would let a caller that forgot to
/// configure a set silently keep the pre-k66 (broken) surface, and it would make the mapper's
/// answer depend on *why* a name is absent. Every caller that emits — the generate CLI through
/// [`crate::emit_framework`], the goldens, each table collector, and each unit test's render helper
/// — builds the sets the same way the orchestrator does: the whole-program registry plus the
/// framework's own declarations.
#[derive(Debug, Clone, Default)]
pub struct TsFfiTypeMapper {
    known_enums: Arc<BTreeSet<String>>,
    known_classes: Arc<BTreeSet<String>>,
    known_protocols: Arc<BTreeSet<String>>,
}

impl FfiTypeMapper for TsFfiTypeMapper {
    fn map_type(&self, type_ref: &TypeRef, is_return_type: bool) -> String {
        let base = self.base_token(type_ref, is_return_type);
        // Nullability rides the annotation into `T | null`, but only for genuine
        // reference (object-pointer) kinds — ObjC `_Nullable` annotates pointers,
        // never a scalar `number`/`boolean`/`void`/POD struct (ADR-0055 §6).
        if type_ref.nullable && is_nullable_reference(&type_ref.kind) {
            format!("{base} | null")
        } else {
            base
        }
    }
}

impl TsFfiTypeMapper {
    /// The recognition-free mapper — nothing is a known enum (every `Alias` maps to its safe
    /// underlying), nothing is a known class (every `Class{name}` degrades to `NSObject`) and
    /// nothing is a known protocol (every `id<P>` qualifier drops). For callers to which no
    /// recognition is relevant: the structural [`crate::native_dispatch`] ABI classification, and
    /// unit tests of kinds other than `Alias`/`Class`/`Id`.
    pub fn new() -> Self {
        Self::default()
    }

    /// An enum-aware mapper over the framework's recognition set
    /// ([`crate::enum_graph::EnumModuleResolver::known_enums`]) — a proven enum alias
    /// upgrades to its TS `enum` type name. Carries no class or protocol knowledge (struct doc).
    pub fn with_known_enums(known_enums: Arc<BTreeSet<String>>) -> Self {
        Self {
            known_enums,
            known_classes: Arc::default(),
            known_protocols: Arc::default(),
        }
    }

    /// A class-aware mapper over the whole-program declared-class set
    /// ([`crate::class_graph::declared_classes`]) — the frontier + degrade rule of
    /// [`crate::class_binding`]. Carries no enum or protocol knowledge, and that is exactly right
    /// for its three callers:
    ///
    /// - the **table collectors**, whose frontier must match the emitters' but whose ABI
    ///   classification is enum-blind (an enum alias and its underlying integer have the same
    ///   machine shape) and protocol-blind (every pointer-like collapses to one ABI code);
    /// - the **protocol registry** ([`crate::protocol_graph::ProtocolRegistry::from_framework_refs`])
    ///   and the orchestrator's **emittability** pre-pass, which *compute* the protocol
    ///   recognition set and so cannot already hold it. Sound because
    ///   [`crate::emit_protocol::is_emittable_protocol`] runs the **method frontier**, and the
    ///   frontier reads neither enums nor protocols — only class membership and the ABI shape.
    ///   (If it ever did, this would be a bootstrap paradox, not a mere gap.)
    pub fn with_known_classes(known_classes: Arc<BTreeSet<String>>) -> Self {
        Self {
            known_enums: Arc::default(),
            known_classes,
            known_protocols: Arc::default(),
        }
    }

    /// The fully configured mapper — all three recognition sets. What every **emitter** builds
    /// ([`crate::emit_framework`] threads the framework's enum set, the whole-program class set,
    /// and the protocol recognition set through the three resolvers).
    ///
    /// Three arguments, not two-plus-an-optional-builder, deliberately: a site that silently
    /// omitted the protocol set would keep the pre-k89 surface (every qualifier dropped) with
    /// nothing to notice it — the very "empty means empty" trap the struct doc warns about. Making
    /// it a required argument forces every emitter to answer.
    pub fn with_known(
        known_enums: Arc<BTreeSet<String>>,
        known_classes: Arc<BTreeSet<String>>,
        known_protocols: Arc<BTreeSet<String>>,
    ) -> Self {
        Self {
            known_enums,
            known_classes,
            known_protocols,
        }
    }

    /// Whether `name` is a proven `NS_ENUM`/`NS_OPTIONS` — in the recognition set the
    /// mapper was built with. The single gate both [`Self::alias_token`] (type-surface
    /// upgrade) and [`Self::known_enum_name`] (import collection / body cast) read.
    pub fn is_known_enum(&self, name: &str) -> bool {
        self.known_enums.contains(name)
    }

    /// Whether `name` is a class the IR **declares** — so the emitter emits it, its module
    /// exports it, and a `Class{name}` reference to it binds.
    ///
    /// The single gate [`crate::class_binding`] reads — and through it the type surface, the
    /// import set, the wrap primitives, and the method frontier. Never re-derive class
    /// membership at a second site; that is how a body and its import drift.
    pub fn is_bound_class(&self, name: &str) -> bool {
        self.known_classes.contains(name)
    }

    /// Whether `name` is a protocol the emitter emits an `interface` for — in the recognition set
    /// the mapper was built with, which is the **same** set
    /// ([`ProtocolModuleResolver::is_known`](crate::protocol_graph::ProtocolModuleResolver::is_known))
    /// the class `implements` clause is filtered on. That single set is what makes the bind arm and
    /// the conformance clause admit the same calls (`protocol-binding-surface-k89`).
    ///
    /// The single gate [`crate::protocol_binding`] reads — and through it the type surface and the
    /// protocol import set. Never re-derive protocol membership at a second site.
    pub fn is_known_protocol(&self, name: &str) -> bool {
        self.known_protocols.contains(name)
    }

    /// The whole-program declared-class set itself — for the **Swift-native residual**
    /// classifier ([`crate::trampoline::classify_function`]), which gates its object return on
    /// the same membership by name rather than by [`TypeRef`] (k65). Borrowed, so the per-framework
    /// render passes do not clone 5 000-odd names.
    pub fn bound_classes(&self) -> &BTreeSet<String> {
        &self.known_classes
    }

    /// If `type_ref` is an `Alias` naming a known enum, its TS enum type name (borrowed
    /// from the `TypeRef`); else `None`. Used to collect an enum type an emitted signature
    /// references (routed through [`crate::imports`]) and to cast an enum-typed return in
    /// the `.ts` body (a numeric `enum` is not structurally `number`, so `number` → enum
    /// needs an explicit `as`).
    pub fn known_enum_name<'t>(&self, type_ref: &'t TypeRef) -> Option<&'t str> {
        match &type_ref.kind {
            TypeRefKind::Alias { name, .. } if self.is_known_enum(name) => Some(name),
            _ => None,
        }
    }

    /// The un-nullability-decorated TS token for a kind.
    fn base_token(&self, type_ref: &TypeRef, is_return_type: bool) -> String {
        // A POD geometry aggregate first, whichever kind the IR spells it as: libclang classifies
        // `NSRect`/`CGRect` as a typedef (`Alias`), the swift-api-digester as a `Struct`. Routing
        // both through the ONE predicate the import set also reads ([`pod_type_name`]) is what
        // makes the rendered token and its `import type` the same string by construction — the
        // `surface_class_name` discipline (k66), applied to the other by-value population.
        if let Some(pod) = pod_type_name(type_ref) {
            return pod.to_string();
        }
        match &type_ref.kind {
            TypeRefKind::Primitive { name } => primitive_token(name).to_string(),
            // A bound class is its own branded type; a real ObjC class the IR does not declare
            // degrades to the root (`class_binding::surface_class_name` — the one place the
            // degrade lives). A `.swiftinterface` nominal type never reaches here: the method
            // frontier already deferred the member that named it.
            TypeRefKind::Class { name, .. } => surface_class_name(name, self),
            // A **protocol-qualified** `id` types as its interface — `P` in a param (the widest
            // thing that satisfies the API: a JS object literal suffices), `P & NSObject` in a
            // return (what the value *is*, once `dynamic-class-wrap-k88` mints it into its real
            // ObjC class). A qualifier that cannot bind — and a bare `id` — degrades to the root,
            // exactly as before. The one predicate, shared with the import set
            // ([`crate::protocol_binding`], ADR-0055 §4b).
            TypeRefKind::Id { .. } => id_surface_type(type_ref, self, is_return_type)
                .unwrap_or_else(|| "NSObject".to_string()),
            // `instancetype`: the polymorphic receiver type as a return (`this`);
            // as a param (rare) the root object. `emit-class` overrides the return
            // to the concrete class in static factories.
            TypeRefKind::Instancetype => {
                if is_return_type { "this" } else { "NSObject" }.to_string()
            }
            // `Class` metatype — any class object; `typeof NSObject` accepts every
            // bound subclass constructor.
            TypeRefKind::ClassRef => "typeof NSObject".to_string(),
            // `SEL` crosses idiomatically as its selector-name string.
            TypeRefKind::Selector => "string".to_string(),
            TypeRefKind::CString => "string".to_string(),
            // Opaque native pointers — methods carrying them are largely deferred
            // by the method filter; `bigint` matches the spike's pointer marshalling.
            TypeRefKind::Pointer | TypeRefKind::FunctionPointer { .. } => "bigint".to_string(),
            // A block's *precise* per-shape typed callback surface (`(a: A, b: B) => R`) is
            // ADR-0059's general widening (a later leaf) — the method filter still defers every
            // block-carrying method except the narrow `block-call-site-emission-k120` carve-out.
            // For that carve-out, this token must be structurally identical to the runtime's
            // `CallbackFn` (`callbacks.ts`) — `(...args: any[]) => unknown`, not the bare
            // `Function` interface — because `emit_class::emit_body` passes the param straight
            // into `__makeEscapingBlock(fn: CallbackFn, …)`, and TS does not consider `Function`
            // assignable to a concrete call signature (a real, corpus-caught TS2345).
            TypeRefKind::Block { .. } => "(...args: any[]) => unknown".to_string(),
            // A non-geometry struct: opaque (the POD family already returned above). Methods
            // carrying one are largely deferred by the method filter; Swift-native value structs
            // (population B) become branded handle classes, a later leaf.
            TypeRefKind::Struct { .. } => "bigint".to_string(),
            TypeRefKind::Alias {
                name,
                underlying_primitive,
                ..
            } => self.alias_token(name, underlying_primitive.as_deref()),
        }
    }

    /// A typedef alias token, for an alias that is **not** a geometry POD (those returned in
    /// [`Self::base_token`] before reaching here). A **proven** `NS_ENUM`/`NS_OPTIONS` alias maps to
    /// its TS `enum` type name (the [`Self::is_known_enum`] upgrade); ObjC generic type
    /// params (`ObjectType`, `KeyType`) are objects → `NSObject`; every other alias emits
    /// its safe underlying scalar (`number`). A proven enum wins over the generic-param
    /// heuristic (a real enum name never matches [`is_generic_type_param`] anyway — it
    /// starts with 2+ uppercase — but the fact beats the guess by construction).
    fn alias_token(&self, name: &str, underlying_primitive: Option<&str>) -> String {
        if self.is_known_enum(name) {
            return name.to_string();
        }
        if name.ends_with("Type") && is_generic_type_param(name) {
            return "NSObject".to_string();
        }
        // A non-enum alias carries a resolved width, but the safe surface is `number` — the
        // enum upgrade above is the only thing that promotes an alias off the scalar.
        let _ = underlying_primitive;
        "number".to_string()
    }
}

/// A C/ObjC primitive name → its idiomatic TS token. All integer widths and floats
/// collapse to `number` (see the 64-bit caveat in the module doc); `bool` → the
/// TS `boolean`; `void` → `void`; a bare `pointer` primitive → opaque `bigint`.
fn primitive_token(name: &str) -> &'static str {
    match normalize_primitive_name(name).as_str() {
        "void" => "void",
        "bool" => "boolean",
        "int8" | "uint8" | "int16" | "uint16" | "int32" | "uint32" | "int64" | "uint64"
        | "nsinteger" | "nsuinteger" | "float" | "double" => "number",
        "pointer" => "bigint",
        // Unknown/unqualified primitive — a collection-level gap, not the mapper's
        // job to resolve; opaque so the surface stays sound.
        _ => "bigint",
    }
}

/// The POD geometry type a [`TypeRef`] references, or `None` — **the** predicate for
/// "does this type name a by-value geometry aggregate?" (population A, ADR-0042 / ADR-0055 §5).
///
/// The IR spells the same aggregate two ways depending on the extractor — libclang classifies
/// `NSRect`/`CGRect` as a typedef ([`TypeRefKind::Alias`]), the swift-api-digester as a
/// [`TypeRefKind::Struct`] — so both kinds route here and canonicalise to one name.
///
/// Three readers, one decision (the k57 rule): the **type surface**
/// ([`TsFfiTypeMapper::base_token`], which consults this first), the **import set**
/// ([`crate::class_surface::referenced_pod_types`] and its per-emitter siblings, whose names
/// become `import type { CGRect } from '@apianyware/runtime'`), and the **method frontier**
/// ([`is_geometry_struct`], which admits a geometry-carrying method by value). Never re-derive
/// POD membership at a second site: a body that renders `CGRect` while its import set says
/// otherwise is the drift this single predicate exists to make impossible.
pub fn pod_type_name(type_ref: &TypeRef) -> Option<&'static str> {
    match &type_ref.kind {
        TypeRefKind::Struct { name } | TypeRefKind::Alias { name, .. } => pod_struct_type(name),
        _ => None,
    }
}

/// The canonical TS **POD object type** name for a known by-value geometry struct
/// (population A, ADR-0042 / ADR-0055 §5), or `None` for anything else. The
/// typedef-equivalent NS/CG spelling pairs canonicalise to one name so a single POD
/// type is defined per memory layout (the CG spelling for the rect/point/size trio,
/// per ADR-0055 §5's `CGRect`; NS spelling for the AppKit-only aggregates). These
/// nine names are the types the **runtime** defines (`@apianyware/runtime`, `structs.ts`) —
/// keyed by memory layout, not by framework, so one `CGRect` serves AppKit, Foundation and
/// CoreGraphics alike. Prefer [`pod_type_name`] when you hold a `TypeRef`; this is the
/// name-keyed core it and [`is_geometry_struct`] share.
pub fn pod_struct_type(name: &str) -> Option<&'static str> {
    match name {
        "NSRect" | "CGRect" => Some("CGRect"),
        "NSPoint" | "CGPoint" => Some("CGPoint"),
        "NSSize" | "CGSize" => Some("CGSize"),
        "NSRange" => Some("NSRange"),
        "NSEdgeInsets" => Some("NSEdgeInsets"),
        "NSDirectionalEdgeInsets" => Some("NSDirectionalEdgeInsets"),
        "NSAffineTransformStruct" => Some("NSAffineTransformStruct"),
        "CGAffineTransform" => Some("CGAffineTransform"),
        "CGVector" => Some("CGVector"),
        _ => None,
    }
}

/// True when `name` is a known by-value geometry struct — the population-A set the
/// method filter admits by value (mirrors sbcl's `is_known_geometry_alias`).
pub fn is_geometry_struct(name: &str) -> bool {
    pod_struct_type(name).is_some()
}

/// Kinds whose TS token is a genuine pointer reference, so a `_Nullable` annotation surfaces as
/// `T | null`. Scalars, `void`, enums, and POD geometry structs are excluded (ObjC does not
/// annotate them nullable).
///
/// `Selector` belongs here: a `SEL` is a pointer, `SEL _Nullable` is real (`-[NSControl
/// setAction:]` takes one, and `-[NSControl action]` returns nil when none is set), and the runtime
/// crossing represents it (`__sel(null)` → the nil `SEL`; `__selName(0n)` → `null`). Omitting it
/// **discarded** the annotation, so a nullable `SEL` rendered as a bare `string` — the one kind
/// whose nullability the mapper silently dropped (`sel-classref-surface-k72`).
fn is_nullable_reference(kind: &TypeRefKind) -> bool {
    matches!(
        kind,
        TypeRefKind::Class { .. }
            | TypeRefKind::Id { .. }
            | TypeRefKind::Instancetype
            | TypeRefKind::ClassRef
            | TypeRefKind::Selector
            | TypeRefKind::Block { .. }
            | TypeRefKind::CString
            | TypeRefKind::Pointer
            | TypeRefKind::FunctionPointer { .. }
    )
}

/// Strip a framework-qualified prefix (`Swift.Bool` → `bool`) and lowercase, so the
/// swift-api-digester's qualified primitive names match the ObjC extractor's
/// canonical ones (mirrors the shared/racket/sbcl `normalize`).
fn normalize_primitive_name(name: &str) -> String {
    let unqualified = name.rsplit_once('.').map_or(name, |(_, suffix)| suffix);
    unqualified.to_ascii_lowercase()
}

#[cfg(test)]
mod tests {
    use super::*;

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

    #[test]
    fn primitives_map_to_idiomatic_ts() {
        let m = TsFfiTypeMapper::new();
        let p = |n: &str| ty(TypeRefKind::Primitive { name: n.into() });
        assert_eq!(m.map_type(&p("void"), true), "void");
        assert_eq!(m.map_type(&p("bool"), false), "boolean");
        assert_eq!(m.map_type(&p("int32"), false), "number");
        assert_eq!(m.map_type(&p("uint32"), false), "number");
        assert_eq!(m.map_type(&p("double"), false), "number");
        assert_eq!(m.map_type(&p("float"), false), "number");
        // 64-bit integers → number (first-pass; see module doc).
        assert_eq!(m.map_type(&p("int64"), false), "number");
        assert_eq!(m.map_type(&p("uint64"), false), "number");
        // Swift-qualified + NSInteger spellings normalise.
        assert_eq!(m.map_type(&p("Swift.Bool"), false), "boolean");
        assert_eq!(m.map_type(&p("NSInteger"), false), "number");
        assert_eq!(m.map_type(&p("NSUInteger"), false), "number");
    }

    /// A mapper over a declared-class set — the shape every emitter builds (`emit_framework`).
    fn known_classes(names: &[&str]) -> TsFfiTypeMapper {
        TsFfiTypeMapper::with_known_classes(Arc::new(names.iter().map(|s| s.to_string()).collect()))
    }

    #[test]
    fn objects_map_to_branded_class_types() {
        let m = known_classes(&["NSString"]);
        assert_eq!(
            m.map_type(
                &ty(TypeRefKind::Class {
                    name: "NSString".into(),
                    framework: None,
                    params: vec![],
                }),
                false
            ),
            "NSString"
        );
        assert_eq!(
            m.map_type(
                &ty(TypeRefKind::Id {
                    protocols: Vec::new()
                }),
                false
            ),
            "NSObject"
        );
        // instancetype: `this` as a return, root object as a param.
        assert_eq!(m.map_type(&ty(TypeRefKind::Instancetype), true), "this");
        assert_eq!(
            m.map_type(&ty(TypeRefKind::Instancetype), false),
            "NSObject"
        );
        // Class metatype accepts any bound class constructor.
        assert_eq!(
            m.map_type(&ty(TypeRefKind::ClassRef), false),
            "typeof NSObject"
        );
    }

    #[test]
    fn nullability_surfaces_on_reference_kinds_only() {
        let m = known_classes(&["NSString"]);
        assert_eq!(
            m.map_type(
                &nullable(TypeRefKind::Class {
                    name: "NSString".into(),
                    framework: None,
                    params: vec![],
                }),
                false
            ),
            "NSString | null"
        );
        assert_eq!(
            m.map_type(
                &nullable(TypeRefKind::Id {
                    protocols: Vec::new()
                }),
                false
            ),
            "NSObject | null"
        );
        assert_eq!(
            m.map_type(&nullable(TypeRefKind::CString), false),
            "string | null"
        );
        // A (spurious) nullable scalar/void must NOT gain `| null`.
        assert_eq!(
            m.map_type(
                &nullable(TypeRefKind::Primitive {
                    name: "int32".into()
                }),
                false
            ),
            "number"
        );
        assert_eq!(
            m.map_type(
                &nullable(TypeRefKind::Primitive {
                    name: "void".into()
                }),
                true
            ),
            "void"
        );
    }

    #[test]
    fn an_undeclared_class_degrades_to_the_runtime_root() {
        // The k66 rule at the type surface: a `Class{name}` the IR never declares is not a class
        // this target emits, so no module can export it and no `import { CLLocation }` may be
        // written. It renders as the runtime root instead — sound, because the method frontier
        // has already deferred every member whose unbound name might not be an object at all
        // (`class_binding`). Nullability still rides it: `NSObject | null`.
        let m = known_classes(&["NSString"]);
        let cllocation = |nullable| TypeRef {
            nullable,
            kind: TypeRefKind::Class {
                name: "CLLocation".into(),
                framework: Some("CoreLocation".into()),
                params: vec![],
            },
        };
        assert_eq!(m.map_type(&cllocation(false), true), "NSObject");
        assert_eq!(m.map_type(&cllocation(true), true), "NSObject | null");
        assert!(m.is_bound_class("NSString"));
        assert!(!m.is_bound_class("CLLocation"));
    }

    #[test]
    fn strings_selectors_and_opaque_pointers() {
        let m = TsFfiTypeMapper::new();
        assert_eq!(m.map_type(&ty(TypeRefKind::CString), false), "string");
        assert_eq!(m.map_type(&ty(TypeRefKind::Selector), false), "string");
        assert_eq!(m.map_type(&ty(TypeRefKind::Pointer), false), "bigint");
        assert_eq!(
            m.map_type(
                &ty(TypeRefKind::FunctionPointer {
                    name: None,
                    params: vec![],
                    return_type: Box::new(TypeRef::void()),
                }),
                false
            ),
            "bigint"
        );
        assert_eq!(
            m.map_type(
                &ty(TypeRefKind::Block {
                    params: vec![],
                    return_type: Box::new(TypeRef::void()),
                }),
                false
            ),
            "(...args: any[]) => unknown"
        );
    }

    #[test]
    fn pod_geometry_structs_map_to_object_types() {
        let m = TsFfiTypeMapper::new();
        // NS/CG rect-point-size pairs canonicalise to the CG spelling.
        assert_eq!(
            m.map_type(
                &ty(TypeRefKind::Struct {
                    name: "NSRect".into()
                }),
                false
            ),
            "CGRect"
        );
        assert_eq!(
            m.map_type(
                &ty(TypeRefKind::Struct {
                    name: "CGRect".into()
                }),
                false
            ),
            "CGRect"
        );
        assert_eq!(
            m.map_type(
                &ty(TypeRefKind::Struct {
                    name: "CGPoint".into()
                }),
                false
            ),
            "CGPoint"
        );
        // libclang emits geometry typedefs as Alias — same POD name.
        assert_eq!(
            m.map_type(
                &ty(TypeRefKind::Alias {
                    name: "NSRange".into(),
                    framework: None,
                    underlying_primitive: None,
                }),
                false
            ),
            "NSRange"
        );
        // A non-geometry struct is opaque (deferred by the method filter).
        assert_eq!(
            m.map_type(
                &ty(TypeRefKind::Struct {
                    name: "SomeOtherStruct".into()
                }),
                false
            ),
            "bigint"
        );
        assert!(is_geometry_struct("CGRect"));
        assert!(!is_geometry_struct("SomeOtherStruct"));
    }

    #[test]
    fn the_pod_predicate_and_the_rendered_token_are_the_same_string() {
        // THE ONE-DECISION INVARIANT (`pod-struct-types-k73`). `pod_type_name` is what the import
        // set collects, and `map_type` is what the signature renders. If they could disagree, an
        // emitted body would name `CGRect` while its import block named something else — the drift
        // k66's `surface_class_name` and k76's file stem both exist to prevent. They cannot
        // disagree here because `base_token` *consults* the predicate: same input, same string.
        let m = TsFfiTypeMapper::new();
        let cases = [
            // Both spellings of each kind — libclang says Alias, swift-api-digester says Struct.
            ty(TypeRefKind::Struct {
                name: "NSRect".into(),
            }),
            ty(TypeRefKind::Struct {
                name: "CGRect".into(),
            }),
            ty(TypeRefKind::Struct {
                name: "CGPoint".into(),
            }),
            ty(TypeRefKind::Alias {
                name: "NSRange".into(),
                framework: None,
                underlying_primitive: None,
            }),
            ty(TypeRefKind::Alias {
                name: "NSPoint".into(),
                framework: None,
                underlying_primitive: None,
            }),
            ty(TypeRefKind::Alias {
                name: "CGVector".into(),
                framework: None,
                underlying_primitive: None,
            }),
        ];
        for t in &cases {
            let pod = pod_type_name(t).expect("a geometry aggregate");
            assert_eq!(
                m.map_type(t, false),
                pod,
                "the import name and the rendered token must be one string"
            );
        }
        // A nullable POD still renders bare (a struct is not a pointer — `is_nullable_reference`),
        // so the `| null` can never split the token away from its import name.
        assert_eq!(
            m.map_type(
                &nullable(TypeRefKind::Struct {
                    name: "CGRect".into()
                }),
                false
            ),
            "CGRect"
        );
        // Everything else yields no POD reference — nothing to import.
        for t in [
            ty(TypeRefKind::Struct {
                name: "SomeOtherStruct".into(),
            }),
            ty(TypeRefKind::Id {
                protocols: Vec::new(),
            }),
            ty(TypeRefKind::Primitive {
                name: "int32".into(),
            }),
            ty(TypeRefKind::Alias {
                name: "NSStringEncoding".into(),
                framework: None,
                underlying_primitive: Some("uint64".into()),
            }),
        ] {
            assert_eq!(pod_type_name(&t), None);
        }
    }

    #[test]
    fn a_geometry_alias_outranks_the_enum_upgrade() {
        // The POD check precedes the enum check (it now lives in `base_token`, ahead of the match),
        // so a mapper that has somehow been told `NSRange` is an enum still renders the POD. The
        // ordering is load-bearing: the import set routes a POD to the runtime and an enum to a
        // framework barrel, so a flip here would dangle the import.
        let known: Arc<BTreeSet<String>> = Arc::new(["NSRange".to_string()].into_iter().collect());
        let m = TsFfiTypeMapper::with_known_enums(known);
        let range = ty(TypeRefKind::Alias {
            name: "NSRange".into(),
            framework: None,
            underlying_primitive: None,
        });
        assert_eq!(m.map_type(&range, false), "NSRange");
        assert_eq!(pod_type_name(&range), Some("NSRange"));
    }

    #[test]
    fn aliases_generic_params_and_unproven_enums() {
        let m = TsFfiTypeMapper::new();
        // Generic ObjC type param → object.
        assert_eq!(
            m.map_type(
                &ty(TypeRefKind::Alias {
                    name: "ObjectType".into(),
                    framework: None,
                    underlying_primitive: None,
                }),
                false
            ),
            "NSObject"
        );
        // A context-free mapper cannot prove `NSStringEncoding` an enum → safe underlying.
        assert_eq!(
            m.map_type(
                &ty(TypeRefKind::Alias {
                    name: "NSStringEncoding".into(),
                    framework: None,
                    underlying_primitive: Some("uint64".into()),
                }),
                false
            ),
            "number"
        );
    }

    #[test]
    fn proven_enum_alias_upgrades_to_the_enum_type_name() {
        // The enum-alias-typing upgrade (ADR-0055 §6, second half): an alias in the
        // recognition set renders as its TS `enum` type name, not `number`.
        let known: Arc<BTreeSet<String>> =
            Arc::new(["NSComparisonResult".to_string()].into_iter().collect());
        let m = TsFfiTypeMapper::with_known_enums(known);
        let cmp = TypeRefKind::Alias {
            name: "NSComparisonResult".into(),
            framework: None,
            underlying_primitive: Some("int64".into()),
        };
        assert_eq!(m.map_type(&ty(cmp.clone()), true), "NSComparisonResult");
        // Enums are scalars at the ABI — `_Nullable` never annotates one, so even a
        // (spurious) nullable enum alias does NOT gain `| null`.
        assert_eq!(m.map_type(&nullable(cmp), false), "NSComparisonResult");
        // A non-enum alias in the same mapper still falls through to `number`.
        assert_eq!(
            m.map_type(
                &ty(TypeRefKind::Alias {
                    name: "NSStringEncoding".into(),
                    framework: None,
                    underlying_primitive: Some("uint64".into()),
                }),
                false
            ),
            "number"
        );
        // A geometry alias is still POD (geometry check precedes the enum check), and a
        // proven enum wins over the generic-type-param heuristic.
        assert_eq!(
            m.map_type(
                &ty(TypeRefKind::Alias {
                    name: "NSRange".into(),
                    framework: None,
                    underlying_primitive: None,
                }),
                false
            ),
            "NSRange"
        );
    }

    #[test]
    fn known_enum_name_extracts_the_alias_name_for_imports_and_casts() {
        let known: Arc<BTreeSet<String>> =
            Arc::new(["TKAlignment".to_string()].into_iter().collect());
        let m = TsFfiTypeMapper::with_known_enums(known);
        let enum_alias = ty(TypeRefKind::Alias {
            name: "TKAlignment".into(),
            framework: None,
            underlying_primitive: Some("int64".into()),
        });
        assert_eq!(m.known_enum_name(&enum_alias), Some("TKAlignment"));
        assert!(m.is_known_enum("TKAlignment"));
        // A non-enum alias, a scalar, and an object all yield None (nothing to import/cast).
        assert_eq!(
            m.known_enum_name(&ty(TypeRefKind::Alias {
                name: "NSStringEncoding".into(),
                framework: None,
                underlying_primitive: Some("uint64".into()),
            })),
            None
        );
        assert_eq!(
            m.known_enum_name(&ty(TypeRefKind::Primitive {
                name: "int64".into()
            })),
            None
        );
        assert!(!m.is_known_enum("NSStringEncoding"));
    }

    #[test]
    fn trait_helpers_classify_kinds() {
        let m = TsFfiTypeMapper::new();
        assert!(m.is_object_type(&ty(TypeRefKind::Id {
            protocols: Vec::new()
        })));
        assert!(m.is_object_type(&ty(TypeRefKind::Class {
            name: "NSView".into(),
            framework: None,
            params: vec![],
        })));
        assert!(m.is_void(&TypeRef::void()));
        assert!(m.is_block_type(&ty(TypeRefKind::Block {
            params: vec![],
            return_type: Box::new(TypeRef::void()),
        })));
        assert!(m.is_struct_type(&ty(TypeRefKind::Struct {
            name: "NSRect".into()
        })));
    }
}
