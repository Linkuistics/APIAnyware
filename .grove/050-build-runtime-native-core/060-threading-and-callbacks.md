# 060-threading-and-callbacks

**Kind:** work

## Goal

Wire the **foreign-thread callback model** (ADR-0035) — the Lisp side of the
main-thread bounce. The spine: a foreign thread must **never** run Lisp (the spike
crashed **5/5**, `ENOTSUP` in `GC-STOP-THE-WORLD` — SBCL cannot stop-the-world-suspend
*foreign* threads on macOS arm64). chez's `Sactivate_thread` activation (ADR-0016) is
**rejected** — this leaf wires the bounce the spike proved instead.

- **`aw-block`** (Lisp closure → C block SAP) — the node BRIEF DISPATCH-BODY helper.
  Wraps a Lisp closure as an ObjC block; `nil` → the null block. The block's invocation
  **bounces to main** via 010's `CallbackBounce` before re-entering Lisp.
- **The main-thread bounce wiring** (to 010's `CallbackBounce.swift`): `dispatch_sync`
  for value-returning callbacks (block must return a value), `dispatch_async` for void.
  Both deliver onto the main thread, then call the registered Lisp closure / IMP. The
  IMP path is shared with 040's subclass dispatch table — 060 makes the *foreign-thread*
  entry safe (040 exercised only the main-thread path).
- **`AsyncBridge` wiring** (to 010's `AsyncBridge.swift`): async-method completion
  delivered **on main** (ADR-0035) — the Lisp continuation runs main-side.
- **The `sb-thread` native-worker boundary** — the *richer-than-gerbil* point:
  SBCL-native `sb-thread` workers **do** run concurrent Lisp safely (the spike control
  survived). So sample-app background compute uses `sb-thread`; the bounce scopes to
  *foreign* entry only. Provide / document the safe-worker pattern (a thin
  `with-background-work` or just the rule + a smoke) so 060-sample-apps knows the
  boundary: **never** call back into Lisp from a foreign thread without the bounce;
  **do** use `sb-thread` for pure-Lisp compute.

## Context

Node BRIEF (`aw-block` in DISPATCH BODY). Design spec §3 (threading/callbacks) +
ADR-0035 (the bounce, the 5/5 crash evidence). The bounce **mechanism** is 010's
`CallbackBounce.swift` + `AsyncBridge.swift` — 060 is the Lisp wiring + the
`sb-thread` boundary. Spike: `2026-06-20-sbcl-threading-spike/` (spike.lisp/spike.c/
run.sh — the crash + the surviving `sb-thread` control). Reference:
`generation/targets/gerbil/lib/runtime/async-bridge.ss` + the `make-objc-block` token
marshalling in `objc.ss`. Needs 010 (the bounce dylib) + 040 (the IMP dispatch table
the foreign path feeds).

## Done when

- A block-taking API (e.g. `enumerateObjectsUsingBlock:` or a GCD-dispatched callback)
  invoked from a **foreign** thread bounces to main + runs the Lisp closure **without
  crashing** (the exact scenario that crashed 5/5 pre-bounce — this is the regression
  gate).
- A value-returning block returns its value across the `dispatch_sync` bounce; a void
  block via `dispatch_async` runs.
- An async method's completion runs the Lisp continuation on the main thread.
- An `sb-thread` worker does pure-Lisp compute concurrently without crashing (the
  control path stays green) — and the rule "no foreign-thread Lisp re-entry without the
  bounce" is documented for 060-sample-apps.

## Notes

- This is the **highest-risk** runtime leaf (it's literally the thing that crashed in
  the spike). Verify the foreign-thread path empirically, not by inspection.
- Do not conflate the two thread kinds: *foreign* (ObjC/GCD) → must bounce; *native*
  (`sb-thread`) → safe. The whole ADR-0035 nuance is that distinction.
