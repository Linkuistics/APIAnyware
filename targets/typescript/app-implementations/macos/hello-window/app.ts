// hello-window — the Node TypeScript target's simplest sample app (ladder rung 1/7): a
// centred 400×200 window with a "Hello, macOS!" label and a standard app menu (Quit only).
// Mirrors the racket/chez/sbcl `hello-window` spec exactly (same size, title pattern, label).
//
// Loaded by bootstrap.mjs strictly AFTER the dispatch backend is installed: every generated
// class's own `static { __registerClass(...) }` / `static __cls = __class(...)` runs at THIS
// module's own import time (an ES module's static imports evaluate before anything else in the
// importing file runs), so a static top-level `import { NSWindow } from '@apianyware/appkit'`
// here would call `__class('NSWindow')` against the NOT_LOADED dispatch sentinel if this module
// were imported before `__installDispatch` — see bootstrap.mjs.
//
// Does NOT call `NSApplication.run()`: the native launcher (embed_main.mm) owns `main()` and
// calls `[NSApp run]` itself, AFTER this module finishes (ADR-0056) — a JS call to `run()` would
// re-introduce the blocking JS→native call the pump architecture exists to avoid (k6 FINDINGS).

import {
  NSApplication,
  NSApplicationActivationPolicy,
  NSBackingStoreType,
  NSFont,
  NSMenu,
  NSMenuItem,
  NSTextAlignment,
  NSTextField,
  NSWindow,
  NSWindowStyleMask,
} from '@apianyware/appkit';
import { NSString } from '@apianyware/foundation';
import { __alloc, __cfstr, __wrapOwned } from '@apianyware/runtime';

function jsString(s: string): NSString {
  return __wrapOwned(NSString, __cfstr(s))!;
}

const app = NSApplication.sharedApplication();
app.setActivationPolicy_(NSApplicationActivationPolicy.NSApplicationActivationPolicyRegular);

// ── Standard app menu: one top-level item, its submenu holding Quit (→ `terminate:`) ────────────
// A nil-targeted action sends up the responder chain to NSApplication, which implements
// `terminate:` — no delegate/target wiring needed for Quit to work.
const mainMenu = __alloc(NSMenu).initWithTitle_(jsString(''));
const appMenuItem = __alloc(NSMenuItem).initWithTitle_action_keyEquivalent_(
  jsString(''),
  '',
  jsString(''),
);
const appMenu = __alloc(NSMenu).initWithTitle_(jsString('Hello Window'));
const quitItem = __alloc(NSMenuItem).initWithTitle_action_keyEquivalent_(
  jsString('Quit Hello Window'),
  'terminate:',
  jsString('q'),
);
appMenu.addItem_(quitItem);
appMenuItem.setSubmenu_(appMenu);
mainMenu.addItem_(appMenuItem);
app.setMainMenu_(mainMenu);

// ── Window (400×200, centred, titled|closable|miniaturizable — not resizable) ───────────────────
const styleMask =
  NSWindowStyleMask.NSWindowStyleMaskTitled |
  NSWindowStyleMask.NSWindowStyleMaskClosable |
  NSWindowStyleMask.NSWindowStyleMaskMiniaturizable;

const window = __alloc(NSWindow).initWithContentRect_styleMask_backing_defer_(
  { origin: { x: 0, y: 0 }, size: { width: 400, height: 200 } },
  styleMask,
  NSBackingStoreType.NSBackingStoreBuffered,
  false,
);
window.setTitle_(jsString('Hello from Node TypeScript'));
window.center();

// ── Label (centred in the content area) ──────────────────────────────────────────────────────────
const label = __alloc(NSTextField).initWithFrame_({
  origin: { x: 0, y: 70 },
  size: { width: 400, height: 60 },
});
label.setStringValue_(jsString('Hello, macOS!'));
label.setFont_(NSFont.systemFontOfSize_(24));
label.setAlignment_(NSTextAlignment.NSTextAlignmentCenter);
label.setEditable_(false);
label.setSelectable_(false);
label.setBezeled_(false);
label.setDrawsBackground_(false);

window.contentView().addSubview_(label);

// AW_HELLO_SMOKE=1 (the host construction pre-flight, matching the other targets'
// `run.lisp`/`hello-window.rkt` convention): every FFI crossing above must still succeed, but
// skip actually showing the window — the launcher (embed_main.mm) does not enter `[NSApp run]`
// in this mode either, so nothing would service a shown window's events anyway.
if (!process.env.AW_HELLO_SMOKE) {
  window.makeKeyAndOrderFront_(app);
  app.activate();
}
