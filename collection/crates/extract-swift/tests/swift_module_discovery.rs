//! Tests for Swift module discovery and digester invocation.

use apianyware_extract_swift::digester;

#[test]
fn discover_swift_modules_from_sdk() {
    let sdk_path = std::process::Command::new("xcrun")
        .args(["--show-sdk-path"])
        .output()
        .expect("xcrun")
        .stdout;
    let sdk_path = String::from_utf8(sdk_path).unwrap();
    let sdk_path = std::path::Path::new(sdk_path.trim());

    let modules = digester::discover_swift_modules(sdk_path).expect("discover modules");

    // Should find a substantial number of Swift modules
    assert!(
        modules.len() > 50,
        "expected >50 Swift modules, found {}",
        modules.len()
    );

    // Foundation should be among them
    assert!(
        modules.iter().any(|m| m.name == "Foundation"),
        "Foundation should have a Swift module"
    );

    // SwiftData should be among them (Swift-only framework)
    assert!(
        modules.iter().any(|m| m.name == "SwiftData"),
        "SwiftData should be discoverable"
    );

    // Modules should be sorted
    let names: Vec<&str> = modules.iter().map(|m| m.name.as_str()).collect();
    let mut sorted = names.clone();
    sorted.sort();
    assert_eq!(names, sorted, "modules should be sorted by name");
}

#[test]
fn find_swift_api_digester_binary() {
    let path = digester::find_swift_api_digester().expect("find digester");
    assert!(
        path.exists(),
        "swift-api-digester should exist at {}",
        path.display()
    );
    assert!(
        path.to_string_lossy().contains("swift-api-digester"),
        "path should contain swift-api-digester"
    );
}

#[test]
fn run_digester_on_observation() {
    let sdk_path = std::process::Command::new("xcrun")
        .args(["--show-sdk-path"])
        .output()
        .expect("xcrun")
        .stdout;
    let sdk_path = String::from_utf8(sdk_path).unwrap();
    let sdk_path = std::path::Path::new(sdk_path.trim());

    let json = digester::run_swift_api_digester("Observation", sdk_path).expect("run digester");

    // Should be valid JSON with ABIRoot key
    let doc: apianyware_extract_swift::abi_types::AbiDocument =
        serde_json::from_str(&json).expect("parse ABIRoot");
    assert_eq!(doc.root.name, "Observation");
}
