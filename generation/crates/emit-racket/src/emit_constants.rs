//! Racket constants file code generation.
//!
//! Emits `get-ffi-obj` definitions for framework-level global constants
//! (e.g., NSString notification names, numeric defaults).
//!
//! Generated bindings include `provide/contract` forms that enforce value
//! types at module boundaries using Racket contracts mapped from IR TypeRef.

use apianyware_macos_emit::code_writer::CodeWriter;
use apianyware_macos_emit::ffi_type_mapping::{FfiTypeMapper, RacketFfiTypeMapper};
use apianyware_macos_emit::write_line;
use apianyware_macos_types::ir::Constant;

use apianyware_macos_types::type_ref::{TypeRef, TypeRefKind};

use crate::emit_functions::map_contract;
use crate::shared_signatures::{any_struct_type, framework_ffi_lib_arg};

/// Returns true if a constant's declared type is a raw struct (not a
/// pointer or typedef alias). These globals need `ffi-obj-ref` to get
/// the symbol's address rather than `get-ffi-obj` which dereferences it.
fn is_struct_data_symbol(type_ref: &TypeRef) -> bool {
    matches!(type_ref.kind, TypeRefKind::Struct { .. })
}

/// Returns true if any constant in the list uses a macro-defined value (CFSTR).
fn has_cfstr_constants(constants: &[Constant]) -> bool {
    constants.iter().any(|c| c.macro_value.is_some())
}

/// Generate a Racket constants file for a framework.
pub fn generate_constants_file(constants: &[Constant], framework: &str) -> String {
    let mapper = RacketFfiTypeMapper;
    // Struct data symbols use ffi-obj-ref (no FFI type needed), so exclude
    // them from the geometry struct detection that triggers type-mapping.rkt.
    let needs_structs = any_struct_type(
        constants
            .iter()
            .filter(|c| !is_struct_data_symbol(&c.constant_type))
            .map(|c| &c.constant_type),
        &mapper,
    );
    let needs_cfstr = has_cfstr_constants(constants);
    let mut w = CodeWriter::new();
    w.line("#lang racket/base");
    write_line!(w, ";; Generated constant definitions for {}", framework);
    w.blank_line();
    w.line("(require ffi/unsafe");
    w.line("         ffi/unsafe/objc");
    // Rename `racket/contract`'s `->` to `c->` to avoid colliding with
    // `ffi/unsafe`'s `->`. Constants don't use `->` themselves, but the
    // collision is at require-time regardless.
    if needs_structs {
        w.line("         (rename-in racket/contract [-> c->])");
        w.line("         \"../../runtime/type-mapping.rkt\")");
    } else {
        w.line("         (rename-in racket/contract [-> c->]))");
    }
    w.blank_line();

    // Contract-based provide
    if constants.is_empty() {
        w.line("(provide)");
    } else {
        w.line("(provide/contract");
        for constant in constants {
            let contract = if constant.macro_value.is_some() {
                "(or/c cpointer? #f)".to_string()
            } else if is_struct_data_symbol(&constant.constant_type) {
                "cpointer?".to_string()
            } else {
                map_contract(&constant.constant_type, false)
            };
            write_line!(w, "  [{} {}]", constant.name, contract);
        }
        w.line("  )");
    }
    w.blank_line();

    // Load framework dylib (needed even if all constants are CFSTR — other
    // files in the framework may re-export this module).
    write_line!(
        w,
        "(define _fw-lib (ffi-lib \"{}\"))",
        framework_ffi_lib_arg(framework)
    );
    w.blank_line();

    // CFSTR preamble: a helper that constructs CFString constants at load time.
    // kCFStringEncodingUTF8 = #x08000100.
    if needs_cfstr {
        w.line(";; CFSTR macro constant support");
        w.line("(define _cfstr-lib (ffi-lib \"/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation\"))");
        w.line("(define _cfstr-create (get-ffi-obj 'CFStringCreateWithCString _cfstr-lib");
        w.line("                                   (_fun _pointer _string _uint32 -> _pointer)))");
        w.line("(define (_make-cfstr s) (_cfstr-create #f s #x08000100))");
        w.blank_line();
    }

    for constant in constants {
        if let Some(ref value) = constant.macro_value {
            write_line!(w, "(define {} (_make-cfstr \"{}\"))", constant.name, value);
        } else if is_struct_data_symbol(&constant.constant_type) {
            write_line!(
                w,
                "(define {} (ffi-obj-ref '{} _fw-lib))",
                constant.name,
                constant.name
            );
        } else {
            let ffi_type = mapper.map_type(&constant.constant_type, false);
            write_line!(
                w,
                "(define {} (get-ffi-obj '{} _fw-lib {}))",
                constant.name,
                constant.name,
                ffi_type
            );
        }
    }

    w.finish()
}

#[cfg(test)]
mod tests {
    use super::*;
    use apianyware_macos_types::type_ref::{TypeRef, TypeRefKind};

    fn make_constant(name: &str, kind: TypeRefKind) -> Constant {
        Constant {
            name: name.to_string(),
            constant_type: TypeRef {
                nullable: false,
                kind,
            },
            source: None,
            provenance: None,
            doc_refs: None,
            macro_value: None,
        }
    }

    fn make_nullable_constant(name: &str, kind: TypeRefKind) -> Constant {
        Constant {
            name: name.to_string(),
            constant_type: TypeRef {
                nullable: true,
                kind,
            },
            source: None,
            provenance: None,
            doc_refs: None,
            macro_value: None,
        }
    }

    #[test]
    fn test_nsstring_constant() {
        let constants = vec![make_constant(
            "TKVersionString",
            TypeRefKind::Class {
                name: "NSString".into(),
                framework: None,
                params: vec![],
            },
        )];
        let output = generate_constants_file(&constants, "TestKit");
        assert!(
            output.contains("(define TKVersionString (get-ffi-obj 'TKVersionString _fw-lib _id))")
        );
    }

    #[test]
    fn test_nsstring_constant_contract() {
        let constants = vec![make_constant(
            "TKVersionString",
            TypeRefKind::Class {
                name: "NSString".into(),
                framework: None,
                params: vec![],
            },
        )];
        let output = generate_constants_file(&constants, "TestKit");
        assert!(output.contains("(provide/contract"));
        assert!(output.contains("[TKVersionString cpointer?]"));
    }

    #[test]
    fn test_double_constant() {
        let constants = vec![make_constant(
            "TKDefaultTimeout",
            TypeRefKind::Primitive {
                name: "double".into(),
            },
        )];
        let output = generate_constants_file(&constants, "TestKit");
        assert!(output
            .contains("(define TKDefaultTimeout (get-ffi-obj 'TKDefaultTimeout _fw-lib _double))"));
    }

    #[test]
    fn test_double_constant_contract() {
        let constants = vec![make_constant(
            "TKDefaultTimeout",
            TypeRefKind::Primitive {
                name: "double".into(),
            },
        )];
        let output = generate_constants_file(&constants, "TestKit");
        assert!(output.contains("[TKDefaultTimeout real?]"));
    }

    #[test]
    fn test_alias_constant() {
        let constants = vec![make_constant(
            "TKDefaultOptions",
            TypeRefKind::Alias {
                name: "NSPointerFunctionsOptions".into(),
                framework: None,
                underlying_primitive: None,
            },
        )];
        let output = generate_constants_file(&constants, "TestKit");
        assert!(output
            .contains("(define TKDefaultOptions (get-ffi-obj 'TKDefaultOptions _fw-lib _uint64))"));
    }

    #[test]
    fn test_alias_constant_contract() {
        let constants = vec![make_constant(
            "TKDefaultOptions",
            TypeRefKind::Alias {
                name: "NSPointerFunctionsOptions".into(),
                framework: None,
                underlying_primitive: None,
            },
        )];
        let output = generate_constants_file(&constants, "TestKit");
        assert!(output.contains("[TKDefaultOptions exact-nonnegative-integer?]"));
    }

    #[test]
    fn test_nullable_object_constant_contract() {
        let constants = vec![make_nullable_constant(
            "TKOptionalRef",
            TypeRefKind::Class {
                name: "NSString".into(),
                framework: None,
                params: vec![],
            },
        )];
        let output = generate_constants_file(&constants, "TestKit");
        assert!(output.contains("[TKOptionalRef (or/c cpointer? #f)]"));
    }

    #[test]
    fn test_framework_lib_loading() {
        let output = generate_constants_file(&[], "Foundation");
        assert!(output.contains(
            "(define _fw-lib (ffi-lib \"/System/Library/Frameworks/Foundation.framework/Foundation\"))"
        ));
    }

    #[test]
    fn test_empty_constants_provide() {
        let output = generate_constants_file(&[], "TestKit");
        assert!(output.contains("(provide)"));
        assert!(!output.contains("provide/contract"));
    }

    #[test]
    fn test_requires_racket_contract() {
        let output = generate_constants_file(&[], "TestKit");
        assert!(output.contains("(rename-in racket/contract [-> c->])"));
    }

    #[test]
    fn test_multiple_constants_ordered() {
        let constants = vec![
            make_constant(
                "TKVersionString",
                TypeRefKind::Class {
                    name: "NSString".into(),
                    framework: None,
                    params: vec![],
                },
            ),
            make_constant(
                "TKDefaultTimeout",
                TypeRefKind::Primitive {
                    name: "double".into(),
                },
            ),
        ];
        let output = generate_constants_file(&constants, "TestKit");
        let ver_pos = output.find("TKVersionString").unwrap();
        let timeout_pos = output.find("TKDefaultTimeout").unwrap();
        assert!(ver_pos < timeout_pos, "Constants should preserve IR order");
    }

    #[test]
    fn test_multiple_constants_contracts() {
        let constants = vec![
            make_constant(
                "TKVersionString",
                TypeRefKind::Class {
                    name: "NSString".into(),
                    framework: None,
                    params: vec![],
                },
            ),
            make_constant(
                "TKDefaultTimeout",
                TypeRefKind::Primitive {
                    name: "double".into(),
                },
            ),
        ];
        let output = generate_constants_file(&constants, "TestKit");
        assert!(output.contains("(provide/contract"));
        assert!(output.contains("[TKVersionString cpointer?]"));
        assert!(output.contains("[TKDefaultTimeout real?]"));
    }

    #[test]
    fn test_constants_with_struct_type_require_type_mapping() {
        // Foundation ships NSZeroPoint / NSZeroRect as module-level constants
        // of geometry struct type. The generated constants.rkt must require
        // type-mapping.rkt so `_NSPoint` etc. are in scope for `get-ffi-obj`.
        let constants = vec![make_constant(
            "NSZeroPoint",
            TypeRefKind::Alias {
                name: "NSPoint".into(),
                framework: None,
                underlying_primitive: None,
            },
        )];
        let output = generate_constants_file(&constants, "Foundation");
        assert!(
            output.contains("\"../../runtime/type-mapping.rkt\""),
            "Expected type-mapping.rkt require for struct-typed constant. \
             Output was:\n{output}"
        );
    }

    #[test]
    fn test_constants_without_structs_omit_type_mapping() {
        // Primitive-only and object-only constant lists must not pull in
        // type-mapping.rkt.
        let constants = vec![
            make_constant(
                "TKDefaultTimeout",
                TypeRefKind::Primitive {
                    name: "double".into(),
                },
            ),
            make_constant(
                "TKVersionString",
                TypeRefKind::Class {
                    name: "NSString".into(),
                    framework: None,
                    params: vec![],
                },
            ),
        ];
        let output = generate_constants_file(&constants, "TestKit");
        assert!(
            !output.contains("type-mapping.rkt"),
            "Expected no type-mapping.rkt require when no struct types \
             are used. Output was:\n{output}"
        );
    }

    #[test]
    fn test_struct_global_uses_ffi_obj_ref() {
        // Struct-typed globals (e.g. _dispatch_main_q) must use ffi-obj-ref
        // to get the symbol's address, not get-ffi-obj which dereferences it.
        let constants = vec![make_constant(
            "_dispatch_main_q",
            TypeRefKind::Struct {
                name: "struct dispatch_queue_s".into(),
            },
        )];
        let output = generate_constants_file(&constants, "libdispatch");
        assert!(
            output.contains("(define _dispatch_main_q (ffi-obj-ref '_dispatch_main_q _fw-lib))"),
            "Struct globals must use ffi-obj-ref, not get-ffi-obj. Output was:\n{output}"
        );
        assert!(
            !output.contains("get-ffi-obj"),
            "Struct globals must not use get-ffi-obj. Output was:\n{output}"
        );
    }

    #[test]
    fn test_struct_global_contract_is_cpointer() {
        // The result of ffi-obj-ref is a cpointer — the contract must match.
        let constants = vec![make_constant(
            "_dispatch_main_q",
            TypeRefKind::Struct {
                name: "struct dispatch_queue_s".into(),
            },
        )];
        let output = generate_constants_file(&constants, "libdispatch");
        assert!(
            output.contains("[_dispatch_main_q cpointer?]"),
            "Struct global contract should be cpointer?. Output was:\n{output}"
        );
    }

    #[test]
    fn test_pointer_global_still_uses_get_ffi_obj() {
        // Pointer-typed globals (e.g. kCFRunLoopCommonModes) must keep
        // using get-ffi-obj — the symbol's memory IS the pointer value.
        let constants = vec![make_constant(
            "kCFRunLoopCommonModes",
            TypeRefKind::Class {
                name: "NSString".into(),
                framework: None,
                params: vec![],
            },
        )];
        let output = generate_constants_file(&constants, "CoreFoundation");
        assert!(
            output.contains(
                "(define kCFRunLoopCommonModes (get-ffi-obj 'kCFRunLoopCommonModes _fw-lib _id))"
            ),
            "Pointer globals must still use get-ffi-obj. Output was:\n{output}"
        );
    }

    #[test]
    fn test_mixed_struct_and_pointer_globals() {
        // A file with both struct and pointer globals should use the right
        // form for each.
        let constants = vec![
            make_constant(
                "_dispatch_main_q",
                TypeRefKind::Struct {
                    name: "struct dispatch_queue_s".into(),
                },
            ),
            make_constant(
                "_dispatch_data_destructor_free",
                TypeRefKind::Block {
                    params: vec![],
                    return_type: Box::new(TypeRef {
                        nullable: false,
                        kind: TypeRefKind::Primitive {
                            name: "void".into(),
                        },
                    }),
                },
            ),
        ];
        let output = generate_constants_file(&constants, "libdispatch");
        assert!(
            output.contains("(define _dispatch_main_q (ffi-obj-ref '_dispatch_main_q _fw-lib))"),
            "Struct global must use ffi-obj-ref. Output was:\n{output}"
        );
        assert!(
            output.contains("(define _dispatch_data_destructor_free (get-ffi-obj '_dispatch_data_destructor_free _fw-lib _pointer))"),
            "Block global must use get-ffi-obj. Output was:\n{output}"
        );
    }

    fn make_cfstr_constant(name: &str, value: &str) -> Constant {
        Constant {
            name: name.to_string(),
            constant_type: TypeRef {
                nullable: true,
                kind: TypeRefKind::Id,
            },
            source: None,
            provenance: None,
            doc_refs: None,
            macro_value: Some(value.to_string()),
        }
    }

    #[test]
    fn test_cfstr_constant_emits_create_call() {
        let constants = vec![make_cfstr_constant("kAXWindowsAttribute", "AXWindows")];
        let output = generate_constants_file(&constants, "ApplicationServices");
        assert!(
            output.contains("(define kAXWindowsAttribute (_make-cfstr \"AXWindows\"))"),
            "CFSTR constant should emit _make-cfstr call. Output was:\n{output}"
        );
    }

    #[test]
    fn test_cfstr_constant_contract() {
        let constants = vec![make_cfstr_constant("kAXWindowsAttribute", "AXWindows")];
        let output = generate_constants_file(&constants, "ApplicationServices");
        assert!(
            output.contains("[kAXWindowsAttribute (or/c cpointer? #f)]"),
            "CFSTR constant contract should be (or/c cpointer? #f). Output was:\n{output}"
        );
    }

    #[test]
    fn test_cfstr_preamble_present() {
        let constants = vec![make_cfstr_constant("kAXWindowsAttribute", "AXWindows")];
        let output = generate_constants_file(&constants, "ApplicationServices");
        assert!(
            output.contains("_make-cfstr"),
            "CFSTR preamble should be present. Output was:\n{output}"
        );
        assert!(
            output.contains("CFStringCreateWithCString"),
            "CFSTR preamble should reference CFStringCreateWithCString. Output was:\n{output}"
        );
    }

    #[test]
    fn test_cfstr_preamble_absent_when_no_macros() {
        let constants = vec![make_constant(
            "TKVersionString",
            TypeRefKind::Class {
                name: "NSString".into(),
                framework: None,
                params: vec![],
            },
        )];
        let output = generate_constants_file(&constants, "TestKit");
        assert!(
            !output.contains("_make-cfstr"),
            "CFSTR preamble should not be present without CFSTR constants. Output was:\n{output}"
        );
    }

    #[test]
    fn test_mixed_cfstr_and_regular_constants() {
        let constants = vec![
            make_cfstr_constant("kAXWindowsAttribute", "AXWindows"),
            make_constant(
                "TKDefaultTimeout",
                TypeRefKind::Primitive {
                    name: "double".into(),
                },
            ),
        ];
        let output = generate_constants_file(&constants, "ApplicationServices");
        assert!(
            output.contains("(define kAXWindowsAttribute (_make-cfstr \"AXWindows\"))"),
            "CFSTR constant should use _make-cfstr. Output was:\n{output}"
        );
        assert!(
            output.contains(
                "(define TKDefaultTimeout (get-ffi-obj 'TKDefaultTimeout _fw-lib _double))"
            ),
            "Regular constant should use get-ffi-obj. Output was:\n{output}"
        );
    }

    #[test]
    fn test_struct_typedef_global_uses_ffi_obj_ref() {
        // Struct typedefs (e.g. CFDictionaryKeyCallBacks) that resolve
        // to Struct in the IR must also use ffi-obj-ref.
        let constants = vec![make_constant(
            "kCFTypeDictionaryKeyCallBacks",
            TypeRefKind::Struct {
                name: "CFDictionaryKeyCallBacks".into(),
            },
        )];
        let output = generate_constants_file(&constants, "CoreFoundation");
        assert!(
            output.contains("(define kCFTypeDictionaryKeyCallBacks (ffi-obj-ref 'kCFTypeDictionaryKeyCallBacks _fw-lib))"),
            "Struct typedef globals must use ffi-obj-ref. Output was:\n{output}"
        );
        assert!(
            output.contains("[kCFTypeDictionaryKeyCallBacks cpointer?]"),
            "Struct typedef global contract should be cpointer?. Output was:\n{output}"
        );
    }
}
