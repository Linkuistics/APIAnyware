# mini-browser (sbcl target)

The 060 ladder's **sixth app**: a Mini Browser — an address bar, ◀/▶/Reload toolbar, a
`WKWebView` filling the window, and a status line driven by the `WKNavigationDelegate`
callbacks. Typing a URL + Return (or clicking Go) navigates; a missing scheme gets
`https://` prepended; ◀/▶ walk the back-forward list. Written against the CL-family interface
contract (ADR-0033 / the contract spec) — names only the `ns:` surface, `make-instance` typed
inits (§3.3 — WKWebView's `initWithFrame:configuration:`, NSURL's `initWithString:`,
NSURLRequest's `initWithURL:`), the per-selector generics (§3.2), the `@"…"` NSString reader
(§3.2), and the subclass macros `define-objc-subclass` / `define-objc-method` (§3.4/§3.5).
The sbcl analogue of racket/chez/gerbil's mini-browser.

**Distinctive:** first sbcl ladder app to use **WebKit**, the riskiest delegate shape so far
— the **async, multi-callback `WKNavigationDelegate`** — and a synthesized subclass that
**formally conforms to a framework protocol**. ONE `browser-controller`
(`define-objc-subclass` of `NSObject`, `(:protocols "WKNavigationDelegate")`) carries EIGHT
forwarded selectors in two roles: the four WKNavigationDelegate callbacks
(`didStartProvisionalNavigation:`/`didFinishNavigation:`/`didFail…:withError:`) AND the four
toolbar target-actions (`go:`/`back:`/`forward:`/`reload:`, address-field Return→`go:`). The
nav selectors are the first with **two and three** object args (`v@:@@`, `v@:@@@`); the one
forwarding dispatcher reads the arg shape live off the NSInvocation's `NSMethodSignature`, so
they marshal through the same path pdfkit-viewer's 1-arg observer used. WebKit delivers nav
callbacks on the **main thread**, so the ADR-0035 bounce is a no-op pass-through.

This leaf also fixed a runtime gap: the subclass macros' `aw-selector->generic-name` still
**dropped** colons (pre-ADR-0039), so `reload:` collided with WKWebView's emitted 0-arg
`reload`. It now follows ADR-0039 (colon→`_`), matching the emitter — see `learnings.md`.

Every WebKit/AppKit/Foundation call is plain ObjC (`:load-residual nil`); the app loads
`libAPIAnywareSbcl` **only** for the `aw_sbcl_subclass_*` bounce shim (as scenekit/pdfkit),
not trampoline residual. No framework constant is needed, so no startup-constant pass here.

## AppSpec instrumentation (sbcl-instrument-build-k119)

Instrumented to the logging contract
(`apps/macos/mini-browser/docs/logging-contract.md`): `events.lisp` (pure CL, the
`mb-events` package, loaded first by run.lisp/dump.lisp) writes the structured
`/tmp/mini-browser/events.log` (`MINI_BROWSER_EVENTS_LOG` overrides) the AppSpec runner
tails — `[lifecycle] startup`/`shutdown`, the bare launch line, and the three `[nav]`
events mirroring the four `WKNavigationDelegate` callbacks: `started url="…"` post-state
(loading status set), `finished url="…" title="…" can-go-back=… can-go-forward=…` after
the **whole** §7.2 chrome refresh (reading the same history getters the button
enablement used; booleans as bare `true`/`false`; `title=""` on instant loads — the
first-load title lag), and `failed phase=<request|load> message="…"` at rule entry —
message computed, **before** `runModal` (the runner's dismissal cue; the status line's
capitalized `Load failed:` stays as realized, only the log key is normalized lowercase).
The `browser-controller` gains the `applicationWillTerminate:` delegate hook (ninth
forwarded selector — informal conformance; the formal `:protocols` list stays
WKNavigationDelegate-only) and is installed as the app delegate. Impl descriptor:
`mini-browser-impl.rkt`.

## Build

```sh
targets/sbcl/app-implementations/macos/mini-browser/build.sh
```

Produces `build/MiniBrowser-sbcl.app` (`CFBundleIdentifier
com.linkuistics.mini-browser-sbcl`) via the production bundler
(`apianyware-bundle-sbcl`, ADR-0041): the app's `dump.lisp`
(`save-lisp-and-die :executable t`) behind the Swift stub, with **libzstd** and
**libAPIAnywareSbcl** vendored into `Contents/Frameworks/` — the bundle travels alone
(no `/tmp` staging; the k119 rebuild retired this app's original 060-era staged wrap).
build.sh regenerates the sbcl bindings if WebKit is absent from the local tree (keyed on
`generated/webkit/wkwebview.lisp`) and relinks the dylib in lockstep — NB the k116
WebKit corpus **grew the trampoline residual 170 → 174** (+4 `WebKit.WebPage` methods),
so a pre-k116 tree needs the regen + `swift build --product APIAnywareSbcl` relink even
though wkwebview.lisp exists — then runs the host construction **pre-flight** + a
**revive smoke** through the stub (subclass re-synthesis + **protocol re-conformance** +
dispatcher re-registration + vendored-dylib reopen).

## VM-verify (never run GUI apps from the CLI — use TestAnyware)

Upload the bundle (it travels alone), `xattr -dr com.apple.quarantine`, `open -n`. The
VM has **no network** (k74 provisioning), so the launch-time `https://example.com` load
fails: the §7.3 modal NSAlert is the expected launch observable, and the scenario suite
drives all success-path navigation against **local `file://` fixture pages** (the k116
probe: `loadRequest:` renders local HTML; `[nav] finished` carries `title=""` on every
file:// load — the didFinish-time title read misses on instant loads). Drive the address
field by **triple-click** (select-all) → type → Return (the NSTextField Cmd-A does not
take reliably over VNC). The key behaviour to verify is the status line tracking the
**async** navigation, `https://` prepended to a bare host (witnessed by `[nav] started`
even offline), and ◀/▶ bidirectional history — enablement asserted via the `[nav]
finished` booleans (the AX `enabled` flag is dropped by the snapshot transform). Tier-2
live-run belongs to the appspec-mini-browser live-run leaf. See
`test-results/mini-browser/report.md` for the original 060 VM report.
