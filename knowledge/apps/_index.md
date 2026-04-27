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

Retired: `counter/`, `file-lister/`, `menu-bar-tool/`, and `text-editor/` removed (2026-04-27). `hello-window` is now the canonical demo app for the bundler integration test, the top-level `README.md` bundle-layout example, the racket-oo developer guide, and the VM-testing walkthrough. NSTableView/NSStackView learnings originally surfaced via file-lister are retained as historical attribution in `knowledge/targets/racket-oo.md`.
