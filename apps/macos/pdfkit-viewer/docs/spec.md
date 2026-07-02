# PDFKit Viewer

*Reverse-generated (LLM) from the four existing VM-verified implementations (racket,
chez, gerbil, sbcl) on 2026-07-02, then human-validated by git review (ADR-0050,
ADR-0052): this prose is the target-independent source of truth; the four
implementations are its projections.*

## 1. Structural facts

- **app-kind:** `gui-app` (the bundled, windowed Cocoa app — `platforms/macos/app-kinds/gui-app/`)
- **display name:** PDFKit Viewer *(the bundlers read this from the first H1 above)*
- **complexity:** 7/7 (the portfolio's seventh rung — the framework-notification
  document viewer)
- **API frameworks:** PDFKit (`PDFView`, `PDFDocument`, `PDFPage`,
  `PDFViewPageChangedNotification`), AppKit (window, toolbar controls, open panel,
  notification center wiring), Foundation (strings, geometry value types, arrays, URLs,
  `NSNotificationCenter`)
- **pattern-kinds exercised:** `target-action` · `observer` (notification-center
  observer) · `parent-child` (view containment) · object-lifecycle ·
  property-configuration · class-method-factory · value-type-geometry ·
  option-set bitmask · modal-panel interaction · notification-driven UI refresh ·
  menu object-graph construction · run-loop entry
- **native units:** none beyond the platform frameworks (pure ObjC surface of
  AppKit/Foundation/PDFKit; no app-specific native code, no custom drawing)

## 2. Purpose & intent

A minimal PDF document viewer: the user opens a `.pdf` through the standard open panel,
the document renders in an embedded `PDFView`, toolbar buttons step through its pages,
and a **"Page n of N"** status label stays synchronized with the view's current page via
the framework's page-changed notification. The behavioural core is
**document-open + page-navigation**; the app's observable document state is the status
label (current 1-based page index and total page count) — never the rendered pixel
contents. It exercises a mid-tier generated framework (PDFKit) end-to-end, a modal
`NSOpenPanel`, and an `NSNotificationCenter` observer of a framework-posted
notification. There is no persistence, no editing, and no document chrome beyond the
label.

## 3. Application kind & lifecycle

A regular, dock-visible, single-window AppKit application (`gui-app`). Launch is
deterministic:

1. **Acquire the application singleton** — the process-wide shared `NSApplication`.
2. **Become a regular app** — activation policy *Regular*
   (`NSApplicationActivationPolicyRegular` = 0): Dock icon and menu bar.
3. **Install the application menu** (§8).
4. **Build the window (§4), the toolbar and PDF view (§5)**, compose them into the
   window's content view, **wire the buttons' target-action handlers (§7), and register
   the page-changed notification observer (§7)** — the observer is registered during
   setup, before the run loop, so it is live for the first page turn.
5. **Establish the initial (empty) UI state** — run the shared UI-refresh rule (§7.2)
   once with no document loaded: the label reads `No PDF loaded`, both navigation
   buttons disabled.
6. **Present and focus** — make the window key and order it front; activate the
   application ignoring other apps so it is frontmost on launch.
7. **Announce** — write a one-line launch diagnostic to standard output. The line
   **begins with the text `PDFKit Viewer`**; the remainder (running/opened phrasing,
   quit guidance) is implementation-specific and not part of the contract.
8. **Run** — enter the AppKit run loop; the process blocks servicing events.
9. **Terminate** — via the **Quit** command (Command-Q → `-[NSApplication terminate:]`),
   the `gui-app` app-kind's termination model (`termination
   "ns-application-terminate"`). See §8.

   **Termination is Quit-driven, not close-driven.** No implementation installs an
   application delegate or opts into terminate-after-last-window-closed, and the
   app-kind does not require it; on stock AppKit, closing the window hides it and the
   process keeps running **(unknown — to confirm in-VM)**. Three implementations' printed
   guidance ("Close window … to exit") suggests otherwise; that text is guidance prose,
   not behaviour.

No timers or background work; all dynamism is user-initiated (button actions, panel
interaction, and the page-changed notification they trigger).

## 4. Window

A single top-level window created through the designated initializer
`initWithContentRect:styleMask:backing:defer:`:

- **Content rectangle:** origin `(0, 0)`, size **720 × 540** points (recentered before
  display, so the origin is irrelevant).
- **Style mask:** the bitwise-OR of **Titled** (1) · **Closable** (2) ·
  **Miniaturizable** (4) · **Resizable** (8). Resizable is deliberate: the layout is
  built to track resize (autoresizing masks, §5) and the PDF view rescales its content
  proportionally (auto-scaling, §5.2).
- **Backing store:** *Buffered* (`NSBackingStoreBuffered` = 2). **Defer:** *false*.
- **Title:** the literal string **`PDFKit Viewer`** — invariant across implementations
  (it names the app, not the loaded document; opening a document does not retitle the
  window).
- **Minimum content size:** **480 × 360** points — the window cannot be shrunk below
  this.
- **Position:** recentered via the window's standard `center` behaviour before display.

## 5. Content layout

Two regions fill the content view: a toolbar strip pinned to the top edge, and the PDF
view filling everything below it. Both are direct subviews of the window's content view
and track window resize through autoresizing masks (no Auto Layout constraints).

### 5.1 Toolbar

A **horizontal stack view** (`NSStackView`), frame `(12, 500, 696, 32)` in the content
view's bottom-left-origin space — i.e. a 32-point strip inset 12 points from the left,
spanning the top of the 540-point-tall content area:

- **Orientation:** horizontal (`NSUserInterfaceLayoutOrientationHorizontal` = 0);
  **alignment:** first-baseline (`NSLayoutAttributeFirstBaseline` = 12) so the buttons
  and label sit on a shared text baseline; **spacing:** 8 points.
- **Arranged subviews, in order:** the **Open button**, the **previous-page button**,
  the **next-page button**, the **page label**. (Individual control frames are stack
  arrangement details, not part of this contract.)
- **Autoresizing:** width-sizable + min-Y-margin — the strip grows with window width and
  stays **pinned to the top edge** as the window resizes.

The three buttons all use the **rounded bezel style** (`NSBezelStyleRounded` = 1):

| Control | Title | Role |
|---------|-------|------|
| Open button | `Open…` (U+2026 horizontal ellipsis) | present the open panel (§6) |
| Previous-page button | `◀` (U+25C0) | go to the previous page (§7.1) |
| Next-page button | `▶` (U+25B6) | go to the next page (§7.1) |

The **page label** is an `NSTextField` configured with the static-label idiom —
**editable = false, selectable = false, bezeled = false, drawsBackground = false** — in
the **system font at 13 points**. Its text is owned entirely by the UI-refresh rule
(§7.2); at launch it reads **`No PDF loaded`**.

### 5.2 PDF view

A `PDFView` with frame `(0, 0, 720, 492)` — filling the window below the toolbar strip:

- **Autoresizing:** width-sizable + height-sizable — it grows with the window in both
  dimensions.
- **Auto-scaling on** (`setAutoScales:` true): PDFKit picks a reasonable initial zoom
  and keeps the content scale proportional as the window resizes. The app sets no
  explicit zoom factor and exposes no zoom controls.
- **Display mode: single-page continuous** (`kPDFDisplaySinglePageContinuous` = 1) —
  the Preview.app-like feel: the document is scrollable, but navigation operates in
  one-page units for the toolbar buttons.
- The view starts **empty** (no document assigned) and renders nothing until the first
  successful open.

## 6. Document model & the open flow

- **The app ships no document.** There is no bundled resource, no generated document,
  and no hard-coded path: **the only way a document enters the app is the user's
  open-panel selection**. (Acceptance fixtures must therefore be provisioned into the
  test environment and selected through the panel — see §13.)
- **The loaded document is tracked in application state**, initially empty and assigned
  exactly once per successful open — the app never reads the document back from the
  `PDFView`. *Why:* the view's document is nil until first assignment, and every
  implementation avoids round-tripping through that nullable property.

**Open flow** — activating the Open button:

1. Obtain the standard **`NSOpenPanel`** (class factory `openPanel`) and configure it:
   **canChooseFiles = true**, **canChooseDirectories = false**,
   **allowsMultipleSelection = false**, and **allowed file types = a one-element array
   containing the string `pdf`** (`setAllowedFileTypes:` — deprecated since macOS 12
   but functional; the modern `setAllowedContentTypes:` needs UniformTypeIdentifiers'
   `UTType`, outside the generated surface) so the panel is filtered to `.pdf` files.
2. Run the panel **modally** (`runModal` — declared on `NSSavePanel`, invoked on the
   open panel); the action handler blocks until the panel is dismissed.
3. **Only when the response is OK** (`NSModalResponseOK` = 1): read the panel's `URL`.
4. **Boundary — nil URL:** if the panel returns no URL, nothing happens (no state
   change, no error surfaced).
5. Construct a **`PDFDocument`** from the URL (`initWithURL:`).
6. **Boundary — failed document construction:** if the initializer fails (e.g. the file
   is not a readable PDF), nothing happens — the previously displayed state, document
   reference, and label are all left unchanged; no error dialog is shown.
7. On success: store the document in the app's state (**replacing** any previously
   loaded document), assign it to the PDF view (`setDocument:`), and run the UI-refresh
   rule (§7.2) — the one place a refresh is invoked explicitly rather than via the
   notification.
8. **Boundary — cancel:** dismissing the panel without confirming (response ≠ OK)
   changes nothing; the prior state stays displayed.

## 7. Page navigation & UI synchronization

### 7.1 Navigation actions

- The previous-/next-page buttons send **`goToPreviousPage:`** / **`goToNextPage:`** to
  the PDF view, passing a nil sender (PDFKit ignores it).
- The navigation handlers **do not refresh the UI themselves**: the page change they
  cause makes PDFKit post the page-changed notification, and the observer performs the
  refresh. This indirection is the point — the label stays correct **however** the page
  turns (toolbar buttons, keyboard arrows, trackpad scrolling — any navigation the view
  itself handles) **(non-button navigation paths to confirm in-VM)**.

### 7.2 The UI-refresh rule (single source of truth for label + button state)

- **No document loaded:** label = `No PDF loaded`; previous and next buttons both
  **disabled**.
- **Document loaded:** with *total* = the document's `pageCount` and *index* = the
  document's `indexForPage:` of the view's `currentPage` (a `PDFPage` used purely as an
  opaque identity token):
  - label = **`Page {index+1} of {total}`** — the page number displayed is **1-based**;
  - previous-button enabled = the view's **`canGoToPreviousPage`**;
  - next-button enabled = the view's **`canGoToNextPage`**.
- **Boundary — transiently nil current page** (e.g. mid-document-swap): treated as index
  0, so the label falls back to `Page 1 of {total}` instead of failing.

### 7.3 The notification observer

- The app registers **one observer** with the default `NSNotificationCenter`
  (`defaultCenter` + `addObserver:selector:name:object:`) for
  **`PDFViewPageChangedNotification`**, with the **object filter set to the app's PDF
  view** — only that view's page changes fire it.
- The observer callback runs the UI-refresh rule (§7.2); the notification payload is
  ignored.
- The observer is registered once during setup and **never unregistered** —
  app-lifetime registration is the contract; there is no balancing unregister (see
  §12).

### 7.4 Boundary behaviour (each its own assertion; see §13)

- **At the first page:** the previous-page button is **disabled**; the next-page button
  is enabled (for a document of ≥ 2 pages) **(to confirm in-VM — the enablement rule is
  code-witnessed; its first-page truth value is platform runtime behaviour)**.
- **At the last page:** the next-page button is **disabled**; the previous-page button
  is enabled **(to confirm in-VM, as above)**.
- **At an interior page:** both buttons are enabled **(to confirm in-VM)**.
- **Navigation at a boundary is inert:** the disabled control cannot advance past the
  document's ends; no wrap-around exists **(to confirm in-VM)**.
- **Empty state:** with no document, both buttons are disabled and clicking them does
  nothing observable.
- **Display-mode behaviour:** the loaded document scrolls continuously, and
  button-driven navigation moves in single-page units, each turn updating the label
  **(to confirm in-VM)**.
- **Zoom behaviour:** no zoom controls exist; content scale follows the window size via
  auto-scaling **(to confirm in-VM; the closed scenario-verb set has no window-resize
  gesture, so this stays spec prose without a runnable assertion)**.

## 8. Application menu

- The menu bar carries one application menu; its bold app-name slot comes from the
  bundle's `CFBundleName` when launched as a `.app` bundle.
- The mandated behaviour is a **Quit** command: title **`Quit PDFKit Viewer`**
  (`"Quit " + <display name>`), **key equivalent Command-Q**, action
  **`-[NSApplication terminate:]`** — the app-kind's termination model.
- A conforming implementation may include the other conventional first-menu items
  (About, Hide, …); only *Quit (Command-Q) terminates the app* is asserted.

## 9. API surface exercised

Selectors witnessed in **every** implementation (or named by the app-kind contract) —
platform truths, projection-free:

| Class | Selector | Kind | Role |
|-------|----------|------|------|
| NSApplication | `sharedApplication` | class accessor (singleton) | obtain the app instance |
| NSApplication | `setActivationPolicy:` | property setter | become a Regular app |
| NSApplication | `activateIgnoringOtherApps:` | instance method | foreground on launch |
| NSApplication | `run` | instance method | enter the run loop |
| NSApplication | `terminate:` | instance method | quit (app-kind termination; invoked by the Quit item) |
| NSWindow | `initWithContentRect:styleMask:backing:defer:` | designated initializer | create the window |
| NSWindow | `setTitle:` · `center` · `setMinSize:` · `contentView` · `makeKeyAndOrderFront:` | setters/methods/getter | title, position, size floor, composition root, show+focus |
| NSView | `addSubview:` | instance method | view containment |
| NSView | `setAutoresizingMask:` | property setter | resize tracking (toolbar & PDF view) |
| NSButton | `setTitle:` · `setBezelStyle:` | property setters | toolbar button chrome |
| NSControl | `setEnabled:` | property setter | nav-button enablement (§7.2) |
| NSControl | `setStringValue:` · `setFont:` | property setters | page-label text & font |
| NSTextField | `setEditable:` · `setSelectable:` · `setBezeled:` · `setDrawsBackground:` | property setters | static-label idiom |
| NSFont | `systemFontOfSize:` | class factory | the 13-point label font |
| NSStackView | `setOrientation:` · `setAlignment:` · `setSpacing:` · `addArrangedSubview:` | setters/method | the toolbar strip |
| NSOpenPanel | `openPanel` | class factory | obtain the panel |
| NSOpenPanel | `setCanChooseFiles:` · `setCanChooseDirectories:` · `setAllowsMultipleSelection:` | property setters | panel behaviour |
| NSSavePanel *(invoked on the open panel — declared on the superclass)* | `setAllowedFileTypes:` · `runModal` · `URL` | setter/method/getter | `.pdf` filter, modal run, chosen file |
| PDFView | `setAutoScales:` · `setDisplayMode:` | property setters | §5.2 configuration |
| PDFView | `setDocument:` | property setter | display the opened document |
| PDFView | `currentPage` | property getter | the page shown (an opaque `PDFPage`) |
| PDFView | `canGoToPreviousPage` · `canGoToNextPage` | property getters | nav-button enablement |
| PDFView | `goToPreviousPage:` · `goToNextPage:` | instance methods | page navigation |
| PDFDocument | `initWithURL:` | failable initializer | construct the document from the chosen URL |
| PDFDocument | `pageCount` | property getter | the label's *N* |
| PDFDocument | `indexForPage:` | instance method | the label's *n−1* (0-based index) |
| PDFPage | *(identity only)* | — | return of `currentPage`, argument to `indexForPage:` |
| NSNotificationCenter | `defaultCenter` | class accessor | obtain the center |
| NSNotificationCenter | `addObserver:selector:name:object:` | instance method | register the page-changed observer |
| PDFKit constant | `PDFViewPageChangedNotification` | notification-name string constant | the observed notification |

**Abstract operations whose realizing selector varies per implementation** (this spec
asserts the operation, never one impl's selector): control/view instantiation + framing
(`initWithFrame:` vs. bare init + `setFrame:`); construction of the one-element
`.pdf` file-type array (immutable-array bridging vs. `NSMutableArray`
`initWithCapacity:` + `addObject:`); main-menu installation (a shared standard-menu
helper vs. inline `NSMenu`/`NSMenuItem` object-graph construction); handler-object
granularity (§10, third bullet).

**9.1 Enum / constant values used in every implementation:**

| Constant | Value | Used for |
|----------|-------|----------|
| `NSApplicationActivationPolicyRegular` | 0 | activation policy |
| `NSWindowStyleMaskTitled` | 1 | window style |
| `NSWindowStyleMaskClosable` | 2 | window style |
| `NSWindowStyleMaskMiniaturizable` | 4 | window style |
| `NSWindowStyleMaskResizable` | 8 | window style |
| `NSBackingStoreBuffered` | 2 | window backing |
| `NSBezelStyleRounded` | 1 | button bezels |
| `NSUserInterfaceLayoutOrientationHorizontal` | 0 | toolbar stack orientation |
| `NSLayoutAttributeFirstBaseline` | 12 | toolbar stack alignment |
| `NSViewWidthSizable` | 2 | autoresizing |
| `NSViewHeightSizable` | 16 | autoresizing (PDF view) |
| `NSViewMinYMargin` | 8 | autoresizing (toolbar pin-to-top) |
| `NSModalResponseOK` | 1 | open-panel confirmation (hand-defined in every implementation — absent from the generated AppKit enums) |
| `kPDFDisplaySinglePageContinuous` | 1 | PDF display mode |

## 10. API-usage patterns

- **`target-action`:** each toolbar button is wired via `setTarget:`/`setAction:` to an
  app-side handler object. All four implementations use the same app-defined action
  selector names — `openDocument:`, `goPrev:`, `goNext:` — an internal, non-observable
  convention recorded here as shared fact, not as testable contract.
- **`observer`:** the page-changed observer of §7.3 — register → callbacks → (no
  unregister; app-lifetime registration).
- **Handler-object granularity is a realization, not a rule:** one implementation wires
  four separate single-selector handler objects; the other three use one handler object
  carrying all four selectors (the three actions **plus** the `pageChanged:` observer
  callback). The invariant is only: *app-side handlers receive the three actions and the
  notification callback, and all handler objects outlive the run loop* (button targets
  and notification observers are weakly referenced by AppKit).
- **`parent-child` / view composition:** toolbar strip and PDF view into the content
  view; buttons and label arranged into the stack.
- **Modal-panel interaction:** the open panel runs modally inside a button's action
  handler; control returns with a response code.
- **Notification-driven UI refresh:** state changes flow *into* the view
  (`setDocument:`, `goTo…Page:`), and the UI derives *from* the view via the
  notification-triggered refresh — a one-way loop that keeps label and buttons correct
  for navigation the app did not initiate.
- **Failable initializer as the error path:** `initWithURL:` returning nil is the whole
  load-failure protocol; every implementation guards it and does nothing on failure.
- **Class-method factories / singletons:** `sharedApplication`, `openPanel`,
  `defaultCenter`, `systemFontOfSize:`.
- **Object lifecycle, property configuration, value-type geometry, option-set bitmask,
  menu object-graph construction, run-loop entry:** as in the app-kind and the earlier
  portfolio specs.

## 11. Observable outcomes & accessibility

**Visual outcomes:**
- A centered, resizable 720 × 540 window titled `PDFKit Viewer`, with a top toolbar
  reading `Open…` `◀` `▶` followed by the status label, above an empty document area;
  at launch the label reads `No PDF loaded` and both arrow buttons are disabled.
- After a successful open, the document's first page renders in the view **(to confirm
  in-VM)** and the label reads `Page 1 of N`.
- Each page turn updates the label; the arrow buttons' enabled states track the
  first/last-page boundaries (§7.4) **(to confirm in-VM)**.
- Native macOS control appearance throughout (no custom drawing).

**Accessibility expectations** *(in-VM confirmable)*:
- The window is exposed with accessibility title `PDFKit Viewer`.
- The three toolbar buttons are exposed as button elements with their titles
  (`Open…`, `◀`, `▶`) and truthful `enabled` states — the enabled flags are the reliable
  navigation-state signal (more reliable than a possibly pre-repaint screenshot).
- The page label is exposed as a static-text element whose value is the current label
  string.
- **The open panel is hosted out-of-process** on modern macOS, so it may not appear
  under the app's own accessibility tree; scenario drivers should drive it by keyboard
  (see §13).
- The application menu's Quit item is reachable and carries the Command-Q key
  equivalent.

## 12. Not included

- **No bundled, generated, or hard-coded document** — the open panel is the only
  document source (§6).
- **No error dialog** for a failed or cancelled open: both are silent no-ops.
- **No window retitling** on document load — the title stays `PDFKit Viewer`.
- **No zoom controls, page thumbnails, search, selection, or text extraction** — the
  PDF view's own auto-scaled rendering is the whole document UI.
- **No document-position persistence, no recents/MRU, no state across launches.**
- **No keyboard shortcuts of the app's own** for navigation (any arrow-key/scroll
  navigation is the PDF view's built-in behaviour, reflected via the notification).
- **No observer unregistration** — the notification observer is app-lifetime.
- **No close-to-quit.** Closing the window is not specified to terminate the app (§3.9).
- **No custom drawing, subclass-drawn views, timers, or background threads.**

## 13. Behavioural exemplar (acceptance / forward-generation input)

Observable assertions against a live-VM run, each mapped to a scenario-runner verb
(enumeration only — not scenario code). Assertions state the *rule* (stable
substrings/invariants), so the suite verifies any conforming implementation.

**Fixture rule:** the app ships no document, so the suite must **provision a PDF fixture
file into the VM** and select it through the open panel. The fixture should have **N ≥ 3
pages** (so first-boundary, last-boundary, *and* interior states are all reachable) with
OCR-distinguishable per-page content (e.g. a large `PAGE n` marker per page). Because
the open panel is out-of-process (§11), drive it by keyboard: `chord cmd shift g` →
`type <fixture path>` → `press return` → `press return`.

- **Process is running after launch.** → `expect-running-app`
- **Launch diagnostic is emitted.** Stdout contains a line beginning `PDFKit Viewer`. →
  `wait-for-log "PDFKit Viewer"` / `expect-log "PDFKit Viewer"`
- **Window title is correct.** The frontmost window's accessibility title is
  `PDFKit Viewer`. → `expect-ax` window AXTitle and/or `expect-ocr "PDFKit Viewer"`
- **Empty state — label.** `No PDF loaded` is readable on screen at launch. →
  `wait-for-ocr "No PDF loaded"`
- **Empty state — navigation disabled.** The `◀` and `▶` button elements report
  enabled = false. → `expect-ax` button enabled flags
- **Toolbar present.** An `Open…` button element exists. → `expect-ax`
  (and/or `expect-ocr "Open"`)
- **Open flow reaches the panel.** Clicking `Open…` presents the modal open panel
  *(out-of-process — presence may need OCR rather than the app's AX tree)*. →
  `click-at` Open…, then `wait-for-ocr` a panel affordance *(to confirm in-VM)*
- **Boundary — cancel is a no-op.** Cancelling the panel leaves `No PDF loaded`
  readable and both arrows disabled. → `click-at` Open…, `press escape`,
  `expect-ocr "No PDF loaded"`, `expect-ax` enabled flags *(to confirm in-VM)*
- **Open loads page 1.** Selecting the N-page fixture (keyboard-driven, per the fixture
  rule) yields a label reading `Page 1 of ` + N. → `chord cmd shift g`, `type`,
  `press return` ×2, `wait-for-ocr "Page 1 of"` *(to confirm in-VM)*
- **The first page renders.** The fixture's page-1 marker is readable in the document
  area. → `expect-ocr` fixture page-1 text *(to confirm in-VM)*
- **Boundary — first page.** At `Page 1 of N`: `◀` reports enabled = false, `▶`
  enabled = true. → `expect-ax` *(to confirm in-VM)*
- **Advance.** Clicking `▶` updates the label to `Page 2 of ` + N (the update flows
  through the page-changed notification). → `click-at` ▶, `wait-for-ocr "Page 2 of"`
  *(to confirm in-VM; allow a settle before screenshots — the AX label/flags update
  before the repaint)*
- **Interior page.** At an interior page both arrows report enabled = true. →
  `expect-ax` *(to confirm in-VM)*
- **Boundary — last page.** After advancing to page N: label reads `Page ` + N +
  ` of ` + N, `▶` reports enabled = false, `◀` enabled = true. → `click-at` ▶
  repeatedly, `wait-for-ocr`, `expect-ax` *(to confirm in-VM)*
- **Boundary — no wrap-around.** With `▶` disabled at page N, the label still reads
  `Page ` + N + ` of ` + N after further clicks at its position. → `click-at`,
  `expect-ocr` *(to confirm in-VM)*
- **Back.** Clicking `◀` decrements the label (`Page ` + (N−1) + ` of ` + N). →
  `click-at` ◀, `wait-for-ocr` *(to confirm in-VM)*
- **Label tracks non-button navigation.** With the document focused, arrow-key paging
  also updates the label (the observer, not the buttons, drives the refresh). →
  `click-at` the document area, `press` an arrow key, `wait-for-ocr` the changed label
  *(to confirm in-VM)*
- **Quit menu terminates the app.** Sending Command-Q ends the process. →
  `chord cmd q`, then `expect-running-app` is false
- **(To confirm in-VM) Close-button behaviour.** Activating the close control hides the
  window; per §3.9 the process is expected to keep running (no close-to-quit opt-in). A
  scenario should record the *actual* observed behaviour. → `click-at` close button,
  then `expect-running-app`
