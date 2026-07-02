# chez-instrument-build-k117

**Kind:** work

## Goal

Instrument the chez mini-browser impl to the k114 contracts and build the
standalone `.app` — the scenekit k108 pattern, mirroring the k116 racket
reference (parent brief child-1 entry carries the app-level shape + handoffs).

## Context

- Contracts + checklist: `apps/macos/mini-browser/docs/logging-contract.md` (foot).
  Impl: `targets/chez/app-implementations/macos/mini-browser/mini-browser.sls`.
- The k108 pattern: emitter inlined in the `.sls` (no separate module), app-prefixed
  names; startup + test-config no-op top-level before `(main)`;
  `applicationWillTerminate:` delegate → `reason=menu`.
- The k116 app-level shape to carry over: current-url/current-title read helpers
  ("" when nil); `started` after the loading status set; `finished` after the
  whole §7.2 refresh reading the same history getters as the buttons; `failed`
  in the error-alert proc right after the message computation, before the modal;
  booleans as bare `true`/`false` bytes; env `MINI_BROWSER_EVENTS_LOG` /
  `MINI_BROWSER_TEST_CONFIG`, defaults under `/tmp/mini-browser/`.
- **Corpus inherited from k116** (WebKit collected + analyzed) but chez needs its
  own `apianyware-generate --target chez` + `APIAnywareChez` relink
  (`swift build --product APIAnywareChez`) before bundling — WebKit grows the
  trampoline residual 170→174, so the git-clean dylib shortcut does NOT hold.
- Descriptor `mini-browser-impl.rkt`: `MiniBrowser-chez.app`,
  `com.linkuistics.mini-browser-chez`, same events/test-config paths.
- `file://` probe already answered (k80 brief) — do not re-probe.
- Smoke: launch via `open`, observe startup + launch line + a `[nav]` event in
  `/tmp/mini-browser/events.log`, AppleScript quit → `shutdown reason=menu`.

## Done when

Checklist satisfied for chez; `MiniBrowser-chez.app` builds with the conforming
bundle id; CLI smoke green.

## Notes

No visible-behaviour change — launch-line remainder, `Loading...` spelling, and
the `www.apple.com` home URL stay as realized.
