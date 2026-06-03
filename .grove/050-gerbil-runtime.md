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

## Contract settled by node 040 (emitter)

The emitter (`emit-gerbil`, leaf 040) fixed these; the runtime must match them:

- **Package name `gerbil-bindings`.** Generated modules import as
  `:gerbil-bindings/<framework>/<class>` (and a framework facade as
  `:gerbil-bindings/<framework>`). The runtime owns the **static `gerbil.pkg`**
  (`(package: gerbil-bindings)`) at the generated package root
  (`generation/targets/gerbil/lib/`, `generated_subdir = "lib"`) — it is *not*
  emitted per run (IR-independent). Decide whether the runtime modules live under
  the same package or a sibling (e.g. `:gerbil-bindings/runtime/objc`) — the
  emitted code references runtime entries by bare imported name, so the import
  path is the runtime's call as long as the names resolve.
- **Names the generated code calls into (must exist in the runtime, exact
  spellings TBD as leaves 020–040 land — they will append here / inbox-note):**
  the `objc-obj` constructor + `objc-obj-ptr` accessor (ADR-0018 handle), a
  `wrap`/lifetime entry for `id`-typed returns (ADR-0019 will), the
  `with-autorelease-pool` entry macro, the block-bridge constructor
  (`make-objc-block` analogue), the delegate-bridge constructor (`make-delegate`
  analogue), the `nserror` wrapper for `(values result error)`, and a
  string→NSString helper for CFSTR constants. Treat any name a construct-emitter
  leaf emits against as binding on this module.
- **`:std/generic` veneer:** generated veneer uses `(import :std/generic)`'s
  `defgeneric`/`defmethod` (NOT the built-in `{}` system — measured slower,
  ADR-0018); note the rename needed to avoid the built-in `defmethod` clash
  (`03b-generic-tax.ss` used `(rename-in :std/generic (defmethod g:defmethod))`).

## Notes

The two-toolchain rule (spec §1): develop/measure on the bottled gerbil. Clear
stale `~/.gerbil/lib/static/<mod>.o.lock` on hung builds. May decompose if the
native core + Gerbil modules are too big for one session.
