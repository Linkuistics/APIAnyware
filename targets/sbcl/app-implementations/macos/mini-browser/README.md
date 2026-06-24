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

## Build

```sh
# prerequisites: WebKit generated (resolve→annotate→enrich --only WebKit, then --target sbcl)
# + the dylib built
SDKROOT=macosx cargo run -p apianyware-analyze -- resolve  --only WebKit
SDKROOT=macosx cargo run -p apianyware-analyze -- annotate --only WebKit --llm-dir analysis/ir/llm-annotations
SDKROOT=macosx cargo run -p apianyware-analyze -- enrich   --only WebKit
SDKROOT=macosx cargo run -p apianyware-generate -- --target sbcl
SDKROOT=macosx swift build --package-path swift --product APIAnywareSbcl
# then:
targets/sbcl/app-implementations/macos/mini-browser/build.sh
```

Produces `build/MiniBrowser.app` (a standalone `save-lisp-and-die :executable t` dump).
`build.sh` stages the dylib at `/tmp/libAPIAnywareSbcl.dylib` (the revive auto-reopen path,
ADR-0038 §5), runs the host construction **pre-flight** + a **revive smoke** (dump+revive
**with** the dylib + subclass re-synthesis + **protocol re-conformance** + dispatcher
re-registration) before the bundle.

## VM-verify (never run GUI apps from the CLI — use TestAnyware)

Provision the VM with `/opt/homebrew/opt/zstd/lib/libzstd.1.dylib` (via `sudo` — the golden
has no Homebrew), `/tmp/libAPIAnywareSbcl.dylib`, and a **network connection** (the app loads
`https://example.com`; no sample file). Upload the bundle, `xattr -dr com.apple.quarantine`,
`open -n`. Drive the address field by **triple-click** (select-all) → type → Return (the
NSTextField Cmd-A does not take reliably over VNC). The key behaviour to verify is the status
line tracking the **async** navigation to "Done", the address bar resolving to the canonical
URL (both via the `WKNavigationDelegate` callbacks), `https://` prepended to a bare host, and
◀/▶ bidirectional history with correct enable/disable. See
`test-results/mini-browser/report.md`.
