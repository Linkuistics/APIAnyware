//! Serde model for swift-api-digester `-dump-sdk` JSON output.
//!
//! The `ABIRoot` JSON tree is a recursive structure where every node is an
//! [`AbiNode`] with a `kind` discriminator, optional declaration metadata,
//! and a list of child nodes. This module deserializes that tree faithfully;
//! the mapping to IR types happens in [`crate::declaration_mapping`].

use serde::Deserialize;

/// Top-level wrapper: the JSON file has a single `"ABIRoot"` key.
#[derive(Debug, Deserialize)]
pub struct AbiDocument {
    #[serde(rename = "ABIRoot")]
    pub root: AbiNode,
}

/// A node in the ABIRoot tree. Every element — imports, type declarations,
/// functions, properties, conformances — is represented uniformly.
#[derive(Debug, Clone, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct AbiNode {
    /// Node kind: `"Root"`, `"TypeDecl"`, `"Function"`, `"Var"`,
    /// `"Constructor"`, `"Import"`, `"TypeNominal"`, `"TypeFunc"`, etc.
    pub kind: String,

    /// Simple name (e.g., `"Observable"`, `"init"`, `"String"`).
    #[serde(default)]
    pub name: String,

    /// Pretty-printed name including parameter labels (e.g., `"init(name:)"`,
    /// `"process(input:)"`).
    #[serde(default)]
    pub printed_name: String,

    /// Child nodes (methods, properties, type parameters, etc.).
    #[serde(default)]
    pub children: Vec<AbiNode>,

    // ----- Declaration metadata (present when `kind` is a declaration) -----
    /// Declaration kind: `"Class"`, `"Struct"`, `"Enum"`, `"Protocol"`,
    /// `"Func"`, `"Var"`, `"Constructor"`, `"EnumElement"`, `"Import"`,
    /// `"Accessor"`, `"Macro"`, `"TypeAlias"`, `"AssociatedType"`.
    #[serde(default)]
    pub decl_kind: Option<String>,

    /// Unified Symbol Resolution identifier (Swift mangled).
    #[serde(default)]
    pub usr: Option<String>,

    /// Swift mangled name.
    #[serde(default)]
    pub mangled_name: Option<String>,

    /// Module that owns this declaration.
    #[serde(default)]
    pub module_name: Option<String>,

    // ----- Availability -----
    /// macOS introduction version (e.g., `"14.0"`, `"10.15"`).
    #[serde(default, rename = "intro_Macosx")]
    pub intro_macos: Option<String>,

    /// iOS introduction version.
    #[serde(default, rename = "intro_iOS")]
    pub intro_ios: Option<String>,

    /// tvOS introduction version.
    #[serde(default, rename = "intro_tvOS")]
    pub intro_tvos: Option<String>,

    /// watchOS introduction version.
    #[serde(default, rename = "intro_watchOS")]
    pub intro_watchos: Option<String>,

    /// Minimum Swift version required.
    #[serde(default, rename = "intro_swift")]
    pub intro_swift: Option<String>,

    // ----- Declaration attributes -----
    /// Attribute keywords (e.g., `["Available", "MacroRole"]`).
    #[serde(default)]
    pub decl_attributes: Vec<String>,

    // ----- Class / struct metadata -----
    /// USR of the superclass (for classes).
    #[serde(default)]
    pub superclass_usr: Option<String>,

    /// Printed superclass name chain (e.g., `["TestFramework.Base"]`).
    #[serde(default)]
    pub superclass_names: Vec<String>,

    /// Protocol conformances.
    #[serde(default)]
    pub conformances: Vec<AbiNode>,

    /// Generic signature (e.g., `"<Subject where Subject : Observable>"`).
    #[serde(default)]
    pub generic_sig: Option<String>,

    // ----- Function / method metadata -----
    /// Whether this is a `static` declaration.
    #[serde(default, rename = "static")]
    pub is_static: bool,

    /// `"Mutating"`, `"NonMutating"`, etc.
    #[serde(default)]
    pub func_self_kind: Option<String>,

    /// Whether this function can throw.
    #[serde(default)]
    pub throwing: bool,

    /// Whether this function is async, **as reported by an `async` JSON field**.
    ///
    /// WARNING: `swift-api-digester` (json_format_version 8, Xcode 16) does **not**
    /// emit an `async` field — async is recoverable only from the mangled-name
    /// `Ya` effect marker (see [`mangled_is_async`] in `declaration_mapping`). This
    /// field therefore deserializes to `false` on every current decl; it is kept
    /// for forward-compatibility with a future digester that does surface it, and
    /// is OR-ed with the mangled-name detection rather than read alone. (`throwing`
    /// above *is* emitted, so it is read directly.)
    #[serde(default, rename = "async")]
    pub is_async: bool,

    /// For constructors: `"Designated"`, `"Convenience"`, etc.
    #[serde(default, rename = "init_kind")]
    pub init_kind: Option<String>,

    /// Whether this method is a protocol requirement.
    #[serde(default)]
    pub protocol_req: bool,

    // ----- Variable / property metadata -----
    /// Property accessors (Get, Set, etc.).
    #[serde(default)]
    pub accessors: Vec<AbiNode>,

    /// Accessor kind when `declKind == "Accessor"` (e.g., `"get"`, `"set"`).
    #[serde(default)]
    pub accessor_kind: Option<String>,

    /// Whether this property is a `let` constant.
    #[serde(default, rename = "isLet")]
    pub is_let: bool,

    /// Whether this property has backing storage.
    #[serde(default)]
    pub has_storage: bool,

    /// Whether this declaration comes from an extension.
    #[serde(default)]
    pub is_from_extension: bool,

    /// Whether a new witness table entry is required (protocol members).
    #[serde(default)]
    pub req_new_witness_table_entry: bool,

    // ----- Enum metadata -----
    /// Raw type name for enums with a raw value (e.g., `"Int"`, `"String"`).
    #[serde(default)]
    pub enum_raw_type_name: Option<String>,

    /// Whether this enum is exhaustive (non-frozen).
    #[serde(default)]
    pub is_enum_exhaustive: bool,

    // ----- Override / implicit metadata -----
    /// Whether this declaration overrides a superclass member.
    #[serde(default)]
    pub overriding: bool,

    /// Whether this declaration is compiler-generated / implicit.
    #[serde(default)]
    pub implicit: bool,

    /// Whether a parameter has a default argument.
    #[serde(default)]
    pub has_default_arg: bool,

    // ----- Type metadata (for TypeNominal nodes) -----
    /// Parameter value ownership (e.g., `"InOut"`).
    #[serde(default)]
    pub param_value_ownership: Option<String>,

    /// Type attributes (e.g., `["noescape"]`).
    #[serde(default)]
    pub type_attributes: Vec<String>,
}
