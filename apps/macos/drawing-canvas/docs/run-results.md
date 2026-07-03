# Drawing Canvas — live-VM run results

Durable record of the Tier-2 live run (`live-run-k139`, 2026-07-03): the forward-generated
`#lang app-spec` suite (`scenarios/`, 17 scenarios, leaf k138) replayed against the four built
impls in a macOS VM via TestAnyware, per the AppSpec run capability
(`AppSpec/capabilities/run/workflow.md`). Data home is here (ADR-0052/ADR-0013); the toolkit-side
record is AppSpec's workflow/validation docs. Seventh app through the toolkit — the first whose
primary content surface is a **custom `NSView`** (strokes are framebuffer pixels, OCR-meaningless
and AX-invisible), so the `[canvas]` log events carry every state assertion and screenshot
artifacts carry the visual bar.

> **Update — `canvas-ax-scope-k140` (2026-07-03): the sole k139 red is closed → 17/17 ×4.**
> Scenario 03's whole-snapshot `expect-no-ax` red was a snapshot-scope finding, not an impl defect
> (diagnosis unchanged, below). k140 gave AppSpec's `expect-ax`/`expect-no-ax` an opt-in **`#:scope
> 'app-content`** (toolkit commit AppSpec `cb178f8`) that walks only the app-under-test's window
> content — dropping the window's own title-bar `AXStaticText` (text == the window's AXTitle) and
> foreign windows (Notification Center) — and regenerated scenario 03 to use it. Re-verified in a
> fresh Tahoe VM against the same four k133 bundles: **03 PASS on all four impls** via the real
> AppSpec runner, plus a 01+02 regression spot-check (chez) confirming the additive scope left the
> default `'anywhere` path intact. The table/tally below are updated to the **final 17/17 ×4** state;
> the original k139 adjudication is retained (marked resolved) for legibility.

## Run environment

- **Date:** 2026-07-03.
- **VM:** `testanyware vm start --platform macos` (golden `testanyware-golden-macos-tahoe`),
  framebuffer **1920×1080** (non-HiDPI), fresh clone, **zero build provisioning** — all four impls
  are now self-contained `.app`s (k133 builds: racket 86M **self-contained since k76** —
  `raco exe` + `raco distribute`, no host Racket/ffi2 needed; chez 5.1M, gerbil 58M, sbcl 83M;
  reused unrebuilt — no impl source changed after k133; per-impl bundle-ids verified). Installed to
  `/Applications/DrawingCanvas-<impl>.app`, `xattr -dr com.apple.quarantine`.
- **Guest prep:** `/tmp/drawing-canvas/` created; Tahoe `EnableStandardClickToShowDesktop` disabled.
  **No fixtures, no `work/`, no between-scenario cleanup** (the app has no persistence — all state
  is in-process and dies with each relaunch; observable-state.md).
- **NSColorPanel provisioning (the k112 rule):** each impl's shared panel seeded to the **RGB
  Sliders** kind at provisioning and **clean-quit (Cmd-Q)** — the kind then **persists across the
  runner's per-scenario `open -n` relaunches** (verified: racket relaunched into RGB directly).
  Fresh per-app defaults open the sliders pane in Grayscale; re-seed after any VM re-clone. The
  panel remembers a **per-app frame** (chez/gerbil (0,605), racket/sbcl (0,610)).
- **Runner:** `racket AppSpec/runner/main.rkt --impl <descriptor> --run-values <config>
  --vm <id> run <chunk-dir>` at AppSpec **`49a6340`** (the k121/k130 base — `drag-from-to`
  + the `gv-click` pre-move — **plus the settle-move fix this run forced**, see adjudication). The
  suite ran in **four chunked invocations per impl** — [01–05] [06–08] [09–11] [12–17] — with idle
  gaps, the workflow's harness-convenience split against the exec-channel close stall (the k75
  residual; recurred here as back-to-back 30s `Process timed out` on rapid transitions). Chunking
  is not a runner limitation.
- **Run-values:** measured live per impl (see *Coordinates*) — `run-values.rkt`
  (chez + gerbil + sbcl, pixel-identical app window), `run-values-racket.rkt` (compact 22px metrics).

## Outcomes (final suite)

| scenario | racket | chez | gerbil | sbcl |
|---|---|---|---|---|
| 01 launch steady-state cluster (hard) | PASS | PASS | PASS | PASS |
| 02 slider initial-value AXTitle fold `recording:` | PASS (confirms) | PASS (confirms) | PASS (confirms) | PASS (confirms) |
| 03 canvas exposes no content AX `recording:` | PASS (scoped)¹ | PASS (scoped)¹ | PASS (scoped)¹ | PASS (scoped)¹ |
| 04 Clear on empty canvas no-op (hard) | PASS | PASS | PASS | PASS |
| 05 bare click paints a dot `recording:` | PASS (confirms)² | PASS (confirms)² | PASS (confirms)² | PASS (confirms)² |
| 06 held-button drag paints a stroke `recording:` | PASS (confirms) | PASS (confirms) | PASS (confirms) | PASS (confirms) |
| 07 width applies to new strokes only `recording:` | PASS (confirms) | PASS (confirms) | PASS (confirms) | PASS (confirms) |
| 08 Clear empties the canvas (hard) | PASS | PASS | PASS | PASS |
| 09 Color… opens the colour panel `recording:` | PASS (confirms) | PASS (confirms) | PASS (confirms) | PASS (confirms) |
| 10 live recolour — the key behaviour `recording:` | PASS (confirms) | PASS (confirms) | PASS (confirms) | PASS (confirms) |
| 11 dismissing the panel picks nothing `recording:` | PASS (confirms) | PASS (confirms) | PASS (confirms) | PASS (confirms) |
| 12 control-drag draws nothing `recording:` | PASS (confirms) | PASS (confirms) | PASS (confirms) | PASS (confirms) |
| 13 typing draws nothing (hard) | PASS | PASS | PASS | PASS |
| 14 undo chord is inert (hard) | PASS | PASS | PASS | PASS |
| 15 no strokes across relaunch (hard) | PASS | PASS | PASS | PASS |
| 16 Command-Q terminates (hard, mandated) | PASS | PASS | PASS | PASS |
| 17 close-button keeps running `recording:` | PASS (confirms) | PASS (confirms) | PASS (confirms) | PASS (confirms) |

**Tallies (final, after k140): racket 17/17, chez 17/17, gerbil 17/17, sbcl 17/17.** **No impl
defect.** At k139 the sole red was 03 (16/17 ×4), a byte-identical **snapshot-scope run-mechanism
finding** closed by `canvas-ax-scope-k140` (banner above; the scoped negative re-verified green ×4);
the mandated Command-Q invariant (16) and **all eleven `recording:` confirmations** are green on all
four impls.

¹ At k139 the whole-snapshot `expect-no-ax` tripped on the window's title-bar chrome (diagnosed
below); k140 scoped the negative to app-window content (`#:scope 'app-content`), re-verified PASS ×4.
² Green **after** the gv-click settle-move fix this run forced; the first (discarded) chez attempt
  failed 05 to a driver-injected coincident drag point (`points=2`) — adjudicated below.

## Adjudication

### THE run-forced AppSpec fix — `input click` injects a coincident drag point (points=2)

The first chez attempt failed **05** with one signature: a bare `click-at` on the canvas committed
`stroke-committed r=0 g=0 b=0 width=2 **points=2**`, not the `points=1` the §7.2 motionless-click
dot discriminator asserts. Isolated by live bisection to a deterministic driver characteristic:
**`testanyware input click X Y` moves the cursor to (X,Y) AND presses in one call**, and on a
custom `NSView` that tracks `mouseDragged:` the move-coincident-with-the-press synthesises **one
spurious `mouseDragged:`** — so a bare click paints a **two-point stroke**. Three strategies pinned
it: far-move + `input click` → points=2; pre-move-off + `mouse-down`/`mouse-up` from off-target →
points=2 (the down's implicit move injects the drag); **pre-move-off + `input move` ONTO the target
+ settle + press → points=1**. The cursor must be **already parked at the target** when the button
goes down.

**Fixed as an AppSpec commit during the run** (the k33/k121/k130 precedent): `gv-click` now issues a
**second move — onto the target — before the click** (`testanyware-sdk/input.rkt`; the k130 ≥100px
re-sync pre-move is retained *before* it, so the swallow protection is intact). Verified in-VM on
the fixed runner: a bare click → `points=1` (the dot); a `drag-from-to` still → `points=\d+` (2–3);
a **button still fires** on down+up (Clear/Color… both drove throughout the run). The full suite
then ran green (bar 03) on all four impls. This is the signature finding of the portfolio's first
canvas-gesture app — the analogue of note-editor's capture-then-parked-click swallow and
mini-browser's type→click race; the proper long-term fix (a driver-level "click without a coincident
move") remains TestAnyware-side.

### 03 (all four) — the whole-snapshot `expect-no-ax AXStaticText` trips on window chrome, not canvas  — RESOLVED by k140

`expect-no-ax #:role 'AXStaticText` walks the **whole-system** `agent snapshot` and finds
platform chrome the canvas never produces: at steady state (panel closed) the tripping node is the
app window's own **title-bar `AXStaticText "Drawing Canvas"`** (every titled AppKit window exposes
its title this way in the snapshot), joined by the desktop **Notification Center** widgets'
`AXStaticText` (e.g. "Photos will appear here when they are finished processing"). **Neither is
canvas content.** The canvas itself is genuinely **AX-absent** — an app-defined `NSView` with no
accessibility configured (§6/§12/§13), it never appears as an element in *any* snapshot on *any*
impl (which is *why* 01/02/09 only ever find the toolbar controls + the panel, never a canvas
node). So the spec's claim — the canvas exposes no content elements — is **confirmed**; the
scenario's whole-snapshot `AXStaticText` negative is simply **too broad**. This is precisely the
`recording:`-scenario finding scenario 03's own description anticipated ("platform chrome exposes
static text the whole-snapshot negative trips on, and the run stage narrows the key"). Red **by
design** until a forward-gen regeneration narrows the assertion — scope the negative to the app
window's content region below the toolbar, or assert the canvas region specifically has no children
(its absence *is* the fact). **Not a suite bug, not an impl defect, not an acceptance blocker** (the
gallery-03 / pdfkit-07 / scenekit-07 / note-editor-11 stays-red-until-regen precedent). The suite is
never patched from the run loop.

**Closure (`canvas-ax-scope-k140`, 2026-07-03 — the user chose to chase the literal 17/17 rather
than leave 03 adjudicated).** The finding is a *scope* gap in the negative verb, so the fix is a
**scoping mechanism**, not a suite patch or an impl change. AppSpec `expect-ax`/`expect-no-ax` gained
an opt-in **`#:scope`** (default `'anywhere` = the unchanged whole-snapshot walk; `'app-content`
narrows to the app-under-test's standard window content, dropping the title-bar `AXStaticText` whose
text equals the window's own `AXTitle` and all foreign windows). The app-under-test is identified
snapshot-intrinsically — the `appName` owning the Menu Bar, which the frontmost app always does — so
no per-app plumbing is needed; the transform now preserves each window's `appName`/`windowType`/
`focused` to feed it (AppSpec commit `cb178f8`, hermetic tests + full suite 17/17). Scenario 03 was
regenerated to `(expect-no-ax #:role 'AXStaticText #:scope 'app-content)` — a forward-gen refinement,
committed downstream, never a run-loop patch. **Re-verified in a fresh Tahoe VM against the same four
k133 bundles: 03 PASS on racket, chez, gerbil, sbcl** (the real AppSpec runner, per-scenario launch/
teardown); a 01+02 spot-check on chez confirmed the additive scope left the default path intact. The
proof is honest, not a hidden red: on the live chez tree the whole-snapshot walk still finds the
title chrome `"Drawing Canvas"` (the k139 red reproduced) while the scoped walk finds nothing yet
still sees the real toolbar `Clear` button — the canvas region genuinely has zero content AX. The
underlying spec fact (canvas exposes no content elements) was already confirmed at k139; k140 makes
the *assertion* discriminating. Reusable closer for the "no content AX on a custom-view surface"
shape (swift-native-probe and future apps inherit it).

## Recording confirmations (signal recorded; no spec edited as a side effect)

All eleven `recording:` scenarios that this run could execute confirmed their expectation on **all
four impls**; each is a signal reverse/forward-gen may fold the marker into a hard assertion on
regeneration (a downstream spec edit / reviewed golden re-bless, never an adjudication side effect):

- **02 —** the slider's value **2 folds into its AXTitle** (`expect-ax #:role 'AXSlider #:title "2"`)
  on all four — the provisional value-read format firmed; the firm state half rides `width=2` on the
  first stroke's events.
- **05 —** a bare click paints a **1-point stroke** (`stroke-begun`/`stroke-committed … points=1`) —
  the dot discriminator, confirmed once the driver produces a true single-point click (above).
- **06 —** a **held-button drag paints a stroke** (the portfolio's **first live use of
  `drag-from-to`**): `stroke-committed … points=\d+` (points 2–3, driver-cadence — never bound
  exactly). The §14 preamble's "no mouse-drag verb" is now stale.
- **07 — the width freeze:** a stroke at launch commits `width=2`; a slider drive to the track's
  effective right end fires `width-changed width=20` (the range's upper bound witnessed via the
  platform clamp); a new stroke commits `width=20` while the earlier `width=2` line is unchanged on
  record — **§2's capture-at-mouse-down freeze proven from the log alone.**
- **09 —** Color… brings up the shared panel as an **`AXWindow` titled "Colors"** (+ OCR "Colors")
  on all four — the panel-presence gate 10/11 rely on.
- **10 — THE key behaviour (live recolour applies to subsequent strokes only):** driving the RGB
  fields to 0/128/255 fires `color-changed r=0 g=150 b=255` (the device fold — below), and a new
  stroke commits `r=0 g=150 b=255` while the **baseline `r=0 g=0 b=0` line already on record never
  changes.** Confirmed on all four; the pixel half is the visual-bar artifact (below).
- **11 —** dismissing the panel picks nothing: a stroke drawn after the dismissal still carries the
  last driven colour (no intervening `color-changed`) — the positive form of "picks nothing".
- **12 —** a drag begun **on the slider** draws nothing: the control's tracking loop captures the
  pointer (`width-changed` fires, canvas gets no `mouseDown:`), and a follow-up Clear reports
  `cleared count=0` — the §7.2 boundary held, the cardinality channel turning the absence positive.
- **17 —** close hides the window, the `gui-app` **keeps running** — the **seventh app** to confirm
  the §3 no-close-to-quit expectation; closing emitted no `shutdown` line (as the contract expects).

The `wait-for-ocr "Blue"` gate in 09/10/11 **did resolve** under the runner's repeated-capture poll
despite a standalone finding that the Blue slider label OCRs as **"Rluc"** (conf 0.50 — the k103
small-text class); Red/Green read at conf 1.00. Recorded as a latent OCR residual (a forward-gen
regeneration could prefer a Red/Green gate or an AX read of the RGB pane), but it **cost no verdict**
here — every panel scenario passed.

### The device-RGB fold (the k112 rule, confirmed for drawing-canvas)

A manual drive (chez) captured the panel's non-device-RGB slider space: typing **0 / 128 / 255**
into the RGB fields lands, after the §8.1 `colorUsingColorSpace: deviceRGBColorSpace` fold, as
**device `r=0 g=150 b=255`** (g 128→150) — byte-identical across impls (AppKit-side, uniform per
runtime); the intermediate cyan step folds `255→253` (`color-changed r=0 g=253 b=255`) before the
green field commits. Suites bind **recorded actuals** (the scenarios already do); a no-change field
commit does not re-fire the action.

## Visual bar (artifact review — [[sample_apps_perfect]])

Screenshots of a rich manual drive on chez (no pixel-diff verb exists — the human eye is the
channel, spec §12):

- **Round dots** — a width-2 bare click paints a small round dot; a width-20 click paints a large
  round disc (the §7.3 coincident-second-point round-cap rule renders a single click as a disc).
- **Smooth, connected, round-capped strokes** — width-2 and width-20 `drag-from-to` strokes render
  as smooth connected lines with round caps/joins, no mitres.
- **Width applies to new strokes only** — thin (width-2) and thick (width-20) strokes coexist, each
  frozen at its own gesture.
- **Recolour applies to new strokes only — the headline visual** — after recolouring to azure
  (device `0,150,255`, hex `0080FF`), a new stroke is blue while **every earlier black stroke stays
  black**: §2's capture-at-mouse-down freeze, visually confirmed.
- **Blank after Clear** — Clear (`cleared count=6`) returns the canvas to a completely blank white
  surface.

The Tahoe **"See what's new in macOS Tahoe" notification banner** appeared during the manual visual
drive (absent during the clean automated runs), sat clear of every click target and matched no gate
— **no verdict changed** (the pdfkit k103 / note-editor precedent).

## Coordinates — measured live (per-impl geometry practice)

Measured per impl from `agent snapshot --mode layout` (AX position+size → element centre, framebuffer
px), **two-launch determinism diff green on every impl** (no ambiguous-layout defect):

- **chez + gerbil + sbcl pixel-identical on the app window** (window (640,145) 640×512, 26px control
  metrics): Color… (700,195), width slider track x 759..961, Clear (1230,195), close (656,161),
  title text span x [722,830]. Share `run-values.rkt` (the pdfkit/mini-browser/note-editor
  share-set — racket alone diverges).
- **racket** (`run-values-racket.rkt`): compact 22px metrics — window (640,146) 640×508; Color…
  (700,191), slider track 761..959, Clear (1230,191), close (654,160), title span [906,1014].
- **Slider max (k94):** a track click jumps the knob to the click point clamped; the **effective
  right end = track-end − knob-half** drives the configured maximum. Live-tuned until
  `width-changed width=20` fired: **x=948** (26px), **x=947** (racket).
- **The shared NSColorPanel splits THREE ways** (deeper than the app window — "measure the share-set,
  never assume it"): the panel remembers a per-app frame origin (chez/gerbil (0,605), racket/sbcl
  (0,610)) *and* racket's compact metrics compress its picker pane, giving three RGB-field
  geometries — racket 729/776/823, chez/gerbil 734/781/828, **sbcl 739/786/833**. The chez/gerbil
  values in `run-values.rkt` land **inside sbcl's 24px-tall fields** (verified — the 5px offset is
  absorbed), so sbcl **shares** them (measured, not assumed); racket carries its own. The
  sliders-tab (81,646 / 81,650) and the tiny 9×5 panel-close split the same way.
- The **canvas region** (custom NSView, AX-absent) is derived from the window frame minus the 36pt
  toolbar band: x [640,1280] × y [~213,657] (26px) / [~210,654] (racket) — every driver-chosen
  canvas point sits comfortably inside, respecting the ~10px resize band. The k138 provisional
  (k120 spec-derived projection over scenekit's same-shape geometry) landed **essentially exact** on
  the app window (a re-validation of the projection method on this window shape); only the slider
  max and the panel sub-split needed live tuning.

## Provisional rows firmed at live-run (k138 observable-state handoffs)

- **Canvas AX invisibility — firmed** (the §14/observable-state provisional row): the canvas emits
  **no AX element at all** on any impl. The residual is only that the *scenario's* whole-snapshot
  negative over-reaches onto window chrome (03, above) — the underlying fact is confirmed.
- **Slider value-read format — firmed** (02): the value folds into `AXTitle` as `"2"`, exact.
- **Panel presence as an app `AXWindow "Colors"` — firmed ×4** (09; the k112 shape).
- **The `[canvas]` post-state event vocabulary — firmed end-to-end**: `stroke-begun` /
  `stroke-committed` (with the frozen tuple + `points`), `width-changed`, `color-changed` (success
  path only), `cleared count=<n>` (always emitted, incl. `count=0`), and `shutdown reason=menu`
  (16) all drove exactly as the k132 logging contract specified, byte-identical to the frozen
  semantics — the freeze proof (07/10) verified from the log alone, the committed tuple never
  retroactively tracking a later tool change.

## The run-forced toolkit fix (committed AppSpec-side, noted here per the workflow)

`AppSpec/testanyware-sdk/input.rkt` — `gv-click` now settles the cursor **onto** the target (a real
move + 0.15s) between the k130 re-sync pre-move and the press, so `testanyware input click`'s
move-coincident-with-press no longer injects a spurious `mouseDragged:` on a custom NSView (a bare
click → `points=1`; buttons unaffected). Committed on the AppSpec `main` grove; this downstream
`live-run-k139` commit references it. It is the ADR-0012 "run-mechanism toolkit fix the run forces"
— app data (this record, the run-values) stays downstream, the mechanism fix stays toolkit-side.
