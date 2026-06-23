# move-racket-material-k11

**Kind:** work

## Goal

Relocate all racket per-target material + the Swift adapter into `targets/racket/`,
fix racket's build-affecting + doc-comment path refs, keep `cargo test` at no-new-failures.
See node `BRIEF.md` for shared conventions + the verification baseline (read it first).

## Racket's actual layout (richest of the four)

`generation/targets/racket/` top-level: `apps  docs  lib  runtime  tests  test-results  README.md`.

```text
racket/lib/libAPIAnywareRacket.dylib  → targets/racket/bindings/macos/build/      (built dylib, §42 build/)
racket/generated/  (gitignored, absent in clean checkout — emitted .rkt)
                                       → ensure home targets/racket/bindings/macos/generated/
racket/runtime/    (25 tracked files; HAND-WRITTEN — racket-only top-level)
                                       → targets/racket/bindings/macos/runtime/   (+ TODO: revisit home in adapter-model workstream 6)
racket/tests/      (9 tracked files)   → targets/racket/bindings/macos/tests/
racket/apps        → targets/racket/app-implementations/macos
racket/docs        → targets/racket/docs
racket/test-results → targets/racket/bindings/macos/reports                       (§42 reports)
racket/README.md   → targets/racket/README.md (judge: target-level or bindings-level)
swift/Sources/APIAnywareRacket      → targets/racket/adapters/macos/sources   (14 hand-written .swift + gitignored Generated/)
swift/Tests/APIAnywareRacketTests   → targets/racket/adapters/macos/tests     (14 files)
```

(Confirm the exact tracked set with `git ls-files generation/targets/racket
swift/Sources/APIAnywareRacket swift/Tests/APIAnywareRacketTests` before moving — the
generic node map is a guide; racket's `generated/` is gitignored/absent so only its
target dir needs to exist.)

## Build-affecting path fixes (racket)

- **`targets/racket/tools/bundle-racket/tests/bundle_apps.rs`** — builds fixture root via
  `env!("CARGO_MANIFEST_DIR")` → up to workspace root → `.join("generation").join("targets")...`.
  Repoint to the new `targets/racket/app-implementations/macos/...` (apps) and
  `bindings/macos/generated` (bindings) homes. These are the 3 *pre-existing* failing tests
  (`bundles_hello_window_into_app_directory`, `bundles_every_sample_app`,
  `bundle_has_no_compiled_directories_anywhere`): they must still fail for the same
  environmental reason (gitignored bindings absent) but reference the **new** paths.
- **`bundle-racket/src/{bundle.rs,deps.rs,lib.rs}`, `examples/bundle_app.rs`,
  `emit-racket/src/native_dispatch.rs`** — `generation/targets/racket/...` refs are
  doc-comments; update for accuracy.
- **`racket/runtime/smoke/run.sh`** — repoint its internal paths to the new runtime home;
  racket toolchain IS present here, so attempt the smoke from its new home (path-check at minimum).
- **`swift/Package.swift`** — add explicit `path:` to `.target(name: "APIAnywareRacket")`
  and `.testTarget(name: "APIAnywareRacketTests")` → new adapter source/tests dirs. Verify
  with `swift package describe` (do NOT require `swift build` green — Generated/ trampolines absent).

## Done when

racket material + adapter under `targets/racket/`; racket path refs fixed; `cargo test`
no-new-failures (bundle-racket's 3 still env-fail, now at new paths); racket smoke
path-checked from new home; `generation/targets/racket/` empty; committed as
`move-racket-material-k11`. Do **not** touch `.gitignore` (shared-seam leaf does it once).

## Notes

racket's hand-written `runtime/` is the one target with a top-level runtime dir — give it
a `bindings/macos/runtime/` home + a TODO noting the adapter-model workstream may move it
to `adapters/macos/`. Leave `.gitignore` alone.
