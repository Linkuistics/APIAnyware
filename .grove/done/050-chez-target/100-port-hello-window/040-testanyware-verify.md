## 040-testanyware-verify

**Kind:** work

## Goal
Visually verify the chez `hello-window` `.app` in the macOS VM via
TestAnyware. CLI smoke is not enough — per
[[feedback-use-testanyware]] GUI apps must be exercised in the VM, and
per the policy that every app port gets a VM-verify leaf before its
node retires.

## Inputs
- `030-port-hello-window-app.md` (retired) produced
  `generation/targets/chez/apps/hello-window/build/Hello Window.app`
  via `cargo run --example bundle_app -p apianyware-macos-bundle-chez
  -- hello-window`. Unbundled and bundled `chez --script` both enter
  `[NSApp run]` cleanly from the CLI.
- Two emit-chez bugs were fixed during 030 — per-framework facade now
  at `apianyware/<fw>.sls`, class libraries now load their framework
  dylib at instantiation. If verification fails, the working hypothesis
  is something else still latent (not a regression from those fixes).
- Cross-target spec: `knowledge/apps/hello-window/spec.md` (title
  "Hello from {Language}" — for chez "Hello from Chez", label
  "Hello, macOS!", 400×200 centred window, 24pt system font).

## Context
- TestAnyware is the unified GUI driver — the old
  guivision/GUIVisionVMDriver split has been retired/absorbed.
- The racket `hello-window` already passes TestAnyware; use the same
  test artifacts as the bar, adjusted for the chez bundle path.
- [[feedback-sample-apps-perfect]]: visual perfection bar, not just
  compile+window — title text, label centred, close button works,
  no unbounded memory growth in Activity Monitor.

## Done when
- TestAnyware run is green for the chez `hello-window` (same bar as
  the racket version).
- Manual visual check (or TestAnyware screenshot diff) confirms the
  centred 24pt "Hello, macOS!" label and the "Hello from Chez" window
  title.
- Close-button closes the window and the app exits cleanly.
- Activity Monitor shows no unbounded memory growth during a brief
  hold-open test.
- Any defects surfaced are either fixed-at-source (emitter / runtime /
  app file, regenerate, retest) or recorded as new leaves with clear
  reproduction notes.

## Notes
- The `.app` is freshly bundled — if you've rebuilt the chez tree
  since 030, re-run `cargo run --example bundle_app -p
  apianyware-macos-bundle-chez -- hello-window` before testing.
- If TestAnyware tooling isn't ready for chez yet, this leaf may itself
  decompose: one sub-leaf to wire chez into the harness, one to run
  the test.
