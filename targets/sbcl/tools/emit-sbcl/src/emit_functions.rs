//! SBCL top-level C/Swift function emission.
//!
//! Each direct (ObjC/C-exposed) function gets one `sb-alien:define-alien-routine`:
//!
//! ```lisp
//! (sb-alien:define-alien-routine ("CGRectMake" ns:cg-rect-make) (sb-alien:struct ns-rect)
//!   (x sb-alien:double) (y sb-alien:double) (w sb-alien:double) (h sb-alien:double))
//! ```
//!
//! `define-alien-routine` is the idiomatic compiled-FFI form for a *named* C function:
//! it generates a Lisp wrapper (`ns:cg-rect-make`) and resolves the C symbol through
//! SBCL's foreign **linkage table at call time**. That call-time resolution is why
//! direct functions are **dump-safe for free** — `save-lisp-and-die` repairs the
//! linkage table on startup (ADR-0038 §5), so no per-process re-resolution machinery
//! is needed here, unlike constants ([`crate::emit_constants`]). The raw C symbol is
//! the first element of the `(c-name lisp-name)` pair; the kebab `ns:` symbol is the
//! Lisp binding.
//!
//! This is a **thin raw FFI surface**, exactly as the scheme peers: an object-returning
//! function hands back a raw `system-area-pointer`, **not** an `aw-wrap`ped object, and
//! object *arguments* are raw SAPs (a caller passes `(aw-ptr obj)`). These free
//! functions are a small geometry/string/dispatch utility set whose results often flow
//! straight back into other C functions; wrapping would break that C-to-C interop. The
//! idiom richness (wrapping, lifetime) lives in the method dispatch
//! ([`crate::emit_generics`]) and the trampoline residual (050), not here.
//!
//! Two classes are **skipped entirely** (neither direct nor residual), as in the
//! scheme targets: **inline** functions (no exported symbol to call) and **variadic**
//! functions (`define-alien-routine` is fixed-arity).
//!
//! ## The Swift-native residual is NOT emitted here
//!
//! An `objc_exposed == false` function is a Swift-ABI symbol, not a C export — a direct
//! `define-alien-routine` to it would dangle. These are **collected**
//! ([`collect_fn_residual`]) for the trampoline residual the next leaf (050) routes
//! through `libAPIAnywareSbcl` (`aw_sbcl_swift_*`), exactly as
//! [`crate::emit_generics::collect_residual`] collects the method/init residual. The
//! §6d invariant's `51 fn` originate here.

use std::collections::HashSet;

use apianyware_emit::code_writer::CodeWriter;
use apianyware_emit::ffi_type_mapping::FfiTypeMapper;
use apianyware_emit::naming::camel_to_kebab;
use apianyware_emit::write_line;
use apianyware_types::ir::Function;

use crate::ffi_type_mapping::SbclFfiTypeMapper;
use crate::naming::{qualified_top_level_name, top_level_name};
use crate::shared_signatures::is_libdispatch_unexported;

/// True if a function is a **direct** (ObjC/C-exposed) `define-alien-routine` binding.
/// Skips inline (no symbol) and variadic (fixed-arity FFI) functions. The Swift-native
/// residual (`!objc_exposed`) is collected separately ([`collect_fn_residual`]).
fn is_direct(f: &Function) -> bool {
    f.objc_exposed && !f.inline && !f.variadic
}

/// Generate one framework's direct function bindings. The Swift-native residual
/// (`objc_exposed == false`) is **not** emitted — see [`collect_fn_residual`].
pub fn generate_functions_file(functions: &[Function], framework: &str) -> String {
    let mapper = SbclFfiTypeMapper;
    let is_libdispatch = framework == "libdispatch";
    let mut w = CodeWriter::new();

    write_line!(
        w,
        ";;; Generated C function bindings for {} — do not edit",
        framework
    );
    w.blank_line();

    for f in functions
        .iter()
        .filter(|f| is_direct(f))
        .filter(|f| !(is_libdispatch && is_libdispatch_unexported(&f.name)))
    {
        emit_alien_routine(&mut w, f, &mapper);
    }

    w.finish()
}

/// Emit one `(sb-alien:define-alien-routine ("C" ns:lisp) <ret> (arg <alien>)…)`.
fn emit_alien_routine(w: &mut CodeWriter, f: &Function, mapper: &dyn FfiTypeMapper) {
    let ret = mapper.map_type(&f.return_type, true);
    let names = unique_arg_names(f);
    let args: Vec<String> = f
        .params
        .iter()
        .zip(&names)
        .map(|(p, name)| format!("({} {})", name, mapper.map_type(&p.param_type, false)))
        .collect();

    if args.is_empty() {
        write_line!(
            w,
            "(sb-alien:define-alien-routine (\"{}\" {}) {})",
            f.name,
            qualified_top_level_name(&f.name),
            ret
        );
    } else {
        write_line!(
            w,
            "(sb-alien:define-alien-routine (\"{}\" {}) {}",
            f.name,
            qualified_top_level_name(&f.name),
            ret
        );
        for (i, a) in args.iter().enumerate() {
            let tail = if i + 1 == args.len() { ")" } else { "" };
            write_line!(w, "  {}{}", a, tail);
        }
    }
}

/// The unqualified `ns:`-package symbols this framework's functions contribute, in IR
/// order — the package export surface (060). Includes the Swift-native residual: 050
/// binds it under the **same** `ns:<name>` symbol via the trampoline. Skips the
/// inline/variadic drops and the libdispatch-unexported allowlist (never bound).
pub fn function_symbols(functions: &[Function], framework: &str) -> Vec<String> {
    let is_libdispatch = framework == "libdispatch";
    functions
        .iter()
        .filter(|f| !f.inline && !f.variadic)
        .filter(|f| !(f.objc_exposed && is_libdispatch && is_libdispatch_unexported(&f.name)))
        .map(|f| top_level_name(&f.name))
        .collect()
}

// --- the Swift-native residual --------------------------------------------

/// One `objc_exposed == false` function routed to the trampoline residual (leaf 050)
/// rather than bound directly. The collection shape mirrors
/// [`crate::emit_generics::ResidualEntry`] — a thin identity (the function name) the
/// global pass re-classifies against the IR.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct FnResidualEntry {
    /// The function name (and `aw_sbcl_swift_*` content-addressing key).
    pub name: String,
}

/// Collect a framework's Swift-native (`objc_exposed == false`) function candidates for
/// the trampoline residual (leaf 050). Excludes inline/variadic (never bindable), the
/// same gate as the direct path, so 040 and the 050 global pass agree on the candidate
/// set. These are deliberately **not** emitted here. Feeds the §6d `51 fn`.
pub fn collect_fn_residual(functions: &[Function]) -> Vec<FnResidualEntry> {
    functions
        .iter()
        .filter(|f| !f.objc_exposed && !f.inline && !f.variadic)
        .map(|f| FnResidualEntry {
            name: f.name.clone(),
        })
        .collect()
}

// --- helpers ---------------------------------------------------------------

/// `define-alien-routine` formals must be distinct symbols. Kebab each param label
/// (`argN` for empty/wildcard), then resolve collisions deterministically.
fn unique_arg_names(f: &Function) -> Vec<String> {
    let mut seen: HashSet<String> = HashSet::new();
    let mut out: Vec<String> = Vec::with_capacity(f.params.len());
    for (i, p) in f.params.iter().enumerate() {
        let base = arg_name(&p.name, i);
        let mut name = base.clone();
        if seen.contains(&name) {
            name = format!("arg{i}");
        }
        let mut k = 0;
        while seen.contains(&name) {
            k += 1;
            name = format!("{base}-{k}");
        }
        seen.insert(name.clone());
        out.push(name);
    }
    out
}

/// A Lisp formal for a C param: kebab the label, `argN` for an empty/wildcard label
/// or one that collides with a CL defined constant (`t`/`nil` — see
/// [`crate::naming::is_cl_reserved_formal`]; `CGAffineTransform*` carries a `t` param).
fn arg_name(label: &str, i: usize) -> String {
    let kebab = camel_to_kebab(label);
    if kebab.is_empty() || label == "_" || crate::naming::is_cl_reserved_formal(&kebab) {
        format!("arg{i}")
    } else {
        kebab
    }
}

// The libdispatch-unexported skip list now lives canonically in
// [`crate::shared_signatures::is_libdispatch_unexported`] (leaf 050 retired this seam).

#[cfg(test)]
mod tests {
    use super::*;
    use apianyware_types::ir::{Param, SwiftFnInfo};
    use apianyware_types::type_ref::{TypeRef, TypeRefKind};

    fn ty(kind: TypeRefKind) -> TypeRef {
        TypeRef {
            nullable: false,
            kind,
        }
    }

    fn prim(name: &str) -> TypeRefKind {
        TypeRefKind::Primitive { name: name.into() }
    }

    fn param(name: &str, kind: TypeRefKind) -> Param {
        Param {
            name: name.into(),
            param_type: ty(kind),
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
            return_type: ty(ret),
            inline,
            variadic,
            source: None,
            provenance: None,
            doc_refs: None,
            objc_exposed: true,
            swift_fn: None,
        }
    }

    fn swift_func(name: &str, params: Vec<Param>, ret: TypeRefKind) -> Function {
        Function {
            name: name.into(),
            params,
            return_type: ty(ret),
            inline: false,
            variadic: false,
            source: None,
            provenance: None,
            doc_refs: None,
            objc_exposed: false,
            swift_fn: Some(SwiftFnInfo::default()),
        }
    }

    #[test]
    fn simple_function_emits_define_alien_routine() {
        let fs = vec![func(
            "TKComputeDistance",
            vec![param("x", prim("double")), param("y", prim("double"))],
            prim("double"),
            false,
            false,
        )];
        let out = generate_functions_file(&fs, "TestKit");
        assert!(out.contains(";;; Generated C function bindings for TestKit"));
        // Raw C name for the link, ns: kebab for the binding; no C-decl synthesis.
        assert!(out.contains("(sb-alien:define-alien-routine (\"TKComputeDistance\" ns:tk-compute-distance) sb-alien:double"));
        assert!(out.contains("(x sb-alien:double)"));
        assert!(out.contains("(y sb-alien:double))"));
        assert!(!out.contains("c-declare"));
    }

    #[test]
    fn zero_arg_function_is_single_form() {
        let fs = vec![func("TKReset", vec![], prim("void"), false, false)];
        let out = generate_functions_file(&fs, "TestKit");
        assert!(
            out.contains("(sb-alien:define-alien-routine (\"TKReset\" ns:tk-reset) sb-alien:void)")
        );
    }

    #[test]
    fn object_return_is_raw_sap_not_wrapped() {
        let fs = vec![func(
            "TKMakeWidget",
            vec![],
            TypeRefKind::Id {
                protocols: Vec::new(),
            },
            false,
            false,
        )];
        let out = generate_functions_file(&fs, "TestKit");
        assert!(out.contains(
            "(sb-alien:define-alien-routine (\"TKMakeWidget\" ns:tk-make-widget) sb-alien:system-area-pointer)"
        ));
        // Thin raw FFI surface — no wrap.
        assert!(!out.contains("aw-wrap"));
    }

    #[test]
    fn object_argument_is_raw_sap() {
        let fs = vec![func(
            "TKConsume",
            vec![param(
                "obj",
                TypeRefKind::Id {
                    protocols: Vec::new(),
                },
            )],
            prim("void"),
            false,
            false,
        )];
        let out = generate_functions_file(&fs, "TestKit");
        assert!(out.contains("(obj sb-alien:system-area-pointer))"));
    }

    #[test]
    fn cstring_arg_maps_to_c_string() {
        let fs = vec![func(
            "TKLog",
            vec![param("msg", TypeRefKind::CString)],
            prim("void"),
            false,
            false,
        )];
        let out = generate_functions_file(&fs, "TestKit");
        assert!(out.contains("(msg sb-alien:c-string))"));
    }

    #[test]
    fn by_value_geometry_struct_crosses_by_value() {
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
        let out = generate_functions_file(&fs, "TestKit");
        // 050 owns the (define-alien-type ns-rect …); 040 just references it.
        assert!(out.contains(
            "(sb-alien:define-alien-routine (\"TKBounds\" ns:tk-bounds) (sb-alien:struct ns-point)"
        ));
        assert!(out.contains("(r (sb-alien:struct ns-rect)))"));
    }

    #[test]
    fn inline_and_variadic_are_skipped() {
        let fs = vec![
            func(
                "TKFastHash",
                vec![param("d", TypeRefKind::Pointer)],
                prim("uint64"),
                true,
                false,
            ),
            func(
                "TKLog",
                vec![param("fmt", TypeRefKind::CString)],
                prim("void"),
                false,
                true,
            ),
        ];
        let out = generate_functions_file(&fs, "TestKit");
        assert!(!out.contains("tk-fast-hash"));
        assert!(!out.contains("tk-log"));
        // Neither direct nor residual.
        assert!(collect_fn_residual(&fs).is_empty());
        assert!(function_symbols(&fs, "TestKit").is_empty());
    }

    #[test]
    fn duplicate_param_labels_get_distinct_formals() {
        // Two empty labels both → argN by index, which are already distinct.
        let fs = vec![func(
            "TKPair",
            vec![param("", prim("double")), param("", prim("double"))],
            prim("void"),
            false,
            false,
        )];
        let out = generate_functions_file(&fs, "TestKit");
        assert!(out.contains("(arg0 sb-alien:double)"));
        assert!(out.contains("(arg1 sb-alien:double))"));
    }

    #[test]
    fn repeated_named_labels_are_disambiguated() {
        // Two params that kebab to the same formal get distinct symbols.
        let fs = vec![func(
            "TKDup",
            vec![
                param("value", prim("double")),
                param("value", prim("double")),
            ],
            prim("void"),
            false,
            false,
        )];
        let out = generate_functions_file(&fs, "TestKit");
        assert!(out.contains("(value sb-alien:double)"));
        // The second `value` falls back to arg1.
        assert!(out.contains("(arg1 sb-alien:double))"));
    }

    #[test]
    fn empty_functions_emit_only_a_header() {
        let out = generate_functions_file(&[], "TestKit");
        assert!(out.contains(";;; Generated C function bindings for TestKit"));
        assert!(!out.contains("define-alien-routine"));
    }

    #[test]
    fn libdispatch_unexported_is_dropped() {
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
                prim("void"),
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
                prim("void"),
                false,
                false,
            ),
        ];
        let out = generate_functions_file(&fs, "libdispatch");
        assert!(out.contains("ns:dispatch-async"));
        assert!(!out.contains("dispatch-cancel"));
        assert_eq!(
            function_symbols(&fs, "libdispatch"),
            vec!["dispatch-async".to_string()]
        );
        // The same name is NOT filtered outside libdispatch.
        let out2 = generate_functions_file(&fs, "TestKit");
        assert!(out2.contains("ns:dispatch-cancel"));
    }

    // --- Swift-native residual routing (objc_exposed == false) -------------

    #[test]
    fn swift_native_function_is_collected_not_emitted() {
        let fs = vec![
            func(
                "TKComputeDistance",
                vec![param("x", prim("double"))],
                prim("double"),
                false,
                false,
            ),
            swift_func(
                "TKSwiftScale",
                vec![param("factor", prim("double"))],
                prim("double"),
            ),
        ];
        let out = generate_functions_file(&fs, "TestKit");
        // Direct one bound…
        assert!(out.contains("ns:tk-compute-distance"));
        // …residual one is NOT (050 trampolines it).
        assert!(!out.contains("tk-swift-scale"));
        assert!(!out.contains("TKSwiftScale"));

        let residual = collect_fn_residual(&fs);
        assert_eq!(residual.len(), 1);
        assert_eq!(residual[0].name, "TKSwiftScale");
    }

    #[test]
    fn function_symbols_span_direct_and_residual() {
        let fs = vec![
            func("TKComputeDistance", vec![], prim("double"), false, false),
            swift_func("TKSwiftScale", vec![], prim("double")),
        ];
        assert_eq!(
            function_symbols(&fs, "TestKit"),
            vec![
                "tk-compute-distance".to_string(),
                "tk-swift-scale".to_string()
            ]
        );
    }
}
