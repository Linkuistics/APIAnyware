# move-chez-material-k12

**Kind:** work

## Goal

Relocate all chez per-target material + the Swift adapter into `targets/chez/`, fix
chez's path refs, keep `cargo test` at no-new-failures. Read node `BRIEF.md` first
(shared conventions + verification baseline).

## Chez's actual layout (the `apianyware/` quirk)

`generation/targets/chez/` top-level: `apianyware  apps  docs  lib  test-results  README.md`.

Chez is the only target whose **emitted package root is `apianyware/`** (not `lib/`):
`apianyware/*` is gitignored EXCEPT `apianyware/runtime` (hand-written runtime, tracked).
`lib/` holds only the built `libAPIAnywareChez.dylib`.

```text
chez/apianyware/          → targets/chez/bindings/macos/generated   (emitted package root)
  └ apianyware/runtime/   (hand-written, tracked)   → targets/chez/bindings/macos/generated/runtime
                                                       (keep runtime INSIDE the package root — the chez
                                                        emitter writes framework libs alongside runtime/;
                                                        see .gitignore §22 comment + chez-target-design §8)
chez/lib/libAPIAnywareChez.dylib  → targets/chez/bindings/macos/build/   (built dylib, §42)
chez/apps        → targets/chez/app-implementations/macos
chez/docs        → targets/chez/docs
chez/test-results → targets/chez/bindings/macos/reports
chez/README.md   → targets/chez/README.md (judge)
swift/Sources/APIAnywareChez     → targets/chez/adapters/macos/sources   (8 .swift + gitignored Generated/)
swift/Tests/APIAnywareChezTests  → targets/chez/adapters/macos/tests     (4 files)
```

Confirm with `git ls-files generation/targets/chez swift/Sources/APIAnywareChez
swift/Tests/APIAnywareChezTests`. The `apianyware/runtime` exception must keep its
relative position under the package root so the emitter's hardcoded import paths hold.

## Build-affecting path fixes (chez)

- **`bundle-chez/src/{bundle.rs,lib.rs,standalone.rs}`, `tests/bundle_apps.rs`,
  `examples/bundle_app.rs`, `emit-chez/src/chez_builtins.rs`** — `generation/targets/chez/...`
  refs are mostly doc-comments; update for accuracy. Check `tests/bundle_apps.rs` for any
  fixture-root path construction (`.join("generation").join("targets")...`) and repoint it.
- **`swift/Package.swift`** — explicit `path:` for `.target(name: "APIAnywareChez")` +
  `.testTarget(name: "APIAnywareChezTests")` → new adapter dirs. Verify `swift package describe`.

## Done when

chez material + adapter under `targets/chez/`; chez path refs fixed; `cargo test`
no-new-failures; `generation/targets/chez/` empty; committed as `move-chez-material-k12`.
Leave `.gitignore` untouched (shared-seam leaf rewrites it once, preserving the
`apianyware/runtime` exception under the new path).

## Notes

The `apianyware/` → `bindings/macos/generated` mapping is the chez-specific resolution of
the node's generic `<emitted> → bindings/macos/generated` rule. chez/sbcl smokes runnable
here (chez + sbcl toolchains present).
