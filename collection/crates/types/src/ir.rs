//! Core IR type definitions for macOS API declarations.
//!
//! These types represent the intermediate representation of API metadata
//! extracted from macOS SDK headers and Swift module interfaces. They
//! serialize to/from JSON checkpoint files at each pipeline phase.

use serde::{Deserialize, Serialize};

use crate::annotation::{ApiPattern, ClassAnnotations};
use crate::enrichment::{EnrichmentData, VerificationReport};
use crate::provenance::{DeclarationSource, DocRefs, SourceProvenance};
use crate::serde_helpers::null_as_empty_vec;
use crate::type_ref::TypeRef;

// ---------------------------------------------------------------------------
// Top-level document
// ---------------------------------------------------------------------------

/// Top-level IR document for a single framework.
///
/// Each checkpoint file contains one `Framework` value. Successive pipeline
/// phases add fields (resolved relations, annotations, enrichment) while
/// preserving all fields from prior phases.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Framework {
    /// Schema version for this checkpoint format (e.g., `"1.0"`).
    #[serde(default)]
    pub format_version: String,

    /// Pipeline phase that produced this checkpoint: `"collected"`, `"resolved"`,
    /// `"annotated"`, or `"enriched"`.
    #[serde(default)]
    pub checkpoint: String,

    /// Framework name (e.g., `"Foundation"`, `"AppKit"`).
    pub name: String,

    /// macOS SDK version used during collection (e.g., `"15.4"`).
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub sdk_version: Option<String>,

    /// ISO 8601 timestamp when the collection was performed.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub collected_at: Option<String>,

    /// Frameworks this one depends on.
    #[serde(default)]
    pub depends_on: Vec<String>,

    /// Symbols that were skipped during extraction, with reasons.
    #[serde(default, deserialize_with = "null_as_empty_vec")]
    pub skipped_symbols: Vec<SkippedSymbol>,

    /// Objective-C/Swift class declarations.
    #[serde(default, deserialize_with = "null_as_empty_vec")]
    pub classes: Vec<Class>,

    /// Protocol declarations.
    #[serde(default, deserialize_with = "null_as_empty_vec")]
    pub protocols: Vec<Protocol>,

    /// Enumeration declarations.
    #[serde(default, deserialize_with = "null_as_empty_vec")]
    pub enums: Vec<Enum>,

    /// C struct declarations.
    #[serde(default, deserialize_with = "null_as_empty_vec")]
    pub structs: Vec<Struct>,

    /// C function declarations.
    #[serde(default, deserialize_with = "null_as_empty_vec")]
    pub functions: Vec<Function>,

    /// Global constants and extern variables.
    #[serde(default, deserialize_with = "null_as_empty_vec")]
    pub constants: Vec<Constant>,

    // --- Annotated phase additions ---
    /// Per-class and per-protocol method annotations (populated by annotate
    /// step). Each entry is keyed by a class or protocol name.
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub class_annotations: Vec<ClassAnnotations>,

    /// Multi-method behavioral patterns (populated by annotate step).
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub api_patterns: Vec<ApiPattern>,

    // --- Enriched phase additions ---
    /// Annotation-derived enrichment relations (populated by enrich step).
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub enrichment: Option<EnrichmentData>,

    /// Verification report (populated by enrich step).
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub verification: Option<VerificationReport>,
}

/// A symbol that was skipped during extraction.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SkippedSymbol {
    pub name: String,
    pub kind: String,
    pub reason: String,
}

// ---------------------------------------------------------------------------
// Classes
// ---------------------------------------------------------------------------

/// Objective-C class declaration.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Class {
    /// Class name (e.g., `"NSString"`).
    pub name: String,

    /// Superclass name (e.g., `"NSObject"`). Empty string if none.
    #[serde(rename = "super", default)]
    pub superclass: String,

    /// Protocols this class conforms to.
    #[serde(default)]
    pub protocols: Vec<String>,

    /// Declared properties.
    #[serde(default, deserialize_with = "null_as_empty_vec")]
    pub properties: Vec<Property>,

    /// Declared methods (instance and class).
    #[serde(default, deserialize_with = "null_as_empty_vec")]
    pub methods: Vec<Method>,

    /// Methods contributed by categories from other frameworks.
    #[serde(default)]
    pub category_methods: Vec<CategoryGroup>,

    /// Swift declaration attributes attached to the class
    /// (e.g. `"MainActor"`, `"_Concurrency.MainActor"`, `"Available"`).
    /// Sourced from swift-api-digester `declAttributes`. Used by the
    /// annotate step to propagate class-level threading constraints to
    /// every instance method.
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub swift_attributes: Vec<String>,

    // --- Resolved phase additions ---
    /// Transitive ancestor classes (populated by resolve step).
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub ancestors: Vec<String>,

    /// Inheritance-flattened methods (populated by resolve step).
    /// Named `all_methods` for backward compat with POC Level 1 JSON.
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub all_methods: Vec<Method>,

    /// Inheritance-flattened properties (populated by resolve step).
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub all_properties: Vec<Property>,

    /// Whether this declaration is reachable through the ObjC/C runtime without
    /// crossing the Swift ABI (clang `c:`/`So` USR cursor, or an `@objc` Swift
    /// decl). False for genuinely Swift-native declarations (`s:` USR) that need
    /// a trampoline. Drives the per-target direct-vs-trampoline boundary
    /// (ADR-0026). Defaults true (the fully-elided ObjC limit) and is omitted
    /// from JSON when true, so the golden diff audits exactly the trampoline
    /// residual.
    #[serde(
        default = "crate::serde_helpers::default_true",
        skip_serializing_if = "crate::serde_helpers::is_true"
    )]
    pub objc_exposed: bool,
}

/// Methods contributed by a category from another framework.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CategoryGroup {
    /// Category name.
    pub category: String,
    /// Framework that defines this category.
    pub origin_framework: String,
    /// Methods in this category.
    #[serde(default)]
    pub methods: Vec<Method>,
}

// ---------------------------------------------------------------------------
// Methods & parameters
// ---------------------------------------------------------------------------

/// ObjC method (instance or class).
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Method {
    /// Selector string (e.g., `"initWithString:"`).
    pub selector: String,

    /// Whether this is a class method (`+`) vs instance method (`-`).
    #[serde(default)]
    pub class_method: bool,

    /// Whether this is an initializer method.
    #[serde(default)]
    pub init_method: bool,

    /// Method parameters.
    #[serde(default)]
    pub params: Vec<Param>,

    /// Return type.
    pub return_type: TypeRef,

    /// Whether this method is deprecated.
    #[serde(default)]
    pub deprecated: bool,

    /// Whether this method accepts variadic arguments.
    #[serde(default)]
    pub variadic: bool,

    /// Which extractor produced this declaration.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub source: Option<DeclarationSource>,

    /// Source location and availability information.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub provenance: Option<SourceProvenance>,

    /// Documentation references (header comment, Apple doc URL, USR).
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub doc_refs: Option<DocRefs>,

    // --- Resolved phase additions ---
    /// Framework that originally declared this method (for inherited methods).
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub origin: Option<String>,

    /// Category that contributed this method.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub category: Option<String>,

    /// Class whose method this overrides.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub overrides: Option<String>,

    /// Whether this method returns a retained object (ownership family detection).
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub returns_retained: Option<bool>,

    /// Protocol whose requirement this method satisfies.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub satisfies_protocol: Option<String>,

    /// Whether this declaration is reachable through the ObjC/C runtime without
    /// crossing the Swift ABI (clang `c:`/`So` USR cursor, or an `@objc` Swift
    /// decl). False for genuinely Swift-native declarations (`s:` USR) that need
    /// a trampoline. Drives the per-target direct-vs-trampoline boundary
    /// (ADR-0026). Defaults true (the fully-elided ObjC limit) and is omitted
    /// from JSON when true, so the golden diff audits exactly the trampoline
    /// residual.
    #[serde(
        default = "crate::serde_helpers::default_true",
        skip_serializing_if = "crate::serde_helpers::is_true"
    )]
    pub objc_exposed: bool,
}

/// Named parameter in a method or function signature.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Param {
    /// Parameter name.
    pub name: String,
    /// Parameter type.
    #[serde(rename = "type")]
    pub param_type: TypeRef,
}

// ---------------------------------------------------------------------------
// Properties
// ---------------------------------------------------------------------------

/// ObjC property (instance or class).
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Property {
    /// Property name.
    pub name: String,

    /// Property type.
    #[serde(rename = "type")]
    pub property_type: TypeRef,

    /// Whether the property is read-only.
    #[serde(default)]
    pub readonly: bool,

    /// Whether this is a class property (vs instance property).
    #[serde(default)]
    pub class_property: bool,

    /// Whether the property carries the `(copy)` attribute. For block-typed
    /// properties this is the canonical signal that the synthesised setter
    /// stores the block (`Block_copy`-ed) on the instance — used by the
    /// annotate step to classify the setter's block parameter as `stored`.
    #[serde(default, skip_serializing_if = "std::ops::Not::not")]
    pub is_copy: bool,

    /// Whether this property is deprecated.
    #[serde(default)]
    pub deprecated: bool,

    /// Which extractor produced this declaration.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub source: Option<DeclarationSource>,

    /// Source location and availability information.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub provenance: Option<SourceProvenance>,

    /// Documentation references.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub doc_refs: Option<DocRefs>,

    // --- Resolved phase additions ---
    /// Framework that originally declared this property (for inherited properties).
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub origin: Option<String>,

    /// Whether this declaration is reachable through the ObjC/C runtime without
    /// crossing the Swift ABI (clang `c:`/`So` USR cursor, or an `@objc` Swift
    /// decl). False for genuinely Swift-native declarations (`s:` USR) that need
    /// a trampoline. Drives the per-target direct-vs-trampoline boundary
    /// (ADR-0026). Defaults true (the fully-elided ObjC limit) and is omitted
    /// from JSON when true, so the golden diff audits exactly the trampoline
    /// residual.
    #[serde(
        default = "crate::serde_helpers::default_true",
        skip_serializing_if = "crate::serde_helpers::is_true"
    )]
    pub objc_exposed: bool,
}

// ---------------------------------------------------------------------------
// Protocols
// ---------------------------------------------------------------------------

/// Objective-C protocol.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Protocol {
    /// Protocol name (e.g., `"NSCopying"`).
    pub name: String,

    /// Protocols this protocol inherits from.
    #[serde(default)]
    pub inherits: Vec<String>,

    /// Methods that conforming classes must implement.
    #[serde(default)]
    pub required_methods: Vec<Method>,

    /// Methods that conforming classes may optionally implement.
    #[serde(default)]
    pub optional_methods: Vec<Method>,

    /// Properties declared by this protocol.
    #[serde(default)]
    pub properties: Vec<Property>,

    /// Which extractor produced this declaration.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub source: Option<DeclarationSource>,

    /// Source location and availability information.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub provenance: Option<SourceProvenance>,

    /// Documentation references.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub doc_refs: Option<DocRefs>,

    /// Whether this declaration is reachable through the ObjC/C runtime without
    /// crossing the Swift ABI (clang `c:`/`So` USR cursor, or an `@objc` Swift
    /// decl). False for genuinely Swift-native declarations (`s:` USR) that need
    /// a trampoline. Drives the per-target direct-vs-trampoline boundary
    /// (ADR-0026). Defaults true (the fully-elided ObjC limit) and is omitted
    /// from JSON when true, so the golden diff audits exactly the trampoline
    /// residual.
    #[serde(
        default = "crate::serde_helpers::default_true",
        skip_serializing_if = "crate::serde_helpers::is_true"
    )]
    pub objc_exposed: bool,
}

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

/// C/ObjC enumeration.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Enum {
    /// Enum name (e.g., `"NSActivityOptions"`).
    pub name: String,

    /// Underlying integer type.
    #[serde(rename = "type")]
    pub enum_type: TypeRef,

    /// Enum values (name + integer value pairs).
    #[serde(default)]
    pub values: Vec<EnumValue>,

    /// Which extractor produced this declaration.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub source: Option<DeclarationSource>,

    /// Source location and availability information.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub provenance: Option<SourceProvenance>,

    /// Documentation references.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub doc_refs: Option<DocRefs>,

    /// Whether this declaration is reachable through the ObjC/C runtime without
    /// crossing the Swift ABI (clang `c:`/`So` USR cursor, or an `@objc` Swift
    /// decl). False for genuinely Swift-native declarations (`s:` USR) that need
    /// a trampoline. Drives the per-target direct-vs-trampoline boundary
    /// (ADR-0026). Defaults true (the fully-elided ObjC limit) and is omitted
    /// from JSON when true, so the golden diff audits exactly the trampoline
    /// residual.
    #[serde(
        default = "crate::serde_helpers::default_true",
        skip_serializing_if = "crate::serde_helpers::is_true"
    )]
    pub objc_exposed: bool,
}

/// Single value in an enumeration.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct EnumValue {
    /// Value name (e.g., `"NSActivityBackground"`).
    pub name: String,
    /// Integer value.
    pub value: i64,
}

// ---------------------------------------------------------------------------
// Structs
// ---------------------------------------------------------------------------

/// C struct declaration.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Struct {
    /// Struct name (e.g., `"NSAffineTransformStruct"`).
    pub name: String,

    /// Struct fields.
    #[serde(default)]
    pub fields: Vec<StructField>,

    /// Which extractor produced this declaration.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub source: Option<DeclarationSource>,

    /// Source location and availability information.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub provenance: Option<SourceProvenance>,

    /// Documentation references.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub doc_refs: Option<DocRefs>,

    /// Whether this declaration is reachable through the ObjC/C runtime without
    /// crossing the Swift ABI (clang `c:`/`So` USR cursor, or an `@objc` Swift
    /// decl). False for genuinely Swift-native declarations (`s:` USR) that need
    /// a trampoline. Drives the per-target direct-vs-trampoline boundary
    /// (ADR-0026). Defaults true (the fully-elided ObjC limit) and is omitted
    /// from JSON when true, so the golden diff audits exactly the trampoline
    /// residual.
    #[serde(
        default = "crate::serde_helpers::default_true",
        skip_serializing_if = "crate::serde_helpers::is_true"
    )]
    pub objc_exposed: bool,
}

/// Field within a C struct.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct StructField {
    /// Field name.
    pub name: String,
    /// Field type.
    #[serde(rename = "type")]
    pub field_type: TypeRef,
}

// ---------------------------------------------------------------------------
// Functions
// ---------------------------------------------------------------------------

/// C function declaration.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Function {
    /// Function name.
    pub name: String,

    /// Function parameters.
    #[serde(default)]
    pub params: Vec<Param>,

    /// Return type.
    pub return_type: TypeRef,

    /// Whether this is an inline function.
    #[serde(default)]
    pub inline: bool,

    /// Whether this function accepts variadic arguments.
    #[serde(default)]
    pub variadic: bool,

    /// Which extractor produced this declaration.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub source: Option<DeclarationSource>,

    /// Source location and availability information.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub provenance: Option<SourceProvenance>,

    /// Documentation references.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub doc_refs: Option<DocRefs>,

    /// Whether this declaration is reachable through the ObjC/C runtime without
    /// crossing the Swift ABI (clang `c:`/`So` USR cursor, or an `@objc` Swift
    /// decl). False for genuinely Swift-native declarations (`s:` USR) that need
    /// a trampoline. Drives the per-target direct-vs-trampoline boundary
    /// (ADR-0026). Defaults true (the fully-elided ObjC limit) and is omitted
    /// from JSON when true, so the golden diff audits exactly the trampoline
    /// residual.
    #[serde(
        default = "crate::serde_helpers::default_true",
        skip_serializing_if = "crate::serde_helpers::is_true"
    )]
    pub objc_exposed: bool,
}

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

/// Global constant or extern variable.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Constant {
    /// Constant name.
    pub name: String,
    /// Constant type.
    #[serde(rename = "type")]
    pub constant_type: TypeRef,

    /// Which extractor produced this declaration.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub source: Option<DeclarationSource>,

    /// Source location and availability information.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub provenance: Option<SourceProvenance>,

    /// Documentation references.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub doc_refs: Option<DocRefs>,

    /// For macro-defined constants (e.g. `CFSTR("...")`), the literal string
    /// value embedded in the macro. When present, the emitter generates a
    /// runtime-constructed CFString instead of a `get-ffi-obj` / `dlsym` lookup.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub macro_value: Option<String>,

    /// Whether this declaration is reachable through the ObjC/C runtime without
    /// crossing the Swift ABI (clang `c:`/`So` USR cursor, or an `@objc` Swift
    /// decl). False for genuinely Swift-native declarations (`s:` USR) that need
    /// a trampoline. Drives the per-target direct-vs-trampoline boundary
    /// (ADR-0026). Defaults true (the fully-elided ObjC limit) and is omitted
    /// from JSON when true, so the golden diff audits exactly the trampoline
    /// residual.
    #[serde(
        default = "crate::serde_helpers::default_true",
        skip_serializing_if = "crate::serde_helpers::is_true"
    )]
    pub objc_exposed: bool,
}
