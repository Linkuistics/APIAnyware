# racket-instrument-build-k125

**Kind:** work

## Goal

Instrument the racket note-editor impl to the k123 contracts, build the
self-contained `.app`, and CLI-smoke it on the host — the reference pattern the
three sibling impls mirror (the mini-browser k116 twin, minus the corpus step).

## Context

- Contracts: `apps/macos/note-editor/docs/{logging-contract,observable-state}.md`;
  the per-impl checklist at the logging contract's foot is the work list. Events:
  `[lifecycle] startup` / the bare launch line beginning `Note Editor` (dual
  emission, keep stdout) / `[lifecycle] shutdown reason=<menu|signal|error>`;
  `[preview] rendered placeholder=<b> chars=<n>` immediately after **every**
  `loadHTMLString:` hand-off (startup render included; `chars` = Unicode scalar
  count of the Markdown the render consumed); the six `[document]` events with
  fixed key order `path` `dirty` (booleans bare `true`/`false`, unset path `""`) —
  `new`/`opened`/`saved` post-state at rule end (`saved` in **both** branches, the
  sheet branch **inside the completion handler** — in racket that falls out of
  emitting at the end of `write-current-file!`, which the completion lambda
  calls), `open-failed`/`save-failed` with the **attempted** path after the
  status set, `dirty-changed` on the §6.2 clean→dirty flip only, after the title
  refresh (inside the observer's `unless dirty?` arm, before `refresh-preview!`
  so the first-keystroke order `dirty-changed` → `rendered` holds). Env vars
  `NOTE_EDITOR_EVENTS_LOG` / `NOTE_EDITOR_TEST_CONFIG`, fixed defaults under
  `/tmp/note-editor/`.
- Impl (bare today — source + learnings only):
  `targets/racket/app-implementations/macos/note-editor/note-editor.rkt`. The
  failure plumbing already routes through `load-file!`/`write-current-file!`
  handlers (status set in each) — the emission points slot in cleanly; the app
  currently installs **no** delegate, so the `applicationWillTerminate:` hook is
  additive (the prior five apps' pattern).
- Reference pattern (mini-browser k116): sibling `events.rkt` (path resolve /
  truncate-open line-buffered / quote-string / bare booleans) + top-of-module
  wiring (events-init! + startup before construction; test-config env no-op;
  uncaught-exception-handler → signal/error; app delegate → reason=menu) +
  self-contained `build.sh` (k76 bundler + post-mv PlistBuddy re-sign to
  `com.linkuistics.note-editor-racket` / `NoteEditor-racket.app`) + the
  `note-editor-impl.rkt` descriptor (`#:binary /Applications/NoteEditor-racket.app`).
- **No corpus step (k115 handoff):** note-editor's corpus (Foundation+AppKit+
  WebKit) matches mini-browser's; the k115 relinks (174 trampoline entries ×4)
  should be current — **verify** (generated webkit tree present, adapter dylib
  present/fresh), regenerate only if the verify fails.
- Smoke (per-impl bar; VM bar stays with live-run): launch via `open`, observe in
  `/tmp/note-editor/events.log` the deterministic launch sequence `startup` →
  `rendered placeholder=true chars=0` → the bare launch line, AppleScript quit →
  `shutdown reason=menu`. The `[document]` events all need UI interaction (typing,
  panels) — **not reachable by host smoke**; they are witnessed by code-audit
  against the checklist here and exercised for real at live-run.

## Done when

Checklist satisfied for racket; `NoteEditor-racket.app` builds with
`CFBundleIdentifier com.linkuistics.note-editor-racket`; CLI smoke green
(startup / initial rendered / launch line / shutdown reason=menu); learnings
record any deviation.

## Notes

No visible-behaviour change (logging/plist/build plumbing only) — launch-line
remainder, status-line `<detail>` realizations (racket: exn-message), and the
`Opened ~a`/`Saved ~a` status spellings stay as realized.
