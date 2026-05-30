# Mini Browser — Chez Test Report

**Date:** 2026-05-29
**Status:** Pass

> **Superseded by the standalone re-verification (2026-05-30) below.** The body
> describes the retired source-exec / precompile bundle. Under ADR-0009 chez apps
> ship as a self-contained open-world standalone binary; source-exec-era caveats
> (menu-bar "chez", `brew install chezscheme`) are obsolete — see the dated
> section at the end.

## Build & launch

- Dev-host bundle build: `cargo run --example bundle_app -p
  apianyware-macos-bundle-chez -- mini-browser`.
- Bundle size: **121 MB** (carries the chez-precompiled WebKit `.so` set
  on top of AppKit/Foundation).
- In-VM cold launch: window visible **~4 s** after `open -n` — inside the
  1-3 s band for the AppKit/Foundation apps, a touch higher because WebKit
  is a large framework that the precompile pass also has to map in. Well
  short of the ≥10 s regression bar.
- VM provisioning: the golden image ships no Chez, so the run did
  `brew install chezscheme` (10.4.1 bottle, `/opt/homebrew/bin/chez`) once
  in the clone before launch — exactly the 050 brief's note. The bundle
  was transferred host→VM in 4 MB chunks (the agent's upload cap is between
  4 and 8 MB; a single 57 MB tarball returns HTTP 413) and reassembled +
  md5-verified in the guest.

## What this app is the first to exercise

`mini-browser` is the first chez sample with an **async, multi-callback
delegate**. The pdfkit/scenekit/ui-controls trio's delegate callbacks were
all synchronous (target-action, NSNotificationCenter observer) — they fire
*within* the event tick that triggered them. WKNavigationDelegate's
`didStartProvisionalNavigation:` → `didFinishNavigation:` /
`didFailNavigation:` / `didFailProvisionalNavigation:` fire from WebKit's
run loop whenever a load resolves, each **re-entering Scheme** through the
`foreign-callable` trampoline whose body wraps in `with-autorelease-pool` +
guardian drain (ADR-0007). The RSS-stability check below is what confirms
that combination drains correctly across run-loop re-entry, not just within
one tick.

Two delegate records: `nav-delegate` (the four WKNavigationDelegate
selectors) and `ui-target` (the four toolbar/address-field target-action
selectors `go:` / `back:` / `forward:` / `reload:`).

## Steps Completed

- [x] **Launch + initial load (success path).** Window 800×632, toolbar
      `◀`/`▶` (both disabled — no history), `Reload`, address field
      `https://www.apple.com`, `Go`; status `Ready`→`Loading...`→`Done`;
      WKWebView renders apple.com. Window title became
      `Apple — Mini Browser` — `didFinishNavigation:` fired, `refresh-chrome!`
      read `wkwebview-title` = "Apple" and `wkwebview-url`, both via
      `nsstring->string` (screenshot-001-launch.png).
- [x] **Standard app menu.** `install-standard-app-menu!` produced
      About/Hide/Quit "Mini Browser".
- [x] **`didFailProvisionalNavigation:` (failure path).** Address set to
      `https://nonexistent.invalid` (reserved TLD, never resolves) + Return:
      `didStartProvisionalNavigation:` set status `Loading...`, then
      `didFailProvisionalNavigation:withError:` fired. `show-error!` read
      `nserror-localized-description` (the raw `err` uptr passed straight
      through `coerce-arg` — no wrap needed), built an `+alertWithError:`
      NSAlert reading **"A server with the specified hostname could not be
      found."**, and ran it modally (screenshot-002-fail-alert.png).
- [x] **Failure status after dismiss.** Pressing OK unwound `runModal`;
      `show-error!`'s tail set the status line to **"request failed: A
      server with the specified hostname could not be found."** (phase
      "request", matching the provisional-failure selector)
      (screenshot-003-fail-status.png).
- [x] **`go:` target-action + scheme prepend.** Typed `example.com` (no
      scheme) + Return → `normalize-url` prepended `https://`; address field
      resolved to `https://example.com/`, page rendered "Example Domain",
      status `Done` (screenshot-004-example-scheme-prepend.png).
- [x] **`back:` / `forward:` target-action.** `◀` enabled after the first
      navigation; pressing it ran `wkwebview-can-go-back` →
      `wkwebview-go-back`, landing on the prior page (address + chrome
      refreshed by the resulting `didFinish`), and enabled `▶`; pressing `▶`
      returned to `https://example.com/`. Confirms the canGo*/go* pair and
      that the post-navigation `didFinish` re-runs `refresh-chrome!`.
- [x] **`reload:` target-action (RSS loop, below).**
- [x] Cmd+Q exits cleanly.

## Activity Monitor — RSS stability (reload loop)

The done-bar's load test: load → reload → reload should show no unbounded
growth, confirming guardian + autoreleasepool drain across the async
didStart/didFinish callbacks. In-VM `ps -o rss=` for the chez process
(pid 2155) across 6 consecutive `Reload` presses on example.com, each
followed by `didFinish` (status returned to `Done` every time):

```
baseline (post first loads): 593.359 MB
reload 1: 589.797 MB
reload 2: 550.172 MB
reload 3: 550.203 MB
reload 4: 550.250 MB
reload 5: 550.312 MB
reload 6: 550.328 MB
+10 s idle: 550.188 MB
```

RSS *fell* from baseline (the heavy apple.com page set released) and then
held flat — 0.16 MB drift across reloads 2-6, reverting on idle. No
unbounded growth. The guardian + autoreleasepool combination drains
cleanly across repeated async navigation-callback re-entry. AppKit+WebKit
idle baseline ~550 MB sits between ui-controls-gallery (525 MB) and
scenekit-viewer (577 MB).

## Issues Found

None.

## Notes

- **Title-at-didFinish is an approximation, shared with racket.** On
  example.com the window title stayed at the `Mini Browser` fallback rather
  than "Example Domain": WKWebView updates its `title` property via KVO
  *slightly after* `didFinishNavigation:` for fast-loading pages, so the
  synchronous `wkwebview-title` read inside `refresh-chrome!` can catch it
  empty. apple.com (a heavier, multi-stage load) had its title populated by
  the time its final `didFinish` fired, so it showed "Apple". The racket
  source has the identical read-at-didFinish logic and the same
  timing-dependent behaviour — this is **parity, not a chez regression**.
  A KVO observer on `title` would fix both ports; out of scope for this leaf.
- **Navigation-delegate callbacks arrive on the main thread.** WebKit
  delivers WKNavigationDelegate methods on the main run loop, so the
  callbacks re-enter Scheme on the same thread as `nsapplication-run`. No
  non-main-thread convention was needed; the leaf's "if a callback fires
  off-main-thread, document it" contingency did not arise. Recorded in
  `knowledge/targets/chez.md`.
- **Delegate args are raw uptrs; `coerce-arg` absorbs them.** The Swift
  trampoline hands `err` to the failure selectors as a `void*` integer, not
  a pre-wrapped `objc-object`. Because every generated accessor runs its
  receiver through `coerce-arg` (which accepts integers), `(nserror-localized-description
  err)` works directly; nil is the `(zero? err)` check, with no
  racket-style contract layer. `wkwebview-url`'s *returned* objc-object,
  by contrast, is nil-checked with `(zero? (objc-object-ptr u))`.
- Menu-bar / Force-Quit name reads "chez" — same stub-launcher `execv`
  concern as the rest of the chez portfolio, out of scope.
- Bundle transfer via 4 MB chunks is a TestAnyware-agent upload-size
  workaround, not an app concern.

---

## Standalone re-verification (2026-05-30, leaf `060/050/050`)

**Status: PASS.** Fifth portfolio app. New axis: **async multi-callback delegate**
(WKNavigationDelegate) — callbacks fire asynchronously off WebKit's run loop,
stressing the entry-point autoreleasepool + guardian lifetime under the embedded
boot.

**Build.** `cargo run --release --example bundle_app -p
apianyware-macos-bundle-chez -- mini-browser`. Output: `Mini Browser.app`,
**4.9 MB**, bundle id `com.linkuistics.MiniBrowser`, signed; no Chez/Scheme
linkage. No new wrapper collisions.

**VM verify (no-Chez bar).** Golden macOS 26.3 arm64, no Chez present, **network
reachable** (apple.com → HTTP/2 200). Uploaded (md5-verified), unpacked,
quarantine-stripped, `open -n`.
- [x] **WKWebView renders live web pages** in the standalone — default
      `https://www.apple.com` loads the full "iPhone 17 Pro" page; window title
      becomes "Apple — Mini Browser" (`screenshot-standalone-001-apple-loaded.png`).
      WebKit loads at runtime in the no-Chez VM.
- [x] **Async `didStartProvisionalNavigation:` → `didFinishNavigation:` fire** —
      status field transitions "Loading…" → **"Done"**; `refresh-chrome!` updates
      the window title and address field. These fire from WebKit's run loop, not
      synchronously — the core async-callback proof.
- [x] **`go:` fires** — typing `https://example.com` + Enter navigates; the
      "Example Domain" page renders, address → `https://example.com/`, status
      "Done" (`screenshot-standalone-002-example-navigated.png`). A second full
      async navigation cycle.
- [x] **`back:` fires** — back button enabled after history accrues; clicking it
      navigates to the prior entry, address refreshed via the back navigation's
      async finish callback.
- [~] **Error-path selectors** (`didFailNavigation:` / `didFailProvisionalNavigation:`):
      **covered by construction, not live-triggered.** A TestAnyware quirk on this
      NSTextField (Cmd+A select-all / `agent set-value` didn't clear/resolve the
      field, so a clean bad-host URL couldn't be entered; concatenated text
      resolved to served 4xx pages, which correctly take the *success* path —
      `didFinish`, status "Done"). The two failure selectors are wired identically
      to the proven `didFinish` selector in the same `make-delegate` record. Not a
      blocker; the async substrate is proven by the successful navigations + back.
- [x] **RSS stable ~142–144 MB** across ~6 navigations (many async callback
      re-entries); process never crashed. The key async-lifetime result: repeated
      async callbacks entering Scheme from WebKit's run loop don't leak or collect
      mid-flight — the entry-point autoreleasepool + guardian interaction holds
      under the embedded boot.

Consistent with the leaf-020 dispatch-substrate proof: the `eval`-synthesised
trampolines fire correctly on the async path too.

**Obsoleted source-exec caveats (resolved by standalone):** menu bar reads "Mini
Browser"; no `brew install chezscheme`; 4.9 MB bundle. No app code changes.
