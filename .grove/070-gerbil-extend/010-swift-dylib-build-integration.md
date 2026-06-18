# 010-swift-dylib-build-integration

**Kind:** work

## Goal

Stand up the **novel ADR-0017-deviation infrastructure** — a Swift dylib in
gerbil's build — and de-risk it *before* any trampoline codegen, with a
hand-written probe. This is the one genuinely-new piece (ADR-0017 said gerbil has
**no `swift build` step**); 020 fills it with generated trampolines, 030 verifies.

## Context

ADR-0029 §1/§3/§4. Gerbil's app build is currently `generate → gxc` with the
native core compiled by `gsc`/`clang` into the static exe; this leaf adds the
`swift build` step and the dylib link/relocate path. `bundle-gerbil`
(`relocate.rs`) already vendors+relocates non-system dylibs (openssl@3) — extend
its vendor set, don't invent a new mechanism.

## Done when

- **New SwiftPM target.** `swift/Package.swift` gains a `.library(name:
  "APIAnywareGerbil", type: .dynamic, …)` + `.target(name: "APIAnywareGerbil")`
  (+ test target), mirroring `APIAnywareChez`. `swift build` produces
  `libAPIAnywareGerbil.dylib`.
- **Probe trampoline resolves from a gerbil exe.** A *hand-written*
  `@_cdecl("aw_gerbil_probe")` (e.g. returns a known `Int`, or bridges
  `MLCreateErrorDomain`) in `APIAnywareGerbil`, bound from a throwaway gerbil
  smoke via `define-c-lambda` against `-lAPIAnywareGerbil`, resolves and returns
  the expected value. Proves the `generate → swift build → gxc -exe` link path
  works end-to-end **before** committing to codegen.
- **Self-containment preserved.** `bundle-gerbil` (`relocate.rs`) extended to
  vendor+relocate the built `libAPIAnywareGerbil.dylib` into
  `Contents/Frameworks/` alongside openssl@3; `otool -L` on the bundled probe exe
  shows only `/usr/lib/*`, system frameworks, and `@executable_path/..` (the
  ADR-0009 bar). Confirm the Swift runtime resolves from `/usr/lib/swift/`
  (OS-resident, not vendored).
- `cargo test --workspace` green (bundle-gerbil relocation logic covered).

## Notes

- ADR-0029 §4: **no** chez-style lazy-load forcing reference — gerbil links at
  `gxc -exe` time, so symbols resolve at image load.
- The build-order change (`generate → swift build → gxc`) and the
  self-containment-via-relocation note land in
  `generation/targets/gerbil/docs/reference.md`.
- Keep the probe **hand-written and disposable** — its only job is to prove the
  link/load/bundle path. Real entries are generated in 020. Capture the rough
  `swift build` wall-clock here (feeds the N1 measurement in 030).
