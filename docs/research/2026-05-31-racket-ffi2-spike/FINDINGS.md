# Racket ffi2 native-binding spike — findings

**Date:** 2026-05-31
**Leaf:** `update-racket-to-9.2-and-use-ffi2/040.../010-design-and-spike`
**Decision framing:** D0 = "spike-decide first" (chosen by user). This spike
measures the two load-bearing unknowns — dispatch relocation cost and the
foreign-thread callback story — so D1 (dispatch mechanism) and D2 (embedding
direction) rest on numbers, not guesses.

**Repro:** `docs/research/2026-05-31-racket-ffi2-spike/` —
`bash run.sh` rebuilds `libspike.dylib` and runs the dispatch benchmark + the
callback-thread matrix. `racket diag3.rkt` runs the callback-shape isolation.
Throwaway spike code; not shipped. Host: macOS 26.x arm64, Racket v9.2 [cs],
ffi2-lib installed (leaf 030).

---

## 1. Outbound dispatch microbenchmark (sending `-hash`, N=3,000,000)

| approach | ns/call | vs `tell` |
|---|--:|--:|
| C floor (objc_msgSend loop in C, one FFI crossing) | ~2.5 | — |
| **in-Racket `tell`** (today's path, SEL cached by macro) | **~90–110** | 1.0× |
| **native typed via ffi2** (C `objc_msgSend` shim, SEL cached) | **~20** | **~4–5× faster** |
| native typed via ffi2 (selector string marshalled per call) | ~86–94 | ~1× |
| **native libffi generic via ffi2, CIF cached** | **~39** | **~2.3× faster** |
| native libffi generic via ffi2, CIF rebuilt per call | ~49 | ~1.8× faster |
| native NSInvocation generic via ffi2 | ~660–680 | **~7× slower** |

**Reading.**
- The ffi2↔`ffi/unsafe` seam is *cheap*: routing dispatch through a native typed
  C shim via ffi2 is **5× faster** than today's in-Racket `tell`. This inverts
  the a-priori fear that the seam tax would make relocation a loss.
- **SEL caching is essential**: passing the selector as a string per call adds
  ~65 ns (string marshalling). A relocated dispatcher must pre-register SELs.
- **NSInvocation loses badly** (~7× slower than `tell`) — not viable as a generic
  dispatcher. **But libffi is the viable generic dispatcher** (D1 follow-up
  spike): ~39 ns CIF-cached, **2.3× faster than `tell`** and ~17× faster than
  NSInvocation. Crucially it is *one* generic native function — no per-signature
  typed-entry library. CIF caching only saves ~10 ns on this 2-arg signature
  (would widen for richer signatures), so even CIF-per-call (~49 ns) beats `tell`.
  Ranking: typed-native (20) < libffi (39) < tell (90) ≪ NSInvocation (680).
- **Caveat — bottleneck relevance.** 90 ns/call saved matters only at millions
  of calls/sec. The racket sample apps are GUI apps; per-method dispatch is *not*
  their bottleneck. The speedup is real but the *workload* does not need it. The
  ADR-0010 case for relocation is therefore architectural (thin scripting side),
  not performance-urgent.
- **Caveat — bridging tax not isolated.** This bench bridged the target pointer
  once (stable object) and returns `uint64`. Methods that take/return `_id` pay
  `ptr_t<->cpointer` bridging both ways per call (020 §2); a relocated dispatcher
  carrying `_id` values would pay more than the 20 ns measured here.

## 2. Callback / foreign-thread matrix (020's biggest unknown)

`callback-thread.rkt` × `diag3.rkt`. A callback is invoked on: the main thread,
a fresh C `pthread`, and a GCD global-queue worker.

| callback kind | main thread | foreign pthread / GCD |
|---|---|---|
| `_cprocedure` + `function-ptr` (today) | OK | **SIGILL** (never fires) |
| ffi2 callback, raw lambda, **non-void** return | OK | **SIGILL** (never fires) |
| ffi2 callback, raw lambda, **void** return | **BROKEN** (ffi2 bug) | (n/a) |
| pre-made `ffi2-callback` → arrow-typed param | type mismatch (wrong usage) | — |

**Reading.**
- **Foreign-thread invocation SIGILLs for *both* `_cprocedure` and ffi2** — the
  callback never even fires. The doc's "*subject to `call-in-os-thread`
  constraints*" is **not automatic**: a C-created OS thread is not registered
  with the Racket CS runtime, so entering Racket from it crashes. **ffi2 does NOT
  solve the foreign-thread callback problem.** It must be solved in the native
  layer: the Swift trampoline that receives the ObjC call bounces to a
  Racket-safe thread (the existing `main-thread.rkt` GCD-to-main model) before
  invoking the Racket callback. ADR-0010-aligned: native owns thread-safety.
- **ffi2's idiomatic callback form** is *declare the parameter as an arrow type
  and pass a raw Racket lambda* (ffi2 auto-creates + auto-retains for synchronous
  callouts). Passing a pre-made `(ffi2-callback ...)` to an arrow-typed parameter
  is a **type error** — pre-made callbacks go to `ptr_t`-typed params.
- **Void-returning ffi2 callbacks are BROKEN — root cause found.** Reproducible
  with zero `ffi/unsafe` (`diag3.rkt`/`diag4.rkt`); non-void (`int`) callbacks
  work. The bug is in ffi2's `build-ffi2-procedure` wrapper
  (`ffi2-lib/.../core.rkt:986`): for any callout it emits
  `(let-values ([(out out-errno ...) (proc in ...)]) ((ffi2-type-c->racket out-t) out) …)`.
  For a `void_t` result `(ffi2-type-c->racket void_t)` is `#f`, so applying it
  yields "not a procedure: #f". Every void-callback spelling fails (`(void)` →
  not-a-procedure; returning `0` → "foreign-callback result does not match type";
  `(values)` → arity mismatch; pre-made `ffi2-callback` → param type mismatch).
  Since void is the dominant delegate/block-handler shape (`windowWillClose:`,
  completion handlers), this alone disqualifies ffi2 callbacks for our callback
  layer — independent of the foreign-thread SIGILL. **It is an upstream ffi2 bug**
  (could be reported), but we should not block the migration on an upstream fix.

## 2b. The "combinatorial" cost of typed-native dispatch — measured

`objc_msgSend` cannot be called variadically on arm64: each call must cast it to
a concrete `@convention(c)` function pointer matching the exact ABI shape (see
`MessageSend.swift` — one `typealias`/entry per shape). So a *typed-native*
dispatch library needs **one compiled entry per distinct ABI signature**. libffi
needs **one** generic entry for all of them (it builds the call frame at runtime
from an `ffi_type` description).

Counted across the 30 golden class files (curated AppKit+Foundation subset; full
IR is gitignored and several× larger):

| metric | count |
|---|--:|
| typed-dispatch call sites | 814 |
| distinct **IR-level** signatures (`_msg-N` dedup keys today) | **213** |
| distinct **ABI-collapsed** shapes (typed-native entries needed) | **160** |

Theoretical space is `Σ_{k=0}^{n} c^{k+1}` (≈ millions for c≈8, n≈6) — but that's
never populated; the empirical count is what matters. Distribution: ~25 shapes
cover most of the 814 uses (`P P -> I64` ×33, `P P -> I32` ×31, `P P I64 -> void`
×29 …); the **tail is ~90 shapes appearing exactly once** (e.g.
`(P P S:_NSRect S:_NSRect I64 F I32 P -> void) ×1`), each needing its own native
entry to serve a single method.

**Consequences for D1.**
- Typed-native relocation = growing `MessageSend.swift` from ~18 entries to
  **160+ and growing with every new framework/method** — an open, ever-expanding
  set. (Today's ~18 native entries cover almost none of these, which is *why*
  generated code dispatches in-Racket.)
- The 213→160 collapse (25%) is ABI-equivalence the native side gets free
  (`_id`/`_pointer`/`_string`→one pointer class; `_int32`/`_bool`→one int class).
- **Honest caveat:** 160 slightly *under*counts true typed entries — arm64 cares
  about struct-by-value layout (NSRect=4×SIMD, NSRange=2×int, small vs large
  struct returns) and some width/signedness, which my coarse collapse merged. The
  real typed-entry count sits between 160 and 213. libffi derives all of this from
  `ffi_type` descriptors automatically, sidestepping the per-entry struct-ABI
  minefield — which strengthens, not weakens, the libffi case.

## 3. Disposition facts established

- **`MessageSend.swift` (`aw_common_msg_*`) is dead code** — grep finds **no
  callers** in `generation/` or `runtime/`. Generated bindings dispatch entirely
  in-Racket (`tell` / dedup'd `_msg-N` typed `get-ffi-obj`, per
  `method_filter.rs` `DispatchStrategy`). So a native typed-dispatch table would
  be a *new* path, not reuse — and the existing one can be deleted, not rehomed.
- **What the runtime actually uses native for** (`swift-helpers.rkt`):
  `aw_common_*` → autorelease push/pop, retain/release, get-class, sel-register,
  string conversion; `aw_racket_*` → block bridge, delegate bridge, GC
  prevention. **Never message dispatch.**
- **ffi2 closes two 020 gaps:** `ffi2-sizeof` exists (020 open-item #2);
  `ptr_t->cpointer` / `cpointer->ptr_t` bridges present and work.
- **`->` collision is a real migration constraint:** `ffi2` and `ffi/unsafe`
  both export `->`. Any module mixing ffi2 arrow types with `ffi/unsafe`'s `_fun`
  collides. **`(rename-in ffi2 [-> ffi2->])` breaks ffi2's *nested* arrow-type
  parsing** (callback param types) — so the rename must be on `ffi/unsafe`'s side
  (`(except-in ffi/unsafe ->)`) or the two libraries kept in separate modules.

## 4. Conclusions feeding D1 / D2

- **D1 (dispatch).** libffi is now proven as a viable *generic* native dispatcher
  (~39 ns, 2.3× faster than `tell`, no per-signature library). Three live
  options: (a) **conservative** — keep per-method `tell`, aim ADR-0010 at batch
  marshalling + the native callback trampoline, ffi2 only for the C-function
  layer; (b) **libffi generic dispatcher** — one native dispatch entry point the
  emitted shims call, 2.3× faster *and* it shrinks the Racket dispatch surface
  toward the ADR-0010 "thin scripting side" goal; (c) typed-native per-signature
  (fastest at 20 ns but combinatorial). The per-call speed is not the GUI
  bottleneck, so (b)'s real appeal is *architectural* (thin seam), not perf.
- **D2 (embedding direction / callbacks).** Stay **outbound** (Racket→Swift via
  ffi2/C-ABI on opaque pointers); **do not** adopt ffi2 callbacks (void-broken +
  foreign-thread SIGILL); **do not** pursue inbound Racket-CS C-embedding (no
  evidence it's needed, large complexity). Keep `_cprocedure` callback creation
  behind the **native Swift trampolines**, with foreign-thread safety owned in
  native (bounce to main). This is the current model — ADR-0010 *endorses and
  strengthens* it rather than replacing it.
