//! Which methods this scaffold leaf can bind.
//!
//! Stricter than the racket filter: in addition to skipping variadic /
//! deprecated / Swift-paren selectors, this scaffold also defers methods
//! that take **block** parameters or that pass / return **non-geometry**
//! structs by value. Block bridging needs `make-objc-block` from
//! `runtime/dispatch.sls`; arbitrary struct-by-value would need an
//! ftype definition the runtime doesn't carry. Known-geometry aliases
//! (NSRect, NSPoint, NSSize, NSRange, NSEdgeInsets, …) are supported:
//! the mapper emits `(& <ftype>)` and `runtime/types.sls` provides the
//! ftype constructors callers pass through.

use apianyware_macos_emit::ffi_type_mapping::FfiTypeMapper;
use apianyware_macos_types::ir::{Method, Param};
use apianyware_macos_types::type_ref::{TypeRef, TypeRefKind};

use crate::ffi_type_mapping::is_known_geometry_alias;

pub fn is_supported_method(method: &Method, mapper: &dyn FfiTypeMapper) -> bool {
    if method.variadic || method.deprecated || method.selector.contains('(') {
        return false;
    }
    if has_block_params(&method.params) || returns_block(&method.return_type) {
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
    params.iter().any(|p| matches!(p.param_type.kind, TypeRefKind::Block { .. }))
}

fn returns_block(t: &TypeRef) -> bool {
    matches!(t.kind, TypeRefKind::Block { .. })
}

fn has_unsupported_struct_param(params: &[Param], mapper: &dyn FfiTypeMapper) -> bool {
    params.iter().any(|p| is_unsupported_struct(&p.param_type, mapper))
}

fn returns_unsupported_struct(t: &TypeRef, mapper: &dyn FfiTypeMapper) -> bool {
    is_unsupported_struct(t, mapper)
}

/// A struct-by-value the emitter cannot honour: anything `is_struct_type`
/// catches that isn't one of the curated geometry aliases the runtime
/// already defines as an ftype.
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

/// FunctionPointer typedefs and raw Pointer params/returns reach into
/// territory the scaffold doesn't model (callback-bridging, output buffers).
/// Skip them at this stage so the emitter never emits a wrapper it cannot
/// honour. Selectors and class refs are fine (they are still `void*`).
fn has_unsupported_pointer_alias_param(params: &[Param]) -> bool {
    params.iter().any(|p| is_unsupported_pointer(&p.param_type))
}

fn returns_unsupported_pointer_alias(t: &TypeRef) -> bool {
    is_unsupported_pointer(t)
}

fn is_unsupported_pointer(t: &TypeRef) -> bool {
    matches!(t.kind, TypeRefKind::FunctionPointer { .. } | TypeRefKind::Pointer)
}
