//! Chez per-framework helpers shared by the constants / functions emitters.
//!
//! Chez's FFI is global: `load-shared-object` brings every symbol into one
//! flat resolution table and subsequent `foreign-procedure` / `foreign-entry`
//! calls look there. So each generated framework file emits its own
//! `(load-shared-object …)` for the framework's dylib — there is no
//! per-file handle equivalent to Racket's `_fw-lib` binding.

/// Argument to pass to `load-shared-object` for the given framework.
///
/// Real frameworks live at
/// `/System/Library/Frameworks/{Name}.framework/{Name}`. Synthetic
/// pseudo-frameworks like `libdispatch` have no `.framework` bundle —
/// their symbols ship inside `libSystem.dylib`.
pub fn framework_shared_object_arg(framework_name: &str) -> String {
    if framework_name == "libdispatch" {
        return "libSystem.dylib".to_string();
    }
    format!(
        "/System/Library/Frameworks/{0}.framework/{0}",
        framework_name
    )
}

/// Returns `true` if the symbol is declared in libdispatch/pthread
/// headers but is not exported by the live `libSystem` dylib on modern
/// macOS. Emitting a `foreign-procedure` for these causes a load-time
/// "could not find foreign entry" error. List mirrors emit-racket's;
/// kept in sync so both targets skip the same set.
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
    fn framework_path_for_real_framework() {
        assert_eq!(
            framework_shared_object_arg("Foundation"),
            "/System/Library/Frameworks/Foundation.framework/Foundation"
        );
    }

    #[test]
    fn framework_path_for_libdispatch() {
        assert_eq!(
            framework_shared_object_arg("libdispatch"),
            "libSystem.dylib"
        );
    }

    #[test]
    fn libdispatch_unexported_list() {
        assert!(is_libdispatch_unexported("dispatch_cancel"));
        assert!(!is_libdispatch_unexported("dispatch_async"));
    }
}
