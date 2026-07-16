//! One-shot measurement + prune tool for `llm-ownership-prune-k94`.
//!
//! For every framework whose `annotations.apiw` carries LLM `param-ownership`
//! facts, measures — per fact-slot, by literally re-running the real
//! `annotate_framework`/`audit_annotations` pipeline with that fact removed and
//! diffing the resolved value — whether the corpus's resolved ownership at that
//! slot depends on the LLM fact at all. A slot whose resolved value is
//! unchanged with the fact absent is **declaration/convention-covered**: safe to
//! prune (ADR-0050's charter — the overlay is for facts only Apple's prose
//! knows). A slot whose value changes (or vanishes) with the fact removed is
//! **prose-only**: the LLM contributed real information no other tier has, so
//! it must stay.
//!
//! This does not re-implement the precedence ladder — it drives the actual
//! `apianyware_annotate::annotate_framework` + `validate::audit_annotations`
//! code the real pipeline runs, so the safe/prose-only split is exactly what
//! resolve would (re)produce, not a reconstruction of its rules.
//!
//! Usage:
//!   cargo run -p apianyware-analyze --example prune_llm_ownership -- \
//!     [--api-root <dir>] [--only Fw1,Fw2] [--write]
//!
//! Default is a dry-run report; `--write` rewrites each framework's
//! `annotations.apiw` with the safe-to-prune facts removed, after verifying
//! in-memory that every OTHER resolved fact (ownership included) is unchanged.

use std::collections::BTreeMap;
use std::path::PathBuf;
use std::process::ExitCode;

use apianyware_annotate::annotate_framework;
use apianyware_datalog::loading::{discover_family_artifacts, load_framework_from_file};
use apianyware_spec_format::apiw::{parse_apiw, write_apiw};
use apianyware_types::annotation::{ClassAnnotations, FrameworkAnnotations, MethodAnnotation, OwnershipKind};
use apianyware_types::ir::Framework;

/// A resolved method key: `(receiver, selector, is_instance)` — `is_instance`
/// disambiguates a class method and an instance method that happen to share a
/// selector spelling.
type MethodKey = (String, String, bool);

fn method_map(class_annotations: &[ClassAnnotations]) -> BTreeMap<MethodKey, &MethodAnnotation> {
    let mut map = BTreeMap::new();
    for class in class_annotations {
        for method in &class.methods {
            map.insert(
                (class.class_name.clone(), method.selector.clone(), method.is_instance),
                method,
            );
        }
    }
    map
}

/// One LLM `param-ownership` fact as it stands in the committed overlay.
struct Fact {
    class_name: String,
    selector: String,
    is_instance: bool,
    param_index: usize,
    ownership: OwnershipKind,
}

fn collect_facts(overlay: &FrameworkAnnotations) -> Vec<Fact> {
    let mut facts = Vec::new();
    for class in &overlay.classes {
        for method in &class.methods {
            for po in &method.parameter_ownership {
                facts.push(Fact {
                    class_name: class.class_name.clone(),
                    selector: method.selector.clone(),
                    is_instance: method.is_instance,
                    param_index: po.param_index,
                    ownership: po.ownership,
                });
            }
        }
    }
    facts
}

/// The overlay with every method's `parameter_ownership` cleared — "what if no
/// LLM ownership fact existed at all in this framework."
fn overlay_without_ownership(overlay: &FrameworkAnnotations) -> FrameworkAnnotations {
    let mut cleared = overlay.clone();
    for class in &mut cleared.classes {
        for method in &mut class.methods {
            method.parameter_ownership.clear();
        }
    }
    cleared
}

fn resolved_ownership(
    map: &BTreeMap<MethodKey, &MethodAnnotation>,
    key: &MethodKey,
    param_index: usize,
) -> Option<OwnershipKind> {
    map.get(key)?
        .parameter_ownership
        .iter()
        .find(|p| p.param_index == param_index)
        .map(|p| p.ownership)
}

/// Remove exactly the given `(selector, is_instance, param_index)` slots from
/// `overlay`'s methods, dropping any method/class left with zero annotation
/// content (no empty shells — matches the subagent-prompt hard rule).
fn prune_overlay(
    overlay: &FrameworkAnnotations,
    to_remove: &[(String, bool, usize)],
) -> FrameworkAnnotations {
    let mut pruned = overlay.clone();
    for class in &mut pruned.classes {
        for method in &mut class.methods {
            method.parameter_ownership.retain(|po| {
                !to_remove.iter().any(|(sel, is_instance, idx)| {
                    sel == &method.selector && *is_instance == method.is_instance && *idx == po.param_index
                })
            });
        }
        class.methods.retain(|m| {
            !m.parameter_ownership.is_empty()
                || !m.block_parameters.is_empty()
                || m.threading.is_some()
                || m.error_pattern.is_some()
        });
    }
    pruned.classes.retain(|c| !c.methods.is_empty());
    pruned
}

struct FrameworkResult {
    name: String,
    safe_to_prune: Vec<(String, bool, usize)>,
    prose_only: Vec<String>,
}

fn analyze_one(api_root: &std::path::Path, resolved_path: &std::path::Path) -> anyhow::Result<Option<FrameworkResult>> {
    let base: Framework = load_framework_from_file(resolved_path)?;
    let overlay_path = api_root.join(&base.name).join("annotations.apiw");
    if !overlay_path.is_file() {
        return Ok(None);
    }
    let overlay_text = std::fs::read_to_string(&overlay_path)?;
    let overlay = parse_apiw(&overlay_path.display().to_string(), &overlay_text)
        .map_err(|e| anyhow::anyhow!("{e}"))?;

    let facts = collect_facts(&overlay);
    if facts.is_empty() {
        return Ok(None);
    }

    let annotated_full = annotate_framework(&base, Some(&overlay));
    let no_ownership_overlay = overlay_without_ownership(&overlay);
    let annotated_no_llm_ownership = annotate_framework(&base, Some(&no_ownership_overlay));

    let map_full = method_map(&annotated_full.class_annotations);
    let map_no_llm = method_map(&annotated_no_llm_ownership.class_annotations);

    let mut safe_to_prune = Vec::new();
    let mut prose_only = Vec::new();

    for fact in &facts {
        let key: MethodKey = (fact.class_name.clone(), fact.selector.clone(), fact.is_instance);
        // `with_llm` is today's real resolved value (the overlay's LLM fact may
        // still lose to a higher-precedence declared attribute — e.g. the known
        // NSComboBox.setDataSource: disagreement — so this need not equal the
        // raw overlay fact). What matters is whether removing the LLM fact
        // changes it.
        let with_llm = resolved_ownership(&map_full, &key, fact.param_index);
        let without_llm = resolved_ownership(&map_no_llm, &key, fact.param_index);

        if without_llm == with_llm {
            safe_to_prune.push((fact.selector.clone(), fact.is_instance, fact.param_index));
        } else {
            prose_only.push(format!(
                "{}.{} [{}] param {} ownership={:?} (without-LLM: {:?})",
                fact.class_name,
                fact.selector,
                if fact.is_instance { "-" } else { "+" },
                fact.param_index,
                fact.ownership,
                without_llm
            ));
        }
    }

    Ok(Some(FrameworkResult {
        name: base.name.clone(),
        safe_to_prune,
        prose_only,
    }))
}

/// After pruning, re-run the pipeline on the pruned overlay and assert every
/// resolved fact (all four facets, not just ownership) is byte-identical to the
/// pre-prune resolution — the "audit + goldens prove resolved values unchanged"
/// verification, done in-memory before a single byte is written to disk.
fn verify_unchanged(base: &Framework, before_overlay: &FrameworkAnnotations, pruned_overlay: &FrameworkAnnotations) {
    let before = annotate_framework(base, Some(before_overlay));
    let after = annotate_framework(base, Some(pruned_overlay));

    let map_before = method_map(&before.class_annotations);
    let map_after = method_map(&after.class_annotations);

    assert_eq!(
        map_before.len(),
        map_after.len(),
        "{}: pruning changed the set of annotated methods",
        base.name
    );
    for (key, m_before) in &map_before {
        let m_after = map_after
            .get(key)
            .unwrap_or_else(|| panic!("{}: method {key:?} vanished after pruning", base.name));
        assert_eq!(
            serde_json::to_value(&m_before.parameter_ownership).unwrap(),
            serde_json::to_value(&m_after.parameter_ownership).unwrap(),
            "{}: {key:?} ownership changed after pruning",
            base.name
        );
        assert_eq!(
            serde_json::to_value(&m_before.block_parameters).unwrap(),
            serde_json::to_value(&m_after.block_parameters).unwrap(),
            "{}: {key:?} block parameters changed after pruning",
            base.name
        );
        assert_eq!(
            m_before.threading, m_after.threading,
            "{}: {key:?} threading changed after pruning",
            base.name
        );
        assert_eq!(
            m_before.error_pattern, m_after.error_pattern,
            "{}: {key:?} error pattern changed after pruning",
            base.name
        );
    }
}

fn main() -> ExitCode {
    let mut api_root = PathBuf::from("platforms/macos/api");
    let mut only: Option<Vec<String>> = None;
    let mut write = false;

    let mut args = std::env::args().skip(1);
    while let Some(arg) = args.next() {
        match arg.as_str() {
            "--api-root" => api_root = PathBuf::from(args.next().expect("--api-root needs a value")),
            "--only" => {
                only = Some(
                    args.next()
                        .expect("--only needs a value")
                        .split(',')
                        .map(str::to_string)
                        .collect(),
                )
            }
            "--write" => write = true,
            other => {
                eprintln!("unknown argument: {other}");
                return ExitCode::FAILURE;
            }
        }
    }

    let resolved_files = match discover_family_artifacts(&api_root, "resolved.kdl") {
        Ok(files) => files,
        Err(e) => {
            eprintln!("error: {e}");
            return ExitCode::FAILURE;
        }
    };

    let mut total_safe = 0usize;
    let mut total_prose_only = 0usize;
    let mut frameworks_touched = 0usize;
    let mut all_prose_only: Vec<String> = Vec::new();

    for resolved_path in &resolved_files {
        let framework_name = resolved_path
            .parent()
            .and_then(|p| p.file_name())
            .and_then(|n| n.to_str())
            .unwrap_or("");
        if let Some(filter) = &only {
            if !filter.iter().any(|f| f == framework_name) {
                continue;
            }
        }

        let result = match analyze_one(&api_root, resolved_path) {
            Ok(Some(r)) => r,
            Ok(None) => continue,
            Err(e) => {
                eprintln!("error analyzing {}: {e}", resolved_path.display());
                return ExitCode::FAILURE;
            }
        };

        if result.safe_to_prune.is_empty() && result.prose_only.is_empty() {
            continue;
        }

        frameworks_touched += 1;
        total_safe += result.safe_to_prune.len();
        total_prose_only += result.prose_only.len();
        for p in &result.prose_only {
            all_prose_only.push(format!("{}: {p}", result.name));
        }

        println!(
            "{}: {} safe-to-prune, {} prose-only",
            result.name,
            result.safe_to_prune.len(),
            result.prose_only.len()
        );

        if write && !result.safe_to_prune.is_empty() {
            let base: Framework = load_framework_from_file(resolved_path).expect("reload base");
            let overlay_path = api_root.join(&result.name).join("annotations.apiw");
            let overlay_text = std::fs::read_to_string(&overlay_path).expect("reread overlay");
            let overlay = parse_apiw(&overlay_path.display().to_string(), &overlay_text)
                .expect("reparse overlay");
            let pruned = prune_overlay(&overlay, &result.safe_to_prune);

            verify_unchanged(&base, &overlay, &pruned);

            let pruned_text = write_apiw(&pruned);
            // Round-trip before committing to disk.
            let reparsed = parse_apiw(&overlay_path.display().to_string(), &pruned_text)
                .expect("pruned overlay must reparse");
            assert_eq!(
                serde_json::to_value(&pruned).unwrap(),
                serde_json::to_value(&reparsed).unwrap(),
                "{}: pruned overlay did not round-trip",
                result.name
            );

            std::fs::write(&overlay_path, pruned_text).expect("write pruned overlay");
            println!("  wrote {}", overlay_path.display());
        }
    }

    println!();
    println!(
        "total: {frameworks_touched} frameworks, {total_safe} safe-to-prune, {total_prose_only} prose-only"
    );
    if !all_prose_only.is_empty() {
        println!("prose-only facts (kept):");
        for p in &all_prose_only {
            println!("  {p}");
        }
    }

    ExitCode::SUCCESS
}
