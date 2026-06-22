# fix-objc-runtime-class-naming-k38

**Kind:** work

## Goal

Fix the **sbcl** target so a class whose Swift overlay drops/renames the `NS` prefix is
reachable through the natural construct/auto-wrap paths — i.e. `register-objc-class` bakes
the **ObjC runtime** class name, not the Swift-overlay import name.

## Context

Surfaced by 060/030 (swift-native-probe), 2026-06-21. Classes like `Scanner` (ObjC
`NSScanner`), `FileHandle` (`NSFileHandle`), `Notification` (`NSNotification`) reach the IR
under their Swift-overlay name, so the emitter writes
`(register-objc-class 'ns:scanner "Scanner" "NSObject")` from `cls.name`. But the live ObjC
class is `"NSScanner"`, so:

- `aw-resolve-bound-class` (auto-wrap) looks up `class_getName` (`"NSScanner"`) in
  `*objc-class-registry*` (which has `"Scanner"`) → misses → wraps to `ns:ns-object` → a
  Swift-native method specialized on `ns:scanner` gets *no applicable method*; and
- `make-instance 'ns:scanner` → `aw-class "Scanner"` → `objc_getClass("Scanner")` → nil → fails.

Only the receiver-handle **method** trampoline works (pointer-based, name-agnostic). The
probe worked around it with `(make-instance 'ns:scanner :ptr id)` over the real `"NSScanner"`.

**Does NOT block the GUI ladder** (AppKit `NSButton`/`NSWindow`/`NSTextField`/… keep their
ObjC names), which is why the remaining 060 apps are unaffected.

This leaf is the **sbcl** slice. The cross-target question (racket/chez/gerbil very likely
share the same IR-level naming, since the class name comes from shared analysis) stays in the
repo-root `TODO.md` for the other languages — fix or rule it out there, not here.

## Done when

- `register-objc-class`'s ObjC-name argument is the runtime class name for the NS-dropped /
  renamed family (verify the IR carries the runtime name from the digester, or derive it).
- `make-instance 'ns:scanner` (construct) and `aw-wrap` of a live `NSScanner` both resolve to
  `ns:scanner`; the Swift-native method dispatches **without** the `:ptr` workaround.
- A regression test (emitter golden and/or a runtime smoke over a renamed class).
- The swift-native-probe's Scanner `:ptr` workaround is removed (or noted as no-longer-needed),
  and its learnings updated.

## Notes / pointers

- Finding detail + workaround: `generation/targets/sbcl/apps/swift-native-probe/learnings.md`,
  `generation/targets/sbcl/test-results/swift-native-probe/report.md`, repo-root `TODO.md`.
- Emitter site: `emit-sbcl/src/emit_class.rs` `emit_register_class` (uses `cls.name`); the
  registry consumer is `runtime/ffi.lisp` `aw-resolve-bound-class` + `aw-class`.
- Check whether `cls.name` vs an ObjC-runtime-name field already exists in the shared IR
  (`apianyware-macos-types`) — the fix may be "use the right field" or may need the digester
  to record the runtime name.
- Sequencing: independent of the 060 apps (non-blocking); ideally lands before a final
  080-docs pass. A planning session may `leaf-insert` it earlier if desired.
