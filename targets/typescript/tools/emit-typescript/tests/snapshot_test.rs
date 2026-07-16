//! Snapshot (golden-file) regression tests for the TypeScript emitter's
//! per-framework orchestrator (`framework-orchestration-and-goldens-k22`).
//!
//! Two layers, mirroring the sbcl precedent:
//!   1. **TestKit (synthetic)** — always runs, no enriched IR needed. A bespoke TS
//!      fixture emitted through the real [`TargetEmitter`] (with the whole-program
//!      registry the CLI pre-pass builds): a same-framework inheritance chain, a
//!      cross-framework reference (`NSString`, owned by Foundation), and a synthesized
//!      bare class-graph node — the multi-module import grouping + barrel load order the
//!      hand-built one-class unit tests cannot exercise. The whole emitted directory
//!      (paired `.ts`/`.d.ts` per class + the barrel) is compared against committed
//!      goldens.
//!   2. **Foundation (real IR)** — goldens-as-truth over a curated subset. SKIPPED-as-pass
//!      when the enriched IR is absent (it is gitignored, 16–90 MB), so default
//!      `cargo test` stays green everywhere. Once the analysis pipeline has been run
//!      locally, bootstrap/refresh with `UPDATE_GOLDEN=1`.
//!
//! To update golden files after intentional emitter changes:
//!   UPDATE_GOLDEN=1 cargo test -p apianyware-emit-typescript --test snapshot_test

use std::collections::BTreeSet;
use std::path::PathBuf;

use apianyware_emit::snapshot_testing::GoldenTest;
use apianyware_emit::target_emitter::TargetEmitter;
use apianyware_emit_typescript::class_graph::ClassRegistry;
use apianyware_emit_typescript::enum_graph::EnumRegistry;
use apianyware_emit_typescript::protocol_graph::ProtocolRegistry;
use apianyware_emit_typescript::TsEmitter;
use apianyware_types::enrichment::{ClassSelectorEntry, EnrichmentData};
use apianyware_types::ir::{
    Class, Constant, Enum, EnumValue, Framework, Function, Method, Param, Protocol,
};
use apianyware_types::type_ref::{TypeRef, TypeRefKind};

// ---------------------------------------------------------------------------
// Type + node helpers
// ---------------------------------------------------------------------------

fn ty(kind: TypeRefKind) -> TypeRef {
    TypeRef {
        nullable: false,
        kind,
    }
}

fn nullable(kind: TypeRefKind) -> TypeRef {
    TypeRef {
        nullable: true,
        kind,
    }
}

fn id() -> TypeRef {
    ty(TypeRefKind::Id {
        protocols: Vec::new(),
    })
}

/// A **protocol-qualified** `id<P…>` — what `protocol-qualifier-ir-k81` put into the IR and
/// `protocol-binding-surface-k89` types by its interface (ADR-0055 §4b).
fn qualified_id(protocols: &[&str]) -> TypeRef {
    ty(TypeRefKind::Id {
        protocols: protocols.iter().map(|s| s.to_string()).collect(),
    })
}

/// A nullable protocol-qualified `id<P…>` — the delegate **getter**'s shape.
fn nullable_qualified_id(protocols: &[&str]) -> TypeRef {
    nullable(TypeRefKind::Id {
        protocols: protocols.iter().map(|s| s.to_string()).collect(),
    })
}

fn instancetype() -> TypeRef {
    ty(TypeRefKind::Instancetype)
}

fn instancetype_nullable() -> TypeRef {
    nullable(TypeRefKind::Instancetype)
}

fn class_ty(name: &str) -> TypeRef {
    ty(TypeRefKind::Class {
        name: name.into(),
        framework: None,
        params: vec![],
    })
}

fn class_ty_nullable(name: &str) -> TypeRef {
    nullable(TypeRefKind::Class {
        name: name.into(),
        framework: None,
        params: vec![],
    })
}

fn integer() -> TypeRef {
    ty(TypeRefKind::Primitive {
        name: "NSInteger".into(),
    })
}

fn boolean() -> TypeRef {
    ty(TypeRefKind::Primitive {
        name: "BOOL".into(),
    })
}

fn double() -> TypeRef {
    ty(TypeRefKind::Primitive {
        name: "double".into(),
    })
}

/// A genuine `NS_ENUM`/`NS_OPTIONS` typedef alias in a signature — the mapper upgrades it
/// to the TS `enum` type name once the framework's enum set proves it an enum
/// (enum-alias-typing). `underlying` is the extracted width that also fixes the dispatch
/// code (`NSInteger`/`int64` → `q`, `uint32` → `I`).
fn enum_alias(name: &str, underlying: &str) -> TypeRef {
    ty(TypeRefKind::Alias {
        name: name.into(),
        framework: None,
        underlying_primitive: Some(underlying.into()),
    })
}

fn param(name: &str, param_type: TypeRef) -> Param {
    Param {
        name: name.into(),
        param_type,
    }
}

fn method(selector: &str, class_method: bool, params: Vec<Param>, return_type: TypeRef) -> Method {
    Method {
        selector: selector.into(),
        class_method,
        init_method: false,
        params,
        return_type,
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
        objc_exposed: true,
        swift_fn: None,
    }
}

fn class(name: &str, superclass: &str, methods: Vec<Method>) -> Class {
    class_conforming(name, superclass, &[], methods)
}

/// A class that conforms to `protocols` — the `implements` clause surface (ADR-0055 §4).
fn class_conforming(
    name: &str,
    superclass: &str,
    protocols: &[&str],
    methods: Vec<Method>,
) -> Class {
    Class {
        name: name.into(),
        superclass: superclass.into(),
        protocols: protocols.iter().map(|s| (*s).into()).collect(),
        properties: vec![],
        methods,
        category_methods: vec![],
        swift_attributes: vec![],
        ancestors: vec![],
        all_methods: vec![],
        all_properties: vec![],
        objc_exposed: true,
        swift_name: None,
    }
}

fn protocol(
    name: &str,
    inherits: &[&str],
    required: Vec<Method>,
    optional: Vec<Method>,
) -> Protocol {
    Protocol {
        name: name.into(),
        inherits: inherits.iter().map(|s| (*s).into()).collect(),
        required_methods: required,
        optional_methods: optional,
        properties: vec![],
        source: None,
        provenance: None,
        doc_refs: None,
        objc_exposed: true,
    }
}

fn enum_decl(name: &str, underlying: &str, values: &[(&str, i64)]) -> Enum {
    Enum {
        name: name.into(),
        enum_type: ty(TypeRefKind::Primitive {
            name: underlying.into(),
        }),
        values: values
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

/// A bespoke TS fixture exercising the orchestrator's whole surface:
/// - a same-framework chain `TKObject → TKView → TKButton` (subclass imports its
///   superclass from the package barrel — the intra-package cycle the load order fixes);
/// - a **cross-framework** reference: `-[TKObject name]` / `-[TKButton title]` return
///   `NSString`, owned by Foundation (via the registry) → imported from
///   `@apianyware/foundation`;
/// - a class (`TKView`) that references **no** `NSObject` → its runtime block carries only
///   seam helpers (the fixed unconditional-import case);
/// - a **synthesized bare node**: `TKGizmo extends TKMissing`, where `TKMissing` is
///   referenced but not collected → emitted as a minimal root-derived class ahead of the
///   collected classes and re-exported first;
/// - **enums** (`emit-enums-k24`): a signed `NS_ENUM` (`TKAlignment`, verbatim members +
///   values) and an unsigned `NS_OPTIONS` (`TKKeyMask`, whose all-bits `-1` reinterprets to
///   the `uint32` max) → the co-generated `enums.ts` + `enums.d.ts`, re-exported from the
///   barrel after the classes;
/// - **enum-alias-typing** (`enum-alias-typing-k26`): `TKButton` gains `setAlignment:`
///   (a `TKAlignment` param → the enum type, crossing uncoerced) and `keyMask` (a
///   `TKKeyMask` return → the enum type, cast in the `.ts` body) — both same-framework
///   enums imported **type-only** from the barrel (no runtime cycle);
/// - **protocols** (`emit-protocol-k25`): a base `TKRefreshing` (required + `?`-optional
///   members) and a `TKButtonDelegate` (same-framework inheritance from `TKRefreshing`,
///   an `id` param → runtime `NSObject`, a cross-framework `NSString` return →
///   `@apianyware/foundation`, and an `alignmentForButton:` member returning the
///   `TKAlignment` enum → a type-only enum import) → the co-generated `protocols.ts` +
///   `protocols.d.ts`, re-exported from the barrel after the enums;
/// - **implements + cross-framework protocol extends + protocol-typed param**
///   (`implements-and-param-typing-k27`): `TKView implements TKRefreshing` (a same-framework
///   conformance — the interface imported type-only from TestKit's own barrel — declaring the
///   required `refresh()`); `TKButtonDelegate extends TKRefreshing, NSCopying`, where
///   `NSCopying` is owned by Foundation (via the protocol registry) → a **cross-framework**
///   `extends` imported type-only from `@apianyware/foundation`;
/// - **the protocol-qualified slot, both directions** (`protocol-binding-surface-k89`, ADR-0055
///   §4b): `TKButton.setDelegate:` takes `id<TKButtonDelegate>` → the **bare interface**
///   `TKButtonDelegate` (contravariant — a plain JS object literal satisfies it), while
///   `TKButton.delegate` returns `id<TKButtonDelegate>` → `TKButtonDelegate & NSObject`
///   (covariant — what the value *is*, once `dynamic-class-wrap-k88` mints it into its real ObjC
///   class), whose body carries the declared conformance into the class-less wrap arm
///   (`__wrapRetained<TKButtonDelegate & NSObject>(__ret)`). The interface imports **type-only**;
/// - **constants + free functions** (`constants-and-functions-k28`, ADR-0055 §6 / ADR-0054):
///   a `constants.ts`/`.d.ts` (a pointer-valued `NSString` global read + wrapped borrowed, a
///   CFSTR macro built from its literal + wrapped owned, a scalar global, an enum-typed global
///   cast to the enum type) and a `functions.ts`/`.d.ts` (scalar dispatch, object-arg + object
///   return by CF-Create-Rule ownership, enum param/return, void — plus a deferred raw-pointer
///   `NSError**`-shape function that emits nothing) → both re-exported from the barrel after
///   the protocols.
/// - **the `NSError**` → `Result<T>` channel for fallible methods** (`error-model-k29`,
///   ADR-0058): `TKObject` gains a **static** object factory (`+objectFromFile:error:` →
///   `Result<TKObject>`, out-param dropped, `+0` → `__resultRetained` over the `…_e` entry)
///   and an **instance** BOOL writer (`-writeToFile:error:` → `Result<boolean>` via
///   `__resultScalar`), driven by the `enrichment.convenience_error_methods` set below;
///   `Result` imports type-only from the runtime and the barrel re-exports the runtime error
///   hierarchy (`unwrap`/`ObjCError`/`NSExceptionError`/`NSErrorError`).
///
/// The shared `build_snapshot_test_framework` is deliberately not reused: it carries
/// properties, blocks, and structs this emitter's `method_filter` still defers — a bespoke
/// fixture keeps the golden focused on this leaf's surface.
fn build_testkit_framework() -> Framework {
    Framework {
        format_version: "1.0".into(),
        checkpoint: "resolved".into(),
        name: "TestKit".into(),
        sdk_version: Some("15.4".into()),
        collected_at: Some("2026-01-01T00:00:00Z".into()),
        depends_on: vec![],
        skipped_symbols: vec![],
        // IR order deliberately not load order — the orchestrator must sort.
        classes: vec![
            class(
                "TKObject",
                "NSObject",
                vec![
                    method(
                        "objectWithName:",
                        true,
                        vec![param("name", id())],
                        instancetype(),
                    ),
                    method("name", false, vec![], class_ty_nullable("NSString")),
                    method(
                        "setTag:",
                        false,
                        vec![param("tag", integer())],
                        TypeRef::void(),
                    ),
                    method("tag", false, vec![], integer()),
                    // Two fallible NSError** methods (error-model-k29, ADR-0058): the
                    // enrichment set below flags both, so each drops its trailing NSError**
                    // cell and returns Result<T> over a `…_e` dispatch entry.
                    // A **static** object factory: nil-on-failure instancetype → Result<TKObject>
                    // (T non-null), +0 → __resultRetained; the out-param is dropped.
                    method(
                        "objectFromFile:error:",
                        true,
                        vec![
                            param("path", class_ty("NSString")),
                            param("error", ty(TypeRefKind::Pointer)),
                        ],
                        instancetype_nullable(),
                    ),
                    // An **instance** BOOL writer: NO-on-failure → Result<boolean>, the scalar
                    // helper; a cross-framework NSString arg unwraps.
                    method(
                        "writeToFile:error:",
                        false,
                        vec![
                            param("path", class_ty("NSString")),
                            param("error", ty(TypeRefKind::Pointer)),
                        ],
                        boolean(),
                    ),
                ],
            ),
            // TKView conforms to the same-framework protocol TKRefreshing (implements-and-
            // param-typing-k27): it declares the required `refresh()` (the optional
            // `refreshInterval` is omittable), so `deno check` accepts the conformance; the
            // interface imports type-only from TestKit's own barrel.
            class_conforming(
                "TKView",
                "TKObject",
                &["TKRefreshing"],
                vec![
                    method(
                        "initWithParent:",
                        false,
                        vec![param("parent", class_ty("TKObject"))],
                        instancetype_nullable(),
                    ),
                    method(
                        "addSubview:",
                        false,
                        vec![param("view", class_ty("TKView"))],
                        TypeRef::void(),
                    ),
                    method("superview", false, vec![], class_ty_nullable("TKView")),
                    method("refresh", false, vec![], TypeRef::void()),
                ],
            ),
            class(
                "TKButton",
                "TKView",
                vec![
                    method("title", false, vec![], class_ty_nullable("NSString")),
                    method(
                        "setEnabled:",
                        false,
                        vec![param("enabled", boolean())],
                        TypeRef::void(),
                    ),
                    // THE PROTOCOL-QUALIFIED SLOT, both directions (`protocol-binding-surface-k89`,
                    // ADR-0055 §4b). k27 wrote these as a bare `id` because `extract-objc` dropped
                    // the qualifier; `protocol-qualifier-ir-k81` put it into the IR, and the two
                    // positions now render *differently* — which is the whole variance argument:
                    //
                    //   setDelegate:  (contravariant — what we accept)  → `TKButtonDelegate`
                    //   delegate      (covariant     — what we promise) → `TKButtonDelegate & NSObject`
                    //
                    // The setter's bare interface is what lets a plain JS object be installed as a
                    // delegate. The getter's intersection is what the value *is* (k88 mints it into
                    // its real ObjC class) — and without it, handing the result to any `id`-typed
                    // slot, which renders `NSObject`, would stop compiling.
                    method(
                        "setDelegate:",
                        false,
                        vec![param("delegate", qualified_id(&["TKButtonDelegate"]))],
                        TypeRef::void(),
                    ),
                    method(
                        "delegate",
                        false,
                        vec![],
                        nullable_qualified_id(&["TKButtonDelegate"]),
                    ),
                    // enum-alias-typing (ADR-0055 §6): a signed NS_ENUM param → the enum
                    // type (crosses uncoerced — enum → number is assignable), and an
                    // unsigned NS_OPTIONS return → the enum type (cast, since number is not
                    // assignable to an enum). Both same-framework enums import type-only
                    // from the barrel.
                    method(
                        "setAlignment:",
                        false,
                        vec![param("alignment", enum_alias("TKAlignment", "NSInteger"))],
                        TypeRef::void(),
                    ),
                    method("keyMask", false, vec![], enum_alias("TKKeyMask", "uint32")),
                ],
            ),
            class(
                "TKGizmo",
                "TKMissing",
                vec![method("reset", false, vec![], TypeRef::void())],
            ),
        ],
        // Two same-framework protocols, one inheriting the other (emit-protocol-k25): a
        // base with a required + an optional member, and a delegate that `extends` it with
        // an `id` param (→ runtime NSObject) and a cross-framework NSString return.
        protocols: vec![
            protocol(
                "TKRefreshing",
                &[],
                vec![method("refresh", false, vec![], TypeRef::void())],
                vec![method("refreshInterval", false, vec![], integer())],
            ),
            protocol(
                "TKButtonDelegate",
                // Same-framework inheritance (TKRefreshing, in-file) plus **cross-framework**
                // inheritance (NSCopying, owned by Foundation via the protocol registry) —
                // implements-and-param-typing-k27: the cross-fw base joins `extends` and
                // imports type-only from `@apianyware/foundation`.
                &["TKRefreshing", "NSCopying"],
                vec![
                    method(
                        "didClickButton:",
                        false,
                        vec![param("button", id())],
                        TypeRef::void(),
                    ),
                    // A protocol member typed by a proven enum → the enum type, imported
                    // type-only (an interface member carries no runtime value).
                    method(
                        "alignmentForButton:",
                        false,
                        vec![param("button", id())],
                        enum_alias("TKAlignment", "NSInteger"),
                    ),
                ],
                vec![method(
                    "titleForButton:",
                    false,
                    vec![param("button", id())],
                    class_ty_nullable("NSString"),
                )],
            ),
        ],
        enums: vec![
            // A signed NS_ENUM: verbatim members + values, negatives kept verbatim.
            enum_decl(
                "TKAlignment",
                "NSInteger",
                &[
                    ("TKAlignmentLeft", 0),
                    ("TKAlignmentCenter", 1),
                    ("TKAlignmentRight", 2),
                ],
            ),
            // An unsigned NS_OPTIONS: bit-flags plus a large all-bits value. `extract-objc`
            // resolves an unsigned constant from its u64 component, so a uint32 `~0` reaches
            // the IR as the positive 4294967295 (< 2^53, precise) — realistic input rendered
            // verbatim (the negative-i64 reinterpretation is a defensive net, unit-tested).
            enum_decl(
                "TKKeyMask",
                "uint32",
                &[
                    ("TKKeyMaskNone", 0),
                    ("TKKeyMaskShift", 1),
                    ("TKKeyMaskControl", 2),
                    ("TKKeyMaskOption", 4),
                    ("TKKeyMaskCommand", 8),
                    ("TKKeyMaskAll", 4294967295),
                ],
            ),
        ],
        structs: vec![],
        // Free functions (constants-and-functions-k28): the free-function dual of the method
        // bodies — a scalar dispatch, an object-arg + same-framework object return (+0 wrap),
        // a CF-Create-Rule +1 owned return, an enum param/return, a void, and a deferred
        // raw-pointer (NSError**-shape) function proving the frontier drops it.
        functions: vec![
            func(
                "TKComputeDistance",
                vec![param("x", double()), param("y", double())],
                double(),
            ),
            // Object arg (id → NSObject) + same-framework object return (+0 → __wrapRetained),
            // nullable → no `!`; TKView imports from TestKit's own barrel (call-time only).
            func(
                "TKViewForObject",
                vec![param("obj", id())],
                class_ty_nullable("TKView"),
            ),
            // CF Create Rule: a `Create` in the name → +1 owned (__wrapOwned), non-null `!`.
            func(
                "TKObjectCreate",
                vec![param("name", id())],
                class_ty("TKObject"),
            ),
            // Enum param crosses uncoerced; enum return casts; TKAlignment imported type-only.
            func(
                "TKClampAlignment",
                vec![param("a", enum_alias("TKAlignment", "NSInteger"))],
                enum_alias("TKAlignment", "NSInteger"),
            ),
            func("TKResetAll", vec![], TypeRef::void()),
            // A Swift-native (objc_exposed == false) SCALAR free function binds to its
            // call-by-name trampoline `aw_ts_swift_TestKit_TKSwiftScale` (ADR-0027,
            // fn-trampoline-spine-k53) — NOT the plain-C `aw_ts_fn_`. Same scalar body shape.
            swift_native_func("TKSwiftScale", vec![param("factor", double())], double()),
            // A Swift-native (objc_exposed == false) OBJECT-returning free function (object-
            // bridged-returns-k55, ADR-0061 §3): its call-by-name trampoline bridges the result
            // `as AnyObject?` and hands JS a uniform +1, so the `.ts` wraps `__wrapOwned` —
            // ALWAYS, unlike the CF-Create-Rule C path above (no `Create`/`Copy` in the name, yet
            // still owned because the trampoline's `passRetained` is the +1). Non-null → `!`.
            swift_native_func("TKSwiftMakeThing", vec![], class_ty("TKObject")),
            // Deferred: an NSError** out-param arrives as a raw Pointer (no NSError identity),
            // so it drops with every other raw pointer — the free-function Result<T> channel is
            // the error-model leaf (ADR-0058). Emits nothing.
            func(
                "TKReadInto",
                vec![param("err", ty(TypeRefKind::Pointer))],
                boolean(),
            ),
        ],
        // Constants (constants-and-functions-k28, ADR-0055 §6): a pointer-valued NSString
        // global (owned by Foundation → read + wrapped borrowed), a CFSTR macro (built from
        // its literal, wrapped owned), a scalar global, and an enum-typed global (cast +
        // type-only import).
        constants: vec![
            constant("TKDefaultFontName", class_ty("NSString")),
            cfstr("TKGreeting", "Hello, TestKit"),
            constant("TKDefaultTimeout", double()),
            constant("TKDefaultAlignment", enum_alias("TKAlignment", "NSInteger")),
        ],
        class_annotations: vec![],
        patterns: vec![],
        // The NSError out-param enrichment relation (error-model-k29): the two TKObject
        // `…error:` selectors the analysis stage classified as ErrorPattern::ErrorOutParam.
        // This is the cross-target source of truth every emitter keys Result routing off
        // (ADR-0058); without it the methods would defer as raw pointers.
        enrichment: Some(EnrichmentData {
            convenience_error_methods: vec![
                ClassSelectorEntry {
                    class: "TKObject".into(),
                    selector: "objectFromFile:error:".into(),
                },
                ClassSelectorEntry {
                    class: "TKObject".into(),
                    selector: "writeToFile:error:".into(),
                },
            ],
            ..Default::default()
        }),
        verification: None,
    }
}

/// A constant read through the addon (pointer-valued object global, or scalar/enum global) —
/// no `macro_value`, so it is fetched by its C symbol at module load (ADR-0055 §6).
fn constant(name: &str, constant_type: TypeRef) -> Constant {
    Constant {
        name: name.into(),
        constant_type,
        array_element: None,
        source: None,
        provenance: None,
        doc_refs: None,
        macro_value: None,
        objc_exposed: true,
    }
}

/// A CFSTR-macro constant — a compile-time `NSString` (no exported symbol), built from the
/// embedded literal and wrapped owned (+1) at module load.
fn cfstr(name: &str, value: &str) -> Constant {
    Constant {
        name: name.into(),
        constant_type: class_ty("NSString"),
        array_element: None,
        source: None,
        provenance: None,
        doc_refs: None,
        macro_value: Some(value.into()),
        objc_exposed: true,
    }
}

fn func(name: &str, params: Vec<Param>, return_type: TypeRef) -> Function {
    Function {
        name: name.into(),
        params,
        return_type,
        inline: false,
        variadic: false,
        source: None,
        provenance: None,
        doc_refs: None,
        objc_exposed: true,
        swift_fn: None,
    }
}

/// A Swift-native (`objc_exposed == false`) free function carrying `swift_fn` metadata — the
/// residual reached only by a call-by-name trampoline (ADR-0027). A scalar one binds to
/// `aw_ts_swift_<Module>_<name>` (fn-trampoline-spine-k53).
fn swift_native_func(name: &str, params: Vec<Param>, return_type: TypeRef) -> Function {
    Function {
        objc_exposed: false,
        swift_fn: Some(apianyware_types::ir::SwiftFnInfo::default()),
        ..func(name, params, return_type)
    }
}

fn crate_root() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR"))
}

fn golden_dir() -> PathBuf {
    crate_root().join("tests").join("golden")
}

fn golden_foundation_dir() -> PathBuf {
    crate_root().join("tests").join("golden-foundation")
}

#[test]
fn testkit_snapshot_matches_golden() {
    let fw = build_testkit_framework();
    // The whole-program registries the CLI pre-pass builds: NSString is owned by Foundation
    // (class references route to its module), and NSCopying is a Foundation-owned protocol
    // (so TKButtonDelegate's cross-framework `extends NSCopying` resolves to its module). The
    // enum registry stays empty — TestKit's own enums seed from `fw.enums`.
    let mut registry = ClassRegistry::new();
    registry.insert("NSString", "foundation");
    let mut protocol_registry = ProtocolRegistry::new();
    protocol_registry.insert("NSCopying", "foundation");
    let emitter = TsEmitter::with_registries(
        registry,
        EnumRegistry::new(),
        protocol_registry,
        BTreeSet::new(),
    );

    let tmp = tempfile::tempdir().unwrap();
    emitter.emit_framework(&fw, tmp.path()).unwrap();

    GoldenTest::new(&golden_dir(), "typescript")
        .assert_matches(tmp.path())
        .unwrap();
}

/// Curated subset of real Foundation files for golden comparison — the barrel, a
/// short inheritance chain (`NSString`/`NSMutableString`), and a couple of collection /
/// value heavyweights, each with its paired `.d.ts`. Paths are relative to the
/// emitter's output root. A representative slice, not all ~277 class files.
const FOUNDATION_GOLDEN_FILES: &[&str] = &[
    "foundation/index.ts",
    "foundation/nsstring.ts",
    "foundation/nsstring.d.ts",
    "foundation/nsmutablestring.ts",
    "foundation/nsmutablestring.d.ts",
    "foundation/nsarray.ts",
    "foundation/nsarray.d.ts",
    "foundation/nsvalue.ts",
    "foundation/nsvalue.d.ts",
];

/// Load one enriched IR framework from the per-family spec triad, or `None` if it is
/// not present locally (the IR is gitignored). Mirrors the sbcl loader — reads via the
/// machine codec.
fn load_enriched_framework(name: &str) -> Option<Framework> {
    let api_root = crate_root()
        .parent() // emit-typescript → tools
        .and_then(|p| p.parent()) // tools → typescript
        .and_then(|p| p.parent()) // typescript → targets
        .and_then(|p| p.parent()) // targets → project root
        .map(|p| p.join("platforms").join("macos").join("api"))?;
    let framework_path = api_root.join(name).join("resolved.kdl");
    if !framework_path.exists() {
        return None;
    }
    apianyware_spec_format::machine::read_framework(&framework_path).ok()
}

#[test]
fn foundation_subset_matches_golden() {
    // Real-IR layer: load enriched Foundation, emit, compare the curated subset. Skips
    // as-pass when the gitignored IR is absent (CI without a regeneration step) or the
    // golden subset has not been bootstrapped yet.
    let foundation = match load_enriched_framework("Foundation") {
        Some(fw) => fw,
        None => {
            eprintln!(
                "SKIP foundation_subset_matches_golden: Foundation enriched IR not found \
                 (gitignored — run the analysis pipeline, then UPDATE_GOLDEN=1 to bootstrap)"
            );
            return;
        }
    };
    if !golden_foundation_dir().exists() && std::env::var("UPDATE_GOLDEN").as_deref() != Ok("1") {
        eprintln!("SKIP foundation_subset_matches_golden: typescript goldens not bootstrapped yet");
        return;
    }

    // Foundation is a base framework, so its own class set resolves its same-framework
    // parents; the registries over `&[&foundation]` match what the CLI builds for it. The
    // protocol registry is load-bearing for conformed-protocol required-method flattening
    // (`protocol-required-method-flattening-k102`): `class_surface::bound_methods` reads
    // `ProtocolRegistry::conformance_closure`/`is_required_method` directly (no same-framework
    // fallback the way `is_known`/`module_for` get one), so a `TsEmitter::with_registry` call
    // (protocol registry defaulted empty) would silently flatten nothing, even for entirely
    // same-framework conformances like `NSString <NSCoding>` — this is the real, from-frameworks
    // registry the generate CLI threads in, so this golden actually exercises the surface.
    let emitter = TsEmitter::with_registries(
        ClassRegistry::from_framework_refs(&[&foundation]),
        EnumRegistry::new(),
        ProtocolRegistry::from_framework_refs(&[&foundation]),
        apianyware_emit_typescript::class_graph::synthetic_init_blocklist(&[&foundation]),
    );
    let tmp = tempfile::tempdir().unwrap();
    let result = emitter.emit_framework(&foundation, tmp.path()).unwrap();
    // Lower bound, not an exact count (SDK-drift tolerant); the de-duplicated Foundation
    // is ~277 classes (the k38 overlay-name unification).
    assert!(
        result.classes_emitted >= 270,
        "Foundation should emit 270+ classes (got {})",
        result.classes_emitted
    );

    GoldenTest::new(&golden_foundation_dir(), "typescript")
        .assert_subset_matches(tmp.path(), FOUNDATION_GOLDEN_FILES)
        .unwrap();
}
