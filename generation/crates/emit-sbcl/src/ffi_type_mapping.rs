//! IR type → `sb-alien` type mapping for the SBCL compiled-FFI seam (ADR-0015).
//!
//! Produces the alien-type spelling that goes in a `define-alien-routine` /
//! `alien-funcall` slot, for both the direct `objc_msgSend` crossing and the
//! `aw_sbcl_*` trampoline bindings. The spellings are grounded in the
//! `030-design` MOP + threading spikes, which loaded first-hand under SBCL 2.6.5
//! (arm64):
//!
//! - ObjC `id` / `Class` / `SEL`, blocks, raw pointers → `system-area-pointer`
//!   (every `objc_getClass` / `objc_allocateClassPair` / callback slot in the
//!   spikes uses `sb-alien:system-area-pointer`).
//! - C strings → `sb-alien:c-string` (the spikes' `class_getName` etc.).
//! - `void` return → `sb-alien:void`; fixed-width scalars → `(sb-alien:signed N)`
//!   / `(sb-alien:unsigned N)` / `sb-alien:float` / `sb-alien:double`; ObjC `BOOL`
//!   → `(sb-alien:boolean 8)` (1-byte on arm64).
//! - geometry structs → a by-value `(sb-alien:struct <name>)`; the matching
//!   `define-alien-type` is the runtime's job (leaf 050), which must also confirm
//!   `sb-alien` by-value struct passing for these (the method filter defers all
//!   other structs until then).
//!
//! All operators are written fully `sb-alien:`-qualified so generated forms are
//! robust regardless of the generated file's package imports.

use apianyware_macos_emit::ffi_type_mapping::{is_generic_type_param, FfiTypeMapper};
use apianyware_macos_types::type_ref::{TypeRef, TypeRefKind};

/// The opaque-pointer alien type. ObjC `id` / `Class` / `SEL`, blocks, function
/// pointers, and raw C pointers all cross as this (spike-verified).
pub const SAP: &str = "sb-alien:system-area-pointer";

pub struct SbclFfiTypeMapper;

impl FfiTypeMapper for SbclFfiTypeMapper {
    fn map_type(&self, type_ref: &TypeRef, is_return_type: bool) -> String {
        match &type_ref.kind {
            TypeRefKind::Primitive { name } => {
                let n = normalize(name);
                if n == "void" {
                    return if is_return_type {
                        "sb-alien:void".into()
                    } else {
                        SAP.into()
                    };
                }
                if n == "pointer" {
                    return SAP.into();
                }
                sbcl_alien_for_primitive(&n).unwrap_or_else(|| SAP.to_string())
            }
            TypeRefKind::Class { .. } | TypeRefKind::Id | TypeRefKind::Instancetype => SAP.into(),
            TypeRefKind::Selector => SAP.into(),
            TypeRefKind::ClassRef => SAP.into(),
            TypeRefKind::Block { .. } => SAP.into(),
            TypeRefKind::CString => "sb-alien:c-string".into(),
            TypeRefKind::Pointer => SAP.into(),
            TypeRefKind::FunctionPointer { .. } => SAP.into(),
            TypeRefKind::Struct { name } => map_geometry_alias(name)
                .map(|s| format!("(sb-alien:struct {s})"))
                .unwrap_or_else(|| SAP.to_string()),
            TypeRefKind::Alias {
                name,
                underlying_primitive,
                ..
            } => {
                if let Some(s) = map_geometry_alias(name) {
                    return format!("(sb-alien:struct {s})");
                }
                // Generic ObjC type params (ObjectType, KeyType, …) are objects.
                if name.ends_with("Type") && is_generic_type_param(name) {
                    return SAP.into();
                }
                // Prefer the enum's extracted underlying width; default to a
                // 64-bit unsigned for aliases whose width wasn't resolved.
                underlying_primitive
                    .as_ref()
                    .map(|s| s.to_ascii_lowercase())
                    .and_then(|s| sbcl_alien_for_primitive(&s))
                    .unwrap_or_else(|| "(sb-alien:unsigned 64)".to_string())
            }
        }
    }
}

/// Fixed-width scalar primitive → `sb-alien` spelling. `None` for names with no
/// fixed-width mapping (callers fall back per slot).
fn sbcl_alien_for_primitive(name: &str) -> Option<String> {
    let spelling = match name {
        // ObjC BOOL is 1 byte on arm64; `(boolean 8)` auto-converts to/from T/NIL.
        "bool" => "(sb-alien:boolean 8)",
        "int8" => "(sb-alien:signed 8)",
        "uint8" => "(sb-alien:unsigned 8)",
        "int16" => "(sb-alien:signed 16)",
        "uint16" => "(sb-alien:unsigned 16)",
        "int32" => "(sb-alien:signed 32)",
        "uint32" => "(sb-alien:unsigned 32)",
        "int64" | "nsinteger" => "(sb-alien:signed 64)",
        "uint64" | "nsuinteger" => "(sb-alien:unsigned 64)",
        "float" => "sb-alien:float",
        "double" => "sb-alien:double",
        _ => return None,
    };
    Some(spelling.to_string())
}

/// Geometry struct typedef → the canonical `sb-alien:struct` type name the
/// emitter references (and the runtime `define-alien-type`s). `NSRect`/`CGRect`
/// pairs canonicalise to the NS spelling; CG-only structs keep `cg-`.
fn map_geometry_alias(name: &str) -> Option<&'static str> {
    match name {
        "NSRect" | "CGRect" => Some("ns-rect"),
        "NSPoint" | "CGPoint" => Some("ns-point"),
        "NSSize" | "CGSize" => Some("ns-size"),
        "NSRange" => Some("ns-range"),
        "NSEdgeInsets" => Some("ns-edge-insets"),
        "NSDirectionalEdgeInsets" => Some("ns-directional-edge-insets"),
        "NSAffineTransformStruct" => Some("ns-affine-transform-struct"),
        "CGAffineTransform" => Some("cg-affine-transform"),
        "CGVector" => Some("cg-vector"),
        _ => None,
    }
}

/// True when `name` is a known by-value geometry struct (the only structs the
/// method filter lets through, mirroring the scheme targets).
pub fn is_known_geometry_alias(name: &str) -> bool {
    map_geometry_alias(name).is_some()
}

/// True when a block typedef `ret (^)(params…)` can be bridged by the runtime's
/// callback bounce (leaf 050): every inner param + the return reduces to a
/// scalar / `system-area-pointer` slot. By-value geometry, `c-string`, and
/// nested blocks do not qualify. A block the emitter cannot bridge keeps its
/// enclosing method deferred ([`crate::method_filter`]).
pub fn is_bridgeable_block(
    params: &[TypeRef],
    return_type: &TypeRef,
    mapper: &dyn FfiTypeMapper,
) -> bool {
    is_bridgeable_block_token(&mapper.map_type(return_type, true), true)
        && params
            .iter()
            .all(|p| is_bridgeable_block_token(&mapper.map_type(p, false), false))
}

/// A block param/return slot is bridgeable iff its `sb-alien` spelling is a
/// scalar or `system-area-pointer`. `void` is valid only as a return; a by-value
/// `(sb-alien:struct …)` and `sb-alien:c-string` are not bridgeable (the bounce
/// shim marshals only scalars and opaque pointers, leaf 050).
fn is_bridgeable_block_token(token: &str, is_return: bool) -> bool {
    if token == "sb-alien:void" {
        return is_return;
    }
    if token == "sb-alien:c-string" || token.starts_with("(sb-alien:struct") {
        return false;
    }
    // system-area-pointer, float, double, (signed N), (unsigned N), (boolean 8).
    true
}

/// Strip a framework-qualified prefix (`Swift.Bool` → `bool`) and lowercase.
fn normalize(name: &str) -> String {
    let unqualified = match name.rsplit_once('.') {
        Some((_, suffix)) => suffix,
        None => name,
    };
    unqualified.to_ascii_lowercase()
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
        let m = SbclFfiTypeMapper;
        assert_eq!(
            m.map_type(&ty(TypeRefKind::Primitive { name: "void".into() }), true),
            "sb-alien:void"
        );
        // void as a parameter is an opaque pointer (mirrors the other targets).
        assert_eq!(
            m.map_type(&ty(TypeRefKind::Primitive { name: "void".into() }), false),
            SAP
        );
    }

    #[test]
    fn fixed_width_scalars() {
        let m = SbclFfiTypeMapper;
        let p = |n: &str| ty(TypeRefKind::Primitive { name: n.into() });
        assert_eq!(m.map_type(&p("int8"), false), "(sb-alien:signed 8)");
        assert_eq!(m.map_type(&p("uint8"), false), "(sb-alien:unsigned 8)");
        assert_eq!(m.map_type(&p("int16"), false), "(sb-alien:signed 16)");
        assert_eq!(m.map_type(&p("uint16"), false), "(sb-alien:unsigned 16)");
        assert_eq!(m.map_type(&p("int32"), false), "(sb-alien:signed 32)");
        assert_eq!(m.map_type(&p("uint32"), false), "(sb-alien:unsigned 32)");
        assert_eq!(m.map_type(&p("int64"), false), "(sb-alien:signed 64)");
        assert_eq!(m.map_type(&p("uint64"), false), "(sb-alien:unsigned 64)");
        assert_eq!(m.map_type(&p("float"), false), "sb-alien:float");
        assert_eq!(m.map_type(&p("double"), false), "sb-alien:double");
        assert_eq!(m.map_type(&p("bool"), false), "(sb-alien:boolean 8)");
    }

    #[test]
    fn nsinteger_aliases_to_64_bit() {
        let m = SbclFfiTypeMapper;
        let p = |n: &str| ty(TypeRefKind::Primitive { name: n.into() });
        assert_eq!(m.map_type(&p("NSInteger"), false), "(sb-alien:signed 64)");
        assert_eq!(m.map_type(&p("NSUInteger"), false), "(sb-alien:unsigned 64)");
        // Swift-qualified primitives normalise too.
        assert_eq!(m.map_type(&p("Swift.Bool"), false), "(sb-alien:boolean 8)");
    }

    #[test]
    fn object_and_pointer_types_are_sap() {
        let m = SbclFfiTypeMapper;
        assert_eq!(m.map_type(&ty(TypeRefKind::Id), false), SAP);
        assert_eq!(m.map_type(&ty(TypeRefKind::Instancetype), true), SAP);
        assert_eq!(m.map_type(&ty(TypeRefKind::Selector), false), SAP);
        assert_eq!(m.map_type(&ty(TypeRefKind::ClassRef), false), SAP);
        assert_eq!(m.map_type(&ty(TypeRefKind::Pointer), false), SAP);
        assert_eq!(
            m.map_type(
                &ty(TypeRefKind::Block {
                    params: vec![],
                    return_type: Box::new(TypeRef::void()),
                }),
                false
            ),
            SAP
        );
        assert_eq!(
            m.map_type(
                &ty(TypeRefKind::Class {
                    name: "NSString".into(),
                    framework: None,
                    params: vec![],
                }),
                false
            ),
            SAP
        );
    }

    #[test]
    fn cstring_is_c_string() {
        let m = SbclFfiTypeMapper;
        assert_eq!(m.map_type(&ty(TypeRefKind::CString), false), "sb-alien:c-string");
    }

    #[test]
    fn geometry_structs_pass_by_value() {
        let m = SbclFfiTypeMapper;
        // NSRect/CGRect canonicalise to the NS spelling.
        assert_eq!(
            m.map_type(
                &ty(TypeRefKind::Alias {
                    name: "NSRect".into(),
                    framework: None,
                    underlying_primitive: None,
                }),
                false
            ),
            "(sb-alien:struct ns-rect)"
        );
        assert_eq!(
            m.map_type(&ty(TypeRefKind::Struct { name: "CGRect".into() }), false),
            "(sb-alien:struct ns-rect)"
        );
        assert_eq!(
            m.map_type(&ty(TypeRefKind::Struct { name: "CGPoint".into() }), false),
            "(sb-alien:struct ns-point)"
        );
        assert_eq!(
            m.map_type(&ty(TypeRefKind::Struct { name: "CGVector".into() }), false),
            "(sb-alien:struct cg-vector)"
        );
        // A non-geometry struct falls back to an opaque pointer.
        assert_eq!(
            m.map_type(&ty(TypeRefKind::Struct { name: "SomeOther".into() }), false),
            SAP
        );
        assert!(is_known_geometry_alias("CGRect"));
        assert!(!is_known_geometry_alias("SomeOther"));
    }

    #[test]
    fn alias_uses_underlying_width_and_generic_param_is_sap() {
        let m = SbclFfiTypeMapper;
        // Enum alias with a known underlying width.
        assert_eq!(
            m.map_type(
                &ty(TypeRefKind::Alias {
                    name: "AXValueType".into(),
                    framework: None,
                    underlying_primitive: Some("uint32".into()),
                }),
                false
            ),
            "(sb-alien:unsigned 32)"
        );
        // Generic ObjC type param → opaque pointer.
        assert_eq!(
            m.map_type(
                &ty(TypeRefKind::Alias {
                    name: "ObjectType".into(),
                    framework: None,
                    underlying_primitive: None,
                }),
                false
            ),
            SAP
        );
        // Framework-prefixed alias of unknown width → unsigned 64 default.
        assert_eq!(
            m.map_type(
                &ty(TypeRefKind::Alias {
                    name: "NSStringEncoding".into(),
                    framework: None,
                    underlying_primitive: None,
                }),
                false
            ),
            "(sb-alien:unsigned 64)"
        );
    }

    #[test]
    fn block_bridgeability() {
        let m = SbclFfiTypeMapper;
        let void_ret = ty(TypeRefKind::Primitive { name: "void".into() });
        let id_param = ty(TypeRefKind::Id);
        // void (^)(id) — all slots reduce to scalar/pointer → bridgeable.
        assert!(is_bridgeable_block(
            std::slice::from_ref(&id_param),
            &void_ret,
            &m
        ));
        // A block taking a by-value geometry struct is not bridgeable.
        let rect_param = ty(TypeRefKind::Struct { name: "CGRect".into() });
        assert!(!is_bridgeable_block(&[rect_param], &void_ret, &m));
        // A block taking a c-string is not bridgeable.
        let str_param = ty(TypeRefKind::CString);
        assert!(!is_bridgeable_block(&[str_param], &void_ret, &m));
    }

    #[test]
    fn trait_helpers_work() {
        let m = SbclFfiTypeMapper;
        assert!(m.is_object_type(&ty(TypeRefKind::Id)));
        assert!(m.is_void(&TypeRef::void()));
        assert!(m.is_struct_type(&ty(TypeRefKind::Struct { name: "NSRect".into() })));
        let _ = is_generic_type_param("ObjectType");
    }
}
