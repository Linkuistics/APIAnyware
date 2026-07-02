# chez-instrument-build-k126

**Kind:** work

## Goal

Instrument the chez note-editor impl to the k123 contracts, build the `.app`, and
CLI-smoke it — mirror the k125 racket reference pattern via the chez house style
(the mini-browser k117 twin: inline `ne-` emitter, startup + test-config no-op
top-level before `(main)`, terminate hook).

## Context

- Contracts: `apps/macos/note-editor/docs/{logging-contract,observable-state}.md`;
  per-impl checklist at the logging contract's foot.
- Impl: `targets/chez/app-implementations/macos/note-editor/`; the chez
  mini-browser sibling carries the emitter/wiring house pattern to transplant.
- **k125 handoffs (the reference pattern):**
  - Emission points: `startup` before window/split-view construction; `rendered
    placeholder=<b> chars=<n>` immediately after every `loadHTMLString:` hand-off
    (hoist the placeholder? test in the render helper — event + body choice share
    it; `chars` = scalar count of the Markdown consumed); `dirty-changed` inside
    the clean→dirty flip arm, after the title refresh, **before** the re-render
    (first-keystroke order `dirty-changed` → `rendered`); `opened`/`saved`
    post-state at rule end — emitting at the end of the shared write routine puts
    the sheet-branch `saved` inside the completion handler by construction;
    `open-failed`/`save-failed` in the failure handlers after the status set,
    with the **attempted** path; `new` with literal `path="" dirty=false`;
    launch line dual-emitted; `shutdown reason=menu` in the
    `applicationWillTerminate:` hook. Fixed key orders `path`·`dirty` and
    `placeholder`·`chars`; booleans bare `true`/`false`.
  - **No corpus step:** verify (don't regenerate) — Trampolines git-clean +
    adapter dylib newer ⇒ current (racket verified 175 `@_cdecl` entries incl.
    WebKit; the k115 relink stands). If anything regenerates, relink with
    `swift build --product APIAnywareChez` (the k117 precedent).
  - Smoke bar: launch via `open` → `startup` → `rendered placeholder=true
    chars=0` → launch line in `/tmp/note-editor/events.log`, AppleScript quit →
    `shutdown reason=menu`. The `[document]` events are **not host-reachable**
    (need UI interaction) — witness by code audit against the checklist;
    live-run exercises them.
- Descriptor `note-editor-impl.rkt` sibling: `#:bundle-id
  com.linkuistics.note-editor-chez`, `#:binary /Applications/NoteEditor-chez.app`,
  env vars `NOTE_EDITOR_{EVENTS_LOG,TEST_CONFIG}`, fixed defaults under
  `/tmp/note-editor/`.
- Launch-line remainder stays as realized (chez prints `Note Editor running.
  Close window or Ctrl+C to exit.` — the prefix rule).

## Done when

Checklist satisfied for chez; `NoteEditor-chez.app` builds with
`CFBundleIdentifier com.linkuistics.note-editor-chez`; CLI smoke green (startup /
initial rendered / launch line / shutdown reason=menu); learnings record any
deviation.

## Notes

No visible-behaviour change — logging/plist/build plumbing only.
