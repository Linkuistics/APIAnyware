//! Core IR type definitions for macOS API declarations.
//!
//! These types represent the intermediate representation of API metadata
//! extracted from macOS SDK headers and Swift module interfaces. They
//! serialize to/from JSON checkpoint files at each pipeline phase.

use serde::{Deserialize, Serialize};

use crate::annotation::{ClassAnnotations, OwnershipKind};
use crate::enrichment::{EnrichmentData, VerificationReport};
use crate::pattern_instance::PatternInstance;
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

    /// Pipeline phase that produced this checkpoint. On-disk values are
    /// `"extracted"` (machine fact base) and `"resolved"` (the final merged
    /// graph); the in-process passes are `"linked"` (datalog cross-reference,
    /// formerly `"resolved"`) then `"annotated"` (ADR-0046 spec triad).
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

    /// First-class **pattern-instances** — kinds bound to concrete framework
    /// participants, provenance-stamped (ADR-0048; the carriage of workstream-3
    /// child 2). Replaces the former heuristic `api_patterns` list. Produced by
    /// the convention/llm/manual tiers (detection is a later child); empty until
    /// a producer runs.
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub patterns: Vec<PatternInstance>,

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

    /// The **Swift type name** for an ObjC-bridged class the Swift overlay renames
    /// (`NSScanner` → `Scanner`, `NSURLSessionWebSocketTask` →
    /// `URLSessionWebSocketTask`). `name` carries the ObjC **runtime** name (the
    /// identity the registry/construct/auto-wrap key on); this carries the name
    /// Swift code must spell, because the obsoleted ObjC name does not compile as a
    /// Swift type. The Swift-native **trampoline** uses this for its
    /// `Unmanaged<Module.Type>` receiver cast and `Type(labels:)` constructor while
    /// the C entry symbol + Lisp specializer stay on the runtime `name`. `None` when
    /// the overlay does not rename the class (the common case — `name` is already the
    /// Swift-spellable name). Set in `extract-swift` `map_class`; carried through the
    /// Swift↔ObjC merge onto the unified clang class.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub swift_name: Option<String>,
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

    /// Swift-native call metadata (ADR-0027 generalised to methods, leaf 020).
    /// Present **only** on `objc_exposed == false` methods/initializers recovered
    /// from the Swift ABI; `None` for every ObjC/C method (which binds via
    /// `msgSend` and needs no trampoline). Carries the `throws`/`async`/generic
    /// facts the receiver-handle trampoline codegen needs but that the lossy
    /// Swift→ObjC `TypeRef` normalization would otherwise drop. Skip-serialized
    /// when absent so the ObjC golden JSON is byte-identical.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub swift_fn: Option<SwiftFnInfo>,
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

    /// The ownership qualifier the declaration carries — `@property (weak)`,
    /// `(copy)`, `(strong)`/`(retain)`, `(assign)`/`(unsafe_unretained)` — read
    /// off the one `ObjCAttributes` value clang hands the extractor. `None` when
    /// the declaration states none (a plain scalar `@property BOOL enabled;`, or
    /// a Swift-sourced declaration, which has no ObjC attributes to read).
    ///
    /// This is a **declared attribute**, not a derived fact (ADR-0047 §4): the
    /// convention tier's priority-0 `weak-`/`strong-property-attribute` rules
    /// have it as their premise and outrank every rule whose premise is a *name*.
    /// [`Self::is_copy`] is the `(copy)` arm — the block-invocation facet's
    /// canonical signal that the synthesised setter stores a `Block_copy`-ed
    /// block on the instance.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub ownership: Option<OwnershipKind>,

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

impl Property {
    /// Whether the declaration carries `@property (copy)`.
    ///
    /// The `(copy)` arm of [`Self::ownership`], named because it is a premise in
    /// its own right: for a block-typed property it is the block-invocation
    /// facet's signal that the synthesised setter *stores* the block.
    pub fn is_copy(&self) -> bool {
        self.ownership == Some(OwnershipKind::Copy)
    }
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

    /// Swift-native value-type methods + initializers (leaf 020). Empty for C
    /// structs (which carry only fields) and ObjC-bridged value types, so the
    /// `skip_serializing_if` keeps the ObjC golden JSON unchanged. Populated for
    /// `objc_exposed == false` Swift structs so the receiver-handle trampoline
    /// (population B, D1/D3) can vend them — a value-receiver method unboxes the
    /// handle to the concrete type and (for `mutating`) writes the mutated copy
    /// back into the box.
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub methods: Vec<Method>,

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

    /// Swift-native call metadata (ADR-0027, leaf 040/020). Present **only** on
    /// `objc_exposed == false` top-level functions recovered from the Swift ABI;
    /// `None` for every ObjC/C function (which binds directly and needs no
    /// trampoline). Carries the three facts the call-by-name trampoline codegen
    /// needs but that the lossy Swift→ObjC `TypeRef` normalization
    /// (`map_swift_type`) would otherwise drop. Skip-serialized when absent so
    /// the golden JSON of the ObjC-only residual is unchanged.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub swift_fn: Option<SwiftFnInfo>,
}

/// Per-function facts the call-by-name trampoline codegen needs that the lossy
/// Swift→ObjC `TypeRef` normalization discards (ADR-0027 / leaf 040/020). Only
/// attached to Swift-native (`objc_exposed == false`) top-level functions.
#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct SwiftFnInfo {
    /// The Swift function `throws`. The trampoline takes a trailing `NSError **`
    /// out-param (the dispatch-table `error_out` shape) and runs the call inside
    /// `awRacketTry`.
    #[serde(default)]
    pub throwing: bool,
    /// The Swift function is `async`. Recorded + counted (`deferred_async`); the
    /// completion-callback `@_cdecl` shape is a follow-up leaf.
    #[serde(default)]
    pub is_async: bool,
    /// The Swift function is generic (`generic_sig` present). Unbindable —
    /// `@_cdecl` cannot be generic — recorded + counted
    /// (`unbindable_generic_free_function`).
    #[serde(default)]
    pub is_generic: bool,

    /// The method's `self` access kind for value-type receivers (digester
    /// `funcSelfKind`): `"Mutating"`, `"NonMutating"`, `"Consuming"`,
    /// `"Borrowing"`, etc. `None` for free functions (no receiver) and ObjC
    /// methods. Drives D3: a `Mutating` value-receiver trampoline writes the
    /// mutated copy back into the handle box, and a `Consuming` receiver is
    /// deferred-with-count (the handle would dangle after the call). Skip-
    /// serialized when absent so existing free-function `swift_fn` JSON is
    /// unchanged.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub self_kind: Option<String>,
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

    /// Present when the constant's own declared C type is an array (`extern const T X[]` /
    /// `extern const T X[N]`) — `constant_type` still reads `Pointer` (the ABI shape a
    /// `dlsym`'d array symbol collapses to is genuinely pointer-width), but an array global's
    /// *value* is its own symbol address, not something stored at that address the way a
    /// pointer *variable*'s value is. Only a top-level constant's own type carries this
    /// distinction — a parameter/return/field position never reaches here, because C's
    /// array-to-pointer decay already turns those into an ordinary stored-pointer `Pointer`
    /// before libclang reports the type. Carries the array's **element** type (mapped like any
    /// other), so a reader can tell a byte/char buffer (plausibly a banner string) from
    /// anything else, without re-deriving the fact from `constant_type` (which no longer has
    /// it). `array-constant-symbol-value-k109`.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub array_element: Option<TypeRef>,

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
