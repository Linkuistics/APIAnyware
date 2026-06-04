//! Gerbil C-function binding emission.
//!
//! Each emittable C function gets one `(define-c-lambda <name> (<args>) <ret>
//! "<name>")` binding — the short body form where the C-function-name string
//! makes Gambit emit a direct call. Two classes are skipped, as in chez: inline
//! functions (no exported symbol to call) and variadic functions (a
//! `define-c-lambda` is fixed-arity).
//!
//! Symbol resolution differs from chez. chez looks the symbol up at link time
//! across loaded shared objects (`foreign-procedure "name"`) and needs no
//! declaration; Gambit emits a real C call `name(args)`, so `name` must be
//! *declared*. Rather than `#include` the framework umbrella header (Objective-C,
//! which the bottle's default gcc-15 cannot parse), we **synthesize a C
//! prototype** per function — `extern <ret> NAME(<arg>…);`, spelling ObjC
//! pointer types as `void *` ([`c_proto_type`]) — so every crossing compiles
//! under the default compiler with no clang / `-x objective-c` (**ADR-0021**,
//! superseding design §4). A `bool` slot pulls in the C-safe `<stdbool.h>`.
//! By-value geometry struct args/returns additionally need their
//! `(c-define-type … (struct "…"))` declaration (FINDINGS §4), shared with the
//! class emitter via [`emit_geometry_decls`] (CoreGraphics headers `#include`d,
//! NS structs declared inline).
//!
//! The bindings are a thin **raw** FFI surface (like chez): an object-returning
//! C function hands back a raw `(pointer void)`, not a `wrap`ped object — these
//! free functions are a small utility surface (geometry/string/dispatch), and a
//! consumer that wants an object can `wrap` it. Object *arguments* are likewise
//! raw `(pointer void)`; a caller passes `(->ptr obj)`.

use std::collections::HashSet;

use apianyware_macos_emit::code_writer::CodeWriter;
use apianyware_macos_emit::ffi_type_mapping::FfiTypeMapper;
use apianyware_macos_emit::write_line;
use apianyware_macos_types::ir::Function;

use crate::ffi_type_mapping::{
    c_proto_type, emit_geometry_decls, geometry_decl, GeometryDecl, GerbilFfiTypeMapper,
};
use crate::shared_signatures::is_libdispatch_unexported;

/// True if a function can be emitted as a Gambit `define-c-lambda`.
fn is_emittable(f: &Function) -> bool {
    !f.inline && !f.variadic
}

/// Count emittable functions in a framework — used by the orchestrator to decide
/// whether to write `functions.ss` at all.
pub fn count_emittable(functions: &[Function]) -> usize {
    functions.iter().filter(|f| is_emittable(f)).count()
}

/// Names exported by `functions.ss` for a framework — emittable function names
/// in IR order, skipping the libdispatch-unexported allowlist.
pub fn function_emittable_names(functions: &[Function], framework: &str) -> Vec<String> {
    let is_libdispatch = framework == "libdispatch";
    functions
        .iter()
        .filter(|f| is_emittable(f))
        .filter(|f| !(is_libdispatch && is_libdispatch_unexported(&f.name)))
        .map(|f| f.name.clone())
        .collect()
}

/// Generate a Gerbil `functions.ss` module for one framework.
pub fn generate_functions_file(functions: &[Function], framework: &str) -> String {
    let mapper = GerbilFfiTypeMapper;
    let mut w = CodeWriter::new();
    let is_libdispatch = framework == "libdispatch";

    let emittable: Vec<&Function> = functions
        .iter()
        .filter(|f| is_emittable(f))
        .filter(|f| !(is_libdispatch && is_libdispatch_unexported(&f.name)))
        .collect();

    // Pre-compute each function's arg/return tokens (also feeds geometry decls).
    let crossings: Vec<(&Function, Vec<String>, String)> = emittable
        .iter()
        .map(|f| {
            let args: Vec<String> = f
                .params
                .iter()
                .map(|p| mapper.map_type(&p.param_type, false))
                .collect();
            let ret = mapper.map_type(&f.return_type, true);
            (*f, args, ret)
        })
        .collect();

    // By-value geometry structs anywhere in an arg/return slot need a
    // `c-define-type` + decl (CG header / inline NS struct) in the begin-ffi
    // prelude. A `bool` slot needs the C-safe `<stdbool.h>` for the prototype.
    let mut seen = HashSet::new();
    let mut geo: Vec<GeometryDecl> = Vec::new();
    let mut needs_stdbool = false;
    for (_, args, ret) in &crossings {
        for tok in args.iter().chain(std::iter::once(ret)) {
            if tok == "bool" {
                needs_stdbool = true;
            }
            if let Some(decl) = geometry_decl(tok) {
                if seen.insert(decl.token) {
                    geo.push(decl);
                }
            }
        }
    }

    write_line!(
        w,
        ";;; Generated C function bindings for {} — do not edit",
        framework
    );

    if crossings.is_empty() {
        w.line("(export)");
        return w.finish();
    }

    w.line("(import :std/foreign)");
    w.line("(export");
    for (f, _, _) in &crossings {
        write_line!(w, "  {}", f.name);
    }
    w.line("  )");
    w.blank_line();

    // begin-ffi export list: every emittable function name.
    w.line("(begin-ffi (");
    for (f, _, _) in &crossings {
        write_line!(w, "            {}", f.name);
    }
    w.line("            )");
    // Synthesized C declarations only — no framework umbrella `#include`
    // (ADR-0021), so the unit compiles under the default gcc-15.
    if needs_stdbool {
        w.line("  (c-declare \"#include <stdbool.h>\")");
    }
    emit_geometry_decls(&mut w, &geo);
    for (f, args, ret) in &crossings {
        let proto_args: Vec<String> = args.iter().map(|a| c_proto_type(a)).collect();
        let proto_args = if proto_args.is_empty() {
            "void".to_string()
        } else {
            proto_args.join(", ")
        };
        write_line!(
            w,
            "  (c-declare \"extern {} {}({});\")",
            c_proto_type(ret),
            f.name,
            proto_args
        );
    }
    w.blank_line();

    for (f, args, ret) in &crossings {
        write_line!(
            w,
            "  (define-c-lambda {} ({}) {} \"{}\")",
            f.name,
            args.join(" "),
            ret,
            f.name
        );
    }
    w.line("  )");

    w.finish()
}

#[cfg(test)]
mod tests {
    use super::*;
    use apianyware_macos_types::ir::{Function, Param};
    use apianyware_macos_types::type_ref::{TypeRef, TypeRefKind};

    fn param(name: &str, kind: TypeRefKind) -> Param {
        Param {
            name: name.into(),
            param_type: TypeRef {
                nullable: false,
                kind,
            },
        }
    }

    fn func(
        name: &str,
        params: Vec<Param>,
        ret: TypeRefKind,
        inline: bool,
        variadic: bool,
    ) -> Function {
        Function {
            name: name.into(),
            params,
            return_type: TypeRef {
                nullable: false,
                kind: ret,
            },
            inline,
            variadic,
            source: None,
            provenance: None,
            doc_refs: None,
        }
    }

    #[test]
    fn simple_function_emits_synthesized_prototype_not_umbrella() {
        let fs = vec![func(
            "TKComputeDistance",
            vec![
                param("x", TypeRefKind::Primitive { name: "double".into() }),
                param("y", TypeRefKind::Primitive { name: "double".into() }),
            ],
            TypeRefKind::Primitive { name: "double".into() },
            false,
            false,
        )];
        let out = generate_functions_file(&fs, "TestKit");
        assert!(out.contains(";;; Generated C function bindings for TestKit"));
        // ADR-0021: synthesized prototype, no umbrella #include.
        assert!(!out.contains("#include <TestKit/TestKit.h>"));
        assert!(out.contains("(c-declare \"extern double TKComputeDistance(double, double);\")"));
        assert!(out.contains(
            "(define-c-lambda TKComputeDistance (double double) double \"TKComputeDistance\")"
        ));
    }

    #[test]
    fn zero_arg_function_prototype_uses_void_param_list() {
        let fs = vec![func(
            "TKReset",
            vec![],
            TypeRefKind::Primitive { name: "void".into() },
            false,
            false,
        )];
        let out = generate_functions_file(&fs, "TestKit");
        // A zero-arg C prototype spells `(void)`, not `()`.
        assert!(out.contains("(c-declare \"extern void TKReset(void);\")"));
        assert!(out.contains("(define-c-lambda TKReset () void \"TKReset\")"));
    }

    #[test]
    fn bool_slot_pulls_in_stdbool() {
        let fs = vec![func(
            "TKToggle",
            vec![param("on", TypeRefKind::Primitive { name: "bool".into() })],
            TypeRefKind::Primitive { name: "bool".into() },
            false,
            false,
        )];
        let out = generate_functions_file(&fs, "TestKit");
        assert!(out.contains("(c-declare \"#include <stdbool.h>\")"));
        assert!(out.contains("(c-declare \"extern bool TKToggle(bool);\")"));
    }

    #[test]
    fn inline_and_variadic_are_skipped() {
        let fs = vec![
            func(
                "TKFastHash",
                vec![param("d", TypeRefKind::Pointer)],
                TypeRefKind::Primitive { name: "uint64".into() },
                true,
                false,
            ),
            func(
                "TKLog",
                vec![param("fmt", TypeRefKind::CString)],
                TypeRefKind::Primitive { name: "void".into() },
                false,
                true,
            ),
        ];
        let out = generate_functions_file(&fs, "TestKit");
        assert!(!out.contains("TKFastHash"));
        assert!(!out.contains("TKLog"));
        assert_eq!(count_emittable(&fs), 0);
    }

    #[test]
    fn function_returning_id_maps_to_raw_pointer() {
        let fs = vec![func("TKMakeWidget", vec![], TypeRefKind::Id, false, false)];
        let out = generate_functions_file(&fs, "TestKit");
        // ObjC pointer return collapses to `void *` in the synthesized prototype.
        assert!(out.contains("(c-declare \"extern void * TKMakeWidget(void);\")"));
        assert!(out.contains(
            "(define-c-lambda TKMakeWidget () (pointer void) \"TKMakeWidget\")"
        ));
        // Raw FFI surface — no wrapping, no runtime import.
        assert!(!out.contains(":gerbil-bindings/runtime/objc"));
        assert!(!out.contains("wrap"));
    }

    #[test]
    fn by_value_cg_geometry_includes_header_and_struct_proto() {
        let fs = vec![func(
            "TKBounds",
            vec![param(
                "r",
                TypeRefKind::Struct { name: "CGRect".into() },
            )],
            TypeRefKind::Struct { name: "CGPoint".into() },
            false,
            false,
        )];
        let out = generate_functions_file(&fs, "TestKit");
        assert!(out.contains("(c-define-type CGRect (struct \"CGRect\"))"));
        assert!(out.contains("(c-define-type CGPoint (struct \"CGPoint\"))"));
        // CoreGraphics headers are C-safe — kept.
        assert!(out.contains("(c-declare \"#include <CoreGraphics/CGGeometry.h>\")"));
        // The prototype spells the by-value structs as `struct <tag>`.
        assert!(out.contains("(c-declare \"extern struct CGPoint TKBounds(struct CGRect);\")"));
        assert!(out.contains("(define-c-lambda TKBounds (CGRect) CGPoint \"TKBounds\")"));
    }

    #[test]
    fn ns_geometry_emits_inline_struct_not_umbrella() {
        // An NS-prefixed geometry struct gets an ABI-exact inline plain-C decl —
        // never the non-C-safe Foundation/AppKit header.
        let fs = vec![func(
            "TKMakeRange",
            vec![param("len", TypeRefKind::Primitive { name: "uint64".into() })],
            TypeRefKind::Struct { name: "NSRange".into() },
            false,
            false,
        )];
        let out = generate_functions_file(&fs, "TestKit");
        assert!(out.contains(
            "(c-declare \"struct _NSRange { unsigned long location; unsigned long length; };\")"
        ));
        assert!(out.contains("(c-define-type NSRange (struct \"_NSRange\"))"));
        assert!(!out.contains("#include <Foundation/"));
        assert!(out.contains(
            "(c-declare \"extern struct _NSRange TKMakeRange(unsigned long long);\")"
        ));
    }

    #[test]
    fn libdispatch_synthesizes_prototypes_and_skips_unexported() {
        let fs = vec![
            func(
                "dispatch_async",
                vec![param("q", TypeRefKind::Id), param("blk", TypeRefKind::Pointer)],
                TypeRefKind::Primitive { name: "void".into() },
                false,
                false,
            ),
            func(
                "dispatch_cancel",
                vec![param("q", TypeRefKind::Id)],
                TypeRefKind::Primitive { name: "void".into() },
                false,
                false,
            ),
        ];
        let out = generate_functions_file(&fs, "libdispatch");
        // ADR-0021: no umbrella; synthesized prototype with ObjC ptrs as void *.
        assert!(!out.contains("#include <dispatch/dispatch.h>"));
        assert!(out.contains("(c-declare \"extern void dispatch_async(void *, void *);\")"));
        assert!(out.contains("dispatch_async"));
        assert!(!out.contains("dispatch_cancel"));
    }

    #[test]
    fn empty_functions_emit_empty_export() {
        let out = generate_functions_file(&[], "TestKit");
        assert!(out.contains("(export)"));
        assert!(!out.contains("begin-ffi"));
    }

    #[test]
    fn emittable_names_skip_inline_variadic_and_unexported() {
        let fs = vec![
            func("dispatch_async", vec![], TypeRefKind::Primitive { name: "void".into() }, false, false),
            func("dispatch_cancel", vec![], TypeRefKind::Primitive { name: "void".into() }, false, false),
        ];
        assert_eq!(
            function_emittable_names(&fs, "libdispatch"),
            vec!["dispatch_async".to_string()]
        );
    }
}
