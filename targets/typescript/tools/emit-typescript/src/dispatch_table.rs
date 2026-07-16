//! The **generated outbound dispatch table** (`outbound-dispatch-table-k58`, realising
//! ADR-0054 §1 at corpus scale — the racket ADR-0013 shape, N-API-shaped).
//!
//! [`crate::native_dispatch`] computes the content-addressed entry *names* the emitted
//! `.ts` call sites reference; this module renders the **Swift side of that contract**:
//! one napi callback per distinct ABI-collapsed signature across the whole corpus, plus
//! the non-folding `…_o` +1 siblings, the non-folding `…_n` non-object-pointer siblings
//! (ADR-0057 §4) and the `…_e` error-`@catch` siblings (ADR-0058), written to the addon's
//! `src/Generated/DispatchTable.swift` by the generate CLI's global pass
//! (`generate → build.sh`, the racket build order).
//!
//! ## The mirror invariant
//!
//! [`collect_global_entries`] must reproduce, per method, **exactly** the
//! `(NativeSig, RetainAxis)` pair [`crate::emit_class`]'s `emit_body` computes — a call
//! site whose entry is missing from the table is a JS `TypeError` at dispatch time. So
//! the collection walks the same [`bound_methods`] frontier the class emitters walk,
//! keys fallibility off the same enrichment set, and computes the retain axis through
//! the same [`method_retain_axis`] predicate (k70: the fold gates on the wrap boundary,
//! never on the ABI shape — a `SEL`/`Class` return rides the non-folding, non-wrapping
//! `_n` sibling). Racket's rule carries over: err toward **over-collection** (an unused
//! entry is a harmless dead export; a missing one is a runtime failure).
//!
//! ## What the generated Swift leans on
//!
//! The generated file lives in the same swiftc module as the hand-written addon sources,
//! so it calls the internal `awMsgSendAddr` / `objcRetain` (dispatch.swift), the
//! `napi*` marshalling helpers (napi_support.swift), and `aw_msgsend_error_catching`
//! (awexc.m via shim.h). Registration is a generated `awRegisterGeneratedDispatch`
//! the hand-written `napi_register_module_v1` calls.

use std::collections::{BTreeMap, BTreeSet};

use apianyware_emit::enrichment::class_error_selectors;
use apianyware_types::ir::Framework;

use crate::class_graph::declared_classes;
use crate::class_surface::bound_methods;
use crate::emit_class::method_retain_axis;
use crate::ffi_type_mapping::TsFfiTypeMapper;
use crate::method_filter::{is_error_out_method, is_supported_method_ctx, swift_nominal_deferral};
use crate::native_dispatch::{AbiType, NativeSig, RetainAxis};
use crate::protocol_graph::ProtocolRegistry;
use crate::swift_abi::{cstr_arg_expr, cstr_prelude, marshal_return, reader_expr, swift_abi_type};

/// One generated dispatch entry: an ABI signature plus the retain-convention axis
/// (`Some(Owned)` → the non-folding `…_o` sibling; `Some(NoWrap)` → the non-folding,
/// non-wrapping `…_n` sibling for a pointer return that is no object, ADR-0057 §4 /
/// k70; `Some` exactly when the return is `Ptr`-shaped). The `_e` axis rides inside
/// [`NativeSig::error_out`]. Ordered so a `BTreeSet` renders deterministically.
#[derive(Debug, Clone, PartialEq, Eq, PartialOrd, Ord)]
pub struct DispatchEntry {
    pub sig: NativeSig,
    pub axis: Option<RetainAxis>,
}

impl DispatchEntry {
    /// The entry's exported name — the same string the emitted `.ts` call site computed.
    pub fn name(&self) -> String {
        self.sig.entry_name(self.axis)
    }
}

/// A fallible (`…error:`-flagged, trailing-pointer) method the error-out frontier
/// **defers** ([`NativeSig::error_out_from_method`] → `None`: a v-register/struct/void/
/// C-string shape in the fallible signature, or too many visible args for the `awexc.m`
/// switch). Mirror-consistent — such a method emits no call site either — but recorded
/// so the pass log stays honest (the "defer nothing silently" posture, spec §5).
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct DeferredFallible {
    pub class: String,
    pub selector: String,
}

/// A method the **Swift-nominal** frontier defers ([`crate::class_binding`]): a
/// `.swiftinterface`-sourced decl whose signature names a `Class{…}` the IR declares nowhere, so
/// it is not an object type at all (`NEPacketTunnelFlow.readPackets(): Tuple`). Mirror-consistent
/// — such a method emits no call site either — but recorded **with the offending type name**, so
/// the pass log says *which* Swift type cost us the method rather than merely that a count moved
/// (the "defer nothing silently" posture).
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct DeferredNominal {
    pub class: String,
    pub selector: String,
    /// The `Class{name}` the IR does not declare — the reason.
    pub type_name: String,
}

/// The whole-corpus outbound dispatch table: the deduplicated entry set plus the
/// recorded deferrals, by reason.
#[derive(Debug, Clone, Default)]
pub struct DispatchTable {
    pub entries: BTreeSet<DispatchEntry>,
    pub deferred_fallible: Vec<DeferredFallible>,
    pub deferred_nominal: Vec<DeferredNominal>,
}

impl DispatchTable {
    /// The distinct Swift nominal type names the corpus deferred on, each with how many methods
    /// it cost — the pass log's headline (`Tuple ×2`), so a *new* unbindable Swift type shows up
    /// as a named line rather than a drifting total.
    pub fn nominal_deferral_counts(&self) -> BTreeMap<&str, usize> {
        let mut counts: BTreeMap<&str, usize> = BTreeMap::new();
        for d in &self.deferred_nominal {
            *counts.entry(d.type_name.as_str()).or_default() += 1;
        }
        counts
    }
    /// `(plain, owned, no_wrap, error_out)` counts for the pass log — `owned` counts
    /// every `_o` entry (including `_o_e`), `no_wrap` every `_n` entry (including
    /// `_n_e`), `error_out` every `_e` entry (including `_o_e`/`_n_e`).
    pub fn axis_counts(&self) -> (usize, usize, usize, usize) {
        let owned = self
            .entries
            .iter()
            .filter(|e| e.axis == Some(RetainAxis::Owned))
            .count();
        let no_wrap = self
            .entries
            .iter()
            .filter(|e| e.axis == Some(RetainAxis::NoWrap))
            .count();
        let error = self.entries.iter().filter(|e| e.sig.error_out).count();
        let plain = self
            .entries
            .iter()
            .filter(|e| !e.sig.error_out && matches!(e.axis, None | Some(RetainAxis::FoldRetain)))
            .count();
        (plain, owned, no_wrap, error)
    }
}

/// Collect the global, deduplicated dispatch-entry set across all frameworks — the
/// table [`generate_dispatch_swift`] renders (the racket `collect_global_signatures`
/// precedent). Walks [`bound_methods`] — the *identical* frontier the `.ts`/`.d.ts`
/// emitters walk — so the table and the emitted call sites agree by construction.
pub fn collect_global_entries(frameworks: &[Framework]) -> DispatchTable {
    // The mapper carries the **class** recognition set but no enums, and both halves matter.
    // Enum-awareness only changes *rendered type names* — never admission or the ABI shape — so
    // the collector can omit it. Class-awareness changes **admission** (a method naming a Swift
    // nominal type defers, `class_binding`), so the collector must carry the *identical*
    // whole-program set the emitters do, or the two would walk different frontiers and the
    // mirror invariant would break. One builder ([`declared_classes`]) over the same
    // `ordered_frameworks` the CLI hands both sides.
    let mapper = TsFfiTypeMapper::with_known_classes(declared_classes(frameworks));
    // Whole-program protocol registry, built the same way [`crate::emit_framework`] does — so
    // this table's conformed-protocol required-method flattening ([`bound_methods`]) walks the
    // identical frontier the emitted call sites do (the mirror invariant, `protocol-required-
    // method-flattening-k102`).
    let protocol_registry = ProtocolRegistry::from_frameworks(frameworks);
    let mut table = DispatchTable::default();
    for fw in frameworks {
        for cls in &fw.classes {
            let error_selectors = class_error_selectors(fw.enrichment.as_ref(), &cls.name);
            let (statics, instances) =
                bound_methods(cls, &mapper, &error_selectors, &protocol_registry);
            for m in statics.into_iter().chain(instances) {
                let fallible = is_error_out_method(m, &error_selectors);
                let sig = if fallible {
                    NativeSig::error_out_from_method(m)
                } else {
                    NativeSig::from_method(m)
                }
                .expect("a bound method has a routable dispatch signature");
                // The retain axis, computed by the SAME predicate emit_body renders
                // from ([`method_retain_axis`]) — entry name and wrap primitive cannot
                // disagree (ADR-0057 §4, k70).
                let axis = method_retain_axis(m, &mapper);
                table.entries.insert(DispatchEntry { sig, axis });
            }
            // Honesty counts: methods a frontier deferred (they emit no call site — recorded by
            // reason, never silently dropped). Fallible-flagged ones the error-out channel could
            // not route; and Swift-nominal ones whose `Class{…}` the IR declares nowhere.
            for m in &cls.methods {
                if !m.objc_exposed {
                    continue;
                }
                if is_error_out_method(m, &error_selectors)
                    && !is_supported_method_ctx(m, &mapper, &error_selectors)
                {
                    table.deferred_fallible.push(DeferredFallible {
                        class: cls.name.clone(),
                        selector: m.selector.clone(),
                    });
                }
                if let Some(type_name) = swift_nominal_deferral(m, &mapper) {
                    table.deferred_nominal.push(DeferredNominal {
                        class: cls.name.clone(),
                        selector: m.selector.clone(),
                        type_name: type_name.to_string(),
                    });
                }
            }
        }
    }
    table
}

// ---------------------------------------------------------------------------
// Swift codegen
// ---------------------------------------------------------------------------

/// The `uintptr_t`-packing expression for one visible arg of an `…_e` entry — every
/// shape here is [error-routable](AbiType::is_error_routable) by construction
/// (`error_out_from_method` rejected the rest). Integer args travel bit-pattern in the
/// pointer-width slot; the `awexc.m` cast's callee reads its own width's low bits (the
/// same contract C's integer promotion gives a variadic-free prototype).
fn pack_expr(t: AbiType, idx: usize) -> String {
    match t {
        AbiType::Ptr => format!("napiReadHandle(env, a[{idx}])"),
        AbiType::Bool => format!("UInt(napiGetBool(env, a[{idx}]) ? 1 : 0)"),
        AbiType::Int8 | AbiType::Int16 | AbiType::Int32 | AbiType::Int64 => {
            format!("UInt(bitPattern: Int(napiReadInt64(env, a[{idx}])))")
        }
        AbiType::UInt8 | AbiType::UInt16 | AbiType::UInt32 => {
            format!("UInt(truncatingIfNeeded: napiReadInt64(env, a[{idx}]))")
        }
        AbiType::UInt64 => format!("UInt(napiReadUInt64(env, a[{idx}]))"),
        _ => unreachable!("non-error-routable shape in an error-out signature"),
    }
}

/// The marshalled-primary expression for an `…_e` entry's normal arm (`r.primary` is
/// the raw x0 register as a `UInt`): an object folds per its +0/+1 convention, and a
/// non-object pointer (`_n`) never folds (ADR-0057 §4, k70); a `BOOL` masks the low
/// byte (arm64 leaves upper bits unspecified); an integer scalar re-extends from its
/// width's low bits.
fn primary_expr(t: AbiType, axis: Option<RetainAxis>) -> String {
    match t {
        AbiType::Ptr => {
            if axis == Some(RetainAxis::FoldRetain) {
                "napiMakeHandle(env, objcRetain(r.primary))".to_string()
            } else {
                "napiMakeHandle(env, r.primary)".to_string()
            }
        }
        AbiType::Bool => "napiMakeBool(env, (r.primary & 0xFF) != 0)".to_string(),
        AbiType::Int8 => "napiMakeInt64(env, Int64(Int8(truncatingIfNeeded: r.primary)))".into(),
        AbiType::Int16 => "napiMakeInt64(env, Int64(Int16(truncatingIfNeeded: r.primary)))".into(),
        AbiType::Int32 => "napiMakeInt64(env, Int64(Int32(truncatingIfNeeded: r.primary)))".into(),
        AbiType::Int64 => "napiMakeInt64(env, Int64(bitPattern: UInt64(r.primary)))".into(),
        AbiType::UInt8 => "napiMakeInt64(env, Int64(UInt8(truncatingIfNeeded: r.primary)))".into(),
        AbiType::UInt16 => {
            "napiMakeInt64(env, Int64(UInt16(truncatingIfNeeded: r.primary)))".into()
        }
        AbiType::UInt32 => {
            "napiMakeInt64(env, Int64(UInt32(truncatingIfNeeded: r.primary)))".into()
        }
        AbiType::UInt64 => "napiMakeUInt64(env, UInt64(r.primary))".into(),
        _ => unreachable!("non-error-routable primary in an error-out signature"),
    }
}

/// The one-line doc summary for an entry — the signature in Swift-ABI terms plus the
/// convention notes a reader needs at the entry (fold / owned / error-out).
fn entry_doc(sig: &NativeSig, axis: Option<RetainAxis>) -> String {
    let params: Vec<&str> = sig.params.iter().map(|p| swift_abi_type(*p)).collect();
    let params = if params.is_empty() {
        String::new()
    } else {
        format!(", {}", params.join(", "))
    };
    let ret = swift_abi_type(sig.ret);
    let mut notes = String::new();
    match axis {
        Some(RetainAxis::Owned) => notes.push_str(
            " — +1 owned object return, NO fold (`__wrapOwned` takes the method's own +1, ADR-0057 §4)",
        ),
        Some(RetainAxis::FoldRetain) => {
            notes.push_str(" — +0 object return, retain folded (ADR-0057 §4)");
        }
        Some(RetainAxis::NoWrap) => notes.push_str(
            " — non-object pointer return (`SEL`/`Class`): never wrapped, NO fold (ADR-0057 §4)",
        ),
        None => {}
    }
    if sig.error_out {
        notes.push_str(" — `NSError**` error-out via the `awexc.m` `@catch` (ADR-0058)");
    }
    format!("/// `(id, SEL{params}) -> {ret}`{notes}\n")
}

/// Emit one plain (non-`_e`) entry: read the args by shape, cast `objc_msgSend` to the
/// concrete `@convention(c)` signature, call, marshal the result.
fn emit_plain_entry(s: &mut String, sig: &NativeSig, axis: Option<RetainAxis>) {
    let name = sig.entry_name(axis);
    s.push_str(&entry_doc(sig, axis));
    s.push_str(&format!(
        "private func {name}(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {{\n"
    ));
    s.push_str(&format!(
        "  let a = napiCallbackArgs(env, info, {})\n",
        sig.params.len() + 2
    ));

    let mut conv = vec!["UInt".to_string(), "UInt".to_string()];
    let mut call_args = vec![
        "napiReadHandle(env, a[0])".to_string(),
        "napiReadHandle(env, a[1])".to_string(),
    ];
    for (i, p) in sig.params.iter().enumerate() {
        let idx = i + 2;
        conv.push(swift_abi_type(*p).to_string());
        if *p == AbiType::CStr {
            s.push_str(&cstr_prelude(i, idx));
            call_args.push(cstr_arg_expr(i));
        } else {
            call_args.push(reader_expr(*p, idx));
        }
    }

    let conv_ret = swift_abi_type(sig.ret);
    s.push_str(&format!(
        "  typealias Fn = @convention(c) ({}) -> {conv_ret}\n",
        conv.join(", ")
    ));
    let call = format!(
        "unsafeBitCast(awMsgSendAddr, to: Fn.self)({})",
        call_args.join(", ")
    );
    // The fold rides the axis (ADR-0057 §4): only a +0 object return (`FoldRetain`,
    // the bare name) folds; `_o` (+1 — the method's own retain is the wrapper's) and
    // `_n` (a pointer that is no object — nothing ever wraps or releases it) hand the
    // raw handle through.
    marshal_return(s, sig.ret, &call, axis == Some(RetainAxis::FoldRetain));
    s.push_str("}\n");
}

/// Emit one `…_e` error-out entry: pack the visible args into the `uintptr_t` vector,
/// route through `aw_msgsend_error_catching` (the `awexc.m` `@try`/`@catch` — an
/// `NSException` must never unwind the C ABI into V8), and hand back the runtime's
/// `NativeErrorResult` discriminant (result.ts). The exception + out-param `NSError`
/// come back retained +1 by the shim; only the object *primary*'s fold varies (`_o_e`).
fn emit_error_entry(s: &mut String, sig: &NativeSig, axis: Option<RetainAxis>) {
    let name = sig.entry_name(axis);
    s.push_str(&entry_doc(sig, axis));
    s.push_str(&format!(
        "private func {name}(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {{\n"
    ));
    s.push_str(&format!(
        "  let a = napiCallbackArgs(env, info, {})\n",
        sig.params.len() + 2
    ));
    let packed: Vec<String> = sig
        .params
        .iter()
        .enumerate()
        .map(|(i, p)| pack_expr(*p, i + 2))
        .collect();
    s.push_str(&format!("  let args: [UInt] = [{}]\n", packed.join(", ")));
    s.push_str(&format!(
        "  let r = aw_msgsend_error_catching(napiReadHandle(env, a[0]), napiReadHandle(env, a[1]), args, {})\n",
        sig.params.len()
    ));
    s.push_str("  if r.exception != 0 {\n");
    s.push_str("    return napiMakeThrownResult(env, r.exception, napiTakeReason(r.reason))\n");
    s.push_str("  }\n");
    s.push_str(&format!(
        "  return napiMakeNormalResult(env, {}, r.error)\n",
        primary_expr(sig.ret, axis)
    ));
    s.push_str("}\n");
}

/// Render the whole `Generated/DispatchTable.swift`: the banner, imports, one napi callback
/// per entry (deterministic `BTreeSet` order — regeneration is diff-stable), and the
/// `awRegisterGeneratedDispatch` registration the hand-written
/// `napi_register_module_v1` calls.
pub fn generate_dispatch_swift(table: &DispatchTable) -> String {
    let mut s = String::new();
    s.push_str("// Generated outbound dispatch table for the Node TypeScript target\n");
    s.push_str("// (ADR-0054 §1, the racket ADR-0013 shape). DO NOT EDIT — regenerated by\n");
    s.push_str("// `apianyware-generate` from the IR. One napi callback per distinct\n");
    s.push_str("// ABI-collapsed signature, plus the non-folding `_o` +1 siblings, the\n");
    s.push_str("// non-folding `_n` non-object-pointer siblings (ADR-0057 §4), and the\n");
    s.push_str("// `_e` error-@catch siblings (ADR-0058). Entry\n");
    s.push_str("// names are content-addressed (native_dispatch.rs) — the emitted `.ts`\n");
    s.push_str("// call sites compute the same names with no shared state.\n\n");
    // AppKit re-exports Foundation + CoreGraphics — the by-value geometry struct types
    // the struct-shaped entries cast objc_msgSend to (the racket precedent).
    s.push_str("import AppKit\nimport Foundation\n\n");

    for entry in &table.entries {
        if entry.sig.error_out {
            emit_error_entry(&mut s, &entry.sig, entry.axis);
        } else {
            emit_plain_entry(&mut s, &entry.sig, entry.axis);
        }
        s.push('\n');
    }

    s.push_str("/// Register every generated dispatch entry on the addon's exports object —\n");
    s.push_str("/// called by `napi_register_module_v1` (dispatch.swift).\n");
    s.push_str("func awRegisterGeneratedDispatch(_ env: napi_env?, _ exports: napi_value?) {\n");
    for entry in &table.entries {
        let name = entry.name();
        s.push_str(&format!("  napiDefine(env, exports, \"{name}\", {name})\n"));
    }
    s.push_str("}\n\n");

    let (plain, owned, no_wrap, error) = table.axis_counts();
    s.push_str(&format!(
        "// {} generated dispatch entr{}: {plain} plain, {owned} owned (`_o`), {no_wrap} no-wrap (`_n`), {error} error-out (`_e`).\n",
        table.entries.len(),
        if table.entries.len() == 1 { "y" } else { "ies" }
    ));
    s
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::class_graph::ClassRegistry;
    use crate::emit_framework::emit_framework;
    use crate::enum_graph::EnumRegistry;
    use crate::native_dispatch::GeoStruct;
    use crate::protocol_graph::ProtocolRegistry;
    use apianyware_types::enrichment::{ClassSelectorEntry, EnrichmentData};
    use apianyware_types::ir::{Class, Framework, Method, Param};
    use apianyware_types::provenance::DeclarationSource;
    use apianyware_types::type_ref::{TypeRef, TypeRefKind};

    fn ty(kind: TypeRefKind) -> TypeRef {
        TypeRef {
            nullable: false,
            kind,
        }
    }

    fn param(kind: TypeRefKind) -> Param {
        Param {
            name: "x".into(),
            param_type: ty(kind),
        }
    }

    fn method(selector: &str, class_method: bool, params: Vec<Param>, ret: TypeRef) -> Method {
        Method {
            selector: selector.into(),
            class_method,
            init_method: selector.starts_with("init"),
            params,
            return_type: ret,
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

    fn class(name: &str, methods: Vec<Method>) -> Class {
        Class {
            name: name.into(),
            superclass: "NSObject".into(),
            protocols: vec![],
            properties: vec![],
            methods,
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
            swift_name: None,
        }
    }

    fn framework(name: &str, classes: Vec<Class>) -> Framework {
        Framework {
            format_version: "1.0".into(),
            checkpoint: "resolved".into(),
            name: name.into(),
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

    /// Flag `selector` on `class_name` as an NSError out-param selector — the
    /// `convenience_error_methods` enrichment relation `class_error_selectors` reads.
    fn with_error_selector(fw: &mut Framework, class_name: &str, selector: &str) {
        let entry = ClassSelectorEntry {
            class: class_name.into(),
            selector: selector.into(),
        };
        fw.enrichment
            .get_or_insert_with(EnrichmentData::default)
            .convenience_error_methods
            .push(entry);
    }

    /// Every `aw_ts_msg_*` token referenced in `text` (the emitted call sites). The
    /// bare prefix from the emitted header comment (`aw_ts_msg_<codes>`) is skipped —
    /// it is documentation, not a call site.
    fn referenced_entries(text: &str) -> BTreeSet<String> {
        let mut out = BTreeSet::new();
        let mut rest = text;
        while let Some(pos) = rest.find("aw_ts_msg_") {
            let tail = &rest[pos..];
            let end = tail
                .find(|c: char| !c.is_ascii_alphanumeric() && c != '_')
                .unwrap_or(tail.len());
            if end > "aw_ts_msg_".len() {
                out.insert(tail[..end].to_string());
            }
            rest = &rest[pos + end..];
        }
        out
    }

    /// The fixture: a framework exercising the plain / owned / error-out / struct /
    /// scalar axes at once.
    fn fixture() -> Framework {
        let widget = class(
            "TKWidget",
            vec![
                // () -> NSUInteger : plain scalar. `0_Q`.
                method(
                    "length",
                    false,
                    vec![],
                    ty(TypeRefKind::Primitive {
                        name: "NSUInteger".into(),
                    }),
                ),
                // (id) -> id +0 : `P_P`.
                method(
                    "widgetWithName:",
                    true,
                    vec![param(TypeRefKind::Id {
                        protocols: Vec::new(),
                    })],
                    ty(TypeRefKind::Id {
                        protocols: Vec::new(),
                    }),
                ),
                // init… (id) -> instancetype +1 : `P_P_o`.
                method(
                    "initWithName:",
                    false,
                    vec![param(TypeRefKind::Id {
                        protocols: Vec::new(),
                    })],
                    ty(TypeRefKind::Instancetype),
                ),
                // () -> CGRect : struct return. `0_R`.
                method(
                    "frame",
                    false,
                    vec![],
                    ty(TypeRefKind::Struct {
                        name: "CGRect".into(),
                    }),
                ),
                // (CGRect) -> void : struct param. `R_v`.
                method(
                    "setFrame:",
                    false,
                    vec![param(TypeRefKind::Struct {
                        name: "CGRect".into(),
                    })],
                    TypeRef::void(),
                ),
                // (NSString, NSError**) -> BOOL : error-out scalar primary. `P_b_e`.
                method(
                    "writeToFile:error:",
                    false,
                    vec![
                        param(TypeRefKind::Id {
                            protocols: Vec::new(),
                        }),
                        param(TypeRefKind::Pointer),
                    ],
                    ty(TypeRefKind::Primitive {
                        name: "bool".into(),
                    }),
                ),
                // () -> SEL : pointer-shaped but NOT an object — never wrapped, never
                // folded (`objc_retain` on a SEL is UB). `0_P_n` (k70).
                method("action", false, vec![], ty(TypeRefKind::Selector)),
                // (id) -> Class : same non-object pointer convention — retaining a
                // class leaks. `P_P_n` (k70).
                method(
                    "classForName:",
                    true,
                    vec![param(TypeRefKind::Id {
                        protocols: Vec::new(),
                    })],
                    ty(TypeRefKind::ClassRef),
                ),
                // fallible with a double visible arg — deferred (not routable via awexc).
                method(
                    "setLevel:error:",
                    false,
                    vec![
                        param(TypeRefKind::Primitive {
                            name: "double".into(),
                        }),
                        param(TypeRefKind::Pointer),
                    ],
                    ty(TypeRefKind::Primitive {
                        name: "bool".into(),
                    }),
                ),
            ],
        );
        let mut fw = framework("TestKit", vec![widget]);
        with_error_selector(&mut fw, "TKWidget", "writeToFile:error:");
        with_error_selector(&mut fw, "TKWidget", "setLevel:error:");
        fw
    }

    /// [`fixture`] plus the real-corpus **Swift-nominal** shape: a `.swiftinterface`-sourced
    /// method returning `Class{Tuple}` — a Swift tuple, which the IR spells exactly like an object
    /// (`NEPacketTunnelFlow.readPackets()`). Its ABI signature is `0_P`, indistinguishable from a
    /// plain object return, so *only* the k66 frontier keeps it out.
    fn fixture_with_swift_nominal() -> Framework {
        let mut fw = fixture();
        let mut readpackets = method(
            "readPackets",
            false,
            vec![],
            ty(TypeRefKind::Class {
                name: "Tuple".into(),
                framework: None,
                params: vec![],
            }),
        );
        readpackets.source = Some(DeclarationSource::SwiftInterface);
        fw.classes[0].methods.push(readpackets);
        fw
    }

    #[test]
    fn collection_mirrors_the_emitted_call_sites_exactly() {
        // The agreement invariant: the entry set the collection computes == the entry
        // names the rendered `.ts` bodies reference. Render the fixture through the
        // real orchestrator and extract every `aw_ts_msg_*` token.
        let fw = fixture();
        let dir = tempfile::tempdir().unwrap();
        emit_framework(
            &fw,
            dir.path(),
            &ClassRegistry::default(),
            &EnumRegistry::default(),
            &ProtocolRegistry::default(),
            &BTreeSet::new(),
        )
        .unwrap();

        let mut referenced = BTreeSet::new();
        for entry in std::fs::read_dir(dir.path().join("testkit")).unwrap() {
            let path = entry.unwrap().path();
            if path.extension().is_some_and(|e| e == "ts") {
                referenced.extend(referenced_entries(&std::fs::read_to_string(&path).unwrap()));
            }
        }

        let table = collect_global_entries(std::slice::from_ref(&fw));
        let collected: BTreeSet<String> = table.entries.iter().map(|e| e.name()).collect();
        assert_eq!(collected, referenced);
        // The known shape of the fixture, spelled out for the reader.
        assert_eq!(
            collected,
            [
                "aw_ts_msg_0_Q",
                "aw_ts_msg_P_P",
                "aw_ts_msg_P_P_o",
                // A non-object pointer return (`SEL`/`Class`) routes to the `_n`
                // no-wrap sibling, never the folding bare entry (k70, ADR-0057 §4).
                "aw_ts_msg_0_P_n",
                "aw_ts_msg_P_P_n",
                "aw_ts_msg_0_R",
                "aw_ts_msg_R_v",
                "aw_ts_msg_P_b_e",
            ]
            .into_iter()
            .map(String::from)
            .collect()
        );
        // The double-arg fallible method was deferred AND recorded (never silent).
        assert_eq!(table.deferred_fallible.len(), 1);
        assert_eq!(table.deferred_fallible[0].selector, "setLevel:error:");
    }

    #[test]
    fn a_swift_nominal_method_leaves_the_mirror_intact_and_is_counted() {
        // The k66 frontier, checked against the invariant it could most easily break. A method
        // returning `Class{Tuple}` collapses to ABI `0_P` — *identical* to a plain object return —
        // so if the collector and the emitters disagreed about admitting it, one side would name
        // an `aw_ts_msg_0_P` entry the other never produced. Both must defer it, and the entry set
        // must be exactly what the fixture without it produces.
        let plain = collect_global_entries(std::slice::from_ref(&fixture()));
        let fw = fixture_with_swift_nominal();
        let table = collect_global_entries(std::slice::from_ref(&fw));

        // The table is unchanged: the deferred method contributed no entry.
        assert_eq!(table.entries, plain.entries);

        // …and the emitted `.ts` references nothing extra either (the mirror, re-checked).
        let dir = tempfile::tempdir().unwrap();
        emit_framework(
            &fw,
            dir.path(),
            &ClassRegistry::default(),
            &EnumRegistry::default(),
            &ProtocolRegistry::default(),
            &BTreeSet::new(),
        )
        .unwrap();
        let mut referenced = BTreeSet::new();
        for entry in std::fs::read_dir(dir.path().join("testkit")).unwrap() {
            let path = entry.unwrap().path();
            if path.extension().is_some_and(|e| e == "ts") {
                let src = std::fs::read_to_string(&path).unwrap();
                assert!(
                    !src.contains("Tuple") && !src.contains("readPackets"),
                    "a Swift nominal type must not reach the emitted surface:\n{src}"
                );
                referenced.extend(referenced_entries(&src));
            }
        }
        let collected: BTreeSet<String> = table.entries.iter().map(|e| e.name()).collect();
        assert_eq!(collected, referenced);

        // Deferred, but NOT silently: recorded with owner, selector and the offending type name.
        assert_eq!(table.deferred_nominal.len(), 1);
        assert_eq!(table.deferred_nominal[0].class, "TKWidget");
        assert_eq!(table.deferred_nominal[0].selector, "readPackets");
        assert_eq!(table.deferred_nominal[0].type_name, "Tuple");
        assert_eq!(table.nominal_deferral_counts(), [("Tuple", 1)].into());
    }

    #[test]
    fn plain_scalar_entry_renders_the_hand_written_shape() {
        // (id, SEL, NSInteger) -> void — must match the retired hand-written
        // aw_ts_msg_q_v byte-for-byte in the load-bearing lines.
        let sig = NativeSig {
            params: vec![AbiType::Int64],
            ret: AbiType::Void,
            error_out: false,
        };
        let mut s = String::new();
        emit_plain_entry(&mut s, &sig, None);
        assert!(
            s.contains("private func aw_ts_msg_q_v(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {"),
            "{s}"
        );
        assert!(s.contains("let a = napiCallbackArgs(env, info, 3)"), "{s}");
        assert!(
            s.contains("typealias Fn = @convention(c) (UInt, UInt, Int64) -> Void"),
            "{s}"
        );
        assert!(
            s.contains("unsafeBitCast(awMsgSendAddr, to: Fn.self)(napiReadHandle(env, a[0]), napiReadHandle(env, a[1]), napiReadInt64(env, a[2]))"),
            "{s}"
        );
        assert!(s.contains("return napiUndefined(env)"), "{s}");
    }

    #[test]
    fn owned_sibling_skips_the_fold_plain_folds() {
        let sig = NativeSig {
            params: vec![],
            ret: AbiType::Ptr,
            error_out: false,
        };
        let mut plain = String::new();
        emit_plain_entry(&mut plain, &sig, Some(RetainAxis::FoldRetain));
        assert!(
            plain.contains("return napiMakeHandle(env, objcRetain(r))"),
            "{plain}"
        );
        let mut owned = String::new();
        emit_plain_entry(&mut owned, &sig, Some(RetainAxis::Owned));
        assert!(owned.contains("func aw_ts_msg_0_P_o("), "{owned}");
        assert!(owned.contains("return napiMakeHandle(env, r)"), "{owned}");
        assert!(!owned.contains("objcRetain"), "{owned}");
    }

    #[test]
    fn no_wrap_sibling_neither_folds_nor_shares_the_folding_name() {
        // A non-object pointer return (`SEL`/`Class`) renders the `_n` entry: the raw
        // handle passes through — `objc_retain` on a SEL is UB, a retained class leaks
        // (k70, ADR-0057 §4). Distinct name, so it never shares the folding bare entry.
        let sig = NativeSig {
            params: vec![],
            ret: AbiType::Ptr,
            error_out: false,
        };
        let mut s = String::new();
        emit_plain_entry(&mut s, &sig, Some(RetainAxis::NoWrap));
        assert!(s.contains("func aw_ts_msg_0_P_n("), "{s}");
        assert!(s.contains("return napiMakeHandle(env, r)"), "{s}");
        assert!(!s.contains("objcRetain"), "{s}");
        assert!(
            s.contains("non-object pointer return (`SEL`/`Class`): never wrapped, NO fold"),
            "{s}"
        );
        // The `_n_e` fallible sibling: the primary passes through unfolded too.
        let sig_e = NativeSig {
            params: vec![],
            ret: AbiType::Ptr,
            error_out: true,
        };
        let mut e = String::new();
        emit_error_entry(&mut e, &sig_e, Some(RetainAxis::NoWrap));
        assert!(e.contains("func aw_ts_msg_0_P_n_e("), "{e}");
        assert!(
            e.contains("napiMakeNormalResult(env, napiMakeHandle(env, r.primary), r.error)"),
            "{e}"
        );
        assert!(!e.contains("objcRetain"), "{e}");
    }

    #[test]
    fn struct_return_and_param_route_through_the_geo_helpers() {
        // (CGRect) -> NSRange : struct arg reads via napiReadRect, struct result
        // marshals via napiMakeRange.
        let sig = NativeSig {
            params: vec![AbiType::Struct(GeoStruct::CGRect)],
            ret: AbiType::Struct(GeoStruct::NSRange),
            error_out: false,
        };
        let mut s = String::new();
        emit_plain_entry(&mut s, &sig, None);
        assert!(
            s.contains("typealias Fn = @convention(c) (UInt, UInt, CGRect) -> NSRange"),
            "{s}"
        );
        assert!(s.contains("napiReadRect(env, a[2])"), "{s}");
        assert!(s.contains("return napiMakeRange(env, r)"), "{s}");
    }

    #[test]
    fn cstring_arg_strdups_and_frees_across_the_call() {
        let sig = NativeSig {
            params: vec![AbiType::CStr],
            ret: AbiType::Ptr,
            error_out: false,
        };
        let mut s = String::new();
        emit_plain_entry(&mut s, &sig, Some(RetainAxis::FoldRetain));
        assert!(
            s.contains("let s0 = strdup(napiReadString(env, a[2]) ?? \"\")"),
            "{s}"
        );
        assert!(s.contains("defer { free(s0) }"), "{s}");
        assert!(
            s.contains("typealias Fn = @convention(c) (UInt, UInt, UnsafePointer<CChar>?) -> UInt"),
            "{s}"
        );
        assert!(s.contains("UnsafePointer(s0)"), "{s}");
    }

    #[test]
    fn error_entry_renders_the_hand_written_shape() {
        // (id, SEL, id) -> BOOL error-out — must match the retired hand-written
        // aw_ts_msg_P_b_e in the load-bearing lines.
        let sig = NativeSig {
            params: vec![AbiType::Ptr],
            ret: AbiType::Bool,
            error_out: true,
        };
        let mut s = String::new();
        emit_error_entry(&mut s, &sig, None);
        assert!(s.contains("func aw_ts_msg_P_b_e("), "{s}");
        assert!(
            s.contains("let args: [UInt] = [napiReadHandle(env, a[2])]"),
            "{s}"
        );
        assert!(
            s.contains(
                "let r = aw_msgsend_error_catching(napiReadHandle(env, a[0]), napiReadHandle(env, a[1]), args, 1)"
            ),
            "{s}"
        );
        assert!(
            s.contains("return napiMakeThrownResult(env, r.exception, napiTakeReason(r.reason))"),
            "{s}"
        );
        assert!(
            s.contains(
                "return napiMakeNormalResult(env, napiMakeBool(env, (r.primary & 0xFF) != 0), r.error)"
            ),
            "{s}"
        );
    }

    #[test]
    fn owned_error_entry_skips_the_primary_fold() {
        let sig = NativeSig {
            params: vec![AbiType::Ptr],
            ret: AbiType::Ptr,
            error_out: true,
        };
        let mut owned = String::new();
        emit_error_entry(&mut owned, &sig, Some(RetainAxis::Owned));
        assert!(owned.contains("func aw_ts_msg_P_P_o_e("), "{owned}");
        assert!(
            owned.contains("napiMakeNormalResult(env, napiMakeHandle(env, r.primary), r.error)"),
            "{owned}"
        );
        let mut plain = String::new();
        emit_error_entry(&mut plain, &sig, Some(RetainAxis::FoldRetain));
        assert!(
            plain.contains(
                "napiMakeNormalResult(env, napiMakeHandle(env, objcRetain(r.primary)), r.error)"
            ),
            "{plain}"
        );
    }

    #[test]
    fn generated_file_registers_every_entry_and_reports_counts() {
        let table = collect_global_entries(&[fixture()]);
        let out = generate_dispatch_swift(&table);
        assert!(out.contains("import AppKit"), "{out}");
        assert!(
            out.contains(
                "func awRegisterGeneratedDispatch(_ env: napi_env?, _ exports: napi_value?) {"
            ),
            "{out}"
        );
        for entry in &table.entries {
            let name = entry.name();
            assert!(
                out.contains(&format!("napiDefine(env, exports, \"{name}\", {name})")),
                "missing registration for {name}"
            );
        }
        assert!(
            out.contains("// 8 generated dispatch entries: 4 plain, 1 owned (`_o`), 2 no-wrap (`_n`), 1 error-out (`_e`)."),
            "{out}"
        );
    }
}
