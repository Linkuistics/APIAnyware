# racket — language characteristics (§18)

What about **Racket CS 9.2** as a host language shapes the binding — the traits the capability
profile rates and the idiom catalogue works around. The per-dimension rungs are authored in
[`../capability.apiw`](../capability.apiw) (REFACTOR §20); this page is the prose behind them.

## The host in one paragraph

Racket CS is a **garbage-collected, dynamically-typed** Lisp compiled on the Chez backend. It has
no static type system, no RAII, and no ownership types — so every binding concern that another
language would encode in types is, in racket, either a **runtime mechanism** (finalization,
callbacks, struct marshalling) or a **documented convention** (deterministic cleanup, borrowing,
thread affinity). That split is exactly what the capability ladder records, and why racket's
profile clusters at `exact-runtime` (mechanisms it does exactly) and `idiomatic-conventional`
(things it upholds by convention, not by guarantee).

## Traits that shape the binding

- **GC with exact finalization.** `register-finalizer` gives O(dead) GC-death finalization
  (capability `finalization = exact-runtime`). Wrapped ObjC `id`s are released by a will-executor
  at collection; deterministic release is the *convention* layered on top
  (`deterministic-cleanup = idiomatic-conventional`) — a `with-NAME`/`dynamic-wind` bracket or a
  `close-NAME!` procedure, with GC as the backstop, never an RAII guarantee.
- **Dynamic typing.** No static typestate, ownership, borrowing, or lifetime tracking
  (`typestate`/`borrowing`/`lifetime-tracking = lossy-but-documented`): state preconditions are
  runtime contracts (`raise-argument-error`) and documented conventions, not compile-time
  checks. The single `objc-object` record wraps every `id` — generated class files are namespaces
  of procedures keyed by class, not a record hierarchy mirroring the ObjC graph (see CONTEXT.md
  *`objc-object`*).
- **Closures as callbacks.** A Racket procedure becomes an ObjC callback via the
  `DelegateBridge`/`BlockBridge` native bridges (`callback-support = exact-runtime`). Escaping
  closures are **GC-rooted** in the callback registry for their subscription lifetime
  (`escaping-callbacks`/`callback-rooting = exact-runtime`) so the GC keeps them live while ObjC
  may still invoke them.
- **Concurrency by main-thread bounce.** Racket *places* run real concurrent threads, but Cocoa's
  thread rules are upheld by **convention** plus one runtime mechanism: foreign-thread and
  main-thread-only calls **bounce to the main thread** through the trampoline (ADR-0014) —
  `foreign-thread-callbacks`/`thread-affinity = idiomatic-conventional`,
  `main-thread-dispatch = exact-runtime`. This is racket's signature divergence from chez (which
  *activates* the foreign thread) — see CONTEXT.md *Native trampoline* / *Foreign-thread
  activation*.
- **Exact value marshalling.** ffi2 / `ffi/unsafe` pass C structs (`NSRect`, `NSPoint`, …) by
  value exactly (`struct-by-value = exact-runtime`); NSString↔string and NSArray↔sequence convert
  exactly (`strings`/`arrays = exact-runtime`); `NSError**`/`NSException` surface as Racket
  exceptions (`platform-errors = exact-runtime`). Raw buffer / interior-pointer access is
  unsafe-FFI-by-convention (`buffers = idiomatic-conventional`, the two-call sizing pattern).

## App-form characteristics

The second capability face (`app-form { … }` in `capability.apiw`, REFACTOR §36) rates packaging
feasibility, not per-API representability: `raco distribute` self-contains the Racket CS runtime
(`packaging`/`app-bundle = exact-runtime`, VM-verified), while loadable-bundle hosting and the App
Sandbox remain `research`. These feed the §37 per-app-kind support call in
[`../conformance/macos.apiw`](../conformance/macos.apiw), surfaced by
[`../bindings/macos/docs/api-coverage.md`](../bindings/macos/docs/api-coverage.md).

## See also

- [`ffi-model.md`](ffi-model.md) — how these traits are realized at the FFI boundary.
- [`representability.md`](representability.md) — how the per-dimension rungs floor a per-API status.
- [`developer-guide.md`](developer-guide.md) — the user-facing consequences (threading, coercion).
