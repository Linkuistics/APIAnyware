//! Shared naming utilities for code generation.
//!
//! Provides CamelCase parsing and conversion functions used by all language emitters.

/// Split a CamelCase identifier into its component words.
///
/// Handles acronym runs (e.g., "UTF8String" → ["UTF8", "String"]),
/// digit boundaries (e.g., "int32" → ["int32"]), and standard
/// camelCase transitions (e.g., "makeKeyAndOrderFront" → ["make", "Key", "And", "Order", "Front"]).
pub fn split_camel_case(input: &str) -> Vec<String> {
    let bytes = input.as_bytes();
    let len = bytes.len();
    let mut words = Vec::new();
    let mut start = 0;

    let mut i = 0;
    while i < len {
        let c = bytes[i];

        if i == start {
            i += 1;
            continue;
        }

        if c.is_ascii_uppercase() {
            let prev = bytes[i - 1];
            if prev.is_ascii_lowercase() {
                // lowercase → Upper: word boundary
                words.push(input[start..i].to_string());
                start = i;
            } else if prev.is_ascii_uppercase() || prev.is_ascii_digit() {
                // Acronym/digit run: split only if next char is lowercase
                // (e.g., "UTF8String" → split before S, but "3D" stays together)
                if i + 1 < len && bytes[i + 1].is_ascii_lowercase() {
                    words.push(input[start..i].to_string());
                    start = i;
                }
            }
        }

        i += 1;
    }

    if start < len {
        words.push(input[start..].to_string());
    }

    words
}

/// Convert a CamelCase identifier to kebab-case (lowercase, hyphen-separated).
///
/// Examples:
/// - "makeKeyAndOrderFront" → "make-key-and-order-front"
/// - "UTF8String" → "utf8-string"
/// - "URLWithString" → "url-with-string"
/// - "backgroundColor" → "background-color"
pub fn camel_to_kebab(input: &str) -> String {
    let words = split_camel_case(input);
    words
        .iter()
        .map(|w| w.to_ascii_lowercase())
        .collect::<Vec<_>>()
        .join("-")
}

/// Convert an ObjC selector to a kebab-case function name component.
///
/// Multi-keyword selectors have their colons stripped and keywords joined with hyphens.
/// Each keyword is individually converted from CamelCase to kebab-case.
///
/// Examples:
/// - "makeKeyAndOrderFront:" → "make-key-and-order-front"
/// - "initWithContentRect:styleMask:backing:defer:" → "init-with-content-rect-style-mask-backing-defer"
/// - "length" → "length"
pub fn selector_to_kebab_name(selector: &str) -> String {
    if selector.contains(':') {
        let keywords: Vec<&str> = selector.split(':').filter(|s| !s.is_empty()).collect();
        keywords
            .iter()
            .map(|kw| camel_to_kebab(kw))
            .collect::<Vec<_>>()
            .join("-")
    } else {
        camel_to_kebab(selector)
    }
}

/// Convert an ObjC class name to lowercase (e.g., "NSWindow" → "nswindow").
pub fn class_name_to_lowercase(name: &str) -> String {
    name.to_ascii_lowercase()
}

/// Determine if a selector represents a mutating operation.
///
/// Uses the first keyword of the selector to check against known mutating prefixes.
pub fn is_mutating_selector(selector: &str) -> bool {
    let first_keyword = if selector.contains(':') {
        selector.split(':').next().unwrap_or("")
    } else {
        selector
    };

    const MUTATING_PREFIXES: &[&str] = &[
        "set", "add", "remove", "insert", "replace", "move", "close", "center", "order", "display",
        "perform", "begin", "end", "toggle", "reset",
    ];

    MUTATING_PREFIXES
        .iter()
        .any(|prefix| first_keyword.starts_with(prefix))
}

/// Convert a CamelCase identifier to snake_case (lowercase, underscore-separated).
///
/// Useful for languages like Haskell, OCaml, Zig that use snake_case conventions.
///
/// Examples:
/// - "makeKeyAndOrderFront" → "make_key_and_order_front"
/// - "UTF8String" → "utf8_string"
/// - "NSWindow" → "ns_window"
pub fn camel_to_snake(input: &str) -> String {
    let words = split_camel_case(input);
    words
        .iter()
        .map(|w| w.to_ascii_lowercase())
        .collect::<Vec<_>>()
        .join("_")
}

/// Convert an ObjC selector to a snake_case function name component.
///
/// Examples:
/// - "initWithContentRect:styleMask:" → "init_with_content_rect_style_mask"
/// - "length" → "length"
pub fn selector_to_snake_name(selector: &str) -> String {
    if selector.contains(':') {
        let keywords: Vec<&str> = selector.split(':').filter(|s| !s.is_empty()).collect();
        keywords
            .iter()
            .map(|kw| camel_to_snake(kw))
            .collect::<Vec<_>>()
            .join("_")
    } else {
        camel_to_snake(selector)
    }
}

/// Acronym-aware kebab-case for the CL-family contract's name mapper
/// (`docs/specs/2026-06-20-cl-family-interface-contract.md` §3.1). Unlike
/// [`camel_to_kebab`], this honours a curated table of multi-letter acronyms and
/// compound brand tokens so that
///
/// - adjacent acronyms in an all-caps pile-up are split:
///   `NSURLHandleClient` → `ns-url-handle-client` (NOT `nsurl-handle-client`),
///   `NSHTTPURLResponse` → `ns-http-url-response`;
/// - compound brand tokens stay whole: `NSOpenGLView` → `ns-opengl-view`
///   (NOT `ns-open-gl-view`);
/// - everything the plain splitter already gets right is unchanged:
///   `NSString` → `ns-string`, `CGRect` → `cg-rect`, `backgroundColor` →
///   `background-color`.
///
/// The naive "hyphen-before-each-capital" rule and the plain camelCase splitter
/// both mis-spell the pile-up / compound cases (research §5.2). This is **shared
/// analysis-level data** (contract §3.1): every CL-family member applies the
/// identical table, so it lives here rather than in any one emitter crate.
pub fn acronym_aware_kebab(input: &str) -> String {
    acronym_aware_words(input)
        .iter()
        .map(|w| w.to_ascii_lowercase())
        .collect::<Vec<_>>()
        .join("-")
}

/// Curated tokens for [`acronym_aware_kebab`]. Two roles:
///
/// - **Compound brand tokens** (`OpenGL`, …) — kept whole; they out-rank the
///   camelCase splitter, which would otherwise break them at the embedded
///   capital (`OpenGL` → `Open` + `GL`).
/// - **Pile-up acronyms** (`NS`, `URL`, `HTTP`, …) — broken out of all-caps runs
///   the splitter cannot separate (`NSURL` → `NS` + `URL`). A *lone* prefix
///   before a Capitalised word (`NSString`, `CGRect`, `WKWebView`) is already
///   split correctly by [`split_camel_case`], so framework prefixes that only
///   ever appear that way need no entry here.
///
/// Matched case-sensitively, only at a word start, only when the match ends at a
/// clean boundary (next char uppercase or end-of-string — never a lowercase or a
/// digit, which would mean the "acronym" is really the head of a longer word,
/// e.g. `UTF8`). Longest match wins. **Extend as sample apps surface gaps** — the
/// lazy/extensible posture; correctness of the *pattern* does not depend on the
/// table being exhaustive.
const KNOWN_TOKENS: &[&str] = &[
    // Compound brand tokens kept whole.
    "OpenGL",
    "OpenCL",
    "OpenAL",
    // Pile-up acronyms (longer variants first is not required — longest match is
    // computed — but grouped for readability).
    "HTTPS",
    "HTTP",
    "HTML",
    "JSON",
    "RGBA",
    "RGB",
    "CMYK",
    "ASCII",
    "UUID",
    "MIME",
    "JPEG",
    "TIFF",
    "MIDI",
    "NS",
    "URL",
    "URI",
    "XML",
    "PDF",
    "CSV",
    "API",
    "SQL",
    "PNG",
    "GIF",
    "DNS",
];

/// Split `input` into words, honouring [`KNOWN_TOKENS`] at word boundaries and
/// falling back to [`split_camel_case`] for the spans between matches. Because
/// the scan only consults the table at positions that are word boundaries (the
/// start, or just after a previous matched token), and only accepts a match that
/// ends at a clean boundary, an acronym embedded inside a longer word
/// (`Identifier`, `SRGB`, `UTF8`) is never spuriously split.
fn acronym_aware_words(input: &str) -> Vec<String> {
    let bytes = input.as_bytes();
    let n = bytes.len();
    let mut words: Vec<String> = Vec::new();
    let mut free_start = 0; // start of the run not yet handed to split_camel_case
    let mut i = 0;

    while i < n {
        if let Some(tok) = longest_token_at(bytes, i) {
            // Flush the camelCase span before this token.
            if free_start < i {
                words.extend(split_camel_case(&input[free_start..i]));
            }
            words.push(tok.to_string());
            i += tok.len();
            free_start = i;
        } else {
            i += 1;
        }
    }
    if free_start < n {
        words.extend(split_camel_case(&input[free_start..]));
    }
    words
}

/// The longest [`KNOWN_TOKENS`] entry that matches `bytes` starting at `i`, with
/// a clean trailing boundary (next byte is end-of-string or an uppercase ASCII
/// letter). Returns `None` if no entry qualifies. Case-sensitive.
fn longest_token_at(bytes: &[u8], i: usize) -> Option<&'static str> {
    let mut best: Option<&'static str> = None;
    for &tok in KNOWN_TOKENS {
        let tb = tok.as_bytes();
        let end = i + tb.len();
        if end <= bytes.len()
            && &bytes[i..end] == tb
            && (end == bytes.len() || bytes[end].is_ascii_uppercase())
            && best.is_none_or(|b| tb.len() > b.len())
        {
            best = Some(tok);
        }
    }
    best
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_acronym_aware_kebab_contract_examples() {
        // The two normative examples from contract §3.1.
        assert_eq!(acronym_aware_kebab("NSOpenGLView"), "ns-opengl-view");
        assert_eq!(
            acronym_aware_kebab("NSURLHandleClient"),
            "ns-url-handle-client"
        );
    }

    #[test]
    fn test_acronym_aware_kebab_pileups_split() {
        // All-caps acronym pile-ups the plain splitter merges wrongly.
        assert_eq!(acronym_aware_kebab("NSURL"), "ns-url");
        assert_eq!(acronym_aware_kebab("NSURLRequest"), "ns-url-request");
        assert_eq!(
            acronym_aware_kebab("NSHTTPURLResponse"),
            "ns-http-url-response"
        );
        assert_eq!(acronym_aware_kebab("NSXMLParser"), "ns-xml-parser");
        assert_eq!(
            acronym_aware_kebab("NSJSONSerialization"),
            "ns-json-serialization"
        );
    }

    #[test]
    fn test_acronym_aware_kebab_no_regression_on_simple_names() {
        // Names the plain splitter already handles must be unchanged.
        assert_eq!(acronym_aware_kebab("NSString"), "ns-string");
        assert_eq!(acronym_aware_kebab("NSView"), "ns-view");
        assert_eq!(acronym_aware_kebab("NSData"), "ns-data");
        assert_eq!(acronym_aware_kebab("CGRect"), "cg-rect");
        assert_eq!(acronym_aware_kebab("WKWebView"), "wk-web-view");
        assert_eq!(acronym_aware_kebab("backgroundColor"), "background-color");
    }

    #[test]
    fn test_acronym_aware_kebab_longest_match_wins() {
        // RGBA must beat RGB; HTTPS must beat HTTP.
        assert_eq!(acronym_aware_kebab("RGBAColor"), "rgba-color");
        assert_eq!(acronym_aware_kebab("RGBColor"), "rgb-color");
        assert_eq!(
            acronym_aware_kebab("HTTPSConnection"),
            "https-connection"
        );
    }

    #[test]
    fn test_acronym_aware_kebab_no_false_positives() {
        // A table acronym embedded inside a normal word (lowercase-adjacent or
        // mid-word) must NOT be split out — case-sensitive, boundary-clean.
        assert_eq!(acronym_aware_kebab("Identifier"), "identifier");
        assert_eq!(acronym_aware_kebab("Camera"), "camera");
        assert_eq!(acronym_aware_kebab("Apidoc"), "apidoc");
        // UTF8 stays one token (digit-adjacent — table never breaks it).
        assert_eq!(acronym_aware_kebab("UTF8String"), "utf8-string");
    }

    #[test]
    fn test_split_camel_case() {
        assert_eq!(
            split_camel_case("makeKeyAndOrderFront"),
            vec!["make", "Key", "And", "Order", "Front"]
        );
        assert_eq!(split_camel_case("UTF8String"), vec!["UTF8", "String"]);
        assert_eq!(
            split_camel_case("URLWithString"),
            vec!["URL", "With", "String"]
        );
        assert_eq!(
            split_camel_case("backgroundColor"),
            vec!["background", "Color"]
        );
        assert_eq!(split_camel_case("setTitle"), vec!["set", "Title"]);
        assert_eq!(split_camel_case("length"), vec!["length"]);
    }

    #[test]
    fn test_camel_to_kebab() {
        assert_eq!(
            camel_to_kebab("makeKeyAndOrderFront"),
            "make-key-and-order-front"
        );
        assert_eq!(camel_to_kebab("UTF8String"), "utf8-string");
        assert_eq!(camel_to_kebab("URLWithString"), "url-with-string");
        assert_eq!(camel_to_kebab("setTitle"), "set-title");
        assert_eq!(camel_to_kebab("backgroundColor"), "background-color");
        assert_eq!(camel_to_kebab("length"), "length");
        assert_eq!(camel_to_kebab("CATransform3DValue"), "ca-transform3d-value");
    }

    #[test]
    fn test_selector_to_kebab_name() {
        assert_eq!(
            selector_to_kebab_name("makeKeyAndOrderFront:"),
            "make-key-and-order-front"
        );
        assert_eq!(
            selector_to_kebab_name("initWithContentRect:styleMask:backing:defer:"),
            "init-with-content-rect-style-mask-backing-defer"
        );
        assert_eq!(selector_to_kebab_name("length"), "length");
    }

    #[test]
    fn test_class_name_to_lowercase() {
        assert_eq!(class_name_to_lowercase("NSWindow"), "nswindow");
        assert_eq!(class_name_to_lowercase("NSString"), "nsstring");
    }

    #[test]
    fn test_is_mutating_selector() {
        assert!(is_mutating_selector("setTitle:"));
        assert!(is_mutating_selector("addObject:"));
        assert!(is_mutating_selector("removeAllObjects"));
        assert!(is_mutating_selector("insertObject:atIndex:"));
        assert!(is_mutating_selector("replaceObjectAtIndex:withObject:"));
        assert!(is_mutating_selector("close"));
        assert!(is_mutating_selector("orderFront:"));
        assert!(is_mutating_selector("display"));
        assert!(is_mutating_selector("performSelector:"));
        assert!(!is_mutating_selector("init"));
        assert!(!is_mutating_selector("length"));
        assert!(!is_mutating_selector("description"));
        assert!(!is_mutating_selector("objectAtIndex:"));
    }

    #[test]
    fn test_camel_to_snake() {
        assert_eq!(
            camel_to_snake("makeKeyAndOrderFront"),
            "make_key_and_order_front"
        );
        assert_eq!(camel_to_snake("UTF8String"), "utf8_string");
        assert_eq!(camel_to_snake("NSWindow"), "ns_window");
        assert_eq!(camel_to_snake("backgroundColor"), "background_color");
    }

    #[test]
    fn test_selector_to_snake_name() {
        assert_eq!(
            selector_to_snake_name("initWithContentRect:styleMask:"),
            "init_with_content_rect_style_mask"
        );
        assert_eq!(selector_to_snake_name("length"), "length");
    }
}
