# instrument-builds-k124 — brief

**Kind:** node (decomposed on entry 2026-07-03 — one instrument+build child per impl,
the k106/k115 split; racket first as the reference pattern, siblings mirror it;
children materialized lazily, grow the next as each retires)

## Children

1. `racket-instrument-build-k125` ✅ *(done 2026-07-03)* — the reference pattern
   (events.rkt + wiring + descriptor + self-contained build.sh; the mini-browser
   k116 twin). The no-corpus-step expectation held: Trampolines.swift git-clean
   with the adapter dylib rebuilt after it ⇒ k115 relink current, nothing
   regenerated (175 `@_cdecl` entries incl. WebKit — the brief's "174" was a
   different counting convention; source-clean + fresh-dylib is the operative
   verify). App-level shape the siblings mirror: single 6-event `emit-document`
   (fixed key order `path`·`dirty`, `(or path "")` for unset) +
   `emit-preview-rendered` (`placeholder`·`chars`); hoist `placeholder?` in the
   render helper (event + body choice share it; `chars` = `string-length` of the
   Markdown consumed); `dirty-changed` inside the flip arm after the title
   refresh, **before** the re-render; `opened`/`saved` at rule end — emitting at
   the end of the shared write routine puts the sheet-branch `saved` inside the
   completion handler by construction; failure events in the handlers after the
   status set with the attempted path; `new` with literal `""`/`false`.
   CLI smoke green: exact launch sequence `startup` → `rendered placeholder=true
   chars=0` → bare launch line; AppleScript quit → `shutdown reason=menu`; no
   stray events. **The `[document]` events are not host-reachable** (all need UI
   interaction — typing/panels/alert) — per-impl bar is code-audit against the
   checklist + the lifecycle/preview smoke; live-run exercises the rest.
   `NoteEditor-racket.app` 92M, `com.linkuistics.note-editor-racket`.
2. `chez-instrument-build-k126` ✅ *(done 2026-07-03)* — the k125 pattern held
   1:1 via the mini-browser k117 house style (inline `ne-` emitter; terminate-
   hook app delegate; startup + test-config no-op top-level before `(main)` —
   the R6RS body rule lands `startup` before window construction for free).
   No corpus step confirmed again: Trampolines git-clean + dylib newer, 175
   `@_cdecl` entries. `NoteEditor-chez.app` 5.7M,
   `com.linkuistics.note-editor-chez`; CLI smoke green (exact launch sequence,
   AppleScript quit → `shutdown reason=menu`, no stray events); `[document]`
   events witnessed by code audit (not host-reachable).
3. `gerbil-instrument-build-k127` ✅ *(done 2026-07-03)* — the k125/k126
   pattern held 1:1 via the gerbil house style (mini-browser k118 twin:
   inline `ne-` emitter riding the statically-linked prelude; terminate-hook
   delegate; startup + test-config no-op top-level before `(main)`). **The
   `string-length` shadow fired as predicted**: the regenerated wkwebview.ss
   exports the flattened `stringLength` generic, so the import takes
   `(except-in … string-length)` (the pre-k116 source would no longer run
   unfixed). No corpus step confirmed (third time): Trampolines git-clean +
   dylib newer, 175 `@_cdecl` entries; gcc-15 resolves on PATH (Homebrew
   symlink → gcc-16), the shim never needed. `NoteEditor-gerbil.app` 64M,
   `com.linkuistics.note-editor-gerbil`; CLI smoke green (exact launch
   sequence, AppleScript quit → `shutdown reason=menu`, no stray events);
   `[document]` events witnessed by code audit (not host-reachable).
4. `sbcl-instrument-build-k128` ✅ *(done 2026-07-03)* — the k125–k127 pattern
   held 1:1 a **fourth** time via the sbcl house style (mini-browser k119 twin:
   separate pure-CL events.lisp / `ne-events` nickname; terminate-hook delegate
   via `set-delegate_`; startup + test-config no-op gated `when run` before
   construction; single-writer holds — the sheet completion's block bounce is a
   main-thread pass-through, ADR-0035/0036). **Delivered the k123 `build.sh`
   seeds by moving to the production bundler** (ADR-0041, the k119 mirror; the
   060-era /tmp-staged wrap retired): `CFBundleIdentifier
   com.linkuistics.note-editor-sbcl` + `CFBundleInfoDictionaryVersion` (6.0);
   `NoteEditor-sbcl.app` 92M **travels alone** (stub launcher + vendored
   libzstd/libAPIAnywareSbcl — the VM needs nothing staged). No corpus step
   confirmed (fourth time): Trampolines git-clean + dylib newer, 175 `@_cdecl`
   entries. CLI smoke green (exact launch sequence, sbcl's own launch-line
   remainder, AppleScript quit → `shutdown reason=menu`, no stray events);
   `[document]` events witnessed by code audit (not host-reachable).

## Goal

Instrument the four note-editor impls to the k123 contracts and rebuild each to a
launchable `.app`: the events.log emitter (`[lifecycle]`/`[document]`/`[preview]`
events per `apps/macos/note-editor/docs/logging-contract.md`), the
`applicationWillTerminate:` shutdown hook, test-config no-op handling, the impl
descriptor, and a self-contained `build.sh` — then CLI-smoke each on the host
(startup → rendered placeholder=true chars=0 → launch line; document flows as far as
host smoke reaches → shutdown reason=menu).

## Context

- Contracts: `apps/macos/note-editor/docs/{logging-contract,observable-state}.md`
  (k123); the conformance checklist at the contract's foot is the per-impl work list.
- Impls: `targets/<t>/app-implementations/macos/note-editor/` (racket/chez/gerbil/
  sbcl, all VM-verified pre-instrumentation).
- **Emission points** (contract): `startup` first record before window construction;
  `rendered` immediately after every `loadHTMLString:` hand-off (startup render
  included; keys `placeholder` `chars`); `dirty-changed` only on the §6.2 clean→dirty
  flip after the title refresh; `new`/`opened`/`saved` post-state at rule end —
  `saved` in both branches, sheet branch **inside the completion handler**;
  `open-failed`/`save-failed` with the **attempted** path after the status set;
  `shutdown` in the terminate hook. Booleans as bare `true`/`false`; unset path `""`.
- **Trampoline expectation:** note-editor's corpus (Foundation+AppKit+WebKit) matches
  mini-browser's — the k115 relinks (174 entries ×4) should already be current; verify
  rather than regenerate (gerbil's "`Trampolines.swift` git-clean → dylib current"
  shortcut applies only if nothing regenerates).
- **gerbil:** importers of the webkit bindings need `(except-in … string-length)`
  (the standing generics-shadow gotcha, already in the impl learnings).
- **sbcl `build.sh`:** align `CFBundleIdentifier` → `com.linkuistics.note-editor-sbcl`
  and add `CFBundleInfoDictionaryVersion` (verified missing at k123; the k104/k114
  mirror).
- Env vars: `NOTE_EDITOR_EVENTS_LOG` → `/tmp/note-editor/events.log`;
  `NOTE_EDITOR_TEST_CONFIG` → `/tmp/note-editor/test-config.scm`.
- Prior-app patterns: the k116–k119 mini-browser children (inline emitter; startup +
  test-config no-op top-level before `(main)`; terminate hook) — the shape transfers
  1:1; note-editor adds two new emission sites: the notification observer and the
  sheet completion handler.

## Done when

All four impls emit the full contract vocabulary (host CLI smoke witnesses startup /
rendered / launch line / the document events reachable without a VM / shutdown), each
bundles to a `.app` with the suffixed bundle-id, and per-impl learnings record any
deviation. Instrumentation changes no visible behaviour.
