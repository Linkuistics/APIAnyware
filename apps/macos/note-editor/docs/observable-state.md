# Note Editor — Observable State

> **Porting guide.** What an implementation of Note Editor must make *observable* to the AppSpec
> runner's VM-side verbs (OCR, accessibility, process, input, file). Derived from spec §13
> (observable outcomes & accessibility) and §15 (behavioural exemplar); templates:
> [../../hello-window/docs/observable-state.md](../../hello-window/docs/observable-state.md),
> [../../ui-controls-gallery/docs/observable-state.md](../../ui-controls-gallery/docs/observable-state.md),
> [../../pdfkit-viewer/docs/observable-state.md](../../pdfkit-viewer/docs/observable-state.md),
> [../../scenekit-viewer/docs/observable-state.md](../../scenekit-viewer/docs/observable-state.md),
> [../../mini-browser/docs/observable-state.md](../../mini-browser/docs/observable-state.md).
> Nothing here is the impl's to *log* — these are states the **VM observes** of a correctly-built
> impl; the porting obligation is "build the UI so these reads succeed." Assertions that need
> state the verbs cannot read — **save-sheet completion** (async), the failure paths' exact
> subject, the dirty *flip*, and the preview **render hand-off** — ride the **logging contract's
> `[document]`/`[preview]` events** instead ([logging-contract.md](logging-contract.md)); the
> assertion map below shows which channel each §15 line takes.

## Process

| Observable | Verb | Notes |
|---|---|---|
| The app process is running after launch | `expect-running-app <bundle-id>` | `com.linkuistics.note-editor-<impl>`; the impl must build to a `.app` whose `CFBundleIdentifier` matches. |
| The app process is gone after Command-Q | `expect-running-app <bundle-id> #:running? #f` | the ⌘Q chord must reach `-[NSApplication terminate:]` via the app menu (spec §10) and end the process — quit from **steady state only**: an open sheet or modal alert swallows the chord (the mini-browser rule). Quit-with-unsaved-edits neither asks nor saves (§3.10 — to confirm in-VM, flagged for human confirmation). |

## The state-mutating persistence reality (this app's defining constraint)

Note Editor is the portfolio's first app whose scenarios **mutate on-disk state**: saved files,
and the panels' per-app remembered directories. Three rules structure the suite:

- **Directory story.** Two guest-side directories under `/tmp/note-editor/`:
  **`fixtures/`** — read-only inputs (uploaded before the runs from
  `apps/macos/note-editor/fixtures/`, the pdfkit fixture rule: fixtures live with the App,
  never in the AppSpec toolkit); **`work/`** — the scratch directory every save scenario
  targets (created before the runs). The impls' manual runs used `~/Documents`; the suite
  standardizes on `/tmp/note-editor/` — guest-writable, consistent with every prior app's
  upload flow, and free of home-dir resolution under the VM's launch user (the hello-window
  events-path rationale).
- **Cleanup obligation.** A scenario that writes a file must remove it (or the suite's setup
  must), so re-runs and later scenarios see a fresh world; no scenario may depend on a file an
  earlier scenario left behind. The panels' **remembered-directory** state is neutralized by
  driving *both* panels via Cmd-Shift-G absolute paths (below), so no cleanup of panel defaults
  is needed.
- **Save assertions ride the file verbs.** `expect-file` (the path exists after `[document]
  saved`) and `read-file` (content equality with what the scenario typed / the fixture) are the
  ground-truth channel for persistence — on-disk bytes, not pixels.

**The fixture** (authored at the forward-gen stage): a small `.md` file whose first line is a
`# FIXTURE NOTE` heading — rendering as a large h1 in the preview, this app's OCR marker (the
mini-browser ALL-CAPS-marker rule) — followed by a handful of lines exercising §7's forms
(bold, a list item, a fenced block). `.md` passes the §8.3 extension filter; ASCII-only so the
`[preview] rendered` `chars` key is exactly bindable (`opened` + `rendered chars=<fixture
length>` is the open-fidelity witness that needs no editor OCR).

## On-screen (OCR)

| Observable | Verb | Notes |
|---|---|---|
| The window title is readable | `expect-ocr "Untitled"` / `"Note Editor"` | title-bar text; the **AX window title is the firm channel** for the full §6.1 forms (below) — title-bar OCR garble is a known run-mechanism residual (pdfkit k103). |
| Toolbar button titles readable | `expect-ocr "New"`, `"Undo"`, `"Redo"` | prefer **ellipsis-free substrings** (`Open`, `Save`) for the U+2026-bearing titles (spec §15 driver guidance); AX carries the exact forms. |
| Status line strings | `wait-for-ocr "Ready"` / `"New document"` / `"Saved"` / `"Opened"` / `"Open failed:"` / `"Save failed:"` | **11-pt small text** — the OCR small-text class; the AX value→AXTitle fold is the firm channel for every deterministic form, OCR the fallback; the `failed:` forms carry impl-realized `<detail>` → assert the stable prefixes only. |
| The placeholder in the preview | `wait-for-ocr "Start typing Markdown"` | WKWebView-rendered ~16px gray italic — **legibility to confirm in-VM** (riskier than mini-browser's 72px markers); the `[preview] rendered placeholder=true` event is the firm app-side half. |
| Rendered Markdown in the preview | `wait-for-ocr "Hello"` after typing `# Hello`; `wait-for-ocr "FIXTURE NOTE"` after opening the fixture | h1-rendered text is large — the best OCR odds in the preview; body-size paragraph/list text stays adjudicate-by-artifact (k103 class). |
| The save sheet's prefilled name | `wait-for-ocr "untitled.md"` | the §8.4 `setNameFieldStringValue:` — witnesses the sheet is up; AX shape provisional (below). |
| The confirmation alert's texts | `wait-for-ocr "Discard unsaved changes"` / `"start a new note"` | app-authored deterministic strings (§8.1) — trigger-specific message text distinguishes Open- from New-triggered alerts; alert chrome renders at system size (good OCR odds, the k80 precedent). |
| Editor content | — | the 13-pt monospaced editor source is **not** an OCR channel of record (small text); content fidelity rides `read-file` round-trips + the `rendered chars` key + the preview's rendered forms. |

## Accessibility (AX tree)

`expect-ax` / `expect-no-ax` walk `gv-ax-snapshot` matching `AXRole` (+ optional **exact**
`AXTitle`). The SDK transform folds each element's `label` → `value` → `description` (first
non-empty) into `AXTitle`, so a static text's *value* is its matchable title (firmed by the
pdfkit run). Expected roles — the *uncertain* rows are confirmed/corrected during the live-run
stage before the suite hard-asserts them (the standing precedent):

| Element | Expected role | Title match usable? | Confidence |
|---|---|---|---|
| window | `AXWindow` | **yes — the dirty/name channel of record** (§6.1, exact): `"Untitled — Note Editor"` → `"Untitled — edited — Note Editor"` → `"untitled.md — Note Editor"` etc. (real U+2014 em dashes) | firm — the k122 handoff: the close-box dot is unobservable, the title is the reliable dirty observable |
| the five toolbar buttons | `AXButton` | `"New"`, `"Open…"`, `"Save…"`, `"Undo"`, `"Redo"` (U+2026 in the AX title) | firm — pdfkit k96 firmed `Open…`-with-ellipsis as AXTitle |
| status line | `AXStaticText` | `"Ready"` / `"New document"` / `"Saved <path>"` / `"Opened <path>"` — exact deterministic strings via the value→AXTitle fold | firm (pdfkit firmed the fold); the `failed: ` forms are impl-suffixed → prefix via OCR or the `[document]` failure events instead |
| editor | `AXTextArea` (inside an `AXScrollArea`) | content via `AXValue` — **readable in raw layout snapshots** (the mini-browser k121 sharpening) but fold-fidelity under the driver **to confirm in-VM** | provisional — presence rides the role; content assertions ride `read-file`/`rendered chars` |
| preview | a WKWebView subtree — `AXScrollArea`/`AXGroup` wrapping; whether the **rendered DOM** surfaces (mini-browser only witnessed the *non-rendered* state as an empty `scroll-area`) | no | **provisional row** — this app always has rendered HTML, so live-run may finally firm WKWebView DOM exposure; no assertion depends on it |
| save sheet | a sheet attached to the window (`AXSheet`?) carrying the name field (`AXTextField`, value `untitled.md`) + `Save`/`Cancel` buttons | no — shape unknown | **provisional row** — confirm at live-run; the sheet's *presence* witness is OCR `untitled.md`, its *completion* witness the `[document] saved` event |
| open panel | out-of-process; its **file cells are NOT in the AX tree** | — | firm (the k103 rule) — drive via Cmd-Shift-G, never by cell clicks |
| confirmation alert | `dialog` titled `alert`; message + informative text as static texts; `Discard` + `Cancel` buttons | message text via the fold | firm shape (the k80 alert precedent); **Discard is first-added hence default — bare Return fires it**; Cancel via `click-at` its AX coordinates (Escape-for-Cancel — to confirm in-VM) |
| Quit menu item | `AXMenuItem` | `"Quit Note Editor"` | as the prior apps; the ⌘Q key-equivalent itself is the standing `#:key` gap |

## §15 assertion → observation path (the coverage-or-gap map)

Per the forward-gen coverage-or-gap rule (`AppSpec/capabilities/forward-gen/validation.md`
L1b): every §15 line is served by a verb-backed path *or* carries a documented gap. This app
needs no network; every group below is runnable in the VM.

**Launch:**

| §15 assertion | Observation path |
|---|---|
| process running after launch | process: `expect-running-app` |
| launch diagnostic emitted | events.log: `wait-for-log "Note Editor"` |
| window title at launch | AX `AXWindow` exact `"Untitled — Note Editor"` |
| toolbar present | AX `AXButton` ×5 (exact, U+2026 forms) + OCR `"New"`/`"Undo"` |
| status starts Ready | AX `AXStaticText` exact `"Ready"` (fold) + OCR |
| placeholder shows | events.log `rendered placeholder=true chars=0` (launch sequence) + `wait-for-ocr "Start typing Markdown"` *(legibility to confirm in-VM)* |

**Editing / live preview:**

| §15 assertion | Observation path |
|---|---|
| typing marks dirty | `click-at` editor, **settle**, `type "# Hello"` → events.log `dirty-changed dirty=true` + AX `AXWindow` exact `"Untitled — edited — Note Editor"` |
| preview renders the heading | events.log `rendered placeholder=false chars=7` + `wait-for-ocr "Hello"` (h1-large) |
| preview tracks continuous edits | `type` more → the final `rendered chars=<n>` line + OCR the appended text *(body-size — adjudicate-by-artifact if garbled)* |
| list and fence rendering | `type -- "- first item"` (the `--` flag-terminator guard) → OCR `"first item"` + the `rendered` line |

**Save:**

| §15 assertion | Observation path |
|---|---|
| first save opens a sheet, name prefilled | `click-at` Save… → `wait-for-ocr "untitled.md"` (sheet AX shape provisional) |
| completing the save writes + cleans | Cmd-Shift-G → `/tmp/note-editor/work` → Return → Return (Save is the sheet's default button) → events.log `saved path="…/untitled.md" dirty=false` → `expect-file` + `read-file` equality → AX title exact `"untitled.md — Note Editor"` + status fold `"Saved <path>"` *(Go-to-Folder inside a save **sheet** — choreography to confirm in-VM; firmed only for the open panel, k103)* |
| subsequent saves are direct | re-dirty (settle after `type`), `click-at` Save… → a `saved` event **with no sheet interaction** (the operative witness) + `read-file` shows the update + title cleans; `expect-no-ax` sheet *(role provisional)* |
| cancelling the sheet changes nothing | `click-at` Save…, `press "Escape"` → AX title still `"— edited —"`; no event (absence not asserted) |
| write failure surfaces | code-witnessed (§8.5.7); *optional* scenario via an unwritable Go-to-Folder target (e.g. under `/System`) → events.log `save-failed` + OCR `"Save failed:"` prefix — else a **documented gap** |

**Open:**

| §15 assertion | Observation path |
|---|---|
| Open loads a file | clean doc → `click-at` Open… → Cmd-Shift-G → fixture path → Return ×2 → events.log `opened path="…/fixture-note.md" dirty=false` + `rendered chars=<fixture length>` → OCR `"FIXTURE NOTE"` in the preview → AX title exact `"fixture-note.md — Note Editor"` + status fold `"Opened <path>"` |
| round-trip | open the fixture → Save… to `work/` → `read-file` equals the fixture's content |
| dirty Open asks first | `click-at` Open… with unsaved edits → OCR `"Discard unsaved changes"` / alert AX shape |
| read failure surfaces | code-witnessed (§8.5.6); *optional* scenario: upload a fixture then `chmod 000` it in-guest, open it → events.log `open-failed` + OCR `"Open failed:"` prefix — else a **documented gap** |

**New / the confirmation alert:**

| §15 assertion | Observation path |
|---|---|
| dirty New asks first | `click-at` New with unsaved edits → OCR `"start a new note"` (the trigger-specific message) |
| Discard clears everything | `press "Return"` (Discard is default) → events.log `new path="" dirty=false` + `rendered placeholder=true` → status fold `"New document"` + OCR `"Start typing Markdown"` + AX title exact `"Untitled — Note Editor"` |
| Cancel keeps everything | re-dirty, `click-at` New, `click-at` Cancel (AX coordinates) → AX title still `"— edited —"` (+ preview OCR of the typed text intact) |
| clean New shows no alert | `click-at` New on a clean doc → `expect-no-ax` alert + events.log `new` + status fold `"New document"` |

**Undo / Redo:**

| §15 assertion | Observation path |
|---|---|
| Undo reverts typing | `click-at` Undo (repeatedly — **grouping granularity to confirm in-VM**, record actuals) → events.log `rendered placeholder=true` once fully reverted + OCR `"Start typing Markdown"` *(the §9 notification-on-undo coupling is itself to-confirm — the `dirty-changed`/`rendered` trace is the firming instrument)* |
| Redo restores | `click-at` Redo → a `rendered placeholder=false` line + OCR `"Hello"` |
| Undo on a fresh document is a no-op | `click-at` Undo at launch → AX title unchanged + `expect-running-app` (event silence not asserted) |

**Lifecycle:**

| §15 assertion | Observation path |
|---|---|
| no state across launches | save, quit, relaunch → AX title exact `"Untitled — Note Editor"` + `rendered placeholder=true chars=0` in the fresh log |
| Quit terminates | steady state → `chord cmd q` → process gone + events.log `shutdown reason=menu` |
| quit with unsaved edits neither asks nor saves | `type`, settle, `chord cmd q` → `expect-no-ax` alert + process gone (+ no file anywhere to check — nothing was ever saved) — **recording-flavoured: §3.10 flags this to-confirm; a contradiction is a spec-quality finding** |
| close-button behaviour | recording scenario: `click-at` the close button → `expect-running-app` — recorded, not asserted (§3.10 expects keep-running but flags it to-confirm) |

**Driver guidance the suite must honour** (spec §15 + the prior runs): **settle after `type`
before any button click** — the k121 racket type→click race, acute here because *every* editing
scenario types then clicks a toolbar button; text beginning `-` or `` ` `` goes through the
driver's flag-terminator (`type -- "- item"`); press **Return** for a panel's/alert's default
button (the sheet's Save, the alert's Discard) rather than clicking; drive both panels via
**Cmd-Shift-G + absolute path** (open-panel file cells are not in the AX tree); click at
AX-reported coordinates, never screenshot pixels; read dirty/name state from the **window AX
title**, never the close-box dot; after a sheet or alert has had key, the first click on the
app window may only re-activate it (`acceptsFirstMouse` is control-dependent — the scenekit
k112 finding).

## Deferred / gap observables (not acceptance preconditions)

Reported as gaps rather than hard-asserted before the channel is firm (the forward-gen
"mutant-D" discipline; same section shape as the prior apps):

- **Preview OCR legibility — this app's headline unknown.** The placeholder (~16px gray
  italic) and body-size rendered text may garble (the k103 small-text class); h1-rendered
  text is the designed-large marker. Every preview assertion has the `[preview] rendered`
  event as its firm app-side half — a present event + failed OCR adjudicates to run-mechanism,
  not impl defect.
- **WKWebView rendered-DOM AX exposure** — unknown across five apps so far (mini-browser only
  witnessed the non-rendered state); this app renders HTML from launch, so live-run may firm
  it. No assertion depends on it.
- **Editor `AXValue` fold-fidelity under the driver** — raw snapshots carry it (k121); whether
  `expect-ax` can match on it is to-confirm. Content assertions ride `read-file` +
  `rendered chars` regardless.
- **Save-sheet AX shape + the Go-to-Folder-in-sheet choreography** — the k103 rule is firmed
  for the *open panel*; its save-sheet variant is presumed and confirmed at live-run before the
  suite hard-binds it.
- **Undo grouping granularity** (§9) and the **notification-on-undo coupling** — record
  actuals at live-run; the `dirty-changed`/`rendered` trace is the firming instrument.
- **The failure paths** (§8.5.6/7) — code-witnessed; drivable only via manufactured
  unreadable/unwritable paths (chmod-000 fixture; a SIP-protected save target) — forward-gen
  decides, else documented gaps.
- **The close-box dirty dot** (§4) — no verb reads it; the window AX title is the channel of
  record, the dot itself stays unasserted.
- **Window size/position (900×600 centred, min 520×360) and the ⌘Q key-equivalent** — the same
  `expect-ax #:size/#:position/#:key` gap set the prior apps recorded. Resize behaviour (§4/§5
  autoresizing) additionally lacks a window-resize gesture verb — spec prose without a runnable
  assertion.
- **Find-bar reachability** (§5.3 `usesFindBar`) — unspecified in the spec (no menu/key route
  exists); not asserted.
- **Graphical states** — the rendered Markdown *styling* (heading sizes, code-block
  backgrounds, list bullets), fonts, the split divider — confirmed visually during the
  live-run stage and recorded in `run-results.md` (sample apps must be visually perfect — the
  human eye still checks the window).

## Build obligation summary (per impl)

A conformant build must, beyond the [logging contract](logging-contract.md): render the single
centred resizable 900 × 600 window (min 520 × 360) whose title always equals the §6.1 rule's
output (Untitled/name × clean/`— edited —`, real em dashes), with `setDocumentEdited:` tracking
the dirty flag; a top toolbar strip (first-baseline-aligned horizontal stack) reading `New`
`Open…` `Save…` `Undo` `Redo` + the 11-pt static status line starting `Ready`; below it a
vertical-divider split view — left an editable plain-text `NSTextView` (13-pt monospaced,
undo-enabled) in a scroll view, right a `WKWebView` rendering §7's HTML on every text change;
the §6.2 source-filtered text-change observer (strongly held, never unregistered); the §8
document operations (guarded New/Open with the §8.1 alert; modal open panel with the
`md`/`markdown`/`txt` filter; sheet-plus-completion-handler first save, direct overwrite
thereafter; target-native file I/O); button-driven, capability-guarded undo/redo (§9); standard
AX roles for the native controls; and the app-menu **Quit** item (⌘Q → `terminate:`). The four
existing impls already build all of this — the delta each needs is the logging instrumentation.
