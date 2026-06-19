//! Tests for mapping ABIRoot nodes to IR types.

use std::path::PathBuf;

use apianyware_macos_extract_swift::abi_types::AbiDocument;
use apianyware_macos_extract_swift::declaration_mapping::map_abi_to_framework;
use serde_json::{json, Value};

fn fixtures_dir() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("tests/fixtures")
}

#[test]
fn map_test_framework_class() {
    let json = std::fs::read_to_string(fixtures_dir().join("test_framework_abi.json"))
        .expect("read fixture");
    let doc: AbiDocument = serde_json::from_str(&json).expect("parse");
    let framework = map_abi_to_framework(&doc, "15.4");

    assert_eq!(framework.name, "TestFramework");
    assert_eq!(framework.checkpoint, "collected");
    assert_eq!(framework.sdk_version.as_deref(), Some("15.4"));

    // Should have 1 class (Widget)
    assert_eq!(framework.classes.len(), 1);
    let widget = &framework.classes[0];
    assert_eq!(widget.name, "Widget");
    assert_eq!(widget.superclass, "Base");
    assert_eq!(widget.protocols, vec!["SomeProtocol"]);

    // Widget should have 3 methods (1 init + 2 methods)
    assert_eq!(widget.methods.len(), 3, "init + process + defaultWidget");

    // Constructor
    let init = widget
        .methods
        .iter()
        .find(|m| m.init_method)
        .expect("should have init method");
    assert!(init.init_method);
    assert_eq!(init.params.len(), 1);
    assert_eq!(init.params[0].name, "name");

    // Instance method
    let process = widget
        .methods
        .iter()
        .find(|m| m.selector.contains("process"))
        .expect("should have process method");
    assert!(!process.class_method);
    assert_eq!(process.params.len(), 1);
    assert_eq!(process.params[0].name, "input");

    // Static method → class_method
    let default_widget = widget
        .methods
        .iter()
        .find(|m| m.selector.contains("defaultWidget"))
        .expect("should have defaultWidget method");
    assert!(default_widget.class_method);

    // Properties
    assert_eq!(widget.properties.len(), 2, "title + identifier");

    let title = widget
        .properties
        .iter()
        .find(|p| p.name == "title")
        .expect("should have title property");
    assert!(!title.readonly, "title has getter+setter");

    let identifier = widget
        .properties
        .iter()
        .find(|p| p.name == "identifier")
        .expect("should have identifier property");
    assert!(identifier.readonly, "identifier is let / getter-only");
    assert!(identifier.property_type.nullable, "identifier is Optional");
}

#[test]
fn map_test_framework_protocol() {
    let json = std::fs::read_to_string(fixtures_dir().join("test_framework_abi.json"))
        .expect("read fixture");
    let doc: AbiDocument = serde_json::from_str(&json).expect("parse");
    let framework = map_abi_to_framework(&doc, "15.4");

    assert_eq!(framework.protocols.len(), 1);
    let proto = &framework.protocols[0];
    assert_eq!(proto.name, "SomeProtocol");
    assert_eq!(proto.required_methods.len(), 1);
    assert_eq!(proto.required_methods[0].selector, "doWork");
}

#[test]
fn map_test_framework_enum() {
    let json = std::fs::read_to_string(fixtures_dir().join("test_framework_abi.json"))
        .expect("read fixture");
    let doc: AbiDocument = serde_json::from_str(&json).expect("parse");
    let framework = map_abi_to_framework(&doc, "15.4");

    assert_eq!(framework.enums.len(), 1);
    let priority = &framework.enums[0];
    assert_eq!(priority.name, "Priority");
    assert_eq!(priority.values.len(), 3);
    assert_eq!(priority.values[0].name, "low");
    assert_eq!(priority.values[1].name, "medium");
    assert_eq!(priority.values[2].name, "high");
}

#[test]
fn map_test_framework_struct() {
    let json = std::fs::read_to_string(fixtures_dir().join("test_framework_abi.json"))
        .expect("read fixture");
    let doc: AbiDocument = serde_json::from_str(&json).expect("parse");
    let framework = map_abi_to_framework(&doc, "15.4");

    assert_eq!(framework.structs.len(), 1);
    let config = &framework.structs[0];
    assert_eq!(config.name, "Config");
    assert_eq!(config.fields.len(), 2);
    assert_eq!(config.fields[0].name, "maxRetries");
    assert_eq!(config.fields[1].name, "name");
}

#[test]
fn map_test_framework_swift_native_function_is_retained_with_objc_exposed_false() {
    // The synthetic fixture's `createDefaultWidget` has a Swift-mangled USR
    // (`s:13TestFramework...`). Per ADR-0026 the additive change RETAINS such
    // Swift-native top-level functions (carrying `objc_exposed: false`) so they
    // reach the emitter to be trampolined — they are no longer dropped to
    // `skipped_symbols` under `SWIFT_NATIVE`.
    let json_str = std::fs::read_to_string(fixtures_dir().join("test_framework_abi.json"))
        .expect("read fixture");
    let doc: AbiDocument = serde_json::from_str(&json_str).expect("parse");
    let framework = map_abi_to_framework(&doc, "15.4");

    let func = framework
        .functions
        .iter()
        .find(|f| f.name == "createDefaultWidget")
        .unwrap_or_else(|| {
            panic!(
                "Swift-native createDefaultWidget should be retained in functions; got {:?}",
                framework
                    .functions
                    .iter()
                    .map(|f| &f.name)
                    .collect::<Vec<_>>()
            )
        });
    assert!(
        !func.objc_exposed,
        "createDefaultWidget is Swift-native (s: USR) → objc_exposed must be false"
    );

    // It must NOT be recorded as a skipped symbol any more.
    assert!(
        !framework
            .skipped_symbols
            .iter()
            .any(|s| s.name == "createDefaultWidget(name:)"),
        "Swift-native top-level functions are retained, not skipped; got {:?}",
        framework
            .skipped_symbols
            .iter()
            .map(|s| &s.name)
            .collect::<Vec<_>>()
    );
}

// ---------------------------------------------------------------------------
// Swift-native symbol filter — synthetic tests
// ---------------------------------------------------------------------------

fn doc_with_top_level(children: Vec<Value>) -> AbiDocument {
    let value = json!({
        "ABIRoot": {
            "kind": "Root",
            "name": "SyntheticFramework",
            "printedName": "SyntheticFramework",
            "children": children,
        }
    });
    serde_json::from_value(value).expect("build AbiDocument")
}

fn top_level_func(name: &str, usr: &str) -> Value {
    json!({
        "kind": "Function",
        "name": name,
        "printedName": format!("{name}()"),
        "declKind": "Func",
        "usr": usr,
        "children": [
            { "kind": "TypeNominal", "name": "Void", "printedName": "Swift.Void", "children": [] }
        ]
    })
}

fn top_level_var(name: &str, usr: &str) -> Value {
    json!({
        "kind": "Var",
        "name": name,
        "printedName": name,
        "declKind": "Var",
        "usr": usr,
        "children": [
            { "kind": "TypeNominal", "name": "UInt32", "printedName": "Swift.UInt32", "children": [] }
        ]
    })
}

#[test]
fn swift_native_top_level_func_is_retained_with_objc_exposed_false() {
    // Mixed USR prefixes in one synthetic framework (ADR-0026):
    //   `s:…`   → Swift-native: RETAIN with objc_exposed = false (trampoline)
    //   `c:@F@` → clang function cursor (real dylib export): retain, exposed
    //   ``      → missing USR: retain, exposed (conservative — missing data is
    //              not evidence of non-linkability; every real digester node
    //              carries a USR).
    let doc = doc_with_top_level(vec![
        top_level_func("swiftNative", "s:10MyFramework11swiftNativeyyF"),
        top_level_func("c_reexport", "c:@F@c_reexport"),
        top_level_func("unknown", ""),
    ]);

    let framework = map_abi_to_framework(&doc, "15.4");

    // All three are now retained — Swift-native is no longer dropped.
    let kept: Vec<&str> = framework
        .functions
        .iter()
        .map(|f| f.name.as_str())
        .collect();
    assert_eq!(kept, vec!["swiftNative", "c_reexport", "unknown"]);

    let exposed_of = |name: &str| {
        framework
            .functions
            .iter()
            .find(|f| f.name == name)
            .unwrap_or_else(|| panic!("{name} should be retained"))
            .objc_exposed
    };
    assert!(!exposed_of("swiftNative"), "s: USR → objc_exposed false");
    assert!(exposed_of("c_reexport"), "c:@F@ USR → objc_exposed true");
    assert!(exposed_of("unknown"), "missing USR → objc_exposed true");

    // No function lands in skipped_symbols any more (only macro / anon-enum
    // cursors do, exercised by the dedicated tests below).
    let skipped: Vec<&str> = framework
        .skipped_symbols
        .iter()
        .filter(|s| s.kind == "function")
        .map(|s| s.name.as_str())
        .collect();
    assert!(
        skipped.is_empty(),
        "Swift-native funcs are retained, not skipped; got {skipped:?}"
    );
}

#[test]
fn swift_native_top_level_var_is_retained_with_objc_exposed_false() {
    // ADR-0026: a Swift-native top-level `Var` is retained as a constant
    // carrying `objc_exposed: false` (trampoline residual), no longer dropped.
    let doc = doc_with_top_level(vec![
        top_level_var("kSwiftNative", "s:10MyFramework13kSwiftNativeSivp"),
        top_level_var("kCReexport", "c:@kCReexport"),
    ]);

    let framework = map_abi_to_framework(&doc, "15.4");

    let kept: Vec<&str> = framework
        .constants
        .iter()
        .map(|c| c.name.as_str())
        .collect();
    assert_eq!(kept, vec!["kSwiftNative", "kCReexport"]);

    let exposed_of = |name: &str| {
        framework
            .constants
            .iter()
            .find(|c| c.name == name)
            .unwrap_or_else(|| panic!("{name} should be retained"))
            .objc_exposed
    };
    assert!(!exposed_of("kSwiftNative"), "s: USR → objc_exposed false");
    assert!(exposed_of("kCReexport"), "c:@ USR → objc_exposed true");

    let skipped: Vec<&str> = framework
        .skipped_symbols
        .iter()
        .filter(|s| s.kind == "constant")
        .map(|s| s.name.as_str())
        .collect();
    assert!(
        skipped.is_empty(),
        "Swift-native vars are retained, not skipped; got {skipped:?}"
    );
}

#[test]
fn foundation_swift_overlay_symbols_are_retained_for_trampolining() {
    // These four real Foundation symbols carry Swift-mangled `s:10Foundation…`
    // USRs (captured verbatim from a real `swift-api-digester -dump-sdk -module
    // Foundation` run on macOS 26.4). Under the OLD model they were dropped to
    // `skipped_symbols` because the emitter would have emitted broken `dlsym`
    // bindings for them. Under ADR-0026 they are RETAINED carrying
    // `objc_exposed: false`: the direct-vs-trampoline decision moves to the
    // emitter (040), which trampolines or skips them instead of mis-binding
    // them — so the old `dlsym`-at-load-time regression is now prevented at the
    // emitter layer, not by dropping the symbols here.
    //
    // The USR shape is reproduced inline rather than read from the gitignored
    // `collection/ir/collected/Foundation.json`, so CI is not silently green
    // when the checkpoint is absent (see memory: "Prefer synthetic tests over
    // external-data-dependent tests").
    let doc = doc_with_top_level(vec![
        top_level_func("pow", "s:10Foundation3powySo9NSDecimalaAD_SitF"),
        top_level_func(
            "NSLocalizedString",
            "s:10Foundation17NSLocalizedString_9tableName6bundle5value7commentS2S_SSSgSo8NSBundleCS2StF",
        ),
        top_level_var(
            "kCFStringEncodingASCII",
            "s:10Foundation22kCFStringEncodingASCIIs6UInt32Vvp",
        ),
        top_level_var("NSNotFound", "s:10Foundation10NSNotFoundSivp"),
    ]);

    let framework = map_abi_to_framework(&doc, "15.4");

    let fn_names: Vec<&str> = framework
        .functions
        .iter()
        .map(|f| f.name.as_str())
        .collect();
    assert_eq!(fn_names, vec!["pow", "NSLocalizedString"]);
    let const_names: Vec<&str> = framework
        .constants
        .iter()
        .map(|c| c.name.as_str())
        .collect();
    assert_eq!(const_names, vec!["kCFStringEncodingASCII", "NSNotFound"]);

    // Every retained Swift-native symbol carries objc_exposed: false.
    assert!(
        framework.functions.iter().all(|f| !f.objc_exposed),
        "swift-overlay functions must carry objc_exposed: false"
    );
    assert!(
        framework.constants.iter().all(|c| !c.objc_exposed),
        "swift-overlay constants must carry objc_exposed: false"
    );

    // None of them is dropped to skipped_symbols any more.
    assert!(
        framework.skipped_symbols.is_empty(),
        "swift-overlay symbols are retained, not skipped; got {:?}",
        framework
            .skipped_symbols
            .iter()
            .map(|s| &s.name)
            .collect::<Vec<_>>()
    );
}

// ---------------------------------------------------------------------------
// objc_exposed on retained Swift-native TYPES — synthetic tests
// ---------------------------------------------------------------------------

#[test]
fn swift_native_types_carry_objc_exposed_false() {
    // The synthetic TestFramework fixture is entirely Swift-native (every USR
    // is `s:13TestFramework…`). ADR-0026: these already-retained type decls now
    // carry `objc_exposed: false` so the emitter can route them away from the
    // latently-broken `objc_msgSend` bindings.
    let json = std::fs::read_to_string(fixtures_dir().join("test_framework_abi.json"))
        .expect("read fixture");
    let doc: AbiDocument = serde_json::from_str(&json).expect("parse");
    let framework = map_abi_to_framework(&doc, "15.4");

    let widget = &framework.classes[0];
    assert_eq!(widget.name, "Widget");
    assert!(
        !widget.objc_exposed,
        "Swift-native class → objc_exposed false"
    );
    // Per-member granularity: the class's own Swift methods carry false too.
    assert!(
        widget.methods.iter().all(|m| !m.objc_exposed),
        "Swift-native methods must carry objc_exposed: false"
    );
    assert!(
        widget.properties.iter().all(|p| !p.objc_exposed),
        "Swift-native properties must carry objc_exposed: false"
    );
    assert!(
        !framework.protocols[0].objc_exposed,
        "Swift-native protocol → objc_exposed false"
    );
    assert!(
        !framework.enums[0].objc_exposed,
        "Swift-native enum → objc_exposed false"
    );
    assert!(
        !framework.structs[0].objc_exposed,
        "Swift-native struct → objc_exposed false"
    );
}

// ---------------------------------------------------------------------------
// Deferred ABI kinds — synthetic tests
// ---------------------------------------------------------------------------

#[test]
fn deferred_abi_kinds_are_recorded_in_skipped_symbols() {
    // ADR-0026/D2: Macro / TypeAlias / AssociatedType top-level ABI nodes are
    // not yet walked, but recording them in skipped_symbols (under
    // `deferred_abi_kind`) makes the drop auditable rather than the former
    // silent `_ => {}`. Recovering them is a later frontier leaf.
    let doc = doc_with_top_level(vec![
        json!({ "kind": "TypeAlias", "name": "MyAlias", "printedName": "MyAlias",
                "declKind": "TypeAlias", "usr": "s:10MyFramework7MyAliasa", "children": [] }),
        json!({ "kind": "Macro", "name": "MyMacro", "printedName": "MyMacro",
                "declKind": "Macro", "usr": "s:10MyFramework7MyMacrofm", "children": [] }),
        json!({ "kind": "AssociatedType", "name": "Element", "printedName": "Element",
                "declKind": "AssociatedType", "usr": "s:10MyFramework7ElementQa", "children": [] }),
    ]);

    let framework = map_abi_to_framework(&doc, "15.4");

    let deferred: std::collections::BTreeSet<(&str, &str)> = framework
        .skipped_symbols
        .iter()
        .filter(|s| s.reason.contains("deferred_abi_kind"))
        .map(|s| (s.name.as_str(), s.kind.as_str()))
        .collect();
    let expected: std::collections::BTreeSet<(&str, &str)> = [
        ("MyAlias", "typealias"),
        ("MyMacro", "macro"),
        ("Element", "associatedtype"),
    ]
    .into_iter()
    .collect();
    assert_eq!(
        deferred, expected,
        "all three deferred ABI kinds must be recorded with their lowercased decl kind"
    );
}

// ---------------------------------------------------------------------------
// Preprocessor-macro cursor filter — synthetic tests
// ---------------------------------------------------------------------------

#[test]
fn preprocessor_macro_top_level_var_is_skipped_while_c_var_is_kept() {
    // The Swift API digester surfaces clang-imported preprocessor macros as
    // top-level `Var` nodes whose USR begins `c:@macro@`. They have no
    // dylib export (the C compiler inlines `#define` constants at use sites)
    // and any C-FFI binding that references them dies at load time with
    // `get-ffi-obj: could not find export from foreign library`. The filter
    // must distinguish them from `c:@<name>` (clang `VarDecl` cursor — a
    // real exported global) which must continue to land in `constants`.
    let doc = doc_with_top_level(vec![
        top_level_var("kPreprocessorMacro", "c:@macro@kPreprocessorMacro"),
        top_level_var("kRealCVar", "c:@kRealCVar"),
    ]);

    let framework = map_abi_to_framework(&doc, "15.4");

    let kept: Vec<&str> = framework
        .constants
        .iter()
        .map(|c| c.name.as_str())
        .collect();
    assert_eq!(
        kept,
        vec!["kRealCVar"],
        "only `c:@macro@` USRs should be filtered; `c:@<name>` clang VarDecls remain"
    );

    let skipped: Vec<&str> = framework
        .skipped_symbols
        .iter()
        .filter(|s| s.kind == "constant")
        .map(|s| s.name.as_str())
        .collect();
    assert_eq!(skipped, vec!["kPreprocessorMacro"]);

    let skipped_entry = framework
        .skipped_symbols
        .iter()
        .find(|s| s.name == "kPreprocessorMacro")
        .expect("kPreprocessorMacro must be recorded in skipped_symbols");
    assert!(
        skipped_entry.reason.contains("preprocessor macro"),
        "skip reason should identify the cursor family; got {:?}",
        skipped_entry.reason
    );
}

#[test]
fn coretext_version_macro_regression_is_filtered() {
    // Regression guard: `kCTVersionNumber10_10` and siblings were observed
    // leaking into the CoreText collected IR via extract-swift. CoreText
    // exposes a family of `kCTVersionNumber*` `#define` constants that the
    // Swift API digester surfaces as top-level `Var` nodes with
    // `c:@macro@kCTVersionNumber10_10`-shaped USRs. The test reproduces the
    // USR shape inline rather than reading the gitignored
    // `collection/ir/collected/CoreText.json`, so CI is not silently green
    // when the checkpoint is absent (see memory: "Prefer synthetic tests
    // over external-data-dependent tests").
    let doc = doc_with_top_level(vec![
        top_level_var("kCTVersionNumber10_10", "c:@macro@kCTVersionNumber10_10"),
        top_level_var("kCTVersionNumber10_11", "c:@macro@kCTVersionNumber10_11"),
        top_level_var("kCTVersionNumber10_12", "c:@macro@kCTVersionNumber10_12"),
    ]);

    let framework = map_abi_to_framework(&doc, "15.4");

    assert!(
        framework.constants.is_empty(),
        "no kCTVersionNumber* macro entries should reach the IR: got {:?}",
        framework
            .constants
            .iter()
            .map(|c| &c.name)
            .collect::<Vec<_>>()
    );

    let skipped_names: std::collections::BTreeSet<&str> = framework
        .skipped_symbols
        .iter()
        .map(|s| s.name.as_str())
        .collect();
    for name in [
        "kCTVersionNumber10_10",
        "kCTVersionNumber10_11",
        "kCTVersionNumber10_12",
    ] {
        assert!(
            skipped_names.contains(name),
            "{name} should be recorded in skipped_symbols; got {skipped_names:?}"
        );
    }
}

#[test]
fn preprocessor_macro_top_level_func_is_skipped() {
    // Defensive symmetry: a `c:@macro@` USR on a `Func` node (function-like
    // macro) is equally non-`dlsym`-able and must be filtered. Whether or
    // not the digester actually emits this shape today, the filter should
    // be symmetric across the Var and Func arms — same producer, same
    // discriminator, same skip path — so future digester releases that
    // surface function-like macros as Func nodes are caught automatically.
    let doc = doc_with_top_level(vec![
        top_level_func("CTFontGetGlyphCount", "c:@F@CTFontGetGlyphCount"),
        top_level_func("MIN", "c:@macro@MIN"),
    ]);

    let framework = map_abi_to_framework(&doc, "15.4");

    let kept: Vec<&str> = framework
        .functions
        .iter()
        .map(|f| f.name.as_str())
        .collect();
    assert_eq!(
        kept,
        vec!["CTFontGetGlyphCount"],
        "only `c:@macro@` USRs should be filtered from functions"
    );

    let skipped: Vec<&str> = framework
        .skipped_symbols
        .iter()
        .filter(|s| s.kind == "function")
        .map(|s| s.name.as_str())
        .collect();
    assert_eq!(skipped, vec!["MIN()"]);
}

// ---------------------------------------------------------------------------
// Anonymous-enum-member cursor filter — synthetic tests
// ---------------------------------------------------------------------------

#[test]
fn anonymous_enum_member_top_level_vars_are_skipped_while_c_var_is_kept() {
    // libclang USRs distinguish enum cursors by a one- or two-letter family
    // marker after `c:@`:
    //   `c:@E@<Enum>@<Member>`   → member of a *named* enum
    //   `c:@Ea@<dummy>@<Member>` → member of an *anonymous* enum (synthetic
    //                              disambiguator from the first member)
    //   `c:@EA@<typedef>@<Member>` → member of `typedef enum { … } Name_t`
    // Both anonymous shapes (`Ea` and `EA`) are enum *members*: the C
    // compiler inlines their integer values at every use site, so they
    // never receive a dylib symbol and any C-FFI binding that references
    // them dies at load time with `get-ffi-obj: could not find export from
    // foreign library`. The filter must reject both shapes while leaving
    // real `c:@<name>` clang VarDecls (exported globals) untouched.
    let doc = doc_with_top_level(vec![
        top_level_var(
            "nw_browse_result_change_identical",
            "c:@Ea@nw_browse_result_change_invalid@nw_browse_result_change_identical",
        ),
        top_level_var(
            "nw_browser_state_ready",
            "c:@EA@nw_browser_state_t@nw_browser_state_ready",
        ),
        top_level_var("kRealCVar", "c:@kRealCVar"),
    ]);

    let framework = map_abi_to_framework(&doc, "15.4");

    let kept: Vec<&str> = framework
        .constants
        .iter()
        .map(|c| c.name.as_str())
        .collect();
    assert_eq!(
        kept,
        vec!["kRealCVar"],
        "only `c:@<name>` clang VarDecls should remain; both anonymous-enum-member shapes must be filtered"
    );

    let skipped: Vec<&str> = framework
        .skipped_symbols
        .iter()
        .filter(|s| s.kind == "constant")
        .map(|s| s.name.as_str())
        .collect();
    assert_eq!(
        skipped,
        vec![
            "nw_browse_result_change_identical",
            "nw_browser_state_ready"
        ]
    );

    for name in [
        "nw_browse_result_change_identical",
        "nw_browser_state_ready",
    ] {
        let entry = framework
            .skipped_symbols
            .iter()
            .find(|s| s.name == name)
            .unwrap_or_else(|| panic!("{name} must be recorded in skipped_symbols"));
        assert!(
            entry.reason.contains("anonymous enum member"),
            "skip reason for {name} should identify the cursor family; got {:?}",
            entry.reason
        );
    }
}

#[test]
fn nw_browse_result_change_regression_is_filtered() {
    // Regression guard: the seven members of Network's
    // `nw_browse_result_change_*` anonymous enum were observed leaking into
    // the Network collected IR via extract-swift after the racket
    // runtime load harness extension attempt failed at `dlsym` on
    // `nw_browse_result_change_identical`. Their USRs (captured verbatim
    // from a real `swift-api-digester -dump-sdk -module Network` run on
    // macOS 26.4) all begin with `c:@Ea@nw_browse_result_change_invalid@`,
    // where the second segment is the synthetic disambiguator libclang
    // generates for anonymous enums — by convention the first member's
    // name. The test reproduces the USR shape inline rather than reading
    // the gitignored `collection/ir/collected/Network.json`, so CI is not
    // silently green when the checkpoint is absent (see memory: "Prefer
    // synthetic tests over external-data-dependent tests").
    let doc = doc_with_top_level(vec![
        top_level_var(
            "nw_browse_result_change_invalid",
            "c:@Ea@nw_browse_result_change_invalid@nw_browse_result_change_invalid",
        ),
        top_level_var(
            "nw_browse_result_change_identical",
            "c:@Ea@nw_browse_result_change_invalid@nw_browse_result_change_identical",
        ),
        top_level_var(
            "nw_browse_result_change_result_added",
            "c:@Ea@nw_browse_result_change_invalid@nw_browse_result_change_result_added",
        ),
        top_level_var(
            "nw_browse_result_change_result_removed",
            "c:@Ea@nw_browse_result_change_invalid@nw_browse_result_change_result_removed",
        ),
        top_level_var(
            "nw_browse_result_change_interface_added",
            "c:@Ea@nw_browse_result_change_invalid@nw_browse_result_change_interface_added",
        ),
        top_level_var(
            "nw_browse_result_change_interface_removed",
            "c:@Ea@nw_browse_result_change_invalid@nw_browse_result_change_interface_removed",
        ),
        top_level_var(
            "nw_browse_result_change_txt_record_changed",
            "c:@Ea@nw_browse_result_change_invalid@nw_browse_result_change_txt_record_changed",
        ),
    ]);

    let framework = map_abi_to_framework(&doc, "15.4");

    assert!(
        framework.constants.is_empty(),
        "no nw_browse_result_change_* members should reach the IR: got {:?}",
        framework
            .constants
            .iter()
            .map(|c| &c.name)
            .collect::<Vec<_>>()
    );

    let skipped_names: std::collections::BTreeSet<&str> = framework
        .skipped_symbols
        .iter()
        .map(|s| s.name.as_str())
        .collect();
    for name in [
        "nw_browse_result_change_invalid",
        "nw_browse_result_change_identical",
        "nw_browse_result_change_result_added",
        "nw_browse_result_change_result_removed",
        "nw_browse_result_change_interface_added",
        "nw_browse_result_change_interface_removed",
        "nw_browse_result_change_txt_record_changed",
    ] {
        assert!(
            skipped_names.contains(name),
            "{name} should be recorded in skipped_symbols; got {skipped_names:?}"
        );
    }
}

#[test]
fn anonymous_enum_member_top_level_func_is_skipped() {
    // Defensive symmetry: a `c:@Ea@`/`c:@EA@` USR on a `Func` node is
    // equally non-`dlsym`-able and must be filtered. Whether or not the
    // digester actually emits this shape today, the filter should be
    // symmetric across the Var and Func arms — same producer, same
    // discriminator, same skip path — so future digester releases that
    // surface anonymous-enum-shaped Func nodes are caught automatically.
    let doc = doc_with_top_level(vec![
        top_level_func("real_c_function", "c:@F@real_c_function"),
        top_level_func("anon_enum_func_a", "c:@Ea@SomeEnum@anon_enum_func_a"),
        top_level_func(
            "anon_enum_func_typedef",
            "c:@EA@SomeEnum_t@anon_enum_func_typedef",
        ),
    ]);

    let framework = map_abi_to_framework(&doc, "15.4");

    let kept: Vec<&str> = framework
        .functions
        .iter()
        .map(|f| f.name.as_str())
        .collect();
    assert_eq!(
        kept,
        vec!["real_c_function"],
        "only `c:@Ea@`/`c:@EA@` USRs should be filtered from functions"
    );

    let skipped: Vec<&str> = framework
        .skipped_symbols
        .iter()
        .filter(|s| s.kind == "function")
        .map(|s| s.name.as_str())
        .collect();
    assert_eq!(
        skipped,
        vec!["anon_enum_func_a()", "anon_enum_func_typedef()"]
    );
}

#[test]
fn map_test_framework_imports() {
    let json = std::fs::read_to_string(fixtures_dir().join("test_framework_abi.json"))
        .expect("read fixture");
    let doc: AbiDocument = serde_json::from_str(&json).expect("parse");
    let framework = map_abi_to_framework(&doc, "15.4");

    assert_eq!(framework.depends_on, vec!["Foundation"]);
}

#[test]
fn map_test_framework_source_is_swift_interface() {
    let json = std::fs::read_to_string(fixtures_dir().join("test_framework_abi.json"))
        .expect("read fixture");
    let doc: AbiDocument = serde_json::from_str(&json).expect("parse");
    let framework = map_abi_to_framework(&doc, "15.4");

    // All methods should have source: SwiftInterface
    for class in &framework.classes {
        for method in &class.methods {
            assert_eq!(
                method.source,
                Some(apianyware_macos_types::provenance::DeclarationSource::SwiftInterface),
                "method {} should have SwiftInterface source",
                method.selector
            );
        }
        for property in &class.properties {
            assert_eq!(
                property.source,
                Some(apianyware_macos_types::provenance::DeclarationSource::SwiftInterface),
                "property {} should have SwiftInterface source",
                property.name
            );
        }
    }
}

// ---------------------------------------------------------------------------
// Foreign-module top-level decl filter — synthetic tests
//
// `swift-api-digester -dump-sdk -module X` re-emits any external type X
// extends as a top-level declaration with `moduleName` pointing back at the
// owning module (e.g. `Sequence` → `moduleName: "Swift"`). The body of that
// re-emitted node carries X's extension methods. Without filtering, the
// resolve pass treats those re-emitted protocols as if X declared them, then
// propagates their extension methods to every conforming class anywhere in
// the SDK — `SBElementArray.mapAnnotations(_:)` is the original sighting in
// `analysis/ir/llm-summaries/ScriptingBridge.methods.json` (the method is a
// `CreateMLComponents.Sequence` extension that does not exist in
// ScriptingBridge headers). The filter must drop these foreign-module
// declarations entirely.
// ---------------------------------------------------------------------------

fn doc_with_module(module: &str, children: Vec<Value>) -> AbiDocument {
    let value = json!({
        "ABIRoot": {
            "kind": "Root",
            "name": module,
            "printedName": module,
            "children": children,
        }
    });
    serde_json::from_value(value).expect("build AbiDocument")
}

fn protocol_decl_with_module(name: &str, module: &str, child_funcs: Vec<Value>) -> Value {
    json!({
        "kind": "TypeDecl",
        "name": name,
        "printedName": name,
        "declKind": "Protocol",
        "moduleName": module,
        "usr": format!("s:{}P", name),
        "children": child_funcs,
    })
}

fn extension_func_child(name: &str, module: &str) -> Value {
    json!({
        "kind": "Function",
        "name": name,
        "printedName": format!("{name}(_:)"),
        "declKind": "Func",
        "moduleName": module,
        "isFromExtension": true,
        "usr": format!("s:{}{}F", module, name),
        "children": [
            { "kind": "TypeNominal", "name": "Void", "printedName": "Swift.Void", "children": [] }
        ]
    })
}

#[test]
fn foreign_module_protocol_with_extension_methods_is_skipped() {
    // `CreateMLComponents` extends Swift's `Sequence` protocol with
    // `mapAnnotations(_:)` and `mapFeatures(_:)`. The digester re-emits
    // `Sequence` at the top level with `moduleName: "Swift"`, listing the
    // extension methods as children with `isFromExtension: true`. Without
    // filtering, downstream resolve treats `Sequence` as a CreateMLComponents-
    // owned protocol and propagates `mapAnnotations`/`mapFeatures` to every
    // class in the SDK that conforms to `Sequence` — including
    // `SBElementArray` in ScriptingBridge.
    let doc = doc_with_module(
        "CreateMLComponents",
        vec![protocol_decl_with_module(
            "Sequence",
            "Swift",
            vec![
                extension_func_child("mapAnnotations", "CreateMLComponents"),
                extension_func_child("mapFeatures", "CreateMLComponents"),
            ],
        )],
    );

    let framework = map_abi_to_framework(&doc, "15.4");

    assert!(
        framework.protocols.is_empty(),
        "foreign-module Sequence must not be emitted as a CreateMLComponents protocol; got {:?}",
        framework
            .protocols
            .iter()
            .map(|p| &p.name)
            .collect::<Vec<_>>()
    );
}

#[test]
fn foreign_module_struct_with_extension_methods_is_skipped() {
    // CreateMLComponents extends `TabularData.DataFrame`. The digester re-
    // emits the struct at the top level with `moduleName: "TabularData"`.
    let doc = doc_with_module(
        "CreateMLComponents",
        vec![json!({
            "kind": "TypeDecl",
            "name": "DataFrame",
            "printedName": "DataFrame",
            "declKind": "Struct",
            "moduleName": "TabularData",
            "usr": "s:11TabularData9DataFrameV",
            "children": [],
        })],
    );

    let framework = map_abi_to_framework(&doc, "15.4");

    assert!(
        framework.structs.is_empty(),
        "foreign-module DataFrame must not be emitted: got {:?}",
        framework
            .structs
            .iter()
            .map(|s| &s.name)
            .collect::<Vec<_>>()
    );
}

#[test]
fn own_protocol_with_matching_module_is_kept() {
    // Sanity check: a protocol whose `moduleName` matches the framework
    // root must still be emitted normally.
    let doc = doc_with_module(
        "MyFramework",
        vec![json!({
            "kind": "TypeDecl",
            "name": "MyProtocol",
            "printedName": "MyProtocol",
            "declKind": "Protocol",
            "moduleName": "MyFramework",
            "usr": "s:11MyFramework10MyProtocolP",
            "children": [],
        })],
    );

    let framework = map_abi_to_framework(&doc, "15.4");

    let names: Vec<&str> = framework
        .protocols
        .iter()
        .map(|p| p.name.as_str())
        .collect();
    assert_eq!(names, vec!["MyProtocol"]);
}

#[test]
fn decl_without_module_name_is_kept() {
    // Defensive: real digester output always has `moduleName`, but if a
    // decl ever appears without it we should keep it (missing data is not
    // evidence of foreign ownership).
    let doc = doc_with_module(
        "MyFramework",
        vec![json!({
            "kind": "TypeDecl",
            "name": "Untagged",
            "printedName": "Untagged",
            "declKind": "Struct",
            "usr": "s:11MyFramework8UntaggedV",
            "children": [],
        })],
    );

    let framework = map_abi_to_framework(&doc, "15.4");

    let names: Vec<&str> = framework.structs.iter().map(|s| s.name.as_str()).collect();
    assert_eq!(names, vec!["Untagged"]);
}

#[test]
fn map_observation_framework() {
    let json =
        std::fs::read_to_string(fixtures_dir().join("observation_abi.json")).expect("read fixture");
    let doc: AbiDocument = serde_json::from_str(&json).expect("parse");
    let framework = map_abi_to_framework(&doc, "15.4");

    assert_eq!(framework.name, "Observation");

    // Should have the Observable protocol
    let observable = framework
        .protocols
        .iter()
        .find(|p| p.name == "Observable")
        .expect("should have Observable protocol");
    assert!(observable.required_methods.is_empty() || !observable.required_methods.is_empty());

    // Should have ObservationRegistrar struct
    let registrar = framework
        .structs
        .iter()
        .find(|s| s.name == "ObservationRegistrar")
        .expect("should have ObservationRegistrar struct");
    assert!(!registrar.fields.is_empty(), "registrar should have fields");
}
