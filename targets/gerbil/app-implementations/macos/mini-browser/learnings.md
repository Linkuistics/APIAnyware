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

**2026-07-03 (instrument+build, grove leaf `gerbil-instrument-build-k118`):**
- 🟢 Instrumented to the Mini Browser logging contract (k114) in the k109 inline-
  emitter pattern (Gambit primitives only, `mb-` prefix) and rebuilt standalone as
  `build/MiniBrowser-gerbil.app` (`com.linkuistics.mini-browser-gerbil`, build.sh
  post-processes the bundler default). CLI smoke green end-to-end: startup → launch
  line → `[nav] started url="https://example.com/"` → `finished` (fixed key order,
  bare booleans; `title=""` — the contract's first-load title lag, see the KVO note
  above) → AppleScript quit → `shutdown reason=menu`.
- **Second generics-shadow instance (the `only-in` pattern again, sharper):** the
  k116 full-WebKit corpus flattens a `stringLength` selector onto WKWebView
  (leaf-120 conformed-protocol flattening), so `webkit/wkwebview.ss` re-exports a
  **`string-length` generic** that shadows the Gambit builtin in any importer —
  `:std/generic` dispatch then fails at runtime on plain Scheme strings
  (`generic dispatch failure` in `trim-ws`, killing the app at startup). Fix:
  `(except-in :gerbil-bindings/webkit/wkwebview string-length)`. Same class as the
  emitter-side `values` coerce shadow (gerbil-k41): never rely on a bare builtin
  name where generated gerbil generics are in scope; audit each generated import's
  export list against the builtins the app calls.
- WebKit grows the gerbil trampoline residual 170 → 174 (+4 `WebKit.WebPage`
  entries) — regenerate emits the new `Trampolines.swift` (untracked) and the
  adapter MUST be relinked (`swift build --product APIAnywareGerbil`) before
  bundling, since gerbil *links* the dylib at `gxc -exe` (the k116 handoff held).
