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

    /// param_count(receiver, selector, total_params)
    ///
    /// The method's parameter count, used by the block-invocation facet's
    /// "block is the last parameter" rule (mirrors legacy
    /// `param_index == total_params - 1`).
    relation param_count(String, String, u32);

    /// property(receiver, name, is_copy, is_block)
    ///
    /// One tuple per **instance** property the receiver declares directly
    /// (class properties are excluded at load — the legacy block-setter rule
    /// requires `!p.class_property`). `is_copy` is the ObjC `(copy)` attribute;
    /// `is_block` is true when the property's declared type is a block. Consumed
    /// by the copy-block-property-setter rule below; classes **and** protocols
    /// contribute (a protocol may declare a `@property (copy)` block property).
    relation property(String, String, bool, bool);

    /// receiver_method(receiver, selector, is_class)
    ///
    /// One tuple per method (class **or** protocol), the **method-level**
    /// enumeration the threading facet keys on — emitted even for zero-parameter
    /// selectors (`display`, `layout`, `updateLayer`), which carry no `param`
    /// fact. `is_class` is true for class receivers, false for protocols, so the
    /// class-only `@MainActor` signal cannot leak to a **same-named** protocol's
    /// methods (the legacy `annotate_protocol_method_heuristic` passes `&[]`
    /// swift-attributes for protocols). Because the program keys by bare receiver
    /// name, this per-method kind bit is the only thing that keeps a class `Foo`
    /// with `@MainActor` from main-thread-stamping a colliding protocol `Foo`'s
    /// methods.
    relation receiver_method(String, String, bool);

    /// swift_attribute(class, attribute)
    ///
    /// One tuple per Swift attribute on a **class** (`class.swift_attributes` —
    /// classes only; the IR records no Swift attributes on protocols, and the
    /// legacy protocol path passes an empty slice). `attribute` is the bare
    /// digester name without the `@` prefix, possibly module-qualified
    /// (`MainActor`, `_Concurrency.MainActor`). Consumed by the main-actor
    /// threading signal.
    relation swift_attribute(String, String);

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

    // =======================================================================
    // Block-invocation facet
    //
    // Mirrors `heuristics::derive_block_parameters`: every block-typed
    // parameter resolves to exactly one `BlockInvocationStyle` ∈ {synchronous,
    // async_copied, stored} by a **6-level precedence cascade** (lower priority
    // number wins, "first match" in the legacy `if/else if` ladder):
    //
    //   0  copy-block-property-setter (index 0)        → stored
    //   1  sync selector pattern                       → synchronous
    //   2  async selector token                        → async_copied
    //   3  last param + async-method token             → async_copied
    //   4  stored selector pattern                     → stored
    //   5  default                                     → async_copied
    //
    // Each level is an independent rule emitting a `block_candidate` stamped
    // with its priority, style, and rule name. The readback selects the
    // lowest-priority candidate per parameter — the "explicit priority in the
    // readback" precedence option (ADR-0047 / k23 brief), chosen over a deep
    // stratified-negation chain because the six flat rules read as the legacy
    // ladder does. Every block param matches at least level 5, so the cascade
    // always classifies (matching the legacy `async_copied` fall-through).
    // =======================================================================

    /// block_copy_property_setter(receiver, selector)
    ///
    /// `selector` is the synthesised single-arg setter `set<Cap>:` for an
    /// instance `@property (copy)` whose declared type is a block. Mirrors
    /// `heuristics::is_copy_block_property_setter`: the join with `property`
    /// reproduces its `class_properties.iter().any(...)`, with `!class_property`
    /// already enforced at load.
    relation block_copy_property_setter(String, String);
    block_copy_property_setter(r.clone(), s.clone()) <--
        param(r, s, 0, _name, is_block),
        if *is_block,
        property(r, pname, is_copy, prop_is_block),
        if *is_copy,
        if *prop_is_block,
        if is_setter_for_property(s, pname);

    /// block_candidate(receiver, selector, param_index, priority, style, rule)
    ///
    /// One candidate classification for a block parameter; the readback keeps
    /// the lowest-`priority` candidate per `(receiver, selector, param_index)`.
    /// `style` is the serde `snake_case` `BlockInvocationStyle` name; `rule`
    /// becomes the `convention:<rule>` provenance stamp.
    relation block_candidate(String, String, u32, u32, &'static str, &'static str);

    // Priority 0 — `@property (copy)` block setter: stored (overrides the
    // substring tables, exactly as the legacy `if is_copy_block_property_setter`
    // short-circuit does).
    block_candidate(r.clone(), s.clone(), 0, 0, "stored", "block-copy-property-setter") <--
        block_copy_property_setter(r, s);

    // Priority 1 — synchronous selector patterns (enumerate / sort / comparator
    // / predicate / filter / index-of / passing-test): the block runs during
    // the call and is not copied.
    block_candidate(r.clone(), s.clone(), *i, 1, "synchronous", "block-sync") <--
        param(r, s, i, _name, is_block),
        if *is_block,
        if selector_has_sync_pattern(s);

    // Priority 2 — async selector tokens (completion / handler / callback /
    // reply / withResponse): the block is copied for later invocation.
    block_candidate(r.clone(), s.clone(), *i, 2, "async_copied", "block-async-token") <--
        param(r, s, i, _name, is_block),
        if *is_block,
        if selector_has_async_token(s);

    // Priority 3 — the block is the method's **last** parameter and the method
    // name reads as an async operation (dataTask / download / upload / fetch /
    // load / perform / animate).
    block_candidate(r.clone(), s.clone(), *i, 3, "async_copied", "block-async-last-param") <--
        param(r, s, i, _name, is_block),
        if *is_block,
        param_count(r, s, total),
        if *i + 1 == *total,
        if selector_has_async_method_token(s);

    // Priority 4 — stored selector patterns (addObserver / observe /
    // notification / addOperation): the receiver retains the block.
    block_candidate(r.clone(), s.clone(), *i, 4, "stored", "block-stored-pattern") <--
        param(r, s, i, _name, is_block),
        if *is_block,
        if selector_has_stored_pattern(s);

    // Priority 5 — default: async-copied (the legacy fall-through; explicit
    // free is only needed for the synchronous case).
    block_candidate(r.clone(), s.clone(), *i, 5, "async_copied", "block-async-default") <--
        param(r, s, i, _name, is_block),
        if *is_block;

    // =======================================================================
    // Threading facet
    //
    // Mirrors `heuristics::derive_threading`: a method is constrained to the
    // main thread (`ThreadingConstraint::MainThreadOnly` — the *only* constraint
    // the heuristic ever derives) when **any** of three independent signals
    // fires. There is **no precedence ladder** (unlike block-invocation): the
    // facet is a simple disjunction, so each signal is its own rule emitting a
    // `main_thread` fact stamped with the rule that fired. The readback unions
    // the stamps per method — a method may match several signals (e.g. a
    // `@MainActor` `UIView` calling `drawRect:` matches all three), all agreeing
    // on `MainThreadOnly`.
    // =======================================================================

    /// main_thread(receiver, selector, rule)
    ///
    /// The `(receiver, selector)` method is main-thread-only; `rule` becomes the
    /// `convention:<rule>` provenance stamp. Several rules may derive the same
    /// method (disjunction), so the readback keeps every stamp.
    relation main_thread(String, String, &'static str);

    // Signal 1 — class-level `@MainActor` propagates to **every** method on the
    // class (instance and class methods alike). Scoped to **class** receivers
    // (`is_class`): the legacy protocol path passes `&[]` swift-attributes, so a
    // protocol never carries this signal — and the `is_class` gate stops a class
    // `Foo`'s attribute from leaking onto a same-named protocol `Foo`'s methods
    // (the bare-name-keying collision the brief flags).
    main_thread(r.clone(), s.clone(), "main-actor-attribute") <--
        receiver_method(r, s, is_class),
        if *is_class,
        swift_attribute(r, attr),
        if is_main_actor_attribute(attr);

    // Signal 2 — the hardcoded UIKit class list. Keyed on the receiver **name**
    // for any receiver kind, exactly as the legacy `main_thread_classes.contains`
    // check ran for both class and protocol receivers (no UIKit-named protocol
    // exists, so the kind-agnostic match is faithful and inconsequential).
    main_thread(r.clone(), s.clone(), "uikit-class") <--
        receiver_method(r, s, _is_class),
        if is_uikit_main_thread_class(r);

    // Signal 3 — the UI selector list, on any class. Selector-only, so it applies
    // to class and protocol receivers alike (mirrors the legacy
    // `main_thread_selectors.contains(&selector)` check).
    main_thread(r.clone(), s.clone(), "ui-selector") <--
        receiver_method(r, s, _is_class),
        if is_ui_main_thread_selector(s);
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

// ---------------------------------------------------------------------------
// Block-invocation predicates — ported verbatim from
// `heuristics::classify_block_invocation` + `setter_target_property_name`. The
// substring tables are matched case-insensitively against the whole selector,
// exactly as the legacy `selector.to_lowercase().contains(pattern)` loop did.
// ---------------------------------------------------------------------------

/// The selector names a synchronous block use (run-during-the-call, not copied).
fn selector_has_sync_pattern(selector: &str) -> bool {
    const SYNC: [&str; 10] = [
        "enumerate",
        "sortedarray",
        "sortusing",
        "comparator",
        "predicate",
        "filteredarray",
        "filtered",
        "indexofobject",
        "indexesofobjects",
        "passingtest",
    ];
    let lower = selector.to_lowercase();
    SYNC.iter().any(|p| lower.contains(p))
}

/// The selector carries an async-completion token (block copied for later use).
fn selector_has_async_token(selector: &str) -> bool {
    const ASYNC: [&str; 5] = ["completion", "handler", "callback", "reply", "withresponse"];
    let lower = selector.to_lowercase();
    ASYNC.iter().any(|p| lower.contains(p))
}

/// The method name reads as an async operation; only consulted when the block
/// is the method's last parameter (the rule head enforces the position).
fn selector_has_async_method_token(selector: &str) -> bool {
    const METHODS: [&str; 7] = [
        "datatask", "download", "upload", "fetch", "load", "perform", "animate",
    ];
    let lower = selector.to_lowercase();
    METHODS.iter().any(|p| lower.contains(p))
}

/// The selector names a stored-block use (observer / notification / operation
/// registration): the receiver retains the block for repeated invocation.
fn selector_has_stored_pattern(selector: &str) -> bool {
    const STORED: [&str; 4] = ["addobserver", "observe", "notification", "addoperation"];
    let lower = selector.to_lowercase();
    STORED.iter().any(|p| lower.contains(p))
}

/// True when `selector` is the synthesised single-arg setter for the property
/// named `property_name`. Couples `setter_target_property_name` with the
/// name-equality check into one relation-joinable predicate (the join in
/// `block_copy_property_setter` needs both selector and property name bound).
fn is_setter_for_property(selector: &str, property_name: &str) -> bool {
    setter_target_property_name(selector).as_deref() == Some(property_name)
}

/// Map a synthesised setter selector `set<Cap><Rest>:` to the property name
/// `<lower><Rest>`. Returns `None` for selectors that are not single-argument
/// synthesised setters. Ported verbatim from
/// `heuristics::setter_target_property_name`.
fn setter_target_property_name(selector: &str) -> Option<String> {
    let stripped = selector.strip_prefix("set")?.strip_suffix(':')?;
    if stripped.split(':').count() != 1 {
        return None;
    }
    let mut chars = stripped.chars();
    let first = chars.next()?;
    if !first.is_ascii_uppercase() {
        return None;
    }
    let mut name = String::with_capacity(stripped.len());
    name.push(first.to_ascii_lowercase());
    name.extend(chars);
    Some(name)
}

// ---------------------------------------------------------------------------
// Threading predicates — ported verbatim from `heuristics::derive_threading`
// (the hardcoded UIKit class list, the UI selector list) and
// `heuristics::is_main_actor_attribute`. The conventions crate is
// self-contained — it depends on `apianyware-types`, not `annotate` — so these
// are copied rather than referenced (the flip child reverses the dependency,
// making `annotate` depend on `conventions`).
// ---------------------------------------------------------------------------

/// Recognise the swift-api-digester representations of `@MainActor`.
///
/// Match conservatively: equality after stripping a leading module qualifier,
/// so `MainActor` and `_Concurrency.MainActor` match (and a future
/// `Swift._Concurrency.MainActor` would too), while unrelated attributes like
/// `Available`, `HasStorage`, `MacroRole` do not. Ported verbatim from
/// `heuristics::is_main_actor_attribute`.
fn is_main_actor_attribute(attr: &str) -> bool {
    attr.rsplit('.').next().unwrap_or(attr) == "MainActor"
}

/// The receiver is one of the hardcoded UIKit classes that are main-thread-only.
/// AppKit classes are deliberately absent — they reach the heuristic via their
/// `@MainActor` / `NS_SWIFT_UI_ACTOR` swift-attributes (signal 1), so a hardcoded
/// AppKit list would be dead code. Ported verbatim from the `main_thread_classes`
/// array in `heuristics::derive_threading`.
fn is_uikit_main_thread_class(receiver: &str) -> bool {
    const UIKIT: [&str; 8] = [
        "UIView",
        "UIWindow",
        "UIButton",
        "UILabel",
        "UITextField",
        "UITableView",
        "UICollectionView",
        "UIViewController",
    ];
    UIKIT.contains(&receiver)
}

/// The selector is one of the UI-drawing/layout selectors that must run on the
/// main thread, on **any** class. Ported verbatim from the
/// `main_thread_selectors` array in `heuristics::derive_threading`.
fn is_ui_main_thread_selector(selector: &str) -> bool {
    const SELECTORS: [&str; 6] = [
        "display",
        "setNeedsDisplay",
        "setNeedsLayout",
        "layout",
        "drawRect:",
        "updateLayer",
    ];
    SELECTORS.contains(&selector)
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

    // -----------------------------------------------------------------
    // Block-invocation facet
    // -----------------------------------------------------------------

    /// Run the program over one method's parameters (with `param_count`) and
    /// optional `(property_name, is_copy, is_block)` receiver properties, then
    /// return the lowest-priority block candidate for `index` as `(style, rule)`.
    fn winning_block(
        selector: &str,
        params: &[(&str, bool)],
        properties: &[(&str, bool, bool)],
        index: u32,
    ) -> Option<(&'static str, &'static str)> {
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
        prog.param_count
            .push(("R".to_string(), selector.to_string(), params.len() as u32));
        for (name, is_copy, is_block) in properties {
            prog.property
                .push(("R".to_string(), name.to_string(), *is_copy, *is_block));
        }
        prog.run();
        prog.block_candidate
            .iter()
            .filter(|(_, _, i, _, _, _)| *i == index)
            .min_by_key(|(_, _, _, prio, _, _)| *prio)
            .map(|(_, _, _, _, style, rule)| (*style, *rule))
    }

    #[test]
    fn sync_pattern_wins_over_async_token() {
        // `enumerate` (sync, priority 1) is checked before `handler` (async,
        // priority 2) — sync wins, exactly as the legacy ladder orders it.
        let win = winning_block("enumerateUsingHandlerBlock:", &[("block", true)], &[], 0);
        assert_eq!(win, Some(("synchronous", "block-sync")));
    }

    #[test]
    fn async_token_wins_over_stored_pattern() {
        // `completion` (async, priority 2) beats `observe` (stored, priority 4).
        let win = winning_block("observeWithCompletion:", &[("block", true)], &[], 0);
        assert_eq!(win, Some(("async_copied", "block-async-token")));
    }

    #[test]
    fn last_param_async_method_gating_flips_stored_vs_async() {
        // `download` is an async-method token (priority 3) that only fires when
        // the block is the **last** param; `observe` is a stored pattern
        // (priority 4). Block last → async wins; block not last → stored wins.
        // This is the one place the last-param gate changes the resulting
        // *style*. (Note `observe` must appear exactly — `observing` would not
        // match the stored table.)
        let last = winning_block(
            "downloadAndObserve:block:",
            &[("arg", false), ("block", true)],
            &[],
            1,
        );
        assert_eq!(last, Some(("async_copied", "block-async-last-param")));

        let not_last = winning_block(
            "downloadAndObserveWithBlock:extra:",
            &[("block", true), ("extra", false)],
            &[],
            0,
        );
        assert_eq!(not_last, Some(("stored", "block-stored-pattern")));
    }

    #[test]
    fn copy_block_property_setter_overrides_classification() {
        // `setCompletionHandler:` would classify async via its tokens, but a
        // matching `(copy)` block property forces priority-0 stored.
        let win = winning_block(
            "setCompletionHandler:",
            &[("completionHandler", true)],
            &[("completionHandler", true, true)],
            0,
        );
        assert_eq!(win, Some(("stored", "block-copy-property-setter")));
    }

    #[test]
    fn non_copy_or_mismatched_property_does_not_force_stored() {
        // Non-copy property → no override (falls to async via "handler").
        let non_copy = winning_block(
            "setHandler:",
            &[("handler", true)],
            &[("handler", false, true)],
            0,
        );
        assert_eq!(non_copy, Some(("async_copied", "block-async-token")));

        // Two-arg "setter" is not a synthesised single-arg setter → no override.
        let two_arg = winning_block(
            "setHandler:withOptions:",
            &[("handler", true), ("options", false)],
            &[("handler", true, true)],
            0,
        );
        assert_eq!(two_arg, Some(("async_copied", "block-async-token")));
    }

    #[test]
    fn default_async_when_no_pattern_matches() {
        let win = winning_block("doThing:", &[("block", true)], &[], 0);
        assert_eq!(win, Some(("async_copied", "block-async-default")));
    }

    // -----------------------------------------------------------------
    // Threading facet
    // -----------------------------------------------------------------

    /// Run the program over one receiver's methods (with `is_class` and optional
    /// class swift-attributes) and return the set of `(selector, rule)` stamps
    /// the threading facet derived for that receiver, sorted.
    fn threading_stamps(
        receiver: &str,
        is_class: bool,
        selectors: &[&str],
        swift_attrs: &[&str],
    ) -> Vec<(String, &'static str)> {
        let mut prog = ConventionProgram::default();
        for selector in selectors {
            prog.receiver_method
                .push((receiver.to_string(), selector.to_string(), is_class));
        }
        for attr in swift_attrs {
            prog.swift_attribute
                .push((receiver.to_string(), attr.to_string()));
        }
        prog.run();
        let mut out: Vec<(String, &'static str)> = prog
            .main_thread
            .iter()
            .map(|(_, s, rule)| (s.clone(), *rule))
            .collect();
        out.sort();
        out
    }

    #[test]
    fn main_actor_attribute_propagates_to_all_methods() {
        // `@MainActor` on a class stamps every method (instance and class
        // method alike — the facet does not consult `class_method`).
        let stamps = threading_stamps("C", true, &["foo", "barClass:"], &["MainActor"]);
        assert_eq!(
            stamps,
            vec![
                ("barClass:".to_string(), "main-actor-attribute"),
                ("foo".to_string(), "main-actor-attribute"),
            ]
        );
    }

    #[test]
    fn module_qualified_main_actor_matches() {
        let stamps = threading_stamps("C", true, &["foo"], &["_Concurrency.MainActor"]);
        assert_eq!(stamps, vec![("foo".to_string(), "main-actor-attribute")]);
    }

    #[test]
    fn unrelated_attributes_do_not_trigger_main_thread() {
        let stamps = threading_stamps(
            "C",
            true,
            &["foo"],
            &["Available", "HasStorage", "MacroRole"],
        );
        assert!(stamps.is_empty());
    }

    #[test]
    fn uikit_class_list_fires_by_name() {
        let stamps = threading_stamps("UIView", true, &["someMethod"], &[]);
        assert_eq!(stamps, vec![("someMethod".to_string(), "uikit-class")]);
    }

    #[test]
    fn ui_selector_fires_on_any_class() {
        let stamps = threading_stamps("MyCustomView", true, &["drawRect:", "length"], &[]);
        // Only `drawRect:` is a UI selector; `length` is unconstrained.
        assert_eq!(stamps, vec![("drawRect:".to_string(), "ui-selector")]);
    }

    #[test]
    fn all_three_signals_stamp_the_same_method() {
        // A `@MainActor` `UIView` calling `drawRect:` matches every signal; the
        // disjunction keeps all three stamps (no precedence ladder).
        let stamps = threading_stamps("UIView", true, &["drawRect:"], &["MainActor"]);
        // Sorted by `(selector, rule)` — the rule names sort alphabetically.
        assert_eq!(
            stamps,
            vec![
                ("drawRect:".to_string(), "main-actor-attribute"),
                ("drawRect:".to_string(), "ui-selector"),
                ("drawRect:".to_string(), "uikit-class"),
            ]
        );
    }

    #[test]
    fn protocol_receiver_gets_no_main_actor_signal() {
        // A protocol carries no swift-attributes (the loader pushes none); even
        // if one were present, the `is_class` gate would block signal 1. The UI
        // selector signal still applies to protocols (selector-only).
        let stamps = threading_stamps("MyProto", false, &["doStuff", "layout"], &["MainActor"]);
        assert_eq!(stamps, vec![("layout".to_string(), "ui-selector")]);
    }

    #[test]
    fn same_named_class_attr_does_not_leak_to_protocol_methods() {
        // The collision case: a class `Foo` with `@MainActor` and a same-named
        // protocol `Foo` whose method is *not* declared on the class. The class
        // method is main-thread; the protocol-only method is not — the `is_class`
        // bit on `receiver_method` keeps the bare-name-keyed attribute from
        // leaking across.
        let mut prog = ConventionProgram::default();
        prog.receiver_method
            .push(("Foo".to_string(), "classMethod".to_string(), true));
        prog.receiver_method
            .push(("Foo".to_string(), "protoOnly".to_string(), false));
        prog.swift_attribute
            .push(("Foo".to_string(), "MainActor".to_string()));
        prog.run();
        let mut out: Vec<(String, &'static str)> = prog
            .main_thread
            .iter()
            .map(|(_, s, rule)| (s.clone(), *rule))
            .collect();
        out.sort();
        assert_eq!(
            out,
            vec![("classMethod".to_string(), "main-actor-attribute")]
        );
    }
}
