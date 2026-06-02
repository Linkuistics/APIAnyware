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

## 1. Outbound dispatch — exploratory single-shape pass (`run.sh`, send `-hash`)

This first pass (selector `-hash`, scalar return) compared mechanisms against the
*all-object* `tell` macro. It is superseded by the multi-shape, honest-baseline
pass in §1b — kept for the record. Approx ns/call: C-floor ~2.5; in-Racket `tell`
~90–110; native typed via ffi2 (SEL cached) ~20; native libffi (CIF cached) ~39;
NSInvocation ~680; selector-string-per-call ~86 (→ **SEL caching is essential**,
costs ~65 ns).

> ⚠️ **Superseded reading.** This pass concluded "libffi is the viable generic
> dispatcher, 2.3× faster than `tell`." That measured libffi against the *slow
> all-object `tell` path*, the wrong baseline for the typed shapes a generated
> entry replaces. Against the honest baseline (in-Racket typed `get-ffi-obj`
> msgSend, §1b) **libffi is actually slower** on scalar/pointer/float and only
> wins on struct returns — it is dominated by generated-typed everywhere. §1b is
> the decision-grade data.

- **Caveat — bottleneck relevance (still holds).** Per-method dispatch is not the
  GUI-app bottleneck; the ADR-0010 case is primarily architectural (thin scripting
  side), with performance a by-product.

## 1b. Multi-shape dispatch, honest baseline (`bench2.rkt`) — decision-grade

Controlled `AWSpikeTarget` with four representative ABI shapes, each dispatched
three ways. **Baseline corrected vs §1:** for shapes needing typed dispatch
(non-all-object), the *honest* status quo is not `tell` (the ~90 ns macro, used
only for all-object shapes) but Racket's **typed `get-ffi-obj objc_msgSend`**
(`DispatchStrategy::TypedMsgSend`) — already ~10 ns. Measured ns/call, two runs
(N=3M; struct N=1.5M):

| shape | racket-msgsend (status-quo typed) | **generated-typed** | libffi-generic |
|---|--:|--:|--:|
| `h` → uint64 (scalar) | ~10 | **~5** | ~19 |
| `idfor:` → id (pointer both ways) | ~12 | **~6** | ~22 |
| `rectfor:` → CGRect (**struct return**) | ~90 | **~11** | ~26 |
| `addx:y:` → double (2 float args) | ~12 | **~6** | ~27 |

**Three decisive results:**
1. **Generated-typed wins every shape** — ~2× the status-quo typed msgSend on
   simple shapes, **~8× on struct returns** (11 vs 90 ns). ~5–6 ns is essentially
   "ffi2 callout + objc_msgSend": the generated C entry does the ABI in compiled
   code, ffi2 just calls it.
2. **The struct-return gap is the marshalling-depth thesis in miniature.** Racket
   pays ~90 ns to marshal a `CGRect` return; the native entry unpacks it in ~11.
   Pushing ABI work native is an order of magnitude where the value crosses.
3. **libffi is dominated — not a contender.** It is *slower* than the status-quo
   typed msgSend on scalar/pointer/float (19–27 vs 10–12 ns), winning only on
   struct returns, and ~3–4× slower than generated-typed everywhere. It interprets
   an `ffi_cif` per call. **Dropped to escape-hatch only** (statically un-typable
   signatures). The §1 "libffi viable" reading was an artifact of the wrong (slow
   `tell`) baseline.

The combinatorics (§2b) are the asset that makes generated-typed free: the API
analysis enumerates every signature, so we generate exactly the typed entries and
regenerate them — never hand-written.

*Measurement caveat:* loops discard results, so the optimiser may elide a little;
the struct out-buffer write resists elision. Relative ordering is stable across
runs and an earlier checksum-matched variant confirmed correctness.

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
  real typed-entry count sits between 160 and 213. This struct-ABI complexity is
  the one place libffi has an *engineering* edge (it derives layout from
  `ffi_type` descriptors) — but **the emitter has the same information from the
  IR** and generates the correct struct layout per entry, so the C compiler does
  the same job at compile time. §1b shows generated-typed is ~2.4× faster than
  libffi *on exactly the struct-return shape* (11 vs 26 ns) — so the codegen path
  both sidesteps the minefield and wins. The count is not a reason to prefer
  libffi.

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

- **D1 (dispatch) — SETTLED: generated typed native dispatch (ADR-0013).** The
  multi-shape honest-baseline pass (§1b) is decisive: generated-typed is fastest
  on every shape (~2× the status-quo typed msgSend, ~8× on struct returns), and
  libffi is *dominated* (slower than the status quo on non-struct shapes). The
  "combinatorial" objection (§2b) dissolves because the entries are generated from
  the IR, not hand-written — the API analysis enumerates every signature. libffi
  is retained only as the escape hatch for statically un-typable signatures. The
  earlier "three live options incl. libffi generic dispatcher" framing was based
  on the superseded §1 baseline.
- **D2 (embedding direction / callbacks).** Stay **outbound** (Racket→Swift via
  ffi2/C-ABI on opaque pointers); **do not** adopt ffi2 callbacks (void-broken +
  foreign-thread SIGILL); **do not** pursue inbound Racket-CS C-embedding (no
  evidence it's needed, large complexity). Keep `_cprocedure` callback creation
  behind the **native Swift trampolines**, with foreign-thread safety owned in
  native (bounce to main). This is the current model — ADR-0010 *endorses and
  strengthens* it rather than replacing it.
