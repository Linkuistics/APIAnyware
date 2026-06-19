//! Which methods the gerbil emitter can bind.
//!
//! Mirrors the chez filter: skip variadic / deprecated / Swift-paren selectors,
//! and defer methods that pass or return **non-geometry** structs by value, or
//! whose **block** parameters carry an un-bridgeable signature. Known-geometry
//! aliases (NSRect, CGPoint, NSSize, NSRange, …) are supported by value via
//! `(c-define-type … (struct …))` (FINDINGS §4); arbitrary struct-by-value would
//! need a `c-define-type` the emitter cannot derive. Function-pointer typedefs
//! and raw pointers reach into output-buffer / callback territory the per-method
//! crossing does not model, so they are deferred too.
//!
//! Block parameters are bridged through the runtime's block trampoline (leaf
//! 050's ObjC native core): a method with a block param binds **iff** every such
//! block reduces to scalar / `(pointer void)` tokens (see
//! [`is_bridgeable_block`]). Methods that *return* a block stay deferred
//! unconditionally (the reverse C-block → Gerbil-proc direction is not modelled
//! at this layer).

use std::collections::HashSet;

use apianyware_macos_emit::ffi_type_mapping::FfiTypeMapper;
use apianyware_macos_types::ir::{Method, Param};
use apianyware_macos_types::type_ref::{TypeRef, TypeRefKind};

use crate::ffi_type_mapping::{is_bridgeable_block, is_known_geometry_alias};

pub fn is_supported_method(method: &Method, mapper: &dyn FfiTypeMapper) -> bool {
    if method.variadic || method.deprecated || method.selector.contains('(') {
        return false;
    }
    if has_unbridgeable_block_param(&method.params, mapper) || returns_block(&method.return_type) {
        return false;
    }
    if has_unsupported_struct_param(&method.params, mapper)
        || returns_unsupported_struct(&method.return_type, mapper)
    {
        return false;
    }
    if has_unsupported_pointer_alias_param(&method.params)
        || returns_unsupported_pointer_alias(&method.return_type)
    {
        return false;
    }
    true
}

/// Whether a method routes to the `(values result error)` error model
/// (ADR-0006 applied to gerbil): its selector is in the class's
/// enrichment-derived `error_selectors` set **and** its trailing param is a raw
/// pointer (the `NSError**` cell — type-level corroboration of the analysis
/// classification). Gerbil keeps the out-param crossing in Gerbil (ADR-0017),
/// so the predicate works over the IR directly rather than over a native
/// dispatch signature the way racket's `is_error_out_routable` does.
pub fn is_error_out_method(method: &Method, error_selectors: &HashSet<String>) -> bool {
    error_selectors.contains(&method.selector)
        && matches!(
            method.params.last().map(|p| &p.param_type.kind),
            Some(TypeRefKind::Pointer)
        )
}

/// Supportedness honouring NSError out-param routing. An error-out method
/// ([`is_error_out_method`]) is bindable when its **visible** signature (params
/// minus the trailing `NSError**` cell) is — so the trailing error pointer is
/// permitted while any *other* raw pointer in the visible args still defers.
/// Non-error methods fall through to plain [`is_supported_method`].
pub fn is_supported_method_ctx(
    method: &Method,
    mapper: &dyn FfiTypeMapper,
    error_selectors: &HashSet<String>,
) -> bool {
    if is_error_out_method(method, error_selectors) {
        let mut visible = method.clone();
        visible.params.pop();
        return is_supported_method(&visible, mapper);
    }
    is_supported_method(method, mapper)
}

pub fn returns_object_type(method: &Method, mapper: &dyn FfiTypeMapper) -> bool {
    mapper.is_object_type(&method.return_type)
}

pub fn returns_void(method: &Method, mapper: &dyn FfiTypeMapper) -> bool {
    mapper.is_void(&method.return_type)
}

pub fn has_block_params(params: &[Param]) -> bool {
    params
        .iter()
        .any(|p| matches!(p.param_type.kind, TypeRefKind::Block { .. }))
}

fn has_unbridgeable_block_param(params: &[Param], mapper: &dyn FfiTypeMapper) -> bool {
    params.iter().any(|p| match &p.param_type.kind {
        TypeRefKind::Block {
            params,
            return_type,
        } => !is_bridgeable_block(params, return_type, mapper),
        _ => false,
    })
}

fn returns_block(t: &TypeRef) -> bool {
    matches!(t.kind, TypeRefKind::Block { .. })
}

fn has_unsupported_struct_param(params: &[Param], mapper: &dyn FfiTypeMapper) -> bool {
    params
        .iter()
        .any(|p| is_unsupported_struct(&p.param_type, mapper))
}

fn returns_unsupported_struct(t: &TypeRef, mapper: &dyn FfiTypeMapper) -> bool {
    is_unsupported_struct(t, mapper)
}

/// A struct-by-value the emitter cannot honour: a struct kind the IR mapper
/// recognises that isn't one of the curated geometry aliases.
fn is_unsupported_struct(t: &TypeRef, mapper: &dyn FfiTypeMapper) -> bool {
    if !mapper.is_struct_type(t) {
        return false;
    }
    let name = match &t.kind {
        TypeRefKind::Struct { name } => name,
        TypeRefKind::Alias { name, .. } => name,
        _ => return true,
    };
    !is_known_geometry_alias(name)
}

fn has_unsupported_pointer_alias_param(params: &[Param]) -> bool {
    params.iter().any(|p| is_unsupported_pointer(&p.param_type))
}

fn returns_unsupported_pointer_alias(t: &TypeRef) -> bool {
    is_unsupported_pointer(t)
}

fn is_unsupported_pointer(t: &TypeRef) -> bool {
    matches!(
        t.kind,
        TypeRefKind::FunctionPointer { .. } | TypeRefKind::Pointer
    )
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::ffi_type_mapping::GerbilFfiTypeMapper;
    use apianyware_macos_types::ir::Method;
    use apianyware_macos_types::type_ref::TypeRef;

    fn method(selector: &str, variadic: bool, deprecated: bool, ret: TypeRef) -> Method {
        Method {
            selector: selector.into(),
            class_method: false,
            init_method: false,
            params: vec![],
            return_type: ret,
            deprecated,
            variadic,
            source: None,
            provenance: None,
            doc_refs: None,
            origin: None,
            category: None,
            overrides: None,
            returns_retained: None,
            satisfies_protocol: None,
            objc_exposed: true,
            swift_fn: None,
        }
    }

    fn ty(kind: TypeRefKind) -> TypeRef {
        TypeRef {
            nullable: false,
            kind,
        }
    }

    #[test]
    fn plain_method_supported() {
        let m = GerbilFfiTypeMapper;
        let meth = method("length", false, false, ty(TypeRefKind::Id));
        assert!(is_supported_method(&meth, &m));
    }

    #[test]
    fn variadic_and_deprecated_deferred() {
        let m = GerbilFfiTypeMapper;
        assert!(!is_supported_method(
            &method("foo:", true, false, ty(TypeRefKind::Id)),
            &m
        ));
        assert!(!is_supported_method(
            &method("foo:", false, true, ty(TypeRefKind::Id)),
            &m
        ));
    }

    #[test]
    fn geometry_return_supported_but_unknown_struct_deferred() {
        let m = GerbilFfiTypeMapper;
        assert!(is_supported_method(
            &method(
                "frame",
                false,
                false,
                ty(TypeRefKind::Struct {
                    name: "CGRect".into()
                })
            ),
            &m
        ));
        assert!(!is_supported_method(
            &method(
                "weird",
                false,
                false,
                ty(TypeRefKind::Struct {
                    name: "SomeStruct".into()
                })
            ),
            &m
        ));
    }

    #[test]
    fn returns_block_deferred() {
        let m = GerbilFfiTypeMapper;
        let block = ty(TypeRefKind::Block {
            params: vec![],
            return_type: Box::new(TypeRef::void()),
        });
        assert!(!is_supported_method(
            &method("handler", false, false, block),
            &m
        ));
    }

    // --- NSError out-param routing (leaf 050) ----------------------------

    fn param(name: &str, kind: TypeRefKind) -> Param {
        Param {
            name: name.into(),
            param_type: ty(kind),
        }
    }

    fn error_method(selector: &str, visible: Vec<Param>) -> Method {
        let mut m = method(
            "x",
            false,
            false,
            ty(TypeRefKind::Primitive {
                name: "bool".into(),
            }),
        );
        m.selector = selector.into();
        // Visible args, then the trailing NSError** cell (a raw pointer).
        m.params = visible;
        m.params.push(param("error", TypeRefKind::Pointer));
        m
    }

    #[test]
    fn error_out_method_recognised_by_set_and_trailing_pointer() {
        let mut errs = HashSet::new();
        errs.insert("writeToFile:error:".to_string());
        let m = error_method("writeToFile:error:", vec![param("path", TypeRefKind::Id)]);
        assert!(is_error_out_method(&m, &errs));
        // Selector not in the set ⇒ not error-routed even with a trailing pointer.
        assert!(!is_error_out_method(&m, &HashSet::new()));
        // In the set but no trailing pointer ⇒ not error-routed.
        let no_ptr = method(
            "writeToFile:error:",
            false,
            false,
            ty(TypeRefKind::Primitive {
                name: "bool".into(),
            }),
        );
        assert!(!is_error_out_method(&no_ptr, &errs));
    }

    #[test]
    fn trailing_nserror_method_becomes_supported() {
        let m = GerbilFfiTypeMapper;
        let mut errs = HashSet::new();
        errs.insert("writeToFile:error:".to_string());
        let meth = error_method("writeToFile:error:", vec![param("path", TypeRefKind::Id)]);
        // Plain supportedness still defers it (the raw trailing pointer).
        assert!(!is_supported_method(&meth, &m));
        // Error-context supportedness accepts it (the trailing pointer is the cell).
        assert!(is_supported_method_ctx(&meth, &m, &errs));
    }

    #[test]
    fn non_error_trailing_pointer_still_defers() {
        let m = GerbilFfiTypeMapper;
        // Same shape, but the selector is NOT an enrichment error method.
        let meth = error_method("getBytes:length:", vec![param("buf", TypeRefKind::Id)]);
        assert!(!is_supported_method_ctx(&meth, &m, &HashSet::new()));
    }

    #[test]
    fn error_method_with_other_raw_pointer_param_still_defers() {
        let m = GerbilFfiTypeMapper;
        let mut errs = HashSet::new();
        errs.insert("doThing:error:".to_string());
        // A non-trailing raw pointer in the visible args is still unbindable.
        let meth = error_method("doThing:error:", vec![param("raw", TypeRefKind::Pointer)]);
        assert!(!is_supported_method_ctx(&meth, &m, &errs));
    }
}
