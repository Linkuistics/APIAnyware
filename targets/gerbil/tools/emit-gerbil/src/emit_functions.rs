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
//! The **direct** (ObjC-exposed) bindings are a thin **raw** FFI surface (like
//! chez): an object-returning C function hands back a raw `(pointer void)`, not a
//! `wrap`ped object — these free functions are a small utility surface
//! (geometry/string/dispatch), and a consumer that wants an object can `wrap` it.
//! Object *arguments* are likewise raw `(pointer void)`; a caller passes
//! `(->ptr obj)`.
//!
//! **Swift-native residual (`objc_exposed == false`, ADR-0026 / ADR-0029, leaf
//! 070).** A `s:` symbol is *not* a C export of the framework dylib — a direct
//! `define-c-lambda` to it would dangle. These declarations route to the
//! **trampolines**: a `@_cdecl` re-export in `libAPIAnywareGerbil` (linked at
//! `gxc -exe` time), bound here by a per-signature `define-c-lambda` against the
//! dylib's `aw_gerbil_swift_*` entry and wrapped Scheme-side (`object` returns →
//! `wrap` to the exact bound type, `String` → the gerbil string bridge, `throws`
//! → the error-cell helper; `runtime/swift-trampoline.ss`, ADR-0015 / ADR-0020).
//! Decls that cannot be trampolined this leaf are recorded as comments, never
//! silently dropped (spec §5).

use std::collections::HashSet;

use apianyware_emit::code_writer::CodeWriter;
use apianyware_emit::ffi_type_mapping::FfiTypeMapper;
use apianyware_emit::write_line;
use apianyware_types::ir::{Function, Struct};

use crate::ffi_type_mapping::{
    c_proto_type, emit_geometry_decls, geometry_decl_no_header, GeometryDecl, GerbilFfiTypeMapper,
};
use crate::shared_signatures::is_libdispatch_unexported;
use crate::trampoline::{
    classify_function, fn_needs_objc, fn_needs_swift_helpers, value_struct_names, FnDisposition,
    FnTrampoline,
};

/// The runtime module owning `wrap` / `->ptr` / the string bridge (a trampoline
/// `object` return wraps, a value-struct handle param passes via `->ptr`).
const RUNTIME_OBJC_IMPORT: &str = ":gerbil-bindings/runtime/objc";
/// The runtime module supplying the Swift-native trampoline `aw-swift-*` coercers
/// (string in/out, the `throws` error-cell helper).
const RUNTIME_TRAMPOLINE_IMPORT: &str = ":gerbil-bindings/runtime/swift-trampoline";

/// True if a function is a **direct** (ObjC-exposed) Gambit `define-c-lambda`
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
/// is content-addressed; agreement keeps a gerbil binding from dangling).
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
/// used by the orchestrator to decide whether to write `functions.ss` at all.
pub fn count_emittable(functions: &[Function], framework: &str, structs: &[Struct]) -> usize {
    function_emittable_names(functions, framework, structs).len()
}

/// Names exported by `functions.ss` for a framework — direct function names then
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

/// Generate a Gerbil `functions.ss` module for one framework.
///
/// `structs` is the framework's own `Framework.structs` — the value-struct set
/// that gates the trampoline param-unbox path (spec §5c). It must be the same
/// slice the global trampoline pass sees.
pub fn generate_functions_file(
    functions: &[Function],
    framework: &str,
    structs: &[Struct],
) -> String {
    let mapper = GerbilFfiTypeMapper;
    let mut w = CodeWriter::new();
    let is_libdispatch = framework == "libdispatch";

    let emittable: Vec<&Function> = functions
        .iter()
        .filter(|f| is_emittable(f))
        .filter(|f| !(is_libdispatch && is_libdispatch_unexported(&f.name)))
        .collect();

    // Direct crossings: pre-compute each function's arg/return tokens (also feeds
    // geometry decls).
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

    let (tramps, deferred) = classify_residual(functions, framework, structs);

    // By-value geometry structs anywhere in a *direct* arg/return slot need a
    // `c-define-type` + decl (CG header / inline NS struct) in the begin-ffi
    // prelude. A `bool` slot needs the C-safe `<stdbool.h>` for the prototype.
    let mut seen = HashSet::new();
    let mut geo: Vec<GeometryDecl> = Vec::new();
    let mut direct_stdbool = false;
    for (_, args, ret) in &crossings {
        for tok in args.iter().chain(std::iter::once(ret)) {
            if tok == "bool" {
                direct_stdbool = true;
            }
            if let Some(decl) = geometry_decl_no_header(tok) {
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

    // Nothing to bind (no direct, no trampolines): emit an empty export. Any
    // deferred residual is still tallied by the global pass; with no other
    // bindings the per-framework file is not written by the orchestrator, so this
    // branch only fires for a genuinely empty `functions` slice.
    if crossings.is_empty() && tramps.is_empty() {
        w.line("(export)");
        return w.finish();
    }

    // The trampoline crossings cross the dylib; their begin-ffi needs `:std/
    // foreign` like the direct one, the `objc` runtime when a binding wraps an
    // object / passes a handle (`wrap` / `->ptr`), and the `swift-trampoline`
    // runtime for the `aw-swift-*` string/throws coercers. The two runtime modules
    // are disjoint (swift-trampoline exports only `aw-swift-*`), so importing both
    // never double-binds `wrap`.
    let needs_objc = tramps.iter().any(fn_needs_objc);
    let needs_swift = tramps.iter().any(fn_needs_swift_helpers);
    if !needs_objc && !needs_swift {
        // A direct-only (or pure-scalar-residual) module needs just the FFI import.
        w.line("(import :std/foreign)");
    } else {
        w.line("(import");
        w.line("  :std/foreign");
        if needs_objc {
            write_line!(w, "  {}", RUNTIME_OBJC_IMPORT);
        }
        if needs_swift {
            write_line!(w, "  {}", RUNTIME_TRAMPOLINE_IMPORT);
        }
        w.line("  )");
    }

    w.line("(export");
    for (f, _, _) in &crossings {
        write_line!(w, "  {}", f.name);
    }
    for t in &tramps {
        write_line!(w, "  {}", t.binding_name);
    }
    w.line("  )");
    w.blank_line();

    // --- direct (ObjC-exposed) begin-ffi block -------------------------------
    if !crossings.is_empty() {
        w.line("(begin-ffi (");
        for (f, _, _) in &crossings {
            write_line!(w, "            {}", f.name);
        }
        w.line("            )");
        // Synthesized C declarations only — no framework umbrella `#include`
        // (ADR-0021), so the unit compiles under the default gcc-15.
        if direct_stdbool {
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
        // Separate the direct block from a following section only when one exists,
        // so a direct-only module ends exactly at the closing paren (no churn).
        if !tramps.is_empty() || !deferred.is_empty() {
            w.blank_line();
        }
    }

    // --- Swift-native trampoline begin-ffi block + bindings ------------------
    // Each `aw_gerbil_swift_*` entry is a real C symbol in libAPIAnywareGerbil
    // (ADR-0029); declared by a synthesized `extern` (ADR-0021), bound by a
    // per-signature `define-c-lambda`, and wrapped by an outer binding.
    if !tramps.is_empty() {
        let crossings: Vec<_> = tramps.iter().map(|t| t.crossing()).collect();
        w.line("  ;; Swift-native residual — trampolined through libAPIAnywareGerbil");
        w.line("  ;; (aw_gerbil_swift_* entries) rather than the framework dylib (ADR-0029).");
        w.line("(begin-ffi (");
        for t in &tramps {
            write_line!(w, "            %swift-{}", t.binding_name);
        }
        w.line("            )");
        if crossings.iter().any(|c| c.needs_stdbool) {
            w.line("  (c-declare \"#include <stdbool.h>\")");
        }
        for c in &crossings {
            write_line!(w, "  (c-declare \"{}\")", c.proto);
        }
        w.blank_line();
        for c in &crossings {
            write_line!(w, "  {}", c.define_c_lambda);
        }
        w.line("  )");
        w.blank_line();
        for t in &tramps {
            for line in t.render_binding().lines() {
                write_line!(w, "{}", line);
            }
        }
    }

    // Deferred residual — recorded, never silently dropped (spec §5).
    if !deferred.is_empty() {
        w.blank_line();
        w.line(";; Deferred Swift-native residual (not trampolined this leaf):");
        for (func, reason) in &deferred {
            write_line!(w, ";;   {} — {}", func.name, reason);
        }
    }

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
    fn simple_function_emits_synthesized_prototype_not_umbrella() {
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
            TypeRefKind::Primitive {
                name: "void".into(),
            },
            false,
            false,
        )];
        let out = generate_functions_file(&fs, "TestKit", &[]);
        // A zero-arg C prototype spells `(void)`, not `()`.
        assert!(out.contains("(c-declare \"extern void TKReset(void);\")"));
        assert!(out.contains("(define-c-lambda TKReset () void \"TKReset\")"));
    }

    #[test]
    fn bool_slot_pulls_in_stdbool() {
        let fs = vec![func(
            "TKToggle",
            vec![param(
                "on",
                TypeRefKind::Primitive {
                    name: "bool".into(),
                },
            )],
            TypeRefKind::Primitive {
                name: "bool".into(),
            },
            false,
            false,
        )];
        let out = generate_functions_file(&fs, "TestKit", &[]);
        assert!(out.contains("(c-declare \"#include <stdbool.h>\")"));
        assert!(out.contains("(c-declare \"extern bool TKToggle(bool);\")"));
    }

    #[test]
    fn inline_and_variadic_are_skipped() {
        let fs = vec![
            func(
                "TKFastHash",
                vec![param("d", TypeRefKind::Pointer)],
                TypeRefKind::Primitive {
                    name: "uint64".into(),
                },
                true,
                false,
            ),
            func(
                "TKLog",
                vec![param("fmt", TypeRefKind::CString)],
                TypeRefKind::Primitive {
                    name: "void".into(),
                },
                false,
                true,
            ),
        ];
        let out = generate_functions_file(&fs, "TestKit", &[]);
        assert!(!out.contains("TKFastHash"));
        assert!(!out.contains("TKLog"));
        assert_eq!(count_emittable(&fs, "TestKit", &[]), 0);
    }

    #[test]
    fn function_returning_id_maps_to_raw_pointer() {
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
        // ObjC pointer return collapses to `void *` in the synthesized prototype.
        assert!(out.contains("(c-declare \"extern void * TKMakeWidget(void);\")"));
        assert!(out.contains("(define-c-lambda TKMakeWidget () (pointer void) \"TKMakeWidget\")"));
        // Raw FFI surface — no wrapping, no runtime import.
        assert!(!out.contains(":gerbil-bindings/runtime/objc"));
        assert!(!out.contains("wrap"));
    }

    #[test]
    fn by_value_cg_geometry_inlines_struct_not_header() {
        let fs = vec![func(
            "TKBounds",
            vec![param(
                "r",
                TypeRefKind::Struct {
                    name: "CGRect".into(),
                },
            )],
            TypeRefKind::Struct {
                name: "CGPoint".into(),
            },
            false,
            false,
        )];
        let out = generate_functions_file(&fs, "TestKit", &[]);
        assert!(out.contains("(c-define-type CGRect (struct \"CGRect\"))"));
        assert!(out.contains("(c-define-type CGPoint (struct \"CGPoint\"))"));
        // functions.ss synthesizes `extern` prototypes, so it must NOT `#include`
        // a CoreGraphics header — the real CG prototypes would conflict with the
        // synthesized ones (leaf 100/030). CG structs are declared inline instead.
        assert!(!out.contains("#include <CoreGraphics/CGGeometry.h>"));
        assert!(out.contains("typedef struct CGPoint { double x; double y; } CGPoint;"));
        assert!(out.contains(
            "typedef struct CGRect { struct { double x; double y; } origin; struct { double width; double height; } size; } CGRect;"
        ));
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
            vec![param(
                "len",
                TypeRefKind::Primitive {
                    name: "uint64".into(),
                },
            )],
            TypeRefKind::Struct {
                name: "NSRange".into(),
            },
            false,
            false,
        )];
        let out = generate_functions_file(&fs, "TestKit", &[]);
        assert!(out.contains(
            "(c-declare \"typedef struct _NSRange { unsigned long location; unsigned long length; } NSRange;\")"
        ));
        assert!(out.contains("(c-define-type NSRange (struct \"_NSRange\"))"));
        assert!(!out.contains("#include <Foundation/"));
        assert!(
            out.contains("(c-declare \"extern struct _NSRange TKMakeRange(unsigned long long);\")")
        );
    }

    #[test]
    fn libdispatch_synthesizes_prototypes_and_skips_unexported() {
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
        // ADR-0021: no umbrella; synthesized prototype with ObjC ptrs as void *.
        assert!(!out.contains("#include <dispatch/dispatch.h>"));
        assert!(out.contains("(c-declare \"extern void dispatch_async(void *, void *);\")"));
        assert!(out.contains("dispatch_async"));
        assert!(!out.contains("dispatch_cancel"));
    }

    #[test]
    fn empty_functions_emit_empty_export() {
        let out = generate_functions_file(&[], "TestKit", &[]);
        assert!(out.contains("(export)"));
        assert!(!out.contains("begin-ffi"));
    }

    #[test]
    fn emittable_names_skip_inline_variadic_and_unexported() {
        let fs = vec![
            func(
                "dispatch_async",
                vec![],
                TypeRefKind::Primitive {
                    name: "void".into(),
                },
                false,
                false,
            ),
            func(
                "dispatch_cancel",
                vec![],
                TypeRefKind::Primitive {
                    name: "void".into(),
                },
                false,
                false,
            ),
        ];
        assert_eq!(
            function_emittable_names(&fs, "libdispatch", &[]),
            vec!["dispatch_async".to_string()]
        );
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
            // Swift-native scalar function — trampolined via the aw_gerbil_swift_* entry.
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
        // Direct function: its own synthesized prototype + direct call.
        assert!(
            out.contains("(c-declare \"extern double TKComputeDistance(double);\")"),
            "{out}"
        );
        assert!(
            out.contains(
                "(define-c-lambda TKComputeDistance (double) double \"TKComputeDistance\")"
            ),
            "{out}"
        );
        // Swift-native function: a %swift- crossing to the content-addressed entry.
        assert!(
            out.contains(
                "(c-declare \"extern double aw_gerbil_swift_TestKit_TKSwiftScale(double);\")"
            ),
            "{out}"
        );
        assert!(
            out.contains("(define-c-lambda %swift-TKSwiftScale (double) double \"aw_gerbil_swift_TestKit_TKSwiftScale\")"),
            "{out}"
        );
        // Both names exported.
        assert!(out.contains("  TKComputeDistance"), "{out}");
        assert!(out.contains("  TKSwiftScale"), "{out}");
        // A pure-scalar residual needs no runtime import (no wrap/coercion).
        assert!(
            !out.contains(":gerbil-bindings/runtime/swift-trampoline"),
            "{out}"
        );
    }

    #[test]
    fn residual_only_framework_still_emits_trampolines() {
        // A framework with NO direct C functions but a Swift-native residual must
        // still write the trampoline block (count_emittable > 0).
        let fs = vec![swift_func(
            "timestampSeed",
            vec![],
            TypeRefKind::Primitive {
                name: "int64".into(),
            },
            SwiftFnInfo::default(),
        )];
        assert_eq!(count_emittable(&fs, "CreateML", &[]), 1);
        let out = generate_functions_file(&fs, "CreateML", &[]);
        assert!(
            out.contains("aw_gerbil_swift_CreateML_timestampSeed"),
            "{out}"
        );
        assert!(
            out.contains("(define timestampSeed %swift-timestampSeed)"),
            "{out}"
        );
        // No direct begin-ffi block (no direct functions); a pure-scalar residual
        // needs only the FFI import (single-line form, no runtime helpers).
        assert!(out.contains("(import :std/foreign)"), "{out}");
    }

    #[test]
    fn swift_string_function_uses_runtime_and_wraps() {
        let fs = vec![swift_func(
            "TKSwiftGreeting",
            vec![param("name", nsstring_kind())],
            nsstring_kind(),
            SwiftFnInfo::default(),
        )];
        let out = generate_functions_file(&fs, "TestKit", &[]);
        assert!(
            out.contains("(aw-swift-string-arg a0)"),
            "string arg bridged in:\n{out}"
        );
        assert!(
            out.contains("(aw-swift-string-result"),
            "string result coerced out:\n{out}"
        );
        // String shapes pull in the runtime helpers.
        assert!(
            out.contains(":gerbil-bindings/runtime/swift-trampoline"),
            "{out}"
        );
    }

    #[test]
    fn object_returning_trampoline_wraps_to_bound_type() {
        // gerbil's divergence: an id-returning trampoline lands as a wrapped object,
        // not a raw pointer.
        let fs = vec![swift_func(
            "TKMakeWidget",
            vec![],
            TypeRefKind::Class {
                name: "TKWidget".into(),
                framework: Some("TestKit".into()),
                params: vec![],
            },
            SwiftFnInfo::default(),
        )];
        let out = generate_functions_file(&fs, "TestKit", &[]);
        assert!(
            out.contains("(wrap (%swift-TKMakeWidget) #t)"),
            "object return must wrap:\n{out}"
        );
        // `wrap` is owned by the objc runtime, not swift-trampoline.
        assert!(out.contains(":gerbil-bindings/runtime/objc"), "{out}");
    }

    #[test]
    fn deferred_async_residual_is_not_bound() {
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
        // Fully-deferred residual: nothing emittable, so functions.ss is not written
        // by the orchestrator (count == 0); the global pass still tallies it. But if
        // generate is called, the deferral is recorded as a comment, never bound.
        assert_eq!(count_emittable(&fs, "TestKit", &[]), 0);
        let out = generate_functions_file(&fs, "TestKit", &[]);
        assert!(
            !out.contains("aw_gerbil_swift_TestKit_TKSwiftFetch"),
            "{out}"
        );
        // With no bindings the empty-export branch fires; deferred-only frameworks
        // are tallied globally, not per-file.
        assert!(out.contains("(export)"), "{out}");
    }
}
