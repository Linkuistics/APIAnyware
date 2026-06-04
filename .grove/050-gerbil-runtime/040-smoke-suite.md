# 040-smoke-suite

**Kind:** work

## Goal

Consolidate the runtime smoke tests written incrementally across 010–030 into a
coherent `runtime/tests/` suite, write the runtime README, and close any open items
deferred from the earlier leaves. This is the node's verification + tidy pass before
it retires.

## Context

Reference: chez `runtime/tests/` + `runtime/README.md`. The smokes prove the runtime
contract in isolation (CLI/gxc smoke); VM-verify of real sample apps is node 070
(hello-window) and 090 (the rest), NOT here.

## Done when

- **`runtime/tests/`** gathers, as runnable gxc smokes: objc round-trip
  (alloc/msg/release), lifetime (will fires → release; pool drains transients),
  **both** dispatch surfaces (`{sel obj}` and `(sel obj)`) resolving to the same
  proc core, a `make-delegate` callback, a `make-objc-block` invocation, and a
  synthesized-subclass framework callback.
- **`runtime/README.md`** documents the module layout, the two dispatch surfaces,
  the fast-path layering (proc core / raw `%msg-…`), the transparent-subclass idiom,
  and the `with-autorelease-pool` rule for loops outside the run loop (ADR-0019
  consequence).
- **Open items closed or escalated:** anything 010–030 inbox-noted as "confirm at
  smoke build" (geometry struct tags, `(declare (inline))` pragma, cross-module
  generic unification) is resolved here, or escalated to node 060/070 with a clear
  note if it genuinely needs the full emitted-framework build.
- Whole suite passes via gxc against the bottled gerbil.

## Notes

If 010–030's smokes already cover everything cleanly, this leaf is light (gather +
README). The value is the single green "runtime works" signal node 060/070 build on.
