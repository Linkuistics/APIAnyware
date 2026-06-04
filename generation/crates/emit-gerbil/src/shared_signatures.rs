//! Per-framework helpers shared by the construct emitters, plus the
//! per-signature `define-c-lambda` dedup key.
//!
//! ## Shared-object linkage
//!
//! Unlike chez's `(load-shared-object …)` (a runtime call into a global symbol
//! table), Gerbil/Gambit resolves C symbols at **link time**: `gxc -exe`
//! `-ld-options "-framework Foundation"` pulls the framework in, and the
//! `define-c-lambda` bodies call the symbols directly. So the framework→link
//! argument here feeds the *build* (leaf 060's CLI / 070's bundler), not a
//! per-file load form. [`framework_link_arg`] returns the `-framework <Name>`
//! token (or the libSystem note for synthetic pseudo-frameworks).
//!
//! ## Signature deduplication
//!
//! arm64 forbids a variadic `objc_msgSend`, so each distinct method ABI shape
//! needs its own inline-cast `define-c-lambda`. Many selectors share a shape
//! (`-length`, `-count`, `-hash` are all `(id, SEL) → NSUInteger`), so the class
//! emitter (leaf 020) groups methods by [`msgsend_signature_key`] and emits one
//! crossing per distinct key — the compiled-FFI analogue of chez's per-signature
//! `foreign-procedure` sharing (ADR-0015/0017).

use apianyware_macos_emit::ffi_type_mapping::FfiTypeMapper;
use apianyware_macos_types::ir::Param;
use apianyware_macos_types::type_ref::TypeRef;

use crate::ffi_type_mapping::POINTER;

/// The `-framework <Name>` linker token for a framework. Synthetic
/// pseudo-frameworks like `libdispatch` have no `.framework` bundle — their
/// symbols live in `libSystem`, which is always linked, so they need no token.
pub fn framework_link_arg(framework_name: &str) -> Option<String> {
    if framework_name == "libdispatch" {
        return None;
    }
    Some(format!("-framework {framework_name}"))
}

/// The framework umbrella header a `begin-ffi` block must `#include` so the C
/// symbols a constant/function `define-c-lambda` body references (`extern`
/// globals, C functions) are **declared**. Unlike chez's `foreign-entry`
/// (link-time symbol lookup, no declaration needed), Gambit emits real C that
/// calls/reads the symbol by name, so the declaration must be in scope. The
/// umbrella is Objective-C (`<Foundation/Foundation.h>` etc.), which only
/// compiles because the whole FFI unit is built `-x objective-c` (design §4,
/// FINDINGS §2). Most Apple frameworks expose `<Name/Name.h>`; the synthetic
/// `libdispatch` pseudo-framework's symbols live behind `<dispatch/dispatch.h>`.
/// Other synthetic pseudo-frameworks that surface here will need an entry (an
/// inbox item for 060/070, surfaced on first compile).
pub fn framework_umbrella_header(framework_name: &str) -> String {
    match framework_name {
        "libdispatch" => "<dispatch/dispatch.h>".to_string(),
        name => format!("<{name}/{name}.h>"),
    }
}

/// Symbols declared in libdispatch/pthread headers but not exported by the live
/// `libSystem` on modern macOS — a `define-c-lambda` for these fails to link.
/// Kept in lockstep with the racket/chez skip lists so all targets defer the
/// same set.
pub fn is_libdispatch_unexported(symbol: &str) -> bool {
    matches!(
        symbol,
        "dispatch_cancel"
            | "dispatch_notify"
            | "dispatch_testcancel"
            | "dispatch_wait"
            | "pthread_jit_write_with_callback_np"
    )
}

/// A canonical key for a method's `objc_msgSend` ABI signature, used to share
/// one `define-c-lambda` across every selector with the same shape. The msgSend
/// prototype is always `(id, SEL, <params…>) → <ret>`, so the receiver and
/// selector slots are constant `(pointer void)` and the key is determined by the
/// parameter tokens and the return token. Two methods with equal keys can reuse
/// a single crossing; the binding name is derived from the key by leaf 020.
///
/// Format: `"<param-tok>|<param-tok>|…=><ret-tok>"` (the leading `id`/`SEL`
/// slots are implicit and omitted, since they never vary).
pub fn msgsend_signature_key(
    params: &[Param],
    return_type: &TypeRef,
    mapper: &dyn FfiTypeMapper,
) -> String {
    let param_toks: Vec<String> = params
        .iter()
        .map(|p| mapper.map_type(&p.param_type, false))
        .collect();
    let ret_tok = mapper.map_type(return_type, true);
    format!("{}=>{}", param_toks.join("|"), ret_tok)
}

/// The full `define-c-lambda` arg-type list for a msgSend signature, including
/// the implicit leading `id` receiver and `SEL` selector slots (both
/// `(pointer void)`). Leaf 020 splices this between `(` and the return token.
pub fn msgsend_arg_tokens(params: &[Param], mapper: &dyn FfiTypeMapper) -> Vec<String> {
    let mut toks = vec![POINTER.to_string(), POINTER.to_string()];
    toks.extend(params.iter().map(|p| mapper.map_type(&p.param_type, false)));
    toks
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::ffi_type_mapping::GerbilFfiTypeMapper;
    use apianyware_macos_types::ir::Param;
    use apianyware_macos_types::type_ref::{TypeRef, TypeRefKind};

    fn param(kind: TypeRefKind) -> Param {
        Param {
            name: "x".into(),
            param_type: TypeRef {
                nullable: false,
                kind,
            },
        }
    }

    fn ty(kind: TypeRefKind) -> TypeRef {
        TypeRef {
            nullable: false,
            kind,
        }
    }

    #[test]
    fn link_arg_real_vs_synthetic() {
        assert_eq!(
            framework_link_arg("Foundation"),
            Some("-framework Foundation".into())
        );
        assert_eq!(framework_link_arg("libdispatch"), None);
    }

    #[test]
    fn unexported_list() {
        assert!(is_libdispatch_unexported("dispatch_cancel"));
        assert!(!is_libdispatch_unexported("dispatch_async"));
    }

    #[test]
    fn same_shape_shares_key() {
        let m = GerbilFfiTypeMapper;
        // -length and -count are both (id, SEL) → NSUInteger.
        let length = msgsend_signature_key(
            &[],
            &ty(TypeRefKind::Primitive {
                name: "uint64".into(),
            }),
            &m,
        );
        let count = msgsend_signature_key(
            &[],
            &ty(TypeRefKind::Primitive {
                name: "nsuinteger".into(),
            }),
            &m,
        );
        assert_eq!(length, count);
        assert_eq!(length, "=>unsigned-int64");
    }

    #[test]
    fn differing_params_differ() {
        let m = GerbilFfiTypeMapper;
        let one = msgsend_signature_key(&[param(TypeRefKind::Id)], &ty(TypeRefKind::Id), &m);
        let two = msgsend_signature_key(
            &[param(TypeRefKind::Primitive {
                name: "double".into(),
            })],
            &ty(TypeRefKind::Id),
            &m,
        );
        assert_ne!(one, two);
        assert_eq!(one, "(pointer void)=>(pointer void)");
        assert_eq!(two, "double=>(pointer void)");
    }

    #[test]
    fn arg_tokens_prepend_id_and_sel() {
        let m = GerbilFfiTypeMapper;
        let toks = msgsend_arg_tokens(
            &[param(TypeRefKind::Primitive {
                name: "double".into(),
            })],
            &m,
        );
        assert_eq!(toks, vec!["(pointer void)", "(pointer void)", "double"]);
    }
}
