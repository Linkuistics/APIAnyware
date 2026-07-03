# Swift-Native Probe — live-VM run results

Durable record of the Tier-2 live run (`forward-gen-live-run-k147`, 2026-07-04): the
forward-generated `#lang app-spec` suite (`scenarios/`, 3 scenarios) replayed against the
four built impls in a macOS VM via TestAnyware, per the AppSpec run capability
(`~/Development/AppSpec/capabilities/run/workflow.md`). Data home is here (ADR-0052/ADR-0013);
the toolkit-side record is AppSpec's workflow/validation docs. **Eighth and last app through
the toolkit** — a **static coverage-proof window** (spec §5): no coordinate-driven controls,
strokes, panels, or fixtures, so the coverage proof lives in the **log** (`[probe] complete …
all-ok=#t`), the window carries only structural assertions, and the suite is the **smallest in
the portfolio**.

> **Final outcome: 3/3 ×4, no standing red.** The **second app in the portfolio** (after
> drawing-canvas k140) to chase the literal all-green rather than leave an adjudicated
> recording/OCR red — via **two honest, run-forced changes** (a forward-gen suite refinement and
> a genuine impl-defect fix on two targets), each below. The coverage proof (`all-ok=#t`, the
> app's whole purpose) and the mandated Command-Q invariant held on all four throughout.

## Run environment

- **Date:** 2026-07-04.
- **VM:** `testanyware vm start --platform macos` (golden `testanyware-golden-macos-tahoe`),
  framebuffer **1920×1080** (non-HiDPI), fresh clone. Tahoe `EnableStandardClickToShowDesktop`
  disabled; `/tmp/swift-native-probe/` created. **No fixtures, no cleanup obligation** (the probe
  has no persistence — spec §2).
- **Bundles:** the four `instrument-builds-k142` `.app`s, **self-contained** (racket 67M raco
  distribute, chez 4.9M, gerbil 56M gxc-exe, sbcl 91M save-lisp-and-die) — zero VM runtime
  provisioning (no Racket/Chez/Gerbil/SBCL in the guest). Each headless-smoked green
  (`AW_PROBE_SMOKE`) on the full k141 contract before upload; installed to
  `/Applications/SwiftNativeProbe-<impl>.app`, `xattr -dr com.apple.quarantine`. **gerbil + sbcl
  were rebuilt in-grove** for the menu-title fix (below); racket + chez reused unrebuilt (source
  unchanged).
- **Runner:** `racket ~/Development/AppSpec/runner/main.rkt --impl <descriptor> --run-values
  <config> --vm <id> run <scenarios-dir>` at AppSpec **`cb178f8`** (the drawing-canvas k140 base —
  `#:scope 'app-content`). Per-impl **full-suite single invocation**; racket run **solo** (its
  self-contained bundle boots a full embedded runtime → slower per-scenario relaunch, so the
  4-impl sweep exceeded a single harness time box — a harness convenience, not a runner limit).
- **Run-values:** measured live (see *Geometry*) — `run-values.rkt` (racket + chez + gerbil, the
  560×240 window) and `run-values-sbcl.rkt` (sbcl, the 640×300 window). **No toolkit fix was
  forced** (unlike the seven richer apps): the static window needs no new driver behaviour.

## Outcomes (final suite, after the two run-forced changes)

| scenario | racket | chez | gerbil | sbcl |
|---|---|---|---|---|
| 01 steady-state / all-probes-pass (hard) | PASS | PASS | PASS² | PASS² |
| 02 Command-Q terminates (hard, mandated) | PASS | PASS | PASS | PASS |
| 03 close-button keeps running `recording:` | PASS (confirms) | PASS (confirms) | PASS (confirms) | PASS (confirms) |

**Tallies: racket 3/3, chez 3/3, gerbil 3/3, sbcl 3/3 — 12/12, no impl defect standing.**
The coverage proof (`[probe] complete … all-ok=#t` — count=2 racket/chez/gerbil, count=5 sbcl)
and the byte-identical launch line held on all four; the mandated Command-Q invariant (02) and
the `recording:` close-button expectation (03) green on all four.

² gerbil + sbcl were **red at first pass on 01** (2/3 each) on the app-menu Quit-item title —
a genuine two-target impl defect, **fixed in-grove** (Adjudication §2); racket + chez green
first-pass.

## Adjudication

### 1. Forward-gen suite refinement — the heading OCR (k103 small-text class)

**chez first-pass 01 red:** `expect-ocr "Swift-native APIs"` — whole-screen OCR read the heading
as **"Swift-native APls via libAPIAnywareChez trampolines"**: the small-font capital **I** in
"APIs" garbles to lowercase **l** (the **k103 OCR small-text class** — scenekit `SceneKit→Scenekit`,
mini-browser `request→reguest`, pdfkit/note-editor precedents). The heading **renders correctly**
— the AXStaticText `value` is exactly `Swift-native APIs via libAPIAnyware<T> trampolines`, and
the screenshot is crisp. Not an impl defect; a run-mechanism read limit.

**Resolution — a sanctioned forward-gen refinement (not a hide):** the heading fact has **no
projection-free AX channel** (`expect-ax #:title` is exact-only, and the full heading carries the
per-impl library name), so whole-screen OCR is the only projection-free channel — and it must use
an OCR-**reliable** substring. The node brief pre-sanctioned matching the stable tail
**`trampolines`** (all-lower, longer, no capital-I ambiguity). Swapped `"Swift-native APIs"` →
`"trampolines"` in scenario 01; it identifies the Swift-native surface (heading + footer both name
the `@_cdecl trampolines`) and reads reliably on **all four impls incl. racket's compact 22px
metrics**. The scenekit "prefer the reliable read for the same fact" rule; **not** patching to hide
(the fact is real and proven via AX + screenshot). The window title `Swift-Native API Coverage`
(exact) reads perfectly under OCR **and** `expect-ax #:role 'AXWindow #:title` — the projection-free
title assertion this app uniquely affords (hello-window could not, its title being per-impl).

### 2. Impl defect (gerbil + sbcl) — the app-menu Quit title, FIXED in-grove

**gerbil + sbcl first-pass 01 red:** `expect-ax #:role 'AXMenuItem #:title "Quit Swift-Native
Probe"` — **not found**. Both impls' app-menu Quit item read **"Quit Swift Native Probe"** (no
hyphen), while every other name was correct (window `appName`, launch line, heading, and the
Apple-menu Force-Quit all hyphenated). Root cause: a hardcoded-string typo in each source —
`targets/gerbil/…/swift-native-probe.ss:226` `(install-standard-app-menu! app "Swift Native
Probe")` and `targets/sbcl/…/swift-native-probe.lisp:163` `(install-app-menu app "Swift Native
Probe")` — a **space where the display name has a hyphen**. racket (`swift-native-probe.rkt:104`)
and chez (`swift-native-probe.sls:207`) correctly pass `"Swift-Native Probe"`, which is why they
passed 01 first-pass.

This is a genuine (if one-character) **impl-quality bug**, not a legitimate per-impl realization
(the display name is `Swift-Native Probe`, hyphenated, everywhere else). The k142 outcome had
flagged the menu-bar divergence and suggested a suite-side accommodation (fold the per-impl title
in), but once identified as a hardcoded typo the honest adjudication is to **correct the source**,
not bless the wrong title — [[sample_apps_perfect]] (menu titles matter) + the drawing-canvas k140
"chase all-green with a clean fix rather than leave an adjudicated red" precedent. Fixed both
(space → hyphen), **rebuilt** (gerbil `gxc -exe` 56M, sbcl `save-lisp-and-die` 91M — each `build.sh`
self-healed the gcc-15 shim + the persistent CreateML corpus bring-in), re-installed, **re-verified
3/3 each**. The mandated Command-Q invariant itself always held (scenario 02 green **pre-fix** on
both) — the fix only reconciles the Quit item's displayed *title* with the display name.

**Signal for reverse-gen/`portfolio-coverage-tie-in-k85`:** the `swift-native-method-probe` sibling
(no `apps/macos/` dir yet) likely carries the same hardcoded-menu-name pattern; check it when its
own-spec question is settled.

### 3. Recording scenario 03 — close-button keeps running, confirmed ×4

`click-at <close-button>` → `(wait 2)` → `expect-running-app` **true** on all four impls: closing
the window hides it, the `gui-app` **keeps running** (spec §3.9, no close-to-quit opt-in). The
**eighth app** to confirm the portfolio's §3 no-close-to-quit expectation. A pass **confirms** and
**signals reverse-gen may drop the `(to confirm in-VM)` marker** (a downstream spec edit / reviewed
golden re-bless — **not** an adjudication side effect; no spec edited here). Closing emitted **no**
`shutdown` line (as the logging contract expects). The mandated invariant (02) is the separate
proof that the *menu* Quit path terminates.

## Geometry — measured live (per-impl practice)

Measured from `agent snapshot --mode layout`; two-launch determinism green on every impl (the
fixed-size static-label window has no ambiguous-layout defect). The close button is title-bar
chrome positioned by the window **origin** (a centred window → origin follows window **size**), so
it splits by size, **not** by the 22px/26px content-metric divergence:

- **chez + gerbil pixel-identical:** window (680,205) **560×272**, close AXButton (688,213) 16×16 →
  centre **(696,221)**. Share `run-values.rkt`.
- **racket:** compact 22px metrics → window (680,206) **560×268**, 12px traffic-lights, own close
  centre **(694,220)** — but the shared (696,221) lands comfortably **inside** racket's close button
  (694±6 ⇒ x∈[688,700], y∈[214,226]), so racket **shares** `run-values.rkt` (measured, not assumed —
  the drawing-canvas "lands inside, so it shares" pattern). racket 03 clicked (696,221) → PASS.
- **sbcl:** window (640,190) **640×332** (the 5-shape probe), close AXButton (648,198) → centre
  **(656,206)**. Own `run-values-sbcl.rkt`.

The provisional forward-gen hints (human hints behind the `run-value` accessors) were close on x
(exact for the 560 window) and ~12–27px high on y ([NSWindow center] biases the window above true
centre more than the model assumed) — refined to the measured values.

## The coverage-proof channel — firmed ×4

- **`[probe] complete … all-ok=#t` is the single target-agnostic coverage assertion** and held on
  all four: `count=2 ok=2` (racket/chez/gerbil, CreateML `timestampSeed`+`MLCreateErrorDomain`) and
  `count=5 ok=5` (sbcl, CoreGraphics.hypot / NSNotFound / NSNumber.integerLiteral /
  Scanner.scanUpToString / IndexSet round-trip). `wait-for-log` searches the whole scenario buffer,
  so the summary (emitted **before** the launch line, contract §emission-order) matches regardless
  of the two waits' order.
- **The launch line `Swift-Native Probe opened.` is byte-identical in events.log across all four**
  (sbcl's differing *stdout* echo is discarded under `open`). `[lifecycle] startup` is the runner's
  `wait-ready` readiness probe (setup, not a suite verb — the hello-window division of labor).
- **The window is a genuine coverage-proof surface (visual bar met, [[sample_apps_perfect]]):** the
  chez screenshot shows title `Swift-Native API Coverage`, heading `Swift-native APIs via
  libAPIAnywareChez trampolines`, two live blue `name → value` rows (`→ 1783094740426`,
  `→ com.apple.CreateML`), the `objc_exposed:false` / `@_cdecl trampolines` footer, and traffic-lights
  with **no resize affordance** (fixed-size window). The AXStaticText title-bar chrome (text == the
  window's AXTitle) confirmed the k140 finding — scenario 01's `expect-no-ax #:role 'AXTextField
  #:scope 'app-content` correctly avoids it (and the labels are AXStaticText, never AXTextField).

## The run-forced changes, homed per ADR-0052/0013

- **Suite refinement** (heading OCR → `trampolines`): app data → committed **here** (`scenarios/`).
- **Impl fix** (gerbil `.ss:226` + sbcl `.lisp:163` menu title): target source → committed
  **downstream** in this grove (the impls are this repo's app-implementations, not toolkit code).
- **No AppSpec toolkit change was forced** — the static window needed no new driver behaviour, so
  unlike the seven richer apps there is **no** `AppSpec`-side commit for this run.

## Promoted swift-native-probe outcomes (for `portfolio-coverage-tie-in-k85`)

- **Final: 3/3 ×4, genuine all-green, no standing red** — the smallest suite in the portfolio (a
  static coverage-proof window; the log carries the proof). Second app (after drawing-canvas) to
  chase literal all-green.
- **The log is the coverage channel, not the window.** `[probe] complete … all-ok=#t` (count 2 vs 5
  per target) is the single target-agnostic assertion; the launch line is byte-identical ×4; the
  exact window title `Swift-Native API Coverage` is the one projection-free window fact (assertable
  via **both** OCR-exact and `expect-ax #:role 'AXWindow #:title`).
- **Heading OCR needs the reliable substring `trampolines`, never `Swift-native APIs`** (k103:
  small-font capital-I → "APls"); the heading has no projection-free AX channel, so OCR-reliable
  substring is the projection-free channel of record.
- **Two targets shipped a hardcoded app-menu name typo** ("Swift Native Probe", no hyphen) at
  gerbil `.ss:226` / sbcl `.lisp:163`; racket/chez were correct. Fixed + rebuilt in-grove; **check
  `swift-native-method-probe` for the same pattern** (k85). The Command-Q invariant is independent
  of the menu *title* and always held.
- **Geometry:** chez+gerbil pixel-identical (560×272, close (696,221)); racket 560×268 shares that
  coordinate (lands in-button); sbcl 640×332 owns (656,206). Close button splits by window **size**
  (title-bar chrome), not content metrics — a different split axis than the content-driven suites.
- **Self-contained ×4, zero VM runtime provisioning** (raco distribute / whole-program / gxc-exe /
  save-lisp-and-die); the exec-channel-stall / delayed-truncate residuals did not bite this
  3-scenario suite (per-impl single invocation, racket solo).
