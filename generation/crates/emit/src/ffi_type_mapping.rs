//! IR type → FFI type string mapping.
//!
//! Converts IR [`TypeRef`] values to FFI type expression strings for target languages.
//! Each language emitter provides its own [`FfiTypeMapper`] implementation.

use apianyware_macos_types::type_ref::{TypeRef, TypeRefKind};

/// Maps IR types to FFI type strings for a specific target language.
///
/// New target emitters: read [`docs/pipeline/emitter-contract.md`] before
/// implementing this trait. It documents IR shapes whose handling is not
/// obvious from the type itself (currently: OS_OBJECT_USE_OBJC bridged GCD
/// handles), so each new target does not have to re-discover them at
/// integration time.
///
/// [`docs/pipeline/emitter-contract.md`]: ../../../../docs/pipeline/emitter-contract.md
pub trait FfiTypeMapper {
    /// Convert a [`TypeRef`] to its FFI type string representation.
    ///
    /// `is_return_type` affects mapping for certain types (e.g., `void` as return
    /// maps to `_void` in Racket, but `void` as parameter maps to `_pointer`).
    fn map_type(&self, type_ref: &TypeRef, is_return_type: bool) -> String;

    /// Check if a type represents an object pointer (class, protocol, id, instancetype).
    fn is_object_type(&self, type_ref: &TypeRef) -> bool {
        matches!(
            type_ref.kind,
            TypeRefKind::Class { .. } | TypeRefKind::Id | TypeRefKind::Instancetype
        )
    }

    /// Check if a type is a block type.
    fn is_block_type(&self, type_ref: &TypeRef) -> bool {
        matches!(type_ref.kind, TypeRefKind::Block { .. })
    }

    /// Check if a type represents void.
    fn is_void(&self, type_ref: &TypeRef) -> bool {
        matches!(&type_ref.kind, TypeRefKind::Primitive { name } if normalize_primitive_name(name) == "void")
    }

    /// Check if a type is a struct passed by value.
    fn is_struct_type(&self, type_ref: &TypeRef) -> bool {
        match &type_ref.kind {
            TypeRefKind::Struct { .. } => true,
            TypeRefKind::Alias { name, .. } => is_known_geometry_struct(name),
            _ => false,
        }
    }
}

/// Strip framework-qualified prefix and normalize case for primitive name matching.
///
/// The Swift API digester produces qualified primitive names like `Swift.Void` or
/// `Swift.Bool`. This strips the prefix and lowercases to match the canonical
/// primitive names used by the ObjC extractor (`void`, `bool`, `uint64`, etc.).
fn normalize_primitive_name(name: &str) -> String {
    let unqualified = match name.rsplit_once('.') {
        Some((_, suffix)) => suffix,
        None => name,
    };
    unqualified.to_ascii_lowercase()
}

/// Known geometry struct names that may appear as aliases (typedefs) in the IR.
///
/// libclang classifies `NSRect`, `CGRect`, etc. as typedefs (aliases) rather than
/// struct types. The FFI mapper must recognize these and map them to their cstruct
/// representations rather than falling through to the `_uint64` default.
fn is_known_geometry_struct(name: &str) -> bool {
    matches!(
        name,
        "NSRect"
            | "CGRect"
            | "NSPoint"
            | "CGPoint"
            | "NSSize"
            | "CGSize"
            | "NSRange"
            | "NSEdgeInsets"
            | "NSDirectionalEdgeInsets"
            | "NSAffineTransformStruct"
            | "CGAffineTransform"
            | "CGVector"
    )
}

/// Map a known geometry struct alias name to its Racket FFI cstruct type.
fn map_geometry_struct_alias(name: &str) -> Option<&'static str> {
    match name {
        "NSRect" | "CGRect" => Some("_NSRect"),
        "NSPoint" | "CGPoint" => Some("_NSPoint"),
        "NSSize" | "CGSize" => Some("_NSSize"),
        "NSRange" => Some("_NSRange"),
        "NSEdgeInsets" => Some("_NSEdgeInsets"),
        "NSDirectionalEdgeInsets" => Some("_NSDirectionalEdgeInsets"),
        "NSAffineTransformStruct" => Some("_NSAffineTransformStruct"),
        "CGAffineTransform" => Some("_CGAffineTransform"),
        "CGVector" => Some("_CGVector"),
        _ => None,
    }
}

/// Detect ObjC generic type parameters (ObjectType, KeyType, ElementType, etc.)
/// vs framework-prefixed enum aliases (AXValueType, NSBezelType, etc.).
///
/// Generic type params start with a single uppercase letter followed by lowercase
/// (e.g., "ObjectType", "KeyType"). Framework-prefixed aliases start with 2+
/// uppercase letters (e.g., "NSType", "AXValueType", "CGColorRenderingIntent").
pub fn is_generic_type_param(name: &str) -> bool {
    let mut chars = name.chars();
    match (chars.next(), chars.next()) {
        (Some(a), Some(b)) => a.is_ascii_uppercase() && b.is_ascii_lowercase(),
        _ => false,
    }
}

/// Racket FFI type mapper.
///
/// Maps IR types to Racket FFI type expressions (`_id`, `_uint64`, `_NSRect`, etc.).
pub struct RacketFfiTypeMapper;

/// Translate a primitive name into the Racket FFI type string. Handles:
/// - Canonical names produced by the ObjC extractor's `map_primitive_name`
///   (`"int8"`, `"uint32"`, `"int64"`, etc.).
/// - Lowercased `NSInteger`/`NSUInteger` as `"nsinteger"`/`"nsuinteger"`.
///   The ObjC extractor maps these to `"int64"`/`"uint64"` at extraction
///   time, so these arms are defence-in-depth, kept in lockstep with
///   `map_contract`'s primitive arm in emit_functions.rs.
///
/// Returns `None` for names with no fixed-width mapping — callers decide
/// the appropriate fallback (`_pointer` for primitive slots, `_uint64`
/// for enum-alias slots).
fn racket_ffi_type_for_primitive(name: Option<&String>) -> Option<&'static str> {
    match name?.as_str() {
        "bool" => Some("_bool"),
        "int8" => Some("_int8"),
        "uint8" => Some("_uint8"),
        "int16" => Some("_int16"),
        "uint16" => Some("_uint16"),
        "int32" => Some("_int32"),
        "uint32" => Some("_uint32"),
        "int64" | "nsinteger" => Some("_int64"),
        "uint64" | "nsuinteger" => Some("_uint64"),
        "float" => Some("_float"),
        "double" => Some("_double"),
        _ => None,
    }
}

impl FfiTypeMapper for RacketFfiTypeMapper {
    fn map_type(&self, type_ref: &TypeRef, is_return_type: bool) -> String {
        match &type_ref.kind {
            TypeRefKind::Primitive { name } => {
                let normalized = normalize_primitive_name(name);
                if normalized == "void" {
                    return if is_return_type {
                        "_void".into()
                    } else {
                        "_pointer".into()
                    };
                }
                if normalized == "pointer" {
                    return "_pointer".into();
                }
                racket_ffi_type_for_primitive(Some(&normalized))
                    .map(str::to_string)
                    .unwrap_or_else(|| "_pointer".to_string())
            }
            TypeRefKind::Class { .. } | TypeRefKind::Id | TypeRefKind::Instancetype => {
                "_id".to_string()
            }
            TypeRefKind::Selector => "_pointer".to_string(),
            TypeRefKind::ClassRef => "_pointer".to_string(),
            TypeRefKind::Block { .. } => "_pointer".to_string(),
            TypeRefKind::CString => "_string".to_string(),
            TypeRefKind::Pointer => "_pointer".to_string(),
            TypeRefKind::Struct { name } => map_geometry_struct_alias(name)
                .map(|s| s.to_string())
                .unwrap_or_else(|| "_pointer".to_string()),
            TypeRefKind::FunctionPointer { .. } => "_pointer".to_string(),
            TypeRefKind::Alias {
                name,
                underlying_primitive,
                ..
            } => {
                // Geometry struct typedefs (NSRect, CGPoint, etc.) → cstruct types
                if let Some(ffi_type) = map_geometry_struct_alias(name) {
                    return ffi_type.to_string();
                }
                // Generic ObjC type params (ObjectType, KeyType, ElementType)
                // start with a single uppercase letter followed by lowercase.
                // Framework-prefixed aliases (NSStringEncoding, AXValueType,
                // CGColorRenderingIntent) start with 2+ uppercase letters.
                if name.ends_with("Type") && is_generic_type_param(name) {
                    return "_id".to_string();
                }
                // Prefer the enum's extracted underlying width — maps
                // CF_ENUM(uint32_t, AXValueType) to _uint32 instead of the
                // historical _uint64 default, and NS_ENUM(NSInteger, …) to
                // _int64 (signed) instead of _uint64 (unsigned).
                racket_ffi_type_for_primitive(underlying_primitive.as_ref())
                    .map(str::to_string)
                    .unwrap_or_else(|| "_uint64".to_string())
            }
        }
    }
}

/// Translate an `ffi/unsafe` Racket FFI spelling to its ffi2 equivalent.
///
/// ffi2 drops `ffi/unsafe`'s leading-underscore convention for a `_t` suffix
/// (`_uint64` → `uint64_t`, `_double` → `double_t`; research doc §3.3). The
/// translation is mechanical — strip the leading `_`, append `_t` — for every
/// spelling [`RacketFfiTypeMapper`] can emit *except* the two that have no
/// underscore-renamed ffi2 form:
///
/// - `_pointer` → `ptr_t` (not `pointer_t`)
/// - `_id` → `ptr_t` — ffi2 has **no** Objective-C `id` concept; on the
///   C-function side of the seam an object crosses as an opaque `ptr_t` (the
///   shape the generated native dispatch entries take, per the 010 spike). The
///   `_id` *tag* is re-applied at the seam by `ffi2-ptr->id` (runtime
///   `ffi2-seam.rkt`) only where the value re-enters the retained `tell` layer.
///
/// Geometry struct spellings (`_NSRect` → `NSRect_t`, …) fall through the
/// generic rule, matching the `define-ffi2-type NSRect_t (struct_t …)` names
/// the emitter cutover (leaf 050) generates.
pub fn ffi_unsafe_to_ffi2(spelling: &str) -> String {
    match spelling {
        // ffi2 has no `id`; objects/pointers cross as the opaque `ptr_t`.
        "_pointer" | "_id" => "ptr_t".to_string(),
        // Generic rule: strip the leading `_`, append `_t`. Correct for every
        // base type (`_void`→`void_t`, `_uint64`→`uint64_t`, `_string`→
        // `string_t`, `_bool`→`bool_t`, …) and every geometry struct
        // (`_NSRect`→`NSRect_t`, …) the Racket mapper emits.
        _ => match spelling.strip_prefix('_') {
            Some(stem) => format!("{stem}_t"),
            // Defensive: the Racket mapper always emits a `_`-prefixed spelling,
            // so this arm is unreachable in practice. Pass through unchanged
            // rather than mangle an unexpected input.
            None => spelling.to_string(),
        },
    }
}

/// ffi2 Racket FFI type mapper — the seam counterpart of [`RacketFfiTypeMapper`].
///
/// Produces ffi2 type spellings (`uint64_t`, `ptr_t`, `double_t`, `NSRect_t`, …)
/// for the C-function layer (`emit_functions.rs`, `emit_constants.rs`) and the
/// thin ffi2 bindings into the generated native dispatch library (leaf 040).
///
/// Implemented by delegating to [`RacketFfiTypeMapper`] and translating the
/// resulting spelling via [`ffi_unsafe_to_ffi2`], so the two mappers stay in
/// lockstep by construction — a new IR-shape handled in the `ffi/unsafe` mapper
/// is automatically reflected here.
pub struct RacketFfi2TypeMapper;

impl FfiTypeMapper for RacketFfi2TypeMapper {
    fn map_type(&self, type_ref: &TypeRef, is_return_type: bool) -> String {
        ffi_unsafe_to_ffi2(&RacketFfiTypeMapper.map_type(type_ref, is_return_type))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn make_type(kind: TypeRefKind) -> TypeRef {
        TypeRef {
            nullable: false,
            kind,
        }
    }

    #[test]
    fn test_racket_nsinteger_nsuinteger_primitives() {
        // Defence-in-depth: NSInteger/NSUInteger as raw Primitive names should
        // map to the same FFI types as their canonical int64/uint64 equivalents.
        // NSInteger is 64-bit on macOS arm64.
        let m = RacketFfiTypeMapper;
        assert_eq!(
            m.map_type(
                &make_type(TypeRefKind::Primitive {
                    name: "NSInteger".into()
                }),
                false
            ),
            "_int64"
        );
        assert_eq!(
            m.map_type(
                &make_type(TypeRefKind::Primitive {
                    name: "NSUInteger".into()
                }),
                false
            ),
            "_uint64"
        );
    }

    #[test]
    fn test_racket_primitives() {
        let m = RacketFfiTypeMapper;
        assert_eq!(
            m.map_type(
                &make_type(TypeRefKind::Primitive {
                    name: "void".into()
                }),
                true
            ),
            "_void"
        );
        assert_eq!(
            m.map_type(
                &make_type(TypeRefKind::Primitive {
                    name: "void".into()
                }),
                false
            ),
            "_pointer"
        );
        assert_eq!(
            m.map_type(
                &make_type(TypeRefKind::Primitive {
                    name: "bool".into()
                }),
                false
            ),
            "_bool"
        );
        assert_eq!(
            m.map_type(
                &make_type(TypeRefKind::Primitive {
                    name: "uint64".into()
                }),
                false
            ),
            "_uint64"
        );
    }

    #[test]
    fn test_racket_object_types() {
        let m = RacketFfiTypeMapper;
        assert_eq!(
            m.map_type(
                &make_type(TypeRefKind::Class {
                    name: "NSString".into(),
                    framework: None,
                    params: vec![],
                }),
                false,
            ),
            "_id"
        );
        assert_eq!(m.map_type(&make_type(TypeRefKind::Id), false), "_id");
        assert_eq!(
            m.map_type(&make_type(TypeRefKind::Instancetype), true),
            "_id"
        );
    }

    #[test]
    fn test_racket_struct_types() {
        let m = RacketFfiTypeMapper;
        assert_eq!(
            m.map_type(
                &make_type(TypeRefKind::Struct {
                    name: "NSRect".into()
                }),
                false
            ),
            "_NSRect"
        );
        assert_eq!(
            m.map_type(
                &make_type(TypeRefKind::Struct {
                    name: "CGRect".into()
                }),
                false
            ),
            "_NSRect"
        );
        assert_eq!(
            m.map_type(
                &make_type(TypeRefKind::Struct {
                    name: "NSRange".into()
                }),
                false
            ),
            "_NSRange"
        );
        assert_eq!(
            m.map_type(
                &make_type(TypeRefKind::Struct {
                    name: "NSEdgeInsets".into()
                }),
                false
            ),
            "_NSEdgeInsets"
        );
        assert_eq!(
            m.map_type(
                &make_type(TypeRefKind::Struct {
                    name: "CGAffineTransform".into()
                }),
                false
            ),
            "_CGAffineTransform"
        );
        assert_eq!(
            m.map_type(
                &make_type(TypeRefKind::Struct {
                    name: "CGVector".into()
                }),
                false
            ),
            "_CGVector"
        );
        assert_eq!(
            m.map_type(
                &make_type(TypeRefKind::Struct {
                    name: "NSDirectionalEdgeInsets".into()
                }),
                false
            ),
            "_NSDirectionalEdgeInsets"
        );
        assert_eq!(
            m.map_type(
                &make_type(TypeRefKind::Struct {
                    name: "NSAffineTransformStruct".into()
                }),
                false
            ),
            "_NSAffineTransformStruct"
        );
        assert_eq!(
            m.map_type(
                &make_type(TypeRefKind::Struct {
                    name: "SomeOtherStruct".into()
                }),
                false
            ),
            "_pointer"
        );
    }

    #[test]
    fn racket_alias_uses_underlying_uint32_when_known() {
        // CF_ENUM(uint32_t, AXValueType) → extraction resolves underlying
        // to "uint32" → FFI picks _uint32, not the _uint64 default.
        let m = RacketFfiTypeMapper;
        assert_eq!(
            m.map_type(
                &make_type(TypeRefKind::Alias {
                    name: "AXValueType".into(),
                    framework: None,
                    underlying_primitive: Some("uint32".into()),
                }),
                false,
            ),
            "_uint32"
        );
    }

    #[test]
    fn racket_alias_uses_underlying_int64_for_nsinteger_enum() {
        // NS_ENUM(NSInteger, SomeEnum) → underlying_primitive = "int64" on
        // macOS arm64. The old code returned _uint64 — silently wrong for
        // negative enum values. The fix flips to signed.
        let m = RacketFfiTypeMapper;
        assert_eq!(
            m.map_type(
                &make_type(TypeRefKind::Alias {
                    name: "NSWindowLevel".into(),
                    framework: None,
                    underlying_primitive: Some("int64".into()),
                }),
                false,
            ),
            "_int64"
        );
    }

    #[test]
    fn racket_alias_falls_back_to_uint64_when_underlying_unknown() {
        // Preserves the historical default for aliases whose underlying
        // type wasn't resolved at extraction (older IR, non-enum aliases).
        let m = RacketFfiTypeMapper;
        assert_eq!(
            m.map_type(
                &make_type(TypeRefKind::Alias {
                    name: "SomeLegacyAlias".into(),
                    framework: None,
                    underlying_primitive: None,
                }),
                false,
            ),
            "_uint64"
        );
    }

    #[test]
    fn test_racket_alias_types() {
        let m = RacketFfiTypeMapper;
        // Generic type param → _id
        assert_eq!(
            m.map_type(
                &make_type(TypeRefKind::Alias {
                    name: "ObjectType".into(),
                    framework: None,
                    underlying_primitive: None,
                }),
                false,
            ),
            "_id"
        );
        // Framework-prefixed alias → _uint64
        assert_eq!(
            m.map_type(
                &make_type(TypeRefKind::Alias {
                    name: "NSStringEncoding".into(),
                    framework: None,
                    underlying_primitive: None,
                }),
                false,
            ),
            "_uint64"
        );
    }

    #[test]
    fn test_racket_geometry_struct_aliases() {
        let m = RacketFfiTypeMapper;
        // NSRect alias → _NSRect (libclang emits these as Alias, not Struct)
        assert_eq!(
            m.map_type(
                &make_type(TypeRefKind::Alias {
                    name: "NSRect".into(),
                    framework: None,
                    underlying_primitive: None,
                }),
                false,
            ),
            "_NSRect"
        );
        // CGRect alias → _NSRect
        assert_eq!(
            m.map_type(
                &make_type(TypeRefKind::Alias {
                    name: "CGRect".into(),
                    framework: None,
                    underlying_primitive: None,
                }),
                false,
            ),
            "_NSRect"
        );
        // NSPoint alias → _NSPoint
        assert_eq!(
            m.map_type(
                &make_type(TypeRefKind::Alias {
                    name: "NSPoint".into(),
                    framework: None,
                    underlying_primitive: None,
                }),
                false,
            ),
            "_NSPoint"
        );
        // NSSize alias → _NSSize
        assert_eq!(
            m.map_type(
                &make_type(TypeRefKind::Alias {
                    name: "NSSize".into(),
                    framework: None,
                    underlying_primitive: None,
                }),
                false,
            ),
            "_NSSize"
        );
        // NSRange alias → _NSRange
        assert_eq!(
            m.map_type(
                &make_type(TypeRefKind::Alias {
                    name: "NSRange".into(),
                    framework: None,
                    underlying_primitive: None,
                }),
                false,
            ),
            "_NSRange"
        );
        // NSEdgeInsets alias → _NSEdgeInsets
        assert_eq!(
            m.map_type(
                &make_type(TypeRefKind::Alias {
                    name: "NSEdgeInsets".into(),
                    framework: None,
                    underlying_primitive: None,
                }),
                false,
            ),
            "_NSEdgeInsets"
        );
        // NSAffineTransformStruct alias → _NSAffineTransformStruct
        assert_eq!(
            m.map_type(
                &make_type(TypeRefKind::Alias {
                    name: "NSAffineTransformStruct".into(),
                    framework: None,
                    underlying_primitive: None,
                }),
                false,
            ),
            "_NSAffineTransformStruct"
        );
        // CGAffineTransform alias → _CGAffineTransform
        assert_eq!(
            m.map_type(
                &make_type(TypeRefKind::Alias {
                    name: "CGAffineTransform".into(),
                    framework: None,
                    underlying_primitive: None,
                }),
                false,
            ),
            "_CGAffineTransform"
        );
        // CGVector alias → _CGVector
        assert_eq!(
            m.map_type(
                &make_type(TypeRefKind::Alias {
                    name: "CGVector".into(),
                    framework: None,
                    underlying_primitive: None,
                }),
                false,
            ),
            "_CGVector"
        );
        // NSDirectionalEdgeInsets alias → _NSDirectionalEdgeInsets
        assert_eq!(
            m.map_type(
                &make_type(TypeRefKind::Alias {
                    name: "NSDirectionalEdgeInsets".into(),
                    framework: None,
                    underlying_primitive: None,
                }),
                false,
            ),
            "_NSDirectionalEdgeInsets"
        );
    }

    #[test]
    fn test_qualified_primitive_names() {
        let m = RacketFfiTypeMapper;
        // Swift.Void as return type → _void
        assert_eq!(
            m.map_type(
                &make_type(TypeRefKind::Primitive {
                    name: "Swift.Void".into()
                }),
                true
            ),
            "_void"
        );
        // Swift.Void as parameter → _pointer (same as unqualified void)
        assert_eq!(
            m.map_type(
                &make_type(TypeRefKind::Primitive {
                    name: "Swift.Void".into()
                }),
                false
            ),
            "_pointer"
        );
        // Swift.Bool → _bool
        assert_eq!(
            m.map_type(
                &make_type(TypeRefKind::Primitive {
                    name: "Swift.Bool".into()
                }),
                false
            ),
            "_bool"
        );
        // Swift.Double → _double
        assert_eq!(
            m.map_type(
                &make_type(TypeRefKind::Primitive {
                    name: "Swift.Double".into()
                }),
                false
            ),
            "_double"
        );
        // Swift.Float → _float
        assert_eq!(
            m.map_type(
                &make_type(TypeRefKind::Primitive {
                    name: "Swift.Float".into()
                }),
                false
            ),
            "_float"
        );
        // Unqualified names still work
        assert_eq!(
            m.map_type(
                &make_type(TypeRefKind::Primitive {
                    name: "uint64".into()
                }),
                false
            ),
            "_uint64"
        );
        // Unknown qualified primitive → _pointer (collection-level issue, not mapper's job)
        assert_eq!(
            m.map_type(
                &make_type(TypeRefKind::Primitive {
                    name: "CoreFoundation.CFStringEncoding".into()
                }),
                false
            ),
            "_pointer"
        );
    }

    #[test]
    fn test_is_void_with_qualified_names() {
        let m = RacketFfiTypeMapper;
        assert!(m.is_void(&make_type(TypeRefKind::Primitive {
            name: "void".into()
        })));
        assert!(m.is_void(&make_type(TypeRefKind::Primitive {
            name: "Swift.Void".into()
        })));
        assert!(!m.is_void(&make_type(TypeRefKind::Primitive {
            name: "bool".into()
        })));
    }

    #[test]
    fn test_trait_helper_methods() {
        let m = RacketFfiTypeMapper;
        assert!(m.is_object_type(&make_type(TypeRefKind::Id)));
        assert!(m.is_object_type(&make_type(TypeRefKind::Class {
            name: "NSString".into(),
            framework: None,
            params: vec![],
        })));
        assert!(!m.is_object_type(&make_type(TypeRefKind::Primitive {
            name: "int32".into()
        })));
        assert!(m.is_block_type(&make_type(TypeRefKind::Block {
            params: vec![],
            return_type: Box::new(TypeRef::void()),
        })));
        assert!(m.is_void(&TypeRef::void()));
        assert!(m.is_struct_type(&make_type(TypeRefKind::Struct {
            name: "NSRect".into()
        })));
        // Alias struct types recognized as structs
        assert!(m.is_struct_type(&make_type(TypeRefKind::Alias {
            name: "NSRect".into(),
            framework: None,
            underlying_primitive: None,
        })));
        assert!(m.is_struct_type(&make_type(TypeRefKind::Alias {
            name: "CGPoint".into(),
            framework: None,
            underlying_primitive: None,
        })));
        assert!(m.is_struct_type(&make_type(TypeRefKind::Alias {
            name: "NSEdgeInsets".into(),
            framework: None,
            underlying_primitive: None,
        })));
        assert!(m.is_struct_type(&make_type(TypeRefKind::Alias {
            name: "CGAffineTransform".into(),
            framework: None,
            underlying_primitive: None,
        })));
        assert!(m.is_struct_type(&make_type(TypeRefKind::Alias {
            name: "CGVector".into(),
            framework: None,
            underlying_primitive: None,
        })));
        assert!(m.is_struct_type(&make_type(TypeRefKind::Alias {
            name: "NSDirectionalEdgeInsets".into(),
            framework: None,
            underlying_primitive: None,
        })));
        assert!(!m.is_struct_type(&make_type(TypeRefKind::Alias {
            name: "NSStringEncoding".into(),
            framework: None,
            underlying_primitive: None,
        })));
    }

    #[test]
    fn test_generic_type_param_detection() {
        // Generic ObjC type params: single uppercase then lowercase
        assert!(is_generic_type_param("ObjectType"));
        assert!(is_generic_type_param("KeyType"));
        assert!(is_generic_type_param("ValueType"));
        assert!(is_generic_type_param("ElementType"));
        assert!(is_generic_type_param("ContentType"));
        assert!(is_generic_type_param("ResultType"));

        // Framework-prefixed: 2+ uppercase letters at start
        assert!(!is_generic_type_param("NSBezelType"));
        assert!(!is_generic_type_param("AXValueType"));
        assert!(!is_generic_type_param("CGColorRenderingIntent"));
        assert!(!is_generic_type_param("CFStringEncoding"));
        assert!(!is_generic_type_param("WKContentMode"));
        assert!(!is_generic_type_param("MTLResourceType"));
    }

    // --- ffi2 type mapper (RacketFfi2TypeMapper / ffi_unsafe_to_ffi2) ---

    #[test]
    fn ffi2_translation_base_types() {
        // The closed set of `ffi/unsafe` spellings the Racket mapper emits,
        // each translated to its ffi2 form. Base types: strip `_`, append `_t`.
        assert_eq!(ffi_unsafe_to_ffi2("_void"), "void_t");
        assert_eq!(ffi_unsafe_to_ffi2("_bool"), "bool_t");
        assert_eq!(ffi_unsafe_to_ffi2("_int8"), "int8_t");
        assert_eq!(ffi_unsafe_to_ffi2("_uint8"), "uint8_t");
        assert_eq!(ffi_unsafe_to_ffi2("_int16"), "int16_t");
        assert_eq!(ffi_unsafe_to_ffi2("_uint16"), "uint16_t");
        assert_eq!(ffi_unsafe_to_ffi2("_int32"), "int32_t");
        assert_eq!(ffi_unsafe_to_ffi2("_uint32"), "uint32_t");
        assert_eq!(ffi_unsafe_to_ffi2("_int64"), "int64_t");
        assert_eq!(ffi_unsafe_to_ffi2("_uint64"), "uint64_t");
        assert_eq!(ffi_unsafe_to_ffi2("_float"), "float_t");
        assert_eq!(ffi_unsafe_to_ffi2("_double"), "double_t");
        assert_eq!(ffi_unsafe_to_ffi2("_string"), "string_t");
    }

    #[test]
    fn ffi2_translation_pointer_and_id_collapse_to_ptr_t() {
        // ffi2 has no `id`; both `_pointer` and `_id` cross as the opaque
        // `ptr_t` on the C-function side of the seam. (`pointer_t`/`id_t` would
        // be the naive strip+suffix output — both wrong.)
        assert_eq!(ffi_unsafe_to_ffi2("_pointer"), "ptr_t");
        assert_eq!(ffi_unsafe_to_ffi2("_id"), "ptr_t");
    }

    #[test]
    fn ffi2_translation_geometry_structs() {
        assert_eq!(ffi_unsafe_to_ffi2("_NSRect"), "NSRect_t");
        assert_eq!(ffi_unsafe_to_ffi2("_NSPoint"), "NSPoint_t");
        assert_eq!(ffi_unsafe_to_ffi2("_NSSize"), "NSSize_t");
        assert_eq!(ffi_unsafe_to_ffi2("_NSRange"), "NSRange_t");
        assert_eq!(ffi_unsafe_to_ffi2("_NSEdgeInsets"), "NSEdgeInsets_t");
        assert_eq!(
            ffi_unsafe_to_ffi2("_NSDirectionalEdgeInsets"),
            "NSDirectionalEdgeInsets_t"
        );
        assert_eq!(
            ffi_unsafe_to_ffi2("_NSAffineTransformStruct"),
            "NSAffineTransformStruct_t"
        );
        assert_eq!(
            ffi_unsafe_to_ffi2("_CGAffineTransform"),
            "CGAffineTransform_t"
        );
        assert_eq!(ffi_unsafe_to_ffi2("_CGVector"), "CGVector_t");
    }

    #[test]
    fn ffi2_mapper_matches_racket_mapper_in_lockstep() {
        // RacketFfi2TypeMapper must equal ffi_unsafe_to_ffi2 ∘ RacketFfiTypeMapper
        // across a representative spread of IR shapes — proving the delegation
        // wiring is intact (not just the string table).
        let unsafe_m = RacketFfiTypeMapper;
        let ffi2_m = RacketFfi2TypeMapper;
        let cases: Vec<(TypeRef, bool)> = vec![
            (
                make_type(TypeRefKind::Primitive {
                    name: "void".into(),
                }),
                true,
            ),
            (
                make_type(TypeRefKind::Primitive {
                    name: "void".into(),
                }),
                false,
            ),
            (
                make_type(TypeRefKind::Primitive {
                    name: "uint64".into(),
                }),
                false,
            ),
            (
                make_type(TypeRefKind::Primitive {
                    name: "double".into(),
                }),
                false,
            ),
            (
                make_type(TypeRefKind::Primitive {
                    name: "bool".into(),
                }),
                false,
            ),
            (make_type(TypeRefKind::Id), false),
            (
                make_type(TypeRefKind::Class {
                    name: "NSString".into(),
                    framework: None,
                    params: vec![],
                }),
                true,
            ),
            (make_type(TypeRefKind::CString), false),
            (make_type(TypeRefKind::Pointer), false),
            (make_type(TypeRefKind::Selector), false),
            (
                make_type(TypeRefKind::Struct {
                    name: "NSRect".into(),
                }),
                false,
            ),
            (
                make_type(TypeRefKind::Alias {
                    name: "AXValueType".into(),
                    framework: None,
                    underlying_primitive: Some("uint32".into()),
                }),
                false,
            ),
            (
                make_type(TypeRefKind::Alias {
                    name: "NSWindowLevel".into(),
                    framework: None,
                    underlying_primitive: Some("int64".into()),
                }),
                false,
            ),
        ];
        for (t, is_ret) in &cases {
            assert_eq!(
                ffi2_m.map_type(t, *is_ret),
                ffi_unsafe_to_ffi2(&unsafe_m.map_type(t, *is_ret)),
                "ffi2 mapper drifted from ffi/unsafe mapper for {t:?} (is_ret={is_ret})"
            );
        }
    }

    #[test]
    fn ffi2_mapper_object_and_struct_spellings() {
        // End-to-end through the IR: objects → ptr_t, geometry → struct_t name,
        // signed/unsigned enum widths preserved.
        let m = RacketFfi2TypeMapper;
        assert_eq!(m.map_type(&make_type(TypeRefKind::Id), false), "ptr_t");
        assert_eq!(
            m.map_type(
                &make_type(TypeRefKind::Class {
                    name: "NSView".into(),
                    framework: None,
                    params: vec![],
                }),
                true,
            ),
            "ptr_t"
        );
        assert_eq!(
            m.map_type(
                &make_type(TypeRefKind::Struct {
                    name: "CGRect".into()
                }),
                false
            ),
            "NSRect_t"
        );
        assert_eq!(
            m.map_type(
                &make_type(TypeRefKind::Primitive {
                    name: "void".into()
                }),
                true
            ),
            "void_t"
        );
        assert_eq!(
            m.map_type(
                &make_type(TypeRefKind::Primitive {
                    name: "void".into()
                }),
                false
            ),
            "ptr_t"
        );
        assert_eq!(
            m.map_type(&make_type(TypeRefKind::CString), false),
            "string_t"
        );
        assert_eq!(
            m.map_type(
                &make_type(TypeRefKind::Alias {
                    name: "NSWindowLevel".into(),
                    framework: None,
                    underlying_primitive: Some("int64".into()),
                }),
                false,
            ),
            "int64_t"
        );
    }

    #[test]
    fn test_framework_prefixed_alias_maps_to_uint64() {
        let m = RacketFfiTypeMapper;
        // AXValueType is a framework-prefixed enum alias → _uint64
        assert_eq!(
            m.map_type(
                &make_type(TypeRefKind::Alias {
                    name: "AXValueType".into(),
                    framework: None,
                    underlying_primitive: None,
                }),
                false
            ),
            "_uint64"
        );
        // ObjectType is a generic type param → _id
        assert_eq!(
            m.map_type(
                &make_type(TypeRefKind::Alias {
                    name: "ObjectType".into(),
                    framework: None,
                    underlying_primitive: None,
                }),
                false
            ),
            "_id"
        );
    }
}
