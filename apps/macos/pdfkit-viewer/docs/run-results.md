# PDFKit Viewer — live-VM run results

Durable record of the Tier-2 live run (`live-run-k103`, 2026-07-02): the forward-generated
`#lang app-spec` suite (`scenarios/`, 9 scenarios, leaf k102) replayed against the four built
impls in a macOS VM via TestAnyware, per the AppSpec run capability
(`AppSpec/capabilities/run/workflow.md`). Data home is here (ADR-0052/ADR-0013); the
toolkit-side record is AppSpec's workflow/validation docs.

## Run environment

- **Date:** 2026-07-02.
- **VM:** `testanyware vm start --platform macos` (golden `testanyware-golden-macos-tahoe`),
  framebuffer **1920×1080** (non-HiDPI), fresh clone, **zero provisioning** — all four impls
  are self-contained `.app`s (k98–k101 builds; racket embeds its runtime per k76, sbcl vendors
  libzstd per k75). The fixture (`fixtures/fixture.pdf`, 3 pages) uploaded to
  `/tmp/pdfkit-viewer/fixture.pdf` (the `fixture-path` run-value) before the runs.
- **Runner:** `racket AppSpec/runner/main.rkt --impl <descriptor> --run-values <config>
  --vm <id> run scenarios/`, one full-suite invocation per impl (the canonical path), with
  per-scenario solo re-runs to adjudicate unstable reds (sanctioned by run `workflow.md` §3).
- **Run-values:** measured live per impl (see *Coordinates* below) — `run-values.rkt`
  (chez + gerbil + sbcl, pixel-identical layouts), `run-values-racket.rkt` (racket's tighter
  22px control metrics).

## Outcomes (final builds)

| scenario | racket | chez | gerbil | sbcl |
|---|---|---|---|---|
| 01 steady-state cluster (hard) | **FAIL → OCR-read finding**¹ | PASS | PASS | PASS |
| 02 provisional AX roles `recording:` | PASS | PASS | PASS | PASS |
| 03 empty-state arrows inert (hard) | PASS (solo)³ | PASS | PASS | PASS |
| 04 open panel + cancel no-op `recording:` | PASS | PASS | PASS | PASS |
| 05 open loads fixture `recording:` | PASS | PASS | PASS | PASS |
| 06 page-navigation walk `recording:` | PASS | PASS | **FAIL → OCR-read finding**¹ | **FAIL → OCR-read finding**¹ |
| 07 non-button navigation `recording:` | **FAIL → spec finding**² | **FAIL → spec finding**² | **FAIL → spec finding**² | **FAIL → spec finding**² |
| 08 Command-Q terminates (hard, mandated) | PASS | PASS | PASS | PASS |
| 09 close-button keeps running `recording:` | PASS | PASS | PASS | PASS |

¹ Run-mechanism (OCR small-text) instability, **not** an app or spec defect — adjudicated
below; each behaviour independently verified through the AX/artifact/manual channel.
² The anticipated §13 arrow-key judgment point — a genuine spec-quality finding, adjudicated
below with the run-tuning probe results.
³ Red in the full-suite invocation with an empty log buffer (the k94 post-failure
delayed-truncate residual, following 01's artifact capture), green solo — graded per-scenario
per workflow §3.

**No impl defect was found.** The behavioural surface is green on all four impls — every red
adjudicates to either the cross-impl §13 spec finding (07) or the run-mechanism OCR channel
(01-racket, 06-gerbil/sbcl), and each OCR-obscured assertion was independently confirmed
(AX exact reads, failure-artifact screenshots, manual OCR probes). The standing reds are
findings by design (ADR-0010 D4) / run-mechanism residuals, adjudicated below.

## Adjudication

### 07 — spec-quality finding (CONFIRMED cross-impl): arrow keys do not page in continuous mode

`wait-for-log: page-changed page=2 did not appear` on every impl, with the fixture provably
loaded (the `opened` event fired; the failure artifacts show "Page 1 of 3" + the PAGE 1
marker rendered). The §13 line realizes "navigation the view itself handles" as an **arrow
key (Right — PDFView's conventional next-page key)**; the live probe (run-tuning, chez)
characterizes the actual PDFView behaviour in single-page-continuous mode at fit-width:

| key | observed effect (AX scrollbar value + events.log) |
|---|---|
| Right | **nothing** (no horizontal scroll room at fit-width) |
| Down | line-scroll ≈ 24 px, no page change |
| Page Down | **nothing** |
| End | **nothing** |
| **Space** | **scrolls one viewport** (≈ 0.19 of the scroll range) |

Space×3 crossed the page-1 boundary: `[document] page-changed page=2 pages=3` fired and the
label updated to "Page 2 of 3" — **the §7.1/§7.3 behaviour the scenario exists to witness
(the observer, not the buttons, drives the refresh) is TRUE**; the spec's chosen key is what
is wrong. The AX focus read confirms the click does hand key focus to the PDF document view
(`AXGroup document focused=true`), eliminating the focus-miss hypothesis.

**Feedback to reverse-gen (spec §13 + §7.3):** the non-button-navigation exemplar should be
realized as **Space** (or ≥2 presses of it) in single-page-continuous mode — arrow keys
line-scroll or no-op there; Page Down/End produced no observable effect at all through the
VNC key path. Per D4 the suite is **not** patched here; the scenario stays red until a
regeneration folds the corrected realization in (the gallery scenario-03 precedent).

### 01 (racket) + 06 (gerbil, sbcl) — run-mechanism finding (OCR small-text reads), not app defects

Two shapes of the same class. **06:** `wait-for-ocr: "Page 1 of 3" not found within 5.0s` on
gerbil (full-suite + 3 solo re-runs) and sbcl (full-suite + 1 solo); chez and racket read the
identical line green. **01 (racket):** `expect-ocr: "PDFKit Viewer" not found` — racket's
window title (bold, centred, and racket's compact 22px metrics render the toolbar text
smaller than the other impls' 26px) deterministically garbles to `viewer` in the OCR dump,
and racket's *menu-bar* name is `PDFKitViewer-racket` (no space), so unlike the other three
impls the title-bar text is racket's only OCR source for the substring; the same scenario's
`wait-for-log`, `wait-for-ocr "No PDF loaded"` (matching *inside* the garbled toolbar line)
and the preceding launch reads all passed, and the geometry pass's layout snapshot carries
the exact `PDFKit Viewer` window title + static text via AX. The evidence that this class is
**not** an app or spec defect:

- The failure-artifact screenshots show the asserted text **rendered correctly** ("Page 1 of
  3" in the toolbar; racket's title crisp and bold) at the moment of failure, with the
  matching `[document]` events in events.log — the states are real, visually verified.
- Scenario **05 passes the byte-identical label read** (same open flow, same `wait-for-ocr
  "Page 1 of 3"`) on gerbil/sbcl in the same suite invocations; **06 passes whole on
  racket + chez**, proving the walk's every assertion runner-readable in principle.
- Manual reads against the same live state return the gerbil/sbcl label at `conf=1.00` every
  time — in both query mode (`screen find-text "Page 1 of 3"`) and the runner's query-less
  dump mode; racket's title garble, by contrast, reproduces manually too (deterministic for
  its rendering).
- The failing dumps are degraded reads: sparse detections, menu-bar **icons OCR'd as text**
  ("Q" = the Spotlight magnifier, "8" = Control Center), and the toolbar row garbling with
  the ◀/▶ glyph buttons merging into the text line (**"(Page lot 3"**, **"4][• No PDF
  loaded"**). Large text (the fixture's PAGE marker) reads fine in every failing frame.

The instability is consistent per impl (chez/racket deterministically read the 06 label;
gerbil/sbcl deterministically garble it under the runner's flow; racket's title garbles
always) — OCR line-segmentation over small glyph-adjacent text, TestAnyware-side. Proper fix
is TestAnyware-side (OCR robustness on small text) or the region-scoped-OCR verb the SDK
already names as future work (`testanyware-sdk/screenshot.rkt`); forward-gen may also weigh
realizing "window title is correct" through the AX-exact read alone (already asserted in the
same scenario — the OCR read adds nothing on impls whose menu bar echoes the name, and is
engine-hostile on racket's rendering). This joins the k94 delayed-truncate residual as a
standing run-mechanism residual: **adjudicate an OCR-class red by artifact review, not by
patching the suite.** No spec correction: the observable-state role table needs no change
(the OCR channel, not the contract row, is what wobbled).

### Recording passes — confirmations (signal recorded, no spec edited as a side effect)

02/04/05/09 passing on all impls **confirms** their `(to confirm in-VM)` expectations:

- **02 — the k96 provisional AX rows are all firm:** the Open… button's exact `AXTitle`
  carries the real U+2026; the ◀/▶ arrow buttons expose their glyphs as `AXTitle`; the page
  label's value folds into `AXTitle` (`AXStaticText` "No PDF loaded"); the empty PDF view is
  an `AXScrollArea`. The observable-state role table can drop its to-confirm markers.
- **04 —** the modal open panel presents (out-of-process; "Cancel" OCR witnesses it) and
  Escape-cancel is a silent no-op (empty-state label persists).
- **05 —** the keyboard-driven fixture rule works end-to-end (Cmd-Shift-G → path → Return ×2);
  `opened` exact-matches the basename + `pages=3`; the "Page 1 of 3" label and the PAGE 1
  marker render; the window title stays "PDFKit Viewer" post-load (the §12 no-retitle
  exclusion holds via the exact AX title read).
- **06 (racket + chez) —** the full boundary walk confirmed where the OCR channel held: ▶
  advances 1→2→3 with matching `page-changed` events, an extra ▶ at page 3 is inert (no
  wrap-around), ◀ walks back 3→2→1 — every §7.4 boundary line, on two impls through the
  runner (and on gerbil/sbcl the same `page-changed` events + artifacts witness the walk's
  substance behind the failed label read).
- **09 —** close hides the window, the gui-app process keeps running on every impl (the
  hello-window + gallery precedent, third confirmation) — reverse-gen may drop the §3
  close-button marker when the spec is next regenerated.

**Bonus AX observation for the k96 gap record:** the TestAnyware **layout snapshot**
(`agent snapshot --mode layout`) carries per-element `enabled` — the geometry pass recorded
◀/▶ `enabled=false` at the empty state and ◀ `false`/▶ `true` at page 1 on all impls, exactly
the §13 flag truth. The gap remains **runner-side only** (the AppSpec SDK transform +
`expect-ax` drop the flag); the platform reports it fine, so the seeded `expect-ax
#:enabled?` backlog item closes the app's headline proxy gap when picked up.

## Coordinates — measured live (per-impl geometry practice)

Six coordinate keys, measured per impl from `agent snapshot --mode layout` (AX position+size
→ element centre, framebuffer px), **two-launch determinism diff before binding values** —
all four impls byte-identical across relaunches (no gallery-style ambiguous-layout defect;
the toolbar is a plain horizontal stack of intrinsically-sized controls):

- **chez + gerbil + sbcl are pixel-identical** (26px-high toolbar controls) and share
  `run-values.rkt`: Open… (646,182), ◀ (706,182), ▶ (748,182), doc-area (960,456),
  close (616,146).
- **racket** carries `run-values-racket.rkt` (tighter 22px control metrics, the gallery
  pattern): Open… (642,177), ◀ (696,177), ▶ (734,177), doc-area (960,453), close (614,145).

## Visual check ([[sample_apps_perfect]] — states no verb can read)

Eyeballed on all four impls (the 06/07-failure artifacts double as loaded-state captures;
racket's empty state additionally screenshot-inspected during the 01 adjudication): window
centred with the 720×540 content, toolbar strip clean (Open…, ◀/▶, label), the fixture's
tinted page fills the document area edge-to-edge at fit-width with the PAGE marker crisp in
the upper third, overlay scrollbar present, ◀ correctly greyed at page 1 with ▶ enabled.
No visual defects on any impl.

## Observations (recorded, no action)

- **`page-changed page=1` precedes `opened` in every impl's open flow** — the live runs
  exercise the logging contract's "consumers never assume ordering vs `opened`" rule for
  real (the suite's basename+pages match is ordering-proof by construction).
- A macOS **"See what's new in macOS Tahoe" notification banner** appeared mid-run on the
  fresh Tahoe clone and survives `killall NotificationCenter`; it OCR-pollutes full-screen
  dumps. Dismiss by hover + close-X click if a run hits it (it did not change any verdict
  here — gerbil 06 stayed red after dismissal).
- All four impls remain SIGTERM-deaf under `nsapplication-run` (the k94/k88 observation
  stands); only the menu-quit path (`shutdown reason=menu`, Cmd-Q) is exercisable — and it
  passed everywhere (08).
