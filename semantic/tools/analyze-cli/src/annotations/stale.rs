//! `apianyware-analyze annotations stale` — live annotation-staleness detection
//! (ADR-0050 §4 / ws5 `staleness-regen-k46`).
//!
//! Staleness is computed **live** by set-diffing a family's committed
//! `annotations.apiw` overlay against the current **resolved API surface**
//! (`resolved.kdl`) — no stored content hash (artifacts-not-state). The
//! comparison surface is the *resolved* graph, not raw `extracted.kdl`: the
//! overlay is authored over the inheritance-flattened, protocol-conformance-
//! flattened, Swift-renamed surface, so a naive diff against pre-resolve
//! `extracted.kdl` mis-reports ~⅓ of facts as orphaned (inherited methods keyed
//! under a subclass, `FileManager` vs `NSFileManager`, …). `resolved.kdl` is
//! self-contained — its `all_methods` already carry the cross-framework closure
//! — so this is a pure file read, no resolve pass and no dependency loading.
//!
//! Three signals (`CONTEXT.md` "Staleness / regeneration"):
//! - **orphaned** — an overlay fact names a `(receiver, selector)` absent from
//!   the current surface (the method was removed/renamed).
//! - **new-surface** — a current method with an *annotatable shape*
//!   ([`apianyware_annotate::surface::is_annotatable`]: a block param or an
//!   `NSError **` out-param) and no overlay fact.
//! - **shape-changed** — a method present in both whose parameter shape moved: an
//!   overlay fact targets a `param_index` that no longer holds the annotated kind.
//!
//! This child *produces* the worklist (the stale families); the regeneration
//! dispatch (Claude-Code subagents per stale family) is the `orchestration-skill`
//! child's (ws5 #5).

use std::collections::{HashMap, HashSet};
use std::path::PathBuf;

use anyhow::{Context, Result};
use apianyware_annotate::surface;
use apianyware_types::annotation::FrameworkAnnotations;
use apianyware_types::ir::{Framework, Method};
use clap::Args;
use serde::Serialize;

const EXAMPLES: &str = "\
EXAMPLES:
  # Report staleness across every family (gates: exit 1 if any family is stale)
  apianyware-analyze annotations stale

  # One family, machine-readable
  apianyware-analyze annotations stale --only Foundation --json

PRECONDITION:
  Reads each family's resolved.kdl. Regenerate it first with a plain
  `apianyware-analyze` (resolve) run after an SDK bump / extraction change.

EXIT CODES:
  0  no family is stale (all overlays current)
  1  at least one family is stale (regeneration needed)
  2  usage error";

/// `annotations stale` arguments.
#[derive(Args)]
#[command(after_help = EXAMPLES)]
pub struct StaleArgs {
    /// `api/` root holding the per-family spec triad
    /// (`<api-root>/<Framework>/{extracted.kdl,annotations.apiw,resolved.kdl}`).
    #[arg(long, default_value = "platforms/macos/api")]
    pub api_root: PathBuf,

    /// Restrict to specific framework(s) (comma-separated or repeated).
    #[arg(long, value_delimiter = ',')]
    pub only: Vec<String>,

    /// Emit a stable-schema JSON report on stdout instead of human-readable text.
    #[arg(long)]
    pub json: bool,
}

/// A single overlay/surface slot flagged by the staleness diff.
#[derive(Debug, Clone, Serialize, PartialEq, Eq)]
pub struct Slot {
    /// Receiver name (class or protocol) the overlay/surface keys the method on.
    pub class: String,
    /// Method selector.
    pub selector: String,
    /// Instance method (`true`) vs class method (`false`).
    pub is_instance: bool,
    /// Signal-specific detail: the structural reason (`"block"` / `"error"`) for
    /// new-surface; the moved fact-slot (`"block-param[1]"`, `"param-ownership[0]"`,
    /// `"error-pattern"`) for shape-changed; absent for orphaned.
    #[serde(skip_serializing_if = "Option::is_none")]
    pub detail: Option<String>,
}

impl Slot {
    fn new(class: &str, selector: &str, is_instance: bool, detail: Option<String>) -> Self {
        Self {
            class: class.to_string(),
            selector: selector.to_string(),
            is_instance,
            detail,
        }
    }
}

/// The per-family staleness result: the three signal lists. Empty lists ⇒ the
/// family's overlay is current.
#[derive(Debug, Clone, Serialize, PartialEq, Eq)]
pub struct FamilyStaleness {
    pub family: String,
    pub orphaned: Vec<Slot>,
    pub new_surface: Vec<Slot>,
    pub shape_changed: Vec<Slot>,
}

impl FamilyStaleness {
    /// A family is stale iff any signal fired.
    pub fn is_stale(&self) -> bool {
        !self.orphaned.is_empty() || !self.new_surface.is_empty() || !self.shape_changed.is_empty()
    }
}

/// Compute the staleness signals for one family: set-diff its authored `overlay`
/// against its `resolved` API surface. Pure — no I/O — so it is unit-testable
/// against hand-built fixtures.
pub fn compute_staleness(overlay: &FrameworkAnnotations, resolved: &Framework) -> FamilyStaleness {
    // The flattened surface index, for orphan resolution + shape lookup. Keyed
    // by `(receiver, selector, is_instance)` under each class's runtime name AND
    // its `swift_name` (the overlay may key either — `FileManager` vs
    // `NSFileManager`), and under each protocol's name. Classes use the
    // inheritance-flattened `all_methods` (falling back to direct `methods`
    // pre-resolve — both already carry the class's category methods, extraction
    // merges them in, `text-undo-surface-gap-k121`).
    let mut surface: HashMap<(&str, &str, bool), &Method> = HashMap::new();
    for class in &resolved.classes {
        let methods = if class.all_methods.is_empty() {
            &class.methods
        } else {
            &class.all_methods
        };
        for m in methods {
            let inst = !m.class_method;
            surface.insert((class.name.as_str(), m.selector.as_str(), inst), m);
            if let Some(sw) = &class.swift_name {
                surface.insert((sw.as_str(), m.selector.as_str(), inst), m);
            }
        }
    }
    for proto in &resolved.protocols {
        for m in proto.required_methods.iter().chain(&proto.optional_methods) {
            surface.insert(
                (proto.name.as_str(), m.selector.as_str(), !m.class_method),
                m,
            );
        }
    }

    // The overlay key set, for the new-surface coverage check.
    let mut overlay_keys: HashSet<(&str, &str, bool)> = HashSet::new();
    for class in &overlay.classes {
        for m in &class.methods {
            overlay_keys.insert((
                class.class_name.as_str(),
                m.selector.as_str(),
                m.is_instance,
            ));
        }
    }

    // orphaned + shape-changed: walk every overlay fact.
    let mut orphaned = Vec::new();
    let mut shape_changed = Vec::new();
    for class in &overlay.classes {
        for m in &class.methods {
            let key = (
                class.class_name.as_str(),
                m.selector.as_str(),
                m.is_instance,
            );
            match surface.get(&key) {
                None => orphaned.push(Slot::new(
                    &class.class_name,
                    &m.selector,
                    m.is_instance,
                    None,
                )),
                Some(method) => {
                    // Validate each authored fact-slot's targeted parameter still
                    // holds the annotated kind; a mismatch is a shape change.
                    for po in &m.parameter_ownership {
                        if !surface::param_at_is_object(method, po.param_index) {
                            shape_changed.push(Slot::new(
                                &class.class_name,
                                &m.selector,
                                m.is_instance,
                                Some(format!("param-ownership[{}]", po.param_index)),
                            ));
                        }
                    }
                    for bp in &m.block_parameters {
                        if !surface::param_at_is_block(method, bp.param_index) {
                            shape_changed.push(Slot::new(
                                &class.class_name,
                                &m.selector,
                                m.is_instance,
                                Some(format!("block-param[{}]", bp.param_index)),
                            ));
                        }
                    }
                    if m.error_pattern.is_some() && !surface::has_error_out_param(method) {
                        shape_changed.push(Slot::new(
                            &class.class_name,
                            &m.selector,
                            m.is_instance,
                            Some("error-pattern".to_string()),
                        ));
                    }
                    // Threading is a method-level fact with no parameter to track,
                    // so it cannot shape-change (only orphan, handled above).
                }
            }
        }
    }

    // new-surface: walk declared-here methods (`class.methods`, which already
    // carries a class's category methods — extraction merges them in,
    // `text-undo-surface-gap-k121`; required + optional for protocols — *not*
    // the flattened `all_methods`, so an inherited method is reported once,
    // under its declaring receiver), keep the structurally-annotatable ones
    // with no overlay fact.
    let mut new_surface = Vec::new();
    let mut seen: HashSet<(&str, &str, bool)> = HashSet::new();
    for class in &resolved.classes {
        for m in &class.methods {
            consider_new_surface(
                &class.name,
                class.swift_name.as_deref(),
                m,
                &overlay_keys,
                &mut seen,
                &mut new_surface,
            );
        }
    }
    for proto in &resolved.protocols {
        for m in proto.required_methods.iter().chain(&proto.optional_methods) {
            consider_new_surface(
                &proto.name,
                None,
                m,
                &overlay_keys,
                &mut seen,
                &mut new_surface,
            );
        }
    }

    // Deterministic order for stable output + tests (the maps above are unordered).
    sort_slots(&mut orphaned);
    sort_slots(&mut new_surface);
    sort_slots(&mut shape_changed);

    FamilyStaleness {
        family: resolved.name.clone(),
        orphaned,
        new_surface,
        shape_changed,
    }
}

/// Flag `m` as new-surface when it is structurally annotatable and no overlay
/// fact covers it (under the receiver's runtime name *or* its `swift_name`),
/// deduplicating repeats via `seen`.
fn consider_new_surface<'a>(
    receiver: &'a str,
    swift_name: Option<&'a str>,
    m: &'a Method,
    overlay_keys: &HashSet<(&str, &str, bool)>,
    seen: &mut HashSet<(&'a str, &'a str, bool)>,
    out: &mut Vec<Slot>,
) {
    if !surface::is_annotatable(m) {
        return;
    }
    let inst = !m.class_method;
    let covered = overlay_keys.contains(&(receiver, m.selector.as_str(), inst))
        || swift_name.is_some_and(|sw| overlay_keys.contains(&(sw, m.selector.as_str(), inst)));
    if covered {
        return;
    }
    if !seen.insert((receiver, m.selector.as_str(), inst)) {
        return;
    }
    let reason = if surface::has_block_param(m) {
        "block"
    } else {
        "error"
    };
    out.push(Slot::new(
        receiver,
        &m.selector,
        inst,
        Some(reason.to_string()),
    ));
}

fn sort_slots(slots: &mut [Slot]) {
    slots.sort_by(|a, b| {
        (
            a.class.as_str(),
            a.selector.as_str(),
            a.is_instance,
            a.detail.as_deref(),
        )
            .cmp(&(
                b.class.as_str(),
                b.selector.as_str(),
                b.is_instance,
                b.detail.as_deref(),
            ))
    });
}

/// Run the `stale` command: load each family's `resolved.kdl` surface + its
/// committed overlay, compute staleness, print the report, and return whether
/// **any** family is stale (the caller maps `true` → exit 1).
pub fn run(args: &StaleArgs) -> Result<bool> {
    let only = if args.only.is_empty() {
        None
    } else {
        Some(args.only.as_slice())
    };

    let resolved = apianyware_datalog::loading::load_all_family_artifacts(
        &args.api_root,
        "resolved.kdl",
        only,
    )?;
    if resolved.is_empty() {
        anyhow::bail!(
            "no resolved.kdl found under {} — run `apianyware-analyze` (resolve) first to \
             generate the resolved surface",
            args.api_root.display()
        );
    }

    let mut reports: Vec<FamilyStaleness> = resolved
        .iter()
        .map(|fw| {
            let overlay = crate::load_overlay(&args.api_root, &fw.name)?
                .unwrap_or_else(|| empty_overlay(&fw.name));
            Ok(compute_staleness(&overlay, fw))
        })
        .collect::<Result<_>>()?;
    reports.sort_by(|a, b| a.family.cmp(&b.family));

    let stale: Vec<&FamilyStaleness> = reports.iter().filter(|r| r.is_stale()).collect();
    if args.json {
        print_json(&reports, &stale)?;
    } else {
        print_human(&reports, &stale);
    }
    Ok(!stale.is_empty())
}

fn empty_overlay(framework: &str) -> FrameworkAnnotations {
    FrameworkAnnotations {
        framework: framework.to_string(),
        classes: Vec::new(),
        subagent_report: None,
    }
}

/// Stable JSON report. `families` lists only the **stale** families (the
/// actionable records); `worklist` is their names.
#[derive(Serialize)]
struct StaleReport<'a> {
    stale_families: usize,
    total_families: usize,
    worklist: Vec<&'a str>,
    families: Vec<&'a FamilyStaleness>,
}

fn print_json(reports: &[FamilyStaleness], stale: &[&FamilyStaleness]) -> Result<()> {
    let report = StaleReport {
        stale_families: stale.len(),
        total_families: reports.len(),
        worklist: stale.iter().map(|r| r.family.as_str()).collect(),
        families: stale.to_vec(),
    };
    let json = serde_json::to_string_pretty(&report).context("failed to serialize stale report")?;
    println!("{json}");
    Ok(())
}

/// How many slots to list per signal in human output before truncating.
const SAMPLE_LIMIT: usize = 8;

fn print_human(reports: &[FamilyStaleness], stale: &[&FamilyStaleness]) {
    if stale.is_empty() {
        println!(
            "ok: all {} families' annotations are current (no orphaned / new-surface / \
             shape-changed slots)",
            reports.len()
        );
        return;
    }

    for fam in stale {
        println!(
            "{}: {} orphaned, {} new-surface, {} shape-changed",
            fam.family,
            fam.orphaned.len(),
            fam.new_surface.len(),
            fam.shape_changed.len()
        );
        print_sample("orphaned", &fam.orphaned);
        print_sample("new-surface", &fam.new_surface);
        print_sample("shape-changed", &fam.shape_changed);
    }

    let worklist: Vec<&str> = stale.iter().map(|r| r.family.as_str()).collect();
    println!();
    println!(
        "stale: {} of {} families need regeneration: {}",
        stale.len(),
        reports.len(),
        worklist.join(", ")
    );
}

fn print_sample(label: &str, slots: &[Slot]) {
    for slot in slots.iter().take(SAMPLE_LIMIT) {
        let kind = if slot.is_instance { "-" } else { "+" };
        match &slot.detail {
            Some(d) => println!(
                "    {label}: {kind}[{}] {} ({d})",
                slot.class, slot.selector
            ),
            None => println!("    {label}: {kind}[{}] {}", slot.class, slot.selector),
        }
    }
    if slots.len() > SAMPLE_LIMIT {
        println!("    {label}: ... and {} more", slots.len() - SAMPLE_LIMIT);
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use apianyware_types::annotation::{
        AnnotationSource, BlockInvocationStyle, BlockParamAnnotation, ClassAnnotations,
        ErrorPattern, MethodAnnotation, OwnershipKind, ParamOwnership,
    };
    use apianyware_types::ir::{Class, Method, Param};
    use apianyware_types::type_ref::{TypeRef, TypeRefKind};

    fn ir_method(selector: &str, params: Vec<Param>) -> Method {
        Method {
            selector: selector.to_string(),
            class_method: false,
            init_method: false,
            params,
            return_type: TypeRef::void(),
            deprecated: false,
            variadic: false,
            source: None,
            provenance: None,
            doc_refs: None,
            origin: None,
            category: None,
            overrides: None,
            returns_retained: None,
            satisfies_protocol: None,
            objc_exposed: true,
            swift_fn: None,
        }
    }

    fn param(name: &str, kind: TypeRefKind) -> Param {
        Param {
            name: name.to_string(),
            param_type: TypeRef {
                nullable: false,
                kind,
            },
        }
    }

    fn block_param(name: &str) -> Param {
        param(
            name,
            TypeRefKind::Block {
                params: vec![],
                return_type: Box::new(TypeRef::void()),
            },
        )
    }

    fn class(name: &str, swift_name: Option<&str>, methods: Vec<Method>) -> Class {
        Class {
            name: name.to_string(),
            superclass: String::new(),
            protocols: vec![],
            properties: vec![],
            methods,
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
            swift_name: swift_name.map(str::to_string),
        }
    }

    fn framework(name: &str, classes: Vec<Class>) -> Framework {
        Framework {
            format_version: "1.0".to_string(),
            checkpoint: "resolved".to_string(),
            name: name.to_string(),
            sdk_version: None,
            collected_at: None,
            depends_on: vec![],
            skipped_symbols: vec![],
            classes,
            protocols: vec![],
            enums: vec![],
            structs: vec![],
            functions: vec![],
            constants: vec![],
            class_annotations: vec![],
            patterns: vec![],
            enrichment: None,
            verification: None,
        }
    }

    fn overlay(framework: &str, classes: Vec<ClassAnnotations>) -> FrameworkAnnotations {
        FrameworkAnnotations {
            framework: framework.to_string(),
            classes,
            subagent_report: None,
        }
    }

    fn ann(selector: &str) -> MethodAnnotation {
        MethodAnnotation {
            selector: selector.to_string(),
            is_instance: true,
            parameter_ownership: vec![],
            block_parameters: vec![],
            threading: None,
            error_pattern: None,
            source: AnnotationSource::Llm,
            confidence: None,
            provenance: None,
            fact_provenance: None,
        }
    }

    #[test]
    fn current_overlay_is_not_stale() {
        // One block method, annotated. Surface matches overlay → no signal.
        let fw = framework(
            "TestFW",
            vec![class(
                "NSArray",
                None,
                vec![ir_method(
                    "enumerateObjectsUsingBlock:",
                    vec![block_param("block")],
                )],
            )],
        );
        let mut a = ann("enumerateObjectsUsingBlock:");
        a.block_parameters = vec![BlockParamAnnotation {
            param_index: 0,
            invocation: BlockInvocationStyle::Synchronous,
        }];
        let ov = overlay(
            "TestFW",
            vec![ClassAnnotations {
                class_name: "NSArray".to_string(),
                methods: vec![a],
            }],
        );

        let r = compute_staleness(&ov, &fw);
        assert!(!r.is_stale(), "{r:?}");
    }

    #[test]
    fn overlay_fact_for_removed_method_is_orphaned() {
        // Surface has no such method → the overlay fact is orphaned.
        let fw = framework("TestFW", vec![class("NSArray", None, vec![])]);
        let ov = overlay(
            "TestFW",
            vec![ClassAnnotations {
                class_name: "NSArray".to_string(),
                methods: vec![ann("goneAwayUsingBlock:")],
            }],
        );

        let r = compute_staleness(&ov, &fw);
        assert_eq!(r.orphaned.len(), 1);
        assert_eq!(r.orphaned[0].selector, "goneAwayUsingBlock:");
        assert!(r.new_surface.is_empty());
        assert!(r.shape_changed.is_empty());
    }

    #[test]
    fn inherited_overlay_fact_resolves_via_flattened_surface() {
        // The overlay keys `setCompletionBlock:` under the *subclass*
        // NSBlockOperation; the resolved surface carries it in the subclass's
        // `all_methods` (inheritance-flattened). It must NOT be orphaned —
        // this is the exact case naive extracted.kdl diffing gets wrong.
        let mut subclass = class("NSBlockOperation", None, vec![]);
        subclass.all_methods = vec![ir_method("setCompletionBlock:", vec![block_param("block")])];
        let fw = framework("TestFW", vec![subclass]);

        let mut a = ann("setCompletionBlock:");
        a.block_parameters = vec![BlockParamAnnotation {
            param_index: 0,
            invocation: BlockInvocationStyle::AsyncCopied,
        }];
        let ov = overlay(
            "TestFW",
            vec![ClassAnnotations {
                class_name: "NSBlockOperation".to_string(),
                methods: vec![a],
            }],
        );

        let r = compute_staleness(&ov, &fw);
        assert!(r.orphaned.is_empty(), "inherited fact must resolve: {r:?}");
    }

    #[test]
    fn swift_named_class_resolves_overlay_keyed_by_swift_name() {
        // Surface class is NSFileManager (swift_name FileManager); the overlay
        // keyed the fact under the Swift name. It must resolve, not orphan.
        let fw = framework(
            "TestFW",
            vec![class(
                "NSFileManager",
                Some("FileManager"),
                vec![ir_method(
                    "doThing:error:",
                    vec![
                        param(
                            "thing",
                            TypeRefKind::Id {
                                protocols: Vec::new(),
                            },
                        ),
                        param("error", TypeRefKind::Pointer),
                    ],
                )],
            )],
        );
        let mut a = ann("doThing:error:");
        a.error_pattern = Some(ErrorPattern::ErrorOutParam);
        let ov = overlay(
            "TestFW",
            vec![ClassAnnotations {
                class_name: "FileManager".to_string(),
                methods: vec![a],
            }],
        );

        let r = compute_staleness(&ov, &fw);
        assert!(
            r.orphaned.is_empty(),
            "swift-named fact must resolve: {r:?}"
        );
        assert!(r.shape_changed.is_empty(), "{r:?}");
    }

    #[test]
    fn annotatable_method_without_overlay_fact_is_new_surface() {
        // A block method with no overlay fact → new-surface (reason "block").
        let fw = framework(
            "TestFW",
            vec![class(
                "NSDocument",
                None,
                vec![ir_method("performAsync:", vec![block_param("block")])],
            )],
        );
        let r = compute_staleness(&overlay("TestFW", vec![]), &fw);
        assert_eq!(r.new_surface.len(), 1);
        assert_eq!(r.new_surface[0].selector, "performAsync:");
        assert_eq!(r.new_surface[0].detail.as_deref(), Some("block"));
    }

    #[test]
    fn non_annotatable_method_is_not_new_surface() {
        // A plain accessor (no block, no error out-param) is not new-surface.
        let fw = framework(
            "TestFW",
            vec![class("NSArray", None, vec![ir_method("count", vec![])])],
        );
        let r = compute_staleness(&overlay("TestFW", vec![]), &fw);
        assert!(r.new_surface.is_empty(), "{r:?}");
    }

    #[test]
    fn moved_block_param_is_shape_changed() {
        // The overlay says block at index 1, but the current method has a block
        // at index 0 and a non-block at index 1 → shape-changed.
        let fw = framework(
            "TestFW",
            vec![class(
                "NSArray",
                None,
                vec![ir_method(
                    "enumerate:options:",
                    vec![
                        block_param("block"),
                        param(
                            "options",
                            TypeRefKind::Primitive {
                                name: "NSUInteger".to_string(),
                            },
                        ),
                    ],
                )],
            )],
        );
        let mut a = ann("enumerate:options:");
        a.block_parameters = vec![BlockParamAnnotation {
            param_index: 1,
            invocation: BlockInvocationStyle::Synchronous,
        }];
        let ov = overlay(
            "TestFW",
            vec![ClassAnnotations {
                class_name: "NSArray".to_string(),
                methods: vec![a],
            }],
        );

        let r = compute_staleness(&ov, &fw);
        assert_eq!(r.shape_changed.len(), 1);
        assert_eq!(r.shape_changed[0].detail.as_deref(), Some("block-param[1]"));
        assert!(r.orphaned.is_empty());
    }

    #[test]
    fn moved_ownership_param_is_shape_changed() {
        // The overlay annotates ownership on param 0, now a primitive (not an
        // object) → shape-changed.
        let fw = framework(
            "TestFW",
            vec![class(
                "NSCache",
                None,
                vec![ir_method(
                    "setCountLimit:",
                    vec![param(
                        "limit",
                        TypeRefKind::Primitive {
                            name: "NSUInteger".to_string(),
                        },
                    )],
                )],
            )],
        );
        let mut a = ann("setCountLimit:");
        a.parameter_ownership = vec![ParamOwnership {
            param_index: 0,
            ownership: OwnershipKind::Weak,
        }];
        let ov = overlay(
            "TestFW",
            vec![ClassAnnotations {
                class_name: "NSCache".to_string(),
                methods: vec![a],
            }],
        );

        let r = compute_staleness(&ov, &fw);
        assert_eq!(r.shape_changed.len(), 1);
        assert_eq!(
            r.shape_changed[0].detail.as_deref(),
            Some("param-ownership[0]")
        );
    }

    #[test]
    fn class_vs_instance_methods_are_keyed_distinctly() {
        // An overlay fact for the *instance* selector must not be satisfied by a
        // class method of the same selector (and vice-versa).
        let mut class_method = ir_method("create:", vec![block_param("block")]);
        class_method.class_method = true; // +create:
        let fw = framework("TestFW", vec![class("NSThing", None, vec![class_method])]);
        // Overlay fact is for the *instance* -create: which does not exist.
        let mut a = ann("create:"); // ann() sets is_instance = true
        a.block_parameters = vec![BlockParamAnnotation {
            param_index: 0,
            invocation: BlockInvocationStyle::Synchronous,
        }];
        let ov = overlay(
            "TestFW",
            vec![ClassAnnotations {
                class_name: "NSThing".to_string(),
                methods: vec![a],
            }],
        );

        let r = compute_staleness(&ov, &fw);
        assert_eq!(
            r.orphaned.len(),
            1,
            "instance fact must not match class method: {r:?}"
        );
        assert!(r.orphaned[0].is_instance);
        // The +create: class method is itself annotatable & uncovered → new-surface.
        assert_eq!(r.new_surface.len(), 1);
        assert!(!r.new_surface[0].is_instance);
    }
}
