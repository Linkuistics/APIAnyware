# 050-gerbil

**Kind:** work (inherit — decompose into build + rerun/verify when picked)

## Goal

Port the receiver-handle method trampoline (pioneered in `030-racket`) to the
**gerbil** target — the last target — with its own thin structural ADR (the
"0029-for-methods", mirroring ADR-0029). Rerun + VM-verify.

## Context

Blocks on `020-method-recovery` (shared IR) and `030-racket` (the pioneered design +
ADR + spec). gerbil's free-function trampoline path: ADR-0029 (gerbil grows a
trampoline-only Swift dylib because only Swift can call the Swift ABI; `define-c-lambda`
binding, dylib **linked** at `gxc -exe` time, relocated by `bundle-gerbil` into
`Contents/Frameworks/`). The method receiver adds pointer/scalar args over that
existing dylib-call path (D6) — no new seam expected; the dylib just gains the
method/init `@_cdecl`s.

## Done when

- gerbil method-trampoline codegen + emitter routing port the 030 design: receiver
  unbox, initializer producers, mutating write-back, async-via-`await`, charter-#4
  `objc_exposed` branch (suppress + count).
- Residual method classification **reproduces identically to racket's and chez's**
  (the §6d invariant), counts reported.
- Full cold rerun (`collect`→`analyze`→`generate --target gerbil`→`swift build`→`gxc`)
  + `cargo test --workspace` green (incl. any `bundle-gerbil` dylib-relocation tests) +
  gerbil `run-smokes.sh` chains the Swift-native-method smoke as a permanent guard.
- **VM-verified:** the gerbil `swift-native-probe` (or equivalent) shows the
  exemplars — incl. a recovered async method + a population-B init→method — live in a
  standalone self-contained `.app` (ADR-0009); bundled exe `otool -L` clean;
  screenshot in `test-results/`. N1 (added swift-build cost) re-measured if material.
- Thin ADR (gerbil deviations) + co-located target docs.

## Notes

gerbil-only (ADR-0011). Last target — on close, the grove's "propagate to all
targets, each VM-verified" done-bar is met and the grove is ready to **finish**.
Reuse the 030 known-good exemplars (D7). Measure-first; likely `leaf-decompose` into
build + rerun-verify when picked.
