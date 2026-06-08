# 020-background-callback-smoke

**Kind:** work

## Goal

Verify the ADR-0022 bounce works for real: a genuine background callback
(`dispatch_async` GCD worker) driving a Gerbil delegate/block callback under a
live run loop runs correctly and never corrupts the heap. Gerbil analogue of chez
`tests/smoke-dispatch.sls` test 4.

## Context

Leaf 010 makes off-main entry bounce to main; this leaf proves it. The spike
showed direct concurrent entry crashes 30/30 — this test must show the *bounced*
path survives the same pressure.

## Done when

- A smoke test submits work to the GCD global queue (a real worker thread) that
  invokes a Gerbil callback through the native core, doing real Scheme heap work,
  under a turning run loop (`[NSApp run]` or `dispatch_main` / a run-loop spin).
- Asserts the callback ran with the correct result; loops enough iterations to
  surface any crash/leak/corruption (cf. chez's 500×).
- Confirms (or documents) that the callback body executed **on the main thread**
  (the bounce landed) — e.g. the callback checks `isMainThread`.
- Runs green from the repo (host CLI is fine — threading is not a GUI concern;
  the chez equivalent ran on the host). Wire into the gerbil test runner if one
  exists; otherwise a self-contained `tests/` script + build invocation.

## Notes

Mind the deadlock caveat: keep the test's value-returning bounce off the path
where the main thread synchronously awaits the worker. A void completion that
signals via a C-global flag the main run loop polls is the clean shape.
