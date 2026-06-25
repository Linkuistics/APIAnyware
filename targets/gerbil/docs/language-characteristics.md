# gerbil — language characteristics (§18)

What about **Gerbil Scheme** as a host language shapes the binding — the traits the capability
profile rates and the idiom catalogue works around. The per-dimension rungs are authored in
[`../capability.apiw`](../capability.apiw) (REFACTOR §20); this page is the prose behind them.

## The host in one paragraph

Gerbil is a **garbage-collected, dynamically-typed** Scheme on a vendored **Gambit** compiler
(gxc → Gambit → C → native), with a typed C FFI (`:std/foreign` `define-c-lambda`) and a rich
object system — `defclass`, the built-in `{}` MOP, and `:std/generic` generic functions. It has
no static type system, no RAII, and no ownership types, so every binding concern another language
would encode in types is, in gerbil, either a **runtime mechanism** (Gambit wills, native
callback trampolines, struct marshalling) or a **documented convention** (deterministic cleanup,
borrowing, thread affinity). That split is what the capability ladder records. Gerbil's profile
sits **with chez** on most rungs — exact runtime marshalling and finalization — but **with racket**
on the one rung that distinguishes the two: where chez *activates* a foreign OS thread and runs
real Scheme on it, gerbil **bounces** foreign-thread callbacks to the main thread
(`foreign-thread-callbacks = idiomatic-conventional`, ADR-0022). That is the inverse of chez's
headline strength, and it is the single dimension where gerbil floors a notch lower.

## Traits that shape the binding

- **A manifest class graph, not a flat veneer.** Gerbil is the **one** target that reifies the
  ObjC hierarchy as real Gerbil `defclass`es — `NSButton : NSControl : NSView : NSResponder :
  NSObject`, including intermediate classes it binds no methods of (ADR-0020). The runtime owns the
  root `(defclass NSObject (ptr) …)` (the `ptr` slot + the lifetime will); each class is defined
  once by its owning framework module, cross-framework ancestry being a cross-module import. A
  returned `id` is `wrap`ped to its **exact bound type** (`object_getClass` → the
  `register-objc-class!` registry, walking the ObjC superclass chain to the nearest bound ancestor
  for unbound dynamic classes like `__NSCFString`). Ownership is modelled conventionally over that
  graph (`ownership = idiomatic-conventional`); there is still no static ownership type.
- **GC with a will, not a guardian.** Lifetime is a Gambit **will** per wrapper (ADR-0019,
  `finalization = exact-runtime`): `wrap` registers a will that sends one `objc_release` when the
  wrapper is collected — and unlike chez's guardian (drained at every pool boundary) Gambit wills
  **self-execute at GC**, with the box-finalizer freed off the finalizer thread. Deterministic
  release is the *convention* layered on top (`deterministic-cleanup = idiomatic-conventional`) — a
  `with-NAME` / `unwind-protect` bracket — with the will as the backstop, never an RAII guarantee.
  The **entry-point autoreleasepool** (`with-autorelease-pool` / `define-entry-point`) owns transient
  `+0` returns; loops outside the run loop's wrapping must `with-autorelease-pool` themselves.
- **Dynamic typing.** No static typestate, ownership, borrowing, or lifetime tracking
  (`typestate`/`borrowing`/`lifetime-tracking = lossy-but-documented`): state preconditions and
  borrowed/interior values are documented conventions, not compile-time checks.
- **Closures as callbacks.** A Gerbil procedure becomes an ObjC callback via the native-core C
  trampolines (`make-delegate` / `make-objc-block`, `callback-support = exact-runtime`). Escaping
  closures are **registry-rooted** for their subscription lifetime (`escaping-callbacks` /
  `callback-rooting = exact-runtime`) — the IMP-closure registry keyed by `(class-address .
  selector)`, block closures by integer id (`runtime/objc.ss` over `runtime/native-core.ss`). The
  caller must keep a delegate reachable (`setDelegate:` does not retain — ADR-0019).
- **Concurrency by main-thread *bounce* — the signature divergence from chez.** Gerbil does **not**
  thread-activate. Foreign-thread callbacks and "main-thread-only" calls **bounce** to the main
  thread (ADR-0022) — `foreign-thread-callbacks` / `thread-affinity = idiomatic-conventional`, a
  rung **below** chez's `exact-runtime` activation and **level with racket**. Main-thread dispatch
  itself is an exact mechanism (`main-thread-dispatch = exact-runtime`: `dispatch_sync`
  value-returning / `dispatch_async` void); run-loop / event integration rides conventional
  main-thread-bounced handlers (`async-event-integration = idiomatic-conventional`).
- **Exact value marshalling.** `define-c-lambda` open-codes C struct-by-value (`NSRect`, `NSPoint`,
  …) **at compile time** through Gambit (`struct-by-value = exact-runtime`; arm64: ≤16 bytes in
  registers, larger via the x8 hidden pointer); NSString↔string and NSArray↔list/vector convert
  exactly (`strings`/`arrays = exact-runtime`) — though string conversion is **invoked explicitly**
  (`string->nsstring` / `nsstring->string`), not implicit at the boundary. `NSError**`/`NSException`
  surface as `(values result error)` / `:std/error` objects (`platform-errors = exact-runtime`,
  ADR-0006). Raw buffer / interior-pointer access is foreign-pointer-by-convention
  (`buffers = idiomatic-conventional`, the two-call sizing pattern).

## App-form characteristics

The second capability face (`app-form { … }` in `capability.apiw`, REFACTOR §36) rates packaging
feasibility, not per-API representability: gerbil compiles to a **single self-contained static
executable** (`packaging = exact-static` — no separate runtime to bundle, ADR-0021), wrapped into a
VM-verified `.app` (`app-bundle = exact-runtime`, via vendored libs + `install_name_tool`
relocation), while loadable-bundle hosting (`plugin`), the App Sandbox (`sandboxing`), and
runtime-embedding-into-a-host (`native-runtime-embedding`) remain `research` — the runtime is a
static executable, not a hostable dylib. These feed the §37 per-app-kind support call in
[`../conformance/macos.apiw`](../conformance/macos.apiw), surfaced by
[`../bindings/macos/docs/api-coverage.md`](../bindings/macos/docs/api-coverage.md).

## See also

- [`ffi-model.md`](ffi-model.md) — how these traits are realized at the FFI boundary.
- [`representability.md`](representability.md) — how the per-dimension rungs floor a per-API status.
- [`reference.md`](reference.md) — the manifest object model, dual-surface dispatch, and the
  lifetime will in full.
