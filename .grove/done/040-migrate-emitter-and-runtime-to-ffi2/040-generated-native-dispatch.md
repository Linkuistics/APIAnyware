# 040-generated-native-dispatch

**Kind:** work

## Goal
Build the **generated typed native dispatch** core (ADR-0013): from the IR's
per-method ABI signatures, generate one typed native (Swift/C) `objc_msgSend`
entry per distinct signature in `APIAnywareRacket`, and route the emitter's
class/method wrappers to call them through a thin ffi2 binding instead of
in-Racket `tell`/`_msg-N`. This is the §2 core of the design spec and the
highest-leverage performance + ADR-0010 win in the node.

Design: `docs/specs/2026-05-31-racket-native-binding-design.md` (§2, §3).
Evidence: `docs/research/2026-05-31-racket-ffi2-spike/FINDINGS.md` (generated-typed
~6 ns/call: ~3.5× faster than the status-quo typed msgSend, 5.4× on structs).

## Scope
- **Signature source:** reuse the dedup the emitter already computes
  (`shared_signatures.rs` `SignatureMap`, `collect_class_signatures`). It keys
  Racket ctypes (213 in the golden subset); the native side keys ABI shapes (160)
  — decide whether to dedup further at ABI level or generate per-IR-signature
  (simpler; ~25% more entries — measure before optimising).
- **Native generator:** a new emit step producing typed entries, e.g.
  `uint64_t aw_racket_msg_<sig>(void *self, void *sel, ...)` casting
  `objc_msgSend` to the concrete `@convention(c)` shape. Struct returns use the
  out-buffer convention (spike `aw_t_rectfor` pattern); pre-registered SEL
  pointers (no per-call string marshalling — spike showed ~65 ns penalty).
- **Emitter routing:** `emit_class.rs` emits, per method, a `define-ffi2-...`
  binding to the entry + the thin Racket wrapper. Keep `tell` as the fallback
  for all-object shapes *only if* measurement shows the generated path isn't
  worth it there (it is: ffi2 callout ≈3.5× lighter than ffi/unsafe — so route
  those too).
- **libffi escape hatch:** retain a single generic libffi dispatcher for any
  signature the emitter cannot type statically (variadics are already filtered;
  confirm none slip through). Spec §6 open item.
- **`->` discipline:** generated Racket modules mixing ffi2 arrow types with any
  retained `ffi/unsafe` must use `(except-in ffi/unsafe ->)` (NOT
  `rename-in ffi2`, which breaks nested arrow parsing) — spike finding, spec §5.

## Done when
- The native dispatch entries are generated into `APIAnywareRacket` and built.
- The emitter routes class/method dispatch through them; the full pipeline
  regenerates clean (don't trust stale `.rkt` — standing rule).
- The racket build + `APIAnywareRacket` Swift tests are green; snapshot goldens
  updated intentionally (`UPDATE_GOLDEN=1`).
- VM-verify is deferred to root leaf 050 (per node BRIEF).

## Notes
- Depends on 030 (ffi2 seam + type-mapper + `ptr_t<->cpointer` bridge) and 020
  (racket self-contained in `APIAnywareRacket`).
- The marshalling *depth* of each entry (opaque vs typed-marshalling vs batched)
  is the spec §3 spectrum — coordinate with 050 (emitter thin-shim cutover) on
  how far each generated entry marshals; this leaf can start at dispatch-only and
  deepen, or generate Depth-1 entries directly. Decide at implementation time
  from the IR types.