# 030-port-hello-window-app

**Kind:** work

## Goal
Port the `hello-window` sample app to chez. End-to-end pipeline
validation: a sample app's source compiles, bundles, launches, draws
its window, and passes TestAnyware. The simplest app, picked first per
the feature ladder.

## Inputs
- Leaf `010` has lifted the emit-chez struct-by-value restriction —
  `make-nswindow-init-with-content-rect-style-mask-backing-defer` and
  `make-nstextfield-init-with-frame` are emitted.
- Leaf `020` has settled how chez resolves `(import (apianyware …))`
  for unbundled and bundled runs. Whatever the chosen scheme, this
  leaf takes it as given — do not re-grill loading here.

## Context
- `generation/targets/racket/apps/hello-window/hello-window.rkt` —
  reference logic only; the chez version uses
  `(import (apianyware appkit) (apianyware foundation)
   (apianyware runtime cocoa))` instead of relative `(require …)`.
- Design spec §7 (feature ladder).
- `knowledge/apps/hello-window/spec.md` — the cross-target spec
  (title "Hello from {Language}", label "Hello, macOS!", 400×200
  centred window, 24pt system font, centred alignment).
- [[feedback-use-testanyware]] — UI verification runs in the macOS VM
  driver, not from the CLI.
- [[feedback-sample-apps-perfect]] — visual perfection bar; budget
  polish time, not just compile+window.

## Done when
- `generation/targets/chez/apps/hello-window/hello-window.sls` exists
  and follows the design-spec idiom (`define-entry-point` for `main`,
  `(import (apianyware appkit) …)`, no `(require …)`).
- `bundle-chez hello-window` produces a runnable `.app`.
- TestAnyware run is green for the chez `hello-window` (same bar as
  racket's hello-window).
- The .app launches, draws the window with the centred label, accepts
  the close button, exits cleanly. Activity Monitor shows no
  unbounded memory growth.
- The app's README at
  `generation/targets/chez/apps/hello-window/README.md` mirrors the
  racket app's README (one paragraph: what it exercises).

## Notes
- First app: leaves 010 and 020 absorb the structural blockers
  surfaced during the original attempt. Any further runtime/emitter
  bugs that come up still get fixed at their source per the parent
  brief's guidance — regenerate, retest.
- Use exactly the same window size, font, and label text as the
  racket version. The title follows the cross-target convention
  "Hello from {Language}" — for chez that's "Hello from Chez".
