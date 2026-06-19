//! Runtime load verification for the chez target — the acceptance contract that
//! the `src/` snapshot/unit tests cannot reach: that the emitted Chez libraries
//! actually **load and run** through `chez --libdirs`, against a freshly built
//! `libAPIAnywareChez`. The chez analogue of emit-racket's `runtime_load_test.rs`.
//!
//! Today it carries the permanent regression guard for the **Swift-native
//! receiver-handle METHOD frontier** (ADR-0030/0031): the Foundation.IndexSet
//! round-trip — init(integer:) producer (D2) → contains(_:) by-value method →
//! mutating insert(_:) write-back (D3) — all `objc_exposed: false`, reachable ONLY
//! through `aw_chez_swift_{init,m}_Foundation_IndexSet_*` @_cdecls in the dylib.
//! A broken write-back, an emit/global drift (the §6c agreement — binding an entry
//! the Swift side never produced), or a stale/mismatched dylib makes the final
//! `contains` return #f or the library fail to load, and the harness fails. The
//! sync sibling of the async CLI smoke (`runtime/tests/smoke-swift-method.sls`).
//!
//! Skip behaviour (the emit-racket opt-in pattern):
//!  - SKIPPED unless `RUNTIME_LOAD_TEST=1` (emits a framework + shells out to chez).
//!  - SKIPPED if `chez` is not on PATH.
//!  - SKIPPED if `libAPIAnywareChez.dylib` is not built (`lib/` probe path empty).
//!  - SKIPPED if Foundation IR is missing (run collect/analyze first).

use std::path::{Path, PathBuf};
use std::process::Command;

use apianyware_macos_emit::target_emitter::TargetEmitter;
use apianyware_macos_emit_chez::emit_framework::ChezEmitter;
use apianyware_macos_types::ir::Framework;

fn crate_root() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR"))
}

fn project_root() -> PathBuf {
    crate_root()
        .ancestors()
        .nth(3)
        .expect("project root above emit-chez crate")
        .to_path_buf()
}

fn target_root() -> PathBuf {
    project_root().join("generation").join("targets").join("chez")
}

/// Load Foundation from whichever IR tree is present — the enriched pipeline output
/// if available, else the collected IR (the trampoline classification only needs
/// collected-level facts: `objc_exposed`, `swift_fn`, `methods`).
fn load_foundation() -> Option<Framework> {
    let candidates = [
        project_root().join("analysis/ir/enriched/Foundation.json"),
        project_root().join("collection/ir/collected/Foundation.json"),
    ];
    for path in candidates {
        if let Ok(json) = std::fs::read_to_string(&path) {
            if let Ok(fw) = serde_json::from_str::<Framework>(&json) {
                return Some(fw);
            }
        }
    }
    None
}

fn binary_on_path(name: &str, probe_arg: &str) -> bool {
    Command::new(name)
        .arg(probe_arg)
        .output()
        .map(|o| o.status.success())
        .unwrap_or(false)
}

/// The freshly built dylib, probed where `runtime/ffi.sls` looks for it
/// (`<libdir>/lib/libAPIAnywareChez.dylib`).
fn dylib_path() -> PathBuf {
    target_root().join("lib").join("libAPIAnywareChez.dylib")
}

/// Recursively copy a directory tree (the runtime `apianyware/runtime/` cluster).
fn copy_dir(src: &Path, dest: &Path) -> std::io::Result<()> {
    std::fs::create_dir_all(dest)?;
    for entry in std::fs::read_dir(src)? {
        let entry = entry?;
        let from = entry.path();
        let to = dest.join(entry.file_name());
        if entry.file_type()?.is_dir() {
            copy_dir(&from, &to)?;
        } else {
            std::fs::copy(&from, &to)?;
        }
    }
    Ok(())
}

/// Build a hermetic `--libdirs` root: `<root>/apianyware/{runtime,foundation}` +
/// `<root>/lib/libAPIAnywareChez.dylib`, so `(apianyware foundation indexset)` and
/// its runtime imports resolve, and `runtime/ffi.sls` finds the dylib.
fn build_harness_tree(root: &Path, foundation: &Framework) {
    let apianyware = root.join("apianyware");
    // Runtime cluster (ffi/objc/types/swift-trampoline/async-bridge/…).
    copy_dir(
        &target_root().join("apianyware").join("runtime"),
        &apianyware.join("runtime"),
    )
    .expect("copy runtime cluster");
    // The dylib, where ffi.sls probes it (`<libdir>/lib/…`).
    std::fs::create_dir_all(root.join("lib")).expect("create lib dir");
    std::fs::copy(dylib_path(), root.join("lib").join("libAPIAnywareChez.dylib"))
        .expect("copy dylib");
    // Emit Foundation into `<root>/apianyware/` so the struct file lands at
    // `<root>/apianyware/foundation/indexset.sls` (Chez resolves the library name
    // `(apianyware foundation indexset)` to that path).
    ChezEmitter
        .emit_framework(foundation, &apianyware)
        .expect("emit Foundation");
}

fn skip_unless_enabled(test_name: &str) -> bool {
    if std::env::var_os("RUNTIME_LOAD_TEST").is_none() {
        eprintln!(
            "SKIPPED: {test_name} (set RUNTIME_LOAD_TEST=1 to enable; \
             this test emits Foundation and shells out to chez)"
        );
        return true;
    }
    if !binary_on_path("chez", "--version") {
        eprintln!("SKIPPED: {test_name} (chez not found on PATH)");
        return true;
    }
    if !dylib_path().exists() {
        eprintln!(
            "SKIPPED: {test_name} (libAPIAnywareChez.dylib not built; \
             run `cd swift && swift build --product APIAnywareChez`)"
        );
        return true;
    }
    false
}

/// The Swift-native receiver-handle METHOD trampoline round-trip — the permanent
/// regression guard for the method frontier (ADR-0030/0031), chez analogue of
/// emit-racket's `runtime_swift_method_roundtrip`.
#[test]
fn runtime_swift_method_roundtrip() {
    if skip_unless_enabled("runtime_swift_method_roundtrip") {
        return;
    }
    let Some(foundation) = load_foundation() else {
        eprintln!(
            "SKIPPED: runtime_swift_method_roundtrip (Foundation IR not found; \
             run the collect/analyze pipeline first)"
        );
        return;
    };

    let temp = tempfile::tempdir().expect("tempdir");
    build_harness_tree(temp.path(), &foundation);

    // init(integer:) producer → boxed Swift-native value handle (a raw void*, which
    // chez surfaces as a positive integer address); value-receiver unbox + by-value
    // contains; mutating insert! writes the mutated copy back into the SAME box, so
    // a follow-up contains on the SAME handle observes it (D3). A broken write-back
    // leaves 7 absent and fails the guard.
    let script = "\
(import (chezscheme)
        (only (apianyware foundation indexset)
              make-indexset-integer indexset-contains indexset-insert!))
(define (check name v)
  (unless v (display \"FAIL: \") (display name) (newline) (exit 1)))
(define is (make-indexset-integer 5))
(check \"make-indexset-integer returns a handle\" (and (integer? is) (> is 0)))
(check \"contains 5 after init(integer: 5)\" (eq? #t (indexset-contains is 5)))
(check \"7 absent before insert\" (eq? #f (indexset-contains is 7)))
(indexset-insert! is 7)
(check \"contains 7 after insert! — D3 write-back proven\" (eq? #t (indexset-contains is 7)))
(check \"original member 5 still present\" (eq? #t (indexset-contains is 5)))
(display \"OK: Swift-native IndexSet method round-trip — 5 checks passed\") (newline)
(exit 0)
";
    let script_path = temp.path().join("__swift_method_roundtrip.ss");
    std::fs::write(&script_path, script).expect("write round-trip script");

    let output = Command::new("chez")
        .arg("--libdirs")
        .arg(temp.path())
        .arg("--script")
        .arg(&script_path)
        .output()
        .expect("invoke chez");

    if !output.status.success() {
        panic!(
            "Swift-native IndexSet method round-trip failed.\n--- stdout ---\n{}\n--- stderr ---\n{}",
            String::from_utf8_lossy(&output.stdout),
            String::from_utf8_lossy(&output.stderr),
        );
    }
    eprintln!("{}", String::from_utf8_lossy(&output.stdout).trim_end());
}
