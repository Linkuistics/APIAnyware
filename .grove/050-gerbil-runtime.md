# 050-gerbil-runtime

**Kind:** work

## Goal

Build the gerbil runtime (`generation/targets/gerbil/runtime/`): the hand-written
Gerbil modules + the Objective-C native core that the generated bindings sit on.

## Context

Design: `docs/specs/2026-06-03-gerbil-target-design.md` §5, §6. Reference layout:
`generation/targets/chez/apianyware/runtime/` (`ffi.sls`, `objc.sls`, `types.sls`,
`cocoa.sls`, `dispatch.sls`, `cocoa-helpers.sls`, `tests/`). Gerbil analogues, NOT
copies (ADR-0011 hermetic isolation).

## Done when

- **`objc` module:** the `objc-obj` handle struct (ADR-0018), `wrap-objc-obj`
  registering a Gambit **will** sending `release` (ADR-0019), and the
  `with-autorelease-pool` entry-point macro.
- **`ffi` module:** `:std/foreign` seam, arm64 width aliases, the `objc_getClass`/
  `sel_registerName`/`objc_msgSend` plumbing; FFI unit compiled `-x objective-c`.
- **`types` module:** value marshalling in idiomatic Gerbil (strings, structs,
  CGRect decomposition per FINDINGS §4), `(values result error)` `nserror` struct.
- **`:std/generic` veneer support:** the generic-function machinery the emitter's
  veneer methods bind into.
- **ObjC native core (ADR-0017):** block/delegate bridges + dynamic-class support
  authored as Objective-C compiled by gsc (`c-declare`/companion `.m`,
  `-x objective-c`), statically linked. **Main-thread model only** here — the
  foreign-thread story is the 080 threading spike (callbacks may bounce to main as
  a placeholder, like racket ADR-0014).
- Runtime smoke tests (objc round-trip, lifetime, veneer dispatch) pass via gsc
  build (CLI smoke; VM-verify is the apps' job).

## Notes

The two-toolchain rule (spec §1): develop/measure on the bottled gerbil. Clear
stale `~/.gerbil/lib/static/<mod>.o.lock` on hung builds. May decompose if the
native core + Gerbil modules are too big for one session.
