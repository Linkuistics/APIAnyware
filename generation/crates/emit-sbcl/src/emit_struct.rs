//! Per-value-struct CLOS emission — the population-B (value-struct) Swift-native
//! residual (ADR-0042).
//!
//! A **value struct** (`objc_exposed == false`, e.g. `IndexSet`, `Data`) with at least
//! one bindable Swift-native init or method is projected as a **plain CLOS class** —
//! `(defclass ns:<struct> (ns:value-struct) ())`, NOT the `objc-class` metaclass (there
//! is no ObjC `Class` behind it). It roots on the runtime-owned `ns:value-struct`, which
//! carries the opaque `AwSbclValueBox` handle in a `ptr` slot. So:
//!
//! ```lisp
//! (defclass ns:index-set (ns:value-struct) ())
//! (defmethod ns:contains ((self ns:index-set) arg0) …)        ; receiver = (aw-ptr self) = box
//! (defun ns:make-index-set-integer (integer)
//!   (make-instance 'ns:index-set :ptr <crossing>))            ; wrap the box into an instance
//! ```
//!
//! Why a CLOS class rather than gerbil's bare procedures: SBCL has a **single `ns:`
//! package**, so a value-struct method named like an ObjC selector (`ns:contains`) must
//! be a `defmethod` extending the shared generic — a bare `defun ns:contains` cannot
//! coexist with the `defgeneric ns:contains` of an ObjC dispatch (one symbol, one
//! function cell). Gerbil's Scheme has no such collision, so it keeps value structs
//! procedural; SBCL diverges to the CLOS-class projection (ADR-0042).
//!
//! Because the box rides the `ptr` slot, the method receiver coerces through the same
//! `(aw-ptr self)` as a class owner ([`crate::trampoline::MethodTrampoline::render_defmethod`])
//! — no value-specific Lisp receiver path is needed; the unbox + mutating write-back live
//! entirely in the `@_cdecl` Swift side. The method generics ride the framework's shared
//! generic set ([`crate::emit_generics::collect_generics`] folds them in), so this file
//! exports only the **struct class name** and its **constructor symbols**.

use std::collections::BTreeMap;

use apianyware_emit::code_writer::CodeWriter;
use apianyware_emit::write_line;
use apianyware_types::ir::Struct;

use crate::emit_generics::arity_consistent;
use crate::naming::qualified_class_name;
use crate::trampoline::{struct_residual_inits, struct_residual_methods};

/// The runtime-owned root every value-struct CLOS class derives from (ADR-0042). A plain
/// `standard-class` carrying the `AwSbclValueBox` handle in its `ptr` slot + a finalizer
/// that frees the box; runtime-owned (`value-struct.lisp`), never emitted here.
pub const VALUE_STRUCT_ROOT: &str = "value-struct";

/// Render a **population-B value struct**'s `structs.lisp` contribution (ADR-0042): the
/// `defclass`, its residual `defmethod`s, and its `(defun ns:make-<struct> …)` value-owner
/// constructors. Returns `(body, qualified-export-symbols)`, or `None` when the struct has
/// no bindable trampoline (no forms then). The exported symbols are the struct's CLOS class
/// name and its constructor symbols; the method generics ride the framework's shared
/// generic set (folded in by `collect_generics`), so they are not re-exported here.
///
/// `generic_arity` is the framework's canonical (qualified-generic → arity) map
/// ([`crate::emit_generics::generic_arity_index`]). A residual method whose generic is
/// established at a DIFFERENT arity (a post-kebab selector clash, e.g. a value struct's
/// `format(_:)` colliding with an ObjC class's no-arg `ns:format`) is DROPPED: a CLOS
/// generic cannot carry methods of two arities, so emitting it would crash at load. The
/// trampoline + §6d count are unaffected — only the unloadable `defmethod` is skipped (the
/// generation-detail dual of the class-residual `objc_generics` collision drop).
pub fn generate_struct_file(
    st: &Struct,
    framework: &str,
    generic_arity: &BTreeMap<String, usize>,
) -> Option<(String, Vec<String>)> {
    let methods: Vec<_> = struct_residual_methods(framework, &st.name, &st.methods)
        .into_iter()
        .filter(|t| {
            let (name, arity) = t.generic_decl();
            arity_consistent(&name, arity, generic_arity)
        })
        .collect();
    let inits = struct_residual_inits(framework, &st.name, &st.methods);
    if methods.is_empty() && inits.is_empty() {
        return None;
    }

    let mut w = CodeWriter::new();
    let cls = qualified_class_name(&st.name);
    write_line!(
        w,
        ";; --- {} ({}) — Swift-native value-struct residual (ADR-0042) ---",
        st.name,
        framework
    );
    // The value-struct CLOS class: a plain class on the runtime `ns:value-struct` root
    // (the box rides its `ptr` slot), NOT an `objc-class` metaclass.
    write_line!(
        w,
        "(defclass {cls} ({}) ())",
        qualified_class_name(VALUE_STRUCT_ROOT)
    );

    let mut exports = vec![cls];
    for t in &methods {
        for line in t.render_defmethod().lines() {
            write_line!(w, "{}", line);
        }
    }
    for t in &inits {
        for line in t.render_constructor().lines() {
            write_line!(w, "{}", line);
        }
        exports.push(t.binding_symbol());
    }
    w.blank_line();

    Some((w.finish(), exports))
}

#[cfg(test)]
mod tests {
    use super::*;
    use apianyware_types::ir::{Method, Param, Struct, SwiftFnInfo};
    use apianyware_types::type_ref::{TypeRef, TypeRefKind};

    fn prim(name: &str) -> TypeRef {
        TypeRef {
            nullable: false,
            kind: TypeRefKind::Primitive { name: name.into() },
        }
    }
    fn idty() -> TypeRef {
        TypeRef {
            nullable: false,
            kind: TypeRefKind::Id,
        }
    }
    fn param(name: &str, t: TypeRef) -> Param {
        Param {
            name: name.into(),
            param_type: t,
        }
    }
    fn swift_method(selector: &str, init: bool, ret: TypeRef, params: Vec<Param>) -> Method {
        Method {
            selector: selector.into(),
            class_method: false,
            init_method: init,
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
            objc_exposed: false,
            swift_fn: Some(SwiftFnInfo::default()),
        }
    }
    fn value_struct(name: &str, methods: Vec<Method>) -> Struct {
        Struct {
            name: name.into(),
            fields: vec![],
            methods,
            source: None,
            provenance: None,
            doc_refs: None,
            objc_exposed: false,
        }
    }

    #[test]
    fn struct_file_emits_value_struct_class_methods_and_wrapping_constructor() {
        let st = value_struct(
            "IndexSet",
            vec![
                swift_method(
                    "contains(_:)",
                    false,
                    prim("bool"),
                    vec![param("_", prim("int64"))],
                ),
                swift_method(
                    "init(integer:)",
                    true,
                    idty(),
                    vec![param("integer", prim("int64"))],
                ),
            ],
        );
        let (body, exports) =
            generate_struct_file(&st, "Foundation", &BTreeMap::new()).expect("has bindings");

        // A plain CLOS class on the value-struct root (no objc-class metaclass).
        assert!(
            body.contains("(defclass ns:index-set (ns:value-struct) ())"),
            "{body}"
        );
        assert!(
            !body.contains("objc-class"),
            "value struct is not metaclass-backed: {body}"
        );
        // The method is a defmethod specialized on the struct's CLOS class, receiver via
        // the shared (aw-ptr self) path.
        assert!(
            body.contains("(defmethod ns:contains ((self ns:index-set) arg0)"),
            "{body}"
        );
        assert!(body.contains("(aw-ptr self)"), "{body}");
        // The constructor wraps the box into an instance.
        assert!(
            body.contains("(defun ns:make-index-set-integer (integer)"),
            "{body}"
        );
        assert!(body.contains("(make-instance 'ns:index-set :ptr"), "{body}");
        // Exports: the class symbol + the constructor symbol (method generics ride the
        // framework's shared generic set, not exported here).
        assert!(exports.contains(&"ns:index-set".to_string()), "{exports:?}");
        assert!(
            exports.contains(&"ns:make-index-set-integer".to_string()),
            "{exports:?}"
        );
    }

    #[test]
    fn struct_method_clashing_an_established_generic_arity_is_dropped() {
        // `ns:format` is canonically arity 0 (e.g. an ObjC class's no-arg `format`).
        // A value struct's `format(_:)` would emit a `(defmethod ns:format ((self …) arg0))`
        // of arity 1 — a CLOS congruence conflict that crashes at load. It must be DROPPED
        // (the trampoline + §6d count stay; only the unloadable defmethod goes), while a
        // non-conflicting method on the same struct still binds.
        let mut arity: BTreeMap<String, usize> = BTreeMap::new();
        arity.insert("ns:format".into(), 0);
        arity.insert("ns:contains".into(), 1);
        let st = value_struct(
            "ByteCountFormatStyle",
            vec![
                swift_method("format(_:)", false, idty(), vec![param("_", prim("int64"))]),
                swift_method(
                    "contains(_:)",
                    false,
                    prim("bool"),
                    vec![param("_", prim("int64"))],
                ),
            ],
        );
        let (body, _exports) =
            generate_struct_file(&st, "Foundation", &arity).expect("has bindings");
        assert!(
            !body.contains("(defmethod ns:format "),
            "the arity-conflicting defmethod is dropped:\n{body}"
        );
        assert!(
            body.contains("(defmethod ns:contains ((self ns:byte-count-format-style) arg0)"),
            "the non-conflicting method still binds:\n{body}"
        );
    }

    #[test]
    fn struct_file_is_none_without_bindable_residual() {
        // A value struct whose only "method" is ObjC-exposed (no swift_fn) has no residual.
        let mut m = swift_method("count", false, prim("int64"), vec![]);
        m.swift_fn = None;
        m.objc_exposed = true;
        let st = value_struct("Emptyish", vec![m]);
        assert!(generate_struct_file(&st, "Foundation", &BTreeMap::new()).is_none());
    }
}
