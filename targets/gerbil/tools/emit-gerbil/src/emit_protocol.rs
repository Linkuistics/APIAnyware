//! Gerbil delegate-protocol emission.
//!
//! For each ObjC `@protocol` declaring ≥1 method, emit a Gerbil `.ss` module
//! exposing:
//!
//! - `<proto>-selectors` — the list of every selector the protocol declares.
//! - `make-<proto>` — a variadic constructor taking alternating selector
//!   strings and handler procedures, returning a delegate object built by the
//!   runtime's `make-delegate` (the `DelegateBridge` constructor, leaf 050).
//!
//! The runtime's `make-delegate` is monomorphic: it takes one list of
//! 4-tuples `(selector proc param-types return-type)`. Generating per-protocol
//! lets the emitter bake a static `selector → (param-types, return-type)` table
//! straight from the IR, so a client wiring a handler never spells ABI types —
//! they fall out of [`ffi_type_mapping`](crate::ffi_type_mapping), the same
//! Gambit FFI token vocabulary the class crossings use.
//!
//! ## Divergence from emit-chez
//!
//! Two source-form differences from `emit-chez/src/emit_protocol.rs`, both
//! Gerbil-idiomatic:
//!
//! - **Module shape.** Gerbil `.ss` modules use bare top-level `(import …)` /
//!   `(export …)` then body, not chez's enclosing `(library … )` (matches the
//!   gerbil class modules — `emit_class::emit_header`).
//! - **Type tokens.** chez's table emitted `void*`-per-param and a small
//!   return-symbol set; here each param **and** the return reduce through
//!   [`GerbilFfiTypeMapper`](crate::ffi_type_mapping::GerbilFfiTypeMapper) to a
//!   real Gambit FFI token (`(pointer void)`, `bool`, `int64`, …) — EXCEPT an
//!   ObjC object, emitted as the marker `object` (see [`spec_token`]) so the
//!   bridge `wrap`s it while passing a raw `(pointer void)` (a `BOOL*`, a block,
//!   a `SEL`) straight through. The native delegate bridge (leaf 050) reads
//!   these as the per-selector marshalling spec.
//!
//! ## Runtime contract (owned by leaf 050)
//!
//! Emitted against `:gerbil-bindings/runtime/objc`:
//! - **`(make-delegate specs)`** — `specs` is a list of `(selector-string proc
//!   (param-token …) return-token)` 4-tuples; builds and returns a delegate
//!   object whose synthesized ObjC IMPs (the native-core `DelegateBridge`,
//!   design §6) dispatch each protocol selector into its registered Gerbil
//!   `proc`, marshalling args/return per the tokens. The alternating
//!   selector/handler calling shape and this 4-tuple spec are this leaf's
//!   proposal; an inbox note to 050 records it so the runtime matches.

use apianyware_emit::code_writer::CodeWriter;
use apianyware_emit::ffi_type_mapping::FfiTypeMapper;
use apianyware_emit::naming::class_name_to_lowercase;
use apianyware_emit::write_line;
use apianyware_types::ir::{Method, Protocol};
use apianyware_types::type_ref::{TypeRef, TypeRefKind};

use crate::ffi_type_mapping::GerbilFfiTypeMapper;

/// The runtime module the generated protocol binds against (`make-delegate`).
const RUNTIME_OBJC_IMPORT: &str = ":gerbil-bindings/runtime/objc";

/// The delegate-bridge spec token for one callback param / return.
///
/// Diverges from the plain `define-c-lambda` crossing token in ONE way that the
/// native bridge needs: an ObjC **object** (`id`/`Class<…>`/`instancetype`) is
/// emitted as the marker `object`, NOT `(pointer void)`. Both are pointer-width,
/// but the bridge must `wrap` an object into a bound instance while passing a
/// *raw* C pointer (`(pointer void)` — a `BOOL*` out-param, a block, a `SEL`)
/// straight through: `object_getClass` on a non-object pointer dereferences
/// garbage and crashes (leaf 050/020 finding). Everything else reduces through
/// the shared [`GerbilFfiTypeMapper`] exactly as the crossings do.
fn spec_token(t: &TypeRef, is_return: bool, mapper: &GerbilFfiTypeMapper) -> String {
    match &t.kind {
        TypeRefKind::Class { .. } | TypeRefKind::Id { .. } | TypeRefKind::Instancetype => {
            "object".to_string()
        }
        _ => mapper.map_type(t, is_return),
    }
}

/// Names exported by a protocol module.
pub fn protocol_exports(proto: &Protocol) -> Vec<String> {
    let lower = class_name_to_lowercase(&proto.name);
    vec![format!("make-{lower}"), format!("{lower}-selectors")]
}

/// Every method a protocol declares, required first then optional — the set the
/// selector list and the static dispatch table are built over.
fn all_methods(proto: &Protocol) -> Vec<&Method> {
    proto
        .required_methods
        .iter()
        .chain(proto.optional_methods.iter())
        .collect()
}

/// Generate a Gerbil protocol module for one delegate-style protocol.
pub fn generate_protocol_file(proto: &Protocol, framework: &str) -> String {
    let proto_low = class_name_to_lowercase(&proto.name);
    let make_name = format!("make-{proto_low}");
    let selectors_name = format!("{proto_low}-selectors");
    let mapper = GerbilFfiTypeMapper;
    let methods = all_methods(proto);

    let mut w = CodeWriter::new();
    write_line!(
        w,
        ";;; Generated protocol binding for {} ({}) — do not edit",
        proto.name,
        framework
    );
    write_line!(w, "(import {})", RUNTIME_OBJC_IMPORT);
    w.line("(export");
    write_line!(w, "  {}", make_name);
    write_line!(w, "  {}", selectors_name);
    w.line("  )");
    w.blank_line();

    // Selector list — every selector the protocol declares, for client
    // introspection and `set-delegate-method`-style lookup.
    write_line!(w, "(define {}", selectors_name);
    if methods.is_empty() {
        w.line("  '())");
    } else {
        w.line("  '(");
        for m in &methods {
            write_line!(w, "    \"{}\"", m.selector);
        }
        w.line("    ))");
    }
    w.blank_line();

    // Static dispatch table: selector → (param-tokens… return-token). The
    // tokens are Gambit FFI types (ffi_type_mapping); `make-<proto>` reads them
    // to build the (selector proc param-types return-type) 4-tuple the runtime's
    // make-delegate expects, so callers never spell ABI types.
    w.line(";; selector → ((param-tokens …) return-token) — delegate bridge spec");
    w.line("(define %method-info");
    if methods.is_empty() {
        w.line("  '())");
    } else {
        w.line("  '(");
        for m in &methods {
            let pts: Vec<String> = m
                .params
                .iter()
                .map(|p| spec_token(&p.param_type, false, &mapper))
                .collect();
            let ret = spec_token(&m.return_type, true, &mapper);
            write_line!(w, "    (\"{}\" ({}) {})", m.selector, pts.join(" "), ret);
        }
        w.line("    ))");
    }
    w.blank_line();

    write_line!(w, "(define (%lookup-info sel)");
    w.line("  (let loop ((xs %method-info))");
    w.line("    (cond");
    write_line!(
        w,
        "      ((null? xs) (error \"{}: unknown selector for protocol\" sel))",
        make_name
    );
    w.line("      ((string=? (car (car xs)) sel) (car xs))");
    w.line("      (else (loop (cdr xs))))))");
    w.blank_line();

    write_line!(w, "(define ({} . selector+handler-pairs)", make_name);
    w.line("  (let loop ((rest selector+handler-pairs)");
    w.line("             (specs '()))");
    w.line("    (cond");
    w.line("      ((null? rest) (make-delegate (reverse specs)))");
    write_line!(
        w,
        "      ((null? (cdr rest)) (error \"{}: odd number of arguments — expected selector handler pairs\"))",
        make_name
    );
    w.line("      (else");
    w.line("       (let* ((sel  (car rest))");
    w.line("              (proc (cadr rest))");
    w.line("              (info (%lookup-info sel)))");
    w.line("         (loop (cddr rest)");
    w.line("               (cons (list sel proc (cadr info) (caddr info)) specs)))))))");

    w.finish()
}

#[cfg(test)]
mod tests {
    use super::*;
    use apianyware_types::ir::{Method, Param, Protocol};
    use apianyware_types::type_ref::{TypeRef, TypeRefKind};

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

    #[test]
    fn emits_module_with_imports_and_exports() {
        let p = proto(
            "NSWindowDelegate",
            vec![],
            vec![m(
                "windowWillClose:",
                vec![obj_param("notification", "NSNotification")],
                TypeRefKind::Primitive {
                    name: "void".into(),
                },
            )],
        );
        let out = generate_protocol_file(&p, "AppKit");
        // Bare-module form, not chez's `(library …)`.
        assert!(!out.contains("(library"));
        assert!(out.contains(";;; Generated protocol binding for NSWindowDelegate (AppKit)"));
        assert!(out.contains("(import :gerbil-bindings/runtime/objc)"));
        assert!(out.contains("  make-nswindowdelegate"));
        assert!(out.contains("  nswindowdelegate-selectors"));
    }

    #[test]
    fn selector_list_lists_every_method() {
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
        let out = generate_protocol_file(&p, "TestKit");
        assert!(out.contains("\"didStart\""));
        assert!(out.contains("\"shouldContinue\""));
    }

    #[test]
    fn method_info_table_uses_gambit_ffi_tokens() {
        let p = proto(
            "TKMixed",
            vec![
                m(
                    "didStart:",
                    vec![obj_param("x", "NSObject")],
                    TypeRefKind::Primitive {
                        name: "void".into(),
                    },
                ),
                m(
                    "shouldContinue",
                    vec![],
                    TypeRefKind::Primitive {
                        name: "bool".into(),
                    },
                ),
                m("produceResult", vec![], TypeRefKind::Instancetype),
                m(
                    "numberOfRowsInTableView:",
                    vec![obj_param("tv", "NSTableView")],
                    TypeRefKind::Primitive {
                        name: "int64".into(),
                    },
                ),
            ],
            vec![],
        );
        let out = generate_protocol_file(&p, "TestKit");
        // Object param → the `object` marker (the bridge wraps it); void/bool/
        // int64 returns idiomatic.
        assert!(out.contains("(\"didStart:\" (object) void)"));
        assert!(out.contains("(\"shouldContinue\" () bool)"));
        // instancetype return → the `object` marker too (a wrappable result).
        assert!(out.contains("(\"produceResult\" () object)"));
        assert!(out.contains("(\"numberOfRowsInTableView:\" (object) int64)"));
    }

    #[test]
    fn constructor_dispatches_via_make_delegate() {
        let p = proto(
            "TKEmpty",
            vec![],
            vec![m(
                "noop",
                vec![],
                TypeRefKind::Primitive {
                    name: "void".into(),
                },
            )],
        );
        let out = generate_protocol_file(&p, "TestKit");
        assert!(out.contains("(define (make-tkempty . selector+handler-pairs)"));
        assert!(out.contains("(make-delegate (reverse specs))"));
        assert!(out.contains("%lookup-info"));
    }

    #[test]
    fn protocol_exports_helper_returns_two_names() {
        let p = proto(
            "TKWindowDelegate",
            vec![m(
                "windowWillClose:",
                vec![obj_param("n", "NSObject")],
                TypeRefKind::Primitive {
                    name: "void".into(),
                },
            )],
            vec![],
        );
        assert_eq!(
            protocol_exports(&p),
            vec![
                "make-tkwindowdelegate".to_string(),
                "tkwindowdelegate-selectors".into(),
            ]
        );
    }
}
