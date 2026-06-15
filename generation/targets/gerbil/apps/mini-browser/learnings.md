# mini-browser x gerbil

**2026-06-09 (standalone, grove leaf `100/060`):**
- 🟢 Ported and VM-verified as a self-contained `.app` (dylib-clean, WebKit-linked,
  static Gambit runtime). In a **no-Gerbil VM** (with network): a WKWebView loads +
  renders `https://example.com`, the status line tracks the async navigation
  (Loading…→Done), the address bar resolves to the canonical URL, typing a URL +
  Enter navigates, and ◀/▶ history works bidirectionally with correct
  enable/disable. See `generation/targets/gerbil/test-results/mini-browser/report.md`.
- **Riskiest delegate shape so far: async, multi-callback WKNavigationDelegate.**
  `didStartProvisionalNavigation:`/`didFinishNavigation:`/`didFail…withError:` fire
  from WebKit's run loop into Gerbil via the `make-delegate` IMP trampoline. They
  arrive on the MAIN thread, and the ADR-0022 trampoline runs main-thread callbacks
  directly (no `dispatch_sync` bounce, no deadlock) — same path as every prior
  sample's target-action callbacks. Two delegates: the nav delegate + a 4-selector
  target-action `ui-target` (go:/back:/forward:/reload:, address field Return→go:).
- **Import collision fixed with `only-in`:** the generated `foundation/nserror`
  exports `nserror-code`/`nserror-domain`, colliding with `runtime/objc`'s ADR-0006
  `nserror` defstruct accessors. The app imports only `nserror-localized-description`
  via `(only-in …)`. App-level fix, no emitter change. (Pattern to remember for any
  app importing a generated module whose names overlap a runtime defstruct.)
- Idiom: WKWebView needs `initWithFrame:configuration:` (create a
  `WKWebViewConfiguration` up front, no bare init); NSString returns are `wrap`ped
  so reading is `(nsstring->string (->ptr obj))` guarded by `wrap`→#f; delegate args
  wrapped via the 'object token; `nscontrol-set-target!`/`-action!` for the field +
  buttons. URL normalisation hand-rolled (no regex). [[project_gerbil_grove]]
- Cosmetic: window title lags (`wkwebview-title` "" at `didFinishNavigation:` time —
  WebKit title KVO lags the finish callback; matches racket/chez).
