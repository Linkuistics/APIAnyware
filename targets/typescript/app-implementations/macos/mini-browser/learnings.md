# mini-browser — learnings (Node TypeScript target, ladder app 5/7)

The first app in this ladder to exercise WebKit and an async, multi-callback ObjC **delegate
protocol** (`WKNavigationDelegate`) via the runtime's dedicated delegate machinery, rather than
only the `__subclassAlloc`/`__bindSubclass` pattern the first four apps used throughout. Two
runtime-surface findings (one a genuine emitter-corpus gap worked around at the call site, one a
brand-new-territory need for NSString→JS string conversion), one design finding (the two inbound
mechanisms split cleanly by which framework slot requires which), and the usual
VM-provisioning/tooling notes — plus one anomaly (a VM vanished mid-session) worth flagging for
whoever hits it next.

## Design finding: the plain-object `WKNavigationDelegate` literal works exactly as designed — first real-app proof

`delegate.ts`'s machinery (ADR-0059 §3/§6/§8, landed by `inbound-value-surface-k74`'s children)
had only ever been exercised by `delegate.test.ts` (a spy-stub unit test) and the native
integration harness before this leaf. Here it carries real production traffic: `app.ts`'s
`navigationDelegate` is a **plain object literal** — not an `NSObject` subclass, not built via
`__subclassAlloc` — implementing four of the nine `WKNavigationDelegate` interface methods
(`webView_didStartProvisionalNavigation_`, `webView_didFinishNavigation_`,
`webView_didFailNavigation_withError_`, `webView_didFailProvisionalNavigation_withError_`),
passed straight to `webView.setNavigationDelegate_(navigationDelegate)`. No manual keep-alive
was needed (the associating slot pins the synthesized forwarder onto `webView` itself via
`objc_setAssociatedObject`) and every callback argument arrived as the real wrapped type the
interface declares (`WKWebView`, `WKNavigation`, `NSError | null`) — no raw `bigint`s, no
hand-written ObjC type encodings. Confirmed end-to-end in-VM across all four callbacks
(start/finish/fail/fail-provisional), including the `NSError`-carrying failure path (a real
`NSError` object flowed into `error.localizedDescription()` and `NSAlert.alertWithError_(error)`
cleanly). This is the load-bearing confirmation the design's own carried-up notes were waiting on
— a future app needing any `id<P>`-typed delegate slot should follow this exact shape rather than
extending a `__subclassAlloc` handler's selector list, which remains the *other* apps' pattern.

## Design finding: target-action and delegate protocols are genuinely different inbound mechanisms, and the split is clean

`NSControl.setTarget_` is typed `target: NSObject` and its generated body calls `__unwrap(target)`
directly — it requires a real ObjC-backed object, so the four toolbar buttons + the address
field's Return action still route through `__subclassAlloc`/`__bindSubclass`
(`BrowserController`, four selectors: `go:`/`back:`/`forward:`/`reload:`, sender ignored
throughout, matching every prior ladder app's shape). There is no overlap to reconcile — a
framework slot's own declared type (`NSObject` vs. an `id<P>` protocol type) determines which
mechanism it needs, and this app is the first to need both side by side in one implementation.

## Runtime-corpus finding: `WKWebViewConfiguration` has no bare `init()` in this corpus — worked around, not patched

`__alloc(WKWebViewConfiguration).init()` fails to typecheck (`TS2339: Property 'init' does not
exist on type 'WKWebViewConfiguration'`). Root cause: the runtime's own `NSObject` (the class
every generated class ultimately extends) declares **no** `init()` at all; every NSView-rooted
class (`NSButton`, `NSTextField`, `WKWebView`, …) gets one **transitively**, inherited from
`NSResponder`, which **does** declare `init(): this;` in its own `.d.ts`. `WKWebViewConfiguration`
extends the runtime `NSObject` **directly** (it is not a view), and its own Swift/ObjC declared
surface apparently never re-declares a plain `-init` override (real Cocoa code can still call it —
`-init` is always inherited at the ObjC runtime level regardless of whether a header/swiftinterface
re-declares it — but this emitter only surfaces `init()` on a class when it (or a declaring
ancestor) carries it in the IR). **Not fixed here** — this is a corpus/emitter gap, not this app's
concern, and the spec itself sanctions a workaround: §9's "abstract operations" note says two of
the four reference implementations build a `WKWebViewConfiguration` first and two use
`initWithFrame:` alone. This app uses the configuration-less path
(`__alloc(WKWebView).initWithFrame_(rect)`, inherited from `NSView`), sidestepping the gap
entirely rather than patching the runtime for one call site. **A future app that genuinely needs
to configure a `WKWebViewConfiguration` (or construct any other NSObject-direct class with no
declared init) will hit this for real** — that is the moment to raise it as its own leaf, not now.

## Runtime finding: first app needing NSString content read back into JS — no existing primitive, small local helper sufficient

Every prior ladder app only ever **constructs** NSStrings (`jsString`/`__cfstr`); none ever read
one back. This app needs to: read the address field's typed text (for the go-action), read
`webView.title()`/`URL().absoluteString()` for the chrome refresh, and read
`error.localizedDescription()` for the failure status. The generated `NSString` surface in this
corpus has no `UTF8String`/bulk-copy selector — only `length()` + `characterAtIndex_`. A five-line
`nsToString` helper (loop `characterAtIndex_` into `String.fromCharCode`, building up via `+=`
rather than a spread to `String.fromCharCode(...)` to avoid the JS engine's argument-count cap on
long strings) is correctness-sufficient for this app's short strings (URLs, titles, error
messages) and needed no runtime change. A future app reading much longer strings (a text
document's full contents, say) should reconsider — a per-character native crossing loop would
become the bottleneck at that scale, and that would be the moment to add a real bulk-read
primitive to the runtime, not before.

## Finding: the generated non-null types needed defensive guards at the same three call-site shapes prior apps already found

Continuing scenekit-viewer's and pdfkit-viewer's own pattern: `NSURL.initWithString_` (spec §6.2's
whole invalid-URL protocol), `webView.title()`/`webView.URL()` (spec §7.2's nil-title/nil-URL
boundaries), and the `WKNavigationDelegate` callbacks' own `error: NSError` parameter (spec §7.3's
nil-error boundary) all needed `if (!x)` guards despite non-nullable generated types. The nil-error
boundary was not exercised live this session (every failure driven in-VM carried a real `NSError`
from a real DNS failure) — the guard is defensive per the established pattern, not proven load-bearing
here.

## VM-provisioning finding: an active VM clone vanished mid-session, entirely (not just stopped)

Unlike prior sessions' "VM already running, reused it" finding, this session's initial VM
(`testanyware-7c84629f`, reused at session start per that same precedent) **disappeared from
`testanyware vm list` entirely** between two exec calls a few commands apart — not present even as
a stopped/golden entry, `VM_NOT_FOUND` on the next `file`/`exec` call. No crash was visibly
triggered by anything this session did (the prior command was a successful `agent snapshot`); no
root cause was investigated (out of scope for this leaf — starting a fresh clone and
re-provisioning identically was faster and sufficient). **A later session hitting `VM_NOT_FOUND` on
a VM that was healthy a few commands ago should not assume its own action caused it** — just
`vm start` a fresh clone and re-provision (cheap, ~2 minutes for the dylib vendoring + app
deploy); if this recurs, it may be worth a dedicated investigation.

## Tooling/provisioning findings (continuing prior apps' own)

- **The Homebrew dylib closure is identical to pdfkit-viewer's own 20-formula set** (same
  `libnode`/`libuv` transitive graph — WebKit itself needs no additional Homebrew vendoring, only
  system frameworks per `otool -L` on the native addon). Only `lib/` directories were vendored,
  **not** `bin/` — the launcher embeds Node directly via `libnode.dylib` and never shells out to a
  `node` executable, so `which node`/`node --version` failing on the guest is expected and
  harmless.
- **The app + native addon deployment preserves the same relative directory structure as the
  host**: `bootstrap.cjs` resolves the native addon via `../../../bindings/node/native/build/...`
  relative to its own directory, so the tarball must place `app-implementations/macos/
  mini-browser/` and `bindings/node/native/build/APIAnywareTypeScript.node` at that same relative
  offset on the guest — no absolute-path rewriting needed anywhere.
- **`agent snapshot --mode interact` does not expose the static status label** — a non-editable,
  non-selectable, non-bezeled `NSTextField` (this app's status line) does not appear among the
  `interact`-mode elements the way the address field (editable) or the buttons do. Status text was
  read via screenshot/visual inspection instead, consistent with the four Lisp targets' own VM
  notes about the address field's AX *value* being unreliable — extend that caution to any
  purely-static label, not just editable-but-unreliable fields.
- **`input click <x> <y> --count 3` (triple-click) reliably selects the whole address field**,
  confirmed again across many navigations in this session — the established cross-target
  precedent (sbcl/pdfkit-viewer's own VM notes) holds for TypeScript too.
