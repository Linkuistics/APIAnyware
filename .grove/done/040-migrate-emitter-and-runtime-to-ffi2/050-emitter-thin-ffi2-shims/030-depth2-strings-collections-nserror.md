# 030-depth2-strings-collections-nserror

**Kind:** work

## Goal
The Depth-2 surface (spec §3): move the per-element / per-value marshalling that
`type-mapping.rkt` does today in interpreted Racket into native batch helpers, so
the emitted wrappers stay thin for the clunky/hot cases:
- `string` ⇄ `NSString` (Depth 1 `char*` in/out, with returned-string ownership)
- `list` ⇄ `NSArray`, `hash` ⇄ `NSDictionary` (batched in one native call, not N
  per-element `tell`s)
- `NSError**` out-params → `(values result error)` resolved natively

Design: `docs/specs/2026-05-31-racket-native-binding-design.md` §3 Depth 2, §6
(`type-mapping.rkt` row → moves native), §8 open item 1 (returned-string/object
ownership).

## Scope
- **`native_dispatch.rs`:** make `_string` routable (currently the deliberate
  `None` arm) — native entry takes a UTF-8 `char*` param and/or returns a freshly
  owned `char*` (or writes via the Racket CS C-API). Resolve the content-addressed
  name collision noted in `AbiType::from_ffi_unsafe` (a `string_t` vs `ptr_t`
  binding must not share one symbol).
- **Returned-string ownership:** native returns +1-owned `char*`; Racket copies to
  a Racket string and frees — or native writes directly. Pick one, document it.
- **Collections:** native helpers `aw_racket_list_to_nsarray` / `..._from_nsarray`
  and dict equivalents in `APIAnywareRacket`; emitter routes collection params/
  returns to them instead of emitting per-element `tell` loops.
- **`NSError**`:** native out-param entry returns `(values result error)`.
- Sweep `type-mapping.rkt`: delete the per-element Racket conversions the native
  helpers now own (coordinate with leaf 060's fallback-deletion remit — keep this
  leaf to the *marshalling* move, leave broad fallback deletion to 060).

## Done when
- TestKit golden (and any string/collection-bearing class) emits native string/
  collection calls, no in-Racket per-element `tell` loops for these shapes.
- `cargo test` green; native helpers compile; runtime smoke if feasible.

## Notes
- This is the largest-marshalling, lowest-frequency slice — sequenced last because
  010 (bulk pointer dispatch) and 020 (struct headline) deliver more for less risk.
- ffi2 `string_t` already marshals Racket string → `char*` on the *binding* side;
  the question is who owns the *returned* buffer (§8 item 1).
