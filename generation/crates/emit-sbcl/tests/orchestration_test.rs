//! Orchestration integration tests (leaf 040/060) — the whole emitted tree, the
//! invariants the per-module unit tests and the golden snapshot cannot see:
//!
//! - **Runtime-shape (load-smoke proxy).** No SBCL runtime exists yet (leaf 050),
//!   so "does it load" is approximated structurally: every emitted file is a
//!   balanced S-expression with the impl `(in-package …)` header — a malformed
//!   crossing or an unterminated form fails here, not at first `load`.
//! - **The defgeneric ↔ defmethod lockstep across files.** generics.lisp /
//!   protocols.lisp must declare a `defgeneric` for every selector a class file's
//!   `defmethod` extends — the per-class split must not drop the generic.
//! - **The facade export bootstrap.** Every emitter-defined `ns:` symbol must be in
//!   the facade's export surface (the construct files spell names single-colon,
//!   which the reader accepts only for external symbols) — except the runtime-owned
//!   root `ns:ns-object`.
//! - **The Swift-native fn/const residual is bound** (040/060), and a **class** owner's
//!   Swift-native method/init residual binds as a receiver-specialized `defmethod` +
//!   `make-<owner>` constructor with its generic in lockstep (045). Value-struct
//!   (population-B) owners stay deferred (a follow-up leaf).

use std::collections::BTreeSet;
use std::path::Path;

use apianyware_emit::target_emitter::TargetEmitter;
use apianyware_emit::test_fixtures::build_snapshot_test_framework;
use apianyware_emit_sbcl::class_graph::ClassRegistry;
use apianyware_emit_sbcl::protocol_registry::ProtocolRegistry;
use apianyware_emit_sbcl::SbclEmitter;
use apianyware_types::ir::{
    Class, Constant, Framework, Function, Method, Param, Struct, SwiftFnInfo,
};
use apianyware_types::type_ref::{TypeRef, TypeRefKind};

fn emit(fw: &Framework) -> tempfile::TempDir {
    let emitter = SbclEmitter::with_registries(
        ClassRegistry::from_framework_refs(&[fw]),
        ProtocolRegistry::from_framework_refs(&[fw]),
    );
    let tmp = tempfile::tempdir().unwrap();
    emitter.emit_framework(fw, tmp.path()).unwrap();
    tmp
}

/// Collect every `*.lisp` file under `dir`, sorted.
fn lisp_files(dir: &Path) -> Vec<std::path::PathBuf> {
    let mut out = Vec::new();
    collect(dir, &mut out);
    out.sort();
    out
}

fn collect(dir: &Path, out: &mut Vec<std::path::PathBuf>) {
    for entry in std::fs::read_dir(dir).unwrap().flatten() {
        let p = entry.path();
        if p.is_dir() {
            collect(&p, out);
        } else if p.extension().is_some_and(|e| e == "lisp") {
            out.push(p);
        }
    }
}

/// Net paren depth of a Lisp source, skipping `;`-to-EOL comments and `"…"` string
/// literals (with `\"` escapes) — `0` iff balanced, and never negative mid-stream.
fn paren_balance(src: &str) -> Result<i32, String> {
    let mut depth = 0i32;
    let mut in_string = false;
    let mut escaped = false;
    let mut in_comment = false;
    for ch in src.chars() {
        if in_comment {
            if ch == '\n' {
                in_comment = false;
            }
            continue;
        }
        if in_string {
            if escaped {
                escaped = false;
            } else if ch == '\\' {
                escaped = true;
            } else if ch == '"' {
                in_string = false;
            }
            continue;
        }
        match ch {
            ';' => in_comment = true,
            '"' => in_string = true,
            '(' => depth += 1,
            ')' => {
                depth -= 1;
                if depth < 0 {
                    return Err("unbalanced: extra close paren".into());
                }
            }
            _ => {}
        }
    }
    Ok(depth)
}

/// Every `ns:<sym>` that heads a top-level definition form (column 0), by form kind.
/// String-literal `ns:` substrings (inside selectors like `"…Notifications:"`) never
/// match because they are not at line start after `(<defform> `.
fn defined_ns_symbols(src: &str) -> BTreeSet<String> {
    let mut out = BTreeSet::new();
    for line in src.lines() {
        // Definition heads are emitted at column 0; bodies are indented.
        for form in [
            "(defclass ns:",
            "(defgeneric ns:",
            "(defmethod ns:",
            "(defconstant ns:",
            "(defun ns:",
            "(define-objc-constant ns:",
        ] {
            if let Some(rest) = line.strip_prefix(form) {
                let sym: String = rest
                    .chars()
                    .take_while(|c| c.is_ascii_alphanumeric() || *c == '-')
                    .collect();
                if !sym.is_empty() {
                    out.insert(sym);
                }
            }
        }
    }
    out
}

#[test]
fn every_emitted_file_is_a_balanced_in_package_sexpr() {
    let tmp = emit(&build_snapshot_test_framework());
    let files = lisp_files(tmp.path());
    assert!(!files.is_empty(), "TestKit should emit files");
    for f in &files {
        let src = std::fs::read_to_string(f).unwrap();
        assert_eq!(
            paren_balance(&src),
            Ok(0),
            "{} is not a balanced S-expression",
            f.display()
        );
        assert!(
            src.contains("(in-package #:apianyware-sbcl-impl)"),
            "{} missing the impl (in-package …) header",
            f.display()
        );
    }
}

#[test]
fn defgeneric_defmethod_lockstep_across_files() {
    // Every selector a class file's defmethod extends must have a defgeneric in
    // generics.lisp or protocols.lisp — the per-class split must not orphan a method.
    let tmp = emit(&build_snapshot_test_framework());

    let mut declared: BTreeSet<String> = BTreeSet::new();
    for stem in ["testkit/generics.lisp", "testkit/protocols.lisp"] {
        let src = std::fs::read_to_string(tmp.path().join(stem)).unwrap();
        for line in src.lines() {
            if let Some(rest) = line.strip_prefix("(defgeneric ns:") {
                declared.insert(
                    rest.chars()
                        .take_while(|c| c.is_ascii_alphanumeric() || *c == '-')
                        .collect(),
                );
            }
        }
    }

    let mut method_generics: BTreeSet<String> = BTreeSet::new();
    for f in lisp_files(tmp.path()) {
        let src = std::fs::read_to_string(&f).unwrap();
        for line in src.lines() {
            if let Some(rest) = line.strip_prefix("(defmethod ns:") {
                method_generics.insert(
                    rest.chars()
                        .take_while(|c| c.is_ascii_alphanumeric() || *c == '-')
                        .collect(),
                );
            }
        }
    }

    assert!(!method_generics.is_empty(), "fixture emits defmethods");
    for g in &method_generics {
        assert!(
            declared.contains(g),
            "defmethod ns:{g} has no matching defgeneric (declared = {declared:?})"
        );
    }
}

#[test]
fn facade_exports_every_defined_symbol() {
    let tmp = emit(&build_snapshot_test_framework());
    let facade = std::fs::read_to_string(tmp.path().join("testkit.lisp")).unwrap();

    for f in lisp_files(tmp.path()) {
        if f.file_name().is_some_and(|n| n == "testkit.lisp") {
            continue; // the facade itself
        }
        let src = std::fs::read_to_string(&f).unwrap();
        for sym in defined_ns_symbols(&src) {
            // The runtime-owned root is never emitter-defined, so never facade-exported.
            if sym == "ns-object" {
                continue;
            }
            assert!(
                facade.contains(&format!("ns::{sym}")),
                "{} defines ns:{sym} but the facade does not export it",
                f.display()
            );
        }
    }
}

#[test]
fn swift_native_fn_and_const_residual_is_bound_and_exported() {
    // A framework whose only top-level surface is Swift-native (objc_exposed == false):
    // both must be bound through the trampoline (the fn/const half this leaf wires)
    // and enter the facade's package surface.
    let mut fw = build_snapshot_test_framework();
    fw.name = "Residualer".into();
    fw.classes.clear();
    fw.protocols.clear();
    fw.enums.clear();
    fw.functions = vec![Function {
        name: "swiftCompute".into(),
        params: vec![Param {
            name: "factor".into(),
            param_type: TypeRef {
                nullable: false,
                kind: TypeRefKind::Primitive {
                    name: "double".into(),
                },
            },
        }],
        return_type: TypeRef {
            nullable: false,
            kind: TypeRefKind::Primitive {
                name: "double".into(),
            },
        },
        inline: false,
        variadic: false,
        source: None,
        provenance: None,
        doc_refs: None,
        objc_exposed: false,
        swift_fn: None,
    }];
    fw.constants = vec![Constant {
        name: "MLErrorDomain".into(),
        constant_type: TypeRef {
            nullable: false,
            kind: TypeRefKind::Id,
        },
        source: None,
        provenance: None,
        doc_refs: None,
        macro_value: None,
        objc_exposed: false,
    }];

    let tmp = emit(&fw);

    let functions = std::fs::read_to_string(tmp.path().join("residualer/functions.lisp")).unwrap();
    assert!(
        functions.contains("Swift-native functions (trampoline residual"),
        "residual section header present:\n{functions}"
    );
    assert!(
        functions.contains("(defun ns:swift-compute")
            && functions.contains("aw_sbcl_swift_Residualer_swiftCompute"),
        "swiftCompute bound through its content-addressed trampoline:\n{functions}"
    );

    let constants = std::fs::read_to_string(tmp.path().join("residualer/constants.lisp")).unwrap();
    assert!(
        constants.contains("(define-objc-constant ns:ml-error-domain")
            && constants.contains("aw_sbcl_swift_const_Residualer_MLErrorDomain"),
        "MLErrorDomain bound through its content-addressed trampoline:\n{constants}"
    );

    let facade = std::fs::read_to_string(tmp.path().join("residualer.lisp")).unwrap();
    assert!(
        facade.contains("ns::swift-compute"),
        "residual fn exported:\n{facade}"
    );
    assert!(
        facade.contains("ns::ml-error-domain"),
        "residual const exported:\n{facade}"
    );

    // And the whole residual tree still balances.
    for f in lisp_files(tmp.path()) {
        let src = std::fs::read_to_string(&f).unwrap();
        assert_eq!(paren_balance(&src), Ok(0), "{} unbalanced", f.display());
    }
}

fn int64() -> TypeRef {
    TypeRef {
        nullable: false,
        kind: TypeRefKind::Primitive {
            name: "int64".into(),
        },
    }
}

fn swift_native_method(selector: &str, init: bool, ret: TypeRef, params: Vec<Param>) -> Method {
    Method {
        selector: selector.into(),
        class_method: false,
        init_method: init,
        params,
        return_type: ret,
        deprecated: false,
        variadic: false,
        source: None,
        provenance: None,
        doc_refs: None,
        origin: None,
        category: None,
        overrides: None,
        returns_retained: None,
        satisfies_protocol: None,
        objc_exposed: false,
        swift_fn: Some(SwiftFnInfo::default()),
    }
}

#[test]
fn swift_native_method_and_init_residual_bind_on_the_owning_class() {
    // A class owner carrying a Swift-native method `update(with:)` and init
    // `init(value:)` (objc_exposed == false): the method binds as a receiver-specialized
    // defmethod (045), its generic gets a defgeneric (the lockstep), the init binds as a
    // make-<owner> constructor, and both reach the facade's package surface.
    let mut fw = build_snapshot_test_framework();
    fw.name = "Foundation".into();
    fw.classes = vec![Class {
        name: "NSThing".into(),
        superclass: "NSObject".into(),
        protocols: vec![],
        properties: vec![],
        methods: vec![
            swift_native_method(
                "update(with:)",
                false,
                TypeRef::void(),
                vec![Param {
                    name: "with".into(),
                    param_type: int64(),
                }],
            ),
            swift_native_method(
                "init(value:)",
                true,
                TypeRef {
                    nullable: false,
                    kind: TypeRefKind::Instancetype,
                },
                vec![Param {
                    name: "value".into(),
                    param_type: int64(),
                }],
            ),
        ],
        category_methods: vec![],
        swift_attributes: vec![],
        ancestors: vec![],
        all_methods: vec![],
        all_properties: vec![],
        objc_exposed: true,
        swift_name: None,
    }];
    fw.protocols.clear();
    fw.enums.clear();
    fw.functions.clear();
    fw.constants.clear();

    let tmp = emit(&fw);

    let nsthing = std::fs::read_to_string(tmp.path().join("foundation/nsthing.lisp")).unwrap();
    assert!(
        nsthing.contains("(defmethod ns:update-with ((self ns:ns-thing) with)"),
        "residual method binds as a receiver-specialized defmethod:\n{nsthing}"
    );
    assert!(
        nsthing.contains("aw_sbcl_swift_m_Foundation_NSThing_update"),
        "defmethod crosses through its content-addressed trampoline entry:\n{nsthing}"
    );
    assert!(
        nsthing.contains("(defun ns:make-ns-thing-value (value)"),
        "residual init binds as a make-<owner> constructor:\n{nsthing}"
    );
    assert!(
        nsthing.contains("aw_sbcl_swift_init_Foundation_NSThing"),
        "constructor crosses through its content-addressed init entry:\n{nsthing}"
    );

    let generics = std::fs::read_to_string(tmp.path().join("foundation/generics.lisp")).unwrap();
    assert!(
        generics.contains("(defgeneric ns:update-with"),
        "the residual method's generic is declared (the lockstep):\n{generics}"
    );

    let facade = std::fs::read_to_string(tmp.path().join("foundation.lisp")).unwrap();
    assert!(
        facade.contains("ns::update-with"),
        "method generic exported:\n{facade}"
    );
    assert!(
        facade.contains("ns::make-ns-thing-value"),
        "init constructor exported:\n{facade}"
    );

    for f in lisp_files(tmp.path()) {
        let src = std::fs::read_to_string(&f).unwrap();
        assert_eq!(paren_balance(&src), Ok(0), "{} unbalanced", f.display());
    }
}

#[test]
fn swift_native_value_struct_residual_binds_in_structs_lisp() {
    // A population-B value struct (IndexSet) carrying a Swift-native method `contains(_:)`
    // and init `init(integer:)`: ADR-0042 projects it to a plain CLOS class in
    // structs.lisp, the method binds as a defmethod on it (its generic in lockstep), the
    // init binds as a make-<struct> constructor that wraps the box into an instance, and
    // both reach the facade's package surface.
    let mut fw = build_snapshot_test_framework();
    fw.name = "Foundation".into();
    fw.classes.clear();
    fw.protocols.clear();
    fw.enums.clear();
    fw.functions.clear();
    fw.constants.clear();
    fw.structs = vec![Struct {
        name: "IndexSet".into(),
        fields: vec![],
        methods: vec![
            swift_native_method(
                "contains(_:)",
                false,
                TypeRef {
                    nullable: false,
                    kind: TypeRefKind::Primitive {
                        name: "bool".into(),
                    },
                },
                vec![Param {
                    name: "_".into(),
                    param_type: int64(),
                }],
            ),
            swift_native_method(
                "init(integer:)",
                true,
                TypeRef {
                    nullable: false,
                    kind: TypeRefKind::Instancetype,
                },
                vec![Param {
                    name: "integer".into(),
                    param_type: int64(),
                }],
            ),
        ],
        source: None,
        provenance: None,
        doc_refs: None,
        objc_exposed: false,
    }];

    let tmp = emit(&fw);

    let structs = std::fs::read_to_string(tmp.path().join("foundation/structs.lisp")).unwrap();
    assert!(
        structs.contains("(defclass ns:index-set (ns:value-struct) ())"),
        "value struct projects to a plain CLOS class:\n{structs}"
    );
    assert!(
        structs.contains("(defmethod ns:contains ((self ns:index-set) arg0)"),
        "method binds as a defmethod on the struct class:\n{structs}"
    );
    assert!(
        structs.contains("(defun ns:make-index-set-integer (integer)")
            && structs.contains("(make-instance 'ns:index-set :ptr"),
        "init binds as a box-wrapping constructor:\n{structs}"
    );
    assert!(
        structs.contains("(in-package #:apianyware-sbcl-impl)"),
        "structs.lisp carries the impl package header:\n{structs}"
    );

    let generics = std::fs::read_to_string(tmp.path().join("foundation/generics.lisp")).unwrap();
    assert!(
        generics.contains("(defgeneric ns:contains"),
        "the struct method's generic is declared (the lockstep):\n{generics}"
    );

    let facade = std::fs::read_to_string(tmp.path().join("foundation.lisp")).unwrap();
    assert!(
        facade.contains("ns::index-set"),
        "struct class exported:\n{facade}"
    );
    assert!(
        facade.contains("ns::make-index-set-integer"),
        "struct constructor exported:\n{facade}"
    );

    for f in lisp_files(tmp.path()) {
        let src = std::fs::read_to_string(&f).unwrap();
        assert_eq!(paren_balance(&src), Ok(0), "{} unbalanced", f.display());
    }
}
