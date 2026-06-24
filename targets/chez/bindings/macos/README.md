# `bindings/macos/` — the Chez binding (macOS)

The Chez-facing binding for the macOS platform. Per REFACTOR.md §18 / §42:

| dir          | role                                                                       |
|--------------|----------------------------------------------------------------------------|
| `apianyware/`| the Chez **package root** — the `(apianyware …)` library namespace tree.    |
| `apianyware/runtime/` | hand-written runtime modules (FFI seam, objc, types, trampolines), tracked. |
| `apianyware/<framework>/` | emitted per-framework `.sls` binding source (gitignored, absent in a clean checkout). |
| `lib/`       | the built `libAPIAnywareChez.dylib` (symlink into the chez adapter package's `.build`). |
| `reports/`   | screenshots / VM-verify artifacts (was `test-results/`).                    |

The `--libdirs` flag the runtime / launcher / smokes pass is **this directory**
(`targets/chez/bindings/macos`): Chez resolves a library name `(apianyware fw cls)`
to `<libdir>/apianyware/fw/cls.sls`, and `runtime/ffi.sls` probes
`<libdir>/lib/libAPIAnywareChez.dylib` for the mandatory dylib (ADR-0005).

## Why chez is shaped unlike racket (layout decision — `move-chez-material-k12`)

Racket keeps `generated/` (emitted) and `runtime/` (hand-written) as **separate
sibling dirs** because Racket's `require` resolves by explicit relative path.
Chez cannot: its emitter writes each framework's libraries **interleaved with the
hand-written runtime under one `apianyware/` namespace tree**, and Chez maps the
library *name* `(apianyware …)` to the on-disk *path* `<libdir>/apianyware/…`. So
for chez the §18 `generated/` home and the package root are the **same object** —
the `apianyware/` tree — and it must keep that exact directory name or every
`(import (apianyware …))` in the runtime, the emitted bindings, and all sample
apps stops resolving.

The node brief's generic map (rename `apianyware/` → `generated/`, dylib →
`build/`) is therefore **infeasible for chez** — the chez analogue of racket's
"umbrella `Package.swift` is infeasible" discovery (k11). The behaviour-preserving
relocate (user decision, k12): keep the `apianyware/` package root and the
`<libdir>/lib/` dylib as siblings directly under `bindings/macos/`, with
`bindings/macos/` itself as the new `--libdirs` value (the role
`generation/targets/chez/` played before). No literal `generated/` wrapper exists;
the `apianyware/` namespace tree **is** chez's emitted-package-root.

## Open follow-ups (skeleton relocate — `move-chez-material-k12`)

- **dylib home is `lib/`, not §42's `build/`.** `runtime/ffi.sls` loads the dylib
  by probing `<libdir>/lib/libAPIAnywareChez.dylib` for every `(library-directories)`
  entry — the one mechanism that covers both unbundled CLI use and a bundled `.app`
  (where the stub passes `--libdirs <Resources>/chez-app/`). Moving the in-tree
  dylib to §42's `build/` would force that single hardcoded `lib/` load-path to
  diverge between the in-tree and in-bundle contexts — a reconciliation that belongs
  to the **bindings/adapter-model workstream (root brief item 6)**, not a skeleton
  relocate. Kept at `lib/` here so the move is behaviour-preserving.
- **bundler expects a single colocated `source_root`.** `bundle-chez` reads
  `apps/`, `apianyware/`, and `lib/` from one root, but the §18 split puts apps under
  `app-implementations/macos/` and the package root + dylib here. The
  `bundle_apps` integration test stitches the homes back with a symlink fixture (the
  directory-symlink case the bundler already handles). **TODO (item 6):** teach the
  bundler the apps-root / bindings-root split natively so the fixture isn't needed.
- **`generated_subdir = "apianyware"` + the generate-cli output path.** The emitter
  still computes `{base}/chez/apianyware`; pointing a fresh `apianyware-generate`
  run at this new home (so emitted `apianyware/<fw>/` lands beside the tracked
  `apianyware/runtime/`) is owned by the **shared-seam leaf `shared-seam-k15`**
  (generate-cli `--output-dir` default + the shared `emit`/`generate` doc comments),
  together with the wholesale `.gitignore` rewrite that preserves the
  `apianyware/runtime` exception under this path.
