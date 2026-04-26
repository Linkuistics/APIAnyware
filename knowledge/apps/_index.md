# App Catalogue

Sample apps progress from simple to complex. Each exercises specific macOS/binding capabilities. Authoritative portfolio per `docs/specs/2026-04-16-sample-app-portfolio-design.md`.

| # | App | Key Capabilities |
|---|-----|-----------------|
| 1 | hello-window | Window lifecycle, property setters, NSTextField label (smoke test) |
| 2 | ui-controls-gallery | 15+ AppKit controls, enum constants, layout patterns (widget regression suite) |
| 3 | note-editor | NSTextView, NSSplitView, WKWebView preview, NSUndoManager, NSSavePanel completion blocks, NSNotificationCenter |
| 4 | mini-browser | WKWebView, WKNavigationDelegate (async multi-step), NSURL/NSURLRequest, NSProgressIndicator |
| 5 | drawing-canvas | Dynamic ObjC subclass with `drawRect:` + mouse events, CoreGraphics drawing, NSColorPanel |
| 6 | scenekit-viewer | SceneKit 3D rendering, SCNAction animation, scene graph construction |
| 7 | pdfkit-viewer | PDFView, PDFDocument, framework-specific notifications (blocked on Quartz collection fix) |
| 8 | modaliser | Keyboard capture (CGEvent tap), window management, overlays (WKWebView), NSStatusBar/NSMenu, config system (capstone exerciser) |

Retired: `counter/`, `menu-bar-tool/`, and `text-editor/` removed (2026-04-27); `file-lister/` retained — still cited as the canonical demo app by `generation/crates/bundle-racket-oo/tests/bundle_file_lister.rs` (integration test fixture), the top-level `README.md` bundle-layout example, `generation/targets/racket-oo/docs/developer-guide.md`'s VM-testing walkthrough, and `knowledge/targets/racket-oo.md`'s NSTableView/NSStackView learnings. Removing it requires rewiring those references first.
