# mini-browser — learnings (sbcl target, 060 ladder, the 6th app)

A minimal web browser: an address bar, ◀/▶/Reload toolbar, a `WKWebView` filling the window,
and a status line driven by the `WKNavigationDelegate` callbacks. First sbcl app to use
**WebKit**, the **async multi-callback WKNavigationDelegate**, and a subclass that **formally
conforms to a framework protocol**. WebKit was not in any target's local IR, so this leaf ran
the pipeline for it (resolve→annotate→enrich `--only WebKit` + `--target sbcl`; the
`WebKit.llm.json` annotation already existed). It surfaced one real runtime gap (fixed) and
confirmed the conformance + multi-arg-delegate paths end-to-end.

## Runtime gap FIXED: `aw-selector->generic-name` dropped colons — collides with a real method

**The first ladder app whose hand-written delegate selector collides with an emitted
framework method differing only by arity.** `reload:` is a 1-arg target-action; WKWebView's
`reload` is an emitted 0-arg method (`ns:reload`). The runtime's `aw-selector->generic-name`
(the local selector→generic the `define-objc-method` macro uses) still **dropped** colons —
the pre-ADR-0039 convention — so `reload:` → `ns:reload`, the SAME symbol as the 0-arg
`reload`. `define-objc-method` then tried `(defmethod ns:reload ((self browser-controller)
sender))` — a 2-arg method on a 1-arg generic — and CLOS rejected it at load
(`FIND-METHOD-LENGTH-MISMATCH`, caught by the construction pre-flight before any VM trip).

**Root cause:** ADR-0039 (selector-structure preservation: colon→`_`, hump→`-`) fixed the
**emitter** so `reload`/`reload:` stay distinct generics `ns:reload`/`ns:reload_`, but its
**parallel runtime reimplementation in `subclass.lisp` was never synced**. The function's own
header even called itself "the colon/kebab slice" — i.e. the OLD drop-colons kebab. Earlier
apps' delegate selectors (`openDocument:`, `pageChanged:`, `geometryChanged:`, `goPrev:`)
never named a real emitted method, so the gap stayed latent.

**Fix (`lib/runtime/subclass.lisp`):** `aw-selector->generic-name` now writes `_` for each
colon (ADR-0039), so its names match the emitter's exactly: `reload:` → `ns:reload_`,
`webView:didFinishNavigation:` → `ns:web-view_did-finish-navigation_` (= the protocol
registry's generic name). The structural invariant this restores: every colon contributes
both an `_` to the name AND an argument to the method, so any selector that DOES name a real
emitted generic matches its arity too — the override composes instead of colliding. The
seven-smoke runtime suite stays green (its `copyWithZone:`/`handleNote:` selectors now map to
`ns:copy-with-zone_`/`ns:handle-note_`; the smokes check behaviour, not the generic name).

> Pattern for later targets: this is the same B1 collision ADR-0039 addressed for the
> emitter; any per-target runtime that re-derives selector→generic for its subclass macros
> must follow ADR-0039 too, or a delegate selector sharing a name with a 0-arg accessor
> (`reload:`/`reload`, `update:`/`update`, …) will collide. [[project_preserve_selector_structure_cross_target]]

## Patterns confirmed

- **One subclass, eight selectors, two roles, one of them a formal protocol.**
  `browser-controller` is `(define-objc-subclass … (:protocols "WKNavigationDelegate"))` — the
  FIRST GUI app to exercise the conformance path (previously only the
  `smoke-subclass-conformance` runtime test did). `class_conformsToProtocol` is true and each
  nav selector's ABI encoding is read LIVE off the protocol's optional method-description list
  (`protocol_copyMethodDescriptionList`), vs. the synthesized-default `v@:@…` the four
  target-action selectors fall back to. Conformance needs only the framework dlopen'd
  (`objc_getProtocol`/`protocol_*` hit libobjc directly) — WebKit loads `:load-residual nil`.
- **Multi-arg delegate selectors need no new machinery.** `didStart/didFinish` are 2-arg
  (`v@:@@`), `didFail…:withError:` 3-arg (`v@:@@@`). The one forwarding dispatcher reads
  `numberOfArguments` + `getArgumentTypeAtIndex:` off the NSInvocation's `NSMethodSignature`,
  so 2-/3-arg selectors marshal exactly like pdfkit-viewer's 1-arg observer. The error arg
  arrives as a wrapped `ns:ns-error`, so `(ns:localized-description err)` dispatches by class.
- **WKNavigationDelegate callbacks arrive on the main thread**, so the ADR-0035 bounce is a
  no-op pass-through (no `dispatch_sync`, no deadlock) — same path as every target-action
  callback. Matches gerbil's finding exactly.
- **WKWebView needs `initWithFrame:configuration:`** (no bare init): a
  `make-instance 'ns:wk-web-view-configuration` (bare-init NSObject) up front, then
  `(make-instance 'ns:wk-web-view :init-with-frame <rect> :configuration cfg)` — the typed
  multi-arg init (ADR-0040 / contract §3.3), the rect passed by value via `aw-with-rect`.
- **NSString reads via `(nsstring->string (aw-ptr obj))`**, guarded `nil`→"" by a small
  `ns->str`. `ns:title`/`ns:url`/`ns:absolute-string`/`ns:localized-description` return
  wrapped instances; unwrap to the id SAP for the reader.
- **URL normalisation hand-rolled** (no regex), char-scanner `has-uri-scheme-p` + `trim-ws`
  — identical logic to racket/chez/gerbil's source. A bare host gets `https://` prepended;
  VM-verified live (`example.org` → `https://example.org/`).
- **WebKit is pure ObjC for this surface** — adding it regenerated `Trampolines.swift`
  (220 entries) which compiled clean, but the WKWebView/nav-delegate path touches zero
  Swift-native residual, so every framework loads `:load-residual nil`; the dylib is loaded
  ONLY for the `aw_sbcl_subclass_*` bounce shim (as scenekit/pdfkit). No new framework
  constant needed (unlike pdfkit's notification name), so no startup-constant pass here.
- **Title KVO lags the finish callback** — `wkwebview-title` is "" at `didFinishNavigation:`
  time on the FIRST load, so the title stays "Mini Browser"; a back-navigation to an
  already-titled page shows "Example Domain — Mini Browser". Cosmetic, matches all targets.

## VM-driving lessons (TestAnyware, building on pdfkit-viewer's)

- **NSTextField select-all is finicky over VNC.** `input key a --modifiers cmd` did NOT
  reliably select-all in the focused address field (the typed text appended to the existing
  URL instead). **Triple-click the field** (`input click X Y --count 3`) reliably selects the
  whole line, so the typed URL replaces it — that's how the bare-host normalisation test was
  driven cleanly. (A single click just places the cursor; a double-click selects one word.)
- **Network is the only extra provisioning** beyond the two dylibs — the app loads
  `https://example.com`; confirm with `testanyware exec "curl -sS -m 10 -o /dev/null -w 'HTTP
  %{http_code}\n' https://example.com"` (HTTP 200) before launching. The IANA reserved
  `example.{com,net,org}` all serve the same "Example Domain" page, so the **address bar is
  the navigation discriminator**, not the page content (use distinct real domains only if the
  page body must differ).
- **Button enabled-state is the reliable history signal.** ◀/▶ `enabled` in
  `agent snapshot --json` tracks `canGoBack`/`canGoForward`; the screenshot's greyed/dark
  rendering is less legible than the AX flag. (Filter the snapshot for `role=="button"` with
  `80<y<120`; the toolbar buttons sit just under the title bar, distinct from the y≈58
  traffic-lights.)
- The address `text-field`'s `value` came back empty in the AX JSON, so the loaded URL was
  read from the **screenshot**, not AX — get the URL visually, the button states from AX.
