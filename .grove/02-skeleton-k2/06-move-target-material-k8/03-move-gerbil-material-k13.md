# move-gerbil-material-k13

**Kind:** work

## Goal

Relocate all gerbil per-target material + the Swift adapter into `targets/gerbil/`, fix
gerbil's path refs, keep `cargo test` at no-new-failures. Read node `BRIEF.md` first.

## Gerbil's actual layout (package root = `lib/`)

`generation/targets/gerbil/` top-level: `apps  docs  lib  test-results  README.md`.

Gerbil's **`lib/` IS the `gerbil-bindings` package root**: `lib/*` gitignored EXCEPT
`lib/runtime` (hand-written, tracked) and `lib/gerbil.pkg` (static, tracked). Emitted
framework libs land in `lib/<framework>/` (gitignored, absent in clean checkout). The
emitter hardcodes `:gerbil-bindings/<fw>/<cls>` + `:gerbil-bindings/runtime/objc` imports,
so the package-root layout (`runtime` at `lib/runtime/`) must be preserved.

```text
gerbil/lib/   (package root: runtime/ + gerbil.pkg tracked; <fw>/ emitted gitignored)
                                 → targets/gerbil/bindings/macos/generated   (keep runtime/ + gerbil.pkg at the new root)
gerbil/apps   → targets/gerbil/app-implementations/macos     (incl. apps/hello-window/build.sh)
gerbil/docs   → targets/gerbil/docs
gerbil/test-results → targets/gerbil/bindings/macos/reports
gerbil/README.md → targets/gerbil/README.md (judge)
swift/Sources/APIAnywareGerbil    → targets/gerbil/adapters/macos/sources   (3 .swift + gitignored Generated/)
swift/Tests/APIAnywareGerbilTests → targets/gerbil/adapters/macos/tests     (1 file)
```

Confirm with `git ls-files generation/targets/gerbil swift/Sources/APIAnywareGerbil
swift/Tests/APIAnywareGerbilTests`.

## Build-affecting path fixes (gerbil)

- **`targets/gerbil/tools/bundle-gerbil/tests/bundle_apps.rs`** — `workspace_root()` (lines
  21–31) then `.join("generation").join("targets")` → repoint to new `targets/gerbil/...`.
  The pre-existing failing test `computes_hello_window_closure` reads
  `generation/targets/gerbil/apps/hello-window/hello-window.ss` + `lib_root
  generation/targets/gerbil/lib` — repoint both to `app-implementations/macos/hello-window`
  and `bindings/macos/generated`. It stays env-failing (gitignored `lib/<fw>/` absent +
  gerbil toolchain absent) but at the NEW paths.
- **`bundle-gerbil/src/{bundle.rs,lib.rs,relocate.rs,standalone.rs}`,
  `examples/bundle_app.rs`, `emit-gerbil/src/emit_framework.rs`** — `generation/targets/gerbil`
  refs (incl. `relocate.rs:282` fixture string, `standalone.rs:49` "parent of generation/"
  walk-up comment) — update; check `standalone.rs` walk-up depth still resolves to repo root.
- Smoke scripts `lib/runtime/tests/{run-smokes.sh,run-swift-method-smoke.sh,
  run-swift-trampoline-smoke.sh}` + `apps/hello-window/build.sh` — repoint internal paths.
  **gerbil toolchain (gxc/gxi) is ABSENT on this host** → path-check only, do not run.
- **`swift/Package.swift`** — explicit `path:` for the gerbil module + test target.

## Done when

gerbil material + adapter under `targets/gerbil/`; path refs fixed; `cargo test`
no-new-failures (bundle-gerbil's 1 still env-fail, now at new paths); smoke scripts
path-checked from new home; `generation/targets/gerbil/` empty; committed as
`move-gerbil-material-k13`. Leave `.gitignore` untouched (shared-seam leaf).

## Notes

`lib/runtime` + `lib/gerbil.pkg` exceptions must keep their relative position under the
new `bindings/macos/generated/` package root or the emitter's hardcoded
`:gerbil-bindings/runtime/...` imports break on the next regeneration.
