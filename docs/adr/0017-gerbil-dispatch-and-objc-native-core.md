# Gerbil keeps generated `define-c-lambda` dispatch; native core is ObjC-in-gsc, not a Swift dylib

**Status:** accepted

The `gerbil` target dispatches ObjC methods through **generated per-signature
`define-c-lambda` wrappers emitted into the Gerbil binding library** (converging
with chez **ADR-0015**), and authors its native core — the concerns that cannot be
a thin call — as **Objective-C compiled by `gsc` into the static executable**,
**not** as a separate Swift dylib (diverging from racket/chez). This is the first
concrete shape of **ADR-0010** for gerbil and is licensed to diverge from both the
racket fat-dispatch model (**ADR-0013**) and the 020 spike's own headline by
**ADR-0011** (targets are hermetically isolated; per-target divergence is expected).

## Context — settled on BOTH axes

The 020 spike (`docs/research/2026-06-03-gerbil-ffi-dispatch-spike/FINDINGS.md`)
recommended "go fat-native" but flagged that precompilation might reframe it.
ADR-0015 weighed only runtime; this ADR records both axes, as the grove required.

- **Runtime axis (FINDINGS §2): a tie.** Inline-cast `objc_msgSend` 11.00 ns ≈ via
  a separate C shim 10.98 ns. In a compiled-FFI target both are C in the binary,
  so a native-lib entry is free at runtime — the *opposite* of ADR-0015's Chez
  result, where a shim was equal-or-slower. Runtime does **not** pick the model.
- **Compile-time axis (FINDINGS §6 + 030 finding): decides, and does NOT force
  fat-native.** Per-method generated Gerbil costs ~13 ms (`define-c-lambda`) /
  ~5 ms (thin Scheme); the spike read that as a per-build tax favouring fat-native.
  **030 verified the reframe:** a `gxc` of a module produces `.ssi`+`.o1`; an
  importing app *reuses* them (the library `.o1` mtime is untouched across an app
  build). So per-method compile cost is paid **once at binding-build time**,
  amortised across every app — a binding-regeneration-loop cost (~70 s vs ~27 s
  for ~5k methods), not a per-app tax. The premise driving fat-native is falsified.
- arm64 forbids variadic `objc_msgSend`; a per-signature typed crossing must exist
  *somewhere* regardless. Keeping it as generated `define-c-lambda` is the most
  idiomatic, self-contained option.

## Decision

1. **Dispatch:** the emitter open-codes one typed `define-c-lambda` per distinct
   method ABI signature in the binding library; marshalling stays in idiomatic
   Gerbil (the marshalling-depth spectrum applies per method). The binding library
   compiles once to `.ssi`+`.o1`; apps import and reuse it.
2. **Native core = Objective-C, compiled by gsc into the exe** (emitted into the
   FFI unit's `c-declare` / a companion `.m`, `-x objective-c`), statically
   linked. Reserved for blocks, delegates, dynamic classes, lifetime helpers, and
   thread activation. **No Swift dylib** — a dylib would fight the static-exe
   self-contained distribution (ADR-0009; the stray openssl@3 dylib is already an
   unwanted exception the bundler must relocate). gsc *is* a C/ObjC compiler, so
   ObjC-in-gsc is the idiomatic Gerbil path; ADR-0010's "Swift" is honoured in
   spirit — a purpose-built native core in the language gsc speaks.

## Consequences

- **The emitter resembles `emit-chez`, not `emit-racket`:** per-signature FFI
  emission, no generated Swift dispatch table, no `swift build` step in the app
  build. Build order is `generate → gxc` (no separate native-lib compile).
- **Divergence is the record's point.** A reader comparing gerbil to racket
  (ADR-0013, fat dispatch) or to the 020 spike headline must not "fix" gerbil by
  relocating dispatch into a native lib — the measurement (runtime tie) plus
  precompilation (compile cost is one-time) says that is not warranted, and it
  would cost idiom and self-containment.
- **Binding-regeneration cost is real but bounded** (~70 s clean for a large
  binding, incremental per-module otherwise) and is a development-loop concern,
  not borne by app builds. Recorded in `knowledge/targets/gerbil.md`.
- **The native core stays small** — only what genuinely cannot be a thin call,
  per ADR-0010's reserved-concerns boundary (cf. ADR-0015's identical reservation
  for chez).
