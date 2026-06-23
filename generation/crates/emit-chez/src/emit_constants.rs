//! Chez constants file emission.
//!
//! Three constant flavours land in this file:
//!
//! 1. **Pointer-typed globals** (`extern NSString * const Foo`). The symbol
//!    `Foo` is the *address* of the storage holding the NSString pointer;
//!    we dereference once with `(foreign-ref 'uptr (foreign-entry "Foo") 0)`.
//! 2. **Struct-typed globals** (`_dispatch_main_q`). The symbol's address
//!    *is* the struct; we expose the address itself via `foreign-entry`.
//! 3. **CFSTR macros** — compile-time constant NSStrings the C macro
//!    expands to. The macro target has no exported symbol; we build a
//!    retained NSString at load time via the chez dylib's
//!    `string->nsstring-ptr` (plus an `objc_retain` so the value outlives
//!    the autorelease pool that wraps the library load).

use apianyware_emit::code_writer::CodeWriter;
use apianyware_emit::ffi_type_mapping::FfiTypeMapper;
use apianyware_emit::write_line;
use apianyware_types::ir::Constant;
use apianyware_types::type_ref::{TypeRef, TypeRefKind};

use crate::ffi_type_mapping::ChezFfiTypeMapper;
use crate::shared_signatures::framework_shared_object_arg;
use crate::trampoline::classify_constant;

/// True if the constant's declared type is a raw struct (the symbol *is*
/// the struct, not a pointer to one).
fn is_struct_data_symbol(t: &TypeRef) -> bool {
    matches!(t.kind, TypeRefKind::Struct { .. })
}

/// `foreign-ref` type token for reading the value at a global pointer's
/// storage address. Maps the IR type to the Chez memory type used in
/// `(foreign-ref '<token> addr 0)`.
fn foreign_ref_type(t: &TypeRef, mapper: &dyn FfiTypeMapper) -> &'static str {
    match &t.kind {
        TypeRefKind::Primitive { name } => match name.to_ascii_lowercase().as_str() {
            "double" => "double-float",
            "float" => "single-float",
            "int8" => "integer-8",
            "uint8" => "unsigned-8",
            "int16" => "integer-16",
            "uint16" => "unsigned-16",
            "int32" => "integer-32",
            "uint32" => "unsigned-32",
            "int64" | "nsinteger" => "integer-64",
            "uint64" | "nsuinteger" => "unsigned-64",
            _ => "uptr",
        },
        TypeRefKind::Class { .. }
        | TypeRefKind::Id
        | TypeRefKind::Instancetype
        | TypeRefKind::Selector
        | TypeRefKind::ClassRef
        | TypeRefKind::Pointer
        | TypeRefKind::Block { .. }
        | TypeRefKind::FunctionPointer { .. }
        | TypeRefKind::CString => "uptr",
        TypeRefKind::Alias {
            underlying_primitive,
            ..
        } => match underlying_primitive
            .as_ref()
            .map(|s| s.to_ascii_lowercase())
            .as_deref()
        {
            Some("int8") => "integer-8",
            Some("uint8") => "unsigned-8",
            Some("int16") => "integer-16",
            Some("uint16") => "unsigned-16",
            Some("int32") => "integer-32",
            Some("uint32") => "unsigned-32",
            Some("int64") | Some("nsinteger") => "integer-64",
            Some("uint64") | Some("nsuinteger") => "unsigned-64",
            Some("double") => "double-float",
            Some("float") => "single-float",
            _ => {
                // Geometry struct aliases come here; treated as struct globals
                // by the caller (is_struct_data_symbol returns false but the
                // alias-handling branch defers to mapper). For non-geometry
                // aliases the safe default is the wide unsigned integer.
                if mapper.is_struct_type(t) {
                    "uptr"
                } else {
                    "unsigned-64"
                }
            }
        },
        TypeRefKind::Struct { .. } => "uptr",
    }
}

/// Names that `constants.sls` exports — every constant in IR order. Direct
/// (ObjC-exposed) constants and Swift-native residual constants alike: the
/// residual is trampolined (ADR-0027, leaf 060), so its names are now exported
/// (previously skipped). The constant binding name equals the constant name.
pub fn constant_names(constants: &[Constant]) -> Vec<String> {
    constants.iter().map(|c| c.name.clone()).collect()
}

/// Generate a Chez `constants.sls` library for one framework.
pub fn generate_constants_file(constants: &[Constant], framework: &str) -> String {
    // Direct (ObjC-exposed) constants bind against the framework dylib; the
    // Swift-native residual (`objc_exposed == false`, ADR-0026) has no C symbol so
    // it routes to constant trampolines in libAPIAnywareChez (ADR-0027, leaf 060).
    let direct: Vec<&Constant> = constants.iter().filter(|c| c.objc_exposed).collect();
    let residual: Vec<&Constant> = constants.iter().filter(|c| !c.objc_exposed).collect();
    let mapper = ChezFfiTypeMapper;
    let fw_low = framework.to_ascii_lowercase();
    let mut w = CodeWriter::new();

    write_line!(
        w,
        ";; Generated constant definitions for {} — do not edit",
        framework
    );
    write_line!(w, "(library (apianyware {} constants)", fw_low);

    let exports = constant_names(constants);
    if exports.is_empty() {
        w.line("  (export)");
    } else {
        w.line("  (export");
        for n in &exports {
            write_line!(w, "    {}", n);
        }
        w.line("    )");
    }

    // `(apianyware runtime ffi)` loads `libAPIAnywareChez.dylib` (against which the
    // trampoline entries resolve) and exports the dlsym surface. The trampoline
    // coercers come from `(apianyware runtime swift-trampoline)`, imported only
    // when a residual constant is present.
    w.line("  (import (chezscheme)");
    if residual.is_empty() {
        w.line("          (apianyware runtime ffi))");
    } else {
        w.line("          (apianyware runtime ffi)");
        w.line("          (apianyware runtime swift-trampoline))");
    }
    w.blank_line();

    // R6RS library bodies require all definitions to come before any
    // expression; hide the `load-shared-object` inside a dummy `define`
    // RHS so subsequent `(define …)` forms remain valid. The load runs
    // at library instantiation, before any foreign-entry resolves.
    write_line!(
        w,
        "  (define %fw-lib-loaded (begin (load-shared-object \"{}\") #t))",
        framework_shared_object_arg(framework)
    );
    w.blank_line();

    for c in &direct {
        if let Some(v) = &c.macro_value {
            // CFSTR("…") — build a retained NSString at load time. The
            // retain is essential: string->nsstring-ptr returns +0 inside
            // an autorelease pool, and the constant must outlive that pool.
            write_line!(
                w,
                "  (define {} (objc_retain (string->nsstring-ptr \"{}\")))",
                c.name,
                escape_string_literal(v)
            );
        } else if is_struct_data_symbol(&c.constant_type) {
            // Struct globals: the symbol IS the struct — expose its address.
            write_line!(w, "  (define {} (foreign-entry \"{}\"))", c.name, c.name);
        } else {
            // Pointer or primitive — dereference the symbol's storage.
            let ref_ty = foreign_ref_type(&c.constant_type, &mapper);
            write_line!(
                w,
                "  (define {} (foreign-ref '{} (foreign-entry \"{}\") 0))",
                c.name,
                ref_ty,
                c.name
            );
        }
    }

    // Swift-native residual constants — read through the constant trampolines in
    // libAPIAnywareChez (ADR-0027 ported to chez). Each is a zero-arg reader of
    // the Swift global, evaluated once at load; String values coerce Scheme-side.
    if !residual.is_empty() {
        w.blank_line();
        w.line("  ;; Swift-native residual — read through libAPIAnywareChez constant");
        w.line("  ;; trampolines (aw_chez_swift_const_*) rather than a C symbol (ADR-0027).");
        // Force libAPIAnywareChez to load before the readers below resolve (chez
        // instantiates lazily; see swift-trampoline.sls). Must precede the readers,
        // which are evaluated (called) at instantiation.
        w.line("  (define %aw-lib-ready aw-trampoline-lib-ready)");
        for c in &residual {
            let t = classify_constant(framework, c);
            write_line!(w, "  {}", t.render_chez());
        }
    }

    w.blank_line();
    w.line(")");
    w.finish()
}

/// Escape a Scheme string literal. The IR macro values come from C source
/// after preprocessor expansion; backslashes and double quotes are the only
/// realistic concerns for the CFSTR set we observe.
fn escape_string_literal(s: &str) -> String {
    let mut out = String::with_capacity(s.len());
    for ch in s.chars() {
        match ch {
            '\\' => out.push_str("\\\\"),
            '"' => out.push_str("\\\""),
            other => out.push(other),
        }
    }
    out
}

#[cfg(test)]
mod tests {
    use super::*;
    use apianyware_types::ir::Constant;
    use apianyware_types::type_ref::{TypeRef, TypeRefKind};

    fn c(name: &str, kind: TypeRefKind) -> Constant {
        Constant {
            name: name.into(),
            constant_type: TypeRef {
                nullable: false,
                kind,
            },
            source: None,
            provenance: None,
            doc_refs: None,
            macro_value: None,
            objc_exposed: true,
        }
    }

    fn cfstr(name: &str, value: &str) -> Constant {
        Constant {
            name: name.into(),
            constant_type: TypeRef {
                nullable: true,
                kind: TypeRefKind::Id,
            },
            source: None,
            provenance: None,
            doc_refs: None,
            macro_value: Some(value.into()),
            objc_exposed: true,
        }
    }

    #[test]
    fn emits_library_header_and_loads_dylib() {
        let consts = vec![c(
            "TKVersionString",
            TypeRefKind::Class {
                name: "NSString".into(),
                framework: None,
                params: vec![],
            },
        )];
        let out = generate_constants_file(&consts, "TestKit");
        assert!(out.contains("(library (apianyware testkit constants)"));
        assert!(out.contains(
            "(load-shared-object \"/System/Library/Frameworks/TestKit.framework/TestKit\")"
        ));
    }

    #[test]
    fn pointer_global_dereferences_symbol_address() {
        let consts = vec![c(
            "TKVersionString",
            TypeRefKind::Class {
                name: "NSString".into(),
                framework: None,
                params: vec![],
            },
        )];
        let out = generate_constants_file(&consts, "TestKit");
        assert!(out.contains(
            "(define TKVersionString (foreign-ref 'uptr (foreign-entry \"TKVersionString\") 0))"
        ));
    }

    #[test]
    fn primitive_global_uses_typed_foreign_ref() {
        let consts = vec![c(
            "TKDefaultTimeout",
            TypeRefKind::Primitive {
                name: "double".into(),
            },
        )];
        let out = generate_constants_file(&consts, "TestKit");
        assert!(out.contains("(foreign-ref 'double-float (foreign-entry \"TKDefaultTimeout\") 0)"));
    }

    #[test]
    fn struct_global_uses_foreign_entry_directly() {
        let consts = vec![c(
            "_dispatch_main_q",
            TypeRefKind::Struct {
                name: "struct dispatch_queue_s".into(),
            },
        )];
        let out = generate_constants_file(&consts, "libdispatch");
        assert!(out.contains("(define _dispatch_main_q (foreign-entry \"_dispatch_main_q\"))"));
        assert!(out.contains("(load-shared-object \"libSystem.dylib\")"));
        assert!(!out.contains("foreign-ref"));
    }

    #[test]
    fn cfstr_constant_builds_retained_nsstring() {
        let consts = vec![cfstr("kAXWindowsAttribute", "AXWindows")];
        let out = generate_constants_file(&consts, "ApplicationServices");
        assert!(out.contains(
            "(define kAXWindowsAttribute (objc_retain (string->nsstring-ptr \"AXWindows\")))"
        ));
    }

    #[test]
    fn alias_with_signed_underlying_uses_signed_foreign_ref() {
        let consts = vec![c(
            "TKSomeSigned",
            TypeRefKind::Alias {
                name: "NSComparisonResult".into(),
                framework: None,
                underlying_primitive: Some("int64".into()),
            },
        )];
        let out = generate_constants_file(&consts, "TestKit");
        assert!(out.contains("(foreign-ref 'integer-64 (foreign-entry \"TKSomeSigned\") 0)"));
    }

    #[test]
    fn empty_constants_emit_empty_export() {
        let out = generate_constants_file(&[], "TestKit");
        assert!(out.contains("  (export)"));
    }

    #[test]
    fn libdispatch_loads_libsystem() {
        let consts = vec![c(
            "_dispatch_main_q",
            TypeRefKind::Struct {
                name: "struct dispatch_queue_s".into(),
            },
        )];
        let out = generate_constants_file(&consts, "libdispatch");
        assert!(out.contains("(load-shared-object \"libSystem.dylib\")"));
    }

    /// A Swift-native (`objc_exposed == false`) constant.
    fn swift_const(name: &str, kind: TypeRefKind) -> Constant {
        Constant {
            name: name.into(),
            constant_type: TypeRef {
                nullable: false,
                kind,
            },
            source: None,
            provenance: None,
            doc_refs: None,
            macro_value: None,
            objc_exposed: false,
        }
    }

    #[test]
    fn swift_native_string_constant_reads_through_trampoline() {
        // MLCreateErrorDomain: a Swift-native String global — no C symbol, so it
        // reads through the constant trampoline with Scheme-side string coercion.
        let consts = vec![swift_const(
            "MLCreateErrorDomain",
            TypeRefKind::Class {
                name: "NSString".into(),
                framework: Some("Foundation".into()),
                params: vec![],
            },
        )];
        let out = generate_constants_file(&consts, "CreateML");
        assert!(
            out.contains("(define MLCreateErrorDomain (aw-string-result ((foreign-procedure \"aw_chez_swift_const_CreateML_MLCreateErrorDomain\" () void*))))"),
            "{out}"
        );
        // Exported and pulls in the coercion runtime; never a direct foreign-ref.
        assert!(out.contains("    MLCreateErrorDomain"), "{out}");
        assert!(
            out.contains("(apianyware runtime swift-trampoline)"),
            "{out}"
        );
        assert!(
            !out.contains("foreign-entry \"MLCreateErrorDomain\""),
            "{out}"
        );
    }

    #[test]
    fn direct_and_residual_constants_coexist() {
        let consts = vec![
            c(
                "TKVersionString",
                TypeRefKind::Class {
                    name: "NSString".into(),
                    framework: None,
                    params: vec![],
                },
            ),
            swift_const(
                "TKSwiftSeedDomain",
                TypeRefKind::Class {
                    name: "NSString".into(),
                    framework: Some("Foundation".into()),
                    params: vec![],
                },
            ),
        ];
        let out = generate_constants_file(&consts, "TestKit");
        // Direct constant still dereferences its C symbol.
        assert!(
            out.contains("(foreign-ref 'uptr (foreign-entry \"TKVersionString\") 0)"),
            "{out}"
        );
        // Residual constant routes to the trampoline.
        assert!(
            out.contains("aw_chez_swift_const_TestKit_TKSwiftSeedDomain"),
            "{out}"
        );
    }
}
