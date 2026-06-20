//! Top-level construct composition tests (leaf 040/040) — the three non-class
//! emitters ([`emit_enums`], [`emit_constants`], [`emit_functions`]) run *together*
//! over one fixture framework, the way the orchestration leaf (060) will. The
//! per-module unit tests cover each emitter in isolation; this asserts the
//! cross-cutting invariants they cannot see:
//!
//! - the whole top-level surface is acronym-aware kebab-case in the `ns:` package
//!   (the contract §3.1 idiom, applied past classes);
//! - the `objc_exposed == false` residual is **collected, not emitted** — and the
//!   collection shape is consistent with leaf 020's method/init residual (a thin
//!   name-keyed entry the global pass re-classifies);
//! - the direct/residual split (ADR-0026 §3) routes each construct to the right
//!   place: ObjC-exposed → a direct `sb-alien` binding here, Swift-native → the
//!   residual for leaf 050;
//! - every emitted direct binding's symbol is in the construct's package-export
//!   surface (`*_symbols`), and every residual decl is too (050 binds it later).

use apianyware_macos_emit_sbcl::emit_constants::{
    collect_const_residual, constant_symbols, generate_constants_file,
};
use apianyware_macos_emit_sbcl::emit_enums::{defined_enum_symbols, generate_enums_file};
use apianyware_macos_emit_sbcl::emit_functions::{
    collect_fn_residual, function_symbols, generate_functions_file,
};
use apianyware_macos_types::ir::{Constant, Enum, EnumValue, Function, Param};
use apianyware_macos_types::type_ref::{TypeRef, TypeRefKind};

fn ty(kind: TypeRefKind) -> TypeRef {
    TypeRef {
        nullable: false,
        kind,
    }
}

fn enm(name: &str, underlying: &str, vs: &[(&str, i64)]) -> Enum {
    Enum {
        name: name.into(),
        enum_type: ty(TypeRefKind::Primitive {
            name: underlying.into(),
        }),
        values: vs
            .iter()
            .map(|(n, v)| EnumValue {
                name: (*n).into(),
                value: *v,
            })
            .collect(),
        source: None,
        provenance: None,
        doc_refs: None,
        objc_exposed: true,
    }
}

fn constant(name: &str, kind: TypeRefKind, objc_exposed: bool) -> Constant {
    Constant {
        name: name.into(),
        constant_type: ty(kind),
        source: None,
        provenance: None,
        doc_refs: None,
        macro_value: None,
        objc_exposed,
    }
}

fn function(name: &str, params: Vec<Param>, ret: TypeRefKind, objc_exposed: bool) -> Function {
    Function {
        name: name.into(),
        params,
        return_type: ty(ret),
        inline: false,
        variadic: false,
        source: None,
        provenance: None,
        doc_refs: None,
        objc_exposed,
        swift_fn: None,
    }
}

fn param(name: &str, kind: TypeRefKind) -> Param {
    Param {
        name: name.into(),
        param_type: ty(kind),
    }
}

fn nsstring_class() -> TypeRefKind {
    TypeRefKind::Class {
        name: "NSString".into(),
        framework: Some("Foundation".into()),
        params: vec![],
    }
}

#[test]
fn whole_top_level_surface_lives_in_the_ns_package() {
    let enums = vec![enm("NSComparisonResult", "int64", &[("NSOrderedSame", 0)])];
    let constants = vec![constant("NSFontAttributeName", nsstring_class(), true)];
    let functions = vec![function(
        "NSStringFromClass",
        vec![param("cls", TypeRefKind::ClassRef)],
        TypeRefKind::Id,
        true,
    )];

    let e = generate_enums_file(&enums, "AppKit");
    let c = generate_constants_file(&constants, "AppKit");
    let f = generate_functions_file(&functions, "AppKit");

    // Every defined name is ns:-qualified and acronym-aware kebab.
    assert!(e.contains("(defconstant ns:ns-ordered-same 0)"));
    assert!(c.contains("ns:ns-font-attribute-name"));
    assert!(f.contains("ns:ns-string-from-class"));
}

#[test]
fn direct_constructs_are_emitted_residual_constructs_are_only_collected() {
    let constants = vec![
        constant("NSFontAttributeName", nsstring_class(), true), // direct
        constant("MLCreateErrorDomain", nsstring_class(), false), // Swift-native
    ];
    let functions = vec![
        function("CGRectIsEmpty", vec![], TypeRefKind::Primitive { name: "bool".into() }, true), // direct
        function("swiftCompute", vec![], TypeRefKind::Primitive { name: "double".into() }, false), // Swift-native
    ];

    let c = generate_constants_file(&constants, "CreateML");
    let f = generate_functions_file(&functions, "CreateML");

    // Direct ones bound here…
    assert!(c.contains("ns:ns-font-attribute-name"));
    assert!(f.contains("ns:cg-rect-is-empty"));
    // …Swift-native ones are absent from the emitted output (050 trampolines them).
    assert!(!c.contains("create-error-domain"));
    assert!(!f.contains("swift-compute"));

    // …but present in the residual collections, with the name-keyed shape that
    // mirrors leaf 020's ResidualEntry.
    let cres = collect_const_residual(&constants);
    let fres = collect_fn_residual(&functions);
    assert_eq!(cres.len(), 1);
    assert_eq!(cres[0].name, "MLCreateErrorDomain");
    assert_eq!(fres.len(), 1);
    assert_eq!(fres[0].name, "swiftCompute");
}

#[test]
fn package_export_surface_spans_direct_and_residual_for_every_construct() {
    let enums = vec![enm("NSEnum", "int64", &[("NSAlpha", 1), ("NSBeta", 2)])];
    let constants = vec![
        constant("NSFontAttributeName", nsstring_class(), true),
        constant("MLCreateErrorDomain", nsstring_class(), false),
    ];
    let functions = vec![
        function("CGRectIsEmpty", vec![], TypeRefKind::Primitive { name: "bool".into() }, true),
        function("swiftCompute", vec![], TypeRefKind::Primitive { name: "double".into() }, false),
    ];

    // Enums: every defined symbol.
    assert_eq!(defined_enum_symbols(&enums), vec!["ns-alpha".to_string(), "ns-beta".to_string()]);
    // Constants + functions: the export surface includes the residual (050 binds it
    // under the same ns: symbol), so 060 has the full package surface from 040.
    assert_eq!(
        constant_symbols(&constants),
        vec!["ns-font-attribute-name".to_string(), "ml-create-error-domain".to_string()]
    );
    assert_eq!(
        function_symbols(&functions, "CreateML"),
        vec!["cg-rect-is-empty".to_string(), "swift-compute".to_string()]
    );
}

#[test]
fn constant_sub_rule_routes_each_flavour(/* ADR-0026 §3 */) {
    let constants = vec![
        constant("NSFontAttributeName", nsstring_class(), true), // object pointer → wrap
        constant(
            "_dispatch_main_q",
            TypeRefKind::Struct {
                name: "struct dispatch_queue_s".into(),
            },
            true,
        ), // struct → address
        constant("NSTimeout", TypeRefKind::Primitive { name: "double".into() }, true), // scalar → by value
    ];
    let out = generate_constants_file(&constants, "Foundation");
    // object: extern-alien value + borrowed wrap.
    assert!(out.contains("(aw-wrap (sb-alien:extern-alien \"NSFontAttributeName\" sb-alien:system-area-pointer))"));
    // struct: address as raw SAP.
    assert!(out.contains("(sb-sys:foreign-symbol-sap \"_dispatch_main_q\")"));
    // scalar: by-value typed read, no wrap.
    assert!(out.contains("(sb-alien:extern-alien \"NSTimeout\" sb-alien:double)"));
}
