# racket-instrument-build-k116

**Kind:** work

## Goal

Instrument the racket mini-browser impl to the k114 contracts, build the
self-contained `.app`, CLI-smoke it, and run the `file://` renderability probe —
the reference pattern the three sibling impls mirror (the scenekit k107 twin).

## Context

- Contracts: `apps/macos/mini-browser/docs/{logging-contract,observable-state}.md`;
  per-impl checklist at the logging contract's foot. Events: `[lifecycle] startup` /
  the bare launch line beginning `Mini Browser` (dual emission, keep stdout) /
  `[lifecycle] shutdown reason=<menu|signal|error>` + the three `[nav]` events —
  `started url=…` (post-state, after the loading status line), `finished` with fixed
  key order `url title can-go-back can-go-forward` (booleans bare `true`/`false`,
  after the whole §7.2 chrome refresh), `failed phase=<request|load> message=…`
  (message computed, emitted **before** `runModal`; `Unknown error` on the nil-error
  boundary — the nil-error case emits the event but shows no alert). Env vars
  `MINI_BROWSER_EVENTS_LOG` / `MINI_BROWSER_TEST_CONFIG`, fixed defaults under
  `/tmp/mini-browser/`. Silent no-ops (empty input, invalid URL) emit nothing.
- Impl (bare today — source + learnings only):
  `targets/racket/app-implementations/macos/mini-browser/mini-browser.rkt`. The
  failure plumbing already splits `request`/`load` (`show-error!`'s `phase` arg) and
  computes the message before the alert — the emission point slots in cleanly.
- Reference pattern (scenekit k107 / pdfkit k98): `events.rkt` (emit-launch-line
  naming) + top-of-module wiring (events-init! + startup before construction;
  test-config env no-op; uncaught-exception-handler → signal/error;
  `applicationWillTerminate:` app delegate → reason=menu) + self-contained
  `build.sh` (k76 bundler + post-mv PlistBuddy re-sign to
  `com.linkuistics.mini-browser-racket` / `MiniBrowser-racket.app`) + the
  `mini-browser-impl.rkt` descriptor (`#:binary /Applications/MiniBrowser-racket.app`).
- **Corpus step (the k98/k107 twin — this child does it once, siblings inherit):**
  WebKit is NOT in the local corpus (no `platforms/macos/api/WebKit/`
  extracted/resolved, no `generated/webkit/`). `SDKROOT=macosx` collect
  `--only WebKit` → analyze deps-together `--only Foundation,AppKit,WebKit`
  ([[resolved_regen_load_deps_together]]) → `apianyware-generate --target racket` →
  adapter relink (`swift build`, k107 stale-dylib class — verify via `nm -gU`
  bundled-vs-fresh if in doubt). Goldens must not move.
- **`file://` probe (the k114 seed):** after the rebuild, host-side standalone probe
  through the same generated bindings — `loadRequest:` with a `file://` NSURLRequest
  on a local fixture page; does `didFinish` fire and the title read back? Do NOT
  switch the impl to `loadFileURL:` (behaviour changes out of scope). Record the
  answer in the k80 brief for forward-gen.
- Smoke (per-impl bar; VM bar stays with live-run): launch via `open`, observe
  startup + launch line + at least one `[nav]` event in
  `/tmp/mini-browser/events.log` (host has network — the `www.apple.com` home load
  may `finished`), AppleScript quit → `shutdown reason=menu`.

## Done when

Checklist satisfied for racket; `MiniBrowser-racket.app` builds with
`CFBundleIdentifier com.linkuistics.mini-browser-racket`; CLI smoke green; the
`file://` probe answer recorded in the k80 brief.

## Notes

No visible-behaviour change (logging/plist/build plumbing only) — launch-line
remainder, `Loading...` spelling, and the `www.apple.com` home URL stay as realized.
