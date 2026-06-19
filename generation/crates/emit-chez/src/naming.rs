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

/// Extract the argument labels from a **Swift** selector (`base(l1:l2:)`).
///
/// Unlike ObjC selectors (`initWithFoo:bar:`), a Swift selector carries its
/// argument labels inside parentheses. Wildcard labels (`_`, used for
/// positionally-unlabelled arguments like `contains(_:)`) are dropped — they are
/// not part of a readable Scheme name. A label-less selector (`makeIterator`,
/// `init`) yields an empty list. Mirrors emit-racket so the two targets name
/// overloads identically.
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

/// Generate a Chez binding name for a **Swift-native** instance method
/// (`objc_exposed == false`), e.g. `URLSession.data(from:)` → `urlsession-data-from`.
///
/// The ObjC-shaped [`make_method_name`] mangles a Swift selector (it leaves the
/// `(label:)` parentheses in, producing an unreadable name like
/// `urlsession-data(from-)`). A Swift-native method instead derives its name from
/// the selector **base** (up to `(`) plus its non-wildcard argument labels — the
/// labels keep genuine overloads distinct (`data(for:)` → `…-data-for`,
/// `data(from:)` → `…-data-from`). A `mutating` value-receiver method (D3) takes
/// the Scheme `!` mutation marker.
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

/// Generate a Chez binding name for a **Swift-native** initializer producer (D2),
/// e.g. `IndexSet.init(integer:)` → `make-indexset-integer`, the bare `IndexSet.init`
/// → `make-indexset`. The argument labels disambiguate overloaded initializers
/// (`init(integer:)` vs `init(integersIn:)`).
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
    fn swift_method_names_keep_overloads_distinct() {
        assert_eq!(
            make_swift_method_name("URLSession", "data(from:)", false),
            "urlsession-data-from"
        );
        assert_eq!(
            make_swift_method_name("URLSession", "data(for:)", false),
            "urlsession-data-for"
        );
        // A bare wildcard label drops out; the base carries the name.
        assert_eq!(
            make_swift_method_name("IndexSet", "integerGreaterThan(_:)", false),
            "indexset-integer-greater-than"
        );
        assert_eq!(
            make_swift_method_name("IndexSet", "makeIterator", false),
            "indexset-make-iterator"
        );
        // Mutating value-receiver method takes the `!` marker (D3).
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
    fn swift_init_names_disambiguate_overloads() {
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
    fn msgsend_binding() {
        assert_eq!(
            make_msgsend_binding_name("NSString", "length"),
            "%msg-nsstring-length"
        );
    }
}
