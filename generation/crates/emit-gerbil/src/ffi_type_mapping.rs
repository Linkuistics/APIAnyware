//! Gerbil `:std/foreign` / Gambit `define-c-lambda` type mapping.
//!
//! Maps IR [`TypeRef`] values to the C-type tokens that go inside a
//! `(define-c-lambda name (arg-types …) ret-type "…body…")` form. The tokens
//! are Gambit's FFI type names, confirmed against the 020 spike's compiled
//! `.ss` probes (`02-dispatch-cost.ss`, `04-struct-return.ss`):
//!
//! - ObjC `id` / `Class` / `SEL` / blocks / raw pointers → `(pointer void)`.
//! - fixed-width scalars → `int8`/`unsigned-int8` … `int64`/`unsigned-int64`,
//!   `float`, `double`, `bool`.
//! - C strings → `char-string` (Gambit marshals `char*` ↔ Scheme string).
//! - geometry struct typedefs → a **by-value** `c-define-type` token (e.g.
//!   `CGRect`), the genuine divergence from chez's by-reference `(& NSRect)`
//!   ftype-pointers. The matching `(c-define-type <Tok> (struct "<CName>"))`
//!   declaration is emitted into the `begin-ffi` block by the class emitter
//!   (leaf 020); this module only produces the token. Struct args/returns pass
//!   by value — `___arg1.origin.x`, dot not arrow (FINDINGS §4).
//!
//! The FFI unit is compiled `-x objective-c` (design §4), so real ObjC/Cocoa
//! struct names are available; CoreGraphics (`CGRect`/`CGFloat`) is C-safe. The
//! NS-prefixed geometry structs (`NSRange`, `NSEdgeInsets`, …) need their
//! Foundation declaration in scope or a typedef in the `begin-ffi` `c-declare`
//! prelude — that header/typedef set is the class emitter's call (leaf 020),
//! noted there.

use apianyware_macos_emit::ffi_type_mapping::{is_generic_type_param, FfiTypeMapper};
use apianyware_macos_types::type_ref::{TypeRef, TypeRefKind};

/// The opaque-pointer token. ObjC `id`/`Class`/`SEL`, blocks, and raw C
/// pointers all cross as this — a tagged Gambit foreign pointer.
pub const POINTER: &str = "(pointer void)";

pub struct GerbilFfiTypeMapper;

fn normalize(name: &str) -> String {
    let unqualified = match name.rsplit_once('.') {
        Some((_, suffix)) => suffix,
        None => name,
    };
    unqualified.to_ascii_lowercase()
}

/// Fixed-width scalar primitive → Gambit FFI token. `None` for names with no
/// fixed-width mapping; callers fall back per slot (`(pointer void)` for
/// primitive slots, `unsigned-int64` for enum-alias slots).
///
/// ObjC `BOOL` is `signed char` on arm64; mapping it to Gambit `bool` is the
/// idiomatic choice (nonzero ↔ `#t`). If a width mismatch ever surfaces in
/// testing, the narrower `int8` is the fallback — flagged for leaf 020/050.
fn gerbil_type_for_primitive(name: &str) -> Option<&'static str> {
    match name {
        "bool" => Some("bool"),
        "int8" => Some("int8"),
        "uint8" => Some("unsigned-int8"),
        "int16" => Some("int16"),
        "uint16" => Some("unsigned-int16"),
        "int32" => Some("int32"),
        "uint32" => Some("unsigned-int32"),
        "int64" | "nsinteger" => Some("int64"),
        "uint64" | "nsuinteger" => Some("unsigned-int64"),
        "float" => Some("float"),
        "double" => Some("double"),
        _ => None,
    }
}

/// Geometry struct typedef → the by-value `c-define-type` token the emitter
/// uses in `define-c-lambda` arg/return slots. The token is also the name of
/// the `(c-define-type <Tok> (struct "<CName>"))` declaration the class emitter
/// puts in the `begin-ffi` block. Pairs (`NSRect`/`CGRect`) canonicalise to the
/// CoreGraphics spelling where one exists (C-safe under any compilation mode).
fn map_geometry_alias(name: &str) -> Option<&'static str> {
    match name {
        "NSRect" | "CGRect" => Some("CGRect"),
        "NSPoint" | "CGPoint" => Some("CGPoint"),
        "NSSize" | "CGSize" => Some("CGSize"),
        "CGVector" => Some("CGVector"),
        "CGAffineTransform" => Some("CGAffineTransform"),
        "NSRange" => Some("NSRange"),
        "NSEdgeInsets" => Some("NSEdgeInsets"),
        "NSDirectionalEdgeInsets" => Some("NSDirectionalEdgeInsets"),
        "NSAffineTransformStruct" => Some("NSAffineTransformStruct"),
        _ => None,
    }
}

pub fn is_known_geometry_alias(name: &str) -> bool {
    map_geometry_alias(name).is_some()
}

/// `(token, c-struct-tag, header)` for a by-value geometry struct token — the
/// `(c-define-type <token> (struct "<tag>"))` declaration and the `#include`
/// any `begin-ffi` block referencing that token in an arg/return slot needs.
/// Shared by the class emitter and the function emitter (both pass geometry
/// structs by value, FINDINGS §4). All eight struct-tag + header pairs are
/// **compile-verified** (leaf 050/040 smoke build, `cc -c` against the SDK):
/// the CoreGraphics tokens parse as plain C (gcc-15-clean — the existing
/// runtime path); the NS-prefixed and affine ones require `-x objective-c`
/// (clang), so a class/function module referencing them inherits the node-055
/// umbrella-header compiler decision (same clang path as `constants`/
/// `functions`). The `NSDirectionalEdgeInsets` token's header was corrected
/// from `<Foundation/NSGeometry.h>` (where it does NOT live) to its real
/// AppKit home at 050/040.
pub fn geometry_decl(token: &str) -> Option<(&'static str, &'static str, &'static str)> {
    match token {
        "CGRect" => Some(("CGRect", "CGRect", "<CoreGraphics/CGGeometry.h>")),
        "CGPoint" => Some(("CGPoint", "CGPoint", "<CoreGraphics/CGGeometry.h>")),
        "CGSize" => Some(("CGSize", "CGSize", "<CoreGraphics/CGGeometry.h>")),
        "CGVector" => Some(("CGVector", "CGVector", "<CoreGraphics/CGGeometry.h>")),
        "CGAffineTransform" => Some((
            "CGAffineTransform",
            "CGAffineTransform",
            "<CoreGraphics/CGAffineTransform.h>",
        )),
        "NSRange" => Some(("NSRange", "_NSRange", "<Foundation/NSRange.h>")),
        "NSEdgeInsets" => Some(("NSEdgeInsets", "NSEdgeInsets", "<Foundation/NSGeometry.h>")),
        // NSDirectionalEdgeInsets is an AppKit type (compositional-layout
        // header), NOT a Foundation/NSGeometry one — corrected + compile-
        // verified at 050/040.
        "NSDirectionalEdgeInsets" => Some((
            "NSDirectionalEdgeInsets",
            "NSDirectionalEdgeInsets",
            "<AppKit/NSCollectionViewCompositionalLayout.h>",
        )),
        "NSAffineTransformStruct" => Some((
            "NSAffineTransformStruct",
            "NSAffineTransformStruct",
            "<Foundation/NSAffineTransform.h>",
        )),
        _ => None,
    }
}

/// The by-value `c-define-type` token for a geometry struct returned (or
/// passed) by value, e.g. `"CGRect"`. `None` for non-geometry types. Unlike
/// chez, no hidden leading-buffer convention is involved — Gambit returns the
/// struct by value (arm64 x8 hidden pointer handled by the C cast in the body;
/// proven in FINDINGS §4). The caller reads fields via per-field accessor
/// `define-c-lambda`s.
pub fn struct_return_token(name: &str) -> Option<&'static str> {
    map_geometry_alias(name)
}

/// True when a return [`TypeRef`] is a by-value geometry struct.
pub fn return_is_geometry_struct(t: &TypeRef) -> Option<&'static str> {
    let name = match &t.kind {
        TypeRefKind::Struct { name } => name.as_str(),
        TypeRefKind::Alias { name, .. } => name.as_str(),
        _ => return None,
    };
    struct_return_token(name)
}

impl FfiTypeMapper for GerbilFfiTypeMapper {
    fn map_type(&self, type_ref: &TypeRef, is_return_type: bool) -> String {
        match &type_ref.kind {
            TypeRefKind::Primitive { name } => {
                let n = normalize(name);
                if n == "void" {
                    return if is_return_type {
                        "void".into()
                    } else {
                        POINTER.into()
                    };
                }
                if n == "pointer" {
                    return POINTER.into();
                }
                gerbil_type_for_primitive(&n)
                    .map(str::to_string)
                    .unwrap_or_else(|| POINTER.to_string())
            }
            TypeRefKind::Class { .. } | TypeRefKind::Id | TypeRefKind::Instancetype => {
                POINTER.to_string()
            }
            TypeRefKind::Selector => POINTER.to_string(),
            TypeRefKind::ClassRef => POINTER.to_string(),
            TypeRefKind::Block { .. } => POINTER.to_string(),
            TypeRefKind::CString => "char-string".to_string(),
            TypeRefKind::Pointer => POINTER.to_string(),
            TypeRefKind::Struct { name } => map_geometry_alias(name)
                .map(str::to_string)
                .unwrap_or_else(|| POINTER.to_string()),
            TypeRefKind::FunctionPointer { .. } => POINTER.to_string(),
            TypeRefKind::Alias {
                name,
                underlying_primitive,
                ..
            } => {
                if let Some(t) = map_geometry_alias(name) {
                    return t.to_string();
                }
                if name.ends_with("Type") && is_generic_type_param(name) {
                    return POINTER.to_string();
                }
                gerbil_type_for_primitive(
                    underlying_primitive
                        .as_ref()
                        .map(|s| s.to_ascii_lowercase())
                        .as_deref()
                        .unwrap_or(""),
                )
                .map(str::to_string)
                .unwrap_or_else(|| "unsigned-int64".to_string())
            }
        }
    }
}

/// A block's inner param / return type must reduce to one of these scalar /
/// `(pointer void)` tokens for the runtime's block trampoline (leaf 050's ObjC
/// native core) to bridge it. By-value geometry, `char-string`, and nested
/// blocks do not qualify — they would need marshalling the trampoline does not
/// carry. `void` is valid only as a return token.
fn block_token(t: &TypeRef, is_return: bool, mapper: &dyn FfiTypeMapper) -> Option<String> {
    let tok = mapper.map_type(t, is_return);
    match tok.as_str() {
        "void" if is_return => Some(tok),
        "(pointer void)" | "bool" | "float" | "double" | "int8" | "unsigned-int8" | "int16"
        | "unsigned-int16" | "int32" | "unsigned-int32" | "int64" | "unsigned-int64" => Some(tok),
        _ => None,
    }
}

/// True when a block typedef `ret (^)(params…)` can be bridged: every inner
/// param and the return reduce to a scalar / `(pointer void)` token. A block
/// the emitter cannot bridge keeps its enclosing method deferred in
/// [`method_filter`](crate::method_filter).
pub fn is_bridgeable_block(
    params: &[TypeRef],
    return_type: &TypeRef,
    mapper: &dyn FfiTypeMapper,
) -> bool {
    block_token(return_type, true, mapper).is_some()
        && params
            .iter()
            .all(|p| block_token(p, false, mapper).is_some())
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
        let m = GerbilFfiTypeMapper;
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
            "(pointer void)"
        );
    }

    #[test]
    fn primitives() {
        let m = GerbilFfiTypeMapper;
        assert_eq!(
            m.map_type(
                &ty(TypeRefKind::Primitive {
                    name: "uint64".into()
                }),
                false
            ),
            "unsigned-int64"
        );
        assert_eq!(
            m.map_type(
                &ty(TypeRefKind::Primitive {
                    name: "int64".into()
                }),
                false
            ),
            "int64"
        );
        assert_eq!(
            m.map_type(
                &ty(TypeRefKind::Primitive {
                    name: "double".into()
                }),
                false
            ),
            "double"
        );
        assert_eq!(
            m.map_type(
                &ty(TypeRefKind::Primitive {
                    name: "bool".into()
                }),
                false
            ),
            "bool"
        );
        assert_eq!(
            m.map_type(
                &ty(TypeRefKind::Primitive {
                    name: "uint32".into()
                }),
                false
            ),
            "unsigned-int32"
        );
    }

    #[test]
    fn nsinteger_aliases_to_int64() {
        let m = GerbilFfiTypeMapper;
        assert_eq!(
            m.map_type(
                &ty(TypeRefKind::Primitive {
                    name: "NSInteger".into()
                }),
                false
            ),
            "int64"
        );
        assert_eq!(
            m.map_type(
                &ty(TypeRefKind::Primitive {
                    name: "NSUInteger".into()
                }),
                false
            ),
            "unsigned-int64"
        );
    }

    #[test]
    fn object_types_are_pointer() {
        let m = GerbilFfiTypeMapper;
        assert_eq!(m.map_type(&ty(TypeRefKind::Id), false), "(pointer void)");
        assert_eq!(
            m.map_type(&ty(TypeRefKind::Instancetype), false),
            "(pointer void)"
        );
        assert_eq!(
            m.map_type(&ty(TypeRefKind::Selector), false),
            "(pointer void)"
        );
        assert_eq!(
            m.map_type(
                &ty(TypeRefKind::Class {
                    name: "NSString".into(),
                    framework: None,
                    params: vec![]
                }),
                false
            ),
            "(pointer void)"
        );
    }

    #[test]
    fn cstring_is_char_string() {
        let m = GerbilFfiTypeMapper;
        assert_eq!(m.map_type(&ty(TypeRefKind::CString), false), "char-string");
    }

    #[test]
    fn geometry_structs_pass_by_value() {
        let m = GerbilFfiTypeMapper;
        // CGRect/NSRect canonicalise to the CoreGraphics by-value token.
        assert_eq!(
            m.map_type(
                &ty(TypeRefKind::Alias {
                    name: "NSRect".into(),
                    framework: None,
                    underlying_primitive: None,
                }),
                false
            ),
            "CGRect"
        );
        assert_eq!(
            m.map_type(
                &ty(TypeRefKind::Struct {
                    name: "CGPoint".into()
                }),
                false
            ),
            "CGPoint"
        );
        // A non-geometry struct falls back to an opaque pointer.
        assert_eq!(
            m.map_type(
                &ty(TypeRefKind::Struct {
                    name: "SomeOther".into()
                }),
                false
            ),
            "(pointer void)"
        );
        assert!(is_known_geometry_alias("CGRect"));
        assert!(!is_known_geometry_alias("SomeOther"));
        assert_eq!(struct_return_token("NSRect"), Some("CGRect"));
    }

    #[test]
    fn alias_uses_underlying_width() {
        let m = GerbilFfiTypeMapper;
        assert_eq!(
            m.map_type(
                &ty(TypeRefKind::Alias {
                    name: "AXValueType".into(),
                    framework: None,
                    underlying_primitive: Some("uint32".into()),
                }),
                false
            ),
            "unsigned-int32"
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
            "(pointer void)"
        );
        // Framework-prefixed alias of unknown width → uint64 default.
        assert_eq!(
            m.map_type(
                &ty(TypeRefKind::Alias {
                    name: "NSStringEncoding".into(),
                    framework: None,
                    underlying_primitive: None,
                }),
                false
            ),
            "unsigned-int64"
        );
    }

    #[test]
    fn block_bridgeability() {
        let m = GerbilFfiTypeMapper;
        let void_ret = TypeRef {
            nullable: false,
            kind: TypeRefKind::Primitive {
                name: "void".into(),
            },
        };
        let id_param = TypeRef {
            nullable: false,
            kind: TypeRefKind::Id,
        };
        // void (^)(id) — all slots reduce to scalar/pointer tokens → bridgeable.
        assert!(is_bridgeable_block(
            std::slice::from_ref(&id_param),
            &void_ret,
            &m
        ));
        // A block taking a by-value geometry struct is not bridgeable.
        let rect_param = TypeRef {
            nullable: false,
            kind: TypeRefKind::Struct {
                name: "CGRect".into(),
            },
        };
        assert!(!is_bridgeable_block(&[rect_param], &void_ret, &m));
    }
}
