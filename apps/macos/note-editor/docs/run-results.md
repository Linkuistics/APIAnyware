# Note Editor — live-VM run results

Durable record of the Tier-2 live run (`live-run-k130`, 2026-07-03): the forward-generated
`#lang app-spec` suite (`scenarios/`, 21 scenarios, leaf k129) replayed against the four built
impls in a macOS VM via TestAnyware, per the AppSpec run capability
(`AppSpec/capabilities/run/workflow.md`). Data home is here (ADR-0052/ADR-0013); the
toolkit-side record is AppSpec's workflow/validation docs.

## Run environment

- **Date:** 2026-07-03.
- **VM:** `testanyware vm start --platform macos` (golden `testanyware-golden-macos-tahoe`),
  framebuffer **1920×1080** (non-HiDPI), fresh clone, **zero build provisioning** — all four
  impls are self-contained `.app`s (k125–k128 builds, reused unrebuilt: no impl source changed
  after them; per-impl bundle ids verified).
- **Guest prep (the k123 persistence story):** `/tmp/note-editor/{fixtures,work}` created;
  `fixtures/fixture-note.md` uploaded **byte-exact at 123 chars** (scenario 08's
  `rendered chars=123` bound to it); `fixtures/locked.md` uploaded then `chmod 000` in-guest
  (scenario 16); Tahoe `EnableStandardClickToShowDesktop` disabled.
- **Runner:** `racket AppSpec/runner/main.rkt --impl <descriptor> --run-values <config>
  --vm <id> run <chunk-dir>` at AppSpec **`b2c6ffa`** (the k121 `611f73c` base **plus the
  gv-click pre-move fix this run forced** — see adjudication). The suite ran in **five chunked
  invocations per impl** — [01–05] [06] [07–09] [10–17] [18–21] — with
  `rm -rf work/ && mkdir -p work/` between the save-driving chunks (the k123 cleanup
  obligation: 07 asserts `expect-file #:absent?`, and a leftover `work/untitled.md` would
  raise the sheet's replace-confirmation, breaking the keyboard choreography of 05/06/09/18).
  Chunking is the workflow's harness-convenience split, not a runner limitation.
- **Run-values:** measured live per impl (see *Coordinates*) — `run-values.rkt`
  (chez + gerbil + sbcl, pixel-identical), `run-values-racket.rkt` (compact 22px metrics).
- The Tahoe "See what's new" notification banner appeared mid-run (during gerbil c1),
  OCR-polluted whole-screen dumps (visible in gerbil 01's failure dump), and auto-dismissed
  before the sbcl run; it sat clear of every click target and matched no OCR gate — **no
  verdict changed** (the pdfkit k103 precedent).

## Outcomes (final suite, chunked invocations)

| scenario | racket | chez | gerbil | sbcl |
|---|---|---|---|---|
| 01 launch steady-state cluster (hard) | PASS | **FAIL → OCR-class**¹ | **FAIL → OCR-class**¹ | **FAIL → OCR-class**¹ |
| 02 placeholder OCR-legible `recording:` | PASS (confirms) | PASS (confirms) | PASS (confirms) | PASS (confirms) |
| 03 typing marks dirty + renders (hard) | PASS | PASS | PASS | PASS |
| 04 preview tracks edits/list/fence `recording:` | PASS (confirms) | PASS (confirms) | PASS (confirms) | PASS (confirms) |
| 05 first save via sheet writes + cleans (hard) | PASS | PASS² | PASS² | PASS |
| 06 subsequent saves direct, no sheet (hard) | PASS | PASS² | PASS | PASS |
| 07 sheet-cancel changes nothing (hard) | PASS | PASS² | PASS | PASS |
| 08 open loads fixture (hard) | PASS | PASS | PASS | PASS |
| 09 save→New→re-open round trip (hard) | PASS | PASS | PASS | PASS |
| 10 dirty Open asks first; Cancel abandons (hard) | PASS | PASS | PASS | PASS |
| 11 dirty New; Discard clears (hard) | **FAIL → OCR-class**³ | **FAIL → OCR-class**³ | **FAIL → OCR-class**³ | **FAIL → OCR-class**³ |
| 12 dirty New; Cancel keeps (hard) | **FAIL → OCR-class**³ | **FAIL → OCR-class**³ | **FAIL → OCR-class**³ | **FAIL → OCR-class**³ |
| 13 clean New, no alert (hard) | PASS | PASS | PASS | PASS |
| 14 undo on fresh doc no-ops (hard) | PASS | PASS | PASS | PASS |
| 15 undo reverts / redo restores `recording:` | PASS (confirms) | PASS (confirms) | PASS (confirms) | PASS (confirms) |
| 16 locked-file open-failure `recording:` | PASS (confirms) | PASS (confirms) | PASS (confirms) | PASS (confirms) |
| 17 /System save-failure `recording:` | PASS (confirms) | PASS (confirms) | PASS (confirms) | PASS (confirms) |
| 18 no state across launches (hard) | PASS | PASS | PASS | PASS |
| 19 Command-Q terminates (hard, mandated) | PASS | PASS | PASS | PASS |
| 20 quit-unsaved neither asks nor saves `recording:` | PASS (confirms) | PASS (confirms) | PASS (confirms) | PASS (confirms) |
| 21 close-button keeps running `recording:` | PASS (confirms) | PASS (confirms) | PASS (confirms) | PASS (confirms) |

**Tallies: racket 19/21, chez 18/21, gerbil 18/21, sbcl 18/21.** No impl defect; every red is
the k103 OCR run-mechanism class, and every fact behind a red is independently proven through a
second channel (below).

¹ The 11-pt status label's OCR corroboration — adjudicated below.
² Green **after** the gv-click runner fix; the first (discarded) chez attempt failed 05/06/07
  to the capture-then-parked-click swallow — adjudicated below.
³ The alert message's wrapped second line never OCRs — adjudicated below; both behaviours
  manually proven per impl.

## Adjudication

### NEW run-mechanism class — the capture-then-parked-click swallow (fixed in-run, AppSpec `b2c6ffa`)

The first chez attempt failed 05/06/07 with one signature: after `click-at` the editor +
`type "# Hello"`, the log showed a **second `rendered placeholder=true chars=0` + a
`[document] new path="" dirty=false`** — the typed **space had PRESSED the launch-focused New
toolbar button**, i.e. the editor click never moved first responder. The failure artifact's
screenshot shows the focus ring still on New with the I-beam parked exactly on the click
point.

Isolated by live bisection to a deterministic repro: **a click whose pointer is already parked
on the target, sent right after a VNC framebuffer capture** (every `wait-for-ocr` poll is
one), is delivered — buttons still press — but its **focus effect is swallowed**. A ≥100px
real mouse motion between capture and click re-syncs the channel; a 2px nudge does **not**.
The trigger explains the in-run pattern: every scenario parks the pointer on the editor point,
so a scenario opening with OCR-probe → click-same-point inherits the swallow; 03/04 escaped
because the pointer had last rested elsewhere.

**Fixed as an AppSpec commit during the run** (the k33/k121 precedent): `gv-click` now
pre-moves 100px off-target and settles 0.2 s before every click (`b2c6ffa`). The full chez
suite re-ran green on the fixed runner; 05 solo-verified 2/2 first. Joins the k121 type→click
race as the second input-channel-race class; the proper fix remains TestAnyware-side
(serialize/flush pointer state across capture and input).

### 01 (chez/gerbil/sbcl) — the 11-pt status label is OCR-invisible; AX carries the fact

`expect-ocr "Ready"` fails because the whole-screen OCR dump **does not contain the status
label at all** (classic k103 signature alongside: menu icons as `Q`/`8`, `Save.` truncation).
The preceding `expect-ax #:role 'AXStaticText #:title "Ready"` — the same fact via the
value→AXTitle fold — **passed on every impl**, as did the §14 2s-pause exact re-read. On
racket's compact 22px layout the same OCR read is **green** — the k103 class strikes
layout-dependently, with the casualty roles inverted vs mini-browser (there racket's layout
was the victim; here the shared 26px layout is). The scenario's own comment pre-declared this
read adjudicate-by-artifact; the AX channel is the channel of record.

### 11/12 (all four impls) — the alert message's wrapped second line never OCRs; both behaviours proven via the second channel

Both scenarios gate on `wait-for-ocr "start a new note"` — the New-specific message tail that
discriminates this alert from Open's. The §8.1 alert renders its message wrapped:
`Discard unsaved changes and` / `start a new note?`. **OCR reads the first line of each
wrapped block and drops the second** — the dumps carry `Discard unsaved changes and` and
`Your changes will be lost if` (racket also reads `you continue.` and `Cancel`) but never
`start a new note?`, on all four impls. The alert itself is up and correct: line 1 is legible
in the failing dump, and the open-alert AX snapshot carries the full message text (see
*Coordinates*). Scenario 10 — whose gate is the line-1-safe `"Discard unsaved changes"` —
passed everywhere, proving the alert + AX shape + Cancel-abandon path live in-suite (with
trigger=Open).

**Both blocked behaviours were then proven manually per impl** (one drive per impl, events +
AX title as the channels, artifacts in the events tails):

- **12's fact (Cancel keeps everything):** dirty doc → New → alert → click Cancel at the
  measured centre → **no mutation event** (cancel is contract-silent), typing renders intact,
  title still the `— edited —` form.
- **11's fact (Return-Discard clears everything):** New again → **Return fires the default
  Discard** (Cancel is *focused* but Discard, added first, is *default* — Return took the
  default, exactly the §15 driver-guidance assumption) →
  `[preview] rendered placeholder=true chars=0` + `[document] new path="" dirty=false`,
  title back to `Untitled — Note Editor`. Identical on racket, chez, gerbil, sbcl.

The reds stay red by design until a regeneration folds a line-1 gate (plus an AX
discriminator for the trigger-specific tail) in — the gallery-03/pdfkit-07/scenekit-07
stays-red-until-regen precedent. The suite is never patched from the run loop.

## Recording confirmations (signal recorded; no spec edited as a side effect)

- **02 —** the ~16px gray-italic WKWebView placeholder `Start typing Markdown on the left…`
  **is OCR-legible** (conf 1.00) — the app's headline OCR unknown confirmed on all four impls,
  pre-adjudicating every later placeholder-as-preview-emptied-state read (09/11/15/16/18 all
  used it green). Reverse-gen may drop the §15 WKWebView-OCR marker.
- **04 —** the preview tracks continuous edits; list items and fenced code render (body-size
  OCR reads confirmed ×4).
- **15 —** undo reverts typing, redo restores it — **the §9 platform-coupling unknown is
  FIRMED**: a text-mutating Undo drives the same notification path as typing (the placeholder
  re-render fired live). **Grouping actuals** (manual single-click probe, chez): a VNC-typed
  burst (`# Hello`) coalesces into **one undo group — a single Undo click reverts it all**
  (`rendered placeholder=true chars=0` after click 1); further clicks hit the empty stack and
  no-op silently (§8.5.8, no event). The suite's 8-click overshoot is safely idempotent.
- **16 —** the open panel **will select a mode-000 file** (no pre-validation): `[document]
  open-failed path=…/locked.md dirty=false` fired, status `Open failed` legible, title/
  placeholder untouched — the §8.5.6 path is drivable end-to-end.
- **17 —** the save sheet **lets a SIP-protected target through to the app's write** (the
  panel did not pre-validate writability — the platform possibility the spec flagged did not
  materialize): `[document] save-failed path=…/untitled.md dirty=true` fired, status
  `Save failed` legible, dirty title persisted. §8.5.7 drivable end-to-end.
- **20 —** quit with unsaved edits neither asks nor saves: `shutdown reason=menu` + process
  gone on all four — **§3.10 confirmed** (the guard covers New/Open only). This was the
  scenario explicitly flagged for human confirmation; this record + the git review of this
  file is that confirmation's evidence.
- **21 —** close hides the window, the gui-app keeps running (sixth app to confirm §3.9).

## Coordinates — measured live (per-impl geometry practice)

Measured per impl from `agent snapshot --window "Untitled — Note Editor" --mode layout`
(AX position+size → element centre, framebuffer px), **two-launch determinism diff green on
every impl** (no ambiguous-layout defect):

- **chez + gerbil + sbcl pixel-identical** (window (510,115) 900×632, 26px control metrics,
  toolbar centre-line fb y 171): New (548,171), Open… (615,171), Save… (689,171),
  Undo (758,171), Redo (822,171), status label value `Ready` at (857,164), close (526,131),
  split group (522,203) 876×532. Share `run-values.rkt`. (The pdfkit/mini-browser share-set —
  sbcl did **not** diverge here as it had in scenekit.)
- **racket** (`run-values-racket.rkt`): compact 22px metrics — window 900×628, centre-line
  y 166: New (545,166), Open… (607,166), Save… (674,166), Undo (736,166), Redo (794,166),
  close (524,130), split group (522,200) 876×532.
- **Alert (measured from the OPEN alert, the scenekit precedent): layout-INDEPENDENT.** The
  screen-centred NSAlert is byte-identical over the racket and chez window layouts: window
  role dialog titled `alert`, 260×234; image `<display-name> alert`; message + informative
  static texts (full text readable in AX); **Cancel (845,404) 112×30 `[focused]`**, **Discard
  (963,404) 112×30 rightmost = default** (Return fires Discard, not the focused Cancel).
  `alert-cancel` lives in the shared table for all four impls.
- **The k129 spec-derived provisional coordinates all landed inside their control bounds**
  (close-button exact on the shared layout; worst was Redo, 10px off-centre) — the k120
  projection method (window frame + [NSWindow center] bias + intrinsic stack sizing) is
  re-validated on its third window shape. The alert projection was 61px off in y — the
  "weakest projection, measure from the open alert" flag earned its keep.
- The editor point (741,447) sits inside the left split pane on both layouts and serves all
  impls unchanged.

## Provisional rows firmed at live-run (k123 observable-state / k129 handoffs)

- **Save-sheet shape:** an `AXSheet` titled `save` attached to the window, (775,339) 370×182
  on the chez layout — its **children are NOT exposed** in agent snapshots, so the prefilled
  name field is unreadable via AX; the lowercase `untitled` OCR cue (read at conf 1.00 as
  `Save As: untitled`) is genuinely the only contract-stable sheet-up gate, and it is
  case-discriminating against the title bar's `Untitled`. Sheet modality is AX-visible: the
  close traffic-light flips `enabled=false` while the sheet is up.
- **Go-to-Folder INSIDE the save sheet works** (Cmd-Shift-G → `Go to Folder` overlay → typed
  absolute dir → Return ×2) — the k103 rule, previously firmed only for the open panel,
  extends to the sheet on all four impls (05/06/09/17/18 all rode it green).
- **Escape cancels the save sheet** (pdfkit firmed it for the open panel): sheet dismissed,
  document still dirty, nothing written, contract-silent — 07 green ×4.
- **Panels canonicalize `/tmp` → `/private/tmp`** in the paths the impl then reports:
  `saved path="/private/tmp/note-editor/work/untitled.md"` — the suite's basename-only
  matchers are load-bearing.
- **The window AX title is the dirty channel and tracks exactly:**
  `Untitled — Note Editor` → `Untitled — edited — Note Editor` →
  `untitled.md — Note Editor` (real U+2014, exact `equal?` matches green throughout).
- **Editor `AXValue` / WKWebView rendered DOM are NOT surfaced** in agent snapshots: the
  split group has no exposed children in either interact or layout mode — the editor text
  and preview DOM are unreadable via the AX channel. The `[preview] rendered` events + OCR
  remain the only preview-state channels (as k123 assumed); the status label's value→AXTitle
  fold is the one reliable AX text read inside the content area.
- **Launch-line prefix rule holds:** `Note Editor running.` ×3 vs sbcl's
  `Note Editor opened. …` — the suites' `#rx"Note Editor"` prefix matcher absorbed the
  divergence by design.

## Per-impl notes

### racket — 19/21; the two wrapped-alert-line reds only

The compact-22px layout again diverges (its own run-values sibling), and again changes the
OCR casualty set: 01's `Ready` read is **green** here while red on the other three. No
type→click race appeared — every suite `type` settles on its final `rendered chars=N` line
before any button click (the k121 guidance baked into the k129 suite), and the runner's new
pre-move adds slack. The k76 self-contained bundle launched with zero provisioning.

### chez — 18/21; forced the runner fix, then clean

The first attempt's 05/06/07 swallow cluster forced the gv-click fix; on `b2c6ffa` the full
suite ran with only the standing OCR-class reds (01/11/12). The k123 `[document]`event
vocabulary was exercised end-to-end live (new/opened/saved/open-failed/save-failed/
dirty-changed all observed).

### gerbil — 18/21, verdict vector identical to chez

The Tahoe banner appeared during its c1 and polluted 01's OCR dump (the `Ready` red stands on
the label-absence signature regardless — the banner text matched no gate). The k127
`(except-in … string-length)` shadow fix is exercised by every WKWebView `loadHTMLString:`
hand-off throughout the suite.

### sbcl — 18/21, verdict vector identical to chez/gerbil

The production-bundler build (travels alone, k128) ran the whole suite with zero
provisioning; the `opened.` launch-line remainder divergence stayed invisible to the suite by
construction. sbcl shared the chez/gerbil pixel-identical layout (unlike scenekit, where its
toolbar sat 4px lower — measured, never assumed).

## Spec-quality / doc-quality findings for the next regeneration

1. **Alert-message OCR gate (11/12)** — a wrapped alert message's second line is
   OCR-invisible; regen should gate the alert on its first line (`Discard unsaved changes`)
   and discriminate the trigger via a second channel (the AX message text carries the full
   string; an exact `expect-ax` on the message static-text value is available). The
   k121 finding recurs: a substring-capable AX verb (or per-impl status strings as
   run-values) would close this class.
2. **11-pt status OCR corroboration (01)** — layout-dependent (invisible at 26px, legible at
   racket's 22px); AX-exact stays the channel of record, OCR corroboration
   adjudicate-by-artifact.
3. **NEW driver-guidance line for §15 / TestAnyware backlog** — after a framebuffer capture,
   a click at the pointer's parked position is focus-swallowed; drivers must pre-move
   (runner-fixed in AppSpec `b2c6ffa`; proper fix TestAnyware-side).
4. **§9 undo firmed** — delegated text-system undo confirmed; grouping = one coalesced group
   per typed burst (single Undo reverts it; extras silent no-ops); a text-mutating undo rides
   the same §6.2 change path as typing. Reverse-gen may drop the §9/§15 markers and record
   these actuals.
5. **§8.5.7 sheet lets /System through** — the panel does not pre-validate writability; the
   app's write fails and surfaces exactly as specified. The spec's "the panel may refuse"
   hedge can be dropped.
6. **k129 handoff findings confirmed for the docs:** spec §15's driver guidance names a `--`
   flag-terminator the SDK's `gv-type` does not pass (suites use the `*` §7.2 list marker
   instead — the guidance line should name that alternative); the k123 observable-state
   round-trip sketch ("open the fixture → Save… to work/") contradicts §8.4 (an opened doc
   has a path → direct overwrite) — the suite's 09 realizes type → sheet-save → New →
   re-open instead.

## Acceptance inputs (for the toolkit-side verdict)

Condition (c) of the run workflow's cross-impl acceptance review, folded:

- **No impl defect on any of the four impls.** Final tallies: racket 19/21, chez 18/21,
  gerbil 18/21, sbcl 18/21. Every red adjudicates to the k103 OCR run-mechanism class, and
  every behavioural fact behind a red is independently proven: 01's `Ready` via the in-suite
  AX read; 11/12's Discard/Cancel semantics via the per-impl manual drives (events + titles).
- **The mandated invariant held everywhere:** 19 (Command-Q terminates,
  `shutdown reason=menu` + process gone) green on all four impls.
- **The behavioural core is green on all four impls on the log/AX channels:** the full
  persistence machinery live — sheet-save with prefill, direct re-save, sheet-cancel,
  fixture open (byte-exact 123-char render), save→New→re-open round trip, both failure
  paths (locked read, SIP write), dirty-state title tracking, the launch/steady-state
  cluster, no-state-across-launches, and all six lifecycle/undo scenarios.
- **All eight `recording:` scenarios confirm their expectations** (02, 04, 15, 16, 17, 20,
  21 — plus 01's AX half); reverse-gen may act on the drop-the-marker signals on
  regeneration.
- The OCR-class reds stay red by design until a regeneration folds the corrected
  gates/channels in (the standing stays-red-until-regen precedent); they are recorded
  findings, not acceptance blockers.
