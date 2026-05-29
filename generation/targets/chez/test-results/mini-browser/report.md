# Mini Browser — Chez Test Report

**Date:** 2026-05-29
**Status:** Pass

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
