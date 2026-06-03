//! Top-level gerbil framework emission.
//!
//! Produces one Gerbil `.ss` module per class, plus companion `enums.ss`,
//! `constants.ss`, `functions.ss`, `protocols/<proto>.ss`, and a `<framework>.ss`
//! re-export facade written *next to* the framework directory (e.g. `appkit.ss`
//! alongside `appkit/`). The facade IS the per-framework `main` re-export: it
//! imports every sibling module and re-exports the union of their exports, so
//! an app can `(import :gerbil-bindings/<framework>)` for the whole framework or
//! `(import :gerbil-bindings/<framework>/<class>)` for one class.
//!
//! **Status (leaf 010 — crate foundation):** this file stands up the orchestrator
//! and the facade-generation machinery (the [`SubModule`] collection + the
//! collision-rename pass), and handles the **empty framework** end-to-end. The
//! per-construct loops (classes, enums, constants, functions, protocols) are
//! added by leaves 020–040, each pushing its emitted modules onto `submodules`;
//! until then a framework emits just its (possibly empty) facade.

use std::io;
use std::path::Path;

use apianyware_macos_emit::code_writer::CodeWriter;
use apianyware_macos_emit::target_emitter::{EmitResult, TargetEmitter, TargetInfo};
use apianyware_macos_emit::write_line;
use apianyware_macos_types::ir::Framework;

/// The Gerbil package every emitted module lives under: an app imports a class
/// as `:gerbil-bindings/<framework>/<class>` and a whole framework as
/// `:gerbil-bindings/<framework>`. See the layout note in `lib.rs`.
pub const PACKAGE: &str = "gerbil-bindings";

pub const GERBIL_TARGET_INFO: TargetInfo = TargetInfo {
    id: "gerbil",
    display_name: "Gerbil Scheme",
    // The emitter's `output_dir` is the package root; `generated_subdir = "lib"`
    // places it at `generation/targets/gerbil/lib/` (design spec §8). The static
    // `gerbil.pkg` declaring `(package: gerbil-bindings)` is owned by the runtime
    // setup (leaf 050), not emitted per run.
    generated_subdir: "lib",
};

pub struct GerbilEmitter;

impl TargetEmitter for GerbilEmitter {
    fn target_info(&self) -> &TargetInfo {
        &GERBIL_TARGET_INFO
    }

    fn emit_framework(&self, framework: &Framework, output_dir: &Path) -> io::Result<EmitResult> {
        emit_framework(framework, output_dir)
    }
}

/// One emitted sibling module the facade must import and re-export from. The
/// `import_path` is the `:gerbil-bindings/…` form spliced into the facade's
/// `(import …)`; `exports` flow into the facade's `(export …)`. `is_protocol`
/// marks delegate-protocol modules so their exports can be renamed on a name
/// collision with a same-named class sibling (Apple ships class/protocol pairs
/// like `NSAccessibilityElement` that would otherwise both export
/// `make-nsaccessibilityelement`).
pub struct SubModule {
    pub import_path: String,
    pub exports: Vec<String>,
    pub is_protocol: bool,
}

impl SubModule {
    pub fn import_path(framework_low: &str, components: &[&str]) -> String {
        let mut path = format!(":{PACKAGE}/{framework_low}");
        for c in components {
            path.push('/');
            path.push_str(c);
        }
        path
    }
}

pub fn emit_framework(fw: &Framework, output_dir: &Path) -> io::Result<EmitResult> {
    let fw_low = fw.name.to_ascii_lowercase();

    let files_written: usize = 0;
    let submodules: Vec<SubModule> = Vec::new();

    // Leaves 020–040 populate `submodules` here: one entry per class module,
    // plus enums.ss / constants.ss / functions.ss / protocols/<proto>.ss, each
    // written via a `FileEmitter` and pushed onto `submodules` so the facade
    // re-exports it. Until then the framework emits just its facade.

    // Per-framework facade: `<framework>.ss` next to the framework directory.
    let facade = generate_facade_file(&fw.name, &submodules);
    let facade_path = output_dir.join(format!("{fw_low}.ss"));
    std::fs::create_dir_all(output_dir)?;
    std::fs::write(&facade_path, facade)?;

    Ok(EmitResult {
        files_written: files_written + 1,
        classes_emitted: 0,
        protocols_emitted: 0,
        enums_emitted: 0,
        functions_emitted: 0,
        constants_emitted: 0,
    })
}

/// Render the `<framework>.ss` re-export facade from the emitted submodules.
/// Imports each sibling and re-exports the union of their exports, renaming a
/// protocol export to `<name>-protocol` when it collides with a class export of
/// the same name (mirrors chez's facade collision pass).
fn generate_facade_file(framework: &str, submodules: &[SubModule]) -> String {
    use std::collections::HashMap;

    let mut w = CodeWriter::new();
    write_line!(
        w,
        ";;; Generated {} bindings ({} package) — re-export facade",
        framework,
        PACKAGE
    );

    // Tally every export name; a name appearing more than once needs the
    // protocol side disambiguated (the class keeps the natural name).
    let mut name_counts: HashMap<&str, usize> = HashMap::new();
    for s in submodules {
        for n in &s.exports {
            *name_counts.entry(n.as_str()).or_default() += 1;
        }
    }
    let needs_rename = |is_protocol: bool, name: &str| -> bool {
        is_protocol && name_counts.get(name).copied().unwrap_or(0) > 1
    };
    let protocol_renamed = |name: &str| format!("{name}-protocol");

    // Final export list — the names visible from a flat framework import.
    let mut all_exports: Vec<String> = Vec::new();
    for s in submodules {
        for n in &s.exports {
            if needs_rename(s.is_protocol, n) {
                all_exports.push(protocol_renamed(n));
            } else {
                all_exports.push(n.clone());
            }
        }
    }
    all_exports.sort();
    all_exports.dedup();

    // Imports first (Gerbil wants imports before the body), renaming where a
    // collision was resolved. An empty framework imports nothing.
    if !submodules.is_empty() {
        w.line("(import");
        for s in submodules {
            let renames: Vec<(String, String)> = s
                .exports
                .iter()
                .filter(|n| needs_rename(s.is_protocol, n))
                .map(|n| (n.clone(), protocol_renamed(n)))
                .collect();
            if renames.is_empty() {
                write_line!(w, "  {}", s.import_path);
            } else {
                write_line!(w, "  (rename-in {}", s.import_path);
                for (from, to) in &renames {
                    write_line!(w, "             ({} {})", from, to);
                }
                w.line("             )");
            }
        }
        w.line("  )");
    }

    if all_exports.is_empty() {
        w.line("(export)");
    } else {
        w.line("(export");
        for n in &all_exports {
            write_line!(w, "  {}", n);
        }
        w.line("  )");
    }

    w.finish()
}

#[cfg(test)]
mod tests {
    use super::*;
    use apianyware_macos_types::ir::Framework;

    fn make_minimal_framework(name: &str) -> Framework {
        Framework {
            format_version: "1.0".into(),
            checkpoint: "enriched".into(),
            name: name.into(),
            sdk_version: None,
            collected_at: None,
            depends_on: vec![],
            skipped_symbols: vec![],
            classes: vec![],
            protocols: vec![],
            enums: vec![],
            structs: vec![],
            functions: vec![],
            constants: vec![],
            class_annotations: vec![],
            api_patterns: vec![],
            enrichment: None,
            verification: None,
        }
    }

    #[test]
    fn gerbil_target_info() {
        let e = GerbilEmitter;
        assert_eq!(e.target_info().id, "gerbil");
        assert_eq!(e.target_info().display_name, "Gerbil Scheme");
        assert_eq!(e.target_info().generated_subdir, "lib");
    }

    #[test]
    fn empty_framework_writes_just_facade() {
        let tmp = tempfile::tempdir().unwrap();
        let fw = make_minimal_framework("TestKit");
        let res = emit_framework(&fw, tmp.path()).unwrap();
        assert_eq!(res.files_written, 1);
        let facade = tmp.path().join("testkit.ss");
        assert!(facade.exists());
        let body = std::fs::read_to_string(&facade).unwrap();
        assert!(body.contains(";;; Generated TestKit bindings (gerbil-bindings package)"));
        assert!(body.contains("(export)"));
        // Nothing to import in an empty framework.
        assert!(!body.contains("(import"));
    }

    #[test]
    fn facade_imports_and_reexports_submodules() {
        // Exercises the facade machinery 020–040 will drive, including the
        // class/protocol collision rename.
        let submodules = vec![
            SubModule {
                import_path: SubModule::import_path("appkit", &["nswindow"]),
                exports: vec!["make-nswindow".into(), "nswindow-title".into()],
                is_protocol: false,
            },
            SubModule {
                import_path: SubModule::import_path("appkit", &["protocols", "nswindow"]),
                exports: vec!["make-nswindow".into()],
                is_protocol: true,
            },
        ];
        let body = generate_facade_file("AppKit", &submodules);
        assert!(body.contains(":gerbil-bindings/appkit/nswindow"));
        assert!(body.contains(":gerbil-bindings/appkit/protocols/nswindow"));
        // The colliding protocol export is renamed; the class keeps the name.
        assert!(body.contains("(rename-in :gerbil-bindings/appkit/protocols/nswindow"));
        assert!(body.contains("(make-nswindow make-nswindow-protocol)"));
        assert!(body.contains("make-nswindow-protocol"));
        assert!(body.contains("nswindow-title"));
    }

    #[test]
    fn import_path_builder() {
        assert_eq!(
            SubModule::import_path("foundation", &["nsstring"]),
            ":gerbil-bindings/foundation/nsstring"
        );
        assert_eq!(
            SubModule::import_path("appkit", &["protocols", "nswindowdelegate"]),
            ":gerbil-bindings/appkit/protocols/nswindowdelegate"
        );
    }
}
