# chez — language characteristics (§18)

What about **Chez Scheme** as a host language shapes the binding — the traits the capability
profile rates and the idiom catalogue works around. The per-dimension rungs are authored in
[`../capability.apiw`](../capability.apiw) (REFACTOR §20); this page is the prose behind them.

## The host in one paragraph

Chez Scheme is a **garbage-collected, dynamically-typed** Lisp with a mature ahead-of-time native
compiler and a typed C FFI (`foreign-procedure`). It has no static type system, no RAII, and no
ownership types — so every binding concern another language would encode in types is, in chez,
either a **runtime mechanism** (a guardian, foreign-callable trampolines, struct marshalling) or a
**documented convention** (deterministic cleanup, borrowing, thread affinity). That split is what
the capability ladder records. Chez's profile clusters **higher** than racket's: where racket
upholds foreign-thread callbacks by a main-thread *bounce* convention, chez does them with an
*exact runtime mechanism* — it **activates** the foreign OS thread and runs real Scheme on it
(ADR-0016). That single difference is chez's distinguishing strength.

## Traits that shape the binding

- **GC with a guardian.** A single process-wide guardian (`make-guardian`, ADR-0007) gives exact
  GC-death finalization (capability `finalization = exact-runtime`): `wrap-objc-object` registers
  each wrapper, and a drain sends one `objc_release` per wrapper whose Scheme value has been
  collected — converting *Scheme GC events* into *ObjC releases*. Deterministic release is the
  *convention* layered on top (`deterministic-cleanup = idiomatic-conventional`) — a `with-NAME` /
  `dynamic-wind` bracket — with the guardian as the backstop, never an RAII guarantee. A second
  mechanism, the **entry-point autoreleasepool**, owns transient `+0` returns so they never reach
  the guardian (reference §2).
- **Dynamic typing.** No static typestate, ownership, borrowing, or lifetime tracking
  (`typestate`/`borrowing`/`lifetime-tracking = lossy-but-documented`,
  `ownership = idiomatic-conventional`): state preconditions are documented conventions, not
  compile-time checks. The single `objc-object` record wraps every `id` — generated framework
  libraries are namespaces of procedures keyed by class, not a record hierarchy mirroring the ObjC
  graph (CONTEXT.md *`objc-object`*).
- **Closures as callbacks.** A Scheme procedure becomes an ObjC callback via `__collect_safe`
  **foreign-callable** trampolines (`callback-support = exact-runtime`). Escaping closures are
  rooted against GC for their subscription lifetime — chez roots them **Scheme-side via
  `lock-object`** rather than through a native callback registry (`escaping-callbacks` /
  `callback-rooting = exact-runtime`; see the adapter `callback-registry` service, rated `parity`).
- **Concurrency by thread *activation* — the signature divergence.** Chez does **not** main-thread
  bounce for foreign-thread callbacks. It calls `Sactivate_thread`, adopts the calling foreign OS
  thread as a Chez thread, and runs the Scheme handler **on that thread** (ADR-0016) —
  `foreign-thread-callbacks = exact-runtime`, a rung **above** racket/gerbil/sbcl's conventional
  bounce. Main-thread dispatch is still an exact mechanism (`main-thread-dispatch = exact-runtime`)
  but is used **only** for AppKit UI mutation (`thread-affinity = idiomatic-conventional`). One
  rule the activation model imposes: a *blocking outbound* call must itself be `__collect_safe`
  (`async-event-integration = idiomatic-conventional`), or the GC can stall behind it.
- **Exact value marshalling.** `foreign-procedure` open-codes C struct-by-value (`NSRect`,
  `NSPoint`, …) **at compile time** via `define-ftype` (`struct-by-value = exact-runtime`);
  NSString↔string and NSArray↔list/vector convert exactly (`strings`/`arrays = exact-runtime`);
  `NSError**`/`NSException` surface as R6RS conditions / multiple values (`platform-errors =
  exact-runtime`, ADR-0006). Raw buffer / interior-pointer access is foreign-pointer-by-convention
  (`buffers = idiomatic-conventional`, the two-call sizing pattern).

## App-form characteristics

The second capability face (`app-form { … }` in `capability.apiw`, REFACTOR §36) rates packaging
feasibility, not per-API representability: chez ships boot files + the runtime as an **open-world
self-contained distribution** (`packaging`/`app-bundle = exact-runtime`, VM-verified — ADR-0009),
embedding into a host process is conventional (`native-runtime-embedding = idiomatic-conventional`),
while loadable-bundle hosting (`plugin`) and the App Sandbox (`sandboxing`) remain `research`.
These feed the §37 per-app-kind support call in [`../conformance/macos.apiw`](../conformance/macos.apiw),
surfaced by [`../bindings/macos/docs/api-coverage.md`](../bindings/macos/docs/api-coverage.md).

## See also

- [`ffi-model.md`](ffi-model.md) — how these traits are realized at the FFI boundary.
- [`representability.md`](representability.md) — how the per-dimension rungs floor a per-API status.
- [`reference.md`](reference.md) §2 — the guardian + autoreleasepool lifetime model in full.
