# UI Controls Gallery — live-VM run results

Durable record of the Tier-2 live run (`live-run-k94`, 2026-07-02): the forward-generated
`#lang app-spec` suite (`scenarios/`, 11 scenarios, leaf k93) replayed against the four built
impls in a macOS VM via TestAnyware, per the AppSpec run capability
(`AppSpec/capabilities/run/workflow.md`). Data home is here (ADR-0052/ADR-0013); the
toolkit-side record is AppSpec's workflow/validation docs.

## Run environment

- **Date:** 2026-07-02.
- **VM:** `testanyware vm start --platform macos` (golden `testanyware-golden-macos-tahoe`),
  framebuffer **1920×1080** (non-HiDPI), fresh clone, zero provisioning — all four impls are
  self-contained `.app`s (hello-window k75/k76 build shapes).
- **Runner:** `racket AppSpec/runner/main.rkt --impl <descriptor> --run-values <config>
  --vm <id> run scenarios/`, one full-suite invocation per impl (the canonical path), with
  per-scenario solo re-runs to adjudicate flakes (sanctioned by run `workflow.md` §3).
- **Run-values:** measured live per impl (see *Coordinates* below) — `run-values.rkt`
  (chez + gerbil, pixel-identical layouts), `run-values-racket.rkt`, `run-values-sbcl.rkt`.

## Outcomes (final builds, final runner)

| scenario | racket | chez | gerbil | sbcl |
|---|---|---|---|---|
| 01 steady-state cluster (hard) | PASS | PASS | PASS | PASS |
| 02 placeholders `recording:` | PASS | PASS | PASS | PASS |
| 03 date/spinner roles `recording:` | **FAIL → finding** | **FAIL → finding** | **FAIL → finding** | **FAIL → finding** |
| 04 radio exclusivity `recording:` | PASS | PASS | PASS (solo)¹ | PASS |
| 05 checkbox flip `recording:` | PASS | PASS | PASS | PASS |
| 06 text-field input `recording:` | PASS | PASS | PASS | PASS |
| 07 slider clamps `recording:` | PASS | PASS | PASS | PASS |
| 08 stepper clamps `recording:` | PASS | PASS | PASS | PASS |
| 09 push-button negative (hard §12) | PASS | PASS | PASS | PASS |
| 10 Command-Q terminates (hard, mandated) | PASS | PASS | PASS | PASS |
| 11 close-button keeps running `recording:` | PASS | PASS | PASS | PASS |

¹ gerbil 04 red in the full-suite invocation with an empty log buffer (the post-artifact-capture
channel race below), green solo — graded per-scenario per workflow §3.

**Every runnable assertion is green on all four impls.** The single standing red (03) is a
`recording:` scenario whose failure is a spec-quality finding by design (ADR-0010 D4), not a
suite bug and not an acceptance blocker — adjudicated below.

## Adjudication

### 03 — role-mapping finding (CONFIRMED cross-impl, spec corrected)

`expect-ax: no AX node with role=AXDateField found` on all four impls. The AX layout snapshots
show the date picker surfaces as **`AXDateTimeArea`** (a composite area with an embedded
`AXIncrementor`) on macOS Tahoe — exactly the "may be a composite" caveat the observable-state
role table carried. The spinner half **is** `AXBusyIndicator` on all four impls (the scenario
aborts at the date assert, but the roles are confirmed from the same snapshots the failure
artifacts capture). **Actions taken:** `docs/observable-state.md` role table corrected
(date picker → `AXDateTimeArea` firm; spinner → `AXBusyIndicator` firm). The scenario stays
red-by-design until a forward-gen regeneration folds the corrected roles into the hard cluster.

### Recording passes — confirmations (signal recorded, no spec edited as a side effect)

02/04/05/06/07/08/11 passing on all four impls **confirms** their `(to confirm in-VM)`
expectations: placeholders OCR reliably (greyed text is no problem at 1920×1080), radio
exclusivity via the group's sole-selection event, the checkbox flip (order-agnostic — absorbs
sbcl's launches-ON variance), typed text OCR, both slider/stepper clamped ends, and gui-app
close-keeps-running. Reverse-gen may drop those markers when the spec is next regenerated.

## Impl defects found and fixed (the live run chasing hard reds)

Both defects were invisible to source review and CLI smoke — precisely what Tier-2 exists for:

1. **Launch presentation violated spec §4 (racket, chez, gerbil).** All three stack-layout
   impls opened a 500×600 window over a ~900px document; the non-flipped document anchors at
   its origin, so the gallery launched **scrolled to the bottom**, hiding Text Fields/Buttons/
   radios/slider (scenario 01's OCR asserts red; upper controls unclickable). Fix: window
   content height 600 → **920** (`ui-controls-gallery.{rkt,sls,ss}`) so the whole roster is
   visible — nothing scrolls. sbcl's static two-column 820×532 layout was already conformant.
   The spec §4 size example was corrected (500×600 → the realized sizes) — the old example
   size provably cannot present the roster.
2. **Nondeterministic per-launch layout (racket, chez, gerbil).** The radio row's container
   was a plain `NSView` arranged in the `NSStackView`; `addArrangedSubview` disables its
   autoresizing translation and a plain view has **no intrinsic size**, so its ambiguous
   height resolved differently per launch (observed +97px row shifts on racket), randomly
   breaking measured click coordinates. Fix: the radio container is now a **horizontal
   `NSStackView`** (intrinsic size derives from the radios). Determinism verified by
   two-launch AX diff per impl — byte-identical.

## Coordinates — measured live (per-impl geometry practice)

Unlike hello-window's shared close-button, the gallery needs 18 coordinate keys and the
layouts are impl-varying, so the measurement is per impl from `agent snapshot --mode layout`
(AX position+size → element centre, framebuffer px):

- **chez + gerbil are pixel-identical** (same generated-binding control metrics) and share
  `run-values.rkt`; **racket** (tighter 22px metrics) and **sbcl** (two-column 820×532,
  "AppKit Controls - SBCL", radios A/B only, checkbox launches ON) carry per-impl files.
- **Two-launch determinism check before binding values** is now part of the recipe — it is
  what exposed defect 2 above.
- **Slider min-end clicks must avoid the window's resize band**: the track's min end sits
  ~1px from the window's left border, and the ~5px resize-handle band swallowed the click
  (scenario 07 red with the max end green). Click the track's *effective* start instead
  (frame edge + knob half-width inset ≈ 10–12px) — still below the knob inset, clamps to 0.

## Run-mechanism defects (AppSpec-side, fixed there per the ADR-0013 boundary)

The k75 exec-channel close-stall carried into this run and two new tailer defects surfaced;
all fixed as AppSpec commits mid-run (the hello-window precedent):

- **`gv-exec/poll` deadline-guarded content polls** (AppSpec `46fec5b`): a `testanyware exec`
  session after GUI activity delivers its output but can hang its close ~30s; the runner's
  read-to-EOF turned one stalled `cat` poll into a blown `wait-for-log`/`wait-ready` window
  (every post-01 scenario of the first sbcl full-suite run failed this way). Polls now return
  once output goes quiet and reap the stalled process. This obsoletes the k75 per-scenario
  workaround — full-suite invocations run clean.
- **Per-scenario tailer epoch reset** (AppSpec `f2b8b76`): a byte-identical relaunch (constant
  launch lines + an event-less prior scenario) is invisible to the tailer's truncation
  self-heal, suppressing the whole epoch — `wait-for-log` starved on an empty buffer (racket
  04's first-sweep red). The runner now resets the tailer's seen-content epoch alongside the
  log buffer.
- **Residual (recorded, not fixed): post-artifact-capture channel pressure.** The scenario
  immediately following a failure (whose teardown does screenshot + log-tail + AX capture)
  can hit a congestion-delayed setup `truncate` that wipes events.log *after* `wait-ready`
  confirmed it — an empty-buffer red with the app provably up (gerbil 04 full-suite; racket
  04/07/08 in the pre-fix sweep showed doubled/wiped buffers from the same delayed-exec mode).
  Heals when the channel idles; solo re-run is the adjudication. Proper fix is
  TestAnyware-side (exec-channel session close under load).

## Visual check ([[sample_apps_perfect]] — states no verb can read)

Screenshots of all four impls at post-launch steady state (fresh launches, final builds):
spinner rendered, determinate progress bar showing the ~65% blue fill, colour well showing
system blue, image/SF-symbol present (sbcl's star prominent; the stack impls' `action`
template glyph small but visible), whole roster visible without scrolling, placeholders
greyed, radio A selected. sbcl's two-column gallery additionally shows its extra controls
(switch ON, segmented `Grid`, 3-star rating) — polished. No visual defects.

## Observations (recorded, no action)

- **All four impls ignore SIGTERM under `nsapplication-run`** (pkill needs -9; the runtimes'
  signal handling is frozen under the Cocoa run loop). The contract's `shutdown reason=menu`
  path (osascript quit / Cmd-Q) works everywhere; signal-path shutdown remains unexercised,
  matching k88's "signal/error paths unexercised" note.
- The racket `.app` grew to 95 MB (was 82 MB at k76) after the rebuild — same self-contained
  shape, newer binding build.
