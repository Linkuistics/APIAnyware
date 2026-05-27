//! Chez enum file emission.
//!
//! Each framework's `enums.sls` is one Chez library that defines every
//! enum value in the framework as `(define <name> <value>)`. The enum
//! types themselves don't survive into Scheme (they were just integers
//! in C); we mirror the Racket convention of one define per value,
//! grouped by comment header per enum.
//!
//! Two cross-cutting hazards force shape decisions:
//!
//! 1. **R6RS forbids redefining imports.** `(import (chezscheme))` brings
//!    `reverse`, `and`, `or`, `error`, `force` into scope — at-scale
//!    regeneration showed enum values with those exact names. We import
//!    only `define` from `(rnrs base)` so the body's identifiers are a
//!    fresh namespace.
//! 2. **R6RS forbids duplicate definitions.** Two Swift enums may share a
//!    case name (e.g. `WeatherCondition.rain` and `Precipitation.rain`).
//!    When the *value* is identical the duplicate is collapsed; when
//!    different we prefix both with `<enum-type>-` to disambiguate. The
//!    overwhelmingly common no-collision case still emits the bare name.

use std::collections::HashMap;

use apianyware_macos_emit::code_writer::CodeWriter;
use apianyware_macos_emit::write_line;
use apianyware_macos_types::ir::Enum;

/// Generate a Chez `enums.sls` library for one framework.
pub fn generate_enums_file(enums: &[Enum], framework: &str) -> String {
    let plan = build_plan(enums);
    let mut w = CodeWriter::new();
    let fw_low = framework.to_ascii_lowercase();

    write_line!(w, ";; Generated enum definitions for {} — do not edit", framework);
    write_line!(w, "(library (apianyware {} enums)", fw_low);

    if plan.exports.is_empty() {
        w.line("  (export)");
    } else {
        w.line("  (export");
        for n in &plan.exports {
            write_line!(w, "    {}", n);
        }
        w.line("    )");
    }

    // (rnrs base) ships `define`; that's the only identifier we need in
    // the body. Avoiding the chez/rnrs base re-export of `reverse`, `and`,
    // `or`, `error`, `force` lets us emit IR-faithful names for those.
    w.line("  (import (only (rnrs base) define))");
    w.blank_line();

    for en in enums {
        write_line!(w, "  ;; {}", en.name);
        for v in &en.values {
            if let Some(emitted_name) = plan.emit_name(&en.name, &v.name, v.value) {
                write_line!(w, "  (define {} {})", emitted_name, v.value);
            }
        }
        w.blank_line();
    }

    w.line(")");
    w.finish()
}

/// Names exported by `enums.sls` — used by `main.sls` to re-export.
pub fn enum_value_names(enums: &[Enum]) -> Vec<String> {
    build_plan(enums).exports
}

/// Plan for one framework's `enums.sls`: tracks which value-names need
/// `<enum-type>-` prefixing because two enums declare the same name with
/// different integer values, and which (enum, value-name) pairs are
/// duplicates to skip.
struct EnumPlan {
    /// Final exported names in IR order, deduplicated.
    exports: Vec<String>,
    /// Same as the input (enum-name, value-name) pairs, in IR order, with
    /// each entry annotated either "emit as bare" or "emit with prefix"
    /// or "skip (already seen)".
    decisions: HashMap<(String, String), Decision>,
}

#[derive(Clone)]
enum Decision {
    /// Use the bare value name.
    Bare,
    /// Use `<enum-type>-<value-name>` to disambiguate from another enum.
    Prefixed,
    /// Same name and same value already emitted in this file; skip.
    Skip,
}

impl EnumPlan {
    fn emit_name(&self, enum_name: &str, value_name: &str, _value: i64) -> Option<String> {
        match self
            .decisions
            .get(&(enum_name.to_string(), value_name.to_string()))?
        {
            Decision::Bare => Some(value_name.to_string()),
            Decision::Prefixed => Some(format!("{enum_name}-{value_name}")),
            Decision::Skip => None,
        }
    }
}

fn build_plan(enums: &[Enum]) -> EnumPlan {
    // First pass: for each value-name, collect every (enum-name, value)
    // pair it appears under. A value-name with two distinct integer values
    // *must* be prefix-disambiguated; with one distinct value all
    // occurrences after the first are skipped (real duplicate).
    let mut by_value_name: HashMap<&str, Vec<(&str, i64)>> = HashMap::new();
    for en in enums {
        for v in &en.values {
            by_value_name
                .entry(v.name.as_str())
                .or_default()
                .push((en.name.as_str(), v.value));
        }
    }

    let needs_prefix: std::collections::HashSet<&str> = by_value_name
        .iter()
        .filter_map(|(name, occs)| {
            let mut vals: Vec<i64> = occs.iter().map(|(_, v)| *v).collect();
            vals.sort();
            vals.dedup();
            if vals.len() > 1 {
                Some(*name)
            } else {
                None
            }
        })
        .collect();

    // Second pass: walk in IR order, assign a decision per (enum, value-name).
    // For same-name/same-value duplicates within a single enums.sls, only
    // the first occurrence emits.
    let mut decisions: HashMap<(String, String), Decision> = HashMap::new();
    let mut emitted_bare: std::collections::HashSet<String> = std::collections::HashSet::new();
    let mut exports: Vec<String> = Vec::new();

    for en in enums {
        for v in &en.values {
            let key = (en.name.clone(), v.name.clone());
            if needs_prefix.contains(v.name.as_str()) {
                let prefixed = format!("{}-{}", en.name, v.name);
                decisions.insert(key, Decision::Prefixed);
                if !emitted_bare.contains(&prefixed) {
                    emitted_bare.insert(prefixed.clone());
                    exports.push(prefixed);
                }
            } else if emitted_bare.contains(&v.name) {
                // Same name, same value (we've already checked that
                // needs_prefix excludes this case): drop it.
                decisions.insert(key, Decision::Skip);
            } else {
                emitted_bare.insert(v.name.clone());
                decisions.insert(key, Decision::Bare);
                exports.push(v.name.clone());
            }
        }
    }

    EnumPlan {
        exports,
        decisions,
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use apianyware_macos_types::ir::EnumValue;
    use apianyware_macos_types::type_ref::{TypeRef, TypeRefKind};

    fn en(name: &str, vs: &[(&str, i64)]) -> Enum {
        Enum {
            name: name.into(),
            enum_type: TypeRef {
                nullable: false,
                kind: TypeRefKind::Primitive {
                    name: "int64".into(),
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
        }
    }

    #[test]
    fn emits_library_header_and_defines() {
        let enums = vec![en(
            "NSComparisonResult",
            &[("NSOrderedAscending", -1), ("NSOrderedSame", 0)],
        )];
        let out = generate_enums_file(&enums, "Foundation");
        assert!(out.contains("(library (apianyware foundation enums)"));
        assert!(out.contains("(import (only (rnrs base) define))"));
        assert!(out.contains("(define NSOrderedAscending -1)"));
        assert!(out.contains("(define NSOrderedSame 0)"));
    }

    #[test]
    fn empty_enums_emits_empty_export_list() {
        let out = generate_enums_file(&[], "TestKit");
        assert!(out.contains("  (export)"));
    }

    #[test]
    fn same_name_same_value_is_deduped() {
        let enums = vec![
            en("A", &[("zero", 0)]),
            en("B", &[("zero", 0)]),
        ];
        let out = generate_enums_file(&enums, "TestKit");
        // Only one `(define zero 0)` survives — the second-enum's
        // duplicate is dropped.
        assert_eq!(out.matches("(define zero 0)").count(), 1);
        // Export list mentions `zero` exactly once.
        assert_eq!(out.matches("    zero\n").count(), 1);
    }

    #[test]
    fn same_name_different_value_prefixes_with_enum_type() {
        let enums = vec![
            en("WeatherCondition", &[("rain", 22)]),
            en("Precipitation", &[("rain", 3)]),
        ];
        let out = generate_enums_file(&enums, "WeatherKit");
        // Both flavours land in the file under their enum-prefixed name.
        assert!(out.contains("(define WeatherCondition-rain 22)"));
        assert!(out.contains("(define Precipitation-rain 3)"));
        // The bare `rain` is not exported — it would be ambiguous.
        let bare = out.lines().filter(|l| l.trim() == "rain").count();
        assert_eq!(bare, 0);
        assert!(out.contains("    WeatherCondition-rain"));
        assert!(out.contains("    Precipitation-rain"));
    }

    #[test]
    fn no_collision_keeps_bare_name() {
        let enums = vec![
            en("WeatherCondition", &[("rain", 22)]),
            en("OtherEnum", &[("snow", 1)]),
        ];
        let out = generate_enums_file(&enums, "WeatherKit");
        assert!(out.contains("(define rain 22)"));
        assert!(out.contains("(define snow 1)"));
        assert!(!out.contains("WeatherCondition-rain"));
    }

    #[test]
    fn names_colliding_with_chez_builtin_emit_fine() {
        // `reverse`, `and`, `or`, `error`, `force` would conflict with
        // (chezscheme) exports but are fine under (only (rnrs base) define).
        let enums = vec![en(
            "SortOrder",
            &[("forward", 0), ("reverse", 1)],
        )];
        let out = generate_enums_file(&enums, "Foundation");
        assert!(out.contains("(define reverse 1)"));
        assert!(out.contains("(only (rnrs base) define)"));
    }
}
