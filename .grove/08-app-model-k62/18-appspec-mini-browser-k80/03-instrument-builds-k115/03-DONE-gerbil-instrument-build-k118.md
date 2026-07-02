# gerbil-instrument-build-k118

**Kind:** work

## Goal

Instrument the gerbil mini-browser impl to the k114 contracts and build the
standalone `.app` — the scenekit k109 pattern, mirroring the k116 racket
reference (parent brief child-1 entry carries the app-level shape + handoffs)
and the k117 chez sibling.

## Context

- Contracts + checklist: `apps/macos/mini-browser/docs/logging-contract.md` (foot).
  Impl: `targets/gerbil/app-implementations/macos/mini-browser/mini-browser.ss`.
- The k109 pattern: emitter inlined in the `.ss`, Gambit primitives only;
  startup + test-config no-op before the run; `applicationWillTerminate:`
  delegate → `reason=menu`.
- The k116 app-level shape to carry over (k117 realized it 1:1 in chez):
  current-url/current-title read helpers ("" when nil); `started` after the
  loading status set; `finished` after the whole §7.2 refresh reading the same
  history getters as the buttons; `failed` in the error-alert proc right after
  the message computation, before the modal; booleans as bare `true`/`false`
  bytes; env `MINI_BROWSER_EVENTS_LOG` / `MINI_BROWSER_TEST_CONFIG`, defaults
  under `/tmp/mini-browser/`.
- **Corpus inherited from k116** (WebKit collected + analyzed) but gerbil needs
  its own `apianyware-generate --target gerbil`, and the usual "`Trampolines.swift`
  regenerates git-clean → dylib current by construction" shortcut does **NOT**
  hold here (k116 handoff, confirmed by k117: WebKit grows the trampoline
  residual 170→174) — commit the trampoline diff if tracked and relink the
  gerbil adapter (`swift build --product`, never `--target`) before bundling.
- Gerbil build gotchas: the BOTTLE toolchain hardcodes gcc-15 while Homebrew
  ships gcc-16 — use the `/tmp/aw-gcc15-shim` symlink recipe if gxc fails with
  "gcc-15: command not found".
- Descriptor `mini-browser-impl.rkt`: `MiniBrowser-gerbil.app`,
  `com.linkuistics.mini-browser-gerbil`, same events/test-config paths.
- `file://` probe already answered (k80 brief) — do not re-probe.
- Smoke: launch via `open`, observe startup + launch line + a `[nav]` event in
  `/tmp/mini-browser/events.log`, AppleScript quit → `shutdown reason=menu`.
  NB gerbil's home URL is `example.com` (stays as realized — no alignment);
  on a networked host expect `started`→`finished` for that load.

## Done when

Checklist satisfied for gerbil; `MiniBrowser-gerbil.app` builds with the
conforming bundle id; CLI smoke green.

## Notes

No visible-behaviour change — launch-line remainder, loading-text spelling,
and the `example.com` home URL stay as realized.
