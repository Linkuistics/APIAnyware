//! SBCL constant emission — the constant sub-rule (ADR-0026 §3) over `sb-alien`.
//!
//! A constant's **value is not in the IR** (only its type, and for CFSTR macros the
//! literal string): every direct global is read from its C symbol at runtime. SBCL's
//! `sb-alien` seam names the symbol *directly* (`extern-alien` /
//! `foreign-symbol-sap`), so — unlike gerbil, whose Gambit `define-c-lambda` bodies
//! are real C and must `(c-declare "extern …")` every symbol (ADR-0021) — there is
//! **no C-declaration synthesis here at all**. This is the chez `foreign-ref` shape,
//! spelled in alien types.
//!
//! ## The four flavours (the constant sub-rule, ADR-0026 §3)
//!
//! 1. **Object pointer global** (`extern NSString * const Foo`, type `Class|Id|
//!    Instancetype`). `(sb-alien:extern-alien "Foo" system-area-pointer)` reads the
//!    *value* of the global — which is the object pointer — then [`aw-wrap`](crate)s
//!    it **borrowed** (the framework owns the global for the process lifetime; no
//!    retain, no release).
//! 2. **Struct global** (`_dispatch_main_q`). The symbol's *address* is the opaque
//!    handle, so `(sb-sys:foreign-symbol-sap "Foo")` hands back the address as a raw
//!    SAP — left unwrapped, since these feed raw-pointer C functions
//!    ([`crate::emit_functions`]).
//! 3. **Scalar / other-pointer global** (`extern const double Foo`, enum-typed
//!    globals, raw `Pointer`/`CString`/`Selector`/…). `(sb-alien:extern-alien "Foo"
//!    <alien>)` reads the value by its mapped alien type; the raw value is the
//!    binding.
//! 4. **CFSTR macro** — a compile-time `NSString` the C macro expands to. There is no
//!    exported symbol; the string is built + retained at resolution via
//!    [`aw-make-nsstring`](crate) and `aw-wrap`ped **owned** (the retain matters: the
//!    constant must outlive the entry-point autorelease pool, ADR-0036).
//!
//! ## Why constants need re-resolution but functions don't (the `save-lisp-and-die`
//! split, ADR-0034 §6 / ADR-0038 §5)
//!
//! A direct C *function* binds via `define-alien-routine`, which resolves its symbol
//! through SBCL's foreign **linkage table at call time** — `save-lisp-and-die` repairs
//! that table on startup, so the binding is dump-safe for free. A *constant* read into
//! a plain `defparameter` would capture the pointer **once at load**, going stale after
//! a dumped-image restart re-maps the framework. So every constant routes through the
//! runtime macro **`define-objc-constant`** (the 040→050 seam): 040 emits the symbol +
//! the `sb-alien` read form; 050 makes that form (re-)resolve per process — the exact
//! parallel to the Class/SEL re-resolution (ADR-0034 §6). 040 stays a pure code
//! generator; the read mechanism is runtime-owned.
//!
//! ## The Swift-native residual is NOT emitted here
//!
//! An `objc_exposed == false` constant has no C symbol — `extern-alien` to it would
//! dangle. These are **collected** ([`collect_const_residual`]) for the trampoline
//! residual the next leaf (050) routes through `libAPIAnywareSbcl`
//! (`aw_sbcl_swift_const_*`), exactly as [`crate::emit_generics::collect_residual`]
//! collects the method/init residual. The §6d invariant's `7 const` originate here.
//!
//! ## Runtime contract (the 040 → 050 seam, fixed here)
//!
//! Emitted forms reference these runtime-owned symbols (050 provides them). Written
//! **bare** (the file is read in the runtime/impl package); `ns:` names qualified;
//! `sb-alien:` / `sb-sys:` operators fully qualified.
//!
//! - **`define-objc-constant`** `(ns:<name> <read-form>)` — bind a constant symbol to
//!   a per-process-re-resolved read of a C global (see above).
//! - **`aw-make-nsstring`** `(string → +1 NSString SAP)` — build a retained NSString
//!   for a CFSTR macro constant.
//! - **`aw-wrap`** `(id SAP [retained?] → instance)` — the same inbound object wrap the
//!   dispatch bodies use ([`crate::emit_generics`]).

use apianyware_macos_emit::code_writer::CodeWriter;
use apianyware_macos_emit::ffi_type_mapping::FfiTypeMapper;
use apianyware_macos_emit::write_line;
use apianyware_macos_types::ir::Constant;
use apianyware_macos_types::type_ref::TypeRefKind;

use crate::ffi_type_mapping::{SbclFfiTypeMapper, SAP};
use crate::naming::{qualified_top_level_name, top_level_name};

/// The runtime macro binding a constant symbol to a per-process-re-resolved C-global
/// read (the `save-lisp-and-die` re-resolution seam; 050 provides it).
pub const DEFINE_CONSTANT_MACRO: &str = "define-objc-constant";
/// Builds a retained (+1) `NSString` SAP from a Lisp string — the CFSTR constructor.
pub const MAKE_NSSTRING_FN: &str = "aw-make-nsstring";
/// Inbound object wrap (`id` SAP [retained?] → exact bound instance), shared with the
/// dispatch bodies ([`crate::emit_generics`]).
pub const WRAP_FN: &str = "aw-wrap";

/// Generate one framework's direct constant forms. The Swift-native residual
/// (`objc_exposed == false`) is **not** emitted — see [`collect_const_residual`].
pub fn generate_constants_file(constants: &[Constant], framework: &str) -> String {
    let mapper = SbclFfiTypeMapper;
    let mut w = CodeWriter::new();

    write_line!(
        w,
        ";;; Generated constant definitions for {} — do not edit",
        framework
    );
    w.blank_line();

    for c in constants.iter().filter(|c| c.objc_exposed) {
        let read = read_form(c, &mapper);
        write_line!(
            w,
            "({} {} {})",
            DEFINE_CONSTANT_MACRO,
            qualified_top_level_name(&c.name),
            read
        );
    }

    w.finish()
}

/// The unqualified `ns:`-package symbols this framework's constants contribute, in IR
/// order — the package export surface (060). Includes the Swift-native residual:
/// 050 binds it under the **same** `ns:<name>` symbol via the trampoline, so the
/// export list spans both leaves.
pub fn constant_symbols(constants: &[Constant]) -> Vec<String> {
    constants.iter().map(|c| top_level_name(&c.name)).collect()
}

// --- the Swift-native residual --------------------------------------------

/// One `objc_exposed == false` constant routed to the trampoline residual (leaf 050)
/// rather than read directly. The collection shape mirrors
/// [`crate::emit_generics::ResidualEntry`] — a thin identity (the constant name) the
/// global pass re-classifies against the IR.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ConstResidualEntry {
    /// The constant name (and `aw_sbcl_swift_const_*` content-addressing key).
    pub name: String,
}

/// Collect a framework's Swift-native (`objc_exposed == false`) constants for the
/// trampoline residual (leaf 050). These are deliberately **not** emitted as direct
/// reads here. Feeds the §6d `7 const`.
pub fn collect_const_residual(constants: &[Constant]) -> Vec<ConstResidualEntry> {
    constants
        .iter()
        .filter(|c| !c.objc_exposed)
        .map(|c| ConstResidualEntry {
            name: c.name.clone(),
        })
        .collect()
}

// --- flavour classification + read forms ----------------------------------

/// The `define-objc-constant` read form for a direct constant.
fn read_form(c: &Constant, mapper: &dyn FfiTypeMapper) -> String {
    if let Some(v) = &c.macro_value {
        // CFSTR macro — built + retained at resolution, wrapped owned.
        return format!(
            "({WRAP_FN} ({MAKE_NSSTRING_FN} \"{}\") t)",
            escape_string_literal(v)
        );
    }
    match &c.constant_type.kind {
        // Object pointer global: read the pointer value, wrap borrowed.
        TypeRefKind::Class { .. } | TypeRefKind::Id | TypeRefKind::Instancetype => {
            format!("({WRAP_FN} (sb-alien:extern-alien \"{}\" {SAP}))", c.name)
        }
        // Struct global: the symbol's address is the handle — take it raw.
        TypeRefKind::Struct { .. } => {
            format!("(sb-sys:foreign-symbol-sap \"{}\")", c.name)
        }
        // Scalar / other-pointer global: read the value by its mapped alien type.
        _ => {
            let alien = mapper.map_type(&c.constant_type, true);
            format!("(sb-alien:extern-alien \"{}\" {alien})", c.name)
        }
    }
}

/// Escape a Lisp string literal — backslash and double-quote, the only realistic
/// concerns for the post-preprocessor CFSTR values we observe (mirrors the scheme
/// targets).
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
    use apianyware_macos_types::type_ref::TypeRef;

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
    fn object_global_reads_sap_and_wraps_borrowed() {
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
        // ns:-qualified binding; raw C symbol for the lookup; no C-decl synthesis.
        assert!(out.contains(
            "(define-objc-constant ns:ns-font-attribute-name (aw-wrap (sb-alien:extern-alien \"NSFontAttributeName\" sb-alien:system-area-pointer)))"
        ));
        // Borrowed: wrapped without the +1 `t` flag.
        assert!(!out.contains("sb-alien:system-area-pointer)) t)"));
        assert!(!out.contains("c-declare"));
        assert!(!out.contains("extern void"));
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
        // The symbol address is the handle — foreign-symbol-sap, no wrap.
        assert!(out.contains(
            "(define-objc-constant ns:dispatch-main-q (sb-sys:foreign-symbol-sap \"_dispatch_main_q\"))"
        ));
        assert!(!out.contains("aw-wrap"));
    }

    #[test]
    fn scalar_global_reads_by_value() {
        let consts = vec![c(
            "NSDefaultTimeout",
            TypeRefKind::Primitive {
                name: "double".into(),
            },
        )];
        let out = generate_constants_file(&consts, "Foundation");
        assert!(out.contains(
            "(define-objc-constant ns:ns-default-timeout (sb-alien:extern-alien \"NSDefaultTimeout\" sb-alien:double))"
        ));
        assert!(!out.contains("aw-wrap"));
    }

    #[test]
    fn enum_typed_alias_global_uses_underlying_width() {
        let consts = vec![c(
            "NSSomeMode",
            TypeRefKind::Alias {
                name: "NSComparisonResult".into(),
                framework: None,
                underlying_primitive: Some("int64".into()),
            },
        )];
        let out = generate_constants_file(&consts, "Foundation");
        assert!(out.contains(
            "(define-objc-constant ns:ns-some-mode (sb-alien:extern-alien \"NSSomeMode\" (sb-alien:signed 64)))"
        ));
    }

    #[test]
    fn cfstr_constant_builds_retained_nsstring() {
        let consts = vec![cfstr("kAXWindowsAttribute", "AXWindows")];
        let out = generate_constants_file(&consts, "ApplicationServices");
        // Built + retained (owned `t`), no symbol read.
        assert!(out.contains(
            "(define-objc-constant ns:k-ax-windows-attribute (aw-wrap (aw-make-nsstring \"AXWindows\") t))"
        ));
        assert!(!out.contains("extern-alien"));
    }

    #[test]
    fn cfstr_escapes_quotes_and_backslashes() {
        let consts = vec![cfstr("kFoo", "a\"b\\c")];
        let out = generate_constants_file(&consts, "TestKit");
        assert!(out.contains("(aw-make-nsstring \"a\\\"b\\\\c\")"));
    }

    #[test]
    fn empty_constants_emit_only_a_header() {
        let out = generate_constants_file(&[], "TestKit");
        assert!(out.contains(";;; Generated constant definitions for TestKit"));
        assert!(!out.contains("define-objc-constant"));
    }

    // --- Swift-native residual routing (objc_exposed == false) -------------

    #[test]
    fn swift_native_constant_is_collected_not_emitted() {
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
        let out = generate_constants_file(&consts, "CreateML");
        // Direct constant emitted…
        assert!(out.contains("ns:ns-font-attribute-name"));
        // …residual one is NOT (no direct read — 050 trampolines it).
        assert!(!out.contains("MLCreateErrorDomain"));
        assert!(!out.contains("ml-create-error-domain"));

        // …but it IS in the residual collection.
        let residual = collect_const_residual(&consts);
        assert_eq!(residual.len(), 1);
        assert_eq!(residual[0].name, "MLCreateErrorDomain");
    }

    #[test]
    fn constant_symbols_span_direct_and_residual() {
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
        // The package surface includes both — 050 binds the residual under the same
        // ns: symbol.
        assert_eq!(
            constant_symbols(&consts),
            vec![
                "ns-font-attribute-name".to_string(),
                "ml-create-error-domain".to_string()
            ]
        );
    }
}
