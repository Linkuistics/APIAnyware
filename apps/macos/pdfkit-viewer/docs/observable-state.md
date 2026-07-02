# PDFKit Viewer — Observable State

> **Porting guide.** What an implementation of PDFKit Viewer must make *observable* to the AppSpec
> runner's VM-side verbs (OCR, accessibility, process, input). Derived from spec §11 (observable
> outcomes & accessibility) and §13 (behavioural exemplar); templates:
> [../../hello-window/docs/observable-state.md](../../hello-window/docs/observable-state.md) and
> [../../ui-controls-gallery/docs/observable-state.md](../../ui-controls-gallery/docs/observable-state.md).
> Nothing here is the impl's to *log* — these are states the **VM observes** of a correctly-built
> impl; the porting obligation is "build the UI so these reads succeed." Assertions that need
> state the verbs cannot read — the nav-button **enabled flags** and the exact open-completion
> moment — ride the **logging contract's `[document]` events** instead
> ([logging-contract.md](logging-contract.md)); the assertion map below shows which channel each
> §13 line takes.

## Process

| Observable | Verb | Notes |
|---|---|---|
| The app process is running after launch | `expect-running-app <bundle-id>` | `com.linkuistics.pdfkit-viewer-<impl>`; the impl must build to a `.app` whose `CFBundleIdentifier` matches. |
| The app process is gone after Command-Q | `expect-running-app <bundle-id> #:running? #f` | the ⌘Q chord must reach `-[NSApplication terminate:]` via the app menu (spec §8) and end the process. |

## Document state & the fixture

The app ships no document (spec §6) — **every document observable exists only after the suite
provisions the PDF fixture into the VM and drives the open panel**. The fixture rule (spec §13):
**N ≥ 3 pages** (first-boundary, last-boundary, *and* interior states all reachable), each page
carrying an OCR-distinguishable marker (e.g. a large `PAGE n`); the panel is **out-of-process**,
so it is driven by keyboard: `chord cmd shift g` → `type <fixture path>` → `press return` ×2. The
fixture lives with this app's scenarios (never in the AppSpec toolkit — no app data there).

The observable document state is the **loaded document's identity (file name), page count, and
current 1-based page index** — carried by the status label (`No PDF loaded` / `Page n of N`, the
§7.2 single source of truth) and mirrored by the `[document]` log events. **Rendered pixel
contents are never part of the observable state**: the only rendering assertion is that the
*fixture's own* page marker becomes OCR-readable (witnessing that rendering happened, not what it
looks like).

## On-screen (OCR)

| Observable | Verb | Notes |
|---|---|---|
| The window title `PDFKit Viewer` is readable | `expect-ocr "PDFKit Viewer"` | title-bar text — **invariant across impls** (spec §4; unlike hello-window/gallery, the exact text is assertable). The launch *log* line also begins `PDFKit Viewer` — distinct channels. |
| `No PDF loaded` while no document is loaded | `wait-for-ocr "No PDF loaded"` | the §7.2 empty-state label; the first read doubles as the render-settled probe. Also the persistence assertion after cancel and after clicking disabled arrows. |
| An `Open` button is readable | `expect-ocr "Open"` | the title is `Open…` (U+2026); assert the `Open` substring only — the ellipsis glyph may not OCR reliably. |
| `Page 1 of N` after a successful open; `Page n of N` after each navigation | `wait-for-ocr "Page 1 of"` etc. | the §7.2 loaded-state label. **Allow a settle before screenshots** — the label state and log events update before the repaint (spec §13). Wait on the `[document]` event first, then OCR. |
| The fixture's page marker (e.g. `PAGE 1`) after open | `expect-ocr` fixture marker | witnesses first-page rendering *(to confirm in-VM)*. |
| Open-panel affordances after clicking `Open…` | `wait-for-ocr` a panel affordance | the panel is out-of-process (§11) — OCR is the presence probe *(to confirm in-VM)*. |

The `◀` (U+25C0) / `▶` (U+25B6) button glyphs are **not** expected to OCR — they ride AX below.

## Accessibility (AX tree)

`expect-ax` / `expect-no-ax` walk `gv-ax-snapshot` matching `AXRole` (+ optional **exact**
`AXTitle`). The SDK transform folds each element's `label` → `value` → `description` (first
non-empty) into `AXTitle`, so a static text's *value* is its matchable title. Expected roles —
the *uncertain* rows are confirmed/corrected during the live-run stage before the suite
hard-asserts them (the gallery precedent: the date-picker role was corrected in-VM):

| Element | Expected role | Title match usable? | Confidence |
|---|---|---|---|
| window | `AXWindow` | `"PDFKit Viewer"` (invariant §4) | firm |
| Open button | `AXButton` | `"Open…"` — exact match must use the real U+2026 | firm role; ellipsis-in-AXTitle to confirm |
| previous-page button | `AXButton` | `"◀"` (U+25C0) | firm role; glyph-as-AXTitle to confirm in-VM |
| next-page button | `AXButton` | `"▶"` (U+25B6) | firm role; glyph-as-AXTitle to confirm in-VM |
| page label | `AXStaticText` | `"No PDF loaded"` / `"Page 1 of 3"` — exact label strings, deterministic for this app | expected to work via the value→AXTitle fold; **to confirm in-VM** — OCR is the firm fallback |
| PDF view (empty or loaded) | `AXScrollArea` (PDFView wraps a scroll view in continuous mode); children uncertain | no | uncertain — confirm during live-run |
| Quit menu item | `AXMenuItem` | `"Quit PDFKit Viewer"` | as hello-window; the ⌘Q key-equivalent itself is the standing `#:key` gap |

**The nav-button enabled flags — the spec's reliable navigation-state signal (§11) — are not
readable today**: see "gap observables" below. The label (same §7.2 refresh rule) plus the
`[document]` events are the operative proxies.

## §13 assertion → observation path (the coverage-or-gap map)

Per the forward-gen coverage-or-gap rule (`AppSpec/capabilities/forward-gen/validation.md` L1b):
every §13 line is served by a verb-backed path *or* carries a documented gap.

| §13 assertion | Observation path |
|---|---|
| process running after launch | process: `expect-running-app` |
| launch diagnostic emitted | events.log: `wait-for-log "PDFKit Viewer"` |
| window title correct | OCR `"PDFKit Viewer"` (+ AX `AXWindow` exact title) |
| empty state — label | `wait-for-ocr "No PDF loaded"` |
| empty state — navigation disabled | flags are a **gap** (enabled read); behavioural half covered: `click-at` `◀`/`▶` positions → `expect-ocr "No PDF loaded"` persists, no `[document]` event expected (absence not asserted) |
| toolbar present | AX `AXButton` (+ OCR `"Open"`) |
| open flow reaches the panel | `click-at` Open… → `wait-for-ocr` panel affordance *(to confirm in-VM)* |
| boundary — cancel is a no-op | `click-at` Open…, `press escape` → `expect-ocr "No PDF loaded"` persists; no `opened` event is emitted (per the logging contract, absence is not asserted) |
| open loads page 1 | keyboard-driven panel (fixture rule) → events.log `opened file="…" pages=N` (the reliable open-completed signal), then `wait-for-ocr "Page 1 of"` |
| the first page renders | OCR the fixture's page-1 marker *(to confirm in-VM)* |
| boundary — first page (`◀` disabled, `▶` enabled) | flags are a **gap**; proxied by the label `Page 1 of N` + the subsequent advance succeeding |
| advance | `click-at` ▶ → events.log `page-changed page=2 pages=N` + `wait-for-ocr "Page 2 of"` |
| interior page (both enabled) | flags are a **gap**; proxied by an advance *and* a back both succeeding from the interior page (each witnessed by its `page-changed` event) |
| boundary — last page | `click-at` ▶ repeatedly → events.log `page-changed page=N pages=N` + OCR `Page N of N`; the `▶`-disabled flag is a **gap** |
| boundary — no wrap-around | further `click-at` ▶ at the last page → OCR `Page N of N` persists |
| back | `click-at` ◀ → events.log `page-changed page=N−1 pages=N` + OCR |
| label tracks non-button navigation | `click-at` the document area, `press` an arrow key → events.log `page-changed` + OCR the changed label *(to confirm in-VM — the observer, not the buttons, drives the refresh)* |
| Quit terminates the app | `chord cmd q` → process gone + events.log `shutdown reason=menu` |
| close-button behaviour | recording scenario: `click-at` close button + `expect-running-app` — recorded, not asserted (spec §3 expects keep-running but flags it to-confirm; a contradiction is a spec-quality finding, not a suite bug) |

## Deferred / gap observables (not acceptance preconditions)

Reported as gaps rather than hard-asserted before the verb exists (the forward-gen "mutant-D"
discipline; same section shape as the prior apps):

- **AX enabled-flag read — this app's headline gap.** Spec §11 names the nav-button enabled flags
  the reliable navigation-state signal, and four §13 assertions turn on them. The gap is precisely
  located and **runner-side, not VM-side**: TestAnyware's snapshot protocol already carries a
  per-element `enabled` field (`testanyware-protocol/src/element_info.rs`), but the AppSpec SDK
  transform (`testanyware-sdk/agent.rkt` `element->ax-node`) drops it and `expect-ax` has no
  `#:enabled?`. A small AppSpec-side addition unlocks all four — seed it to the AppSpec backlog;
  until then the label + `[document]` events (driven by the same §7.2 refresh rule as the flags)
  are the operative proxies.
- **AXStaticText exact-value matching** (the label strings via the value→AXTitle fold) — expected
  but unconfirmed; the suite may try it as a soft assertion during live-run, with OCR the firm
  channel either way.
- **Window size/position (720×540 centred, 480×360 min) and the ⌘Q key-equivalent** → the same
  `expect-ax #:size/#:position/#:key` gap set hello-window recorded. Resize behaviour (§4/§5
  autoresizing, §7.4 auto-scaling) additionally lacks a window-resize gesture verb — spec prose
  without a runnable assertion.
- **Graphical states** — the rendered page beyond its OCR marker, auto-scaling correctness, native
  control appearance — have no OCR/AX read; confirmed visually during the live-run stage and
  recorded in `run-results.md` (sample apps must be visually perfect — the human eye still checks
  the window).

## Build obligation summary (per impl)

A conformant build must, beyond the [logging contract](logging-contract.md): render the single
centred resizable 720 × 540 window (min 480 × 360) titled exactly `PDFKit Viewer`; a top toolbar
strip (baseline-aligned horizontal stack) reading `Open…` `◀` `▶` followed by the status label;
a `PDFView` filling the rest (auto-scaling, single-page continuous), empty until the first open;
the §7.2 refresh rule as the single source of truth for the label text and nav-button enabled
states, driven by the page-changed notification observer; standard AX roles (native controls, no
custom drawing); and the app-menu **Quit** item (⌘Q → `terminate:`). The four existing impls
already build all of this — the delta each needs is the logging instrumentation.
