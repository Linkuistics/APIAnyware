//! The Swift stub launcher for an sbcl `.app` (ADR-0041).
//!
//! Unlike the peer bundlers, the sbcl stub does **not** `execv` an external
//! language runtime — the `save-lisp-and-die` image *is* the runtime. The stub
//! exists for one reason: the dumped image links `libzstd` (SBCL's core
//! compression) by its absolute Homebrew path, which a clean target lacks, and
//! post-dump `install_name_tool` cannot rewrite that load command (the Lisp core
//! sits past `__LINKEDIT`). The stub sets `DYLD_FALLBACK_LIBRARY_PATH` to the
//! bundle's `Contents/Frameworks/` — where libzstd is vendored — so dyld
//! resolves it (and any other vendored Homebrew dep) by leaf name when the
//! absolute path is missing, then `execv`s the image.
//!
//! Bonus: a per-app stub gives the bundle a unique CDHash for macOS TCC grants
//! (the stub-launcher crate's original purpose).

use std::path::Path;

use apianyware_stub_launcher::compile_stub;

use crate::spec::BundleError;

/// Generate the Swift source for the sbcl stub launcher.
///
/// The stub locates the dumped image at `Contents/Resources/<script>` relative
/// to itself (so the bundle is relocatable), sets
/// `DYLD_FALLBACK_LIBRARY_PATH=<bundle>/Contents/Frameworks`, and `execv`s the
/// image. After `execv`, `@executable_path` is the image's directory
/// (`Contents/Resources/`), so the dlopen'd `libAPIAnywareSbcl` resolves via its
/// `@executable_path/../Frameworks/...` recorded namestring (ADR-0041).
pub fn generate_stub_source(app_name: &str, script_name: &str) -> String {
    let app = escape_swift(app_name);
    let script = escape_swift(script_name);
    format!(
        r#"import Foundation

// Locate this stub, the dumped SBCL image (a sibling resource), and the vendored
// dylib dir — all relative to the running executable so the bundle is relocatable.
let exePath = Bundle.main.executablePath ?? CommandLine.arguments[0]
let macosDir = (exePath as NSString).deletingLastPathComponent       // Contents/MacOS
let contents = (macosDir as NSString).deletingLastPathComponent      // Contents
let frameworks = contents + "/Frameworks"
let image = contents + "/Resources/{script}"

// The dumped image links libzstd by its absolute Homebrew path, absent on a clean
// target. Vendoring it into Frameworks + DYLD_FALLBACK_LIBRARY_PATH lets dyld
// resolve it (by leaf name) when the absolute path is missing (ADR-0041).
setenv("DYLD_FALLBACK_LIBRARY_PATH", frameworks, 1)

guard FileManager.default.isExecutableFile(atPath: image) else {{
    fputs("{app}: bundled image not found at \(image)\n", stderr)
    exit(1)
}}

let cArgv: [UnsafeMutablePointer<CChar>?] = [strdup(image), nil]
execv(image, cArgv)

// execv only returns on failure.
fputs("{app}: exec failed: \(String(cString: strerror(errno)))\n", stderr)
exit(1)
"#
    )
}

/// Generate + compile the stub launcher to `output_path` (the bundle's
/// `Contents/MacOS/<script>` — the `CFBundleExecutable`).
pub fn build_stub(
    app_name: &str,
    script_name: &str,
    output_path: &Path,
) -> Result<(), BundleError> {
    let source = generate_stub_source(app_name, script_name);
    compile_stub(&source, output_path)?;
    Ok(())
}

fn escape_swift(s: &str) -> String {
    s.replace('\\', "\\\\").replace('"', "\\\"")
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn stub_sets_dyld_fallback_to_frameworks() {
        let src = generate_stub_source("Hello Window", "hello-window");
        assert!(
            src.contains(r#"setenv("DYLD_FALLBACK_LIBRARY_PATH", frameworks, 1)"#),
            "stub must set DYLD_FALLBACK_LIBRARY_PATH for the vendored libzstd"
        );
        assert!(src.contains(r#"let frameworks = contents + "/Frameworks""#));
    }

    #[test]
    fn stub_execs_the_resources_image() {
        let src = generate_stub_source("Hello Window", "hello-window");
        assert!(src.contains(r#"let image = contents + "/Resources/hello-window""#));
        assert!(src.contains("execv(image, cArgv)"));
    }

    #[test]
    fn stub_reports_missing_image_and_exec_failure() {
        let src = generate_stub_source("Hello Window", "hello-window");
        assert!(src.contains("Hello Window: bundled image not found"));
        assert!(src.contains("Hello Window: exec failed"));
    }

    #[test]
    fn stub_escapes_quotes_in_names() {
        let src = generate_stub_source(r#"Weird"Name"#, "weird");
        assert!(src.contains(r#"Weird\"Name: exec failed"#));
    }
}
