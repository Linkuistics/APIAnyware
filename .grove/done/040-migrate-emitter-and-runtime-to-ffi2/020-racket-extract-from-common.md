# 020-racket-extract-from-common

**Kind:** work

## Goal
Make `APIAnywareRacket` self-contained (ADR-0011, hermetic isolation): extract
the `APIAnywareCommon` code racket actually uses into `APIAnywareRacket`, and drop
the `APIAnywareCommon` dependency edge from `swift/Package.swift` for the racket
target. Rehome the relevant `APIAnywareCommonTests` into `APIAnywareRacketTests`.
Do **not** modify Chez/Gerbil — Chez de-shares in its own grove
(`chez-adopt-native-binding`); Gerbil is an inert stub.

**What racket actually uses (010 spike, via `swift-helpers.rkt`):**
StringConversion, StructMarshal, ClassLookup, MemoryManagement, AutoreleasePool,
ObservationBridge. Rehome these. **Do NOT rehome `MessageSend.swift`
(`aw_common_msg_*`) — it is dead code** (the spike found zero callers in
`generation/` or `runtime/`; generated bindings dispatch in-Racket today). It is
superseded by the generated typed native dispatch (leaf 040, ADR-0013) — drop it,
don't carry it over.

## Done when
- `APIAnywareRacket` no longer depends on `APIAnywareCommon`; it builds and its
  Swift tests pass standalone.
- Chez/Gerbil are untouched and still build (they keep depending on Common for
  now).
- The racket-side absorbed copy is shaped per the 010 design spec (it's what
  grows under 030–050).

## Notes
- Shape gated on **010**'s racket-native-lib design — run 010 first.
- `APIAnywareCommon` is NOT deleted here — deletion is the job of whichever grove
  (racket or chez) de-shares last, once no real consumer remains (only the inert
  Gerbil stub). See the node BRIEF decision #3.
