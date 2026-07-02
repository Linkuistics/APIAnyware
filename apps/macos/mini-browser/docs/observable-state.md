# Mini Browser — Observable State

> **Porting guide.** What an implementation of Mini Browser must make *observable* to the AppSpec
> runner's VM-side verbs (OCR, accessibility, process, input). Derived from spec §11 (observable
> outcomes & accessibility) and §13 (behavioural exemplar); templates:
> [../../hello-window/docs/observable-state.md](../../hello-window/docs/observable-state.md),
> [../../ui-controls-gallery/docs/observable-state.md](../../ui-controls-gallery/docs/observable-state.md),
> [../../pdfkit-viewer/docs/observable-state.md](../../pdfkit-viewer/docs/observable-state.md),
> [../../scenekit-viewer/docs/observable-state.md](../../scenekit-viewer/docs/observable-state.md).
> Nothing here is the impl's to *log* — these are states the **VM observes** of a correctly-built
> impl; the porting obligation is "build the UI so these reads succeed." Assertions that need
> state the verbs cannot read — navigation completion/failure and the ◀/▶ **enabled flags** —
> ride the **logging contract's `[nav]` events** instead
> ([logging-contract.md](logging-contract.md)); the assertion map below shows which channel each
> §13 line takes.

## Process

| Observable | Verb | Notes |
|---|---|---|
| The app process is running after launch | `expect-running-app <bundle-id>` | `com.linkuistics.mini-browser-<impl>`; the impl must build to a `.app` whose `CFBundleIdentifier` matches. |
| The app process is gone after Command-Q | `expect-running-app <bundle-id> #:running? #f` | the ⌘Q chord must reach `-[NSApplication terminate:]` via the app menu (spec §8) and end the process — **dismiss the offline launch alert first** (a modal alert swallows the chord). |

## The no-network reality & the fixture story (this app's defining constraint)

The verification VM has **no network**, and every impl's home URL is a live `https` URL (spec
§6.1; realized today: racket/chez `https://www.apple.com`, gerbil/sbcl `https://example.com` —
per-impl values bind via run-values, never the suite). Two consequences structure everything
below:

- **The launch-time observable is the failure path.** The initial load (spec §3 step 5) fails
  shortly after launch: `[nav] started` → `[nav] failed` → the §7.3 **modal warning alert**.
  Offline scenarios wait on the `failed` event (the pre-dismissal cue — see the logging
  contract), dismiss with Return, then assert the `failed: ` status line. Every subsequent
  offline interaction must assume this alert has been (or must first be) dismissed.
- **The offline success path is `file://`-gated.** The §6.2 rule passes `file:` URLs through
  unchanged, but whether `loadRequest:` renders `file://` content is the spec's open unknown
  (§6.2/§13) — **seeded to instrument-builds** (probe on the host after the rebuild, firm in-VM
  at live-run). If it renders, the success chrome (`Done`, canonicalization, history, reload,
  title tracking) runs offline against the **fixture pages**; if not, those assertions stay
  network-gated (a documented gap, not a suite bug) and the suite covers the
  network-independent surface only.

**The fixture rule** (the pdfkit-viewer precedent — fixtures live with the App, never in the
AppSpec toolkit): **two local HTML pages** at `apps/macos/mini-browser/fixtures/`
(`page-one.html`, `page-two.html`), uploaded to `/tmp/mini-browser/fixtures/` before the runs
and bound as `file://` run-values. Two pages make both history directions and the
at-head/at-tail boundaries reachable. Each page carries a **distinct `<title>`** (`Fixture Page
One` / `Fixture Page Two` — making the composite window title deterministic and AX-exact-
matchable) and a **large ALL-CAPS body marker** (`FIXTURE ONE` / `FIXTURE TWO` — dark-on-light,
large sans-serif; the OCR small-text lessons from the gallery/pdfkit/scenekit runs). Navigation
is driven through the address field itself — triple-click (select-all; Cmd-A is unreliable over
the VM input path, spec §13), type the `file://` URL, Return — **no out-of-process panel**
(simpler than pdfkit's Cmd-Shift-G dance). Whether the rendered page text is OCR-readable and
what the `WKWebView` exposes to AX are themselves to-confirm (below); **no assertion depends on
page content** beyond the fixture's own marker witnessing that rendering happened.

## On-screen (OCR)

| Observable | Verb | Notes |
|---|---|---|
| The window title `Mini Browser` is readable | `expect-ocr "Mini Browser"` | title-bar text — **invariant across impls at launch** (spec §4). The launch *log* line also begins `Mini Browser` — distinct channels. Title-bar OCR garble is a known run-mechanism residual (pdfkit k103, racket) — adjudicate by artifact review. |
| `Ready` while nothing has loaded | `wait-for-ocr "Ready"` | the §5.3 startup status; doubles as the render-settled probe. **11-pt small text** — the OCR small-text class risk; the AX value→AXTitle fold (firmed by pdfkit) is the firm channel for all deterministic status strings. |
| `Reload` and `Go` button titles readable | `expect-ocr "Reload"`, `expect-ocr "Go"` | toolbar presence; ◀/▶ glyphs ride AX, not OCR (the pdfkit rule). |
| The address field shows an `https://` string at launch | `wait-for-ocr "https://"` | the §6.1 prefill. **OCR is the only read** — the field's AX value reads back empty under the driver (spec §11 caveat). |
| The failure status after dismissing the alert | `wait-for-ocr "failed:"` | stable §7.3 substring (phase word and message are impl/platform-realized). |
| `Enter a URL to navigate` / `Invalid URL` on the §6.2 boundaries | `wait-for-ocr` | deterministic strings — AX-exact via the fold is the firm channel, OCR the fallback. |
| Alert chrome while the modal is up | `wait-for-ocr` an alert affordance | platform-formatted from the NSError — text **to confirm in-VM**; the `[nav] failed` event is the reliable cue, OCR only corroborates. |
| The fixture's body marker after a `file://` load | `expect-ocr "FIXTURE ONE"` | witnesses rendering happened *(file://-gated; WKWebView-rendered text OCR-readability itself to confirm in-VM)*. |
| Composite window title after a titled load | `expect-ocr "Fixture Page Two"` | §7.2 title tracking — assert on a *second* navigation (first-load title lag); the ` — ` separator may not OCR cleanly, match the title fragment. |

## Accessibility (AX tree)

`expect-ax` / `expect-no-ax` walk `gv-ax-snapshot` matching `AXRole` (+ optional **exact**
`AXTitle`). The SDK transform folds each element's `label` → `value` → `description` (first
non-empty) into `AXTitle`, so a static text's *value* is its matchable title (firmed by the
pdfkit run). Expected roles — the *uncertain* rows are confirmed/corrected during the live-run
stage before the suite hard-asserts them (the gallery/pdfkit/scenekit precedent):

| Element | Expected role | Title match usable? | Confidence |
|---|---|---|---|
| window | `AXWindow` | `"Mini Browser"` at launch (invariant §4); `"Fixture Page Two — Mini Browser"` after a titled fixture load (real U+2014) | firm at launch; composite **to confirm in-VM** (first-load lag — assert on a second navigation) |
| back button | `AXButton` | `"◀"` (U+25C0) | firm — pdfkit k103 firmed glyph-as-AXTitle for these exact glyphs |
| forward button | `AXButton` | `"▶"` (U+25B6) | firm |
| Reload button | `AXButton` | `"Reload"` | firm |
| Go button | `AXButton` | `"Go"` | firm |
| address field | `AXTextField` | **no** — its AX value read back *empty* under the driver (spec §11), so the fold yields no usable AXTitle; presence rides the role, content rides OCR | firm role (gallery-confirmed) |
| status line | `AXStaticText` | `"Ready"` / `"Done"` / `"Enter a URL to navigate"` / `"Invalid URL: <typed text>"` — exact deterministic strings via the value→AXTitle fold | firm (pdfkit firmed the fold); the `failed:` form is platform-suffixed → OCR substring instead |
| web view | `AXWebArea` (?) — possibly wrapped in `AXScrollArea`/`AXGroup`; children = the page's DOM exposure, depth unknown | no | **uncertain — provisional row** (the k96 pattern): confirm what a WKWebView exposes during live-run; no assertion depends on it |
| failure alert | `AXWindow` (?) — a modal alert panel; platform-composed text | no | uncertain — to confirm in-VM; the `[nav] failed` event is the operative signal |
| Quit menu item | `AXMenuItem` | `"Quit Mini Browser"` | as the prior apps; the ⌘Q key-equivalent itself is the standing `#:key` gap |

**The ◀/▶ enabled flags — the spec's reliable history observable (§11/§13) — are still not
readable by a suite verb**: re-verified against AppSpec HEAD for this contract —
`testanyware-sdk/agent.rkt` `element->ax-node` drops the snapshot's per-element `enabled` field
and `expect-ax` has no `#:enabled?` (the pdfkit k96 seed remains open on the AppSpec backlog).
The raw `agent snapshot --mode layout` **does** carry the flags (pdfkit verified them manually at
every boundary) — usable for live-run *adjudication*, not suite assertions. The operative suite
channel is the **`[nav] finished` events' `can-go-back`/`can-go-forward` keys** — read in the
same §7.2 refresh that sets the flags, so log value and AX flag are one fact on two channels.

## §13 assertion → observation path (the coverage-or-gap map)

Per the forward-gen coverage-or-gap rule (`AppSpec/capabilities/forward-gen/validation.md` L1b):
every §13 line is served by a verb-backed path *or* carries a documented gap.

**Network-independent (runnable in the no-network VM):**

| §13 assertion | Observation path |
|---|---|
| process running after launch | process: `expect-running-app` |
| launch diagnostic emitted | events.log: `wait-for-log "Mini Browser"` |
| window title at launch | AX `AXWindow` exact `"Mini Browser"` + OCR |
| toolbar present | AX `AXButton` ×4 (`◀` `▶` `Reload` `Go`) + OCR `"Reload"`/`"Go"` |
| history starts empty (◀/▶ disabled) | flags are a **gap** (enabled read); behavioural half: `click-at` ◀/▶ positions → status unchanged, no `[nav]` event expected (absence not asserted) — the pdfkit empty-state shape; raw-snapshot flags checked at live-run adjudication |
| address field prefilled | `wait-for-ocr "https://"` (OCR only — AX value empty) |
| offline initial load fails loudly | events.log `wait-for-log "[nav] started"` → `"[nav] failed"` (the dismissal cue) → `press "Return"` → `wait-for-ocr "failed:"` *(which phase fires offline, and the alert's platform text — to confirm in-VM)* |
| blank input navigates nowhere | triple-`click-at` field, `press "Delete"`, `press "Return"` → AX `AXStaticText` exact `"Enter a URL to navigate"` (+ OCR); no `[nav]` event (absence not asserted) |
| unparseable URL reported, not loaded | `type` text with spaces, `press "Return"` → AX/OCR `"Invalid URL"` *(which strings NSURL rejects — to confirm in-VM)* |
| input is a URL, never a search | `type "not-a-url"`, `press "Return"` → events.log `started url="https://not-a-url…"` (**the prepend rule, witnessed offline in the log**) → the failure sequence |
| Quit terminates the app | dismiss any alert → `chord cmd q` → process gone + events.log `shutdown reason=menu` |
| close-button behaviour | recording scenario: `click-at` close button + `expect-running-app` — recorded, not asserted (spec §3 expects keep-running but flags it to-confirm; a contradiction is a spec-quality finding, not a suite bug) |

**Success path (`file://`-gated — runs offline against the fixtures if `loadRequest:` renders
`file://`; otherwise network-gated and unrunnable in-VM, each line then a documented gap):**

| §13 assertion | Observation path |
|---|---|
| load reaches `Done` | fixture navigation → events.log `started` + `finished` → AX `AXStaticText` exact `"Done"` (+ OCR) |
| address bar canonicalizes | events.log `finished url="file:///tmp/mini-browser/fixtures/page-one.html"` (exact); the field's *display* via OCR (AX value empty) |
| the page renders | OCR the fixture's `FIXTURE ONE` marker *(to confirm in-VM)* |
| typed URL + Return navigates | the fixture open flow itself (triple-click, type, Return) |
| Go ≡ Return | drive the *second* fixture page via `click-at` Go → `finished url="…page-two.html"` |
| bare host gets `https://` prepended (display half) | **network-gated** — a schemeless input can never *succeed* offline, and §7.2 writes the address back only on finish; the rule's log half is covered offline (`started url=`, above) |
| history enables after a second load | events.log `finished … can-go-back=true can-go-forward=false` (the enabled-flag gap's operative channel) |
| back walks history | `click-at` ◀ → `finished url="…page-one.html" … can-go-forward=true` + title reverts |
| forward walks history | `click-at` ▶ → `finished url="…page-two.html" … can-go-forward=false` |
| reload re-navigates | `click-at` Reload → a fresh `started` + `finished` with the same `url` |
| window title tracks titled pages | events.log `finished … title="Fixture Page Two"` + AX `AXWindow` exact `"Fixture Page Two — Mini Browser"` — assert on the *second* navigation (first-load title lag, §7.2) |

Driver guidance the suite must honour (spec §13 + the prior runs): triple-click the address
field to select-all before typing; click at AX-reported coordinates, never screenshot pixels;
dismiss the launch alert before driving anything else; after a modal alert has had key, the
first click on the app window may only re-activate it (`acceptsFirstMouse` is
control-dependent — the scenekit k112 finding).

## Deferred / gap observables (not acceptance preconditions)

Reported as gaps rather than hard-asserted before the verb exists (the forward-gen "mutant-D"
discipline; same section shape as the prior apps):

- **`file://` renderability — this app's headline unknown.** Gates the whole success-path group
  above. Seeded to **instrument-builds** (host-side probe after each rebuild) and firmed at
  live-run; if `loadRequest:` does not render `file://`, the success path stays network-gated
  and its assertions are reported as gaps (the impls are *not* changed to `loadFileURL:` — that
  would change behaviour the spec doesn't state).
- **AX enabled-flag read — still the pdfkit k96 runner-side gap** (re-verified, see the AX
  section): `expect-ax #:enabled?` remains the AppSpec-backlog closer; until then the `[nav]
  finished` booleans + raw-snapshot adjudication are the channels.
- **WKWebView AX exposure** — unknown (provisional row); whether the fixture DOM surfaces as an
  `AXWebArea` subtree with readable children is a spec-quality finding to record at live-run.
  No assertion depends on it.
- **Rendered-page OCR** — whether WKWebView-rendered text OCRs reliably; the fixture markers are
  sized/weighted to maximize the odds (the k103 small-text class).
- **`started url=` fidelity** on provisional starts (nil windows, back/forward targets) — bind
  values only for scenario-driven loads; record actuals at live-run.
- **Alert AX shape + platform text** — the `[nav] failed` event is the cue either way.
- **Window size/position (800×600 centred, min 500×400) and the ⌘Q key-equivalent** → the same
  `expect-ax #:size/#:position/#:key` gap set the prior apps recorded. Resize behaviour (§4/§5
  autoresizing) additionally lacks a window-resize gesture verb — spec prose without a runnable
  assertion.
- **Graphical states** — page rendering beyond the fixture marker, native control appearance —
  confirmed visually during the live-run stage and recorded in `run-results.md` (sample apps
  must be visually perfect — the human eye still checks the window).

## Build obligation summary (per impl)

A conformant build must, beyond the [logging contract](logging-contract.md): render the single
centred resizable 800 × 600 window (min 500 × 400) titled `Mini Browser` (dynamic per §7.2); a
top toolbar strip (baseline-aligned horizontal stack) reading `◀` `▶` `Reload` `[address field]`
`Go` with ◀/▶ initially disabled and the address field prefilled with the impl's home URL; a
`WKWebView` filling the middle; the 11-pt static status line at the bottom starting `Ready`; the
§6.2 text-navigation rule on Go and field-Return; the §7 navigation delegate as the **single**
chrome write-path (buttons, title, address, status — refreshed only in `didFinishNavigation`);
the §7.3 modal `alertWithError:` failure surface; standard AX roles for the native controls; and
the app-menu **Quit** item (⌘Q → `terminate:`). The four existing impls already build all of
this — the delta each needs is the logging instrumentation.
