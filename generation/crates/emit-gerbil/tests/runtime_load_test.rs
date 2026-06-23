//! Runtime load verification for the gerbil target — the acceptance contract that
//! the `src/` snapshot/unit tests cannot reach: that the emitted gerbil bindings
//! actually **compile, link, and run** through `gxc -exe` against a freshly built
//! `libAPIAnywareGerbil.dylib`. The gerbil analogue of emit-chez's
//! `runtime_load_test.rs` and emit-racket's `runtime_swift_method_roundtrip`.
//!
//! Today it carries the permanent regression guard for the **Swift-native
//! receiver-handle METHOD frontier** (ADR-0030/0032): the Foundation.IndexSet
//! round-trip — init(integer:) producer (D2) → contains(_:) by-value method →
//! mutating insert(_:) write-back (D3) — all `objc_exposed: false`, reachable ONLY
//! through `aw_gerbil_swift_{init,m}_Foundation_IndexSet_*` @_cdecls in the dylib.
//! A broken write-back, an emit/global drift (binding an entry the Swift side never
//! produced), or a stale/mismatched dylib makes the round-trip fail and the harness
//! fails. The pop-A async exemplar (URLSession.data(from:)) rides along, so the
//! first gerbil async path (ADR-0032 §5) is guarded too.
//!
//! Unlike chez (`chez --script --libdirs`) and racket (`racket -e dynamic-require`),
//! gerbil's "load and run" is a **whole-closure gxc compile** — `gxc -exe` does not
//! recurse, so the foundation import closure must be precompiled and the dylib
//! linked (`-lAPIAnywareGerbil`, ADR-0029 §4). That logic already lives in
//! `runtime/tests/run-swift-method-smoke.sh` (the CLI smoke, chained into
//! `run-smokes.sh`); this Rust guard wraps that script so `cargo test --workspace`
//! exercises the same method round-trip rather than reinventing the gxc invocation.
//! The script asserts `SWIFT-METHOD-OK` (pop-B IndexSet D2/D3 + pop-A async).
//!
//! Skip behaviour (the emit-racket / emit-chez opt-in pattern):
//!  - SKIPPED unless `RUNTIME_LOAD_TEST=1` (drives the gerbil bottle toolchain).
//!  - SKIPPED if `gxc` is not on PATH.
//!  - SKIPPED if `libAPIAnywareGerbil.dylib` is not built (`swift/.build` probe).
//!  - SKIPPED if the generated Foundation bindings are missing (run generate first).

use std::path::PathBuf;
use std::process::Command;

fn crate_root() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR"))
}

fn project_root() -> PathBuf {
    crate_root()
        .ancestors()
        .nth(3)
        .expect("project root above emit-gerbil crate")
        .to_path_buf()
}

fn target_root() -> PathBuf {
    project_root()
        .join("generation")
        .join("targets")
        .join("gerbil")
}

/// The method-smoke runner — the whole-closure gxc driver this guard wraps.
fn smoke_script() -> PathBuf {
    target_root()
        .join("lib")
        .join("runtime")
        .join("tests")
        .join("run-swift-method-smoke.sh")
}

fn gxc_on_path() -> bool {
    // The bottle's gxc lives in the Homebrew Cellar, not necessarily on PATH; the
    // smoke script discovers it via `brew --prefix gerbil-scheme`. Probe the same
    // way so the skip decision matches what the script can actually do.
    Command::new("brew")
        .args(["--prefix", "gerbil-scheme"])
        .output()
        .map(|o| {
            o.status.success() && {
                let prefix = String::from_utf8_lossy(&o.stdout);
                PathBuf::from(prefix.trim())
                    .join("bin")
                    .join("gxc")
                    .exists()
            }
        })
        .unwrap_or(false)
}

/// The freshly built dylib, probed where the smoke script looks for it
/// (`swift/.build/<triple>/{release,debug}/` or the profile symlinks).
fn dylib_built() -> bool {
    let build = project_root().join("swift").join(".build");
    let name = "libAPIAnywareGerbil.dylib";
    if let Ok(entries) = std::fs::read_dir(&build) {
        for e in entries.flatten() {
            let dir = e.path();
            if dir.is_dir() {
                for profile in ["release", "debug"] {
                    if dir.join(profile).join(name).is_file() {
                        return true;
                    }
                }
            }
        }
    }
    // Fallback: profile symlinks directly under .build.
    for profile in ["release", "debug"] {
        if build.join(profile).join(name).is_file() {
            return true;
        }
    }
    false
}

/// Generated Foundation bindings the two exemplars import.
fn bindings_present() -> bool {
    let fw = target_root().join("lib").join("foundation");
    fw.join("indexset.ss").is_file() && fw.join("urlsession.ss").is_file()
}

fn skip_unless_enabled(test_name: &str) -> bool {
    if std::env::var_os("RUNTIME_LOAD_TEST").is_none() {
        eprintln!(
            "SKIPPED: {test_name} (set RUNTIME_LOAD_TEST=1 to enable; \
             this test drives the gerbil bottle toolchain via gxc)"
        );
        return true;
    }
    if !gxc_on_path() {
        eprintln!("SKIPPED: {test_name} (gerbil bottle gxc not found)");
        return true;
    }
    if !dylib_built() {
        eprintln!(
            "SKIPPED: {test_name} (libAPIAnywareGerbil.dylib not built; run \
             `cd swift && swift build -c release --product APIAnywareGerbil`)"
        );
        return true;
    }
    if !bindings_present() {
        eprintln!(
            "SKIPPED: {test_name} (generated Foundation bindings missing; run \
             `generate --target gerbil` first)"
        );
        return true;
    }
    false
}

/// The Swift-native receiver-handle METHOD trampoline round-trip — the permanent
/// regression guard for the gerbil method frontier (ADR-0030/0032), gerbil
/// analogue of emit-chez's `runtime_swift_method_roundtrip`. Drives
/// `run-swift-method-smoke.sh` (pop-B IndexSet init→contains→insert! D3 write-back
/// + pop-A async URLSession.data(from:)) and asserts `SWIFT-METHOD-OK`.
#[test]
fn runtime_swift_method_roundtrip() {
    if skip_unless_enabled("runtime_swift_method_roundtrip") {
        return;
    }

    let script = smoke_script();
    assert!(
        script.is_file(),
        "method-smoke runner not found at {}",
        script.display()
    );

    let output = Command::new("bash")
        .arg(&script)
        .output()
        .expect("invoke run-swift-method-smoke.sh");

    let stdout = String::from_utf8_lossy(&output.stdout);
    let stderr = String::from_utf8_lossy(&output.stderr);
    if !output.status.success() || !stdout.contains("SWIFT-METHOD-OK") {
        panic!(
            "Swift-native IndexSet method round-trip failed (no SWIFT-METHOD-OK).\n\
             --- stdout ---\n{stdout}\n--- stderr ---\n{stderr}"
        );
    }
    eprintln!("{}", stdout.trim_end());
}
