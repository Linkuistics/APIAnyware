//! Top-level chez framework emission.
//!
//! 070 scaffold scope: per-class `.sls` files only. Enums, constants,
//! functions, protocols, and the `main.sls` re-export are leaf 080.

use std::io;
use std::path::Path;

use apianyware_macos_emit::binding_style::{EmitResult, LanguageEmitter, LanguageInfo};
use apianyware_macos_emit::code_writer::FileEmitter;
use apianyware_macos_emit::naming::class_name_to_lowercase;
use apianyware_macos_types::ir::Framework;

use crate::emit_class::generate_class_file;

pub const CHEZ_LANGUAGE_INFO: LanguageInfo = LanguageInfo {
    id: "chez",
    display_name: "Chez Scheme",
};

pub struct ChezEmitter;

impl LanguageEmitter for ChezEmitter {
    fn language_info(&self) -> &LanguageInfo {
        &CHEZ_LANGUAGE_INFO
    }

    fn emit_framework(&self, framework: &Framework, output_dir: &Path) -> io::Result<EmitResult> {
        emit_framework(framework, output_dir)
    }
}

pub fn emit_framework(fw: &Framework, output_dir: &Path) -> io::Result<EmitResult> {
    let emitter = FileEmitter::new(output_dir, &fw.name)?;

    let mut files_written: usize = 0;
    for cls in &fw.classes {
        let filename = format!("{}.sls", class_name_to_lowercase(&cls.name));
        let content = generate_class_file(cls, &fw.name);
        emitter.write_file(&filename, &content)?;
        files_written += 1;
    }

    Ok(EmitResult {
        files_written,
        classes_emitted: fw.classes.len(),
        protocols_emitted: 0,
        enums_emitted: 0,
        functions_emitted: 0,
        constants_emitted: 0,
    })
}

#[cfg(test)]
mod tests {
    use super::*;
    use apianyware_macos_types::ir::{Class, Method};
    use apianyware_macos_types::type_ref::{TypeRef, TypeRefKind};

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
    fn chez_language_info() {
        let e = ChezEmitter;
        let info = e.language_info();
        assert_eq!(info.id, "chez");
        assert_eq!(info.display_name, "Chez Scheme");
    }

    #[test]
    fn emit_with_one_class_writes_sls() {
        let tmp = tempfile::tempdir().unwrap();
        let mut fw = make_minimal_framework("Foundation");
        fw.classes.push(Class {
            name: "NSObject".into(),
            superclass: String::new(),
            protocols: vec![],
            properties: vec![],
            methods: vec![Method {
                selector: "description".into(),
                class_method: false,
                init_method: false,
                params: vec![],
                return_type: TypeRef { nullable: false, kind: TypeRefKind::Id },
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
            }],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
        });
        let res = emit_framework(&fw, tmp.path()).unwrap();
        assert_eq!(res.classes_emitted, 1);
        assert!(tmp.path().join("foundation/nsobject.sls").exists());
        let content = std::fs::read_to_string(tmp.path().join("foundation/nsobject.sls")).unwrap();
        assert!(content.contains("(library (apianyware foundation nsobject)"));
    }
}
