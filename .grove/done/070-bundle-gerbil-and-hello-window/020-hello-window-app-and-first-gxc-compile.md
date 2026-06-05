# 020-hello-window-app-and-first-gxc-compile

**Kind:** work

## Goal

Write the hello-window sample app and achieve the **first full `gxc -exe` compile**
of an app importing the emitted Foundation/AppKit bindings + the runtime, against
the **static distribution toolchain**. This is the discovery leaf: emitter
C-correctness at scale gets shaken out here.

## Context

Port `generation/targets/chez/apps/hello-window/hello-window.sls` to
`generation/targets/gerbil/apps/hello-window/hello-window.ss`, using gerbil idiom:
`(import :gerbil-bindings/appkit/nswindow …)` etc., `(export main)` (gxc -exe
requires it, FINDINGS §1), entry-point `@autoreleasepool` per ADR-0019. The chez app
exercises: NSApplication, app menu, NSWindow init-with-content-rect, NSTextField
label, geometry (NSRect by value), property setters, the run loop.

Link line (runtime/README.md "Building" step 3 + the node BRIEF notes):
`-ld-options "-lobjc -framework Foundation -framework AppKit native_block.o"`.
Compiles under the **default gcc-15** for every emitted module (ADR-0021); the only
non-default compile is the clang `native_block.c` companion.

## Done when

- `apps/hello-window/hello-window.ss` written (gerbil idiom; mirrors the chez app
  one control at a time).
- It compiles to a runnable exe with `gxc -exe` against
  `~/.local/gerbil-0.18.2-static` linking the emitted bindings + `native_block.o`
  + Foundation/AppKit.
- CLI smoke: the exe launches without crashing on FFI/symbol resolution (a real
  window draw is **not** asserted here — that is 040 VM-verify; do NOT run a GUI
  from the CLI as the done-bar).
- Emitter fixes (if any) land in `emit-gerbil`; regenerate before re-compiling.

## Notes

⚠️ Static toolchain `-O` Scheme codegen ~10× slower than the bottle (spec §1) —
sluggishness is the prelude gap, not the binding.
⚠️ The app `main` and every callback wrap their body in `@autoreleasepool`
(ADR-0019 entry-point pool); loops outside the run loop must pool themselves.
