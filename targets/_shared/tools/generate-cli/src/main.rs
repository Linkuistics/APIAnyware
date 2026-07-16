//! CLI for the generation pipeline: emit target bindings from the resolved IR.
//!
//! Usage:
//!   apianyware-generate                              # generate all targets
//!   apianyware-generate --target racket             # generate Racket only
//!   apianyware-generate --list-targets             # show available emitters

mod generate;
mod registry;

use std::path::PathBuf;

use anyhow::Result;
use clap::Parser;

#[derive(Parser)]
#[command(name = "apianyware-generate")]
#[command(about = "Generate target bindings from the resolved macOS API IR")]
struct Cli {
    /// Target(s) to generate bindings for (comma-separated or repeated).
    /// Default: all registered targets.
    #[arg(long, value_delimiter = ',')]
    target: Vec<String>,

    /// `api/` root holding the per-family resolved IR
    /// (`<input-dir>/<Framework>/resolved.kdl`, ADR-0046 spec triad).
    #[arg(long, default_value = "platforms/macos/api")]
    input_dir: PathBuf,

    /// Base output directory: the `targets/` tree root.
    /// Output goes to `{output-dir}/{target}/bindings/macos/{generated_subdir}/`
    /// (REFACTOR.md §18) — e.g. `targets/racket/bindings/macos/generated/`.
    #[arg(long, default_value = "targets")]
    output_dir: PathBuf,

    /// List available target emitters.
    #[arg(long)]
    list_targets: bool,

    /// Output path for the racket target's generated native dispatch table
    /// (ADR-0013). Written when racket is among the generated targets; `swift
    /// build` then compiles it into `libAPIAnywareRacket`.
    #[arg(
        long,
        default_value = "targets/racket/adapters/macos/sources/Generated/Dispatch.swift"
    )]
    racket_dispatch_out: PathBuf,

    /// Skip generating the racket native dispatch table (useful when only the
    /// `.rkt` bindings are wanted, or the Swift target is unavailable).
    #[arg(long)]
    no_racket_dispatch: bool,

    /// Output path for the racket target's generated Swift-native trampolines
    /// (ADR-0027). Written when racket is among the generated targets; `swift
    /// build` then compiles it into `libAPIAnywareRacket`.
    #[arg(
        long,
        default_value = "targets/racket/adapters/macos/sources/Generated/Trampolines.swift"
    )]
    racket_trampolines_out: PathBuf,

    /// Skip generating the racket Swift-native trampolines.
    #[arg(long)]
    no_racket_trampolines: bool,

    /// Output path for the chez target's generated Swift-native trampolines
    /// (ADR-0027, ported to chez). Written when chez is among the generated
    /// targets; `swift build` then compiles it into `libAPIAnywareChez`.
    #[arg(
        long,
        default_value = "targets/chez/adapters/macos/sources/Generated/Trampolines.swift"
    )]
    chez_trampolines_out: PathBuf,

    /// Skip generating the chez Swift-native trampolines.
    #[arg(long)]
    no_chez_trampolines: bool,

    /// Output path for the gerbil target's generated Swift-native trampolines
    /// (ADR-0029 — the deliberate ADR-0017 deviation: gerbil grows a `swift build`
    /// step for a trampoline-only dylib). Written when gerbil is among the
    /// generated targets; `swift build` then compiles it into libAPIAnywareGerbil.
    #[arg(
        long,
        default_value = "targets/gerbil/adapters/macos/sources/Generated/Trampolines.swift"
    )]
    gerbil_trampolines_out: PathBuf,

    /// Skip generating the gerbil Swift-native trampolines.
    #[arg(long)]
    no_gerbil_trampolines: bool,

    /// Output path for the sbcl target's generated Swift-native trampolines (ADR-0038 —
    /// `libAPIAnywareSbcl` is the SBCL target's sole native unit, so its trampolines live
    /// in a Swift dylib). Written when sbcl is among the generated targets; `swift build`
    /// then compiles it into libAPIAnywareSbcl.
    #[arg(
        long,
        default_value = "targets/sbcl/adapters/macos/sources/Generated/Trampolines.swift"
    )]
    sbcl_trampolines_out: PathBuf,

    /// Skip generating the sbcl Swift-native trampolines.
    #[arg(long)]
    no_sbcl_trampolines: bool,

    /// Output path for the typescript target's generated outbound dispatch table
    /// (ADR-0054 §1, the ADR-0013 shape — one napi callback per distinct ABI signature
    /// + `_o`/`_e` siblings). Written when typescript is among the generated targets;
    /// the addon's `build.sh` then compiles it into `APIAnywareTypeScript.node`.
    #[arg(
        long,
        default_value = "targets/typescript/bindings/node/native/src/Generated/DispatchTable.swift"
    )]
    typescript_dispatch_out: PathBuf,

    /// Skip generating the typescript outbound dispatch table.
    #[arg(long)]
    no_typescript_dispatch: bool,

    /// Output path for the typescript target's generated inbound table (ADR-0059
    /// §1/§2/§4, the inbound dual of the outbound dispatch table — one typed
    /// `@convention(c)` trampoline per distinct inbound ABI signature keyed by ObjC
    /// type encoding, one noescape+escaping block-maker pair per block signature, and
    /// one `aw_ts_super_*` napi entry per super-send signature). Written when
    /// typescript is among the generated targets; the addon's `build.sh` then compiles
    /// it into `APIAnywareTypeScript.node`.
    #[arg(
        long,
        default_value = "targets/typescript/bindings/node/native/src/Generated/InboundTable.swift"
    )]
    typescript_inbound_out: PathBuf,

    /// Skip generating the typescript inbound IMP trampoline table.
    #[arg(long)]
    no_typescript_inbound: bool,

    /// Output path for the typescript target's generated Swift-native `s:` residual
    /// trampolines (ADR-0061 — one napi callback per `objc_exposed == false` free function,
    /// calling the API by name into its framework module). A **distinct file stem** from the
    /// hand-written `src/trampolines.swift`, whose object file would otherwise collide.
    /// Written when typescript is among the generated targets; the addon's `build.sh` then
    /// compiles it into `APIAnywareTypeScript.node`.
    #[arg(
        long,
        default_value = "targets/typescript/bindings/node/native/src/Generated/TrampolineTable.swift"
    )]
    typescript_trampolines_out: PathBuf,

    /// Skip generating the typescript Swift-native residual trampolines.
    #[arg(long)]
    no_typescript_trampolines: bool,

    /// Output path for the typescript target's generated plain-C free-function table
    /// (ADR-0054 §1a — one `aw_ts_fn_<symbol>` export per C symbol, over shared
    /// per-signature bodies joined by `napi_create_function`'s `data` descriptor). A
    /// **fourth distinct file stem**: `src/trampolines.swift` exists, and
    /// `DispatchTable`/`InboundTable`/`TrampolineTable` are taken. Written when typescript is
    /// among the generated targets; the addon's `build.sh` then compiles it into
    /// `APIAnywareTypeScript.node`.
    #[arg(
        long,
        default_value = "targets/typescript/bindings/node/native/src/Generated/FunctionTable.swift"
    )]
    typescript_functions_out: PathBuf,

    /// Skip generating the typescript plain-C free-function table.
    #[arg(long)]
    no_typescript_functions: bool,
}

fn main() -> Result<()> {
    tracing_subscriber::fmt()
        .with_env_filter(
            tracing_subscriber::EnvFilter::try_from_default_env()
                .unwrap_or_else(|_| tracing_subscriber::EnvFilter::new("info")),
        )
        .init();

    let cli = Cli::parse();
    let registry = registry::EmitterRegistry::new();

    if cli.list_targets {
        println!("Available target emitters:\n");
        println!("{}", registry.format_target_list());
        return Ok(());
    }

    let target_filter = if cli.target.is_empty() {
        None
    } else {
        Some(cli.target.as_slice())
    };

    let summaries =
        generate::run_generation(&registry, &cli.input_dir, &cli.output_dir, target_filter)?;

    // Generate the racket native dispatch table (ADR-0013) when racket was among
    // the targets. It is a global pass over all frameworks, so it runs once here
    // rather than per-framework. Build order: generate (here) -> swift build.
    let racket_generated = summaries.iter().any(|s| s.target_id == "racket");
    if racket_generated && !cli.no_racket_dispatch {
        let entries =
            generate::run_racket_native_dispatch(&cli.input_dir, &cli.racket_dispatch_out)?;
        tracing::info!(
            entries,
            output = %cli.racket_dispatch_out.display(),
            "racket native dispatch table generated — run `swift build` to compile it"
        );
    }

    // Generate the racket Swift-native trampolines (ADR-0027) — also a global
    // pass over all frameworks, run alongside the dispatch table. Build order is
    // the same: generate (here) -> swift build.
    if racket_generated && !cli.no_racket_trampolines {
        let entries =
            generate::run_racket_trampolines(&cli.input_dir, &cli.racket_trampolines_out)?;
        tracing::info!(
            entries,
            output = %cli.racket_trampolines_out.display(),
            "racket Swift-native trampolines generated — run `swift build` to compile them"
        );
    }

    // Generate the chez Swift-native trampolines (ADR-0027 ported to chez) when
    // chez was among the targets — a global pass over all frameworks, same build
    // order: generate (here) -> swift build compiles them into libAPIAnywareChez.
    let chez_generated = summaries.iter().any(|s| s.target_id == "chez");
    if chez_generated && !cli.no_chez_trampolines {
        let entries = generate::run_chez_trampolines(&cli.input_dir, &cli.chez_trampolines_out)?;
        tracing::info!(
            entries,
            output = %cli.chez_trampolines_out.display(),
            "chez Swift-native trampolines generated — run `swift build` to compile them"
        );
    }

    // Generate the gerbil Swift-native trampolines (ADR-0029) when gerbil was
    // among the targets — a global pass over all frameworks, same build order:
    // generate (here) -> swift build compiles them into libAPIAnywareGerbil. This
    // is the ADR-0017 deviation: gerbil's build gains a `swift build` step.
    let gerbil_generated = summaries.iter().any(|s| s.target_id == "gerbil");
    if gerbil_generated && !cli.no_gerbil_trampolines {
        let entries =
            generate::run_gerbil_trampolines(&cli.input_dir, &cli.gerbil_trampolines_out)?;
        tracing::info!(
            entries,
            output = %cli.gerbil_trampolines_out.display(),
            "gerbil Swift-native trampolines generated — run `swift build` to compile them"
        );
    }

    // Generate the sbcl Swift-native trampolines (ADR-0038) when sbcl was among the
    // targets — a global pass over all frameworks, same build order: generate (here) ->
    // swift build compiles them into libAPIAnywareSbcl (the SBCL target's sole native unit).
    let sbcl_generated = summaries.iter().any(|s| s.target_id == "sbcl");
    if sbcl_generated && !cli.no_sbcl_trampolines {
        let entries = generate::run_sbcl_trampolines(&cli.input_dir, &cli.sbcl_trampolines_out)?;
        tracing::info!(
            entries,
            output = %cli.sbcl_trampolines_out.display(),
            "sbcl Swift-native trampolines generated — run `swift build` to compile them"
        );
    }

    // Generate the typescript target's outbound dispatch table (ADR-0054 §1) when
    // typescript was among the targets — a global pass over all frameworks, the same
    // build order as racket's ADR-0013 table: generate (here) -> the addon's build.sh
    // compiles hand-written + generated Swift into APIAnywareTypeScript.node.
    let typescript_generated = summaries.iter().any(|s| s.target_id == "typescript");
    if typescript_generated && !cli.no_typescript_dispatch {
        let entries =
            generate::run_typescript_dispatch(&cli.input_dir, &cli.typescript_dispatch_out)?;
        tracing::info!(
            entries,
            output = %cli.typescript_dispatch_out.display(),
            "typescript outbound dispatch table generated — run the addon's build.sh to compile it"
        );
    }

    // Generate the typescript target's inbound table (ADR-0059 §1/§2/§4: IMP trampolines,
    // block makers, super-sends) — the inbound dual of the outbound table, same
    // global-pass shape and build order.
    if typescript_generated && !cli.no_typescript_inbound {
        let entries =
            generate::run_typescript_inbound(&cli.input_dir, &cli.typescript_inbound_out)?;
        tracing::info!(
            entries,
            output = %cli.typescript_inbound_out.display(),
            "typescript inbound table generated — run the addon's build.sh to compile it"
        );
    }

    // Generate the typescript target's Swift-native `s:` residual trampolines (ADR-0061) —
    // the free-function dual of the outbound table: one call-by-name napi callback per
    // residual function. Same global-pass shape and build order as racket's ADR-0027 pass.
    if typescript_generated && !cli.no_typescript_trampolines {
        let entries =
            generate::run_typescript_trampolines(&cli.input_dir, &cli.typescript_trampolines_out)?;
        tracing::info!(
            entries,
            output = %cli.typescript_trampolines_out.display(),
            "typescript Swift-native residual trampolines generated — run the addon's build.sh to compile them"
        );
    }

    // Generate the typescript target's plain-C free-function table (ADR-0054 §1a) — the other
    // free-function family: an ObjC/C symbol dispatched directly by its own address, where the
    // pass above binds the Swift-native residual by name. Same global-pass shape and build order.
    if typescript_generated && !cli.no_typescript_functions {
        let entries =
            generate::run_typescript_functions(&cli.input_dir, &cli.typescript_functions_out)?;
        tracing::info!(
            entries,
            output = %cli.typescript_functions_out.display(),
            "typescript plain-C free-function table generated — run the addon's build.sh to compile it"
        );
    }

    // Print final summary
    for summary in &summaries {
        tracing::info!(
            target = %summary.target_id,
            frameworks = summary.frameworks_generated,
            files = summary.total_files_written,
            classes = summary.total_classes,
            protocols = summary.total_protocols,
            enums = summary.total_enums,
            "generation complete"
        );
    }

    Ok(())
}
