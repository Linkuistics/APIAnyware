# build-sample-apps-k25 — brief

**Kind:** work

## Goal

Implement the standard 7-app sample ladder (guide Step 7, `docs/apps/_index.md`)
under `generation/targets/sbcl/apps/<app>/`, **written against the CL-family
interface contract** (so the source is portable to future CL impls): hello-window
→ ui-controls-gallery → scenekit-viewer → pdfkit-viewer → mini-browser →
note-editor → drawing-canvas. **Every app gets a dedicated TestAnyware VM
verification** — CLI smoke never satisfies the bar (sample apps must be visually
perfect: double-click, edit, empty-state all matter). Record
`apps/<app>/learnings.md` + `test-results/<app>/report.md` per app.

## Context

Needs the emitter (040) + runtime (050) working. Use TestAnyware (the unified VM
driver) per the project testing methodology; never run GUI apps from the CLI.
Apps are written against the CL-family contract (ADR-0033 / contract spec); any
app-level **background compute runs on `sb-thread`, not foreign threads**
(ADR-0035 — SBCL-native threads run concurrent Lisp safely; foreign callbacks are
bounced to main by the runtime), and non-runloop loops wrap in
`with-autorelease-pool` (ADR-0036). The `swift-native-probe` app (the §6d-invariant
exemplar) verifies the trampoline lower layer end-to-end, as for racket/chez/gerbil.

## Done when

- All 7 ladder apps + the `swift-native-probe` exemplar built and VM-verified,
  each with a learnings + report artifact.

## Decomposition

**010-design-generic-naming-and-typed-init** *(planning — inserted 2026-06-21)* —
resolve the two cross-cutting blockers `020-hello-window` surfaced on the first real
multi-framework load: (B1) cross-framework generic arity collisions (`foo`/`foo:`
kebab to one incongruent `ns:foo` → CLOS rejects at load; user leans **collision-rename
the action**) and (B2) typed multi-arg ObjC inits not wired (`make-instance` only does
0/1-arg id inits; `NSWindow`'s designated init can't be built). ADR(s) + contract §3.2
amendment + emitter/runtime fix leaves. Gates the whole ladder.

Ladder order from the goal, with the §6d trampoline exemplar front-loaded:

- **020-hello-window** — proves the whole pipeline end-to-end on pure-ObjC API
  (generate → `swift build` dylib → load in SBCL → window+label → VM-verify);
  the canonical first smoke. The repeatable green baseline is the 050 runtime
  smoke (`run-integration-smoke.sh`, all green 2026-06-21). *(Pipeline bootstrap +
  dev loader already stood up 2026-06-21; blocked on 010.)*
- **030-swift-native-probe** — the §6d-invariant exemplar; verifies the
  Swift-native **trampoline** lower layer end-to-end in a *loaded* app (the
  function/const/value-opaque/class-owner-method+init shapes 045/050 wired),
  before any GUI app depends on it. (Value-struct residual is the parked 090
  leaf; async-method trampolines deferred by design.)
- **040-ui-controls-gallery** — 15+ AppKit controls, enum constants, layout.
- **050-scenekit-viewer** — SceneKit 3D, SCNAction, scene graph.
- **060-pdfkit-viewer** — PDFView/PDFDocument, framework notifications.
- **070-mini-browser** — WKWebView, WKNavigationDelegate (async multi-step).
- **080-note-editor** — NSTextView/NSSplitView/WKWebView preview, undo, panels.
- **090-drawing-canvas** — dynamic ObjC subclass with `drawRect:`+mouse events,
  CoreGraphics, NSColorPanel (exercises `define-objc-subclass`/`-method`).

## Notes

- Each app a leaf with its own TestAnyware VM-verify done-bar
  (`feedback-vm-verify-every-app`); CLI smoke never satisfies it.
- Per-app artifacts: `apps/<app>/{source.lisp, build.sh, README.md,
  learnings.md}` + `test-results/<app>/report.md`. Source written against the
  CL-family contract (ADR-0033) for portability.
