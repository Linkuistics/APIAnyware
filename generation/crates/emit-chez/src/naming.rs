//! Chez-specific naming.
//!
//! Mirrors the racket conventions (lowercase class prefix + kebab selector,
//! `make-…` for constructors, trailing `!` on mutating selectors) since the
//! same on-disk shape and call-site ergonomics are wanted. Identifiers are
//! Scheme symbols — same alphabet as Racket — so the shared
//! `selector_to_kebab_name` does the heavy lifting.

use apianyware_macos_emit::naming::{
    camel_to_kebab, class_name_to_lowercase, is_mutating_selector, selector_to_kebab_name,
};

pub fn make_constructor_name(class_name: &str) -> String {
    format!("make-{}", class_name_to_lowercase(class_name))
}

pub fn make_unique_constructor_name(class_name: &str, selector: &str) -> String {
    format!(
        "{}-{}",
        make_constructor_name(class_name),
        selector_to_kebab_name(selector)
    )
}

pub fn make_property_getter_name(class_name: &str, property_name: &str) -> String {
    format!(
        "{}-{}",
        class_name_to_lowercase(class_name),
        camel_to_kebab(property_name)
    )
}

pub fn make_property_setter_name(class_name: &str, property_name: &str) -> String {
    format!(
        "{}-set-{}!",
        class_name_to_lowercase(class_name),
        camel_to_kebab(property_name)
    )
}

pub fn make_method_name(class_name: &str, selector: &str) -> String {
    let base = format!(
        "{}-{}",
        class_name_to_lowercase(class_name),
        selector_to_kebab_name(selector)
    );
    if is_mutating_selector(selector) {
        format!("{base}!")
    } else {
        base
    }
}

pub fn make_class_method_name(class_name: &str, selector: &str, disambiguate: bool) -> String {
    let base = make_method_name(class_name, selector);
    if !disambiguate {
        return base;
    }
    match base.strip_suffix('!') {
        Some(stem) => format!("{stem}-class!"),
        None => format!("{base}-class"),
    }
}

pub fn make_class_property_getter_name(
    class_name: &str,
    property_name: &str,
    disambiguate: bool,
) -> String {
    let base = make_property_getter_name(class_name, property_name);
    if disambiguate {
        format!("{base}-class")
    } else {
        base
    }
}

pub fn make_class_property_setter_name(
    class_name: &str,
    property_name: &str,
    disambiguate: bool,
) -> String {
    let base = make_property_setter_name(class_name, property_name);
    if !disambiguate {
        return base;
    }
    match base.strip_suffix('!') {
        Some(stem) => format!("{stem}-class!"),
        None => format!("{base}-class"),
    }
}

/// Per-method foreign-procedure identifier. Built from the selector so two
/// methods with the same signature still get distinct C symbol bindings —
/// shared-signature deduplication is leaf 080's concern, not this scaffold's.
pub fn make_msgsend_binding_name(class_name: &str, selector: &str) -> String {
    format!(
        "%msg-{}-{}",
        class_name_to_lowercase(class_name),
        selector_to_kebab_name(selector)
    )
}

/// Per-method cached selector identifier. `%` prefix marks "private to this
/// library" by convention — Chez treats it as an ordinary symbol character.
pub fn make_selector_binding_name(class_name: &str, selector: &str) -> String {
    format!(
        "%sel-{}-{}",
        class_name_to_lowercase(class_name),
        selector_to_kebab_name(selector)
    )
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn constructors() {
        assert_eq!(make_constructor_name("NSString"), "make-nsstring");
        assert_eq!(
            make_unique_constructor_name("NSString", "initWithUTF8String:"),
            "make-nsstring-init-with-utf8-string"
        );
    }

    #[test]
    fn methods() {
        assert_eq!(make_method_name("NSString", "length"), "nsstring-length");
        assert_eq!(
            make_method_name("NSArray", "objectAtIndex:"),
            "nsarray-object-at-index"
        );
        assert_eq!(
            make_method_name("NSWindow", "setTitle:"),
            "nswindow-set-title!"
        );
    }

    #[test]
    fn msgsend_binding() {
        assert_eq!(
            make_msgsend_binding_name("NSString", "length"),
            "%msg-nsstring-length"
        );
    }
}
