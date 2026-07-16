//! The **`TypeRefKind::Class` overload**, resolved once — is this reference an ObjC object
//! the emitter can bind, an ObjC object it cannot, or not an object at all?
//!
//! ## Why the kind is ambiguous
//!
//! `TypeRefKind::Class { name }` means two unrelated things, and the IR does not distinguish
//! them. A decl extracted from an **ObjC header** spells `CLLocation *` that way — a genuine
//! object pointer. A decl recovered from a **`.swiftinterface`** spells *every Swift nominal
//! type* that way: `Tuple`, `KeyPath`, `OpaqueTypeArchetype`, `Binding`, `Hasher`, `SIMD3`,
//! `CGFloat`. Measured over the committed IR, 27,890 `Class{…}` references name something the
//! IR never declares as a class — **99.2% of them from `.swiftinterface` decls**, and only 234
//! from ObjC headers.
//!
//! Treating them alike is the defect this module closes: the emitter typed a Swift tuple as a
//! wrappable handle, emitted `__wrapRetained(Tuple, __ret)` against it, and value-imported
//! `Tuple` from a module nothing exports (`swift-nominal-type-surface-k66`).
//!
//! ## The rule — one predicate, four readers
//!
//! The decl's [`DeclarationSource`] is the discriminator, and it is sound in the direction that
//! matters: **an ObjC header cannot write a Swift tuple in a `Foo *` position**, so an
//! ObjC-sourced `Class{name}` is always a real object pointer, even when the extractor never
//! collected the class. A `.swiftinterface`-sourced one carries no such guarantee.
//!
//! | `Class{name}` | disposition |
//! |---|---|
//! | the IR declares `name` ([`TsFfiTypeMapper::is_bound_class`]) | [`Bound`](ClassBinding::Bound) — its own TS class type, imported from its owning module |
//! | not declared, decl is [`ObjcHeader`](DeclarationSource::ObjcHeader) | [`Degraded`](ClassBinding::Degraded) — a real ObjC class this target does not emit: type it as the runtime root `NSObject` (the gerbil "nearest bound ancestor" precedent, `CONTEXT.md`) |
//! | not declared, decl is [`SwiftInterface`](DeclarationSource::SwiftInterface) | [`Deferred`](ClassBinding::Deferred) — a Swift nominal type with no ObjC identity: the whole member defers |
//!
//! Degrading is sound *and* useful: the handle is a genuine ObjC object, so it retains,
//! uniques and disposes exactly like any other (ADR-0057), and it **round-trips** — a
//! `CLLocation` read from `-[CLLocationManager location]` can be passed straight back into
//! `-[CKLocationSortDescriptor initWithKey:relativeLocation:]`. Deferring it instead would
//! delete that API outright. Deferring a Swift nominal is equally forced: `objc_retain` on a
//! tuple is undefined behaviour.
//!
//! ## The structural guarantee that keeps the mapper source-free
//!
//! Only [`deferred_class`] — read by [`crate::method_filter`] and, through
//! [`crate::class_surface::bound_methods`], by every table collector — needs the decl's
//! `source`. Once it has deferred the Swift-nominal case, **any surviving unbound name is
//! provably ObjC-real**, so the three surface readers ([`crate::ffi_type_mapping`]'s
//! `Class` arm, [`crate::class_surface::object_class_name`]'s import set, and each family's
//! `wrap_class`) degrade *unconditionally* and never see a `DeclarationSource`. That is the
//! [`crate::ptr_value`] discipline — one decision, N readers, no site re-deriving it — applied
//! to the second pointer-surface ambiguity.
//!
//! ## What this does *not* change
//!
//! Nothing at the ABI. [`AbiType::from_type_ref`](crate::native_dispatch::AbiType::from_type_ref)
//! already collapses every `Class{…}` to `Ptr`, and a degraded class is still an object
//! (`is_object_type`), so the retain axis, the entry name, and the outbound/inbound tables are
//! byte-identical. A **deferred** member disappears from
//! [`bound_methods`](crate::class_surface::bound_methods) — the single frontier the call sites
//! *and* the table collection walk — so the mirror invariant holds with the entry set simply
//! smaller.

use apianyware_types::provenance::DeclarationSource;
use apianyware_types::type_ref::{TypeRef, TypeRefKind};

use crate::ffi_type_mapping::TsFfiTypeMapper;
use crate::naming::class_type_name;

/// The runtime-owned root every unbindable-but-real ObjC class degrades to. Same constant as
/// [`crate::class_graph::RUNTIME_ROOT`]; named here so the degrade rule reads locally.
const DEGRADE_TO: &str = "NSObject";

/// How a `Class{name}` reference binds on the TS surface (module doc).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ClassBinding {
    /// The IR declares this class, so the emitter emits it: the TS type is the class itself,
    /// imported from its owning `@apianyware/<fw>` module.
    Bound,
    /// A real ObjC class the IR does not declare — the extractor never collected it, or it
    /// lives in a framework this generate run did not load. The handle is a genuine object, so
    /// the surface degrades it to the runtime root `NSObject` rather than dangle.
    Degraded,
    /// A `.swiftinterface`-lowered Swift nominal type with no ObjC identity (a tuple, a value
    /// type, a key path). Not an object at all: the member that names it defers.
    Deferred,
}

/// Classify one type reference. `None` for every kind that is not a `Class{…}` — `Id`,
/// `Instancetype`, scalars, structs, `SEL`/`Class` ([`crate::ptr_value`]) — none of which is
/// ambiguous. `source` is the **declaring** decl's source, not the type's.
///
/// **Only [`SwiftInterface`](DeclarationSource::SwiftInterface) defers**; an absent source reads
/// as ObjC, matching the IR's settled default posture (`objc_exposed` likewise defaults `true` —
/// "the fully-elided ObjC limit"). That is sound because the *producer* of a Swift nominal type is
/// the `.swiftinterface` extractor, and it always stamps its decls: the committed corpus records a
/// source on **every** method (275 159), function (12 046) and constant (13 098) decl, so a
/// sourceless decl is by construction not from swift-api-digester. Reading `None` as "defer" would
/// instead silently empty every hand-authored fixture and `.apiw` overlay.
pub fn class_binding(
    t: &TypeRef,
    source: Option<DeclarationSource>,
    mapper: &TsFfiTypeMapper,
) -> Option<ClassBinding> {
    let TypeRefKind::Class { name, .. } = &t.kind else {
        return None;
    };
    Some(if mapper.is_bound_class(name) {
        ClassBinding::Bound
    } else if source == Some(DeclarationSource::SwiftInterface) {
        ClassBinding::Deferred
    } else {
        ClassBinding::Degraded
    })
}

/// The first type in `types` that forces the **whole declaration to defer** — a
/// `.swiftinterface`-sourced `Class{name}` naming a class the IR does not declare — or `None`
/// when every reference binds or degrades. Returns the offending name so the caller can *count*
/// the deferral by reason (the k57 "defer nothing silently" discipline).
///
/// The single admission gate for the Swift-nominal case, shared by
/// [`crate::method_filter::is_supported_method`] / [`is_supported_function`](crate::method_filter::is_supported_function)
/// and — through [`crate::class_surface::bound_methods`] — by every table collector, so an
/// emitted call site and its generated dispatch entry can never disagree about which members
/// exist.
pub fn deferred_class<'t>(
    source: Option<DeclarationSource>,
    types: impl IntoIterator<Item = &'t TypeRef>,
    mapper: &TsFfiTypeMapper,
) -> Option<&'t str> {
    types
        .into_iter()
        .find_map(|t| match (class_binding(t, source, mapper), &t.kind) {
            (Some(ClassBinding::Deferred), TypeRefKind::Class { name, .. }) => Some(name.as_str()),
            _ => None,
        })
}

/// The TS class name an **object** reference surfaces as: a bound class is itself; a
/// [`Degraded`](ClassBinding::Degraded) one — and `id`, and any name reaching here without
/// whole-program knowledge — is the runtime root `NSObject`.
///
/// The one place the degrade happens, read by the type surface, the import set, and the wrap
/// primitives alike. It takes **no** `DeclarationSource`, by the module doc's structural
/// guarantee: [`deferred_class`] has already removed every member whose unbound name might not
/// be an object, so anything still here is ObjC-real.
pub fn surface_class_name(name: &str, mapper: &TsFfiTypeMapper) -> String {
    if mapper.is_bound_class(name) {
        class_type_name(name)
    } else {
        DEGRADE_TO.to_string()
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::collections::BTreeSet;
    use std::sync::Arc;

    fn mapper(bound: &[&str]) -> TsFfiTypeMapper {
        let set: Arc<BTreeSet<String>> = Arc::new(bound.iter().map(|s| s.to_string()).collect());
        TsFfiTypeMapper::with_known_classes(set)
    }

    fn class(name: &str) -> TypeRef {
        TypeRef {
            nullable: false,
            kind: TypeRefKind::Class {
                name: name.into(),
                framework: None,
                params: vec![],
            },
        }
    }

    #[test]
    fn a_declared_class_binds_whatever_the_decl_source() {
        let m = mapper(&["NSString"]);
        for source in [
            Some(DeclarationSource::ObjcHeader),
            Some(DeclarationSource::SwiftInterface),
            None,
        ] {
            assert_eq!(
                class_binding(&class("NSString"), source, &m),
                Some(ClassBinding::Bound)
            );
        }
    }

    #[test]
    fn an_objc_sourced_unbound_class_degrades_to_the_runtime_root() {
        // The real-corpus shape: `-[EKStructuredLocation geoLocation]` returns `CLLocation *`
        // from an ObjC header, but CoreLocation's IR declares no CLLocation class. An ObjC
        // header cannot name a non-object there, so the handle is a genuine object — type it
        // `NSObject` rather than dangle an import nothing exports.
        let m = mapper(&["NSString"]);
        assert_eq!(
            class_binding(
                &class("CLLocation"),
                Some(DeclarationSource::ObjcHeader),
                &m
            ),
            Some(ClassBinding::Degraded)
        );
        assert_eq!(surface_class_name("CLLocation", &m), "NSObject");
        assert_eq!(surface_class_name("NSString", &m), "NSString");
    }

    #[test]
    fn a_swift_sourced_unbound_class_defers() {
        // `NEPacketTunnelFlow.readPackets()` is `.swiftinterface`-sourced and returns
        // `Class{Tuple}` — a Swift tuple, not an object. Wrapping it would `objc_retain` a
        // tuple (UB), so the member defers.
        let m = mapper(&["NSArray"]);
        assert_eq!(
            class_binding(&class("Tuple"), Some(DeclarationSource::SwiftInterface), &m),
            Some(ClassBinding::Deferred)
        );
        // Only `.swiftinterface` defers: a **sourceless** decl reads as ObjC (the IR's settled
        // default posture — `objc_exposed` defaults true too), because the producer of a Swift
        // nominal type always stamps its decls. Reading `None` as "defer" would silently empty
        // every hand-authored fixture and `.apiw` overlay.
        assert_eq!(
            class_binding(&class("Tuple"), None, &m),
            Some(ClassBinding::Degraded)
        );
    }

    #[test]
    fn non_class_kinds_are_never_ambiguous() {
        let m = mapper(&[]);
        for kind in [
            TypeRefKind::Id {
                protocols: Vec::new(),
            },
            TypeRefKind::Instancetype,
            TypeRefKind::ClassRef,
            TypeRefKind::Selector,
            TypeRefKind::Pointer,
            TypeRefKind::CString,
            TypeRefKind::Primitive {
                name: "int64".into(),
            },
            TypeRefKind::Struct {
                name: "CGRect".into(),
            },
        ] {
            let t = TypeRef {
                nullable: false,
                kind,
            };
            assert_eq!(
                class_binding(&t, Some(DeclarationSource::SwiftInterface), &m),
                None
            );
        }
    }

    #[test]
    fn deferred_class_finds_the_offending_name_and_ignores_the_rest() {
        let m = mapper(&["NSArray"]);
        let objc = Some(DeclarationSource::ObjcHeader);
        let swift = Some(DeclarationSource::SwiftInterface);

        // Swift-sourced: the unbound `Tuple` forces the deferral and is named back for counting;
        // the bound `NSArray` beside it does not.
        assert_eq!(
            deferred_class(swift, [&class("NSArray"), &class("Tuple")], &m),
            Some("Tuple")
        );
        // Swift-sourced but every name bound → nothing defers.
        assert_eq!(deferred_class(swift, [&class("NSArray")], &m), None);
        // ObjC-sourced: an unbound name degrades, it never defers.
        assert_eq!(deferred_class(objc, [&class("CLLocation")], &m), None);
    }

    #[test]
    fn an_empty_recognition_set_means_empty_not_omniscient() {
        // The mapper has exactly one reading of its set: a name in it is a class, a name outside
        // it is not. There is deliberately no "no knowledge ⇒ assume everything is a class"
        // arm — that would let a caller who forgot to configure the set silently keep the
        // pre-k66 surface, which is the whole defect. So a recognition-free mapper degrades
        // every ObjC-sourced class and defers every Swift-sourced one.
        let m = TsFfiTypeMapper::new();
        assert_eq!(surface_class_name("NSString", &m), "NSObject");
        assert_eq!(
            class_binding(&class("NSString"), Some(DeclarationSource::ObjcHeader), &m),
            Some(ClassBinding::Degraded)
        );
    }
}
