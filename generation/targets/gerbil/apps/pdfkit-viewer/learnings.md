# pdfkit-viewer x gerbil

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
