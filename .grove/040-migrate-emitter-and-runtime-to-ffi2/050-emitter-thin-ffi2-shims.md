# 050-emitter-thin-ffi2-shims

**Kind:** work

## Goal
Cut the emitter over to thin Racket shims that call the native binding, walking
the **marshalling-depth spectrum** (spec §3): each generated method wrapper
becomes ideally a single coercion-free ffi2 call into a native entry that does
dispatch + argument/result marshalling + lifetime. Regenerate the full pipeline.

Design: `docs/specs/2026-05-31-racket-native-binding-design.md` §3, §6.

## Scope
- `emit_class.rs` routes dispatch to the generated native entries (leaf 040) and
  marshals strings/structs/collections at the depth the IR types warrant
  (Depth 1 across the surface; Depth 2 — batched `string<->NSString`,
  `list<->NSArray`, `hash<->NSDictionary`, `NSError**` → `(values result error)`
  — for the known hot/clunky cases in `type-mapping.rkt`).
- `emit_functions.rs` / `emit_constants.rs` already on ffi2 from leaf 030; ensure
  the shim style is consistent.
- Returned-object lifetime: encode `+0`/`+1` ownership (IR `returns_retained`) so
  the Racket side attaches the right finalizer (spec §8 open item 1).
- Regenerate the full pipeline; update snapshot goldens intentionally.

## Done when
- The emitter emits thin shims; per-method Racket wrappers carry no per-call
  coercion logic that the native entry could own.
- The full pipeline regenerates clean; racket build + Swift tests green.

## Notes
- Per ADR-0010: the target language should not have to consider the FFI boundary
  — this leaf is where that goal is realised in the emitted surface.
- Coordinate the depth boundary with leaf 040 (some marshalling may live in the
  dispatch entry itself).