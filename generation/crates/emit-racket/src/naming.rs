//! Racket-specific naming conventions.
//!
//! Builds on the shared naming utilities to produce Racket function names
//! for constructors, properties, and methods.

use apianyware_macos_emit::naming::{
    camel_to_kebab, class_name_to_lowercase, is_mutating_selector, selector_to_kebab_name,
};

/// Generate a Racket constructor name: "make-nswindow"
pub fn make_constructor_name(class_name: &str) -> String {
    format!("make-{}", class_name_to_lowercase(class_name))
}

/// Generate a unique constructor name for a specific init selector:
/// "make-nswindow-init-with-content-rect-style-mask-backing-defer"
pub fn make_unique_constructor_name(class_name: &str, selector: &str) -> String {
    format!(
        "{}-{}",
        make_constructor_name(class_name),
        selector_to_kebab_name(selector)
    )
}

/// Generate a property getter name: "nswindow-title"
pub fn make_property_getter_name(class_name: &str, property_name: &str) -> String {
    format!(
        "{}-{}",
        class_name_to_lowercase(class_name),
        camel_to_kebab(property_name)
    )
}

/// Generate a property setter name: "nswindow-set-title!"
pub fn make_property_setter_name(class_name: &str, property_name: &str) -> String {
    format!(
        "{}-set-{}!",
        class_name_to_lowercase(class_name),
        camel_to_kebab(property_name)
    )
}

/// Generate a method wrapper name: "nswindow-make-key-and-order-front!"
///
/// Mutating methods get a `!` suffix per Racket convention.
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

/// Generate a class-method wrapper name, disambiguating against an instance
/// method that shares the same selector. When `disambiguate` is true, the
/// class variant gains a `-class` suffix (inserted before the mutating `!`
/// marker, if present): "nsevent-modifier-flags-class".
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

/// Generate a class-property getter name, disambiguating against an
/// instance property whose getter shares the same Racket name.
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

/// Generate a class-property setter name, disambiguating against an
/// instance property whose setter shares the same Racket name.
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

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_constructor_names() {
        assert_eq!(make_constructor_name("NSWindow"), "make-nswindow");
        assert_eq!(
            make_unique_constructor_name(
                "NSWindow",
                "initWithContentRect:styleMask:backing:defer:"
            ),
            "make-nswindow-init-with-content-rect-style-mask-backing-defer"
        );
    }

    #[test]
    fn test_property_names() {
        assert_eq!(
            make_property_getter_name("NSWindow", "title"),
            "nswindow-title"
        );
        assert_eq!(
            make_property_setter_name("NSWindow", "title"),
            "nswindow-set-title!"
        );
        assert_eq!(
            make_property_getter_name("NSWindow", "backgroundColor"),
            "nswindow-background-color"
        );
    }

    #[test]
    fn test_method_names() {
        // "make" is not a mutating prefix — no bang suffix
        assert_eq!(
            make_method_name("NSWindow", "makeKeyAndOrderFront:"),
            "nswindow-make-key-and-order-front"
        );
        assert_eq!(make_method_name("NSString", "length"), "nsstring-length");
        assert_eq!(
            make_method_name("NSWindow", "setTitle:"),
            "nswindow-set-title!"
        );
        assert_eq!(
            make_method_name("NSString", "UTF8String"),
            "nsstring-utf8-string"
        );
    }

    #[test]
    fn test_class_method_disambiguation() {
        // Without disambiguation, the class variant matches the instance name.
        assert_eq!(
            make_class_method_name("NSEvent", "modifierFlags", false),
            "nsevent-modifier-flags"
        );
        // With disambiguation, the class variant gains a `-class` suffix.
        assert_eq!(
            make_class_method_name("NSEvent", "modifierFlags", true),
            "nsevent-modifier-flags-class"
        );
        // Mutating selectors keep `!` at the tail after disambiguation.
        assert_eq!(
            make_class_method_name("NSFoo", "setShared:", true),
            "nsfoo-set-shared-class!"
        );
    }
}
