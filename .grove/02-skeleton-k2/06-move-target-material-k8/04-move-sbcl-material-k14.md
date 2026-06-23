# move-sbcl-material-k14

**Kind:** work

## Goal

Relocate all sbcl per-target material + the Swift adapter into `targets/sbcl/`, fix
sbcl's path refs, keep `cargo test` at no-new-failures. Read node `BRIEF.md` first.

## Sbcl's actual layout

`generation/targets/sbcl/` top-level: `apps  docs  lib  test-results  README.md`.

`lib/` holds `runtime/` (hand-written Common Lisp: conditions, ffi, lifetime, load, objc,
packages, reader-syntax, startup, subclass…) plus gitignored emitted bindings
(`generation/targets/*/generated/` pattern, absent in clean checkout).

```text
sbcl/lib/   (runtime/ Lisp tracked; emitted gitignored)
                                 → targets/sbcl/bindings/macos/generated   (keep runtime/ at the new package root)
sbcl/apps   → targets/sbcl/app-implementations/macos     (each app has its own build.sh:
                                                            drawing-canvas, hello-window, mini-browser,
                                                            note-editor, pdfkit-viewer, scenekit-viewer,
                                                            swift-native-probe, ui-controls-gallery)
sbcl/docs   → targets/sbcl/docs
sbcl/test-results → targets/sbcl/bindings/macos/reports
sbcl/README.md → targets/sbcl/README.md (judge)
swift/Sources/APIAnywareSbcl    → targets/sbcl/adapters/macos/sources   (6 .swift + gitignored Generated/)
swift/Tests/APIAnywareSbclTests → targets/sbcl/adapters/macos/tests     (1 file)
```

Confirm with `git ls-files generation/targets/sbcl swift/Sources/APIAnywareSbcl
swift/Tests/APIAnywareSbclTests`.

## Build-affecting path fixes (sbcl)

- **`bundle-sbcl/src/lib.rs`, `examples/bundle_app.rs`, `emit-sbcl/src/lib.rs`** —
  `generation/targets/sbcl/...` refs; check for any non-doc-comment fixture-path
  construction and repoint; update doc comments for accuracy.
- **Smoke `lib/runtime/tests/run-integration-smoke.sh`** + per-app `apps/*/build.sh` —
  repoint internal paths to new homes. **sbcl toolchain IS present** → attempt the
  integration smoke from its new home (path-check at minimum).
- **`swift/Package.swift`** — explicit `path:` for `.target(name: "APIAnywareSbcl")` +
  `.testTarget(name: "APIAnywareSbclTests")`. Verify `swift package describe`.
- Heed memory `project_sbcl_6d_test_stale`: there are pre-existing §6d count assertions in
  sbcl `generate.rs` keyed to regenerated IR — if any sbcl test newly fails, confirm it is
  that stale-count issue (NOT caused by this move) before touching numbers.

## Done when

sbcl material + adapter under `targets/sbcl/`; path refs fixed; `cargo test`
no-new-failures; sbcl smoke path-checked from new home; `generation/targets/sbcl/` empty;
committed as `move-sbcl-material-k14`. Leave `.gitignore` untouched (shared-seam leaf).

## Notes

After this leaf, only `generation/targets/` empty dirs (and any shared-seam fixups)
remain — the next leaf is `shared-seam-k15`.
