//! Top-level SBCL framework emission.
//!
//! **Status (leaf 010 — scaffold):** this is the [`TargetEmitter`] entry point and
//! [`SBCL_TARGET_INFO`]; `emit_framework` currently only ensures the output tree
//! exists. The construct emitters (the `defclass` graph + generics, protocols,
//! enums/constants/functions) and the per-framework re-export facade are added by
//! the sibling `040-build-emitter` child leaves, each writing its forms here.

use std::io;
use std::path::Path;

use apianyware_macos_emit::target_emitter::{EmitResult, TargetEmitter, TargetInfo};
use apianyware_macos_types::ir::Framework;

pub const SBCL_TARGET_INFO: TargetInfo = TargetInfo {
    id: "sbcl",
    display_name: "SBCL",
    // SBCL imposes no on-disk path constraint on the binding's package (unlike
    // chez, whose `(apianyware <fw> <cls>)` library name resolves to a libdir
    // path, hence its `apianyware` subdir). The `ns:` package is loaded by the
    // runtime/ASDF system (leaf 050) pointing at this directory explicitly, so
    // the conventional `generated` subdir is used.
    generated_subdir: "generated",
};

/// The SBCL emitter.
///
/// Default-constructed for the registry / `--list-targets`. Later child leaves
/// give it the cross-framework registries (class graph parents, protocol
/// conformance) via a `with_registries`-style constructor and a CLI pre-pass,
/// the same whole-program shape gerbil uses; `new()` (empty registries) stays the
/// registry's entry.
#[derive(Default)]
pub struct SbclEmitter;

impl SbclEmitter {
    pub fn new() -> Self {
        Self
    }
}

impl TargetEmitter for SbclEmitter {
    fn target_info(&self) -> &TargetInfo {
        &SBCL_TARGET_INFO
    }

    fn emit_framework(&self, framework: &Framework, output_dir: &Path) -> io::Result<EmitResult> {
        // Scaffold: ensure the generated tree exists so `--target sbcl` runs
        // end-to-end. Construct emission is added by the sibling leaves.
        let _ = framework;
        std::fs::create_dir_all(output_dir)?;
        Ok(EmitResult::default())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn sbcl_target_info() {
        let e = SbclEmitter::new();
        assert_eq!(e.target_info().id, "sbcl");
        assert_eq!(e.target_info().display_name, "SBCL");
        assert_eq!(e.target_info().generated_subdir, "generated");
    }

    #[test]
    fn emit_framework_creates_output_tree() {
        let tmp = tempfile::tempdir().unwrap();
        let out = tmp.path().join("generated");
        let fw = Framework {
            format_version: "1.0".into(),
            checkpoint: "enriched".into(),
            name: "TestKit".into(),
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
        };
        let res = SbclEmitter::new().emit_framework(&fw, &out).unwrap();
        assert!(out.exists());
        assert_eq!(res.files_written, 0);
    }
}
