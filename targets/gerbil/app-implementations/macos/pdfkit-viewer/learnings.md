# pdfkit-viewer x gerbil

**2026-07-02 (AppSpec instrument + build, leaf k100):**
- 🟢 Instrumented to the k96 logging contract
  (`apps/macos/pdfkit-viewer/docs/logging-contract.md`): emitter inlined in the
  `.ss` (the k91 gallery rationale — the bundler's closure walk follows only
  `:gerbil-bindings/…` references, and the emitter uses only Gambit primitives,
  so it rides the statically-linked prelude), with the two `[document]`
  state-transition events (`opened` / `page-changed`) + the contract's string
  quoting. `[lifecycle] startup` + `pv-events-init!` are top-level expressions
  *before* `(main)` (the k91 placement — the viewer builds its window/PDF view
  in main's defines section), and the launch line is dual-emitted before
  `nsapplication-run`.
- **App-level shape mirrors the racket/chez siblings (k98/k99)**: `refresh-ui!`
  returns the state it applied (`#f` empty / `(page . total)` loaded), so both
  `[document]` events mirror the §7.2 label by construction, including the
  nil-current-page fallback to page 1. `opened` fires only on the open success
  path, post-refresh, with `file` = the URL's last path component
  (`nsurl-last-path-component` → `nsstring-utf8-string`; `wrap`→#f covers a nil
  NSString and the FFI maps a NULL UTF8String to #f, hence the `(or … "")`
  guard); `page-changed` rides the `pageChanged:` observer post-refresh. Silent
  no-ops (cancel / nil URL / failed `initWithURL:`) emit nothing. New
  `applicationWillTerminate:` delegate → `reason=menu`.
- **The k99 chez handoff held exactly**: the local gerbil binding tree predated
  the k98 PDFKit collection (generics present, no `pdfkit/` modules) —
  regenerated via `apianyware-generate --target gerbil` (29 PDFKit classes; the
  trampoline set grew to 170 entries: 2 constants + 69 inits + 99 methods) and
  relinked the adapter via `swift build --product APIAnywareGerbil` (`--product`,
  not `--target`). `build.sh`'s bindings prereq keys on `pdfkit/pdfview.ss`,
  not `generics.ss`, so a stale pre-PDFKit tree regenerates. No gcc-15 shim
  needed — a real `gcc-15` is on PATH on this host.
- 🟢 Emitter verified in isolation against the contract matchers (block
  extracted verbatim from the `.ss`, driven under plain `gxi`: 16 assertions —
  startup-first ordering, launch-line `PDFKit Viewer` prefix, both `[document]`
  matcher lines exact, quoting edges `\\`/`\"`/newline, env + fixed-default
  path resolution with parent-dir creation, truncate-on-startup,
  emit-after-close no-op). Built standalone via new `build.sh` (k91 recipe):
  `PDFKitViewer-gerbil.app` (51 MB; generics 29 shards 97.9s + closure 74.5s +
  exe link 212.8s on the cold regenerated cache),
  `CFBundleIdentifier=com.linkuistics.pdfkit-viewer-gerbil`,
  `codesign --verify --strict` OK; PDFKit framework-linked,
  `libAPIAnywareGerbil.dylib` vendored into `Contents/Frameworks/` beside the
  openssl pair. Descriptor `pdfkit-viewer-impl.rkt` authored. Live launch is
  the Tier-2 live-run leaf's bar (VM).

**2026-06-09 (standalone, grove leaf `100/040`):**
- 🟢 Ported and VM-verified as a self-contained `.app` (dylib-clean, PDFKit-linked,
  static Gambit runtime). In a **no-Gerbil VM**: Open… opens an NSOpenPanel, the
  selected 3-page PDF renders in a PDFView, the ◀/▶ toolbar buttons navigate, and
  the "Page n of N" label tracks every page change with correct boundary
  enable/disable (page 1: ◀ off; page 3: ▶ off; mid: both on). See
  `generation/targets/gerbil/test-results/pdfkit-viewer/report.md`.
- **Rung-4 feature: one `make-delegate`, four selectors**, serving as BOTH the
  target-action target (`openDocument:`/`goPrev:`/`goNext:`) AND the
  NSNotificationCenter observer (`pageChanged:` on `PDFViewPageChangedNotification`).
  The label updates flow through the notification, not an explicit call. First
  gerbil app to use NSOpenPanel (modal `runModal`), PDFKit, and a notification
  observer.
- **Built clean on first attempt** — the four leaf-030 toolchain fixes carried
  over. The `-framework` on the `gxc -O` closure pass is again load-bearing:
  PDFKit `constants.ss` references `PDFViewPageChangedNotification` as a direct
  `extern` symbol, so the closure-compile loadable link needs `-framework PDFKit`.
- Idiom: inherited NSSavePanel methods (`runModal`/`URL`/`setAllowedFileTypes:`)
  dispatch on the open panel via the declaring-class proc (`nssavepanel-*`);
  `make-delegate` instance passed straight to `nscontrol-set-target!` /
  `add-observer-…!`; `PDFViewPageChangedNotification` is already `wrap`ped (no
  `borrow-objc-object`); `wrap`→#f makes nil checks plain truthiness; file-type
  filter is a one-element `NSMutableArray`.
