# 070-gerbil-extend

**Kind:** design+build (the architecturally hard target — grill, then decompose)

## Goal

Extend the mechanism to **gerbil**, the hard case: it has **no Swift dylib** by
design (ObjC-in-`gsc` native core, ADR-0017). A trampoline for Swift-native APIs
**must** be Swift (only Swift can call the Swift ABI), so gerbil must grow a Swift
compilation unit — a real deviation from ADR-0017 to design deliberately.

## Context

Builds on 030 (shared IR) + the racket/chez mechanism (040/060). Gerbil compiles
Scheme → Gambit → C → static exe; native core authored as ObjC compiled by `gsc`
into the static-exe (ADR-0017), kept self-contained (ADR-0009 / static-exe).

## Open design question (grill)

- **Swift dylib as a build-time WIN, not just a cost (N1, user 2026-06-15).**
  Gerbil's defining pain is compile time (ADR-0023 generics 5h→8.4min without
  optimisation; ADR-0017 precompilation amortisation). Moving native code into a
  **Swift dylib could offload work out of the `gsc` compile** and ease build times.
  ⇒ evaluate: does adopting a Swift dylib for gerbil (at least for the trampoline,
  possibly more of the native core) net-improve build time while staying
  self-contained? Weigh against ADR-0017's self-contained static-exe property.

## Done when

- Gerbil trampoline mechanism designed (Swift unit vs alternatives), built, and
  **VM-verified**; pipeline rerun.
- The ADR-0017 deviation recorded (new ADR): why gerbil grows a Swift unit, and
  the build-time finding (N1) measured, not just asserted.
- Completes the charter's "rerun every target" done-bar → grove ready to finish.

## Notes

- Last target; its completion gates grove-finish and unpauses
  `add-sbcl-clos-target` (whose Swift library is this model's trampoline layer).
