//! Chez `foreign-procedure` type mapping.
//!
//! Maps IR [`TypeRef`] values to Chez Scheme FFI type tokens that go inside
//! `(foreign-procedure name (arg-types ...) ret-type)`. ObjC `id`, `Class`,
//! `SEL` and blocks all use `void*`; primitives map to Chez's fixed-width
//! integer / float keywords (`unsigned-64`, `integer-64`, `double-float`,
//! …). Geometry struct typedefs map to `(& <ftype>)` so values pass by
//! reference as ftype-pointers per `runtime/types.sls`.

use apianyware_emit::ffi_type_mapping::{is_generic_type_param, FfiTypeMapper};
use apianyware_types::type_ref::{TypeRef, TypeRefKind};

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

/// Geometry struct returned by value from an `objc_msgSend` call. Chez's
/// `foreign-procedure` exposes a `(& <ftype>)` *result* type as an explicit
/// leading argument — the caller passes a freshly-allocated result buffer
/// and the foreign call writes the struct into it. This holds for **every**
/// by-value struct return, irrespective of the C ABI's
/// register-vs-indirect choice: even a 16-byte aggregate that the arm64 ABI
/// returns in `x0:x1` must be declared and *called* through Chez's hidden
/// leading-buffer convention. (Calling a `(& NSPoint)`-returning
/// foreign-procedure without the buffer fails at runtime with "incorrect
/// number of arguments" — see the `drawing-canvas` port, the first app to
/// invoke `locationInWindow` / `convertPoint:fromView:` under live
/// dispatch.) Returns the ftype name (e.g. `"NSPoint"`) so the emitter can
/// spell the hidden-arg type and the allocation site.
///
/// Sizes (from `runtime/types.sls`, all CGFloat = 8 bytes), for reference:
///   - 16 bytes: NSPoint, NSSize, NSRange, CGVector
///   - 32 bytes: NSRect, NSEdgeInsets, NSDirectionalEdgeInsets
///   - 48 bytes: NSAffineTransformStruct, CGAffineTransform
pub fn struct_return_ftype(name: &str) -> Option<&'static str> {
    match name {
        "NSRect" | "CGRect" => Some("NSRect"),
        "NSPoint" | "CGPoint" => Some("NSPoint"),
        "NSSize" | "CGSize" => Some("NSSize"),
        "NSRange" => Some("NSRange"),
        "CGVector" => Some("CGVector"),
        "NSEdgeInsets" => Some("NSEdgeInsets"),
        "NSDirectionalEdgeInsets" => Some("NSDirectionalEdgeInsets"),
        "NSAffineTransformStruct" => Some("NSAffineTransformStruct"),
        "CGAffineTransform" => Some("CGAffineTransform"),
        _ => None,
    }
}

/// True when a return [`TypeRef`] is a by-value geometry struct, which Chez
/// returns through the hidden leading-buffer convention described in
/// [`struct_return_ftype`].
pub fn return_needs_indirect_result(t: &TypeRef) -> Option<&'static str> {
    let name = match &t.kind {
        TypeRefKind::Struct { name } => name.as_str(),
        TypeRefKind::Alias { name, .. } => name.as_str(),
        _ => return None,
    };
    struct_return_ftype(name)
}

impl FfiTypeMapper for ChezFfiTypeMapper {
    fn map_type(&self, type_ref: &TypeRef, is_return_type: bool) -> String {
        match &type_ref.kind {
            TypeRefKind::Primitive { name } => {
                let n = normalize(name);
                if n == "void" {
                    return if is_return_type {
                        "void".into()
                    } else {
                        "void*".into()
                    };
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

/// The `foreign-callable` type token a block's inner parameter / return
/// type must reduce to for `make-objc-block` (`runtime/dispatch.sls`) to
/// bridge it. `make-objc-block` builds a `foreign-callable` whose type
/// specifiers are these tokens *literally*, so only the fixed-width scalar
/// and `void*` tokens qualify — geometry `(& <ftype>)` by-value, `string`,
/// and nested blocks do not (they would need ftype/marshalling the block
/// trampoline does not carry).
///
/// `void` is only valid as a return token; a `void` *parameter* maps to
/// `void*` via [`ChezFfiTypeMapper::map_type`] and is rejected here as a
/// param to keep the bridge honest.
fn block_callable_token(
    t: &TypeRef,
    is_return: bool,
    mapper: &dyn FfiTypeMapper,
) -> Option<String> {
    let tok = mapper.map_type(t, is_return);
    match tok.as_str() {
        "void" if is_return => Some(tok),
        "void*" | "boolean" | "float" | "double-float" | "integer-8" | "unsigned-8"
        | "integer-16" | "unsigned-16" | "integer-32" | "unsigned-32" | "integer-64"
        | "unsigned-64" => Some(tok),
        _ => None,
    }
}

/// True when a block typedef `void (^)(params…) → return_type` can be
/// bridged by `make-objc-block`: every inner param and the return reduce
/// to a scalar / `void*` `foreign-callable` token (see
/// [`block_callable_token`]). A block the emitter cannot bridge keeps its
/// enclosing method deferred in [`method_filter`](crate::method_filter).
pub fn is_bridgeable_block(
    params: &[TypeRef],
    return_type: &TypeRef,
    mapper: &dyn FfiTypeMapper,
) -> bool {
    block_callable_token(return_type, true, mapper).is_some()
        && params
            .iter()
            .all(|p| block_callable_token(p, false, mapper).is_some())
}

/// The Scheme `(objc-block-ptr (make-objc-block <var> (list 'tok …) 'ret))`
/// expression a generated method wrapper substitutes for a block-typed
/// argument. `var` is the Scheme identifier the user passes (the bare
/// procedure, mirroring emit-racket's wrapper). Caller must have verified
/// the block is bridgeable via [`is_bridgeable_block`].
pub fn block_make_expr(
    var: &str,
    params: &[TypeRef],
    return_type: &TypeRef,
    mapper: &dyn FfiTypeMapper,
) -> String {
    let param_toks: Vec<String> = params
        .iter()
        .map(|p| {
            format!(
                "'{}",
                block_callable_token(p, false, mapper).expect("block param verified bridgeable")
            )
        })
        .collect();
    let ret_tok =
        block_callable_token(return_type, true, mapper).expect("block return verified bridgeable");
    format!(
        "(objc-block-ptr (make-objc-block {} (list {}) '{}))",
        var,
        param_toks.join(" "),
        ret_tok
    )
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
            m.map_type(
                &ty(TypeRefKind::Primitive {
                    name: "void".into()
                }),
                true
            ),
            "void"
        );
        assert_eq!(
            m.map_type(
                &ty(TypeRefKind::Primitive {
                    name: "void".into()
                }),
                false
            ),
            "void*"
        );
    }

    #[test]
    fn primitives() {
        let m = ChezFfiTypeMapper;
        assert_eq!(
            m.map_type(
                &ty(TypeRefKind::Primitive {
                    name: "uint64".into()
                }),
                false
            ),
            "unsigned-64"
        );
        assert_eq!(
            m.map_type(
                &ty(TypeRefKind::Primitive {
                    name: "int64".into()
                }),
                false
            ),
            "integer-64"
        );
        assert_eq!(
            m.map_type(
                &ty(TypeRefKind::Primitive {
                    name: "double".into()
                }),
                false
            ),
            "double-float"
        );
        assert_eq!(
            m.map_type(
                &ty(TypeRefKind::Primitive {
                    name: "bool".into()
                }),
                false
            ),
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
