//! Cross-emitter helpers shared by the construct emitters and the trampoline pass.
//!
//! ## Why this is small (vs gerbil's `shared_signatures`)
//!
//! gerbil's peer module carries a per-signature `define-c-lambda` dedup key
//! (`msgsend_signature_key`): arm64 forbids a variadic `objc_msgSend`, so each distinct
//! method ABI shape needs its own inline-cast crossing, and many selectors share a shape.
//! **sbcl needs no such dedup.** The direct dispatch open-codes one
//! `(sb-alien:alien-funcall (sb-alien:sap-alien +objc-msgsend+ (sb-alien:function …)) …)`
//! per `defmethod` (emit_generics), and each trampoline `aw_sbcl_*` entry is a *distinct*
//! named C symbol bound by its own `extern-alien` ([`crate::trampoline`]) — neither path
//! reuses a shared crossing, so there is nothing to key. What *is* genuinely shared is the
//! libdispatch skip list, which both the direct function path ([`crate::emit_functions`])
//! and the trampoline pass must apply identically — its canonical home is here.

/// Symbols the digester surfaces from the libdispatch/pthread headers but that the live
/// `libSystem` on modern macOS does **not** export (macros / inline shims): a binding to
/// them — a direct `define-alien-routine` or a trampoline — fails to link. Kept in
/// lockstep with the racket/chez/gerbil skip lists so every target defers the same set.
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

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn unexported_list_matches_peers() {
        assert!(is_libdispatch_unexported("dispatch_cancel"));
        assert!(is_libdispatch_unexported(
            "pthread_jit_write_with_callback_np"
        ));
        // A real, exported symbol is not filtered.
        assert!(!is_libdispatch_unexported("dispatch_async"));
    }
}
