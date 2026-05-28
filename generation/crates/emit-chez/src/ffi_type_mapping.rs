//! Chez `foreign-procedure` type mapping.
//!
//! Maps IR [`TypeRef`] values to Chez Scheme FFI type tokens that go inside
//! `(foreign-procedure name (arg-types ...) ret-type)`. ObjC `id`, `Class`,
//! `SEL` and blocks all use `void*`; primitives map to Chez's fixed-width
//! integer / float keywords (`unsigned-64`, `integer-64`, `double-float`,
//! …). Geometry struct typedefs map to `(& <ftype>)` so values pass by
//! reference as ftype-pointers per `runtime/types.sls`.

use apianyware_macos_emit::ffi_type_mapping::{is_generic_type_param, FfiTypeMapper};
use apianyware_macos_types::type_ref::{TypeRef, TypeRefKind};

pub struct ChezFfiTypeMapper;

fn normalize(name: &str) -> String {
    let unqualified = match name.rsplit_once('.') {
        Some((_, suffix)) => suffix,
        None => name,
    };
    unqualified.to_ascii_lowercase()
}

fn chez_type_for_primitive(name: &str) -> Option<&'static str> {
    match name {
        "bool" => Some("boolean"),
        "int8" => Some("integer-8"),
        "uint8" => Some("unsigned-8"),
        "int16" => Some("integer-16"),
        "uint16" => Some("unsigned-16"),
        "int32" => Some("integer-32"),
        "uint32" => Some("unsigned-32"),
        "int64" | "nsinteger" => Some("integer-64"),
        "uint64" | "nsuinteger" => Some("unsigned-64"),
        "float" => Some("float"),
        "double" => Some("double-float"),
        _ => None,
    }
}

/// Geometry struct typedefs pass by reference as `ftype-pointer` values
/// in Chez. The `foreign-procedure` form spells that as `(& <ftype>)`.
fn map_geometry_alias(name: &str) -> Option<&'static str> {
    match name {
        "NSRect" | "CGRect" => Some("(& NSRect)"),
        "NSPoint" | "CGPoint" => Some("(& NSPoint)"),
        "NSSize" | "CGSize" => Some("(& NSSize)"),
        "NSRange" => Some("(& NSRange)"),
        "NSEdgeInsets" => Some("(& NSEdgeInsets)"),
        "NSDirectionalEdgeInsets" => Some("(& NSDirectionalEdgeInsets)"),
        "NSAffineTransformStruct" => Some("(& NSAffineTransformStruct)"),
        "CGAffineTransform" => Some("(& CGAffineTransform)"),
        "CGVector" => Some("(& CGVector)"),
        _ => None,
    }
}

pub fn is_known_geometry_alias(name: &str) -> bool {
    map_geometry_alias(name).is_some()
}

/// Geometry struct that exceeds the arm64 "fits in two return registers"
/// threshold (16 bytes). When such a struct is the return value of an
/// `objc_msgSend` call, the arm64 ABI uses `x8` for an indirect-result
/// pointer — Chez's `foreign-procedure` exposes that as an explicit leading
/// argument of type `(& <ftype>)`. Returns the ftype name (e.g. `"NSRect"`)
/// so the emitter can spell the hidden-arg type and the allocation site.
///
/// Sizes (from `runtime/types.sls`, all CGFloat = 8 bytes):
///   - 16 bytes (fits): NSPoint, NSSize, NSRange, CGVector
///   - 32 bytes (does not fit): NSRect, NSEdgeInsets, NSDirectionalEdgeInsets
///   - 48 bytes (does not fit): NSAffineTransformStruct, CGAffineTransform
pub fn large_struct_return_ftype(name: &str) -> Option<&'static str> {
    match name {
        "NSRect" | "CGRect" => Some("NSRect"),
        "NSEdgeInsets" => Some("NSEdgeInsets"),
        "NSDirectionalEdgeInsets" => Some("NSDirectionalEdgeInsets"),
        "NSAffineTransformStruct" => Some("NSAffineTransformStruct"),
        "CGAffineTransform" => Some("CGAffineTransform"),
        _ => None,
    }
}

/// True when a return [`TypeRef`] is a struct-by-value that exceeds the
/// 16-byte threshold described in [`large_struct_return_ftype`].
pub fn return_needs_indirect_result(t: &TypeRef) -> Option<&'static str> {
    let name = match &t.kind {
        TypeRefKind::Struct { name } => name.as_str(),
        TypeRefKind::Alias { name, .. } => name.as_str(),
        _ => return None,
    };
    large_struct_return_ftype(name)
}

impl FfiTypeMapper for ChezFfiTypeMapper {
    fn map_type(&self, type_ref: &TypeRef, is_return_type: bool) -> String {
        match &type_ref.kind {
            TypeRefKind::Primitive { name } => {
                let n = normalize(name);
                if n == "void" {
                    return if is_return_type { "void".into() } else { "void*".into() };
                }
                if n == "pointer" {
                    return "void*".into();
                }
                chez_type_for_primitive(&n)
                    .map(str::to_string)
                    .unwrap_or_else(|| "void*".to_string())
            }
            TypeRefKind::Class { .. } | TypeRefKind::Id | TypeRefKind::Instancetype => {
                "void*".to_string()
            }
            TypeRefKind::Selector => "void*".to_string(),
            TypeRefKind::ClassRef => "void*".to_string(),
            TypeRefKind::Block { .. } => "void*".to_string(),
            TypeRefKind::CString => "string".to_string(),
            TypeRefKind::Pointer => "void*".to_string(),
            TypeRefKind::Struct { name } => map_geometry_alias(name)
                .map(str::to_string)
                .unwrap_or_else(|| "void*".to_string()),
            TypeRefKind::FunctionPointer { .. } => "void*".to_string(),
            TypeRefKind::Alias {
                name,
                underlying_primitive,
                ..
            } => {
                if let Some(t) = map_geometry_alias(name) {
                    return t.to_string();
                }
                if name.ends_with("Type") && is_generic_type_param(name) {
                    return "void*".to_string();
                }
                chez_type_for_primitive(
                    underlying_primitive
                        .as_ref()
                        .map(|s| s.to_ascii_lowercase())
                        .as_deref()
                        .unwrap_or(""),
                )
                .map(str::to_string)
                .unwrap_or_else(|| "unsigned-64".to_string())
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn ty(kind: TypeRefKind) -> TypeRef {
        TypeRef {
            nullable: false,
            kind,
        }
    }

    #[test]
    fn void_return_vs_param() {
        let m = ChezFfiTypeMapper;
        assert_eq!(
            m.map_type(&ty(TypeRefKind::Primitive { name: "void".into() }), true),
            "void"
        );
        assert_eq!(
            m.map_type(&ty(TypeRefKind::Primitive { name: "void".into() }), false),
            "void*"
        );
    }

    #[test]
    fn primitives() {
        let m = ChezFfiTypeMapper;
        assert_eq!(
            m.map_type(&ty(TypeRefKind::Primitive { name: "uint64".into() }), false),
            "unsigned-64"
        );
        assert_eq!(
            m.map_type(&ty(TypeRefKind::Primitive { name: "int64".into() }), false),
            "integer-64"
        );
        assert_eq!(
            m.map_type(&ty(TypeRefKind::Primitive { name: "double".into() }), false),
            "double-float"
        );
        assert_eq!(
            m.map_type(&ty(TypeRefKind::Primitive { name: "bool".into() }), false),
            "boolean"
        );
    }

    #[test]
    fn object_types_are_void_ptr() {
        let m = ChezFfiTypeMapper;
        assert_eq!(m.map_type(&ty(TypeRefKind::Id), false), "void*");
        assert_eq!(m.map_type(&ty(TypeRefKind::Instancetype), false), "void*");
        assert_eq!(
            m.map_type(
                &ty(TypeRefKind::Class {
                    name: "NSString".into(),
                    framework: None,
                    params: vec![]
                }),
                false
            ),
            "void*"
        );
    }

    #[test]
    fn geometry_aliases() {
        let m = ChezFfiTypeMapper;
        assert_eq!(
            m.map_type(
                &ty(TypeRefKind::Alias {
                    name: "NSRect".into(),
                    framework: None,
                    underlying_primitive: None,
                }),
                false
            ),
            "(& NSRect)"
        );
    }
}
