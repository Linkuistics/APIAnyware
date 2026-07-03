# Hello Window

*Reverse-generated (LLM) on 2026-06-26 from the four VM-verified implementations
(racket, chez, gerbil, sbcl), then human-validated by git review under the
propose → review → accept-over-git model (ADR-0050, ADR-0052): this prose is the
target-independent source of truth; the four implementations are its projections.*

## 1. Structural facts

- **app-kind:** `gui-app` (the bundled, windowed Cocoa app — `platforms/macos/app-kinds/gui-app/`)
- **display name:** Hello Window  *(the bundlers read this from the first H1 above)*
- **complexity:** 1/7 (the simplest sample)
- **API frameworks:** AppKit (with Foundation for strings and geometry value types)
- **pattern-kinds exercised:** object-lifecycle · property-configuration ·
  class-method-factory (singleton/factory accessors) · value-type-geometry ·
  option-set bitmask · view-composition (containment) · menu object-graph
  construction · run-loop entry
- **native units:** none beyond the platform frameworks (pure AppKit/Foundation; no
  custom drawing, no app-specific native code)

## 2. Purpose & intent

A minimal macOS GUI application: it opens a single fixed-size window containing one
centered, static text label, then runs the standard application event loop until the
user quits. It is the smallest proof that the platform bindings can construct AppKit
objects, configure their properties, compose a view hierarchy, install an application
menu, and drive the run loop — nothing more. There is no document, no persistence, and
no user-input handling beyond the standard window and menu chrome.

## 3. Application kind & lifecycle

This is a regular, dock-visible, single-window AppKit application (`gui-app`). Its
lifecycle is fully deterministic and identical on every launch:

1. **Acquire the application singleton.** Obtain the process-wide shared `NSApplication`
   instance.
2. **Become a regular app.** Set the activation policy to *Regular*
   (`NSApplicationActivationPolicyRegular` = 0), giving the process a Dock icon and a
   menu bar.
3. **Install the application menu** (see §6).
4. **Build the window** (§4) and **the label** (§5), and add the label to the window's
   content view.
5. **Present and focus.** Make the window key and order it to the front; then activate
   the application ignoring other apps so it comes to the foreground on launch.
6. **Announce.** Write a one-line launch-confirmation diagnostic to standard output. The
   line **begins with the text `Hello Window opened.`**; any remaining guidance text
   (e.g. how to quit) is implementation-specific and not part of the contract.
7. **Run.** Enter the AppKit run loop. The process now blocks in the event loop,
   servicing window and menu events.
8. **Terminate.** The app terminates via the **Quit** command
   (Command-Q → `-[NSApplication terminate:]`) — the `gui-app` app-kind's termination
   model (`termination "ns-application-terminate"`). See §6.

   **Termination is Quit-driven, not close-driven.** None of the existing
   implementations opt into "terminate after the last window closes" (no application
   delegate, no `applicationShouldTerminateAfterLastWindowClosed:` returning true), and
   the `gui-app` app-kind does not require it. On stock AppKit, closing the window
   therefore hides it but leaves the process running. The precursor prose's "closing the
   window terminates the app" is **not** a property of these implementations; an
   implementation that wants close-to-quit must opt in explicitly. *(Confirmed in-VM on
   all four implementations — the close-button scenario passes on every impl; see §10.)*

No application delegate logic, timers, or background work is involved.

## 4. Window

A single top-level window, created through the designated initializer
`initWithContentRect:styleMask:backing:defer:` with:

- **Content rectangle:** origin `(0, 0)`, size **400 × 200** points. (The origin is
  irrelevant because the window is recentered before display.)
- **Style mask:** the bitwise-OR (option set) of **Titled** (1) · **Closable** (2) ·
  **Miniaturizable** (4).
  - *Titled* → the window has a title bar displaying the window title.
  - *Closable* → it shows a close button (closing hides the window — see §3.8).
  - *Miniaturizable* → it shows a minimize button.
  - **Resizable is deliberately omitted** ⇒ the window is **fixed-size** (no
    zoom/resize affordance); the 400 × 200 content size is invariant.
- **Backing store:** *Buffered* (`NSBackingStoreBuffered` = 2) — standard
  off-screen-buffered drawing.
- **Defer:** *false* — the native window-server resources are created immediately, not
  deferred to first display.

**Title rule:** the title is `"Hello from " + <implementation identity>`, where
*implementation identity* is the human-readable name of the language/runtime of the
implementation under test (the realized values across the existing implementations are
`Racket`, `Chez`, `Gerbil`, `SBCL`). The literal title is therefore e.g. `"Hello from
Racket"`. The title is observable in the title bar.

**Position:** the window is recentered via the window's standard `center` behaviour —
horizontally centered on the active screen and positioned slightly above the vertical
center (the platform's conventional centering bias).

**Background:** default system window background (the standard window material); the app
sets no custom background color.

## 5. Label control

A single text field is configured to act as a **static, non-interactive label** (not an
input field). It is created, given a frame, configured, and added to the window's
content view.

- **Geometry:** frame origin `(0, 70)`, size **400 × 60** points, in the content view's
  bottom-left-origin coordinate space. Because the field spans the full 400-point
  content width and is 60 points tall with its lower edge at y = 70, its vertical
  mid-line sits at y = 100 — exactly the vertical center of the 200-point content area.
  Combined with centered text alignment, the visible text reads as **centered both
  horizontally and vertically** in the window. *(Re-implement the intent — text
  centered in the window — not the literal y = 70, which is specific to this coordinate
  convention and content size.)*
- **String value (text):** `"Hello, macOS!"`.
- **Font:** the system font at **24-point** size (from the font class factory
  `systemFontOfSize:`).
- **Text alignment:** **Center** (`NSTextAlignmentCenter` = 1).
- **Static-label semantics** — four properties are each set to *false*:
  - **editable = false** — the user cannot type into it.
  - **selectable = false** — the user cannot select or copy its text.
  - **bezeled = false** — no inset border/bezel is drawn around it.
  - **drawsBackground = false** — it paints no background fill, so the window background
    shows through.
  - **Why:** non-editable + non-selectable + no bezel + no background ⇒ the text field
    renders as plain static display text indistinguishable from a label, rather than an
    interactive text-input control. This is the canonical "use an `NSTextField` as a
    label" idiom.

The label is installed into the window by adding it as a subview of the window's content
view.

## 6. Application menu

The app installs a standard application menu so it has a proper menu bar and a working
Quit command.

- The menu bar carries **one application menu** (the leftmost, bold menu). Its title —
  the bold app-name slot — is the application's **display name, `Hello Window`**, sourced
  from the bundle's `CFBundleName` when launched as a `.app` bundle. (Run unbundled, the
  platform substitutes the executable/process name; that is an environmental detail, not
  app behaviour.)
- The only behaviour the spec **mandates** is a **Quit** command:
  - **Title:** `"Quit Hello Window"` (i.e. `"Quit " + <display name>`).
  - **Key equivalent:** **Command-Q**.
  - **Action:** terminate the application (`-[NSApplication terminate:]`).
- A conforming implementation **may** also include the other conventional first-menu
  items (About, Hide, …); their presence is optional and not asserted by this spec. The
  mandated invariant is *Quit (Command-Q) terminates the app*.

## 7. API surface exercised

These are platform truths (Objective-C selectors), and are themselves projection-free.

| Class | Selector | Kind | Role in this app |
|-------|----------|------|------------------|
| NSApplication | `sharedApplication` | class accessor (singleton) | Obtain the process-wide app instance |
| NSApplication | `setActivationPolicy:` | property setter | Become a Regular (dock-visible) app |
| NSApplication | `setMainMenu:` | property setter | Install the menu bar |
| NSApplication | `activateIgnoringOtherApps:` | instance method | Bring the app to the foreground on launch |
| NSApplication | `run` | instance method | Enter the event/run loop |
| NSApplication | `terminate:` | instance method | Quit the app (invoked by the Quit menu item) |
| NSMenu | `initWithTitle:` | initializer | Create the menu bar / submenu objects |
| NSMenu | `addItem:` | instance method | Add an item to a menu |
| NSMenu | `setSubmenu:forItem:` | instance method | Attach the application submenu to its bar item |
| NSMenuItem | `initWithTitle:action:keyEquivalent:` | initializer | Create the Quit (and app) menu items |
| NSWindow | `initWithContentRect:styleMask:backing:defer:` | designated initializer | Create the window with size, style, backing |
| NSWindow | `setTitle:` | property setter | Set the window title |
| NSWindow | `center` | instance method | Center the window on screen |
| NSWindow | `contentView` | property getter | Reach the window's content view for composition |
| NSWindow | `makeKeyAndOrderFront:` | instance method | Show and focus the window |
| NSTextField / NSControl / NSView | `initWithFrame:` (or alloc/init + `setFrame:`) | initializer / geometry setter | Create the label with its frame |
| NSControl | `setStringValue:` | property setter | Set the label text |
| NSControl | `setFont:` | property setter | Set the label font |
| NSControl | `setAlignment:` | property setter | Center-align the text |
| NSTextField | `setEditable:` | property setter | Disable editing (static-label semantics) |
| NSTextField | `setSelectable:` | property setter | Disable selection |
| NSTextField | `setBezeled:` | property setter | Remove the bezel/border |
| NSTextField | `setDrawsBackground:` | property setter | Make the field background transparent |
| NSView | `addSubview:` | instance method | Add the label into the content view |
| NSFont | `systemFontOfSize:` | class factory | Obtain the 24-point system font |
| NSString | string literal | value construction | The title and label text are strings |
| NSRect | `NSMakeRect` (value type) | value-type construction | Window content rect & label frame, passed by value |

**7.1 Enum / constant values used (platform constants):**

| Constant | Value | Used for |
|----------|-------|----------|
| `NSApplicationActivationPolicyRegular` | 0 | activation policy |
| `NSWindowStyleMaskTitled` | 1 | window style |
| `NSWindowStyleMaskClosable` | 2 | window style |
| `NSWindowStyleMaskMiniaturizable` | 4 | window style |
| `NSBackingStoreBuffered` | 2 | window backing |
| `NSTextAlignmentCenter` | 1 | text alignment |

## 8. API-usage patterns

- **Object lifecycle:** allocate → initialize (via a designated initializer) → configure
  (property setters) → use → owned by the view/menu graph for the app's lifetime.
- **Class-method factory / singleton accessor:** `sharedApplication` returns the app
  singleton; `systemFontOfSize:` is a class factory producing a font value.
- **Property configuration:** the bulk of the app is setter calls (title, string value,
  font, alignment, and the four boolean label flags).
- **Value-type geometry:** rectangles (`NSRect`) are constructed as plain value types and
  passed *by value* into the window/label initializers and the frame setter.
- **Option-set bitmask:** the window style mask is built by OR-combining independent flag
  bits.
- **View composition / containment:** the label is parented into the window's content
  view via `addSubview:`.
- **Menu object-graph construction:** a small graph of menu → menu item → submenu is
  assembled and handed to the application as its main menu.
- **Run-loop entry:** control is surrendered to the AppKit event loop, which owns the
  process until termination.

## 9. Observable outcomes & accessibility

**Visual outcomes:**
- A fixed-size 400 × 200 window appears, centered, with the title `"Hello from
  <implementation identity>"` in its title bar.
- The window shows close and minimize buttons but **no** resize/zoom affordance.
- The text `"Hello, macOS!"` is displayed in large (24-point) system-font type, centered
  in the window, over the default window background (the transparent label background
  lets the window material show through).
- No bezel, border, focus ring, or input caret appears around the text — it reads as a
  static label.

**Accessibility expectations:**
- The window is exposed as an accessibility window element whose accessibility title
  equals the window title (`"Hello from <implementation identity>"`).
- The label is exposed as a **static-text** accessibility element whose accessibility
  value is `"Hello, macOS!"` (because it is non-editable/non-selectable, it is *not*
  exposed as a text-input element).
- The application menu and its **Quit** item are reachable in the accessibility tree; the
  Quit item carries the Command-Q key equivalent.

## 10. Behavioural exemplar (acceptance / forward-generation input)

Each behaviour below is an *observable* assertion against a live-VM-run instance,
annotated with the scenario-runner observation verb it maps to (`apps/macos/<app>/
scenarios/` will eventually carry the `#lang app-spec` suite forward-generated from
these — this section is the enumeration, **not** scenario code).

- **Process is running after launch.** → `expect-running-app`
- **Launch diagnostic is emitted.** Standard output contains a line beginning `Hello
  Window opened.` → `wait-for-log` / `expect-log "Hello Window opened."`
- **The greeting is visible.** The text `Hello, macOS!` is readable on screen. →
  `wait-for-ocr "Hello, macOS!"` / `expect-ocr "Hello, macOS!"`
- **Window title is correct.** The title bar shows `Hello from <implementation
  identity>` (the substring `Hello from` is stable across all implementations). →
  `expect-ocr "Hello from"` and/or `expect-ax` window AXTitle
- **Label is a static text element.** An accessibility static-text element has value
  `Hello, macOS!`. → `expect-ax` static-text value
- **Window has the expected size.** The window's accessibility size is approximately
  400 × 200 points. → `expect-ax` window AXSize (tolerance for title-bar height)
- **Window is centered.** The window is positioned near the screen center (loose
  tolerance). → `expect-ax` window AXPosition
- **Quit menu exists.** The application menu contains an item `Quit Hello Window` bound
  to Command-Q. → `expect-ax` menu item
- **Command-Q terminates the app.** Sending the Command-Q chord ends the process. →
  `chord cmd q`, then `expect-running-app` is false
- **No interactive editing.** Clicking the label and typing produces no caret and no
  text change (it is non-editable/non-selectable). → `click-at` label, `type "x"`,
  `expect-ocr "Hello, macOS!"` unchanged
- **Close-button behaviour (confirmed in-VM ×4).** Activating the window's close control
  hides the window; per §3.8 the process **keeps running** (these impls do not opt into
  close-to-quit) — verified on all four implementations. → `click-at` close button, then
  `expect-running-app` true.
