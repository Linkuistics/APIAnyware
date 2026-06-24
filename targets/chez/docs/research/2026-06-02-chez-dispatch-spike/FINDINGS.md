# Chez dispatch / marshalling / foreign-thread spike — FINDINGS

**Grove:** `chez-adopt-native-binding`, leaf `010-design-and-spike`.
**Date:** 2026-06-02. **Host:** macOS arm64, Chez Scheme 10.4.1 (Homebrew,
**threaded** build), Apple clang / Swift 6.3.2.
**Status:** throwaway spike. The durable record is this file plus the design
spec (`generation/targets/chez/docs/design/2026-06-02-chez-native-binding-design.md`) and ADR-0015 /
ADR-0016. Reproduce with `./build.sh && chez --script bench.ss` and
`for s in direct pthread pthread-act gcd gcd-act; do chez --script callback-thread.ss $s; done`.

## Why this spike exists

The grove's design grilling left three things to **measure, not reason about**
(running log D1–D3 in the leaf):

1. **Dispatch posture (measure-first, no prior lean).** Racket relocated outbound
   dispatch into generated native entries (ADR-0013) because its FFI crossing was
   interpreted/macro-heavy. Chez's `foreign-procedure` already compiles to a
   *direct* typed `objc_msgSend` call. Does relocating dispatch into a native
   shim help or hurt?
2. **Marshalling payoff.** Does a native entry doing the ObjC marshalling beat
   chez-side coercion + direct call, for strings and collections?
3. **Foreign-thread callback safety.** Can a Chez `foreign-callable` be entered
   from a non-Scheme OS thread (the chez analogue of racket's ffi2 callback
   SIGILL)? Is a main-thread bounce mandatory?

Methodology mirrors the racket spike (`docs/research/2026-05-31-racket-ffi2-spike/`)
on chez's own runtime, per ADR-0011 (reuse racket's *reasoning*, not its numbers).

---

## Part A — dispatch (hop isolation)

Steady-state ns/call, 3M iterations after warm-up + full GC, two-run consistent.
"direct" = Chez calls `objc_msgSend` itself via a typed `foreign-procedure` (the
status quo). "native shim" = a `aw_chez_send_<sig>` C function that forwards to
`objc_msgSend` (one extra native call). "libffi" = generic dispatcher, CIF cached.

| ABI shape | direct `foreign-procedure` | native typed shim | libffi generic |
|---|--:|--:|--:|
| scalar `(id,SEL,long)->long` | **~6–9** | ~6–8 | ~21 |
| `id->id` `(id,SEL,id)->id` | **~17** | ~17–18 | — |
| 2×float `(…,dbl,dbl)->dbl` | **~6.4** | ~6.8 | — |
| struct ret `(id,SEL)->NSRect` | **~10.5** | ~33 (flat buffer) | — |

**Verdict — keep dispatch direct.** The native shim is *statistically equal* to
direct `foreign-procedure` on scalar / id / float (the extra C call is in the
noise), and **~3× slower on struct returns** (the flat-buffer round-trip costs
more than chez's native `(& NSRect)` indirect-result ABI). libffi-generic is ~3×
slower than direct. Chez's typed `foreign-procedure` is **already at the native
dispatch floor** — relocating dispatch into a generated native entry adds a hop
and buys nothing. This is the **inverse of racket** (ADR-0013), where the native
entry *won* because it beat racket's interpreted FFI; chez has no such overhead
to beat. (The ~6 ns floor itself confirms the harness runs compiled trampolines,
not an interpreter — Chez compiles top-level forms.)

The decision rule (leaf D2): "keep dispatch direct unless the native shim is
faster on simple shapes." It is not faster — equal at best, worse on struct — so
the rule resolves to **keep direct**.

---

## Part B — marshalling payoff

| operation | chez-side coercion + direct call | native one-call |
|---|--:|--:|
| string in/out `-appendBang:` (3 crossings vs 1) | ~276 | ~242 (−12%) |
| `list->NSArray`, 8 elems — chez per-element loop | **~666** | joined+split ~1085; char** batch ~1456 |

**Verdict — keep marshalling in Scheme; no material native win.** The string
round-trip is only ~12% faster natively, and that margin is the NSString
allocation/append work (which both paths pay), *not* the FFI crossings. For
collections, **no native batch beats chez's direct per-element loop** — both the
"joined string + `componentsSeparatedByString:`" and the "`char**` batch"
approaches are *slower*, because (a) chez crossings cost only ~6–17 ns so there
is almost nothing to save by avoiding them, and (b) the native batch incurs its
own work (string-split, or per-element chez→C marshalling into a `void*` array).

This is again the inverse of racket, where each `tell` was ~90 ns interpreted, so
batching N elements natively was a large win. **Chez's cheap compiled crossings
remove that headroom.**

---

## Part C — foreign-thread callback safety

Each stage runs in a *separate process* so a crash can't mask later stages. The
callback does real Scheme heap work (`make-vector` + mutate). `isMainThread`
printed from C before entering Scheme.

| stage | thread | result |
|---|---|---|
| `direct` | main (isMainThread=1) | **SURVIVED** |
| `pthread` | fresh pthread (0) | **CRASH** — nonrecoverable invalid memory reference |
| `pthread-act` | fresh pthread + `Sactivate_thread` | **SURVIVED** |
| `gcd` | `dispatch_async` global queue worker (0) | **CRASH** |
| `gcd-act` | GCD worker + `Sactivate_thread` | **SURVIVED** |

**Verdict.** A Chez `foreign-callable` entered from *any* Scheme-unregistered OS
thread crashes hard — confirmed on both a raw pthread and a genuine GCD worker.
(An earlier `dispatch_sync` test spuriously "survived" because `dispatch_sync` on
the global queue runs the block **inline on the calling main thread** — a
measurement artifact, fixed here by using `dispatch_async` + a semaphore.)

**The chez-specific divergence from racket:** because the Homebrew Chez is a
**threaded** build, wrapping the callback body in
`Sactivate_thread()` / `Sdeactivate_thread()` makes a foreign thread safe to
enter Scheme — **both** the pthread and the GCD worker survive when activated.
Racket's ffi2 callbacks SIGILL with no fix, forcing a main-thread bounce always.
Chez therefore has **two** valid strategies for background callbacks:

1. **Bounce to the main thread** (current `cocoa.sls` `dispatch_async_f` path), or
2. **Activate the foreign thread** (`Sactivate_thread`-wrap the trampoline) and
   run the callback on the worker thread.

The main-thread bounce becomes an **AppKit/UI requirement** (UI mutation must be
on the main thread), *not* a Chez-safety requirement. Background callbacks that
don't touch UI (NSURLSession completions, `dispatch_async` compute) can run
safely on their worker thread once activated.

### Open items for the threading execution leaf
- `Sactivate_thread` returns an `int` disposition; a genuinely new thread context
  may need `Sdestroy_thread` (not just `Sdeactivate_thread`) to avoid leaking
  thread contexts across many short-lived worker callbacks. Confirm the
  bookkeeping.
- Interaction with the ADR-0007 lifetime model: the entry-point autoreleasepool
  is per-thread; the `objc-guardian` drain is process-wide. An activated
  background callback must push its own `@autoreleasepool` and must **not**
  assume the main thread's guardian-drain timing. Design the trampoline wrapper
  accordingly.
- Cost: `Sactivate_thread` per callback is not free; measure if a hot background
  callback path appears (none in the current sample apps).

---

## Bottom line

Chez's compiled `foreign-procedure` seam is **already thin** — at the native
dispatch floor and with crossings cheap enough (~6–17 ns) that relocating
dispatch *or* marshalling into the native library is neutral-to-negative.
ADR-0010's "fat native core behind a thin static crossing" is, for chez,
**satisfied by `foreign-procedure` itself**, not by relocating Scheme work. Chez
therefore adopts ADR-0010 differently from racket:

- **Dispatch + value marshalling stay in idiomatic Scheme** (ADR-0015).
- **The genuinely hard, can't-express-thinly concerns stay/deepen native** —
  blocks, delegates, dynamic classes, GC pinning, and now **foreign-thread
  activation** for background callbacks (ADR-0016).
- **Hermetic isolation (ADR-0011)** — absorb the 4 Common files chez uses, rename
  `aw_common_*` → `aw_chez_*`, drop the dependency, and turn out the lights on
  `APIAnywareCommon` (racket already de-shared on `main`).
