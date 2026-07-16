// mini-browser — the Node TypeScript target's Mini Browser sample app (ladder rung 5/7): an
// address bar with ◀/▶/Reload/Go controls, a WKWebView filling the window, and a status line
// that mirrors the async WKNavigationDelegate callbacks. Typing a URL (or a bare host) and
// pressing Return/Go navigates — a missing scheme gets `https://` prepended; ◀/▶ walk the web
// view's own back-forward history. Mirrors the racket/chez/gerbil/sbcl `mini-browser` apps
// (`apps/macos/mini-browser/docs/spec.md`).
//
// Loaded by bootstrap.cjs strictly AFTER the dispatch backend is installed — see hello-window's
// app.ts for why (an ES module's static imports evaluate before anything else in the importing
// file runs, so every generated class's own `static { __registerClass(...) }` needs a live
// dispatch backend at import time).
//
// Does NOT call `NSApplication.run()`: the native launcher (embed_main.mm) owns `main()` and
// calls `[NSApp run]` itself, AFTER this module finishes (ADR-0056), same as the rest of the
// ladder.
//
// FIRST app in this ladder to exercise WebKit and an async, multi-callback ObjC DELEGATE
// PROTOCOL (WKNavigationDelegate) via the runtime's dedicated delegate machinery, rather than
// only the `__subclassAlloc`/`__bindSubclass` pattern the first four apps used throughout. The
// navigation delegate here is a plain JS object literal implementing the generated
// `WKNavigationDelegate` interface, passed straight to `setNavigationDelegate_`: the runtime
// (`@apianyware/runtime` delegate.ts, ADR-0059 §3/§6/§8) mints a synthesized forwarding ObjC
// class on first use, keeps it alive via `objc_setAssociatedObject` on the web view (the slot is
// `associate`d), and marshals each callback's args to the real wrapped types
// (WKWebView/WKNavigation/NSError) the interface declares — no raw bigints, no hand-written
// ObjC type encodings for these four selectors.
//
// Target-action (the four toolbar buttons + the address field's Return action) still goes
// through `__subclassAlloc`/`__bindSubclass`: `NSControl.setTarget_` is typed `NSObject` and
// `__unwrap`s its argument directly, so it needs a real ObjC-backed subclass instance, not a
// plain JS object — the two inbound mechanisms are used side by side, split by which one each
// framework slot actually requires.
//
// No runtime primitive reads NSString content back into JS (every prior ladder app only ever
// CONSTRUCTS strings). NSString's generated surface is just `length()` + `characterAtIndex_` (no
// UTF8String/bulk-copy selector in this corpus) — `nsToString` below builds on those two, fine
// for this app's short strings (URLs, titles, error messages).

import {
  NSAlert,
  NSAlertStyle,
  NSApplication,
  NSApplicationActivationPolicy,
  NSAutoresizingMaskOptions,
  NSBackingStoreType,
  NSBezelStyle,
  NSButton,
  NSFont,
  NSLayoutAttribute,
  NSMenu,
  NSMenuItem,
  NSStackView,
  NSTextField,
  NSUserInterfaceLayoutOrientation,
  NSWindow,
  NSWindowStyleMask,
} from '@apianyware/appkit';
import { NSError, NSString, NSURL, NSURLRequest } from '@apianyware/foundation';
import { WKWebView } from '@apianyware/webkit';
import type { WKNavigationDelegate } from '@apianyware/webkit';
import {
  NSObject,
  __alloc,
  __bindSubclass,
  __cfstr,
  __class,
  __subclassAlloc,
  __wrapOwned,
} from '@apianyware/runtime';
import type { CGRect, SubclassOverride } from '@apianyware/runtime';

function jsString(s: string): NSString {
  return __wrapOwned(NSString, __cfstr(s))!;
}

function rect(x: number, y: number, w: number, h: number): CGRect {
  return { origin: { x, y }, size: { width: w, height: h } };
}

// NSString has no bulk-read selector in this corpus — build a JS string from `length()` +
// `characterAtIndex_` (UTF-16 code units, exactly what a JS string is internally, so this is
// correct for the whole BMP and passes surrogate pairs through untouched).
function nsToString(s: NSString): string {
  const n = s.length();
  let out = '';
  for (let i = 0; i < n; i++) out += String.fromCharCode(s.characterAtIndex_(i));
  return out;
}

// One fixed home URL (spec §6.1) — prefilled into the address field and navigated to at launch
// through the same text-navigation rule user input uses.
const HOME_URL = 'https://example.com';

// ── App menu (Quit -> -[NSApplication terminate:]), as the rest of the ladder. ─────────────────
function installAppMenu(app: NSApplication, appName: string): void {
  const mainMenu = __alloc(NSMenu).initWithTitle_(jsString(''));
  const appMenuItem = __alloc(NSMenuItem).initWithTitle_action_keyEquivalent_(jsString(''), '', jsString(''));
  const appMenu = __alloc(NSMenu).initWithTitle_(jsString(appName));
  const quitItem = __alloc(NSMenuItem).initWithTitle_action_keyEquivalent_(
    jsString(`Quit ${appName}`),
    'terminate:',
    jsString('q'),
  );
  appMenu.addItem_(quitItem);
  appMenuItem.setSubmenu_(appMenu);
  mainMenu.addItem_(appMenuItem);
  app.setMainMenu_(mainMenu);
}

// ── Assemble the window (spec §4/§5) ─────────────────────────────────────────────────────────
const app = NSApplication.sharedApplication();
app.setActivationPolicy_(NSApplicationActivationPolicy.NSApplicationActivationPolicyRegular);
installAppMenu(app, 'Mini Browser');

const window = __alloc(NSWindow).initWithContentRect_styleMask_backing_defer_(
  rect(0, 0, 800, 600),
  NSWindowStyleMask.NSWindowStyleMaskTitled |
    NSWindowStyleMask.NSWindowStyleMaskClosable |
    NSWindowStyleMask.NSWindowStyleMaskMiniaturizable |
    NSWindowStyleMask.NSWindowStyleMaskResizable,
  NSBackingStoreType.NSBackingStoreBuffered,
  false,
);
window.setTitle_(jsString('Mini Browser'));
window.center();
window.setMinSize_({ width: 500, height: 400 });

const content = window.contentView();

// WKWebView: fills below the toolbar, above the status line (spec §5.2). `initWithFrame:` alone
// (inherited from NSView) — no WKWebViewConfiguration (spec §9's "abstract operations" note: two
// of the four reference targets build a configuration object first, two use `initWithFrame:`
// alone; WKWebViewConfiguration itself declares no plain `init` in this corpus's surface, so the
// configuration-less path is also the simpler one here).
const webView = __alloc(WKWebView).initWithFrame_(rect(12, 46, 776, 498));
webView.setAutoresizingMask_(
  NSAutoresizingMaskOptions.NSViewWidthSizable | NSAutoresizingMaskOptions.NSViewHeightSizable,
);
content.addSubview_(webView);

// Toolbar controls (spec §5.1) — built unwired, then wired to the controller once it exists.
const backButton = __alloc(NSButton).init();
backButton.setTitle_(jsString('◀'));
backButton.setBezelStyle_(NSBezelStyle.NSBezelStyleRounded);
backButton.setEnabled_(false);

const forwardButton = __alloc(NSButton).init();
forwardButton.setTitle_(jsString('▶'));
forwardButton.setBezelStyle_(NSBezelStyle.NSBezelStyleRounded);
forwardButton.setEnabled_(false);

const reloadButton = __alloc(NSButton).init();
reloadButton.setTitle_(jsString('Reload'));
reloadButton.setBezelStyle_(NSBezelStyle.NSBezelStyleRounded);

const addressField = __alloc(NSTextField).init();
addressField.setStringValue_(jsString(HOME_URL));
addressField.setEditable_(true);
addressField.setBordered_(true);

const goButton = __alloc(NSButton).init();
goButton.setTitle_(jsString('Go'));
goButton.setBezelStyle_(NSBezelStyle.NSBezelStyleRounded);

// Status line (spec §5.3) — a static, non-interactive label pinned to the bottom.
const statusLabel = __alloc(NSTextField).init();
statusLabel.setFont_(NSFont.systemFontOfSize_(11));
statusLabel.setEditable_(false);
statusLabel.setSelectable_(false);
statusLabel.setBezeled_(false);
statusLabel.setDrawsBackground_(false);
statusLabel.setFrame_(rect(12, 12, 776, 22));
statusLabel.setAutoresizingMask_(
  NSAutoresizingMaskOptions.NSViewWidthSizable | NSAutoresizingMaskOptions.NSViewMaxYMargin,
);
content.addSubview_(statusLabel);

// ── Status / chrome-refresh / error surfacing / navigation (spec §6.2, §7) ──────────────────────
function setStatus(text: string): void {
  statusLabel.setStringValue_(jsString(text));
}

// The chrome-refresh rule (spec §7.2) — the ONLY place chrome is updated, driven by
// didFinishNavigation: however the load happened (typed URL, ◀/▶ history, Reload).
function refreshChrome(webView: WKWebView): void {
  backButton.setEnabled_(webView.canGoBack());
  forwardButton.setEnabled_(webView.canGoForward());

  const title = webView.title(); // generated non-null; the real call can hand back nil/empty.
  const titleText = title ? nsToString(title) : '';
  window.setTitle_(jsString(titleText === '' ? 'Mini Browser' : `${titleText} — Mini Browser`));

  const url = webView.URL(); // generated non-null; the real call can hand back nil.
  if (url) {
    const urlText = nsToString(url.absoluteString());
    if (urlText !== '') addressField.setStringValue_(jsString(urlText));
  }

  setStatus('Done');
}

// The failure rule (spec §7.3) — both WKNavigationDelegate failure callbacks funnel here,
// parameterized by a phase word. `error` is typed non-null by the generated interface but the
// real callback can hand back nil (spec's own nil-error boundary).
function showError(error: NSError | null, phase: string): void {
  const message = error ? nsToString(error.localizedDescription()) : 'Unknown error';
  if (error) {
    const alert = NSAlert.alertWithError_(error);
    alert.setAlertStyle_(NSAlertStyle.NSAlertStyleWarning);
    alert.runModal(); // blocks until the user dismisses it.
  }
  setStatus(`${phase} failed: ${message}`);
}

// The text-navigation rule (spec §6.2) — shared by the initial load, Go, and the address
// field's Return action.
function navigateToText(text: string): void {
  const trimmed = text.trim();
  if (trimmed === '') {
    setStatus('Enter a URL to navigate');
    return;
  }
  // Scheme detection: an ASCII letter, then letters/digits/+/./- , up to a `:`.
  const normalized = /^[A-Za-z][A-Za-z0-9+.-]*:/.test(trimmed) ? trimmed : `https://${trimmed}`;
  const url = __alloc(NSURL).initWithString_(jsString(normalized));
  if (!url) {
    // generated non-null; the real initializer can hand back nil for a rejected string.
    setStatus(`Invalid URL: ${normalized}`);
    return;
  }
  const request = __alloc(NSURLRequest).initWithURL_(url);
  webView.loadRequest_(request);
}

// ── The toolbar target-action handler (spec §6.3) — one real ObjC subclass, four selectors,
// sender ignored throughout. `NSControl.setTarget_` unwraps its argument directly, so it needs a
// real object, unlike the navigation delegate below. ───────────────────────────────────────────
const NSOBJECT_CLASS = __class('NSObject');
const BROWSER_CONTROLLER_METHODS: readonly SubclassOverride[] = [
  ['go:', 'v@:@'],
  ['back:', 'v@:@'],
  ['forward:', 'v@:@'],
  ['reload:', 'v@:@'],
];

class BrowserController extends NSObject {
  constructor() {
    super(__subclassAlloc(BrowserController, NSOBJECT_CLASS, BROWSER_CONTROLLER_METHODS));
    __bindSubclass(this);
  }

  go_(_sender: bigint): void {
    navigateToText(nsToString(addressField.stringValue()));
  }

  back_(_sender: bigint): void {
    if (webView.canGoBack()) webView.goBack();
  }

  forward_(_sender: bigint): void {
    if (webView.canGoForward()) webView.goForward();
  }

  reload_(_sender: bigint): void {
    webView.reload();
  }
}

// A module-level const, not block-scoped: NSControl.target is weakly referenced, so a live JS
// reference for the process lifetime is what keeps this instance alive (the rule every prior
// ladder app's own controller relies on).
const controller = new BrowserController();

goButton.setTarget_(controller);
goButton.setAction_('go:');
addressField.setTarget_(controller);
addressField.setAction_('go:'); // Return in the field ≡ clicking Go, by construction.
backButton.setTarget_(controller);
backButton.setAction_('back:');
forwardButton.setTarget_(controller);
forwardButton.setAction_('forward:');
reloadButton.setTarget_(controller);
reloadButton.setAction_('reload:');

// ── The navigation delegate (spec §7) — a plain JS object literal implementing the generated
// WKNavigationDelegate interface, bridged automatically by the runtime's delegate machinery
// (ADR-0059 §3/§6/§8) when passed to setNavigationDelegate_. No subclass, no manual keep-alive:
// the slot associates the synthesized forwarder onto webView itself. ───────────────────────────
const navigationDelegate: WKNavigationDelegate = {
  webView_didStartProvisionalNavigation_(_webView, _navigation) {
    setStatus('Loading…');
  },
  webView_didFinishNavigation_(webView, _navigation) {
    refreshChrome(webView);
  },
  webView_didFailNavigation_withError_(_webView, _navigation, error) {
    showError(error, 'Load');
  },
  webView_didFailProvisionalNavigation_withError_(_webView, _navigation, error) {
    showError(error, 'Request');
  },
};
webView.setNavigationDelegate_(navigationDelegate);

// ── Toolbar stack (spec §5.1) ────────────────────────────────────────────────────────────────
const toolbar = __alloc(NSStackView).init();
toolbar.setFrame_(rect(12, 556, 776, 32));
toolbar.setOrientation_(NSUserInterfaceLayoutOrientation.NSUserInterfaceLayoutOrientationHorizontal);
toolbar.setAlignment_(NSLayoutAttribute.NSLayoutAttributeFirstBaseline);
toolbar.setSpacing_(8);
toolbar.addArrangedSubview_(backButton);
toolbar.addArrangedSubview_(forwardButton);
toolbar.addArrangedSubview_(reloadButton);
toolbar.addArrangedSubview_(addressField);
toolbar.addArrangedSubview_(goButton);
toolbar.setAutoresizingMask_(
  NSAutoresizingMaskOptions.NSViewWidthSizable | NSAutoresizingMaskOptions.NSViewMinYMargin,
);
content.addSubview_(toolbar);

setStatus('Ready');

// Kick the initial load (spec §3 step 5) — before the window is shown; the load itself completes
// asynchronously (or fails) after the run loop starts.
navigateToText(HOME_URL);

// AW_MB_SMOKE=1 (the host construction pre-flight, matching hello-window's AW_HELLO_SMOKE
// convention): every FFI crossing above must still succeed, but skip actually showing the
// window — the launcher (embed_main.mm) does not enter `[NSApp run]` in this mode either.
if (!process.env.AW_MB_SMOKE) {
  window.makeKeyAndOrderFront_(app);
  app.activate();
  console.log('Mini Browser opened. Type a URL + Return, navigate with ◀/▶/Reload. Quit with Cmd-Q.');
}
