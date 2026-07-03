# app-model-k62 — brief

**Kind:** planning

## Goal

Open **workstream 7** of the `structural-refactoring` grove (root brief decomposition #7):
the **app model** under `apps/macos/` — the common, target-independent **app-specs** that
every target's implementation is checked against (REFACTOR.md §15 / §7.8). This is a
**planning** leaf: grill the ws7 design with the user, raise ADRs / a PRD where decisions
are genuine agreement points, update `CONTEXT.md` inline as the app-model vocabulary
resolves, and **decompose into a node** (`leaf-decompose`) — doing only the first child this
session.

The app-specs already exist as co-located prose (`apps/macos/<app>/docs/{spec,learnings,
test-strategy}.md`, relocated by `co-locate-docs-k9`); ws7 **promotes them to a first-class,
authored entity** and finalizes the structure. The per-target **app-implementations** already
exist and are VM-verified (`targets/<t>/app-implementations/<platform>/<app>/`) — ws7 does
**not** re-author them; it authors the shared spec they all realize.

## Context (root brief #7 + the consuming seams promoted from ws3/ws4/ws6)

The seams ws7 must honour, already settled:

- **An app-spec *names* its app-kind (ws4 D2 seam).** The seven **app-kinds**
  (`cli-tool`/`gui-app`/`menu-bar-daemon`/`launch-agent`/`spotlight-importer`/
  `quicklook-extension`/`finder-sync-extension`) are a distinct authored registry at
  `platforms/macos/app-kinds/` (ADR-0049). Three **orthogonal axes** share only the
  authored-registry mechanism: **app-kind** (platform category) vs **app-spec** (a concrete
  app that *names* its kind — ws7) vs **pattern-kind** (API-usage — ws3). An app-spec is the
  *instance* side of the category↔instance relation with app-kind.
- **App-implementations are ws6's; the spec is ws7's (ws6 seam).** The per-target
  implementations live at `targets/<t>/app-implementations/<platform>/<app>/` and already
  ship (the VM-verified sample apps); ws6 homes the conformance *report* over them. ws7
  authors the **one** target-independent spec at `apps/macos/<app>/` that all four targets'
  implementations are checked against — kept **projection-free** (the same spec drives
  racket/chez/gerbil/sbcl and future targets alike, §45.11), mirroring the platform-model's
  "states what the API *means*, never how a target expresses it" rule.
- **The spec is already a bundler input.** The four bundlers read each app's display name
  from `apps/macos/<app>/docs/spec.md`'s first H1 (`bundler-reshape-k61`). Whatever ws7 makes
  the spec, that read (or its replacement) must keep working.
- **ws8 owns the machine schema (standing seam).** ws7 may author the AppSpec `.apiw` KDL
  Schema + a focused in-crate validator; the **machine JSON Schema** for any derived AppSpec
  artifact + validation tooling/CI stay **ws8's** (the ws2/3/4/5/6 mirror).
- **ws9 owns execution.** ws9 owns the multi-layer test model (§33) + the TestAnyware/AppSpec
  runner (§34) that drives a spec against a *running* target binding; ws7 **declares** the
  behavioural exemplar (§7.8), it does not build the runner (the declare-now/execute-later
  seam, the ws4 D3 mirror).
- **Goldens-as-truth remains the gate.** ws7 is spec authoring, not an emit change — a moved
  emit golden is a bug unless a child *intends* it (and then it is deliberate).

Current state: `apps/macos/` holds nine app dirs (`hello-window`, `ui-controls-gallery`,
`scenekit-viewer`, `pdfkit-viewer`, `mini-browser`, `note-editor`, `drawing-canvas`,
`swift-native-probe`, …) each with `docs/{spec,learnings,test-strategy}.md`, plus
`apps/macos/docs/` (the portfolio index + design). `apps/macos/README.md` records the ws7
TODO: "promote each `spec.md` to a first-class AppSpec, split spec vs. implementation-notes,
and reconcile the co-located per-app docs with the per-target implementations."

## Grilling agenda (one question at a time — propose a recommended answer for each)

Open threads to settle before decomposing (not exhaustive — grove is for incremental
discovery):

- **The app-spec entity.** Is the AppSpec an authored `.apiw` entity (like target/platform/
  pattern-kind), the existing prose `spec.md`, or a pairing (authored `.apiw` spec + prose
  rationale)? What fields does it carry (app-kind ref, behavioural exemplar / acceptance
  criteria §7.8, required APIs / pattern-kinds, fixtures), and what is authored vs derived?
- **Spec vs implementation-notes split.** Today `spec.md` mixes the target-independent
  exemplar with per-app realization. Where does the projection-free spec end and the
  per-target `learnings.md` (already under `app-implementations/`) begin?
- **The app-kind ↔ app-spec binding.** How an app-spec names its app-kind, and how the
  cross-field validity (does the app's behaviour fit its declared kind's process/run-loop/
  activation truth?) is checked — mirroring ws4's focused app-kind validator.
- **Skeleton-first sequencing.** What buildable-at-every-step order does ws7 take (mirrors
  the root D4 discipline)? Likely: the AppSpec entity + schema + one app first, then the
  portfolio, then the conformance/coverage tie-in.
- **ws8/ws9 boundaries.** Confirm AppSpec machine-JSON-Schema is ws8's; the AppSpec *runner*
  is ws9's; ws7 declares + schema-validates only.

## Status — grilled & decomposed (2026-06-26)

Design converged (see **Decisions** running log: D1, D2, D2′, D3, D5). This node is
the `app-model-k62` workstream; children materialize lazily (do **not** pre-spawn).

## Node done when (ws7 complete)

- The **foundation** is in place: `apps/macos/` defines the APIAnyware↔AppSpec↔TestAnyware
  relationship + data boundary (**ADR-0052**); `CONTEXT.md` carries the reconciled
  app-model vocabulary (AppSpec project + App/impl/scenario/scenario-suite/contract +
  reverse/forward-gen; the 3 "AppSpec" meanings disambiguated).
- The **reverse-gen workflow** is proven: at least one sample app has an LLM-generated,
  human-validated spec/PRD derived from its existing impl.
- The **AppSpec grove is built** (seed/PRD authored, grove initialized in
  `~/Development/AppSpec`), and a **pause-point** leaf marks the hand-off.
- Cross-grove **seeds** delivered (reverse/forward-gen, spec format, patterns/attack-vector
  interface).
- *(Post-pause, deferred — may become follow-on leaves or a later grove):* forward-gen
  suites + AppSpec-runner VM-verify for the apps; finalize the `apps/macos/` file layout
  once AppSpec's format firms; portfolio index + coverage tie-in.

## Children (materialized lazily — only the live ones exist on disk)

1. **`appspec-foundation-k63`** ✅ *(done)* — the foundation: ADR-0052, the
   `CONTEXT.md` glossary reconcile, and the `apps/README.md` + `apps/macos/README.md`
   rewrite defining the boundary/relationship + the generated-spec model. Format-flexible;
   no per-app churn, no bundler change (keep `spec.md`). Skeleton-first.
2. **`reverse-gen-exemplar-k64`** ✅ *(done)* — LLM-generated hello-window's spec/PRD from
   its four impls, human-validated; the worked template (`hello-window/docs/spec.md` +
   `apps/macos/docs/reverse-gen-workflow.md`).
3. **`build-appspec-grove-k65`** ✅ *(done)* — authored the toolkit seed/PRD
   (`apps/macos/docs/appspec-toolkit-seed.md`, the D2′ vision + reconciliation of AppSpec's
   dormant-but-working v1 substrate + proposed grove decomposition) and staged the three
   cross-grove seeds (capability shapes; spec/PRD format; patterns/attack-vectors interface
   open question). Delivery mechanism resolved: `grove-llm inbox-add` does not exist and no
   `grove-meta` branch exists → seed homed durably in this repo; actual init/delivery is
   k66's (the moment a grove exists to receive it). Zero AppSpec-repo edits (boundary held).
4. **`appspec-grove-pause-k66`** ✅ *(done 2026-07-02)* — the **pause point**: the AppSpec
   toolkit grove was initialized, seeded, and **ran to completion** (three capabilities,
   `capabilities/{reverse-gen,forward-gen,run}/workflow.md`; repo back on pristine `main`).
   During the pause, hello-window went end-to-end via cross-grove records k67–k74
   (conformance data; instrument+build ×4; forward-gen suite; Tier-2 live runs — all four
   impls 3/3), firming the spec format as the hello-window shape.
5. **Post-pause children** *(grown on k66 retirement, 2026-07-02)* — build-portability
   findings first (`sbcl-vendor-libzstd-k75` ✅, `racket-self-contained-bundle-k76` ✅), then
   one AppSpec-cycle leaf per remaining app (k77–k83: ui-controls-gallery ✅ *(node
   `appspec-ui-controls-gallery-k77`, complete 2026-07-02 — see **ui-controls-gallery
   outcomes** below)*, pdfkit-viewer ✅ *(node `appspec-pdfkit-viewer-k78`, complete
   2026-07-02 — see **pdfkit-viewer outcomes** below)*, scenekit-viewer ✅ *(node
   `appspec-scenekit-viewer-k79`, complete 2026-07-03 — see **scenekit-viewer outcomes**
   below)*, mini-browser ✅ *(node `appspec-mini-browser-k80`, complete 2026-07-03 — see
   **mini-browser outcomes** below)*, note-editor ✅ *(node `appspec-note-editor-k81`,
   complete 2026-07-03 — see **note-editor outcomes** below)*, drawing-canvas ✅ *(node
   `appspec-drawing-canvas-k82`, complete 2026-07-03 — see **drawing-canvas outcomes** below)*,
   swift-native-probe ✅ *(node `appspec-swift-native-probe-k83`, complete 2026-07-04 — the
   eighth and **last** app; see **swift-native-probe outcomes** below)* — each live-VM-verified,
   each decomposed on entry), then
   `apps-layout-finalize-k84` and `portfolio-coverage-tie-in-k85` (which closes this
   node's Done-when).

## ui-controls-gallery outcomes (promoted from `appspec-ui-controls-gallery-k77` on retirement)

Second app through the toolkit (after hello-window), first with a rich control surface —
the durable findings the six remaining apps (k78–k83) should apply. Full record:
`apps/macos/ui-controls-gallery/docs/run-results.md` (k94).

- **Final outcome:** all four impls green on every runnable scenario (10/11 each); the one
  standing red (scenario 03) is a `recording:` role-mapping finding by design — **date picker
  surfaces as `AXDateTimeArea` on Tahoe, not `AXDateField`** (spinner `AXBusyIndicator`
  confirmed); the observable-state role table is corrected, the scenario stays red until a
  forward-gen regeneration folds the firm roles into the hard cluster.
- **Per-impl geometry practice** (coordinate-driven suites): measure per impl from `agent
  snapshot --mode layout` (AX centre, framebuffer px); run a **two-launch determinism diff
  before binding values**; keep per-impl `run-values-<impl>.rkt` files when layouts diverge
  (chez+gerbil were pixel-identical and share the default; racket/sbcl carry their own);
  never click within ~10px of a resizable window's border (the resize-handle band swallows
  clicks — bind slider ends at the track's *effective* start/end, knob half-width in).
- **Two impl-defect classes only Tier-2 catches** (source review + CLI smoke were blind to
  both): (a) *launch presentation* — a scroll viewport smaller than its non-flipped document
  launches bottom-scrolled, hiding half the roster (spec-§4 violation in all three stack
  impls; fixed by sizing the window content past the document); (b) *ambiguous layout* —
  a plain `NSView` arranged in an `NSStackView` has no intrinsic size and resolves
  nondeterministically per launch (±97px row shifts); **nested containers arranged in a
  stack must themselves be stack views** (or otherwise carry an intrinsic size).
- **The runner is now full-suite-reliable**: the k75 per-scenario workaround is obsolete —
  AppSpec `46fec5b` (deadline-guarded `gv-exec/poll` content polls absorb the exec-channel
  close stall) + `f2b8b76` (per-scenario tailer epoch reset; byte-identical relaunch content
  starved `wait-for-log`). Residual: the scenario *after* a failure inherits artifact-capture
  channel pressure and can hit a delayed-`truncate` empty-log red with the app provably up —
  adjudicate by solo re-run (workflow §3); proper fix is TestAnyware-side.
- **Observation:** all four runtimes ignore SIGTERM under `nsapplication-run` (`pkill` needs
  `-9`); the contract's menu-quit path works everywhere — signal-path shutdown stays
  unexercised, as k88 recorded.

## pdfkit-viewer outcomes (promoted from `appspec-pdfkit-viewer-k78` on retirement)

Third app through the toolkit (after hello-window and ui-controls-gallery), first with a
document fixture + out-of-process panel drive. Full record:
`apps/macos/pdfkit-viewer/docs/run-results.md` (k103). Durable findings for the remaining
apps (k79–k83):

- **Final outcome: no impl defect.** Behavioural surface green on all four impls; every red
  adjudicates to one of two classes: (a) the cross-impl §13 **spec finding** (07) — PDFView
  continuous-mode key navigation is scroll-based: Right/PageDown/End are no-ops through the
  VNC key path, Down line-scrolls ~24px, **Space scrolls one viewport** and is the working
  "navigation the view itself handles" (Space×3 crossed the boundary, `page-changed` fired,
  label tracked — §7.1/§7.3 observer behaviour TRUE, the spec's arrow-key realization wrong;
  feed to reverse-gen on regeneration); (b) the **OCR small-text run-mechanism class** —
  racket 01 (its compact 22px metrics + centred bold title garble deterministically;
  menu-bar name has no space so the title bar is racket's only OCR source) and gerbil/sbcl
  06 (label read garbles under the runner while the identical read passes in 05). Signature:
  sparse dumps, menu-bar icons OCR'd as text ("Q"/"8"), ◀/▶ glyphs merging into text lines
  ("(Page lot 3"). Adjudicate OCR-class reds by artifact review (screenshots + events +
  AX), never by patching the suite; proper fix is TestAnyware-side (or region-scoped OCR /
  AX-preferred realizations in forward-gen). Joins the k94 delayed-truncate residual (which
  also recurred: racket 03 red-then-green-solo) as a standing run-mechanism residual.
- **The keyboard-driven fixture rule works everywhere:** Cmd-Shift-G → absolute path →
  Return ×2 drives the out-of-process panel reliably on all four impls; `opened`
  exact-matches basename + pages. **`page-changed page=1` precedes `opened`** in every
  impl's open flow — the contract's "never assume ordering vs `opened`" rule is load-bearing
  in practice.
- **Geometry:** all four impls deterministic on the two-launch diff (no gallery-style
  ambiguous-layout defect); **chez+gerbil+sbcl pixel-identical** sharing `run-values.rkt`,
  racket alone diverging (`run-values-racket.rkt`, 22px vs 26px control metrics) — note the
  share-set differs from the gallery's (there sbcl diverged too).
- **The k96 enabled-flag gap is runner-side only:** TestAnyware's `agent snapshot --mode
  layout` carries per-element `enabled` (◀/▶ flags verified at empty state and both
  boundaries, all impls); the seeded `expect-ax #:enabled?` AppSpec backlog item remains the
  closer.
- **k96 provisional AX rows all firm** (02 green ×4): Open… U+2026 in AXTitle, ◀/▶
  glyph-as-AXTitle, label value→AXTitle fold, empty PDFView = AXScrollArea.
- **Tahoe VM gotcha:** the "See what's new in macOS Tahoe" notification banner appears on
  fresh clones mid-run, OCR-pollutes full-screen dumps, and survives `killall
  NotificationCenter` — dismiss by hover + close-X click (did not change any verdict here).

## scenekit-viewer outcomes (promoted from `appspec-scenekit-viewer-k79` on retirement)

Fourth app through the toolkit, first with GPU/3D content (viewport unobservable to the
verbs — the `[scene]` events carry the state assertions) and an in-process shared panel.
Full record: `apps/macos/scenekit-viewer/docs/run-results.md` (k112). Durable findings for
the remaining apps (k80–k83):

- **Final outcome: no impl defect.** racket/chez 9/10, gerbil/sbcl 8/10; the one standing
  red (07, byte-identical on all four impls) is the **§13 driver-guidance spec finding by
  design**: after the colour panel takes key, the first app-window click **DELIVERS** to the
  popup — `acceptsFirstMouse` is control-dependent (buttons need the two-click dance, a
  pop-up fires on the activating click) — so the two-click realization opened the menu then
  re-selected Cube. Stays red until a forward-gen regeneration folds the single-click
  choreography in (gallery-03/pdfkit-07 precedent); the key behaviour (colour persists
  across a swap) is proven per impl by 08, which adds a dismissal to the same flow.
- **Runner fix the run forced (AppSpec `611f73c`, the hello-window §6.6 precedent):** a
  scenario that *ends with an open pop-up menu* (03 asserts the open menu) starves every
  later scenario's setup — the graceful AppleScript quit can never deliver to an app inside
  menu tracking, and the next `open` (no `-n`) just re-activates the stale instance →
  wait-ready cascade. `quit-impl!` now escalates: graceful quit → poll for exit →
  `pkill -9 -f <binary>`. Menu-opening scenarios are now safe to sequence.
- **The panel's slider space is not device-RGB (pre-agreed degrade applied):** typing
  0/128/255 into the RGB fields lands as **device `(0,150,255)`** after the §7.4 fold —
  byte-identical across all four impls (AppKit-side conversion, uniform per-runtime).
  Suites asserting exactly-driven colours must bind **recorded actuals**, and note a
  no-change field commit does not re-fire the panel's action. **NSColorPanel provisioning:**
  fresh per-app defaults open the sliders pane in Grayscale kind (no `Blue` label) — seed
  the RGB kind per impl at provisioning (remembered per-app, survives relaunch); all panels
  open at default frame (0,605) 250×397.
- **New OCR-case shape of the k103 class:** the engine cases camel-cap small text —
  `SceneKit`→`Scenekit`/`Scenekir` at `conf=1.00` on a crisp frame — failing case-sensitive
  `expect-ocr` (gerbil/sbcl red; chez wobbled; racket green). Adjudicate via the AX-exact
  channel; forward-gen may prefer AX-exact over whole-screen OCR where both assert the
  same fact.
- **Geometry:** chez+gerbil pixel-identical (shared default); sbcl toolbar 4px lower +
  wider `Colour…`; racket's compact 22px metrics **reach inside the shared NSColorPanel's
  picker pane** (fields ~9px higher, wheel pane drops the Opacity row) — per-app control
  metrics affect system-panel *content*, only the panel chrome is constant. Popup menu item
  positions measured from the OPEN menu (find-text works well); rows ~28px (racket ~24px).
- **Visual bar met on all four** (spin frames, swap visuals, single-click wheel recolour,
  drag orbit); wheel single-click delivery works everywhere — the no-drag-verb degrade was
  never needed.

## mini-browser outcomes (promoted from `appspec-mini-browser-k80` on retirement)

Fifth app through the toolkit, first with WKWebView content, an async-navigation log
channel (`[nav]`), and a manufactured-offline launch reality. Full record:
`apps/macos/mini-browser/docs/run-results.md` (k121). Durable findings for the remaining
apps (k81–k83):

- **Final outcome: no impl defect.** racket 9/13, chez/gerbil/sbcl 10/13; every red is a
  run-mechanism class, every obscured fact proven via a second channel; the mandated
  Command-Q invariant and all three `recording:` confirmations green on all four impls
  (NSURL rejects space-bearing input with the status suffix **normalized** — §6.2 right,
  observable-state "typed" wrong, the k120 ambiguity resolved; WKWebView-rendered 72px
  fixture text IS OCR-observable; close-button keep-running — fifth app to confirm).
- **The VM golden now has LIVE NETWORK** — the k74-era "no VM network" assumption is
  stale (the first probe launch loaded apple.com). Offline is manufactured in-guest,
  keeping the 192.168.64.0/24 control subnet alive: IPv4 `route add -net {0,128}.0.0.0/1
  127.0.0.1 -reject` + IPv6 `::/1`+`8000::/1` twins (fast EHOSTUNREACH; without the v6
  pair, happy-eyeballs hangs to timeout), pf as belt-and-braces (pf `return`/`return-rst`
  silently DROPS on Tahoe — too slow alone), plus a WebKit cache wipe per bundle-id.
  DNS still resolves via the NAT gateway → the offline failure is uniformly
  `[nav] failed phase=request message="Could not connect to the server."` on all four.
- **NEW run-mechanism class — the type→click driver race** (racket 09, solo-confirmed
  deterministic): a mouse click immediately after `type` overtakes the VNC keyboard
  queue (~36 of 48 chars delivered before Go fired; the impl correctly navigated to the
  truncated field). Return-submits are immune (same keyboard channel); only racket's
  slower per-keystroke dispatch exposes it. Guidance for k81–k83 suites: **settle after
  `type` before any button click**; proper fix is TestAnyware-side (serialize mouse
  behind pending keyboard).
- **The k103 OCR small-text class hit hard and layout-dependently** (02/04/06 red on all
  four impls; 01 on racket): the shared-layout impls garble `request failed:` →
  `reguest talled:`; racket instead drops the colon (`request failed.`), garbles the URL
  (`httos://www.annle.com`) yet reads `Invalid URL` cleanly. Every deterministic status
  string asserted via the AX value→AXTitle fold passed everywhere (03/07/09/11) —
  forward-gen should keep preferring AX-exact; 11-pt OCR reads stay adjudicate-by-artifact.
- **Geometry:** chez+gerbil+sbcl pixel-identical sharing `run-values.rkt` (the pdfkit
  share-set), racket alone on the compact-22px sibling; all four two-launch
  deterministic; the k120 spec-derived provisional coordinates ALL landed within their
  control bounds — the projection method (window frame + [NSWindow center] bias +
  intrinsic stack sizing) is validated for provisional authoring.
- **Platform rows firmed ×4:** launch-failure `phase=request`; the failure alert's AX
  shape (`dialog` titled `alert`, message = the event's message text, OK `[focused]` —
  bare Return dismisses); ◀/▶ `enabled=false` at empty state in raw layout snapshots
  (the k96 channel); the address field's AX value IS readable in raw snapshots
  (sharpens k113's "empty under the driver" caveat); post-failure WKWebView surfaces as
  an empty `scroll-area` (no `AXWebArea` at the steady state).

## note-editor outcomes (promoted from `appspec-note-editor-k81` on retirement)

Sixth app through the toolkit, first with state-mutating persistence (save/open panels,
on-disk assertions, between-scenario cleanup obligations). Full record:
`apps/macos/note-editor/docs/run-results.md` (k130). Durable findings for the remaining
apps (k82–k83):

- **Final outcome: no impl defect.** racket 19/21, chez/gerbil/sbcl 18/21; every red is the
  k103 OCR run-mechanism class, every fact behind a red proven via a second channel (in-suite
  AX for the status label; per-impl manual drives for the alert's Discard/Cancel semantics).
  The mandated Command-Q invariant and all eight `recording:` confirmations green ×4 — the
  §9 undo coupling firmed (a typed burst coalesces to ONE undo group; text-mutating undo
  rides the typing notification path), both failure paths (mode-000 read, SIP write) proven
  drivable through the panels, quit-unsaved confirmed silent (§3.10).
- **NEW run-mechanism class, fixed in-run (AppSpec `b2c6ffa`) — the capture-then-parked-click
  swallow:** a click at the pointer's parked position sent right after a VNC framebuffer
  capture (every `wait-for-ocr` poll) is delivered but its FOCUS effect is swallowed — a
  first click into an NSTextView never takes first responder and the following keystrokes
  land on the old responder (a typed space PRESSES the launch-focused toolbar button:
  phantom `new` events). ≥100px real motion between capture and click re-syncs; a 2px nudge
  does not. `gv-click` now pre-moves 100px off-target before every click — k82/k83 suites
  inherit the fix; the proper fix remains TestAnyware-side.
- **OCR wrapped-line class (extends k103):** OCR drops the SECOND line of a wrapped alert
  message (`start a new note?` unreadable at conf-any on all four impls) — gate alerts on
  their first line + an AX discriminator, never on the wrapped tail. The 11-pt status-label
  OCR corroboration is layout-dependent (invisible at 26px metrics, legible on racket's
  22px) — AX-exact stays the channel of record.
- **Geometry:** chez+gerbil+sbcl pixel-identical sharing `run-values.rkt`, racket alone on
  the compact-22px sibling (the pdfkit/mini-browser share-set — sbcl did NOT diverge as in
  scenekit: measure, never assume). **NSAlert geometry is layout-independent** (byte-identical
  over the 22px and 26px window layouts — one shared `alert-cancel`), measured from the OPEN
  alert; note Cancel is *focused* while Discard (added first) is *default* — Return fires
  Discard. The k120 spec-derived projection landed all k129 provisional coordinates in-bounds
  (third window shape validated); its alert projection was 61px off — panels/alerts always
  measure live.
- **Persistence-story practice (first state-mutating app):** the between-scenario guest
  cleanup obligation (`rm -rf work/`) realized as chunked runner invocations around the
  save-driving scenarios — the workflow's harness-convenience split, no runner change needed.
  Panels canonicalize `/tmp` → `/private/tmp` (basename-only event matchers are load-bearing);
  **Cmd-Shift-G works INSIDE the save sheet** (the k103 rule extends beyond the open panel);
  **Escape cancels the sheet**; the sheet is an `AXSheet` whose children are NOT exposed —
  the prefilled-name OCR cue is genuinely the only sheet-up gate (and reads at conf 1.00).
- **Content-area AX invisibility:** the split group's children (NSTextView editor, WKWebView
  preview) are unexposed in agent snapshots on all four impls — contract log events + OCR are
  the only content channels; the status label's value→AXTitle fold is the one reliable AX
  text read inside the content area. Window AX title tracks the dirty state exactly (the
  §6.1 channel of record).

## drawing-canvas outcomes (promoted from `appspec-drawing-canvas-k82` on retirement)

Seventh app through the toolkit, first whose primary content surface is a **custom `NSView`** (strokes
are framebuffer pixels — OCR-meaningless *and* AX-invisible), so the `[canvas]` logging contract carries
every state assertion, coordinate-driven mouse gestures drive it, and screenshots carry the visual bar.
Full record: `apps/macos/drawing-canvas/docs/run-results.md` (k139 + the k140 closure). Durable findings
for swift-native-probe-k83 (and future custom-view apps):

- **Final outcome: 17/17 ×4, no impl defect.** k139 landed 16/17 ×4 (sole red 03, a snapshot-scope
  finding); **`canvas-ax-scope-k140` closed it to a genuine 17/17** — the first app in the portfolio to
  chase the literal all-green rather than leave an adjudicated recording-red (the gallery-03 / pdfkit-07 /
  scenekit-07 / note-editor-11 precedents each stayed red-until-a-future-regen; drawing-canvas regenerated
  its scenario in-grove).
- **TWO run-forced AppSpec fixes, both toolkit-side** (app data stays downstream; the mechanism is
  AppSpec's — ADR-0012), both acutely relevant to any custom-view app:
  - **`gv-click` settle-move (AppSpec `89fb98a`, k139).** `testanyware input click X Y` moves the cursor
    AND presses in one call; on a custom `NSView` tracking `mouseDragged:` the move-coincident-with-press
    synthesises a spurious drag → a bare click paints a **two-point** stroke (`points=2`), defeating the
    §7.2 motionless-click dot (`points=1`). Fix: settle the cursor **onto** the target before the press
    (retaining the k130 ≥100px re-sync pre-move). A button still fires on down+up.
  - **`#:scope 'app-content` on `expect-ax`/`expect-no-ax` (AppSpec `cb178f8`, k140) — the reusable
    closer for "no content AX on a custom-view surface".** A whole-snapshot `(expect-no-ax #:role
    'AXStaticText)` trips on chrome the view never produced: the app window's own **title-bar
    `AXStaticText`** (text == the window's `AXTitle`) and desktop **Notification Center** widgets (which
    are `windowType: standard`, so only an `appName` filter excludes them). The opt-in `#:scope
    'app-content` walks only the app-under-test's standard-window content, dropping the title chrome +
    foreign windows; the app-under-test is identified snapshot-intrinsically (the `appName` owning the
    Menu Bar — the frontmost app always does) so no per-app plumbing is needed. Default `#:scope
    'anywhere` is byte-unchanged. swift-native-probe inherits both.
- **`drag-from-to` proved in live use** (the portfolio's first) — the held-button canvas drag paints a
  multi-point stroke (`points` 2–3, driver-cadence, never bound exactly); the §2 **freeze proof**
  (width/colour captured at mouse-down, unchanged on record when a later stroke uses a new tool) is
  witnessed **from the log alone** (07/10).
- **The device-RGB fold confirmed (the k112 rule):** typing 0/128/255 into the NSColorPanel RGB fields
  lands, after the `deviceRGBColorSpace` fold, as device **`r=0 g=150 b=255`** — byte-identical ×4
  (AppKit-side, uniform per runtime). Bind **recorded actuals**; a no-change field commit does not re-fire
  the panel action; seed the panel's **RGB Sliders** kind per impl at provisioning (fresh defaults open
  Grayscale; persists across the runner's `open -n` relaunches).
- **Geometry:** chez+gerbil+sbcl pixel-identical on the app window (window (640,145) 640×512, 26px
  metrics) sharing `run-values.rkt` (the pdfkit/mini-browser/note-editor share-set); racket alone on the
  compact 22px sibling `run-values-racket.rkt`. The shared **NSColorPanel splits THREE ways** (per-app
  frame origin + racket's compact metrics reaching inside the picker pane). Slider max = track-end −
  knob-half (k94). Two-launch determinism green on every impl (no ambiguous-layout defect).

## swift-native-probe outcomes (promoted from `appspec-swift-native-probe-k83` on retirement)

**Eighth and LAST app through the toolkit** — a **static coverage-proof window** (no
coordinate-driven controls, strokes, panels, or fixtures; the proof lives in the LOG), so the
smallest suite in the portfolio (3 scenarios). Full record:
`apps/macos/swift-native-probe/docs/run-results.md` (k147). The node was lean-decomposed
(`spec-and-contracts-k141` + `instrument-builds-k142` node + `forward-gen-live-run-k147`), the
k142 per-impl CreateML bring-in being the surprise (the "no corpus regen" premise was false for
the Scheme trio). Durable findings for `apps-layout-finalize-k84` + `portfolio-coverage-tie-in-k85`:

- **Final: 3/3 ×4, genuine all-green, no standing red** — the **second app** (after drawing-canvas)
  to chase the literal all-green rather than leave an adjudicated recording/OCR red, via two honest
  run-forced changes (below). The coverage proof (`[probe] complete … all-ok=#t`, the app's whole
  purpose) and the mandated Command-Q invariant held on all four throughout.
- **The log is the coverage channel, not the window** (the load-bearing right-sizing decision).
  `[probe] complete … all-ok=#t` is the single **target-agnostic** assertion (count=2 racket/chez/
  gerbil, count=5 sbcl — sbcl is a *different* 5-shape app); the launch line `Swift-Native Probe
  opened.` is **byte-identical ×4**. The window carries only structural assertions — and the exact
  title `Swift-Native API Coverage` is the one **projection-free** window fact, assertable via **both**
  OCR-exact **and** `expect-ax #:role 'AXWindow #:title` (a strengthening hello-window's per-impl title
  could not afford).
- **Heading OCR needs the reliable substring `trampolines`, never `Swift-native APIs`** — whole-screen
  OCR garbles the small-font capital-I ("APIs"→"APls", the k103 class); the heading has **no
  projection-free AX channel** (`expect-ax #:title` is exact-only, the full heading is per-impl), so an
  OCR-reliable projection-free substring is the channel of record (the node brief pre-sanctioned it; the
  scenekit "prefer the reliable read for the same fact" rule).
- **Two targets shipped a hardcoded app-menu-name typo** — gerbil `swift-native-probe.ss:226` + sbcl
  `swift-native-probe.lisp:163` passed `"Swift Native Probe"` (no hyphen) to the menu-install, diverging
  from the display name; racket/chez were correct. **Fixed in-grove (space→hyphen) + rebuilt** rather
  than folded into the suite ([[sample_apps_perfect]] + the drawing-canvas k140 chase-green precedent);
  the mandated Command-Q invariant is independent of the menu *title* and always held. **k85 must check
  `swift-native-method-probe` for the same pattern** (and settle its own-spec question).
- **Geometry splits by window SIZE (title-bar chrome), not content metrics:** chez+gerbil pixel-identical
  (560×272, close (696,221)); racket 560×268 **shares** that coordinate (lands in-button — the "measured,
  not assumed" pattern); sbcl 640×332 owns (656,206) in `run-values-sbcl.rkt`. A different split axis than
  the content-driven suites (where racket alone diverged).
- **Self-contained ×4, zero VM runtime provisioning**; **no AppSpec toolkit fix was forced** (the static
  window needs no new driver behaviour — the first richer-than-hello app to force none), so the
  exec-channel-stall / delayed-truncate residuals did not bite the 3-scenario suite (per-impl single
  invocation; racket solo — its embedded runtime boots slower).

## Decisions (running log)

Captured inline as each grilling question settles (driving.md running-log habit).

### Exploration findings (2026-06-26 — reframes the brief's core assumption)

The brief presumed an AppSpec would be a *grove-native* `.apiw` KDL entity with a
ws8 schema. Exploration + a user steer reveal an **established external project**
that already owns this concept:

- **`~/Development/AppSpec` is a real sibling project** (git remote
  `Linkuistics/AppSpec`), driven as its own grove. It is *"the single
  authoritative operational specification of an app's behaviour, written once and
  verified against every implementation end-to-end in a live macOS VM."* It owns:
  a **`#lang app-spec`** Racket DSL (scenarios authored as language source,
  ADR-0002), a **harness / driver / runner** (`runner/main.rkt`, `run.sh`) that
  installs a driver + executes scenarios, a **`testanyware-sdk`** that drives the
  live macOS VM through the `testanyware` CLI, and a **three-tier verification
  strategy** (hermetic unit → null-impl meaningful-failure smoke → live-VM
  shakedown, ADR-0004).
- **Its vocabulary is precise** (AppSpec `CONTEXT.md`): **App** (a native UI app,
  build-independent) · **Implementation/impl** (a concrete build under test,
  `--impl`; *avoid "target"*) · **Scenario** (one verifiable behaviour, a
  `#lang app-spec` file, impl-agnostic) · **Scenario suite** (an app's scenarios,
  colocated under `APIAnyware-MacOS/.../apps/<app>/scenarios/`) · **Contract**
  (conformance reqs every impl must satisfy — `logging-contract.md` +
  `observable-state.md`, which double as the porting guide) · **Driver / Harness /
  Runner**.
- **REFACTOR §34 already designates this as external + consumed:**
  `~/Development/AppSpec` for *target-independent app descriptions*,
  `~/Development/TestAnyware` for *behavioural/GUI test scripts*, and "APIAnyware
  should **consume or reference** these systems where appropriate." The LLM loop
  §34 spells out (read spec → read binding docs + idiom catalogue → generate impl →
  build → run TestAnyware → inspect → patch → repeat) **is** the user's stated
  vision (a spec detailed enough for an LLM to build the app in any language with
  testing as perfect feedback). §33 layer 8 = "AppSpec sample app tests".
- **Path drift the refactor created.** AppSpec's README + CONTEXT cite the
  *pre-refactor* homes: scenario suites at `APIAnyware-MacOS/knowledge/apps/<app>/`
  and per-impl `--impl` configs at `generation/targets/racket-oo/apps/<app>/`. The
  grove moved per-app prose docs to `apps/macos/<app>/docs/` (co-locate-docs-k9)
  and targets to `targets/<t>/`. Only **modaliser** has real scenario suites
  (`knowledge/apps/modaliser/`, on `main`); the grove's 9 sample apps have prose
  `spec.md` only (no `#lang app-spec` suites yet).
- **Three colliding "AppSpec" meanings to reconcile in the glossary:** (1) the
  external **AppSpec project** (the authority); (2) the grove briefs' loose use of
  "AppSpec" for "the common app-spec entity"; (3) the bundler Rust struct
  `apianyware_bundle_racket::AppSpec` (Info.plist/signing bundle config — unrelated).

Net: ws7 is **not** inventing a fresh `.apiw` AppSpec from scratch; it is homing /
referencing the **external AppSpec project's** app descriptions under
`apps/macos/<app>/`, reconciling them with the co-located prose, and (open) deciding
whether a thin grove-native structural manifest sits alongside. The grilling below
settles the relationship.

### D1 — Ownership: home + reference the external format (settled 2026-06-26)

**`apps/macos/<app>/` homes each app's target-independent AppSpec in the external
AppSpec project's own format; the grove does not reinvent it.** Each app dir holds
the **`#lang app-spec` scenario suite** (`scenarios/`), the per-app **contracts**
(`logging-contract.md` + `observable-state.md` — the porting guide every impl
satisfies), and a prose **description** (`docs/`). The external AppSpec runner
(`~/Development/AppSpec`) consumes this path over TestAnyware; **`#lang app-spec`
stays authoritative** and is **not** re-expressed as `.apiw`. **ws8 does not
schema-validate `#lang app-spec`** (the AppSpec project owns its reader/validation).

Consequences (collapses much of the brief's presumed scope):
- **No grove-native `.apiw` AppSpec entity, no `app.apiw` KDL schema, no focused
  in-crate validator crate.** The brief's "ws7 may author the AppSpec `.apiw` KDL
  Schema + validator" presumption is **dropped** — superseded by D1. ws7 is a
  *structural homing + reconciliation* workstream, not an entity-authoring one.
- ws7 **relocates** modaliser's scenario suite out of `knowledge/apps/modaliser/`
  into `apps/macos/modaliser/` and **repoints** the external AppSpec project's path
  references (`knowledge/apps/<app>/` → `apps/macos/<app>/`; per-impl `--impl`
  configs `generation/targets/racket-oo/` → `targets/<t>/app-implementations/...`).
  Changes *inside* the external AppSpec repo are seeded to the **AppSpec grove**
  (cross-grove inbox), not made by this grove — boundary confirmed in Q-boundary.
- The grove's 9 sample apps currently have prose `spec.md` only; promoting them to
  full `#lang app-spec` suites (the user's "detailed enough for LLM-build" vision)
  is the bulk of ws7's authoring.

### D2 — Scope: structure + full scenario suites for all sample apps (settled 2026-06-26)

**ws7's write-scope is the largest option: establish the AppSpec home structure +
relationship + reconciliation, AND author complete `#lang app-spec` scenario suites
for every sample app, each per-app live-VM-verified.** This realizes the user's
"perfect feedback / LLM-buildable in any language" vision in full (REFACTOR §34).

Finding: `knowledge/` in the main repo is **entirely untracked** — there are **no
committed scenario suites anywhere** in APIAnyware-MacOS today (AppSpec's `run.sh`
defaults to `../APIAnyware-MacOS/knowledge/apps/modaliser/scenarios/`, a dangling
path). So suite-authoring is greenfield, not relocation.

Decomposition implication (grove is for exactly this — a large effort split into
small VM-verified-per-app leaves; standing rule [[vm_verify_every_app]]):
- **Child 1 (this session): the structure/foundation** — the `apps/macos/` AppSpec
  layout + README defining the consume/reference relationship, prose reconciliation
  (`spec.md` → description; learnings → per-target impl-notes seam), glossary
  reconcile (adopt AppSpec vocab; flag the 3 "AppSpec" meanings), bundler
  display-name read repointed, external path-ref reconciliation. Skeleton-first: no
  suite yet.
- **Child 2: hello-window** — the first full `#lang app-spec` suite + contracts +
  live-VM-verify, the worked exemplar/template that proves the structure.
- **Children 3..N: one per remaining app** — full suite + contracts + VM-verify each
  (a leaf carries the VM-verify done-bar; CLI smoke never satisfies it).
- **Final child: portfolio index + conformance/coverage tie-in.**

### D3 — No machine manifest; structural facts as prose (settled 2026-06-26)

**No grove-native machine manifest.** The grove-domain structural facts — the
app↔app-kind binding (ADR-0049 instance side), the exercised pattern-kinds
(semantic coverage), the display-name — live in the **description prose** (a small
structured header in `docs/overview.md`). The **bundler reads the display-name from
the description's first H1** (as today, just repointed off `spec.md`). A machine
`app.apiw` manifest is **deferred** (constraint 4 — lazy): authored as its own leaf
only IF a real machine consumer materializes (e.g. the bundler projecting bundle
*type* from app-kind per ADR-0049, or `apianyware-conformance` computing pattern
coverage). Honors D1 (don't reinvent in `.apiw` without need).

### D2′ — REVISED: AppSpec is an external LLM-driven toolkit; the spec is *generated*, not hand-authored (settled 2026-06-26)

Two user steers reshaped D2. AppSpec (the project) is meant to be a **human-in-the-loop,
LLM-driven toolkit** with three capabilities (and **holds no app data**):
1. **reverse-gen** — point at an arbitrary app/impl → generate description/spec/PRD
   docs detailed enough to *reliably replicate* it (LLM-driven, human-annotated);
2. **forward-gen** — specs + best-practice guidelines + attack-vectors + patterns/
   anti-patterns → test suites that *correlate with* the specs (human-validated);
3. **run** — replay suites against any impl in a live VM (TestAnyware).
AppSpec will be *"largely dominated by prompts and workflows, rather than a lot of
coding of tools."* This mirrors APIAnyware's own **ws5 LLM side-channel** philosophy
(git is the propose→review→accept boundary; regenerable, annotated artifacts).

**Three-layer boundary:** **TestAnyware** (VM substrate) → **AppSpec** (LLM-driven
spec/test toolkit + formats, no app data) → **APIAnyware** `apps/macos/<app>/` (the
generated+annotated description/spec/PRD + generated+validated suites + contracts;
impls in `targets/<t>/app-implementations/`).

So the **earlier "all 9 suites" answer (D2) is superseded:** hand-authoring suites is
authoring the generator's *output* by hand. The durable human-adjacent artifact is the
**spec/PRD, LLM-generated from the existing implementation and human-validated** — and
this is do-able *now* in Claude Code (the LLM-driven tooling that already exists; the
standing economic constraint that LLM annotation runs inside Claude Code,
[[llm_annotation_constraint]]).

### D5 — ws7 is deliberately minimal; it builds the AppSpec grove + a pause point (settled 2026-06-26)

ws7 in *this* grove is deliberately minimal — it does **not** finalize a rigid
`apps/macos/` file format (that depends on what AppSpec settles a "formal spec" to be).
Its deliverables:
- **Foundation** — establish `apps/macos/` as the AppSpec-data home + the
  consume/reference **relationship** + the **data boundary** (ADR) + the reconciled
  **glossary**; keep it format-flexible. Bundler display-name read unchanged for now
  (keep `spec.md`; no premature rename → zero bundler churn).
- **Reverse-gen bootstrap** — LLM-generate the spec/PRD for the sample apps from their
  existing VM-verified impls (human-validated), starting with one worked exemplar that
  de-risks the AppSpec format.
- **Build the AppSpec grove** — author the AppSpec-toolkit seed/PRD (the D2′ vision)
  and seed/initialize the grove in `~/Development/AppSpec` (cross-grove via the
  `grove-meta` inbox). The AppSpec grove will be *"largely prompts + workflows."*
- **Pause point** — an ordinary leaf whose work is the hand-off: pause
  structural-refactoring, run the AppSpec grove to completion, resume here.
- **Deferred (post-pause)** — forward-gen test suites + AppSpec-runner VM-verify
  (depend on AppSpec tooling); finalize the `apps/macos/` layout once the format firms;
  the portfolio index + coverage tie-in.
- **Seeds to the AppSpec grove** — the generalized reverse/forward-gen, the spec/PRD
  format(s), and the **patterns/attack-vectors/guidelines interface** (which overlaps
  APIAnyware's own `semantic/pattern-kinds`, ws3 — flagged, not resolved here).

**ADR-0052** records the load-bearing decision (external toolkit + data boundary + no
grove-native `.apiw` AppSpec entity + the generated-spec model).

### Q4 finding — spec/impl-notes split is already largely correct (codebase-answered)

Exploration (not a user question — grilling.md "explore instead"): the split the
brief flagged is mostly already done. `apps/macos/<app>/docs/learnings.md` is
explicitly *"App-Universal Learnings — discoveries that apply regardless of which
target implements it"* (**target-independent → stays in `apps/`**);
`test-strategy.md` is a **TestAnyware validation checklist** (a prose precursor the
`#lang app-spec` scenario suite formalizes); and **per-target `learnings.md` already
exist** at `targets/<t>/app-implementations/macos/<app>/learnings.md` (ws6 homed the
realization notes). So ws7's reconciliation is a *mapping*, not a re-split:
`spec.md` → projection-free description; `test-strategy.md` → the scenario suite +
human expected-behaviour; app-universal `learnings.md` → kept. Per-target notes need
no move.

### Finalize decisions (`apps-layout-finalize-k84`, 2026-07-04)

The layout-finalize leaf settled the residual ws7 TODOs against the firmed AppSpec shape
(hello-window k64–k74; the eight-app portfolio k77–k83):

- **Canonical per-app shape** (all eight conform): `docs/{spec,logging-contract,
  observable-state,run-results}.md` + `scenarios/*.rkt` (`#lang app-spec`) +
  `run-values.rkt`. Optional, present only when earned: app-universal `learnings.md`,
  per-impl `run-values-<impl>.rkt`, `fixtures/`. Documented in `apps/macos/README.md`.
- **`test-strategy.md` retired** (all 3 — hello-window/ui-controls-gallery/mini-browser).
  The pre-AppSpec TestAnyware checklist is superseded by the executable scenario suite
  (behaviour) + `observable-state.md` (observable facts) + `run-results.md` (human
  expected-behaviour) — the k62 Q4 mapping. Refs repointed (CONTEXT.md doc-layout line,
  `reverse-gen-workflow.md` precursor list, the four per-target impl READMEs).
- **`learnings.md` kept-but-optional.** The brief's firmed shape lists it and does not
  flag it for retirement, but the mature practice (k77–k83) folded app-universal findings
  into `run-results.md`. Resolution: retire the two **empty stubs** (ui-controls-gallery,
  mini-browser — constraint-4 debris); keep hello-window's (real content, canonical
  exemplar; its one datum is also in `spec.md §3.8` — no information loss); document as
  optional.
- **Bundler read: keep `spec.md` H1** (the zero-churn decision, D5-consistent). `spec.md`
  is the firmed reverse-gen'd description home; every app has a correct display-name H1;
  all four bundlers stay green with no code change.
- **hello-window `(to confirm in-VM)` markers dropped** consistently across
  `scenarios/03-close-button-keeps-running.rkt`, `spec.md §3.8/§10`, and
  `observable-state.md` — the close-button "keeps running" expectation was confirmed on
  all four impls (k73/k74; fifth-app cross-check k80). ADR-0010 D4 licenses the drop; the
  `run-results.md` record keeps the evidence trail.
- **Residual for k85 / grove-finish:** the 19 per-target `app-implementations/*/README.md`
  are broadly stale (pre-refactor `generation/…` paths, unsubstituted `{{PROJECT}}`
  templates); only the retired-file references were repointed here (scope: `apps/macos/`
  layout). A ws6-domain README refresh is a separate concern.

## Notes

- Reference: `REFACTOR.md` §15 (common app specs), §7.8 (behavioural exemplar), §45.11
  (projection-free, one spec drives all targets); ADR-0049 (app-kinds, the category ws7's
  app-specs instantiate); the existing `apps/macos/<app>/docs/` material + `apps/macos/docs/`
  portfolio; the root brief **Platform-model outcomes** (ws7 seam) + **Target-model outcomes**
  (ws7 seam).
- The four targets each already ship VM-verified app-implementations; ws7 authors the **shared
  spec over them** + finalizes the structure — it does not re-port them.
- **Scope discipline:** ws7 is the *common* app-spec layer (`apps/macos/`). Per-target
  app-implementation work is ws6's (done); the AppSpec machine schema is ws8's; the AppSpec
  runner is ws9's. If runner or schema-tooling work surfaces, externalize it to its owning
  workstream, don't absorb it.
