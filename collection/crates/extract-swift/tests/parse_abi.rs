//! Tests for parsing swift-api-digester ABIRoot JSON.

use std::path::PathBuf;

use apianyware_extract_swift::abi_types::AbiDocument;

fn fixtures_dir() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("tests/fixtures")
}

#[test]
fn parse_test_framework_fixture() {
    let json = std::fs::read_to_string(fixtures_dir().join("test_framework_abi.json"))
        .expect("read fixture");
    let doc: AbiDocument = serde_json::from_str(&json).expect("parse ABIRoot JSON");

    assert_eq!(doc.root.name, "TestFramework");
    assert_eq!(doc.root.kind, "Root");

    let children = &doc.root.children;
    // 1 import + 1 protocol + 1 class + 1 enum + 1 struct + 1 function = 6
    assert_eq!(children.len(), 6, "expected 6 top-level children");

    // Verify the import
    let import = &children[0];
    assert_eq!(import.decl_kind.as_deref(), Some("Import"));
    assert_eq!(import.name, "Foundation");

    // Verify the protocol
    let protocol = &children[1];
    assert_eq!(protocol.decl_kind.as_deref(), Some("Protocol"));
    assert_eq!(protocol.name, "SomeProtocol");
    assert_eq!(protocol.intro_macos.as_deref(), Some("14.0"));
    assert_eq!(protocol.children.len(), 1, "protocol should have 1 method");
    let proto_method = &protocol.children[0];
    assert_eq!(proto_method.name, "doWork");
    assert!(proto_method.protocol_req);

    // Verify the class
    let class = &children[2];
    assert_eq!(class.decl_kind.as_deref(), Some("Class"));
    assert_eq!(class.name, "Widget");
    assert_eq!(class.intro_macos.as_deref(), Some("14.0"));
    assert_eq!(
        class.superclass_names,
        vec!["TestFramework.Base"],
        "superclass chain"
    );
    assert!(!class.conformances.is_empty(), "has conformances");
    assert_eq!(class.conformances[0].name, "SomeProtocol");

    // Class children: 1 constructor + 2 methods + 2 properties = 5
    assert_eq!(class.children.len(), 5, "class should have 5 members");
    let constructor = &class.children[0];
    assert_eq!(constructor.decl_kind.as_deref(), Some("Constructor"));
    assert_eq!(constructor.init_kind.as_deref(), Some("Designated"));

    let instance_method = &class.children[1];
    assert_eq!(instance_method.name, "process");
    assert!(!instance_method.is_static);

    let static_method = &class.children[2];
    assert_eq!(static_method.name, "defaultWidget");
    assert!(static_method.is_static);

    let rw_prop = &class.children[3];
    assert_eq!(rw_prop.name, "title");
    assert_eq!(rw_prop.decl_kind.as_deref(), Some("Var"));
    assert_eq!(rw_prop.accessors.len(), 2, "title has get+set");

    let ro_prop = &class.children[4];
    assert_eq!(ro_prop.name, "identifier");
    assert!(ro_prop.is_let);
    assert_eq!(ro_prop.accessors.len(), 1, "identifier is read-only");

    // Verify the enum
    let enum_decl = &children[3];
    assert_eq!(enum_decl.decl_kind.as_deref(), Some("Enum"));
    assert_eq!(enum_decl.name, "Priority");
    assert_eq!(
        enum_decl.children.len(),
        3,
        "enum should have 3 cases: low, medium, high"
    );
    assert_eq!(enum_decl.children[0].name, "low");
    assert_eq!(enum_decl.children[1].name, "medium");
    assert_eq!(enum_decl.children[2].name, "high");

    // Verify the struct
    let struct_decl = &children[4];
    assert_eq!(struct_decl.decl_kind.as_deref(), Some("Struct"));
    assert_eq!(struct_decl.name, "Config");
    assert_eq!(struct_decl.children.len(), 2, "struct should have 2 fields");
    let field = &struct_decl.children[0];
    assert_eq!(field.name, "maxRetries");
    assert!(field.is_let);

    // Verify the top-level function
    let func = &children[5];
    assert_eq!(func.decl_kind.as_deref(), Some("Func"));
    assert_eq!(func.name, "createDefaultWidget");
}

#[test]
fn parse_observation_framework() {
    let json =
        std::fs::read_to_string(fixtures_dir().join("observation_abi.json")).expect("read fixture");
    let doc: AbiDocument = serde_json::from_str(&json).expect("parse Observation ABIRoot JSON");

    assert_eq!(doc.root.name, "Observation");

    // Find the Observable protocol
    let observable = doc
        .root
        .children
        .iter()
        .find(|n| n.name == "Observable" && n.decl_kind.as_deref() == Some("Protocol"))
        .expect("Observable protocol should exist");
    assert_eq!(observable.intro_macos.as_deref(), Some("14.0"));

    // Find ObservationRegistrar struct
    let registrar = doc
        .root
        .children
        .iter()
        .find(|n| n.name == "ObservationRegistrar" && n.decl_kind.as_deref() == Some("Struct"))
        .expect("ObservationRegistrar struct should exist");

    // Should have methods like access, willSet, didSet
    let method_names: Vec<&str> = registrar
        .children
        .iter()
        .filter(|n| n.decl_kind.as_deref() == Some("Func"))
        .map(|n| n.name.as_str())
        .collect();
    assert!(
        method_names.contains(&"access"),
        "registrar should have access method"
    );
    assert!(
        method_names.contains(&"willSet"),
        "registrar should have willSet method"
    );
}
