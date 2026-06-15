# 060-build-sample-apps

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

## Done when

- All 7 apps built and VM-verified, each with a learnings + report artifact.

## Notes

- Decomposes per app (each app a leaf with its own VM-verify done-bar).
