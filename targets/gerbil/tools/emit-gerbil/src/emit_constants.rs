//! Gerbil constants file emission.
//!
//! Each framework's `constants.ss` binds every exported global. Unlike chez —
//! which resolves symbols by name at link time with `foreign-entry`/`foreign-ref`
//! and so needs no C declaration — Gambit `define-c-lambda` bodies are **real C**:
//! reading `NSFontAttributeName` emits C that names the symbol, so the symbol
//! must be *declared*. Rather than `#include` the framework **umbrella header**
//! (Objective-C, which the bottle's default gcc-15 cannot parse), we **synthesize
//! the C declaration** per symbol — an `extern` spelling ObjC pointer types as
//! `void *` — so every crossing compiles under the default compiler with no clang
//! / `-x objective-c` (**ADR-0021**, superseding design §4). Each global is read
//! through a `%const-<name>` crossing.
//!
//! Four flavours land here:
//!
//! 1. **Object-typed pointer globals** (`extern NSString * const Foo`). Declared
//!    `extern void * const Foo;`. The C expression `Foo` *is* the object pointer
//!    (C does the read), so `___return((void*)Foo)` hands back the pointer; the
//!    outer define [`wrap`](crate)s it into a first-class, borrowed object (the
//!    framework owns the global for the process lifetime — no release will).
//!    Wrapping (vs chez's raw pointer) is what lets the constant flow through the
//!    ADR-0020 object model's `->ptr` arg coercion like any other object.
//! 2. **Struct-typed globals** (`_dispatch_main_q`). Only the symbol's *address*
//!    is used as the opaque handle, so it is declared `extern const char Foo;` (a
//!    deliberate type fiction — the linker binds `Foo` to the real symbol) and
//!    `___return((void*)&Foo)` hands back the address as a raw pointer — left
//!    unwrapped because these feed C functions (`dispatch_async`, `functions.ss`)
//!    that take raw `(pointer void)`.
//! 3. **Scalar globals** (`extern const double Foo`, enum-typed globals). Declared
//!    `extern <C-type> Foo;` via [`c_type_for_token`]; read by value through a
//!    typed crossing; the raw scalar is the binding.
//! 4. **CFSTR macros** — compile-time constant NSStrings the macro expands to. The
//!    macro target has no exported symbol, so there is nothing to declare/read;
//!    we build a retained NSString at load via the runtime's `string->nsstring`
//!    (050) and `wrap` it `#t` (owned). The retain matters: the constant must
//!    outlive the entry-point autorelease pool (ADR-0019).

use apianyware_emit::code_writer::CodeWriter;
use apianyware_emit::ffi_type_mapping::FfiTypeMapper;
use apianyware_emit::write_line;
use apianyware_types::ir::Constant;
use apianyware_types::type_ref::TypeRefKind;

use crate::ffi_type_mapping::{c_type_for_token, GerbilFfiTypeMapper, POINTER};
use crate::trampoline::{
    classify_constant, const_needs_objc, const_needs_swift_helpers, ConstTrampoline,
};

/// The runtime module supplying `wrap` (object boxing + lifetime) and
/// `string->nsstring` (CFSTR construction). Same module the class emitter binds;
/// also owns the `wrap` a Swift-native object constant trampoline uses.
const RUNTIME_OBJC_IMPORT: &str = ":gerbil-bindings/runtime/objc";
/// The runtime module supplying the Swift-native trampoline `aw-swift-*` coercers
/// (a Swift-native `String` global is read + coerced Scheme-side).
const RUNTIME_TRAMPOLINE_IMPORT: &str = ":gerbil-bindings/runtime/swift-trampoline";

/// What kind of crossing a constant needs. Computed once per constant; drives
/// both the `begin-ffi` `define-c-lambda` body and the outer binding form.
enum Flavour {
    /// CFSTR macro — no symbol to read; built + retained at load.
    CfString(String),
    /// Object pointer global — read as `(pointer void)`, `wrap`ped (borrowed).
    Object,
    /// Struct global — its address is the handle; raw `(pointer void)`.
    StructAddr,
    /// Scalar / non-object pointer global — read by value; raw. Carries its
    /// Gambit return token.
    Scalar(String),
}

fn classify(c: &Constant, mapper: &dyn FfiTypeMapper) -> Flavour {
    if let Some(v) = &c.macro_value {
        return Flavour::CfString(v.clone());
    }
    match &c.constant_type.kind {
        TypeRefKind::Class { .. } | TypeRefKind::Id { .. } | TypeRefKind::Instancetype => {
            Flavour::Object
        }
        TypeRefKind::Struct { .. } => Flavour::StructAddr,
        _ => Flavour::Scalar(mapper.map_type(&c.constant_type, true)),
    }
}

/// The internal `%const-<name>` crossing identifier for a global read.
fn crossing_name(name: &str) -> String {
    format!("%const-{name}")
}

/// The C `define-c-lambda` body that reads global `name` for `flavour`. `None`
/// for [`Flavour::CfString`] (built in Scheme, no crossing).
fn crossing_body(name: &str, flavour: &Flavour) -> Option<String> {
    match flavour {
        Flavour::CfString(_) => None,
        // The framework owns the storage; C reads the object pointer directly.
        Flavour::Object => Some(format!("___return((void*){name});")),
        // The symbol *is* the struct — hand back its address as the handle.
        Flavour::StructAddr => Some(format!("___return((void*)&{name});")),
        Flavour::Scalar(tok) if tok == POINTER => Some(format!("___return((void*){name});")),
        Flavour::Scalar(_) => Some(format!("___return({name});")),
    }
}

/// The synthesized C `extern` declaration for global `name` of `flavour`
/// (ADR-0021), or `None` for [`Flavour::CfString`] (no symbol). ObjC pointer
/// globals collapse to `void * const`; a struct global is declared `const char`
/// because only its address is taken; a scalar uses its FFI token's C type.
fn extern_decl(name: &str, flavour: &Flavour) -> Option<String> {
    match flavour {
        Flavour::CfString(_) => None,
        Flavour::Object => Some(format!("extern void * const {name};")),
        Flavour::StructAddr => Some(format!("extern const char {name};")),
        Flavour::Scalar(tok) if tok == POINTER => Some(format!("extern void * const {name};")),
        Flavour::Scalar(tok) => Some(format!("extern {} {name};", c_type_for_token(tok))),
    }
}

/// The Gambit return token for a global read crossing.
fn crossing_return_token(flavour: &Flavour) -> &str {
    match flavour {
        Flavour::Object | Flavour::StructAddr => POINTER,
        Flavour::Scalar(tok) => tok,
        Flavour::CfString(_) => POINTER, // unused
    }
}

/// Names that `constants.ss` exports — every constant in IR order. Direct
/// (ObjC-exposed) globals and the Swift-native residual (`objc_exposed == false`,
/// trampolined through libAPIAnywareGerbil, ADR-0029) are *both* bound, so the
/// facade re-export list is the full set.
pub fn constant_names(constants: &[Constant]) -> Vec<String> {
    constants.iter().map(|c| c.name.clone()).collect()
}

/// Generate a Gerbil `constants.ss` module for one framework.
pub fn generate_constants_file(constants: &[Constant], framework: &str) -> String {
    let mapper = GerbilFfiTypeMapper;
    let mut w = CodeWriter::new();

    // Direct (ObjC-exposed) globals read by name; the Swift-native residual
    // (`objc_exposed == false`) has no C symbol, so it is read through a
    // `aw_gerbil_swift_const_*` trampoline in libAPIAnywareGerbil (ADR-0029).
    let direct: Vec<&Constant> = constants.iter().filter(|c| c.objc_exposed).collect();
    let residual: Vec<ConstTrampoline> = constants
        .iter()
        .filter(|c| !c.objc_exposed)
        .map(|c| classify_constant(framework, c))
        .collect();

    let flavours: Vec<(&Constant, Flavour)> =
        direct.iter().map(|c| (*c, classify(c, &mapper))).collect();

    // A `begin-ffi` block (and so `:std/foreign`) is needed for any symbol-read
    // crossing — a direct non-CFSTR global or any residual trampoline. The `objc`
    // runtime is needed when something is `wrap`ped (object/CFSTR globals, a
    // residual object constant); the `swift-trampoline` runtime for a residual
    // `String` global (Scheme-side coercion). The two runtime modules are disjoint.
    let needs_ffi = flavours
        .iter()
        .any(|(_, f)| !matches!(f, Flavour::CfString(_)))
        || !residual.is_empty();
    let needs_objc = flavours
        .iter()
        .any(|(_, f)| matches!(f, Flavour::Object | Flavour::CfString(_)))
        || residual.iter().any(const_needs_objc);
    let needs_swift = residual.iter().any(const_needs_swift_helpers);

    write_line!(
        w,
        ";;; Generated constant definitions for {} — do not edit",
        framework
    );

    if needs_ffi || needs_objc || needs_swift {
        w.line("(import");
        if needs_ffi {
            w.line("  :std/foreign");
        }
        if needs_objc {
            write_line!(w, "  {}", RUNTIME_OBJC_IMPORT);
        }
        if needs_swift {
            write_line!(w, "  {}", RUNTIME_TRAMPOLINE_IMPORT);
        }
        w.line("  )");
    }

    let exports = constant_names(constants);
    if exports.is_empty() {
        w.line("(export)");
    } else {
        w.line("(export");
        for n in &exports {
            write_line!(w, "  {}", n);
        }
        w.line("  )");
    }
    w.blank_line();

    // Direct begin-ffi: one global-read crossing per non-CFSTR constant. Each
    // symbol is declared by a synthesized `extern` (ADR-0021) — never by
    // `#include`-ing the framework umbrella header — so the block compiles under
    // the default gcc-15.
    let direct_has_ffi = flavours
        .iter()
        .any(|(_, f)| !matches!(f, Flavour::CfString(_)));
    if direct_has_ffi {
        let needs_stdbool = flavours
            .iter()
            .any(|(_, f)| matches!(f, Flavour::Scalar(tok) if tok == "bool"));
        w.line("(begin-ffi (");
        for (c, f) in &flavours {
            if !matches!(f, Flavour::CfString(_)) {
                write_line!(w, "            {}", crossing_name(&c.name));
            }
        }
        w.line("            )");
        if needs_stdbool {
            w.line("  (c-declare \"#include <stdbool.h>\")");
        }
        for (c, f) in &flavours {
            if let Some(decl) = extern_decl(&c.name, f) {
                write_line!(w, "  (c-declare \"{}\")", decl);
            }
        }
        w.blank_line();
        for (c, f) in &flavours {
            if let Some(body) = crossing_body(&c.name, f) {
                write_line!(
                    w,
                    "  (define-c-lambda {} () {} \"{}\")",
                    crossing_name(&c.name),
                    crossing_return_token(f),
                    body
                );
            }
        }
        w.line("  )");
        w.blank_line();
    }

    // Swift-native residual begin-ffi: one `%swift-const-<name>` reader per
    // residual global, against the `aw_gerbil_swift_const_*` entry in
    // libAPIAnywareGerbil (ADR-0029).
    if !residual.is_empty() {
        let crossings: Vec<_> = residual.iter().map(|t| t.crossing()).collect();
        w.line("  ;; Swift-native residual — read through libAPIAnywareGerbil constant");
        w.line("  ;; trampolines (aw_gerbil_swift_const_*) rather than a C symbol (ADR-0029).");
        w.line("(begin-ffi (");
        for t in &residual {
            write_line!(w, "            %swift-const-{}", t.swift_name);
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
    }

    // Direct outer bindings: read (+ wrap object/CFSTR) each global.
    for (c, f) in &flavours {
        match f {
            Flavour::CfString(v) => write_line!(
                w,
                "(define {} (wrap (string->nsstring \"{}\") #t))",
                c.name,
                escape_string_literal(v)
            ),
            Flavour::Object => {
                write_line!(w, "(define {} (wrap ({})))", c.name, crossing_name(&c.name))
            }
            Flavour::StructAddr | Flavour::Scalar(_) => {
                write_line!(w, "(define {} ({}))", c.name, crossing_name(&c.name))
            }
        }
    }

    // Swift-native residual outer bindings: read once at load (+ wrap object /
    // coerce String) — the trampoline analogue of the direct globals above.
    for t in &residual {
        write_line!(w, "{}", t.render_binding());
    }

    w.finish()
}

/// Escape a Scheme string literal. The IR macro values come from C source after
/// preprocessor expansion; backslashes and double quotes are the only realistic
/// concerns for the CFSTR set we observe.
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
            array_element: None,
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
                kind: TypeRefKind::Id {
                    protocols: Vec::new(),
                },
            },
            array_element: None,
            source: None,
            provenance: None,
            doc_refs: None,
            macro_value: Some(value.into()),
            objc_exposed: true,
        }
    }

    #[test]
    fn object_global_reads_then_wraps_via_synth_extern() {
        let consts = vec![c(
            "NSFontAttributeName",
            TypeRefKind::Class {
                name: "NSString".into(),
                framework: None,
                params: vec![],
            },
        )];
        let out = generate_constants_file(&consts, "AppKit");
        assert!(out.contains(";;; Generated constant definitions for AppKit"));
        // ADR-0021: synthesized extern, no umbrella #include.
        assert!(out.contains("(c-declare \"extern void * const NSFontAttributeName;\")"));
        assert!(!out.contains("#include <AppKit/AppKit.h>"));
        assert!(out.contains(
            "(define-c-lambda %const-NSFontAttributeName () (pointer void) \"___return((void*)NSFontAttributeName);\")"
        ));
        // Object globals become first-class wrapped objects (borrowed).
        assert!(out.contains("(define NSFontAttributeName (wrap (%const-NSFontAttributeName)))"));
        assert!(out.contains(":gerbil-bindings/runtime/objc"));
    }

    #[test]
    fn struct_global_takes_address_raw() {
        let consts = vec![c(
            "_dispatch_main_q",
            TypeRefKind::Struct {
                name: "struct dispatch_queue_s".into(),
            },
        )];
        let out = generate_constants_file(&consts, "libdispatch");
        // ADR-0021: only the address is used, so declare `const char` (the linker
        // binds the symbol); no <dispatch/dispatch.h> umbrella.
        assert!(out.contains("(c-declare \"extern const char _dispatch_main_q;\")"));
        assert!(!out.contains("#include <dispatch/dispatch.h>"));
        assert!(out.contains(
            "(define-c-lambda %const-_dispatch_main_q () (pointer void) \"___return((void*)&_dispatch_main_q);\")"
        ));
        // Used by C functions → raw, not wrapped.
        assert!(out.contains("(define _dispatch_main_q (%const-_dispatch_main_q))"));
        assert!(!out.contains("(wrap (%const-_dispatch_main_q))"));
    }

    #[test]
    fn primitive_global_reads_by_value() {
        let consts = vec![c(
            "NSDefaultTimeout",
            TypeRefKind::Primitive {
                name: "double".into(),
            },
        )];
        let out = generate_constants_file(&consts, "Foundation");
        // ADR-0021: scalar declared with its C type, no umbrella #include.
        assert!(out.contains("(c-declare \"extern double NSDefaultTimeout;\")"));
        assert!(!out.contains("#include <Foundation/Foundation.h>"));
        assert!(out.contains(
            "(define-c-lambda %const-NSDefaultTimeout () double \"___return(NSDefaultTimeout);\")"
        ));
        assert!(out.contains("(define NSDefaultTimeout (%const-NSDefaultTimeout))"));
        // No object → no runtime import needed.
        assert!(!out.contains(":gerbil-bindings/runtime/objc"));
    }

    #[test]
    fn cfstr_constant_builds_retained_nsstring() {
        let consts = vec![cfstr("kAXWindowsAttribute", "AXWindows")];
        let out = generate_constants_file(&consts, "ApplicationServices");
        assert!(
            out.contains("(define kAXWindowsAttribute (wrap (string->nsstring \"AXWindows\") #t))")
        );
        // Pure CFSTR module: no symbol to read → no begin-ffi / :std/foreign.
        assert!(!out.contains("begin-ffi"));
        assert!(!out.contains(":std/foreign"));
        // …but it does wrap, so the runtime is imported.
        assert!(out.contains(":gerbil-bindings/runtime/objc"));
    }

    #[test]
    fn empty_constants_emit_empty_export() {
        let out = generate_constants_file(&[], "TestKit");
        assert!(out.contains("(export)"));
        assert!(!out.contains("(import"));
    }

    #[test]
    fn cfstr_escapes_quotes_and_backslashes() {
        let consts = vec![cfstr("kFoo", "a\"b\\c")];
        let out = generate_constants_file(&consts, "TestKit");
        assert!(out.contains("(string->nsstring \"a\\\"b\\\\c\")"));
    }

    // -----------------------------------------------------------------------
    // Swift-native residual routing (objc_exposed == false → trampolines)
    // -----------------------------------------------------------------------

    /// A Swift-native (`objc_exposed == false`) constant.
    fn swift_const(name: &str, kind: TypeRefKind) -> Constant {
        Constant {
            name: name.into(),
            constant_type: TypeRef {
                nullable: false,
                kind,
            },
            array_element: None,
            source: None,
            provenance: None,
            doc_refs: None,
            macro_value: None,
            objc_exposed: false,
        }
    }

    #[test]
    fn swift_native_string_constant_reads_through_trampoline() {
        // The §6a exemplar: a Swift-native String global with no C symbol, read
        // through the aw_gerbil_swift_const_* trampoline + Scheme-side coercion.
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
            out.contains("(c-declare \"extern void * aw_gerbil_swift_const_CreateML_MLCreateErrorDomain(void);\")"),
            "{out}"
        );
        assert!(
            out.contains("(define-c-lambda %swift-const-MLCreateErrorDomain () (pointer void) \"aw_gerbil_swift_const_CreateML_MLCreateErrorDomain\")"),
            "{out}"
        );
        assert!(
            out.contains("(define MLCreateErrorDomain (aw-swift-string-result (%swift-const-MLCreateErrorDomain)))"),
            "{out}"
        );
        // String coercion pulls in the swift-trampoline runtime; no umbrella include.
        assert!(
            out.contains(":gerbil-bindings/runtime/swift-trampoline"),
            "{out}"
        );
        assert!(!out.contains("#include <CreateML/"), "{out}");
        // Exported through the facade-visible name list.
        assert!(constant_names(&consts).contains(&"MLCreateErrorDomain".to_string()));
    }

    #[test]
    fn swift_native_scalar_constant_reads_by_value() {
        let consts = vec![swift_const(
            "MLDefaultBatchSize",
            TypeRefKind::Primitive {
                name: "int64".into(),
            },
        )];
        let out = generate_constants_file(&consts, "CreateML");
        assert!(
            out.contains("(define-c-lambda %swift-const-MLDefaultBatchSize () int64 \"aw_gerbil_swift_const_CreateML_MLDefaultBatchSize\")"),
            "{out}"
        );
        assert!(
            out.contains("(define MLDefaultBatchSize (%swift-const-MLDefaultBatchSize))"),
            "{out}"
        );
        // A pure scalar residual needs no runtime helpers.
        assert!(
            !out.contains(":gerbil-bindings/runtime/swift-trampoline"),
            "{out}"
        );
    }

    #[test]
    fn direct_and_residual_constants_coexist_without_double_wrap() {
        // A framework with both a direct object global (needs objc `wrap`) and a
        // Swift-native String residual (needs swift-trampoline) imports both
        // runtimes; the two are disjoint, so `wrap` is bound exactly once.
        let consts = vec![
            c(
                "NSFontAttributeName",
                TypeRefKind::Class {
                    name: "NSString".into(),
                    framework: None,
                    params: vec![],
                },
            ),
            swift_const(
                "MLCreateErrorDomain",
                TypeRefKind::Class {
                    name: "NSString".into(),
                    framework: Some("Foundation".into()),
                    params: vec![],
                },
            ),
        ];
        let out = generate_constants_file(&consts, "AppKit");
        assert!(out.contains(":gerbil-bindings/runtime/objc"), "{out}");
        assert!(
            out.contains(":gerbil-bindings/runtime/swift-trampoline"),
            "{out}"
        );
        // Direct object global still wraps; residual string still coerces.
        assert!(
            out.contains("(define NSFontAttributeName (wrap (%const-NSFontAttributeName)))"),
            "{out}"
        );
        assert!(
            out.contains("(define MLCreateErrorDomain (aw-swift-string-result"),
            "{out}"
        );
    }
}
