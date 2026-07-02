# pdfkit-viewer x racket

**2026-06-02 (Racket 9.2 + ffi2, native dispatch) — first VM verification:**
- 🟢 Toolbar (Open… / prev / next + status) + empty PDFView render ("No PDF loaded").
- 🟢 Opening a 2-page PDF via NSOpenPanel renders the document in PDFView; status
  shows "Page 1 of 2"; the next-page arrow enables; clicking it advances to
  "Page 2 of 2" with correct enable/disable of the nav arrows. PDFKit document
  load + render + page navigation work through generated bindings + native dispatch.
- TestAnyware VM (macOS 26.3).

**2026-07-02 (racket-instrument-build-k98) — AppSpec logging instrumentation + self-contained .app:**
- Instrumented to the k96 logging contract (`apps/macos/pdfkit-viewer/docs/logging-contract.md`):
  `events.rkt` (gallery k89 template; launch line renamed `emit-launch-line` because this app
  has a real `[document] opened` event), startup/shutdown + `applicationWillTerminate:`
  delegate wiring, dual-emitted launch line.
- **Event ≡ label by construction:** `refresh-ui!` now *returns* the state it applied
  (`#f` empty / `(cons page total)` loaded); both `[document]` emits read that return value,
  so the log can never disagree with the §7.2 label — including the nil-current-page
  fallback to page 1.
- `file` basename via `nsurl-last-path-component` + `nsstring-utf8-string` (nil-guarded);
  cancel / nil URL / failed `initWithURL:` stay silent no-ops (no emit in those branches).
- `emit-document-opened` fires **after** `refresh-ui!`; note `pdfview-set-document!` may
  itself fire the page-changed observer first, so `page-changed page=1` can precede
  `opened` — the contract explicitly permits either order (consumers match specific
  lines, never sequence).
- Isolation verify: all contract matchers green against the emitter (startup / bare launch
  line / opened / page-changed interior+boundary / shutdown / quoting edge / re-init
  truncation / env-var fallback).
- Build: `build.sh` mirrors the gallery (bundler → rename `PDFKit Viewer.app` →
  `PDFKitViewer-racket.app` → PlistBuddy `com.linkuistics.pdfkit-viewer-racket` → re-sign →
  self-containment gate). In-place `raco make` cannot compile the impl (the `../../generated/`
  requires resolve only in the bundler's staging tree) — the bundler's `raco exe` is the
  compile gate.
- PDFKit was missing from the local partial corpus: collected (`SDKROOT=macosx`) + resolved
  deps-together (`--only Foundation,AppKit,PDFKit`), regenerated racket bindings, and relinked
  the adapter dylib (`swift build --product APIAnywareRacket` — the trampoline set grew with
  the third family). Goldens unmoved. Self-containment report: 86M, distributed exe present,
  no `/opt/homebrew` links, `libAPIAnywareRacket.dylib` carried.
