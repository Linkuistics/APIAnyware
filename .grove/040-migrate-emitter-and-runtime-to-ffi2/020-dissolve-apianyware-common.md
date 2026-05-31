# 020-dissolve-apianyware-common

**Kind:** work

## Goal
Dissolve the shared `APIAnywareCommon` Swift target (ADR-0011): split its code
into each of `APIAnywareRacket` / `APIAnywareChez` / `APIAnywareGerbil`, delete
the `APIAnywareCommon` target and its dependency edges from `swift/Package.swift`,
and rehome `APIAnywareCommonTests` into each target's own test target. Each
language dylib becomes fully self-contained.

## Done when
- `APIAnywareCommon` no longer exists; `swift/Package.swift` has no shared target.
- All three dylibs build; **all three targets' Swift tests pass.**
- Racket's absorbed copy is shaped per the 010 design spec (it's the one that
  then grows under 030–050); Chez/Gerbil get a faithful absorbed copy (no
  behaviour change intended — their bar is build + tests green).

## Notes
- Shape gated on **010**'s racket-native-lib design — run 010 first.
- Chez/Gerbil full VM-verify is out of scope (flagged regression risk).
