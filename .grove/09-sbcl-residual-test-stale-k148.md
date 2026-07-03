# sbcl-residual-test-stale-k148

**Kind:** work

## Goal

Fix the pre-existing RED test `classifies_residual_apps_against_real_tree` in
`targets/sbcl/tools/bundle-sbcl/tests/bundle_apps.rs` so the workspace test suite is green
before grove-finish (a red test must not merge to main).

## Context (discovered during `apps-layout-finalize-k84` verification, 2026-07-04)

The test anchors `driver_needs_dylib` against the **real** sbcl app tree with a
**pure-ObjC vs residual contrast**: it asserts `hello-window` is pure-ObjC (dump.lisp has
**no** `(aw-load-native-dylib`) while `swift-native-probe` loads the dylib. That premise is
now obsolete:

- The AppSpec-pause instrumentation (`appspec-hello-window-sbcl-build-k70`, and the
  per-impl builds after it) added an `applicationWillTerminate:` terminate-delegate to the
  sbcl impls that **needs libAPIAnywareSbcl's subclass bounce shim**, so the impl now calls
  `(aw-load-native-dylib)` at load.
- Survey of the committed tree (k84): **all eight** sbcl `dump.lisp` files now contain
  exactly one `(aw-load-native-dylib)` — hello-window, ui-controls-gallery, pdfkit-viewer,
  scenekit-viewer, mini-browser, note-editor, drawing-canvas, swift-native-probe. **There
  is no pure-ObjC sbcl impl left** to anchor the contrast on.
- Because `dump.lisp` is committed, `sbcl_tree_present()` is true in CI → the test **runs
  and fails** in CI (not a partial-corpus skip like `[[sbcl_6d_test_stale]]`).

The unit under test is fine: the hermetic `driver_needs_dylib_true_for_residual_driver` /
`driver_needs_dylib_false_for_pure_objc_driver` tests (temp-file fixtures, `dump.rs`) pass
and fully cover the token-scan logic. Only the **real-tree anchor** is stale.

Pre-existing since k70/k75 — **unrelated to `apps/macos/` layout**; k84 only discovered it
while verifying the bundlers stay green (the display-name read tests all passed).

## Disposition (decide, then do — likely the first)

- **Retire the real-tree anchor test.** The pure-ObjC-vs-residual contrast it encoded no
  longer exists in the tree, and `driver_needs_dylib`'s logic is already covered
  hermetically. Deleting `classifies_residual_apps_against_real_tree` (keep
  `rejects_missing_driver`) removes the stale coupling to instrumentation churn. **OR**
- **Re-purpose it** to assert the *current* truth: every sbcl impl now loads the dylib
  (`driver_needs_dylib` true for all of `apps_root()`'s children) — but this re-anchors on
  a fact that future de-instrumentation could flip again, so prefer retirement unless a
  standing "which impls are residual" invariant is genuinely wanted.

## Done when

`cargo test -p apianyware-bundle-sbcl` is green (all four bundlers green); the fix is a
single focused commit named `sbcl-residual-test-stale-k148`. No production bundler/impl
code changes — this is test hygiene only.

## Notes

- Do **not** edit the impls' `dump.lisp` to remove the dylib load — the terminate-delegate
  bounce shim is a legitimate instrumentation the apps rely on ([[sample_apps_perfect]]).
  The test premise is what's stale, not the impls.
- Kin to `[[sbcl_6d_test_stale]]` (a real-tree/real-corpus assertion drifting under
  legitimate downstream change) but distinct: this one is CI-red, not skip-as-pass.
