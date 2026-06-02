# 020-vm-verify-sample-apps

**Kind:** work

## Goal
VM-verify **every** chez sample app visually via TestAnyware — the grove's
done-bar (root BRIEF). The standalone `.app`s produced by leaf 010 are launched
in a macOS VM and observed to render and interact correctly. CLI smoke does
**not** satisfy this (standing rule `feedback_vm_verify_every_app`).

## Context
- Prereq: leaf 010 produced self-contained `.app` bundles for all 7 apps.
- VM provisioning + chunked upload + `open -n` launch recipe:
  memory `reference_testanyware_cli` (the in-repo general.md is stale; use the
  brew-installed `testanyware` + `testanyware llm-instructions`).
- The "visually perfect" bar (`feedback_sample_apps_perfect`): not just
  "window opens" — exercise double-click, edit, empty state, and the app's
  signature interaction per its purpose (e.g. note-editor edit+save,
  mini-browser navigation, drawing-canvas draw, ui-controls-gallery every
  control, scenekit/pdfkit render correctness).

## Done when
- Each of the 7 apps launches in the macOS VM and is observed (screenshot) with
  its window + signature interactions correct.
- Any visual regression traced to the de-Common / thread-safety changes is fixed
  (in the runtime or emitter), rebuilt (loops back through 010's build), and
  re-verified.
- If a single app needs deep per-app remediation, spin a dedicated follow-up
  leaf for it lazily rather than blocking the others.

## Notes
- Retiring this leaf empties node 040 → grove is ready to **Finish**. Per the
  loop + `feedback_grove_autonomous_pace`, propose the finish cycle and **wait
  for explicit user confirmation** before any teardown.
