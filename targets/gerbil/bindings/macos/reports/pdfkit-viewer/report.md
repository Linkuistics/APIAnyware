# PDFKit Viewer — Gerbil Test Report

**Date:** 2026-06-09
**Status:** PASS — fourth gerbil sample app. First to use **NSOpenPanel** (modal),
**PDFKit**, and an **NSNotificationCenter observer**; first with a single
`make-delegate` carrying **four selectors** that doubles as both target-action
target and notification observer (rung 4 of the feature ladder).

Done-bar for grove leaf `100-sample-apps/040-pdfkit-viewer`: the self-contained
`.app` built by `bundle-gerbil` opens a PDF via NSOpenPanel, renders it in a
PDFView, navigates pages via toolbar buttons, and keeps a "Page n of N" label in
sync — VM-verified in a **no-Gerbil VM** ([[feedback-vm-verify-every-app]]).

## Build

`cargo run --example bundle_app -p apianyware-bundle-gerbil -- pdfkit-viewer`.
Output: `…/apps/pdfkit-viewer/build/PDFKit Viewer.app`, bundle id
`com.linkuistics.PDFKitViewer`, codesigned. `otool -L` is dylib-clean — system
frameworks (AppKit, **PDFKit**, Foundation, …) + vendored openssl; Gambit runtime
statically embedded. **Built clean on the first attempt** — the four toolchain
fixes from leaf 030 carried over (notably the `-framework` on the `gxc -O` closure
pass: PDFKit's `constants.ss` references the `PDFViewPageChangedNotification`
symbol directly, so the closure-compile loadable link needs `-framework PDFKit`).
Build ~11.9 min cold (generics 312s · facade 15s · 24 modules `-O` 77s · `-exe -O`
link 313s).

## VM verify (no-Gerbil bar)

Golden `testanyware-golden-macos-tahoe`, arm64, macOS 26 (1024×768). App tarball
(md5-verified) + a 3-page test PDF (`cupsfilter`-generated) uploaded, `xattr -dr
com.apple.quarantine`, launched via `open -n`. No runtime errors.

Results (`pdfkit-viewer-empty.png`, `pdfkit-viewer-page1.png`,
`pdfkit-viewer-page3.png`):

- [x] Window draws, titled **"PDFKit Viewer"**, with the toolbar (Open… / ◀ / ▶ /
      label) pinned to the top edge over the PDFView. **Empty state**: label
      "No PDF loaded", **both ◀ and ▶ disabled** (`nscontrol-set-enabled! #f`).
      The "Open…"/"◀"/"▶" glyphs render correctly (UTF-8 string path).
- [x] Standard app menu reads **"PDFKit Viewer"** (About/Hide/Quit).
- [x] **Open… opens an NSOpenPanel** (`openDocument:` → `nsopenpanel-open-panel` +
      inherited `nssavepanel-run-modal`). Selecting the PDF ran
      `make-pdfdocument-init-with-url` → `pdfview-set-document!` → `refresh-ui!`.
- [x] **PDF renders**: page 1 content shown, label **"Page 1 of 3"**, ◀ disabled
      (first page) / ▶ enabled — `pdfdocument-page-count` = 3 and the
      can-go-prev/next enable logic are correct.
- [x] **Next navigates forward**: ▶ → "Page 2 of 3" → "Page 3 of 3"; on the last
      page ▶ disables and ◀ stays enabled. The label updates came through the
      **`pageChanged:` notification observer** (`PDFViewPageChangedNotification`),
      not an explicit call — proving the single delegate serves as both
      target-action target and NSNotificationCenter observer.
- [x] **Prev navigates back**: ◀ → "Page 2 of 3", both buttons enabled
      (mid-document) — `goPrev:` works and the enable state is bidirectional.

The 4-selector `make-delegate` (openDocument:/goPrev:/goNext: target-actions +
pageChanged: observer), NSOpenPanel modal loop, PDFKit rendering, and the
notification-driven label all work under whole-program `-O` in a no-Gerbil VM.

## Idiom notes

- Inherited NSSavePanel methods (`runModal`/`URL`/`setAllowedFileTypes:`) dispatch
  on the NSOpenPanel via the **declaring class's proc core** (`nssavepanel-*`),
  the same inherited-dispatch idiom as ui-controls' `nscontrol-double-value`.
- `make-delegate` returns a bound instance passed straight to
  `nscontrol-set-target!` and `nsnotificationcenter-add-observer-…!` (no chez
  `delegate-ptr`); `PDFViewPageChangedNotification` is already a `wrap`ped object,
  so it flows directly into the observer setter (no chez `borrow-objc-object`).
- `wrap` returns #f for nil, so nil checks are plain truthiness; the file-type
  filter is a one-element `NSMutableArray` of `"pdf"`.

See [[feedback-use-testanyware]], [[reference-testanyware-cli]],
[[feedback-sample-apps-perfect]].
