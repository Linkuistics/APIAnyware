//! Core generation orchestration — loads the resolved IR, invokes emitters,
//! writes output to `targets/{target}/bindings/macos/{generated_subdir}/` (§18).

use std::path::{Path, PathBuf};

use anyhow::{bail, Context, Result};
use apianyware_emit::framework_ordering::topological_sort;
use apianyware_emit::target_emitter::{EmitResult, TargetEmitter, TargetInfo};

use crate::registry::EmitterRegistry;

/// Result of generating bindings for one target across all frameworks.
#[derive(Debug, Default)]
pub struct GenerationSummary {
    pub target_id: String,
    pub frameworks_generated: usize,
    pub total_files_written: usize,
    pub total_classes: usize,
    pub total_protocols: usize,
    pub total_enums: usize,
}

impl GenerationSummary {
    fn accumulate(&mut self, result: &EmitResult) {
        self.frameworks_generated += 1;
        self.total_files_written += result.files_written;
        self.total_classes += result.classes_emitted;
        self.total_protocols += result.protocols_emitted;
        self.total_enums += result.enums_emitted;
    }
}

/// Build the output directory path for a target.
///
/// Pattern: `{base_output_dir}/{info.id}/bindings/macos/{info.generated_subdir}/`
/// (REFACTOR.md §18). Most targets use the conventional `generated` subdir; the
/// chez target uses `apianyware` so Chez's default library-name resolution finds
/// the emitted files with `--libdirs targets/chez/bindings/macos`.
///
/// TODO(platform-neutrality workstream): the `bindings/macos` segment is hardcoded
/// to the only platform that exists today; parameterize by platform when a second
/// one (Linux/.NET) lands.
pub fn output_dir_for_target(base_output_dir: &Path, info: &TargetInfo) -> PathBuf {
    base_output_dir
        .join(info.id)
        .join("bindings")
        .join("macos")
        .join(info.generated_subdir)
}

/// Generate bindings for the specified targets (or all if none specified).
///
/// For each target, generates every family from its `resolved.kdl`. Reads the
/// resolved IR per family under `input_dir` (the `api/` root), writes to
/// `{base_output_dir}/{target}/bindings/macos/{generated_subdir}/`.
pub fn run_generation(
    registry: &EmitterRegistry,
    input_dir: &Path,
    base_output_dir: &Path,
    target_filter: Option<&[String]>,
) -> Result<Vec<GenerationSummary>> {
    // Load every family's resolved IR (the generator input).
    let frameworks =
        apianyware_datalog::loading::load_all_family_artifacts(input_dir, "resolved.kdl", None)?;

    if frameworks.is_empty() {
        bail!(
            "no resolved.kdl found under {} (run `apianyware-analyze` first)",
            input_dir.display()
        );
    }

    // Sort frameworks in dependency order
    let order = topological_sort(&frameworks);
    let ordered_frameworks: Vec<_> = order
        .iter()
        .filter_map(|name| frameworks.iter().find(|fw| &fw.name == name))
        .collect();

    tracing::info!(frameworks = ordered_frameworks.len(), "loaded resolved IR");

    // Determine which emitters to run
    let emitters: Vec<&dyn TargetEmitter> = if let Some(targets) = target_filter {
        let mut found = Vec::new();
        for target in targets {
            match registry.get(target) {
                Some(emitter) => found.push(emitter),
                None => bail!(
                    "unknown target: '{}'. Use --list-targets to see available emitters.",
                    target
                ),
            }
        }
        found
    } else {
        registry.all().collect()
    };

    let mut summaries = Vec::new();

    for emitter in &emitters {
        let info = emitter.target_info();
        let out_dir = output_dir_for_target(base_output_dir, info);

        tracing::info!(
            target = info.id,
            output = %out_dir.display(),
            "generating bindings"
        );

        let mut summary = GenerationSummary {
            target_id: info.id.to_string(),
            ..Default::default()
        };

        // Gerbil's manifest class graph (ADR-0020) places a class's parent in
        // whichever framework *owns* it — a cross-framework fact — but
        // `emit_framework` runs per framework and cannot see the others. So
        // build the global class→owning-framework `ClassRegistry` once over
        // every loaded framework and run a program-configured emitter, the
        // same whole-program shape as racket's native-dispatch pass. Every
        // other target uses the registry instance unchanged.
        let gerbil_configured;
        let sbcl_configured;
        let typescript_configured;
        let active: &dyn TargetEmitter = if info.id == apianyware_emit_gerbil::GERBIL_TARGET_INFO.id
        {
            let reg = apianyware_emit_gerbil::class_graph::ClassRegistry::from_framework_refs(
                &ordered_frameworks,
            );
            // Protocol-inheritance registry (leaf 120): the same whole-program
            // shape, backing conformed-protocol method flattening — a class's
            // conformance closure follows protocol `inherits` edges that cross
            // frameworks.
            let protos =
                apianyware_emit_gerbil::protocol_registry::ProtocolRegistry::from_framework_refs(
                    &ordered_frameworks,
                );
            // Same whole-program shape: the shared global generics module
            // (`generics.ss`) holds one `:std/generic` generic per distinct
            // instance-surface selector across every framework, so a selector
            // shared by unrelated classes is one generic they all extend
            // (cross-module unification fix). Written once, here.
            apianyware_emit_gerbil::write_global_generics_module(&ordered_frameworks, &out_dir)?;
            gerbil_configured = apianyware_emit_gerbil::GerbilEmitter::with_registries(reg, protos);
            &gerbil_configured
        } else if info.id == apianyware_emit_sbcl::SBCL_TARGET_INFO.id {
            // SBCL takes the same whole-program registries (ADR-0034 §1 metaclass
            // graph crosses frameworks; conformed-protocol flattening follows
            // cross-framework protocol `inherits` edges) — but **no** global
            // generics module: a CL package unifies one `(defgeneric ns:<sel> …)`
            // across files for free, so SBCL needs no gerbil-style `generics.ss`
            // (ADR-0034 §3). The configured emitter is otherwise the gerbil shape.
            let reg = apianyware_emit_sbcl::class_graph::ClassRegistry::from_framework_refs(
                &ordered_frameworks,
            );
            let protos =
                apianyware_emit_sbcl::protocol_registry::ProtocolRegistry::from_framework_refs(
                    &ordered_frameworks,
                );
            sbcl_configured = apianyware_emit_sbcl::SbclEmitter::with_registries(reg, protos);
            &sbcl_configured
        } else if info.id == apianyware_emit_typescript::TS_TARGET_INFO.id {
            // TypeScript takes the same whole-program shape but with **three**
            // ownership registries: a cross-framework class parent / protocol
            // conformance resolves to its owning `@apianyware/<fw>` module, and —
            // new to this target — the `.d.ts` surface makes referenced enums a
            // typed import too (ADR-0055 §6 upgrades an enum alias off `number`),
            // so enum ownership is registry-resolved as well. No gerbil-style
            // global generics module: ES modules import symbols directly.
            let reg = apianyware_emit_typescript::class_graph::ClassRegistry::from_framework_refs(
                &ordered_frameworks,
            );
            let enums = apianyware_emit_typescript::enum_graph::EnumRegistry::from_framework_refs(
                &ordered_frameworks,
            );
            let protos =
                apianyware_emit_typescript::protocol_graph::ProtocolRegistry::from_framework_refs(
                    &ordered_frameworks,
                );
            // The whole-program synthetic-init blocklist (`nsobject-plain-init-surface-gap-k122`):
            // a class with a real descendant somewhere in the corpus whose own bare `-init`
            // override is already incompatible with a `this`-typed synthetic member (several
            // NetworkExtension/Intents provider/response families mark it `NS_UNAVAILABLE`) must
            // not receive one — adding it would be a NEW TS override-compatibility error the
            // corpus gate did not have before this class had any `init` at all.
            let init_blocklist = apianyware_emit_typescript::class_graph::synthetic_init_blocklist(
                &ordered_frameworks,
            );
            tracing::info!(
                count = init_blocklist.len(),
                names = %init_blocklist.iter().cloned().collect::<Vec<_>>().join(", "),
                "typescript synthetic-init blocklist"
            );
            // What the corpus's `id<P>` qualifiers did (ADR-0055 §4b). A qualifier that cannot bind
            // (no proven emittable interface) degrades to `NSObject` — the prior behaviour, so always
            // safe — but it is **never silent** (k57): every degraded name is reported, so a protocol
            // whose interface stops being emitted shows up here rather than as a quietly weaker type
            // surface.
            let binding =
                apianyware_emit_typescript::degradation_report(&ordered_frameworks, &protos);
            tracing::info!(
                bound = binding.bound,
                degraded = binding.degraded_occurrences(),
                degraded_names = binding.degraded.len(),
                detail = %binding.summary(),
                "typescript protocol-qualifier binding"
            );
            // ObjC has two namespaces, TypeScript one (`protocol-class-name-collapse-k90`): a
            // protocol whose name a declared class also carries no longer degrades — it re-encodes
            // as `<Name>Protocol` (`protocol_type_name`) so the framework barrel never exports one
            // symbol twice. Counted at the DECLARATION level (once per colliding name), never silent.
            let renamed =
                apianyware_emit_typescript::renamed_protocols(&ordered_frameworks, &protos);
            tracing::info!(
                count = renamed.len(),
                names = %renamed.iter().cloned().collect::<Vec<_>>().join(", "),
                "typescript protocol/class name collisions re-encoded"
            );
            // What the bound slots *did* (ADR-0059 §3/§6, `emitted-delegate-spec-k84`) — the bridge
            // that turns a JS object literal in an `id<P>` slot into a real ObjC forwarder. The dual
            // of the report above: that one says which qualifiers earned a type, this one says which
            // slots earned a value. Both count every drop, so neither a narrowed type nor a
            // never-firing delegate method can land silently (k57).
            let slots = apianyware_emit_typescript::slot_report(
                &ordered_frameworks,
                &protos,
                |fw, class_name| {
                    apianyware_emit::enrichment::class_error_selectors(
                        fw.enrichment.as_ref(),
                        class_name,
                    )
                },
            );
            tracing::info!(
                bridged = slots.bridged,
                associated = slots.associated,
                skipped = slots.bridged - slots.associated,
                init_owned = slots.init_owned,
                deferred = %slots.summary(),
                "typescript delegate-spec slots"
            );
            typescript_configured = apianyware_emit_typescript::TsEmitter::with_registries(
                reg,
                enums,
                protos,
                init_blocklist,
            );
            &typescript_configured
        } else {
            *emitter
        };

        for fw in &ordered_frameworks {
            let result = active
                .emit_framework(fw, &out_dir)
                .with_context(|| format!("failed to emit {} for {}", fw.name, info.id))?;

            tracing::info!(
                framework = %fw.name,
                files = result.files_written,
                classes = result.classes_emitted,
                "emitted"
            );

            summary.accumulate(&result);
        }

        tracing::info!(
            target = info.id,
            frameworks = summary.frameworks_generated,
            files = summary.total_files_written,
            "target complete"
        );

        summaries.push(summary);
    }

    Ok(summaries)
}

/// Generate the racket target's typed native dispatch table (ADR-0013) into the
/// `APIAnywareRacket` Swift target, then `swift build` compiles it into the dylib.
///
/// This is a **global** pass (the dispatch entries are deduplicated across every
/// framework, unlike the per-framework `.rkt` bindings), so it runs once after
/// [`run_generation`] rather than per-framework. The build order is therefore
/// `generate -> swift build` (the dispatch `.swift` must exist before the dylib
/// is built). Returns the number of distinct entries written.
///
/// The collapsed-ABI signatures are derived from the `ffi/unsafe` spellings, so
/// the mapper here is [`RacketFfiTypeMapper`] (not the ffi2 one): `native_dispatch`
/// parses `_id`/`_uint64`/`_NSRect` tokens and collapses pointer-likes itself.
pub fn run_racket_native_dispatch(input_dir: &Path, swift_out: &Path) -> Result<usize> {
    use apianyware_emit::ffi_type_mapping::RacketFfiTypeMapper;
    use apianyware_emit_racket::native_dispatch::{
        collect_global_signatures, generate_dispatch_swift,
    };

    let frameworks =
        apianyware_datalog::loading::load_all_family_artifacts(input_dir, "resolved.kdl", None)?;
    if frameworks.is_empty() {
        bail!(
            "no resolved.kdl found under {} (run `apianyware-analyze` first)",
            input_dir.display()
        );
    }

    let sigs = collect_global_signatures(&frameworks, &RacketFfiTypeMapper);
    let swift = generate_dispatch_swift(&sigs);

    if let Some(parent) = swift_out.parent() {
        std::fs::create_dir_all(parent)
            .with_context(|| format!("creating {}", parent.display()))?;
    }
    std::fs::write(swift_out, swift).with_context(|| format!("writing {}", swift_out.display()))?;

    tracing::info!(
        entries = sigs.len(),
        output = %swift_out.display(),
        "generated native dispatch table"
    );
    Ok(sigs.len())
}

/// Generate the racket target's Swift-native **trampolines** (ADR-0027) into the
/// `APIAnywareRacket` Swift target; `swift build` then compiles them into the dylib.
///
/// Like the native dispatch table this is a **global** pass — the trampolines are
/// collected across every framework and emitted into one file — so it runs once
/// after [`run_generation`], before `swift build`. Every retained
/// `objc_exposed == false` declaration is either trampolined or recorded as
/// deferred (with a reason); the per-reason counts are logged so a clean generate
/// reports what was bound and what was not (spec §5, "defer nothing, but be
/// honest"). Returns the number of trampoline entries written.
pub fn run_racket_trampolines(input_dir: &Path, swift_out: &Path) -> Result<usize> {
    use apianyware_emit_racket::trampoline::{collect_trampolines, generate_trampolines_swift};

    let frameworks =
        apianyware_datalog::loading::load_all_family_artifacts(input_dir, "resolved.kdl", None)?;
    if frameworks.is_empty() {
        bail!(
            "no resolved.kdl found under {} (run `apianyware-analyze` first)",
            input_dir.display()
        );
    }

    let set = collect_trampolines(&frameworks);
    let entries = set.functions.len() + set.constants.len() + set.inits.len() + set.methods.len();
    let swift = generate_trampolines_swift(&set);

    if let Some(parent) = swift_out.parent() {
        std::fs::create_dir_all(parent)
            .with_context(|| format!("creating {}", parent.display()))?;
    }
    std::fs::write(swift_out, swift).with_context(|| format!("writing {}", swift_out.display()))?;

    let deferred: Vec<String> = set
        .defer_counts()
        .iter()
        .map(|(reason, n)| format!("{n} {reason}"))
        .collect();
    tracing::info!(
        functions = set.functions.len(),
        constants = set.constants.len(),
        inits = set.inits.len(),
        methods = set.methods.len(),
        deferred = %if deferred.is_empty() { "none".to_string() } else { deferred.join(", ") },
        output = %swift_out.display(),
        "generated Swift-native trampolines"
    );
    Ok(entries)
}

/// Generate the **typescript** target's outbound dispatch table (ADR-0054 §1, the
/// racket ADR-0013 shape) into the Node addon's `src/Generated/DispatchTable.swift`;
/// `build.sh` then compiles it into `APIAnywareTypeScript.node`.
///
/// A **global** pass like the racket dispatch table: one napi callback per distinct
/// ABI-collapsed signature across every framework (+ the non-folding `…_o` +1
/// siblings and `…_n` non-object-pointer siblings, ADR-0057 §4, and the `…_e`
/// error-`@catch` siblings, ADR-0058), plus a
/// generated `awRegisterGeneratedDispatch` the hand-written module registration
/// calls. The collection walks the same `bound_methods` frontier the `.ts`/`.d.ts`
/// emitters walk, so the table and the emitted call sites agree by construction.
/// Fallible methods the error-out frontier defers (v-register/struct shapes the
/// `awexc.m` mechanism cannot carry) are counted in the log — mirror-consistent,
/// never silent. Returns the number of entries written.
pub fn run_typescript_dispatch(input_dir: &Path, swift_out: &Path) -> Result<usize> {
    use apianyware_emit_typescript::dispatch_table::{
        collect_global_entries, generate_dispatch_swift,
    };

    let frameworks =
        apianyware_datalog::loading::load_all_family_artifacts(input_dir, "resolved.kdl", None)?;
    if frameworks.is_empty() {
        bail!(
            "no resolved.kdl found under {} (run `apianyware-analyze` first)",
            input_dir.display()
        );
    }

    let table = collect_global_entries(&frameworks);
    let swift = generate_dispatch_swift(&table);

    if let Some(parent) = swift_out.parent() {
        std::fs::create_dir_all(parent)
            .with_context(|| format!("creating {}", parent.display()))?;
    }
    std::fs::write(swift_out, swift).with_context(|| format!("writing {}", swift_out.display()))?;

    let (plain, owned, no_wrap, error) = table.axis_counts();
    // Deferrals are reported **by reason**, never as a bare total (the "defer nothing silently"
    // discipline): a Swift nominal type the IR declares nowhere is named, with the method count it
    // cost, so a *new* unbindable Swift type surfaces as its own line rather than nudging a total.
    let nominal: Vec<String> = table
        .nominal_deferral_counts()
        .into_iter()
        .map(|(name, n)| format!("{name}×{n}"))
        .collect();
    tracing::info!(
        entries = table.entries.len(),
        plain,
        owned,
        no_wrap,
        error_out = error,
        deferred_fallible = table.deferred_fallible.len(),
        deferred_swift_nominal = table.deferred_nominal.len(),
        swift_nominal_types = %nominal.join(" "),
        output = %swift_out.display(),
        "generated typescript outbound dispatch table"
    );
    Ok(table.entries.len())
}

/// Generate the **typescript** target's inbound table — the IMP trampolines
/// (ADR-0059 §1, the inbound dual of [`run_typescript_dispatch`]), the per-signature
/// block-maker pairs (ADR-0059 §2), and the per-signature `aw_ts_super_*` super-send
/// entries (ADR-0059 §4) — into the Node addon's `src/Generated/InboundTable.swift`;
/// `build.sh` then compiles it into `APIAnywareTypeScript.node`.
///
/// A **global** pass with the frontier form of the mirror invariant: the IMP
/// collection walks the same `bound_methods` instance frontier the `.ts`/`.d.ts`
/// class emitters walk plus the same interface frontier the protocol emitter walks,
/// so every encoding a delegate spec / subclass override can name has its typed
/// trampoline in the generated `awGeneratedInboundIMP(forEncoding:)` map; the block
/// collection walks the block-typed params of **all** class + protocol methods (the
/// *future* frontier — block-carrying methods are still method_filter-deferred), so
/// every signature the block emitter will name has its `awGeneratedMakeBlock` /
/// `awGeneratedMakeEscapingBlock` case; the super-send collection rides the **same**
/// frontier as the IMPs (a super-send exists exactly where an override can), fanned
/// out over the ADR-0057 §4 owned (`_o`) retain axis. Frontier shapes outside the
/// inbound alphabet (geometry-struct / C-string — `drawRect:` and kin) are deferred
/// and counted in the log — never silent. Returns the number of trampolines written.
pub fn run_typescript_inbound(input_dir: &Path, swift_out: &Path) -> Result<usize> {
    use apianyware_emit_typescript::inbound_table::{
        collect_inbound_table, generate_inbound_swift,
    };

    let frameworks =
        apianyware_datalog::loading::load_all_family_artifacts(input_dir, "resolved.kdl", None)?;
    if frameworks.is_empty() {
        bail!(
            "no resolved.kdl found under {} (run `apianyware-analyze` first)",
            input_dir.display()
        );
    }

    let table = collect_inbound_table(&frameworks);
    let swift = generate_inbound_swift(&table);

    if let Some(parent) = swift_out.parent() {
        std::fs::create_dir_all(parent)
            .with_context(|| format!("creating {}", parent.display()))?;
    }
    std::fs::write(swift_out, swift).with_context(|| format!("writing {}", swift_out.display()))?;

    let (super_plain, super_owned, super_no_wrap) = table.super_axis_counts();
    tracing::info!(
        entries = table.entries.len(),
        deferred = table.deferred.len(),
        block_signatures = table.block_entries.len(),
        deferred_blocks = table.deferred_blocks.len(),
        super_entries = table.super_entries.len(),
        super_plain,
        super_owned,
        super_no_wrap,
        output = %swift_out.display(),
        "generated typescript inbound table (IMP trampolines + block makers + super-sends)"
    );
    Ok(table.entries.len())
}

/// Generate the **typescript** target's Swift-native `s:` residual trampolines (ADR-0061,
/// the racket ADR-0027 shape) into the Node addon's `src/Generated/TrampolineTable.swift`;
/// `build.sh` then compiles them into `APIAnywareTypeScript.node`.
///
/// A **global** pass like the two tables above: every framework's `objc_exposed == false`
/// free function is either trampolined — a napi callback that `import`s the owning module
/// and calls the API **by name**, so swiftc owns Swift-ABI correctness — or recorded as
/// deferred with a reason. The per-reason counts are logged, so a clean generate reports
/// what was bound and what was not (ADR-0061 §3, "defer nothing, but say what truly can't
/// be bound"). The collection and the `.ts` emitter share
/// `trampoline::classify_function`, so the generated table and the emitted `aw_ts_swift_*`
/// call sites agree by construction. Returns the number of trampolines written.
pub fn run_typescript_trampolines(input_dir: &Path, swift_out: &Path) -> Result<usize> {
    use apianyware_emit_typescript::trampoline::{collect_trampolines, generate_trampolines_swift};

    let frameworks =
        apianyware_datalog::loading::load_all_family_artifacts(input_dir, "resolved.kdl", None)?;
    if frameworks.is_empty() {
        bail!(
            "no resolved.kdl found under {} (run `apianyware-analyze` first)",
            input_dir.display()
        );
    }

    let set = collect_trampolines(&frameworks);
    let swift = generate_trampolines_swift(&set);

    if let Some(parent) = swift_out.parent() {
        std::fs::create_dir_all(parent)
            .with_context(|| format!("creating {}", parent.display()))?;
    }
    std::fs::write(swift_out, swift).with_context(|| format!("writing {}", swift_out.display()))?;

    let deferred: Vec<String> = set
        .defer_counts()
        .iter()
        .map(|(reason, n)| format!("{n} {reason}"))
        .collect();
    tracing::info!(
        entries = set.functions.len(),
        deferred = %if deferred.is_empty() { "none".to_string() } else { deferred.join(", ") },
        output = %swift_out.display(),
        "generated typescript Swift-native residual trampolines"
    );
    Ok(set.functions.len())
}

/// Generate the **typescript** target's plain-C free-function table (ADR-0054 §1a — ADR-0025's
/// trampoline-elided limit for a named C export) into the Node addon's
/// `src/Generated/FunctionTable.swift`; `build.sh` then compiles it into
/// `APIAnywareTypeScript.node`.
///
/// A **global** pass like its three siblings, and the last gap between what the emitted `.ts`
/// names and what the addon exports. Unlike the outbound `aw_ts_msg_*` table — which folds the
/// corpus into one entry per ABI signature because every method multiplexes through one
/// `objc_msgSend` address — a C function is called by its own address, so its **exports cannot
/// fold**: one `aw_ts_fn_<symbol>` per symbol. Its *bodies* still fold by signature, joined to
/// the symbol by `napi_create_function`'s `data` descriptor, so the file is
/// `entries`-many registrations over `signatures`-many callbacks. The collection and the `.ts`
/// emitter share `emit_functions::is_bound_direct_c`, so the table and the emitted call sites
/// agree by construction. Returns the number of exported entries written.
pub fn run_typescript_functions(input_dir: &Path, swift_out: &Path) -> Result<usize> {
    use apianyware_emit_typescript::function_table::{
        collect_function_entries, generate_function_table_swift,
    };

    let frameworks =
        apianyware_datalog::loading::load_all_family_artifacts(input_dir, "resolved.kdl", None)?;
    if frameworks.is_empty() {
        bail!(
            "no resolved.kdl found under {} (run `apianyware-analyze` first)",
            input_dir.display()
        );
    }

    let table = collect_function_entries(&frameworks);
    let swift = generate_function_table_swift(&table);

    if let Some(parent) = swift_out.parent() {
        std::fs::create_dir_all(parent)
            .with_context(|| format!("creating {}", parent.display()))?;
    }
    std::fs::write(swift_out, swift).with_context(|| format!("writing {}", swift_out.display()))?;

    // "Defer nothing silently": the duplicate declarations the per-symbol key deduped, and the
    // closed unbundled set, ride the pass log as well as the generated file's trailer.
    let duplicates: Vec<String> = table
        .duplicates
        .iter()
        .map(|d| format!("{} ({} kept, {} dropped)", d.symbol, d.kept, d.dropped))
        .collect();
    let unbundled: Vec<&str> = table.unbundled().into_iter().collect();
    tracing::info!(
        entries = table.entries.len(),
        signatures = table.signatures().len(),
        frameworks = table.framework_counts().len(),
        folded_object_returns = table.entries.values().filter(|e| e.fold_retain).count(),
        unbundled = %if unbundled.is_empty() { "none".to_string() } else { unbundled.join(", ") },
        deduped = %if duplicates.is_empty() { "none".to_string() } else { duplicates.join("; ") },
        output = %swift_out.display(),
        "generated typescript plain-C free-function table"
    );
    Ok(table.entries.len())
}

/// Generate the **chez** target's Swift-native trampolines (ADR-0027 ported to
/// chez, leaf 060) into the `APIAnywareChez` Swift target; `swift build` then
/// compiles them into `libAPIAnywareChez`.
///
/// A **global** pass like the racket trampolines: the residual is collected across
/// every framework into one `Generated/Trampolines.swift`. Per ADR-0011 the chez
/// trampoline layer shares no native substrate with racket — only the
/// classification taxonomy (a property of the shared IR) is duplicated. Every
/// retained `objc_exposed == false` declaration is either trampolined or recorded
/// as deferred with a reason; the per-reason counts are logged (spec §5). Returns
/// the number of trampoline entries written.
pub fn run_chez_trampolines(input_dir: &Path, swift_out: &Path) -> Result<usize> {
    use apianyware_emit_chez::trampoline::{collect_trampolines, generate_trampolines_swift};

    let frameworks =
        apianyware_datalog::loading::load_all_family_artifacts(input_dir, "resolved.kdl", None)?;
    if frameworks.is_empty() {
        bail!(
            "no resolved.kdl found under {} (run `apianyware-analyze` first)",
            input_dir.display()
        );
    }

    let set = collect_trampolines(&frameworks);
    // Match racket's accounting: the method frontier (ADR-0030) adds init producers
    // + receiver-handle methods to the free-function/constant residual, so the
    // entry total and the log report all four kinds (the §6c invariant is checked
    // by reproducing racket's per-kind + per-reason counts).
    let entries = set.functions.len() + set.constants.len() + set.inits.len() + set.methods.len();
    let swift = generate_trampolines_swift(&set);

    if let Some(parent) = swift_out.parent() {
        std::fs::create_dir_all(parent)
            .with_context(|| format!("creating {}", parent.display()))?;
    }
    std::fs::write(swift_out, swift).with_context(|| format!("writing {}", swift_out.display()))?;

    let deferred: Vec<String> = set
        .defer_counts()
        .iter()
        .map(|(reason, n)| format!("{n} {reason}"))
        .collect();
    tracing::info!(
        functions = set.functions.len(),
        constants = set.constants.len(),
        inits = set.inits.len(),
        methods = set.methods.len(),
        deferred = %if deferred.is_empty() { "none".to_string() } else { deferred.join(", ") },
        output = %swift_out.display(),
        "generated chez Swift-native trampolines"
    );
    Ok(entries)
}

/// Generate the **gerbil** target's Swift-native trampolines (ADR-0027 racket /
/// ADR-0028 chez, ported to gerbil under ADR-0029, leaf 070) into the
/// `APIAnywareGerbil` Swift target; `swift build` then compiles them into
/// `libAPIAnywareGerbil` — the deliberate ADR-0017 deviation (gerbil grows a
/// `swift build` step) the dylib trampoline requires.
///
/// A **global** pass like the racket/chez trampolines: the residual is collected
/// across every framework into one `Generated/Trampolines.swift`. Per ADR-0011
/// the gerbil trampoline layer shares no native substrate with racket/chez — only
/// the classification taxonomy (a property of the shared IR) is duplicated, so the
/// residual reproduces exactly (51 functions, 7 constants). Every retained
/// `objc_exposed == false` declaration is either trampolined or recorded as
/// deferred with a reason; the per-reason counts are logged (spec §5). Returns the
/// number of trampoline entries written.
pub fn run_gerbil_trampolines(input_dir: &Path, swift_out: &Path) -> Result<usize> {
    use apianyware_emit_gerbil::trampoline::{collect_trampolines, generate_trampolines_swift};

    let frameworks =
        apianyware_datalog::loading::load_all_family_artifacts(input_dir, "resolved.kdl", None)?;
    if frameworks.is_empty() {
        bail!(
            "no resolved.kdl found under {} (run `apianyware-analyze` first)",
            input_dir.display()
        );
    }

    let set = collect_trampolines(&frameworks);
    let entries = set.functions.len() + set.constants.len() + set.inits.len() + set.methods.len();
    let swift = generate_trampolines_swift(&set);

    if let Some(parent) = swift_out.parent() {
        std::fs::create_dir_all(parent)
            .with_context(|| format!("creating {}", parent.display()))?;
    }
    std::fs::write(swift_out, swift).with_context(|| format!("writing {}", swift_out.display()))?;

    let deferred: Vec<String> = set
        .defer_counts()
        .iter()
        .map(|(reason, n)| format!("{n} {reason}"))
        .collect();
    tracing::info!(
        functions = set.functions.len(),
        constants = set.constants.len(),
        inits = set.inits.len(),
        methods = set.methods.len(),
        deferred = %if deferred.is_empty() { "none".to_string() } else { deferred.join(", ") },
        output = %swift_out.display(),
        "generated gerbil Swift-native trampolines"
    );
    Ok(entries)
}

/// Generate the **sbcl** target's Swift-native trampolines (ADR-0038, the racket
/// ADR-0027 / chez ADR-0028 / gerbil ADR-0029 mechanism ported to sbcl, leaf 040/050)
/// into the `APIAnywareSbcl` Swift target; `swift build` then compiles them into
/// `libAPIAnywareSbcl` — the SBCL target's **sole native compilation unit** (a Lisp
/// compiles neither ObjC nor Swift inline, so the trampolines must live in a Swift dylib).
///
/// A **global** pass like the racket/chez/gerbil trampolines: the residual is collected
/// across every framework into one `Generated/Trampolines.swift`. Per ADR-0011 the sbcl
/// trampoline layer shares no native substrate with the peers — only the classification
/// taxonomy (a property of the shared IR) is duplicated, so the residual reproduces the
/// peers' **exactly** (the §6d invariant: 51 fn + 7 const + 576 init + 554 method). Every
/// retained `objc_exposed == false` declaration is either trampolined or recorded as
/// deferred with a reason; the per-reason counts are logged (spec §5). Returns the number
/// of trampoline entries written.
pub fn run_sbcl_trampolines(input_dir: &Path, swift_out: &Path) -> Result<usize> {
    use apianyware_emit_sbcl::trampoline::{collect_trampolines, generate_trampolines_swift};

    let frameworks =
        apianyware_datalog::loading::load_all_family_artifacts(input_dir, "resolved.kdl", None)?;
    if frameworks.is_empty() {
        bail!(
            "no resolved.kdl found under {} (run `apianyware-analyze` first)",
            input_dir.display()
        );
    }

    let set = collect_trampolines(&frameworks);
    let entries = set.functions.len() + set.constants.len() + set.inits.len() + set.methods.len();
    let swift = generate_trampolines_swift(&set);

    if let Some(parent) = swift_out.parent() {
        std::fs::create_dir_all(parent)
            .with_context(|| format!("creating {}", parent.display()))?;
    }
    std::fs::write(swift_out, swift).with_context(|| format!("writing {}", swift_out.display()))?;

    let deferred: Vec<String> = set
        .defer_counts()
        .iter()
        .map(|(reason, n)| format!("{n} {reason}"))
        .collect();
    tracing::info!(
        functions = set.functions.len(),
        constants = set.constants.len(),
        inits = set.inits.len(),
        methods = set.methods.len(),
        deferred = %if deferred.is_empty() { "none".to_string() } else { deferred.join(", ") },
        output = %swift_out.display(),
        "generated sbcl Swift-native trampolines"
    );
    Ok(entries)
}

#[cfg(test)]
mod tests {
    use super::*;
    use apianyware_emit::test_fixtures::build_snapshot_test_framework;
    use apianyware_types::ir::{Class, Framework, Method};
    use apianyware_types::type_ref::{TypeRef, TypeRefKind};

    /// **The §6d invariant** (ADR-0038 §7 / racket spec §6d) — the hard done-bar for the
    /// sbcl trampoline leaf (`040/050`). The Swift-native residual is a deterministic
    /// function of the *shared* resolved IR, so the sbcl classification must reproduce
    /// racket's/chez's/gerbil's **exactly**: 51 function + 7 constant + 563 init + 549
    /// method trampolines. The strongest evidence the hermetic port is faithful (ADR-0011).
    /// (Re-measured 2026-07-15 against a byte-for-byte-reproducible fresh regeneration —
    /// `corpus-reproducibility-k86` — after a real SDK/environment drift from the leaf's
    /// original 2026-06-20 baseline of 576 init + 554 method: see
    /// `sbcl-trampoline-count-inconsistency-k108`.)
    ///
    /// The resolved IR is gitignored (regenerated from the SDK + LLM pipeline), so this
    /// test **skips-as-pass** when the IR is absent — local checkouts and CI without a
    /// regeneration step — and asserts the counts when it is present (post-regeneration,
    /// the release gate, exactly as the racket snapshot tests gate on local IR).
    ///
    /// Compared as **one tuple**, not four sequential `assert_eq!`s: a sequential assert
    /// stops at the first mismatch and hides any further-drifted field behind it — exactly
    /// how this gate previously mistook an already-drifted `methods` count (554 → 549) for
    /// a "gap between two call sites" that never existed (k108) — the `inits` mismatch
    /// panicked first and the `methods` assertion never ran.
    #[test]
    fn sbcl_residual_reproduces_the_6d_invariant() {
        use apianyware_emit_sbcl::trampoline::collect_trampolines;

        // The resolved IR lives per family under the `api/` root (ADR-0046 spec triad),
        // four levels up from this crate.
        let api_root =
            Path::new(env!("CARGO_MANIFEST_DIR")).join("../../../../platforms/macos/api");
        let frameworks = match apianyware_datalog::loading::load_all_family_artifacts(
            &api_root,
            "resolved.kdl",
            None,
        ) {
            Ok(fws) if !fws.is_empty() => fws,
            _ => {
                eprintln!(
                    "SKIP sbcl_residual_reproduces_the_6d_invariant: no resolved.kdl under {} \
                         (gitignored — run the regeneration pipeline to exercise this gate)",
                    api_root.display()
                );
                return;
            }
        };

        let set = collect_trampolines(&frameworks);
        assert_eq!(
            (
                set.functions.len(),
                set.constants.len(),
                set.inits.len(),
                set.methods.len(),
            ),
            (51, 7, 563, 549),
            "(function, constant, init, method) trampolines (§6d)"
        );
    }

    /// The §6d invariant through the **public pipeline pass** (leaf 040/060) — the
    /// end-to-end complement to the unit assertion above: `run_sbcl_trampolines`
    /// collects the residual across every framework, emits `Trampolines.swift`, and
    /// returns the entry total. Skips-as-pass when the gitignored IR is absent.
    #[test]
    fn sbcl_run_trampolines_reproduces_6d_end_to_end() {
        let api_root =
            Path::new(env!("CARGO_MANIFEST_DIR")).join("../../../../platforms/macos/api");
        if apianyware_datalog::loading::load_all_family_artifacts(&api_root, "resolved.kdl", None)
            .map(|f| f.is_empty())
            .unwrap_or(true)
        {
            eprintln!(
                "SKIP sbcl_run_trampolines_reproduces_6d_end_to_end: no resolved.kdl under {} \
                 (gitignored — run the regeneration pipeline to exercise this gate)",
                api_root.display()
            );
            return;
        }

        let tmp = tempfile::tempdir().unwrap();
        let swift_out = tmp.path().join("Generated/Trampolines.swift");
        let entries = run_sbcl_trampolines(&api_root, &swift_out).unwrap();

        // 51 fn + 7 const + 563 init + 549 method = 1170 (the node's hard done-bar,
        // re-measured 2026-07-15 — see the sibling test's doc comment and
        // `sbcl-trampoline-count-inconsistency-k108`), and the pass actually wrote the
        // residual `.swift`.
        assert_eq!(entries, 51 + 7 + 563 + 549, "§6d residual entry total");
        assert!(swift_out.exists(), "Trampolines.swift written by the pass");
    }

    fn make_test_framework(name: &str) -> Framework {
        Framework {
            format_version: "1.0".to_string(),
            checkpoint: "resolved".to_string(),
            name: name.to_string(),
            sdk_version: None,
            collected_at: None,
            depends_on: vec![],
            skipped_symbols: vec![],
            classes: vec![Class {
                name: "NSObject".to_string(),
                superclass: String::new(),
                protocols: vec![],
                properties: vec![],
                methods: vec![Method {
                    selector: "init".to_string(),
                    class_method: false,
                    init_method: true,
                    params: vec![],
                    return_type: TypeRef {
                        nullable: false,
                        kind: TypeRefKind::Instancetype,
                    },
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
                }],
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
            functions: vec![],
            constants: vec![],
            class_annotations: vec![],
            patterns: vec![],
            enrichment: None,
            verification: None,
        }
    }

    /// Write a family's `resolved.kdl` into the per-family spec layout the
    /// generator reads: `<api_root>/<Framework>/resolved.kdl` (ADR-0046).
    fn write_test_framework(api_root: &Path, fw: &Framework) {
        let family_dir = api_root.join(&fw.name);
        std::fs::create_dir_all(&family_dir).unwrap();
        // Write through the machine codec so the on-disk encoding matches what the
        // generator reads back (KDL via the JiK codec, ADR-0046 §5) — not raw JSON.
        apianyware_spec_format::machine::write_framework(fw, &family_dir.join("resolved.kdl"))
            .unwrap();
    }

    #[test]
    fn output_dir_for_target_builds_correct_path() {
        let base = Path::new("/out/targets");
        let racket = TargetInfo {
            id: "racket",
            display_name: "Racket",
            generated_subdir: "generated",
        };
        assert_eq!(
            output_dir_for_target(base, &racket),
            PathBuf::from("/out/targets/racket/bindings/macos/generated")
        );

        let chez = TargetInfo {
            id: "chez",
            display_name: "Chez Scheme",
            generated_subdir: "apianyware",
        };
        assert_eq!(
            output_dir_for_target(base, &chez),
            PathBuf::from("/out/targets/chez/bindings/macos/apianyware")
        );
    }

    #[test]
    fn generate_single_target() {
        let tmp = tempfile::tempdir().unwrap();
        let input_dir = tmp.path().join("enriched");
        let output_dir = tmp.path().join("targets");

        let fw = make_test_framework("TestKit");
        write_test_framework(&input_dir, &fw);

        let registry = EmitterRegistry::new();
        let targets = vec!["racket".to_string()];
        let summaries = run_generation(&registry, &input_dir, &output_dir, Some(&targets)).unwrap();

        assert_eq!(summaries.len(), 1);
        assert_eq!(summaries[0].target_id, "racket");
        assert!(summaries[0].total_files_written > 0);

        // Verify output structure
        assert!(output_dir
            .join("racket/bindings/macos/generated/testkit/main.rkt")
            .exists());
    }

    #[test]
    fn generate_multiple_frameworks() {
        let tmp = tempfile::tempdir().unwrap();
        let input_dir = tmp.path().join("enriched");
        let output_dir = tmp.path().join("targets");

        write_test_framework(&input_dir, &make_test_framework("Foundation"));
        write_test_framework(&input_dir, &make_test_framework("AppKit"));

        let registry = EmitterRegistry::new();
        let targets = vec!["racket".to_string()];
        let summaries = run_generation(&registry, &input_dir, &output_dir, Some(&targets)).unwrap();

        // Both frameworks generated
        assert_eq!(summaries[0].frameworks_generated, 2);
        assert!(output_dir
            .join("racket/bindings/macos/generated/foundation")
            .exists());
        assert!(output_dir
            .join("racket/bindings/macos/generated/appkit")
            .exists());
    }

    #[test]
    fn generate_all_targets() {
        let tmp = tempfile::tempdir().unwrap();
        let input_dir = tmp.path().join("enriched");
        let output_dir = tmp.path().join("targets");

        write_test_framework(&input_dir, &make_test_framework("TestKit"));

        let registry = EmitterRegistry::new();
        let summaries = run_generation(&registry, &input_dir, &output_dir, None).unwrap();

        // Should generate for all registered targets (currently just racket)
        assert!(!summaries.is_empty());
        assert_eq!(summaries[0].target_id, "racket");
    }

    #[test]
    fn generate_unknown_target_returns_error() {
        let tmp = tempfile::tempdir().unwrap();
        let input_dir = tmp.path().join("enriched");
        let output_dir = tmp.path().join("targets");

        write_test_framework(&input_dir, &make_test_framework("TestKit"));

        let registry = EmitterRegistry::new();
        let targets = vec!["unknown".to_string()];
        let result = run_generation(&registry, &input_dir, &output_dir, Some(&targets));

        assert!(result.is_err());
        let err = result.unwrap_err().to_string();
        assert!(err.contains("unknown target"));
    }

    #[test]
    fn generate_empty_input_dir_returns_error() {
        let tmp = tempfile::tempdir().unwrap();
        let input_dir = tmp.path().join("enriched");
        std::fs::create_dir_all(&input_dir).unwrap();
        let output_dir = tmp.path().join("targets");

        let registry = EmitterRegistry::new();
        let result = run_generation(&registry, &input_dir, &output_dir, None);

        assert!(result.is_err());
        let err = result.unwrap_err().to_string();
        assert!(err.contains("no resolved.kdl"));
    }

    // -----------------------------------------------------------------------
    // Integration tests — rich synthetic IR through full pipeline
    // -----------------------------------------------------------------------

    #[test]
    fn rich_framework_reports_correct_emit_statistics() {
        let tmp = tempfile::tempdir().unwrap();
        let input_dir = tmp.path().join("enriched");
        let output_dir = tmp.path().join("targets");

        write_test_framework(&input_dir, &build_snapshot_test_framework());

        let registry = EmitterRegistry::new();
        let targets = vec!["racket".to_string()];
        let summaries = run_generation(&registry, &input_dir, &output_dir, Some(&targets)).unwrap();

        let summary = &summaries[0];
        assert_eq!(summary.frameworks_generated, 1);
        assert_eq!(summary.total_classes, 5, "TestKit has 5 classes");
        assert_eq!(summary.total_protocols, 2, "TestKit has 2 protocols");
        assert_eq!(summary.total_enums, 1, "TestKit has 1 enum");
    }

    #[test]
    fn rich_framework_creates_expected_file_structure() {
        let tmp = tempfile::tempdir().unwrap();
        let input_dir = tmp.path().join("enriched");
        let output_dir = tmp.path().join("targets");

        write_test_framework(&input_dir, &build_snapshot_test_framework());

        let registry = EmitterRegistry::new();
        let targets = vec!["racket".to_string()];
        run_generation(&registry, &input_dir, &output_dir, Some(&targets)).unwrap();

        let testkit_dir = output_dir.join("racket/bindings/macos/generated/testkit");

        // Per-class files
        for name in &["tkobject", "tkview", "tkbutton", "tkmanager", "tkhelper"] {
            assert!(
                testkit_dir.join(format!("{name}.rkt")).exists(),
                "missing class file: {name}.rkt"
            );
        }

        // Aggregate files
        assert!(testkit_dir.join("main.rkt").exists(), "missing main.rkt");
        assert!(testkit_dir.join("enums.rkt").exists(), "missing enums.rkt");
        assert!(
            testkit_dir.join("constants.rkt").exists(),
            "missing constants.rkt"
        );

        // Protocol directory
        assert!(
            testkit_dir.join("protocols").is_dir(),
            "missing protocols/ directory"
        );
    }

    #[test]
    fn rich_framework_output_contains_expected_content() {
        let tmp = tempfile::tempdir().unwrap();
        let input_dir = tmp.path().join("enriched");
        let output_dir = tmp.path().join("targets");

        write_test_framework(&input_dir, &build_snapshot_test_framework());

        let registry = EmitterRegistry::new();
        let targets = vec!["racket".to_string()];
        run_generation(&registry, &input_dir, &output_dir, Some(&targets)).unwrap();

        let testkit_dir = output_dir.join("racket/bindings/macos/generated/testkit");

        // main.rkt re-exports submodules
        let main = std::fs::read_to_string(testkit_dir.join("main.rkt")).unwrap();
        assert!(
            main.contains("require"),
            "main.rkt should require submodules"
        );

        // Class file references its class name
        let tkview = std::fs::read_to_string(testkit_dir.join("tkview.rkt")).unwrap();
        assert!(
            tkview.contains("TKView"),
            "tkview.rkt should reference TKView"
        );

        // Enum file contains enum values
        let enums = std::fs::read_to_string(testkit_dir.join("enums.rkt")).unwrap();
        assert!(
            enums.contains("TKAlignment"),
            "enums.rkt should contain TKAlignment"
        );
        assert!(
            enums.contains("TKAlignmentLeft"),
            "enums.rkt should contain TKAlignmentLeft"
        );

        // Constants file references the framework
        let constants = std::fs::read_to_string(testkit_dir.join("constants.rkt")).unwrap();
        assert!(
            constants.contains("TestKit"),
            "constants.rkt should reference the TestKit framework"
        );
    }

    #[test]
    fn all_emitters_handle_rich_framework() {
        let tmp = tempfile::tempdir().unwrap();
        let input_dir = tmp.path().join("enriched");
        let output_dir = tmp.path().join("targets");

        write_test_framework(&input_dir, &build_snapshot_test_framework());

        let registry = EmitterRegistry::new();
        let summaries = run_generation(&registry, &input_dir, &output_dir, None).unwrap();

        // Every registered emitter runs through the pipeline and produces a full
        // framework tree. sbcl became a mature target with leaf 040/060 (the
        // orchestrator + facade), so all four now carry the strong output
        // assertions; typescript joined at Step 5 of its build phase
        // (cli-registration-k56).
        assert_eq!(
            summaries.len(),
            5,
            "should run racket + chez + gerbil + sbcl + typescript emitters"
        );
        for s in &summaries {
            assert!(
                s.total_files_written > 0,
                "{} should produce files",
                s.target_id
            );
            assert_eq!(s.total_classes, 5, "{} class count", s.target_id);
        }
    }

    fn bare_class(name: &str, superclass: &str) -> Class {
        Class {
            name: name.into(),
            superclass: superclass.into(),
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
        }
    }

    #[test]
    fn gerbil_cross_framework_parent_import_resolves_through_registry() {
        // The end-to-end proof that the CLI pre-pass builds and threads gerbil's
        // cross-framework ClassRegistry: Foundation owns
        // NSMutableAttributedString; AppKit's NSTextStorage derives from it.
        // `emit_framework` sees only AppKit, so it can place that parent
        // precisely only because the pre-pass built the registry over both.
        let tmp = tempfile::tempdir().unwrap();
        let input_dir = tmp.path().join("enriched");
        let output_dir = tmp.path().join("targets");

        let mut foundation = make_test_framework("Foundation");
        foundation.classes = vec![bare_class("NSMutableAttributedString", "NSObject")];

        let mut appkit = make_test_framework("AppKit");
        appkit.depends_on = vec!["Foundation".to_string()];
        appkit.classes = vec![bare_class("NSTextStorage", "NSMutableAttributedString")];

        write_test_framework(&input_dir, &foundation);
        write_test_framework(&input_dir, &appkit);

        let registry = EmitterRegistry::new();
        let targets = vec!["gerbil".to_string()];
        run_generation(&registry, &input_dir, &output_dir, Some(&targets)).unwrap();

        // `generated_subdir = "generated"` (the gerbil package root).
        let storage = std::fs::read_to_string(
            output_dir.join("gerbil/bindings/macos/generated/appkit/nstextstorage.ss"),
        )
        .unwrap();
        assert!(
            storage.contains("(defclass (NSTextStorage NSMutableAttributedString)"),
            "child derives from the cross-framework parent:\n{storage}"
        );
        assert!(
            storage.contains(":gerbil-bindings/foundation/nsmutableattributedstring"),
            "cross-framework parent import should resolve through the wired registry:\n{storage}"
        );
    }

    #[test]
    fn sbcl_cross_framework_parent_resolves_through_registry() {
        // The end-to-end proof that the CLI pre-pass builds and threads sbcl's
        // cross-framework metaclass-graph ClassRegistry (ADR-0034 §1): Foundation
        // owns NSMutableAttributedString; AppKit's NSTextStorage derives from it.
        // emit_framework sees only AppKit, so the `ns:ns-text-storage` defclass
        // names that cross-framework parent only because the pre-pass built the
        // registry over both frameworks (SBCL needs no global generics module).
        let tmp = tempfile::tempdir().unwrap();
        let input_dir = tmp.path().join("enriched");
        let output_dir = tmp.path().join("targets");

        let mut foundation = make_test_framework("Foundation");
        foundation.classes = vec![bare_class("NSMutableAttributedString", "NSObject")];

        let mut appkit = make_test_framework("AppKit");
        appkit.depends_on = vec!["Foundation".to_string()];
        appkit.classes = vec![bare_class("NSTextStorage", "NSMutableAttributedString")];

        write_test_framework(&input_dir, &foundation);
        write_test_framework(&input_dir, &appkit);

        let registry = EmitterRegistry::new();
        let targets = vec!["sbcl".to_string()];
        run_generation(&registry, &input_dir, &output_dir, Some(&targets)).unwrap();

        // `generated_subdir = "generated"`; per-class file under the framework dir.
        let storage = std::fs::read_to_string(
            output_dir.join("sbcl/bindings/macos/generated/appkit/nstextstorage.lisp"),
        )
        .unwrap();
        assert!(
            storage.contains(
                "(defclass ns:ns-text-storage (ns:ns-mutable-attributed-string) () (:metaclass objc-class))"
            ),
            "child derives from the cross-framework parent through the wired registry:\n{storage}"
        );
    }

    #[test]
    fn typescript_cross_framework_parent_import_resolves_through_registry() {
        // The end-to-end proof that the CLI pre-pass builds and threads
        // typescript's cross-framework ClassRegistry: Foundation owns
        // NSMutableAttributedString; AppKit's NSTextStorage extends it.
        // `emit_framework` sees only AppKit, so the emitted class imports its
        // parent from `@apianyware/foundation` (rather than degrading to the
        // current framework) only because the pre-pass built the registry over
        // both frameworks and swapped in the configured emitter.
        let tmp = tempfile::tempdir().unwrap();
        let input_dir = tmp.path().join("enriched");
        let output_dir = tmp.path().join("targets");

        let mut foundation = make_test_framework("Foundation");
        foundation.classes = vec![bare_class("NSMutableAttributedString", "NSObject")];

        let mut appkit = make_test_framework("AppKit");
        appkit.depends_on = vec!["Foundation".to_string()];
        appkit.classes = vec![bare_class("NSTextStorage", "NSMutableAttributedString")];

        write_test_framework(&input_dir, &foundation);
        write_test_framework(&input_dir, &appkit);

        let registry = EmitterRegistry::new();
        let targets = vec!["typescript".to_string()];
        run_generation(&registry, &input_dir, &output_dir, Some(&targets)).unwrap();

        // `generated_subdir = "generated"`; per-class `<class_low>.ts` under the
        // framework dir.
        let storage = std::fs::read_to_string(
            output_dir.join("typescript/bindings/macos/generated/appkit/nstextstorage.ts"),
        )
        .unwrap();
        assert!(
            storage.contains("class NSTextStorage extends NSMutableAttributedString"),
            "child extends the cross-framework parent:\n{storage}"
        );
        assert!(
            storage.contains("'@apianyware/foundation'"),
            "cross-framework parent import should resolve through the wired registry:\n{storage}"
        );
    }

    fn class_with_method(name: &str, selector: &str) -> Class {
        Class {
            name: name.into(),
            superclass: "NSObject".into(),
            protocols: vec![],
            properties: vec![],
            methods: vec![Method {
                selector: selector.into(),
                class_method: false,
                init_method: false,
                params: vec![],
                return_type: TypeRef {
                    nullable: false,
                    kind: TypeRefKind::Primitive {
                        name: "uint64".into(),
                    },
                },
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
            }],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
            swift_name: None,
        }
    }

    #[test]
    fn gerbil_shared_generic_declared_once_across_unrelated_classes() {
        // Two unrelated classes in two frameworks both expose `count`. The CLI
        // pre-pass writes a single shared generics.ss with ONE (g:defgeneric
        // count); each class module imports it rather than re-declaring — the
        // cross-module generic-unification fix, proven end-to-end.
        let tmp = tempfile::tempdir().unwrap();
        let input_dir = tmp.path().join("enriched");
        let output_dir = tmp.path().join("targets");

        let mut foundation = make_test_framework("Foundation");
        foundation.classes = vec![class_with_method("NSArray", "count")];
        let mut coredata = make_test_framework("CoreData");
        coredata.depends_on = vec!["Foundation".to_string()];
        coredata.classes = vec![class_with_method("NSFetchRequest", "count")];

        write_test_framework(&input_dir, &foundation);
        write_test_framework(&input_dir, &coredata);

        let registry = EmitterRegistry::new();
        let targets = vec!["gerbil".to_string()];
        run_generation(&registry, &input_dir, &output_dir, Some(&targets)).unwrap();

        let lib = output_dir.join("gerbil/bindings/macos/generated");
        // The facade re-exports the sharded declarations (ADR-0023): the
        // `(g:defgeneric …)` forms live in `generics/NNN.ss`, one site total.
        let facade = std::fs::read_to_string(lib.join("generics.ss")).unwrap();
        assert!(
            facade.contains(":gerbil-bindings/generics/000"),
            "facade re-exports the shards:\n{facade}"
        );
        let mut shards = String::new();
        for entry in std::fs::read_dir(lib.join("generics")).unwrap().flatten() {
            shards.push_str(&std::fs::read_to_string(entry.path()).unwrap());
        }
        assert_eq!(
            shards.matches("(g:defgeneric count)").count(),
            1,
            "single declaration site for the shared generic across shards:\n{shards}"
        );

        // Both class modules import the shared module and do NOT declare the generic.
        for module in ["foundation/nsarray.ss", "coredata/nsfetchrequest.ss"] {
            let body = std::fs::read_to_string(lib.join(module)).unwrap();
            assert!(
                body.contains(":gerbil-bindings/generics"),
                "{module} should import the shared generics module:\n{body}"
            );
            assert!(
                !body.contains("(g:defgeneric count)"),
                "{module} must not re-declare the shared generic:\n{body}"
            );
            assert!(
                body.contains("(g:defmethod (count "),
                "{module} should extend the shared generic:\n{body}"
            );
        }
    }

    #[test]
    fn dependent_frameworks_both_generate_correctly() {
        let tmp = tempfile::tempdir().unwrap();
        let input_dir = tmp.path().join("enriched");
        let output_dir = tmp.path().join("targets");

        let mut foundation = make_test_framework("Foundation");
        foundation.depends_on = vec![];

        let mut appkit = make_test_framework("AppKit");
        appkit.depends_on = vec!["Foundation".to_string()];

        write_test_framework(&input_dir, &foundation);
        write_test_framework(&input_dir, &appkit);

        let registry = EmitterRegistry::new();
        let targets = vec!["racket".to_string()];
        let summaries = run_generation(&registry, &input_dir, &output_dir, Some(&targets)).unwrap();

        assert_eq!(summaries[0].frameworks_generated, 2);

        // Both output directories should exist with correct content
        let generated_dir = output_dir.join("racket/bindings/macos/generated");
        assert!(
            generated_dir.join("foundation/main.rkt").exists(),
            "Foundation output should exist"
        );
        assert!(
            generated_dir.join("appkit/main.rkt").exists(),
            "AppKit output should exist"
        );
    }

    #[test]
    fn multiple_rich_frameworks_accumulate_statistics() {
        let tmp = tempfile::tempdir().unwrap();
        let input_dir = tmp.path().join("enriched");
        let output_dir = tmp.path().join("targets");

        // Write the same rich framework under two names
        let mut fw1 = build_snapshot_test_framework();
        fw1.name = "FrameworkA".to_string();
        let mut fw2 = build_snapshot_test_framework();
        fw2.name = "FrameworkB".to_string();

        write_test_framework(&input_dir, &fw1);
        write_test_framework(&input_dir, &fw2);

        let registry = EmitterRegistry::new();
        let targets = vec!["racket".to_string()];
        let summaries = run_generation(&registry, &input_dir, &output_dir, Some(&targets)).unwrap();

        let summary = &summaries[0];
        assert_eq!(summary.frameworks_generated, 2);
        assert_eq!(summary.total_classes, 10, "5 classes x 2 frameworks");
        assert_eq!(summary.total_protocols, 4, "2 protocols x 2 frameworks");
        assert_eq!(summary.total_enums, 2, "1 enum x 2 frameworks");
    }
}
