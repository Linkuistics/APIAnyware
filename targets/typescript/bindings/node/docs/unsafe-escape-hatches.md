# typescript (Node) macOS binding — unsafe escape hatches (§22)

When the binding does not model an API, the runtime lets you drop below the generated class surface
to the raw dispatch seam. This is the documented, supported way out — but it is **unsafe**: you take
on the retain/release, threading, and value-crossing obligations the generated call sites otherwise
handle for you. Unlike racket's `_cpointer` accessor or sbcl's `aw-alien` cast over `objc_msgSend`,
this target's hatch is **narrower by construction**: there is no generic re-cast of `objc_msgSend`
to an arbitrary signature (N-API's per-symbol entries are fixed at generation time, ADR-0054), so
"drop to raw FFI" here means "drop to the raw handle/dispatch-entry primitives `@apianyware/runtime`
itself already uses" — all exported from its public barrel, all double-underscore-prefixed by
convention to signal "seam, not application code."

## The hatches, least to most drastic

1. **The raw native handle of a wrapped object — `__unwrap(obj)`.** Every wrapper's underlying ObjC
   `id` is a `bigint`, retrievable via the same `__unwrap` the generated call sites use internally.
   Throws `ObjectDisposedError` if the wrapper has already been disposed, so you cannot silently read
   a dangling handle. You are now responsible for the ObjC retain/release discipline on that raw
   value if you pass it to your own dispatch call (below) — the wrapper's own dispose still releases
   its one +1 regardless of what you did with the handle meanwhile.

2. **A raw per-signature dispatch call — `__dispatch.aw_ts_msg_<code>(recv, sel, …)`.** For a
   selector with no generated method (a class the emitter didn't bind a particular selector on), you
   can call the addon's own generated dispatch entry directly if you know its content-addressed name
   — the same `NativeEntry` shape (`(...args: any[]) => any`) every emitted class body already calls.
   This is a **narrower** hatch than a generic ObjC-FFI escape: the entry set is fixed at generation
   time from the corpus, so it only reaches signatures the emitter already saw somewhere, and the
   `Generated/*.swift` tables that name them are gitignored build output, not a stable, documented
   API — treat this as a last resort, not a routine tool. Build the `SEL`/`Class` arguments with
   `__sel`/`__class`/`__classArg` (below); an object argument still needs `__unwrap`.

3. **Raw `SEL`/`Class` value primitives — `__sel`/`__selName`, `__class`/`__classArg`/`__classCtor`.**
   Neither a `SEL` nor a `Class` is ever wrapped/retained/disposed (ADR-0057 §4 — retaining a class
   leaks, retaining a selector is UB); these are the same interning/lookup primitives the generated
   surface uses to cross them. Useful alongside hatch 2, or to probe a class/selector's existence
   without a generated call site (`__class('SomePrivateClass')`, then check it's non-zero).

4. **A constant global whose symbol resolves but whose shape the binding gets wrong.** The array-
   typed-global case (`extern const unsigned char X[]`) reads safely (no crash) but not honestly —
   the emitted value is not yet the symbol's real bytes (`../../../docs/representability.md`). There is
   no better hatch for this today; if you need one of these constants correctly, that's a coverage
   gap worth filing rather than working around.

## What you give up

Dropping to a hatch bypasses the generated call site's typed marshalling, the wrap-boundary's
uniquing/retain-fold accounting, and (for anything beyond a plain data call) the callback/delegate
machinery's keep-alive and exception containment. In particular:

- A raw dispatch call you make yourself follows **none** of the ownership rules a generated call
  site's `__wrapRetained`/`__wrapOwned`/`__wrapBorrowed` choice encodes — if the entry returns an
  object `id`, decide its retain convention yourself (the CF Create Rule: a `copy`/`new`/`alloc`-
  family selector hands you a +1 you must eventually balance; anything else is +0 and must not be
  retained again) before wrapping it, if you wrap it at all.
- **There is no reflective NSInvocation-style fallback** the way sbcl's `SubclassSynth` or gerbil's
  generic trampoline offer — an ABI signature outside the generated entry set (hatch 2) is simply
  unreachable from JS without writing native code of your own.
- A `SEL`/`Class` value crossing raw dispatch entries is your own responsibility to get right — the
  ABI collapses `id`/`SEL`/`Class`/block/raw-pointer to one pointer code, so nothing native-side
  stops you from handing a `Class` handle where an object was expected.

## What is genuinely unbindable — no hatch reaches these

- **Generic free functions and Swift operator declarations.** No TS identifier exists for an
  operator, and a sanitised name for either would collide across the corpus (ADR-0061 §3). These are
  recorded with a reason and counted by the trampoline pass, not silently dropped — but there is no
  workaround from JS; the underlying Swift symbol has no stable, callable C-ABI form to reach.
- **26 free-function symbols that resolve nowhere even once their owning framework is loaded** (24
  Ruby header-only/deprecated declarations, 2 DirectoryService) — calling the generated wrapper
  throws a JS `Error` naming the symbol and framework, rather than crashing on a null-address call.
  Nothing to escape-hatch to; the symbol genuinely isn't there on this platform.

## When you shouldn't need a hatch

If the API is Swift-native (`async`/`throws`/a value return) rather than genuinely unmodeled ObjC,
the binding already models it — through the generated by-name residual trampoline or the `Result<T>`
channel, not a raw hatch ([`../../../docs/ffi-model.md`](../../../docs/ffi-model.md)). And to receive
framework callbacks, prefer the generated **subclass**/**delegate** machinery over any hand-rolled
native code — it is the supported, thread-bounced, exception-contained path (see
[`user-guide.md`](user-guide.md)). Reach for a hatch only for genuinely unmodeled ObjC surface; if
you find yourself needing one for a common API, that is a coverage gap worth filing (see
[`api-coverage.md`](api-coverage.md)).
