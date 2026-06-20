//! SBCL CLOS naming — the CL-family contract's name mapper (contract §3.1/§3.2).
//!
//! Unlike the scheme targets (which opaquely lowercase a class to `nsstring`),
//! SBCL presents fully acronym-aware kebab-cased names in the **`ns:` package**,
//! per CCL's documented conventions which the contract adopts wholesale:
//!
//! - **Classes** → `ns:`-qualified, acronym-aware kebab: `NSString` →
//!   `ns:ns-string`, `NSOpenGLView` → `ns:ns-opengl-view`, `NSURLHandleClient` →
//!   `ns:ns-url-handle-client` (the acronym handling is shared analysis-level
//!   data, [`apianyware_macos_emit::naming::acronym_aware_kebab`]).
//! - **Selectors** → a per-selector generic-function symbol (the colon-joined
//!   keyword components kebab-cased) and a keyword-symbol list, one per component
//!   (`nextEventMatchingMask:untilDate:inMode:dequeue:` → generic
//!   `ns:next-event-matching-mask-until-date-in-mode-dequeue`, keyword list
//!   `(:next-event-matching-mask :until-date :in-mode :dequeue)`).
//!
//! The acronym table lives in the shared `emit` crate (contract §3.1: shared,
//! applied identically by every CL member); this module is the SBCL-specific
//! composition over it (package, generic naming, keyword lists).

use apianyware_macos_emit::naming::acronym_aware_kebab;

/// The Common Lisp package every bound Cocoa name lives in (contract §3.1).
pub const PACKAGE: &str = "ns";

/// The symbol name of a bound ObjC class within the `ns:` package — acronym-aware
/// kebab-case, the `NS` prefix retained (`NSString` → `ns-string`). Unqualified;
/// use [`qualified_class_name`] for the `ns:`-prefixed form.
pub fn class_name(objc_class: &str) -> String {
    acronym_aware_kebab(objc_class)
}

/// The `ns:`-qualified class symbol (`NSString` → `ns:ns-string`). The form the
/// emitter writes into a `defclass` specializer / superclass reference.
pub fn qualified_class_name(objc_class: &str) -> String {
    format!("{PACKAGE}:{}", class_name(objc_class))
}

/// The per-selector generic-function symbol name (unqualified): the selector's
/// keyword components, each acronym-aware kebab-cased, joined with `-`. One
/// generic per selector (ADR-0034 §2). `length` → `length`, `objectAtIndex:` →
/// `object-at-index`, `initWithContentRect:styleMask:backing:defer:` →
/// `init-with-content-rect-style-mask-backing-defer`.
pub fn generic_name(selector: &str) -> String {
    selector_components(selector)
        .iter()
        .map(|c| acronym_aware_kebab(c))
        .collect::<Vec<_>>()
        .join("-")
}

/// The `ns:`-qualified generic-function symbol (`objectAtIndex:` →
/// `ns:object-at-index`) — the named contract surface (contract §3.2).
pub fn qualified_generic_name(selector: &str) -> String {
    format!("{PACKAGE}:{}", generic_name(selector))
}

/// The selector's keyword-symbol list (contract §3.2), one keyword per component:
/// `nextEventMatchingMask:untilDate:inMode:dequeue:` →
/// `[":next-event-matching-mask", ":until-date", ":in-mode", ":dequeue"]`. A
/// zero-colon selector (a unary message like `length`) has no keyword list and
/// returns an empty vector.
pub fn selector_keyword_symbols(selector: &str) -> Vec<String> {
    if !selector.contains(':') {
        return Vec::new();
    }
    selector_components(selector)
        .iter()
        .map(|c| format!(":{}", acronym_aware_kebab(c)))
        .collect()
}

/// The number of arguments a selector takes (its colon count) — the generic's
/// arity minus the receiver. `length` → 0, `objectAtIndex:` → 1,
/// `insertObject:atIndex:` → 2.
pub fn selector_arity(selector: &str) -> usize {
    selector.bytes().filter(|&b| b == b':').count()
}

/// The `ns:` symbol name for a **top-level C/Swift identifier** — a free function,
/// a global constant, or an enum value. The whole non-class, non-selector surface
/// (leaf 040) shares this mapping, so the SBCL binding is uniformly acronym-aware
/// kebab-case (the contract §3.1 idiom, applied past classes to every name).
///
/// Unlike [`class_name`] (a single camelCase token) this also treats **`_` as a
/// word separator**, because C functions/constants frequently use snake_case:
/// `dispatch_async` → `dispatch-async`, `objc_msgSend` → `objc-msg-send`,
/// `_dispatch_main_q` → `dispatch-main-q` (leading-underscore segment dropped).
/// PascalCase identifiers kebab acronym-aware as elsewhere: `CGRectMake` →
/// `cg-rect-make`, `NSFontAttributeName` → `ns-font-attribute-name`,
/// `NSUTF8StringEncoding` → `ns-utf8-string-encoding`.
///
/// The **raw** C symbol (`"dispatch_async"`, `"NSFontAttributeName"`) is what the
/// `sb-alien` crossing names for the actual link-time lookup; this is only the
/// Lisp-visible binding symbol.
pub fn top_level_name(raw: &str) -> String {
    raw.split('_')
        .filter(|s| !s.is_empty())
        .map(acronym_aware_kebab)
        .filter(|s| !s.is_empty())
        .collect::<Vec<_>>()
        .join("-")
}

/// The `ns:`-qualified form of [`top_level_name`] — the symbol an `emit_enums` /
/// `emit_constants` / `emit_functions` binding form defines.
pub fn qualified_top_level_name(raw: &str) -> String {
    format!("{PACKAGE}:{}", top_level_name(raw))
}

/// The keyword components of a selector — the text before each `:` (or the whole
/// selector for a unary message). `insertObject:atIndex:` →
/// `["insertObject", "atIndex"]`; `length` → `["length"]`.
fn selector_components(selector: &str) -> Vec<&str> {
    if selector.contains(':') {
        selector.split(':').filter(|s| !s.is_empty()).collect()
    } else {
        vec![selector]
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn class_names_are_acronym_aware_and_ns_qualified() {
        assert_eq!(class_name("NSString"), "ns-string");
        assert_eq!(class_name("NSOpenGLView"), "ns-opengl-view");
        assert_eq!(class_name("NSURLHandleClient"), "ns-url-handle-client");
        assert_eq!(qualified_class_name("NSString"), "ns:ns-string");
        assert_eq!(qualified_class_name("NSURL"), "ns:ns-url");
        // A non-NS framework class keeps its own prefix; the package is still ns:.
        assert_eq!(qualified_class_name("WKWebView"), "ns:wk-web-view");
    }

    #[test]
    fn unary_selector_maps_to_a_bare_generic() {
        assert_eq!(generic_name("length"), "length");
        assert_eq!(qualified_generic_name("length"), "ns:length");
        assert!(selector_keyword_symbols("length").is_empty());
        assert_eq!(selector_arity("length"), 0);
    }

    #[test]
    fn single_keyword_selector() {
        assert_eq!(generic_name("objectAtIndex:"), "object-at-index");
        assert_eq!(
            qualified_generic_name("objectAtIndex:"),
            "ns:object-at-index"
        );
        assert_eq!(
            selector_keyword_symbols("objectAtIndex:"),
            vec![":object-at-index"]
        );
        assert_eq!(selector_arity("objectAtIndex:"), 1);
    }

    #[test]
    fn multi_keyword_selector_matches_contract_example() {
        let sel = "nextEventMatchingMask:untilDate:inMode:dequeue:";
        assert_eq!(
            generic_name(sel),
            "next-event-matching-mask-until-date-in-mode-dequeue"
        );
        assert_eq!(
            selector_keyword_symbols(sel),
            vec![
                ":next-event-matching-mask",
                ":until-date",
                ":in-mode",
                ":dequeue",
            ]
        );
        assert_eq!(selector_arity(sel), 4);
    }

    #[test]
    fn selector_acronyms_are_preserved() {
        // URL stays whole inside a selector keyword (acronym-aware per component).
        assert_eq!(
            generic_name("dataWithContentsOfURL:"),
            "data-with-contents-of-url"
        );
    }

    #[test]
    fn top_level_names_kebab_pascal_case() {
        // PascalCase free functions / constants kebab acronym-aware, like classes.
        assert_eq!(top_level_name("CGRectMake"), "cg-rect-make");
        assert_eq!(top_level_name("NSStringFromClass"), "ns-string-from-class");
        assert_eq!(top_level_name("NSFontAttributeName"), "ns-font-attribute-name");
        assert_eq!(top_level_name("NSUTF8StringEncoding"), "ns-utf8-string-encoding");
        assert_eq!(
            qualified_top_level_name("NSFontAttributeName"),
            "ns:ns-font-attribute-name"
        );
    }

    #[test]
    fn top_level_names_split_snake_case() {
        // Underscores are word separators — the camel splitter alone would leave
        // them embedded in the symbol.
        assert_eq!(top_level_name("dispatch_async"), "dispatch-async");
        assert_eq!(top_level_name("objc_msgSend"), "objc-msg-send");
        assert_eq!(top_level_name("CFStringCreateWithCString"), "cf-string-create-with-c-string");
        // A leading-underscore "private" symbol drops the empty leading segment.
        assert_eq!(top_level_name("_dispatch_main_q"), "dispatch-main-q");
        assert_eq!(qualified_top_level_name("dispatch_async"), "ns:dispatch-async");
    }

    #[test]
    fn top_level_name_matches_class_name_when_no_underscores() {
        // A single camelCase token routes through the same acronym table as
        // class_name — the surface is uniform.
        assert_eq!(top_level_name("NSString"), class_name("NSString"));
        assert_eq!(top_level_name("WKWebView"), class_name("WKWebView"));
    }
}
