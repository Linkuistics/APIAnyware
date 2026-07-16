//! The per-app native launcher (ADR-0060 §1): generate its source, discover
//! the build-time Node embedder toolchain, and compile + link it.
//!
//! The launcher is **thin** — it bakes this app's identity and a
//! Resources-relative JS entry path as string literals, links the shared
//! `pump.swift`/`pump_shim.cc` embedder core (the same reusable machinery the
//! dev harness in `native/harness/` and every sample app's own `embed_main.mm`
//! already prove — `embed-pump-harness-k42`), and hands control to
//! `NSApplicationMain()` without ever calling `SpinEventLoop`/
//! `uv_run(DEFAULT)` (ADR-0056). Unlike the dev launcher (which resolves its
//! app directory from a fixed two-levels-up-from-`build/` convention because
//! the source tree colocates the launcher with its own `build/js/`), this one
//! resolves `Contents/Resources/app` — one level up from `Contents/MacOS/`, the
//! shipped bundle's own layout (ADR-0060 §4).

use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;

use crate::bundle::{AppSpec, BundleError};

/// The build-time Node embedder toolchain: headers + the shared `libnode`/
/// `libuv` dylibs the launcher links against. This is also exactly the
/// dylib pair `crate::relocate` vendors into the bundle afterward — a
/// **pinned matched pair** (ADR-0060 §2): the vendored `libnode` must be the
/// one these headers came from.
pub struct NodeToolchain {
    pub node_inc: PathBuf,
    pub libnode: PathBuf,
    pub libuv: PathBuf,
}

/// Discover the active `node`'s embedder headers and shared `libnode`/`libuv`
/// dylibs, mirroring the dev harness's own discovery
/// (`app-implementations/macos/*/build.sh`). Build-time only: the shipped
/// `.app` vendors its own copy (`crate::relocate`) and never depends on this
/// host's `node` again.
pub fn discover_node_toolchain() -> Result<NodeToolchain, BundleError> {
    let exec_path_out = Command::new("node")
        .args(["-e", "process.stdout.write(process.execPath)"])
        .output()
        .map_err(|e| BundleError::NodeToolchainNotFound {
            reason: format!("`node` not on PATH: {e}"),
        })?;
    if !exec_path_out.status.success() {
        return Err(BundleError::NodeToolchainNotFound {
            reason: "`node -e` failed to report process.execPath".to_string(),
        });
    }
    let exec_path = PathBuf::from(String::from_utf8_lossy(&exec_path_out.stdout).into_owned());
    let node_prefix = exec_path.parent().and_then(Path::parent).ok_or_else(|| {
        BundleError::NodeToolchainNotFound {
            reason: format!("cannot derive a prefix from node's own exec path {}", exec_path.display()),
        }
    })?;

    let node_inc = node_prefix.join("include").join("node");
    if !node_inc.join("node.h").exists() {
        return Err(BundleError::NodeToolchainNotFound {
            reason: format!("{} does not contain node.h", node_inc.display()),
        });
    }

    let lib_dir = node_prefix.join("lib");
    let libnode = fs::read_dir(&lib_dir)
        .map_err(|e| BundleError::NodeToolchainNotFound {
            reason: format!("cannot read {}: {e}", lib_dir.display()),
        })?
        .filter_map(|entry| entry.ok())
        .map(|entry| entry.path())
        .find(|p| {
            p.file_name()
                .and_then(|n| n.to_str())
                .is_some_and(|n| n.starts_with("libnode.") && n.ends_with(".dylib"))
        })
        .ok_or_else(|| BundleError::NodeToolchainNotFound {
            reason: format!("no libnode.*.dylib under {}", lib_dir.display()),
        })?;

    // libuv is dlsym'd by pump.swift but linked directly by pump_shim.cc's own
    // `#include <uv.h>` calls — discovered off libnode's own otool -L, exactly
    // as the dev harness's build.sh does.
    let otool_out = Command::new("otool")
        .arg("-L")
        .arg(&libnode)
        .output()
        .map_err(|e| BundleError::ToolNotAvailable { tool: "otool", source: e })?;
    let listing = String::from_utf8_lossy(&otool_out.stdout);
    let libuv = listing
        .lines()
        .find_map(|line| {
            let path = line.trim().split(" (").next().unwrap_or("").to_string();
            path.contains("/libuv.").then_some(PathBuf::from(path))
        })
        .ok_or_else(|| BundleError::NodeToolchainNotFound {
            reason: format!("{} does not link a shared libuv", libnode.display()),
        })?;

    Ok(NodeToolchain { node_inc, libnode, libuv })
}

/// Generate the launcher's ObjC++ source for `spec`. Baked as string
/// literals: the app's display name (diagnostics) and bundle id
/// (diagnostics) — the JS entry path itself is not baked as a literal
/// string constant but computed via the fixed `"/../Resources/app"` suffix
/// every bundle shares (ADR-0060 §4's layout is the same for every app; only
/// the identity differs).
pub fn generate_launcher_source(spec: &AppSpec) -> String {
    // Plain placeholder substitution rather than `format!` — the template body is one giant
    // brace-heavy C++/ObjC++ unit, and escaping every literal `{`/`}` for `format!` would be
    // illegible and error-prone to keep correct across edits.
    LAUNCHER_TEMPLATE
        .replace("__APP_NAME__", &spec.app_name)
        .replace("__APP_NAME_C__", &escape_c_string(&spec.app_name))
        .replace("__BUNDLE_ID_C__", &escape_c_string(&spec.bundle_id))
}

const LAUNCHER_TEMPLATE: &str = r#"// Generated by apianyware-bundle-typescript (ADR-0060) for "__APP_NAME__" — the per-app
// native launcher that owns main(), embeds Node, and hands control to NSApplicationMain()
// with libuv pumped as a guest (ADR-0056 mechanism (c)). Not hand-edited — regenerate via
// `targets/typescript/tools/bundle-typescript`'s launcher.rs.

#include <mach-o/dyld.h>
#include <node.h>
#include <v8.h>
#import <AppKit/AppKit.h>
#include <climits>
#include <cstdio>
#include <cstdlib>
#include <string>
#include <vector>

extern "C" {
void aw_rl_pump_v8(void* loop);
void aw_rl_pump_start(uintptr_t loop, void (*pump_v8)(void*));
void aw_rl_pump_teardown(void);
}

using node::CommonEnvironmentSetup;
using node::Environment;
using node::MultiIsolatePlatform;
using v8::Context;
using v8::HandleScope;
using v8::Isolate;
using v8::Locker;
using v8::MaybeLocal;
using v8::V8;
using v8::Value;

static const char* const kAppName = "__APP_NAME_C__";
static const char* const kBundleId = "__BUNDLE_ID_C__";

// Contents/Resources/app — resolved at runtime from the executable's own path so the same
// signed bundle runs unmodified wherever it is copied (Contents/MacOS/<exe> is always one
// level below Contents/, and Resources/app is the ADR-0060 §4 layout every bundle shares).
static std::string resources_app_dir() {
  char buf[PATH_MAX];
  uint32_t size = sizeof(buf);
  if (_NSGetExecutablePath(buf, &size) != 0) {
    fprintf(stderr, "%s: executable path exceeds PATH_MAX\n", kAppName);
    exit(1);
  }
  char resolved[PATH_MAX];
  if (realpath(buf, resolved) == nullptr) {
    fprintf(stderr, "%s: realpath(%s) failed\n", kAppName, buf);
    exit(1);
  }
  std::string exe(resolved);
  size_t macos_dir = exe.find_last_of('/');  // strip the executable's own filename
  return exe.substr(0, macos_dir) + "/../Resources/app";
}

static int run_embedded(MultiIsolatePlatform* platform,
                        const std::vector<std::string>& args,
                        const std::vector<std::string>& exec_args) {
  std::vector<std::string> errors;
  std::unique_ptr<CommonEnvironmentSetup> setup =
      CommonEnvironmentSetup::Create(platform, &errors, args, exec_args);
  if (!setup) {
    for (const std::string& err : errors) fprintf(stderr, "%s: setup error: %s\n", kAppName, err.c_str());
    return 1;
  }
  fprintf(stderr, "%s (%s): launching\n", kAppName, kBundleId);
  Isolate* isolate = setup->isolate();
  Environment* env = setup->env();
  int exit_code = 0;
  // AW_APP_SMOKE=1: a construction pre-flight — runs bootstrap's async chain to completion via
  // the ordinary Node event loop, no AppKit/pump/window. Useful for verifying the bundle wiring
  // (addon load, JS resolution) without a display; the real run (unset) is what VM-verification
  // drives.
  bool smoke = getenv("AW_APP_SMOKE") != nullptr;
  {
    Locker locker(isolate);
    Isolate::Scope isolate_scope(isolate);
    HandleScope handle_scope(isolate);
    Context::Scope context_scope(setup->context());

    std::string boot =
        "const { createRequire } = require('module');"
        "const req = createRequire('" + resources_app_dir() + "/');"
        "req('./bootstrap.cjs');";
    MaybeLocal<Value> ret = node::LoadEnvironment(env, boot.c_str());
    if (ret.IsEmpty()) { fprintf(stderr, "%s: LoadEnvironment failed\n", kAppName); return 1; }

    if (smoke) {
      exit_code = node::SpinEventLoop(env).FromMaybe(1);
    } else {
      // AppKit owns thread 0 from here. Start the pump BEFORE [NSApp run] so libuv is serviced
      // as a guest (ADR-0056).
      @autoreleasepool {
        [NSApplication sharedApplication];
        [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];

        void* loop = static_cast<void*>(setup->event_loop());
        aw_rl_pump_start(reinterpret_cast<uintptr_t>(loop), &aw_rl_pump_v8);

        [NSApp run];  // returns once Quit (Cmd-Q / the app menu) calls -terminate:

        aw_rl_pump_teardown();
      }
    }
  }
  node::Stop(env);
  return exit_code;
}

int main(int argc, char** argv) {
  std::vector<std::string> args(argv, argv + argc);
  std::shared_ptr<node::InitializationResult> result =
      node::InitializeOncePerProcess(
          args,
          {node::ProcessInitializationFlags::kNoInitializeV8,
           node::ProcessInitializationFlags::kNoInitializeNodeV8Platform});
  for (const std::string& error : result->errors())
    fprintf(stderr, "%s: init error: %s\n", kAppName, error.c_str());
  if (result->early_return() != 0) return result->exit_code();

  std::unique_ptr<MultiIsolatePlatform> platform = MultiIsolatePlatform::Create(4);
  V8::InitializePlatform(platform.get());
  V8::Initialize();

  int ret = run_embedded(platform.get(), result->args(), result->exec_args());

  V8::Dispose();
  V8::DisposePlatform();
  node::TearDownOncePerProcess();
  return ret;
}
"#;

fn escape_c_string(s: &str) -> String {
    s.replace('\\', "\\\\").replace('"', "\\\"")
}

/// Compile + link the per-app launcher for `spec` into `out_exe`. Mirrors the
/// dev harness's own recipe exactly (`clang++` the pump shim + the generated
/// launcher source, `swiftc` links them with `pump.swift` against the
/// build-time `libnode`/`libuv`) — the sequencing is already proven
/// (`embed-pump-harness-k42`); only the launcher source and its baked
/// identity are new here. The produced binary's load commands still carry
/// this host's absolute `/opt/homebrew/...` paths — `crate::relocate` rewrites
/// them afterward.
pub fn compile_launcher(
    spec: &AppSpec,
    native_dir: &Path,
    toolchain: &NodeToolchain,
    scratch: &Path,
    out_exe: &Path,
) -> Result<(), BundleError> {
    let launcher_src = scratch.join("launcher_main.mm");
    fs::write(&launcher_src, generate_launcher_source(spec))?;

    let pump_shim_src = native_dir.join("src").join("pump_shim.cc");
    let pump_shim_o = scratch.join("pump_shim.o");
    run_clangxx(
        &[
            "-std=c++20",
            "-O2",
            "-fno-exceptions",
            "-c",
            path_str(&pump_shim_src),
            "-I",
            path_str(&toolchain.node_inc),
            "-o",
            path_str(&pump_shim_o),
        ],
        &pump_shim_src,
    )?;

    let launcher_o = scratch.join("launcher_main.o");
    run_clangxx(
        &[
            "-std=c++20",
            "-O2",
            "-ObjC++",
            "-c",
            path_str(&launcher_src),
            "-I",
            path_str(&toolchain.node_inc),
            "-o",
            path_str(&launcher_o),
        ],
        &launcher_src,
    )?;

    let pump_swift = native_dir.join("src").join("pump.swift");
    let mut cmd = Command::new("swiftc");
    cmd.args(["-O", "-parse-as-library", "-o"])
        .arg(out_exe)
        .arg(&pump_swift)
        .arg(&pump_shim_o)
        .arg(&launcher_o)
        .arg(&toolchain.libnode)
        .arg(&toolchain.libuv)
        .args(["-framework", "AppKit", "-framework", "Foundation", "-framework", "CoreFoundation"]);
    for framework in &spec.extra_frameworks {
        cmd.args(["-framework", framework]);
    }
    let output = cmd
        .arg("-lc++")
        .output()
        .map_err(|e| BundleError::ToolNotAvailable { tool: "swiftc", source: e })?;
    if !output.status.success() {
        return Err(BundleError::SwiftcLinkFailed {
            stderr: String::from_utf8_lossy(&output.stderr).into_owned(),
        });
    }
    Ok(())
}

fn run_clangxx(args: &[&str], file: &Path) -> Result<(), BundleError> {
    let output = Command::new("clang++")
        .args(args)
        .output()
        .map_err(|e| BundleError::ToolNotAvailable { tool: "clang++", source: e })?;
    if !output.status.success() {
        return Err(BundleError::ClangFailed {
            file: file.to_path_buf(),
            stderr: String::from_utf8_lossy(&output.stderr).into_owned(),
        });
    }
    Ok(())
}

fn path_str(p: &Path) -> &str {
    p.to_str().expect("bundle paths are constructed from UTF-8 workspace paths")
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn generated_source_bakes_app_identity() {
        let spec = AppSpec::from_script_name("hello-window");
        let src = generate_launcher_source(&spec);
        assert!(src.contains(r#"kAppName = "Hello Window""#));
        assert!(src.contains(r#"kBundleId = "com.linkuistics.HelloWindow""#));
    }

    #[test]
    fn generated_source_resolves_resources_app_relative_to_exe() {
        let spec = AppSpec::from_script_name("hello-window");
        let src = generate_launcher_source(&spec);
        assert!(src.contains(r#""/../Resources/app""#));
    }

    #[test]
    fn generated_source_never_spins_the_default_loop_outside_smoke_mode() {
        let spec = AppSpec::from_script_name("hello-window");
        let src = generate_launcher_source(&spec);
        // ADR-0056: the launcher must not call SpinEventLoop/uv_run(DEFAULT) on the real path —
        // only the AW_APP_SMOKE pre-flight branch may.
        assert!(src.contains("if (smoke) {\n      exit_code = node::SpinEventLoop"));
        assert!(src.contains("[NSApp run];"));
    }

    #[test]
    fn escape_c_string_handles_backslash_and_quotes() {
        assert_eq!(escape_c_string(r#"a\b"c"#), r#"a\\b\"c"#);
    }
}
