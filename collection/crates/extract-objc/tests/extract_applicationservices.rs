//! Integration test: extract ApplicationServices umbrella framework and
//! verify that declarations from real (non-symlinked) subframeworks like
//! HIServices are included. Symlinked subframeworks (CoreGraphics,
//! CoreText, etc.) must NOT appear here — libclang canonicalises their
//! paths to the top-level framework, and they get extracted there.

use std::sync::LazyLock;

use apianyware_extract_objc::{create_index, extract_framework, init_clang, sdk};

static APPLICATION_SERVICES: LazyLock<apianyware_types::ir::Framework> = LazyLock::new(|| {
    let sdk = sdk::discover_sdk().expect("should discover macOS SDK");
    let frameworks = sdk::discover_frameworks(&sdk.path).expect("should discover frameworks");
    let fw = frameworks
        .iter()
        .find(|f| f.name == "ApplicationServices")
        .expect("ApplicationServices not found");

    let clang = init_clang().expect("should initialize clang");
    let index = create_index(&clang);
    extract_framework(&index, fw, &sdk).expect("should extract ApplicationServices")
});

fn application_services() -> &'static apianyware_types::ir::Framework {
    &APPLICATION_SERVICES
}

#[test]
fn application_services_includes_hiservices_ax_functions() {
    let fw = application_services();
    let required = [
        "AXIsProcessTrusted",
        "AXIsProcessTrustedWithOptions",
        "AXUIElementCreateApplication",
        "AXUIElementCopyAttributeValue",
        "AXUIElementSetAttributeValue",
        "AXUIElementCopyAttributeNames",
        "AXUIElementGetPid",
        "AXValueCreate",
        "AXValueGetValue",
    ];
    let names: std::collections::HashSet<&str> =
        fw.functions.iter().map(|f| f.name.as_str()).collect();
    for req in required {
        assert!(
            names.contains(req),
            "required AX function {req} missing from ApplicationServices"
        );
    }
}

#[test]
fn application_services_extracts_cfstr_macro_constants() {
    let fw = application_services();
    // These are defined as `#define kFoo CFSTR("...")` in
    // HIServices/AXAttributeConstants.h — not extern symbols.
    let required = [
        "kAXWindowsAttribute",
        "kAXFocusedWindowAttribute",
        "kAXMainAttribute",
        "kAXTitleAttribute",
        "kAXRaiseAction",
    ];
    let constant_map: std::collections::HashMap<&str, &apianyware_types::ir::Constant> =
        fw.constants.iter().map(|c| (c.name.as_str(), c)).collect();
    for req in required {
        let c = constant_map
            .get(req)
            .unwrap_or_else(|| panic!("CFSTR constant {req} missing from ApplicationServices"));
        assert!(
            c.macro_value.is_some(),
            "CFSTR constant {req} should have macro_value set"
        );
        // The macro_value should be a non-empty string
        assert!(
            !c.macro_value.as_ref().unwrap().is_empty(),
            "CFSTR constant {req} macro_value should not be empty"
        );
    }
    // Spot-check one known value
    let kax_windows = constant_map.get("kAXWindowsAttribute").unwrap();
    assert_eq!(
        kax_windows.macro_value.as_deref(),
        Some("AXWindows"),
        "kAXWindowsAttribute should have macro_value 'AXWindows'"
    );
}

#[test]
fn application_services_excludes_symlinked_subframeworks() {
    // CoreGraphics, CoreText, ColorSync, ImageIO are symlinks inside
    // ApplicationServices.framework/Versions/A/Frameworks/ pointing to
    // the top-level frameworks. libclang should canonicalise their
    // paths so these symbols do not land here.
    let fw = application_services();
    let cg_funcs = fw
        .functions
        .iter()
        .filter(|f| f.name.starts_with("CGContext") || f.name.starts_with("CGEvent"))
        .count();
    assert_eq!(
        cg_funcs, 0,
        "CoreGraphics functions should not leak into ApplicationServices \
         via the symlinked subframework"
    );
    let ct_funcs = fw
        .functions
        .iter()
        .filter(|f| f.name.starts_with("CTFont") || f.name.starts_with("CTLine"))
        .count();
    assert_eq!(
        ct_funcs, 0,
        "CoreText functions should not leak into ApplicationServices"
    );
}
