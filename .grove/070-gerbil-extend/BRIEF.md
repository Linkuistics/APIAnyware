# 070-gerbil-extend — brief

**Kind:** node (design settled in grilling 2026-06-18 → ADR-0029; build remains)

## Goal

Extend the proven Swift-native trampoline mechanism (racket ADR-0027 / chez
ADR-0028, spec `docs/specs/2026-06-15-racket-trampoline.md`) to **gerbil**, the
hard case: it has **no Swift dylib** by design (ObjC-in-`gsc` native core,
ADR-0017). A trampoline **must** be Swift (only Swift can call the Swift ABI), so
gerbil grows a Swift compilation unit — the deliberate ADR-0017 deviation.

## Design — settled this session (grilling 2026-06-18)

Recorded in **ADR-0029**. Three load-bearing forks resolved with the user:

1. **Packaging — a small Swift dylib `libAPIAnywareGerbil`, trampoline-only**
   (mirror chez's `APIAnywareChez`). The Swift runtime is OS-resident, so it is
   the only new non-system dylib — vendored+relocated into the `.app` by
   `bundle-gerbil` exactly like the existing openssl@3 dylib. Self-containment
   (ADR-0009) preserved by the *existing* relocation path, not a new exception.
   The ObjC native core stays where ADR-0017 put it.
2. **Scope — trampoline only; N1 measured, not asserted.** The build-time-*win*
   hypothesis (N1) does **not** hold: gerbil's compile cost is the *generics*
   (Scheme `define-c-lambda`, can't move to Swift), and the trampoline is new,
   small work that never flowed through `gsc`. The dylib is justified by
   *necessity*, not a win. The `swift build` cost + unchanged generics compile get
   *quantified* in 030 and appended to ADR-0029.
3. **Marshalling — Scheme-side, bound via `define-c-lambda`** (ADR-0015/0017
   idiom), object returns wrapped to exact type via the ADR-0020 class registry;
   only box + throws hermetic in Swift. **No** chez-style lazy-load forcing
   reference — gerbil links the dylib at `gxc -exe` time, so symbols resolve at
   load (gerbil diverges *less* than chez here).

The residual is identical to racket/chez (same shared IR): **51 function
trampolines, 7 constants**; deferred 6 closure / 10 nonbridged-struct / 4
unnameable / 34 unbindable-generic. The marshalling taxonomy, deferred buckets,
and §6a exemplars all carry over from the racket spec — a horizontal port.

## Children

- **010-swift-dylib-build-integration** — the novel ADR-0017-deviation
  infrastructure, de-risked *before* codegen volume: new `APIAnywareGerbil`
  SwiftPM target, the `generate → swift build → gxc` step, the app build linking
  `-lAPIAnywareGerbil`, and `bundle-gerbil` vendoring+relocating the dylib. Prove
  a **hand-written probe `@_cdecl`** resolves and runs from a gerbil exe and that
  the bundled `.app` still passes `otool -L` self-containment.
- **020-trampoline-codegen-and-emitter** — `run_gerbil_trampolines` global pass
  → `Generated/Trampolines.swift`; hermetic `OpaqueHandle.swift` /
  `ThrowsBridge.swift`; emitter routing (`emit_functions`/`emit_constants` →
  `define-c-lambda` bindings in `runtime/swift-trampoline.ss`, object-return wrap
  via the ADR-0020 registry, Scheme-side String/throws coercers); replace the
  `objc_exposed` skips; CLI smoke proving the §6a exemplars
  (`CreateML.timestampSeed()`, `MLCreateErrorDomain`); `cargo test --workspace`.
- **030-rerun-verify** — cold full pipeline rerun for gerbil (residual counts
  reproduce); VM-verify a `swift-native-probe` gerbil sample app (port of the
  racket/chez one) showing the §6a exemplars live in the TestAnyware VM (project
  done-bar, `feedback-vm-verify-every-app`, `feedback-sample-apps-perfect`);
  **measure N1** (swift build cost + unchanged generics compile) and append to
  ADR-0029. After this leaf the node retires and the grove is ready to finish.

## Done when (node)

- Gerbil trampolines + emitter bindings landed; full pipeline rerun; **VM-verified**.
- ADR-0029's N1 measurement section filled with real numbers (not asserted).
- Completes the charter's "rerun every target" done-bar → grove ready to finish.

## Notes

- Last target; its completion gates grove-finish and unpauses
  `add-sbcl-clos-target` (whose Swift library is this model's trampoline layer).
- If the build reveals the design underspecified, kick back to update ADR-0029
  rather than guessing (the racket-030 pattern).
- Pointers: `swift/Package.swift` (target list), `generation/crates/bundle-gerbil/src/relocate.rs`
  (dylib vendoring), `generation/crates/emit-gerbil/src/{emit_functions,emit_constants}.rs`
  (the skips at `:49` / `:133`), `generation/crates/emit-chez/src/trampoline.rs`
  (codegen reference), `generation/crates/cli/src/generate.rs` (`run_chez_trampolines`),
  `generation/targets/gerbil/lib/runtime/{cocoa,objc}.ss`, ADR-0029/0028/0027/0017/0015/0020/0009.
