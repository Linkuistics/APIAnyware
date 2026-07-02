# instrument-builds-k124

**Kind:** work (expected to decompose on entry — one instrument+build child per impl,
the k106/k115 split; racket first as the reference pattern, siblings mirror it)

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
