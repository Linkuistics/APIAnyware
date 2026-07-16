// pdfkit-viewer — the Node TypeScript target's PDFKit-viewer sample app (ladder rung 4/7): a
// 720×540 window with a toolbar (Open…/◀/▶ + a "Page n of N" label) over a PDFView. The user
// opens a .pdf via a modal NSOpenPanel, navigates pages with the toolbar buttons, and the label
// stays synchronized via the PDFViewPageChangedNotification observer — however the page turned
// (buttons, arrow keys, scroll). Mirrors the racket/chez/gerbil/sbcl `pdfkit-viewer` apps
// (`apps/macos/pdfkit-viewer/docs/spec.md`).
//
// Loaded by bootstrap.cjs strictly AFTER the dispatch backend is installed — see hello-window's
// app.ts for why (an ES module's static imports evaluate before anything else in the importing
// file runs, so every generated class's own `static { __registerClass(...) }` needs a live
// dispatch backend at import time).
//
// Does NOT call `NSApplication.run()`: the native launcher (embed_main.mm) owns `main()` and
// calls `[NSApp run]` itself, AFTER this module finishes (ADR-0056), same as hello-window.
//
// First app in this ladder to exercise PDFKit, a modal NSOpenPanel, and an NSNotificationCenter
// observer. ONE `__subclassAlloc`/`__bindSubclass` handler carries FOUR selectors —
// `openDocument:`/`goPrev:`/`goNext:` (target-action) plus `pageChanged:` (the notification
// callback) — generalizing scenekit-viewer's `SceneController` (three target-actions) to a
// fourth, differently-wired selector; same primitives, same "module-level const keeps it alive"
// rule (NSControl target/action and NSNotificationCenter observers are weakly referenced).
//
// The label update flows through the NOTIFICATION, not an explicit call from goPrev_/goNext_ —
// so it stays correct however the page turned (spec §7.1/§7.3), the app's load-bearing behaviour.

import {
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
  NSOpenPanel,
  NSStackView,
  NSTextField,
  NSUserInterfaceLayoutOrientation,
  NSWindow,
  NSWindowStyleMask,
} from '@apianyware/appkit';
import { NSMutableArray, NSNotificationCenter, NSString } from '@apianyware/foundation';
import { PDFDisplayMode, PDFDocument, PDFView, PDFViewPageChangedNotification } from '@apianyware/pdfkit';
import type { PDFPage } from '@apianyware/pdfkit';
import { UTType } from '@apianyware/uniformtypeidentifiers';
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

// NSModalResponseOK is hand-defined in every reference implementation — absent from the
// generated AppKit enums (spec §9.1).
const NS_MODAL_RESPONSE_OK = 1;

// ── The handler (spec §10, "handler-object granularity is a realization, not a rule" — this
// leaf follows sbcl's shape: one object, all four selectors). Built on the same
// `__subclassAlloc`/`__bindSubclass` primitives ui-controls-gallery/scenekit-viewer already
// proved for one/three selectors respectively. ─────────────────────────────────────────────────
const NSOBJECT_CLASS = __class('NSObject');
const PDF_CONTROLLER_METHODS: readonly SubclassOverride[] = [
  ['openDocument:', 'v@:@'],
  ['goPrev:', 'v@:@'],
  ['goNext:', 'v@:@'],
  ['pageChanged:', 'v@:@'],
];

class PdfController extends NSObject {
  private readonly pdfView: PDFView;
  private readonly prevButton: NSButton;
  private readonly nextButton: NSButton;
  private readonly pageLabel: NSTextField;
  private document: PDFDocument | null = null;

  constructor(pdfView: PDFView, prevButton: NSButton, nextButton: NSButton, pageLabel: NSTextField) {
    super(__subclassAlloc(PdfController, NSOBJECT_CLASS, PDF_CONTROLLER_METHODS));
    __bindSubclass(this);
    this.pdfView = pdfView;
    this.prevButton = prevButton;
    this.nextButton = nextButton;
    this.pageLabel = pageLabel;
    this.refresh(); // spec §3 step 5 — establish the initial (empty) UI state.
  }

  // The UI-refresh rule (spec §7.2) — single source of truth for the label + button enabled
  // state, driven explicitly after a successful open and via the pageChanged: notification for
  // every other page turn (buttons, arrow keys, scroll).
  private refresh(): void {
    if (!this.document) {
      this.pageLabel.setStringValue_(jsString('No PDF loaded'));
      this.prevButton.setEnabled_(false);
      this.nextButton.setEnabled_(false);
      return;
    }
    const total = this.document.pageCount();
    // A transiently nil current page (mid-swap) collapses to index 0 (spec §7.2 boundary) — the
    // emitted return type asserts non-null, but the real ObjC call can hand back nil.
    const current: PDFPage | null = this.pdfView.currentPage();
    const index = current ? this.document.indexForPage_(current) : 0;
    this.pageLabel.setStringValue_(jsString(`Page ${index + 1} of ${total}`));
    this.prevButton.setEnabled_(this.pdfView.canGoToPreviousPage());
    this.nextButton.setEnabled_(this.pdfView.canGoToNextPage());
  }

  // openDocument: — modal NSOpenPanel filtered to .pdf via UTType (the deprecated
  // setAllowedFileTypes: the four Lisp targets use is not in this corpus; setAllowedContentTypes:
  // + UTType.typeWithFilenameExtension_ is the generated equivalent — same filtering operation).
  // Every boundary (cancel, nil URL, failed initWithURL:) is a silent no-op (spec §6).
  openDocument_(_sender: bigint): void {
    const panel = NSOpenPanel.openPanel();
    panel.setCanChooseFiles_(true);
    panel.setCanChooseDirectories_(false);
    panel.setAllowsMultipleSelection_(false);
    const pdfType = UTType.typeWithFilenameExtension_(jsString('pdf'));
    const types = __alloc(NSMutableArray).initWithCapacity_(1);
    types.addObject_(pdfType);
    panel.setAllowedContentTypes_(types);

    if (panel.runModal() !== NS_MODAL_RESPONSE_OK) return; // boundary — cancel.
    const url = panel.URL();
    if (!url) return; // boundary — nil URL.
    const doc = __alloc(PDFDocument).initWithURL_(url);
    if (!doc) return; // boundary — failed document construction (not a readable PDF).

    this.document = doc; // replaces any previously loaded document.
    this.pdfView.setDocument_(doc);
    this.refresh(); // the one place a refresh is invoked explicitly, not via the notification.
  }

  // goPrev:/goNext: — PDFKit ignores the sender (spec §7.1); the emitted signature types it as
  // non-nullable NSObject (no nullability annotation on this SDK parameter), so pass a valid
  // object (this handler itself) rather than fighting the type system with a cast. The resulting
  // page change fires PDFViewPageChangedNotification, which refreshes the UI via pageChanged: —
  // these handlers do NOT refresh the UI themselves.
  goPrev_(_sender: bigint): void {
    this.pdfView.goToPreviousPage_(this);
  }

  goNext_(_sender: bigint): void {
    this.pdfView.goToNextPage_(this);
  }

  // pageChanged: — fires on EVERY page change (buttons, arrow keys, scroll); one observer keeps
  // the label + buttons correct however the page was turned (spec §7.3).
  pageChanged_(_note: bigint): void {
    this.refresh();
  }
}

// ── App menu (Quit -> -[NSApplication terminate:]), as hello-window/ui-controls-gallery/
// scenekit-viewer. ───────────────────────────────────────────────────────────────────────────
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
installAppMenu(app, 'PDFKit Viewer');

const window = __alloc(NSWindow).initWithContentRect_styleMask_backing_defer_(
  rect(0, 0, 720, 540),
  NSWindowStyleMask.NSWindowStyleMaskTitled |
    NSWindowStyleMask.NSWindowStyleMaskClosable |
    NSWindowStyleMask.NSWindowStyleMaskMiniaturizable |
    NSWindowStyleMask.NSWindowStyleMaskResizable,
  NSBackingStoreType.NSBackingStoreBuffered,
  false,
);
window.setTitle_(jsString('PDFKit Viewer'));
window.center();
window.setMinSize_({ width: 480, height: 360 });

const content = window.contentView();

// PDFView: fills below the toolbar strip, auto-scaling, single-page-continuous (spec §5.2).
// Unlike SCNView, PDFView declares no own designated initializer — plain `init()` + `setFrame_`
// (matching NSView's usual shape, confirmed against the sbcl reference).
const pdfView = __alloc(PDFView).init();
pdfView.setFrame_(rect(0, 0, 720, 492));
pdfView.setAutoresizingMask_(
  NSAutoresizingMaskOptions.NSViewWidthSizable | NSAutoresizingMaskOptions.NSViewHeightSizable,
);
pdfView.setAutoScales_(true);
pdfView.setDisplayMode_(PDFDisplayMode.kPDFDisplaySinglePageContinuous);
content.addSubview_(pdfView);

// Toolbar controls (spec §5.1) — built unwired, then wired to the controller once it exists
// (same two-phase construction as ui-controls-gallery's radio pair / scenekit-viewer's picker).
const openButton = __alloc(NSButton).init();
openButton.setTitle_(jsString('Open…'));
openButton.setBezelStyle_(NSBezelStyle.NSBezelStyleRounded);

const prevButton = __alloc(NSButton).init();
prevButton.setTitle_(jsString('◀'));
prevButton.setBezelStyle_(NSBezelStyle.NSBezelStyleRounded);

const nextButton = __alloc(NSButton).init();
nextButton.setTitle_(jsString('▶'));
nextButton.setBezelStyle_(NSBezelStyle.NSBezelStyleRounded);

const pageLabel = __alloc(NSTextField).init();
pageLabel.setFont_(NSFont.systemFontOfSize_(13));
pageLabel.setEditable_(false);
pageLabel.setSelectable_(false);
pageLabel.setBezeled_(false);
pageLabel.setDrawsBackground_(false);

// A module-level const, not block-scoped: NSControl.target/action and NSNotificationCenter
// observers are all weakly referenced, so a live JS reference for the process lifetime is what
// keeps this instance alive (the rule every prior ladder app's own controller relies on).
const controller = new PdfController(pdfView, prevButton, nextButton, pageLabel);

openButton.setTarget_(controller);
openButton.setAction_('openDocument:');
prevButton.setTarget_(controller);
prevButton.setAction_('goPrev:');
nextButton.setTarget_(controller);
nextButton.setAction_('goNext:');

const toolbar = __alloc(NSStackView).init();
toolbar.setFrame_(rect(12, 500, 696, 32));
toolbar.setOrientation_(NSUserInterfaceLayoutOrientation.NSUserInterfaceLayoutOrientationHorizontal);
toolbar.setAlignment_(NSLayoutAttribute.NSLayoutAttributeFirstBaseline);
toolbar.setSpacing_(8);
toolbar.addArrangedSubview_(openButton);
toolbar.addArrangedSubview_(prevButton);
toolbar.addArrangedSubview_(nextButton);
toolbar.addArrangedSubview_(pageLabel);
toolbar.setAutoresizingMask_(
  NSAutoresizingMaskOptions.NSViewWidthSizable | NSAutoresizingMaskOptions.NSViewMinYMargin,
);
content.addSubview_(toolbar);

// The notification observer (spec §7.3) — registered once during setup, before the run loop, so
// it is live for the first page turn; never unregistered (app-lifetime registration).
NSNotificationCenter.defaultCenter().addObserver_selector_name_object_(
  controller,
  'pageChanged:',
  PDFViewPageChangedNotification,
  pdfView,
);

// AW_PKV_SMOKE=1 (the host construction pre-flight, matching hello-window's AW_HELLO_SMOKE
// convention): every FFI crossing above must still succeed, but skip actually showing the
// window — the launcher (embed_main.mm) does not enter `[NSApp run]` in this mode either.
if (!process.env.AW_PKV_SMOKE) {
  window.makeKeyAndOrderFront_(app);
  app.activate();
  console.log('PDFKit Viewer opened. Open a .pdf, navigate with ◀/▶. Quit with Cmd-Q.');
}
