# conformance-data-k105

**Kind:** work

## Goal

The scenekit-viewer **conformance data**: `logging-contract.md` + `observable-state.md`
at `apps/macos/scenekit-viewer/docs/` — the porting-guide contracts every impl satisfies
(the hello-window k67 / ui-controls-gallery k87 / pdfkit-viewer k96 stage), derived from
the accepted reverse-gen spec (k104) and the four impls.

## Context

- Templates: `apps/macos/{hello-window,ui-controls-gallery,pdfkit-viewer}/docs/
  {logging-contract,observable-state}.md`.
- The k104 spec fixes the surface: launch diagnostic (line begins `SceneKit Viewer`),
  the four-item geometry popup (AX value = selected title), the `Colo…` button, the
  shared `Colors` panel, and Quit via ⌘Q. **The k104 verifiability finding drives the
  event vocabulary:** rendered-scene content (shape, colour, spin) is pixel-level and
  not AX-observable, and the closed verb set has no drag/pixel verb — so the key
  behaviours (geometry swap applied, colour changed + re-applied across swap) need
  **log events** to be assertable at all. Candidate vocabulary: lifecycle triad +
  `[scene] geometry-changed shape=<title>` + `[scene] color-changed rgb=<r,g,b>`
  (post-state emission; silent no-ops emit nothing — k77 lesson; lowercase `reason`,
  `shutdown reason=menu` as the exercised terminate path).
- Observable-state doc: window/AX structure (title, popup value, button title, panel
  window presence) is the AX-observable surface; the SCNView itself — check what AX
  element (if any) an SCNView exposes, a k96-style provisional-row concern for the
  live-run stage to firm.
- Seeded handoffs from k104: sbcl `build.sh` Info.plist lacks kind-required
  `CFBundleInfoDictionaryVersion` (align at instrument stage); conversion-failure
  divergence (majority keep-previous, sbcl stores-raw) — instrument stage may align.

## Done when

Both contract docs committed under `apps/macos/scenekit-viewer/docs/`, consistent with
the k104 spec and realizable by all four impls (the instrument-builds children will
implement them verbatim).

## Notes

Observable state captures popup selection + contract log events — never rendered
pixel contents (node brief).
