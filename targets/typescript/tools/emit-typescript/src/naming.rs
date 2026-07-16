//! TypeScript naming — ObjC selectors and class/framework names → TS identifiers.
//!
//! The `typescript` target mirrors the ObjC graph as **real ES6 classes** (ADR-0055
//! §1), so a bound class keeps its ObjC PascalCase name verbatim (`NSString`,
//! `WKWebView`) — a macOS/TS developer expects exactly that spelling. The one
//! non-trivial mapping is **selector → method name**, which follows the
//! structure-preserving **injective** rule (ADR-0039 / ADR-0055 §3):
//!
//! - each selector `:` → `_`; **camelCase humps are kept as-is** (camelCase is
//!   TS-native — unlike the sbcl realization, which also lowers humps to `-`).
//!
//! So `setObject:forKey:` → `setObject_forKey_`, `initWithFrame:` → `initWithFrame_`,
//! `length` → `length`. The trailing `:`→`_` keeps a unary `foo` distinct from the
//! one-arg `foo:` (`foo` vs `foo_`), so the map is **injective over selector
//! strings** — no rename table, no collision detector, ever ([`method_name`] doc).
//! Because a colon is the only character in an ObjC selector that is not already a
//! valid JS identifier character, the replacement always yields a valid TS **member
//! name** (member positions accept reserved words like `delete`/`new`, so no keyword
//! guard is needed). The `NSError**` error selector keeps its injective form
//! (`writeToFile:error:` → `writeToFile_error_`, retaining `_error_`; ADR-0058).
//!
//! The one place a **collision detector really is needed** is the on-disk **file stem**
//! ([`ClassFileStems`]) — not because two selectors can collide, but because lowercasing a
//! class name to name its file is a lossy map, and a case-insensitive filesystem cannot
//! keep the two apart.

use std::collections::{BTreeMap, BTreeSet};

/// The TS **method name** for an ObjC selector — the structure-preserving
/// **injective** rule (ADR-0039 / ADR-0055 §3): each `:` → `_`, camelCase humps
/// kept. `length` → `length`, `objectAtIndex:` → `objectAtIndex_`,
/// `setObject:forKey:` → `setObject_forKey_`. Injective because the trailing colon
/// renders as a trailing `_`, so `cancel` → `cancel` stays distinct from
/// `cancel:` → `cancel_` — distinct selectors never collide, and the same `SEL`
/// across frameworks maps to the same method name at the same arity.
pub fn method_name(selector: &str) -> String {
    selector.replace(':', "_")
}

/// The number of arguments a selector takes — its colon count. `length` → 0,
/// `objectAtIndex:` → 1, `insertObject:atIndex:` → 2. (The generated method's
/// declared parameter count; the receiver is implicit.)
pub fn selector_arity(selector: &str) -> usize {
    selector.bytes().filter(|&b| b == b':').count()
}

/// A conservative ASCII TS/JS identifier check — a leading letter/`_`/`$`, then
/// letters/digits/`_`/`$`. ObjC class/enum/protocol tag names are ASCII identifiers;
/// the exceptions this rejects are libclang's synthetic names (an anonymous enum's
/// `enum (unnamed at …)`, spaces/parens/colons), which would otherwise emit as
/// uncompilable TS. Shared by [`crate::emit_enums`] and [`crate::emit_protocol`] so
/// the "skip non-identifier construct names" rule reads the same for both.
pub fn is_valid_ts_identifier(name: &str) -> bool {
    let mut chars = name.chars();
    match chars.next() {
        Some(c) if c.is_ascii_alphabetic() || c == '_' || c == '$' => {}
        _ => return false,
    }
    chars.all(|c| c.is_ascii_alphanumeric() || c == '_' || c == '$')
}

/// ECMAScript reserved words — the `Keyword` / `FutureReservedWord` grammar (every
/// emitted module is strict-mode, so the strict-only future words are included
/// unconditionally) — plus `arguments`/`eval`, which are not keywords but are a
/// SyntaxError as a strict-mode **binding** identifier. A **member** position (a
/// method or property name) tolerates every one of these (`obj.class`, `iface.new`
/// parse fine — [`method_name`]'s doc comment); only a **parameter binding** cannot,
/// which is why this list is consulted by [`param_identifier`] alone.
const RESERVED_WORDS: &[&str] = &[
    "arguments",
    "await",
    "break",
    "case",
    "catch",
    "class",
    "const",
    "continue",
    "debugger",
    "default",
    "delete",
    "do",
    "else",
    "enum",
    "eval",
    "export",
    "extends",
    "false",
    "finally",
    "for",
    "function",
    "if",
    "implements",
    "import",
    "in",
    "instanceof",
    "interface",
    "let",
    "new",
    "null",
    "package",
    "private",
    "protected",
    "public",
    "return",
    "static",
    "super",
    "switch",
    "this",
    "throw",
    "true",
    "try",
    "typeof",
    "var",
    "void",
    "while",
    "with",
    "yield",
];

/// The TS **parameter identifier** for an ObjC parameter name — a **total** map
/// (unlike [`is_valid_ts_identifier`], which only rejects malformed syntax and is
/// never applied to parameters): an ObjC parameter name is always syntactically a
/// valid identifier, but a reserved one (`arguments`, `function`, `interface`, …) is
/// a hard parse error in a binding position, and every emitted module is strict
/// mode. The one place param names are rendered as JS identifiers — the declared
/// signature ([`crate::class_surface::render_params`]) and every body expression
/// that reads the same parameter — must call this, never `Param::name` directly, so
/// the two can never drift apart (the k57 "one decision, N readers" discipline).
///
/// A colliding name takes a trailing `_`: name-local (no neighbouring param can
/// perturb it) and always distinct from the bare word, since no ECMAScript reserved
/// word itself ends in `_`.
pub fn param_identifier(name: &str) -> String {
    if RESERVED_WORDS.contains(&name) {
        format!("{name}_")
    } else {
        name.to_string()
    }
}

/// The TS **class / type identifier** for a bound ObjC class — the ObjC runtime
/// name verbatim (`NSString` → `NSString`), the "mirror the graph" idiom
/// (ADR-0055 §1). Kept as a named seam so later leaves can layer swift-overlay
/// renames (the IR's `Class::swift_name`, e.g. `NSScanner` → `Scanner`) here
/// rather than at every call site — deferred to `emit-class`.
pub fn class_type_name(objc_class: &str) -> String {
    objc_class.to_string()
}

/// The on-disk **framework directory name** under the generated-bindings root —
/// lowercased (`Foundation` → `foundation`), matching
/// [`apianyware_emit::code_writer::FileEmitter`]'s `base_dir` convention so the
/// two never diverge.
pub fn framework_dir_name(framework: &str) -> String {
    framework.to_ascii_lowercase()
}

/// The stems a framework directory reserves for its **non-class** modules — the barrel
/// and the five per-framework aggregate modules ([`crate::emit_framework`]'s layout). A
/// class whose lowercased name lands on one of these would have its file overwritten by
/// the module (or vice versa), so [`ClassFileStems`] treats them as occupied and tags any
/// class that collides with them. No macOS SDK class does today; the reservation is what
/// keeps that a fact rather than a hope — and it is why adding `delegates`
/// (`emitted-delegate-spec-k84`) cannot silently clobber a class file: a new module stem is
/// a new reservation, and the write-once orchestrator would fail loudly if it were not.
pub const RESERVED_MODULE_STEMS: [&str; 6] = [
    "constants",
    "delegates",
    "enums",
    "functions",
    "index",
    "protocols",
];

/// The on-disk **file stems** for one framework directory's classes — the single,
/// **injective** class→stem decision that the file writer and the barrel both read (the
/// k57 "one decision, N readers" discipline: a stem re-derived at a second site is a stem
/// that drifts).
///
/// ## Why this is not just `to_ascii_lowercase`
///
/// The base stem is the lowercased ObjC name (`NSString` → `nsstring`), the per-class-file
/// convention shared with the CL targets. Lowercasing is **not injective**: Matter declares
/// 17 ALL-CAPS acronym classes alongside their Swift-friendly aliases
/// (`MTRBaseClusterWakeOnLAN` / `MTRBaseClusterWakeOnLan`,
/// `MTRClusterOTASoftwareUpdateProvider` / `MTRClusterOtaSoftwareUpdateProvider`, …), each
/// pair lowering to one stem — so the emitter wrote one file and the second class silently
/// clobbered the first, while 34 sibling modules went on importing the vanished name.
///
/// Spelling the ObjC name verbatim is **no fix**: macOS (APFS) and Windows filesystems are
/// case-**insensitive**, so `MTRBaseClusterWakeOnLAN.ts` and `MTRBaseClusterWakeOnLan.ts`
/// still name one file on the developer's own disk. A disambiguator must differ in **more
/// than case**.
///
/// ## The rule
///
/// A class whose lowercased stem is shared — with another class, or with a
/// [`RESERVED_MODULE_STEMS`] module — takes a **case tag** suffix, `<lower>-<tag>`, where
/// the tag is [`case_tag`]: the hex of the name's ASCII-uppercase bitmap. The tag is
/// precisely the information the lowercasing threw away, so within a collision group (whose
/// members share a lowercase form *by definition*) it determines the name exactly. The map
/// is therefore injective **by construction** — not by digest luck — and a tagged stem can
/// never meet an untagged one, because an ObjC class name contains no `-`.
///
/// Every member of a colliding group is tagged, not just the later ones: which class is
/// "first" would otherwise depend on IR order, and the stem must not move when the IR is
/// reordered. The tag depends on the name alone, so adding an unrelated class churns no
/// existing stem.
pub struct ClassFileStems {
    by_class: BTreeMap<String, String>,
}

impl ClassFileStems {
    /// Build the stem table for every class a framework directory will hold — its collected
    /// classes **and** its synthesized bare nodes, which share the directory.
    pub fn new<'a>(class_names: impl IntoIterator<Item = &'a str>) -> Self {
        let names: BTreeSet<&str> = class_names.into_iter().collect();
        // The reserved module stems start occupied, so a class named `Enums` is tagged
        // rather than overwritten by (or overwriting) `enums.ts`.
        let mut occupancy: BTreeMap<String, usize> = RESERVED_MODULE_STEMS
            .iter()
            .map(|stem| ((*stem).to_string(), 1usize))
            .collect();
        for name in &names {
            *occupancy.entry(name.to_ascii_lowercase()).or_default() += 1;
        }
        let by_class = names
            .iter()
            .map(|name| {
                let lower = name.to_ascii_lowercase();
                let stem = if occupancy[&lower] > 1 {
                    format!("{lower}-{}", case_tag(name))
                } else {
                    lower
                };
                ((*name).to_string(), stem)
            })
            .collect();
        Self { by_class }
    }

    /// The stem for a class the table was built from — `<stem>.ts`, `<stem>.d.ts`, and the
    /// barrel's `export * from './<stem>'`. Panics on a name the table does not hold: the
    /// readers all walk the same set the table was built from, so an absent name is a broken
    /// invariant, not a runtime condition to paper over with a lowercase fallback (which is
    /// the very map that was not injective).
    pub fn stem(&self, class_name: &str) -> &str {
        self.by_class
            .get(class_name)
            .unwrap_or_else(|| {
                panic!("emit-typescript: no file stem for '{class_name}' — the stem table must be built from every class the framework directory holds")
            })
            .as_str()
    }
}

/// The **case tag** of an ObjC class name: the hex of its ASCII-uppercase bitmap, eight
/// characters per byte, LSB-first (`NSData` → bits 0,1,2 of the first byte → `07`). It is a
/// **lossless** encoding of what `to_ascii_lowercase` discards — every byte the lowercasing
/// left alone (digits, `_`) is recoverable from the lowercase stem, and every byte it
/// changed is recoverable from its bit — so two names with the same lowercase stem have the
/// same case tag only if they are the same name. That is what makes [`ClassFileStems`]
/// injective by construction rather than by a digest's collision odds.
pub fn case_tag(objc_class: &str) -> String {
    use std::fmt::Write;

    let bytes = objc_class.as_bytes();
    let mut tag = String::with_capacity(bytes.len().div_ceil(8) * 2);
    for chunk in bytes.chunks(8) {
        let mut bits = 0u8;
        for (i, b) in chunk.iter().enumerate() {
            if b.is_ascii_uppercase() {
                bits |= 1 << i;
            }
        }
        let _ = write!(tag, "{bits:02x}");
    }
    tag
}

/// The **module specifier** an app imports a framework's classes from —
/// `import { NSString } from '@apianyware/foundation'` (ADR-0055 §2, the
/// per-framework module boundary that bounds artifact size via lazy import /
/// tree-shaking). `Foundation` → `@apianyware/foundation`.
pub fn module_specifier(framework: &str) -> String {
    format!("@apianyware/{}", framework.to_ascii_lowercase())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn unary_selector_is_unchanged() {
        assert_eq!(method_name("length"), "length");
        assert_eq!(method_name("description"), "description");
        assert_eq!(selector_arity("length"), 0);
    }

    #[test]
    fn keyword_selectors_map_each_colon_to_underscore() {
        // The normative ADR-0055 §3 examples: `:`→`_`, camelCase humps kept as-is.
        assert_eq!(method_name("objectAtIndex:"), "objectAtIndex_");
        assert_eq!(method_name("setObject:forKey:"), "setObject_forKey_");
        assert_eq!(method_name("initWithFrame:"), "initWithFrame_");
        assert_eq!(
            method_name("initWithContentRect:styleMask:backing:defer:"),
            "initWithContentRect_styleMask_backing_defer_"
        );
        assert_eq!(selector_arity("setObject:forKey:"), 2);
        assert_eq!(selector_arity("objectAtIndex:"), 1);
    }

    #[test]
    fn rule_is_injective_no_arity_collision() {
        // The B1 collisions ADR-0039 exists to prevent: `foo` vs `foo:` must not
        // collapse to one name (camelCase colon-elision — the rejected §3 option —
        // would collide them). The trailing `_` keeps them apart.
        assert_eq!(method_name("cancel"), "cancel");
        assert_eq!(method_name("cancel:"), "cancel_");
        assert_ne!(method_name("cancel"), method_name("cancel:"));
        // Two selectors that differ only in colon placement stay distinct.
        assert_eq!(
            method_name("drawTitleWithFrame:inView:"),
            "drawTitleWithFrame_inView_"
        );
        assert_eq!(
            method_name("drawTitle:withFrame:inView:"),
            "drawTitle_withFrame_inView_"
        );
        assert_ne!(
            method_name("drawTitleWithFrame:inView:"),
            method_name("drawTitle:withFrame:inView:")
        );
    }

    #[test]
    fn error_selector_keeps_injective_error_underscore() {
        // ADR-0058: the `NSError**` selector keeps its structure-preserving form;
        // `_error_` falls out of the injective rule, no special-casing.
        assert_eq!(method_name("writeToFile:error:"), "writeToFile_error_");
        assert_eq!(
            method_name("writeToURL:options:error:"),
            "writeToURL_options_error_"
        );
    }

    #[test]
    fn class_names_are_verbatim_objc_names() {
        assert_eq!(class_type_name("NSString"), "NSString");
        assert_eq!(class_type_name("WKWebView"), "WKWebView");
        assert_eq!(class_type_name("NSURLSession"), "NSURLSession");
    }

    #[test]
    fn framework_names_lowercase_for_dir_and_module() {
        assert_eq!(framework_dir_name("Foundation"), "foundation");
        assert_eq!(framework_dir_name("AppKit"), "appkit");
        assert_eq!(module_specifier("Foundation"), "@apianyware/foundation");
        assert_eq!(module_specifier("AppKit"), "@apianyware/appkit");
    }

    #[test]
    fn uncontended_class_file_stem_is_the_lowercased_objc_name() {
        // The overwhelmingly common case: no other class lowers to the same stem, so the
        // stem stays the plain lowercased name — no tag, no churn.
        let stems = ClassFileStems::new(["NSString", "WKWebView", "NSURLSession"]);
        assert_eq!(stems.stem("NSString"), "nsstring");
        assert_eq!(stems.stem("WKWebView"), "wkwebview");
        assert_eq!(stems.stem("NSURLSession"), "nsurlsession");
    }

    #[test]
    fn case_only_collision_gets_two_stems_differing_in_more_than_case() {
        // The real Matter pair the emitter used to clobber: the ALL-CAPS acronym class and
        // its Swift-friendly alias lower to one stem. Both are tagged (not just the later
        // one — "later" is IR order, which must not move a stem), and the two stems differ
        // in **more than case**, so a case-insensitive filesystem keeps them apart too.
        let stems = ClassFileStems::new(["MTRBaseClusterWakeOnLAN", "MTRBaseClusterWakeOnLan"]);
        let all_caps = stems.stem("MTRBaseClusterWakeOnLAN");
        let alias = stems.stem("MTRBaseClusterWakeOnLan");
        assert_ne!(all_caps, alias);
        assert_ne!(
            all_caps.to_ascii_lowercase(),
            alias.to_ascii_lowercase(),
            "APFS is case-insensitive: stems must differ in more than case, got {all_caps} / {alias}"
        );
        assert!(
            all_caps.starts_with("mtrbaseclusterwakeonlan-"),
            "{all_caps}"
        );
        assert!(alias.starts_with("mtrbaseclusterwakeonlan-"), "{alias}");
    }

    #[test]
    fn a_stem_does_not_move_when_an_unrelated_class_is_added() {
        // Stability: the tag is a function of the name alone, so an unrelated class joining
        // the framework churns no existing stem (a moving stem is a whole-corpus diff).
        let before = ClassFileStems::new(["MTRBaseClusterWakeOnLAN", "MTRBaseClusterWakeOnLan"]);
        let after = ClassFileStems::new([
            "MTRBaseClusterWakeOnLAN",
            "MTRBaseClusterWakeOnLan",
            "MTRUnrelatedThing",
        ]);
        assert_eq!(
            before.stem("MTRBaseClusterWakeOnLAN"),
            after.stem("MTRBaseClusterWakeOnLAN")
        );
        assert_eq!(
            before.stem("MTRBaseClusterWakeOnLan"),
            after.stem("MTRBaseClusterWakeOnLan")
        );
        assert_eq!(after.stem("MTRUnrelatedThing"), "mtrunrelatedthing");
    }

    #[test]
    fn a_class_colliding_with_a_reserved_module_stem_is_tagged() {
        // A class named `Enums` would otherwise be overwritten by (or overwrite) the
        // framework's `enums.ts` aggregate module. No SDK class does this today; the
        // reservation is what keeps that a fact rather than a hope.
        let stems = ClassFileStems::new(["Enums", "NSString"]);
        assert_ne!(stems.stem("Enums"), "enums");
        assert!(
            stems.stem("Enums").starts_with("enums-"),
            "{}",
            stems.stem("Enums")
        );
        assert_eq!(stems.stem("NSString"), "nsstring");
    }

    #[test]
    fn case_tag_is_a_lossless_encoding_of_the_discarded_case() {
        // The tag is the ASCII-uppercase bitmap, LSB-first per byte: `NSData` is uppercase
        // at 0, 1 and 2 (N, S, D) → 0b0000_0111 → 0x07.
        assert_eq!(case_tag("NSData"), "07");
        // Two names with the same lowercase form share a tag only if they are the same name
        // — that is the injectivity argument, exercised on the whole Matter collision set.
        let matter_pairs = [
            ("MTRBaseClusterWakeOnLAN", "MTRBaseClusterWakeOnLan"),
            (
                "MTRClusterOTASoftwareUpdateProvider",
                "MTRClusterOtaSoftwareUpdateProvider",
            ),
            (
                "MTRTimeSynchronizationClusterSetUTCTimeParams",
                "MTRTimeSynchronizationClusterSetUtcTimeParams",
            ),
        ];
        for (all_caps, alias) in matter_pairs {
            assert_eq!(
                all_caps.to_ascii_lowercase(),
                alias.to_ascii_lowercase(),
                "the pair must actually collide under lowercasing"
            );
            assert_ne!(case_tag(all_caps), case_tag(alias), "{all_caps} / {alias}");
        }
    }

    #[test]
    fn param_identifier_escapes_reserved_words_only() {
        // The three names actually measured in the corpus (k91/k97).
        assert_eq!(param_identifier("arguments"), "arguments_");
        assert_eq!(param_identifier("function"), "function_");
        assert_eq!(param_identifier("interface"), "interface_");
        // A non-keyword name, including one that merely looks similar, passes through.
        assert_eq!(param_identifier("argument"), "argument");
        assert_eq!(param_identifier("s"), "s");
        assert_eq!(param_identifier("separator"), "separator");
    }

    #[test]
    fn param_identifier_escape_is_never_itself_reserved() {
        // The escape must not land back on a reserved word — trivially true since no
        // ECMAScript reserved word ends in `_`, but pin it so a future word added to
        // the list cannot silently break the invariant.
        for word in RESERVED_WORDS {
            let escaped = param_identifier(word);
            assert_ne!(escaped, *word);
            assert!(!RESERVED_WORDS.contains(&escaped.as_str()), "{escaped}");
        }
    }

    #[test]
    fn valid_ts_identifier_accepts_names_rejects_synthetic() {
        // Real ObjC tag names pass; libclang's synthetic anonymous names (the one case
        // the enum/protocol emitters must skip) fail.
        assert!(is_valid_ts_identifier("NSComparisonResult"));
        assert!(is_valid_ts_identifier("NSWindowDelegate"));
        assert!(is_valid_ts_identifier("_private"));
        assert!(is_valid_ts_identifier("$weird"));
        assert!(is_valid_ts_identifier("A1B2"));
        assert!(!is_valid_ts_identifier(""));
        assert!(!is_valid_ts_identifier("2LeadingDigit"));
        assert!(!is_valid_ts_identifier("has space"));
        assert!(!is_valid_ts_identifier("enum (unnamed at Foo.h:1:1)"));
    }
}
