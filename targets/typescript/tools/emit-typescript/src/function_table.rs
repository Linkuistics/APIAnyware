//! The **generated free-function table** (`fn-table-codegen-k69`, realising ADR-0054 §1a at
//! corpus scale) — the plain-C / ObjC-exposed free functions the emitted `.ts` dispatches
//! **directly** by symbol, the trampoline-elided limit of ADR-0025.
//!
//! The free-function sibling of [`crate::dispatch_table`], and the one entry family whose
//! **exports and Swift bodies are keyed on different axes**. An ObjC method multiplexes through
//! one `objc_msgSend` address selected by selector, so the whole corpus folds into 998
//! signature-keyed `aw_ts_msg_*` entries. A C function is called **by its own address**, so its
//! exports cannot fold — 2192 symbols means 2192 exports, a floor. Its *bodies*, though, differ
//! only by ABI signature: 317 of them.
//!
//! The join is `napi_create_function`'s **`data` payload**. One shared per-signature callback
//! (`aw_ts_fnsig_<codes>` — a private Swift name, never a JS export key) is registered once per
//! symbol, each registration carrying that symbol's [`AwFnDesc`] descriptor. The callback reads
//! the descriptor back through `napi_get_cb_info` and casts the lazily-resolved address to the
//! `@convention(c)` shape it was generated for. Exports keys stay `aw_ts_fn_<symbol>`
//! ([`function_entry_name`]), so the emitted `.ts` call sites — and the mirror invariant — are
//! untouched.
//!
//! ## The mirror invariant, in its strong form
//!
//! Unlike the inbound tables, the `.ts` **names** these entries, so [`collect_function_entries`]
//! can be checked against the rendered call sites exactly. It applies the *same* admission
//! predicate the emitter does ([`is_bound_direct_c`]) over the same `objc_exposed` stream, so
//! *collected == referenced* by construction. Racket's rule carries over: err toward
//! **over-collection** — a dead export is harmless, a missing one is a runtime `TypeError`.
//!
//! ## The retain axis rides the descriptor, not the entry name
//!
//! A C function's object return follows the CF **Create Rule**
//! ([`function_returns_retained`]): `Create`/`Copy` → +1 owned (`__wrapOwned`), else +0
//! autoreleased (`__wrapRetained`). Under uniform-+1 (ADR-0057 §4) the +0 case **must fold an
//! `objcRetain`** in the native entry — `__wrapRetained` does not retain; it takes a handle whose
//! entry already folded (see its doc, and the sibling `aw_ts_const_P`).
//!
//! That decision is **per symbol** where the outbound table's is per signature, so it cannot ride
//! the entry name (which is the symbol) nor the body name (which is the signature): it rides the
//! **descriptor**, as `AwFnDesc`'s `retains` flag, and the shared body branches on it. Two
//! consequences worth stating:
//!
//! - There is **no `…_o` sibling entry** here. The `_o` axis exists outbound only because one
//!   entry name serves many symbols; here the export *is* the symbol.
//! - The fold is gated on the return being a **real object** (`is_object_type`), not on its ABI
//!   being `Ptr`. `NSClassFromString` returns a `Class` — ABI-`Ptr`, never wrapped `.ts`-side —
//!   so it folds nothing. (The outbound table realises the same rule through its entry-name
//!   suffix: the non-folding `_n` sibling, `crate::native_dispatch::RetainAxis`.)

use std::collections::{BTreeMap, BTreeSet};

use apianyware_emit::ffi_type_mapping::FfiTypeMapper;
use apianyware_types::ir::Framework;

use crate::class_graph::declared_classes;
use crate::emit_functions::{function_returns_retained, is_bound_direct_c};
use crate::ffi_type_mapping::TsFfiTypeMapper;
use crate::native_dispatch::{function_entry_name, AbiType, NativeSig};
use crate::swift_abi::{cstr_arg_expr, cstr_prelude, marshal_return, reader_expr, swift_abi_type};

/// IR "frameworks" that are **not** loadable `.framework` bundles, so the resolver must not try
/// to `dlopen` a canonical bundle path for them. A closed set with a stated reason, in the shape
/// of [`crate::ffi_type_mapping::pod_struct_type`]'s curated population — never a heuristic.
///
/// Exactly one member today: **`libdispatch`**, which lives in libSystem and is therefore always
/// loaded (62 symbols). Marking it unbundled keeps a genuine "no such symbol" miss from being
/// misreported as a missing image. The other 72 contributing frameworks all `dlopen` from
/// `/System/Library/Frameworks/<N>.framework/<N>` — including `Ruby` and `Tcl`, whose binaries
/// exist only in the dyld shared cache, so `stat` denies a path `dlopen` opens happily.
const UNBUNDLED_FRAMEWORKS: &[&str] = &["libdispatch"];

fn is_bundled_framework(name: &str) -> bool {
    !UNBUNDLED_FRAMEWORKS.contains(&name)
}

/// One generated free-function entry: the C symbol, its owning framework, the ABI signature its
/// shared body was generated for, and whether that body folds an `objcRetain` into the return.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct FunctionEntry {
    /// The C symbol name — also the export key's tail (`aw_ts_fn_<symbol>`).
    pub symbol: String,
    /// The framework that declares it; the resolver's `dlopen` target and failure diagnostic.
    pub framework: String,
    /// The signature the shared `aw_ts_fnsig_<codes>` body casts the resolved address to.
    pub sig: NativeSig,
    /// Whether the entry folds an `objcRetain` — true iff the return is a **+0 object**
    /// (ADR-0057 §4; see the module docs on why this is not `sig.ret == Ptr`).
    pub fold_retain: bool,
}

impl FunctionEntry {
    /// The exported name the emitted `.ts` call site computed — `aw_ts_fn_<symbol>`.
    pub fn entry_name(&self) -> String {
        function_entry_name(&self.symbol)
    }

    /// The **private Swift** body this entry registers against — `aw_ts_fnsig_<param-codes>_<ret>`,
    /// shared by every symbol of the same ABI signature. Never crosses to JS.
    pub fn body_name(&self) -> String {
        format!("aw_ts_fnsig_{}", self.sig.sig_code())
    }
}

/// A symbol declared by more than one framework — one C symbol, so the per-symbol export key
/// dedupes it, but the collector walks per framework and must say so.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct DuplicateSymbol {
    pub symbol: String,
    /// The framework that declared it first (whose descriptor is kept).
    pub kept: String,
    /// The framework whose duplicate declaration was dropped.
    pub dropped: String,
}

/// The whole-corpus free-function table: the deduplicated per-symbol entry set (ordered by
/// symbol, so regeneration is byte-stable) plus the recorded duplicate declarations.
#[derive(Debug, Clone, Default)]
pub struct FunctionTable {
    /// Keyed by C symbol — the dedupe, and the deterministic render order.
    pub entries: BTreeMap<String, FunctionEntry>,
    pub duplicates: Vec<DuplicateSymbol>,
}

impl FunctionTable {
    /// The distinct ABI signatures across the table — the number of Swift bodies rendered.
    pub fn signatures(&self) -> BTreeSet<NativeSig> {
        self.entries.values().map(|e| e.sig.clone()).collect()
    }

    /// Per-framework entry counts for the pass log, ordered by framework name.
    pub fn framework_counts(&self) -> BTreeMap<&str, usize> {
        let mut counts: BTreeMap<&str, usize> = BTreeMap::new();
        for e in self.entries.values() {
            *counts.entry(e.framework.as_str()).or_default() += 1;
        }
        counts
    }

    /// The frameworks marked unbundled in this table (the `dlopen`-less set) — logged so the
    /// closed [`UNBUNDLED_FRAMEWORKS`] set is visible in the pass output, never silent.
    pub fn unbundled(&self) -> BTreeSet<&str> {
        self.entries
            .values()
            .map(|e| e.framework.as_str())
            .filter(|f| !is_bundled_framework(f))
            .collect()
    }
}

/// Collect the global, symbol-deduplicated free-function entry set across all frameworks — the
/// table [`generate_function_table_swift`] renders.
///
/// Walks the `objc_exposed` stream through [`is_bound_direct_c`], the *identical* admission
/// predicate [`crate::emit_functions`]'s `bound_functions` applies, so the table and the emitted
/// call sites agree by construction. The Swift-native (`objc_exposed == false`) residual is a
/// different mechanism entirely — [`crate::trampoline`]'s `aw_ts_swift_*` call-by-name
/// trampolines (ADR-0061) — and is skipped here.
pub fn collect_function_entries(frameworks: &[Framework]) -> FunctionTable {
    // The class recognition set is **admission-relevant** (a method naming a Swift nominal type
    // defers, `class_binding`), so the collector must carry the *identical* whole-program set the
    // emitters do or the two would walk different frontiers and break the mirror invariant. Enums
    // are not: they only change rendered type names, never admission or the ABI shape.
    let mapper = TsFfiTypeMapper::with_known_classes(declared_classes(frameworks));
    let mut table = FunctionTable::default();
    for fw in frameworks {
        for func in &fw.functions {
            if !func.objc_exposed || !is_bound_direct_c(func, &mapper) {
                continue;
            }
            let sig = NativeSig::from_function(func)
                .expect("is_bound_direct_c closes on NativeSig::from_function");
            // The fold gate is the wrap boundary, not the ABI shape: only a return the `.ts`
            // wraps (`is_object_type`) may be retained, and only at +0 (ADR-0057 §4).
            let fold_retain =
                mapper.is_object_type(&func.return_type) && !function_returns_retained(func);
            let entry = FunctionEntry {
                symbol: func.name.clone(),
                framework: fw.name.clone(),
                sig,
                fold_retain,
            };
            match table.entries.get(&func.name) {
                Some(kept) => table.duplicates.push(DuplicateSymbol {
                    symbol: func.name.clone(),
                    kept: kept.framework.clone(),
                    dropped: fw.name.clone(),
                }),
                None => {
                    table.entries.insert(func.name.clone(), entry);
                }
            }
        }
    }
    table
}

// ---------------------------------------------------------------------------
// Swift codegen
// ---------------------------------------------------------------------------

/// The one-line doc summary for a shared body — its signature in Swift-ABI terms.
fn body_doc(sig: &NativeSig) -> String {
    let params: Vec<&str> = sig.params.iter().map(|p| swift_abi_type(*p)).collect();
    format!(
        "/// `({}) -> {}` — shared by every symbol of this ABI signature.\n",
        params.join(", "),
        swift_abi_type(sig.ret)
    )
}

/// Emit one shared per-signature body: resolve the address from the `data` descriptor (lazily,
/// on first call — [`awResolveFn`](../../../../bindings/node/native/src/fn_resolve.swift)), read
/// the args by shape, cast to the concrete `@convention(c)` signature, call, marshal back.
///
/// A `Ptr` return branches on the descriptor's `retains` flag, because the fold is a per-symbol
/// fact (the CF Create Rule) while the body is per-signature. Every other shape is fold-free, so
/// the branch is generated only where it can fire.
fn emit_body(s: &mut String, sig: &NativeSig) {
    let name = format!("aw_ts_fnsig_{}", sig.sig_code());
    s.push_str(&body_doc(sig));
    s.push_str(&format!(
        "private func {name}(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {{\n"
    ));
    // A zero-arg body still calls napiCallbackArgsData (it yields the `data` payload), but
    // binding an unused `a` would trip swiftc's unused-value warning in the addon build.
    let bind = if sig.params.is_empty() { "_" } else { "a" };
    s.push_str(&format!(
        "  let ({bind}, data) = napiCallbackArgsData(env, info, {})\n",
        sig.params.len()
    ));
    s.push_str("  guard let fn = awResolveFn(env, data) else { return nil }\n");

    let mut conv = Vec::with_capacity(sig.params.len());
    let mut call_args = Vec::with_capacity(sig.params.len());
    for (i, p) in sig.params.iter().enumerate() {
        conv.push(swift_abi_type(*p).to_string());
        if *p == AbiType::CStr {
            s.push_str(&cstr_prelude(i, i));
            call_args.push(cstr_arg_expr(i));
        } else {
            call_args.push(reader_expr(*p, i));
        }
    }

    s.push_str(&format!(
        "  typealias Fn = @convention(c) ({}) -> {}\n",
        conv.join(", "),
        swift_abi_type(sig.ret)
    ));
    let call = format!("unsafeBitCast(fn, to: Fn.self)({})", call_args.join(", "));

    if sig.ret == AbiType::Ptr {
        // The +0/+1 split is per symbol, so it is read from the descriptor at call time rather
        // than baked into this shared body (ADR-0057 §4; module docs).
        s.push_str(&format!("  let r = {call}\n"));
        s.push_str("  return napiMakeHandle(env, awFnFoldRetain(data, r))\n");
    } else {
        marshal_return(s, sig.ret, &call, false);
    }
    s.push_str("}\n");
}

/// Render one symbol's descriptor literal — `AwFnDesc("hypot", "CoreGraphics")`, with the
/// `bundled` / `retains` flags spelled only when they leave their defaults.
fn desc_literal(e: &FunctionEntry) -> String {
    let bundled = is_bundled_framework(&e.framework);
    match (bundled, e.fold_retain) {
        (true, false) => format!("AwFnDesc(\"{}\", \"{}\")", e.symbol, e.framework),
        _ => format!(
            "AwFnDesc(\"{}\", \"{}\", bundled: {bundled}, retains: {})",
            e.symbol, e.framework, e.fold_retain
        ),
    }
}

/// Render the whole `Generated/FunctionTable.swift`: the banner, one shared napi callback per
/// distinct ABI signature, the per-symbol descriptor array, and the `awRegisterGeneratedFunctions`
/// registration the hand-written `napi_register_module_v1` calls.
///
/// Bodies render in `BTreeSet<NativeSig>` order and descriptors in `BTreeMap` symbol order, both
/// pure functions of the input artifacts — regeneration is byte-stable.
pub fn generate_function_table_swift(table: &FunctionTable) -> String {
    let mut s = String::new();
    s.push_str("// Generated plain-C free-function table for the Node TypeScript target\n");
    s.push_str("// (ADR-0054 §1a, ADR-0025's trampoline-elided limit for a named C export).\n");
    s.push_str("// DO NOT EDIT — regenerated by `apianyware-generate` from the IR.\n");
    s.push_str("//\n");
    s.push_str("// Per-symbol exports (`aw_ts_fn_<symbol>`, native_dispatch.rs's\n");
    s.push_str("// `function_entry_name` — the names the emitted `.ts` calls) over shared\n");
    s.push_str(
        "// per-signature bodies (`aw_ts_fnsig_<codes>`, private to this file), joined by\n",
    );
    s.push_str("// `napi_create_function`'s `data` payload: the symbol's AwFnDesc descriptor.\n");
    s.push_str("// Addresses resolve lazily on first call and are cached (fn_resolve.swift).\n\n");
    // AppKit re-exports Foundation + CoreGraphics — the by-value geometry struct types the
    // struct-shaped bodies cast to (the DispatchTable.swift precedent).
    s.push_str("import AppKit\nimport Foundation\n\n");

    for sig in &table.signatures() {
        emit_body(&mut s, sig);
        s.push('\n');
    }

    s.push_str("/// One descriptor per exported symbol, in the order the registration indexes\n");
    s.push_str("/// them. Heap-allocated: `napi_create_function` keeps the raw pointer, and a\n");
    s.push_str("/// Swift Array's buffer is not address-stable (fn_resolve.swift).\n");
    s.push_str("private let awFnEntries = awMakeFnEntries([\n");
    for e in table.entries.values() {
        s.push_str(&format!("  {},\n", desc_literal(e)));
    }
    s.push_str("])\n\n");

    s.push_str(
        "/// Register every generated free-function entry on the addon's exports object —\n",
    );
    s.push_str("/// called by `napi_register_module_v1` (dispatch.swift).\n");
    s.push_str("func awRegisterGeneratedFunctions(_ env: napi_env?, _ exports: napi_value?) {\n");
    for (i, e) in table.entries.values().enumerate() {
        s.push_str(&format!(
            "  napiDefineWithData(env, exports, \"{}\", {}, awFnEntries.advanced(by: {i}))\n",
            e.entry_name(),
            e.body_name()
        ));
    }
    s.push_str("}\n\n");

    let entries = table.entries.len();
    let sigs = table.signatures().len();
    let folded = table.entries.values().filter(|e| e.fold_retain).count();
    s.push_str(&format!(
        "// {entries} per-symbol entries over {sigs} shared per-signature bodies; {folded} fold a\n\
         // +0 object return's retain (ADR-0057 §4). Frameworks: {}.\n",
        table.framework_counts().len()
    ));
    let unbundled: Vec<&str> = table.unbundled().into_iter().collect();
    s.push_str(&format!(
        "// Unbundled (no dlopen — always-loaded, not a .framework): {}.\n",
        if unbundled.is_empty() {
            "none".to_string()
        } else {
            unbundled.join(", ")
        }
    ));
    if !table.duplicates.is_empty() {
        let dups: Vec<String> = table
            .duplicates
            .iter()
            .map(|d| format!("{} ({} kept, {} dropped)", d.symbol, d.kept, d.dropped))
            .collect();
        s.push_str(&format!(
            "// Declared by two frameworks, deduped by symbol: {}.\n",
            dups.join("; ")
        ));
    }
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
    use apianyware_types::ir::{Class, Function, Param};
    use apianyware_types::type_ref::{TypeRef, TypeRefKind};

    fn ty(kind: TypeRefKind) -> TypeRef {
        TypeRef {
            nullable: false,
            kind,
        }
    }

    fn param(name: &str, kind: TypeRefKind) -> Param {
        Param {
            name: name.into(),
            param_type: ty(kind),
        }
    }

    fn function(name: &str, params: Vec<Param>, ret: TypeRef) -> Function {
        Function {
            name: name.into(),
            params,
            return_type: ret,
            inline: false,
            variadic: false,
            source: None,
            provenance: None,
            doc_refs: None,
            objc_exposed: true,
            swift_fn: None,
        }
    }

    /// A framework declaring `TKWidget` — the class the object-returning fixtures name. A
    /// framework whose C function returns `TKWidget *` **declares** `TKWidget`, so the
    /// whole-program recognition set contains it and the reference binds; a `Class{name}` the IR
    /// declares nowhere is not an object type the emitter can bind (`class_binding`, k66).
    fn framework(name: &str, functions: Vec<Function>) -> Framework {
        Framework {
            format_version: "1.0".into(),
            checkpoint: "resolved".into(),
            name: name.into(),
            sdk_version: None,
            collected_at: None,
            depends_on: vec![],
            skipped_symbols: vec![],
            classes: vec![Class {
                name: "TKWidget".into(),
                superclass: "NSObject".into(),
                protocols: vec![],
                properties: vec![],
                methods: vec![],
                category_methods: vec![],
                swift_attributes: vec![],
                ancestors: vec![],
                all_methods: vec![],
                all_properties: vec![],
                objc_exposed: true,
                swift_name: None,
            }],
            protocols: vec![],
            enums: vec![],
            structs: vec![],
            functions,
            constants: vec![],
            class_annotations: vec![],
            patterns: vec![],
            enrichment: None,
            verification: None,
        }
    }

    /// Every `aw_ts_fn_*` token referenced in `text` (the emitted call sites).
    fn referenced_entries(text: &str) -> BTreeSet<String> {
        let mut out = BTreeSet::new();
        let mut rest = text;
        while let Some(pos) = rest.find("aw_ts_fn_") {
            let tail = &rest[pos..];
            let end = tail
                .find(|c: char| !c.is_ascii_alphanumeric() && c != '_')
                .unwrap_or(tail.len());
            if end > "aw_ts_fn_".len() {
                out.insert(tail[..end].to_string());
            }
            rest = &rest[pos + end..];
        }
        out
    }

    /// A fixture exercising every axis at once: scalar / struct / C-string / void shapes, the
    /// +0 and +1 object returns, a non-object `Ptr` return, and — the routability gate —
    /// a `vFloat`-shaped alias param the real corpus defers.
    fn fixture() -> Framework {
        framework(
            "TestKit",
            vec![
                // () -> double : `0_d`.
                function(
                    "TKAbsoluteTime",
                    vec![],
                    ty(TypeRefKind::Primitive {
                        name: "double".into(),
                    }),
                ),
                // (double, double) -> double : `dd_d`, sharing no body with the above.
                function(
                    "TKHypot",
                    vec![
                        param(
                            "x",
                            TypeRefKind::Primitive {
                                name: "double".into(),
                            },
                        ),
                        param(
                            "y",
                            TypeRefKind::Primitive {
                                name: "double".into(),
                            },
                        ),
                    ],
                    ty(TypeRefKind::Primitive {
                        name: "double".into(),
                    }),
                ),
                // (id) -> id, +0 by the CF Create Rule → the entry FOLDS a retain.
                function(
                    "TKWidgetGetName",
                    vec![param(
                        "w",
                        TypeRefKind::Id {
                            protocols: Vec::new(),
                        },
                    )],
                    ty(TypeRefKind::Class {
                        name: "TKWidget".into(),
                        framework: None,
                        params: vec![],
                    }),
                ),
                // (id) -> id, +1 (`Create`) → same `P_P` body, NO fold. Proves the retain axis
                // rides the descriptor, not the body.
                function(
                    "TKWidgetCreateCopy",
                    vec![param(
                        "w",
                        TypeRefKind::Id {
                            protocols: Vec::new(),
                        },
                    )],
                    ty(TypeRefKind::Class {
                        name: "TKWidget".into(),
                        framework: None,
                        params: vec![],
                    }),
                ),
                // () -> Class : ABI-`Ptr` but NOT is_object_type → never folds, never wrapped.
                function("TKWidgetClass", vec![], ty(TypeRefKind::ClassRef)),
                // (char*) -> CGRect : the C-string prelude + a by-value struct return.
                function(
                    "TKRectFromString",
                    vec![param("s", TypeRefKind::CString)],
                    ty(TypeRefKind::Struct {
                        name: "CGRect".into(),
                    }),
                ),
                // (vFloat) -> void : an alias with no static ABI shape — the routability gate
                // drops it, so no call site and no entry (the vecLib residual, in miniature).
                function(
                    "TKVectorAdd",
                    vec![param(
                        "v",
                        TypeRefKind::Alias {
                            name: "vFloat".into(),
                            framework: None,
                            underlying_primitive: None,
                        },
                    )],
                    TypeRef::void(),
                ),
            ],
        )
    }

    #[test]
    fn collection_mirrors_the_emitted_call_sites_exactly() {
        // The agreement invariant: the entry set the collection computes == the entry names the
        // rendered `.ts` bodies reference. Render the fixture through the real orchestrator.
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

        let table = collect_function_entries(std::slice::from_ref(&fw));
        let collected: BTreeSet<String> = table.entries.values().map(|e| e.entry_name()).collect();
        assert_eq!(collected, referenced);
        // The known shape of the fixture, spelled out — note `TKVectorAdd` is absent from both
        // sides: the routability gate participates in the mirror.
        assert_eq!(
            collected,
            [
                "aw_ts_fn_TKAbsoluteTime",
                "aw_ts_fn_TKHypot",
                "aw_ts_fn_TKWidgetGetName",
                "aw_ts_fn_TKWidgetCreateCopy",
                "aw_ts_fn_TKWidgetClass",
                "aw_ts_fn_TKRectFromString",
            ]
            .into_iter()
            .map(String::from)
            .collect()
        );
        assert!(!collected.contains("aw_ts_fn_TKVectorAdd"));
    }

    #[test]
    fn the_retain_fold_gates_on_the_wrap_boundary_not_the_abi_shape() {
        let table = collect_function_entries(&[fixture()]);
        let fold = |sym: &str| table.entries[sym].fold_retain;
        // +0 object return: `__wrapRetained` takes the fold's +1.
        assert!(fold("TKWidgetGetName"));
        // +1 object return (CF Create Rule): `__wrapOwned` takes the function's own +1.
        assert!(!fold("TKWidgetCreateCopy"));
        // ABI-`Ptr` but not an object — retaining a Class would leak, a SEL would be UB.
        assert!(!fold("TKWidgetClass"));
        assert_eq!(table.entries["TKWidgetClass"].sig.ret, AbiType::Ptr);
        // Both object returns share ONE body: the axis rides the descriptor.
        assert_eq!(
            table.entries["TKWidgetGetName"].body_name(),
            table.entries["TKWidgetCreateCopy"].body_name()
        );
        assert_eq!(
            table.entries["TKWidgetGetName"].body_name(),
            "aw_ts_fnsig_P_P"
        );
    }

    #[test]
    fn exports_are_per_symbol_and_bodies_per_signature() {
        let table = collect_function_entries(&[fixture()]);
        assert_eq!(table.entries.len(), 6);
        // `P_P` is shared by the two object returns → 5 distinct bodies for 6 exports.
        assert_eq!(table.signatures().len(), 5);
    }

    #[test]
    fn a_symbol_declared_by_two_frameworks_dedupes_and_is_recorded() {
        // `krb5_gss_register_acceptor_identity` is declared by both GSS and Kerberos; it is one
        // C symbol, so the per-symbol key dedupes it — but the collector walks per framework.
        let f = || {
            function(
                "krb5_gss_register_acceptor_identity",
                vec![],
                ty(TypeRefKind::Primitive {
                    name: "int32".into(),
                }),
            )
        };
        let table = collect_function_entries(&[
            framework("GSS", vec![f()]),
            framework("Kerberos", vec![f()]),
        ]);
        assert_eq!(table.entries.len(), 1);
        assert_eq!(table.entries.values().next().unwrap().framework, "GSS");
        assert_eq!(table.duplicates.len(), 1);
        assert_eq!(table.duplicates[0].kept, "GSS");
        assert_eq!(table.duplicates[0].dropped, "Kerberos");
    }

    #[test]
    fn a_body_resolves_lazily_reads_its_args_and_casts_the_address() {
        let sig = NativeSig {
            params: vec![AbiType::Double, AbiType::Double],
            ret: AbiType::Double,
            error_out: false,
        };
        let mut s = String::new();
        emit_body(&mut s, &sig);
        assert!(s.contains("private func aw_ts_fnsig_dd_d(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {"), "{s}");
        assert!(
            s.contains("let (a, data) = napiCallbackArgsData(env, info, 2)"),
            "{s}"
        );
        assert!(
            s.contains("guard let fn = awResolveFn(env, data) else { return nil }"),
            "{s}"
        );
        // No implicit self/_cmd: the first visible arg is a[0], not a[2].
        assert!(s.contains("napiReadDouble(env, a[0])"), "{s}");
        assert!(s.contains("napiReadDouble(env, a[1])"), "{s}");
        assert!(
            s.contains("typealias Fn = @convention(c) (Double, Double) -> Double"),
            "{s}"
        );
        assert!(s.contains("unsafeBitCast(fn, to: Fn.self)"), "{s}");
        assert!(
            !s.contains("awMsgSendAddr"),
            "a free function is called by its own address: {s}"
        );
    }

    #[test]
    fn a_zero_arg_body_discards_the_arg_array_but_keeps_the_data_payload() {
        let sig = NativeSig {
            params: vec![],
            ret: AbiType::Void,
            error_out: false,
        };
        let mut s = String::new();
        emit_body(&mut s, &sig);
        assert!(
            s.contains("let (_, data) = napiCallbackArgsData(env, info, 0)"),
            "{s}"
        );
        assert!(
            s.contains("typealias Fn = @convention(c) () -> Void"),
            "{s}"
        );
        assert!(s.contains("return napiUndefined(env)"), "{s}");
    }

    #[test]
    fn an_object_returning_body_folds_through_the_descriptor_flag() {
        // One body, both conventions — the branch reads `data`, not the body's identity.
        let sig = NativeSig {
            params: vec![AbiType::Ptr],
            ret: AbiType::Ptr,
            error_out: false,
        };
        let mut s = String::new();
        emit_body(&mut s, &sig);
        assert!(
            s.contains("return napiMakeHandle(env, awFnFoldRetain(data, r))"),
            "{s}"
        );
        // The unconditional fold of the outbound table must NOT appear here.
        assert!(!s.contains("objcRetain(r)"), "{s}");
    }

    #[test]
    fn a_cstring_arg_strdups_and_a_struct_return_marshals_by_value() {
        let sig = NativeSig {
            params: vec![AbiType::CStr],
            ret: AbiType::Struct(GeoStruct::CGRect),
            error_out: false,
        };
        let mut s = String::new();
        emit_body(&mut s, &sig);
        assert!(
            s.contains("let s0 = strdup(napiReadString(env, a[0]) ?? \"\")"),
            "{s}"
        );
        assert!(s.contains("defer { free(s0) }"), "{s}");
        assert!(
            s.contains("typealias Fn = @convention(c) (UnsafePointer<CChar>?) -> CGRect"),
            "{s}"
        );
        assert!(s.contains("UnsafePointer(s0)"), "{s}");
        assert!(s.contains("return napiMakeRect(env, r)"), "{s}");
    }

    #[test]
    fn libdispatch_descriptors_are_marked_unbundled() {
        let fw = framework(
            "libdispatch",
            vec![function(
                "dispatch_get_main_queue",
                vec![],
                ty(TypeRefKind::Id {
                    protocols: Vec::new(),
                }),
            )],
        );
        let table = collect_function_entries(&[fw]);
        let out = generate_function_table_swift(&table);
        assert!(
            out.contains("AwFnDesc(\"dispatch_get_main_queue\", \"libdispatch\", bundled: false, retains: true)"),
            "{out}"
        );
        assert!(
            out.contains(
                "// Unbundled (no dlopen — always-loaded, not a .framework): libdispatch."
            ),
            "{out}"
        );
        // Every other framework stays on the two-arg default.
        let cf = framework(
            "CoreFoundation",
            vec![function(
                "CFAbsoluteTimeGetCurrent",
                vec![],
                ty(TypeRefKind::Primitive {
                    name: "double".into(),
                }),
            )],
        );
        let out = generate_function_table_swift(&collect_function_entries(&[cf]));
        assert!(
            out.contains("AwFnDesc(\"CFAbsoluteTimeGetCurrent\", \"CoreFoundation\"),"),
            "{out}"
        );
    }

    #[test]
    fn generated_file_registers_every_entry_against_its_body_and_reports_counts() {
        let table = collect_function_entries(&[fixture()]);
        let out = generate_function_table_swift(&table);
        assert!(out.contains("import AppKit"), "{out}");
        assert!(
            out.contains(
                "func awRegisterGeneratedFunctions(_ env: napi_env?, _ exports: napi_value?) {"
            ),
            "{out}"
        );
        for (i, e) in table.entries.values().enumerate() {
            assert!(
                out.contains(&format!(
                    "napiDefineWithData(env, exports, \"{}\", {}, awFnEntries.advanced(by: {i}))",
                    e.entry_name(),
                    e.body_name()
                )),
                "missing registration for {}",
                e.entry_name()
            );
            assert!(
                out.contains(&format!("private func {}(", e.body_name())),
                "missing body {}",
                e.body_name()
            );
        }
        assert!(
            out.contains("// 6 per-symbol entries over 5 shared per-signature bodies; 1 fold a"),
            "{out}"
        );
    }

    #[test]
    fn regeneration_is_byte_stable() {
        let a = generate_function_table_swift(&collect_function_entries(&[fixture()]));
        let b = generate_function_table_swift(&collect_function_entries(&[fixture()]));
        assert_eq!(a, b);
    }
}
