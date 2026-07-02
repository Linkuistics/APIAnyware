# gerbil-instrument-build-k127

**Kind:** work

## Goal

Instrument the gerbil note-editor impl to the k123 contracts, build the `.app`, and
CLI-smoke it — mirror the k125/k126 reference pattern via the gerbil house style
(the mini-browser k118 twin: inline `ne-` emitter, startup + test-config no-op
before the run-loop entry, terminate hook).

## Context

- Contracts: `apps/macos/note-editor/docs/{logging-contract,observable-state}.md`;
  per-impl checklist at the logging contract's foot.
- Impl: `targets/gerbil/app-implementations/macos/note-editor/`; the gerbil
  mini-browser sibling carries the emitter/wiring house pattern to transplant.
- **k125/k126 handoffs (the reference pattern, held 1:1 at k126):**
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
    adapter dylib newer ⇒ current (racket/chez each verified 175 `@_cdecl`
    entries incl. WebKit; the k115 relinks stand). If anything regenerates,
    relink with `swift build --product APIAnywareGerbil` (never `--target`).
  - Smoke bar: launch via `open` → `startup` → `rendered placeholder=true
    chars=0` → launch line in `/tmp/note-editor/events.log`, AppleScript quit →
    `shutdown reason=menu`. The `[document]` events are **not host-reachable**
    (need UI interaction) — witness by code audit against the checklist;
    live-run exercises them.
- **gerbil standing gotchas:**
  - Importers of the webkit bindings need `(except-in … string-length)` (the
    generics-shadow gotcha, already in the impl learnings) — acutely relevant:
    the render helper's `chars` count uses the builtin `string-length`.
  - The bottle toolchain (ADR-0021) hardcodes gcc-15; Homebrew now ships gcc-16
    only — if gxc rebuilds break with "gcc-15: command not found", use the
    `/tmp/aw-gcc15-shim` symlink-to-gcc-16 fix.
- Descriptor `note-editor-impl.rkt` sibling: `#:bundle-id
  com.linkuistics.note-editor-gerbil`, `#:binary
  /Applications/NoteEditor-gerbil.app`, env vars
  `NOTE_EDITOR_{EVENTS_LOG,TEST_CONFIG}`, fixed defaults under
  `/tmp/note-editor/`.
- Launch-line remainder stays as realized (gerbil prints `Note Editor running.
  Close window or Ctrl+C to exit.` — the prefix rule).

## Done when

Checklist satisfied for gerbil; `NoteEditor-gerbil.app` builds with
`CFBundleIdentifier com.linkuistics.note-editor-gerbil`; CLI smoke green (startup /
initial rendered / launch line / shutdown reason=menu); learnings record any
deviation.

## Notes

No visible-behaviour change — logging/plist/build plumbing only.
