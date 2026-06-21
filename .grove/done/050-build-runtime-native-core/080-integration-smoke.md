# 080-integration-smoke

**Kind:** work

## Goal

The **node done-bar**: prove the whole 050 stack composes against a **real framework**,
end-to-end, with the emitted bindings from 040 loaded on top of the runtime from
020–070. Not unit smokes (each leaf has its own) — the *integration* gate the node
BRIEF's "Done when" names: instantiate, dispatch, subclass, callback + a
background-release smoke + the §6d trampoline residual resolving.

- **Generate + load:** run `generate --target sbcl` for a real framework slice
  (Foundation + an AppKit slice, mirroring the 040 goldens — testkit + foundation),
  load the emitted CLOS tree on the 020–070 runtime in SBCL. The package model, the
  per-file `(in-package …)`/`(export …)` headers (040/060), and the runtime all compose.
- **The four MOP operations end-to-end** (against the real framework, not fixtures):
  - **Instantiate** — `make-instance` → alloc/init a real class; an explicit-init
    class via the `register-objc-init` mapping.
  - **Dispatch** — send a chain of real selectors via the emitted generics, including
    `call-next-method` up the reified chain + a class method.
  - **Subclass** — `define-objc-subclass` a real class, `define-objc-method` override,
    instantiate, trigger the override from the framework (delegate/target).
  - **Callback** — a block-taking API from a **foreign** thread bounces to main + runs
    the Lisp closure (the 060 regression gate, in an integration setting).
- **Background-release smoke** (ADR-0036, a node done-bar item): the 050 lifetime smoke
  in the integrated runtime — finalizers enqueue off-main, the main drain `release`s, no
  leak, no off-main `release`.
- **§6d trampoline residual resolves — Swift-only API access is a FIRST-CLASS gate**
  (a node done-bar item; user re-emphasised 2026-06-20 — accessing *all* Swift-only APIs
  is a major outcome, equal to the ObjC/MOP work, mirroring the scheme targets + the api
  extractor): the `aw_sbcl_*` residual (040's `run_sbcl_trampolines` → 010's dylib) —
  every binding the slice references resolves against `libAPIAnywareSbcl`; the
  **51 fn + 7 const + 576 init + 554 method** invariant is the emitter's (040). Verify
  the *runtime* side **by shape**, not just one representative: a Swift-native
  **function**, a **constant**, a **method** on a class owner (045), an **init** on a
  class owner (045), a **value-struct-owner** method/init (090), a **value/opaque return**
  through `AwSbclValueBox`, a **`throws`** through `ThrowsBridge`→`ns:cocoa-error` (050),
  and an **async/callback** through `AsyncBridge`/`CallbackBounce` (060) — at least one of
  EACH shape present in the slice links + calls through. (090 must be retired for the
  value-struct shape to pass; if 090 is still open when 080 runs, record that shape as
  pending — do not silently skip it.)
- **Capture the recipe** — a repeatable `sbcl --load`/`swift build` smoke script under
  `generation/targets/sbcl/lib/runtime/tests/` (peer the gerbil runtime `tests/`), so
  060-sample-apps + 070-distribution inherit a green baseline.

## Context

Node BRIEF ("Done when (node)" — this leaf is the gate). Design spec §5 (build
pipeline + artifact map — `generate → swift build → load in SBCL`) + §6 (contract
conformance table: this exercises §3.1–§3.8). All of 010–070. Reference: the gerbil
runtime `tests/` + `generation/targets/gerbil/test-results/swift-native-probe` (the
analogous integration probe that proved gerbil's trampoline residual). The 040 goldens
(`emit-sbcl/tests/`) name the framework slices to use.

## Done when

- `generate --target sbcl` + `swift build` + `sbcl --load` compose with **no errors**;
  the emitted tree loads on the runtime.
- The four MOP operations (instantiate / dispatch / subclass / callback) **all pass**
  against a real framework, captured in a repeatable smoke script.
- The background-release smoke passes; the §6d residual links + a Swift-only entry of
  **each shape** (function / constant / class-owner method / class-owner init /
  value-struct-owner method-or-init / value-opaque return / `throws` / async-callback)
  links + calls through (any shape absent from the chosen slice or blocked on an open
  leaf is recorded as pending, never silently skipped).
- The smoke script is committed under the runtime `tests/` dir + documented (a runtime
  README, peer gerbil's) so 060/070 inherit it.

## Notes

- This is **CLI/`--load` smoke, NOT the VM-verify bar** — that bar belongs to
  060-sample-apps (`feedback-vm-verify-every-app`: CLI smoke never satisfies a sample
  app's done-bar). 080 proves the *runtime* composes; the *apps* prove the *product*.
- If a MOP operation fails here, it's a defect in the **owning** leaf (010–070) — fix it
  there + re-retire if needed, don't patch around it in the smoke.
- Retiring 080 empties the 050 node → triggers the node-retirement cascade (promote
  anything durable from the node BRIEF up to the grove BRIEF / a runtime README / the
  design spec, then `leaf-retire` + ask before retiring the node).
