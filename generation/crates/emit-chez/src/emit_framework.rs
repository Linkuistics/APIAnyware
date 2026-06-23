//! Top-level chez framework emission.
//!
//! Produces one Chez library per class, plus four companion libraries
//! (`enums.sls`, `constants.sls`, `functions.sls`,
//! `protocols/<proto>.sls`), and a `<framework>.sls` re-export *next to*
//! the framework directory (e.g. `apianyware/appkit.sls` alongside
//! `apianyware/appkit/`) that imports every sibling library and
//! re-exports the union of their exports. Chez's default library-name
//! resolution maps `(apianyware <framework>)` to
//! `<libdir>/apianyware/<framework>.sls`, so the facade must sit at the
//! parent level — not inside the framework dir as a `main.sls`. Chez
//! `library` requires an explicit `(export …)` list, so each
//! sub-emitter exposes a helper returning the names it exports.

use std::io;
use std::path::Path;

use apianyware_emit::code_writer::{CodeWriter, FileEmitter};
use apianyware_emit::naming::class_name_to_lowercase;
use apianyware_emit::target_emitter::{EmitResult, TargetEmitter, TargetInfo};
use apianyware_emit::write_line;
use apianyware_types::ir::Framework;

use crate::emit_class::{generate_class_file_with_exports, generate_struct_file};
use crate::emit_constants::{constant_names, generate_constants_file};
use crate::emit_enums::{enum_value_names, generate_enums_file};
use crate::emit_functions::{count_emittable, function_emittable_names, generate_functions_file};
use crate::emit_protocol::{generate_protocol_file, protocol_exports};
use crate::trampoline::value_struct_names;

pub const CHEZ_TARGET_INFO: TargetInfo = TargetInfo {
    id: "chez",
    display_name: "Chez Scheme",
    generated_subdir: "apianyware",
};

pub struct ChezEmitter;

impl TargetEmitter for ChezEmitter {
    fn target_info(&self) -> &TargetInfo {
        &CHEZ_TARGET_INFO
    }

    fn emit_framework(&self, framework: &Framework, output_dir: &Path) -> io::Result<EmitResult> {
        emit_framework(framework, output_dir)
    }
}

/// One library subentry the `main.sls` re-export needs to import. The
/// `library_path` is the Chez `(apianyware …)` form path that goes into
/// `(import …)`; the `exports` list flows into `main.sls`'s
/// `(export …)` form. `is_protocol` marks delegate-protocol
/// sub-libraries so their exports can be `(rename)`d in case of a name
/// collision with a same-named class sibling (Apple has protocol-class
/// pairs like NSAccessibilityElement / NSAccessibilityElement that
/// would otherwise both export `make-nsaccessibilityelement`).
struct SubLibrary {
    library_path: String,
    exports: Vec<String>,
    is_protocol: bool,
}

pub fn emit_framework(fw: &Framework, output_dir: &Path) -> io::Result<EmitResult> {
    let emitter = FileEmitter::new(output_dir, &fw.name)?;
    let fw_low = fw.name.to_ascii_lowercase();

    let mut files_written: usize = 0;
    let mut sublibraries: Vec<SubLibrary> = Vec::new();

    // The owning framework's value-struct set is the soundness gate for unboxing
    // value-struct params on Swift-native methods (spec §5c). It must be the same
    // slice the global trampoline pass sees, and is threaded into both class and
    // struct emission so the per-type bindings agree on trampoline-vs-deferred.
    let value_structs = value_struct_names(&fw.structs);
    let mut used_filenames: std::collections::HashSet<String> = std::collections::HashSet::new();

    // Class files (ObjC substrate + Swift-native trampoline section, charter #4).
    for cls in &fw.classes {
        let cls_low = class_name_to_lowercase(&cls.name);
        let filename = format!("{}.sls", cls_low);
        let (content, exports) = generate_class_file_with_exports(cls, &fw.name, &value_structs);
        emitter.write_file(&filename, &content)?;
        used_filenames.insert(filename);
        files_written += 1;

        sublibraries.push(SubLibrary {
            library_path: format!("(apianyware {fw_low} {cls_low})"),
            exports,
            is_protocol: false,
        });
    }

    // Swift-native value-struct files (population B, ADR-0030). Only structs that
    // vend at least one bindable trampoline get a file; a plain C struct yields
    // `None`. A struct whose lowercased name collides with a class file (rare) takes
    // a `-struct` suffix so neither clobbers the other.
    for st in &fw.structs {
        let base = class_name_to_lowercase(&st.name);
        let (filename, lib_low) = if used_filenames.contains(&format!("{base}.sls")) {
            (format!("{base}-struct.sls"), format!("{base}-struct"))
        } else {
            (format!("{base}.sls"), base.clone())
        };
        let Some((content, exports)) = generate_struct_file(st, &fw.name, &value_structs, &lib_low)
        else {
            continue;
        };
        emitter.write_file(&filename, &content)?;
        used_filenames.insert(filename);
        files_written += 1;
        sublibraries.push(SubLibrary {
            library_path: format!("(apianyware {fw_low} {lib_low})"),
            exports,
            is_protocol: false,
        });
    }

    // Enums.
    let has_enums = !fw.enums.is_empty();
    if has_enums {
        let content = generate_enums_file(&fw.enums, &fw.name);
        emitter.write_file("enums.sls", &content)?;
        files_written += 1;
        sublibraries.push(SubLibrary {
            library_path: format!("(apianyware {fw_low} enums)"),
            exports: enum_value_names(&fw.enums),
            is_protocol: false,
        });
    }

    // Constants.
    let has_constants = !fw.constants.is_empty();
    if has_constants {
        let content = generate_constants_file(&fw.constants, &fw.name);
        emitter.write_file("constants.sls", &content)?;
        files_written += 1;
        sublibraries.push(SubLibrary {
            library_path: format!("(apianyware {fw_low} constants)"),
            exports: constant_names(&fw.constants),
            is_protocol: false,
        });
    }

    // C functions (direct ObjC-exposed + Swift-native trampolined residual).
    let emittable_functions = count_emittable(&fw.functions, &fw.name, &fw.structs);
    let has_functions = emittable_functions > 0;
    if has_functions {
        let content = generate_functions_file(&fw.functions, &fw.name, &fw.structs);
        emitter.write_file("functions.sls", &content)?;
        files_written += 1;
        sublibraries.push(SubLibrary {
            library_path: format!("(apianyware {fw_low} functions)"),
            exports: function_emittable_names(&fw.functions, &fw.name, &fw.structs),
            is_protocol: false,
        });
    }

    // Protocols (only those that declare at least one method).
    let delegate_protocols: Vec<_> = fw
        .protocols
        .iter()
        .filter(|p| !p.required_methods.is_empty() || !p.optional_methods.is_empty())
        .collect();

    for proto in &delegate_protocols {
        let proto_low = class_name_to_lowercase(&proto.name);
        let filename = format!("{}.sls", proto_low);
        let content = generate_protocol_file(proto, &fw.name);
        emitter.write_subdir_file("protocols", &filename, &content)?;
        files_written += 1;
        sublibraries.push(SubLibrary {
            library_path: format!("(apianyware {fw_low} protocols {proto_low})"),
            exports: protocol_exports(proto),
            is_protocol: true,
        });
    }

    // Per-framework re-export: written one level up as `<framework>.sls`
    // so Chez's library-name resolver finds it for `(import (apianyware
    // <framework>))`. See design spec §8.
    let main_content = generate_main_file(&fw.name, &sublibraries);
    let facade_path = output_dir.join(format!("{}.sls", fw_low));
    std::fs::write(&facade_path, main_content)?;
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

fn generate_main_file(framework: &str, sublibraries: &[SubLibrary]) -> String {
    use std::collections::HashMap;

    let mut w = CodeWriter::new();
    let fw_low = framework.to_ascii_lowercase();
    write_line!(
        w,
        ";; Generated {} bindings — re-exports every emitted library",
        framework
    );
    write_line!(w, "(library (apianyware {})", fw_low);

    // Tally every name as it would land in main.sls's body if each
    // sub-library were imported unchanged. Names that show up more than
    // once require disambiguation — Apple ships class/protocol pairs
    // (e.g. NSAccessibilityElement) that would otherwise both export
    // `make-nsaccessibilityelement`. The convention: the *protocol* is
    // the side that takes the `-protocol` suffix in main.sls, leaving
    // the natural unsuffixed name for the class.
    let mut name_counts: HashMap<&str, usize> = HashMap::new();
    for s in sublibraries {
        for n in &s.exports {
            *name_counts.entry(n.as_str()).or_default() += 1;
        }
    }
    let needs_rename = |is_protocol: bool, name: &str| -> bool {
        is_protocol && name_counts.get(name).copied().unwrap_or(0) > 1
    };
    let protocol_renamed = |name: &str| format!("{name}-protocol");

    // Final export list — the names actually visible from the flat
    // import. Builds in IR order, dedup at the end.
    let mut all_exports: Vec<String> = Vec::new();
    for s in sublibraries {
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

    if all_exports.is_empty() {
        w.line("  (export)");
    } else {
        w.line("  (export");
        for n in &all_exports {
            write_line!(w, "    {}", n);
        }
        w.line("    )");
    }

    w.line("  (import");
    for s in sublibraries {
        // Collect the renames this sub-library needs. A `rename` form
        // names every renamed identifier as a `(from to)` pair inside
        // `(rename (lib) (from1 to1) (from2 to2) …)`.
        let renames: Vec<(String, String)> = s
            .exports
            .iter()
            .filter(|n| needs_rename(s.is_protocol, n))
            .map(|n| (n.clone(), protocol_renamed(n)))
            .collect();
        if renames.is_empty() {
            write_line!(w, "    {}", s.library_path);
        } else {
            write_line!(w, "    (rename {}", s.library_path);
            for (from, to) in &renames {
                write_line!(w, "            ({} {})", from, to);
            }
            w.line("            )");
        }
    }
    w.line("    )");
    w.blank_line();
    w.line(")");

    w.finish()
}

#[cfg(test)]
mod tests {
    use super::*;
    use apianyware_types::ir::{
        Class, Constant, Enum, EnumValue, Function, Method, Param, Protocol,
    };
    use apianyware_types::type_ref::{TypeRef, TypeRefKind};

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
    fn chez_target_info() {
        let e = ChezEmitter;
        assert_eq!(e.target_info().id, "chez");
        assert_eq!(e.target_info().display_name, "Chez Scheme");
    }

    #[test]
    fn empty_framework_writes_just_main() {
        let tmp = tempfile::tempdir().unwrap();
        let fw = make_minimal_framework("TestKit");
        let res = emit_framework(&fw, tmp.path()).unwrap();
        assert_eq!(res.files_written, 1);
        assert!(tmp.path().join("testkit.sls").exists());
        let main = std::fs::read_to_string(tmp.path().join("testkit.sls")).unwrap();
        assert!(main.contains("(library (apianyware testkit)"));
        assert!(main.contains("  (export)"));
    }

    #[test]
    fn framework_with_one_class_includes_class_in_main_import() {
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
        let res = emit_framework(&fw, tmp.path()).unwrap();
        assert_eq!(res.classes_emitted, 1);
        assert!(tmp.path().join("foundation/nsobject.sls").exists());
        let main = std::fs::read_to_string(tmp.path().join("foundation.sls")).unwrap();
        assert!(main.contains("(apianyware foundation nsobject)"));
        // NSObject.description goes through the per-class file's exports.
        assert!(main.contains("nsobject-description"));
    }

    #[test]
    fn framework_with_enums_writes_enums_sls_and_reexports_values() {
        let tmp = tempfile::tempdir().unwrap();
        let mut fw = make_minimal_framework("Foundation");
        fw.enums.push(Enum {
            name: "NSComparisonResult".into(),
            enum_type: TypeRef {
                nullable: false,
                kind: TypeRefKind::Primitive {
                    name: "int64".into(),
                },
            },
            values: vec![EnumValue {
                name: "NSOrderedSame".into(),
                value: 0,
            }],
            source: None,
            provenance: None,
            doc_refs: None,
            objc_exposed: true,
        });
        let res = emit_framework(&fw, tmp.path()).unwrap();
        assert_eq!(res.enums_emitted, 1);
        assert!(tmp.path().join("foundation/enums.sls").exists());
        let main = std::fs::read_to_string(tmp.path().join("foundation.sls")).unwrap();
        assert!(main.contains("(apianyware foundation enums)"));
        assert!(main.contains("NSOrderedSame"));
    }

    #[test]
    fn framework_with_constants_writes_constants_sls() {
        let tmp = tempfile::tempdir().unwrap();
        let mut fw = make_minimal_framework("PDFKit");
        fw.constants.push(Constant {
            name: "PDFViewPageChangedNotification".into(),
            constant_type: TypeRef {
                nullable: false,
                kind: TypeRefKind::Class {
                    name: "NSString".into(),
                    framework: None,
                    params: vec![],
                },
            },
            source: None,
            provenance: None,
            doc_refs: None,
            macro_value: None,
            objc_exposed: true,
        });
        let res = emit_framework(&fw, tmp.path()).unwrap();
        assert_eq!(res.constants_emitted, 1);
        assert!(tmp.path().join("pdfkit/constants.sls").exists());
        let main = std::fs::read_to_string(tmp.path().join("pdfkit.sls")).unwrap();
        assert!(main.contains("(apianyware pdfkit constants)"));
        assert!(main.contains("PDFViewPageChangedNotification"));
    }

    #[test]
    fn framework_with_functions_writes_functions_sls() {
        let tmp = tempfile::tempdir().unwrap();
        let mut fw = make_minimal_framework("TestKit");
        fw.functions.push(Function {
            name: "TKCompute".into(),
            params: vec![Param {
                name: "x".into(),
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
        let res = emit_framework(&fw, tmp.path()).unwrap();
        assert_eq!(res.functions_emitted, 1);
        assert!(tmp.path().join("testkit/functions.sls").exists());
        let main = std::fs::read_to_string(tmp.path().join("testkit.sls")).unwrap();
        assert!(main.contains("(apianyware testkit functions)"));
        assert!(main.contains("TKCompute"));
    }

    #[test]
    fn framework_skips_inline_functions_and_omits_functions_sls() {
        let tmp = tempfile::tempdir().unwrap();
        let mut fw = make_minimal_framework("TestKit");
        fw.functions.push(Function {
            name: "TKInline".into(),
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
        let res = emit_framework(&fw, tmp.path()).unwrap();
        assert_eq!(res.functions_emitted, 0);
        assert!(!tmp.path().join("testkit/functions.sls").exists());
    }

    #[test]
    fn framework_with_protocol_writes_under_protocols_subdir() {
        let tmp = tempfile::tempdir().unwrap();
        let mut fw = make_minimal_framework("AppKit");
        fw.protocols.push(Protocol {
            name: "NSWindowDelegate".into(),
            inherits: vec![],
            required_methods: vec![],
            optional_methods: vec![Method {
                selector: "windowWillClose:".into(),
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
        let res = emit_framework(&fw, tmp.path()).unwrap();
        assert_eq!(res.protocols_emitted, 1);
        assert!(tmp
            .path()
            .join("appkit/protocols/nswindowdelegate.sls")
            .exists());
        let main = std::fs::read_to_string(tmp.path().join("appkit.sls")).unwrap();
        assert!(main.contains("(apianyware appkit protocols nswindowdelegate)"));
        assert!(main.contains("make-nswindowdelegate"));
    }

    #[test]
    fn empty_protocols_are_skipped() {
        let tmp = tempfile::tempdir().unwrap();
        let mut fw = make_minimal_framework("AppKit");
        fw.protocols.push(Protocol {
            name: "EmptyProto".into(),
            inherits: vec![],
            required_methods: vec![],
            optional_methods: vec![],
            properties: vec![],
            source: None,
            provenance: None,
            doc_refs: None,
            objc_exposed: true,
        });
        let res = emit_framework(&fw, tmp.path()).unwrap();
        assert_eq!(res.protocols_emitted, 0);
        assert!(!tmp.path().join("appkit/protocols").exists());
    }
}
