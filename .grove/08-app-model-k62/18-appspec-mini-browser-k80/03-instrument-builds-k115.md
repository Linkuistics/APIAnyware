# instrument-builds-k115

**Kind:** work

## Goal

Instrument all four mini-browser impls to the k114 contracts and rebuild each to a
launchable `.app` — the scenekit `instrument-builds` stage mirror. Expected to
**decompose on entry** (one child per impl, racket/chez/gerbil/sbcl) if the four
don't fit one session; per-impl CLI smoke (launch, one nav event observed in
events.log, quit) is the per-impl bar — the VM bar stays with `live-run`.

## Context

- The contracts: `apps/macos/mini-browser/docs/{logging-contract,observable-state}.md`
  (k114). Per-impl checklist at the logging contract's foot. Impl sources:
  `targets/<t>/app-implementations/macos/mini-browser/`.
- **k114 handoffs:**
  - Events: `[lifecycle] startup` / bare launch line / `[lifecycle] shutdown reason=…`
    (add the `applicationWillTerminate:` hook, prior-apps pattern) + the three `[nav]`
    events. Fixed key order `url title can-go-back can-go-forward`; booleans as bare
    `true`/`false` (not `#t`); `phase` normalized lowercase `request`/`load` even where
    the status line capitalizes (sbcl); `failed` emitted **before** `runModal` (message
    computed first). Env vars `MINI_BROWSER_EVENTS_LOG` / `MINI_BROWSER_TEST_CONFIG`,
    defaults under `/tmp/mini-browser/`.
  - **No visible-behaviour alignment**: launch-line remainder, `Loading...`/`Loading…`,
    status phase spelling, and the per-impl home URLs (racket/chez `www.apple.com`,
    gerbil/sbcl `example.com`) all stay as realized.
  - **sbcl `build.sh`**: align `CFBundleIdentifier` to
    `com.linkuistics.mini-browser-sbcl` + add `CFBundleInfoDictionaryVersion` (the
    scenekit k104-seed mirror). Check the other three impls' bundle plumbing produces
    `com.linkuistics.mini-browser-<impl>` too.
  - **Seeded probe: `file://` renderability** — after each rebuild, host-side probe
    whether `loadRequest:` renders a local HTML file (drives the k114 success-path
    gate; record the answer for forward-gen). Do not switch impls to `loadFileURL:` —
    behaviour changes are out of scope.
- Build recipes: the prior apps' instrument stages (hello-window k68–k71 pattern;
  racket self-contained bundle per k76, sbcl vendored libzstd per k75, gerbil gcc-15
  shim). `swift build --product` gotcha does not apply (no native unit).

## Done when

All four impls emit the contract events (checklist satisfied), build to `.app`s with
conforming bundle ids, and pass a CLI smoke each; the `file://` probe answer is
recorded (a note in the k80 brief or the leaf, for forward-gen). Commits name the
impl child handles (or this handle if kept whole).

## Notes

Instrumentation must not change visible behaviour (contract rule) — logging, plist,
and build plumbing only.
