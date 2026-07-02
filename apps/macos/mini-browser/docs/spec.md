# Mini Browser

*Reverse-generated (LLM) from the four existing VM-verified implementations (racket, chez,
gerbil, sbcl) on 2026-07-03, then human-validated by git review (ADR-0050, ADR-0052): this
prose is the target-independent source of truth; the four implementations are its
projections.*

## 1. Structural facts

- **app-kind:** `gui-app` (the bundled, windowed Cocoa app — `platforms/macos/app-kinds/gui-app/`)
- **display name:** Mini Browser *(the bundlers read this from the first H1 above)*
- **complexity:** 4/7 (the portfolio's fourth rung — WKWebView, async multi-step
  WKNavigationDelegate, NSURL/NSURLRequest)
- **API frameworks:** WebKit (`WKWebView`, `WKNavigationDelegate`; two implementations also
  `WKWebViewConfiguration`), AppKit (window, buttons, text fields, stack view, alert, font),
  Foundation (`NSURL`, `NSURLRequest`, `NSError`, strings, geometry value types) — a
  deliberately cross-framework app
- **pattern-kinds exercised:** `delegate` (the async, multi-callback navigation delegate) ·
  `target-action` (five wirings) · `parent-child` (view containment) · plus, descriptively:
  object-lifecycle · property-configuration · value-type-geometry · option-set bitmask ·
  menu object-graph construction · run-loop entry
- **native units:** none beyond the platform frameworks (every WebKit/AppKit/Foundation call
  is plain ObjC surface; the one target that loads a native helper library does so for its
  own delegate-dispatch mechanism, a target-runtime detail, not app behaviour)

## 2. Purpose & intent

A minimal web browser: an address bar with Go, back/forward/reload controls, a `WKWebView`
filling the window, and a status line that mirrors the `WKNavigationDelegate` callbacks.
Typing a URL and pressing Return (or clicking Go) navigates; input without a URI scheme gets
`https://` prepended; ◀/▶ walk the web view's back-forward history, enabling and disabling
with it. The app's load-bearing feature is the **asynchronous, multi-callback navigation
delegate**: loads resolve on the framework's schedule, and every piece of chrome — status
text, window title, address text, history-button enablement — is updated only from those
callbacks. Failed loads surface a modal alert built from the `NSError` plus a status-line
message. There is no document, no persistence, and no browsing feature beyond this surface.

## 3. Application kind & lifecycle

A regular, dock-visible, single-window AppKit application (`gui-app`). Launch is
deterministic; the coarse order below is common to all implementations (finer construction
interleaving is not contractual):

1. **Acquire the application singleton** — the process-wide shared `NSApplication`.
2. **Become a regular app** — activation policy *Regular*
   (`NSApplicationActivationPolicyRegular` = 0): Dock icon and menu bar.
3. **Install the application menu** (§8).
4. **Build the window** (§4) **and its three content regions** (§5): toolbar, web view,
   status line; **wire the navigation delegate** (§7) and the five target-action routes
   (§6.3).
5. **Kick the initial load** — navigate to the home URL (§6.1) through the same
   text-navigation rule user input uses. This happens *before* the window is shown; the load
   itself completes asynchronously (or fails) after the run loop starts.
6. **Present and focus** — make the window key and order it front; activate the application
   ignoring other apps.
7. **Announce** — write a one-line launch diagnostic to standard output. The line **begins
   with the text `Mini Browser`**; the remainder (running/opened phrasing, quit guidance) is
   implementation-specific and not part of the contract.
8. **Run** — enter the AppKit run loop; the process blocks servicing events.
9. **Terminate** — via the **Quit** command (Command-Q → `-[NSApplication terminate:]`), the
   `gui-app` app-kind's termination model (`termination "ns-application-terminate"`). See §8.

   **Termination is Quit-driven, not close-driven.** No implementation installs an
   application delegate or opts into terminate-after-last-window-closed, and the app-kind
   does not require it; on stock AppKit, closing the window hides it and the process keeps
   running **(unknown — to confirm in-VM)**. Three implementations' printed guidance ("Close
   window or Ctrl+C to exit") suggests otherwise; that text is guidance prose, not behaviour.

No app-driven timers or background work. All dynamism after launch is either user-initiated
or a navigation-delegate callback arriving from the framework's run loop.

## 4. Window

A single top-level window created through the designated initializer
`initWithContentRect:styleMask:backing:defer:`:

- **Content rectangle:** origin `(0, 0)`, size **800 × 600** points (recentered before
  display, so the origin is irrelevant).
- **Style mask:** the bitwise-OR of **Titled** (1) · **Closable** (2) ·
  **Miniaturizable** (4) · **Resizable** (8). Resizable is deliberate: all three content
  regions track resize through autoresizing masks (§5).
- **Backing store:** *Buffered* (`NSBackingStoreBuffered` = 2). **Defer:** *false*.
- **Title at launch:** the literal string **`Mini Browser`**. The title is *dynamic*: after
  each finished navigation it becomes `"<page title> — Mini Browser"` (separator = space,
  em dash U+2014, space) when the page exposes a non-empty title, and reverts to plain
  `Mini Browser` when it does not (§7.2).
- **Minimum content size:** **500 × 400** points.
- **Position:** recentered via the window's standard `center` behaviour before display.

## 5. Content layout

Three non-overlapping regions fill the 800 × 600 content view with a consistent **12-point
gutter** on every side and between regions. All are direct subviews of the window's content
view and track resize via autoresizing masks (no Auto Layout constraints). *(Coordinates
below are the content view's bottom-left-origin space; re-implement the intent — a top
toolbar strip, a bottom status line, the web view filling the rest — not the literal
numbers.)*

### 5.1 Toolbar

A **horizontal stack view** (`NSStackView`), frame `(12, 556, 776, 32)` — a 32-point strip
inset 12 points from the top and sides.

- **Orientation:** horizontal (`NSUserInterfaceLayoutOrientationHorizontal` = 0);
  **alignment:** first baseline (`NSLayoutAttributeFirstBaseline` = 12); **spacing:** 8
  points.
- **Arranged subviews, in order:** **back button · forward button · reload button ·
  address field · Go button**. (Per-control construction frames are stack-arrangement
  details, not part of this contract.)
- **Autoresizing:** width-sizable + min-Y-margin — grows with window width, stays pinned to
  the top edge.

The five controls:

- **Back button** — title **`◀`** (U+25C0), rounded bezel (`NSBezelStyleRounded` = 1),
  **initially disabled**.
- **Forward button** — title **`▶`** (U+25B6), rounded bezel, **initially disabled**.
- **Reload button** — title **`Reload`**, rounded bezel, always enabled.
- **Address field** — an editable, bordered text field, **prefilled with the home URL**
  (§6.1).
- **Go button** — title **`Go`**, rounded bezel.

### 5.2 Web view

A `WKWebView`, frame `(12, 46, 776, 498)` — the full inset width, filling everything between
the toolbar and the status line with 12-point gaps to each.

- **Autoresizing:** width-sizable + height-sizable — grows with the window in both
  dimensions.
- Its **navigation delegate** is set at startup (§7); its content is whatever the current
  navigation loaded. The web view's own in-page behaviour (rendering, scrolling, link
  handling) is entirely the framework's — the app adds no policy hooks (§12).

### 5.3 Status line

A text field configured as a **static, non-interactive label** at the bottom: frame
`(12, 12, 776, 22)`.

- **Initial text:** **`Ready`**.
- **Font:** the system font at **11-point** size. **Alignment:** left
  (`NSTextAlignmentLeft` = 0 — set explicitly in three implementations; the fourth takes the
  control default; alignment is a realization, not contract).
- **Static-label semantics:** editable, selectable, bezeled, drawsBackground all *false* —
  it renders as plain display text.
- **Autoresizing:** width-sizable + max-Y-margin — grows with window width, stays pinned to
  the bottom edge.

The status line is the app's sole message surface; its full value vocabulary is: `Ready`
(startup only), a loading message beginning **`Loading`** (§7.1), **`Done`**, **`Enter a URL
to navigate`**, **`Invalid URL: <text>`**, and the failure form **`<phase> failed:
<message>`** (§7.3).

## 6. URL handling & navigation

### 6.1 The home URL

The app has **one fixed home URL** — an `https` URL baked into the implementation (a
per-implementation realized value, e.g. `https://example.com`). Two invariants hold:
the **address field is prefilled with exactly this string** at construction, and the launch
sequence **navigates to exactly this string** through the same rule as user input (§6.2).
The home page is a **live network URL in every implementation** — in a no-network
environment the initial load cannot succeed and the failure path (§7.3) is the expected
launch-time observable **(which failure callback the platform delivers offline — to confirm
in-VM)**.

### 6.2 The text-navigation rule

One rule turns text into a navigation; it is used by the initial load, the Go action, and
the address field's Return action:

1. **Trim** leading and trailing whitespace.
2. **Boundary — empty result:** set the status line to **`Enter a URL to navigate`** and do
   nothing else (no navigation is attempted).
3. **Scheme detection:** if the text begins with a URI scheme — an ASCII letter followed by
   letters, digits, `+`, `.` or `-`, up to a `:` — it is used unchanged. *Any* scheme
   passes this test (`file:` included — whether the web view renders non-http(s) schemes via
   this load path is **(unknown — to confirm in-VM)**).
4. **Scheme defaulting:** otherwise prepend **`https://`**. (Consequence: input is always
   treated as a URL, never as a search query — a bare word becomes `https://<word>`, which
   then resolves or fails as a navigation.)
5. **Build the URL** via `NSURL initWithString:`. **Boundary — URL parse failure:** if the
   platform rejects the string (returns nil), set the status line to **`Invalid URL:
   <normalized text>`** and do nothing else.
6. **Load:** wrap the URL in an `NSURLRequest` (`initWithURL:`) and call the web view's
   `loadRequest:`. The call returns immediately; all further consequences arrive through the
   navigation delegate (§7).

### 6.3 Control actions

Five target-action routes, all to app-side handler object(s) (§10):

- **Go button → the go action:** read the address field's current `stringValue` and apply
  §6.2 to it.
- **Address field → the same go action**, fired by the field's Return/Enter action — Return
  in the field and clicking Go are the same behaviour by construction.
- **Back button → the back action:** if the web view's `canGoBack` is true, call `goBack`;
  otherwise do nothing (guarded even though the button's enablement should already prevent
  it).
- **Forward button → the forward action:** symmetric, `canGoForward` / `goForward`.
- **Reload button → the reload action:** call `reload` unconditionally — there is no
  guard and no current-page check **(behaviour when nothing has ever loaded —
  to confirm in-VM)**.

Back/forward history state lives entirely in the web view; the app holds no navigation
state of its own.

## 7. The navigation delegate — status, chrome, and error surfacing

The app registers **one navigation-delegate object** on the web view
(`setNavigationDelegate:` — a *weak* property; the implementation must keep the handler
alive for the run loop's lifetime) implementing **four** `WKNavigationDelegate` callbacks.
These callbacks are **asynchronous** — they fire from the framework's run loop whenever a
load progresses — and are the **only** place chrome is updated: there is no KVO, no polling,
and no synchronous read-after-load anywhere.

### 7.1 Load started — `webView:didStartProvisionalNavigation:`

Set the status line to a loading message **beginning `Loading`** (realized per
implementation as `Loading...` or `Loading…`). Nothing else changes at start.

### 7.2 Load finished — `webView:didFinishNavigation:` (the chrome-refresh moment)

1. **History buttons:** back-button enabled := `canGoBack`; forward-button enabled :=
   `canGoForward`.
2. **Window title:** read the web view's `title`. Non-empty → `"<title> — Mini Browser"`;
   empty or nil → `Mini Browser`. *Known platform behaviour (observed in the
   implementations' VM runs): the title property can lag the finish callback on a first
   load, so the window may stay `Mini Browser` until a subsequent navigation to an
   already-titled page — cosmetic, common to all implementations.*
3. **Address field:** read the web view's `URL`; if non-nil with a non-empty
   `absoluteString`, write that canonical string into the address field (this is how a typed
   bare host visibly becomes its `https://…/` canonical form). If nil/empty, the field is
   left as typed.
4. **Status line:** **`Done`**.

Chrome refresh happens **only here** — after a failed navigation the address field keeps the
attempted text and the history buttons keep their prior state.

### 7.3 Load failed — `webView:didFailNavigation:withError:` and `webView:didFailProvisionalNavigation:withError:`

Both failure callbacks funnel to one error-surfacing rule, parameterized by a *phase* word —
the provisional (request never committed) failure uses the word `request`, the committed
(load) failure uses `load` (realized with differing capitalization across implementations;
the stable observable is the **`failed: `** form below):

1. **Message:** the error's `localizedDescription`. **Boundary — nil error:** the message is
   the literal **`Unknown error`**, and **no alert is shown**.
2. **Alert (non-nil error only):** build an `NSAlert` via the class factory
   `alertWithError:`, set its style to **warning** (`NSAlertStyleWarning` = 1), and run it
   **modally** (`runModal`) — a blocking dialog the user must dismiss.
3. **Status line (after the alert is dismissed):** **`<phase> failed: <message>`**.

No navigation retry, no error page, no state cleanup — the web view is left however the
framework left it.

## 8. Application menu

- The menu bar carries one application menu; its bold app-name slot comes from the bundle's
  `CFBundleName` (`Mini Browser`) when launched as a `.app` bundle.
- The mandated behaviour is a **Quit** command: title **`Quit Mini Browser`**
  (`"Quit " + <display name>`), **key equivalent Command-Q**, action
  **`-[NSApplication terminate:]`** — the app-kind's termination model.
- A conforming implementation may include the other conventional first-menu items (three of
  the four install About / Hide / Hide Others / Show All via a shared standard-menu helper;
  one installs Quit alone); only *Quit (Command-Q) terminates the app* is asserted.

## 9. API surface exercised

Selectors witnessed in **every** implementation (or named by the app-kind contract) —
platform truths, projection-free:

| Class | Selector | Kind | Role |
|-------|----------|------|------|
| NSApplication | `sharedApplication` | class accessor (singleton) | obtain the app instance |
| NSApplication | `setActivationPolicy:` | property setter | become a Regular app |
| NSApplication | `activateIgnoringOtherApps:` | instance method | foreground on launch |
| NSApplication | `run` | instance method | enter the run loop |
| NSApplication | `terminate:` | instance method | quit (app-kind termination; the Quit item's action) |
| NSWindow | `initWithContentRect:styleMask:backing:defer:` | designated initializer | create the window |
| NSWindow | `setTitle:` · `center` · `setMinSize:` · `contentView` · `makeKeyAndOrderFront:` | setters/methods/getter | dynamic title, position, size floor, composition root, show+focus |
| NSView | `addSubview:` · `setAutoresizingMask:` | method / setter | containment; resize tracking |
| NSButton | `setTitle:` · `setBezelStyle:` | property setters | the four button titles; rounded bezel |
| NSControl | `setEnabled:` | property setter | initial disable + history-driven enablement |
| NSControl | `setTarget:` · `setAction:` | property setters | the five action wirings (buttons + field Return) |
| NSTextField / NSControl | `setStringValue:` · `stringValue` | setter / getter | address prefill & canonical-URL write-back; status text; reading the typed URL |
| NSTextField | `setEditable:` · `setBordered:` | property setters | address-field input semantics |
| NSTextField | `setSelectable:` · `setBezeled:` · `setDrawsBackground:` | property setters | status-line static-label semantics |
| NSStackView | `setOrientation:` · `setAlignment:` · `setSpacing:` · `addArrangedSubview:` | setters/method | the toolbar row |
| NSFont | `systemFontOfSize:` | class factory | the 11-point status font |
| NSAlert | `alertWithError:` | class factory | the failure dialog, built from the NSError |
| NSAlert | `setAlertStyle:` · `runModal` | setter / instance method | warning style; blocking modal run |
| NSError | `localizedDescription` | property getter | the failure message |
| NSURL | `initWithString:` | initializer | parse the normalized text (nil ⇒ `Invalid URL:`) |
| NSURL | `absoluteString` | property getter | canonical URL for the address write-back |
| NSURLRequest | `initWithURL:` | initializer | wrap the URL for loading |
| WKWebView | `loadRequest:` | instance method | start a navigation |
| WKWebView | `reload` · `goBack` · `goForward` | instance methods | the three toolbar navigations |
| WKWebView | `canGoBack` · `canGoForward` | property getters | history guards + button enablement |
| WKWebView | `title` · `URL` | property getters | window-title & address write-back (both may be nil) |
| WKWebView | `setNavigationDelegate:` | property setter (weak) | register the async delegate |
| WKNavigationDelegate | `webView:didStartProvisionalNavigation:` · `webView:didFinishNavigation:` · `webView:didFailNavigation:withError:` · `webView:didFailProvisionalNavigation:withError:` | protocol callbacks | the four async navigation events |

**Abstract operations whose realizing selector varies per implementation** (this spec
asserts the operation, never one impl's selector): web-view creation (two implementations
create a default `WKWebViewConfiguration` and use `initWithFrame:configuration:`; two use
`initWithFrame:` alone); control/stack/label instantiation and framing (`initWithFrame:`
vs. bare init + `setFrame:`); main-menu installation (a shared standard-menu helper vs.
inline `NSMenu`/`NSMenuItem` construction); handler-object mechanism (§10).

**9.1 Enum / constant values used in every implementation:**

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
| `NSBezelStyleRounded` | 1 | the four buttons |
| `NSViewWidthSizable` | 2 | autoresizing (all three regions) |
| `NSViewHeightSizable` | 16 | autoresizing (web view) |
| `NSViewMinYMargin` | 8 | autoresizing (toolbar pin-to-top) |
| `NSViewMaxYMargin` | 32 | autoresizing (status pin-to-bottom) |
| `NSAlertStyleWarning` | 1 | the failure alert |

*Used in three of the four implementations (the fourth takes the platform default):*
`NSTextAlignmentLeft` (0, status-line alignment).

## 10. API-usage patterns

- **`delegate` — asynchronous and multi-callback (the app's load-bearing pattern):** the web
  view (delegator) holds the app's handler **weakly** via `setNavigationDelegate:`; the
  handler must outlive the run loop (every implementation keeps it alive in app state). Four
  protocol callbacks re-enter application code from the framework's run loop whenever a load
  resolves — the lifetime and re-entry model must hold *across* run-loop turns, not just
  within one event. Callbacks are delivered on the main thread (a fact each implementation's
  notes record from live runs).
- **`target-action`, five wirings:** four buttons plus the address field's Return, all wired
  at build time. The field and the Go button share one action, making Return ≡ Go by
  construction. All four implementations use the same app-defined action selector names —
  `go:`, `back:`, `forward:`, `reload:` — an internal, non-observable convention recorded
  here as shared fact, not testable contract.
- **Handler-object granularity is a realization, its role a rule:** every implementation
  routes the four navigation callbacks and the five action wirings to app-side handler
  object(s) that outlive the run loop — realized variously as one navigation delegate plus
  four single-selector targets, one navigation delegate plus one four-selector target, or a
  single eight-selector controller object (an `NSObject` subclass formally conforming to
  `WKNavigationDelegate`).
- **`parent-child`:** toolbar stack, web view, and status line into the content view; the
  five controls arranged into the stack.
- **Callback-driven UI reconciliation:** all chrome (status, title, address, enablement)
  is a function of web-view state, read and applied only inside delegate callbacks — the
  app never caches navigation state.
- **Error object surfacing:** the `NSError` delivered by the failure callbacks is consumed
  twice — `localizedDescription` for the status line, and the whole object via the
  `alertWithError:` factory for the modal dialog.
- **Value construction chain:** text → `NSURL` → `NSURLRequest` → `loadRequest:` — each step
  nil-checked or unconditional as §6.2 specifies.
- **Object lifecycle, property configuration, value-type geometry, option-set bitmask, menu
  object-graph construction, run-loop entry:** as in the app-kind and the earlier portfolio
  specs.

## 11. Observable outcomes & accessibility

**Visual outcomes:**
- A centered, resizable 800 × 600 window titled `Mini Browser`, with a top toolbar reading
  `◀ ▶ Reload [address field] Go`, a large web-content area, and a small bottom status line
  initially reading `Ready`.
- The address field is prefilled with the home URL; ◀ and ▶ start disabled.
- With network, the home page renders in the web view; the status line passes through
  `Loading…`/`Loading...` to `Done`; the address field shows the canonical URL
  **(to confirm in-VM — network-dependent)**.
- After navigating to a page exposing a title, the window title reads
  `<page title> — Mini Browser` (subject to the first-load title lag, §7.2)
  **(to confirm in-VM)**.
- A failed load raises a modal warning alert (platform-formatted from the NSError);
  dismissing it reveals a status line containing `failed: ` **(to confirm in-VM)**.
- Window resizing keeps the toolbar pinned top, status pinned bottom, web view filling the
  rest; the window refuses to shrink below 500 × 400 **(to confirm in-VM)**.

**Accessibility expectations** *(in-VM confirmable)*:
- The window is exposed with accessibility title `Mini Browser` (or the §7.2 composite after
  a titled load).
- The four buttons are exposed as button elements titled `◀`, `▶`, `Reload`, `Go`; the
  ◀/▶ elements' *enabled* flag tracks `canGoBack`/`canGoForward` — the implementations' VM
  notes found this AX flag the reliable history observable (the greyed rendering is less
  legible than the flag).
- The address field is exposed as a text-field element. *Caveat from the implementations'
  VM notes: its AX value read back empty under the test driver — the displayed URL had to be
  read via OCR/screenshot; treat AX-value assertions on it as unreliable.*
- The status line is exposed as a static-text element (non-editable, non-selectable).
- The web view's rendered page is a WKWebView subtree; whether its DOM is AX- or
  OCR-observable under the driver is **(unknown — to confirm in-VM)** — no assertion in this
  spec depends on page content.
- The application menu's Quit item is reachable and carries the Command-Q key equivalent.

## 12. Not included

- **No progress indicator** — loading feedback is the status line's text only. (A catalogue
  row mentions `NSProgressIndicator`; no implementation has one.)
- **No navigation-policy, UI-delegate, or download hooks** — no
  `decidePolicyForNavigationAction:`-style methods, no `WKUIDelegate`: link clicks, popups,
  and in-page behaviour are entirely the web view's defaults, unobserved by the app.
- **No stop/cancel control**, no home button, no history UI beyond ◀/▶.
- **No search** — address input is always treated as a URL (§6.2.4), never a search query.
- **No document, file, or persistence surface; no MRU; no state across launches.**
- **No authentication/TLS handling** — no challenge callbacks; whatever the platform does
  with certificate errors surfaces only through the generic failure path (§7.3).
- **No close-to-quit** — closing the window is not specified to terminate the app (§3.9).
- **No app timers or background threads** — all asynchrony is the framework's.
- **No web-view configuration tuning** — where a configuration object is created at all, it
  is the default, untouched.
- **No chrome refresh outside `didFinishNavigation:`** — deliberate single write-path (§7.2).

## 13. Behavioural exemplar (acceptance / forward-generation input)

Observable assertions against a live-VM run, each mapped to a scenario-runner verb
(enumeration only — not scenario code). Assertions state the *rule* (stable
substrings/invariants), so the suite verifies any conforming implementation.

**Network reality (load-bearing for this app):** the verification VM has **no network**, and
every implementation's home URL is a live `https` URL. Assertions below are grouped by what
they need. In a no-network VM the initial load is expected to *fail* shortly after launch,
producing the §7.3 modal alert — offline scenarios must dismiss it (press Return) before
driving other chrome. A network-free path to exercise the success chrome (`Done`, history,
reload, title) would be `file://` navigation, which the normalization rule passes through
unchanged — but whether `loadRequest:` renders `file://` content is **(unknown — to confirm
in-VM)**; until confirmed, success-path assertions are network-gated. **Driver guidance**
(from the implementations' VM notes): triple-click the address field to select-all before
typing (Cmd-A is unreliable over the VM input path; single click only places the cursor);
read ◀/▶ history state from the AX *enabled* flag, not pixels; read the address-field text
via OCR, not its AX value.

**Network-independent (runnable in the no-network VM):**

- **Process is running after launch.** → `expect-running-app`
- **Launch diagnostic is emitted.** Stdout contains a line beginning `Mini Browser`. →
  `wait-for-log "Mini Browser"` / `expect-log "Mini Browser"`
- **Window title at launch.** The frontmost window's accessibility title is `Mini Browser`
  (before any titled load). → `expect-ax` window AXTitle
- **Toolbar present.** Button elements titled `Reload` and `Go` exist; button elements
  titled `◀` and `▶` exist. → `expect-ax` / `expect-ocr "Reload"`, `expect-ocr "Go"`
- **History starts empty.** The `◀` and `▶` buttons are disabled. → `expect-ax`
  (enabled = false)
- **Address field is prefilled.** The field shows the implementation's home URL — an
  `https://` string (stable substring `https://`). → `wait-for-ocr "https://"`
- **Boundary — offline initial load fails loudly.** With no network, a modal warning alert
  appears after launch; dismissing it (Return) leaves a status line containing `failed: `.
  → `wait-for-ocr` alert chrome, `press "Return"`, `wait-for-ocr "failed:"` *(which failure
  callback fires offline, and the alert's platform text — to confirm in-VM)*
- **Boundary — blank input navigates nowhere.** Empty the address field (triple-click,
  delete) and press Return: the status line reads `Enter a URL to navigate`; no alert, no
  load. → `click-at` field ×3, `press "Delete"`, `press "Return"`,
  `wait-for-ocr "Enter a URL to navigate"`
- **Boundary — unparseable URL is reported, not loaded.** Type text the platform URL parser
  rejects (e.g. containing spaces) and press Return: the status line begins `Invalid URL: `.
  → `type`, `press "Return"`, `wait-for-ocr "Invalid URL"` *(which strings NSURL rejects is
  platform behaviour — to confirm in-VM)*
- **Boundary — input is a URL, never a search.** Typing a bare word and pressing Return
  attempts `https://<word>` (observable offline as a failure alert, never a search page). →
  `type "not-a-url"`, `press "Return"`, then the failure sequence above *(to confirm in-VM)*
- **Quit terminates the app.** Sending Command-Q ends the process. → `chord cmd q`, then
  `expect-running-app` is false *(dismiss any modal alert first)*
- **(To confirm in-VM) Close-button behaviour.** Activating the close control hides the
  window; per §3.9 the process is expected to keep running (no close-to-quit opt-in). A
  scenario should record the *actual* observed behaviour. → `click-at` close button, then
  `expect-running-app`

**Network-required (unrunnable in the no-network VM; previously verified in the
implementations' networked VM runs — retained as the success-path contract):**

- **Home page loads.** The status line passes through a value beginning `Loading` and
  settles on `Done`. → `wait-for-ocr "Loading"` (timing-fragile; optional), then
  `wait-for-ocr "Done"`
- **Address bar canonicalizes.** After `Done`, the address field shows the web view's
  canonical URL (stable substring `https://`). → `wait-for-ocr` *(read via OCR — AX value
  unreliable)*
- **Typed URL + Return navigates.** Select-all, type a different URL, press Return: status
  reaches `Done`; the address field shows the new URL. → `click-at` ×3, `type`,
  `press "Return"`, `wait-for-ocr "Done"`
- **Go ≡ Return.** The same navigation driven by clicking `Go` behaves identically. →
  `click-at` Go, `wait-for-ocr "Done"`
- **Bare host gets `https://` prepended.** Typing a schemeless host and navigating results
  in the address field showing it with the `https://` prefix. → `type "example.org"`,
  `press "Return"`, `wait-for-ocr "https://example.org"`
- **History enables after a second load.** After two distinct successful navigations, `◀` is
  enabled. → `expect-ax` (enabled = true)
- **Back walks history.** Clicking `◀` loads the previous page (`Done` again; address
  reverts) and `▶` becomes enabled. → `click-at` ◀, `wait-for-ocr "Done"`, `expect-ax` ▶
  enabled
- **Forward walks history.** Clicking `▶` re-loads the newer page and re-disables `▶` at the
  history head. → `click-at` ▶, `wait-for-ocr "Done"`, `expect-ax`
- **Reload re-navigates.** Clicking `Reload` passes through `Loading`→`Done` again. →
  `click-at` Reload, `wait-for-ocr "Done"`
- **Window title tracks titled pages.** After navigating to a page exposing a title, the
  window title contains `— Mini Browser`. Assert this on a *second* navigation or a back-nav
  to an already-titled page — the title property lags the finish callback on first loads
  (§7.2). → `expect-ax` window AXTitle / `expect-ocr "Mini Browser"`
