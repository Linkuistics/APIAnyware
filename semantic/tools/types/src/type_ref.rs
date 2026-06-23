//! Type reference system for representing Objective-C, C, and Swift types.
//!
//! [`TypeRef`] wraps a [`TypeRefKind`] variant with an optional nullability flag,
//! providing a uniform way to represent all type references in method signatures,
//! property types, and function parameters.

use serde::{Deserialize, Serialize};

/// Universal type reference. Wraps a [`TypeRefKind`] variant with an optional
/// `nullable` flag that can apply to any kind.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TypeRef {
    /// Whether this type is annotated as nullable (`_Nullable` in ObjC).
    #[serde(default)]
    pub nullable: bool,

    /// The specific type kind.
    #[serde(flatten)]
    pub kind: TypeRefKind,
}

/// The discriminated union of type kinds. Serialized as `{"kind": "..."}`.
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(tag = "kind")]
pub enum TypeRefKind {
    /// Type alias (typedef). Example: `NSStringEncoding`.
    ///
    /// `underlying_primitive` carries the resolved width/signedness for
    /// enum-typedef aliases (e.g. `CF_ENUM(uint32_t, AXValueType)` →
    /// `Some("uint32")`, `NS_ENUM(NSInteger, …)` → `Some("int64")` on
    /// macOS arm64). Populated at extraction via
    /// `Entity::get_enum_underlying_type`; `None` for non-enum aliases
    /// and when the underlying type is unavailable. FFI mappers consult
    /// this to pick the right fixed-width type instead of defaulting
    /// every enum alias to `_uint64`.
    #[serde(rename = "alias")]
    Alias {
        name: String,
        #[serde(default, skip_serializing_if = "Option::is_none")]
        framework: Option<String>,
        #[serde(default, skip_serializing_if = "Option::is_none")]
        underlying_primitive: Option<String>,
    },

    /// ObjC block type with parameter types and a return type.
    #[serde(rename = "block")]
    Block {
        #[serde(default)]
        params: Vec<TypeRef>,
        return_type: Box<TypeRef>,
    },

    /// ObjC class reference with optional generic type parameters.
    #[serde(rename = "class")]
    Class {
        name: String,
        #[serde(default, skip_serializing_if = "Option::is_none")]
        framework: Option<String>,
        #[serde(default, skip_serializing_if = "Vec::is_empty")]
        params: Vec<TypeRef>,
    },

    /// Metatype reference (`Class` in ObjC — the class object itself).
    #[serde(rename = "class_ref")]
    ClassRef,

    /// Untyped object pointer (`id`).
    #[serde(rename = "id")]
    Id,

    /// Return type that matches the receiver's type.
    #[serde(rename = "instancetype")]
    Instancetype,

    /// C function pointer type with parameter types and a return type.
    /// Captures the full signature for callback typedefs like `CGEventTapCallBack`.
    #[serde(rename = "function_pointer")]
    FunctionPointer {
        /// Typedef name (e.g., `"CGEventTapCallBack"`). Present when the function
        /// pointer was reached through a typedef; absent for anonymous function pointers.
        #[serde(default, skip_serializing_if = "Option::is_none")]
        name: Option<String>,
        #[serde(default)]
        params: Vec<TypeRef>,
        return_type: Box<TypeRef>,
    },

    /// C string pointer (`const char *` only).
    ///
    /// Non-const `char *` (output buffers) maps to `Pointer` instead, since
    /// auto-converting string types lose writes to the buffer.
    /// Distinguished from generic `Pointer` so emitters can use auto-converting
    /// string types (e.g., Racket's `_string` which auto-marshals between Racket
    /// strings and C strings).
    #[serde(rename = "c_string")]
    CString,

    /// Raw C pointer (e.g., `void *`, `int *`).
    #[serde(rename = "pointer")]
    Pointer,

    /// C primitive type (int, float, bool, void, etc.).
    #[serde(rename = "primitive")]
    Primitive { name: String },

    /// ObjC selector type (`SEL`).
    #[serde(rename = "selector")]
    Selector,

    /// C struct type.
    #[serde(rename = "struct")]
    Struct { name: String },
}

impl TypeRef {
    /// Create a `void` type reference (used as placeholder for cross-framework methods
    /// where the original declaration is not available in the current framework).
    pub fn void() -> Self {
        Self {
            nullable: false,
            kind: TypeRefKind::Primitive {
                name: "void".to_string(),
            },
        }
    }
}
