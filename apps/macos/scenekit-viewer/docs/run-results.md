# SceneKit Viewer — live-VM run results

Durable record of the Tier-2 live run (`live-run-k112`, 2026-07-03): the forward-generated
`#lang app-spec` suite (`scenarios/`, 10 scenarios, leaf k111) replayed against the four built
impls in a macOS VM via TestAnyware, per the AppSpec run capability
(`AppSpec/capabilities/run/workflow.md`). Data home is here (ADR-0052/ADR-0013); the
toolkit-side record is AppSpec's workflow/validation docs.

## Run environment

- **Date:** 2026-07-03.
- **VM:** `testanyware vm start --platform macos` (golden `testanyware-golden-macos-tahoe`),
  framebuffer **1920×1080** (non-HiDPI), fresh clone, **zero build provisioning** — all four
  impls are self-contained `.app`s (k107–k110 builds; racket embeds its runtime per k76, sbcl
  vendors libzstd per k75). No fixtures (the app ships no document).
- **Panel provisioning (new for this app):** the shared `NSColorPanel`'s sliders pane defaults
  to the **Grayscale Slider** kind on fresh per-app defaults — the 07/08 `wait-for-ocr "Blue"`
  gate would time out (the k111 pre-agreed remedy). The run's provisioning pass opened each
  impl's panel once, selected **RGB Sliders**, and quit cleanly; the kind is remembered
  per-app (verified across quit+relaunch). All four panels open at the default frame
  **(0,605) 250×397** (bottom-left). Re-seed after any VM re-clone.
- **Runner:** `racket AppSpec/runner/main.rkt --impl <descriptor> --run-values <config>
  --vm <id> run scenarios/`, one full-suite invocation per impl (the canonical path), at
  AppSpec `611f73c` — which includes a **runner fix this live run forced** (see the
  quit-escalation finding below).
- **Run-values:** measured live per impl (see *Coordinates*) — `run-values.rkt`
  (chez + gerbil, pixel-identical), `run-values-sbcl.rkt` (toolbar 4px lower, wider
  `Colour…`), `run-values-racket.rkt` (22px compact metrics **and** a ~9px-higher panel pane).

## Outcomes (final suite, canonical invocations)

| scenario | racket | chez | gerbil | sbcl |
|---|---|---|---|---|
| 01 steady-state cluster (hard) | PASS | PASS | **FAIL → OCR-case finding**² | **FAIL → OCR-case finding**² |
| 02 picker value-fold `recording:` | PASS | PASS | PASS | PASS |
| 03 catalogue menu `recording:` | PASS | PASS | PASS | PASS |
| 04 swap shape-only `recording:` | PASS | PASS | PASS | PASS |
| 05 panel opens `recording:` | PASS | PASS | PASS | PASS |
| 06 wheel-click recolour `recording:` | PASS | PASS | PASS | PASS |
| 07 colour persists across swap `recording:` | **FAIL → spec finding**¹ | **FAIL → spec finding**¹ | **FAIL → spec finding**¹ | **FAIL → spec finding**¹ |
| 08 dismiss changes nothing `recording:` | PASS | PASS | PASS | PASS |
| 09 Command-Q terminates (hard, mandated) | PASS | PASS | PASS | PASS |
| 10 close-button keeps running `recording:` | PASS | PASS | PASS | PASS |

**No impl defect was found.** The behavioural surface is green on all four impls — every red
adjudicates to the cross-impl §13 driver-guidance finding (07, byte-identical event signature
on all four) or the run-mechanism OCR-case channel (01 on gerbil/sbcl), and each obscured
assertion was independently confirmed through the AX/artifact/manual channel. The key
behaviour — colour persists across a geometry swap — is proven on **every impl** by 08 (which
adds a panel dismissal to the same drive-then-swap flow).

¹ The §13 two-click driver-guidance finding — adjudicated below; the key behaviour (colour
persists across a swap) is independently proven by 08's pass in the same invocation.
² Run-mechanism (OCR small-text casing), not an app or spec defect — adjudicated below;
the title's correctness is independently confirmed through the AX exact read.

## Adjudication

### Runner defect this run forced (fixed AppSpec-side, the hello-window §6.6 precedent)

**A scenario that ends with an open pop-up menu starved every later scenario's setup.**
Scenario 03 asserts the *open* picker menu (its final `expect-ax 'AXMenuItem`) and — by
design — never closes it. The runner's graceful teardown (`quit-impl!` = AppleScript
`tell application id … to quit`) can never deliver to an app whose run loop is inside
**menu tracking**, so 03's instance survived teardown with its menu open; the next setup's
plain `open` (no `-n`, deliberately — two instances would fight over events.log) merely
**re-activated** the stale instance, no fresh `[lifecycle] startup` was written, and 04+
starved in `wait-ready` — a cascade confirmed live (the stale pid + still-open menu observed
directly). **Fix:** AppSpec `611f73c` — `quit-impl!` now takes `#:binary` and escalates:
graceful quit, poll VM-side for process exit (the normal case exits on the first probe),
then `pkill -9 -f <binary>` (SIGTERM is ignored under `nsapplication-run` on every impl —
the k88 observation). All 17 AppSpec test suites green; the fix is why 04+ run at all in
one invocation.

### 07 — §13 driver-guidance spec finding (CONFIRMED cross-impl): the first app-window click after panel-key DELIVERS to the popup

`wait-for-log: geometry-changed shape="Sphere" r=0 g=150 b=255 did not appear` — on **all
four impls, with byte-identical event tails**: `color-changed (255,255,255) → (0,253,255) →
(0,150,255)` then **`geometry-changed shape="Cube" r=0 g=150 b=255`**, the failure
screenshot showing the menu closed, picker on `Cube`, and the **cube rendered in the driven
blue** (the §7.4 store+apply visibly correct). Mechanism: §13's guidance — "after the panel
takes key, the first click on the app window only re-activates it; the control fires on the
second" — is **wrong for the geometry picker**: `NSPopUpButton` accepts first mouse, so the
suite's first click both re-activated the app *and opened the menu*; the second "open the
menu" click then landed on the **Cube row lying over the button** (a pop-up aligns its
current item over itself), re-selecting Cube (the logging contract's "re-selecting the
current item logs again" line — exactly what the tail shows). The Torus gate passed on the
dismissing menu's stale frame (the hazard k111 pre-documented), and the Sphere-position
click fell on a closed menu (an inert viewport click).

**Feedback to reverse-gen (spec §13):** the first-click rule is control-dependent
(`acceptsFirstMouse`): buttons need the two-click dance; the pop-up **fires on the
activating click**. The corrected 07 realization is a single picker click (as 04/08).
Per D4 the suite is **not** patched here; 07 stays red until a regeneration folds the
corrected choreography in (the gallery-03/pdfkit-07 precedent). **The behaviour 07 exists
to witness is TRUE** — 08 proves it end-to-end in the same invocation: drive to a known
colour, dismiss the panel, swap → `geometry-changed shape="Sphere" r=0 g=150 b=255`
(persistence across a swap *and* a dismissal, on the post-dismissal single-click
choreography, which works exactly as §13 expects).

### 07/08 recorded actuals — the panel's slider space is not device-RGB (pre-agreed degrade, applied)

The k111 exact matchers (`r=0 g=128 b=255`) hit the pre-agreed colour-space case: typing
0/128/255 into the RGB slider fields lands as **device `(0,150,255)`** after the impl's §7.4
device-RGB fold (the panel's slider colour space → device conversion shifts g 128→150; the
red-field commit also shifted g 255→253, corroborating a colourspace conversion rather than
a typing artifact). Deterministic and **identical on all four impls** — every impl's 07 and
08 produced byte-identical `color-changed` sequences (eight samples total): the conversion
is AppKit's, upstream of every binding, and the §7.4 device fold is uniform across the four
language runtimes. Per the k111 generation notes the matchers (not the typed drive) were
**degraded to the recorded actuals** in scenarios 07/08. Observed commit
behaviour worth keeping: each field commit fires the continuous action with converted
components of the *current* colour; a commit that does not change the panel's colour (blue
already 255) does **not** re-fire — the `(0,150,255)` line is the green commit's.

### 01 — OCR title mis-case (gerbil red; chez wobbled once), run-mechanism, not an impl defect

The OCR engine cases the camel-cap title as **`Scenekit Viewer`** (lower-case k; menu bar
and title bar both, plus the degraded-dump signature "Q"/"8" — menu-bar icons OCR'd as
text), failing 01's case-sensitive `expect-ocr "SceneKit Viewer"`. Gerbil read mis-cased
in-suite and solo; chez read mis-cased on its first (voided) invocation and green on the
next two; racket — whose pdfkit title garbled *deterministically* — read green here. Same
pixels on chez/gerbil (their layouts are pixel-identical), different reads: engine wobble,
unlucky-deterministic on gerbil's frames. The adjudication evidence that
this is not an app or spec defect:

- **The AX exact read returns exactly `SceneKit Viewer`** (the same scenario's next
  assertion — passes whenever the OCR line is reached; also confirmed by direct probe
  against the live gerbil instance and by every provisioning snapshot on all four impls).
- **A manual query-mode probe against the live state returns the mis-cased text at
  `conf=1.00`** (`find-text "SceneKit Viewer"` → `Scenekit viewer (720,159) conf=1.00`) —
  the engine is *confident* in the wrong casing; nothing about the frame is degraded.
- The failure screenshots show the title rendered crisp and correct.

On **sbcl** the same class hits harder: its menu-bar name is `SceneKitViewer-sbcl`
(no space — the title bar is sbcl's *only* OCR source for the substring, the
pdfkit-racket pattern) and the title-bar read garbled to `Scenekir viewer` (k→r). The
sbcl AX exact title was confirmed `SceneKit Viewer` at provisioning (two launches).

Joins the pdfkit k103 OCR small-text class (there: garbling under racket's compact
metrics; here: case-folding on the standard title bar). Proper fix is TestAnyware-side
(case-robust OCR or region-scoped reads); forward-gen may also weigh dropping the
whole-screen OCR half where the AX exact read already asserts the same fact. Adjudicate
by artifact review; never patch the suite.

### 04 (second invocation, chez) — wait-for-log starvation with the line provably in the log

One transient red: `wait-for-log "SceneKit Viewer"` (5s) timed out while the failure
artifact's events tail **contains the launch line** — the k75/k94 exec-channel/tailer
starvation class (the quit-escalation adds one more exec per teardown, aggravating
back-to-back channel pressure). Green in-suite on the canonical invocation; no solo run
needed. Standing run-mechanism residual; proper fix is TestAnyware-side.

### Recording passes — confirmations (signal recorded, no spec edited as a side effect)

Chez (canonical invocation): 02/03/04/05/06/08/10 confirm their `(to confirm in-VM)`
expectations — TBD cross-impl fold:

- **02 —** the picker's first-item `Cube` default holds, OCR-readable, and the popup's
  selected value **folds into `AXTitle`** (the SDK value→AXTitle fold works for pop-ups,
  not just static text — the observable-state row firms).
- **03 —** the open menu lists the full catalogue (`Sphere`/`Torus`/`Cylinder` all
  OCR-witnessed) and the open-menu items expose as **`AXMenuItem` with title** — the AX
  row the run stage's own item-position reads depend on, firmed.
- **04 —** the swap flow works end-to-end at the open-menu AX position: `geometry-changed
  shape="Sphere"` (shape-only matcher), the picker's displayed value updates, and the
  window title does **not** retitle (§12 exclusion held via the exact AX read).
- **05 —** the colour button opens the shared panel; the platform `Colors` chrome is
  OCR-readable; the in-process panel **is an `AXWindow` of the app, exactly titled
  `Colors`** (snapshot scope covers non-key floating panels — the observable-state row
  firms).
- **06 —** a **single click** in the colour wheel fires the continuous action
  (`color-changed` with bare-integer components) — the no-drag-verb degrade path was NOT
  needed (also pre-verified at provisioning on sbcl and racket: wheel clicks fired
  `r=255 g=204 b=59` / `r=255 g=235 b=73`).
- **08 —** dismissal changes nothing: the stored colour survives the panel close and the
  post-dismiss swap carries it; **the first click after dismissal delivers** (the app
  re-keys in-process — §13's post-dismissal expectation confirmed).
- **10 —** close hides the window, the gui-app keeps running (the fourth app to confirm;
  reverse-gen may drop the §3 marker on regeneration).

## Coordinates — measured live (per-impl geometry practice)

Measured per impl from `agent snapshot` (AX position+size → element centre, framebuffer px),
**two-launch determinism diff before binding** — all four impls byte-identical across
relaunches (no gallery-style ambiguous-layout defect; the toolbar is an intrinsically-sized
horizontal stack):

- **chez + gerbil pixel-identical** (26px controls, window (640,145) 640×512): picker
  (702,197), Sphere-in-open-menu (685,224), Color… (792,197), close (656,161). Share
  `run-values.rkt`.
- **sbcl** (`run-values-sbcl.rkt`): toolbar strip 4px lower — picker (702,201),
  Colour… (796,201) (wider button, the §5.1 spelling divergence); window/close/menu/panel
  shared with the default.
- **racket** (`run-values-racket.rkt`): 22px compact metrics (window (640,146) 640×508) —
  picker (694,192), Sphere (682,216), Color… (773,192), close (654,160) — **and the compact
  metrics propagate into the shared `NSColorPanel`'s picker pane**: its sliders pane sits
  ~9px higher (RGB fields at y 724/771/818 vs 733/780/827) and its wheel pane omits the
  Opacity row entirely (a larger wheel). Panel *chrome* (frame, toolbar tabs, close widget)
  is unchanged — new-to-this-app finding: per-app control metrics reach inside the shared
  system panel's content.
- **Panel (all impls):** frame (0,605) 250×397; wheel tab (37,646), sliders tab (81,646),
  wheel point (170,715), panel close (13,618).

## Visual check ([[sample_apps_perfect]] — states no verb can read)

Driven by hand on **each impl** after its suite run (screenshots in the session record):

- **Launch + spin:** all four render the lit **red cube** against the dark-grey viewport,
  crisp and centred; two frames 2s apart show clearly different orientations (edge-on ↔
  face-on) on every impl — the spin is live.
- **Swap visual:** choosing `Torus` renders the torus; chez additionally captured the
  intermediate **red torus** (the colour visibly survives the swap before any recolour).
- **Live recolour:** a single wheel click turns the rendered shape the picked yellow on
  every impl, live; the typed-drive artifacts additionally show the **blue cube** at the
  driven `(0,150,255)` with the panel reading 0/128/255 (07 artifacts, all impls).
- **Orbit:** a viewport drag rotates the camera on every impl — the torus swings from
  edge-on to face-on with its hole cleanly resolved; recolour persists through the orbit.
- No visual defects on any impl; racket's chrome differs only by its compact control
  metrics (centred title, 22px controls) — consistent with its other apps.

## Observations (recorded, no action)

- The **Tahoe "See what's new" notification banner** appeared mid-run on this fresh clone
  (the k103 gotcha); dismissed by hover + close-X between the chez and gerbil runs. It did
  not change any verdict (07's failure is fully explained mechanistically).
- The panel's continuous action **re-fires on mode/kind interactions**: switching to the
  sliders pane fired `color-changed r=255 g=255 b=255` (the fresh panel's white) before any
  field was driven — the contract's "never count `[scene]` events" rule is load-bearing.
- All impls' panels open **white** on a fresh process (the panel colour is not remembered
  across app instances); the initial *material* colour is the app's own and is never
  asserted by folded values (contract rule) — the suite's shape-only matchers held.
