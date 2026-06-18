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
//! **Status (leaf 040/020/030 — manifest class graph):** the orchestrator + the
//! facade-generation machinery (the [`SubModule`] collection + collision-rename
//! pass) stand up the empty framework; the **class loop** emits one module per
//! class (its `defclass`-graph slice + proc surface) and one per synthesized bare
//! intermediate node, resolving parents via [`build_class_graph`]. The remaining
//! per-construct loops (enums, constants, functions, protocols) are added by the
//! sibling leaves, each pushing its emitted modules onto `submodules`.

use std::io;
use std::path::Path;

use apianyware_macos_emit::code_writer::CodeWriter;
use apianyware_macos_emit::enrichment::class_error_selectors;
use apianyware_macos_emit::target_emitter::{EmitResult, TargetEmitter, TargetInfo};
use apianyware_macos_emit::write_line;
use apianyware_macos_types::ir::Framework;

use crate::class_graph::{build_class_graph, ClassRegistry, ParentRef};
use crate::emit_class::{generate_bare_module, generate_class_file_with_parent};
use crate::emit_constants::{constant_names, generate_constants_file};
use crate::emit_enums::{enum_value_names, generate_enums_file};
use crate::emit_functions::{count_emittable, function_emittable_names, generate_functions_file};
use crate::emit_protocol::{generate_protocol_file, protocol_exports};
use crate::naming::class_module_stem;
use crate::protocol_registry::ProtocolRegistry;

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

/// The Gerbil emitter. Carries the cross-framework [`ClassRegistry`] used to
/// resolve manifest-graph parents that live in another framework (ADR-0020),
/// and the cross-framework [`ProtocolRegistry`] backing conformed-protocol
/// method flattening (leaf 120). Default-constructed both registries are
/// empty — same-framework parents still resolve from each framework's own
/// class set and emission degrades to own-methods-only; the CLI pre-pass
/// (leaf 060) builds the global registries and constructs the emitter with
/// [`GerbilEmitter::with_registries`].
#[derive(Default)]
pub struct GerbilEmitter {
    class_registry: ClassRegistry,
    protocol_registry: ProtocolRegistry,
}

impl GerbilEmitter {
    pub fn new() -> Self {
        Self::default()
    }

    pub fn with_registries(
        class_registry: ClassRegistry,
        protocol_registry: ProtocolRegistry,
    ) -> Self {
        Self {
            class_registry,
            protocol_registry,
        }
    }
}

impl TargetEmitter for GerbilEmitter {
    fn target_info(&self) -> &TargetInfo {
        &GERBIL_TARGET_INFO
    }

    fn emit_framework(&self, framework: &Framework, output_dir: &Path) -> io::Result<EmitResult> {
        emit_framework(
            framework,
            output_dir,
            &self.class_registry,
            &self.protocol_registry,
        )
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

pub fn emit_framework(
    fw: &Framework,
    output_dir: &Path,
    registry: &ClassRegistry,
    protocols: &ProtocolRegistry,
) -> io::Result<EmitResult> {
    let fw_low = fw.name.to_ascii_lowercase();

    let mut files_written: usize = 0;
    let mut submodules: Vec<SubModule> = Vec::new();

    std::fs::create_dir_all(output_dir)?;

    // Resolve the manifest class graph (ADR-0020): each class's Gerbil parent,
    // plus any bare intermediate nodes that must be synthesized so the graph has
    // no dangling parent.
    let graph = build_class_graph(fw, registry);

    // Class modules: one `<fw_low>/<cls>.ss` per class, each emitting its slice
    // of the `defclass` graph (deriving from its resolved parent) + the proc
    // surface. Leaves 040 (surfaces) and the other construct leaves add their
    // forms the same way, each pushing a `SubModule` so the facade re-exports it.
    if !fw.classes.is_empty() || !graph.synthesized.is_empty() {
        let class_dir = output_dir.join(&fw_low);
        std::fs::create_dir_all(&class_dir)?;
        for cls in &fw.classes {
            let cls_low = class_module_stem(&cls.name);
            let parent = graph
                .parents
                .get(&cls.name)
                .cloned()
                .unwrap_or(ParentRef::RuntimeRoot);
            // The class's NSError out-param selectors (ADR-0006), from the
            // shared enrichment helper so racket + gerbil key off the same set.
            let error_selectors = class_error_selectors(fw.enrichment.as_ref(), &cls.name);
            let (content, exports) = generate_class_file_with_parent(
                cls,
                &fw.name,
                &parent,
                &error_selectors,
                protocols,
            );
            std::fs::write(class_dir.join(format!("{cls_low}.ss")), content)?;
            files_written += 1;
            submodules.push(SubModule {
                import_path: SubModule::import_path(&fw_low, &[&cls_low]),
                exports,
                is_protocol: false,
            });
        }
        // Synthesized bare intermediate nodes: minimal `defclass`-only modules so
        // a child's local parent import resolves (no dangling reference).
        for name in &graph.synthesized {
            let cls_low = class_module_stem(name);
            let (content, exports) = generate_bare_module(name, &fw.name);
            std::fs::write(class_dir.join(format!("{cls_low}.ss")), content)?;
            files_written += 1;
            submodules.push(SubModule {
                import_path: SubModule::import_path(&fw_low, &[&cls_low]),
                exports,
                is_protocol: false,
            });
        }
    }

    // Delegate-protocol modules: one `<fw_low>/protocols/<proto>.ss` per ObjC
    // `@protocol` that declares at least one method (empty marker protocols are
    // skipped — there is nothing to delegate). Each builds a `make-<proto>`
    // delegate constructor over the runtime bridge; the facade re-exports them,
    // renaming on a class/protocol name collision (`is_protocol`).
    let delegate_protocols: Vec<_> = fw
        .protocols
        .iter()
        .filter(|p| !p.required_methods.is_empty() || !p.optional_methods.is_empty())
        .collect();
    if !delegate_protocols.is_empty() {
        let protocols_dir = output_dir.join(&fw_low).join("protocols");
        std::fs::create_dir_all(&protocols_dir)?;
        for proto in &delegate_protocols {
            let proto_low = class_module_stem(&proto.name);
            let content = generate_protocol_file(proto, &fw.name);
            std::fs::write(protocols_dir.join(format!("{proto_low}.ss")), content)?;
            files_written += 1;
            submodules.push(SubModule {
                import_path: SubModule::import_path(&fw_low, &["protocols", &proto_low]),
                exports: protocol_exports(proto),
                is_protocol: true,
            });
        }
    }

    // Data modules: `enums.ss`, `constants.ss`, `functions.ss` — written only
    // when the framework has that construct family (node 040 brief). Each ensures
    // the `<fw_low>/` directory exists (a framework may have e.g. constants but no
    // classes), writes its module, and pushes a `SubModule` so the facade
    // re-exports it. None is a protocol → no `-protocol` rename.
    let fw_dir = output_dir.join(&fw_low);
    let mut emit_data_module =
        |stem: &str, content: String, exports: Vec<String>| -> io::Result<()> {
            std::fs::create_dir_all(&fw_dir)?;
            std::fs::write(fw_dir.join(format!("{stem}.ss")), content)?;
            files_written += 1;
            submodules.push(SubModule {
                import_path: SubModule::import_path(&fw_low, &[stem]),
                exports,
                is_protocol: false,
            });
            Ok(())
        };

    let enums_emitted = !fw.enums.is_empty();
    if enums_emitted {
        emit_data_module(
            "enums",
            generate_enums_file(&fw.enums, &fw.name),
            enum_value_names(&fw.enums),
        )?;
    }
    let constants_emitted = !fw.constants.is_empty();
    if constants_emitted {
        emit_data_module(
            "constants",
            generate_constants_file(&fw.constants, &fw.name),
            constant_names(&fw.constants),
        )?;
    }
    let functions_emitted = count_emittable(&fw.functions, &fw.name, &fw.structs) > 0;
    if functions_emitted {
        emit_data_module(
            "functions",
            generate_functions_file(&fw.functions, &fw.name, &fw.structs),
            function_emittable_names(&fw.functions, &fw.name, &fw.structs),
        )?;
    }

    // Per-framework facade: `<framework>.ss` next to the framework directory.
    let facade = generate_facade_file(&fw.name, &submodules);
    let facade_path = output_dir.join(format!("{fw_low}.ss"));
    std::fs::write(&facade_path, facade)?;

    Ok(EmitResult {
        files_written: files_written + 1,
        classes_emitted: fw.classes.len(),
        protocols_emitted: delegate_protocols.len(),
        enums_emitted: if enums_emitted { fw.enums.len() } else { 0 },
        functions_emitted: count_emittable(&fw.functions, &fw.name, &fw.structs),
        constants_emitted: if constants_emitted {
            fw.constants.len()
        } else {
            0
        },
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
        let e = GerbilEmitter::new();
        assert_eq!(e.target_info().id, "gerbil");
        assert_eq!(e.target_info().display_name, "Gerbil Scheme");
        assert_eq!(e.target_info().generated_subdir, "lib");
    }

    #[test]
    fn empty_framework_writes_just_facade() {
        let tmp = tempfile::tempdir().unwrap();
        let fw = make_minimal_framework("TestKit");
        let res = emit_framework(
            &fw,
            tmp.path(),
            &ClassRegistry::new(),
            &ProtocolRegistry::new(),
        )
        .unwrap();
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

    fn class_with(name: &str, superclass: &str) -> apianyware_macos_types::ir::Class {
        apianyware_macos_types::ir::Class {
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
        }
    }

    #[test]
    fn emits_class_graph_chain_and_cross_framework_import() {
        // A same-framework chain NSResponder -> NSObject(root), NSView ->
        // NSResponder, plus a cross-framework parent resolved via the registry.
        let tmp = tempfile::tempdir().unwrap();
        let mut fw = make_minimal_framework("AppKit");
        fw.classes = vec![
            class_with("NSResponder", "NSObject"),
            class_with("NSView", "NSResponder"),
            class_with("NSTextStorage", "NSMutableAttributedString"),
        ];
        let mut reg = ClassRegistry::new();
        reg.insert("NSMutableAttributedString", "foundation");

        emit_framework(&fw, tmp.path(), &reg, &ProtocolRegistry::new()).unwrap();

        let responder = std::fs::read_to_string(tmp.path().join("appkit/nsresponder.ss")).unwrap();
        assert!(responder.contains("(defclass (NSResponder NSObject) () transparent: #t)"));

        let view = std::fs::read_to_string(tmp.path().join("appkit/nsview.ss")).unwrap();
        assert!(view.contains("(defclass (NSView NSResponder) () transparent: #t)"));
        assert!(view.contains(":gerbil-bindings/appkit/nsresponder"));

        let storage = std::fs::read_to_string(tmp.path().join("appkit/nstextstorage.ss")).unwrap();
        assert!(storage
            .contains("(defclass (NSTextStorage NSMutableAttributedString) () transparent: #t)"));
        assert!(storage.contains(":gerbil-bindings/foundation/nsmutableattributedstring"));

        // The facade re-exports every class's Gerbil identifier.
        let facade = std::fs::read_to_string(tmp.path().join("appkit.ss")).unwrap();
        assert!(facade.contains("NSView"));
        assert!(facade.contains("NSResponder"));
    }

    #[test]
    fn synthesized_bare_intermediate_is_written_and_linked() {
        // A leaf whose super is an uncollected, unowned intermediate: a bare
        // module is synthesized for it and the leaf links to it locally.
        let tmp = tempfile::tempdir().unwrap();
        let mut fw = make_minimal_framework("Widgets");
        fw.classes = vec![class_with("Leaf", "Mid")];

        emit_framework(
            &fw,
            tmp.path(),
            &ClassRegistry::new(),
            &ProtocolRegistry::new(),
        )
        .unwrap();

        let mid = std::fs::read_to_string(tmp.path().join("widgets/mid.ss")).unwrap();
        assert!(mid.contains("synthesized bare class-graph node"));
        assert!(mid.contains("(defclass (Mid NSObject) () transparent: #t)"));

        let leaf = std::fs::read_to_string(tmp.path().join("widgets/leaf.ss")).unwrap();
        assert!(leaf.contains("(defclass (Leaf Mid) () transparent: #t)"));
        assert!(leaf.contains(":gerbil-bindings/widgets/mid"));
    }

    fn method(sel: &str, ret: &str) -> apianyware_macos_types::ir::Method {
        use apianyware_macos_types::ir::Method;
        use apianyware_macos_types::type_ref::{TypeRef, TypeRefKind};
        Method {
            selector: sel.into(),
            class_method: false,
            init_method: false,
            params: vec![],
            return_type: TypeRef {
                nullable: false,
                kind: TypeRefKind::Primitive { name: ret.into() },
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
        }
    }

    fn protocol(name: &str, optional: Vec<apianyware_macos_types::ir::Method>) -> Protocol {
        use apianyware_macos_types::ir::Protocol as P;
        P {
            name: name.into(),
            inherits: vec![],
            required_methods: vec![],
            optional_methods: optional,
            properties: vec![],
            source: None,
            provenance: None,
            doc_refs: None,
            objc_exposed: true,
        }
    }

    use apianyware_macos_types::ir::Protocol;

    #[test]
    fn framework_with_protocol_writes_under_protocols_subdir() {
        let tmp = tempfile::tempdir().unwrap();
        let mut fw = make_minimal_framework("AppKit");
        fw.protocols.push(protocol(
            "NSWindowDelegate",
            vec![method("windowWillClose:", "void")],
        ));

        let res = emit_framework(
            &fw,
            tmp.path(),
            &ClassRegistry::new(),
            &ProtocolRegistry::new(),
        )
        .unwrap();
        assert_eq!(res.protocols_emitted, 1);

        let module = tmp.path().join("appkit/protocols/nswindowdelegate.ss");
        assert!(module.exists());
        let body = std::fs::read_to_string(&module).unwrap();
        assert!(body.contains("make-nswindowdelegate"));

        // The facade imports the protocol module and re-exports its names.
        let facade = std::fs::read_to_string(tmp.path().join("appkit.ss")).unwrap();
        assert!(facade.contains(":gerbil-bindings/appkit/protocols/nswindowdelegate"));
        assert!(facade.contains("make-nswindowdelegate"));
    }

    #[test]
    fn empty_protocols_are_skipped() {
        let tmp = tempfile::tempdir().unwrap();
        let mut fw = make_minimal_framework("AppKit");
        fw.protocols.push(protocol("NSEmptyMarker", vec![]));

        let res = emit_framework(
            &fw,
            tmp.path(),
            &ClassRegistry::new(),
            &ProtocolRegistry::new(),
        )
        .unwrap();
        assert_eq!(res.protocols_emitted, 0);
        assert!(!tmp.path().join("appkit/protocols").exists());
    }

    #[test]
    fn class_protocol_name_collision_renames_protocol_in_facade() {
        // Apple ships class/protocol pairs (e.g. NSAccessibilityElement); the
        // protocol export is the side that takes the `-protocol` suffix.
        let tmp = tempfile::tempdir().unwrap();
        let mut fw = make_minimal_framework("AppKit");
        fw.classes = vec![class_with("NSAccessibilityElement", "NSObject")];
        fw.protocols.push(protocol(
            "NSAccessibilityElement",
            vec![method("accessibilityFrame", "void")],
        ));

        emit_framework(
            &fw,
            tmp.path(),
            &ClassRegistry::new(),
            &ProtocolRegistry::new(),
        )
        .unwrap();

        let facade = std::fs::read_to_string(tmp.path().join("appkit.ss")).unwrap();
        // The colliding protocol constructor is renamed; the class keeps its name.
        assert!(
            facade.contains("(make-nsaccessibilityelement make-nsaccessibilityelement-protocol)")
        );
        assert!(facade.contains("make-nsaccessibilityelement-protocol"));
    }

    #[test]
    fn emits_data_modules_and_reexports_them() {
        use apianyware_macos_types::ir::{Constant, Enum, EnumValue, Function};
        use apianyware_macos_types::type_ref::{TypeRef, TypeRefKind};

        let tmp = tempfile::tempdir().unwrap();
        let mut fw = make_minimal_framework("TestKit");
        fw.enums = vec![Enum {
            name: "TKState".into(),
            enum_type: TypeRef {
                nullable: false,
                kind: TypeRefKind::Primitive {
                    name: "int64".into(),
                },
            },
            values: vec![EnumValue {
                name: "TKOff".into(),
                value: 0,
            }],
            source: None,
            provenance: None,
            doc_refs: None,
            objc_exposed: true,
        }];
        fw.constants = vec![Constant {
            name: "TKVersionKey".into(),
            constant_type: TypeRef {
                nullable: false,
                kind: TypeRefKind::Id,
            },
            source: None,
            provenance: None,
            doc_refs: None,
            macro_value: None,
            objc_exposed: true,
        }];
        fw.functions = vec![Function {
            name: "TKReset".into(),
            params: vec![],
            return_type: TypeRef {
                nullable: false,
                kind: TypeRefKind::Primitive {
                    name: "void".into(),
                },
            },
            inline: false,
            variadic: false,
            source: None,
            provenance: None,
            doc_refs: None,
            objc_exposed: true,
            swift_fn: None,
        }];

        let res = emit_framework(
            &fw,
            tmp.path(),
            &ClassRegistry::new(),
            &ProtocolRegistry::new(),
        )
        .unwrap();
        assert_eq!(res.enums_emitted, 1);
        assert_eq!(res.constants_emitted, 1);
        assert_eq!(res.functions_emitted, 1);

        // The three data modules land under the framework directory.
        assert!(tmp.path().join("testkit/enums.ss").exists());
        assert!(tmp.path().join("testkit/constants.ss").exists());
        assert!(tmp.path().join("testkit/functions.ss").exists());

        // The facade imports all three and re-exports their names (the `main`
        // re-export of CONTEXT.md).
        let facade = std::fs::read_to_string(tmp.path().join("testkit.ss")).unwrap();
        assert!(facade.contains(":gerbil-bindings/testkit/enums"));
        assert!(facade.contains(":gerbil-bindings/testkit/constants"));
        assert!(facade.contains(":gerbil-bindings/testkit/functions"));
        assert!(facade.contains("TKOff"));
        assert!(facade.contains("TKVersionKey"));
        assert!(facade.contains("TKReset"));
    }

    #[test]
    fn data_modules_skipped_when_empty() {
        let tmp = tempfile::tempdir().unwrap();
        let fw = make_minimal_framework("TestKit");
        let res = emit_framework(
            &fw,
            tmp.path(),
            &ClassRegistry::new(),
            &ProtocolRegistry::new(),
        )
        .unwrap();
        assert_eq!(res.enums_emitted, 0);
        assert_eq!(res.constants_emitted, 0);
        assert_eq!(res.functions_emitted, 0);
        assert!(!tmp.path().join("testkit/enums.ss").exists());
        assert!(!tmp.path().join("testkit").exists());
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
