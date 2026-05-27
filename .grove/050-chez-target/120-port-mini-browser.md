# 120-port-mini-browser

**Kind:** work

## Goal
Port `mini-browser` to chez. First app with an **async multi-callback
delegate** (`WKNavigationDelegate`: `didStart`, `didFinish`,
`didFailNavigation`). Validates delegate-callback re-entry into Scheme
under the autoreleasepool entry-point wrap.

## Context
- `generation/targets/racket/apps/mini-browser/mini-browser.rkt`.
- `runtime/dispatch.sls`'s `make-delegate` — async invocation surface.
- `runtime/objc.sls`'s `define-entry-point` — the wrap convention each
  callback uses.
- ADR-0007 (lifetime model — callbacks are entry points).

## Done when
- `mini-browser.sls` exists, bundles, launches, navigates to a URL,
  exercises both success (didFinish) and failure (didFailNavigation)
  paths. TestAnyware run green.
- A reload loop (load → reload → reload) shows no unbounded growth in
  Activity Monitor — confirms the guardian + autoreleasepool combination
  drains correctly across callbacks.

## Notes
- If a callback fires from a non-main thread, document the convention
  in `knowledge/targets/chez.md` (leaf 150).
