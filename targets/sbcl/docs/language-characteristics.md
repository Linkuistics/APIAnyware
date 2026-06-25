# sbcl — language characteristics (§18)

What about **Common Lisp on SBCL** as a host language shapes the binding — the traits the capability
profile rates and the idiom catalogue works around. The per-dimension rungs are authored in
[`../capability.apiw`](../capability.apiw) (REFACTOR §20); this page is the prose behind them.

## The host in one paragraph

SBCL is a **garbage-collected, dynamically-typed** Common Lisp with a native compiler, a
**genuinely multi-threaded** runtime (`sb-thread`, real preemptive OS threads), a compiler-integrated
C FFI (`sb-alien`), and a full **CLOS / metaobject protocol** (`sb-mop`). It has no static type
system, no RAII, and no ownership types, so every binding concern another language would encode in
types is, in SBCL, either a **runtime mechanism** (`sb-ext:finalize`, native callback trampolines,
struct marshalling) or a **documented convention** (deterministic cleanup, borrowing, thread
affinity). That split is what the capability ladder records. SBCL's profile sits **with chez and
gerbil** on most rungs — exact runtime marshalling and finalization — but **with racket and gerbil**
on the one rung that distinguishes the targets: where chez *activates* a foreign OS thread and runs
real Scheme on it, SBCL **bounces** foreign-thread callbacks to the main thread
(`foreign-thread-callbacks = idiomatic-conventional`, ADR-0035), because a foreign thread running
Lisp under GC is catastrophic (spiked first-hand: 5/5 crash in `GC-STOP-THE-WORLD`). That is the
inverse of chez's headline strength. But SBCL has a strength the Schemes lack: its **native**
`sb-thread` workers run real concurrent Lisp safely, so background *compute* is genuinely parallel.

## Traits that shape the binding

- **A MOP class graph, not a flat veneer — and not a manifest `defclass` graph either.** SBCL is the
  target that projects the ObjC class system into CLOS *through the metaobject protocol* (ADR-0034):
  an `objc-class` metaclass (a `standard-class` subclass) backs every bound ObjC class; the
  runtime-owned root `ns:ns-object` carries the foreign `ptr` (the `id`); the full ancestor chain is
  reified, with ObjC ivars as foreign slots via `slot-value-using-class`. This goes **further** than
  gerbil's manifest `defclass` graph and rejects racket/chez's flat free-procedures-over-one-opaque
  object. A returned `id` is `aw-wrap`ped to its **exact bound type** through the MOP class registry
  (the gerbil ADR-0029 analogue). Ownership is modelled conventionally over that graph
  (`ownership = idiomatic-conventional`); there is still no static ownership type.
- **GC with finalize + a main-thread release queue, not a guardian.** Lifetime is `sb-ext:finalize`
  (ADR-0036, `finalization = exact-runtime`): exact GC-death finalization, O(dead) like a guardian.
  The SBCL twist: finalizers run on a dedicated **off-main** finalizer thread, and an off-main
  `dealloc` of an AppKit object is UB — so a finalizer captures only the raw `id` and **enqueues**
  it, and a **main-thread drain** at the entry-point pool boundary sends `release`. Deterministic
  release is the *convention* layered on top (`deterministic-cleanup = idiomatic-conventional`) — an
  `unwind-protect` / `with-*` bracket — with the finalizer as the backstop, never an RAII guarantee.
  The **entry-point autoreleasepool** (`with-autorelease-pool` / `define-entry-point`) owns transient
  `+0` returns; loops outside the run loop's wrapping must `with-autorelease-pool` themselves.
- **Dynamic typing.** No static typestate, ownership, borrowing, or lifetime tracking
  (`typestate`/`borrowing`/`lifetime-tracking = lossy-but-documented`): state preconditions and
  borrowed/interior values are documented conventions, not compile-time checks.
- **Closures as callbacks.** A Lisp closure becomes an ObjC callback via `sb-alien` callbacks + the
  `libAPIAnywareSbcl` native trampolines (`callback-support = exact-runtime`): one universal ObjC
  block (`BlockBridge`), delegate/subclass IMPs (`SubclassSynth`). Escaping closures are
  **registry-rooted** for their subscription lifetime (`escaping-callbacks` /
  `callback-rooting = exact-runtime`) — `*subclass-instances*` is a **strong** hash table, so a
  synthesized controller owning observers/target-actions is pinned for the process (the structural
  reason the gerbil weak-delegate GC bug cannot recur on sbcl).
- **Concurrency by main-thread *bounce* — but with safe native background compute.** SBCL does **not**
  let foreign threads run Lisp. Foreign-thread callbacks and "main-thread-only" calls **bounce** to
  the main thread (ADR-0035) — `foreign-thread-callbacks` / `thread-affinity =
  idiomatic-conventional`, a rung **below** chez's `exact-runtime` activation and **level with
  racket/gerbil**. Main-thread dispatch itself is an exact mechanism (`main-thread-dispatch =
  exact-runtime`: `dispatch_sync` value-returning / `dispatch_async` void in `libAPIAnywareSbcl`);
  run-loop / event integration rides conventional main-thread-bounced handlers
  (`async-event-integration = idiomatic-conventional`). The divergence from gerbil/racket: **native
  `sb-thread` workers run real concurrent Lisp safely** (`with-background-work`), so pure-Lisp compute
  parallelises — only the hand-*off* to ObjC/UI bounces to main.
- **Exact value marshalling.** `sb-alien` open-codes C struct-by-value (`NSRect`, `NSPoint`, …) at
  compile time, projected to a CLOS **value-struct** surface (`struct-by-value = exact-runtime`,
  ADR-0042; arm64 HFA returns are directly slot-readable, no accessor helper — a divergence from
  gerbil); NSString↔CL-string and NSArray↔CL-sequence convert exactly
  (`strings`/`arrays = exact-runtime`) — string conversion invoked explicitly (`@"…"` reader /
  `nsstring->string`), not implicit at the boundary. `NSError**`/`NSException` surface as the
  **signalled `ns:objc-error` condition hierarchy** (`platform-errors = exact-runtime`, ADR-0037 —
  the CL-family idiom, diverging from chez/gerbil's `(values result error)`). Raw buffer /
  interior-pointer access is `sb-alien`-pointer-by-convention (`buffers = idiomatic-conventional`,
  the two-call sizing pattern).

## App-form characteristics

The second capability face (`app-form { … }` in `capability.apiw`, REFACTOR §36) rates packaging
feasibility, not per-API representability: sbcl ships as a **dumped SBCL image**
(`save-lisp-and-die :executable t`) — the image **is** the executable — relocated via
`@executable_path/..` and signed around (`packaging = exact-runtime`, ADR-0041; **not** gerbil's
`exact-static` single static executable — the dump cannot be `install_name_tool`'d or re-signed, so
self-containment is closed at runtime), wrapped into a VM-verified `.app` (`app-bundle =
exact-runtime`). Loadable-bundle hosting (`plugin`), the App Sandbox (`sandboxing`), and **embedding
the dumped image into a host process** (`native-runtime-embedding`) all remain `research` — the
dumped image is the executable, and `libAPIAnywareSbcl` is the sole *separate* native unit, so there
is no host-process embedding path yet. These feed the §37 per-app-kind support call in
[`../conformance/macos.apiw`](../conformance/macos.apiw), surfaced by
[`../bindings/macos/docs/api-coverage.md`](../bindings/macos/docs/api-coverage.md).

## See also

- [`ffi-model.md`](ffi-model.md) — how these traits are realized at the FFI boundary.
- [`representability.md`](representability.md) — how the per-dimension rungs floor a per-API status.
- [`reference.md`](reference.md) — the `objc-class` metaclass model, per-selector dispatch, the
  finalize + release-queue lifetime, the condition hierarchy, and the FP-trap landmine in full.
