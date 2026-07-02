# UI Controls Gallery — Observable State

> **Porting guide.** What an implementation of UI Controls Gallery must make *observable* to the
> AppSpec runner's VM-side verbs (OCR, accessibility, process, input). Derived from spec §11
> (observable outcomes & accessibility) and §13 (behavioural exemplar); template:
> [../../hello-window/docs/observable-state.md](../../hello-window/docs/observable-state.md).
> Nothing here is the impl's to *log* — these are states the **VM observes** of a correctly-built
> impl; the porting obligation is "build the UI so these reads succeed." Interaction assertions
> that need value/state reads ride the **logging contract's `[controls]` events** instead
> (`expect-ax` matches role + exact title only); the assertion map below shows which channel each
> §13 line takes.

## Process

| Observable | Verb | Notes |
|---|---|---|
| The app process is running after launch | `expect-running-app <bundle-id>` | `com.linkuistics.ui-controls-gallery-<impl>`; the impl must build to a `.app` whose `CFBundleIdentifier` matches. |
| The app process is gone after Command-Q | `expect-running-app <bundle-id> #:running? #f` | the ⌘Q chord must reach `-[NSApplication terminate:]` via the app menu (spec §8) and end the process. |

## On-screen (OCR)

| Observable | Verb | Notes |
|---|---|---|
| The window title contains `Controls` | `expect-ocr "Controls"` | title-bar text. Realized titles vary (`UI Controls Gallery`, sbcl's `AppKit Controls - SBCL`) — only the §4 substring is asserted. `Controls Gallery` is **not** an OCR assertion (that substring belongs to the launch *log* line, §3.6). |
| `Click Me`, `Option A`, `Option B` are readable | `wait-for-ocr "Click Me"`, `expect-ocr "Option A"` / `"Option B"` | invariant §6 titles; `wait-for-ocr` on the first doubles as the render-settled probe. |
| A checkbox title beginning `Enable` is readable | `expect-ocr "Enable"` | realized `Enable Feature` / `Enable feature` — assert the substring only (§6 capitalization hole). |
| Placeholders `Type here` and `Password` while the fields are empty | `expect-ocr "Type here"`, `expect-ocr "Password"` | *(to confirm in-VM: greyed placeholder text may or may not OCR reliably — §13 flags it)*. |
| Typed `abc` appears in the text field | `click-at` the field, `type "abc"`, `expect-ocr "abc"` | the §13 text-entry assertion; input verbs + OCR, no logging involved. |

## Accessibility (AX tree)

`expect-ax` / `expect-no-ax` walk `gv-ax-snapshot` matching `AXRole` (+ optional **exact**
`AXTitle`). Expected roles for the §6 roster — the *uncertain* rows are confirmed/corrected during
the live-run stage before the suite hard-asserts them (snapshot coverage itself is to-confirm:
hello-window found `gv-ax-snapshot` gaps, e.g. missing `AXMenuItemCmdChar`):

| Control | Expected role | Title match usable? | Confidence |
|---|---|---|---|
| window | `AXWindow` | no (titles impl-varying) | firm |
| section headers / labels | `AXStaticText` | no (section map impl-varying) | firm |
| push button | `AXButton` | `"Click Me"` (invariant §6) | firm; AXTitle≡button-title to confirm |
| checkbox | `AXCheckBox` | no (only *begins* `Enable`; exact-match unusable) | firm |
| radio buttons | `AXRadioButton` | `"Option A"` / `"Option B"` (invariant §6) | firm; AXTitle≡button-title to confirm |
| text field | `AXTextField` | no | firm |
| secure text field | `AXTextField` (subrole `AXSecureTextField`) | no | subrole not matchable → indistinguishable from the plain field via `expect-ax` |
| slider | `AXSlider` | no | firm |
| pop-up button | `AXPopUpButton` | no | firm |
| combo box | `AXComboBox` | no | firm |
| date picker | `AXDateField` (or a composite group per element) | no | **to confirm in-VM** |
| progress bar | `AXProgressIndicator` | no | firm |
| spinner | `AXBusyIndicator` (spinning style) or `AXProgressIndicator` | no | **to confirm in-VM** |
| stepper | `AXIncrementor` | no | firm |
| color well | `AXColorWell` | no | firm |
| image view | `AXImage` | no | firm |

## §13 assertion → observation path (the coverage-or-gap map)

Per the forward-gen coverage-or-gap rule (`AppSpec/capabilities/forward-gen/validation.md` L1b):
every §13 line is served by a verb-backed path *or* carries a documented gap.

| §13 assertion | Observation path |
|---|---|
| process running after launch | process: `expect-running-app` |
| launch diagnostic emitted | events.log: `wait-for-log "Controls Gallery"` |
| window title names the gallery | OCR `"Controls"` |
| roster texts visible | OCR (table above) |
| placeholders visible | OCR *(to confirm in-VM)* |
| radio exclusivity | `click-at` Option B → events.log `radio-selected option="Option B"`; the deselected-A half is a **gap** (needs an AX state read) — covered by the event's sole-selection semantics |
| checkbox toggles | `click-at` ×2 → events.log two `checkbox-changed` events with opposite `state` (initial state is a §6 hole — assert the flip, not a sequence) |
| text field accepts input | `click-at` + `type` + OCR `"abc"` |
| secure field does not echo | **gap** — needs an AX value read (assert ≠ cleartext) or a negative-OCR verb; until then the secure field is covered only by role existence + placeholder OCR |
| slider present within range | AX `AXSlider` exists + events.log `slider-changed` values in [0, 100] |
| slider clamps | `click-at` track ends → events.log `value=0` / `value=100` as the last event |
| stepper clamps | `click-at` arrows repeatedly → events.log `value=10` (top) / `value=0` (bottom) as the last event |
| popup offers exactly three choices | **gap** — needs an AX children-count read; item texts are impl-varying so OCR cannot count |
| progress bar preset ≈ two-thirds | **gap** — needs an AX value read; the visual fill is checked in the live-run stage and recorded in `run-results.md` |
| gallery structural elements exist | AX roles (table above) for combo box, date picker, spinner, color well, image |
| Quit terminates the app | `chord cmd q` → process gone + events.log `shutdown reason=menu` |
| close-button behaviour | recording scenario: `click-at` close button + `expect-running-app` — recorded, not asserted (spec §3.8 expects keep-running; a contradiction is a spec-quality finding, not a suite bug) |

## Deferred / gap observables (not acceptance preconditions)

Reported as gaps rather than hard-asserted before the verb exists (the forward-gen "mutant-D"
discipline; same section shape as hello-window):

- **AX state/value reads** — radio/checkbox states, slider/stepper/progress values → need an
  `expect-ax #:value`-family verb. The *interaction* half is covered by the `[controls]` events;
  the *external verification* half (e.g. Option A visibly deselected, progress ≈ 65) is deferred.
- **Popup/combo item counts** → need an AX children-count read.
- **Secure-field non-echo** → needs an AX value read or a negative-OCR verb.
- **Window size/position and the ⌘Q key-equivalent** → the same `expect-ax #:size/#:position/#:key`
  gap set hello-window recorded.
- **Graphical states** — spinner animating, progress fill, color-well blue, system image content —
  have no OCR/AX read; confirmed visually during the live-run stage and recorded in
  `run-results.md` (sample apps must be visually perfect — the human eye still checks the window).

## Build obligation summary (per impl)

A conformant build must, beyond the [logging contract](logging-contract.md): render the single
centred titled window (title containing `Controls`) presenting all fourteen §6 controls grouped
under bold static-text section headers; expose the standard AX roles above (native controls, no
custom drawing that would break them); keep the §6 invariant texts (`Click Me`, `Option A`/`B`,
`Enable…`, `Type here...`, `Password`) render-visible for OCR; and wire the app-menu **Quit** item
(⌘Q → `terminate:`). The four existing impls already build all of this — the delta each needs is
the logging instrumentation.
