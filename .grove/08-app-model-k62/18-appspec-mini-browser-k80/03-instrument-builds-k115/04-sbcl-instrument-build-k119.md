# sbcl-instrument-build-k119

**Kind:** work

## Goal

Instrument the sbcl mini-browser impl to the k114 contracts and build the
standalone `.app` — the k101/k110 pattern, mirroring the k116 racket reference
(parent brief child-1 entry carries the app-level shape + handoffs) and the
k117/k118 siblings. Closes the node.

## Context

- Contracts + checklist: `apps/macos/mini-browser/docs/logging-contract.md` (foot).
  Impl: `targets/sbcl/app-implementations/macos/mini-browser/mini-browser.lisp`
  (+ existing `build.sh` / `dump.lisp` / `run.lisp`).
- The k110 pattern: sbcl carries the emitter as a **sibling `events.lisp`**
  (the dump.lisp load sequence includes it — sbcl has no gerbil/chez closure-walk
  constraint); startup + test-config no-op before the run;
  `applicationWillTerminate:` delegate → `reason=menu`.
- The k116 app-level shape to carry over (k117/k118 realized it 1:1): current-url/
  current-title read helpers ("" when nil); `started` after the loading status
  set; `finished` after the whole §7.2 refresh reading the same history getters
  as the buttons; `failed` in the error-alert proc right after the message
  computation, before the modal; booleans as bare `true`/`false` bytes;
  **`phase` normalized lowercase** `request`/`load` even though sbcl's status
  line capitalizes (`Load failed: …` stays as realized); env
  `MINI_BROWSER_EVENTS_LOG` / `MINI_BROWSER_TEST_CONFIG`, defaults under
  `/tmp/mini-browser/`.
- **This leaf owns the k114 `build.sh` seeds** (the scenekit k104-seed mirror):
  align `CFBundleIdentifier` to `com.linkuistics.mini-browser-sbcl` (today it
  writes the unsuffixed `com.linkuistics.mini-browser`) and add the
  kind-required `CFBundleInfoDictionaryVersion`.
- **Corpus inherited from k116** (WebKit collected + analyzed) but sbcl needs its
  own `apianyware-generate --target sbcl`; WebKit grows the trampoline residual
  170→174 (confirmed by k117 chez and k118 gerbil) — relink the sbcl adapter
  (`swift build --product APIAnywareSbcl`, never `--target`) **before** driving
  `dump.lisp` (the dumped image re-opens the dylib via `*shared-objects*`,
  ADR-0038/0041; bundle-sbcl vendors libzstd per k75).
- Descriptor `mini-browser-impl.rkt`: `MiniBrowser-sbcl.app`,
  `com.linkuistics.mini-browser-sbcl`, same events/test-config paths.
- `file://` probe already answered (k80 brief) — do not re-probe.
- Smoke: launch via `open`, observe startup + launch line + a `[nav]` event in
  `/tmp/mini-browser/events.log`, AppleScript quit → `shutdown reason=menu`.
  NB sbcl's home URL is `example.com` and its launch line is `Mini Browser
  opened. Type a URL + Return, navigate with ◀/▶/Reload. Quit with Cmd-Q.`
  (both stay as realized — the prefix rule covers the launch line); on a
  networked host expect `started`→`finished` for that load (`title=""` on the
  first finished is the contract's first-load title lag — k118 observed it for
  example.com).

## Done when

Checklist satisfied for sbcl; `MiniBrowser-sbcl.app` builds with the conforming
bundle id + `CFBundleInfoDictionaryVersion`; CLI smoke green. Retiring this leaf
leaves `instrument-builds-k115` with no live child — confirm the node done and
grow the k80 node's next stage (forward-gen-suite) per the k80 brief.

## Notes

No visible-behaviour change — launch-line remainder, status-phase capitalization,
and the `example.com` home URL stay as realized.
