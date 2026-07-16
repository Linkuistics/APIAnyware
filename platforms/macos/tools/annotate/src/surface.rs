//! The **annotatable-shape** predicate — the signature shapes that warrant a
//! semantic annotation slot (ADR-0050 §4).
//!
//! A method is *annotatable* when its signature structurally carries a fact the
//! annotation model classifies: a **block-typed parameter** (block-invocation
//! style) or an **`NSError **` out-param** (error pattern). These are the two
//! shapes the LLM tier is dispatched over and reliably annotates, so they define
//! the side-channel's surface for staleness detection (ws5
//! `staleness-regen-k46`): a current method with an annotatable shape and no
//! overlay fact is *new-surface*; an overlay fact whose targeted parameter no
//! longer holds its shape is *shape-changed*.
//!
//! The legacy `llm::classify_interest` predicate additionally flags
//! `delegate`/`datasource`/`observer` **selector substrings** to surface LLM
//! *candidates*. That selector heuristic is deliberately **excluded** here: it
//! matches accessor getters (`delegate`, `removeObserver:`) the LLM declines to
//! annotate, so it is ~75% steady-state noise for a staleness diff. The
//! structural predicate below is the durable home for "what is annotatable",
//! independent of the retired `.llm.json` plumbing in `llm`.

use apianyware_types::ir::Method;
use apianyware_types::type_ref::TypeRefKind;

/// True when any parameter of `method` is block-typed.
pub fn has_block_param(method: &Method) -> bool {
    method
        .params
        .iter()
        .any(|p| matches!(p.param_type.kind, TypeRefKind::Block { .. }))
}

/// True when `method`'s last parameter has the `NSError **` out-param shape: a
/// pointer-typed parameter whose name is `error` or ends in `error` (e.g.
/// `outError`). Mirrors `llm::classify_interest`'s `error_out_param` reason.
pub fn has_error_out_param(method: &Method) -> bool {
    let Some(last) = method.params.last() else {
        return false;
    };
    let name = last.name.to_lowercase();
    (name == "error" || name.ends_with("error"))
        && matches!(last.param_type.kind, TypeRefKind::Pointer)
}

/// The annotatable-shape predicate (ADR-0050 §4): a method warrants a semantic
/// annotation slot iff it carries a block parameter or an error out-param.
pub fn is_annotatable(method: &Method) -> bool {
    has_block_param(method) || has_error_out_param(method)
}

/// True when the parameter at `index` is block-typed. Used to verify that a
/// `block-param N` overlay fact still targets a block parameter (else the
/// method's shape moved — *shape-changed*).
pub fn param_at_is_block(method: &Method, index: usize) -> bool {
    matches!(
        method.params.get(index).map(|p| &p.param_type.kind),
        Some(TypeRefKind::Block { .. })
    )
}

/// True when the parameter at `index` is an ownership-relevant **object** type
/// (`id`, a class, or `instancetype`). Used to verify that a `param-ownership N`
/// overlay fact still targets an object parameter. A metatype (`Class`,
/// `class_ref`) is not an owned object and is excluded.
pub fn param_at_is_object(method: &Method, index: usize) -> bool {
    matches!(
        method.params.get(index).map(|p| &p.param_type.kind),
        Some(TypeRefKind::Id { .. } | TypeRefKind::Class { .. } | TypeRefKind::Instancetype)
    )
}

#[cfg(test)]
mod tests {
    use super::*;
    use apianyware_types::ir::{Method, Param};
    use apianyware_types::type_ref::{TypeRef, TypeRefKind};

    fn block_param(name: &str) -> Param {
        Param {
            name: name.to_string(),
            param_type: TypeRef {
                nullable: false,
                kind: TypeRefKind::Block {
                    params: vec![],
                    return_type: Box::new(TypeRef::void()),
                },
            },
        }
    }

    fn param(name: &str, kind: TypeRefKind) -> Param {
        Param {
            name: name.to_string(),
            param_type: TypeRef {
                nullable: false,
                kind,
            },
        }
    }

    fn method(selector: &str, params: Vec<Param>) -> Method {
        Method {
            selector: selector.to_string(),
            class_method: false,
            init_method: false,
            params,
            return_type: TypeRef::void(),
            deprecated: false,
            variadic: false,
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

    #[test]
    fn block_param_makes_method_annotatable() {
        let m = method("enumerateObjectsUsingBlock:", vec![block_param("block")]);
        assert!(has_block_param(&m));
        assert!(is_annotatable(&m));
        assert!(param_at_is_block(&m, 0));
        assert!(!param_at_is_block(&m, 1));
    }

    #[test]
    fn error_out_param_makes_method_annotatable() {
        let m = method(
            "writeToURL:error:",
            vec![
                param(
                    "url",
                    TypeRefKind::Id {
                        protocols: Vec::new(),
                    },
                ),
                param("error", TypeRefKind::Pointer),
            ],
        );
        assert!(has_error_out_param(&m));
        assert!(is_annotatable(&m));
        // `outError`-style trailing names also match.
        let m2 = method("foo:", vec![param("outError", TypeRefKind::Pointer)]);
        assert!(has_error_out_param(&m2));
    }

    #[test]
    fn non_pointer_error_name_is_not_error_out_param() {
        // A param named `error` but not pointer-typed is not an out-param shape.
        let m = method(
            "setError:",
            vec![param(
                "error",
                TypeRefKind::Id {
                    protocols: Vec::new(),
                },
            )],
        );
        assert!(!has_error_out_param(&m));
        assert!(!is_annotatable(&m));
    }

    #[test]
    fn plain_method_is_not_annotatable() {
        // No block, no error out-param, no delegate substring (which is excluded
        // anyway) — a plain accessor is not annotatable.
        let m = method("length", vec![]);
        assert!(!is_annotatable(&m));
        // A `delegate` getter is NOT annotatable here (selector heuristic excluded).
        let d = method("delegate", vec![]);
        assert!(!is_annotatable(&d));
    }

    #[test]
    fn param_at_is_object_matches_object_kinds_only() {
        let m = method(
            "do:with:and:",
            vec![
                param(
                    "a",
                    TypeRefKind::Id {
                        protocols: Vec::new(),
                    },
                ),
                param("b", TypeRefKind::Instancetype),
                param("c", TypeRefKind::Primitive { name: "int".into() }),
            ],
        );
        assert!(param_at_is_object(&m, 0));
        assert!(param_at_is_object(&m, 1));
        assert!(!param_at_is_object(&m, 2));
        assert!(!param_at_is_object(&m, 9)); // out of bounds
    }
}
