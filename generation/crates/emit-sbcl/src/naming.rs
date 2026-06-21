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
//! - **Selectors** → a per-selector generic-function symbol (**selector-structure
//!   preserving**, ADR-0039: each `:` → `_`, each camelCase hump → `-`) and a
//!   keyword-symbol list, one per component
//!   (`nextEventMatchingMask:untilDate:inMode:dequeue:` → generic
//!   `ns:next-event-matching-mask_until-date_in-mode_dequeue_`, keyword list
//!   `(:next-event-matching-mask :until-date :in-mode :dequeue)`). The injective
//!   `:`→`_` mapping keeps `foo`/`foo:` distinct (`ns:foo`/`ns:foo_`), so no two
//!   distinct selectors ever collide — the pre-ADR-0039 `-`-join did, breaking
//!   cross-framework load (B1).
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

/// The per-selector generic-function symbol name (unqualified) — **selector-structure
/// preserving** (ADR-0039, D1). Each selector COLON renders as `_`; each camelCase hump
/// renders as `-`. The two separator classes never merge, so the selector→symbol map is
/// **injective** over selector strings: distinct ObjC selectors get distinct generics, and
/// the same `SEL` across frameworks maps to the same generic at the same arity (so CLOS
/// dispatch unifies it). `length` → `length` (no colon), `objectAtIndex:` →
/// `object-at-index_`, `setObject:forKey:` → `set-object_for-key_`,
/// `initWithContentRect:styleMask:backing:defer:` →
/// `init-with-content-rect_style-mask_backing_defer_`. Critically `cancel` → `cancel` but
/// `cancel:` → `cancel_`, and `drawTitleWithFrame:inView:` → `draw-title-with-frame_in-view_`
/// vs `drawTitle:withFrame:inView:` → `draw-title_with-frame_in-view_` — the kebab no longer
/// erases the colon (the pre-ADR-0039 `-`-join collided these, breaking cross-framework load).
/// The `_` also preserves the argument-description nature of the ObjC selector.
pub fn generic_name(selector: &str) -> String {
    if selector.contains(':') {
        // Each component is followed by a colon → `_`; the trailing `_` distinguishes
        // `foo:` (foo_) from the unary `foo` (foo). Components kebab acronym-aware.
        let mut name = selector_components(selector)
            .iter()
            .map(|c| acronym_aware_kebab(c))
            .collect::<Vec<_>>()
            .join("_");
        name.push('_');
        name
    } else {
        acronym_aware_kebab(selector)
    }
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

/// The per-selector generic-function symbol name (unqualified) for a **Swift-native
/// residual method** — the *selector-analogous* mapping of a method that carries a
/// Swift base name + argument labels rather than an ObjC selector (contract §3.2).
/// The base plus each **non-wildcard** label, each acronym-aware kebab-cased and
/// joined with `-`: `update(with:)` (base `update`, labels `["with"]`) →
/// `update-with`; a zero-label method (`start()`) → `start`; a wildcard label
/// (`contains(_:)`) contributes nothing → `contains`.
///
/// Base-only (`update`) risks colliding with an unrelated ObjC `update`; this
/// selector-analogous form mirrors how [`generic_name`] joins ObjC selector
/// components, so a residual method shares a generic with an ObjC selector **only**
/// when both genuinely kebab the same name (then CLOS dispatch unifies them — one
/// generic, two receiver-specialized methods).
pub fn swift_method_generic_name(base: &str, labels: &[String]) -> String {
    let mut parts = vec![acronym_aware_kebab(base)];
    for l in labels {
        if l != "_" && !l.is_empty() {
            parts.push(acronym_aware_kebab(l));
        }
    }
    parts.join("-")
}

/// The `ns:`-qualified form of [`swift_method_generic_name`] — the generic a residual
/// method's `(defmethod …)` extends and `collect_generics` declares a `defgeneric`
/// for (the lockstep).
pub fn qualified_swift_method_generic_name(base: &str, labels: &[String]) -> String {
    format!("{PACKAGE}:{}", swift_method_generic_name(base, labels))
}

/// The `ns:` symbol name (unqualified) for a **Swift-native residual initializer**'s
/// constructor — `make-` + the owning type's acronym-aware kebab name + each
/// non-wildcard label: `IndexSet.init(integer:)` → `make-index-set-integer`, the bare
/// `IndexSet.init()` → `make-index-set`. A standalone constructor `defun` (not a
/// `make-instance` registration): a Swift-native init calls `Type(labels:)` through
/// the trampoline, **not** ObjC `alloc`/`init`, so it is not §3.3's make-instance
/// contract; the named constructor mirrors the gerbil peer's `make-<type>`.
pub fn swift_init_constructor_name(owner: &str, labels: &[String]) -> String {
    let mut name = format!("make-{}", class_name(owner));
    for l in labels {
        if l != "_" && !l.is_empty() {
            name.push('-');
            name.push_str(&acronym_aware_kebab(l));
        }
    }
    name
}

/// The `ns:`-qualified form of [`swift_init_constructor_name`].
pub fn qualified_swift_init_constructor_name(owner: &str, labels: &[String]) -> String {
    format!("{PACKAGE}:{}", swift_init_constructor_name(owner, labels))
}

/// True when a kebab'd **lambda-list formal** would collide with a Common Lisp
/// defined constant that cannot be used as a variable — `t` and `nil`. A
/// `(sb-alien:define-alien-routine … (t …))` formal, or a `defmethod` formal named
/// `t`, is a `SIMPLE-PROGRAM-ERROR` at load (`COMMON-LISP:T names a defined constant,
/// and cannot be used …`). The `CGAffineTransform*` family carries a C parameter
/// literally named `t`, so this bites any binding that loads `functions.lisp`. Such a
/// formal falls back to the positional `argN`, exactly like an empty/wildcard label.
/// Only **formals** are affected: a bound NAME (`ns:t`, a constant/function symbol)
/// lives in the `ns:` package, distinct from `cl:t`, so it needs no guard.
pub fn is_cl_reserved_formal(kebab: &str) -> bool {
    matches!(kebab, "t" | "nil")
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
        // ADR-0039: the trailing colon renders as `_` (preserves the arg-taking nature).
        assert_eq!(generic_name("objectAtIndex:"), "object-at-index_");
        assert_eq!(
            qualified_generic_name("objectAtIndex:"),
            "ns:object-at-index_"
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
        // ADR-0039: each colon → `_` (the boundary), each hump → `-` (within a component).
        assert_eq!(
            generic_name(sel),
            "next-event-matching-mask_until-date_in-mode_dequeue_"
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
        // URL stays whole inside a selector keyword (acronym-aware per component);
        // the trailing colon is the `_` (ADR-0039).
        assert_eq!(
            generic_name("dataWithContentsOfURL:"),
            "data-with-contents-of-url_"
        );
    }

    #[test]
    fn selector_structure_is_injective_no_arity_collision() {
        // The B1 collisions ADR-0039 resolves: `foo` vs `foo:` and the camelCase-vs-colon
        // case. `:`→`_`, hump→`-` never merge, so distinct selectors get distinct symbols.
        assert_eq!(generic_name("cancel"), "cancel");
        assert_eq!(generic_name("cancel:"), "cancel_");
        assert_ne!(generic_name("cancel"), generic_name("cancel:"));
        // drawTitleWithFrame:inView: (2 args) vs drawTitle:withFrame:inView: (3 args)
        assert_eq!(generic_name("drawTitleWithFrame:inView:"), "draw-title-with-frame_in-view_");
        assert_eq!(generic_name("drawTitle:withFrame:inView:"), "draw-title_with-frame_in-view_");
        assert_ne!(
            generic_name("drawTitleWithFrame:inView:"),
            generic_name("drawTitle:withFrame:inView:")
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
    fn swift_method_generics_are_selector_analogous() {
        // base + non-wildcard labels, acronym-aware, joined with `-`.
        assert_eq!(swift_method_generic_name("update", &["with".into()]), "update-with");
        assert_eq!(qualified_swift_method_generic_name("update", &["with".into()]), "ns:update-with");
        // Zero-label method → bare base.
        assert_eq!(swift_method_generic_name("start", &[]), "start");
        // A wildcard label contributes nothing (so two wildcard params don't double-`-`).
        assert_eq!(swift_method_generic_name("contains", &["_".into()]), "contains");
        // Multi-label, acronym preserved inside a label.
        assert_eq!(
            swift_method_generic_name("data", &["fromURL".into(), "delegate".into()]),
            "data-from-url-delegate"
        );
    }

    #[test]
    fn swift_init_constructors_are_make_prefixed() {
        // make- + owner kebab + non-wildcard labels.
        assert_eq!(swift_init_constructor_name("IndexSet", &["integer".into()]), "make-index-set-integer");
        assert_eq!(qualified_swift_init_constructor_name("IndexSet", &["integer".into()]), "ns:make-index-set-integer");
        // Bare init → make-<owner>.
        assert_eq!(swift_init_constructor_name("IndexSet", &[]), "make-index-set");
        // A class owner kebabs acronym-aware like everywhere else.
        assert_eq!(swift_init_constructor_name("ImageCreator", &[]), "make-image-creator");
    }

    #[test]
    fn cl_reserved_formals_are_only_t_and_nil() {
        // The exact CL defined constants that cannot be lambda-list variables. `t` is
        // the one the CGAffineTransform* C param hits; `nil` guarded for symmetry.
        assert!(is_cl_reserved_formal("t"));
        assert!(is_cl_reserved_formal("nil"));
        // Everything else (including collision-resolved `t-1`, ordinary labels) is fine.
        assert!(!is_cl_reserved_formal("t-1"));
        assert!(!is_cl_reserved_formal("transform"));
        assert!(!is_cl_reserved_formal("arg0"));
        assert!(!is_cl_reserved_formal(""));
    }

    #[test]
    fn top_level_name_matches_class_name_when_no_underscores() {
        // A single camelCase token routes through the same acronym table as
        // class_name — the surface is uniform.
        assert_eq!(top_level_name("NSString"), class_name("NSString"));
        assert_eq!(top_level_name("WKWebView"), class_name("WKWebView"));
    }
}
