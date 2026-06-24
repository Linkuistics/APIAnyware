# Swift-Native Probe

**Complexity:** 1/7 (probe)
**Key features exercised:** Swift-native trampoline residual (ADR-0027) — a
Swift-native free function and a Swift-native constant reached through
`libAPIAnywareRacket`'s `@_cdecl` trampolines, displayed in an AppKit window.

## Purpose

The complete-API binding model (ADR-0025) re-exports the **whole** macOS API,
trampolining the Swift-native residual the target cannot reach directly. The CLI
smoke (`generation/targets/racket/tests/test-swift-trampoline-smoke.rkt`) proves
the trampolines resolve and run in-process; this probe closes the
`add-swift-native-api-coverage` grove's racket slice (leaf 050) by proving the
same residual works **end-to-end in a real GUI app, VM-verified** — the project
done-bar (`feedback-vm-verify-every-app`), which CLI smoke never satisfies.

It is deliberately a **probe**, not a portfolio sample app: it exercises exactly
the two known-good real exemplars the trampoline mechanism was proven against
(spec §6a), so a green window is unambiguous evidence the Swift-native path is
live — neither symbol has a C symbol in `CreateML.framework`; both are reachable
only via the trampolines.

## Window Layout

- **Window:**
  - Title: "Swift-Native API Coverage"
  - Size: 560 x 240 points
  - Position: centered on screen
  - Style: titled, closable, miniaturizable

- **Heading label:** "Swift-native APIs, reached via libAPIAnywareRacket trampolines"
- **Function row:** `CreateML.timestampSeed()` → the returned `Int` (time-derived)
- **Constant row:** `CreateML.MLCreateErrorDomain` → `com.apple.CreateML`
- **Footer:** note that neither symbol exists as a C symbol in the framework —
  both are trampolined Swift-native decls (`objc_exposed: false`).

## Exercised exemplars (spec §6a)

| Kind | Swift decl | Trampoline entry | C-ABI rep |
|---|---|---|---|
| scalar free function | `CreateML.timestampSeed() -> Int` | `aw_racket_swift_CreateML_timestampSeed` | `Int` |
| pointer constant | `CreateML.MLCreateErrorDomain: String` | `aw_racket_swift_const_CreateML_MLCreateErrorDomain` | `id` (NSString) |
