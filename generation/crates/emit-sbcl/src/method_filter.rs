//! Which methods the SBCL emitter can bind.
//!
//! Mirrors the scheme targets' filter: defer variadic / deprecated / Swift-paren
//! selectors, methods that pass or return a **non-geometry** struct by value, a
//! **block** parameter with an un-bridgeable signature, or a raw / function
//! pointer. Known-geometry structs are supported by value via `(sb-alien:struct
//! …)` (subject to the runtime confirming `sb-alien` by-value passing, leaf 050);
//! everything else stays deferred until the frontier grows.
//!
//! Block parameters are bridged through the runtime's main-thread callback bounce
//! (leaf 050, ADR-0035): a method with a block param binds **iff** every such
//! block reduces to scalar / `system-area-pointer` slots (see
//! [`crate::ffi_type_mapping::is_bridgeable_block`]). Methods that *return* a
//! block stay deferred (the reverse C-block → Lisp-closure direction is not
//! modelled at this layer).

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

/// Whether a method routes to the `NSError**` out-param path (ADR-0006 applied to
/// SBCL): its selector is in the class's enrichment-derived `error_selectors` set
/// **and** its trailing param is a raw pointer (the `NSError**` cell). SBCL
/// surfaces such errors as a **signalled `ns:objc-error` condition** (ADR-0037),
/// not a `(values result error)` tuple — but the *bindability* question is the
/// same as gerbil's: the trailing error pointer is permitted while any other raw
/// pointer in the visible args still defers.
pub fn is_error_out_method(method: &Method, error_selectors: &HashSet<String>) -> bool {
    error_selectors.contains(&method.selector)
        && matches!(
            method.params.last().map(|p| &p.param_type.kind),
            Some(TypeRefKind::Pointer)
        )
}

/// Supportedness honouring `NSError**` out-param routing. An error-out method
/// ([`is_error_out_method`]) is bindable when its **visible** signature (params
/// minus the trailing `NSError**` cell) is. Non-error methods fall through to
/// plain [`is_supported_method`].
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
    use crate::ffi_type_mapping::SbclFfiTypeMapper;

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

    fn param(name: &str, kind: TypeRefKind) -> Param {
        Param {
            name: name.into(),
            param_type: ty(kind),
        }
    }

    #[test]
    fn plain_method_supported() {
        let m = SbclFfiTypeMapper;
        let meth = method("length", false, false, ty(TypeRefKind::Id));
        assert!(is_supported_method(&meth, &m));
    }

    #[test]
    fn variadic_deprecated_and_swift_paren_deferred() {
        let m = SbclFfiTypeMapper;
        assert!(!is_supported_method(
            &method("foo:", true, false, ty(TypeRefKind::Id)),
            &m
        ));
        assert!(!is_supported_method(
            &method("foo:", false, true, ty(TypeRefKind::Id)),
            &m
        ));
        assert!(!is_supported_method(
            &method("data(from:)", false, false, ty(TypeRefKind::Id)),
            &m
        ));
    }

    #[test]
    fn geometry_return_supported_unknown_struct_deferred() {
        let m = SbclFfiTypeMapper;
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
        let m = SbclFfiTypeMapper;
        let block = ty(TypeRefKind::Block {
            params: vec![],
            return_type: Box::new(TypeRef::void()),
        });
        assert!(!is_supported_method(
            &method("handler", false, false, block),
            &m
        ));
    }

    #[test]
    fn bridgeable_block_param_supported() {
        let m = SbclFfiTypeMapper;
        let mut meth = method("enumerateWithBlock:", false, false, TypeRef::void());
        meth.params = vec![Param {
            name: "block".into(),
            param_type: ty(TypeRefKind::Block {
                params: vec![ty(TypeRefKind::Id)],
                return_type: Box::new(TypeRef::void()),
            }),
        }];
        assert!(is_supported_method(&meth, &m));
        // …but an un-bridgeable block (by-value geometry param) defers.
        meth.params = vec![Param {
            name: "block".into(),
            param_type: ty(TypeRefKind::Block {
                params: vec![ty(TypeRefKind::Struct {
                    name: "CGRect".into(),
                })],
                return_type: Box::new(TypeRef::void()),
            }),
        }];
        assert!(!is_supported_method(&meth, &m));
    }

    #[test]
    fn error_out_method_recognised_and_bindable_in_context() {
        let m = SbclFfiTypeMapper;
        let mut errs = HashSet::new();
        errs.insert("writeToFile:error:".to_string());
        let mut meth = method(
            "writeToFile:error:",
            false,
            false,
            ty(TypeRefKind::Primitive {
                name: "bool".into(),
            }),
        );
        meth.params = vec![
            param("path", TypeRefKind::Id),
            param("error", TypeRefKind::Pointer),
        ];
        assert!(is_error_out_method(&meth, &errs));
        // Plain supportedness defers it (the trailing raw pointer).
        assert!(!is_supported_method(&meth, &m));
        // Error-context supportedness accepts it (the trailing pointer is the cell).
        assert!(is_supported_method_ctx(&meth, &m, &errs));
        // Not in the set ⇒ stays deferred.
        assert!(!is_supported_method_ctx(&meth, &m, &HashSet::new()));
    }

    #[test]
    fn error_method_with_other_raw_pointer_still_defers() {
        let m = SbclFfiTypeMapper;
        let mut errs = HashSet::new();
        errs.insert("doThing:error:".to_string());
        let mut meth = method(
            "doThing:error:",
            false,
            false,
            ty(TypeRefKind::Primitive {
                name: "bool".into(),
            }),
        );
        meth.params = vec![
            param("raw", TypeRefKind::Pointer),
            param("error", TypeRefKind::Pointer),
        ];
        assert!(!is_supported_method_ctx(&meth, &m, &errs));
    }

    #[test]
    fn return_classifiers() {
        let m = SbclFfiTypeMapper;
        assert!(returns_object_type(
            &method("self", false, false, ty(TypeRefKind::Id)),
            &m
        ));
        assert!(returns_void(
            &method("noop", false, false, TypeRef::void()),
            &m
        ));
        assert!(has_block_params(&[param(
            "b",
            TypeRefKind::Block {
                params: vec![],
                return_type: Box::new(TypeRef::void()),
            }
        )]));
    }
}
