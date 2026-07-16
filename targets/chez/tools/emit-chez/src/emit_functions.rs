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
//! the direct declarations following it resolve. libdispatch maps to
//! `libSystem.dylib`; everything else points at the framework binary.
//!
//! **Swift-native residual (`objc_exposed == false`, ADR-0026 / leaf 060).** A
//! `s:` symbol is *not* a C export of the framework dylib — a direct
//! `foreign-procedure` to it would dangle. These declarations route to the
//! **trampolines** (ADR-0027, ported to chez): a `@_cdecl` re-export in
//! `libAPIAnywareChez` (already loaded by `(apianyware runtime ffi)`), bound here
//! with a plain `foreign-procedure` against the chez dylib's `aw_chez_swift_*`
//! entry and wrapped with Scheme-side coercion (`(apianyware runtime
//! swift-trampoline)`, ADR-0015). Decls that cannot be trampolined this leaf are
//! recorded as comments, never silently dropped (spec §5).

use apianyware_emit::code_writer::CodeWriter;
use apianyware_emit::ffi_type_mapping::FfiTypeMapper;
use apianyware_emit::write_line;
use apianyware_types::ir::{Function, Struct};

use crate::chez_builtins::chezscheme_import_spec;
use crate::ffi_type_mapping::ChezFfiTypeMapper;
use crate::shared_signatures::{framework_shared_object_arg, is_libdispatch_unexported};
use crate::trampoline::{classify_function, value_struct_names, FnDisposition, FnTrampoline};

/// True if a function is a **direct** (ObjC-exposed) Chez `foreign-procedure`
/// binding. Skips inline (no exported symbol) and variadic functions. The
/// Swift-native residual (`!objc_exposed`) is handled separately (trampolined).
fn is_emittable(f: &Function) -> bool {
    !f.inline && !f.variadic && f.objc_exposed
}

/// True if a Swift-native residual function is a trampoline *candidate* — i.e.
/// reaches the classifier at all (not inline/variadic).
fn is_residual_candidate(f: &Function) -> bool {
    !f.inline && !f.variadic && !f.objc_exposed
}

/// Classify a framework's residual functions into trampolines + deferred
/// recordings, using the framework's own value-struct set as the unbox gate. The
/// same `structs` the global pass sees, so the per-framework emitter and the
/// global `collect_trampolines` agree on trampoline-vs-deferred (the entry name
/// is content-addressed; agreement keeps a chez binding from dangling).
fn classify_residual<'a>(
    functions: &'a [Function],
    framework: &str,
    structs: &[Struct],
) -> (Vec<FnTrampoline>, Vec<(&'a Function, &'static str)>) {
    let value_structs = value_struct_names(structs);
    let mut tramps = Vec::new();
    let mut deferred = Vec::new();
    for func in functions.iter().filter(|f| is_residual_candidate(f)) {
        match classify_function(framework, func, functions, &value_structs) {
            FnDisposition::Trampoline(t) => tramps.push(t),
            FnDisposition::Deferred(reason) => deferred.push((func, reason.as_str())),
        }
    }
    (tramps, deferred)
}

/// Count functions a framework would emit a binding for (direct + trampolined) —
/// used by the orchestrator to decide whether to write `functions.sls` at all.
pub fn count_emittable(functions: &[Function], framework: &str, structs: &[Struct]) -> usize {
    function_emittable_names(functions, framework, structs).len()
}

/// Names exported by `functions.sls` for a framework — direct function names then
/// trampolined residual binding names, both in IR order, skipping the
/// libdispatch-unexported allowlist for the direct half.
pub fn function_emittable_names(
    functions: &[Function],
    framework: &str,
    structs: &[Struct],
) -> Vec<String> {
    let is_libdispatch = framework == "libdispatch";
    let mut names: Vec<String> = functions
        .iter()
        .filter(|f| is_emittable(f))
        .filter(|f| !(is_libdispatch && is_libdispatch_unexported(&f.name)))
        .map(|f| f.name.clone())
        .collect();
    let (tramps, _) = classify_residual(functions, framework, structs);
    names.extend(tramps.into_iter().map(|t| t.binding_name));
    names
}

/// Generate a Chez `functions.sls` library for one framework.
///
/// `structs` is the framework's own `Framework.structs` — the value-struct set
/// that gates the trampoline param-unbox path (spec §5c). It must be the same
/// slice the global trampoline pass sees.
pub fn generate_functions_file(
    functions: &[Function],
    framework: &str,
    structs: &[Struct],
) -> String {
    let mapper = ChezFfiTypeMapper;
    let fw_low = framework.to_ascii_lowercase();
    let is_libdispatch = framework == "libdispatch";
    let mut w = CodeWriter::new();

    let direct: Vec<&Function> = functions
        .iter()
        .filter(|f| is_emittable(f))
        .filter(|f| !(is_libdispatch && is_libdispatch_unexported(&f.name)))
        .collect();
    let (tramps, deferred) = classify_residual(functions, framework, structs);

    write_line!(
        w,
        ";; Generated C function bindings for {} — do not edit",
        framework
    );
    write_line!(w, "(library (apianyware {} functions)", fw_low);

    let exports = function_emittable_names(functions, framework, structs);
    if exports.is_empty() {
        w.line("  (export)");
    } else {
        w.line("  (export");
        for n in &exports {
            write_line!(w, "    {}", n);
        }
        w.line("    )");
    }
    // `(apianyware runtime types)` exports the geometry ftypes (`NSRect`,
    // `NSPoint`, …) that `(& <ftype>)` argument forms refer to in
    // `foreign-procedure` declarations, and transitively loads
    // `libAPIAnywareChez.dylib` (via `(apianyware runtime ffi)`), against which the
    // trampoline entries resolve. The trampoline coercers live in
    // `(apianyware runtime swift-trampoline)`, imported only when residual is present.
    // Free functions mirror C/libm names (`acos`, `cos`, …) which collide with
    // `(chezscheme)` builtins; except the offenders so the local define wins.
    write_line!(w, "  (import {}", chezscheme_import_spec(&exports));
    if tramps.is_empty() {
        w.line("          (apianyware runtime types))");
    } else {
        w.line("          (apianyware runtime types)");
        w.line("          (apianyware runtime swift-trampoline))");
    }
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

    // Direct (ObjC-exposed) bindings — bound against the framework dylib.
    for func in &direct {
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

    // Swift-native trampoline bindings — bound against libAPIAnywareChez via the
    // `aw_chez_swift_*` entries (ADR-0027 ported to chez; ADR-0015 Scheme-side
    // marshalling). The chez dylib is loaded by the runtime import above.
    if !tramps.is_empty() {
        w.blank_line();
        w.line("  ;; Swift-native residual — trampolined through libAPIAnywareChez");
        w.line("  ;; (aw_chez_swift_* entries) rather than the framework dylib (ADR-0027).");
        // Force libAPIAnywareChez to load before the entries below resolve: chez
        // instantiates a library lazily, so a pure-scalar trampoline file that uses
        // no coercer would otherwise never trigger the dylib load (see
        // swift-trampoline.sls). This reference must precede the foreign-procedures.
        w.line("  (define %aw-lib-ready aw-trampoline-lib-ready)");
        for t in &tramps {
            for line in t.render_chez().lines() {
                write_line!(w, "  {}", line);
            }
        }
    }

    // Deferred residual — recorded, never silently dropped (spec §5).
    if !deferred.is_empty() {
        w.blank_line();
        w.line("  ;; Deferred Swift-native residual (not trampolined this leaf):");
        for (func, reason) in &deferred {
            write_line!(w, "  ;;   {} — {}", func.name, reason);
        }
    }

    w.blank_line();
    w.line(")");
    w.finish()
}

#[cfg(test)]
mod tests {
    use super::*;
    use apianyware_types::ir::{Function, Param};
    use apianyware_types::type_ref::{TypeRef, TypeRefKind};

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
            swift_fn: None,
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
        let out = generate_functions_file(&fs, "TestKit", &[]);
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
        let out = generate_functions_file(&fs, "TestKit", &[]);
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
        let out = generate_functions_file(&fs, "TestKit", &[]);
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
        let out = generate_functions_file(&fs, "TestKit", &[]);
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
        assert_eq!(count_emittable(&fs, "TestKit", &[]), 1);
    }

    #[test]
    fn libdispatch_loads_libsystem_and_skips_unexported() {
        let fs = vec![
            func(
                "dispatch_async",
                vec![
                    param(
                        "q",
                        TypeRefKind::Id {
                            protocols: Vec::new(),
                        },
                    ),
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
                vec![param(
                    "q",
                    TypeRefKind::Id {
                        protocols: Vec::new(),
                    },
                )],
                TypeRefKind::Primitive {
                    name: "void".into(),
                },
                false,
                false,
            ),
        ];
        let out = generate_functions_file(&fs, "libdispatch", &[]);
        assert!(out.contains("(load-shared-object \"libSystem.dylib\")"));
        assert!(out.contains("dispatch_async"));
        assert!(!out.contains("dispatch_cancel"));
    }

    #[test]
    fn function_returning_id_maps_to_void_ptr() {
        let fs = vec![func(
            "TKMakeWidget",
            vec![],
            TypeRefKind::Id {
                protocols: Vec::new(),
            },
            false,
            false,
        )];
        let out = generate_functions_file(&fs, "TestKit", &[]);
        assert!(out.contains("(define TKMakeWidget (foreign-procedure \"TKMakeWidget\" () void*))"));
    }

    #[test]
    fn empty_functions_emit_empty_export() {
        let out = generate_functions_file(&[], "TestKit", &[]);
        assert!(out.contains("  (export)"));
    }

    // -----------------------------------------------------------------------
    // Swift-native residual routing (objc_exposed == false → trampolines)
    // -----------------------------------------------------------------------

    use apianyware_types::ir::SwiftFnInfo;

    /// A Swift-native (`objc_exposed == false`) function with the given `SwiftFnInfo`.
    fn swift_func(name: &str, params: Vec<Param>, ret: TypeRefKind, info: SwiftFnInfo) -> Function {
        Function {
            name: name.into(),
            params,
            return_type: TypeRef {
                nullable: false,
                kind: ret,
            },
            inline: false,
            variadic: false,
            source: None,
            provenance: None,
            doc_refs: None,
            objc_exposed: false,
            swift_fn: Some(info),
        }
    }

    fn nsstring_kind() -> TypeRefKind {
        TypeRefKind::Class {
            name: "NSString".into(),
            framework: Some("Foundation".into()),
            params: vec![],
        }
    }

    #[test]
    fn direct_and_trampoline_functions_route_to_different_symbols() {
        let fs = vec![
            // Direct ObjC-exposed C function — bound by its own C symbol.
            func(
                "TKComputeDistance",
                vec![param(
                    "x",
                    TypeRefKind::Primitive {
                        name: "double".into(),
                    },
                )],
                TypeRefKind::Primitive {
                    name: "double".into(),
                },
                false,
                false,
            ),
            // Swift-native scalar function — trampolined via the aw_chez_swift_* entry.
            swift_func(
                "TKSwiftScale",
                vec![param(
                    "factor",
                    TypeRefKind::Primitive {
                        name: "double".into(),
                    },
                )],
                TypeRefKind::Primitive {
                    name: "double".into(),
                },
                SwiftFnInfo::default(),
            ),
        ];
        let out = generate_functions_file(&fs, "TestKit", &[]);
        // Direct function binds its own C symbol.
        assert!(
            out.contains("(define TKComputeDistance (foreign-procedure \"TKComputeDistance\""),
            "{out}"
        );
        // Swift-native function binds the content-addressed trampoline entry.
        assert!(
            out.contains("(define TKSwiftScale (foreign-procedure \"aw_chez_swift_TestKit_TKSwiftScale\" (double-float) double-float))"),
            "{out}"
        );
        // Both names are exported.
        assert!(out.contains("    TKComputeDistance"), "{out}");
        assert!(out.contains("    TKSwiftScale"), "{out}");
        // The residual pulls in the Scheme-side coercion runtime import.
        assert!(
            out.contains("(apianyware runtime swift-trampoline)"),
            "{out}"
        );
        // ...and forces the chez dylib to load before the entries resolve (chez
        // instantiates libraries lazily — see swift-trampoline.sls).
        let force = out.find("(define %aw-lib-ready aw-trampoline-lib-ready)");
        let entry = out.find("aw_chez_swift_TestKit_TKSwiftScale");
        assert!(force.is_some(), "forcing reference must be emitted:\n{out}");
        assert!(
            force < entry,
            "forcing reference must precede the entries:\n{out}"
        );
    }

    #[test]
    fn swift_string_function_uses_scheme_side_coercers() {
        let fs = vec![swift_func(
            "TKSwiftGreeting",
            vec![param("name", nsstring_kind())],
            nsstring_kind(),
            SwiftFnInfo::default(),
        )];
        let out = generate_functions_file(&fs, "TestKit", &[]);
        assert!(
            out.contains("(aw-string-arg a0)"),
            "string arg bridged in:\n{out}"
        );
        assert!(
            out.contains("(aw-string-result (%raw"),
            "string result coerced out:\n{out}"
        );
        assert!(
            out.contains("(apianyware runtime swift-trampoline)"),
            "{out}"
        );
    }

    #[test]
    fn deferred_residual_is_recorded_as_comment_not_dropped() {
        let fs = vec![swift_func(
            "TKSwiftFetch",
            vec![],
            TypeRefKind::Primitive {
                name: "void".into(),
            },
            SwiftFnInfo {
                is_async: true,
                ..Default::default()
            },
        )];
        let out = generate_functions_file(&fs, "TestKit", &[]);
        // Not bound...
        assert!(!out.contains("aw_chez_swift_TestKit_TKSwiftFetch"), "{out}");
        // ...but recorded with its reason.
        assert!(
            out.contains(";;   TKSwiftFetch — deferred_async"),
            "deferred residual must be recorded:\n{out}"
        );
        // A fully-deferred residual needs no coercion runtime.
        assert!(!out.contains("swift-trampoline)"), "{out}");
    }

    #[test]
    fn no_residual_keeps_plain_runtime_import() {
        let fs = vec![func(
            "TKDirect",
            vec![],
            TypeRefKind::Primitive {
                name: "void".into(),
            },
            false,
            false,
        )];
        let out = generate_functions_file(&fs, "TestKit", &[]);
        assert!(out.contains("(apianyware runtime types))"), "{out}");
        assert!(!out.contains("swift-trampoline"), "{out}");
    }
}
