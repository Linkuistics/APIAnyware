# App Catalogue

The **common macOS app portfolio** — eight target-independent apps under `apps/macos/<app>/`,
each a first-class **AppSpec** (a reverse-gen'd `spec.md` + the two contracts + a forward-gen'd
`#lang app-spec` scenario suite), realized by four VM-verified per-target implementations
(`targets/<t>/app-implementations/macos/<app>/`) and driven by the external **AppSpec** toolkit
(`~/Development/AppSpec`) against a live macOS VM through TestAnyware (ADR-0052). The apps climb
from a one-window smoke test to a framework-notification document viewer, each adding a
*distinguishing* API/pattern surface no earlier app covers.

- **Per-app data + layout** — see [`../README.md`](../README.md) (the canonical per-app shape).
- **How the specs are produced** — [`reverse-gen-workflow.md`](reverse-gen-workflow.md) (worked
  exemplar: [`../hello-window/docs/spec.md`](../hello-window/docs/spec.md)); the toolkit that
  generalizes reverse-/forward-gen is seeded in
  [`appspec-toolkit-seed.md`](appspec-toolkit-seed.md).
- **Original portfolio rationale** (why *these* apps) —
  [`2026-04-16-sample-app-portfolio-design.md`](2026-04-16-sample-app-portfolio-design.md)
  (a dated design record; this index is the current catalogue — see the status banner there).

## The portfolio

Ordered by the complexity rung each app's `spec.md` declares (1–7), with the probe last. Every
app is app-kind [`gui-app`](../../../platforms/macos/app-kinds/gui-app/) (a bundled, windowed
Cocoa app; ADR-0049) and ships a live-VM-verified suite on all four targets. **Per-app run detail
(X/Y green per impl, adjudicated reds, durable findings) lives in each app's `run-results.md` —
this index does not duplicate it.**

| Rung | App | Distinguishing surface | Scenarios | Record |
|---|---|---|---|---|
| 1 | **Hello Window** | Window lifecycle smoke test — "does a window appear?"; the first check for a new target | 3 | [spec](../hello-window/docs/spec.md) · [run](../hello-window/docs/run-results.md) |
| 2 | **UI Controls Gallery** | 15+ AppKit control types, enum constants, layout breadth — the widget-regression suite | 11 | [spec](../ui-controls-gallery/docs/spec.md) · [run](../ui-controls-gallery/docs/run-results.md) |
| 3 | **Note Editor** | `NSTextView` · `NSSplitView` · `WKWebView` live preview · `NSUndoManager` · save/open panels (completion block) · `NSNotificationCenter` · on-disk persistence | 21 | [spec](../note-editor/docs/spec.md) · [run](../note-editor/docs/run-results.md) |
| 4 | **Mini Browser** | `WKWebView` + the async multi-callback `WKNavigationDelegate` · `NSURL`/`NSURLRequest` · manufactured-offline launch | 13 | [spec](../mini-browser/docs/spec.md) · [run](../mini-browser/docs/run-results.md) |
| 5 | **Drawing Canvas** | Dynamic ObjC subclass with `drawRect:` + mouse-event overrides · direct CoreGraphics drawing · `NSColorPanel` — content is framebuffer pixels (AX-invisible) | 17 | [spec](../drawing-canvas/docs/spec.md) · [run](../drawing-canvas/docs/run-results.md) |
| 6 | **SceneKit Viewer** | SceneKit 3D rendering · `SCNAction` animation · scene-graph construction (chained-accessor traversal) · shared `NSColorPanel` | 10 | [spec](../scenekit-viewer/docs/spec.md) · [run](../scenekit-viewer/docs/run-results.md) |
| 7 | **PDFKit Viewer** | `PDFView`/`PDFDocument` · framework-specific notifications (`observer`) · modal open panel · document fixture | 9 | [spec](../pdfkit-viewer/docs/spec.md) · [run](../pdfkit-viewer/docs/run-results.md) |
| — | **Swift-Native Probe** | A coverage **proof**, not a UI app: exercises each target's `libAPIAnyware<Target>` **Swift-native trampoline residual** (`@_cdecl` shims for `objc_exposed: false` decls, unreachable by the FFI alone). The proof lives in the log, not the window. | 3 | [spec](../swift-native-probe/docs/spec.md) · [run](../swift-native-probe/docs/run-results.md) |

**Portfolio totals:** 8 apps · 87 scenarios · `gui-app` ×8 · VM-verified on racket/chez/gerbil/sbcl.

## Pattern-kind coverage

Each spec's `pattern-kinds exercised` header names the [semantic pattern-kinds](../../../semantic/pattern-kinds/)
(ADR-0048) the app realizes. Every `gui-app` exercises the same **baseline chrome** — `object-lifecycle`,
`property-configuration`, `class-method-factory`, `value-type-geometry`, `option-set` bitmask,
`view-composition` (containment), `menu` object-graph construction, and `run-loop` entry — so the
coverage story is the **distinguishing** pattern-kinds each app adds beyond that baseline:

| Pattern-kind | First covered by | Also |
|---|---|---|
| `target-action` (discrete controls) | UI Controls Gallery | note-editor, mini-browser, pdfkit-viewer, scenekit-viewer, drawing-canvas |
| `enum-constant` configuration | UI Controls Gallery | — |
| `observer` (`NSNotificationCenter`) | Note Editor | pdfkit-viewer |
| completion-block async re-entry · synchronous modal sessions | Note Editor | — |
| `delegate` (async, multi-callback navigation) | Mini Browser | — |
| `subclass-override` callback surface (`drawRect:` / mouse) | Drawing Canvas | — |
| continuous-control `target-action` (slider / colour panel) | Drawing Canvas | scenekit-viewer |
| chained-accessor traversal (node→geometry→material) | SceneKit Viewer | — |
| `protocol-conformed` member access | SceneKit Viewer | — |
| modal-panel interaction · notification-driven UI refresh | PDFKit Viewer | — |
| Swift-native trampoline residual (`objc_exposed: false`) | Swift-Native Probe | — |

## Per-target coverage & run status — derived, never hand-maintained

Per-target app status is **not** tabulated here (constraint 4 — no hand-maintained state). It is
**derived on demand** by the ws6 conformance tooling, which scans each target's shipped
`app-implementations/macos/` ports and their `bindings/macos/reports/<app>/` VM-verify evidence:

```
apianyware-conformance                 # §37 report for all four live targets
apianyware-conformance --target racket  # one target
apianyware-conformance --json           # machine-readable, one record per target
apianyware-conformance --check          # CI gate: exit 1 if authored judgment ⨯ derived reality
```

Its `common app-implementation status` block reports each app as `pass` (implemented **and**
VM-verified) or `partial` (implemented, evidence not yet captured), and cross-checks the authored
`exemplar` claims in each `targets/<t>/conformance/macos.apiw` against that derived reality. The
authored judgment (per-app-kind support call, unsupported features, research items) stays in those
`.apiw` files; the derived coverage histogram + per-app status are computed fresh every run and
never committed. This index simply **points at** that report — the single source of per-target
truth — rather than duplicating it.

Roster note for readers of that report: it enumerates every directory under
`app-implementations/macos/`, so for racket/chez/gerbil it lists a **ninth** entry,
`swift-native-method-probe` — a per-target verification probe, not a portfolio app (see below).

## Roster edges (settled by `portfolio-coverage-tie-in-k85`, 2026-07-04)

Two apps sit at the portfolio's edge; both are **recorded here as deliberately outside** the eight
common AppSpecs.

### `swift-native-method-probe` — a per-target verification probe, not a portfolio app

The method-frontier sibling of `swift-native-probe`. It proves the receiver-handle Swift-native
**method** trampoline mechanism (ADR-0030/0031/0032) works end-to-end in a real GUI — a value-struct
mutating write-back (`Foundation.IndexSet`) and an async method (`URLSession.data(from:)`). It ships
as a VM-verified `app-implementations/macos/` port on **racket, chez, and gerbil only**; sbcl's
method port is an open [research item](../../../targets/sbcl/conformance/macos.apiw) (sbcl folds its
Swift-native method coverage into its merged `swift-native-probe` instead).

**Decision: it stays a per-target probe with no common `apps/macos/` AppSpec.** It is target-mechanism
infrastructure (a project done-bar the in-process CLI smoke cannot satisfy), not a user-facing sample
app — its own README states "a verification **probe**, not a portfolio sample app." Promoting it to a
common AppSpec would misrepresent per-target mechanism proof as portable app behaviour. The
`swift-native-probe` spec's deferred own-spec question (§ its "coverage set" note) is resolved here:
**no**. It is not listed as a `gui-app` exemplar in any conformance file (correctly — the seven
exemplars already ground the `pass` call). *k85 checked all three impls for the hardcoded
app-menu-name typo that afflicted `swift-native-probe`'s gerbil/sbcl builds (space vs. hyphen):*
**clean** — racket/chez/gerbil all pass the correct `"Swift-Native Method Probe"`.

### `modaliser` — an external real-world reference app, not a sample

Modaliser-Racket is a real shipping app whose real-world coverage (NSStatusBar, NSMenu,
target-action, CGEvent taps, WKWebView, Accessibility, dynamic ObjC subclasses) **informed** the
portfolio design (see the coverage matrix in the design doc). Its scenario material once lived at an
untracked `knowledge/apps/modaliser/` path.

**Decision: it has no place in the `apps/macos/` portfolio, and nothing is relocated.** The D1
plan to relocate its suite was overtaken by the D2 greenfield finding: `knowledge/` was **entirely
untracked** and is absent from the refactored tree (confirmed absent on `main` too) — there is
nothing committed to move, and importing untracked, unreviewed material into the portfolio would be
scope creep, not relocation. Modaliser remains an external reference app that shaped the design; the
eight sample apps above are greenfield AppSpecs, not ports of it.

## Machine manifest — still deferred (D3 holds)

The grove-domain structural facts an app carries — its **app-kind** (ADR-0049 instance side), the
**pattern-kinds** it exercises, its **display-name** — stay **prose** in each app's `spec.md`
structured header. The coverage tie-in above is **not** a machine consumer of those facts: the
conformance CLI reads the app↔app-kind binding from each *target's* `conformance/macos.apiw`
(`exemplar` names) and derives status from directory + report presence — it never reads
`apps/macos/<app>/`. So D3's "author a machine `app.apiw` manifest IF a real machine consumer
materializes" test still resolves **no**; the manifest remains deferred (constraint 4, lazy). The
one machine read of an app dir — the four bundlers taking the display-name from `spec.md`'s first
H1 — is served by prose, as designed.

## History

The original portfolio replaced a simpler set (hello-window, counter, ui-controls-gallery,
file-lister, menu-bar-tool, text-editor, mini-browser) once LLM-assisted replication + TestAnyware
removed the "keep apps simple so they're hand-portable" constraint. `counter`, `file-lister`,
`menu-bar-tool`, and `text-editor` were retired (2026-04-27; rationale in the design doc);
`hello-window` is now the canonical demo for the bundler integration test, the top-level README
bundle-layout example, and the VM-testing walkthrough. Table-view / stack-view learnings that first
surfaced via `file-lister` are retained as historical attribution in
[`targets/racket/docs/reference.md`](../../../targets/racket/docs/reference.md).
