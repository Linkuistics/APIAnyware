# reverse-gen-k131

**Kind:** work

## Goal

Reverse-gen the projection-free, replication-grade **drawing-canvas spec** from the
four VM-verified impls, per the AppSpec reverse-gen workflow
(`~/Development/AppSpec/capabilities/reverse-gen/{workflow,prompt}.md`): dispatch the
read-only subagent, validate its modeling notes (anchor order: app-kind contract >
impl behaviour > human prose), and write the accepted spec to
`apps/macos/drawing-canvas/docs/spec.md` (replacing the precursor prose — the lowest
anchor). The commit is the propose→review→accept boundary (ADR-0050/0052).

## Context

- Inputs: impls at `targets/{racket,chez,gerbil,sbcl}/app-implementations/macos/
  drawing-canvas/` (sbcl carries extra build/run/dump scripts + a README); app-kind
  contract `platforms/macos/app-kinds/gui-app/kind.apiw`; precursor prose
  `apps/macos/drawing-canvas/docs/spec.md` (**spec.md only** — no `learnings.md` /
  `test-strategy.md` precursors, the k122 thin-anchor set); portfolio catalogue
  `apps/macos/docs/_index.md` (complexity = portfolio rank — drawing-canvas is
  **row 5 of 7**; the precursor's "most architecturally novel" framing is a claim to
  check, not a rank); pattern-kind registry `semantic/pattern-kinds/`; closed verb
  set `~/Development/AppSpec/app-spec/main.rkt`.
- Templates: `apps/macos/hello-window/docs/spec.md` (the k64 exemplar — H1 = display
  name for the bundlers; provenance line; §1 structural facts; behavioural-exemplar
  final § mapped to the closed scenario-verb set) and
  `apps/macos/scenekit-viewer/docs/spec.md` (the closest content-shape precedent —
  content surface unobservable to the AX/OCR verbs, state assertions carried by
  contract events + screenshots).
- Watch for stale-prose risks (the k86/k95/k104/k113/k122 lesson: precursor claims
  matching *no* impl get cut) — the precursor is **heavily racket-flavoured**
  (`runtime/dynamic-class.rkt`, `make-dynamic-subclass`, `add-method!`,
  `nsevent-location-in-window`, module-level-`define` IMP retention — all
  projections) and enumerates a racket-specific "API surface"; verify every layout /
  toolbar / stroke-model / colour / slider / clear claim against what the four impls
  actually realize.
- **App-specific:** note per impl the stroke data model (in-progress stroke vs
  committed list; what state a stroke carries — points, colour, width), what each
  gesture makes observable **today** (log lines? expected none — the k122 finding
  class; status/tool state surfaces?), the colour mechanics (NSColorPanel
  `setAction:`/`setTarget:` → RGB extraction; is the panel's shared/system nature
  witnessed?), slider continuity + range, Clear semantics (drops all strokes?
  redraw?), the empty launch state, window/canvas/toolbar geometry, and whether the
  custom view exposes any AX (expected: none — events + screenshots become the
  channels; that gap seeds the conformance child). Panel driver guidance (k112
  NSColorPanel practice) belongs in §13.

## Done when

`apps/macos/drawing-canvas/docs/spec.md` is the validated reverse-gen spec (first H1
bundler-safe — the display name), committed with the modeling notes reviewed;
unsupported claims grounded or cut, gaps honestly marked `(to confirm in-VM)`.

## Notes

The behavioural-exemplar section is the forward-gen input for the later suite child —
it should enumerate launch-empty-state, stroke draw (down/drag/up → visible stroke +
committed state), width change → subsequent strokes thicker, colour change →
subsequent strokes recoloured, multi-stroke accumulation, Clear → blank, and quit as
observable assertions where in-VM-verifiable ([[sample_apps_perfect]]). Where a
behaviour has no observable witness (stroke committed, tool state), that gap is a
finding, not a failure — it seeds the conformance/instrument children.

## Status — done 2026-07-03 (validated & accepted)

Subagent dispatched per the AppSpec workflow; modeling notes worked; load-bearing
witnesses mechanically re-verified against all four sources (window 640×480 /
toolbar 36 / min 400×300 ×4; control frames + `Color…` U+2026 titles; slider 1–20
init 2.0 continuous ×4; initial colour black + width 2.0 ×4; capture-at-mouse-down +
drag-flag guard + up-appends-nothing + clear-resets-flag ×4; round cap/join +
alpha 1.0 ×4; panel rewire-on-every-open + continuous + deviceRGB normalization +
nil-guards ×4; menu = standard helper ×3 vs sbcl inline `Quit ~A`/Cmd-Q; no app
delegate / no `applicationShould*` ×4; stdout is the launch line ONLY — all other
diagnostics are stderr). **Zero discrepancies; spec accepted with one editorial fix**
(a garbled `deviceRGBColorSpaceColorSpace` token in §11). Key acceptances:

- **Complexity 5/7** from the catalogue row (the precursor's "most architecturally
  novel" framing is prose, not rank).
- **Conflicts resolved:** toolbar height 36 beats the precursor's "32-point" claim
  (impl behaviour wins, app-kind silent); close-to-quit cut — the app-kind's
  `ns-application-terminate` wins over the ×3 printed "Close window or Ctrl+C"
  guidance (the hello-window correction repeated; close-button consequence carried
  as an in-VM gap); the precursor's racket projections cut (`make-dynamic-subclass`,
  module-level-`define` IMP retention, parent-encoding lookup — chez explicitly
  contradicts two of them).
- **Verb-set honesty verified:** the closed set (`main.rkt` provides) has **no
  mouse-drag verb and no pixel-comparison verb** — scenekit's k112 drag was
  TestAnyware `input drag` at run level, outside the scenario language. The spec
  says so; stroke-content assertions are spec prose pending a drag/pixel-capable
  driver.
- **Unsupported items handled:** RGB-component-exception lore + round-cap-dot
  mechanism attributed as recorded impl rationale (not platform fact); the
  panel-holds-key first-click question left to §13/live-run (the k112
  `acceptsFirstMouse` finding will govern).
- **Handoff to conformance/instrument children:** launch-line prefixes diverge
  (`running.` ×3 vs sbcl `opened.` — the standing prefix rule applies); **the app
  emits NO per-operation log lines** — strokes/colour/width/clear are all silent
  and the canvas is expected AX-invisible, so stroke lifecycle + tool state need
  contract log events to be assertable at all (the scenekit `[scene]` channel
  mirror, flagged in the spec as visual-only today); two impls carry a stderr
  `colorChanged:` diagnostic the contract may standardize or drop; screenshots are
  the only canvas-content channel (visual bar = artifact review).
