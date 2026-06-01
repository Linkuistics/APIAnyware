# 050-emitter-thin-ffi2-shims — brief

**Kind:** node (decomposed 2026-06-01 during execution — the spectrum is genuinely
multi-session)

## Goal
Cut the emitter over to thin Racket shims that call the native binding, walking
the **marshalling-depth spectrum** (spec §3): each generated method wrapper
becomes ideally a single coercion-free ffi2 call into a native entry that does
dispatch + argument/result marshalling + lifetime.

Design: `docs/specs/2026-05-31-racket-native-binding-design.md` §3, §6.

## Why decomposed
Leaf 040 routed only the *typed-scalar* surface natively
(`DispatchStrategy::TypedMsgSend`, non-`_id` property setters, typed
constructors). The rest still rides `tell`/`get-ffi-obj`: all-object dispatch,
property getters, struct-by-value returns (`frame`), string args, collections.
Closing the whole spectrum in one commit is too big and too risky to verify
against the one local witness (the committed synthetic **TestKit** golden — no
local enriched IR, so real-framework regen + VM-verify is the **root 050** leaf's
job). The spectrum splits cleanly along §3's depth ordering.

## Child leaves (depth ordering, spec §3)
- **010 pointer-surface native dispatch** — route the *pointer-shaped* remainder
  (all-object `Tell`-strategy methods + object/scalar **property getters** +
  object returns) through the generated native entries. No new native marshalling
  — objects/scalars already cross as `ptr_t`/scalar; this is pure routing
  widening + result wrapping, the largest slice. Widen `collect_class_native_sigs`
  in lockstep. `tell` stays only as the non-routable fallback (full fallback
  deletion is **060**). Witness: TestKit golden `title`/`description`/`hidden`
  getters collapse to native.
- **020 struct-by-value marshalling** — the §3 8× headline. Add a struct ABI to
  `native_dispatch.rs` (ffi2 `struct_t` ⇄ Swift `@_cdecl` by-value/out-buffer
  matching the arm64 `objc_msgSend` struct convention), route NSRect/NSPoint/
  CGAffineTransform-family returns & params natively. Witness: TestKit `frame`.
- **030 Depth-2 strings + collections** — native `char*`⇄NSString (returned-string
  ownership = +0/borrowed, ffi2 `string_t` copy-on-read) + `_string` made routable
  (`AbiType::CStr`), and batched `list`⇄NSArray / `hash`⇄NSDictionary
  (`CollectionMarshal.swift`). Moved `type-mapping.rkt`'s per-element `tell`
  conversions native; verified by a runtime round-trip smoke. **DONE 2026-06-01.**
- **040 nserror-out-params** — NSError `**` out-params → `(values result error)`,
  split out of 030 (decision 2026-06-01): no local witness, needs emitter+IR work
  the marshalling slices didn't. **NEW.**

## Cross-cutting (each leaf preserves)
- **Returned-object lifetime (+0/+1)** is already encoded via `returns_retained`
  → `#:retained` and threads through every leaf — not a separate leaf.
- **Build-green bar per leaf:** TestKit golden regenerated intentionally; `cargo
  test` green; `swift build` compiles the regenerated `Dispatch.swift`. Real-IR
  full-pipeline regen + VM-verify is **root 050**.
- **`emit_functions.rs`/`emit_constants.rs`** already ffi2 from leaf 030; keep the
  shim style consistent as each leaf touches the surface.

## Notes
- Per ADR-0010: the target language should not have to consider the FFI boundary —
  this node is where that goal is realised in the emitted surface.
- **Symlink fix (carryover from 040):** `lib/libAPIAnywareRacket.dylib` points at
  the *main* repo's `.build`, not this worktree's. Any leaf that loads generated
  bindings here must repoint it (decide committed vs worktree-local).
- **Build order (ADR-0013):** `generate → swift build` (generate writes
  `Dispatch.swift`, gitignored; swift compiles it).
