//! Runtime load verification — exercises the *acceptance* contract that
//! snapshot tests cannot: that emitted files actually load in Racket.
//!
//! Two complementary patterns:
//!  - **Libraries** via `racket -e '(dynamic-require ... #f)'`: class wrappers,
//!    protocol files, `functions.rkt`, `constants.rkt` across multiple
//!    frameworks. Library files have no side-effectful top-level so
//!    `dynamic-require` is the right signal.
//!  - **Apps** via `raco make`: app top-levels call `nsapplication-run`, so
//!    `dynamic-require` would block on a window. `raco make` compiles the
//!    full require graph without instantiating the body — exactly "do the
//!    imports resolve and the imported modules compile?".
//!
//! Motivation, from memory.md: the `provide/contract` migration landed green
//! with every text-level snapshot passing while *no emitted file actually
//! loaded in Racket* — six load-time failures slipped through in sequence
//! (`->` require conflict, `exact-nonneg-integer?` typo, missing cstruct
//! provides, missing `type-mapping.rkt` require in functions/constants,
//! missing `ffi/unsafe/objc` require, preprocessor-macros-as-symbols leak).
//! This harness closes that gap, and additionally validates the recent core
//! filter fixes (internal-linkage in extract-objc, `s:` and `c:@macro@` USR
//! families in extract-swift) by loading the symbol surfaces those filters
//! cleaned up: Foundation/CoreGraphics functions+constants and CoreText
//! constants.
//!
//! Skip behavior:
//!  - SKIPPED if `racket` or `raco` is not on PATH
//!  - SKIPPED if enriched IR is missing for a required framework
//!  - SKIPPED unless `RUNTIME_LOAD_TEST=1` (slow test gated out of default
//!    `cargo test` runs; same opt-in pattern as `UPDATE_GOLDEN=1`).

use std::path::{Path, PathBuf};
use std::process::Command;

use apianyware_macos_emit::language_emitter::LanguageEmitter;
use apianyware_macos_emit_racket::emit_framework::RacketEmitter;
use apianyware_macos_types::ir::Framework;

const RUNTIME_FILES: &[&str] = &[
    "app-menu.rkt",
    "ax-helpers.rkt",
    "block.rkt",
    "cf-bridge.rkt",
    "cgevent-helpers.rkt",
    "coerce.rkt",
    "delegate.rkt",
    "dynamic-class.rkt",
    "main-thread.rkt",
    "nsevent-helpers.rkt",
    "nsview-helpers.rkt",
    "objc-base.rkt",
    "objc-interop.rkt",
    "objc-subclass.rkt",
    "spi-helpers.rkt",
    "swift-helpers.rkt",
    "type-mapping.rkt",
    "variadic-helpers.rkt",
];

const REQUIRED_FRAMEWORKS: &[&str] = &[
    "Foundation",
    "AppKit",
    "AudioToolbox",
    "AVFoundation",
    "CoreGraphics",
    "CoreSpotlight",
    "CoreText",
    "ApplicationServices",
    "libdispatch",
    "MapKit",
    "Network",
    "NetworkExtension",
    "PDFKit",
    "SceneKit",
    "WebKit",
];

const APPS: &[&str] = &[
    "hello-window",
    "ui-controls-gallery",
    "drawing-canvas",
    "pdfkit-viewer",
    "scenekit-viewer",
    "mini-browser",
    "note-editor",
];

/// Library files exercised via `dynamic-require`. Each entry is a path
/// under the harness tempdir root, chosen to cover one distinct dimension:
///
/// 1. Class wrapper — `../../../runtime/` relative path resolution.
/// 2. Protocol file — `../../../../runtime/` (one level deeper than classes).
/// 3. Foundation `constants.rkt` — exercises both extract-objc's
///    internal-linkage filter (NSHashTableCopyIn et al) and extract-swift's
///    `s:` USR-family filter (NSLocalizedString, NSNotFound).
/// 4. Foundation `functions.rkt` — same filters, different binding kind.
/// 5. CoreGraphics `functions.rkt` — geometry-struct require + the largest
///    single population of `s:`-prefix Swift-native filtered symbols (46).
/// 6. CoreText `constants.rkt` — the highest-population framework for the
///    `c:@macro@` filter (15 of the 30 macro symbols cleared by the
///    2026-04-13 core fix).
/// 7. AppKit `nsmenuitem.rkt` — canary for class-method (static) property
///    setters (`+[NSMenuItem usesUserKeyEquivalents]`/
///    `+[NSMenuItem setUsesUserKeyEquivalents:]`). A prior arity-mismatch
///    regression between the impl and its `provide/contract` entry was
///    invisible to snapshot tests because TestKit has no class-method
///    properties; this check makes the harness fail on any recurrence.
/// 11. `runtime/dynamic-class.rkt` — curated libobjc bridge for runtime
///     subclass construction. Hand-written runtime file, not generated;
///     listed here so its `get-ffi-obj` chain against libobjc is exercised
///     at harness time rather than only when a sample app subclasses an
///     ObjC class. Catches drift in libobjc symbol availability.
/// 12. `audiotoolbox/constants.rkt` — covers the platform-unavailable
///     extern leak surfaced by Modaliser-Racket and closed 2026-04-13. The
///     framework's constants surface was previously broken at load time
///     because dylib-unexported externs reached the IR; this check is the
///     long-term canary that the leak does not return.
/// 13. `networkextension/constants.rkt` and `network/constants.rkt` —
///     the canary frameworks for the anonymous-enum-as-constant filter
///     (`c:@Ea@…`); both broke load with `nw_browse_result_change_identical`
///     leakage before the filter landed earlier in 2026-04.
/// 14. `corespotlight/constants.rkt` — the canary for the skipped_symbols
///     "leak" that turned out to be stale downstream checkpoints
///     (CoreSpotlightAPIVersion canary), confirmed clean against fresh IR
///     2026-04-13.
const LIBRARY_LOAD_CHECKS: &[&str] = &[
    "generated/foundation/nsstring.rkt",
    "generated/foundation/protocols/nscopying.rkt",
    "generated/foundation/constants.rkt",
    "generated/foundation/functions.rkt",
    "generated/coregraphics/functions.rkt",
    "generated/coretext/constants.rkt",
    "generated/appkit/nsmenuitem.rkt",
    "generated/appkit/nsevent.rkt",
    "generated/appkit/nsscreen.rkt",
    "generated/webkit/wkwebview.rkt",
    "generated/applicationservices/functions.rkt",
    "generated/libdispatch/functions.rkt",
    "generated/libdispatch/constants.rkt",
    "generated/audiotoolbox/constants.rkt",
    "generated/networkextension/constants.rkt",
    "generated/network/constants.rkt",
    "generated/corespotlight/constants.rkt",
    "runtime/dynamic-class.rkt",
    "runtime/nsevent-helpers.rkt",
    "runtime/nsview-helpers.rkt",
    "runtime/cf-bridge.rkt",
    "runtime/ax-helpers.rkt",
    "runtime/cgevent-helpers.rkt",
    "runtime/objc-interop.rkt",
    "runtime/objc-subclass.rkt",
    "runtime/spi-helpers.rkt",
];

fn crate_root() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR"))
}

fn project_root() -> PathBuf {
    crate_root()
        .ancestors()
        .nth(3)
        .expect("project root above emit-racket crate")
        .to_path_buf()
}

fn target_root() -> PathBuf {
    project_root()
        .join("generation")
        .join("targets")
        .join("racket")
}

fn enriched_dir() -> PathBuf {
    project_root().join("analysis").join("ir").join("enriched")
}

fn binary_on_path(name: &str, probe_arg: &str) -> bool {
    Command::new(name)
        .arg(probe_arg)
        .output()
        .map(|o| o.status.success())
        .unwrap_or(false)
}

fn load_framework(name: &str) -> Option<Framework> {
    let path = enriched_dir().join(format!("{name}.json"));
    let json = std::fs::read_to_string(&path).ok()?;
    serde_json::from_str(&json).ok()
}

fn load_required_frameworks() -> Result<Vec<Framework>, String> {
    let mut out = Vec::with_capacity(REQUIRED_FRAMEWORKS.len());
    for name in REQUIRED_FRAMEWORKS {
        match load_framework(name) {
            Some(fw) => out.push(fw),
            None => return Err((*name).to_string()),
        }
    }
    Ok(out)
}

fn copy_runtime(dest_runtime: &Path) -> std::io::Result<()> {
    let src = target_root().join("runtime");
    std::fs::create_dir_all(dest_runtime)?;
    for name in RUNTIME_FILES {
        std::fs::copy(src.join(name), dest_runtime.join(name))?;
    }
    Ok(())
}

fn copy_lib(dest_lib: &Path) -> std::io::Result<()> {
    let src = target_root().join("lib").join("libAPIAnywareRacket.dylib");
    if !src.exists() {
        return Ok(());
    }
    std::fs::create_dir_all(dest_lib)?;
    std::fs::copy(src, dest_lib.join("libAPIAnywareRacket.dylib"))?;
    Ok(())
}

fn copy_app(dest_apps: &Path, name: &str) -> std::io::Result<()> {
    let src = target_root()
        .join("apps")
        .join(name)
        .join(format!("{name}.rkt"));
    let dest_app_dir = dest_apps.join(name);
    std::fs::create_dir_all(&dest_app_dir)?;
    std::fs::copy(src, dest_app_dir.join(format!("{name}.rkt")))?;
    Ok(())
}

fn emit_framework(emitter: &RacketEmitter, fw: &Framework, generated_dir: &Path) {
    emitter
        .emit_framework(fw, generated_dir)
        .unwrap_or_else(|e| panic!("emit {} failed: {e}", fw.name));
}

/// Build a hermetic target tree under `root` containing runtime, lib,
/// generated framework output, and copies of the sample apps.
fn build_harness_tree(root: &Path, frameworks: &[Framework]) {
    copy_runtime(&root.join("runtime")).expect("copy runtime");
    copy_lib(&root.join("lib")).expect("copy lib");

    let generated_dir = root.join("generated");
    std::fs::create_dir_all(&generated_dir).expect("create generated dir");
    let emitter = RacketEmitter;
    for fw in frameworks {
        emit_framework(&emitter, fw, &generated_dir);
    }

    let apps_dir = root.join("apps");
    std::fs::create_dir_all(&apps_dir).expect("create apps dir");
    for app in APPS {
        copy_app(&apps_dir, app).expect("copy app");
    }
}

fn skip_unless_enabled(test_name: &str) -> bool {
    if std::env::var_os("RUNTIME_LOAD_TEST").is_none() {
        eprintln!(
            "SKIPPED: {test_name} (set RUNTIME_LOAD_TEST=1 to enable; \
             this test regenerates 4 frameworks and shells out to racket/raco)"
        );
        return true;
    }
    if !binary_on_path("racket", "--version") {
        eprintln!("SKIPPED: {test_name} (racket not found on PATH)");
        return true;
    }
    // `raco` has no --version flag; `raco help` prints usage and exits 0.
    if !binary_on_path("raco", "help") {
        eprintln!("SKIPPED: {test_name} (raco not found on PATH)");
        return true;
    }
    false
}

#[test]
fn runtime_load_libraries_via_dynamic_require() {
    if skip_unless_enabled("runtime_load_libraries_via_dynamic_require") {
        return;
    }

    let frameworks = match load_required_frameworks() {
        Ok(fws) => fws,
        Err(missing) => {
            eprintln!(
                "SKIPPED: enriched IR not found for {missing}. \
                 Run the analysis pipeline first."
            );
            return;
        }
    };

    let temp = tempfile::tempdir().expect("tempdir");
    build_harness_tree(temp.path(), &frameworks);

    let abs_paths: Vec<String> = LIBRARY_LOAD_CHECKS
        .iter()
        .map(|p| temp.path().join(p).to_string_lossy().to_string())
        .collect();

    // Build a small racket script that dynamic-requires each path under an
    // exn:fail? handler, collects every failure rather than first-fail, and
    // prints a per-path report. Single racket startup amortises load cost
    // across all checks.
    let mut script =
        String::from("#lang racket/base\n(require racket/list)\n(define checks (list\n");
    for path in &abs_paths {
        script.push_str(&format!("  {}\n", racket_string_literal(path)));
    }
    script.push_str("))\n");
    script.push_str(
        "(define failures\n\
         \x20 (for/list ([p (in-list checks)])\n\
         \x20   (with-handlers ([exn:fail? (lambda (e) (cons p (exn-message e)))])\n\
         \x20     (dynamic-require `(file ,p) #f)\n\
         \x20     #f)))\n\
         (define real-failures (filter values failures))\n\
         (cond\n\
         \x20 [(null? real-failures)\n\
         \x20  (printf \"OK: ~a library load checks passed~n\" (length checks))]\n\
         \x20 [else\n\
         \x20  (printf \"FAIL: ~a of ~a library load checks failed~n\"\n\
         \x20    (length real-failures) (length checks))\n\
         \x20  (for ([f (in-list real-failures)])\n\
         \x20    (printf \"  - ~a:~n    ~a~n\" (car f) (cdr f)))\n\
         \x20  (exit 1)])\n",
    );

    let script_path = temp.path().join("__load_check.rkt");
    std::fs::write(&script_path, script).expect("write load script");

    let output = Command::new("racket")
        .arg(&script_path)
        .output()
        .expect("invoke racket");

    if !output.status.success() {
        panic!(
            "library dynamic-require checks failed.\n--- stdout ---\n{}\n--- stderr ---\n{}",
            String::from_utf8_lossy(&output.stdout),
            String::from_utf8_lossy(&output.stderr),
        );
    }

    eprintln!("{}", String::from_utf8_lossy(&output.stdout).trim_end());
}

#[test]
fn runtime_load_apps_via_raco_make() {
    if skip_unless_enabled("runtime_load_apps_via_raco_make") {
        return;
    }

    let frameworks = match load_required_frameworks() {
        Ok(fws) => fws,
        Err(missing) => {
            eprintln!(
                "SKIPPED: enriched IR not found for {missing}. \
                 Run the analysis pipeline first."
            );
            return;
        }
    };

    let temp = tempfile::tempdir().expect("tempdir");
    build_harness_tree(temp.path(), &frameworks);

    // Single raco make invocation for all apps — amortises racket startup
    // and exercises the full require graph (runtime/, generated/, plus
    // any additional cross-framework imports the apps pull in).
    let mut cmd = Command::new("raco");
    cmd.arg("make");
    for app in APPS {
        let app_path = temp
            .path()
            .join("apps")
            .join(app)
            .join(format!("{app}.rkt"));
        cmd.arg(app_path);
    }

    let output = cmd.output().expect("invoke raco");

    if !output.status.success() {
        panic!(
            "raco make for sample apps failed.\n--- stdout ---\n{}\n--- stderr ---\n{}",
            String::from_utf8_lossy(&output.stdout),
            String::from_utf8_lossy(&output.stderr),
        );
    }

    eprintln!(
        "OK: raco make compiled {} sample apps ({})",
        APPS.len(),
        APPS.join(", ")
    );
}

#[test]
fn runtime_block_nil_guard() {
    if skip_unless_enabled("runtime_block_nil_guard") {
        return;
    }

    let temp = tempfile::tempdir().expect("tempdir");
    copy_runtime(&temp.path().join("runtime")).expect("copy runtime");
    copy_lib(&temp.path().join("lib")).expect("copy lib");

    let script = "\
#lang racket/base
(require ffi/unsafe \"runtime/block.rkt\")

;; Test 1: make-objc-block with #f returns (values #f #f) — no live block wrapper
(define-values (block-ptr block-id)
  (make-objc-block #f (list) _void))
(unless (and (not block-ptr) (not block-id))
  (eprintf \"FAIL: make-objc-block #f should return (values #f #f), got ~a ~a~n\" block-ptr block-id)
  (exit 1))

;; Test 2: the returned block-ptr must be usable as a NULL _pointer FFI arg.
;; A live wrapper would be a cpointer satisfying cpointer?; #f passes through
;; FFI as NULL. This verifies no block was constructed at all.
(unless (eq? block-ptr #f)
  (eprintf \"FAIL: block-ptr must be exactly #f (NULL), not a live wrapper; got ~a~n\" block-ptr)
  (exit 1))

;; Test 3: free-objc-block with #f is a no-op
(free-objc-block #f)

;; Test 4: call-with-objc-block with #f passes #f to body
(define-values (result cb-id)
  (call-with-objc-block #f (list) _void (lambda (bp) bp)))
(unless (and (not result) (not cb-id))
  (eprintf \"FAIL: call-with-objc-block #f should yield #f, got ~a ~a~n\" result cb-id)
  (exit 1))

;; Test 5: normal path still works — a real proc yields a live wrapper
(define invoked? #f)
(define-values (real-block real-id)
  (make-objc-block (lambda () (set! invoked? #t)) (list) _void))
(unless (cpointer? real-block)
  (eprintf \"FAIL: real block should be cpointer?, got ~a~n\" real-block)
  (exit 1))
(unless (exact-integer? real-id)
  (eprintf \"FAIL: real block-id should be integer, got ~a~n\" real-id)
  (exit 1))
(free-objc-block real-id)

(printf \"OK: make-objc-block nil guard — 5 checks passed~n\")
";

    let script_path = temp.path().join("__nil_guard_test.rkt");
    std::fs::write(&script_path, script).expect("write nil guard test script");

    let output = Command::new("racket")
        .arg(&script_path)
        .output()
        .expect("invoke racket");

    if !output.status.success() {
        panic!(
            "make-objc-block nil guard test failed.\n--- stdout ---\n{}\n--- stderr ---\n{}",
            String::from_utf8_lossy(&output.stdout),
            String::from_utf8_lossy(&output.stderr),
        );
    }

    eprintln!("{}", String::from_utf8_lossy(&output.stdout).trim_end());
}

#[test]
fn runtime_objc_subclass_macro() {
    if skip_unless_enabled("runtime_objc_subclass_macro") {
        return;
    }

    let temp = tempfile::tempdir().expect("tempdir");
    copy_runtime(&temp.path().join("runtime")).expect("copy runtime");
    copy_lib(&temp.path().join("lib")).expect("copy lib");

    // Exercises define-objc-subclass end-to-end: zero-arg method (hash,
    // returns NSUInteger) and one-arg method (isEqual:, object→BOOL) on
    // the same subclass of NSObject. Both paths must:
    //   - register the class under the requested name
    //   - wire the IMP via the correct _cprocedure signature (inferred
    //     from the superclass's own ObjC type-encoding)
    //   - execute the user lambda when called via objc_msgSend
    //
    // NSObject is the only superclass available without also pulling in
    // AppKit; both overridden selectors are defined on NSObject itself so
    // the superclass lookup always succeeds. Running with inferred types
    // also exercises the ObjC encoding parser: "Q24@0:8" (hash) and
    // "B32@0:8@16" (isEqual:) must tokenise correctly.
    let script = "\
#lang racket/base
(require ffi/unsafe
         \"runtime/dynamic-class.rkt\"
         \"runtime/objc-subclass.rkt\")

(define hash-called? #f)
(define isEqual-arg #f)

(define-objc-subclass APIAnywareSubclassMacroTest NSObject
  [(hash)
    (lambda (self)
      (set! hash-called? #t)
      99)]
  [(isEqual:)
    (lambda (self other)
      (set! isEqual-arg other)
      #t)])

;; 1. Class is registered under the requested name.
(unless (objc-get-class \"APIAnywareSubclassMacroTest\")
  (eprintf \"FAIL: APIAnywareSubclassMacroTest not registered~n\")
  (exit 1))

;; 2. Instantiate via raw objc_msgSend — the macro does not synthesize a
;; constructor; alloc+init is inherited from NSObject.
(define objc-lib (ffi-lib \"libobjc\"))
(define msg->ptr
  (get-ffi-obj \"objc_msgSend\" objc-lib
               (_fun _pointer _pointer -> _pointer)))
(define msg->u64
  (get-ffi-obj \"objc_msgSend\" objc-lib
               (_fun _pointer _pointer -> _uint64)))
(define msg-isEqual
  (get-ffi-obj \"objc_msgSend\" objc-lib
               (_fun _pointer _pointer _pointer -> _bool)))
(define sel-reg
  (get-ffi-obj \"sel_registerName\" objc-lib
               (_fun _string -> _pointer)))

(define cls APIAnywareSubclassMacroTest)
(define instance
  (msg->ptr (msg->ptr cls (sel-reg \"alloc\")) (sel-reg \"init\")))
(unless instance
  (eprintf \"FAIL: alloc+init returned NULL~n\") (exit 1))

;; 3. Call [instance hash] — expected 99, with side-effect on hash-called?.
(define h (msg->u64 instance (sel-reg \"hash\")))
(unless (= h 99)
  (eprintf \"FAIL: expected hash=99, got ~a~n\" h) (exit 1))
(unless hash-called?
  (eprintf \"FAIL: hash handler not invoked~n\") (exit 1))

;; 4. Call [instance isEqual:instance] — expected #t, with side-effect
;; capturing the `other` arg. The arg arrives as a raw cpointer (matches
;; the declared _pointer FFI type in the override).
(define eq-result (msg-isEqual instance (sel-reg \"isEqual:\") instance))
(unless eq-result
  (eprintf \"FAIL: expected isEqual=#t, got ~a~n\" eq-result) (exit 1))
(unless (and isEqual-arg (ptr-equal? isEqual-arg instance))
  (eprintf \"FAIL: isEqual arg not captured as instance pointer; got ~a~n\" isEqual-arg)
  (exit 1))

;; 5. Idempotency: re-evaluating define-objc-subclass with the same ObjC
;; class name must not fail — make-dynamic-subclass returns the existing
;; class. A module top-level (define name ...) cannot appear twice, so
;; the re-use is checked inside a let so the inner define is a local
;; binding. The live IMP stays the original one because libobjc forbids
;; class_addMethod after registration; the correct response to a module
;; re-require is exactly this no-op.
(let ()
  (define-objc-subclass APIAnywareSubclassMacroTest NSObject
    [(hash) (lambda (self) 123)])
  (unless (objc-get-class \"APIAnywareSubclassMacroTest\")
    (eprintf \"FAIL: idempotent re-define lost the class~n\") (exit 1))
  ;; Old IMP still wins — libobjc rejects add-method after registration.
  (define h2 (msg->u64 instance (sel-reg \"hash\")))
  (unless (= h2 99)
    (eprintf \"FAIL: re-define should not replace live IMP; got ~a~n\" h2)
    (exit 1)))

;; 6. Keyword-based explicit override — verify #:ret-type bypasses inference.
;; The override form exists so unusual types (unions, bitfields, non-
;; geometry structs not in the known-structs table) can still be expressed.
;; Here the override is redundant (inference would pick _uint64 anyway) but
;; the check is that the macro's shape with #:ret-type parses and runs.
(let ()
  (define-objc-subclass APIAnywareSubclassExplicitOverride NSObject
    [(hash) #:ret-type _uint64 (lambda (self) 55)])
  (define inst-o
    (msg->ptr (msg->ptr APIAnywareSubclassExplicitOverride (sel-reg \"alloc\"))
              (sel-reg \"init\")))
  (define h-o (msg->u64 inst-o (sel-reg \"hash\")))
  (unless (= h-o 55)
    (eprintf \"FAIL: explicit-override hash=~a, expected 55~n\" h-o)
    (exit 1)))

(printf \"OK: define-objc-subclass — 6 checks passed~n\")
";

    let script_path = temp.path().join("__objc_subclass_test.rkt");
    std::fs::write(&script_path, script).expect("write objc-subclass test script");

    let output = Command::new("racket")
        .arg(&script_path)
        .output()
        .expect("invoke racket");

    if !output.status.success() {
        panic!(
            "objc-subclass macro test failed.\n--- stdout ---\n{}\n--- stderr ---\n{}",
            String::from_utf8_lossy(&output.stdout),
            String::from_utf8_lossy(&output.stderr),
        );
    }

    eprintln!("{}", String::from_utf8_lossy(&output.stdout).trim_end());
}

#[test]
fn runtime_objc_subclass_struct_encoding() {
    if skip_unless_enabled("runtime_objc_subclass_struct_encoding") {
        return;
    }

    let temp = tempfile::tempdir().expect("tempdir");
    copy_runtime(&temp.path().join("runtime")).expect("copy runtime");
    copy_lib(&temp.path().join("lib")).expect("copy lib");

    // Exercises two paths in define-objc-subclass that the sibling test
    // (`runtime_objc_subclass_macro`) does not reach:
    //
    // 1. Nested balanced-delimiter struct encoding. NSView's drawRect: has
    //    encoding "v48@0:8{CGRect={CGPoint=dd}{CGSize=dd}}16". Parsing the
    //    outer `{CGRect=...}` token requires `read-balanced` to track depth
    //    across the two nested `{...}` fields inside. The result is a known
    //    struct (`_NSRect`) so inference succeeds end-to-end.
    //
    // 2. Explicit `#:arg-types` / `#:ret-type` keyword overrides. NSView
    //    inherits `tag` from NSResponder via NSView with encoding "q16@0:8" (returns
    //    NSInteger/_int64); supplying `#:arg-types () #:ret-type _long`
    //    bypasses inference entirely, verifying the keyword-override path.
    //
    // NSView is only registered with the ObjC runtime after AppKit is
    // loaded; the script loads it via ffi-lib before using NSView as the
    // superclass.
    let script = "\
#lang racket/base
(require ffi/unsafe
         \"runtime/dynamic-class.rkt\"
         \"runtime/objc-subclass.rkt\"
         \"runtime/type-mapping.rkt\")

;; NSView is only registered after AppKit is loaded.
(void (ffi-lib \"/System/Library/Frameworks/AppKit.framework/AppKit\"))

;; --- Path 1: nested-struct encoding (exercises read-balanced recursion) ---
;; drawRect: encoding: v48@0:8{CGRect={CGPoint=dd}{CGSize=dd}}16
;; The outer {CGRect=...} token contains two nested {..} tokens; depth
;; reaches 3 inside read-balanced. CGRect is in known-structs as _NSRect.
(define drew (box #f))
(define-objc-subclass D2InferView NSView
  [(drawRect:) (lambda (self dirty-rect) (set-box! drew #t))])
(unless D2InferView
  (eprintf \"FAIL: D2InferView not registered~n\")
  (exit 1))

;; --- Path 2: explicit #:arg-types / #:ret-type bypass inference -----------
;; tag is inherited from NSResponder via NSView with encoding \"q16@0:8\".
(define-objc-subclass D2ExplicitView NSView
  [(tag) #:arg-types () #:ret-type _long (lambda (self) 7)])
(unless D2ExplicitView
  (eprintf \"FAIL: D2ExplicitView not registered~n\")
  (exit 1))

;; --- Smoke-test that the D2ExplicitView tag method is callable ------------
(define objc-lib (ffi-lib \"libobjc\"))
(define msg->ptr
  (get-ffi-obj \"objc_msgSend\" objc-lib
               (_fun _pointer _pointer -> _pointer)))
(define msg->long
  (get-ffi-obj \"objc_msgSend\" objc-lib
               (_fun _pointer _pointer -> _long)))
(define msg-draw
  (get-ffi-obj \"objc_msgSend\" objc-lib
               (_fun _pointer _pointer _NSRect -> _void)))
(define sel-reg
  (get-ffi-obj \"sel_registerName\" objc-lib
               (_fun _string -> _pointer)))

(define inst
  (msg->ptr (msg->ptr D2ExplicitView (sel-reg \"alloc\")) (sel-reg \"init\")))
(unless inst
  (eprintf \"FAIL: D2ExplicitView alloc+init returned NULL~n\")
  (exit 1))

(define tag-val (msg->long inst (sel-reg \"tag\")))
(unless (= tag-val 7)
  (eprintf \"FAIL: expected tag=7, got ~a~n\" tag-val)
  (exit 1))

;; --- Verify the D2InferView drawRect: IMP is actually wired ---------------
;; Allocate an instance and call drawRect: with a by-value NSRect struct.
;; If the nested-struct encoding was parsed correctly, the IMP lambda fires
;; and sets `drew`. A wrong encoding would produce a bad _cprocedure
;; signature, causing a crash or silent non-invocation.
(define inst2
  (msg->ptr (msg->ptr D2InferView (sel-reg \"alloc\")) (sel-reg \"init\")))
(unless inst2
  (eprintf \"FAIL: D2InferView alloc+init returned NULL~n\")
  (exit 1))
(msg-draw inst2 (sel-reg \"drawRect:\") (make-nsrect 0 0 10 10))
(unless (unbox drew)
  (eprintf \"FAIL: drawRect: override not invoked — IMP not wired correctly~n\")
  (exit 1))

(printf \"OK: define-objc-subclass struct-encoding — 6 checks passed~n\")
";

    let script_path = temp.path().join("__objc_subclass_struct_test.rkt");
    std::fs::write(&script_path, script).expect("write struct-encoding test script");

    let output = Command::new("racket")
        .arg(&script_path)
        .output()
        .expect("invoke racket");

    if !output.status.success() {
        panic!(
            "objc-subclass struct-encoding test failed.\n--- stdout ---\n{}\n--- stderr ---\n{}",
            String::from_utf8_lossy(&output.stdout),
            String::from_utf8_lossy(&output.stderr),
        );
    }

    eprintln!("{}", String::from_utf8_lossy(&output.stdout).trim_end());
}

#[test]
fn runtime_default_constructors() {
    if skip_unless_enabled("runtime_default_constructors") {
        return;
    }

    let frameworks = match load_required_frameworks() {
        Ok(fws) => fws,
        Err(missing) => {
            eprintln!(
                "SKIPPED: enriched IR not found for {missing}. \
                 Run the analysis pipeline first."
            );
            return;
        }
    };

    let temp = tempfile::tempdir().expect("tempdir");
    build_harness_tree(temp.path(), &frameworks);

    let t = temp.path().to_string_lossy();
    let script = format!(
        "\
#lang racket/base
(require ffi/unsafe
         (file \"{t}/runtime/type-mapping.rkt\")
         (file \"{t}/generated/appkit/nsalert.rkt\")
         (file \"{t}/generated/appkit/nscolorpanel.rkt\")
         (file \"{t}/generated/appkit/nsstackview.rkt\")
         (file \"{t}/generated/appkit/nssavepanel.rkt\")
         (file \"{t}/generated/appkit/nsopenpanel.rkt\"))

(define (check name v)
  (unless v (eprintf \"FAIL: ~a returned #f/nil~n\" name) (exit 1)))

;; NSAlert — genuine synthesized zero-arg default constructor.
(check \"make-nsalert\" (make-nsalert))
;; NSStackView — explicit init selector.
(check \"make-nsstackview-init-with-frame\"
       (make-nsstackview-init-with-frame (make-nsrect 0 0 100 100)))
;; NSColorPanel / NSSavePanel / NSOpenPanel — class-factory accessors.
(check \"nscolorpanel-shared-color-panel\" (nscolorpanel-shared-color-panel))
(check \"nssavepanel-save-panel\"          (nssavepanel-save-panel))
(check \"nsopenpanel-open-panel\"          (nsopenpanel-open-panel))

(printf \"OK: default/factory constructors — 5 checks passed~n\")
"
    );

    let script_path = temp.path().join("__default_constructors_test.rkt");
    std::fs::write(&script_path, &script).expect("write default-constructors test script");

    let output = Command::new("racket")
        .arg(&script_path)
        .output()
        .expect("invoke racket");

    if !output.status.success() {
        panic!(
            "default-constructors test failed.\n--- stdout ---\n{}\n--- stderr ---\n{}",
            String::from_utf8_lossy(&output.stdout),
            String::from_utf8_lossy(&output.stderr),
        );
    }

    eprintln!("{}", String::from_utf8_lossy(&output.stdout).trim_end());
}

#[test]
fn runtime_framework_deep_checks() {
    if skip_unless_enabled("runtime_framework_deep_checks") {
        return;
    }

    let frameworks = match load_required_frameworks() {
        Ok(fws) => fws,
        Err(missing) => {
            eprintln!(
                "SKIPPED: enriched IR not found for {missing}. \
                 Run the analysis pipeline first."
            );
            return;
        }
    };

    let temp = tempfile::tempdir().expect("tempdir");
    build_harness_tree(temp.path(), &frameworks);

    // Beyond the shallow `dynamic-require` load checks: construct values,
    // call deterministic C functions across three frameworks, and assert on
    // the *results*. All chosen entry points are pure geometry/utility
    // functions — no GUI, no main-thread constraint, no I/O.
    //
    //  - CoreGraphics: CGAffineTransform predicates. The identity transform
    //    constant must report as identity; a 2x scale must not.
    //  - MapKit: MKMapPointsPerMeterAtLatitude — a monotone scalar function,
    //    strictly positive at the equator and strictly larger toward the
    //    poles (Mercator projection stretches map points per meter as
    //    |latitude| grows).
    //  - AVFoundation: AVMakeRectWithAspectRatioInsideRect — fits a square
    //    (1x1 aspect) inside a 100x50 rect; the result is the largest
    //    centered square, i.e. 50x50 at origin (25, 0). Exact arithmetic on
    //    a by-value _NSSize / _NSRect cstruct round-trip.
    let t = temp.path().to_string_lossy();
    let script = format!(
        "\
#lang racket/base
(require ffi/unsafe
         (file \"{t}/runtime/type-mapping.rkt\")
         (file \"{t}/generated/coregraphics/functions.rkt\")
         (file \"{t}/generated/coregraphics/constants.rkt\")
         (file \"{t}/generated/mapkit/functions.rkt\")
         (file \"{t}/generated/avfoundation/functions.rkt\"))

(define (expect name actual expected)
  (unless (equal? actual expected)
    (eprintf \"FAIL: ~a = ~s, expected ~s~n\" name actual expected) (exit 1)))
(define (expect-true name v)
  (unless v (eprintf \"FAIL: ~a was false~n\" name) (exit 1)))

;; --- CoreGraphics — affine-transform predicates (deterministic) ----------
;; CGAffineTransformIdentity is exported from constants.rkt as a raw,
;; untagged cpointer (an ffi-obj-ref to the C global). CGAffineTransformIsIdentity
;; takes a by-value _CGAffineTransform, so the raw pointer must first be
;; dereferenced into a tagged struct value via ptr-ref.
(define identity-xform (ptr-ref CGAffineTransformIdentity _CGAffineTransform))
(expect \"CGAffineTransformIsIdentity(identity)\"
        (CGAffineTransformIsIdentity identity-xform) #t)
;; A 2x scale is not the identity. CGAffineTransformMakeScale returns a
;; by-value _CGAffineTransform struct, fed straight back into the predicate.
(expect \"CGAffineTransformIsIdentity(scale 2)\"
        (CGAffineTransformIsIdentity (CGAffineTransformMakeScale 2.0 2.0)) #f)

;; --- MapKit — scalar geometry (deterministic, no struct round-trip) ------
;; MKMapPointsPerMeterAtLatitude is (_fun _double -> _double): strictly
;; positive everywhere, and strictly larger toward the poles than at the
;; equator (Mercator scale factor grows with |latitude|).
(define mpm-equator (MKMapPointsPerMeterAtLatitude 0.0))
(define mpm-mid     (MKMapPointsPerMeterAtLatitude 60.0))
(expect-true \"MKMapPointsPerMeterAtLatitude(0) > 0\" (> mpm-equator 0.0))
(expect-true \"MKMapPointsPerMeterAtLatitude(60) > MKMapPointsPerMeterAtLatitude(0)\"
             (> mpm-mid mpm-equator))

;; --- AVFoundation — by-value struct geometry -----------------------------
;; AVMakeRectWithAspectRatioInsideRect is (_fun _NSSize _NSRect -> _NSRect).
;; A 1x1 aspect fitted inside (0,0,100,50) yields the largest centered
;; square: 50x50 at origin (25, 0).
(define av-rect
  (AVMakeRectWithAspectRatioInsideRect (make-nssize 1.0 1.0)
                                       (make-nsrect 0.0 0.0 100.0 50.0)))
(define av-size (NSRect-size av-rect))
(define av-origin (NSRect-origin av-rect))
(expect \"AVMakeRect width\"  (NSSize-width av-size)  50.0)
(expect \"AVMakeRect height\" (NSSize-height av-size) 50.0)
(expect \"AVMakeRect origin.x\" (NSPoint-x av-origin) 25.0)
(expect \"AVMakeRect origin.y\" (NSPoint-y av-origin) 0.0)

(printf \"OK: framework deep checks passed~n\")
"
    );

    let script_path = temp.path().join("__framework_deep_test.rkt");
    std::fs::write(&script_path, &script).expect("write framework-deep test script");

    let output = Command::new("racket")
        .arg(&script_path)
        .output()
        .expect("invoke racket");

    if !output.status.success() {
        panic!(
            "framework deep-check test failed.\n--- stdout ---\n{}\n--- stderr ---\n{}",
            String::from_utf8_lossy(&output.stdout),
            String::from_utf8_lossy(&output.stderr),
        );
    }

    eprintln!("{}", String::from_utf8_lossy(&output.stdout).trim_end());
}

/// Encode a Rust string as a Racket string literal, escaping `"` and `\`.
fn racket_string_literal(s: &str) -> String {
    let mut out = String::with_capacity(s.len() + 2);
    out.push('"');
    for c in s.chars() {
        match c {
            '\\' => out.push_str("\\\\"),
            '"' => out.push_str("\\\""),
            _ => out.push(c),
        }
    }
    out.push('"');
    out
}
