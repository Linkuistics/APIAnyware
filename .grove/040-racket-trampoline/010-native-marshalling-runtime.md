# 010-native-marshalling-runtime

**Kind:** work

## Goal

Build the **racket native-lib marshalling layer** that the generated trampolines
(020) will call — everything in the ADR-0027 taxonomy that the existing runtime
does **not** already provide. This is the foundation; 020's `@_cdecl` bodies bind
to it.

## Scope (per `docs/specs/2026-06-15-racket-trampoline.md` §3)

Already present, reuse as-is: `StringConversion.swift` (String↔NSString),
`CollectionMarshal.swift` (Array/Dictionary↔NS), `StructMarshal.swift` (geometry
pack/unpack), and the GC/will lifetime machinery.

New, in `swift/Sources/APIAnywareRacket/`:

- **Opaque-handle infra** — heap-box a non-bridged Swift `struct` / payload `enum`
  / tuple and return an opaque pointer; `Unmanaged`-retain a class instance /
  existential / `some P`. Generated-friendly primitives so 020 can emit
  `aw_racket_box_<T>_<field>` / `_tag` / `_free` against them. Wire `_free` into
  the existing finalization/will path — do **not** invent a new lifetime model.
- **`throws` bridge** — the trailing `NSError**` out-param convention (mirror the
  dispatch table's `error_out` shape).
- **`async` bridge** — a completion-callback trampoline, main-thread aware
  (reuse `main-thread.rkt` / the existing callback machinery; respect the
  foreign-thread SIGILL constraint noted in the function emitter).
- **Any missing value bridge** — e.g. `Set`→list if absent.

## Done when

- `swift build` green; `APIAnywareRacketTests` cover the new infra (box round-trip,
  handle free, error out-param, async completion) the way the existing
  `*MarshalTests` / `*BridgeTests` do.
- The exports are named and shaped so 020 can bind them mechanically (sanity-check
  against spec §2 naming + §3 taxonomy before declaring done).

## Notes

- Racket-local (ADR-0011). No shared substrate with chez/gerbil.
- If the taxonomy needs a rep the spec didn't pin, decide it here and update
  spec §3 rather than leaving 020 to guess.
