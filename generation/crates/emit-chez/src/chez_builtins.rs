//! Avoiding generated bindings that collide with `(chezscheme)` builtins.
//!
//! A generated library imports `(chezscheme)` for `define`, `let`,
//! `foreign-procedure`, the FFI ftypes, etc. Chez is strict R6RS: a local
//! `(define X …)` whose name `X` is *also* imported from `(chezscheme)` is a hard
//! "multiple definitions for X" error at library load — unlike Gerbil/Gambit,
//! where shadowing an imported procedure is harmless (cf. emit-gerbil's
//! `is_reserved_surface_name`, which deliberately omits procedures).
//!
//! Most generated names are multi-segment kebab (`urlsession-data-from`) and never
//! collide, but a few do: value-struct **init producers** spell `make-<struct>`
//! (`Foundation.Date` → `make-date`, colliding with Chez's `make-date`; the
//! `mediaextension` `List` value struct → `make-list`), and free functions mirror
//! libm names (`coregraphics/functions.sls` exports `acos`, `cos`, `sin`, …). These
//! stayed latent until a sample app imported the owning framework umbrella (which
//! loads every sub-library); the `add-swift-native-method-coverage/040-chez/020`
//! cold rerun + method-probe VM-verify surfaced them via `(apianyware foundation)`.
//!
//! Fix: `except` the colliding names from `(import (chezscheme) …)`, letting the
//! local `define` win. This is provably safe — a file that both *exported* `X` and
//! *used* Chez's builtin `X` in a body would already fail to load today (the
//! "multiple definitions" error), so excepting an **export** name never breaks a
//! currently-loading file; for the failing files it makes the intended local
//! binding the one in scope.
//!
//! The builtin set is `(environment-symbols (environment '(chezscheme)))` captured
//! verbatim in `chez_builtins.txt`. Regenerate it (when the host Chez changes) with:
//! ```text
//! echo '(import (chezscheme)) (for-each (lambda (s) (display s)(newline)) \
//!   (environment-symbols (environment (quote (chezscheme)))))' \
//!   | chez -q | sort -u > generation/crates/emit-chez/src/chez_builtins.txt
//! ```

use std::collections::HashSet;
use std::sync::LazyLock;

/// Every identifier exported by Chez's `(chezscheme)` library (verbatim from
/// `environment-symbols`). See the module docs for the regeneration recipe.
static CHEZSCHEME_BUILTINS: LazyLock<HashSet<&'static str>> = LazyLock::new(|| {
    include_str!("chez_builtins.txt")
        .lines()
        .map(str::trim)
        .filter(|l| !l.is_empty())
        .collect()
});

/// Is `name` an identifier exported by `(chezscheme)`?
pub fn is_chezscheme_builtin(name: &str) -> bool {
    CHEZSCHEME_BUILTINS.contains(name)
}

/// The `(chezscheme)` import spec for a generated library whose exported names are
/// `exports`: bare `(chezscheme)` when nothing collides, else
/// `(except (chezscheme) <colliders…>)` so the local `define`s of those names are
/// not rejected as redefinitions of `(chezscheme)` imports.
pub fn chezscheme_import_spec(exports: &[String]) -> String {
    let mut clash: Vec<&str> = exports
        .iter()
        .map(String::as_str)
        .filter(|n| is_chezscheme_builtin(n))
        .collect();
    clash.sort_unstable();
    clash.dedup();
    if clash.is_empty() {
        "(chezscheme)".to_string()
    } else {
        format!("(except (chezscheme) {})", clash.join(" "))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn known_builtins_are_recognised() {
        // The exact collisions the cold rerun surfaced.
        assert!(is_chezscheme_builtin("make-date"));
        assert!(is_chezscheme_builtin("make-list"));
        assert!(is_chezscheme_builtin("cos"));
        assert!(is_chezscheme_builtin("values"));
        // Generated kebab names are not builtins.
        assert!(!is_chezscheme_builtin("urlsession-data-from"));
        assert!(!is_chezscheme_builtin("make-indexset-integer"));
    }

    #[test]
    fn import_spec_bare_when_no_collision() {
        let exports = vec![
            "make-indexset-integer".to_string(),
            "indexset-contains".to_string(),
        ];
        assert_eq!(chezscheme_import_spec(&exports), "(chezscheme)");
    }

    #[test]
    fn import_spec_excepts_colliding_builtins_sorted() {
        let exports = vec![
            "make-date".to_string(),
            "date-formatted".to_string(),
            "make-list".to_string(),
        ];
        assert_eq!(
            chezscheme_import_spec(&exports),
            "(except (chezscheme) make-date make-list)"
        );
    }

    #[test]
    fn import_spec_only_excepts_export_names_not_body_uses() {
        // `values` is the async identity marshaller used in bodies but never an
        // export — it must NOT be excepted (that would break the marshaller).
        let exports = vec!["urlsession-data-from".to_string()];
        assert_eq!(chezscheme_import_spec(&exports), "(chezscheme)");
    }
}
