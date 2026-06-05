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
//!   declaration is emitted into the `begin-ffi` block by the class/function
//!   emitters via [`emit_geometry_decls`]; this module produces the token and
//!   the [`GeometryDecl`]. Struct args/returns pass by value — `___arg1.origin.x`,
//!   dot not arrow (FINDINGS §4).
//!
//! Every emitted module compiles under the bottle's **default gcc-15** — no
//! `-x objective-c`, no framework umbrella `#include` (ADR-0021, superseding
//! design §4). CoreGraphics struct headers (`CGRect`/`CGFloat`) are C-safe, so
//! they are `#include`d directly; the four NS-prefixed geometry structs
//! (`NSRange`, `NSEdgeInsets`, `NSDirectionalEdgeInsets`,
//! `NSAffineTransformStruct`) have Objective-C headers, so the emitter declares
//! an **ABI-exact plain-C typedef'd struct inline** instead ([`GeometryCScope`]).

use apianyware_macos_emit::code_writer::CodeWriter;
use apianyware_macos_emit::ffi_type_mapping::{is_generic_type_param, FfiTypeMapper};
use apianyware_macos_emit::write_line;
use apianyware_macos_types::type_ref::{TypeRef, TypeRefKind};

/// The opaque-pointer token. ObjC `id`/`Class`/`SEL`, blocks, and raw C
/// pointers all cross as this — a tagged Gambit foreign pointer.
pub const POINTER: &str = "(pointer void)";

/// The C type spelling a `define-c-lambda` arg/return token reduces to, for a
/// **synthesized** C declaration (ADR-0021: the emitter declares the symbols its
/// crossings name with `extern`s / prototypes, never by `#include`-ing a
/// framework umbrella header). Each pairing is compile-verified under the bottle's
/// default gcc-15: the synthesized prototype's C types are ABI-compatible with
/// both Gambit's per-token argument conversions and the real exported symbol
/// (ObjC pointer types collapse to `void *`, exactly as chez resolves them by
/// name with no header). `bool` requires `<stdbool.h>` in scope (C-safe); callers
/// that emit a `bool` slot must add that include once. Geometry tokens are not
/// handled here — they carry a struct-tag `c-define-type` declared separately
/// (CoreGraphics header or, for the NS-prefixed structs, an inline plain-C
/// typedef; [`geometry_decl`]).
pub fn c_type_for_token(token: &str) -> &'static str {
    match token {
        "(pointer void)" => "void *",
        "char-string" => "const char *",
        "void" => "void",
        "bool" => "bool",
        "int8" => "signed char",
        "unsigned-int8" => "unsigned char",
        "int16" => "short",
        "unsigned-int16" => "unsigned short",
        "int32" => "int",
        "unsigned-int32" => "unsigned int",
        "int64" => "long long",
        "unsigned-int64" => "unsigned long long",
        "float" => "float",
        "double" => "double",
        // A geometry struct token (CGRect, NSRange, …) carries its own
        // `c-define-type` tag and is spelled by the caller's prototype directly,
        // never through this scalar helper; an opaque pointer is the safe default
        // for any unrecognised token.
        _ => "void *",
    }
}

/// The C type a `define-c-lambda` arg/return token reduces to **in a synthesized
/// function prototype** (ADR-0021). Scalars and pointers defer to
/// [`c_type_for_token`]; a by-value geometry token spells `struct <tag>` (the
/// same tag its [`geometry_decl`] `c-define-type` names — valid because the tag
/// is in C scope, via a CoreGraphics header or an inline plain-C struct). The
/// real symbol's `CGRect`/`NSRange` typedef is identical to `struct CGRect` /
/// `struct _NSRange`, so the prototype is ABI-compatible with both Gambit's
/// by-value marshalling and the exported function.
pub fn c_proto_type(token: &str) -> String {
    match geometry_decl(token) {
        Some(decl) => format!("struct {}", decl.tag),
        None => c_type_for_token(token).to_string(),
    }
}

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

/// How a geometry struct's C tag is brought into a `begin-ffi` block's scope
/// (ADR-0021). CoreGraphics struct headers are C-safe under the default gcc-15,
/// so they are `#include`d; the NS-prefixed structs have Objective-C headers, so
/// the emitter declares an ABI-exact plain-C typedef'd struct inline instead.
#[derive(Clone, Copy)]
pub enum GeometryCScope {
    /// `#include` this C-safe CoreGraphics header to bring the struct tag in.
    Header(&'static str),
    /// Emit this inline plain-C `typedef struct <tag> { … } <token>;` (the NS
    /// structs). The typedef is load-bearing: `(c-define-type <token> (struct
    /// "<tag>"))` needs the `struct <tag>` form, while the hand-written
    /// `define-c-lambda` cast bodies spell the type as the bare `<token>` — only
    /// the typedef satisfies both. CoreGraphics headers already ship the typedef;
    /// these inline structs must declare their own (found at the first
    /// full-framework gxc compile, leaf 070/020).
    InlineStruct(&'static str),
}

/// A by-value geometry struct token, its C struct tag (the `(c-define-type
/// <token> (struct "<tag>"))` names it), and how to bring that tag into C scope.
/// Shared by the class and function emitters (both pass geometry structs by
/// value, FINDINGS §4) through [`emit_geometry_decls`].
///
/// The four inline NS structs are **ABI-exact, SDK-verified** (field order +
/// width against the macOS SDK headers, 055/020): `NSUInteger → unsigned long`,
/// `CGFloat → double` on arm64. `NSAffineTransformStruct` is declared by the SDK
/// as an *anonymous*-tagged typedef, so the inline form gives it a real
/// `NSAffineTransformStruct` tag (matching the `c-define-type`) — which the old
/// umbrella-header path lacked. `NSDirectionalEdgeInsets` lives in AppKit's
/// compositional-layout header, not Foundation/NSGeometry (the source of its
/// inline field list).
pub struct GeometryDecl {
    pub token: &'static str,
    pub tag: &'static str,
    pub scope: GeometryCScope,
}

pub fn geometry_decl(token: &str) -> Option<GeometryDecl> {
    use GeometryCScope::{Header, InlineStruct};
    let cg = "<CoreGraphics/CGGeometry.h>";
    let (token, tag, scope) = match token {
        "CGRect" => ("CGRect", "CGRect", Header(cg)),
        "CGPoint" => ("CGPoint", "CGPoint", Header(cg)),
        "CGSize" => ("CGSize", "CGSize", Header(cg)),
        "CGVector" => ("CGVector", "CGVector", Header(cg)),
        "CGAffineTransform" => (
            "CGAffineTransform",
            "CGAffineTransform",
            Header("<CoreGraphics/CGAffineTransform.h>"),
        ),
        "NSRange" => (
            "NSRange",
            "_NSRange",
            InlineStruct(
                "typedef struct _NSRange { unsigned long location; unsigned long length; } NSRange;",
            ),
        ),
        "NSEdgeInsets" => (
            "NSEdgeInsets",
            "NSEdgeInsets",
            InlineStruct(
                "typedef struct NSEdgeInsets { double top; double left; double bottom; double right; } NSEdgeInsets;",
            ),
        ),
        "NSDirectionalEdgeInsets" => (
            "NSDirectionalEdgeInsets",
            "NSDirectionalEdgeInsets",
            InlineStruct(
                "typedef struct NSDirectionalEdgeInsets { double top; double leading; double bottom; double trailing; } NSDirectionalEdgeInsets;",
            ),
        ),
        "NSAffineTransformStruct" => (
            "NSAffineTransformStruct",
            "NSAffineTransformStruct",
            InlineStruct(
                "typedef struct NSAffineTransformStruct { double m11; double m12; double m21; double m22; double tX; double tY; } NSAffineTransformStruct;",
            ),
        ),
        _ => return None,
    };
    Some(GeometryDecl { token, tag, scope })
}

/// Emit the geometry `c-declare` prelude (a C-safe header `#include` or an
/// inline plain-C struct) and the `c-define-type` token for each geometry struct
/// a module uses, indented to sit inside a `begin-ffi` block. Shared by the
/// class and function emitters so both stay ADR-0021-consistent — no module
/// emits a framework umbrella `#include`. The `c-declare`s precede every
/// `c-define-type` so the struct tags are in scope when the types are defined.
pub fn emit_geometry_decls(w: &mut CodeWriter, decls: &[GeometryDecl]) {
    for d in decls {
        match d.scope {
            GeometryCScope::Header(h) => write_line!(w, "  (c-declare \"#include {}\")", h),
            GeometryCScope::InlineStruct(s) => write_line!(w, "  (c-declare \"{}\")", s),
        }
    }
    for d in decls {
        write_line!(w, "  (c-define-type {} (struct \"{}\"))", d.token, d.tag);
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
