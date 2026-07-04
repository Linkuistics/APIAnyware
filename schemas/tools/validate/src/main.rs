//! CLI: `apianyware-validate` — the **one validation mechanism** over every
//! authored APIAnyware artifact (`structural-refactoring` grove, workstream 8 —
//! `schema-validation-k149`, leaf `validate-umbrella-k154`; ADR-0046 §5).
//!
//! It tree-walks the repository, dispatches every authored `.apiw` file to the
//! KDL-Schema validator owned by its producing crate (the twelve `validate_*`
//! functions ws2–ws6 authored), and reports the result — plus flags any `.apiw`
//! that matches no known layout, so the "validate *every* artifact" promise cannot
//! silently rot as new artifact types appear. It is a **lean driver** over those
//! validators; it embeds no schema and re-implements no validation. The per-crate
//! `tests/*_registry.rs` guards remain the `cargo test` story; this is the runnable
//! (dev + `make validate`) one.
//!
//! The derived **machine IR** (`extracted.kdl` / `resolved.kdl`) is validated only
//! under `--machine` (opt-in): it is large + derived and validation runs on the
//! format-preserving KDL parser (~2 s/MB), so a full-corpus check is minutes-scale
//! and must not run on every `make validate`.
//!
//! ## Usage
//!
//!   apianyware-validate                 # validate every authored .apiw (fast; what `make validate` runs)
//!   apianyware-validate --machine       # also validate the materialized machine IR (slow; opt-in)
//!   apianyware-validate --json          # machine-readable summary (one JSON object)
//!   apianyware-validate --list          # list the artifact classes + file counts, then exit
//!   apianyware-validate -q              # only failures + the summary line
//!
//! ## Exit codes
//!
//!   0  every artifact validated (and, under --machine, the materialized IR too)
//!   1  one or more artifacts failed validation, or an authored .apiw matched no validator
//!   2  usage error (bad flags), or --machine with no materialized IR, or repo root not found

use std::path::PathBuf;
use std::process::ExitCode;

use anyhow::{anyhow, Context, Result};
use apianyware_spec_format::validate_machine_kdl;
use apianyware_validate::{find_repo_root, machine_ir_files, validate_authored, AuthoredReport};
use clap::Parser;

#[derive(Parser)]
#[command(
    name = "apianyware-validate",
    about = "Validate every authored .apiw artifact against its KDL-Schema (the one validation mechanism, ws8).",
    long_about = "Tree-walk the repository and dispatch every authored .apiw artifact to the KDL-Schema \
        validator owned by its producing crate, reporting per-class results and flagging any .apiw that \
        matches no known layout. A lean driver over the twelve per-crate validators — it re-implements \
        nothing. With --machine it also validates the derived machine IR (extracted.kdl / resolved.kdl); \
        that is opt-in because validation runs on the format-preserving KDL parser (~2 s/MB) and the \
        materialized corpus is large, so a full check is minutes-scale and must not run on every \
        `make validate`.\n\n\
        EXAMPLES:\n\
        \x20 apianyware-validate                 validate every authored .apiw (fast; what `make validate` runs)\n\
        \x20 apianyware-validate --machine       also validate the materialized machine IR (slow; opt-in)\n\
        \x20 apianyware-validate --json          machine-readable summary (one JSON object)\n\
        \x20 apianyware-validate --list          list the artifact classes + file counts, then exit\n\n\
        EXIT CODES:\n\
        \x20 0  everything validated   1  a validation failure or an unclassified .apiw   2  usage / precondition error"
)]
struct Cli {
    /// Also validate the derived machine IR (extracted.kdl / resolved.kdl) against
    /// machine-ir.kdl-schema. Opt-in: minutes-scale on a materialized corpus, and
    /// requires the pipeline to have run (else an actionable precondition error).
    #[arg(long)]
    machine: bool,

    /// Repository root to walk. Default: auto-detected by walking up from the
    /// current directory to the ancestor holding semantic/ platforms/ targets/ schemas/.
    #[arg(long)]
    root: Option<PathBuf>,

    /// Emit a machine-readable JSON summary instead of the human report.
    #[arg(long)]
    json: bool,

    /// List the artifact classes and how many files each covers, then exit 0
    /// without validating.
    #[arg(long)]
    list: bool,

    /// Suppress the per-class OK lines; print only failures and the summary.
    #[arg(short, long)]
    quiet: bool,
}

fn main() -> ExitCode {
    let cli = Cli::parse();
    match run(&cli) {
        Ok(code) => code,
        Err(e) => {
            eprintln!("error: {e:#}");
            ExitCode::from(2)
        }
    }
}

fn run(cli: &Cli) -> Result<ExitCode> {
    let root = match &cli.root {
        Some(r) => r.clone(),
        None => {
            let cwd = std::env::current_dir().context("could not read the current directory")?;
            find_repo_root(&cwd).ok_or_else(|| {
                anyhow!(
                    "could not locate the repository root from {} — run from inside the repo, \
                     or pass --root <DIR> (the dir holding semantic/ platforms/ targets/ schemas/)",
                    cwd.display()
                )
            })?
        }
    };

    let authored = validate_authored(&root);

    if cli.list {
        print_class_listing(&authored);
        return Ok(ExitCode::SUCCESS);
    }

    // Machine IR is only touched under --machine; a full report ("in one run") is
    // authored + machine together.
    let machine = if cli.machine {
        Some(validate_machine(&root, cli.quiet, cli.json)?)
    } else {
        None
    };

    if cli.json {
        print_json(&authored, machine.as_ref());
    } else {
        print_text(&authored, machine.as_ref(), cli.quiet);
    }

    let ok = authored.ok() && machine.as_ref().is_none_or(|m| m.failed == 0);
    Ok(if ok {
        ExitCode::SUCCESS
    } else {
        ExitCode::from(1)
    })
}

/// The machine-IR validation pass (opt-in). Streams progress (cheapest files
/// first) so a minutes-scale run is never a silent hang.
struct MachineReport {
    validated: usize,
    failed: usize,
    total_bytes: u64,
    failures: Vec<String>,
}

fn validate_machine(root: &std::path::Path, quiet: bool, json: bool) -> Result<MachineReport> {
    let files = machine_ir_files(root);
    if files.is_empty() {
        // Precondition, mirroring `make lint-annotations`: the IR is derived +
        // gitignored, so name the fix rather than silently passing.
        return Err(anyhow!(
            "--machine requested but no materialized machine IR found under {}/platforms/macos/api. \
             The machine IR is derived (gitignored); run the pipeline first: \
             `cargo run -p apianyware-collect` then `cargo run -p apianyware-analyze`.",
            root.display()
        ));
    }

    let total_bytes: u64 = files
        .iter()
        .filter_map(|p| std::fs::metadata(p).ok().map(|m| m.len()))
        .sum();
    if !json {
        eprintln!(
            "validating {} materialized machine IR file(s) (~{:.1} MB; ~2 s/MB — this can take minutes)…",
            files.len(),
            total_bytes as f64 / 1_048_576.0
        );
    }

    let mut report = MachineReport {
        validated: 0,
        failed: 0,
        total_bytes,
        failures: Vec::new(),
    };
    for path in &files {
        let label = rel_label(root, path);
        let text = std::fs::read_to_string(path)
            .with_context(|| format!("reading machine IR {}", path.display()))?;
        match validate_machine_kdl(&label, &text) {
            Ok(()) => {
                if !quiet && !json {
                    eprintln!("  ok    {label}");
                }
            }
            Err(e) => {
                report.failed += 1;
                report.failures.push(format!("{label}: {e}"));
                if !json {
                    eprintln!("  FAIL  {label}: {e}");
                }
            }
        }
        report.validated += 1;
    }
    Ok(report)
}

/// Repo-relative label like `Foundation/resolved.kdl` for a machine-IR path.
fn rel_label(root: &std::path::Path, path: &std::path::Path) -> String {
    path.strip_prefix(root.join("platforms").join("macos").join("api"))
        .unwrap_or(path)
        .to_string_lossy()
        .into_owned()
}

fn print_text(authored: &AuthoredReport, machine: Option<&MachineReport>, quiet: bool) {
    use std::collections::BTreeMap;

    // Per-class rollup for the human report.
    let mut per_class: BTreeMap<&str, (usize, usize)> = BTreeMap::new();
    for o in &authored.outcomes {
        let e = per_class.entry(o.class).or_insert((0, 0));
        if o.error.is_none() {
            e.0 += 1;
        } else {
            e.1 += 1;
        }
    }

    if !quiet {
        for (class, (ok, failed)) in &per_class {
            if *failed == 0 {
                println!("  ok    {class}: {ok} valid");
            }
        }
    }
    // Failures always print, in path order.
    for o in &authored.outcomes {
        if let Some(err) = &o.error {
            println!("  FAIL  {} [{}]: {}", o.rel_path, o.class, err);
        }
    }
    for path in &authored.unclassified {
        println!(
            "  FAIL  {path} [unclassified]: no validator is wired for this .apiw layout — \
             add a class to schemas/tools/validate/src/lib.rs (or move the file)"
        );
    }

    let mut summary = format!(
        "authored: {} valid, {} failed",
        authored.passed(),
        authored.failed()
    );
    if !authored.unclassified.is_empty() {
        summary.push_str(&format!(", {} unclassified", authored.unclassified.len()));
    }
    if let Some(m) = machine {
        summary.push_str(&format!(
            "; machine IR: {} validated, {} failed (~{:.1} MB)",
            m.validated,
            m.failed,
            m.total_bytes as f64 / 1_048_576.0
        ));
    }
    println!("{summary}");
}

fn print_json(authored: &AuthoredReport, machine: Option<&MachineReport>) {
    use std::collections::BTreeMap;

    let mut per_class: BTreeMap<&str, (usize, usize)> = BTreeMap::new();
    for o in &authored.outcomes {
        let e = per_class.entry(o.class).or_insert((0, 0));
        if o.error.is_none() {
            e.0 += 1;
        } else {
            e.1 += 1;
        }
    }

    // Hand-rolled JSON keeps the crate dependency-lean (no serde_json needed for a
    // flat, fixed-shape summary). Strings are the only values needing escaping.
    let classes: Vec<String> = per_class
        .iter()
        .map(|(name, (ok, failed))| {
            format!(
                r#"{{"class":{},"valid":{ok},"failed":{failed}}}"#,
                jstr(name)
            )
        })
        .collect();
    let failures: Vec<String> = authored
        .outcomes
        .iter()
        .filter_map(|o| {
            o.error.as_ref().map(|e| {
                format!(
                    r#"{{"path":{},"class":{},"error":{}}}"#,
                    jstr(&o.rel_path),
                    jstr(o.class),
                    jstr(e)
                )
            })
        })
        .collect();
    let unclassified: Vec<String> = authored.unclassified.iter().map(|p| jstr(p)).collect();

    let machine_json = match machine {
        Some(m) => format!(
            r#","machine":{{"validated":{},"failed":{},"bytes":{},"failures":[{}]}}"#,
            m.validated,
            m.failed,
            m.total_bytes,
            m.failures
                .iter()
                .map(|f| jstr(f))
                .collect::<Vec<_>>()
                .join(",")
        ),
        None => String::new(),
    };

    let ok = authored.ok() && machine.is_none_or(|m| m.failed == 0);
    println!(
        r#"{{"ok":{ok},"authored":{{"valid":{},"failed":{},"unclassified":[{}],"classes":[{}],"failures":[{}]}}{}}}"#,
        authored.passed(),
        authored.failed(),
        unclassified.join(","),
        classes.join(","),
        failures.join(","),
        machine_json
    );
}

/// Minimal JSON string escaping for the flat summary.
fn jstr(s: &str) -> String {
    let mut out = String::with_capacity(s.len() + 2);
    out.push('"');
    for ch in s.chars() {
        match ch {
            '"' => out.push_str("\\\""),
            '\\' => out.push_str("\\\\"),
            '\n' => out.push_str("\\n"),
            '\r' => out.push_str("\\r"),
            '\t' => out.push_str("\\t"),
            c if (c as u32) < 0x20 => out.push_str(&format!("\\u{:04x}", c as u32)),
            c => out.push(c),
        }
    }
    out.push('"');
    out
}

fn print_class_listing(authored: &AuthoredReport) {
    use std::collections::BTreeMap;

    let mut counts: BTreeMap<&str, usize> = BTreeMap::new();
    for o in &authored.outcomes {
        *counts.entry(o.class).or_insert(0) += 1;
    }
    println!("authored artifact classes covered by apianyware-validate:");
    for (class, n) in &counts {
        println!("  {class}: {n} file(s)");
    }
    if !authored.unclassified.is_empty() {
        println!("unclassified .apiw (no validator wired):");
        for path in &authored.unclassified {
            println!("  {path}");
        }
    }
    println!(
        "note: the machine IR (extracted.kdl / resolved.kdl) is validated only under --machine."
    );
}
