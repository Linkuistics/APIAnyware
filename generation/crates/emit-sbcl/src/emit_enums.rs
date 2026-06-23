//! SBCL enum emission — `(defconstant ns:<name> <value>)` per enum value.
//!
//! Enums are the one top-level construct whose **value is in the IR**
//! (`EnumValue.value`), so unlike constants/functions (runtime-read C globals,
//! [`crate::emit_constants`] / [`crate::emit_functions`]) an enum value is a true
//! compile-time integer literal: `defconstant`, not the runtime-resolved
//! `define-objc-constant` macro. They are also `objc_exposed`-irrelevant — a
//! preprocessor/enum value crosses no ABI, so there is no direct/trampoline split
//! here (ADR-0026 §3, the enum carve-out).
//!
//! Two decisions shape the output:
//!
//! 1. **Width/signedness reinterpretation (the enum-typedef fix).** `EnumValue.value`
//!    is an `i64`; an *unsigned* enum whose value has the high bit set is stored as a
//!    negative `i64` (e.g. a `uint64` `0xFFFF…FF` arrives as `-1`). SBCL `defconstant`s
//!    are passed straight into typed `(sb-alien:unsigned N)` slots, where a negative
//!    literal is a hard type error — so an unsigned enum's negative `i64` is
//!    reinterpreted as the unsigned value of the enum's `underlying_primitive` width.
//!    Signed enums emit the `i64` verbatim. (gerbil emits the raw `i64`; its `define`
//!    is untyped and the FFI coerces, so it can get away without this — SBCL cannot.)
//!
//! 2. **Same-name collision (Lisp-universal).** Two enums may carry the same value
//!    name (`WeatherCondition.rain`, `Precipitation.rain`), and both kebab to the
//!    same `ns:` symbol. A second `defconstant` of one symbol with a *different*
//!    value is an error in any Lisp, so — exactly as the scheme targets — identical
//!    values collapse to one binding and differing values are disambiguated by
//!    prefixing each with its `<enum-type>-`. The dedup keys on the **emitted kebab
//!    symbol** (so two raw names that kebab alike are caught too) and on the
//!    **formatted** value (so the reinterpretation above is reflected).
//!
//! There is no per-file `(export …)` (CL packages, not Scheme libraries, own the
//! export surface); the orchestration leaf (060) reads [`defined_enum_symbols`] to
//! build the `ns:` package's export list.

use std::collections::{HashMap, HashSet};

use apianyware_macos_emit::code_writer::CodeWriter;
use apianyware_macos_emit::write_line;
use apianyware_macos_types::ir::Enum;
use apianyware_macos_types::type_ref::{TypeRef, TypeRefKind};

use crate::naming::{qualified_top_level_name, top_level_name};

/// Generate one framework's enum forms — a `;; <EnumType>` comment header followed
/// by one `(defconstant ns:<value> <int>)` per value.
pub fn generate_enums_file(enums: &[Enum], framework: &str) -> String {
    let plan = build_plan(enums);
    let mut w = CodeWriter::new();

    write_line!(
        w,
        ";;; Generated enum definitions for {} — do not edit",
        framework
    );
    w.blank_line();

    for en in enums {
        // Skip an enum that contributes no surviving value (all duplicates).
        if en
            .values
            .iter()
            .all(|v| plan.emit(&en.name, &v.name).is_none())
        {
            continue;
        }
        write_line!(w, ";; {}", en.name);
        for v in &en.values {
            if let Some(sym) = plan.emit(&en.name, &v.name) {
                write_line!(
                    w,
                    "(defconstant {} {})",
                    sym,
                    format_enum_value(v.value, &en.enum_type)
                );
            }
        }
        w.blank_line();
    }

    w.finish()
}

/// The unqualified `ns:`-package symbols this framework's enums define, in IR order,
/// deduplicated — what the orchestration leaf (060) exports from the package.
pub fn defined_enum_symbols(enums: &[Enum]) -> Vec<String> {
    build_plan(enums).exports
}

// --- value formatting (width/signedness) ----------------------------------

/// Format an enum value for emission, reinterpreting an unsigned enum's negative
/// `i64` as the unsigned value of its `underlying_primitive` width (see the
/// module note). Signed enums pass the `i64` through verbatim.
fn format_enum_value(value: i64, enum_type: &TypeRef) -> String {
    if value < 0 && enum_is_unsigned(enum_type) {
        let mask = width_mask(enum_bits(enum_type));
        ((value as u64) & mask).to_string()
    } else {
        value.to_string()
    }
}

/// The lowercased primitive name backing an enum type — direct for a `Primitive`
/// `enum_type`, via `underlying_primitive` for an `Alias`.
fn enum_underlying(enum_type: &TypeRef) -> Option<String> {
    match &enum_type.kind {
        TypeRefKind::Primitive { name } => Some(name.to_ascii_lowercase()),
        TypeRefKind::Alias {
            underlying_primitive,
            ..
        } => underlying_primitive
            .as_ref()
            .map(|s| s.to_ascii_lowercase()),
        _ => None,
    }
}

fn enum_is_unsigned(enum_type: &TypeRef) -> bool {
    matches!(
        enum_underlying(enum_type).as_deref(),
        Some("uint8" | "uint16" | "uint32" | "uint64" | "nsuinteger")
    )
}

/// The enum's bit width; defaults to 64 (`nsuinteger`/`uint64`/unknown).
fn enum_bits(enum_type: &TypeRef) -> u32 {
    match enum_underlying(enum_type).as_deref() {
        Some("uint8" | "int8") => 8,
        Some("uint16" | "int16") => 16,
        Some("uint32" | "int32") => 32,
        _ => 64,
    }
}

fn width_mask(bits: u32) -> u64 {
    if bits >= 64 {
        u64::MAX
    } else {
        (1u64 << bits) - 1
    }
}

// --- the dedup / disambiguation plan --------------------------------------

/// Per-framework decision: which (enum, value) pairs emit bare, prefixed, or are
/// skipped as exact duplicates. Mirrors the scheme targets' enum plan, keyed on the
/// emitted kebab symbol and the formatted value.
struct EnumPlan {
    /// Final exported unqualified symbols in IR order, deduplicated.
    exports: Vec<String>,
    /// (enum-name, value-name) → decision.
    decisions: HashMap<(String, String), Decision>,
}

#[derive(Clone)]
enum Decision {
    /// Emit the bare `ns:<value-kebab>` symbol.
    Bare,
    /// Emit `ns:<enum-kebab>-<value-kebab>` to disambiguate a clashing value name.
    Prefixed,
    /// Same symbol + same value already emitted in this framework; skip.
    Skip,
}

impl EnumPlan {
    /// The qualified `ns:` symbol to emit for one (enum, value), or `None` to skip.
    fn emit(&self, enum_name: &str, value_name: &str) -> Option<String> {
        match self
            .decisions
            .get(&(enum_name.to_string(), value_name.to_string()))?
        {
            Decision::Bare => Some(qualified_top_level_name(value_name)),
            Decision::Prefixed => Some(format!(
                "ns:{}-{}",
                top_level_name(enum_name),
                top_level_name(value_name)
            )),
            Decision::Skip => None,
        }
    }
}

fn build_plan(enums: &[Enum]) -> EnumPlan {
    // Pass 1: group by the *emitted* kebab symbol, collecting the distinct formatted
    // values it appears with. A symbol with two distinct values must be prefix-
    // disambiguated; with one distinct value the later occurrences are exact dups.
    let mut by_symbol: HashMap<String, HashSet<String>> = HashMap::new();
    for en in enums {
        for v in &en.values {
            by_symbol
                .entry(top_level_name(&v.name))
                .or_default()
                .insert(format_enum_value(v.value, &en.enum_type));
        }
    }
    let needs_prefix: HashSet<&str> = by_symbol
        .iter()
        .filter(|(_, vals)| vals.len() > 1)
        .map(|(sym, _)| sym.as_str())
        .collect();

    // Pass 2: walk in IR order, assigning a decision per (enum, value).
    let mut decisions: HashMap<(String, String), Decision> = HashMap::new();
    let mut emitted: HashSet<String> = HashSet::new();
    let mut exports: Vec<String> = Vec::new();

    for en in enums {
        for v in &en.values {
            let key = (en.name.clone(), v.name.clone());
            let sym = top_level_name(&v.name);
            if needs_prefix.contains(sym.as_str()) {
                let prefixed = format!("{}-{}", top_level_name(&en.name), sym);
                decisions.insert(key, Decision::Prefixed);
                if emitted.insert(prefixed.clone()) {
                    exports.push(prefixed);
                }
            } else if emitted.contains(&sym) {
                // Same symbol, same value (the differing case went to needs_prefix).
                decisions.insert(key, Decision::Skip);
            } else {
                emitted.insert(sym.clone());
                decisions.insert(key, Decision::Bare);
                exports.push(sym);
            }
        }
    }

    EnumPlan { exports, decisions }
}

#[cfg(test)]
mod tests {
    use super::*;
    use apianyware_macos_types::ir::EnumValue;

    fn en(name: &str, underlying: &str, vs: &[(&str, i64)]) -> Enum {
        Enum {
            name: name.into(),
            enum_type: TypeRef {
                nullable: false,
                kind: TypeRefKind::Primitive {
                    name: underlying.into(),
                },
            },
            values: vs
                .iter()
                .map(|(n, v)| EnumValue {
                    name: (*n).into(),
                    value: *v,
                })
                .collect(),
            source: None,
            provenance: None,
            doc_refs: None,
            objc_exposed: true,
        }
    }

    #[test]
    fn emits_header_and_acronym_aware_defconstants() {
        let enums = vec![en(
            "NSComparisonResult",
            "int64",
            &[("NSOrderedAscending", -1), ("NSOrderedSame", 0)],
        )];
        let out = generate_enums_file(&enums, "Foundation");
        assert!(out.contains(";;; Generated enum definitions for Foundation"));
        assert!(out.contains(";; NSComparisonResult"));
        // ns:-qualified, acronym-aware kebab; signed value verbatim.
        assert!(out.contains("(defconstant ns:ns-ordered-ascending -1)"));
        assert!(out.contains("(defconstant ns:ns-ordered-same 0)"));
        // Pure data: no FFI / import machinery (enums cross no ABI).
        assert!(!out.contains("sb-alien"));
        assert!(!out.contains("define-objc-constant"));
    }

    #[test]
    fn empty_enums_emit_only_a_header() {
        let out = generate_enums_file(&[], "TestKit");
        assert!(out.contains(";;; Generated enum definitions for TestKit"));
        assert!(!out.contains("defconstant"));
        assert!(defined_enum_symbols(&[]).is_empty());
    }

    #[test]
    fn unsigned_enum_reinterprets_high_bit_value() {
        // A uint64 enum value 0xFFFFFFFFFFFFFFFF arrives as i64 -1; emitting it raw
        // would be a negative literal in an (unsigned 64) slot.
        let enums = vec![en("NSUIntFlags", "uint64", &[("NSAll", -1), ("NSNone", 0)])];
        let out = generate_enums_file(&enums, "Foundation");
        assert!(out.contains("(defconstant ns:ns-all 18446744073709551615)"));
        assert!(out.contains("(defconstant ns:ns-none 0)"));
        assert!(!out.contains("ns:ns-all -1"));
    }

    #[test]
    fn unsigned_narrow_enum_masks_to_width() {
        // A uint32 -1 reinterprets to the 32-bit unsigned max, not the 64-bit one.
        let enums = vec![en("NSU32", "uint32", &[("NSMax32", -1)])];
        let out = generate_enums_file(&enums, "Foundation");
        assert!(out.contains("(defconstant ns:ns-max32 4294967295)"));
    }

    #[test]
    fn signed_enum_keeps_negative_value() {
        let enums = vec![en("NSSigned", "int32", &[("NSNeg", -5)])];
        let out = generate_enums_file(&enums, "Foundation");
        assert!(out.contains("(defconstant ns:ns-neg -5)"));
    }

    #[test]
    fn alias_underlying_drives_signedness() {
        // An enum typed as an Alias carrying an unsigned underlying primitive.
        let enums = vec![Enum {
            name: "AXValueType".into(),
            enum_type: TypeRef {
                nullable: false,
                kind: TypeRefKind::Alias {
                    name: "AXValueType".into(),
                    framework: None,
                    underlying_primitive: Some("uint32".into()),
                },
            },
            values: vec![EnumValue {
                name: "kAXAll".into(),
                value: -1,
            }],
            source: None,
            provenance: None,
            doc_refs: None,
            objc_exposed: true,
        }];
        let out = generate_enums_file(&enums, "ApplicationServices");
        assert!(out.contains("(defconstant ns:k-ax-all 4294967295)"));
    }

    #[test]
    fn same_name_same_value_is_deduped() {
        let enums = vec![
            en("A", "int64", &[("zero", 0)]),
            en("B", "int64", &[("zero", 0)]),
        ];
        let out = generate_enums_file(&enums, "TestKit");
        assert_eq!(out.matches("(defconstant ns:zero 0)").count(), 1);
        assert_eq!(defined_enum_symbols(&enums), vec!["zero".to_string()]);
    }

    #[test]
    fn same_name_different_value_prefixes_with_enum_type() {
        let enums = vec![
            en("WeatherCondition", "int64", &[("rain", 22)]),
            en("Precipitation", "int64", &[("rain", 3)]),
        ];
        let out = generate_enums_file(&enums, "WeatherKit");
        assert!(out.contains("(defconstant ns:weather-condition-rain 22)"));
        assert!(out.contains("(defconstant ns:precipitation-rain 3)"));
        // The ambiguous bare symbol is never emitted.
        assert!(!out.contains("(defconstant ns:rain "));
        assert_eq!(
            defined_enum_symbols(&enums),
            vec![
                "weather-condition-rain".to_string(),
                "precipitation-rain".to_string()
            ]
        );
    }

    #[test]
    fn no_collision_keeps_bare_names() {
        let enums = vec![
            en("WeatherCondition", "int64", &[("rain", 22)]),
            en("OtherEnum", "int64", &[("snow", 1)]),
        ];
        let out = generate_enums_file(&enums, "WeatherKit");
        assert!(out.contains("(defconstant ns:rain 22)"));
        assert!(out.contains("(defconstant ns:snow 1)"));
        assert!(!out.contains("weather-condition-rain"));
    }

    #[test]
    fn distinct_raw_names_kebabbing_alike_are_disambiguated() {
        // `Foo_Bar` and `FooBar` both kebab to `foo-bar`; differing values force the
        // prefix path even though the raw names differ.
        let enums = vec![
            en("E1", "int64", &[("Foo_Bar", 1)]),
            en("E2", "int64", &[("FooBar", 2)]),
        ];
        let out = generate_enums_file(&enums, "TestKit");
        assert!(out.contains("(defconstant ns:e1-foo-bar 1)"));
        assert!(out.contains("(defconstant ns:e2-foo-bar 2)"));
    }
}
