//! Map ABIRoot nodes to IR types.
//!
//! Walks the ABIRoot tree and converts Swift declarations (classes, structs,
//! enums, protocols, functions, properties) into the shared IR types with
//! `source: SwiftInterface`.

use apianyware_macos_types::{
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
        if is_foreign_module_type_decl(child, &root.name) {
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
                    if let Some(reason) = non_c_linkable_skip_reason(child) {
                        // Record with the printed name (e.g. `pointwiseMin(_:_:)`)
                        // so that Swift overloads with identical simple names become
                        // distinct `skipped_symbols` entries. Mirrors how extract-objc
                        // qualifies methods with their owner class.
                        skipped_symbols.push(ir::SkippedSymbol {
                            name: child.printed_name.clone(),
                            kind: "function".to_string(),
                            reason: reason.to_string(),
                        });
                    } else if let Some(f) = map_top_level_function(child) {
                        functions.push(f);
                    }
                }
            }
            "Var" => {
                if child.kind == "Var" && !child.children.is_empty() {
                    if let Some(reason) = non_c_linkable_skip_reason(child) {
                        skipped_symbols.push(ir::SkippedSymbol {
                            name: child.name.clone(),
                            kind: "constant".to_string(),
                            reason: reason.to_string(),
                        });
                    } else if let Some(c) = map_top_level_constant(child) {
                        constants.push(c);
                    }
                }
            }
            // Skip Import, Macro, TypeAlias, AssociatedType
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

/// Classify a top-level declaration node by its USR prefix and return a skip
/// reason if the node is not reachable via `dlsym` from the framework dylib.
///
/// The Swift API digester stamps declarations with Unified Symbol Resolution
/// identifiers whose prefix identifies the producing cursor:
///
/// - `s:…` — Swift-mangled USR: declaration native to the Swift module,
///   reachable only via the Swift ABI. **Not C-linkable.**
/// - `c:@F@<name>` — clang `FunctionDecl` cursor: a real C function
///   re-exported from the clang-imported module. Linkable.
/// - `c:@<Name>` — clang `VarDecl` / enum cursor. Linkable.
/// - `c:@macro@…` — clang preprocessor macro cursor. The C compiler inlines
///   `#define` values at use sites and emits no dylib symbol, so any FFI
///   binding that references the name will fail at load time with
///   `get-ffi-obj: could not find export from foreign library`. **Not
///   C-linkable.**
/// - `c:@Ea@<dummy>@<Member>` — member of an *anonymous* enum. The second
///   USR segment is libclang's synthetic disambiguator for enums with no
///   tag (conventionally the first member's name). **Not C-linkable.** The
///   C compiler inlines enum members' integer values at every use site, so
///   they never receive a dylib symbol. Members of *named* enums use the
///   `c:@E@<Enum>@<Member>` shape and reach the IR through the dedicated
///   `Enum` → `EnumElement` mapping path, not the top-level `Var` / `Func`
///   cursors filtered here.
/// - `c:@EA@<typedef>@<Member>` — same as above for the typedef'd anonymous
///   enum shape (`typedef enum { … } Name_t`). The second segment is the
///   typedef name. **Not C-linkable** for the same reason.
/// - `So<mangled>` — clang-imported Obj-C declaration. Linkable via the
///   Obj-C runtime (not handled here; Obj-C extraction lives in
///   `extract-objc`).
///
/// Nodes without a USR are treated as linkable — missing metadata is not
/// evidence of non-linkability, and every real digester node carries one.
/// New USR families discovered in future SDK releases should be added here
/// so that the filter remains the single source of truth for "is this
/// `dlsym`-able from the framework dylib?".
fn non_c_linkable_skip_reason(node: &AbiNode) -> Option<&'static str> {
    let usr = node.usr.as_deref()?;
    if usr.starts_with("s:") {
        Some(skipped_symbol_reason::SWIFT_NATIVE)
    } else if usr.starts_with("c:@macro@") {
        Some(skipped_symbol_reason::PREPROCESSOR_MACRO)
    } else if usr.starts_with("c:@Ea@") || usr.starts_with("c:@EA@") {
        Some(skipped_symbol_reason::ANONYMOUS_ENUM_MEMBER)
    } else {
        None
    }
}

/// Detect a top-level type declaration that the digester re-emitted from an
/// imported module purely as a container for the current framework's
/// extension members.
///
/// Returns true when `node` is a `Class`/`Protocol`/`Struct`/`Enum` whose
/// `moduleName` is set to a value other than `framework_name`. Such nodes
/// must be dropped: their identity belongs to the foreign module, and their
/// children are extension members the current framework adds via
/// `extension ForeignType { ... }` — keeping the node would cause downstream
/// resolution to attribute those extension members to the foreign type.
fn is_foreign_module_type_decl(node: &AbiNode, framework_name: &str) -> bool {
    let is_type_decl = matches!(
        node.decl_kind.as_deref(),
        Some("Class") | Some("Protocol") | Some("Struct") | Some("Enum")
    );
    if !is_type_decl {
        return false;
    }
    match node.module_name.as_deref() {
        Some(module) => module != framework_name,
        None => false,
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

    Some(ir::Class {
        name: node.name.clone(),
        superclass,
        protocols,
        properties,
        methods,
        category_methods: vec![],
        ancestors: vec![],
        all_methods: vec![],
        all_properties: vec![],
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
        enum_type: apianyware_macos_types::type_ref::TypeRef {
            nullable: false,
            kind: apianyware_macos_types::type_ref::TypeRefKind::Primitive {
                name: "swift_enum".to_string(),
            },
        },
        values,
        source: Some(DeclarationSource::SwiftInterface),
        provenance: build_provenance(node),
        doc_refs: build_doc_refs(node),
    })
}

// ---------------------------------------------------------------------------
// Struct mapping
// ---------------------------------------------------------------------------

fn map_struct(node: &AbiNode) -> Option<ir::Struct> {
    let mut fields = Vec::new();

    for child in &node.children {
        if child.decl_kind.as_deref() == Some("Var") && !child.children.is_empty() {
            let type_node = &child.children[0];
            fields.push(ir::StructField {
                name: child.name.clone(),
                field_type: map_swift_type(type_node),
            });
        }
    }

    Some(ir::Struct {
        name: node.name.clone(),
        fields,
        source: Some(DeclarationSource::SwiftInterface),
        provenance: build_provenance(node),
        doc_refs: build_doc_refs(node),
    })
}

// ---------------------------------------------------------------------------
// Method mapping
// ---------------------------------------------------------------------------

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
        deprecated: false,
        source: Some(DeclarationSource::SwiftInterface),
        provenance: build_provenance(node),
        doc_refs: build_doc_refs(node),
        origin: None,
    })
}

// ---------------------------------------------------------------------------
// Top-level function / constant mapping
// ---------------------------------------------------------------------------

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
