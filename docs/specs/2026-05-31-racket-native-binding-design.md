# Racket native-binding design — generated typed dispatch over a thin ffi2 seam

**Status:** design (grove `update-racket-to-9.2-and-use-ffi2`, leaf 040/010);
backed by the measurement spike in
`docs/research/2026-05-31-racket-ffi2-spike/` (`FINDINGS.md` + repro harness).

**Audience:** anyone extending the `racket` target, evaluating the same approach
for another target (chez), or auditing *why* the FFI boundary is shaped the way
it is. Assumes `CONTEXT.md` (Target, Target idiom, `objc-object`, Racket 9.2,
ffi2) and **ADR-0010** (the per-target native library *is* the binding) and
**ADR-0011** (targets hermetically isolated).

## Scope

The technical design record for how the `racket` target crosses into macOS:
**method dispatch, argument/result marshalling, callbacks, and memory** — and
how Racket 9.2's **ffi2** fits. It sets the per-concern disposition for the
runtime and the emitter, and it records the performance analysis that chose the
dispatch mechanism. It is the agreement artifact the execution leaves (020–060)
build against.

---

## 1. The objective function

ADR-0010 makes the per-target native (Swift) library *the* binding. This design
takes the strongest reading of that goal, set by the grove's guiding directive:

> **Optimise so the target language never has to consider the FFI boundary — as
> far as possible — and pay for it with generated native code, not interpreted
> scripting-language code.**

Two consequences drive every decision below:

1. **The scripting side is a thin, static seam.** The Racket wrapper for a method
   should ideally be a single typed FFI call into a native entry point that does
   the real work (dispatch + marshalling + lifetime). No per-call coercion logic
   interpreted in Racket; no `objc_msgSend` shape assembled at the Racket level.
2. **Performance is a first-class output, bought with code generation.** Because
   the `collect → analyse` pipeline *enumerates the entire API surface*, we can
   generate exactly the native code each method needs. Generation lets us choose
   the fastest mechanism even when it would be unaffordable to hand-write.

These compose into the headline architecture: **a fat native core (one generated,
compiled, ABI-correct entry per method signature) behind a thin static ffi2
crossing.**

---

## 2. The dispatch mechanism — analysis and decision

Outbound Objective-C method dispatch is the hot path and the largest surface
(`emit_class.rs` is the bulk of all generated bindings). The question: *how does
a Racket method wrapper invoke an ObjC method?* Five mechanisms were measured on
a controlled target across four representative ABI shapes (Racket v9.2 [cs],
macOS arm64; steady-state ns/call, two runs averaged; full method + raw data in
the spike `FINDINGS.md` §1b).

| mechanism | scalar | id→id | **struct ret** | 2×float | maintenance | generality |
|---|--:|--:|--:|--:|---|---|
| in-Racket `tell` (all-object macro path) | ~90 | ~93 | n/a¹ | ~110 | none | full |
| in-Racket typed `get-ffi-obj` msgSend (status quo for typed shapes) | ~10 | ~12 | ~90 | ~12 | none | full |
| native NSInvocation (generic) | ~680 | — | — | — | none | full |
| native libffi (generic, CIF-cached) | ~19 | ~22 | ~26 | ~27 | none | full |
| **native generated-typed (per signature)** | **~5** | **~6** | **~11** | **~6** | **generated** | exact |

¹ `tell` is the macro for all-object shapes; a `uint64`/struct return takes the
typed `get-ffi-obj` path, the honest status-quo baseline for this row.

### 2.1 Why generated-typed wins

- **Fastest of all options** — ~5–6 ns for simple shapes (~2× the status-quo
  typed `get-ffi-obj` msgSend, ~15× the all-object `tell` path), and **~8× faster
  on struct returns** (11 vs 90 ns). It approaches the pure-C floor because the
  generated C entry does the ABI in compiled code and ffi2 just calls it — and
  ffi2's callout path is itself leaner than ffi/unsafe's.
- **The struct-return result is the whole thesis in miniature.** The status quo
  pays ~90 ns to marshal a `CGRect` return through Racket; the native entry
  unpacks it in ~11. Pushing the ABI work native is not a micro-optimisation —
  it is an order of magnitude where the value actually crosses.
- **The combinatorics are an asset, not a cost.** A typed entry must exist per
  distinct ABI signature because arm64 forbids variadic `objc_msgSend` (each call
  casts it to a concrete `@convention(c)` pointer). Measured across the golden
  subset: **160 distinct ABI shapes / 213 IR-level signatures** over 814 call
  sites, with a long tail of ~90 shapes used exactly once; the full surface is
  larger and *open-ended*. Hand-writing that table (today's `MessageSend.swift`
  has ~18 entries and is unused) would be unbounded maintenance — **but we don't
  hand-write it. The API analysis already enumerates every signature, so the
  emitter generates exactly the entries needed and regenerates them when the
  surface changes.** The cost that motivates a generic dispatcher (unknown
  signatures at runtime) does not exist for us.
- **It is the literal embodiment of ADR-0010 + the codegen economics**: bespoke,
  fully-optimised native code per target, affordable only because it is
  generated.

### 2.2 Why not the others

- **`tell` / typed `get-ffi-obj` (status quo):** keep dispatch *and* marshalling
  interpreted on the Racket side — the opposite of the objective, and 2–8× slower.
  `tell` is retained only as the correctness oracle and a fallback the migration
  deletes.
- **NSInvocation:** ~7× slower than even `tell`. Dead on arrival.
- **libffi:** the obvious *generic* native dispatcher (one function for all
  shapes) and the right choice *if* signatures were unknown — but they are not.
  Measured, it is **not even a win**: it is *slower* than the status-quo typed
  `get-ffi-obj` msgSend on scalar/pointer/float (19–27 vs 10–12 ns), beating it
  only on struct returns, and it is ~3–4× slower than generating. It interprets
  an `ffi_cif`/`ffi_type` description every call. Recorded as the rejected
  alternative; **retained solely as the escape hatch** for any signature the
  emitter cannot type statically (§6).

### 2.3 Decision

**Generate one typed native dispatch entry per distinct method signature, from
the IR.** The emitter emits, per class/method, a thin Racket ffi2 binding that
calls the corresponding generated native entry. This is recorded as **ADR-0013**.

---

## 3. How thin can the seam get — the marshalling-depth spectrum

Dispatch is necessary but not sufficient for "the target never sees the
boundary." A method like `-stringByAppendingString:` still needs `String →
NSString` in, `NSString → String` out, and `+0/+1` lifetime handling. *Where*
that happens is a spectrum:

- **Depth 0 — dispatch only (opaque).** The generated native entry takes/returns
  opaque pointers + scalars; Racket still converts strings/arrays and tags `_id`.
  The seam is thin for dispatch but Racket still "sees" ObjC for marshalling.
- **Depth 1 — typed marshalling per method (recommended target).** The generated
  native entry takes/returns *Racket-friendly* representations and does the ObjC
  marshalling natively: a method taking a string takes a UTF-8 `char*`; one
  returning a string returns a freshly-allocated `char*` (or writes a Racket
  string via the CS C-API); geometry structs cross as flat scalars / `struct_t`.
  The Racket wrapper becomes a single ffi2 call with **no coercion code**.
- **Depth 2 — semantic batching.** Collections cross in one native call
  (`list → NSArray`, `hash → NSDictionary`) instead of N per-element `tell`s;
  `NSError**` out-params resolve natively into `(values result error)`.

**Recommendation:** target **Depth 1 across the generated surface**, with **Depth
2 for the known hot/clunky cases** the runtime already special-cases
(`type-mapping.rkt`'s string/array/dict conversions — today many per-element
`tell`s). Depth 0 is the floor we never settle for; Depth 2 everywhere is not
worth the per-method native complexity where a value crosses once.

This is a *spectrum the emitter walks per method*, not a global switch: the IR's
type information already tells the emitter which marshalling each parameter/result
needs, so the generated native entry is specialised exactly as far as the types
warrant. (Decisions that prove hard-to-reverse here fold into ADR-0013's
consequences; the execution leaf 050 fixes the concrete representation choices —
e.g. returned-string ownership — with code.)

---

## 4. Callbacks, delegates, blocks — embedding direction

The *inbound* path (ObjC calls Racket) is governed by a hard constraint the spike
nailed down (resolving 020's biggest open question).

### 4.1 Findings

- **ffi2 callbacks do not help and cannot be used here.** (a) On a foreign OS
  thread (a fresh `pthread` or a GCD worker) an ffi2 callback **SIGILLs exactly
  like `_cprocedure`** — the callback never fires; ffi2's atomic-mode model does
  *not* make a Racket-unregistered thread safe to enter. (b) ffi2 callbacks with
  a **`void` return are broken upstream** (`ffi2-lib .../core.rkt:986` applies
  `(ffi2-type-c->racket void_t)` which is `#f`), and `void` is the dominant
  delegate/handler shape. Either issue alone disqualifies them.
- **The native trampoline model already solves this correctly.**
  `DelegateBridge.swift` (dynamic class + IMP trampolines + per-instance dispatch
  table) and `BlockBridge.swift` (global-block ABI + copy/dispose refcount) own
  the ObjC side; `main-thread.rkt` bounces foreign-thread work to the main thread
  via `dispatch_async_f` before any Racket code runs; `GCPrevention.swift` pins
  the callback against GC.

### 4.2 Decision

**Stay outbound.** Racket→Swift via the ffi2/C-ABI on opaque pointers. Keep
`_cprocedure` + `function-ptr` callback *creation* in Racket, registered behind
the **native Swift trampolines**, with **foreign-thread safety owned natively**
(bounce to a Racket-safe thread). **Reject** ffi2 callbacks and **reject** the
inbound direction (Swift linking the Racket CS C-embedding API to drive Racket
closures/GC directly) — no evidence it is needed, far larger surface, and it
faces the same foreign-thread activation problem one level down. Recorded as
**ADR-0014**. (The ffi2 void-callback bug is worth reporting upstream; we do not
depend on a fix.)

This is ADR-0010-aligned: the native library owns the hard concern (threading,
lifetimes), and it is the *current* architecture — the spike confirms we keep and
deepen it rather than replace it.

---

## 5. ffi2's actual role and the hybrid boundary

ffi2 has **no Objective-C layer** (020): no equivalent of `tell` / `import-class`
/ `objc_msgSend`. So the boundary is a *forced hybrid*:

- **ffi2** binds the **C-function layer**: framework C exports and CoreFoundation
  functions (`emit_functions.rs`, `emit_constants.rs`), C structs (`struct_t`),
  and the **typed entry points into the generated native dispatch library** (§2).
  Adopt ffi2's richest idioms there: `define-ffi2-definer` + arrow types, tagged
  pointer subtypes for `_id`, `struct_t` with generated accessors, `ffi2-sizeof`
  (confirmed present — closes a 020 gap), allocator/deallocator where a C
  resource needs paired free.
- **`ffi/unsafe` + `ffi/unsafe/objc`** is retained only where genuinely ObjC:
  the `tell`-based fallback during migration, IMP/`class_addMethod` construction
  for the callback trampolines, and any value that must be `_id`-tagged for the
  retained ObjC path.
- **The seam** between them is `ptr_t->cpointer` / `cpointer->ptr_t` (020 §2).
  Under this design most values cross *natively* (the generated entry takes a
  `ptr_t` straight from ffi2), so Racket-level bridging shrinks to where the two
  libraries must coexist in one module.

**Migration constraint (spike finding):** `ffi2` and `ffi/unsafe` both export
`->`. A module mixing them must rename — and the rename must be on
**`ffi/unsafe`'s** side (`(except-in ffi/unsafe ->)`), because
`(rename-in ffi2 [-> ffi2->])` breaks ffi2's *nested* arrow-type parsing
(callback parameter types). Cleanest is to keep the two libraries in separate
modules where possible.

---

## 6. Per-concern disposition

For each surface: **stays Racket (thin)** / **moves native** / **deleted**
(pure-Racket fallback the native lib now covers, per ADR-0010 making the dylib
mandatory).

| surface | disposition | notes |
|---|---|---|
| `emit_class.rs` dispatch (`tell`/`_msg-N`) | **moves native** | generated typed dispatch entries (§2); Racket wrapper = one ffi2 call |
| `emit_functions.rs`, `emit_constants.rs` | **ffi2 (stays Racket, thin)** | C-function layer; `define-ffi2-definer` + arrow types + ffi2 type-mapper |
| `type-mapping.rkt` string/array/dict | **moves native (Depth 2)** | batch `string<->NSString`, `list<->NSArray`, `hash<->NSDictionary` natively; today many per-element `tell`s |
| geometry structs (`_NSPoint` family) | **ffi2 `struct_t`** | flat-scalar / `struct_t` crossing; generated accessors |
| `MessageSend.swift` (`aw_common_msg_*`) | **deleted** | dead code (no callers); superseded by generated dispatch |
| `delegate.rkt` + `DelegateBridge.swift` | **stays (native trampoline)** | §4; delete the pure-Racket `make-delegate/racket` fallback |
| `block.rkt` + `BlockBridge.swift` | **stays (native trampoline)** | §4; delete the pure-Racket block-ABI fallback |
| `main-thread.rkt` | **stays Racket (thin) over native GCD** | foreign-thread bounce; the mechanism that makes §4 safe |
| `objc-base.rkt` retain/release/autorelease | **stays Racket over native** (`swift:*`) | delete the `tell …retain` fallback; dylib mandatory |
| `coerce.rkt`, `objc-interop.rkt` | **shrinks** | the curated `ffi/unsafe/objc` allowlist; narrows as dispatch goes native |
| `swift-helpers.rkt` | **stays (the loader)** | becomes mandatory (no `swift-available? = #f` branch) |

**Hermetic isolation (ADR-0011):** all of the above lands in
`APIAnywareRacket`; racket drops its `APIAnywareCommon` dependency (the Common
pieces it uses are rehomed into `APIAnywareRacket`). Chez de-shares in its own
grove; Common is physically deleted by whichever target de-shares last. (leaf
020.)

---

## 7. Consequences and build sequence

- **The emitter narrows toward thin shims** (ADR-0010): `emit_class.rs` stops
  open-coding `objc_msgSend` and instead emits (a) a generated native dispatch
  entry per signature and (b) a one-line ffi2 Racket binding to it.
- **A new native dispatch generator** consumes the same IR signatures
  `shared_signatures.rs` already dedups, emitting Swift/C typed entries.
- **The dylib becomes mandatory**; every `swift-available?` fallback is deleted.
- **Performance:** dispatch ~2× faster on simple shapes, ~8× on struct returns,
  with marshalling-heavy paths much more (batch vs per-element). Not the GUI-app
  bottleneck *today* — the win is primarily architectural (thin scripting seam)
  with performance as a guaranteed by-product.
- **Build order** (execution leaves):
  020 racket de-shares from Common (delete dead `MessageSend.swift`) ·
  030 ffi2 seam + type-mapper + C-function layer ·
  **040 generated native dispatch library + emitter routing (the §2 core)** ·
  050 emitter thin-shim cutover (marshalling-depth) + full pipeline regen ·
  060 delete pure-Racket fallbacks, make dylib mandatory · then 050 (root leaf)
  VM-verify every sample app.

---

## 8. Open items (carried to execution leaves)

1. **Returned-object lifetime across the native entry** (Depth 1): a generated
   entry returning a `+0` autoreleased `id` vs a `+1` owned `id` must encode
   ownership so the Racket side attaches the right finalizer. The IR's
   `returns_retained` flag feeds this. (050)
2. **Statically un-typable signatures** → libffi fallback path retained as the
   escape hatch (variadics already filtered; confirm none slip through). (040)
3. **`->` coexistence discipline** codified in the emitter (separate modules /
   `except-in ffi/unsafe`). (030)
4. **Report the ffi2 void-callback bug upstream.** (non-blocking)

---

## Appendix — benchmark methodology

Spike at `docs/research/2026-05-31-racket-ffi2-spike/`. `dispatch.m` defines a
controlled `AWSpikeTarget` and the dispatch mechanisms (generated-typed C shims,
libffi generic with cached CIFs, NSInvocation); `bench2.rkt` drives each shape
N=1.5–3M iterations with the status-quo typed `get-ffi-obj` msgSend as the Racket
baseline; `bash run.sh` reproduces the single-shape + callback-thread matrix.
Numbers are steady-state ns/call after a warm GC, host macOS arm64 / Racket v9.2
[cs], two runs averaged. Loops discard results so the optimiser may elide a
little (the struct out-buffer write resists elision); relative ordering is robust
and an earlier checksum-matched variant confirmed correctness. Throwaway spike
code — not shipped; this spec and its ADRs are the durable record.
