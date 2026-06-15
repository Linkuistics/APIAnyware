//! Chez C-function binding emission.
//!
//! Each emittable function gets one `(define <name> (foreign-procedure …))`
//! binding. Inline functions are skipped (no exported symbol) and variadic
//! functions are skipped (Chez `foreign-procedure` requires a fixed
//! arity; the chez idiom of declaring multiple per-call-site variants
//! is out of scope for the constants/functions file).
//!
//! Symbol resolution: `foreign-procedure` looks up the C symbol across
//! every shared object the chez session has loaded. We emit a
//! `(load-shared-object …)` for the framework's dylib at file load so
//! the declarations following it resolve. libdispatch maps to
//! `libSystem.dylib`; everything else points at the framework binary.

use apianyware_macos_emit::code_writer::CodeWriter;
use apianyware_macos_emit::ffi_type_mapping::FfiTypeMapper;
use apianyware_macos_emit::write_line;
use apianyware_macos_types::ir::Function;

use crate::ffi_type_mapping::ChezFfiTypeMapper;
use crate::shared_signatures::{framework_shared_object_arg, is_libdispatch_unexported};

/// True if a function can be emitted as a Chez `foreign-procedure`.
fn is_emittable(f: &Function) -> bool {
    !f.inline && !f.variadic
}

/// Count emittable functions in a framework — used by the orchestrator to
/// decide whether to write `functions.sls` at all.
pub fn count_emittable(functions: &[Function]) -> usize {
    functions.iter().filter(|f| is_emittable(f)).count()
}

/// Names exported by `functions.sls` for a framework — emittable function
/// names in IR order, skipping the libdispatch-unexported allowlist.
pub fn function_emittable_names(functions: &[Function], framework: &str) -> Vec<String> {
    let is_libdispatch = framework == "libdispatch";
    functions
        .iter()
        .filter(|f| is_emittable(f))
        .filter(|f| !(is_libdispatch && is_libdispatch_unexported(&f.name)))
        .map(|f| f.name.clone())
        .collect()
}

/// Generate a Chez `functions.sls` library for one framework.
pub fn generate_functions_file(functions: &[Function], framework: &str) -> String {
    let mapper = ChezFfiTypeMapper;
    let fw_low = framework.to_ascii_lowercase();
    let mut w = CodeWriter::new();

    write_line!(
        w,
        ";; Generated C function bindings for {} — do not edit",
        framework
    );
    write_line!(w, "(library (apianyware {} functions)", fw_low);

    let exports = function_emittable_names(functions, framework);
    if exports.is_empty() {
        w.line("  (export)");
    } else {
        w.line("  (export");
        for n in &exports {
            write_line!(w, "    {}", n);
        }
        w.line("    )");
    }
    // `(apianyware runtime types)` exports the geometry ftypes
    // (`NSRect`, `NSPoint`, …) that `(& <ftype>)` argument forms refer to
    // in `foreign-procedure` declarations. Importing it unconditionally
    // keeps the emission rule simple — the runtime is always loaded for
    // any chez consumer.
    w.line("  (import (chezscheme)");
    w.line("          (apianyware runtime types))");
    w.blank_line();
    // R6RS library bodies require every definition to precede any
    // expression. Hide the dylib load inside a dummy `define`'s RHS so
    // the load runs at library instantiation without blocking the
    // following `(define …)` lines. Mirror `runtime/ffi.sls`'s pattern.
    write_line!(
        w,
        "  (define %fw-lib-loaded (begin (load-shared-object \"{}\") #t))",
        framework_shared_object_arg(framework)
    );
    w.blank_line();

    let is_libdispatch = framework == "libdispatch";
    let emittable: Vec<&Function> = functions
        .iter()
        .filter(|f| is_emittable(f))
        .filter(|f| !(is_libdispatch && is_libdispatch_unexported(&f.name)))
        .collect();

    for func in &emittable {
        let param_types: Vec<String> = func
            .params
            .iter()
            .map(|p| mapper.map_type(&p.param_type, false))
            .collect();
        let return_type = mapper.map_type(&func.return_type, true);
        let arglist = if param_types.is_empty() {
            String::new()
        } else {
            param_types.join(" ")
        };
        write_line!(
            w,
            "  (define {} (foreign-procedure \"{}\" ({}) {}))",
            func.name,
            func.name,
            arglist,
            return_type
        );
    }

    w.blank_line();
    w.line(")");
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
            objc_exposed: true,
        }
    }

    #[test]
    fn simple_function_emits_foreign_procedure() {
        let fs = vec![func(
            "TKComputeDistance",
            vec![
                param(
                    "x",
                    TypeRefKind::Primitive {
                        name: "double".into(),
                    },
                ),
                param(
                    "y",
                    TypeRefKind::Primitive {
                        name: "double".into(),
                    },
                ),
            ],
            TypeRefKind::Primitive {
                name: "double".into(),
            },
            false,
            false,
        )];
        let out = generate_functions_file(&fs, "TestKit");
        assert!(out.contains("(library (apianyware testkit functions)"));
        assert!(out.contains(
            "(define TKComputeDistance (foreign-procedure \"TKComputeDistance\" (double-float double-float) double-float))"
        ));
    }

    #[test]
    fn zero_arg_function_emits_empty_param_list() {
        let fs = vec![func(
            "TKReset",
            vec![],
            TypeRefKind::Primitive {
                name: "void".into(),
            },
            false,
            false,
        )];
        let out = generate_functions_file(&fs, "TestKit");
        assert!(out.contains("(define TKReset (foreign-procedure \"TKReset\" () void))"));
    }

    #[test]
    fn inline_function_is_skipped() {
        let fs = vec![func(
            "TKFastHash",
            vec![param("d", TypeRefKind::Pointer)],
            TypeRefKind::Primitive {
                name: "uint64".into(),
            },
            true,
            false,
        )];
        let out = generate_functions_file(&fs, "TestKit");
        assert!(!out.contains("TKFastHash"));
    }

    #[test]
    fn variadic_function_is_skipped() {
        let fs = vec![func(
            "TKLog",
            vec![param("fmt", TypeRefKind::CString)],
            TypeRefKind::Primitive {
                name: "void".into(),
            },
            false,
            true,
        )];
        let out = generate_functions_file(&fs, "TestKit");
        assert!(!out.contains("TKLog"));
    }

    #[test]
    fn count_emittable_filters_inline_and_variadic() {
        let fs = vec![
            func(
                "A",
                vec![],
                TypeRefKind::Primitive {
                    name: "void".into(),
                },
                false,
                false,
            ),
            func(
                "B",
                vec![],
                TypeRefKind::Primitive {
                    name: "void".into(),
                },
                true,
                false,
            ),
            func(
                "C",
                vec![],
                TypeRefKind::Primitive {
                    name: "void".into(),
                },
                false,
                true,
            ),
        ];
        assert_eq!(count_emittable(&fs), 1);
    }

    #[test]
    fn libdispatch_loads_libsystem_and_skips_unexported() {
        let fs = vec![
            func(
                "dispatch_async",
                vec![
                    param("q", TypeRefKind::Id),
                    param("blk", TypeRefKind::Pointer),
                ],
                TypeRefKind::Primitive {
                    name: "void".into(),
                },
                false,
                false,
            ),
            func(
                "dispatch_cancel",
                vec![param("q", TypeRefKind::Id)],
                TypeRefKind::Primitive {
                    name: "void".into(),
                },
                false,
                false,
            ),
        ];
        let out = generate_functions_file(&fs, "libdispatch");
        assert!(out.contains("(load-shared-object \"libSystem.dylib\")"));
        assert!(out.contains("dispatch_async"));
        assert!(!out.contains("dispatch_cancel"));
    }

    #[test]
    fn function_returning_id_maps_to_void_ptr() {
        let fs = vec![func("TKMakeWidget", vec![], TypeRefKind::Id, false, false)];
        let out = generate_functions_file(&fs, "TestKit");
        assert!(out.contains("(define TKMakeWidget (foreign-procedure \"TKMakeWidget\" () void*))"));
    }

    #[test]
    fn empty_functions_emit_empty_export() {
        let out = generate_functions_file(&[], "TestKit");
        assert!(out.contains("  (export)"));
    }
}
