//! Corpus typecheck gate (`corpus-typecheck-gate-k75`) — the acceptance contract golden
//! snapshots cannot express: that the emitted `.ts`/`.d.ts` pair actually typechecks
//! under the real TypeScript compiler, proving ADR-0055 §2's "provably cannot drift"
//! claim rather than asserting it. Named `runtime_load_test.rs` to match the
//! chez/racket/gerbil precedent (their real-toolchain acceptance gate lives at the same
//! path in each target's emitter crate); `tsc --noEmit` is this target's analogue of
//! `racket`/`chez --script`/`gxc -exe` — the real compiler standing in for "does this
//! actually work", one level short of running the native addon.
//!
//! Roots: Foundation + AppKit (the natural first cut named by the task — the whole
//! ~5223-class/252-framework corpus would be slow to typecheck every run). The
//! cross-framework `@apianyware/<fw>` import closure those two roots pull in (17
//! frameworks, measured) is discovered by a BFS over the *emitted* source
//! ([`emit_closure`]) rather than a hand-maintained list: a stale list would either
//! under-check silently (a new cross-framework reference never added to the harness) or
//! over-fail loudly (tsc reporting "cannot find module" for an entry the list forgot) —
//! BFS can't go stale because it reads the exact imports tsc will resolve.
//!
//! Cross-framework `ClassRegistry`/`EnumRegistry`/`ProtocolRegistry` are built over
//! **every** loaded family ([`apianyware_datalog::loading::load_all_family_artifacts`]
//! with no filter), mirroring generate-cli's `run_generation` exactly. This is
//! deliberate: `corpus-reproducibility-k86` (open) found that restricting *which*
//! families feed a registry-building pass changes cross-framework resolution — this
//! harness must not reintroduce that contamination class by filtering its own input.
//!
//! Skip behavior (same convention as chez/racket/gerbil's `runtime_load_test.rs`):
//!  - SKIPPED unless `RUNTIME_LOAD_TEST=1`
//!  - SKIPPED if `node` is not on PATH, or the runtime package's `node_modules/typescript`
//!    is not installed (`npm install` in `bindings/node/runtime`)
//!  - SKIPPED if no `resolved.kdl` is found under `platforms/macos/api` (run the
//!    analysis pipeline first)

use std::collections::{BTreeSet, HashMap, VecDeque};
use std::path::{Path, PathBuf};
use std::process::Command;

use apianyware_emit::framework_ordering::topological_sort;
use apianyware_emit::target_emitter::TargetEmitter;
use apianyware_emit_typescript::class_graph::ClassRegistry;
use apianyware_emit_typescript::enum_graph::EnumRegistry;
use apianyware_emit_typescript::naming::module_specifier;
use apianyware_emit_typescript::protocol_graph::ProtocolRegistry;
use apianyware_emit_typescript::TsEmitter;
use apianyware_types::ir::Framework;

/// The typecheck roots — Step 7's first sample app (`hello-window`) needs Foundation +
/// AppKit, and the task names them as the natural bounded first cut.
const ROOT_FRAMEWORKS: &[&str] = &["Foundation", "AppKit"];

const RUNTIME_MODULE: &str = "@apianyware/runtime";

fn crate_root() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR"))
}

/// `targets/typescript/tools/emit-typescript` is 4 levels below the project root —
/// the same depth as `emit-racket`/`emit-chez`/`emit-sbcl`, so this mirrors their
/// `project_root()` helper exactly.
fn project_root() -> PathBuf {
    crate_root()
        .ancestors()
        .nth(4)
        .expect("project root above emit-typescript crate")
        .to_path_buf()
}

fn api_root() -> PathBuf {
    project_root().join("platforms").join("macos").join("api")
}

fn runtime_dir() -> PathBuf {
    project_root()
        .join("targets")
        .join("typescript")
        .join("bindings")
        .join("node")
        .join("runtime")
}

fn tsc_bin() -> PathBuf {
    runtime_dir()
        .join("node_modules")
        .join("typescript")
        .join("bin")
        .join("tsc")
}

fn binary_on_path(name: &str, probe_arg: &str) -> bool {
    Command::new(name)
        .arg(probe_arg)
        .output()
        .map(|o| o.status.success())
        .unwrap_or(false)
}

/// Every distinct `@apianyware/<fw>` specifier a `.ts`/`.d.ts` file under
/// `framework_dir` references — a plain string scan (no regex dependency needed for
/// so small a pattern), matching exactly what tsc's own module resolution will see.
fn scan_apianyware_imports(framework_dir: &Path) -> BTreeSet<String> {
    const PREFIX: &str = "@apianyware/";
    let mut found = BTreeSet::new();
    for entry in std::fs::read_dir(framework_dir)
        .unwrap_or_else(|e| panic!("read_dir {}: {e}", framework_dir.display()))
    {
        let path = entry.expect("dir entry").path();
        if path.extension().and_then(|e| e.to_str()) != Some("ts") {
            continue;
        }
        let content = std::fs::read_to_string(&path)
            .unwrap_or_else(|e| panic!("read {}: {e}", path.display()));
        let mut rest = content.as_str();
        while let Some(idx) = rest.find(PREFIX) {
            let after = &rest[idx + PREFIX.len()..];
            let end = after
                .find(|c: char| !(c.is_ascii_alphanumeric() || c == '_'))
                .unwrap_or(after.len());
            found.insert(format!("{PREFIX}{}", &after[..end]));
            rest = &after[end..];
        }
    }
    found
}

/// Emit `roots` plus their transitive `@apianyware/<fw>` import closure into
/// `generated_dir`. Registries are built over **every** loaded family (never a
/// filtered subset — see the module doc's `corpus-reproducibility-k86` note); only the
/// *emission* is bounded to the closure the roots actually reach.
///
/// Returns the emitted module specifiers, in BFS discovery order (roots first),
/// for the caller's diagnostics.
fn emit_closure(generated_dir: &Path, roots: &[&str]) -> Vec<String> {
    let all =
        apianyware_datalog::loading::load_all_family_artifacts(&api_root(), "resolved.kdl", None)
            .unwrap_or_else(|e| panic!("load resolved.kdl under {}: {e}", api_root().display()));
    assert!(
        !all.is_empty(),
        "no resolved.kdl found under {} (run the analysis pipeline first)",
        api_root().display()
    );

    let order = topological_sort(&all);
    let ordered: Vec<&Framework> = order
        .iter()
        .filter_map(|name| all.iter().find(|fw| &fw.name == name))
        .collect();

    let by_specifier: HashMap<String, &Framework> = ordered
        .iter()
        .map(|fw| (module_specifier(&fw.name), *fw))
        .collect();

    let class_registry = ClassRegistry::from_framework_refs(&ordered);
    let enum_registry = EnumRegistry::from_framework_refs(&ordered);
    let protocol_registry = ProtocolRegistry::from_framework_refs(&ordered);
    // The same whole-program blocklist the CLI computes (`nsobject-plain-init-surface-gap-k122`) —
    // built over every loaded family here too, matching this harness's own "never a filtered
    // subset" registry-building discipline (module doc).
    let init_blocklist =
        apianyware_emit_typescript::class_graph::synthetic_init_blocklist(&ordered);
    let emitter = TsEmitter::with_registries(
        class_registry,
        enum_registry,
        protocol_registry,
        init_blocklist,
    );

    let mut emitted_order = Vec::new();
    let mut emitted: BTreeSet<String> = BTreeSet::new();
    let mut queue: VecDeque<String> = roots.iter().map(|name| module_specifier(name)).collect();

    while let Some(specifier) = queue.pop_front() {
        if emitted.contains(&specifier) {
            continue;
        }
        let fw = *by_specifier.get(&specifier).unwrap_or_else(|| {
            panic!("no resolved IR for {specifier} (is it a real framework name?)")
        });
        emitter
            .emit_framework(fw, generated_dir)
            .unwrap_or_else(|e| panic!("emit {} failed: {e}", fw.name));
        emitted.insert(specifier.clone());
        emitted_order.push(specifier.clone());

        let module_dir = generated_dir.join(specifier.trim_start_matches("@apianyware/"));
        for imported in scan_apianyware_imports(&module_dir) {
            if imported != RUNTIME_MODULE && !emitted.contains(&imported) {
                queue.push_back(imported);
            }
        }
    }

    emitted_order
}

/// Write the tempdir's `tsconfig.json`: `@apianyware/*` path-mapped by wildcard onto
/// `emit_closure`'s output (so a BFS gap surfaces as tsc's own "cannot find module",
/// never a silent pass), `@apianyware/runtime` mapped straight at the runtime
/// package's TS source (no build step needed for a `--noEmit` check).
///
/// `moduleResolution: "bundler"` (not the runtime's own `"nodenext"`) is deliberate:
/// the emitted corpus's relative imports (`export * from './nsstring'`) are
/// deliberately extension-less — a distribution/bundler-consumed shape (ADR-0060), not
/// the runtime's own `.js`-suffixed ESM style — and `nodenext` would reject them.
///
/// `strict: true` only — matching the task's literal "strict mode", not the runtime's
/// own extra opt-in flags (`noImplicitOverride`/`exactOptionalPropertyTypes`/
/// `noFallthroughCasesInSwitch`): those are a hand-written-24-file style choice the
/// generated corpus was never designed against, and turning them on here floods the
/// gate with an unrelated, enormous (`override`-keyword) finding that has nothing to do
/// with this leaf's "provably cannot drift" claim.
fn write_tsconfig(root: &Path) {
    let runtime_index = runtime_dir().join("src").join("index.ts");
    let tsconfig = format!(
        r#"{{
  "compilerOptions": {{
    "target": "es2023",
    "lib": ["es2023", "esnext.disposable"],
    "module": "esnext",
    "moduleResolution": "bundler",
    "strict": true,
    "skipLibCheck": true,
    "noEmit": true,
    "baseUrl": ".",
    "paths": {{
      "{RUNTIME_MODULE}": ["{runtime_index}"],
      "@apianyware/*": ["generated/*/index.ts"]
    }}
  }},
  "include": ["generated/**/*.ts"]
}}
"#,
        runtime_index = runtime_index.display(),
    );
    std::fs::write(root.join("tsconfig.json"), tsconfig).expect("write tsconfig.json");
}

#[test]
fn corpus_typecheck_gate() {
    if std::env::var_os("RUNTIME_LOAD_TEST").is_none() {
        eprintln!(
            "SKIPPED: corpus_typecheck_gate (set RUNTIME_LOAD_TEST=1 to enable; this test \
             emits Foundation+AppKit's cross-framework closure and shells out to tsc)"
        );
        return;
    }
    if !binary_on_path("node", "--version") {
        eprintln!("SKIPPED: corpus_typecheck_gate (node not found on PATH)");
        return;
    }
    if !tsc_bin().exists() {
        eprintln!(
            "SKIPPED: corpus_typecheck_gate (typescript not installed — run `npm install` in {})",
            runtime_dir().display()
        );
        return;
    }
    if !api_root().join("Foundation").join("resolved.kdl").exists() {
        eprintln!(
            "SKIPPED: corpus_typecheck_gate (no resolved.kdl under {} — run the analysis \
             pipeline first)",
            api_root().display()
        );
        return;
    }

    let temp = tempfile::tempdir().expect("tempdir");
    let generated_dir = temp.path().join("generated");
    std::fs::create_dir_all(&generated_dir).expect("create generated dir");

    let emitted = emit_closure(&generated_dir, ROOT_FRAMEWORKS);
    eprintln!(
        "corpus_typecheck_gate: emitted {} frameworks ({})",
        emitted.len(),
        emitted
            .iter()
            .map(|s| s.trim_start_matches("@apianyware/"))
            .collect::<Vec<_>>()
            .join(", ")
    );

    write_tsconfig(temp.path());

    let output = Command::new("node")
        .arg(tsc_bin())
        .arg("-p")
        .arg(temp.path().join("tsconfig.json"))
        .arg("--noEmit")
        .output()
        .expect("invoke tsc");

    if !output.status.success() {
        panic!(
            "corpus typecheck gate failed ({} frameworks: {}).\n--- stdout ---\n{}\n--- stderr ---\n{}",
            emitted.len(),
            emitted
                .iter()
                .map(|s| s.trim_start_matches("@apianyware/"))
                .collect::<Vec<_>>()
                .join(", "),
            String::from_utf8_lossy(&output.stdout),
            String::from_utf8_lossy(&output.stderr),
        );
    }

    eprintln!(
        "OK: corpus typecheck gate — {} frameworks clean under tsc --noEmit --strict",
        emitted.len()
    );
}
