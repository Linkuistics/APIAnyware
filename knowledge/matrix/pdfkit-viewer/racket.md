# pdfkit-viewer x racket

**2026-06-02 (Racket 9.2 + ffi2, native dispatch) — first VM verification:**
- 🟢 Toolbar (Open… / prev / next + status) + empty PDFView render ("No PDF loaded").
- 🟢 Opening a 2-page PDF via NSOpenPanel renders the document in PDFView; status
  shows "Page 1 of 2"; the next-page arrow enables; clicking it advances to
  "Page 2 of 2" with correct enable/disable of the nav arrows. PDFKit document
  load + render + page navigation work through generated bindings + native dispatch.
- TestAnyware VM (macOS 26.3).
