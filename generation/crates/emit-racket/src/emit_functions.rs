//! Racket C-API function binding code generation.
//!
//! Emits `get-ffi-obj` definitions with `_fun` type signatures for C functions
//! exported by a framework. Inline and variadic functions are skipped (inline
//! functions are not exported symbols; variadic functions cannot be represented
//! by Racket's `_fun` type constructor).
//!
//! Generated bindings include `provide/contract` forms that enforce argument
//! types at module boundaries using Racket contracts mapped from IR TypeRef.

use apianyware_macos_emit::code_writer::CodeWriter;
use apianyware_macos_emit::ffi_type_mapping::{
    is_generic_type_param, FfiTypeMapper, RacketFfiTypeMapper,
};
use apianyware_macos_emit::write_line;
use apianyware_macos_types::ir::Function;
use apianyware_macos_types::type_ref::{TypeRef, TypeRefKind};

use crate::shared_signatures::{any_struct_type, framework_ffi_lib_arg, is_libdispatch_unexported};
use crate::trampoline::{classify_function, FnDisposition, FnTrampoline};

/// Returns true if a function can be emitted as a Racket FFI binding.
///
/// Skips inline functions (no exported symbol to link against) and
/// variadic functions (Racket `_fun` cannot represent C varargs).
fn is_emittable(func: &Function) -> bool {
    !func.inline && !func.variadic
}

/// Map an IR TypeRef to a Racket contract expression.
///
/// Contracts provide runtime boundary checking when the module is `require`d.
/// The mapping complements `_fun` FFI types: `_fun` handles C-level marshaling,
/// while contracts catch Racket-level misuse before the FFI call.
pub fn map_contract(type_ref: &TypeRef, is_return_type: bool) -> String {
    match &type_ref.kind {
        TypeRefKind::Primitive { name } => {
            let normalized = normalize_primitive(name);
            match normalized.as_str() {
                "void" if is_return_type => "void?".to_string(),
                "void" => "any/c".to_string(),
                "bool" => "boolean?".to_string(),
                "float" | "double" => "real?".to_string(),
                "int8" | "int16" | "int32" | "int64" | "nsinteger" => "exact-integer?".to_string(),
                "uint8" | "uint16" | "uint32" | "uint64" | "nsuinteger" => {
                    "exact-nonnegative-integer?".to_string()
                }
                "pointer" => "(or/c cpointer? #f)".to_string(),
                _ => "any/c".to_string(),
            }
        }
        TypeRefKind::Class { .. } | TypeRefKind::Id | TypeRefKind::Instancetype => {
            if type_ref.nullable {
                "(or/c cpointer? #f)".to_string()
            } else {
                "cpointer?".to_string()
            }
        }
        TypeRefKind::Selector | TypeRefKind::ClassRef => "cpointer?".to_string(),
        TypeRefKind::CString => {
            if is_return_type {
                // C `const char *` returns can be NULL; Racket's `_string`
                // FFI type converts NULL to #f, so the contract must accept it.
                "(or/c string? #f)".to_string()
            } else {
                "string?".to_string()
            }
        }
        TypeRefKind::Pointer => "(or/c cpointer? #f)".to_string(),
        TypeRefKind::Block { .. } | TypeRefKind::FunctionPointer { .. } => {
            "(or/c cpointer? #f)".to_string()
        }
        TypeRefKind::Struct { .. } => "any/c".to_string(),
        TypeRefKind::Alias {
            name,
            underlying_primitive,
            ..
        } => {
            if is_known_geometry_struct(name) {
                "any/c".to_string()
            } else if name.ends_with("Type") && is_generic_type_param(name) {
                // Generic type params (ObjectType, KeyType) → object
                "cpointer?".to_string()
            } else {
                // Framework-prefixed aliases (NSBezelType, NSComparisonResult, …) are
                // enum typedefs → integer. Honor the extracted underlying width's
                // signedness: a signed NS_ENUM(NSInteger, …) carries negative cases
                // (NSComparisonResult.orderedAscending = -1) and must accept them.
                // Unsigned, non-integer-typed, or unknown widths keep the historical non-negative default.
                match underlying_primitive.as_deref() {
                    Some(p) if p.starts_with("int") => "exact-integer?".to_string(),
                    _ => "exact-nonnegative-integer?".to_string(),
                }
            }
        }
    }
}

/// Normalize a primitive name the same way the FFI mapper does.
fn normalize_primitive(name: &str) -> String {
    let unqualified = match name.rsplit_once('.') {
        Some((_, suffix)) => suffix,
        None => name,
    };
    unqualified.to_ascii_lowercase()
}

/// Check if a name is a known geometry struct alias.
fn is_known_geometry_struct(name: &str) -> bool {
    matches!(
        name,
        "NSRect"
            | "CGRect"
            | "NSPoint"
            | "CGPoint"
            | "NSSize"
            | "CGSize"
            | "NSRange"
            | "NSEdgeInsets"
            | "NSDirectionalEdgeInsets"
            | "NSAffineTransformStruct"
            | "CGAffineTransform"
            | "CGVector"
    )
}

/// Generate a Racket functions file for a framework's function exports.
///
/// Branches each emittable function on `objc_exposed` (ADR-0026):
/// - **Direct** (`objc_exposed == true`, the trampoline-elided ObjC limit): bound
///   against the framework dylib `_fw-lib` via `get-ffi-obj` — unchanged.
/// - **Trampolined** (`objc_exposed == false`, Swift-native residual): bound
///   against `libAPIAnywareRacket` (`_aw-lib`, from `swift-trampoline.rkt`) via
///   the generated `aw_racket_swift_*` entry, with racket-side coercion (ADR-0027).
/// - **Deferred** (async / generic / non-bridged-struct param): emitted as a
///   recording comment, never silently dropped (spec §5).
///
/// Uses `provide/contract` for boundary checking; each bound function gets both a
/// definition and a (post-coercion, racket-visible) contract.
pub fn generate_functions_file(functions: &[Function], framework: &str) -> String {
    let mapper = RacketFfiTypeMapper;
    let is_libdispatch = framework == "libdispatch";

    // Direct (ObjC-exposed) functions — bound against the framework dylib.
    let direct: Vec<&Function> = functions
        .iter()
        .filter(|f| is_emittable(f))
        .filter(|f| f.objc_exposed)
        .filter(|f| !(is_libdispatch && is_libdispatch_unexported(&f.name)))
        .collect();

    // Swift-native residual — classified into trampolines + deferred recordings.
    let mut tramps: Vec<FnTrampoline> = Vec::new();
    let mut deferred: Vec<(&Function, &'static str)> = Vec::new();
    for func in functions.iter().filter(|f| is_emittable(f) && !f.objc_exposed) {
        match classify_function(framework, func, functions) {
            FnDisposition::Trampoline(t) => tramps.push(t),
            FnDisposition::Deferred(reason) => deferred.push((func, reason.as_str())),
        }
    }

    // type-mapping.rkt is needed only by the direct `_fun` geometry-struct types;
    // trampoline reps are scalar/pointer/string and never pull it in.
    let direct_types = direct.iter().flat_map(|f| {
        std::iter::once(&f.return_type).chain(f.params.iter().map(|p| &p.param_type))
    });
    let needs_structs = any_struct_type(direct_types, &mapper);
    let needs_trampoline = !tramps.is_empty();

    let mut w = CodeWriter::new();
    w.line("#lang racket/base");
    write_line!(w, ";; Generated C function bindings for {}", framework);
    w.blank_line();
    w.line("(require ffi/unsafe");
    // `ffi/unsafe/objc` provides `_id` (and other ObjC types) used by
    // object-returning/taking C functions like
    // `CGDirectDisplayCopyCurrentMetalDevice`. Required unconditionally
    // for parity with `constants.rkt` and to avoid per-function detection
    // drift.
    w.line("         ffi/unsafe/objc");
    // Rename `racket/contract`'s `->` to `c->` to avoid colliding with
    // `ffi/unsafe`'s `->` (used as a literal in `(_fun ... -> ...)` below).
    // Extra runtime requires (type-mapping for geometry structs, swift-trampoline
    // for the Swift-native residual) extend the block; the last one closes it.
    let mut extra_requires: Vec<&str> = Vec::new();
    if needs_structs {
        extra_requires.push("\"../../runtime/type-mapping.rkt\"");
    }
    if needs_trampoline {
        extra_requires.push("\"../../runtime/swift-trampoline.rkt\"");
    }
    if extra_requires.is_empty() {
        w.line("         (rename-in racket/contract [-> c->]))");
    } else {
        w.line("         (rename-in racket/contract [-> c->])");
        for (i, req) in extra_requires.iter().enumerate() {
            let close = if i == extra_requires.len() - 1 { ")" } else { "" };
            write_line!(w, "         {}{}", req, close);
        }
    }
    w.blank_line();

    // Contract-based provide (direct first, then trampolined — deferred excluded).
    if direct.is_empty() && tramps.is_empty() {
        w.line("(provide)");
    } else {
        w.line("(provide/contract");
        for func in &direct {
            let param_contracts: Vec<String> = func
                .params
                .iter()
                .map(|p| map_contract(&p.param_type, false))
                .collect();
            let return_contract = map_contract(&func.return_type, true);

            let contract = if param_contracts.is_empty() {
                format!("(c-> {})", return_contract)
            } else {
                format!("(c-> {} {})", param_contracts.join(" "), return_contract)
            };

            write_line!(w, "  [{} {}]", func.name, contract);
        }
        for t in &tramps {
            write_line!(w, "  {}", t.provide_contract());
        }
        w.line("  )");
    }
    w.blank_line();

    // Load framework dylib (always — other files in the framework may re-export
    // this module, and the direct bindings need it).
    write_line!(
        w,
        "(define _fw-lib (ffi-lib \"{}\"))",
        framework_ffi_lib_arg(framework)
    );
    w.blank_line();

    // Direct function definitions (bound against `_fw-lib`).
    for (i, func) in direct.iter().enumerate() {
        // Emit thread-safety warning for functions with callback parameters.
        // _cprocedure callbacks SIGILL when invoked from a non-main OS thread
        // on Racket CS; #:async-apply deadlocks under nsapplication-run.
        let has_callback = func.params.iter().any(|p| {
            matches!(
                p.param_type.kind,
                TypeRefKind::FunctionPointer { .. } | TypeRefKind::Block { .. }
            )
        });
        if has_callback {
            if i > 0 {
                w.blank_line();
            }
            w.line("; WARNING: callback parameter — _cprocedure invoked from a foreign");
            w.line(";   OS thread (GCD worker, libdispatch) SIGILLs on Racket CS.");
            w.line(";   #:async-apply deadlocks under nsapplication-run.");
        }
        let param_types: Vec<String> = func
            .params
            .iter()
            .map(|p| {
                let t = mapper.map_type(&p.param_type, false);
                // libdispatch OS-object types (dispatch_queue_t etc.) resolve
                // to _id via OS_OBJECT_USE_OBJC, but no wrapper classes exist.
                // Emit _pointer so consumers can pass raw cpointers (e.g. from
                // ffi-obj-ref) without a (cast ... _pointer _id) ceremony. New
                // target emitters: see docs/pipeline/emitter-contract.md
                // ("OS_OBJECT_USE_OBJC bridged types") for the cross-language
                // contract.
                if is_libdispatch && t == "_id" {
                    "_pointer".to_string()
                } else {
                    t
                }
            })
            .collect();
        let return_type = {
            let t = mapper.map_type(&func.return_type, true);
            if is_libdispatch && t == "_id" {
                "_pointer".to_string()
            } else {
                t
            }
        };

        let fun_type = if param_types.is_empty() {
            format!("(_fun -> {})", return_type)
        } else {
            format!("(_fun {} -> {})", param_types.join(" "), return_type)
        };

        write_line!(
            w,
            "(define {} (get-ffi-obj '{} _fw-lib {}))",
            func.name,
            func.name,
            fun_type
        );
    }

    // Swift-native trampoline definitions (bound against `_aw-lib`, ADR-0027).
    if !tramps.is_empty() {
        w.blank_line();
        w.line(";; Swift-native residual — trampolined through libAPIAnywareRacket");
        w.line(";; (_aw-lib) rather than the framework dylib (ADR-0027).");
        for t in &tramps {
            for line in t.render_racket().lines() {
                w.line(line);
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

/// Count how many functions in the slice are emittable (not inline, not variadic).
pub fn count_emittable(functions: &[Function]) -> usize {
    functions.iter().filter(|f| is_emittable(f)).count()
}

#[cfg(test)]
mod tests {
    use super::*;
    use apianyware_macos_types::ir::Param;

    fn make_param(name: &str, kind: TypeRefKind) -> Param {
        Param {
            name: name.to_string(),
            param_type: TypeRef {
                nullable: false,
                kind,
            },
        }
    }

    fn make_function(
        name: &str,
        params: Vec<Param>,
        return_kind: TypeRefKind,
        inline: bool,
        variadic: bool,
    ) -> Function {
        Function {
            name: name.to_string(),
            params,
            return_type: TypeRef {
                nullable: false,
                kind: return_kind,
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

    // -----------------------------------------------------------------------
    // Contract mapping tests
    // -----------------------------------------------------------------------

    #[test]
    fn test_contract_primitives() {
        let double_t = TypeRef {
            nullable: false,
            kind: TypeRefKind::Primitive {
                name: "double".into(),
            },
        };
        assert_eq!(map_contract(&double_t, false), "real?");
        assert_eq!(map_contract(&double_t, true), "real?");

        let bool_t = TypeRef {
            nullable: false,
            kind: TypeRefKind::Primitive {
                name: "bool".into(),
            },
        };
        assert_eq!(map_contract(&bool_t, false), "boolean?");

        let uint32_t = TypeRef {
            nullable: false,
            kind: TypeRefKind::Primitive {
                name: "uint32".into(),
            },
        };
        assert_eq!(map_contract(&uint32_t, false), "exact-nonnegative-integer?");

        let int64_t = TypeRef {
            nullable: false,
            kind: TypeRefKind::Primitive {
                name: "int64".into(),
            },
        };
        assert_eq!(map_contract(&int64_t, false), "exact-integer?");
    }

    #[test]
    fn test_contract_void() {
        let void_t = TypeRef {
            nullable: false,
            kind: TypeRefKind::Primitive {
                name: "void".into(),
            },
        };
        assert_eq!(map_contract(&void_t, true), "void?");
        assert_eq!(map_contract(&void_t, false), "any/c");
    }

    #[test]
    fn test_contract_objects() {
        let non_null = TypeRef {
            nullable: false,
            kind: TypeRefKind::Class {
                name: "NSString".into(),
                framework: None,
                params: vec![],
            },
        };
        assert_eq!(map_contract(&non_null, false), "cpointer?");

        let nullable = TypeRef {
            nullable: true,
            kind: TypeRefKind::Class {
                name: "NSString".into(),
                framework: None,
                params: vec![],
            },
        };
        assert_eq!(map_contract(&nullable, false), "(or/c cpointer? #f)");

        let id_t = TypeRef {
            nullable: false,
            kind: TypeRefKind::Id,
        };
        assert_eq!(map_contract(&id_t, false), "cpointer?");
    }

    #[test]
    fn test_contract_pointers() {
        let ptr = TypeRef {
            nullable: false,
            kind: TypeRefKind::Pointer,
        };
        assert_eq!(map_contract(&ptr, false), "(or/c cpointer? #f)");

        let sel = TypeRef {
            nullable: false,
            kind: TypeRefKind::Selector,
        };
        assert_eq!(map_contract(&sel, false), "cpointer?");
    }

    #[test]
    fn test_contract_geometry_structs() {
        let point = TypeRef {
            nullable: false,
            kind: TypeRefKind::Alias {
                name: "NSPoint".into(),
                framework: None,
                underlying_primitive: None,
            },
        };
        assert_eq!(map_contract(&point, false), "any/c");

        let rect = TypeRef {
            nullable: false,
            kind: TypeRefKind::Alias {
                name: "CGRect".into(),
                framework: None,
                underlying_primitive: None,
            },
        };
        assert_eq!(map_contract(&rect, false), "any/c");
    }

    #[test]
    fn test_contract_framework_aliases() {
        let alias = TypeRef {
            nullable: false,
            kind: TypeRefKind::Alias {
                name: "NSStringEncoding".into(),
                framework: None,
                underlying_primitive: None,
            },
        };
        assert_eq!(map_contract(&alias, false), "exact-nonnegative-integer?");
    }

    #[test]
    fn test_contract_alias_signed_underlying_yields_exact_integer() {
        // NS_ENUM(NSInteger, NSComparisonResult) → underlying_primitive = "int64"
        // orderedAscending = -1, so the contract must accept negative values.
        let signed_alias = TypeRef {
            nullable: false,
            kind: TypeRefKind::Alias {
                name: "NSComparisonResult".into(),
                framework: None,
                underlying_primitive: Some("int64".into()),
            },
        };
        assert_eq!(map_contract(&signed_alias, false), "exact-integer?");

        // Also test int32-backed alias
        let signed32_alias = TypeRef {
            nullable: false,
            kind: TypeRefKind::Alias {
                name: "NSTextAlignment".into(),
                framework: None,
                underlying_primitive: Some("int32".into()),
            },
        };
        assert_eq!(map_contract(&signed32_alias, false), "exact-integer?");
    }

    #[test]
    fn test_contract_alias_unsigned_underlying_keeps_nonnegative() {
        // CF_ENUM(uint32_t, …) → underlying_primitive = "uint32" → non-negative
        let unsigned_alias = TypeRef {
            nullable: false,
            kind: TypeRefKind::Alias {
                name: "AXValueType".into(),
                framework: None,
                underlying_primitive: Some("uint32".into()),
            },
        };
        assert_eq!(
            map_contract(&unsigned_alias, false),
            "exact-nonnegative-integer?"
        );

        // NS_OPTIONS(NSUInteger, …) → underlying_primitive = "uint64" — the most
        // common unsigned backing for Apple bitmask types. Documents that the
        // `starts_with("int")` discriminator correctly leaves uint64 in the
        // non-negative branch.
        let uint64_alias = TypeRef {
            nullable: false,
            kind: TypeRefKind::Alias {
                name: "NSWindowStyleMask".into(),
                framework: None,
                underlying_primitive: Some("uint64".into()),
            },
        };
        assert_eq!(
            map_contract(&uint64_alias, false),
            "exact-nonnegative-integer?"
        );
    }

    #[test]
    fn test_contract_primitive_nsinteger_nsuinteger() {
        // Defence-in-depth: NSInteger/NSUInteger as raw Primitive names should
        // map to the same contracts as their canonical int64/uint64 equivalents.
        let nsinteger_t = TypeRef {
            nullable: false,
            kind: TypeRefKind::Primitive {
                name: "NSInteger".into(),
            },
        };
        assert_eq!(map_contract(&nsinteger_t, false), "exact-integer?");

        let nsuinteger_t = TypeRef {
            nullable: false,
            kind: TypeRefKind::Primitive {
                name: "NSUInteger".into(),
            },
        };
        assert_eq!(
            map_contract(&nsuinteger_t, false),
            "exact-nonnegative-integer?"
        );
    }

    #[test]
    fn test_contract_cstring_param_is_string() {
        let cstr = TypeRef {
            nullable: false,
            kind: TypeRefKind::CString,
        };
        assert_eq!(
            map_contract(&cstr, false),
            "string?",
            "CString params should accept string? (Racket auto-converts to C char*)"
        );
    }

    #[test]
    fn test_contract_cstring_return_includes_false() {
        // C functions returning `const char *` can return NULL.
        // Racket's `_string` FFI type converts NULL to #f, so the
        // contract must accept #f to avoid a contract violation.
        let cstr = TypeRef {
            nullable: false,
            kind: TypeRefKind::CString,
        };
        assert_eq!(
            map_contract(&cstr, true),
            "(or/c string? #f)",
            "CString returns must accept #f (NULL maps to #f via _string FFI type)"
        );
    }

    // -----------------------------------------------------------------------
    // Function generation tests (with contracts)
    // -----------------------------------------------------------------------

    #[test]
    fn test_simple_function_with_contract() {
        let functions = vec![make_function(
            "TKComputeDistance",
            vec![
                make_param(
                    "x",
                    TypeRefKind::Primitive {
                        name: "double".into(),
                    },
                ),
                make_param(
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
        let output = generate_functions_file(&functions, "TestKit");
        assert!(output.contains("(require ffi/unsafe"));
        assert!(output.contains("(rename-in racket/contract [-> c->])"));
        assert!(output.contains("(provide/contract"));
        assert!(output.contains("[TKComputeDistance (c-> real? real? real?)]"));
        assert!(output.contains(
            "(define TKComputeDistance (get-ffi-obj 'TKComputeDistance _fw-lib (_fun _double _double -> _double)))"
        ));
    }

    #[test]
    fn test_void_return_contract() {
        let functions = vec![make_function(
            "TKReset",
            vec![],
            TypeRefKind::Primitive {
                name: "void".into(),
            },
            false,
            false,
        )];
        let output = generate_functions_file(&functions, "TestKit");
        assert!(output.contains("[TKReset (c-> void?)]"));
        assert!(output.contains("(define TKReset (get-ffi-obj 'TKReset _fw-lib (_fun -> _void)))"));
    }

    #[test]
    fn test_struct_param_contract() {
        let functions = vec![make_function(
            "TKTransformPoint",
            vec![make_param(
                "point",
                TypeRefKind::Alias {
                    name: "NSPoint".into(),
                    framework: None,
                    underlying_primitive: None,
                },
            )],
            TypeRefKind::Alias {
                name: "NSPoint".into(),
                framework: None,
                underlying_primitive: None,
            },
            false,
            false,
        )];
        let output = generate_functions_file(&functions, "TestKit");
        assert!(output.contains("[TKTransformPoint (c-> any/c any/c)]"));
    }

    #[test]
    fn test_mixed_param_contract() {
        let functions = vec![make_function(
            "TKCreateBuffer",
            vec![
                make_param(
                    "name",
                    TypeRefKind::Class {
                        name: "NSString".into(),
                        framework: None,
                        params: vec![],
                    },
                ),
                make_param(
                    "size",
                    TypeRefKind::Primitive {
                        name: "uint32".into(),
                    },
                ),
            ],
            TypeRefKind::Pointer,
            false,
            false,
        )];
        let output = generate_functions_file(&functions, "TestKit");
        assert!(output.contains(
            "[TKCreateBuffer (c-> cpointer? exact-nonnegative-integer? (or/c cpointer? #f))]"
        ));
    }

    #[test]
    fn test_variadic_function_skipped() {
        let functions = vec![make_function(
            "TKLog",
            vec![make_param(
                "format",
                TypeRefKind::Class {
                    name: "NSString".into(),
                    framework: None,
                    params: vec![],
                },
            )],
            TypeRefKind::Primitive {
                name: "void".into(),
            },
            false,
            true,
        )];
        let output = generate_functions_file(&functions, "TestKit");
        assert!(
            !output.contains("TKLog"),
            "Variadic functions should be skipped"
        );
    }

    #[test]
    fn test_inline_function_skipped() {
        let functions = vec![make_function(
            "TKFastHash",
            vec![make_param("data", TypeRefKind::Pointer)],
            TypeRefKind::Primitive {
                name: "uint64".into(),
            },
            true,
            false,
        )];
        let output = generate_functions_file(&functions, "TestKit");
        assert!(
            !output.contains("TKFastHash"),
            "Inline functions should be skipped"
        );
    }

    #[test]
    fn test_count_emittable() {
        let functions = vec![
            make_function(
                "F1",
                vec![],
                TypeRefKind::Primitive {
                    name: "void".into(),
                },
                false,
                false,
            ),
            make_function(
                "F2",
                vec![],
                TypeRefKind::Primitive {
                    name: "void".into(),
                },
                true,
                false,
            ),
            make_function(
                "F3",
                vec![],
                TypeRefKind::Primitive {
                    name: "void".into(),
                },
                false,
                true,
            ),
            make_function(
                "F4",
                vec![],
                TypeRefKind::Primitive {
                    name: "void".into(),
                },
                false,
                false,
            ),
        ];
        assert_eq!(count_emittable(&functions), 2);
    }

    #[test]
    fn test_framework_lib_loading() {
        let output = generate_functions_file(&[], "CoreGraphics");
        assert!(output.contains(
            "(define _fw-lib (ffi-lib \"/System/Library/Frameworks/CoreGraphics.framework/CoreGraphics\"))"
        ));
    }

    #[test]
    fn test_empty_functions_provide() {
        let output = generate_functions_file(&[], "TestKit");
        assert!(output.contains("(provide)"));
        assert!(!output.contains("provide/contract"));
    }

    #[test]
    fn test_multiple_functions_ordered() {
        let functions = vec![
            make_function(
                "Alpha",
                vec![],
                TypeRefKind::Primitive {
                    name: "void".into(),
                },
                false,
                false,
            ),
            make_function(
                "Beta",
                vec![],
                TypeRefKind::Primitive {
                    name: "void".into(),
                },
                false,
                false,
            ),
        ];
        let output = generate_functions_file(&functions, "TestKit");
        let alpha_pos = output.find("Alpha").unwrap();
        let beta_pos = output.find("Beta").unwrap();
        assert!(alpha_pos < beta_pos, "Functions should preserve IR order");
    }

    #[test]
    fn test_qualified_primitive_contract() {
        let t = TypeRef {
            nullable: false,
            kind: TypeRefKind::Primitive {
                name: "Swift.Bool".into(),
            },
        };
        assert_eq!(map_contract(&t, false), "boolean?");

        let t = TypeRef {
            nullable: false,
            kind: TypeRefKind::Primitive {
                name: "Swift.Double".into(),
            },
        };
        assert_eq!(map_contract(&t, false), "real?");
    }

    // -----------------------------------------------------------------------
    // type-mapping.rkt require emission (geometry struct detection)
    // -----------------------------------------------------------------------

    #[test]
    fn test_functions_with_struct_param_require_type_mapping() {
        // CoreGraphics-style: a function taking a CGAffineTransform by value
        // must emit a require for type-mapping.rkt so _CGAffineTransform is
        // in scope for the generated _fun signature.
        let functions = vec![make_function(
            "CGAffineTransformInvert",
            vec![make_param(
                "t",
                TypeRefKind::Alias {
                    name: "CGAffineTransform".into(),
                    framework: None,
                    underlying_primitive: None,
                },
            )],
            TypeRefKind::Alias {
                name: "CGAffineTransform".into(),
                framework: None,
                underlying_primitive: None,
            },
            false,
            false,
        )];
        let output = generate_functions_file(&functions, "CoreGraphics");
        assert!(
            output.contains("\"../../runtime/type-mapping.rkt\""),
            "Expected type-mapping.rkt require when a function uses a \
             geometry struct. Output was:\n{output}"
        );
    }

    #[test]
    fn test_functions_without_structs_omit_type_mapping() {
        // A framework with only primitive/object functions should not pull
        // in type-mapping.rkt (it's a cross-framework runtime dependency
        // and we want to keep it opt-in).
        let functions = vec![make_function(
            "TKComputeDistance",
            vec![
                make_param(
                    "x",
                    TypeRefKind::Primitive {
                        name: "double".into(),
                    },
                ),
                make_param(
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
        let output = generate_functions_file(&functions, "TestKit");
        assert!(
            !output.contains("type-mapping.rkt"),
            "Expected no type-mapping.rkt require when no struct types \
             are used. Output was:\n{output}"
        );
    }

    #[test]
    fn test_functions_with_struct_return_require_type_mapping() {
        // Return-type-only struct use must also trigger the require.
        let functions = vec![make_function(
            "NSMakePoint",
            vec![
                make_param(
                    "x",
                    TypeRefKind::Primitive {
                        name: "double".into(),
                    },
                ),
                make_param(
                    "y",
                    TypeRefKind::Primitive {
                        name: "double".into(),
                    },
                ),
            ],
            TypeRefKind::Alias {
                name: "NSPoint".into(),
                framework: None,
                underlying_primitive: None,
            },
            false,
            false,
        )];
        let output = generate_functions_file(&functions, "Foundation");
        assert!(output.contains("\"../../runtime/type-mapping.rkt\""));
    }

    #[test]
    fn test_functions_file_requires_ffi_unsafe_objc() {
        // The `_id` FFI type used by object-returning or object-taking C
        // functions (e.g., CGDirectDisplayCopyCurrentMetalDevice) is defined
        // in `ffi/unsafe/objc`, not plain `ffi/unsafe`. Without this require,
        // any CoreGraphics/etc. file that returns or accepts an object fails
        // to load with "unbound identifier: _id". `constants.rkt` already
        // requires this unconditionally; `functions.rkt` must do the same.
        let functions = vec![make_function(
            "CGDirectDisplayCopyCurrentMetalDevice",
            vec![make_param(
                "display",
                TypeRefKind::Primitive {
                    name: "uint64".into(),
                },
            )],
            TypeRefKind::Id,
            false,
            false,
        )];
        let output = generate_functions_file(&functions, "CoreGraphics");
        assert!(
            output.contains("ffi/unsafe/objc"),
            "functions.rkt must require ffi/unsafe/objc so `_id` is in \
             scope. Output was:\n{output}"
        );
    }

    #[test]
    fn test_inline_struct_function_does_not_trigger_require() {
        // Inline functions are skipped for emission — a struct type inside
        // a skipped function should NOT cause the require to appear, since
        // the corresponding _fun signature is never generated.
        let functions = vec![make_function(
            "CGRectGetMinX",
            vec![make_param(
                "r",
                TypeRefKind::Alias {
                    name: "CGRect".into(),
                    framework: None,
                    underlying_primitive: None,
                },
            )],
            TypeRefKind::Primitive {
                name: "double".into(),
            },
            true,
            false,
        )];
        let output = generate_functions_file(&functions, "CoreGraphics");
        assert!(
            !output.contains("type-mapping.rkt"),
            "Skipped (inline) functions must not trigger type-mapping \
             require. Output was:\n{output}"
        );
    }

    // -----------------------------------------------------------------------
    // libdispatch _id → _pointer override
    // -----------------------------------------------------------------------

    #[test]
    fn test_libdispatch_id_params_emit_pointer() {
        // dispatch_queue_t etc. are ObjC objects under OS_OBJECT_USE_OBJC=1,
        // but no wrapper classes exist. Emitting _pointer instead of _id
        // lets consumers pass raw cpointers (e.g. from ffi-obj-ref) without
        // a (cast ... _pointer _id) ceremony.
        let functions = vec![make_function(
            "dispatch_async_f",
            vec![
                make_param("queue", TypeRefKind::Id),
                make_param("context", TypeRefKind::Pointer),
                make_param(
                    "work",
                    TypeRefKind::FunctionPointer {
                        name: Some("dispatch_function_t".into()),
                        params: vec![TypeRef {
                            nullable: false,
                            kind: TypeRefKind::Pointer,
                        }],
                        return_type: Box::new(TypeRef {
                            nullable: false,
                            kind: TypeRefKind::Primitive {
                                name: "void".into(),
                            },
                        }),
                    },
                ),
            ],
            TypeRefKind::Primitive {
                name: "void".into(),
            },
            false,
            false,
        )];
        let output = generate_functions_file(&functions, "libdispatch");
        assert!(
            output.contains("(_fun _pointer _pointer _pointer -> _void)"),
            "libdispatch _id params should be emitted as _pointer. Output was:\n{output}"
        );
        assert!(
            !output.contains("_id"),
            "libdispatch functions should not contain _id. Output was:\n{output}"
        );
    }

    #[test]
    fn test_libdispatch_id_return_emits_pointer() {
        // dispatch_queue_create returns dispatch_queue_t (id in IR).
        // Should emit _pointer for libdispatch.
        let functions = vec![make_function(
            "dispatch_queue_create",
            vec![
                make_param(
                    "label",
                    TypeRefKind::Class {
                        name: "NSString".into(),
                        framework: None,
                        params: vec![],
                    },
                ),
                make_param("attr", TypeRefKind::Id),
            ],
            TypeRefKind::Id,
            false,
            false,
        )];
        let output = generate_functions_file(&functions, "libdispatch");
        assert!(
            output.contains("(_fun _pointer _pointer -> _pointer)"),
            "libdispatch _id returns should be emitted as _pointer. Output was:\n{output}"
        );
    }

    #[test]
    fn test_non_libdispatch_id_params_keep_id() {
        // Non-libdispatch frameworks must keep _id for ObjC object params.
        let functions = vec![make_function(
            "CGDirectDisplayCopyCurrentMetalDevice",
            vec![make_param(
                "display",
                TypeRefKind::Primitive {
                    name: "uint64".into(),
                },
            )],
            TypeRefKind::Id,
            false,
            false,
        )];
        let output = generate_functions_file(&functions, "CoreGraphics");
        assert!(
            output.contains("-> _id"),
            "Non-libdispatch _id returns must stay as _id. Output was:\n{output}"
        );
    }

    // -----------------------------------------------------------------------
    // CString function generation (Bug: nullable return contracts)
    // -----------------------------------------------------------------------

    #[test]
    fn test_cstring_return_contract_includes_false() {
        // CFStringGetCStringPtr returns `const char *` which can be NULL.
        // The contract must include #f.
        let functions = vec![make_function(
            "CFStringGetCStringPtr",
            vec![
                make_param("theString", TypeRefKind::Pointer),
                make_param(
                    "encoding",
                    TypeRefKind::Primitive {
                        name: "uint32".into(),
                    },
                ),
            ],
            TypeRefKind::CString,
            false,
            false,
        )];
        let output = generate_functions_file(&functions, "CoreFoundation");
        assert!(
            output.contains("(or/c string? #f)"),
            "CString return contract must include #f for NULL. Output was:\n{output}"
        );
    }

    #[test]
    fn test_cstring_param_contract_is_string() {
        // Function taking a C string param — contract should be string?, not nullable.
        let functions = vec![make_function(
            "TKLookup",
            vec![make_param("name", TypeRefKind::CString)],
            TypeRefKind::Primitive {
                name: "int32".into(),
            },
            false,
            false,
        )];
        let output = generate_functions_file(&functions, "TestKit");
        assert!(
            output.contains("[TKLookup (c-> string? exact-integer?)]"),
            "CString param contract should be string?. Output was:\n{output}"
        );
    }

    // -----------------------------------------------------------------------
    // Foreign-thread safety warnings for callback parameters
    // -----------------------------------------------------------------------

    #[test]
    fn test_function_pointer_param_emits_thread_warning() {
        // Functions with callback (function pointer) parameters should
        // emit a warning comment about _cprocedure SIGILL on foreign threads.
        let functions = vec![Function {
            name: "CGEventTapCreate".to_string(),
            params: vec![
                Param {
                    name: "tap".to_string(),
                    param_type: TypeRef {
                        nullable: false,
                        kind: TypeRefKind::Primitive {
                            name: "uint32".into(),
                        },
                    },
                },
                Param {
                    name: "callback".to_string(),
                    param_type: TypeRef {
                        nullable: false,
                        kind: TypeRefKind::FunctionPointer {
                            name: Some("CGEventTapCallBack".into()),
                            params: vec![],
                            return_type: Box::new(TypeRef {
                                nullable: false,
                                kind: TypeRefKind::Pointer,
                            }),
                        },
                    },
                },
            ],
            return_type: TypeRef {
                nullable: false,
                kind: TypeRefKind::Pointer,
            },
            inline: false,
            variadic: false,
            source: None,
            provenance: None,
            doc_refs: None,
            objc_exposed: true,
            swift_fn: None,
        }];
        let output = generate_functions_file(&functions, "CoreGraphics");
        assert!(
            output.contains("; WARNING:"),
            "Function with callback param should have a thread-safety warning. Output was:\n{output}"
        );
        assert!(
            output.contains("_cprocedure"),
            "Warning should mention _cprocedure. Output was:\n{output}"
        );
    }

    // -----------------------------------------------------------------------
    // Swift-native residual routing (objc_exposed == false → trampolines)
    // -----------------------------------------------------------------------

    /// A Swift-native (`objc_exposed == false`) function with the given
    /// `SwiftFnInfo`, the shape `map_top_level_function` produces.
    fn swift_function(
        name: &str,
        params: Vec<Param>,
        return_kind: TypeRefKind,
        info: apianyware_macos_types::ir::SwiftFnInfo,
    ) -> Function {
        Function {
            name: name.to_string(),
            params,
            return_type: TypeRef {
                nullable: false,
                kind: return_kind,
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
    fn direct_and_trampoline_functions_route_to_different_libs() {
        use apianyware_macos_types::ir::SwiftFnInfo;
        let functions = vec![
            // Direct ObjC-exposed C function — unchanged, bound against _fw-lib.
            make_function(
                "TKComputeDistance",
                vec![make_param("x", TypeRefKind::Primitive { name: "double".into() })],
                TypeRefKind::Primitive { name: "double".into() },
                false,
                false,
            ),
            // Swift-native scalar function — trampolined against _aw-lib.
            swift_function(
                "TKSwiftScale",
                vec![make_param("factor", TypeRefKind::Primitive { name: "double".into() })],
                TypeRefKind::Primitive { name: "double".into() },
                SwiftFnInfo::default(),
            ),
        ];
        let out = generate_functions_file(&functions, "TestKit");
        // The swift-trampoline runtime is required when any residual is present.
        assert!(out.contains("\"../../runtime/swift-trampoline.rkt\""), "{out}");
        // Direct function still binds the framework dylib.
        assert!(
            out.contains("(define TKComputeDistance (get-ffi-obj 'TKComputeDistance _fw-lib"),
            "{out}"
        );
        // Swift-native function binds the trampoline entry against _aw-lib.
        assert!(
            out.contains("(define TKSwiftScale (get-ffi-obj 'aw_racket_swift_TestKit_TKSwiftScale _aw-lib"),
            "{out}"
        );
        // Both appear in the provide/contract block.
        assert!(out.contains("[TKComputeDistance (c-> real? real?)]"), "{out}");
        assert!(out.contains("[TKSwiftScale (c-> real? real?)]"), "{out}");
    }

    #[test]
    fn swift_string_function_uses_coercers() {
        use apianyware_macos_types::ir::SwiftFnInfo;
        let functions = vec![swift_function(
            "TKSwiftGreeting",
            vec![make_param("name", nsstring_kind())],
            nsstring_kind(),
            SwiftFnInfo::default(),
        )];
        let out = generate_functions_file(&functions, "TestKit");
        assert!(out.contains("aw-string-arg"), "string arg bridged in:\n{out}");
        assert!(out.contains("aw-string-result"), "string result coerced out:\n{out}");
        assert!(out.contains("[TKSwiftGreeting (c-> string? (or/c string? #f))]"), "{out}");
    }

    #[test]
    fn deferred_residual_is_recorded_as_comment_not_dropped() {
        use apianyware_macos_types::ir::SwiftFnInfo;
        let functions = vec![swift_function(
            "TKSwiftFetch",
            vec![],
            TypeRefKind::Primitive { name: "void".into() },
            SwiftFnInfo {
                is_async: true,
                ..Default::default()
            },
        )];
        let out = generate_functions_file(&functions, "TestKit");
        // Not bound...
        assert!(!out.contains("aw_racket_swift_TestKit_TKSwiftFetch"), "{out}");
        // ...but recorded with its reason.
        assert!(
            out.contains(";;   TKSwiftFetch — deferred_async"),
            "deferred residual must be recorded:\n{out}"
        );
    }

    #[test]
    fn test_no_callback_param_no_warning() {
        // Functions without callback params should have no warning.
        let functions = vec![make_function(
            "TKSimple",
            vec![make_param(
                "x",
                TypeRefKind::Primitive {
                    name: "double".into(),
                },
            )],
            TypeRefKind::Primitive {
                name: "void".into(),
            },
            false,
            false,
        )];
        let output = generate_functions_file(&functions, "TestKit");
        assert!(
            !output.contains("; WARNING:"),
            "Functions without callbacks should have no warning. Output was:\n{output}"
        );
    }
}
