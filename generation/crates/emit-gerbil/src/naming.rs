//! Gerbil-specific naming.
//!
//! Mirrors the chez/racket conventions (lowercase class prefix + kebab selector,
//! `make-…` for constructors, trailing `!` on mutating selectors): Gerbil
//! identifiers are Scheme symbols over the same alphabet, the on-disk shape and
//! call-site ergonomics are wanted cross-target, so the shared
//! `selector_to_kebab_name` does the heavy lifting and this module is thin.

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

/// Per-class module name: the `.ss` file stem and the trailing component of the
/// `:gerbil-bindings/<fw>/<cls>` import path. Lowercased class name, matching
/// chez's `<cls>.sls` convention.
pub fn class_module_stem(class_name: &str) -> String {
    class_name_to_lowercase(class_name)
}

/// Internal binding name for a method's `define-c-lambda` `objc_msgSend`
/// wrapper. The `%` prefix marks "private to this module" by convention —
/// Gerbil treats it as an ordinary identifier character. Per-selector here in
/// the foundation; leaf 020 keys the *emitted* binding on the shared ABI
/// signature (see [`crate::shared_signatures`]) so two selectors with the same
/// signature share one crossing.
pub fn make_msgsend_binding_name(class_name: &str, selector: &str) -> String {
    format!(
        "%msg-{}-{}",
        class_name_to_lowercase(class_name),
        selector_to_kebab_name(selector)
    )
}

/// Internal binding name for a method's cached `SEL` pointer (registered once
/// at module load via `sel_registerName`, then reused per call).
pub fn make_selector_binding_name(class_name: &str, selector: &str) -> String {
    format!(
        "%sel-{}-{}",
        class_name_to_lowercase(class_name),
        selector_to_kebab_name(selector)
    )
}

/// The Swift selector's argument labels (the `label:` parts inside the
/// parentheses), dropping `_` wildcards and empty segments. Used to build a
/// readable, overload-disambiguated binding name for a Swift-native method/init.
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

/// Gerbil binding name for a **Swift-native** instance method
/// (`objc_exposed == false`), e.g. `URLSession.data(from:)` →
/// `urlsession-data-from`, `IndexSet.update(with:)` (mutating) →
/// `indexset-update-with!`.
///
/// The ObjC-shaped [`make_method_name`] mangles a Swift selector (it leaves the
/// `(label:)` parentheses in, producing an unreadable `urlsession-data(from-)`).
/// A Swift-native method derives its name from the base + kebabed labels, with a
/// trailing `!` on a `mutating` value-receiver method. Mirrors chez's
/// `make_swift_method_name`.
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

/// Gerbil binding name for a **Swift-native** initializer producer (D2), e.g.
/// `IndexSet.init(integer:)` → `make-indexset-integer`, the bare `IndexSet.init`
/// → `make-indexset`. The argument labels disambiguate overloaded initializers.
/// Mirrors chez's `make_swift_init_name`.
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
    fn properties() {
        assert_eq!(
            make_property_getter_name("NSView", "wantsLayer"),
            "nsview-wants-layer"
        );
        assert_eq!(
            make_property_setter_name("NSView", "wantsLayer"),
            "nsview-set-wants-layer!"
        );
    }

    #[test]
    fn module_stem_and_bindings() {
        assert_eq!(class_module_stem("NSWindow"), "nswindow");
        assert_eq!(
            make_msgsend_binding_name("NSString", "length"),
            "%msg-nsstring-length"
        );
        assert_eq!(
            make_selector_binding_name("NSString", "length"),
            "%sel-nsstring-length"
        );
    }
}
