# sbcl-instrument-build-k128

**Kind:** work

## Goal

Instrument the sbcl note-editor impl to the k123 contracts, build the `.app`, and
CLI-smoke it — mirror the k125/k126/k127 reference pattern via the sbcl house style
(the mini-browser k119 twin) — **and deliver the k123 `build.sh` seeds** (this impl's
build today writes the unsuffixed bundle-id and omits `CFBundleInfoDictionaryVersion`).

## Context

- Contracts: `apps/macos/note-editor/docs/{logging-contract,observable-state}.md`;
  per-impl checklist at the logging contract's foot.
- Impl: `targets/sbcl/app-implementations/macos/note-editor/`; the sbcl
  mini-browser sibling carries the emitter/wiring house pattern to transplant.
- **k125/k126/k127 handoffs (the reference pattern, held 1:1 three times):**
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
  - **No corpus step:** verify (don't regenerate) — Trampolines.swift git-clean +
    adapter dylib newer ⇒ current (racket/chez/gerbil each verified 175 `@_cdecl`
    entries incl. WebKit; the k115 relinks stand). If anything regenerates,
    relink with `swift build --product APIAnywareSbcl` (never `--target`).
  - Smoke bar: launch via `open` → `startup` → `rendered placeholder=true
    chars=0` → launch line in `/tmp/note-editor/events.log`, AppleScript quit →
    `shutdown reason=menu`, no stray events. The `[document]` events are **not
    host-reachable** (need UI interaction) — witness by code audit against the
    checklist; live-run exercises them.
- **sbcl `build.sh` seeds (verified at k123 — the k104/k114 mirror):** align
  `CFBundleIdentifier` → `com.linkuistics.note-editor-sbcl` (today unsuffixed
  `com.linkuistics.note-editor`) and add the kind-required
  `CFBundleInfoDictionaryVersion`.
- **Launch-line remainder stays as realized** (sbcl prints `Note Editor opened.
  Type Markdown on the left; preview renders on the right. Quit with Cmd-Q.` —
  the prefix rule; contract asserts only the `Note Editor` prefix). The emitter's
  dual-emitted launch line must match sbcl's own realized line, not the scheme
  targets'.
- Descriptor `note-editor-impl.rkt` sibling: `#:bundle-id
  com.linkuistics.note-editor-sbcl`, `#:binary
  /Applications/NoteEditor-sbcl.app`, env vars
  `NOTE_EDITOR_{EVENTS_LOG,TEST_CONFIG}`, fixed defaults under
  `/tmp/note-editor/`.
- **sbcl lifetime note (ADR-0036):** the emitter writes from AppKit main-thread
  entry points only (the k119 single-writer discipline) — no finalizer-thread
  emission.

## Done when

Checklist satisfied for sbcl; `NoteEditor-sbcl.app` builds with
`CFBundleIdentifier com.linkuistics.note-editor-sbcl` +
`CFBundleInfoDictionaryVersion`; CLI smoke green (startup / initial rendered /
launch line / shutdown reason=menu); learnings record any deviation.

## Notes

No visible-behaviour change — logging/plist/build plumbing only. This is the last
instrument+build child; on its retirement the `instrument-builds-k124` node closes
and the next stage (forward-gen-suite) grows on `appspec-note-editor-k81`.
