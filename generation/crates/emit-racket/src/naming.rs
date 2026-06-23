//! Racket-specific naming conventions.
//!
//! Builds on the shared naming utilities to produce Racket function names
//! for constructors, properties, and methods.

use apianyware_emit::naming::{
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

/// Extract the argument labels from a **Swift** selector (`base(l1:l2:)`).
///
/// Unlike ObjC selectors (`initWithFoo:bar:`), a Swift selector carries its
/// argument labels inside parentheses. Wildcard labels (`_`, used for
/// positionally-unlabelled arguments like `contains(_:)`) are dropped — they are
/// not part of a readable Racket name. A label-less selector (`makeIterator`,
/// `init`) yields an empty list.
fn swift_selector_labels(selector: &str) -> Vec<&str> {
    match selector.split_once('(') {
        Some((_, rest)) => rest
            .trim_end_matches(')')
            .split(':')
            .filter(|l| !l.is_empty() && *l != "_")
            .collect(),
        None => Vec::new(),
    }
}

/// Generate a Racket binding name for a **Swift-native** instance method
/// (`objc_exposed == false`), e.g. `URLSession.data(from:)` → `urlsession-data-from`.
///
/// The ObjC-shaped [`make_method_name`] mangles a Swift selector (it leaves the
/// `(label:)` parentheses in, producing an unreadable, unreadable-as-an-identifier
/// name like `urlsession-data(from-)`). A Swift-native method instead derives its
/// name from the selector **base** (up to `(`) plus its non-wildcard argument
/// labels — the labels keep genuine overloads distinct (`data(for:)` →
/// `…-data-for`, `data(from:)` → `…-data-from`). A `mutating` value-receiver
/// method (D3) takes the Racket `!` mutation marker.
pub fn make_swift_method_name(class_name: &str, selector: &str, mutating: bool) -> String {
    let base = selector.split('(').next().unwrap_or(selector);
    let mut name = format!(
        "{}-{}",
        class_name_to_lowercase(class_name),
        camel_to_kebab(base)
    );
    for label in swift_selector_labels(selector) {
        name.push('-');
        name.push_str(&camel_to_kebab(label));
    }
    if mutating {
        name.push('!');
    }
    name
}

/// Generate a Racket binding name for a **Swift-native** initializer producer
/// (D2), e.g. `IndexSet.init(integer:)` → `make-indexset-integer`, the bare
/// `IndexSet.init` → `make-indexset`. The argument labels disambiguate
/// overloaded initializers (`init(integer:)` vs `init(integersIn:)`).
pub fn make_swift_init_name(class_name: &str, selector: &str) -> String {
    let base = make_constructor_name(class_name);
    let labels = swift_selector_labels(selector);
    if labels.is_empty() {
        base
    } else {
        let suffix = labels
            .iter()
            .map(|l| camel_to_kebab(l))
            .collect::<Vec<_>>()
            .join("-");
        format!("{base}-{suffix}")
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
    fn test_swift_method_names() {
        // Swift selector: base + non-wildcard labels, no leftover parens.
        assert_eq!(
            make_swift_method_name("URLSession", "data(from:)", false),
            "urlsession-data-from"
        );
        // Overloads stay distinct via their labels.
        assert_eq!(
            make_swift_method_name("URLSession", "data(for:)", false),
            "urlsession-data-for"
        );
        // Wildcard labels are dropped.
        assert_eq!(
            make_swift_method_name("IndexSet", "integerGreaterThan(_:)", false),
            "indexset-integer-greater-than"
        );
        // Label-less selector.
        assert_eq!(
            make_swift_method_name("IndexSet", "makeIterator", false),
            "indexset-make-iterator"
        );
        // Mutating value-receiver gets the `!` marker (D3).
        assert_eq!(
            make_swift_method_name("IndexSet", "insert(_:)", true),
            "indexset-insert!"
        );
        assert_eq!(
            make_swift_method_name("IndexSet", "update(with:)", true),
            "indexset-update-with!"
        );
    }

    #[test]
    fn test_swift_init_names() {
        assert_eq!(make_swift_init_name("IndexSet", "init"), "make-indexset");
        assert_eq!(
            make_swift_init_name("IndexSet", "init(integer:)"),
            "make-indexset-integer"
        );
        assert_eq!(
            make_swift_init_name("IndexSet", "init(integersIn:)"),
            "make-indexset-integers-in"
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
