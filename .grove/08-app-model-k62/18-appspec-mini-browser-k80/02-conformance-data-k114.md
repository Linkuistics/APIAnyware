# conformance-data-k114

**Kind:** work

## Goal

Author the mini-browser **contracts** — `apps/macos/mini-browser/docs/logging-contract.md`
+ `observable-state.md` — from the accepted spec (k113), per the k67/k87/k96/k105
precedents: the structured log format every impl must emit and the AX/OCR-observable
state the suite may assert, doubling as the porting guide.

## Context

- Input: the accepted `apps/macos/mini-browser/docs/spec.md` (k113); templates:
  `apps/macos/{hello-window,ui-controls-gallery,pdfkit-viewer,scenekit-viewer}/docs/
  {logging-contract,observable-state}.md`.
- **k113 handoffs to fold in:**
  - Launch-line prefixes diverge (racket/chez/gerbil `Mini Browser running.` vs sbcl
    `Mini Browser opened.`) — pick the prefix rule (scenekit precedent: prefix-match
    only) or mandate alignment for the instrument child.
  - Navigation completion needs **contract log events** to be assertable without OCR
    timing races: didStart/didFinish/didFail(-provisional) events (the scenekit
    `[scene]`-events precedent — e.g. `[nav]` events carrying phase + URL + canGoBack/
    canGoForward + title), making the async success path log-observable.
  - Loading-text (`...` vs `…`) and failure-phase capitalization (`load/request` vs
    `Load/Request`) are contract-alignment candidates.
  - **The no-network reality:** initial load fails → modal NSAlert at launch; whether
    `loadRequest:` renders `file://` is an open in-VM gap gating the offline success
    path — the observable-state doc should state what the offline surface is, and the
    contract may need a fixture-page story (local HTML) for the instrument child.
  - AX caveats: address-field AX value reads empty (OCR only); ◀/▶ history via the AX
    `enabled` flag.

## Done when

Both contract docs authored and committed, consistent with the spec's §13 exemplar and
the prior apps' contract shape; open realization questions (launch-line alignment,
`[nav]` event vocabulary, fixture story) resolved or explicitly seeded to
`instrument-builds`.
