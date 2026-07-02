# Note Editor

*Reverse-generated (LLM) from the four existing VM-verified implementations (racket, chez,
gerbil, sbcl) on 2026-07-03, then human-validated by git review (ADR-0050, ADR-0052): this
prose is the target-independent source of truth; the four implementations are its
projections.*

## 1. Structural facts

- **app-kind:** `gui-app` (the bundled, windowed Cocoa app — `platforms/macos/app-kinds/gui-app/`)
- **display name:** Note Editor *(the bundlers read this from the first H1 above)*
- **complexity:** 3/7 (the portfolio's third rung — NSTextView, NSSplitView, WKWebView
  preview, NSUndoManager, NSSavePanel completion block, NSNotificationCenter)
- **API frameworks:** AppKit (window, split view, text view, scroll view, stack view,
  buttons, text fields, alert, open/save panels, fonts, the text-change notification),
  WebKit (`WKWebView` as a local HTML renderer; two implementations also
  `WKWebViewConfiguration`), Foundation (`NSURL`, `NSUndoManager`, `NSNotificationCenter`,
  strings, geometry value types; two implementations `NSMutableArray`) — a deliberately
  cross-framework app. **File I/O is deliberately *not* a platform API**: reading and
  writing the document bytes is a target-native operation (§8), not a Cocoa call.
- **pattern-kinds exercised:** `target-action` (five wirings) · `observer` (the
  text-change notification; registered once, never unregistered — the kind's
  balanced-unregister law is deliberately unexercised, the observer lives for the process)
  · `parent-child` (view containment) · plus, descriptively: completion-block async
  re-entry (the save sheet's handler), synchronous modal sessions (alert, open panel),
  object-lifecycle · property-configuration · value-type-geometry · option-set bitmask ·
  menu object-graph construction · run-loop entry
- **native units:** none beyond the platform frameworks (the Markdown renderer and the
  file I/O are ordinary application code in the implementing language; no app-specific
  native code)

## 2. Purpose & intent

A Markdown editor with a live HTML preview. The window is split side-by-side: the left
pane is a plain-text editor; the right pane is a web view that re-renders the editor's
text as HTML on **every text change**. A toolbar carries **New / Open… / Save… / Undo /
Redo** and a status line. The app maintains a single-document model — a current file path
(or *Untitled*) and a dirty flag — surfaced in the window title, the window's
document-edited indicator, and the status line. Save uses the system save panel as a
window sheet with an **asynchronous completion handler** (the app's load-bearing async
pattern); Open uses the system open panel modally; New and Open guard unsaved changes
with a confirmation alert. Undo/Redo drive the text view's own undo manager. The preview
is rendered by a **built-in, deliberately small Markdown-to-HTML rule** (§7) and loaded
as an HTML string — no navigation, no network, no JavaScript. There is no document beyond
this one buffer, and no persistence beyond explicit Save.

## 3. Application kind & lifecycle

A regular, dock-visible, single-window AppKit application (`gui-app`). Launch is
deterministic; the coarse order below is common to all implementations (finer
construction interleaving is not contractual):

1. **Acquire the application singleton** — the process-wide shared `NSApplication`.
2. **Become a regular app** — activation policy *Regular*
   (`NSApplicationActivationPolicyRegular` = 0): Dock icon and menu bar.
3. **Install the application menu** (§10).
4. **Build the window** (§4) **and its content** (§5): toolbar, split view with editor
   and preview panes; **register the text-change observer** (§6.2) and the five
   target-action routes (§5.1).
5. **Render the initial preview** — an empty-document render, so the preview shows the
   placeholder (§7.1) before the window appears.
6. **Set the initial title** — `Untitled — Note Editor` (§6.1), with the document-edited
   indicator off.
7. **Present and focus** — make the window key and order it front; activate the
   application ignoring other apps.
8. **Announce** — write a one-line launch diagnostic to standard output. The line
   **begins with the text `Note Editor`**; the remainder (running/opened phrasing, usage
   or quit guidance) is implementation-specific and not part of the contract.
9. **Run** — enter the AppKit run loop; the process blocks servicing events.
10. **Terminate** — via the **Quit** command (Command-Q → `-[NSApplication terminate:]`),
    the `gui-app` app-kind's termination model (`termination
    "ns-application-terminate"`). See §10.

    **Termination is Quit-driven, not close-driven.** No implementation installs an
    application delegate or opts into terminate-after-last-window-closed, and the
    app-kind does not require it; on stock AppKit, closing the window hides it and the
    process keeps running **(unknown — to confirm in-VM)**. Three implementations'
    printed guidance ("Close window or Ctrl+C to exit") suggests otherwise; that text is
    guidance prose, not behaviour.

    **Boundary — termination does not consult the dirty flag.** The unsaved-changes
    confirmation (§8.1) is wired to New and Open **only**. Quitting (or closing the
    window) with unsaved changes triggers no alert and no save; the edits are silently
    lost **(unknown — to confirm in-VM)**.

No app-driven timers or background work. All dynamism after launch is user-initiated —
directly (buttons, typing) or via the two framework re-entry paths: the text-change
notification (§6.2) and the save sheet's completion handler (§8.4).

## 4. Window

A single top-level window created through the designated initializer
`initWithContentRect:styleMask:backing:defer:`:

- **Content rectangle:** origin `(0, 0)`, size **900 × 600** points (recentered before
  display, so the origin is irrelevant).
- **Style mask:** the bitwise-OR of **Titled** (1) · **Closable** (2) ·
  **Miniaturizable** (4) · **Resizable** (8). Resizable is deliberate: the toolbar and
  split view track resize through autoresizing masks (§5).
- **Backing store:** *Buffered* (`NSBackingStoreBuffered` = 2). **Defer:** *false*.
- **Minimum content size:** **520 × 360** points.
- **Position:** recentered via the window's standard `center` behaviour before display.
- **Title:** dynamic — always derived from document state by the title rule (§6.1);
  `Untitled — Note Editor` at launch.
- **Document-edited indicator:** the window's `setDocumentEdited:` is kept equal to the
  dirty flag on every title refresh (§6.1) — the platform's close-box dirty-dot
  affordance **(dot rendering — to confirm in-VM; the window title is the reliable
  observable)**.

## 5. Content layout

Two regions fill the 900 × 600 content view with a consistent **12-point gutter**: a
32-point toolbar strip across the top, and a split view filling everything below it. Both
are direct subviews of the window's content view and track resize via autoresizing masks
(no Auto Layout constraints). *(Coordinates are the content view's bottom-left-origin
space; re-implement the intent — a top toolbar, a side-by-side editor/preview split
filling the rest — not the literal numbers.)*

### 5.1 Toolbar

A **horizontal stack view** (`NSStackView`), frame `(12, 556, 876, 32)`.

- **Orientation:** horizontal (`NSUserInterfaceLayoutOrientationHorizontal` = 0);
  **alignment:** first baseline (`NSLayoutAttributeFirstBaseline` = 12); **spacing:** 8
  points.
- **Arranged subviews, in order:** **New · Open… · Save… · Undo · Redo · status label**.
  (Per-control construction frames are stack-arrangement details, not contract.)
- **Autoresizing:** width-sizable + min-Y-margin — grows with window width, pinned to the
  top edge.

The five buttons all have the rounded bezel (`NSBezelStyleRounded` = 1) and titles
**`New`**, **`Open…`**, **`Save…`**, **`Undo`**, **`Redo`** (the ellipses are the single
character U+2026). Each is wired by target-action to one document operation (§8, §9).

The **status label** is a text field configured as a static, non-interactive label:
initial text **`Ready`**, system font at **11-point**, editable/selectable/bezeled/
drawsBackground all *false* (left alignment is set explicitly in three implementations;
the fourth takes the control default — a realization, not contract). Its value
vocabulary is fixed (§6.3).

### 5.2 Split view

An `NSSplitView`, frame `(12, 12, 876, 532)`, with **`setVertical: true`** — a vertical
divider, i.e. the two panes sit **side-by-side**. Autoresizing: width- and
height-sizable. Two subviews, left to right: the editor's scroll view (§5.3) and the web
view (§5.4), each constructed at **half the split width** (438 points); thereafter pane
sizing is the split view's standard divider behaviour.

### 5.3 Editor pane (left)

An `NSTextView` inside an `NSScrollView` (the scroll view's `documentView`; vertical
scroller on, horizontal scroller off).

The text view is configured as a plain-text Markdown editor:

- **editable** = true; **richText** = false (plain text only).
- **allowsUndo** = true — the text system records undo groups for §9.
- **usesFindBar** = true *(configuration fact; no menu item or key routing to the find
  action exists — §10 — so reachability of the find bar is unspecified)*.
- **Font:** the **user fixed-pitch (monospaced) font at 13-point**
  (`userFixedPitchFontOfSize:`).
- **horizontallyResizable** = false — the text-wraps-to-width configuration *(wrapping
  appearance — to confirm in-VM)*.
- Autoresizing: width- and height-sizable.

### 5.4 Preview pane (right)

A `WKWebView`. Its only use is `loadHTMLString:baseURL:` with a **nil base URL** (§7):
it is a local HTML renderer, never a browser. No navigation delegate, no configuration
tuning (where a configuration object is created at all it is the default, untouched), no
network. Render completion is **not observable** to the app — no callback of any kind is
registered on the web view; the only signal that a render happened is the visible result.

## 6. Document state, title, and status

### 6.1 The document model and the title rule

The app holds exactly two pieces of document state:

- **current path** — absent for a never-saved document, otherwise the absolute file path
  of the last successful open or save;
- **dirty flag** — true iff there are unsaved edits.

One refresh rule derives all title-bar state from them. Let *name* = `Untitled` when no
path is set, else the **last path component** of the current path. Then:

- clean → title **`<name> — Note Editor`**
- dirty → title **`<name> — edited — Note Editor`**

(separators: space, em dash U+2014, space), and the window's `setDocumentEdited:` is set
to the dirty flag. The rule runs at launch and on every state transition (§6.2, §8), so
title and indicator never disagree with the model.

### 6.2 Dirty tracking — the text-change observer

The app registers **one observer** with the default notification center
(`addObserver:selector:name:object:`) for **`NSTextDidChangeNotification`**, with the
**text view as the source object** (source-filtered). The observer object is kept
strongly referenced by the app for the run loop's lifetime (the notification center holds
observers weakly — a lifetime rule every implementation records), and is **never
unregistered** — it lives until process exit.

On every notification (i.e. after every user edit):

1. if the dirty flag is not already set: set it and run the title rule (§6.1) — the
   title flips to the `— edited —` form on the **first** keystroke after any clean
   point;
2. **always** re-render the preview from the full current editor text (§7).

### 6.3 The status line vocabulary

The status label is the app's sole message surface. Its complete value vocabulary:

| Value | When |
|---|---|
| `Ready` | startup only |
| `Opened <path>` | successful Open (§8.3) |
| `Open failed: <detail>` | failed read on Open (§8.5) |
| `Saved <path>` | successful Save (§8.4) |
| `Save failed: <detail>` | failed write on Save (§8.5) |
| `New document` | New (§8.2) |

`<path>` is the absolute file path. `<detail>` varies per implementation (the failing
path, or an error message); the stable observables are the **`Open failed: `** /
**`Save failed: `** prefixes. Status values persist until the next operation replaces
them (no timers).

## 7. The live preview — Markdown → HTML

Every render produces a complete HTML document — a fixed template head (inline CSS, UTF-8
meta), the rendered body, a fixed foot — and hands it to the web view via
`loadHTMLString:baseURL:` (nil base URL). The template's inline CSS styles: body in the
system font stack with 16px padding, 1.5 line-height, dark-gray text; code spans and
fenced blocks on a light-gray (`#f4f4f4`) rounded background in a monospace stack; the
placeholder class in gray (`#888`) italic. **Render triggers:** startup (§3.5), every
text-change notification (§6.2), New (§8.2), Open (§8.3) — *not* Save.

### 7.1 The placeholder

If the whole editor text is empty or whitespace-only (after trimming), the body is a
single placeholder paragraph — the text **`Start typing Markdown on the left…`** (ellipsis
U+2026), styled by the template's placeholder class (gray italic) — instead of rendered
Markdown.

### 7.2 Block rules (line-oriented, first match wins per line)

The renderer is deliberately small — the same rule in all four implementations:

1. **Inside a fenced code block:** a line beginning <code>```</code> whose remainder is
   only whitespace **closes** the block; any other line is HTML-escaped and emitted
   verbatim (no inline transforms inside fences).
2. **Fence open:** a line beginning <code>```</code> opens a fenced code block
   (`<pre><code>`), first closing any open list.
3. **ATX heading:** 1–6 `#` characters followed by at least one whitespace character →
   `<h1>`…`<h6>` (level = number of `#`s) with inline-rendered text. Seven or more `#`s,
   or no whitespace after the `#`s, is **not** a heading (falls through to paragraph).
4. **Unordered list item:** `-`, `*`, or `+` followed by at least one whitespace
   character → `<li>` with inline-rendered text; consecutive items are grouped in one
   `<ul>`; any non-item line closes the group.
5. **Blank line** (all whitespace): closes any open list; emits no visible content.
6. **Anything else:** a paragraph — `<p>` with inline-rendered text.
7. **End of input:** any open list and any open fence are closed automatically.

### 7.3 Inline rules (applied to heading, list-item, and paragraph text, in order)

1. HTML-escape `&`, `<`, `>`.
2. `` `code` `` → `<code>` (code spans first, so their contents are not further
   transformed).
3. `**strong**` → `<strong>`.
4. `*emphasis*` → `<em>`.

Delimited content is a maximal non-empty run of characters not containing the delimiter
character; unbalanced delimiters pass through literally.

**Deliberately unsupported** (§14): links, images, ordered lists, blockquotes, tables,
nested lists, setext headings — full CommonMark is out of scope.

## 8. File operations

Reading and writing the document is an **abstract operation** — *read the whole file as
UTF-8 text* / *write the editor text to the path as UTF-8, replacing any existing file* —
realized with each target's native file I/O, never a Cocoa API (a deliberate,
cross-implementation choice; the panels are the platform surface under test, the bytes
are not).

### 8.1 The unsaved-changes confirmation

New and Open (and **only** New and Open — §3.10) are guarded: if the dirty flag is set,
a warning alert runs **modally** before proceeding.

- **Style:** warning (`NSAlertStyleWarning` = 1).
- **Message text:** trigger-specific — Open: **`Discard unsaved changes?`**; New:
  **`Discard unsaved changes and start a new note?`**.
- **Informative text:** **`Your changes will be lost if you continue.`**
- **Buttons, in order added:** **`Discard`**, **`Cancel`** (Discard, added first, is the
  default button — it fires on Return).
- The operation proceeds **iff** Discard is chosen (the first-button return code, 1000);
  any other outcome abandons the operation with **no state change** — the confirmation
  itself discards nothing.

With a clean document the alert is skipped entirely.

### 8.2 New

After passing §8.1: the editor text is cleared, the current path is unset, the dirty flag
cleared; title refreshes (→ `Untitled — Note Editor`), the preview re-renders (→
placeholder), status becomes **`New document`**.

### 8.3 Open

After passing §8.1, the system **open panel** runs **modally** (`runModal` — synchronous;
deliberately contrasting with Save's sheet-plus-handler):

- **Configuration:** can choose files = true; can choose directories = false; multiple
  selection = false; **allowed file types = `md`, `markdown`, `txt`** (an array of the
  three extension strings).
- **OK** (`NSModalResponseOK` = 1) → take the panel's `URL`, nil-guarded; its file-system
  `path` is loaded: the file is read (abstract read above), the editor text replaced with
  its content, current path set, dirty cleared, title refreshed, preview re-rendered,
  status **`Opened <path>`**.
- **Cancel** → nothing changes (even though the user may just have confirmed a discard).

### 8.4 Save

The Save… action branches on the document model:

- **A path is set** (previously saved/opened) → **direct write, no panel**: the abstract
  write above to the current path, then dirty cleared, title refreshed, status
  **`Saved <path>`**. (The preview is *not* re-rendered — the text did not change.)
- **No path** (Untitled) → the system **save panel** is presented **as a sheet on the
  window** with an **asynchronous completion handler**
  (`beginSheetModalForWindow:completionHandler:`) — the call returns immediately and the
  handler re-enters application code when the sheet is dismissed. Panel configuration:
  can create directories = true; **suggested filename (`setNameFieldStringValue:`) =
  `untitled.md`** (the rule is *the current display name if a path were set, else
  `untitled.md`*; since the sheet is only reached when no path is set, `untitled.md` is
  the only reachable value).
  - Handler, on **OK** (response = `NSModalResponseOK` = 1): take the panel's `URL`
    (nil-guarded), its `path` (empty-guarded), and perform the same write-plus-state
    update as the direct branch — path set, dirty cleared, title refreshed, status
    `Saved <path>`.
  - Handler, on any other response (Cancel): nothing changes.

After a successful sheet save the document has a path, so **every subsequent Save is a
direct overwrite with no panel**.

### 8.5 Boundary & error behaviours (enumerated)

1. **New/Open on a clean document** → no alert; the operation proceeds directly.
2. **Alert dismissed with Cancel** → the command is abandoned; text, dirty flag, path,
   title all unchanged.
3. **Open panel cancelled** (after a Discard confirmation) → no state change; the
   "discarded" edits are still present and still dirty.
4. **Save sheet cancelled** → no write; the document stays dirty; title keeps the
   `— edited —` form.
5. **Save sheet OK with a nil URL or empty path** → no write, no state change (guarded).
6. **Open read failure** (path unreadable) → status `Open failed: <detail>`; editor
   text, path, dirty flag untouched.
7. **Save write failure** → status `Save failed: <detail>`; path and dirty flag
   untouched (the dirty title persists).
8. **Undo/Redo with nothing to undo/redo** → no-op (§9).
9. **Whitespace-only document** → the preview shows the placeholder, not an empty page
   (§7.1).
10. **Quit or window-close with unsaved changes** → **no confirmation, no save** (§3.10)
    **(to confirm in-VM)**.

## 9. Undo / Redo

The **Undo** and **Redo** buttons drive the text view's own undo machinery — the app
keeps no edit history of its own:

- Fetch the text view's `undoManager` (the `NSResponder` accessor; non-nil-guarded).
- Undo: if `canUndo`, call `undo`; else do nothing. Redo: symmetric
  (`canRedo`/`redo`).

Undo grouping/granularity is the text system's (enabled by `allowsUndo`, §5.3), not the
app's. An undone or redone edit mutates the editor text; in the one implementation whose
VM run exercised it, undoing all typing visibly reverted the preview to the placeholder —
i.e. the text system's undo drives the same change-notification path as typing **(the
notification-on-undo coupling, and its dirty-flag consequence, are platform behaviour —
to confirm in-VM)**.

No keyboard shortcuts are wired for undo/redo: there is no Edit menu (§10), so Cmd-Z /
Cmd-Shift-Z routing is unspecified — the buttons are the contract.

## 10. Application menu

- The menu bar carries one application menu; its bold app-name slot comes from the
  bundle's `CFBundleName` (`Note Editor`) when launched as a `.app` bundle.
- The mandated behaviour is a **Quit** command: title **`Quit Note Editor`**
  (`"Quit " + <display name>`), **key equivalent Command-Q**, action
  **`-[NSApplication terminate:]`** — the app-kind's termination model.
- A conforming implementation may include the other conventional first-menu items (three
  of the four install About / Hide / Hide Others / Show All via a shared standard-menu
  helper; one installs Quit alone); only *Quit (Command-Q) terminates the app* is
  asserted.
- **There is no Edit menu and no other menu** — no menu-routed Cut/Copy/Paste/Undo/Find
  key equivalents are part of this app's contract.

## 11. API surface exercised

Selectors witnessed in **every** implementation (or named by the app-kind contract) —
platform truths, projection-free:

| Class | Selector | Kind | Role |
|-------|----------|------|------|
| NSApplication | `sharedApplication` | class accessor (singleton) | obtain the app instance |
| NSApplication | `setActivationPolicy:` | property setter | become a Regular app |
| NSApplication | `setMainMenu:` | property setter | install the menu bar |
| NSApplication | `activateIgnoringOtherApps:` | instance method | foreground on launch |
| NSApplication | `run` | instance method | enter the run loop |
| NSApplication | `terminate:` | instance method | quit (app-kind termination; the Quit item's action) |
| NSWindow | `initWithContentRect:styleMask:backing:defer:` | designated initializer | create the window |
| NSWindow | `setTitle:` · `center` · `setMinSize:` · `contentView` · `makeKeyAndOrderFront:` | setters/methods/getter | dynamic title, position, size floor, composition root, show+focus |
| NSWindow | `setDocumentEdited:` | property setter | the dirty-state close-box indicator |
| NSView | `addSubview:` · `setAutoresizingMask:` | method / setter | containment; resize tracking |
| NSSplitView | `setVertical:` | property setter | side-by-side panes |
| NSScrollView | `setHasVerticalScroller:` · `setHasHorizontalScroller:` · `setDocumentView:` | setters | the editor's scrolling container |
| NSTextView (NSText) | `setEditable:` · `setRichText:` · `setAllowsUndo:` · `setUsesFindBar:` · `setFont:` · `setHorizontallyResizable:` | property setters | plain-text editor configuration |
| NSTextView (NSText) | `string` · `setString:` | getter / setter | read the document text; replace it (Open, New) |
| NSResponder | `undoManager` | property getter | reach the text view's undo manager |
| NSUndoManager | `canUndo` · `undo` · `canRedo` · `redo` | getters / methods | button-driven undo/redo |
| NSButton | `setTitle:` · `setBezelStyle:` | property setters | the five toolbar buttons |
| NSControl | `setTarget:` · `setAction:` | property setters | the five action wirings |
| NSTextField / NSControl | `setStringValue:` | property setter | the status line |
| NSControl | `setFont:` | property setter | status font (11 pt) |
| NSTextField | `setEditable:` · `setSelectable:` · `setBezeled:` · `setDrawsBackground:` | property setters | status-line static-label semantics |
| NSStackView | `setOrientation:` · `setAlignment:` · `setSpacing:` · `addArrangedSubview:` | setters/method | the toolbar row |
| NSFont | `systemFontOfSize:` · `userFixedPitchFontOfSize:` | class factories | status font; monospaced editor font |
| NSNotificationCenter | `defaultCenter` | class accessor | the notification hub |
| NSNotificationCenter | `addObserver:selector:name:object:` | instance method | register the text-change observer (source-filtered) |
| NSAlert | `setAlertStyle:` · `setMessageText:` · `setInformativeText:` · `addButtonWithTitle:` · `runModal` | setters / method | the unsaved-changes confirmation (created via plain alloc/init — no factory) |
| NSSavePanel | `savePanel` | class factory | create the save panel |
| NSSavePanel | `setCanCreateDirectories:` · `setNameFieldStringValue:` · `URL` | setters / getter | sheet configuration; result URL |
| NSSavePanel | `beginSheetModalForWindow:completionHandler:` | instance method (async, block) | the sheet + completion-handler save |
| NSOpenPanel | `openPanel` | class factory | create the open panel |
| NSOpenPanel | `setCanChooseFiles:` · `setCanChooseDirectories:` · `setAllowsMultipleSelection:` · `setAllowedFileTypes:` | setters | open-panel configuration + extension filter |
| NSOpenPanel | `runModal` | instance method (sync) | the modal open |
| NSURL | `path` | property getter | file-system path from the panel URL |
| WKWebView | `loadHTMLString:baseURL:` | instance method | render the preview HTML (nil base URL) |

**Constant with app-kind standing:** `NSTextDidChangeNotification` — the notification
name observed in every implementation.

**Abstract operations whose realizing selector varies per implementation** (this spec
asserts the operation, never one impl's selector): web-view creation (two implementations
create a default `WKWebViewConfiguration` and use `initWithFrame:configuration:`; two use
`initWithFrame:` alone); control/stack/label instantiation and framing (`initWithFrame:`
vs. bare init + `setFrame:`); building the three-element extension array (an immutable
array from a list vs. `NSMutableArray` `initWithCapacity:`+`addObject:`); main-menu
installation (a shared standard-menu helper vs. inline construction); **whole-file
read/write (target-native, no platform selector at all)**; handler-object mechanism
(§12).

**11.1 Enum / constant values used in every implementation:**

| Constant | Value | Used for |
|----------|-------|----------|
| `NSApplicationActivationPolicyRegular` | 0 | activation policy |
| `NSWindowStyleMaskTitled` | 1 | window style |
| `NSWindowStyleMaskClosable` | 2 | window style |
| `NSWindowStyleMaskMiniaturizable` | 4 | window style |
| `NSWindowStyleMaskResizable` | 8 | window style |
| `NSBackingStoreBuffered` | 2 | window backing |
| `NSUserInterfaceLayoutOrientationHorizontal` | 0 | toolbar stack orientation |
| `NSLayoutAttributeFirstBaseline` | 12 | toolbar stack alignment |
| `NSBezelStyleRounded` | 1 | the five buttons |
| `NSViewWidthSizable` | 2 | autoresizing (toolbar, split, editor) |
| `NSViewHeightSizable` | 16 | autoresizing (split, editor) |
| `NSViewMinYMargin` | 8 | autoresizing (toolbar pin-to-top) |
| `NSAlertStyleWarning` | 1 | the confirmation alert |
| `NSModalResponseOK` | 1 | save/open panel OK (hand-defined in every implementation — not collector-extracted) |
| `NSAlertFirstButtonReturn` | 1000 | the Discard button (hand-defined in every implementation) |

*Used in three of the four implementations (the fourth takes the platform default):*
`NSTextAlignmentLeft` (0, status-line alignment).

## 12. API-usage patterns

- **`observer` — the app's live loop:** one observer object registered with the default
  notification center for `NSTextDidChangeNotification`, filtered to the text view as
  source. The center holds observers weakly, so the app must keep the observer strongly
  reachable for the run loop's life — a lifetime rule every implementation enforces (one
  target's runtime learned it the hard way under this app's per-keystroke allocation
  load). The kind's balanced-unregister law is deliberately unexercised: the observer is
  never removed; process exit is the teardown.
- **Completion-block async re-entry (the app's load-bearing async pattern):** the save
  sheet's completion handler is a block the platform retains for the sheet's life and
  invokes on dismissal, re-entering application code with the modal response —
  asynchronous, in contrast to the open panel's synchronous `runModal`. Both directions
  are exercised deliberately: Save = sheet + block, Open = modal, alert = modal.
- **`target-action`, five wirings:** the five toolbar buttons, wired at build time to
  app-side handler object(s). All four implementations use the same app-defined action
  selector names — `newDoc:`, `openDoc:`, `saveDoc:`, `undoDoc:`, `redoDoc:` — an
  internal, non-observable convention recorded here as shared fact, not testable
  contract.
- **Handler-object granularity is a realization, its role a rule:** every implementation
  routes the five actions and the one notification callback to app-side handler object(s)
  that outlive the run loop — realized variously as five single-selector targets plus a
  separate observer object, one five-selector target plus a separate observer, or a
  single six-selector controller object that also carries the document state.
- **`parent-child`:** toolbar stack and split view into the content view; five buttons
  and the status label arranged into the stack; scroll view and web view into the split
  view; the text view as the scroll view's document view.
- **Single-source state, single write-path:** all title/indicator/status state is
  derived from the two-field document model by one refresh rule; the preview is always a
  function of the full current editor text (re-rendered whole, never patched).
- **Delegated undo:** the app forwards to the text system's undo manager rather than
  modelling edits — capability-guarded (`canUndo`/`canRedo`) button actions.
- **Object lifecycle, property configuration, value-type geometry, option-set bitmask,
  menu object-graph construction, run-loop entry:** as in the app-kind and the earlier
  portfolio specs.

## 13. Observable outcomes & accessibility

**Visual outcomes:**
- A centered, resizable 900 × 600 window titled `Untitled — Note Editor`, with a top
  toolbar reading `New Open… Save… Undo Redo Ready`, and below it a two-pane split: an
  empty monospaced editor (left) and a preview pane showing the gray-italic placeholder
  `Start typing Markdown on the left…` (right) **(preview text legibility to
  OCR — to confirm in-VM)**.
- Typing Markdown in the left pane immediately re-renders the right pane as styled HTML —
  headings render large, `**bold**`/`*italic*`/`` `code` `` render styled, list items
  bullet, fenced blocks render as gray code blocks (each implementation's VM run verified
  this rendering visually).
- From the first keystroke the window title contains `— edited —` and the close box shows
  the document-edited dot **(dot — to confirm in-VM)**; after a successful save or open
  the title shows the file's name without `edited`.
- Save on an Untitled document slides a save-panel sheet down from the title bar
  (observed in the implementations' VM runs); Open presents the system open dialog;
  a dirty New/Open first presents the warning alert with Discard/Cancel buttons.

**Accessibility expectations** *(in-VM confirmable)*:
- The window's accessibility title equals the §6.1 title — the implementations' VM notes
  found the title-bar AX attribute the *reliable* dirty/name observable (more legible
  than the close-box dot).
- The five buttons are exposed as button elements titled `New`, `Open…`, `Save…`,
  `Undo`, `Redo`; the status line as a static-text element (non-editable,
  non-selectable).
- The editor is exposed as a text-area element (editable text) **(its AX value fidelity
  under the driver — to confirm in-VM)**.
- The preview is a WKWebView subtree; whether its rendered DOM is AX-observable under the
  driver is **(unknown — to confirm in-VM)** — assertions on preview content should use
  OCR/screenshot.
- The open panel's file cells are **not** in the AX tree (an implementation VM note);
  driver paths go through Go-to-Folder (§15 driver guidance).
- The application menu's Quit item is reachable and carries the Command-Q key equivalent.

## 14. Not included

- **No Markdown beyond §7:** no links, images, ordered lists, blockquotes, tables,
  nested lists, or setext headings. (The precursor prose's "links" claim is corrected —
  no implementation renders links.)
- **No JavaScript in the preview** — rendering happens in application code before the
  HTML string is loaded; the template contains CSS only. (Corrects the precursor's
  in-template JS-renderer sketch.)
- **No keyboard shortcuts for Undo/Redo/Find** — no Edit menu exists; the toolbar
  buttons are the only specified undo surface. (Corrects the precursor's
  Cmd-Z / Cmd-Shift-Z claim.)
- **No unsaved-changes protection on quit or window close** — the guard covers New and
  Open only (§3.10, §8.5.10).
- **No close-to-quit** — closing the window is not specified to terminate the app (§3.10).
- **No autosave, no save-on-quit, no MRU/recent-files, no state across launches** — the
  only persistence is an explicit Save.
- **No document architecture** — no NSDocument; the two-field model of §6.1 is the whole
  document system.
- **No web-view delegates or navigation** — the preview never navigates, loads no URL,
  and needs no network.
- **No status timers** — status values persist until replaced.
- **No app-side undo model** — undo is entirely the text system's.

## 15. Behavioural exemplar (acceptance / forward-generation input)

Observable assertions against a live-VM run, each mapped to a scenario-runner verb
(enumeration only — not scenario code). Assertions state the *rule* (stable
substrings/invariants), so the suite verifies any conforming implementation. This app
needs **no network**; scenarios that save/open need a writable directory in the VM
(the implementations' runs used `~/Documents`).

**Driver guidance** (from the implementations' VM notes — driver technique, not app
behaviour): text beginning `-` or `` ` `` must be passed through the driver's
flag-terminator (`type -- "- item"`); press **Return** for a panel's or alert's default
button (the save panel's Save, and the alert's Discard — first-added, hence default)
rather than clicking; select files in the open panel via **Cmd-Shift-G + full path +
Return** (its file cells are not in the AX tree), then Return again to open; read
dirty/name state from the **window AX title**, not the close-box dot; prefer
ellipsis-free OCR substrings (`Open`, `Save`, `Start typing Markdown`); preview-content
assertions use OCR, not AX (§13).

**Launch:**

- **Process is running after launch.** → `expect-running-app`
- **Launch diagnostic is emitted.** Stdout contains a line beginning `Note Editor`. →
  `wait-for-log "Note Editor"` / `expect-log "Note Editor"`
- **Window title at launch.** The frontmost window's AX title is
  `Untitled — Note Editor`. → `expect-ax` window AXTitle
- **Toolbar is present.** Button elements titled `New`, `Undo`, `Redo` (and the
  ellipsis-bearing `Open…`, `Save…`) exist. → `expect-ax` / `expect-ocr "New"`,
  `expect-ocr "Undo"`
- **Status starts Ready.** The status line reads `Ready`. → `expect-ocr "Ready"`
- **Placeholder shows in the preview.** The right pane shows
  `Start typing Markdown on the left…`. → `wait-for-ocr "Start typing Markdown"`
  *(WKWebView OCR legibility — to confirm in-VM)*

**Editing / live preview:**

- **Typing marks the document dirty.** Click into the editor, type `# Hello`: the window
  AX title contains `edited`. → `click-at` editor, `type "# Hello"`, `expect-ax` AXTitle
- **The preview renders the heading.** `Hello` appears in the right pane (as a rendered
  heading, visually large). → `wait-for-ocr "Hello"` *(to confirm in-VM)*
- **The preview tracks continuous edits.** Append a paragraph line; it appears in the
  preview without any other action. → `type`, `wait-for-ocr` *(to confirm in-VM)*
- **List and fence rendering.** A `- item` line renders as a bulleted item; a fenced
  block renders as a code block (typed via the `--` guard). →
  `type -- "- first item"`, `wait-for-ocr "first item"` *(to confirm in-VM)*

**Save:**

- **First save opens a sheet with the default name.** With an Untitled dirty document,
  activating `Save…` presents a save sheet whose name field is prefilled `untitled.md`. →
  `click-at` Save…, `wait-for-ocr "untitled.md"` *(to confirm in-VM)*
- **Completing the save writes the file and cleans the document.** Choose a path
  (Cmd-Shift-G flow) and press Return: the file exists; its content equals the editor
  text; the status line begins `Saved `; the window title shows the chosen filename and
  no `edited`. → `expect-file`, `read-file`, `wait-for-ocr "Saved"`, `expect-ax` AXTitle
- **Subsequent saves are direct.** Edit again (title shows `edited`), activate `Save…`:
  no sheet appears; the file's content updates; the title cleans. → `click-at` Save…,
  `read-file`, `expect-ax` AXTitle, `expect-no-ax` sheet element *(sheet-absence
  observability — to confirm in-VM)*
- **Boundary — cancelling the sheet changes nothing.** Dirty Untitled document, `Save…`,
  then Escape: no file is written; the title still contains `edited`. → `click-at`
  Save…, `press "Escape"`, `expect-ax` AXTitle
- **Boundary — write failure surfaces on the status line.** Status begins
  `Save failed: `; the dirty title persists. *(Hard to drive through the system panel —
  code-witnessed; a scenario may target an unwritable path via Go-to-Folder if the VM
  provides one.)* → `wait-for-ocr "Save failed:"` *(to confirm in-VM)*

**Open:**

- **Open loads a file.** With a clean document, `Open…` → Cmd-Shift-G, a known `.md`
  fixture path, Return, Return: the editor shows the file's text, the preview renders
  it, the status begins `Opened `, and the title is `<filename> — Note Editor`. →
  `click-at` Open…, `chord`, `type`, `press "Return"` ×2, `wait-for-ocr "Opened"`,
  `expect-ax` AXTitle
- **Round-trip.** A file saved by the app and re-opened shows identical content. →
  `read-file` vs. editor OCR / a second `read-file` after re-save
- **Boundary — dirty Open asks first.** With unsaved edits, `Open…` first raises the
  alert `Discard unsaved changes?`. → `wait-for-ocr "Discard unsaved changes"`
- **Boundary — read failure surfaces on the status line.** Status begins
  `Open failed: `; the editor keeps its text. *(Hard to drive through the panel —
  code-witnessed.)* → `wait-for-ocr "Open failed:"` *(to confirm in-VM)*

**New / the confirmation alert:**

- **Dirty New asks first.** With unsaved edits, `New` raises the warning alert
  `Discard unsaved changes and start a new note?` with buttons `Discard` and `Cancel`. →
  `click-at` New, `wait-for-ocr "start a new note"`
- **Discard clears everything.** Press Return (Discard is default): the editor empties,
  the preview returns to the placeholder, the status reads `New document`, the title is
  `Untitled — Note Editor`. → `press "Return"`, `wait-for-ocr "New document"`,
  `wait-for-ocr "Start typing Markdown"`, `expect-ax` AXTitle
- **Boundary — Cancel keeps everything.** Re-dirty, `New`, choose `Cancel`: the text is
  intact and the title still contains `edited`. → `click-at` Cancel, `expect-ocr` typed
  text, `expect-ax` AXTitle
- **Boundary — clean New shows no alert.** With a clean document, `New` proceeds
  directly (status `New document`, no alert element). → `click-at` New,
  `expect-no-ax` alert, `wait-for-ocr "New document"`

**Undo / Redo:**

- **Undo reverts typing.** After typing into a fresh document, `Undo` (repeatedly, per
  the text system's grouping) restores the earlier text; undoing all typing returns the
  preview to the placeholder. → `click-at` Undo, `wait-for-ocr "Start typing Markdown"`
  *(grouping granularity — to confirm in-VM)*
- **Redo restores.** `Redo` re-applies the undone edit; the preview shows the content
  again. → `click-at` Redo, `wait-for-ocr "Hello"` *(to confirm in-VM)*
- **Boundary — Undo on a fresh document is a no-op.** At launch, `Undo` changes nothing
  and the app keeps running. → `click-at` Undo, `expect-ax` AXTitle unchanged,
  `expect-running-app`

**Lifecycle:**

- **No state across launches.** Kill and relaunch: the app starts at
  `Untitled — Note Editor` with an empty editor and the placeholder preview. →
  `kill-impl!`, `restart-impl!`, `expect-ax` AXTitle
- **Quit terminates the app.** Command-Q ends the process. → `chord cmd q`, then
  `expect-running-app` is false
- **Boundary — quit with unsaved edits neither asks nor saves.** Type, then Command-Q:
  no alert appears and the process exits; the edits are not on disk anywhere. →
  `type`, `chord cmd q`, `expect-no-ax` alert, `expect-running-app` false *(to confirm
  in-VM — flagged for human confirmation, §8.5.10)*
- **(To confirm in-VM) Close-button behaviour.** Activating the close control hides the
  window; per §3.10 the process is expected to keep running (no close-to-quit opt-in). A
  scenario should record the *actual* observed behaviour. → `click-at` close button, then
  `expect-running-app`
