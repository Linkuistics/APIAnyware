//! Racket protocol file code generation.
//!
//! Generates protocol definition files with `make-<protocol>` helper functions
//! for creating delegate instances.

use apianyware_macos_emit::code_writer::CodeWriter;
use apianyware_macos_emit::naming::camel_to_kebab;
use apianyware_macos_emit::write_line;
use apianyware_macos_types::enrichment::EnrichmentData;
use apianyware_macos_types::ir::{Method, Protocol};
use apianyware_macos_types::type_ref::{TypeRef, TypeRefKind};

use crate::enrichment_comments::EnrichmentNotes;

/// Contract for the protocol constructor (`make-<proto>`).
///
/// Accepts alternating selector strings and handler procedures via rest args,
/// returns an opaque delegate value. Contracts cannot express the alternation
/// precisely, so each rest element is `(or/c string? procedure?)`.
const MAKE_DELEGATE_CONTRACT: &str = "(->* () () #:rest (listof (or/c string? procedure?)) any/c)";

/// Contract for the protocol selector-list value (`<proto>-selectors`).
const SELECTOR_LIST_CONTRACT: &str = "(listof string?)";

/// Generate a Racket protocol definition file.
pub fn generate_protocol_file(
    proto: &Protocol,
    framework: &str,
    enrichment: Option<&EnrichmentData>,
) -> String {
    let mut w = CodeWriter::new();
    let name = &proto.name;
    let lower_name = name.to_ascii_lowercase();
    let notes = EnrichmentNotes::for_protocol(enrichment, name);

    let req = &proto.required_methods;
    let opt = &proto.optional_methods;
    let all_methods: Vec<&Method> = req.iter().chain(opt.iter()).collect();

    let void_methods: Vec<&&Method> = all_methods
        .iter()
        .filter(|m| method_return_kind(m) == "void")
        .collect();
    let bool_methods: Vec<&&Method> = all_methods
        .iter()
        .filter(|m| method_return_kind(m) == "bool")
        .collect();
    let id_methods: Vec<&&Method> = all_methods
        .iter()
        .filter(|m| method_return_kind(m) == "id")
        .collect();
    let int_methods: Vec<&&Method> = all_methods
        .iter()
        .filter(|m| method_return_kind(m) == "int")
        .collect();
    let long_methods: Vec<&&Method> = all_methods
        .iter()
        .filter(|m| method_return_kind(m) == "long")
        .collect();

    let helper_name = format!("make-{lower_name}");

    // Header
    w.line("#lang racket/base");
    write_line!(
        w,
        ";; Generated protocol definition for {} ({})",
        name,
        framework
    );
    w.line(";; Do not edit — regenerate from enriched IR");
    w.line(";;");
    write_line!(w, ";; {} defines {} methods:", name, all_methods.len());

    // Threading note: surface main-thread affinity from enrichment data.
    if notes.is_main_thread() {
        w.line(";; Threading: this protocol has main-thread-only methods.");
    }

    if !void_methods.is_empty() {
        write_line!(w, ";;   void-returning ({}):", void_methods.len());
        for m in &void_methods {
            w.line(&method_listing_line(m, &notes));
        }
    }
    if !bool_methods.is_empty() {
        write_line!(w, ";;   bool-returning ({}):", bool_methods.len());
        for m in &bool_methods {
            w.line(&method_listing_line(m, &notes));
        }
    }
    if !id_methods.is_empty() {
        write_line!(w, ";;   id-returning ({}):", id_methods.len());
        for m in &id_methods {
            w.line(&method_listing_line(m, &notes));
        }
    }
    if !int_methods.is_empty() {
        write_line!(w, ";;   int-returning ({}):", int_methods.len());
        for m in &int_methods {
            w.line(&method_listing_line(m, &notes));
        }
    }
    if !long_methods.is_empty() {
        write_line!(w, ";;   long-returning ({}):", long_methods.len());
        for m in &long_methods {
            w.line(&method_listing_line(m, &notes));
        }
    }

    w.blank_line();
    w.line("(require racket/contract");
    w.line("         \"../../../../runtime/delegate.rkt\")");
    w.blank_line();
    w.line("(provide/contract");
    write_line!(w, "  [{} {}]", helper_name, MAKE_DELEGATE_CONTRACT);
    write_line!(
        w,
        "  [{}-selectors {}])",
        lower_name,
        SELECTOR_LIST_CONTRACT
    );
    w.blank_line();

    // Selector list
    w.line(";; All selectors in this protocol");
    write_line!(w, "(define {}-selectors", lower_name);
    w.raw("  '(");
    for (i, m) in all_methods.iter().enumerate() {
        if i > 0 {
            w.raw("\n    ");
        }
        w.raw(&format!("\"{}\"", m.selector));
    }
    w.raw_line("))\n");

    // Convenience constructor
    write_line!(w, ";; Create a {} delegate.", name);
    w.line(";; Pass selector string → handler procedure pairs.");
    w.line(";; Example:");
    write_line!(w, ";;   ({}", helper_name);
    if let Some(m) = void_methods.first() {
        let param_strs = format_param_names(m);
        write_line!(w, ";;     \"{}\" (lambda ({}) ...)", m.selector, param_strs,);
    }
    if let Some(m) = bool_methods.first() {
        let param_strs = format_param_names(m);
        write_line!(
            w,
            ";;     \"{}\" (lambda ({}) ... #t)",
            m.selector,
            param_strs,
        );
    }
    w.line(";;   )");
    write_line!(w, "(define ({} . selector+handler-pairs)", helper_name);

    // Build return-types hash for non-void methods
    let non_void: Vec<(&str, &str)> = bool_methods
        .iter()
        .map(|m| (m.selector.as_str(), "bool"))
        .chain(id_methods.iter().map(|m| (m.selector.as_str(), "id")))
        .chain(int_methods.iter().map(|m| (m.selector.as_str(), "int")))
        .chain(long_methods.iter().map(|m| (m.selector.as_str(), "long")))
        .collect();

    // Build param-types hash for methods with object params
    let has_object_params = any_method_has_object_param(&all_methods);

    let has_keywords = !non_void.is_empty() || has_object_params;

    if !has_keywords {
        w.line("  (apply make-delegate selector+handler-pairs))");
    } else {
        w.line("  (apply make-delegate");

        if !non_void.is_empty() {
            w.line("    #:return-types");
            w.raw("    (hash");
            for (sel, kind) in &non_void {
                w.raw(&format!(" \"{sel}\" '{kind}"));
            }
            w.raw_line(")");
        }

        if has_object_params {
            w.line("    #:param-types");
            w.raw("    (hash");
            for m in &all_methods {
                if m.params.is_empty() {
                    continue;
                }
                let types: Vec<&str> = m
                    .params
                    .iter()
                    .map(|p| param_type_symbol(&p.param_type))
                    .collect();
                w.raw(&format!(" \"{}\" '({})", m.selector, types.join(" ")));
            }
            w.raw_line(")");
        }

        w.line("    selector+handler-pairs))");
    }

    w.finish()
}

fn method_return_kind(method: &Method) -> &'static str {
    match &method.return_type.kind {
        TypeRefKind::Primitive { name } if name == "void" => "void",
        TypeRefKind::Primitive { name } if name == "bool" => "bool",
        TypeRefKind::Primitive { name }
            if matches!(
                name.as_str(),
                "int8" | "int16" | "int32" | "uint8" | "uint16" | "uint32"
            ) =>
        {
            "int"
        }
        TypeRefKind::Primitive { name } if matches!(name.as_str(), "int64" | "uint64") => "long",
        TypeRefKind::Class { .. } | TypeRefKind::Id | TypeRefKind::Instancetype => "id",
        _ => "void", // default for unhandled types (structs/aliases)
    }
}

/// Map an IR param type to the delegate param-type symbol for `#:param-types`.
fn param_type_symbol(type_ref: &TypeRef) -> &'static str {
    match &type_ref.kind {
        TypeRefKind::Class { .. } | TypeRefKind::Id | TypeRefKind::Instancetype => "object",
        TypeRefKind::Primitive { name } if name == "bool" => "bool",
        TypeRefKind::Primitive { name }
            if matches!(
                name.as_str(),
                "int8" | "int16" | "int32" | "uint8" | "uint16" | "uint32"
            ) =>
        {
            "int"
        }
        TypeRefKind::Primitive { name } if matches!(name.as_str(), "int64" | "uint64") => "long",
        _ => "pointer",
    }
}

/// Check if any method in the protocol has at least one object param
/// (meaning #:param-types would add value via auto-wrapping).
fn any_method_has_object_param(methods: &[&Method]) -> bool {
    methods.iter().any(|m| {
        m.params
            .iter()
            .any(|p| param_type_symbol(&p.param_type) == "object")
    })
}

/// Build one header-listing comment line for a protocol method.
///
/// The base form is `;;     {selector}  ({params})`. When enrichment data
/// carries notes for the method's selector, they are appended after an em-dash
/// separator, joined by `; `.
fn method_listing_line(method: &Method, notes: &EnrichmentNotes) -> String {
    let base = format!(
        ";;     {}  ({})",
        method.selector,
        format_method_params(method)
    );
    let method_notes = notes.notes_for(&method.selector);
    if method_notes.is_empty() {
        base
    } else {
        format!("{base}  — {}", method_notes.join("; "))
    }
}

fn format_method_params(method: &Method) -> String {
    method
        .params
        .iter()
        .map(|p| {
            let type_desc = match &p.param_type.kind {
                TypeRefKind::Class { name, .. } => name.clone(),
                TypeRefKind::Id => "id".to_string(),
                TypeRefKind::Instancetype => "instancetype".to_string(),
                TypeRefKind::Struct { name } => name.clone(),
                TypeRefKind::Alias { name, .. } => name.clone(),
                TypeRefKind::Primitive { name } => name.clone(),
                TypeRefKind::Block { .. } => "block".to_string(),
                TypeRefKind::Selector => "selector".to_string(),
                TypeRefKind::ClassRef => "class_ref".to_string(),
                TypeRefKind::FunctionPointer { name, .. } => name
                    .clone()
                    .unwrap_or_else(|| "function_pointer".to_string()),
                TypeRefKind::CString => "c_string".to_string(),
                TypeRefKind::Pointer => "pointer".to_string(),
            };
            format!("{}:{}", p.name, type_desc)
        })
        .collect::<Vec<_>>()
        .join(", ")
}

fn format_param_names(method: &Method) -> String {
    let names: Vec<String> = method
        .params
        .iter()
        .map(|p| camel_to_kebab(&p.name))
        .collect();
    names.join(" ")
}

#[cfg(test)]
mod tests {
    use super::*;
    use apianyware_macos_types::ir::{Method, Param};
    use apianyware_macos_types::type_ref::TypeRef;

    fn make_method(selector: &str, params: Vec<Param>, return_kind: TypeRefKind) -> Method {
        Method {
            selector: selector.to_string(),
            class_method: false,
            init_method: false,
            params,
            return_type: TypeRef {
                nullable: false,
                kind: return_kind,
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
        }
    }

    fn void_method(selector: &str, params: Vec<Param>) -> Method {
        make_method(
            selector,
            params,
            TypeRefKind::Primitive {
                name: "void".into(),
            },
        )
    }

    fn bool_method(selector: &str) -> Method {
        make_method(
            selector,
            vec![],
            TypeRefKind::Primitive {
                name: "bool".into(),
            },
        )
    }

    fn id_method(selector: &str) -> Method {
        make_method(selector, vec![], TypeRefKind::Instancetype)
    }

    fn int32_method(selector: &str, params: Vec<Param>) -> Method {
        make_method(
            selector,
            params,
            TypeRefKind::Primitive {
                name: "int32".into(),
            },
        )
    }

    fn int64_method(selector: &str, params: Vec<Param>) -> Method {
        make_method(
            selector,
            params,
            TypeRefKind::Primitive {
                name: "int64".into(),
            },
        )
    }

    fn uint64_method(selector: &str, params: Vec<Param>) -> Method {
        make_method(
            selector,
            params,
            TypeRefKind::Primitive {
                name: "uint64".into(),
            },
        )
    }

    fn obj_param(name: &str, class: &str) -> Param {
        Param {
            name: name.to_string(),
            param_type: TypeRef {
                nullable: false,
                kind: TypeRefKind::Class {
                    name: class.to_string(),
                    framework: None,
                    params: vec![],
                },
            },
        }
    }

    fn protocol(name: &str, required: Vec<Method>, optional: Vec<Method>) -> Protocol {
        Protocol {
            name: name.to_string(),
            inherits: vec![],
            required_methods: required,
            optional_methods: optional,
            properties: vec![],
            source: None,
            provenance: None,
            doc_refs: None,
        }
    }

    #[test]
    fn test_protocol_emits_provide_contract() {
        let proto = protocol("TKCopying", vec![id_method("copyWithZone:")], vec![]);
        let output = generate_protocol_file(&proto, "TestKit", None);

        assert!(
            output.contains("(require racket/contract"),
            "expected racket/contract require, got:\n{output}"
        );
        assert!(
            output.contains("(provide/contract"),
            "expected provide/contract form, got:\n{output}"
        );
        assert!(
            !output.contains("(provide make-tkcopying"),
            "old plain provide form should be gone, got:\n{output}"
        );
    }

    #[test]
    fn test_protocol_contract_for_constructor() {
        let proto = protocol(
            "TKDelegate",
            vec![void_method(
                "managerDidFinish:",
                vec![obj_param("manager", "TKManager")],
            )],
            vec![],
        );
        let output = generate_protocol_file(&proto, "TestKit", None);

        assert!(
            output.contains(
                "[make-tkdelegate (->* () () #:rest (listof (or/c string? procedure?)) any/c)]"
            ),
            "expected constructor contract, got:\n{output}"
        );
    }

    #[test]
    fn test_protocol_contract_for_selector_list() {
        let proto = protocol(
            "TKDelegate",
            vec![void_method("foo:", vec![obj_param("x", "NSObject")])],
            vec![],
        );
        let output = generate_protocol_file(&proto, "TestKit", None);

        assert!(
            output.contains("[tkdelegate-selectors (listof string?)])"),
            "expected selector list contract, got:\n{output}"
        );
    }

    #[test]
    fn test_protocol_with_mixed_return_types_still_contracted() {
        let proto = protocol(
            "TKMixed",
            vec![
                void_method("didStart:", vec![obj_param("x", "NSObject")]),
                bool_method("shouldContinue"),
                id_method("produceResult"),
            ],
            vec![],
        );
        let output = generate_protocol_file(&proto, "TestKit", None);

        assert!(output.contains("(provide/contract"));
        assert!(output.contains("[make-tkmixed"));
        assert!(output.contains("[tkmixed-selectors (listof string?)])"));
        // Dispatcher body still emits the return-types hash for bool/id methods
        assert!(output.contains("#:return-types"));
    }

    #[test]
    fn test_protocol_empty_methods_still_contracted() {
        let proto = protocol("TKEmpty", vec![], vec![]);
        let output = generate_protocol_file(&proto, "TestKit", None);

        assert!(output.contains("(provide/contract"));
        assert!(output.contains("[make-tkempty"));
        assert!(output.contains("[tkempty-selectors (listof string?)])"));
    }

    #[test]
    fn test_method_return_kind_int32() {
        let m = int32_method("statusCode", vec![]);
        assert_eq!(method_return_kind(&m), "int");
    }

    #[test]
    fn test_method_return_kind_int64() {
        let m = int64_method(
            "numberOfRowsInTableView:",
            vec![obj_param("tableView", "NSTableView")],
        );
        assert_eq!(method_return_kind(&m), "long");
    }

    #[test]
    fn test_method_return_kind_uint64() {
        let m = uint64_method("countOfItems:", vec![obj_param("view", "NSView")]);
        assert_eq!(method_return_kind(&m), "long");
    }

    #[test]
    fn test_protocol_int64_return_emits_return_types_hash() {
        let proto = protocol(
            "TKDataSource",
            vec![
                int64_method(
                    "numberOfRowsInTableView:",
                    vec![obj_param("tableView", "NSTableView")],
                ),
                void_method(
                    "tableView:didSelectRow:",
                    vec![
                        obj_param("tableView", "NSTableView"),
                        obj_param("row", "NSObject"),
                    ],
                ),
            ],
            vec![],
        );
        let output = generate_protocol_file(&proto, "TestKit", None);

        assert!(
            output.contains("\"numberOfRowsInTableView:\" 'long"),
            "expected long return type in hash, got:\n{output}"
        );
        assert!(
            output.contains("#:return-types"),
            "expected return-types keyword, got:\n{output}"
        );
    }

    #[test]
    fn test_protocol_int32_return_emits_int_kind() {
        let proto = protocol("TKStatus", vec![int32_method("statusCode", vec![])], vec![]);
        let output = generate_protocol_file(&proto, "TestKit", None);

        assert!(
            output.contains("\"statusCode\" 'int"),
            "expected int return type in hash, got:\n{output}"
        );
    }

    fn int64_param(name: &str) -> Param {
        Param {
            name: name.to_string(),
            param_type: TypeRef {
                nullable: false,
                kind: TypeRefKind::Primitive {
                    name: "int64".into(),
                },
            },
        }
    }

    #[test]
    fn test_param_type_symbol_object() {
        let tr = TypeRef {
            nullable: false,
            kind: TypeRefKind::Id,
        };
        assert_eq!(param_type_symbol(&tr), "object");
    }

    #[test]
    fn test_param_type_symbol_int64() {
        let tr = TypeRef {
            nullable: false,
            kind: TypeRefKind::Primitive {
                name: "int64".into(),
            },
        };
        assert_eq!(param_type_symbol(&tr), "long");
    }

    #[test]
    fn test_protocol_emits_param_types_for_object_params() {
        let proto = protocol(
            "TKDataSource",
            vec![int64_method(
                "numberOfRows:",
                vec![obj_param("tableView", "NSTableView")],
            )],
            vec![],
        );
        let output = generate_protocol_file(&proto, "TestKit", None);

        assert!(
            output.contains("#:param-types"),
            "expected #:param-types keyword, got:\n{output}"
        );
        assert!(
            output.contains("\"numberOfRows:\" '(object)"),
            "expected object param type for tableView, got:\n{output}"
        );
    }

    #[test]
    fn test_protocol_param_types_mixed() {
        let proto = protocol(
            "TKMixedParams",
            vec![void_method(
                "tableView:didSelectRow:",
                vec![obj_param("tableView", "NSTableView"), int64_param("row")],
            )],
            vec![],
        );
        let output = generate_protocol_file(&proto, "TestKit", None);

        assert!(
            output.contains("\"tableView:didSelectRow:\" '(object long)"),
            "expected mixed param types, got:\n{output}"
        );
    }

    #[test]
    fn test_protocol_no_param_types_when_no_object_params() {
        let proto = protocol("TKPrimitive", vec![void_method("tick", vec![])], vec![]);
        let output = generate_protocol_file(&proto, "TestKit", None);

        assert!(
            !output.contains("#:param-types"),
            "should not emit #:param-types for no-param methods, got:\n{output}"
        );
    }

    #[test]
    fn test_protocol_header_groups_int_long_methods() {
        let proto = protocol(
            "TKMixed2",
            vec![
                void_method("didStart:", vec![obj_param("x", "NSObject")]),
                int64_method("numberOfItems:", vec![obj_param("view", "NSView")]),
                int32_method("statusCode", vec![]),
            ],
            vec![],
        );
        let output = generate_protocol_file(&proto, "TestKit", None);

        assert!(
            output.contains("int-returning"),
            "expected int-returning group in header, got:\n{output}"
        );
        assert!(
            output.contains("long-returning"),
            "expected long-returning group in header, got:\n{output}"
        );
    }

    // --- Enrichment metadata comments ---

    #[test]
    fn test_enrichment_augments_header_listing_line() {
        use apianyware_macos_types::enrichment::{BlockMethodEntry, EnrichmentData};

        let proto = protocol(
            "TKDelegate",
            vec![void_method(
                "application:didFinish:",
                vec![
                    obj_param("application", "NSApplication"),
                    obj_param("handler", "NSObject"),
                ],
            )],
            vec![],
        );
        let enrichment = EnrichmentData {
            protocol_async_block_methods: vec![BlockMethodEntry {
                class: "TKDelegate".to_string(),
                selector: "application:didFinish:".to_string(),
                param_index: 1,
            }],
            ..EnrichmentData::default()
        };
        let output = generate_protocol_file(&proto, "TestKit", Some(&enrichment));

        assert!(
            output.contains("  — block param 1: async-copied (runtime-managed)"),
            "expected augmented header listing line, got:\n{output}"
        );
        // The augmentation rides on the same line as the selector listing.
        let listing = output
            .lines()
            .find(|l| l.contains(";;     application:didFinish:"))
            .expect("listing line present");
        assert!(
            listing.ends_with("— block param 1: async-copied (runtime-managed)"),
            "note must be appended to the listing line, got: `{listing}`"
        );
    }

    #[test]
    fn test_enrichment_unannotated_protocol_method_listing_unchanged() {
        use apianyware_macos_types::enrichment::EnrichmentData;

        let proto = protocol("TKDelegate", vec![bool_method("shouldContinue")], vec![]);
        let output = generate_protocol_file(&proto, "TestKit", Some(&EnrichmentData::default()));
        assert!(
            !output.contains("  — "),
            "unannotated method listing must not be augmented, got:\n{output}"
        );
    }

    #[test]
    fn test_enrichment_protocol_main_thread_header_comment() {
        use apianyware_macos_types::enrichment::EnrichmentData;

        let proto = protocol("TKDelegate", vec![bool_method("shouldContinue")], vec![]);
        let enrichment = EnrichmentData {
            protocol_main_thread_protocols: vec!["TKDelegate".to_string()],
            ..EnrichmentData::default()
        };
        let output = generate_protocol_file(&proto, "TestKit", Some(&enrichment));
        assert!(
            output.contains(";; Threading: this protocol has main-thread-only methods."),
            "expected main-thread header comment, got:\n{output}"
        );

        let plain = generate_protocol_file(&proto, "TestKit", Some(&EnrichmentData::default()));
        assert!(
            !plain.contains(";; Threading:"),
            "non-main-thread protocol must get no threading comment, got:\n{plain}"
        );
    }
}
