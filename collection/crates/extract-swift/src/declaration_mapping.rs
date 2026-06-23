//! Map ABIRoot nodes to IR types.
//!
//! Walks the ABIRoot tree and converts Swift declarations (classes, structs,
//! enums, protocols, functions, properties) into the shared IR types with
//! `source: SwiftInterface`.

use apianyware_types::{
    ir,
    provenance::{Availability, DeclarationSource, DocRefs, SourceProvenance},
    skipped_symbol_reason,
};

use crate::abi_types::{AbiDocument, AbiNode};
use crate::type_mapping::map_swift_type;

/// Map an entire ABIRoot document to an IR [`ir::Framework`].
pub fn map_abi_to_framework(doc: &AbiDocument, sdk_version: &str) -> ir::Framework {
    let root = &doc.root;
    let mut classes = Vec::new();
    let mut protocols = Vec::new();
    let mut enums = Vec::new();
    let mut structs = Vec::new();
    let mut functions = Vec::new();
    let mut constants = Vec::new();
    let mut skipped_symbols = Vec::new();

    let is_overlay = is_cross_import_overlay(&root.name);

    for child in &root.children {
        let decl_kind = child.decl_kind.as_deref().unwrap_or("");

        // Drop top-level type declarations re-emitted from imported modules.
        // `swift-api-digester -dump-sdk -module X` lists every external type
        // X extends as a top-level `Class`/`Protocol`/`Struct`/`Enum` whose
        // `moduleName` points back at the owning module (e.g. `Sequence` →
        // `Swift`, `DataFrame` → `TabularData`); the children are X's
        // extension members. Treating those as if X owned them caused the
        // resolve pass to propagate `mapAnnotations(_:)` /
        // `mapFeatures(_:)` (CreateMLComponents extensions on `Sequence`) to
        // every conforming class in the SDK — `SBElementArray` included.
        // Functions and Vars do not have this problem (they always carry the
        // owning module's name) so the filter only gates type decls.
        //
        // Exception: cross-import overlays (`_<A>_<B>` naming convention,
        // e.g. `_RealityKit_SwiftUI`) have their entire API surface as
        // foreign type decls — these are kept when `is_overlay` is true.
        if is_foreign_module_type_decl(child, &root.name, is_overlay) {
            continue;
        }

        match decl_kind {
            "Class" => {
                if let Some(class) = map_class(child) {
                    classes.push(class);
                }
            }
            "Struct" => {
                if let Some(s) = map_struct(child) {
                    structs.push(s);
                }
            }
            "Enum" => {
                if let Some(e) = map_enum(child) {
                    enums.push(e);
                }
            }
            "Protocol" => {
                if let Some(p) = map_protocol(child) {
                    protocols.push(p);
                }
            }
            "Func" => {
                if child.kind == "Function" {
                    match classify_usr(child) {
                        // Additive change (ADR-0026): Swift-native top-level
                        // functions are now RETAINED (carrying objc_exposed:
                        // false) so they reach the emitter to be trampolined,
                        // rather than being dropped under SWIFT_NATIVE.
                        // `map_top_level_function` stamps objc_exposed from the
                        // node's USR, so the Direct and SwiftNative arms coincide
                        // here — both retain.
                        UsrDisposition::Direct | UsrDisposition::SwiftNative => {
                            if let Some(f) = map_top_level_function(child) {
                                functions.push(f);
                            }
                        }
                        UsrDisposition::Skip(reason) => {
                            // Record with the printed name (e.g. `pointwiseMin(_:_:)`)
                            // so that Swift overloads with identical simple names become
                            // distinct `skipped_symbols` entries. Mirrors how extract-objc
                            // qualifies methods with their owner class.
                            skipped_symbols.push(ir::SkippedSymbol {
                                name: child.printed_name.clone(),
                                kind: "function".to_string(),
                                reason: reason.to_string(),
                            });
                        }
                    }
                }
            }
            "Var" => {
                if child.kind == "Var" && !child.children.is_empty() {
                    match classify_usr(child) {
                        UsrDisposition::Direct | UsrDisposition::SwiftNative => {
                            if let Some(c) = map_top_level_constant(child) {
                                constants.push(c);
                            }
                        }
                        UsrDisposition::Skip(reason) => {
                            skipped_symbols.push(ir::SkippedSymbol {
                                name: child.name.clone(),
                                kind: "constant".to_string(),
                                reason: reason.to_string(),
                            });
                        }
                    }
                }
            }
            // Deferred ABI kinds (ADR-0026/D2): not yet walked, but recorded in
            // skipped_symbols so the drop is auditable rather than silent.
            // Recovery is a later frontier leaf.
            "Macro" | "TypeAlias" | "AssociatedType" => {
                skipped_symbols.push(ir::SkippedSymbol {
                    name: child.name.clone(),
                    kind: child.decl_kind.clone().unwrap_or_default().to_lowercase(),
                    reason: skipped_symbol_reason::DEFERRED_ABI_KIND.to_string(),
                });
            }
            // Import (and any other kind) is still ignored.
            _ => {}
        }
    }

    ir::Framework {
        format_version: "1.0".to_string(),
        checkpoint: "collected".to_string(),
        name: root.name.clone(),
        sdk_version: Some(sdk_version.to_string()),
        collected_at: Some(chrono::Utc::now().to_rfc3339()),
        depends_on: extract_imports(&root.children),
        skipped_symbols,
        classes,
        protocols,
        enums,
        structs,
        functions,
        constants,
        class_annotations: vec![],
        api_patterns: vec![],
        enrichment: None,
        verification: None,
    }
}

/// Three-way disposition of an ABI node, derived from its USR prefix. This is
/// the single classifier that subsumes the old `non_c_linkable_skip_reason()`
/// (ADR-0026): it decides retain-vs-skip **and** yields the `objc_exposed`
/// fact, so the USR-prefix knowledge lives in exactly one place.
enum UsrDisposition {
    /// Directly reachable through the ObjC/C runtime (clang `c:@F@`, `c:@`,
    /// `So…` cursors, or a missing USR). Retain with `objc_exposed: true`.
    Direct,
    /// Swift-native (`s:` USR): reachable only via the Swift ABI. Retain with
    /// `objc_exposed: false` so the emitter trampolines it downstream.
    SwiftNative,
    /// Unrepresentable: no dylib symbol exists. Do not retain; record in
    /// `skipped_symbols` with `reason`.
    Skip(&'static str),
}

/// Classify a declaration node by its USR prefix.
///
/// The Swift API digester stamps declarations with Unified Symbol Resolution
/// identifiers whose prefix identifies the producing cursor:
///
/// - `s:…` — Swift-mangled USR: declaration native to the Swift module,
///   reachable only via the Swift ABI. **Swift-native** → retain & trampoline.
///   (An `@objc`-annotated Swift declaration instead carries a clang `c:` USR
///   such as `c:@M@Probe@objc(cs)Foo` — so it classifies as `Direct`, ADR-0026.)
/// - `c:@F@<name>` — clang `FunctionDecl` cursor: a real C function
///   re-exported from the clang-imported module. **Direct.**
/// - `c:@<Name>` — clang `VarDecl` / enum cursor. **Direct.**
/// - `c:@macro@…` — clang preprocessor macro cursor. The C compiler inlines
///   `#define` values at use sites and emits no dylib symbol, so any FFI
///   binding that references the name will fail at load time with
///   `get-ffi-obj: could not find export from foreign library`. **Skip.**
/// - `c:@Ea@<dummy>@<Member>` — member of an *anonymous* enum. The second
///   USR segment is libclang's synthetic disambiguator for enums with no
///   tag (conventionally the first member's name). **Skip.** The C compiler
///   inlines enum members' integer values at every use site, so they never
///   receive a dylib symbol. Members of *named* enums use the
///   `c:@E@<Enum>@<Member>` shape and reach the IR through the dedicated
///   `Enum` → `EnumElement` mapping path, not the top-level `Var` / `Func`
///   cursors classified here.
/// - `c:@EA@<typedef>@<Member>` — same as above for the typedef'd anonymous
///   enum shape (`typedef enum { … } Name_t`). The second segment is the
///   typedef name. **Skip** for the same reason.
/// - `So<mangled>` — clang-imported Obj-C declaration. **Direct** (linkable via
///   the Obj-C runtime; Obj-C extraction itself lives in `extract-objc`).
///
/// Nodes without a USR are treated as `Direct` — missing metadata is not
/// evidence of non-linkability, and every real digester node carries one.
/// New USR families discovered in future SDK releases should be added here
/// so that this stays the single source of truth for both the skip filter and
/// the `objc_exposed` fact.
fn classify_usr(node: &AbiNode) -> UsrDisposition {
    let Some(usr) = node.usr.as_deref() else {
        return UsrDisposition::Direct;
    };
    if usr.starts_with("s:") {
        UsrDisposition::SwiftNative
    } else if usr.starts_with("c:@macro@") {
        UsrDisposition::Skip(skipped_symbol_reason::PREPROCESSOR_MACRO)
    } else if usr.starts_with("c:@Ea@") || usr.starts_with("c:@EA@") {
        UsrDisposition::Skip(skipped_symbol_reason::ANONYMOUS_ENUM_MEMBER)
    } else {
        UsrDisposition::Direct
    }
}

/// The `objc_exposed` fact for a node: true unless the node is Swift-native
/// (`s:` USR). `Direct` and `Skip` nodes are both ObjC/C-cursor'd; only
/// `SwiftNative` is `false`. (Skip nodes are never retained, so their value is
/// moot — but computing it uniformly keeps the rule in one place.)
fn objc_exposed_of(node: &AbiNode) -> bool {
    !matches!(classify_usr(node), UsrDisposition::SwiftNative)
}

/// The ObjC runtime class name for an ObjC-bridged class node, recovered from
/// its clang USR.
///
/// The Swift overlay renames many ObjC classes (NSScanner → Scanner,
/// NSURLSession → URLSession, NSFileHandle → FileHandle, …) but the clang USR —
/// the prefix form `c:objc(cs)NSScanner` or the @objc-Swift infixed form
/// `c:@M@<module>@objc(cs)NSScanner` (see [`classify_usr`]) — preserves the
/// runtime identity. Keying the IR class on this name lets the by-name
/// Swift↔ObjC merge ([`crate::merge`]) unify the overlay declaration with its
/// clang twin, instead of producing a *duplicate* class whose emitted
/// `register-objc-class` would bake a name (`"Scanner"`) that no live object
/// ever reports — leaving the overlay's Swift-native methods unreachable through
/// the natural construct/auto-wrap paths.
///
/// Returns `None` for a genuinely Swift-native class (`s:` USR — no ObjC runtime
/// name); the caller keeps the Swift name, as there is no ObjC twin to unify with.
fn objc_runtime_class_name(node: &AbiNode) -> Option<String> {
    let usr = node.usr.as_deref()?;
    usr.rsplit_once("objc(cs)")
        .map(|(_, name)| name.to_string())
        .filter(|name| !name.is_empty())
}

/// True iff `framework_name` follows Apple's cross-import overlay convention
/// `_<ModuleA>_<ModuleB>[...]`: leading underscore, then ≥2 non-empty
/// underscore-free tokens. Excludes plain underscore-prefixed private
/// modules such as `_LocationEssentials` (no internal underscore).
fn is_cross_import_overlay(framework_name: &str) -> bool {
    let Some(body) = framework_name.strip_prefix('_') else {
        return false;
    };
    let parts: Vec<&str> = body.split('_').collect();
    parts.len() >= 2 && parts.iter().all(|p| !p.is_empty())
}

/// Detect a top-level type declaration that the digester re-emitted from an
/// imported module purely as a container for the current framework's
/// extension members.
///
/// Returns true when `node` is a `Class`/`Protocol`/`Struct`/`Enum` whose
/// `moduleName` is set to a value other than `framework_name` AND the
/// framework is not a cross-import overlay.
///
/// For cross-import overlays (`_<A>_<B>` naming convention, e.g.
/// `_RealityKit_SwiftUI`, `_AppIntents_SwiftUI`), foreign type decls ARE
/// the overlay's entire API surface — the bridged types carrying the
/// overlay's extension members — so they must be kept. For normal
/// frameworks, foreign type decls are spurious extension containers whose
/// children would be mis-attributed to the foreign type if kept.
fn is_foreign_module_type_decl(node: &AbiNode, framework_name: &str, is_overlay: bool) -> bool {
    let is_type_decl = matches!(
        node.decl_kind.as_deref(),
        Some("Class") | Some("Protocol") | Some("Struct") | Some("Enum")
    );
    if !is_type_decl {
        return false;
    }
    match node.module_name.as_deref() {
        None => false,                           // missing data: keep
        Some(m) if m == framework_name => false, // native: keep
        Some(_) => !is_overlay,                  // foreign: drop unless overlay
    }
}

// ---------------------------------------------------------------------------
// Class mapping
// ---------------------------------------------------------------------------

fn map_class(node: &AbiNode) -> Option<ir::Class> {
    let superclass = node
        .superclass_names
        .first()
        .map(|s| extract_simple_name(s))
        .unwrap_or_default();

    let protocols: Vec<String> = node
        .conformances
        .iter()
        .filter(|c| !is_stdlib_conformance(&c.name))
        .map(|c| c.name.clone())
        .collect();

    let mut methods = Vec::new();
    let mut properties = Vec::new();

    for child in &node.children {
        match child.decl_kind.as_deref() {
            Some("Constructor") => {
                if let Some(m) = map_constructor(child) {
                    methods.push(m);
                }
            }
            Some("Func") => {
                if let Some(m) = map_method(child) {
                    methods.push(m);
                }
            }
            Some("Var") => {
                if let Some(p) = map_property(child) {
                    properties.push(p);
                }
            }
            _ => {}
        }
    }

    // Key on the ObjC runtime name (NSScanner), not the Swift overlay name (Scanner),
    // so the by-name Swift↔ObjC merge unifies this overlay class with its clang twin
    // rather than duplicating it (see `objc_runtime_class_name`). When the overlay
    // *renamed* the class, keep its Swift name in `swift_name` so the Swift trampoline
    // can spell a type the obsoleted runtime name won't compile as. Swift-native
    // classes keep their Swift name and need no `swift_name`.
    let runtime_name = objc_runtime_class_name(node);
    let swift_name = match &runtime_name {
        Some(rt) if *rt != node.name => Some(node.name.clone()),
        _ => None,
    };
    Some(ir::Class {
        name: runtime_name.unwrap_or_else(|| node.name.clone()),
        superclass,
        protocols,
        properties,
        methods,
        category_methods: vec![],
        swift_attributes: node.decl_attributes.clone(),
        ancestors: vec![],
        all_methods: vec![],
        all_properties: vec![],
        objc_exposed: objc_exposed_of(node),
        swift_name,
    })
}

// ---------------------------------------------------------------------------
// Protocol mapping
// ---------------------------------------------------------------------------

fn map_protocol(node: &AbiNode) -> Option<ir::Protocol> {
    let inherits: Vec<String> = node
        .conformances
        .iter()
        .filter(|c| !is_stdlib_conformance(&c.name))
        .map(|c| c.name.clone())
        .collect();

    let mut required_methods = Vec::new();
    let mut optional_methods = Vec::new();
    let mut properties = Vec::new();

    for child in &node.children {
        match child.decl_kind.as_deref() {
            Some("Func") => {
                if let Some(m) = map_method(child) {
                    // Swift protocols mark required methods with `protocolReq: true`.
                    // In Swift, all protocol methods are required unless marked @optional
                    // (which only applies to @objc protocols).
                    if child.protocol_req {
                        required_methods.push(m);
                    } else {
                        optional_methods.push(m);
                    }
                }
            }
            Some("Constructor") => {
                if let Some(m) = map_constructor(child) {
                    required_methods.push(m);
                }
            }
            Some("Var") => {
                if let Some(p) = map_property(child) {
                    properties.push(p);
                }
            }
            _ => {}
        }
    }

    Some(ir::Protocol {
        name: node.name.clone(),
        inherits,
        required_methods,
        optional_methods,
        properties,
        source: Some(DeclarationSource::SwiftInterface),
        provenance: build_provenance(node),
        doc_refs: build_doc_refs(node),
        objc_exposed: objc_exposed_of(node),
    })
}

// ---------------------------------------------------------------------------
// Enum mapping
// ---------------------------------------------------------------------------

fn map_enum(node: &AbiNode) -> Option<ir::Enum> {
    let mut values = Vec::new();

    for (index, child) in node.children.iter().enumerate() {
        if child.decl_kind.as_deref() == Some("EnumElement") {
            values.push(ir::EnumValue {
                name: child.name.clone(),
                // Swift enums don't have integer raw values by default.
                // Use index as a synthetic ordinal.
                value: index as i64,
            });
        }
    }

    // Swift enums without cases (e.g., namespace-like enums) are still valid.
    Some(ir::Enum {
        name: node.name.clone(),
        // Swift enums don't expose an underlying integer type in ABIRoot.
        // Use a sentinel to indicate a Swift enum.
        enum_type: apianyware_types::type_ref::TypeRef {
            nullable: false,
            kind: apianyware_types::type_ref::TypeRefKind::Primitive {
                name: "swift_enum".to_string(),
            },
        },
        values,
        source: Some(DeclarationSource::SwiftInterface),
        provenance: build_provenance(node),
        doc_refs: build_doc_refs(node),
        objc_exposed: objc_exposed_of(node),
    })
}

// ---------------------------------------------------------------------------
// Struct mapping
// ---------------------------------------------------------------------------

fn map_struct(node: &AbiNode) -> Option<ir::Struct> {
    let mut fields = Vec::new();
    let mut methods = Vec::new();

    for child in &node.children {
        match child.decl_kind.as_deref() {
            // `Var` children with a type are stored fields.
            Some("Var") if !child.children.is_empty() => {
                let type_node = &child.children[0];
                fields.push(ir::StructField {
                    name: child.name.clone(),
                    field_type: map_swift_type(type_node),
                });
            }
            // Value-type initializers are the population-B root producer (D2):
            // an `init` trampoline returns a boxed handle of the struct type.
            Some("Constructor") => {
                if let Some(m) = map_constructor(child) {
                    methods.push(m);
                }
            }
            // Value-type methods are the population-B receiver methods (D1/D3):
            // recovered here so the receiver-handle trampoline can unbox the
            // struct and call them. Previously dropped — a Swift struct's methods
            // never reached the IR at all.
            Some("Func") => {
                if let Some(m) = map_method(child) {
                    methods.push(m);
                }
            }
            _ => {}
        }
    }

    Some(ir::Struct {
        name: node.name.clone(),
        fields,
        methods,
        source: Some(DeclarationSource::SwiftInterface),
        provenance: build_provenance(node),
        doc_refs: build_doc_refs(node),
        objc_exposed: objc_exposed_of(node),
    })
}

// ---------------------------------------------------------------------------
// Method mapping
// ---------------------------------------------------------------------------

/// Build the Swift-native call metadata for a method/initializer node, mirroring
/// `map_top_level_function`'s `swift_fn` population (ADR-0027 / leaf 020).
///
/// Returns `None` for an `objc_exposed` (ObjC/C-cursor'd) decl — it binds via
/// `msgSend` and needs no trampoline facts, and `None` is skip-serialized so the
/// ObjC golden JSON is unchanged. Returns `Some` for a Swift-native (`s:` USR)
/// decl, carrying the `throws`/`async`/generic facts the receiver-handle codegen
/// needs but the lossy `TypeRef` normalization drops.
fn build_swift_fn(node: &AbiNode) -> Option<ir::SwiftFnInfo> {
    if objc_exposed_of(node) {
        return None;
    }
    Some(ir::SwiftFnInfo {
        throwing: node.throwing,
        // `node.is_async` is the (currently never-emitted) digester `async`
        // field; OR it with the mangled-name `Ya` marker so async is actually
        // detected (swift-api-digester surfaces async only in the mangling).
        is_async: node.is_async || node_is_async(node),
        is_generic: node.generic_sig.is_some(),
        // Receiver mutation kind for value-type methods (D3). `None` for inits
        // and any decl the digester leaves unmarked.
        self_kind: node.func_self_kind.clone(),
    })
}

/// Map a Swift function/method node to an IR [`ir::Method`].
fn map_method(node: &AbiNode) -> Option<ir::Method> {
    // Children: [0] = return type, [1..] = parameters
    if node.children.is_empty() {
        return None;
    }

    let return_type = map_swift_type(&node.children[0]);
    let params = map_method_params(node);

    // Build a selector-like name from the Swift printed name.
    let selector = swift_name_to_selector(&node.printed_name);

    Some(ir::Method {
        selector,
        class_method: node.is_static,
        init_method: false,
        params,
        return_type,
        deprecated: false,
        variadic: false,
        source: Some(DeclarationSource::SwiftInterface),
        provenance: build_provenance(node),
        doc_refs: build_doc_refs(node),
        origin: None,
        category: None,
        overrides: None,
        returns_retained: None,
        satisfies_protocol: None,
        objc_exposed: objc_exposed_of(node),
        swift_fn: build_swift_fn(node),
    })
}

/// Map a Swift constructor node to an IR [`ir::Method`] with `init_method: true`.
fn map_constructor(node: &AbiNode) -> Option<ir::Method> {
    if node.children.is_empty() {
        return None;
    }

    // Constructor children: [0] = return type (Self), [1..] = parameters
    let return_type = map_swift_type(&node.children[0]);
    let params = map_method_params(node);

    let selector = swift_name_to_selector(&node.printed_name);

    Some(ir::Method {
        selector,
        class_method: false,
        init_method: true,
        params,
        return_type,
        deprecated: false,
        variadic: false,
        source: Some(DeclarationSource::SwiftInterface),
        provenance: build_provenance(node),
        doc_refs: build_doc_refs(node),
        origin: None,
        category: None,
        overrides: None,
        returns_retained: None,
        satisfies_protocol: None,
        objc_exposed: objc_exposed_of(node),
        swift_fn: build_swift_fn(node),
    })
}

/// Extract parameters from a function/constructor node.
///
/// In the ABIRoot tree, children[0] is the return type and children[1..] are
/// the parameter types. Parameter names come from the `printedName` of the
/// parent (e.g., `"process(input:)"` → param name `"input"`).
fn map_method_params(node: &AbiNode) -> Vec<ir::Param> {
    let param_names = extract_param_names(&node.printed_name);
    let param_types = &node.children[1..]; // skip return type

    param_types
        .iter()
        .enumerate()
        .map(|(i, type_node)| {
            let name = param_names
                .get(i)
                .cloned()
                .unwrap_or_else(|| format!("param{i}"));
            ir::Param {
                name,
                param_type: map_swift_type(type_node),
            }
        })
        .collect()
}

// ---------------------------------------------------------------------------
// Property mapping
// ---------------------------------------------------------------------------

fn map_property(node: &AbiNode) -> Option<ir::Property> {
    if node.children.is_empty() {
        return None;
    }

    let type_node = &node.children[0];
    let property_type = map_swift_type(type_node);

    // Read-only if: isLet, or only has a getter accessor (no setter)
    let has_setter = node
        .accessors
        .iter()
        .any(|a| a.accessor_kind.as_deref() == Some("set"));
    let readonly = node.is_let || !has_setter;

    // Static properties are class properties
    let class_property = node.is_static;

    Some(ir::Property {
        name: node.name.clone(),
        property_type,
        readonly,
        class_property,
        // `(copy)` is an ObjC property attribute; Swift bridged properties
        // surface as ObjC overrides which carry the attribute on the ObjC
        // side. Default-false here; merge keeps the ObjC value.
        is_copy: false,
        deprecated: false,
        source: Some(DeclarationSource::SwiftInterface),
        provenance: build_provenance(node),
        doc_refs: build_doc_refs(node),
        origin: None,
        objc_exposed: objc_exposed_of(node),
    })
}

// ---------------------------------------------------------------------------
// Top-level function / constant mapping
// ---------------------------------------------------------------------------

/// Detect an `async` function from its Swift **mangled name**, since
/// `swift-api-digester` (json_format_version 8) does not emit a structured
/// `async` field (it *does* emit `throwing`). The mangling encodes effect
/// markers right before the final function operator `F`: async is `Ya`, throws is
/// `K`, so an async free function's symbol ends in `YaF` (async) or `YaKF` (async
/// throws) — e.g. `URLSession.data(from:)` is `…tYaKF`. Both the `usr` and
/// `mangled_name` carry the suffix; check whichever is present.
///
/// The check is anchored at the suffix to avoid a stray `Ya` mid-symbol producing
/// a false positive. It is forward-compatible: if a future digester populates the
/// `async` field, the caller OR-s that in (see `map_top_level_function`).
fn mangled_is_async(symbol: &str) -> bool {
    symbol.ends_with("YaF") || symbol.ends_with("YaKF")
}

/// True when this node's mangled symbol marks it `async`.
fn node_is_async(node: &AbiNode) -> bool {
    node.mangled_name
        .as_deref()
        .or(node.usr.as_deref())
        .is_some_and(mangled_is_async)
}

fn map_top_level_function(node: &AbiNode) -> Option<ir::Function> {
    if node.children.is_empty() {
        return None;
    }

    let return_type = map_swift_type(&node.children[0]);
    let param_names = extract_param_names(&node.printed_name);
    let params: Vec<ir::Param> = node.children[1..]
        .iter()
        .enumerate()
        .map(|(i, type_node)| {
            let name = param_names
                .get(i)
                .cloned()
                .unwrap_or_else(|| format!("param{i}"));
            ir::Param {
                name,
                param_type: map_swift_type(type_node),
            }
        })
        .collect();

    Some(ir::Function {
        name: node.name.clone(),
        params,
        return_type,
        inline: false,
        variadic: false,
        source: Some(DeclarationSource::SwiftInterface),
        provenance: build_provenance(node),
        doc_refs: build_doc_refs(node),
        objc_exposed: objc_exposed_of(node),
        // Carry the call-by-name facts the trampoline codegen needs (ADR-0027 /
        // leaf 040/020) — `throws`/`async`/generic that the Swift→ObjC TypeRef
        // normalization drops. Only Swift-native top-level functions reach here.
        swift_fn: Some(ir::SwiftFnInfo {
            throwing: node.throwing,
            // `node.is_async` is the (currently never-emitted) `async` JSON field;
            // OR it with the mangled-name marker so async is actually detected
            // (swift-api-digester surfaces async only in the mangling). Without
            // this an async free function would classify as *bindable* and the
            // trampoline codegen would emit a synchronous `return foo(…)` call that
            // does not compile (ADR-0027 / racket-trampoline spec §3a kick-back).
            is_async: node.is_async || node_is_async(node),
            is_generic: node.generic_sig.is_some(),
            // Free functions have no `self` receiver.
            self_kind: None,
        }),
    })
}

fn map_top_level_constant(node: &AbiNode) -> Option<ir::Constant> {
    if node.children.is_empty() {
        return None;
    }

    let type_node = &node.children[0];
    Some(ir::Constant {
        name: node.name.clone(),
        constant_type: map_swift_type(type_node),
        source: Some(DeclarationSource::SwiftInterface),
        provenance: build_provenance(node),
        doc_refs: build_doc_refs(node),
        macro_value: None,
        objc_exposed: objc_exposed_of(node),
    })
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Build provenance from an ABI node's availability attributes.
fn build_provenance(node: &AbiNode) -> Option<SourceProvenance> {
    let availability = if node.intro_macos.is_some() {
        Some(Availability {
            introduced: node.intro_macos.clone(),
            deprecated: None,
        })
    } else {
        None
    };

    if availability.is_some() {
        Some(SourceProvenance {
            header: None, // Swift modules don't have header paths
            line: None,
            availability,
        })
    } else {
        None
    }
}

/// Build doc refs from an ABI node's USR.
fn build_doc_refs(node: &AbiNode) -> Option<DocRefs> {
    node.usr.as_ref().map(|usr| DocRefs {
        header_comment: None,
        apple_doc_url: None,
        usr: Some(usr.clone()),
    })
}

/// Extract import names from top-level nodes.
fn extract_imports(children: &[AbiNode]) -> Vec<String> {
    children
        .iter()
        .filter(|n| n.decl_kind.as_deref() == Some("Import"))
        .map(|n| n.name.clone())
        .filter(|name| !name.starts_with('_')) // Skip private imports
        .collect()
}

/// Convert a Swift printed name like `"process(input:count:)"` to a
/// selector-like string `"process:input:count:"`.
///
/// For Swift-only APIs, this produces a readable selector-style identifier
/// that downstream analysis can use.
pub fn swift_name_to_selector(printed_name: &str) -> String {
    // If no parentheses, it's a simple name (property, operator, etc.)
    let Some(paren_start) = printed_name.find('(') else {
        return printed_name.to_string();
    };

    let base = &printed_name[..paren_start];
    let params_part = &printed_name[paren_start + 1..];
    let params_part = params_part.trim_end_matches(')');

    if params_part.is_empty() {
        // No parameters: `"doWork()"` → `"doWork"`
        return base.to_string();
    }

    // Split parameter labels: `"input:count:"` → ["input", "count"]
    let labels: Vec<&str> = params_part.split(':').filter(|s| !s.is_empty()).collect();

    // Build ObjC-style selector: `"processWithInput:count:"` for `"process(input:count:)"`
    // Simplified: just use `"base(label1:label2:)"` format as the selector
    format!(
        "{}({})",
        base,
        labels.iter().map(|l| format!("{l}:")).collect::<String>()
    )
}

/// Extract parameter names from a printed name like `"process(input:count:)"`.
fn extract_param_names(printed_name: &str) -> Vec<String> {
    let Some(paren_start) = printed_name.find('(') else {
        return vec![];
    };

    let params_part = &printed_name[paren_start + 1..];
    let params_part = params_part.trim_end_matches(')');

    params_part
        .split(':')
        .filter(|s| !s.is_empty())
        .map(|s| s.to_string())
        .collect()
}

/// Extract simple type name from a qualified name like `"TestFramework.Base"` → `"Base"`.
fn extract_simple_name(qualified: &str) -> String {
    qualified
        .rsplit('.')
        .next()
        .unwrap_or(qualified)
        .to_string()
}

/// Check if a conformance is a Swift stdlib conformance that we skip in the IR.
fn is_stdlib_conformance(name: &str) -> bool {
    matches!(
        name,
        "Copyable" | "Escapable" | "Sendable" | "SendableMetatype" | "BitwiseCopyable"
    )
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

#[cfg(test)]
mod tests {
    use super::*;
    use crate::abi_types::AbiDocument;
    use serde_json::json;

    // ------------------------------------------------------------------
    // is_cross_import_overlay boundary tests
    // ------------------------------------------------------------------

    #[test]
    fn is_cross_import_overlay_boundary_table() {
        assert!(
            is_cross_import_overlay("_RealityKit_SwiftUI"),
            "_RealityKit_SwiftUI should be an overlay"
        );
        assert!(
            is_cross_import_overlay("_AppIntents_SwiftUI"),
            "_AppIntents_SwiftUI should be an overlay"
        );
        assert!(
            is_cross_import_overlay("_SwiftData_CoreData"),
            "_SwiftData_CoreData should be an overlay"
        );
        assert!(
            is_cross_import_overlay("_WebKit_SwiftUI"),
            "_WebKit_SwiftUI should be an overlay"
        );
        assert!(
            !is_cross_import_overlay("_LocationEssentials"),
            "_LocationEssentials has no internal underscore — not an overlay"
        );
        assert!(
            !is_cross_import_overlay("CreateMLComponents"),
            "CreateMLComponents has no leading underscore — not an overlay"
        );
        assert!(
            !is_cross_import_overlay("CoreTransferable"),
            "CoreTransferable has no leading underscore — not an overlay"
        );
        assert!(
            !is_cross_import_overlay("Foundation"),
            "Foundation has no leading underscore — not an overlay"
        );
        assert!(
            !is_cross_import_overlay("_"),
            "bare underscore — empty body, not an overlay"
        );
        assert!(
            !is_cross_import_overlay("_Foo_"),
            "_Foo_ has a trailing empty token — not an overlay"
        );
    }

    // ------------------------------------------------------------------
    // Keep fixture A — overlay with a foreign Class (must be retained)
    // ------------------------------------------------------------------

    fn make_overlay_doc_with_foreign_class(
        framework: &str,
        class_name: &str,
        foreign_module: &str,
    ) -> AbiDocument {
        let value = json!({
            "ABIRoot": {
                "kind": "Root",
                "name": framework,
                "printedName": framework,
                "children": [
                    {
                        "kind": "TypeDecl",
                        "name": class_name,
                        "printedName": class_name,
                        "declKind": "Class",
                        "moduleName": foreign_module,
                        "usr": format!("s:{}{}C", foreign_module, class_name),
                        "isExternal": true,
                        "children": [
                            {
                                "kind": "Function",
                                "name": "components",
                                "printedName": "components()",
                                "declKind": "Func",
                                "moduleName": framework,
                                "isFromExtension": true,
                                "usr": format!("s:{}10componentsyyF", framework),
                                "children": [
                                    { "kind": "TypeNominal", "name": "Void", "printedName": "Swift.Void", "children": [] }
                                ]
                            }
                        ]
                    }
                ]
            }
        });
        serde_json::from_value(value).expect("build AbiDocument")
    }

    #[test]
    fn overlay_foreign_class_entity_is_kept() {
        // Keep fixture A: _RealityKit_SwiftUI with foreign Class `Entity`
        // (module_name: "RealityFoundation"). Must survive the filter.
        let doc = make_overlay_doc_with_foreign_class(
            "_RealityKit_SwiftUI",
            "Entity",
            "RealityFoundation",
        );
        let framework = map_abi_to_framework(&doc, "26.5");

        let class_names: Vec<&str> = framework.classes.iter().map(|c| c.name.as_str()).collect();
        assert!(
            class_names.contains(&"Entity"),
            "_RealityKit_SwiftUI overlay must retain foreign Class `Entity`; got {class_names:?}"
        );
    }

    // ------------------------------------------------------------------
    // Keep fixture B — zero-native overlay (must be retained)
    // ------------------------------------------------------------------

    #[test]
    fn overlay_zero_native_foreign_class_intent_parameter_is_kept() {
        // Keep fixture B: _AppIntents_SwiftUI has ZERO native type decls;
        // all nodes are foreign. `IntentParameter` (module: AppIntents)
        // must survive the filter.
        let doc = make_overlay_doc_with_foreign_class(
            "_AppIntents_SwiftUI",
            "IntentParameter",
            "AppIntents",
        );
        let framework = map_abi_to_framework(&doc, "26.5");

        let class_names: Vec<&str> = framework.classes.iter().map(|c| c.name.as_str()).collect();
        assert!(
            class_names.contains(&"IntentParameter"),
            "_AppIntents_SwiftUI overlay must retain foreign Class `IntentParameter`; got {class_names:?}"
        );
    }

    // ------------------------------------------------------------------
    // ObjC runtime class name recovered from the clang USR
    // (NSScanner → Scanner overlay rename; merge unification, k38)
    // ------------------------------------------------------------------

    fn make_doc_with_class(framework: &str, name: &str, usr: &str) -> AbiDocument {
        let value = json!({
            "ABIRoot": {
                "kind": "Root",
                "name": framework,
                "printedName": framework,
                "children": [
                    {
                        "kind": "TypeDecl",
                        "name": name,
                        "printedName": name,
                        "declKind": "Class",
                        "moduleName": framework,
                        "usr": usr,
                        "children": []
                    }
                ]
            }
        });
        serde_json::from_value(value).expect("build AbiDocument")
    }

    fn mapped_class_names(doc: &AbiDocument) -> Vec<String> {
        map_abi_to_framework(doc, "26.5")
            .classes
            .iter()
            .map(|c| c.name.clone())
            .collect()
    }

    #[test]
    fn objc_bridged_class_uses_runtime_name_from_usr() {
        // The Foundation Swift overlay renames NSScanner → Scanner, but the clang
        // USR (`c:objc(cs)NSScanner`) preserves the runtime identity. The IR must
        // key the class on the runtime name so the by-name Swift↔ObjC merge unifies
        // the overlay with its clang twin instead of emitting a duplicate
        // `Scanner` / `ns:scanner` class with a registration that no live object
        // matches (k38).
        let doc = make_doc_with_class("Foundation", "Scanner", "c:objc(cs)NSScanner");
        assert_eq!(
            mapped_class_names(&doc),
            vec!["NSScanner"],
            "Scanner must map to its ObjC runtime name NSScanner"
        );
    }

    #[test]
    fn objc_bridged_class_runtime_name_handles_objc_swift_infixed_usr() {
        // An @objc Swift class carries the infixed clang USR form
        // `c:@M@<module>@objc(cs)<Name>` (see `classify_usr`'s `c:@M@Probe@objc(cs)Foo`).
        let doc = make_doc_with_class("Probe", "Foo", "c:@M@Probe@objc(cs)NSFoo");
        assert_eq!(mapped_class_names(&doc), vec!["NSFoo"]);
    }

    #[test]
    fn objc_bridged_class_with_unrenamed_name_is_idempotent() {
        // A class the overlay does NOT rename (NSString) stays NSString.
        let doc = make_doc_with_class("Foundation", "NSString", "c:objc(cs)NSString");
        assert_eq!(mapped_class_names(&doc), vec!["NSString"]);
    }

    #[test]
    fn swift_native_class_keeps_its_swift_name() {
        // A genuinely Swift-native class (`s:` USR — no ObjC runtime name) keeps
        // its Swift name; there is no ObjC twin to unify with.
        let doc = make_doc_with_class("MyModule", "Widget", "s:8MyModule6WidgetC");
        assert_eq!(mapped_class_names(&doc), vec!["Widget"]);
    }

    // ------------------------------------------------------------------
    // async detection from the mangled name (no digester `async` field)
    // ------------------------------------------------------------------

    #[test]
    fn mangled_is_async_recognises_async_effect_suffix() {
        // Real `URLSession.data(from:)` USR — `async throws`, suffix `YaKF`.
        assert!(mangled_is_async(
            "s:So12NSURLSessionC10FoundationE4data4fromAC4DataV_So13NSURLResponseCtAC3URLV_tYaKF"
        ));
        // Async, non-throwing: suffix `YaF`.
        assert!(mangled_is_async("s:8MyModule5fetchSiyYaF"));
        // Sync throwing (`KF`) and plain sync (`F`) are NOT async.
        assert!(!mangled_is_async("s:8MyModule4riskySiyKF"));
        assert!(!mangled_is_async("s:8MyModule4pureSiyF"));
        // A stray `Ya` mid-symbol must not false-positive (anchored at suffix).
        assert!(!mangled_is_async("s:8MyModule3YapSiyF"));
    }

    fn async_func_node(usr: &str) -> AbiNode {
        // A top-level Swift-native async free function: a Func node with a single
        // return-type child and an async-marked USR. `swift-api-digester` emits no
        // `async` field, so detection must come from the mangling.
        serde_json::from_value(json!({
            "kind": "Function",
            "name": "fetch",
            "printedName": "fetch()",
            "declKind": "Func",
            "moduleName": "MyModule",
            "usr": usr,
            "children": [
                { "kind": "TypeNominal", "name": "Int", "printedName": "Swift.Int", "children": [] }
            ]
        }))
        .expect("build AbiNode")
    }

    #[test]
    fn top_level_async_function_sets_is_async_from_mangling() {
        // No `async` JSON field present (digester never emits one); the mangled USR
        // suffix `SiyYaF` is the only async signal. The mapped function must carry
        // `swift_fn.is_async = true` so the trampoline codegen defers it rather than
        // misclassifying it as a (non-compiling) synchronous call.
        let f = map_top_level_function(&async_func_node("s:8MyModule5fetchSiyYaF"))
            .expect("async free function maps");
        let info = f.swift_fn.expect("swift_fn populated");
        assert!(
            info.is_async,
            "async must be detected from the mangled name"
        );

        // A sync counterpart (same shape, `SiyF`) must stay non-async.
        let g = map_top_level_function(&async_func_node("s:8MyModule5fetchSiyF"))
            .expect("sync free function maps");
        assert!(!g.swift_fn.unwrap().is_async, "sync function is not async");
    }

    // ------------------------------------------------------------------
    // Swift-native method recovery: swift_fn on ir::Method (leaf 020)
    // ------------------------------------------------------------------

    /// A Swift method node (`Func` under a type) with a single return-type child
    /// and the given USR + printed name. `throwing`/effects are set by the
    /// caller via the JSON.
    fn swift_method_node(usr: &str, printed_name: &str, throwing: bool) -> AbiNode {
        swift_method_node_self(usr, printed_name, throwing, "NonMutating")
    }

    fn swift_method_node_self(
        usr: &str,
        printed_name: &str,
        throwing: bool,
        self_kind: &str,
    ) -> AbiNode {
        serde_json::from_value(json!({
            "kind": "Function",
            "name": printed_name.split('(').next().unwrap_or(printed_name),
            "printedName": printed_name,
            "declKind": "Func",
            "moduleName": "MyModule",
            "usr": usr,
            "throwing": throwing,
            "funcSelfKind": self_kind,
            "children": [
                { "kind": "TypeNominal", "name": "Int", "printedName": "Swift.Int", "children": [] }
            ]
        }))
        .expect("build method AbiNode")
    }

    #[test]
    fn swift_native_mutating_method_records_self_kind() {
        // D3: a `mutating` value-type method needs write-back in the trampoline,
        // so the receiver mutation kind must be recovered into the IR. `consuming
        // self` (handle would dangle) is deferred — both decisions need this fact.
        let m = map_method(&swift_method_node_self(
            "s:8MyModule6WidgetV6resizeyyF",
            "resize()",
            false,
            "Mutating",
        ))
        .expect("mutating method maps");
        let info = m.swift_fn.expect("swift_fn populated");
        assert_eq!(
            info.self_kind.as_deref(),
            Some("Mutating"),
            "mutating self-kind recovered for D3 write-back sizing"
        );
    }

    #[test]
    fn swift_native_method_carries_swift_fn_with_async_from_mangling() {
        // Swift-native (`s:` USR) async method. The digester emits no `async`
        // field, so async must be recovered from the `YaF` mangled suffix —
        // exactly as `map_top_level_function` does. Without it the method would
        // misclassify as a synchronous call and the trampoline codegen (030)
        // would emit a non-compiling `return recv.method(…)`.
        let m = map_method(&swift_method_node(
            "s:8MyModule3FooV5fetchSiyYaF",
            "fetch()",
            false,
        ))
        .expect("swift-native method maps");
        let info = m
            .swift_fn
            .expect("swift_fn populated for swift-native method");
        assert!(info.is_async, "async recovered from mangled `YaF` suffix");
        assert!(!info.throwing, "non-throwing");
    }

    #[test]
    fn swift_native_throwing_method_sets_throwing() {
        let m = map_method(&swift_method_node(
            "s:8MyModule3FooV4riskSiyKF",
            "risk()",
            true,
        ))
        .expect("swift-native throwing method maps");
        let info = m.swift_fn.expect("swift_fn populated");
        assert!(info.throwing, "throwing recovered from node.throwing");
        assert!(!info.is_async, "sync");
    }

    #[test]
    fn objc_exposed_method_has_no_swift_fn() {
        // An ObjC-exposed method (`c:` USR) binds directly via msgSend and needs
        // no trampoline metadata. `swift_fn` MUST be `None` so the skip-serialized
        // field keeps the ObjC golden JSON byte-identical (ADR-0026 discipline).
        let m = map_method(&swift_method_node("c:objc(cs)NSFoo(im)bar", "bar()", false))
            .expect("objc method maps");
        assert!(
            m.swift_fn.is_none(),
            "objc-exposed method must not carry swift_fn"
        );
    }

    fn swift_constructor_node(usr: &str, throwing: bool) -> AbiNode {
        serde_json::from_value(json!({
            "kind": "Constructor",
            "name": "init",
            "printedName": "init(value:)",
            "declKind": "Constructor",
            "moduleName": "MyModule",
            "usr": usr,
            "throwing": throwing,
            "children": [
                { "kind": "TypeNominal", "name": "Foo", "printedName": "MyModule.Foo", "children": [] },
                { "kind": "TypeNominal", "name": "Int", "printedName": "Swift.Int", "children": [] }
            ]
        }))
        .expect("build constructor AbiNode")
    }

    #[test]
    fn swift_native_constructor_is_init_method_with_swift_fn() {
        // The population-B root producer (D2): an `init` carries `init_method:
        // true` and the same swift_fn facts (a throwing init drives the
        // error-out producer shape).
        let m = map_constructor(&swift_constructor_node(
            "s:8MyModule3FooV5valueACSi_tcfc",
            true,
        ))
        .expect("constructor maps");
        assert!(m.init_method, "constructor is an initializer");
        let info = m
            .swift_fn
            .expect("swift_fn populated for swift-native init");
        assert!(info.throwing, "throwing init recovered");
    }

    // ------------------------------------------------------------------
    // Swift-native struct method/initializer recovery (leaf 020)
    // ------------------------------------------------------------------

    fn swift_struct_node() -> AbiNode {
        // A Swift-native value type with a field, an initializer, and a method.
        // Today `map_struct` reads only the `Var` field and silently drops the
        // `Constructor` + `Func` — the population-B (value-receiver) recovery hole.
        serde_json::from_value(json!({
            "kind": "TypeDecl",
            "name": "Widget",
            "printedName": "Widget",
            "declKind": "Struct",
            "moduleName": "MyModule",
            "usr": "s:8MyModule6WidgetV",
            "children": [
                {
                    "kind": "Var", "name": "size", "printedName": "size",
                    "declKind": "Var", "usr": "s:8MyModule6WidgetV4sizeSivp",
                    "children": [ { "kind": "TypeNominal", "name": "Int", "printedName": "Swift.Int", "children": [] } ]
                },
                {
                    "kind": "Constructor", "name": "init", "printedName": "init(size:)",
                    "declKind": "Constructor", "usr": "s:8MyModule6WidgetV4sizeACSi_tcfc",
                    "children": [
                        { "kind": "TypeNominal", "name": "Widget", "printedName": "MyModule.Widget", "children": [] },
                        { "kind": "TypeNominal", "name": "Int", "printedName": "Swift.Int", "children": [] }
                    ]
                },
                {
                    "kind": "Function", "name": "area", "printedName": "area()",
                    "declKind": "Func", "usr": "s:8MyModule6WidgetV4areaSiyF",
                    "children": [ { "kind": "TypeNominal", "name": "Int", "printedName": "Swift.Int", "children": [] } ]
                }
            ]
        }))
        .expect("build struct AbiNode")
    }

    #[test]
    fn swift_native_struct_recovers_methods_and_initializers() {
        let s = map_struct(&swift_struct_node()).expect("struct maps");
        // The field is still recovered.
        assert_eq!(s.fields.len(), 1, "field recovered");
        // The initializer + method are now recovered as methods (were dropped).
        assert_eq!(
            s.methods.len(),
            2,
            "struct constructor + func recovered as methods"
        );
        let init = s
            .methods
            .iter()
            .find(|m| m.init_method)
            .expect("initializer recovered");
        assert!(
            !init.objc_exposed,
            "swift-native struct init is not objc-exposed"
        );
        assert!(init.swift_fn.is_some(), "init carries swift_fn");
        let area = s
            .methods
            .iter()
            .find(|m| !m.init_method)
            .expect("instance method recovered");
        assert!(area.swift_fn.is_some(), "struct method carries swift_fn");
    }
}
