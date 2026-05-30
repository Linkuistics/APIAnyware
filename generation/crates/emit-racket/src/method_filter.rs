//! Method and property filtering for Racket code generation.
//!
//! Determines which methods can be bound (supported) and which should be skipped
//! (variadic, deprecated, etc.).

use apianyware_macos_emit::ffi_type_mapping::FfiTypeMapper;
use apianyware_macos_types::ir::{Method, Param};
use apianyware_macos_types::type_ref::TypeRefKind;

/// Check if a method can be bound in Racket.
///
/// Skips variadic, deprecated, and Swift-style methods whose selectors contain
/// parentheses (e.g., `init(string:)`). Swift-style selectors cannot be called
/// via `objc_msgSend` or Racket's `tell` macro — they require Swift interop.
/// ObjC equivalents (e.g., `initWithString:`) are already present in the IR.
pub fn is_supported_method(method: &Method) -> bool {
    !method.variadic && !method.deprecated && !method.selector.contains('(')
}

/// Check if all parameters of a method are object types (can use Racket's `tell`).
pub fn all_params_are_object_type(params: &[Param], mapper: &dyn FfiTypeMapper) -> bool {
    params.iter().all(|p| mapper.is_object_type(&p.param_type))
}

/// Check if a method's return type is an object type.
pub fn returns_object_type(method: &Method, mapper: &dyn FfiTypeMapper) -> bool {
    mapper.is_object_type(&method.return_type)
}

/// Check if a method returns void.
pub fn returns_void(method: &Method, mapper: &dyn FfiTypeMapper) -> bool {
    mapper.is_void(&method.return_type)
}

/// Check if any parameter is a block type.
pub fn has_block_params(params: &[Param]) -> bool {
    params
        .iter()
        .any(|p| matches!(p.param_type.kind, TypeRefKind::Block { .. }))
}

/// Determine the dispatch strategy for a method.
///
/// - `Tell`: all params are objects AND return is object or void → use Racket's `tell`
/// - `TypedMsgSend`: needs explicit `objc_msgSend` binding with typed FFI signature
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum DispatchStrategy {
    Tell,
    TypedMsgSend,
}

/// Determine dispatch strategy for a method.
pub fn dispatch_strategy(method: &Method, mapper: &dyn FfiTypeMapper) -> DispatchStrategy {
    let all_id = all_params_are_object_type(&method.params, mapper);
    let ret_id = returns_object_type(method, mapper);
    let ret_void = returns_void(method, mapper);

    if all_id && (ret_id || ret_void) {
        DispatchStrategy::Tell
    } else {
        DispatchStrategy::TypedMsgSend
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use apianyware_macos_emit::ffi_type_mapping::RacketFfiTypeMapper;
    use apianyware_macos_types::ir::{Method, Param};
    use apianyware_macos_types::type_ref::{TypeRef, TypeRefKind};

    fn make_type(kind: TypeRefKind) -> TypeRef {
        TypeRef {
            nullable: false,
            kind,
        }
    }

    fn make_param(name: &str, kind: TypeRefKind) -> Param {
        Param {
            name: name.to_string(),
            param_type: make_type(kind),
        }
    }

    fn make_method(
        selector: &str,
        params: Vec<Param>,
        return_kind: TypeRefKind,
        variadic: bool,
        deprecated: bool,
    ) -> Method {
        Method {
            selector: selector.to_string(),
            class_method: false,
            init_method: false,
            params,
            return_type: make_type(return_kind),
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

    #[test]
    fn test_supported_method_filtering() {
        let normal = make_method(
            "length",
            vec![],
            TypeRefKind::Primitive {
                name: "uint64".into(),
            },
            false,
            false,
        );
        let variadic = make_method("format:", vec![], TypeRefKind::Id, true, false);
        let deprecated = make_method("old:", vec![], TypeRefKind::Id, false, true);

        assert!(is_supported_method(&normal));
        assert!(!is_supported_method(&variadic));
        assert!(!is_supported_method(&deprecated));
    }

    #[test]
    fn test_dispatch_strategy_tell() {
        let mapper = RacketFfiTypeMapper;
        let m = make_method(
            "objectAtIndex:",
            vec![make_param("index", TypeRefKind::Id)],
            TypeRefKind::Id,
            false,
            false,
        );
        assert_eq!(dispatch_strategy(&m, &mapper), DispatchStrategy::Tell);
    }

    #[test]
    fn test_dispatch_strategy_typed() {
        let mapper = RacketFfiTypeMapper;
        let m = make_method(
            "objectAtIndex:",
            vec![make_param(
                "index",
                TypeRefKind::Primitive {
                    name: "uint64".into(),
                },
            )],
            TypeRefKind::Id,
            false,
            false,
        );
        assert_eq!(
            dispatch_strategy(&m, &mapper),
            DispatchStrategy::TypedMsgSend
        );
    }

    #[test]
    fn test_dispatch_strategy_void_return_tell() {
        let mapper = RacketFfiTypeMapper;
        let m = make_method(
            "addObject:",
            vec![make_param("obj", TypeRefKind::Id)],
            TypeRefKind::Primitive {
                name: "void".into(),
            },
            false,
            false,
        );
        assert_eq!(dispatch_strategy(&m, &mapper), DispatchStrategy::Tell);
    }
}
