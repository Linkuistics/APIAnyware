//! Gerbil constants file emission.
//!
//! Each framework's `constants.ss` binds every exported global. Unlike chez —
//! which resolves symbols by name at link time with `foreign-entry`/`foreign-ref`
//! and so needs no C declaration — Gambit `define-c-lambda` bodies are **real C**:
//! reading `NSFontAttributeName` emits C that names the symbol, so the symbol
//! must be *declared*. We therefore `#include` the framework umbrella header in a
//! `begin-ffi` block (Objective-C — compiles only because the FFI unit is built
//! `-x objective-c`, design §4) and read each global through a `%const-<name>`
//! crossing.
//!
//! Four flavours land here:
//!
//! 1. **Object-typed pointer globals** (`extern NSString * const Foo`). The C
//!    expression `Foo` *is* the object pointer (C does the read), so
//!    `___return((void*)Foo)` hands back the pointer; the outer define
//!    [`wrap`](crate)s it into a first-class, borrowed object (the framework owns
//!    the global for the process lifetime — no release will). Wrapping (vs chez's
//!    raw pointer) is what lets the constant flow through the ADR-0020 object
//!    model's `->ptr` arg coercion like any other object.
//! 2. **Struct-typed globals** (`_dispatch_main_q`). The symbol's *address* is the
//!    value used as the opaque handle (`dispatch_queue_t`); `___return((void*)&Foo)`
//!    hands back the address as a raw pointer — left unwrapped because these feed
//!    C functions (`dispatch_async`, `functions.ss`) that take raw `(pointer void)`.
//! 3. **Scalar globals** (`extern const double Foo`, enum-typed globals). Read by
//!    value through a typed crossing; the raw scalar is the binding.
//! 4. **CFSTR macros** — compile-time constant NSStrings the macro expands to. The
//!    macro target has no exported symbol, so there is nothing to `#include`/read;
//!    we build a retained NSString at load via the runtime's `string->nsstring`
//!    (050) and `wrap` it `#t` (owned). The retain matters: the constant must
//!    outlive the entry-point autorelease pool (ADR-0019).

use apianyware_macos_emit::code_writer::CodeWriter;
use apianyware_macos_emit::ffi_type_mapping::FfiTypeMapper;
use apianyware_macos_emit::write_line;
use apianyware_macos_types::ir::Constant;
use apianyware_macos_types::type_ref::TypeRefKind;

use crate::ffi_type_mapping::{GerbilFfiTypeMapper, POINTER};
use crate::shared_signatures::framework_umbrella_header;

/// The runtime module supplying `wrap` (object boxing + lifetime) and
/// `string->nsstring` (CFSTR construction). Same module the class emitter binds.
const RUNTIME_OBJC_IMPORT: &str = ":gerbil-bindings/runtime/objc";

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
        TypeRefKind::Class { .. } | TypeRefKind::Id | TypeRefKind::Instancetype => Flavour::Object,
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

/// The Gambit return token for a global read crossing.
fn crossing_return_token(flavour: &Flavour) -> &str {
    match flavour {
        Flavour::Object | Flavour::StructAddr => POINTER,
        Flavour::Scalar(tok) => tok,
        Flavour::CfString(_) => POINTER, // unused
    }
}

/// Names that `constants.ss` exports — every constant in IR order.
pub fn constant_names(constants: &[Constant]) -> Vec<String> {
    constants.iter().map(|c| c.name.clone()).collect()
}

/// Generate a Gerbil `constants.ss` module for one framework.
pub fn generate_constants_file(constants: &[Constant], framework: &str) -> String {
    let mapper = GerbilFfiTypeMapper;
    let mut w = CodeWriter::new();

    let flavours: Vec<(&Constant, Flavour)> = constants
        .iter()
        .map(|c| (c, classify(c, &mapper)))
        .collect();

    // A `begin-ffi` block (and so `:std/foreign`) is needed only for symbol-read
    // crossings; the runtime module only when something is `wrap`ped (object
    // globals + CFSTR).
    let needs_ffi = flavours
        .iter()
        .any(|(_, f)| !matches!(f, Flavour::CfString(_)));
    let needs_runtime = flavours
        .iter()
        .any(|(_, f)| matches!(f, Flavour::Object | Flavour::CfString(_)));

    write_line!(
        w,
        ";;; Generated constant definitions for {} — do not edit",
        framework
    );

    if needs_ffi || needs_runtime {
        w.line("(import");
        if needs_ffi {
            w.line("  :std/foreign");
        }
        if needs_runtime {
            write_line!(w, "  {}", RUNTIME_OBJC_IMPORT);
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

    // begin-ffi: one global-read crossing per non-CFSTR constant, under the
    // framework umbrella header so the symbols are declared.
    if needs_ffi {
        w.line("(begin-ffi (");
        for (c, f) in &flavours {
            if !matches!(f, Flavour::CfString(_)) {
                write_line!(w, "            {}", crossing_name(&c.name));
            }
        }
        w.line("            )");
        write_line!(
            w,
            "  (c-declare \"#include {}\")",
            framework_umbrella_header(framework)
        );
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

    // Outer bindings: read (+ wrap object/CFSTR) each global.
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
    use apianyware_macos_types::ir::Constant;
    use apianyware_macos_types::type_ref::{TypeRef, TypeRefKind};

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
        }
    }

    #[test]
    fn object_global_reads_then_wraps_under_umbrella() {
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
        assert!(out.contains("(c-declare \"#include <AppKit/AppKit.h>\")"));
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
        // Synthetic pseudo-framework umbrella.
        assert!(out.contains("(c-declare \"#include <dispatch/dispatch.h>\")"));
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
        assert!(out.contains(
            "(define kAXWindowsAttribute (wrap (string->nsstring \"AXWindows\") #t))"
        ));
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
}
