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
            &method("frame", false, false, ty(TypeRefKind::Struct { name: "CGRect".into() })),
            &m
        ));
        assert!(!is_supported_method(
            &method("weird", false, false, ty(TypeRefKind::Struct { name: "SomeStruct".into() })),
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
        assert!(!is_supported_method(&method("handler", false, false, block), &m));
    }
}
