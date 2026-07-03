# Sample App Portfolio Design

> **Status (as of `portfolio-coverage-tie-in-k85`, 2026-07-04):** this is the *original*
> portfolio design rationale (why these apps), kept as a dated record. It is **superseded for
> current status** by [`_index.md`](_index.md) (the live catalogue) and `apianyware-conformance`
> (derived per-target status). Since this was written, the whole portfolio shipped and is
> VM-verified on all four targets: **PDFKit Viewer is no longer blocked** (the Quartz/PDFKit
> collection was fixed; it is a full portfolio app), a **Swift-Native Probe** was added (the
> Swift-native trampoline coverage proof), and each app now carries a first-class AppSpec
> (`spec.md` + contracts + a `#lang app-spec` scenario suite) rather than the prose specs assumed
> below. The "Retirement plan" and "Pipeline prerequisite" sections are historical. Read this doc
> for the *design reasoning*; read `_index.md` for what the portfolio *is* today.

Redesign of the Racket sample app portfolio to maximize API coverage and
novel pattern exercise, informed by Modaliser-Racket's real-world coverage
and the availability of LLM-assisted replication + TestAnyware for
automated VM interaction testing.

## Context

The original sample app set (hello-window, counter, ui-controls-gallery,
file-lister, menu-bar-tool, text-editor, mini-browser) was designed when
manual replication across target languages was a constraint — simplicity was
a feature. Two changes remove that constraint:

1. **Modaliser-Racket** exercises NSStatusBar, NSMenu, target-action, accessory
   lifecycle, clipboard, CGEvent taps, WKWebView rendering, Accessibility APIs,
   and dynamic ObjC subclasses — superseding the Menu Bar Tool and partially
   overlapping the File Lister's delegate pattern.
2. **LLMs + TestAnyware** automate both app porting (to new language
   targets) and visual verification, so apps can be richer without increasing
   per-language cost.

## Portfolio

### Retained Apps

| App | Rationale |
|---|---|
| **hello-window** | Smoke test — "does a window appear?" (~30 lines). First-check for new language targets. Costs nothing to keep. |
| **ui-controls-gallery** | Widget regression suite — 15+ control types, enum constants, layout patterns. No other app covers this breadth. |

### Retired Apps

| App | Rationale |
|---|---|
| **counter** | Fully subsumed — every interactive app exercises target-action + mutable state. ui-controls-gallery covers buttons with callbacks. |
| **file-lister** | NSTableView data-source delegate proven by Modaliser-Racket. NSOpenPanel exercised by Note Editor. NSFileManager is a trivial binding call. |
| **menu-bar-tool** | Already marked `done (superseded)` — Modaliser-Racket covers every pattern. |

### New Apps

#### 1. Note Editor

Markdown editor with live preview. Exercises text editing, undo/redo,
file I/O with completion blocks, notification observation, and cross-framework
rendering (AppKit + WebKit).

**Layout:**
- NSSplitView: left pane NSTextView (editor), right pane WKWebView (HTML preview)
- Toolbar: New, Open, Save, Undo, Redo buttons
- Window title: filename + dirty indicator (e.g. "notes.md — edited")

**Interactions:**
1. Type markdown → preview updates live (debounced via NSNotificationCenter
   text-change observation). Markdown→HTML conversion via a bundled JS library
   (e.g. marked.js) evaluated inside the WKWebView, keeping the Racket side
   simple — it sends raw markdown text via `loadHTMLString` with an inline
   script that renders it.
2. Cmd+S → NSSavePanel (first save) or direct write (subsequent), completion
   block confirms success
3. Cmd+O → NSOpenPanel, loads file into NSTextView
4. Cmd+Z / Cmd+Shift+Z → NSUndoManager undo/redo
5. Window title tracks dirty state via notification observation

**API surface:**
- NSTextView — main editor
- NSSplitView — side-by-side layout
- WKWebView — markdown→HTML preview (loadHTMLString)
- NSUndoManager — undo/redo integration
- NSNotificationCenter — observe NSTextDidChangeNotification
- NSSavePanel — file save with completion block
- NSOpenPanel — file open
- NSFileManager — file read/write
- NSAlert — unsaved-changes confirmation dialog

**Novel patterns:**
- NSNotificationCenter observation (register/remove observer)
- Completion block on NSSavePanel (`beginSheetModalForWindow:completionHandler:`)
- NSUndoManager integration (direct or via NSTextView's built-in undo)
- WKWebView loadHTMLString (local HTML, not URL navigation)
- Window dirty-state tracking (observing mutations → updating UI)

**VM test strategy:**
1. Launch → verify split pane visible, preview shows placeholder
2. Type `# Hello` → verify heading appears in preview (OCR)
3. Cmd+S → verify NSSavePanel appears, save to known path
4. Modify text → verify title shows "edited" indicator
5. Cmd+Z → verify text reverts, indicator clears
6. Cmd+O → open pre-staged file, verify content loads

---

#### 2. Mini Browser

Minimal web browser with URL bar, navigation controls, and WKNavigationDelegate.
Exercises the async multi-step delegate pattern — structurally different from
the synchronous data-source delegates already validated.

**Layout:**
- URL bar (NSTextField) with Go button
- Navigation bar: Back, Forward, Reload
- Loading indicator (NSProgressIndicator)
- WKWebView fills remaining space
- Window title updates to page title

**Interactions:**
1. Type URL + Enter → WKWebView loads URL
2. Page loading → progress indicator visible, didStartProvisionalNavigation fires
3. Page loaded → indicator hides, title updates, didFinishNavigation fires
4. Page failed → NSAlert shows error, didFailNavigation fires
5. Back/Forward → goBack/goForward on WKWebView
6. Reload → reload on WKWebView

**API surface:**
- WKWebView — web content display
- WKWebViewConfiguration — web view setup
- WKNavigationDelegate — async navigation callbacks
- NSURL / NSURLRequest — URL construction
- NSProgressIndicator — loading state
- NSTextField — URL bar
- NSAlert — error display

**Novel patterns:**
- Multi-callback async delegate (didStart → didRedirect? → didFinish/didFail)
- Cross-framework imports (AppKit + WebKit + Foundation)
- Generated WebKit bindings (first app using non-AppKit class wrappers; raw
  `tell` workaround for wkwebview.rkt generator bug if needed)
- NSURL/NSURLRequest URL handling

**VM test strategy:**
1. Launch → verify URL bar and empty web view
2. Type `https://example.com`, click Go → find "Example Domain" via OCR
3. Verify window title updated
4. Click link → verify navigation
5. Click Back → verify previous page
6. Type invalid URL → verify error alert

---

#### 3. Drawing Canvas

Freehand drawing app with color picker and line width control. The most
architecturally novel app — requires a dynamic ObjC subclass with `drawRect:`
override via `make-dynamic-subclass` + `add-method!`.

**Layout:**
- Custom NSView subclass fills most of window (drawing canvas)
- Toolbar: color picker button (NSColorPanel), line width slider (NSSlider),
  Clear button
- Current color/width indicator

**Interactions:**
1. Mouse down → start new stroke
2. Mouse drag → extend stroke, canvas redraws in real time
3. Mouse up → finalize stroke
4. Color button → NSColorPanel opens, color applies to next stroke
5. Slider → line width changes
6. Clear → removes all strokes, redraws blank

**API surface:**
- Custom NSView subclass via `make-dynamic-subclass`
- `drawRect:` override via `add-method!` — CoreGraphics drawing callback
- CGContext — current graphics context, stroke color/width, path drawing
- `mouseDown:` / `mouseDragged:` / `mouseUp:` via `add-method!`
- NSEvent — mouse location extraction
- NSColorPanel — system color picker
- NSColor — color representation, conversion to CGColor
- NSSlider — line width control

**Novel patterns:**
- Dynamic ObjC subclass with 4+ method overrides (drawRect:, mouseDown:,
  mouseDragged:, mouseUp:). Modaliser uses `make-dynamic-subclass` for one
  method; this uses it as the primary architectural pattern.
- CoreGraphics drawing — CGContextRef manipulation inside drawRect:
- Mouse event handling — coordinate extraction, state across event sequence
- Mutable shared state from ObjC callbacks — stroke list accessed by both
  drawing and event callbacks

**VM test strategy:**
1. Launch → verify empty canvas and toolbar
2. Mouse drag across canvas → verify line appears (screenshot diff vs blank)
3. Open color picker → verify NSColorPanel appears
4. Select different color, draw again → verify different color stroke
5. Clear → verify canvas returns to blank
6. Adjust line width, draw → verify thicker stroke

---

#### 4. SceneKit Viewer

3D scene viewer with animated geometry. The "wow factor" app — 3D rendering
from Racket using SceneKit, a completely different framework domain from
AppKit's 2D widgets.

**Layout:**
- SCNView fills most of window (3D viewport with built-in orbit/zoom via
  `allowsCameraControl`)
- Toolbar: geometry picker (NSPopUpButton — cube/sphere/torus/cylinder),
  color picker (NSColorPanel), wireframe toggle, animation toggle

**Interactions:**
1. Launch → colored 3D cube rotating slowly
2. Mouse drag → orbit camera (built-in `allowsCameraControl`)
3. Scroll → zoom (built-in)
4. Geometry picker → shape swaps, animation continues
5. Color button → NSColorPanel, color applies to geometry material
6. Wireframe toggle → wireframe rendering
7. Animation toggle → rotation pauses/resumes

**API surface:**
- SCNView — 3D viewport (NSView subclass from SceneKit)
- SCNScene — scene graph container
- SCNNode — geometry node
- SCNBox / SCNSphere / SCNTorus / SCNCylinder — parametric geometry
- SCNMaterial — surface material (diffuse color, lighting model)
- SCNLight — directional + ambient lighting
- SCNCamera — camera node
- SCNAction — rotation animation (repeatForever, rotateBy)
- NSColor — material colors
- NSPopUpButton — geometry selection
- NSColorPanel — color picker

**Novel patterns:**
- SceneKit framework end-to-end — completely different domain from AppKit widgets
- Chained object construction — scene → node → geometry → material → action
- SCNAction animation — class method factory returning action applied to node
- Cross-framework NSView subclass — SCNView is from SceneKit, embedded in
  AppKit window
- Float-heavy API — CGFloat and geometry dimensions across FFI boundary

**SCNVector3 note:** Camera/light positioning needs SCNVector3. Options:
(a) use raw `tell` for the few position-setting calls, (b) add SCNVector3
to `type-mapping.rkt`, or (c) rely on default positions + `allowsCameraControl`.
Decision deferred to implementation.

**VM test strategy:**
1. Launch → verify 3D viewport not blank (screenshot has non-uniform center)
2. Select Sphere → screenshot diff shows shape change
3. Color picker → select red → verify color change
4. Wireframe toggle → verify visual change
5. Animation: two screenshots 1s apart → differ (rotating) or match (paused)

---

#### 5. PDFKit Viewer (blocked)

**Status:** Blocked on Quartz/PDFKit collection fix.

PDF viewer with page navigation and text search. Validates that generated
bindings for a non-AppKit/non-WebKit framework "just work."

**Blocker:** PDFKit lives under the Quartz umbrella framework, which is
excluded from the subframework allowlist in `sdk.rs` due to a `clang-2.0.0`
crate UTF-8 panic. Unblocking requires either:
- Fixing the UTF-8 panic and adding Quartz to the allowlist, or
- Adding PDFKit as a narrow subframework-allowlist entry (like HIServices
  under ApplicationServices)

**Layout:**
- PDFView fills most of window
- Toolbar: Open, Previous/Next page, page indicator, search field

**Interactions:**
1. Open → NSOpenPanel (filtered to .pdf), load into PDFView
2. Previous/Next → page navigation
3. Page indicator updates on navigation
4. Search → highlights matches in PDF

**API surface:** PDFView, PDFDocument, PDFPage, PDFSelection,
NSNotificationCenter (PDFViewPageChangedNotification), NSOpenPanel.

**Novel patterns:** Non-AppKit/WebKit/SceneKit framework integration,
framework-specific notification names, filtered NSOpenPanel.

**VM test strategy:** Open pre-staged PDF → verify content visible → navigate
pages → verify indicator updates → search known term → verify highlight.

## Coverage Matrix

| Pattern | Covered by |
|---|---|
| Basic window/lifecycle | hello-window |
| Widget breadth (15+ types) | ui-controls-gallery |
| NSStatusBar/NSMenu/accessory app | Modaliser-Racket |
| CGEvent tap / Accessibility | Modaliser-Racket |
| NSPasteboard (clipboard) | Modaliser-Racket |
| WKWebView (HTML rendering) | Modaliser-Racket, Note Editor |
| Target-action delegates | Modaliser-Racket, all interactive apps |
| Data-source delegates | Modaliser-Racket |
| NSTextView / rich text editing | Note Editor |
| NSUndoManager | Note Editor |
| NSNotificationCenter observation | Note Editor, PDFKit Viewer |
| NSSavePanel completion blocks | Note Editor |
| NSSplitView layout | Note Editor |
| Window dirty-state tracking | Note Editor |
| WKNavigationDelegate (async multi-step) | Mini Browser |
| Cross-framework WebKit | Mini Browser, Note Editor |
| NSURL / NSURLRequest | Mini Browser |
| NSProgressIndicator | Mini Browser |
| NSAlert (error/confirmation) | Note Editor, Mini Browser |
| Dynamic ObjC subclass (multi-method) | Drawing Canvas |
| CoreGraphics drawing (CGContext) | Drawing Canvas |
| Mouse event handling | Drawing Canvas |
| NSColorPanel | Drawing Canvas, SceneKit Viewer |
| SceneKit (3D rendering) | SceneKit Viewer |
| Cross-framework NSView subclass | SceneKit Viewer |
| SCNAction animation | SceneKit Viewer |
| Scene graph object construction | SceneKit Viewer |
| PDFKit | PDFKit Viewer (blocked) |

## Pipeline prerequisite

**Unblock PDFKit collection:** Fix the Quartz subframework UTF-8 panic in
the `clang-2.0.0` crate, or add PDFKit as a narrow allowlist entry in
`sdk.rs`. This is a core pipeline task, not a sample app task. Filed to
the core backlog.

## Retirement plan

When the new apps are implemented:
1. Delete `apps/counter/` directory and `knowledge/apps/counter/`
2. Delete `apps/file-lister/` directory and `knowledge/apps/file-lister/`
3. Remove counter and file-lister from `RUNTIME_LOAD_CHECKS` in the harness
   (replace with new apps)
4. Update `README.md` app count and descriptions
5. Delete old Text Editor and Mini Browser specs from `knowledge/apps/`
   (replaced by this design)
