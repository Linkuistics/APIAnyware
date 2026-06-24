//! Ascent Datalog program for the Cocoa naming-convention tier (ADR-0047).
//!
//! Re-expresses the imperative classifiers of `annotate/heuristics.rs` as
//! declarative `ascent` rules over a per-method fact base, the same engine as
//! the `resolve` and `enrich` programs. Each derived fact names the **rule**
//! that produced it (`&'static str`), so the per-fact `convention:<rule>`
//! provenance (ADR-0046 §4) falls out of the derivation trace.
//!
//! **Facet scope (k22):** parameter ownership only — weak delegate/dataSource/
//! observer references and copied block parameters. The block-invocation,
//! threading, and error-pattern facets are later siblings; the pipeline is not
//! yet wired to this program (the flip child does that). Rules here reproduce
//! the legacy classifications *exactly* (goldens-as-truth), introducing no new
//! conventions.

// The `ascent!` macro expands rule bodies into code that clones Copy-typed
// relation fields, produces `()` tail expressions, and stamps explicit
// lifetimes on index iterators. Clippy cannot see past macro boundaries, so
// these lints fire on generated code we don't own.
#![allow(clippy::clone_on_copy, clippy::unused_unit, clippy::needless_lifetimes)]

use ascent::ascent;

ascent! {
    pub struct ConventionProgram;

    // =======================================================================
    // Base facts (loaded from the linked IR — one tuple per method parameter)
    // =======================================================================

    /// param(receiver, selector, param_index, param_name, is_block)
    ///
    /// `receiver` is a class or protocol name; `is_block` is true when the
    /// parameter's declared type is an ObjC block.
    relation param(String, String, u32, String, bool);

    // =======================================================================
    // Parameter-ownership facet
    // =======================================================================

    /// weak_param(receiver, selector, param_index, rule)
    ///
    /// A parameter the receiver holds *weakly* (does not retain). Mirrors
    /// `heuristics::is_delegate_param` + `is_observer_param`.
    relation weak_param(String, String, u32, &'static str);

    // Delegate / data-source by parameter name (`delegate`, `dataSource`).
    weak_param(r.clone(), s.clone(), *i, "weak-delegate-param") <--
        param(r, s, i, name, _is_block),
        if name_is_delegateish(name);

    // Delegate / data-source by the selector segment at the parameter index
    // (e.g. `setDelegate:` segment 0 is "setDelegate").
    weak_param(r.clone(), s.clone(), *i, "weak-delegate-param") <--
        param(r, s, i, _name, _is_block),
        if segment_is_delegateish(s, *i);

    // The canonical single-arg `setDelegate:` / `setDataSource:` setters: the
    // sole argument (index 0) is weak.
    weak_param(r.clone(), s.clone(), 0, "weak-delegate-param") <--
        param(r, s, 0, _name, _is_block),
        if is_set_delegate_selector(s);

    // KVO / notification `add…Observer:` — the first argument is the observer,
    // held weakly. Mirrors `heuristics::is_observer_param`.
    weak_param(r.clone(), s.clone(), 0, "weak-observer-param") <--
        param(r, s, 0, name, _is_block),
        if is_observer_first_param(s, name);

    /// is_weak(receiver, selector, param_index) — rule-erased projection of
    /// `weak_param`, so `copy_param`'s negation has all variables bound (the
    /// stratified-negation pattern used by the enrich program).
    relation is_weak(String, String, u32);
    is_weak(r.clone(), s.clone(), *i) <-- weak_param(r, s, i, _rule);

    /// copy_param(receiver, selector, param_index, rule)
    ///
    /// A block-typed parameter the receiver copies (`Block_copy`). Weak takes
    /// precedence (a block that is also a delegate stays weak), exactly as the
    /// legacy `if is_delegate … else if is_block …` ladder did.
    relation copy_param(String, String, u32, &'static str);
    copy_param(r.clone(), s.clone(), *i, "block-param-copy") <--
        param(r, s, i, _name, is_block),
        if *is_block,
        !is_weak(r, s, i);
}

// ---------------------------------------------------------------------------
// Convention predicates — ported verbatim from `annotate/heuristics.rs` so the
// rule set reproduces the current classifications. Kept as free functions
// (rather than inlined into the guards) to keep each rule legible.
// ---------------------------------------------------------------------------

/// A parameter name that names a delegate or data source.
/// Mirrors `is_delegate_param`'s direct-name branch.
fn name_is_delegateish(name: &str) -> bool {
    let lower = name.to_lowercase();
    lower.contains("delegate") || lower.contains("datasource")
}

/// The selector segment at `index` (split on `:`) names a delegate / data
/// source. Mirrors `is_delegate_param`'s selector-part branch.
fn segment_is_delegateish(selector: &str, index: u32) -> bool {
    selector.split(':').nth(index as usize).is_some_and(|part| {
        let lower = part.to_lowercase();
        lower.contains("delegate") || lower.contains("datasource")
    })
}

/// The selector is the canonical `setDelegate:` / `setDataSource:` setter.
/// Mirrors `is_delegate_param`'s known-setter branch.
fn is_set_delegate_selector(selector: &str) -> bool {
    let lower = selector.to_lowercase();
    lower == "setdelegate:" || lower == "setdatasource:"
}

/// The first parameter of an `add<Qualifier>Observer:` selector is the
/// observer. Mirrors `is_observer_param` (the index-0 gate lives in the rule
/// head). The block-form `addObserverForName:…` is excluded because its first
/// segment ends in `Name`, not `Observer`.
fn is_observer_first_param(selector: &str, param_name: &str) -> bool {
    if !param_name.to_lowercase().contains("observer") {
        return false;
    }
    let first_segment = selector.split(':').next().unwrap_or("");
    first_segment.starts_with("add") && first_segment.ends_with("Observer")
}

#[cfg(test)]
mod tests {
    use super::*;

    /// Run the program over a single method's parameters and collect the
    /// derived ownership facts as `(index, kind, rule)` for assertion.
    fn run(selector: &str, params: &[(&str, bool)]) -> ConventionProgram {
        let mut prog = ConventionProgram::default();
        for (i, (name, is_block)) in params.iter().enumerate() {
            prog.param.push((
                "R".to_string(),
                selector.to_string(),
                i as u32,
                name.to_string(),
                *is_block,
            ));
        }
        prog.run();
        prog
    }

    #[test]
    fn set_delegate_first_param_is_weak() {
        let prog = run("setDelegate:", &[("delegate", false)]);
        assert!(prog
            .weak_param
            .iter()
            .any(|(_, s, i, _)| s == "setDelegate:" && *i == 0));
        assert!(prog.copy_param.is_empty());
    }

    #[test]
    fn observer_first_param_is_weak() {
        let prog = run(
            "addObserver:forKeyPath:options:context:",
            &[
                ("observer", false),
                ("keyPath", false),
                ("options", false),
                ("context", false),
            ],
        );
        let observer = prog.weak_param.iter().find(|(_, _, i, _)| *i == 0);
        assert!(matches!(observer, Some((_, _, _, "weak-observer-param"))));
    }

    #[test]
    fn block_param_is_copy_not_weak() {
        let prog = run("sortedArrayUsingComparator:", &[("cmptr", true)]);
        assert!(prog
            .copy_param
            .iter()
            .any(|(_, _, i, rule)| *i == 0 && *rule == "block-param-copy"));
        assert!(prog.weak_param.is_empty());
    }

    #[test]
    fn observer_block_form_does_not_match() {
        // `addObserverForName:…` first segment ends in "Name" — not an observer.
        let prog = run(
            "addObserverForName:object:queue:usingBlock:",
            &[
                ("name", false),
                ("obj", false),
                ("queue", false),
                ("block", true),
            ],
        );
        // Param 0 (name) must not be weak; param 3 (block) is copy.
        assert!(!prog.weak_param.iter().any(|(_, _, i, _)| *i == 0));
        assert!(prog.copy_param.iter().any(|(_, _, i, _)| *i == 3));
    }
}
