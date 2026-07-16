// note-editor — the Node TypeScript target's Note Editor sample app (ladder rung 6/7, the
// capstone-adjacent widest feature surface so far): a 900×600 window split side-by-side into a
// plain-text Markdown editor (NSTextView in an NSScrollView) and a live HTML preview (WKWebView),
// with a New/Open…/Save…/Undo/Redo toolbar + status line. A single-document model (current path +
// dirty flag) drives the window title and the document-edited indicator. Save uses an NSSavePanel
// sheet with an async completion handler on first save, then direct-overwrites; Open uses a modal
// NSOpenPanel; New/Open guard unsaved changes with a warning alert; Undo/Redo drive the text
// view's own NSUndoManager. Mirrors the racket/chez/gerbil/sbcl `note-editor` apps
// (`apps/macos/note-editor/docs/spec.md`).
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
// FIRST app in this ladder to exercise NSTextView/NSSplitView/NSScrollView, NSUndoManager, an
// NSSavePanel SHEET (vs. pdfkit-viewer's modal NSOpenPanel only), and Node's own `fs` for file
// I/O (spec §8 — reading/writing the document is deliberately NOT a Cocoa call; the panels are
// the platform surface under test, the bytes are not). The Save sheet's completion handler is
// already unblocked by block-call-site-emission-k120: `NSSavePanel.beginSheetModalForWindow_
// completionHandler_` has a real generated call site (`handler: (...args: any[]) => unknown`,
// dispatched via `__makeEscapingBlock`) — used directly below, one JS closure, no ceremony.
// Undo/Redo are unblocked by text-undo-surface-gap-k121's general fix (category methods now
// merge into `Class::methods` at extraction): `NSTextView.allowsUndo`/`setAllowsUndo_` and
// `NSResponder.undoManager` are both real generated call sites, verified end-to-end
// (`native/test/undo-manager.mjs`).
//
// One controller object carries SIX selectors in two roles — five toolbar target-actions
// (newDoc:/openDoc:/saveDoc:/undoDoc:/redoDoc:) plus one NSTextDidChangeNotification observer
// (textDidChange:) — matching every reference implementation's own shape (spec §12) and
// generalizing pdfkit-viewer's four-selector controller (three target-actions + one
// notification) by two more target-actions.
//
// The Markdown→HTML renderer (spec §7) is pure TypeScript, ported line-for-line from the
// racket/chez/gerbil/sbcl rule set (no regex, line-oriented block rules + ordered inline rules).

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
  NSOpenPanel,
  NSSavePanel,
  NSScrollView,
  NSSplitView,
  NSStackView,
  NSTextField,
  NSTextView,
  NSUserInterfaceLayoutOrientation,
  NSWindow,
  NSWindowStyleMask,
} from '@apianyware/appkit';
import { NSTextDidChangeNotification } from '@apianyware/appkit';
import { NSMutableArray, NSNotificationCenter, NSString, NSURL } from '@apianyware/foundation';
import type { NSUndoManager } from '@apianyware/foundation';
import { WKWebView } from '@apianyware/webkit';
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
import { readFileSync, writeFileSync } from 'node:fs';

function jsString(s: string): NSString {
  return __wrapOwned(NSString, __cfstr(s))!;
}

function rect(x: number, y: number, w: number, h: number): CGRect {
  return { origin: { x, y }, size: { width: w, height: h } };
}

// NSString has no bulk-read selector in this corpus — build a JS string from `length()` +
// `characterAtIndex_` (mini-browser's own helper, ported verbatim). This app's own strings are
// file paths and the editor's full text — the learnings.md note flags this per-character-crossing
// cost for a long document as a future reconsideration point if a live VM run shows it as a real
// bottleneck; not a blocker to work around ahead of time.
function nsToString(s: NSString): string {
  const n = s.length();
  let out = '';
  for (let i = 0; i < n; i++) out += String.fromCharCode(s.characterAtIndex_(i));
  return out;
}

function basename(path: string): string {
  const slash = path.lastIndexOf('/');
  return slash === -1 ? path : path.slice(slash + 1);
}

// NSModalResponseOK / NSAlertFirstButtonReturn are hand-defined in every reference
// implementation — absent from the generated AppKit enums (spec §11.1).
const NS_MODAL_RESPONSE_OK = 1;
const NS_ALERT_FIRST_BUTTON_RETURN = 1000;

// ── Markdown → HTML (spec §7) — pure TypeScript, no regex; a faithful, deliberately small
// line-oriented block-rule pass + an ordered inline-rule pass, ported from the racket/chez/
// gerbil/sbcl renderer. ──────────────────────────────────────────────────────────────────────
function htmlEscape(text: string): string {
  let out = '';
  for (const c of text) {
    if (c === '&') out += '&amp;';
    else if (c === '<') out += '&lt;';
    else if (c === '>') out += '&gt;';
    else out += c;
  }
  return out;
}

// Replace every `open<content>close` run (content = a maximal non-empty span not containing
// `forbidden`), wrapping the content via `wrap`. Unbalanced delimiters pass through literally
// (spec §7.3).
function replaceDelimited(s: string, delim: string, forbidden: string, wrap: (content: string) => string): string {
  let out = '';
  let i = 0;
  const n = s.length;
  const dl = delim.length;
  while (i < n) {
    if (s.startsWith(delim, i)) {
      let k = i + dl;
      while (k < n && s[k] !== forbidden) k++;
      if (k > i + dl && s.startsWith(delim, k)) {
        out += wrap(s.slice(i + dl, k));
        i = k + dl;
        continue;
      }
    }
    out += s[i];
    i++;
  }
  return out;
}

function renderInline(text: string): string {
  const escaped = htmlEscape(text);
  const withCode = replaceDelimited(escaped, '`', '`', (c) => `<code>${c}</code>`);
  const withStrong = replaceDelimited(withCode, '**', '*', (c) => `<strong>${c}</strong>`);
  const withEm = replaceDelimited(withStrong, '*', '*', (c) => `<em>${c}</em>`);
  return withEm;
}

function isBlank(line: string): boolean {
  return line.trim() === '';
}

function fenceLine(line: string): boolean {
  return line.startsWith('```');
}

function fenceClose(line: string): boolean {
  return fenceLine(line) && line.slice(3).trim() === '';
}

// ATX heading: 1–6 `#`, then whitespace, then text → [level, text]; else null (spec §7.2.3).
function headingMatch(line: string): [number, string] | null {
  let i = 0;
  while (i < line.length && line[i] === '#') i++;
  if (i < 1 || i > 6 || i >= line.length || !/[ \t]/.test(line[i])) return null;
  let j = i;
  while (j < line.length && /[ \t]/.test(line[j])) j++;
  return [i, line.slice(j)];
}

// Unordered list item: -/*/+ then whitespace then text → text; else null (spec §7.2.4).
function listItemMatch(line: string): string | null {
  if (line.length < 2) return null;
  if (!'-*+'.includes(line[0]) || !/[ \t]/.test(line[1])) return null;
  let j = 1;
  while (j < line.length && /[ \t]/.test(line[j])) j++;
  return line.slice(j);
}

function renderMarkdown(source: string): string {
  let out = '';
  let inFence = false;
  let inList = false;
  const closeList = () => {
    if (inList) {
      out += '</ul>\n';
      inList = false;
    }
  };
  for (const line of source.split('\n')) {
    if (inFence) {
      if (fenceClose(line)) {
        out += '</code></pre>\n';
        inFence = false;
      } else {
        out += `${htmlEscape(line)}\n`;
      }
      continue;
    }
    if (fenceLine(line)) {
      closeList();
      out += '<pre><code>';
      inFence = true;
      continue;
    }
    const heading = headingMatch(line);
    if (heading) {
      closeList();
      const [level, text] = heading;
      out += `<h${level}>${renderInline(text)}</h${level}>\n`;
      continue;
    }
    const item = listItemMatch(line);
    if (item !== null) {
      if (!inList) {
        out += '<ul>\n';
        inList = true;
      }
      out += `<li>${renderInline(item)}</li>\n`;
      continue;
    }
    if (isBlank(line)) {
      closeList();
      out += '\n';
      continue;
    }
    closeList();
    out += `<p>${renderInline(line)}</p>\n`;
  }
  closeList();
  if (inFence) out += '</code></pre>\n';
  return out;
}

const PREVIEW_TEMPLATE_HEAD =
  '<!DOCTYPE html><html><head><meta charset="utf-8">' +
  '<style>' +
  'body{font-family:-apple-system,BlinkMacSystemFont,sans-serif;' +
  'padding:16px;line-height:1.5;color:#222}' +
  'h1,h2,h3{margin-top:0.8em;margin-bottom:0.4em}' +
  'code{background:#f4f4f4;padding:1px 4px;border-radius:3px;' +
  'font-family:ui-monospace,SFMono-Regular,Menlo,monospace}' +
  'pre{background:#f4f4f4;padding:12px;border-radius:6px;overflow:auto}' +
  'pre code{background:none;padding:0}' +
  '.placeholder{color:#888;font-style:italic}' +
  '</style></head><body>';
const PREVIEW_TEMPLATE_FOOT = '</body></html>';
const PREVIEW_PLACEHOLDER = '<p class="placeholder">Start typing Markdown on the left…</p>';

// WKWebView.loadHTMLString_baseURL_'s `baseURL:` is header-nullable (`nullable NSURL *`) but the
// emitted param type is plain NSURL — nullability not plumbed for this slot (a known corpus gap,
// distinct from the triaged corpus-typecheck-gate residuals). Construct the null instance
// directly rather than fight the type: `__wrapOwned` returns null for a 0n handle by construction
// (lifetime.ts), and `!` only asserts the TS type — the runtime value stays genuinely null, which
// is exactly what `__unwrap` turns back into the nil pointer this call needs (spec §5.4 — the
// preview never navigates, so there is no base URL to give it).
const NIL_URL = __wrapOwned(NSURL, 0n)!;

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

// ── The controller (spec §12 — "handler-object granularity is a realization, its role a rule"):
// one object, six selectors, two roles — five toolbar target-actions + the text-change observer.
// Built on the same `__subclassAlloc`/`__bindSubclass` primitives every earlier ladder app used.
// Document state (current path + dirty flag) lives in plain instance fields. ────────────────────
const NSOBJECT_CLASS = __class('NSObject');
const NOTE_CONTROLLER_METHODS: readonly SubclassOverride[] = [
  ['newDoc:', 'v@:@'],
  ['openDoc:', 'v@:@'],
  ['saveDoc:', 'v@:@'],
  ['undoDoc:', 'v@:@'],
  ['redoDoc:', 'v@:@'],
  ['textDidChange:', 'v@:@'],
];

class NoteController extends NSObject {
  private readonly window: NSWindow;
  private readonly textView: NSTextView;
  private readonly webView: WKWebView;
  private readonly statusLabel: NSTextField;
  private currentPath: string | null = null;
  private dirty = false;

  constructor(window: NSWindow, textView: NSTextView, webView: WKWebView, statusLabel: NSTextField) {
    super(__subclassAlloc(NoteController, NSOBJECT_CLASS, NOTE_CONTROLLER_METHODS));
    __bindSubclass(this);
    this.window = window;
    this.textView = textView;
    this.webView = webView;
    this.statusLabel = statusLabel;
    this.renderPreview(''); // spec §3 step 5 — the initial (empty) placeholder render.
    this.refreshTitle(); // spec §3 step 6 — "Untitled — Note Editor", dirty indicator off.
  }

  // The title rule (spec §6.1) — single source of truth for the title + the close-box dirty dot,
  // re-run on every state transition.
  private displayName(): string {
    return this.currentPath ? basename(this.currentPath) : 'Untitled';
  }

  private refreshTitle(): void {
    const name = this.displayName();
    const title = this.dirty ? `${name} — edited — Note Editor` : `${name} — Note Editor`;
    this.window.setTitle_(jsString(title));
    this.window.setDocumentEdited_(this.dirty);
  }

  private setStatus(text: string): void {
    this.statusLabel.setStringValue_(jsString(text));
  }

  private currentEditorText(): string {
    return nsToString(this.textView.string());
  }

  // The live preview (spec §7) — the placeholder when blank, else the rendered Markdown, always
  // the FULL current text (re-rendered whole, never patched).
  private renderPreview(markdown: string): void {
    const body = markdown.trim() === '' ? PREVIEW_PLACEHOLDER : renderMarkdown(markdown);
    this.webView.loadHTMLString_baseURL_(jsString(PREVIEW_TEMPLATE_HEAD + body + PREVIEW_TEMPLATE_FOOT), NIL_URL);
  }

  private refreshPreview(): void {
    this.renderPreview(this.currentEditorText());
  }

  // File I/O (spec §8) — deliberately Node's own `fs`, never a Cocoa selector; the panels below
  // are the platform surface under test, the bytes are not.
  private loadFile(path: string): void {
    try {
      const text = readFileSync(path, 'utf8');
      this.textView.setString_(jsString(text));
      this.currentPath = path;
      this.dirty = false;
      this.refreshTitle();
      this.refreshPreview();
      this.setStatus(`Opened ${path}`);
    } catch {
      // §8.5.6 — editor text, path, and dirty flag stay untouched on a failed read.
      this.setStatus(`Open failed: ${path}`);
    }
  }

  private writeCurrentFile(path: string): void {
    try {
      writeFileSync(path, this.currentEditorText(), 'utf8');
      this.currentPath = path;
      this.dirty = false;
      this.refreshTitle();
      this.setStatus(`Saved ${path}`);
      // The preview is NOT re-rendered here (spec §8.4) — the text did not change.
    } catch {
      // §8.5.7 — path and dirty flag stay untouched on a failed write (the dirty title persists).
      this.setStatus(`Save failed: ${path}`);
    }
  }

  // The unsaved-changes confirmation (spec §8.1) — New and Open only. A clean document skips the
  // alert entirely.
  private confirmDiscard(message: string): boolean {
    if (!this.dirty) return true;
    const alert = __alloc(NSAlert).init();
    alert.setAlertStyle_(NSAlertStyle.NSAlertStyleWarning);
    alert.setMessageText_(jsString(message));
    alert.setInformativeText_(jsString('Your changes will be lost if you continue.'));
    alert.addButtonWithTitle_(jsString('Discard')); // added first — the default button (Return).
    alert.addButtonWithTitle_(jsString('Cancel'));
    return alert.runModal() === NS_ALERT_FIRST_BUTTON_RETURN;
  }

  // Save (spec §8.4) — a path already set: direct overwrite, no panel. No path: the sheet below.
  private promptSave(): void {
    const panel = NSSavePanel.savePanel();
    panel.setCanCreateDirectories_(true);
    panel.setNameFieldStringValue_(jsString('untitled.md')); // only reachable when no path is set.
    // The async completion handler (ADR-0059 §2/§5, block-call-site-emission-k120's carve-out) —
    // re-enters this closure whenever the user dismisses the sheet, possibly off thread 0.
    panel.beginSheetModalForWindow_completionHandler_(this.window, (response: unknown) => {
      if (Number(response) !== NS_MODAL_RESPONSE_OK) return; // boundary — Cancel: no state change.
      const url = panel.URL();
      if (!url) return; // boundary — nil URL.
      const path = nsToString(url.path());
      if (path === '') return; // boundary — empty path.
      this.writeCurrentFile(path);
    });
  }

  private doSave(): void {
    if (this.currentPath) this.writeCurrentFile(this.currentPath);
    else this.promptSave();
  }

  // Open (spec §8.3) — a MODAL NSOpenPanel, deliberately contrasting with Save's sheet.
  private doOpen(): void {
    if (!this.confirmDiscard('Discard unsaved changes?')) return;
    const panel = NSOpenPanel.openPanel();
    panel.setCanChooseFiles_(true);
    panel.setCanChooseDirectories_(false);
    panel.setAllowsMultipleSelection_(false);
    const extensions = __alloc(NSMutableArray).initWithCapacity_(3);
    for (const ext of ['md', 'markdown', 'txt']) extensions.addObject_(jsString(ext));
    panel.setAllowedFileTypes_(extensions);
    if (panel.runModal() !== NS_MODAL_RESPONSE_OK) return; // boundary — Cancel: no state change.
    const url = panel.URL();
    if (!url) return; // boundary — nil URL.
    this.loadFile(nsToString(url.path()));
  }

  // New (spec §8.2).
  private doNew(): void {
    if (!this.confirmDiscard('Discard unsaved changes and start a new note?')) return;
    this.textView.setString_(jsString(''));
    this.currentPath = null;
    this.dirty = false;
    this.refreshTitle();
    this.refreshPreview();
    this.setStatus('New document');
  }

  // Undo/Redo (spec §9) — drive the text view's own undo manager; the app keeps no edit history
  // of its own. `undoManager()` is generated non-null but the real call can hand back nil (an
  // orphan text view with no window has nowhere to resolve the responder chain to) — guarded.
  private doUndo(): void {
    const mgr: NSUndoManager | null = this.textView.undoManager();
    if (mgr && mgr.canUndo()) mgr.undo();
  }

  private doRedo(): void {
    const mgr: NSUndoManager | null = this.textView.undoManager();
    if (mgr && mgr.canRedo()) mgr.redo();
  }

  // ── Toolbar target-actions (synthesized default v@:@; sender ignored throughout). ────────────
  newDoc_(_sender: bigint): void {
    this.doNew();
  }

  openDoc_(_sender: bigint): void {
    this.doOpen();
  }

  saveDoc_(_sender: bigint): void {
    this.doSave();
  }

  undoDoc_(_sender: bigint): void {
    this.doUndo();
  }

  redoDoc_(_sender: bigint): void {
    this.doRedo();
  }

  // NSTextDidChangeNotification observer (spec §6.2) — fires on every user edit. The clean→dirty
  // flip happens at most once per clean spell; the preview re-renders on EVERY notification.
  textDidChange_(_note: bigint): void {
    if (!this.dirty) {
      this.dirty = true;
      this.refreshTitle();
    }
    this.refreshPreview();
  }
}

// ── Assemble the window (spec §4/§5) ─────────────────────────────────────────────────────────
const WINDOW_W = 900;
const WINDOW_H = 600;
const MARGIN = 12;
const TOOLBAR_H = 32;
const TOOLBAR_Y = WINDOW_H - MARGIN - TOOLBAR_H;
const SPLIT_Y = MARGIN;
const SPLIT_H = TOOLBAR_Y - SPLIT_Y - MARGIN;
const SPLIT_W = WINDOW_W - 2 * MARGIN;
const EDITOR_W = Math.floor(SPLIT_W / 2);
const PREVIEW_W = SPLIT_W - EDITOR_W;

const app = NSApplication.sharedApplication();
app.setActivationPolicy_(NSApplicationActivationPolicy.NSApplicationActivationPolicyRegular);
installAppMenu(app, 'Note Editor');

const window = __alloc(NSWindow).initWithContentRect_styleMask_backing_defer_(
  rect(0, 0, WINDOW_W, WINDOW_H),
  NSWindowStyleMask.NSWindowStyleMaskTitled |
    NSWindowStyleMask.NSWindowStyleMaskClosable |
    NSWindowStyleMask.NSWindowStyleMaskMiniaturizable |
    NSWindowStyleMask.NSWindowStyleMaskResizable,
  NSBackingStoreType.NSBackingStoreBuffered,
  false,
);
window.center();
window.setMinSize_({ width: 520, height: 360 });

const content = window.contentView();

// Editor pane (left, spec §5.3): a plain-text Markdown NSTextView inside an NSScrollView.
const textView = __alloc(NSTextView).initWithFrame_(rect(0, 0, EDITOR_W, SPLIT_H));
textView.setEditable_(true);
textView.setRichText_(false);
textView.setAllowsUndo_(true);
textView.setUsesFindBar_(true);
textView.setFont_(NSFont.userFixedPitchFontOfSize_(13));
textView.setHorizontallyResizable_(false);
textView.setAutoresizingMask_(
  NSAutoresizingMaskOptions.NSViewWidthSizable | NSAutoresizingMaskOptions.NSViewHeightSizable,
);

const editorScroll = __alloc(NSScrollView).initWithFrame_(rect(0, 0, EDITOR_W, SPLIT_H));
editorScroll.setHasVerticalScroller_(true);
editorScroll.setHasHorizontalScroller_(false);
editorScroll.setDocumentView_(textView);

// Preview pane (right, spec §5.4): a WKWebView, `loadHTMLString:baseURL:` only — never navigates.
// `initWithFrame:` alone (no configuration), matching mini-browser's own simpler realization.
const webView = __alloc(WKWebView).initWithFrame_(rect(0, 0, PREVIEW_W, SPLIT_H));

// Split view (spec §5.2): vertical divider → side-by-side panes.
const splitView = __alloc(NSSplitView).init();
splitView.setFrame_(rect(MARGIN, SPLIT_Y, SPLIT_W, SPLIT_H));
splitView.setVertical_(true);
splitView.setAutoresizingMask_(
  NSAutoresizingMaskOptions.NSViewWidthSizable | NSAutoresizingMaskOptions.NSViewHeightSizable,
);
splitView.addSubview_(editorScroll);
splitView.addSubview_(webView);
content.addSubview_(splitView);

// Toolbar controls (spec §5.1) — built unwired, then wired to the controller once it exists.
const newButton = __alloc(NSButton).init();
newButton.setTitle_(jsString('New'));
newButton.setBezelStyle_(NSBezelStyle.NSBezelStyleRounded);

const openButton = __alloc(NSButton).init();
openButton.setTitle_(jsString('Open…'));
openButton.setBezelStyle_(NSBezelStyle.NSBezelStyleRounded);

const saveButton = __alloc(NSButton).init();
saveButton.setTitle_(jsString('Save…'));
saveButton.setBezelStyle_(NSBezelStyle.NSBezelStyleRounded);

const undoButton = __alloc(NSButton).init();
undoButton.setTitle_(jsString('Undo'));
undoButton.setBezelStyle_(NSBezelStyle.NSBezelStyleRounded);

const redoButton = __alloc(NSButton).init();
redoButton.setTitle_(jsString('Redo'));
redoButton.setBezelStyle_(NSBezelStyle.NSBezelStyleRounded);

const statusLabel = __alloc(NSTextField).init();
statusLabel.setStringValue_(jsString('Ready'));
statusLabel.setFont_(NSFont.systemFontOfSize_(11));
statusLabel.setEditable_(false);
statusLabel.setSelectable_(false);
statusLabel.setBezeled_(false);
statusLabel.setDrawsBackground_(false);

// A module-level const, not block-scoped: NSControl.target/action and NSNotificationCenter
// observers are all weakly referenced, so a live JS reference for the process lifetime is what
// keeps this instance alive (the rule every prior ladder app's own controller relies on) — the
// per-keystroke allocation load this app's own preview re-render carries makes this the app where
// getting that rule wrong would show up fastest (gerbil's own note-editor is where the equivalent
// bug first surfaced).
const controller = new NoteController(window, textView, webView, statusLabel);

newButton.setTarget_(controller);
newButton.setAction_('newDoc:');
openButton.setTarget_(controller);
openButton.setAction_('openDoc:');
saveButton.setTarget_(controller);
saveButton.setAction_('saveDoc:');
undoButton.setTarget_(controller);
undoButton.setAction_('undoDoc:');
redoButton.setTarget_(controller);
redoButton.setAction_('redoDoc:');

// The text-change observer (spec §6.2) — registered once, before the run loop; never
// unregistered (app-lifetime registration), source-filtered to the text view.
NSNotificationCenter.defaultCenter().addObserver_selector_name_object_(
  controller,
  'textDidChange:',
  NSTextDidChangeNotification,
  textView,
);

const toolbar = __alloc(NSStackView).init();
toolbar.setFrame_(rect(MARGIN, TOOLBAR_Y, SPLIT_W, TOOLBAR_H));
toolbar.setOrientation_(NSUserInterfaceLayoutOrientation.NSUserInterfaceLayoutOrientationHorizontal);
toolbar.setAlignment_(NSLayoutAttribute.NSLayoutAttributeFirstBaseline);
toolbar.setSpacing_(8);
toolbar.addArrangedSubview_(newButton);
toolbar.addArrangedSubview_(openButton);
toolbar.addArrangedSubview_(saveButton);
toolbar.addArrangedSubview_(undoButton);
toolbar.addArrangedSubview_(redoButton);
toolbar.addArrangedSubview_(statusLabel);
toolbar.setAutoresizingMask_(
  NSAutoresizingMaskOptions.NSViewWidthSizable | NSAutoresizingMaskOptions.NSViewMinYMargin,
);
content.addSubview_(toolbar);

// AW_NE_SMOKE=1 (the host construction pre-flight, matching hello-window's AW_HELLO_SMOKE
// convention): every FFI crossing above must still succeed, but skip actually showing the
// window — the launcher (embed_main.mm) does not enter `[NSApp run]` in this mode either.
if (!process.env.AW_NE_SMOKE) {
  window.makeKeyAndOrderFront_(app);
  app.activate();
  console.log('Note Editor opened. Type Markdown on the left; preview renders on the right. Quit with Cmd-Q.');
}
