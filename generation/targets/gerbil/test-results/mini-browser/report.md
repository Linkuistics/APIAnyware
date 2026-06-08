# Mini Browser — Gerbil Test Report

**Date:** 2026-06-09
**Status:** PASS — sixth gerbil sample app. First to use **WebKit** and the
riskiest delegate shape yet: an **async, multi-callback WKNavigationDelegate**
whose methods fire from WebKit's run loop, plus a second target-action delegate.

Done-bar for grove leaf `100-sample-apps/060-mini-browser`: the self-contained
`.app` loads a real web page in a WKWebView, navigates via the address bar +
back/forward/reload, and reflects WKNavigationDelegate state in a status line —
VM-verified in a **no-Gerbil VM** ([[feedback-vm-verify-every-app]]).

## Build

`cargo run --example bundle_app -p apianyware-macos-bundle-gerbil -- mini-browser`.
Output: `…/apps/mini-browser/build/Mini Browser.app`, bundle id
`com.linkuistics.MiniBrowser`, codesigned, dylib-clean (WebKit + system frameworks
+ vendored openssl; static Gambit runtime). Build ~9 min (cache partly warm on the
rebuild).

### Import collision fixed (`only-in`)

The generated `:gerbil-bindings/foundation/nserror` exports `nserror-code` /
`nserror-domain` (the NSError class's properties), which **collide** with
`runtime/objc`'s ADR-0006 `nserror` defstruct accessors of the same names — an
ambiguous-import `gxc` error. The app needs only `nserror-localized-description`
from the generated module (different from the struct's British-spelled
`nserror-localised-description`), so it imports that one binding via
`(only-in …)`. No emitter change — an app-level import-hygiene fix.

## VM verify (no-Gerbil bar)

Golden `testanyware-golden-macos-tahoe`, arm64, macOS 26; VM has network
(`curl https://example.com` → HTTP/2 200). App tarball (md5-verified) uploaded,
dequarantined, `open -n`. No runtime errors.

Results (`mini-browser-loaded.png`, `mini-browser-history.png`):

- [x] Window "Mini Browser" with the toolbar (◀ / ▶ / Reload / address field /
      Go) over a WKWebView and a status line. ◀/▶ start disabled. Standard app
      menu reads "Mini Browser".
- [x] **WKWebView loads + renders a real page**: the initial `https://example.com`
      load shows the rendered "Example Domain" page (heading, body, "Learn more"
      link) — genuine WebKit rendering in the bundled app.
- [x] **Async WKNavigationDelegate callbacks fire** (the riskiest feature): the
      status line shows "Done" after load — `didFinishNavigation:` re-entered
      Gerbil from WebKit's run loop through the `make-delegate` IMP trampoline and
      ran `refresh-chrome!` + `set-status!`. (`didStartProvisionalNavigation:`
      sets "Loading…" on the way.)
- [x] **Address bar resolves** to the canonical `https://example.com/` via
      `refresh-chrome!` (`wkwebview-url` → `nsurl-absolute-string`).
- [x] **Navigation via the address field** (`go:` on Return): typing a second URL
      and pressing Enter loaded a new entry; **Back enabled** (history grew,
      `can-go-back` → true).
- [x] **Back navigates** (`back:` → `wkwebview-go-back`): clicking ◀ returned to
      the first entry; afterward **◀ disabled / ▶ enabled** — the re-fired delegate
      ran `refresh-chrome!` and the can-go-back/forward enable logic is correct
      and bidirectional.
- [x] Reload button present and wired (`reload:` → `wkwebview-reload`).

Two delegates (the async WKNavigationDelegate + the 4-selector target-action
`ui-target`), WebKit rendering, URL normalisation, and history navigation all work
under whole-program `-O` in a no-Gerbil VM. WKNavigationDelegate callbacks arrive
on the main thread and the ADR-0022 trampoline runs them directly (no bounce /
deadlock), exactly as the prior samples' main-thread target-actions do.

## Notes

- The window title stays "Mini Browser" rather than "Example Domain — Mini
  Browser": WebKit's `title` KVO lags `didFinishNavigation:`, so `wkwebview-title`
  is still "" when `refresh-chrome!` runs and the `(string=? title "")` fallback
  applies — matching the racket/chez ports' timing, not a port defect.
- WKWebView requires `initWithFrame:configuration:` (no bare init), so a
  `WKWebViewConfiguration` is created up front.

See [[feedback-use-testanyware]], [[reference-testanyware-cli]],
[[feedback-sample-apps-perfect]].
