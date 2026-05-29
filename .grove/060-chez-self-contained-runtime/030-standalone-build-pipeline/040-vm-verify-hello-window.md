# 040-vm-verify-hello-window

**Kind:** work

## Goal
The node's done-bar: prove the standalone `hello-window` `.app` built by
`bundle_app_standalone` **launches and draws its window on a macOS VM with no
Chez Scheme installed** — the whole point of node `060`. CLI/local launch does
not satisfy this ([[feedback-vm-verify-every-app]]).

## Context
- Driver: `testanyware` (brew-installed); recipe in
  [[reference-testanyware-cli]] — VM start, chunked upload of the `.app`
  (or a `.tgz`), `xattr -dr com.apple.quarantine`, `open -n`, screenshot.
- No-Chez precondition: confirm the VM has no Chez —
  `which chez scheme petite` empty, `/opt/homebrew/bin/chez` absent — exactly as
  the spike's VM evidence established. The shipped `.app` must not reach for a
  system Chez.
- The spike already proved a *hand-built* standalone draws in a no-Chez VM; this
  leaf proves the **bundler-built** one does, end to end.

## Done when
- The `bundle_app_standalone` `Hello Window.app` is uploaded to a clean macOS VM
  with no Chez installed and launches via `open -n`.
- A screenshot shows the window with the centred "Hello, macOS!" label and the
  menu-bar app name "Hello Window" (from `CFBundleName`, not "chez").
- No `Chez Scheme Version …` banner / no system-Chez dependency observed.
- Evidence (screenshot + the no-Chez check transcript) captured under
  `docs/research/` or the app's build dir and referenced from the commit.
- On green, this leaf retires and — with `010`–`030` done — node `030` is
  complete; promote any durable gotchas into `chez.md`/the spec before the node
  retires.

## Notes
- [[feedback-sample-apps-perfect]] applies even to hello-window: the window must
  look right (centred label, correct title bar), not merely appear.
- If launch fails in the VM (works locally), suspect signing/quarantine or a
  dylib-path/prelude issue surfacing only without a dev Chez present — debug
  against the spike's known-good VM recipe.
- [[feedback-use-testanyware]], [[feedback-regenerate-pipeline-aggressively]].
