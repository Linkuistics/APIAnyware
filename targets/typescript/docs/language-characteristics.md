# typescript (Node) — language characteristics (§18)

What about **TypeScript on Node.js** as a host language shapes the binding. Unlike the four
Lisp targets, there is no authored `capability.apiw` for this target yet (see
`overview.md`'s facet table) — the traits below are the prose a capability profile would
rate, without the formal per-dimension rungs.

## The host in one paragraph

TypeScript is **statically, structurally typed** and compiles to JS running on a
**single-threaded event loop** (libuv) with a generational, non-deterministic GC (V8). It
has no macros, no RAII, and no compile-time ownership tracking — but it does have a real
static type checker, so binding concerns another dynamic-language target would leave to
runtime contracts or documented convention are, here, partly **checked at compile time**
through the generated `.d.ts` surface (ADR-0055). This is the axis that makes TypeScript
alien to the four Lisp targets in a way none of them are alien to each other: the type
surface is a first-class deliverable, not a comment.

## Traits that shape the binding

- **Static structural typing, generated.** Every emitted class, method, and constant is
  typed in a generated `.d.ts` sibling; `tsc --noEmit` over the whole corpus is this
  target's standing type-surface guard (the `corpus-typecheck-gate`, see
  `representability.md`). A binding mistake that a dynamic target would only surface at
  runtime is, for the representable surface, a compile error here.
- **No deterministic destructors, but `Symbol.dispose`.** JS has no RAII. TypeScript 5.2's
  `using` declarations + `Symbol.dispose` give a real, deterministic disposal hook, which
  this binding uses as the **primary** lifetime mechanism, backed by a
  `FinalizationRegistry` best-effort safety net for objects a caller forgets to dispose
  (ADR-0057). This is the one Lisp-target-analogue trait TypeScript has that the four Schemes
  do not: an explicit, checked disposal contract rather than GC-only cleanup.
- **Single-threaded event loop, real OS threads underneath.** Node's JS execution is
  single-threaded (the event loop), but `worker_threads`, the libuv threadpool, and GCD
  completion callbacks are real concurrent OS threads — none of which may touch JS directly.
  Every callback into JS from a non-JS-thread context must **bounce** to the loop thread
  (`ffi-model.md`); there is no racket-style "the runtime pumps a bg thread and mutexes
  cooperate" option because V8 is not thread-safe at all.
- **Real ES6 classes, not a namespace of procedures.** Unlike the four Lisp targets (a flat
  module of free procedures keyed by class name), TypeScript gets **actual `class`
  declarations** mirroring the ObjC class graph — `extends`, `instanceof`, and IDE
  autocomplete all work the way a TypeScript programmer expects (ADR-0055). This is a
  genuine idiom win the static type system buys, not available to the dynamically-typed
  targets.
- **npm-native module + native-addon loading.** The runtime ships as an ESM package
  (`@apianyware/runtime`), and the native core loads as a `require()`-able `.node` addon —
  the two ordinary Node.js extension points, not a bespoke loader.

## App-form characteristics

Packaging feasibility (the §36 app-form face, when authored) is currently only
demonstrated, not formally rated: all **seven** GUI sample apps build to self-contained
`.app` bundles via `bundle-typescript` and pass TestAnyware VM verification (ADR-0060).
Headless (`cli-tool`) and background (`menu-bar-daemon`/`launch-agent`) forms are
unexercised — nothing about the distribution model rules them out, but no sample
demonstrates them (see `../bindings/node/docs/api-coverage.md`).

## See also

- [`ffi-model.md`](ffi-model.md) — how these traits are realized at the FFI/threading
  boundary.
- [`representability.md`](representability.md) — how binding coverage is measured for this
  target.
- [`../bindings/node/docs/user-guide.md`](../bindings/node/docs/user-guide.md) — the
  user-facing consequences (dispose/`using`, threading, error handling).
