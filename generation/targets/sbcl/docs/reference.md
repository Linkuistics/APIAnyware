# sbcl — Target Reference

> Seeded by build leaf `050/060` with the **threading & callbacks** contract the sample
> apps (`060-build-sample-apps`) must follow. The remaining sections (toolchain, FFI,
> object model, lifetime, conditions, distribution, verification) are authored by the
> docs leaf `080-docs`.

## Threading & callbacks — the foreign-vs-native split (ADR-0035)

SBCL is a genuinely multi-threaded runtime (`sb-thread`, real preemptive OS threads),
so — unlike gerbil's single-VM Gambit — the question "can a foreign thread run Lisp?"
was open and had to be **spiked, not assumed**. The threading spike
(`docs/research/2026-06-20-sbcl-threading-spike/`, SBCL 2.6.5 / arm64) settled it:

| Who runs the consing callback | Result |
|---|---|
| 8 **SBCL-native** `sb-thread`s (control) | **SURVIVED** |
| **1** foreign GCD worker | survived |
| **8 concurrent** foreign GCD workers | **CRASHED 5/5** |

The crash is deterministic: a fatal `ENOTSUP` inside `SB-KERNEL::GC-STOP-THE-WORLD` —
SBCL cannot stop-the-world-suspend a thread it merely **attached** for a callback (only
threads it created). So the rule that governs every callback in this target:

> **A foreign OS thread (a GCD worker, a framework completion thread) must NEVER run
> Lisp.** Foreign-thread callbacks **bounce to the main thread** — SBCL-native,
> suspendable, owner of the AppKit run loop — before any Lisp runs.

The bounce is **native** (in `libAPIAnywareSbcl`, ADR-0038): the block body / the
subclass `forwardInvocation:` hops to main via `dispatch_sync` (synchronous, because a
callback **borrows** its framework-owned `id` arguments for the call's extent — an async
hop would run Lisp against freed objects), then calls the registered Lisp dispatcher. On
the main thread already (the UI common case — AppKit delegates fire on main) it calls
straight in: zero hop. The regression gate
(`lib/runtime/tests/smoke-threading-callbacks.lisp`) reproduces the 8-concurrent-worker
storm under GC pressure and now **survives 5/5**.

### What this means for an app author

- **Background COMPUTE → `sb-thread` (`with-background-work`).** This is where sbcl is
  *richer than gerbil*: SBCL-native worker threads **do** run concurrent Lisp safely (the
  spike's control survived). Do pure-Lisp work on them freely.

  ```lisp
  (with-background-work (:name "reindex")
    (let ((result (expensive-pure-lisp-computation)))
      ;; To touch ObjC / the UI with the result, deliver it onto the main thread:
      (aw-on-main (lambda () (update-some-view result)))))
  ```

- **`aw-on-main`** runs a thunk on the main thread and blocks until it finishes — the
  UI-safe hand-off from a worker. (It drains only while the main thread services the run
  loop, i.e. under `[NSApp run]`.)

- **Blocks — `aw-block` is automatic.** A bound method taking an ObjC block argument
  accepts a plain Lisp closure; the emitted binding wraps it with `aw-block`. The closure
  receives the block's arguments at its natural arity (up to 3), as raw values — coerce an
  object arg with `aw-wrap`, read an index with `sb-sys:sap-int`:

  ```lisp
  (ns:enumerate-objects-using-block array
    (lambda (obj idx stop)
      (declare (ignore stop))
      (format t "~D: ~A~%" (sb-sys:sap-int idx) (nsstring->string obj))))
  ```

  A value-returning block's closure must end in a coercible value (a bound instance, an
  integer, a SAP, `t`/`nil`); a `void` block's return is ignored. Pass `nil` for "no
  block". (Bridgeable blocks are the integer-class signatures — pointer / `BOOL` /
  `NSInteger`-family args and result; by-value struct or `c-string` block slots keep their
  method deferred, [`emit-sbcl::is_bridgeable_block`].)

### The one caveat (shared with racket/gerbil)

A **value-returning** callback whose result the main thread is *itself* synchronously
blocked awaiting would deadlock (the bounce is `dispatch_sync`). Void completions are
immune. And long synchronous work on the main thread starves background callbacks, since
the bounce drains only when the run loop turns — let the run loop breathe.

### Async methods

A Swift-native `async` method's completion is delivered **on the main thread** by
`AsyncBridge.swift` (it marshals the payload on the cooperative pool, then hops via
`MainActor.run`), so the Lisp continuation runs main-side, GC-safe — the same guarantee
blocks get. (Async residual trampolines are emitted by a follow-up leaf; the Lisp
continuation seam binds to the bridge there.)
