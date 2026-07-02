# sbcl-instrument-build-k92

**Kind:** work

## Goal

Instrument the **sbcl** ui-controls-gallery impl to the k87 contracts and rebuild it as a
launchable `.app` — the biggest delta of the four: the impl today has **no** target-action
wiring for checkbox/slider/stepper (constructor `nil`/`""` slots) and the radio pair relies
on platform sibling-grouping with no shared action. Add a real shared radio action + the
three new target-actions, the events emitter (lifecycle + the four `[controls]` events with
the contract's string quoting), `build.sh`, and the `#lang app-spec/impl` descriptor.

## Context

- Contracts: `apps/macos/ui-controls-gallery/docs/{logging-contract,observable-state}.md`;
  env/paths `UI_CONTROLS_GALLERY_{EVENTS_LOG,TEST_CONFIG}` →
  `/tmp/ui-controls-gallery/{events.log,test-config.scm}`.
- Templates: `targets/sbcl/app-implementations/macos/hello-window/` (k71 pattern —
  `events.lisp` exists as a separate module there; mirror its shape) and the done siblings
  k89/k90/k91 (emit placement, post-state semantics, checkbox switch-toggles-before-action,
  quoting; each verified its emitter in isolation against the contract matchers — for sbcl
  drive the emitter under plain `sbcl --script`).
- **Radio note (contract):** sbcl conforms via the platform's sibling-group exclusion (same
  superview + shared action) — the shared action's job is the `radio-selected` emit naming
  the sender's title; no explicit sibling-clearing needed (either realization conforms).
- **Checkbox initial state:** sbcl launches its checkbox ON (a spec §6 hole the contract
  tolerates) — the toggle scenario asserts a flip, never a fixed on/off sequence; do not
  "fix" the initial state (instrumentation must not change visible behaviour).
- Names: `UIControlsGallery-sbcl.app` / `com.linkuistics.ui-controls-gallery-sbcl`;
  descriptor mirrors the chez/gerbil ones with `(SBCL)` naming.
- Gotchas: `sb-ext:finalize` runs off-main — but the emitter writes only from main-thread
  action callbacks + the terminate path, so the single-writer story holds (ADR-0035/0036);
  hello-window k71's build.sh writes Info.plist itself (the sbcl bundler case — no
  PlistBuddy rename dance; check and mirror).

## Done when

Emitter verified in isolation against the contract matchers; `.app` built via `build.sh`
with the contract bundle id; descriptor authored; `learnings.md` updated; committed. Live
launch is the Tier-2 leaf's bar (no host GUI launch — [[use_testanyware]]).

## Notes

Last instrument+build child — on retire the k88 node has no live leaf: confirm node-done
with the user (or proceed per the autonomous-pace steer), promote anything durable, and
grow the k77 node's next stage (forward-gen scenario suite + `run-values.rkt`).
