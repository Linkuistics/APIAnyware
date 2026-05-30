//! Chez delegate-protocol emission.
//!
//! For each ObjC `@protocol` with at least one method, emit a Chez library
//! that exposes:
//!
//! - `<proto>-selectors` — list of every selector the protocol declares.
//! - `make-<proto>` — variadic constructor taking alternating selector
//!   strings and handler procedures, returning a `delegate` record from
//!   `(apianyware runtime dispatch)`.
//!
//! The runtime's `make-delegate` is monomorphic: it takes one list of
//! 4-tuples `(selector proc param-types return-type)`. Per-protocol code
//! generation lets us look up the `param-types` / `return-type` for each
//! selector from a static table without forcing every caller to spell
//! them out.

use apianyware_macos_emit::code_writer::CodeWriter;
use apianyware_macos_emit::naming::class_name_to_lowercase;
use apianyware_macos_emit::write_line;
use apianyware_macos_types::ir::{Method, Protocol};
use apianyware_macos_types::type_ref::{TypeRef, TypeRefKind};

/// Names exported by a protocol file.
pub fn protocol_exports(proto: &Protocol) -> Vec<String> {
    let lower = class_name_to_lowercase(&proto.name);
    vec![format!("make-{lower}"), format!("{lower}-selectors")]
}

/// Map an IR method return type to the chez sym `make-delegate` expects.
fn return_type_sym(t: &TypeRef) -> &'static str {
    match &t.kind {
        TypeRefKind::Primitive { name } => match name.to_ascii_lowercase().as_str() {
            "void" => "void",
            "bool" => "boolean",
            "int8" | "int16" | "int32" => "int-32",
            "uint8" | "uint16" | "uint32" => "unsigned-32",
            "int64" | "nsinteger" => "int-64",
            "uint64" | "nsuinteger" => "unsigned-64",
            _ => "void*",
        },
        TypeRefKind::Class { .. } | TypeRefKind::Id | TypeRefKind::Instancetype => "void*",
        _ => "void*",
    }
}

/// Generate a Chez protocol library for one delegate-style protocol.
pub fn generate_protocol_file(proto: &Protocol, framework: &str) -> String {
    let fw_low = framework.to_ascii_lowercase();
    let proto_low = class_name_to_lowercase(&proto.name);
    let mut w = CodeWriter::new();

    let all_methods: Vec<&Method> = proto
        .required_methods
        .iter()
        .chain(proto.optional_methods.iter())
        .collect();

    write_line!(
        w,
        ";; Generated protocol definition for {} ({}) — do not edit",
        proto.name,
        framework
    );
    write_line!(
        w,
        "(library (apianyware {} protocols {})",
        fw_low,
        proto_low
    );
    let make_name = format!("make-{proto_low}");
    let selectors_name = format!("{proto_low}-selectors");
    w.line("  (export");
    write_line!(w, "    {}", make_name);
    write_line!(w, "    {}", selectors_name);
    w.line("    )");
    w.line("  (import (chezscheme)");
    w.line("          (apianyware runtime dispatch))");
    w.blank_line();

    // Selector list — the runtime needs it for client `set-delegate-method`
    // lookup as well as introspection.
    write_line!(w, "  (define {}", selectors_name);
    if all_methods.is_empty() {
        w.line("    '())");
    } else {
        w.line("    '(");
        for m in &all_methods {
            write_line!(w, "      \"{}\"", m.selector);
        }
        w.line("      ))");
    }
    w.blank_line();

    // Static dispatch table: selector → (param-types, return-type-sym).
    // Used by make-<proto> to assemble the (selector proc param-types ret)
    // 4-tuple that runtime/dispatch.sls's make-delegate expects.
    w.line("  ;; selector → (param-types-list return-type-sym)");
    w.line("  (define %method-info");
    if all_methods.is_empty() {
        w.line("    '())");
    } else {
        w.line("    '(");
        for m in &all_methods {
            // Swift trampoline strips self/_cmd and passes the remaining
            // args as void*; the handler proc sees the same. Future leaves
            // may opt-in to richer param signalling; for parity-with-racket
            // here we just emit void*-per-param.
            let pts: Vec<&str> = m.params.iter().map(|_| "void*").collect();
            let ret = return_type_sym(&m.return_type);
            write_line!(
                w,
                "      (\"{}\" ({}) {})",
                m.selector,
                pts.join(" "),
                ret
            );
        }
        w.line("      ))");
    }
    w.blank_line();

    w.line("  (define (%lookup-info sel)");
    w.line("    (let loop ([xs %method-info])");
    w.line("      (cond");
    write_line!(
        w,
        "        [(null? xs) (error '{} \"unknown selector for protocol\" sel)]",
        make_name
    );
    w.line("        [(string=? (car (car xs)) sel) (car xs)]");
    w.line("        [else (loop (cdr xs))])))");
    w.blank_line();

    write_line!(w, "  (define ({} . selector+handler-pairs)", make_name);
    w.line("    (let loop ([rest selector+handler-pairs]");
    w.line("               [specs '()])");
    w.line("      (cond");
    w.line("        [(null? rest) (make-delegate (reverse specs))]");
    w.line("        [(null? (cdr rest))");
    write_line!(
        w,
        "         (error '{} \"odd number of arguments — expected selector handler pairs\")]",
        make_name
    );
    w.line("        [else");
    w.line("         (let* ([sel  (car rest)]");
    w.line("                [proc (cadr rest)]");
    w.line("                [info (%lookup-info sel)])");
    w.line("           (loop (cddr rest)");
    w.line("                 (cons (list sel proc (cadr info) (caddr info)) specs)))])))");

    w.blank_line();
    w.line(")");
    w.finish()
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
        }
    }

    #[test]
    fn emits_library_with_exports_and_imports() {
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
        assert!(out.contains("(library (apianyware appkit protocols nswindowdelegate)"));
        assert!(out.contains("    make-nswindowdelegate"));
        assert!(out.contains("    nswindowdelegate-selectors"));
        assert!(out.contains("(apianyware runtime dispatch)"));
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
    fn method_info_table_maps_return_types() {
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
                m(
                    "produceResult",
                    vec![],
                    TypeRefKind::Instancetype,
                ),
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
        assert!(out.contains("(\"didStart:\" (void*) void)"));
        assert!(out.contains("(\"shouldContinue\" () boolean)"));
        assert!(out.contains("(\"produceResult\" () void*)"));
        assert!(out.contains("(\"numberOfRowsInTableView:\" (void*) int-64)"));
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
