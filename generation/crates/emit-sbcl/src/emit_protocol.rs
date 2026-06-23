//! ObjC `@protocol` → the CLOS conformance surface (leaf 040/030, contract §3.5).
//!
//! A protocol in the SBCL projection is **not** a class and gets **no** `defclass`
//! (ADR-0034 projects only the ObjC superclass chain). Its role is twofold, and
//! this module emits the static half of each:
//!
//! 1. **Conformance surface for Lisp subclasses (this module).** Contract §3.5: a
//!    Lisp programmer *declares conformance* to an existing ObjC protocol on a
//!    `define-objc-subclass` and implements its methods with `define-objc-method`
//!    (the delegate pattern — many protocol methods on one Lisp subclass; methods
//!    belong only to Lisp-created classes, never as a category on a foreign
//!    class). For a `define-objc-method` to specialize a selector, a **`defgeneric`
//!    must exist** for it. This module emits the protocol's contributed generics —
//!    exactly those selectors **not otherwise on the class graph** (a pure
//!    delegate selector like `windowDidResize:` that no concrete bound class
//!    declares) — and bakes a `register-objc-protocol` table the runtime drives
//!    conformance from (§B4 / ADR-0034 §5).
//! 2. **Callable surface on conforming foreign classes (NOT here).** When a *bound
//!    foreign* class conforms to a protocol (`NSData` → `NSCopying`), its
//!    `copyWithZone:` must be a callable `defmethod` on `ns:ns-data`. That is the
//!    **flattening** in [`crate::emit_generics`], driven by
//!    [`crate::protocol_registry::ProtocolRegistry`] — see that module's header
//!    for why the CLOS class graph does not cover it for free.
//!
//! ## Why no `make-<proto>` delegate constructor (the gerbil divergence)
//!
//! `emit-gerbil/emit_protocol.rs` emits a variadic `make-<proto>` that builds a
//! delegate *object* from `(selector handler)` pairs, plus a baked per-selector
//! marshalling-token table its monomorphic `make-delegate` reads at the call site.
//! SBCL's contract realizes the delegate pattern through the CLOS subclass macros
//! instead (§3.4/§3.5), so there is **no constructor and no marshalling-token
//! table**: the runtime synthesizes each IMP and reads its ObjC type encoding from
//! the **live** protocol (`protocol_getMethodDescription`) at conformance time —
//! "the runtime drives conformance". The emitter therefore bakes only the *names*
//! (selector ↔ `ns:` generic), required/optional, not the ABI signatures.
//!
//! ## Runtime contract (the 040 → 050 seam, fixed here)
//!
//! - **`register-objc-protocol`** `("<ObjCName>" :required ((sel gen)…) :optional
//!   ((sel gen)…))` — registers the protocol's selector surface for the runtime's
//!   `define-objc-subclass` conformance machinery (`objc_getProtocol` +
//!   `class_addProtocol` + per-selector IMP install). Each entry pairs the ObjC
//!   selector string with its `ns:` generic-function name. An inbox note records
//!   this for 050 alongside `register-objc-class` / `register-objc-init`.

use std::collections::BTreeSet;

use apianyware_macos_emit::code_writer::CodeWriter;
use apianyware_macos_emit::write_line;
use apianyware_macos_types::ir::{Method, Protocol};

use crate::emit_generics::{render_generics, GenericDecl};
use crate::naming::{qualified_generic_name, selector_arity};

/// Bakes a protocol's selector surface for the runtime's conformance machinery (§5).
pub const REGISTER_PROTOCOL_FN: &str = "register-objc-protocol";

/// One protocol method paired with whether the protocol declares it **required**.
struct ProtoMethod<'a> {
    method: &'a Method,
    required: bool,
}

/// A protocol's `objc_exposed` declared methods, required first then optional —
/// the surface the generics and the registration table are built over.
///
/// `objc_exposed == false` protocol methods are excluded (ADR-0026 §3 — the split
/// applies to protocol methods as to class methods): they carry no ObjC selector,
/// so neither a direct generic nor a live-protocol IMP can reach them. Protocol
/// *properties* are not separately surfaced here — a conforming class's property
/// accessors arrive via flattening ([`crate::emit_generics`]), and the runtime
/// reads any needed encoding from the live protocol.
fn exposed_methods(proto: &Protocol) -> Vec<ProtoMethod<'_>> {
    proto
        .required_methods
        .iter()
        .map(|m| ProtoMethod {
            method: m,
            required: true,
        })
        .chain(proto.optional_methods.iter().map(|m| ProtoMethod {
            method: m,
            required: false,
        }))
        .filter(|pm| pm.method.objc_exposed)
        .collect()
}

/// Whether a protocol declares at least one `objc_exposed` method — the empty
/// marker protocols (pure inheritance shells) carry no surface and are skipped by
/// the orchestration leaf (060), mirroring gerbil's empty-protocol skip.
pub fn has_surface(proto: &Protocol) -> bool {
    !exposed_methods(proto).is_empty()
}

/// The generics this protocol contributes that are **not already on the class
/// graph** (`existing` is the global `defgeneric` name set from
/// [`crate::emit_generics::collect_generics`], which already includes the
/// flattened conformed-protocol methods). A selector a concrete bound class
/// declares — or that flattens onto a conformer — already has its `defgeneric`
/// from the class path; the protocol only adds the genuinely
/// delegate-only selectors. Deduped within the protocol by generic name; arity is
/// the selector's colon count (its visible arity).
pub fn protocol_generic_decls(proto: &Protocol, existing: &BTreeSet<String>) -> Vec<GenericDecl> {
    let mut seen: BTreeSet<String> = BTreeSet::new();
    let mut decls = Vec::new();
    for pm in exposed_methods(proto) {
        let name = qualified_generic_name(&pm.method.selector);
        if existing.contains(&name) || !seen.insert(name.clone()) {
            continue;
        }
        decls.push(GenericDecl {
            name,
            arity: selector_arity(&pm.method.selector),
        });
    }
    decls
}

/// Render one protocol's CLOS conformance surface: a header comment, the
/// contributed `defgeneric`s (those not already declared by the class graph), and
/// the `register-objc-protocol` table the runtime drives conformance from. A
/// protocol with no `objc_exposed` methods renders nothing ([`has_surface`]).
pub fn render_protocol(
    proto: &Protocol,
    framework: &str,
    existing_generics: &BTreeSet<String>,
) -> String {
    let methods = exposed_methods(proto);
    if methods.is_empty() {
        return String::new();
    }

    let mut w = CodeWriter::new();
    write_line!(
        w,
        ";; --- {} ({}) — protocol conformance surface (contract §3.5) ---",
        proto.name,
        framework
    );

    // The contributed generics (delegate-only selectors). The class-graph
    // selectors already have their defgenerics from collect_generics.
    let decls = protocol_generic_decls(proto, existing_generics);
    if !decls.is_empty() {
        w.line(render_generics(&decls).trim_end());
    }

    // The runtime registration: selector ↔ ns: generic, split required/optional.
    render_registration(&mut w, &proto.name, &methods);
    w.blank_line();
    w.finish()
}

/// Emit the `register-objc-protocol` form: `("<ObjCName>" :required ((sel gen)…)
/// :optional ((sel gen)…))`. The selector ↔ generic pairs let the runtime map a
/// `define-objc-method` back to the protocol selector it satisfies; the
/// required/optional split mirrors the ObjC protocol's own classification.
fn render_registration(w: &mut CodeWriter, proto_name: &str, methods: &[ProtoMethod<'_>]) {
    let pairs = |required: bool| -> Vec<String> {
        let mut seen: BTreeSet<String> = BTreeSet::new();
        methods
            .iter()
            .filter(|pm| pm.required == required)
            .filter_map(|pm| {
                let sel = &pm.method.selector;
                if !seen.insert(sel.clone()) {
                    return None;
                }
                Some(format!("(\"{}\" {})", sel, qualified_generic_name(sel)))
            })
            .collect()
    };
    let required = pairs(true);
    let optional = pairs(false);

    write_line!(w, "({REGISTER_PROTOCOL_FN} \"{proto_name}\"");
    write_line!(w, "  :required ({})", required.join(" "));
    write_line!(w, "  :optional ({}))", optional.join(" "));
}

#[cfg(test)]
mod tests {
    use super::*;
    use apianyware_macos_types::ir::{Method, Param, Protocol};
    use apianyware_macos_types::type_ref::{TypeRef, TypeRefKind};

    fn ty(kind: TypeRefKind) -> TypeRef {
        TypeRef {
            nullable: false,
            kind,
        }
    }

    fn m(sel: &str, params: Vec<Param>, ret: TypeRefKind) -> Method {
        Method {
            selector: sel.into(),
            class_method: false,
            init_method: false,
            params,
            return_type: ty(ret),
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

    fn obj_param(name: &str, class: &str) -> Param {
        Param {
            name: name.into(),
            param_type: ty(TypeRefKind::Class {
                name: class.into(),
                framework: None,
                params: vec![],
            }),
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

    fn empty() -> BTreeSet<String> {
        BTreeSet::new()
    }

    #[test]
    fn contributes_defgenerics_for_delegate_selectors() {
        let p = proto(
            "NSWindowDelegate",
            vec![],
            vec![
                m(
                    "windowWillClose:",
                    vec![obj_param("notification", "NSNotification")],
                    TypeRefKind::Primitive {
                        name: "void".into(),
                    },
                ),
                m(
                    "windowShouldClose:",
                    vec![obj_param("sender", "NSWindow")],
                    TypeRefKind::Primitive {
                        name: "bool".into(),
                    },
                ),
            ],
        );
        let out = render_protocol(&p, "AppKit", &empty());
        // No defclass for a protocol.
        assert!(!out.contains("defclass"));
        // Each delegate selector gets a defgeneric (arity 1 = one colon).
        assert!(out.contains("(defgeneric ns:window-will-close_ (receiver arg0)"));
        assert!(out.contains("(defgeneric ns:window-should-close_ (receiver arg0)"));
    }

    #[test]
    fn selector_already_on_class_graph_is_not_redeclared() {
        // If a bound class already declares `windowWillClose:` (or it flattened onto
        // a conformer), its generic is in `existing` — the protocol must not emit a
        // duplicate defgeneric.
        let p = proto(
            "NSWindowDelegate",
            vec![],
            vec![m(
                "windowWillClose:",
                vec![obj_param("n", "NSNotification")],
                TypeRefKind::Primitive {
                    name: "void".into(),
                },
            )],
        );
        let mut existing = BTreeSet::new();
        existing.insert("ns:window-will-close_".to_string());
        let out = render_protocol(&p, "AppKit", &existing);
        assert!(!out.contains("(defgeneric ns:window-will-close_"));
        // …but it still appears in the registration table (a conformer must still
        // be routable to the selector).
        assert!(out.contains("(\"windowWillClose:\" ns:window-will-close_)"));
    }

    #[test]
    fn registration_splits_required_and_optional() {
        let p = proto(
            "TKDelegate",
            vec![m(
                "didStart",
                vec![],
                TypeRefKind::Primitive {
                    name: "void".into(),
                },
            )],
            vec![m(
                "shouldContinue",
                vec![],
                TypeRefKind::Primitive {
                    name: "bool".into(),
                },
            )],
        );
        let out = render_protocol(&p, "TestKit", &empty());
        assert!(out.contains("(register-objc-protocol \"TKDelegate\""));
        assert!(out.contains("  :required ((\"didStart\" ns:did-start))"));
        assert!(out.contains("  :optional ((\"shouldContinue\" ns:should-continue)))"));
    }

    #[test]
    fn tkcopying_analogue_surfaces_copy_with_zone() {
        // The NSCopying analogue: one required method, object param + object return.
        let p = proto(
            "TKCopying",
            vec![m(
                "copyWithZone:",
                vec![obj_param("zone", "NSZone")],
                TypeRefKind::Instancetype,
            )],
            vec![],
        );
        let out = render_protocol(&p, "TestKit", &empty());
        assert!(out.contains("(defgeneric ns:copy-with-zone_ (receiver arg0)"));
        assert!(out.contains("(register-objc-protocol \"TKCopying\""));
        assert!(out.contains("  :required ((\"copyWithZone:\" ns:copy-with-zone_))"));
        assert!(out.contains("  :optional ()"));
    }

    #[test]
    fn objc_exposed_false_protocol_method_excluded() {
        // A Swift-native protocol requirement carries no ObjC selector — excluded
        // from both the generic surface and the registration (ADR-0026 §3).
        let mut native = m("nativeRequirement", vec![], TypeRefKind::Id);
        native.objc_exposed = false;
        let p = proto(
            "TKMixed",
            vec![
                native,
                m(
                    "realOne",
                    vec![],
                    TypeRefKind::Primitive {
                        name: "void".into(),
                    },
                ),
            ],
            vec![],
        );
        let out = render_protocol(&p, "TestKit", &empty());
        assert!(!out.contains("native-requirement"));
        assert!(!out.contains("nativeRequirement"));
        assert!(out.contains("(\"realOne\" ns:real-one)"));
    }

    #[test]
    fn empty_marker_protocol_renders_nothing() {
        let p = proto("NSObjectProtocolMarker", vec![], vec![]);
        assert!(!has_surface(&p));
        assert_eq!(render_protocol(&p, "Foundation", &empty()), "");
    }

    #[test]
    fn all_native_protocol_has_no_surface() {
        // A protocol whose only methods are Swift-native has no ObjC surface.
        let mut native = m("nativeRequirement", vec![], TypeRefKind::Id);
        native.objc_exposed = false;
        let p = proto("TKAllNative", vec![native], vec![]);
        assert!(!has_surface(&p));
    }

    #[test]
    fn multi_component_selector_arity_from_colons() {
        let p = proto(
            "TKTableDelegate",
            vec![],
            vec![m(
                "tableView:objectValueForTableColumn:row:",
                vec![
                    obj_param("tv", "NSTableView"),
                    obj_param("col", "NSTableColumn"),
                    obj_param("row", "NSInteger"),
                ],
                TypeRefKind::Id,
            )],
        );
        let decls = protocol_generic_decls(&p, &empty());
        assert_eq!(decls.len(), 1);
        assert_eq!(
            decls[0].name,
            "ns:table-view_object-value-for-table-column_row_"
        );
        assert_eq!(decls[0].arity, 3);
    }
}
