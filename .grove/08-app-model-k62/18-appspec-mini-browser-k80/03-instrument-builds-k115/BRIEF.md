# instrument-builds-k115 — brief

**Kind:** node (decomposed on entry 2026-07-03 — one instrument+build child per
impl, the scenekit k106 split; children materialized lazily, grow the next as each
retires)

## Children

1. `racket-instrument-build-k116` ✅ — the reference pattern (events.rkt + wiring +
   self-contained build.sh + descriptor; scenekit k107 twin). Did the one-time
   WebKit corpus step (collect `--only WebKit`, analyze deps-together
   `--only Foundation,AppKit,WebKit` — 164 classes/29 protocols/168 racket files)
   the siblings inherit, and answered the `file://` probe (k80 brief "file://
   probe result" — success path OPEN; title misses the didFinish read on every
   file:// load; siblings need not re-probe). App-level shape the siblings
   mirror: `current-url-string`/`current-title-string` helpers (URL
   absoluteString / title at callback time, "" when nil); started emits after
   the loading status set; finished after the whole §7.2 refresh reading the
   same history getters the buttons just used; failed emits in `show-error!`
   right after the message computation, before the alert block (the existing
   `request`/`load` phase args are already the normalized spellings).
   **Sibling handoff (the k107 twin, still live):** WebKit GROWS the trampoline
   residual (170 → 174 entries: +2 constants, +2 init/method) — unlike
   SceneKit's zero — so each sibling needs its own `apianyware-generate
   --target <t>` + adapter dylib relink before bundling, and gerbil's
   "`Trampolines.swift` git-clean → dylib current by construction" shortcut
   will NOT hold (the trampoline source really changes). CLI smoke on the host
   reaches `[nav] finished` (host network) — expect `started`→`finished` for
   the `www.apple.com` home load, `title="Apple"` at didFinish.
2. `chez-instrument-build-k117` ✅ *(done 2026-07-03)* — the k108 pattern held
   1:1 (inline `mb-` emitter; startup + test-config no-op top-level before
   `(main)`; terminate hook; k116 emission points). The k116 trampoline
   prediction confirmed: regenerate `--target chez` produced exactly 174
   entries; `swift build --product APIAnywareChez` relink, then bundle.
   CLI smoke green end-to-end (startup → launch line → `[nav] started` →
   `finished url="https://www.apple.com/" title="Apple"` → `shutdown
   reason=menu`). No new sibling handoffs — the pattern held cleanly.
3. `gerbil-instrument-build-k118` ✅ *(done 2026-07-03)* — the k109 pattern held
   (inline `mb-` emitter; startup + test-config no-op top-level before `(main)`;
   terminate hook; k116 emission points). The k116 trampoline prediction
   confirmed again: regenerate `--target gerbil` produced exactly 174 entries
   (+4 `WebKit.WebPage`); `swift build --product APIAnywareGerbil` relink
   (gerbil *links* the dylib at `gxc -exe`), then bundle. CLI smoke green
   end-to-end (startup → launch line → `[nav] started` → `finished
   url="https://example.com/"` `title=""` first-load lag → `shutdown
   reason=menu`). **New sibling-relevant finding (gerbil-only):** the WebKit
   corpus flattens `stringLength` onto WKWebView, so `wkwebview.ss` re-exports
   a `string-length` GENERIC shadowing the Gambit builtin — runtime dispatch
   failure in any importer; fixed app-side with `(except-in
   :gerbil-bindings/webkit/wkwebview string-length)` (the `values`-coerce
   shadow class; recorded in the impl learnings.md + memory). Does not affect
   sbcl (package-qualified `ns:` names cannot shadow CL builtins).
4. `sbcl-instrument-build-k119` — the k101/k110 pattern (sibling `events.lisp`);
   owns the k114 `build.sh` seeds (bundle id `com.linkuistics.mini-browser-sbcl`
   + `CFBundleInfoDictionaryVersion`). Closes the node.

## Goal

Instrument all four mini-browser impls to the k114 contracts and rebuild each to a
launchable `.app` — the scenekit `instrument-builds` stage mirror. Per-impl CLI
smoke (launch, one nav event observed in events.log, quit) is the per-impl bar —
the VM bar stays with `live-run`.

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
