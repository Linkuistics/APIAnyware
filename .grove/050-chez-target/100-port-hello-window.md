# 100-port-hello-window

**Kind:** work

## Goal
Port the `hello-window` sample app to chez. End-to-end pipeline
validation: a sample app's source compiles, bundles, launches, draws
its window, and passes TestAnyware. The simplest app, picked first per
the feature ladder.

## Context
- `generation/targets/racket/apps/hello-window/hello-window.rkt` —
  reference logic only; the chez version uses
  `(import (apianyware appkit) (apianyware foundation)
   (apianyware runtime cocoa))` instead of relative `(require …)`.
- Design spec §7 (feature ladder).
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
- First app: expect runtime / emitter bugs to surface. Fix them in the
  appropriate leaf's location, regenerate, retest.
- Use exactly the same window size, title, font, and label text as the
  racket version — symmetry is a checkable property.
