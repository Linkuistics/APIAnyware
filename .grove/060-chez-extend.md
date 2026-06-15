# 060-chez-extend

**Kind:** work (decompose if the ADR-0011 question reopens)

## Goal

Extend the proven mechanism to the **chez** target. Chez ships a Swift dylib
(`APIAnywareChez`), so this is the second-easiest target — and the first point
where the **per-target-vs-shared-source** question for the trampoline becomes real
(two Swift-trampoline targets now exist).

## Context

030's IR change is shared (already done). This leaf is chez-side: extend
`APIAnywareChez` to vend the C-ABI trampolines, emit the thin `foreign-procedure`
bindings (ADR-0015 chez direct dispatch + scheme marshalling), handle
pointer-constants. Chez is compiled-FFI + self-contained bundle (ADR-0009) — same
family as the paused sbcl target that adopts this next.

## Done when

- chez trampolines + emitter bindings landed; pipeline rerun; **VM-verified**.
- **ADR-0011 shared-source question explicitly resolved:** keep hermetic
  duplication (the ADR-0011 default) unless racket+chez duplication is painful
  enough to justify a shared Swift trampoline source — record the call either way.

## Notes

- Per D1/D2 the mechanism is proven on racket first; this is horizontal port, not
  rediscovery. Watch for chez-specific marshalling differences vs racket.
