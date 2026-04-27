//! Swift source and Info.plist generation for stub launchers.

use crate::StubConfig;

/// Generate the Swift source code for a stub launcher.
///
/// The generated binary finds its main script inside the app bundle's Resources
/// directory and `execv`s into the language runtime. This gives each app a unique
/// CDHash for macOS TCC permission management.
pub fn generate_stub_source(config: &StubConfig) -> String {
    let mut source = String::with_capacity(512);

    source.push_str("import Foundation\n\n");

    // Runtime path — baked in at compile time
    source.push_str(&format!(
        "let runtime = \"{}\"\n\n",
        escape_swift_string(&config.runtime_path)
    ));

    // Look up the main script inside the app bundle
    source.push_str(&format!(
        "guard let script = Bundle.main.path(forResource: \"{}\", ofType: \"{}\", inDirectory: \"{}\") else {{\n",
        escape_swift_string(&config.script_resource_name),
        escape_swift_string(&config.script_resource_type),
        escape_swift_string(&config.script_resource_dir),
    ));
    source.push_str(&format!(
        "    fputs(\"{}: could not find {}.{} in app bundle\\n\", stderr)\n",
        escape_swift_string(&config.app_name),
        escape_swift_string(&config.script_resource_name),
        escape_swift_string(&config.script_resource_type),
    ));
    source.push_str("    exit(1)\n");
    source.push_str("}\n\n");

    // Build argv: [runtime, ...runtime_args, script]
    if config.runtime_args.is_empty() {
        source.push_str("let argv = [runtime, script]\n");
    } else {
        let args_literal = config
            .runtime_args
            .iter()
            .map(|a| format!("\"{}\"", escape_swift_string(a)))
            .collect::<Vec<_>>()
            .join(", ");
        source.push_str(&format!("let argv = [runtime, {args_literal}, script]\n"));
    }

    // execv with null-terminated C argv
    source.push_str("let cArgv = argv.map { strdup($0) } + [nil]\n");
    source.push_str("execv(runtime, cArgv)\n\n");

    // execv only returns on failure
    source.push_str(&format!(
        "fputs(\"{}: exec failed: \\(String(cString: strerror(errno)))\\n\", stderr)\n",
        escape_swift_string(&config.app_name),
    ));
    source.push_str("exit(1)\n");

    source
}

/// Generate a minimal `Info.plist` for the app bundle.
///
/// Includes standard keys: `CFBundleName`, `CFBundleIdentifier`, `CFBundleExecutable`,
/// `CFBundlePackageType`, plus Retina and macOS 14+ support flags.
pub fn generate_info_plist(config: &StubConfig) -> String {
    let app_name = escape_xml(&config.app_name);
    let bundle_id = escape_xml(&config.bundle_identifier);

    format!(
        r#"<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>{app_name}</string>
    <key>CFBundleIdentifier</key>
    <string>{bundle_id}</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleExecutable</key>
    <string>{app_name}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSSupportsAutomaticGraphicsSwitching</key>
    <true/>
</dict>
</plist>
"#
    )
}

/// Escape special characters for Swift string literals.
fn escape_swift_string(s: &str) -> String {
    s.replace('\\', "\\\\").replace('"', "\\\"")
}

/// Escape characters for XML text content.
fn escape_xml(s: &str) -> String {
    s.replace('&', "&amp;")
        .replace('<', "&lt;")
        .replace('>', "&gt;")
        .replace('"', "&quot;")
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::StubConfig;

    fn test_config() -> StubConfig {
        StubConfig {
            app_name: "Hello Window".to_string(),
            runtime_path: "/opt/homebrew/bin/racket".to_string(),
            runtime_args: vec![],
            script_resource_name: "main".to_string(),
            script_resource_type: "rkt".to_string(),
            script_resource_dir: "racket-app".to_string(),
            bundle_identifier: "com.example.HelloWindow".to_string(),
            signing_identity: None,
        }
    }

    // --- Swift source generation ---

    #[test]
    fn stub_source_imports_foundation() {
        let source = generate_stub_source(&test_config());
        assert!(
            source.contains("import Foundation"),
            "stub must import Foundation for Bundle.main"
        );
    }

    #[test]
    fn stub_source_contains_runtime_path() {
        let source = generate_stub_source(&test_config());
        assert!(
            source.contains(r#"let runtime = "/opt/homebrew/bin/racket""#),
            "runtime path should be baked into the stub"
        );
    }

    #[test]
    fn stub_source_looks_up_script_in_bundle() {
        let source = generate_stub_source(&test_config());
        assert!(
            source.contains(
                r#"Bundle.main.path(forResource: "main", ofType: "rkt", inDirectory: "racket-app")"#
            ),
            "should look up script resource in the app bundle"
        );
    }

    #[test]
    fn stub_source_calls_execv() {
        let source = generate_stub_source(&test_config());
        assert!(
            source.contains("execv(runtime, cArgv)"),
            "must execv into the runtime"
        );
    }

    #[test]
    fn stub_source_handles_missing_script() {
        let source = generate_stub_source(&test_config());
        assert!(
            source.contains("Hello Window: could not find main.rkt in app bundle"),
            "should print an error if the script is not found"
        );
    }

    #[test]
    fn stub_source_handles_exec_failure() {
        let source = generate_stub_source(&test_config());
        assert!(
            source.contains("Hello Window: exec failed"),
            "should print an error if execv returns (which means it failed)"
        );
    }

    #[test]
    fn stub_source_without_runtime_args_uses_simple_argv() {
        let source = generate_stub_source(&test_config());
        assert!(
            source.contains("let argv = [runtime, script]"),
            "with no runtime_args, argv should be just [runtime, script]"
        );
    }

    #[test]
    fn stub_source_with_runtime_args_includes_them_in_argv() {
        let mut config = test_config();
        config.runtime_args = vec!["-f".to_string(), "--no-init".to_string()];
        let source = generate_stub_source(&config);
        assert!(
            source.contains(r#""-f""#),
            "runtime args should appear in argv"
        );
        assert!(
            source.contains(r#""--no-init""#),
            "all runtime args should appear in argv"
        );
        assert!(source.contains("script"), "script should still be in argv");
    }

    #[test]
    fn stub_source_null_terminates_cargv() {
        let source = generate_stub_source(&test_config());
        assert!(
            source.contains("+ [nil]"),
            "cArgv must be null-terminated for execv"
        );
    }

    // --- Info.plist generation ---

    #[test]
    fn info_plist_is_valid_xml() {
        let plist = generate_info_plist(&test_config());
        assert!(plist.starts_with(r#"<?xml version="1.0""#));
        assert!(plist.contains("<plist version=\"1.0\">"));
        assert!(plist.trim_end().ends_with("</plist>"));
    }

    #[test]
    fn info_plist_contains_bundle_name() {
        let plist = generate_info_plist(&test_config());
        assert!(plist.contains("<key>CFBundleName</key>"));
        assert!(plist.contains("<string>Hello Window</string>"));
    }

    #[test]
    fn info_plist_contains_bundle_identifier() {
        let plist = generate_info_plist(&test_config());
        assert!(plist.contains("<key>CFBundleIdentifier</key>"));
        assert!(plist.contains("<string>com.example.HelloWindow</string>"));
    }

    #[test]
    fn info_plist_executable_matches_app_name() {
        let plist = generate_info_plist(&test_config());
        let exec_pos = plist
            .find("<key>CFBundleExecutable</key>")
            .expect("CFBundleExecutable key missing");
        let after = &plist[exec_pos..];
        assert!(
            after.contains("<string>Hello Window</string>"),
            "CFBundleExecutable must match app_name"
        );
    }

    #[test]
    fn info_plist_has_appl_package_type() {
        let plist = generate_info_plist(&test_config());
        assert!(plist.contains("<string>APPL</string>"));
    }

    #[test]
    fn info_plist_supports_retina() {
        let plist = generate_info_plist(&test_config());
        assert!(
            plist.contains("<key>NSHighResolutionCapable</key>"),
            "should declare Retina support"
        );
    }

    // --- Escaping ---

    #[test]
    fn escape_swift_string_handles_backslash_and_quotes() {
        assert_eq!(escape_swift_string(r#"a\b"c"#), r#"a\\b\"c"#);
    }

    #[test]
    fn escape_swift_string_passes_through_normal_text() {
        assert_eq!(escape_swift_string("hello world"), "hello world");
    }

    #[test]
    fn escape_xml_handles_ampersand_and_angle_brackets() {
        assert_eq!(escape_xml("a&b<c>d"), "a&amp;b&lt;c&gt;d");
    }

    #[test]
    fn escape_xml_passes_through_normal_text() {
        assert_eq!(escape_xml("hello world"), "hello world");
    }
}
