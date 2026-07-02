# conformance-data-k123

**Kind:** work

## Goal

Author the note-editor **contracts** — `apps/macos/note-editor/docs/logging-contract.md`
+ `observable-state.md` — from the accepted spec (k122), per the k67/k87/k96/k105/k114
precedents: the structured log format every impl must emit and the AX/OCR-observable
state the suite may assert, doubling as the porting guide.

## Context

- Input: the accepted `apps/macos/note-editor/docs/spec.md` (k122); templates:
  `apps/macos/{hello-window,ui-controls-gallery,pdfkit-viewer,scenekit-viewer,
  mini-browser}/docs/{logging-contract,observable-state}.md`.
- **k122 handoffs to fold in:**
  - Launch-line prefixes diverge (racket/chez/gerbil `Note Editor running. Close
    window or Ctrl+C to exit.` vs sbcl `Note Editor opened. … Quit with Cmd-Q.`) —
    pick the prefix rule (spec §3.8 already states begins-`Note Editor`; the k114
    precedent) or mandate alignment for the instrument child.
  - **The app emits NO per-operation log lines today** — the status label is the sole
    message surface, and preview render completion is entirely unobservable. Document
    ops need a contract event vocabulary (the `[nav]` precedent — e.g. `[doc]` events
    for opened/saved/save-failed/open-failed/new/dirty, carrying path + a dirty flag
    in fixed key order) so the async sheet completion, direct-save (no sheet), and
    failure paths are log-assertable without OCR races; consider a render event at
    `loadHTMLString:` time to make preview re-render countable (spec §7 triggers).
  - Failure `<detail>` diverges (racket exn-message vs path ×3) — a contract-alignment
    candidate (normalize, or contract only the stable `Open failed: `/`Save failed: `
    prefixes as the spec does).
  - The dirty dot is unobservable — the **window AX title is the dirty/name channel**
    (title rule §6.1); the status label asserts AX-exact via the value→AXTitle fold.
  - System-chrome AX shapes need observable-state rows: the warning alert
    (Discard default + Cancel; the k80 alert-shape precedent), the save **sheet**
    (name field prefilled `untitled.md`), the open panel (file cells NOT in the AX
    tree → Cmd-Shift-G drive; the k103 rule).
  - **State-mutating persistence:** the observable-state doc should state the
    writable-dir story (~/Documents precedent) + the cleanup obligation between
    scenarios; saved-file assertions ride `expect-file`/`read-file`.
  - sbcl `build.sh` bundle-id/plist alignment check (the k104/k114 mirror).

## Done when

Both contract docs authored and committed, consistent with the spec's §13/§15 exemplar
and the prior apps' contract shape; open realization questions (launch-line alignment,
`[doc]` event vocabulary, render observability, failure-detail normalization) resolved
or explicitly seeded to `instrument-builds`.
