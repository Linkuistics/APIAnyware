//! Cocoa ownership family detection from selector naming conventions.
//!
//! Methods in the `init`, `new`, `copy`, or `mutableCopy` families return
//! retained (+1 refcount) objects per Cocoa memory management rules.

/// Determine if a method returns a retained (+1) object per Cocoa naming conventions.
///
/// Instance methods in the `init`, `copy`, or `mutableCopy` families return retained.
/// Class methods in the `new`, `copy`, or `mutableCopy` families return retained.
pub fn is_returns_retained(selector: &str, is_class_method: bool) -> bool {
    if !is_class_method && is_method_family(selector, "init") {
        return true;
    }
    if is_class_method && is_method_family(selector, "new") {
        return true;
    }
    is_method_family(selector, "copy") || is_method_family(selector, "mutableCopy")
}

/// Check if a selector belongs to a method family.
///
/// A selector matches if it equals the family name exactly, or starts with it
/// followed by an uppercase letter, ':', or '(' (for Swift-style selectors).
/// This follows Apple's Cocoa naming conventions:
/// - `init` matches `init`, `initWithString:`, `init(arrayLiteral:)`, but not `initialize`
/// - `copy` matches `copy`, `copyWithZone:`, but not `copyright`
fn is_method_family(selector: &str, family: &str) -> bool {
    if selector == family {
        return true;
    }
    if selector.len() > family.len() && selector.starts_with(family) {
        let next = selector.as_bytes()[family.len()];
        // '(' handles Swift-style selectors like `init(arrayLiteral:)`
        return next.is_ascii_uppercase() || next == b':' || next == b'(';
    }
    false
}

#[cfg(test)]
mod tests {
    use super::*;

    // -----------------------------------------------------------------------
    // is_method_family
    // -----------------------------------------------------------------------

    #[test]
    fn init_family_exact_match() {
        assert!(is_method_family("init", "init"));
    }

    #[test]
    fn init_family_with_uppercase_continuation() {
        assert!(is_method_family("initWithString:", "init"));
        assert!(is_method_family("initWithCoder:", "init"));
    }

    #[test]
    fn init_family_swift_style_selector() {
        assert!(is_method_family("init(arrayLiteral:)", "init"));
        assert!(is_method_family("init()", "init"));
    }

    #[test]
    fn init_family_rejects_lowercase_continuation() {
        assert!(!is_method_family("initialize", "init"));
        assert!(!is_method_family("initials", "init"));
    }

    #[test]
    fn copy_family_matches() {
        assert!(is_method_family("copy", "copy"));
        assert!(is_method_family("copyWithZone:", "copy"));
    }

    #[test]
    fn copy_family_rejects_non_family() {
        assert!(!is_method_family("copyright", "copy"));
    }

    #[test]
    fn mutable_copy_family_matches() {
        assert!(is_method_family("mutableCopy", "mutableCopy"));
        assert!(is_method_family("mutableCopyWithZone:", "mutableCopy"));
    }

    #[test]
    fn new_family_matches() {
        assert!(is_method_family("new", "new"));
        assert!(is_method_family("newWithName:", "new"));
    }

    #[test]
    fn new_family_rejects_non_family() {
        assert!(!is_method_family("newspaper", "new"));
    }

    // -----------------------------------------------------------------------
    // is_returns_retained
    // -----------------------------------------------------------------------

    #[test]
    fn instance_init_returns_retained() {
        assert!(is_returns_retained("init", false));
        assert!(is_returns_retained("initWithString:", false));
    }

    #[test]
    fn class_init_does_not_return_retained() {
        // init is only retained for instance methods
        assert!(!is_returns_retained("init", true));
    }

    #[test]
    fn class_new_returns_retained() {
        assert!(is_returns_retained("new", true));
        assert!(is_returns_retained("newWithName:", true));
    }

    #[test]
    fn instance_new_does_not_return_retained() {
        assert!(!is_returns_retained("new", false));
    }

    #[test]
    fn copy_returns_retained_for_both() {
        assert!(is_returns_retained("copy", false));
        assert!(is_returns_retained("copy", true));
        assert!(is_returns_retained("copyWithZone:", false));
    }

    #[test]
    fn mutable_copy_returns_retained_for_both() {
        assert!(is_returns_retained("mutableCopy", false));
        assert!(is_returns_retained("mutableCopy", true));
    }

    #[test]
    fn regular_methods_not_retained() {
        assert!(!is_returns_retained("compare:", false));
        assert!(!is_returns_retained("description", false));
        assert!(!is_returns_retained("stringByAppendingString:", false));
        assert!(!is_returns_retained("alloc", true));
    }
}
