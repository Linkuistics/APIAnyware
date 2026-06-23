//! Top-level Racket framework emission.
//!
//! Orchestrates generation of all files for a framework: class files,
//! enums, constants, protocols, and the main re-export module.

use std::io;
use std::path::Path;

use apianyware_macos_emit::code_writer::{CodeWriter, FileEmitter};
use apianyware_macos_emit::naming::class_name_to_lowercase;
use apianyware_macos_emit::target_emitter::{EmitResult, TargetEmitter, TargetInfo};
use apianyware_macos_emit::write_line;
use apianyware_macos_types::ir::Framework;

use crate::emit_class::{generate_class_file_with_structs, generate_struct_file};
use crate::emit_constants::generate_constants_file;
use crate::emit_enums::generate_enums_file;
use crate::emit_functions::{count_emittable, generate_functions_file};
use crate::emit_protocol::generate_protocol_file;

/// Target metadata for the Racket emitter.
pub const RACKET_TARGET_INFO: TargetInfo = TargetInfo {
    id: "racket",
    display_name: "Racket",
    generated_subdir: "generated",
};

/// Racket target emitter implementing the shared [`TargetEmitter`] trait.
pub struct RacketEmitter;

impl TargetEmitter for RacketEmitter {
    fn target_info(&self) -> &TargetInfo {
        &RACKET_TARGET_INFO
    }

    fn emit_framework(&self, framework: &Framework, output_dir: &Path) -> io::Result<EmitResult> {
        emit_framework(framework, output_dir)
    }
}

/// Emit all Racket bindings for a framework to the given output directory.
///
/// Creates `{output_dir}/{framework_lowercase}/` with:
/// - One `.rkt` file per class
/// - `enums.rkt` if enums exist
/// - `constants.rkt` if constants exist
/// - `protocols/` subdirectory with protocol files
/// - `main.rkt` re-export module
pub fn emit_framework(fw: &Framework, output_dir: &Path) -> std::io::Result<EmitResult> {
    let emitter = FileEmitter::new(output_dir, &fw.name)?;

    let mut files_written: usize = 0;

    // Class files. The owning framework's value-struct set is the soundness gate for
    // unboxing value-struct params on Swift-native methods (threaded so emit_class
    // classifies identically to the global trampoline pass).
    let value_structs = crate::trampoline::value_struct_names(&fw.structs);
    let mut class_files: Vec<(String, String)> = Vec::new();
    let mut used_filenames: std::collections::HashSet<String> = std::collections::HashSet::new();
    for cls in &fw.classes {
        let filename = format!("{}.rkt", class_name_to_lowercase(&cls.name));
        let content =
            generate_class_file_with_structs(cls, &fw.name, fw.enrichment.as_ref(), &value_structs);
        emitter.write_file(&filename, &content)?;
        used_filenames.insert(filename.clone());
        class_files.push((cls.name.clone(), filename));
        files_written += 1;
    }

    // Swift-native value-struct files (population B, ADR-0030). Only structs that
    // vend at least one bindable trampoline get a file; a plain C struct yields
    // `None`. A struct whose lowercased name collides with a class file (rare) takes
    // a `-struct` suffix so neither clobbers the other.
    for st in &fw.structs {
        let Some(content) = generate_struct_file(st, &fw.name, &value_structs) else {
            continue;
        };
        let base = class_name_to_lowercase(&st.name);
        let mut filename = format!("{base}.rkt");
        if used_filenames.contains(&filename) {
            filename = format!("{base}-struct.rkt");
        }
        emitter.write_file(&filename, &content)?;
        used_filenames.insert(filename.clone());
        class_files.push((st.name.clone(), filename));
        files_written += 1;
    }

    // Enums
    let has_enums = !fw.enums.is_empty();
    if has_enums {
        let content = generate_enums_file(&fw.enums, &fw.name);
        emitter.write_file("enums.rkt", &content)?;
        files_written += 1;
    }

    // Constants
    let has_constants = !fw.constants.is_empty();
    if has_constants {
        let content = generate_constants_file(&fw.constants, &fw.name);
        emitter.write_file("constants.rkt", &content)?;
        files_written += 1;
    }

    // C functions (skip inline and variadic)
    let emittable_functions = count_emittable(&fw.functions);
    let has_functions = emittable_functions > 0;
    if has_functions {
        let content = generate_functions_file(&fw.functions, &fw.name, &fw.structs);
        emitter.write_file("functions.rkt", &content)?;
        files_written += 1;
    }

    // Protocols (only those with at least one method)
    let mut protocol_files: Vec<(String, String)> = Vec::new();
    let delegate_protocols: Vec<_> = fw
        .protocols
        .iter()
        .filter(|p| {
            let total = p.required_methods.len() + p.optional_methods.len();
            total > 0
        })
        .collect();

    for proto in &delegate_protocols {
        let filename = format!("{}.rkt", class_name_to_lowercase(&proto.name));
        let content = generate_protocol_file(proto, &fw.name, fw.enrichment.as_ref());
        emitter.write_subdir_file("protocols", &filename, &content)?;
        protocol_files.push((proto.name.clone(), filename));
        files_written += 1;
    }

    // Main re-export module
    let main_content = generate_main_file(
        &fw.name,
        &class_files,
        has_enums,
        has_constants,
        has_functions,
        &protocol_files,
    );
    emitter.write_file("main.rkt", &main_content)?;
    files_written += 1;

    Ok(EmitResult {
        files_written,
        classes_emitted: fw.classes.len(),
        protocols_emitted: delegate_protocols.len(),
        enums_emitted: fw.enums.len(),
        functions_emitted: emittable_functions,
        constants_emitted: fw.constants.len(),
    })
}

fn generate_main_file(
    framework: &str,
    class_files: &[(String, String)],
    has_enums: bool,
    has_constants: bool,
    has_functions: bool,
    protocol_files: &[(String, String)],
) -> String {
    let mut w = CodeWriter::new();
    w.line("#lang racket/base");
    write_line!(
        w,
        ";; Generated {} bindings — re-exports all modules",
        framework
    );
    w.blank_line();
    w.line("(require");
    for (_, filename) in class_files {
        write_line!(w, "  \"{}\"", filename);
    }
    if has_enums {
        w.line("  \"enums.rkt\"");
    }
    if has_constants {
        w.line("  \"constants.rkt\"");
    }
    if has_functions {
        w.line("  \"functions.rkt\"");
    }
    for (_, filename) in protocol_files {
        write_line!(w, "  \"protocols/{}\"", filename);
    }
    w.line("  )");
    w.blank_line();
    w.line("(provide (all-from-out");
    for (_, filename) in class_files {
        write_line!(w, "  \"{}\"", filename);
    }
    if has_enums {
        w.line("  \"enums.rkt\"");
    }
    if has_constants {
        w.line("  \"constants.rkt\"");
    }
    if has_functions {
        w.line("  \"functions.rkt\"");
    }
    for (_, filename) in protocol_files {
        write_line!(w, "  \"protocols/{}\"", filename);
    }
    w.line("  ))");

    w.finish()
}

#[cfg(test)]
mod tests {
    use super::*;
    use apianyware_macos_types::ir::{Class, Enum, EnumValue, Method, Protocol};
    use apianyware_macos_types::type_ref::{TypeRef, TypeRefKind};

    fn make_minimal_framework(name: &str) -> Framework {
        Framework {
            format_version: "1.0".to_string(),
            checkpoint: "enriched".to_string(),
            name: name.to_string(),
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
    fn test_emit_framework_empty() {
        let tmp = tempfile::tempdir().unwrap();
        let fw = make_minimal_framework("TestKit");
        let result = emit_framework(&fw, tmp.path()).unwrap();
        assert_eq!(result.classes_emitted, 0);
        assert_eq!(result.files_written, 1); // just main.rkt
        assert!(tmp.path().join("testkit/main.rkt").exists());
    }

    #[test]
    fn test_emit_framework_with_class() {
        let tmp = tempfile::tempdir().unwrap();
        let mut fw = make_minimal_framework("Foundation");
        fw.classes.push(Class {
            name: "NSObject".to_string(),
            superclass: String::new(),
            protocols: vec![],
            properties: vec![],
            methods: vec![Method {
                selector: "description".to_string(),
                class_method: false,
                init_method: false,
                params: vec![],
                return_type: TypeRef {
                    nullable: false,
                    kind: TypeRefKind::Id,
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
        });
        let result = emit_framework(&fw, tmp.path()).unwrap();
        assert_eq!(result.classes_emitted, 1);
        assert!(tmp.path().join("foundation/nsobject.rkt").exists());
        assert!(tmp.path().join("foundation/main.rkt").exists());
    }

    #[test]
    fn test_emit_framework_with_enums() {
        let tmp = tempfile::tempdir().unwrap();
        let mut fw = make_minimal_framework("Foundation");
        fw.enums.push(Enum {
            name: "NSComparisonResult".to_string(),
            enum_type: TypeRef {
                nullable: false,
                kind: TypeRefKind::Primitive {
                    name: "int64".into(),
                },
            },
            values: vec![
                EnumValue {
                    name: "NSOrderedAscending".to_string(),
                    value: -1,
                },
                EnumValue {
                    name: "NSOrderedSame".to_string(),
                    value: 0,
                },
            ],
            source: None,
            provenance: None,
            doc_refs: None,
            objc_exposed: true,
        });
        let result = emit_framework(&fw, tmp.path()).unwrap();
        assert_eq!(result.enums_emitted, 1);
        assert!(tmp.path().join("foundation/enums.rkt").exists());
    }

    #[test]
    fn test_emit_framework_with_protocol() {
        let tmp = tempfile::tempdir().unwrap();
        let mut fw = make_minimal_framework("AppKit");
        fw.protocols.push(Protocol {
            name: "NSWindowDelegate".to_string(),
            inherits: vec![],
            required_methods: vec![],
            optional_methods: vec![Method {
                selector: "windowWillClose:".to_string(),
                class_method: false,
                init_method: false,
                params: vec![],
                return_type: TypeRef {
                    nullable: false,
                    kind: TypeRefKind::Primitive {
                        name: "void".into(),
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
            properties: vec![],
            source: None,
            provenance: None,
            doc_refs: None,
            objc_exposed: true,
        });
        let result = emit_framework(&fw, tmp.path()).unwrap();
        assert_eq!(result.protocols_emitted, 1);
        assert!(tmp
            .path()
            .join("appkit/protocols/nswindowdelegate.rkt")
            .exists());
    }

    #[test]
    fn test_emit_framework_with_functions() {
        let tmp = tempfile::tempdir().unwrap();
        let mut fw = make_minimal_framework("TestKit");
        fw.functions.push(apianyware_macos_types::ir::Function {
            name: "TKComputeDistance".to_string(),
            params: vec![apianyware_macos_types::ir::Param {
                name: "x".to_string(),
                param_type: TypeRef {
                    nullable: false,
                    kind: TypeRefKind::Primitive {
                        name: "double".into(),
                    },
                },
            }],
            return_type: TypeRef {
                nullable: false,
                kind: TypeRefKind::Primitive {
                    name: "double".into(),
                },
            },
            inline: false,
            variadic: false,
            source: None,
            provenance: None,
            doc_refs: None,
            objc_exposed: true,
            swift_fn: None,
        });
        let result = emit_framework(&fw, tmp.path()).unwrap();
        assert_eq!(result.functions_emitted, 1);
        assert!(tmp.path().join("testkit/functions.rkt").exists());
        // functions.rkt should be in main.rkt
        let main_content = std::fs::read_to_string(tmp.path().join("testkit/main.rkt")).unwrap();
        assert!(main_content.contains("\"functions.rkt\""));
    }

    #[test]
    fn test_emit_framework_skips_inline_variadic_functions() {
        let tmp = tempfile::tempdir().unwrap();
        let mut fw = make_minimal_framework("TestKit");
        // Only add functions that should be skipped
        fw.functions.push(apianyware_macos_types::ir::Function {
            name: "TKInline".to_string(),
            params: vec![],
            return_type: TypeRef {
                nullable: false,
                kind: TypeRefKind::Primitive {
                    name: "void".into(),
                },
            },
            inline: true,
            variadic: false,
            source: None,
            provenance: None,
            doc_refs: None,
            objc_exposed: true,
            swift_fn: None,
        });
        let result = emit_framework(&fw, tmp.path()).unwrap();
        assert_eq!(result.functions_emitted, 0);
        // No functions.rkt should be generated when all are skipped
        assert!(!tmp.path().join("testkit/functions.rkt").exists());
        let main_content = std::fs::read_to_string(tmp.path().join("testkit/main.rkt")).unwrap();
        assert!(!main_content.contains("functions.rkt"));
    }

    #[test]
    fn test_racket_target_info() {
        assert_eq!(RACKET_TARGET_INFO.id, "racket");
        assert_eq!(RACKET_TARGET_INFO.display_name, "Racket");
    }
}
