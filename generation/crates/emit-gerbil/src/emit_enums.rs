//! Gerbil enum file emission.
//!
//! Each framework's `enums.ss` is one Gerbil module that defines every enum
//! value as `(define <name> <value>)`, grouped by a `;; <EnumType>` comment
//! header. The enum *types* don't survive into Scheme (they were just integers
//! in C); we mirror the racket/chez convention of one `define` per value. Pure
//! data — no `:std/foreign`, no `begin-ffi` (enum values are compile-time
//! integers, not symbols to resolve).
//!
//! Two cross-cutting hazards force shape decisions, the same two chez documents,
//! but their resolution differs because Gerbil's module/import semantics differ
//! from R6RS:
//!
//! 1. **Collision with prelude bindings.** chez had to import only `define` from
//!    `(rnrs base)` because R6RS *forbids* a library body from redefining an
//!    imported identifier (`reverse`, `and`, `or`, `error`, `force` come in with
//!    `(import (chezscheme))`). Gerbil is more permissive: a module-level
//!    definition **shadows** the prelude import of the same name (Gerbil guide,
//!    "definitions in the body can shadow local bindings"). So the Gerbil enums
//!    module needs *no* minimal-prelude trick — it carries no `(import …)` at all
//!    (the implicit `:gerbil/core` prelude supplies `define` and the integer
//!    literal reader) and emits IR-faithful bare names even for prelude
//!    collisions. If a future gsc compile (leaf 060) ever rejects a specific
//!    shadow, the documented fallback is a `prelude:`-minimal module or an
//!    `except-in` on the prelude — flagged, not pre-solved (grove incremental
//!    discovery).
//! 2. **Duplicate definitions within one module.** Two enums may share a case
//!    name (`WeatherCondition.rain`, `Precipitation.rain`). A duplicate
//!    top-level `define` is an error in *any* Scheme, so this hazard is real
//!    here too and resolved exactly as chez: collapse when the value is
//!    identical, prefix both with `<enum-type>-` when the values differ.

use std::collections::{HashMap, HashSet};

use apianyware_macos_emit::code_writer::CodeWriter;
use apianyware_macos_emit::write_line;
use apianyware_macos_types::ir::Enum;

/// Generate a Gerbil `enums.ss` module for one framework.
pub fn generate_enums_file(enums: &[Enum], framework: &str) -> String {
    let plan = build_plan(enums);
    let mut w = CodeWriter::new();

    write_line!(
        w,
        ";;; Generated enum definitions for {} — do not edit",
        framework
    );

    // No `(import …)`: the implicit `:gerbil/core` prelude supplies `define` and
    // the integer reader, and our top-level defines shadow any prelude binding of
    // the same name (hazard 1). An empty framework still emits a valid module.
    if plan.exports.is_empty() {
        w.line("(export)");
    } else {
        w.line("(export");
        for n in &plan.exports {
            write_line!(w, "  {}", n);
        }
        w.line("  )");
    }
    w.blank_line();

    for en in enums {
        write_line!(w, ";; {}", en.name);
        for v in &en.values {
            if let Some(emitted_name) = plan.emit_name(&en.name, &v.name) {
                write_line!(w, "(define {} {})", emitted_name, v.value);
            }
        }
        w.blank_line();
    }

    w.finish()
}

/// Names exported by `enums.ss` — used by the framework facade to re-export.
pub fn enum_value_names(enums: &[Enum]) -> Vec<String> {
    build_plan(enums).exports
}

/// Plan for one framework's `enums.ss`: tracks which value-names need
/// `<enum-type>-` prefixing because two enums declare the same name with
/// different integer values, and which (enum, value-name) pairs are duplicates
/// to skip. Mirrors the chez plan exactly — this is the Scheme-universal hazard.
struct EnumPlan {
    /// Final exported names in IR order, deduplicated.
    exports: Vec<String>,
    /// Per (enum-name, value-name): emit bare, emit prefixed, or skip.
    decisions: HashMap<(String, String), Decision>,
}

#[derive(Clone)]
enum Decision {
    /// Use the bare value name.
    Bare,
    /// Use `<enum-type>-<value-name>` to disambiguate from another enum.
    Prefixed,
    /// Same name and same value already emitted in this module; skip.
    Skip,
}

impl EnumPlan {
    fn emit_name(&self, enum_name: &str, value_name: &str) -> Option<String> {
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
    // First pass: for each value-name, collect every (enum-name, value) pair it
    // appears under. A value-name with two distinct integer values *must* be
    // prefix-disambiguated; with one distinct value all occurrences after the
    // first are skipped (a real duplicate).
    let mut by_value_name: HashMap<&str, Vec<(&str, i64)>> = HashMap::new();
    for en in enums {
        for v in &en.values {
            by_value_name
                .entry(v.name.as_str())
                .or_default()
                .push((en.name.as_str(), v.value));
        }
    }

    let needs_prefix: HashSet<&str> = by_value_name
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
    let mut decisions: HashMap<(String, String), Decision> = HashMap::new();
    let mut emitted: HashSet<String> = HashSet::new();
    let mut exports: Vec<String> = Vec::new();

    for en in enums {
        for v in &en.values {
            let key = (en.name.clone(), v.name.clone());
            if needs_prefix.contains(v.name.as_str()) {
                let prefixed = format!("{}-{}", en.name, v.name);
                decisions.insert(key, Decision::Prefixed);
                if emitted.insert(prefixed.clone()) {
                    exports.push(prefixed);
                }
            } else if emitted.contains(&v.name) {
                // Same name, same value (needs_prefix excludes the different-value
                // case): drop the duplicate.
                decisions.insert(key, Decision::Skip);
            } else {
                emitted.insert(v.name.clone());
                decisions.insert(key, Decision::Bare);
                exports.push(v.name.clone());
            }
        }
    }

    EnumPlan { exports, decisions }
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
    fn emits_module_header_and_defines() {
        let enums = vec![en(
            "NSComparisonResult",
            &[("NSOrderedAscending", -1), ("NSOrderedSame", 0)],
        )];
        let out = generate_enums_file(&enums, "Foundation");
        assert!(out.contains(";;; Generated enum definitions for Foundation"));
        // Pure data: no FFI / import machinery.
        assert!(!out.contains("(import"));
        assert!(!out.contains("begin-ffi"));
        assert!(out.contains(";; NSComparisonResult"));
        assert!(out.contains("(define NSOrderedAscending -1)"));
        assert!(out.contains("(define NSOrderedSame 0)"));
    }

    #[test]
    fn empty_enums_emits_empty_export_list() {
        let out = generate_enums_file(&[], "TestKit");
        assert!(out.contains("(export)"));
    }

    #[test]
    fn same_name_same_value_is_deduped() {
        let enums = vec![en("A", &[("zero", 0)]), en("B", &[("zero", 0)])];
        let out = generate_enums_file(&enums, "TestKit");
        assert_eq!(out.matches("(define zero 0)").count(), 1);
        assert_eq!(out.matches("  zero\n").count(), 1);
    }

    #[test]
    fn same_name_different_value_prefixes_with_enum_type() {
        let enums = vec![
            en("WeatherCondition", &[("rain", 22)]),
            en("Precipitation", &[("rain", 3)]),
        ];
        let out = generate_enums_file(&enums, "WeatherKit");
        assert!(out.contains("(define WeatherCondition-rain 22)"));
        assert!(out.contains("(define Precipitation-rain 3)"));
        // The bare `rain` is not a standalone define line — it would be ambiguous.
        let bare = out
            .lines()
            .filter(|l| l.trim() == "(define rain 22)" || l.trim() == "(define rain 3)")
            .count();
        assert_eq!(bare, 0);
        assert!(out.contains("  WeatherCondition-rain"));
        assert!(out.contains("  Precipitation-rain"));
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
    fn names_colliding_with_prelude_emit_bare_via_shadowing() {
        // `reverse`/`error`/`force` shadow the `:gerbil/core` prelude bindings —
        // Gerbil permits the redefinition (unlike R6RS), so we keep IR-faithful
        // names with no minimal-prelude import.
        let enums = vec![en("SortOrder", &[("forward", 0), ("reverse", 1)])];
        let out = generate_enums_file(&enums, "Foundation");
        assert!(out.contains("(define reverse 1)"));
        assert!(!out.contains("(import"));
    }
}
