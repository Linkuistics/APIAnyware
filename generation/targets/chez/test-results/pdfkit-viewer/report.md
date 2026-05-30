# PDFKit Viewer — Chez Test Report

**Date:** 2026-05-29
**Status:** Pass

> **Superseded by the standalone re-verification (2026-05-30) below.** The body
> describes the retired source-exec / precompile bundle. Under ADR-0009 chez apps
> ship as a self-contained open-world standalone binary; source-exec-era caveats
> (menu-bar "chez", `brew install chezscheme`) are obsolete — see the dated
> section at the end.

## Build & launch

- Dev-host bundle build: `cargo run --release --example bundle_app -p
  apianyware-macos-bundle-chez -- pdfkit-viewer` — **156.4 s**.
- Bundle size: **107 MB** (carries chez-precompiled PDFKit `.so` set).
- In-VM cold launch: window visible **~1 s** after `open -n` (well
  inside the 1-3 s precompile-on band). PDFKit is a relatively small
  framework on top of the AppKit/Foundation already cached by the
  precompile pass.

## Steps Completed
- [x] Empty-state launch: title "PDFKit Viewer", 720×572 content;
      toolbar with `[Open…]` (enabled), `[◀]` and `[▶]` (both disabled),
      and `No PDF loaded` label. PDFView area below renders as empty
      gray (screenshot-001-launch.png).
- [x] **`openDocument:` delegate** — clicking `Open…` brings up
      NSOpenPanel (`agent windows` reports `(dialog) Open`). The
      `setCanChooseFiles:`, `setCanChooseDirectories:`,
      `setAllowsMultipleSelection:` calls all run, and
      `setAllowedFileTypes:` with the single-element NSArray of NSString
      `"pdf"` does its filtering job — the sample.pdf preview pane
      renders, while non-pdf files are filtered out.
- [x] **File-load roundtrip** — navigating to `/Users/admin/sample.pdf`
      via Cmd+Shift+G + path entry, then pressing the dialog's `Open`
      button: `nsopenpanel-run-modal` returns `NSModalResponseOK`,
      `nsopenpanel-url` resolves, `make-pdfdocument-init-with-url` loads
      the document, `pdfview-set-document!` plumbs it into the PDFView,
      and `refresh-ui!` fires (screenshot-002-page1.png).
- [x] **Page 1 rendered correctly.** `Page 1 of 3` label
      (current-page index 0 + 1, page-count 3); `◀` disabled
      (`canGoToPreviousPage` = false); `◀ → ▶` enabled
      (`canGoToNextPage` = true). Page 1 text "Chez PDFKit Viewer
      Verification - Page 1" rendered.
- [x] **`goNext:` delegate + `pageChanged:` notification** — pressing
      `▶`: `pdfview-go-to-next-page` runs, PDFKit posts
      `PDFViewPageChangedNotification`, the chez observer fires
      `pageChanged:`, `refresh-ui!` re-evaluates the page index and
      button enabled-states. End state: `Page 2 of 3`, both `◀` and `▶`
      enabled, page 2 content "Page-Change Delegate Test - Page 2"
      visible (screenshot-003-page2.png).
- [x] **Mid-document state** — pressing `▶` again: `Page 3 of 3`, `◀`
      enabled, `▶` **disabled** (end of document — `canGoToNextPage`
      false), page 3 content "Multi-page Document End - Page 3" visible
      (screenshot-004-page3-next-disabled.png).
- [x] **`goPrev:` delegate** — pressing `◀`: `Page 2 of 3`, both
      buttons re-enabled, page 2 content re-rendered. Confirms the
      single observer record handles both directions; the
      `pageChanged:` callback path is symmetric (screenshot-005-page2-back.png).
- [x] Cmd+Q exits cleanly.

## Activity Monitor — RSS stability (30 s)

In-VM `ps aux` for the chez process, sampled every 5 s during idle on
page 2:

```
t=5s:  746.812 MB
t=10s: 746.812 MB
t=15s: 746.812 MB
t=20s: 746.812 MB
t=25s: 746.812 MB
t=30s: 746.812 MB
```

Zero drift across 6 samples. No unbounded growth. The PDFView idle-redraw
plus the observer-registered chez delegate hold steady. Baseline is
higher than ui-controls-gallery (525 MB) and scenekit-viewer (577 MB) —
PDFKit pulls a heavy resident page set on top of AppKit, but stable.

## Issues Found

None. The chez delegate ladder at rung 4 — one `make-delegate` record
carrying **four selectors** with one of them an NSNotificationCenter
observer rather than a target-action — works end-to-end. PDFKit emission
(PDFDocument / PDFView / PDFPage / `kPDFDisplaySinglePageContinuous` /
`PDFViewPageChangedNotification` foreign-ref) all bind cleanly.

The `borrow-objc-object` wrap on `PDFViewPageChangedNotification` (a
raw uptr `foreign-ref`) before passing to
`nsnotificationcenter-add-observer-selector-name-object!` is exactly
the pattern the runtime documents — and it works without further
massaging.

## Notes

- The cross-target test artifact baseline (`knowledge/apps/pdfkit-viewer/`)
  carries only `spec.md`. Per the leaf's notes, this verify also implies
  a chez-specific `test-strategy.md` — currently inheriting the
  spec-as-strategy stance from the racket bar. Not promoting to a
  shared test-strategy doc here; the racket port also hasn't.
- Menu-bar app name reads "chez" — same stub-launcher concern, out of
  scope.
- `agent press --label "Open…"` reported `axError: -25204` (push-on
  push-button is not standardly AXPress-pressable from the agent's
  query path) but the dialog opened anyway — TestAnyware quirk, not a
  pdfkit-viewer behaviour issue. The `Open` button inside the open
  dialog accepted `agent press` cleanly.
- The `NSModalResponseOK = 1` local define mirrors the racket app's
  workaround for AppKit/enums.sls not carrying NSModalResponse* values.
  Candidate follow-up at the emitter level if NSModalResponse is part
  of any modaliser drop we already process.

---

## Standalone re-verification (2026-05-30, leaf `060/050/040`)

**Status: PASS.** Fourth portfolio app. New axis: **multi-delegate** — one
`make-delegate` record with four selectors, including a notification-center
observer path distinct from button target-action.

**Build.** `cargo run --release --example bundle_app -p
apianyware-macos-bundle-chez -- pdfkit-viewer`. Output: `PDFKit Viewer.app`,
**5.0 MB**, bundle id `com.linkuistics.PDFKitViewer`, signed; no Chez/Scheme
linkage. No new wrapper collisions.

**VM verify (no-Chez bar).** Golden macOS 26.3 arm64, no Chez present. A 3-page
`sample.pdf` was generated in-guest (`cupsfilter`). Uploaded (md5-verified),
unpacked, quarantine-stripped, `open -n`.
- [x] Empty state correct: toolbar `[Open…] [◀] [▶]` with ◀/▶ **disabled** (no
      doc) and "No PDF loaded" (`screenshot-standalone-001-empty.png`).
- [x] **`openDocument:` trampoline fires** — clicking "Open…" opens NSOpenPanel
      (880×448 dialog); selecting `sample.pdf` (via Cmd+Shift+G go-to-folder)
      loads + renders "Page one content."
      (`screenshot-standalone-002-loaded-page1.png`).
- [x] **`pageChanged:` trampoline fires (notification observer)** — on load the
      label updates "No PDF loaded" → **"Page 1 of 3"** and `refresh-ui!` sets
      ◀ disabled / ▶ enabled. A distinct invocation path from target-action.
- [x] **`goNext:` trampoline fires** — page 1 → **"Page 2 of 3"** ("Page two
      content."), both ◀/▶ now enabled (`screenshot-standalone-003-page2.png`).
- [x] **`goPrev:` trampoline fires** — page 2 → page 1, ◀ disabled again.
- [x] **RSS ~226 MB** with the document loaded (PDFKit caches rendered page
      bitmaps — expected for a viewer; loaded-doc baseline, not a leak).

Four distinct trampoline paths (two button target-actions, the modal
NSOpenPanel-driven open, and the NSNotificationCenter observer) all fire in the
no-Chez standalone — consistent with the dispatch-substrate proof from leaf `020`.

**VM-interaction note.** The tahoe golden image's "click wallpaper → reveal
desktop widgets" behaviour stole focus on near-miss clicks. **Disabled it for the
session** with `defaults write com.apple.WindowManager
EnableStandardClickToShowDesktop -bool false; killall WindowManager`. Also note:
`screenshot --window` returns *window-relative* pixel coordinates, but `input
click` takes *screen-absolute* coordinates — click at the accessibility
snapshot's `positionX/Y` (screen-absolute) and ensure the window is key first.

**Obsoleted source-exec caveats (resolved by standalone):** menu bar reads
"PDFKit Viewer"; no `brew install chezscheme`; 5.0 MB bundle. No app code changes.
