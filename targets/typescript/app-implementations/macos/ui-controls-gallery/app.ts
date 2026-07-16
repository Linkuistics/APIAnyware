// ui-controls-gallery — the Node TypeScript target's broad-surface AppKit control roster
// (ladder rung 2/7): a single fixed-size window presenting the 14 control kinds
// `apps/macos/ui-controls-gallery/docs/spec.md` §6 requires, each configured per spec, grouped
// under bold section headers. Mirrors the racket/chez/gerbil/sbcl `ui-controls-gallery` apps.
//
// Loaded by bootstrap.cjs strictly AFTER the dispatch backend is installed — see hello-window's
// app.ts for why (an ES module's static imports evaluate before anything else in the importing
// file runs, so every generated class's own `static { __registerClass(...) }` needs a live
// dispatch backend at import time).
//
// Does NOT call `NSApplication.run()`: the native launcher (embed_main.mm) owns `main()` and
// calls `[NSApp run]` itself, AFTER this module finishes (ADR-0056), same as hello-window.
//
// Interactivity (spec §7): checkbox toggling and slider/stepper range clamping are native
// NSControl/NSButton behaviour needing no app-side callback — VM-verified directly. Radio
// mutual exclusion is NOT automatic for plain sibling NSButtons sharing a superview (measured
// in-VM: two radio-type buttons added to the same content view do NOT auto-exclude); it needs
// the explicit callback path spec §7 itself allows ("via an explicit selection callback that
// clears siblings and selects the sender") — `GalleryController` below, built on ADR-0059's
// subclass/target-action machinery (`__subclassAlloc`/`__bindSubclass`, proven end-to-end
// against the real addon by `native/test/super.mjs` §3). Every other control's target stays
// nil, matching the spec's own "no app-level handling" posture (§7's last bullet, §12).

import {
  NSApplication,
  NSApplicationActivationPolicy,
  NSBackingStoreType,
  NSBezelStyle,
  NSBox,
  NSBoxType,
  NSButton,
  NSButtonType,
  NSColor,
  NSColorWell,
  NSComboBox,
  NSDatePicker,
  NSDatePickerElementFlags,
  NSDatePickerStyle,
  NSFont,
  NSImage,
  NSImageScaling,
  NSImageView,
  NSMenu,
  NSMenuItem,
  NSPopUpButton,
  NSProgressIndicator,
  NSProgressIndicatorStyle,
  NSSecureTextField,
  NSSlider,
  NSStepper,
  NSTextAlignment,
  NSTextField,
  NSWindow,
  NSWindowStyleMask,
} from '@apianyware/appkit';
import type { NSView } from '@apianyware/appkit';
import { NSDate, NSString } from '@apianyware/foundation';
import {
  NSObject,
  __alloc,
  __bindSubclass,
  __cfstr,
  __class,
  __subclassAlloc,
  __unwrap,
  __wrapOwned,
} from '@apianyware/runtime';
import type { CGRect, SubclassOverride } from '@apianyware/runtime';

function jsString(s: string): NSString {
  return __wrapOwned(NSString, __cfstr(s))!;
}

function rect(x: number, y: number, w: number, h: number): CGRect {
  return { origin: { x, y }, size: { width: w, height: h } };
}

// ── Layout: a single-column, top-down stack. AppKit's content view is NOT flipped (origin
// bottom-left), so a control's ObjC y is `totalH - (top + h)` where TOP is its distance from the
// top edge — letting the helpers below lay rows out top-down while returning the next TOP. ────
const WINDOW_W = 480;
const WINDOW_H = 820;
const MARGIN = 20;
const CONTENT_W = WINDOW_W - 2 * MARGIN;
const LABEL_W = 130;
const CTRL_X = MARGIN + LABEL_W + 15;

function place(content: NSView, totalH: number, control: NSView, x: number, top: number, w: number, h: number): void {
  control.setFrame_(rect(x, totalH - (top + h), w, h));
  content.addSubview_(control);
}

function label(
  content: NSView,
  totalH: number,
  text: string,
  x: number,
  top: number,
  w: number,
  h: number,
  opts: { size?: number; align?: NSTextAlignment; bold?: boolean; color?: NSColor } = {},
): void {
  const field = __alloc(NSTextField).initWithFrame_(rect(x, totalH - (top + h), w, h));
  field.setStringValue_(jsString(text));
  const size = opts.size ?? 13;
  field.setFont_(opts.bold ? NSFont.boldSystemFontOfSize_(size) : NSFont.systemFontOfSize_(size));
  field.setAlignment_(opts.align ?? NSTextAlignment.NSTextAlignmentLeft);
  field.setEditable_(false);
  field.setSelectable_(false);
  field.setBezeled_(false);
  field.setDrawsBackground_(false);
  if (opts.color) field.setTextColor_(opts.color);
  content.addSubview_(field);
}

function header(content: NSView, totalH: number, top: number, text: string): number {
  label(content, totalH, text, MARGIN, top, CONTENT_W, 20, { size: 15, bold: true });
  const sep = __alloc(NSBox).init();
  sep.setBoxType_(NSBoxType.NSBoxSeparator);
  place(content, totalH, sep, MARGIN, top + 25, CONTENT_W, 1);
  return top + 38;
}

const CAPTION_COLOR = NSColor.secondaryLabelColor();

function row(content: NSView, totalH: number, top: number, caption: string, control: NSView, cw: number, ch: number): number {
  const rowH = Math.max(ch, 22);
  label(content, totalH, caption, MARGIN, top + Math.floor((rowH - 18) / 2), LABEL_W, 18, {
    align: NSTextAlignment.NSTextAlignmentRight,
    color: CAPTION_COLOR,
  });
  place(content, totalH, control, CTRL_X, top + Math.floor((rowH - ch) / 2), cw, ch);
  return top + rowH + 14;
}

// ── The control constructors (spec §6). Each returns a configured, un-framed control — `row`
// frames + adds it. No control is given a target/action (see the module doc above). ──────────

function mkPushButton(): NSButton {
  const b = __alloc(NSButton).init();
  b.setButtonType_(NSButtonType.NSButtonTypeMomentaryPushIn);
  b.setBezelStyle_(NSBezelStyle.NSBezelStylePush);
  b.setBordered_(true);
  b.setTitle_(jsString('Click Me'));
  return b;
}

function mkCheckbox(): NSButton {
  const b = __alloc(NSButton).init();
  b.setButtonType_(NSButtonType.NSButtonTypeSwitch);
  b.setTitle_(jsString('Enable Feature'));
  b.setState_(1);
  return b;
}

function mkRadio(title: string, on: boolean): NSButton {
  const b = __alloc(NSButton).init();
  b.setButtonType_(NSButtonType.NSButtonTypeRadio);
  b.setTitle_(jsString(title));
  b.setState_(on ? 1 : 0);
  return b;
}

function mkSlider(): NSSlider {
  const s = __alloc(NSSlider).init();
  s.setMinValue_(0);
  s.setMaxValue_(100);
  s.setDoubleValue_(50);
  return s;
}

function mkStepper(): NSStepper {
  const s = __alloc(NSStepper).init();
  s.setMinValue_(0);
  s.setMaxValue_(10);
  s.setIncrement_(1);
  s.setDoubleValue_(5);
  return s;
}

function mkProgressBar(): NSProgressIndicator {
  const p = __alloc(NSProgressIndicator).init();
  p.setStyle_(NSProgressIndicatorStyle.NSProgressIndicatorStyleBar);
  p.setIndeterminate_(false);
  p.setMinValue_(0);
  p.setMaxValue_(100);
  p.setDoubleValue_(65);
  return p;
}

function mkSpinner(): NSProgressIndicator {
  const p = __alloc(NSProgressIndicator).init();
  p.setStyle_(NSProgressIndicatorStyle.NSProgressIndicatorStyleSpinning);
  p.setIndeterminate_(true);
  return p; // startAnimation_ is called after it is in the view (below).
}

function mkPopup(): NSPopUpButton {
  const p = __alloc(NSPopUpButton).init();
  p.addItemWithTitle_(jsString('Small'));
  p.addItemWithTitle_(jsString('Medium'));
  p.addItemWithTitle_(jsString('Large'));
  p.selectItemAtIndex_(1);
  return p;
}

function mkCombo(): NSComboBox {
  const c = __alloc(NSComboBox).init();
  c.addItemWithObjectValue_(jsString('Small'));
  c.addItemWithObjectValue_(jsString('Medium'));
  c.addItemWithObjectValue_(jsString('Large'));
  c.setStringValue_(jsString('Medium'));
  return c;
}

function mkTextField(): NSTextField {
  const tf = __alloc(NSTextField).init(); // default: editable + bezeled, unlike the static labels
  tf.setPlaceholderString_(jsString('Type here...'));
  return tf;
}

function mkSecureField(): NSSecureTextField {
  const sf = __alloc(NSSecureTextField).init();
  sf.setPlaceholderString_(jsString('Password'));
  return sf;
}

function mkColorWell(): NSColorWell {
  const w = __alloc(NSColorWell).init();
  w.setColor_(NSColor.systemBlueColor());
  return w;
}

// NSDate carries no ObjC `+now`/`+date` class factory in the emitted TS surface (unlike sbcl's
// `ns:now`) — worth root-causing in a future leaf (see learnings.md). Computed here instead via
// the one instance init the emitted surface does carry, offset from the JS `Date.now()` clock by
// the fixed NSDate-reference-epoch-to-Unix-epoch constant (2001-01-01T00:00Z − 1970-01-01T00:00Z).
const REFERENCE_DATE_UNIX_EPOCH_OFFSET_SECONDS = 978307200;

function mkDatePicker(): NSDatePicker {
  const dp = __alloc(NSDatePicker).init();
  dp.setDatePickerStyle_(NSDatePickerStyle.NSDatePickerStyleTextFieldAndStepper);
  dp.setDatePickerElements_(NSDatePickerElementFlags.NSDatePickerElementFlagYearMonthDay);
  const nowSecondsSinceReference = Date.now() / 1000 - REFERENCE_DATE_UNIX_EPOCH_OFFSET_SECONDS;
  dp.setDateValue_(__alloc(NSDate).initWithTimeIntervalSinceReferenceDate_(nowSecondsSinceReference));
  return dp;
}

function mkImageView(): NSImageView {
  const img = NSImage.imageWithSystemSymbolName_accessibilityDescription_(
    jsString('star.fill'),
    jsString('star'),
  );
  const iv = NSImageView.imageViewWithImage_(img);
  iv.setImageScaling_(NSImageScaling.NSImageScaleProportionallyUpOrDown);
  iv.setContentTintColor_(NSColor.controlAccentColor());
  return iv;
}

// ── The radio group's explicit exclusion callback (spec §7) — see the module doc above for why
// this one control needs a real target-action wire while the rest of the roster does not. ──────
const NSOBJECT_CLASS = __class('NSObject');
const RADIO_CONTROLLER_METHODS: readonly SubclassOverride[] = [['selectRadio:', 'v@:@']];

class GalleryController extends NSObject {
  private readonly radios: NSButton[] = [];

  constructor() {
    super(__subclassAlloc(GalleryController, NSOBJECT_CLASS, RADIO_CONTROLLER_METHODS));
    __bindSubclass(this);
  }

  registerRadios(radios: readonly NSButton[]): void {
    this.radios.push(...radios);
  }

  selectRadio_(senderId: bigint): void {
    for (const radio of this.radios) radio.setState_(__unwrap(radio) === senderId ? 1 : 0);
  }
}

// ── App menu (Quit -> -[NSApplication terminate:]), as hello-window. ────────────────────────────
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

// ── Assemble the window ──────────────────────────────────────────────────────────────────────
const app = NSApplication.sharedApplication();
app.setActivationPolicy_(NSApplicationActivationPolicy.NSApplicationActivationPolicyRegular);
installAppMenu(app, 'UI Controls Gallery');

const window = __alloc(NSWindow).initWithContentRect_styleMask_backing_defer_(
  rect(0, 0, WINDOW_W, WINDOW_H),
  NSWindowStyleMask.NSWindowStyleMaskTitled |
    NSWindowStyleMask.NSWindowStyleMaskClosable |
    NSWindowStyleMask.NSWindowStyleMaskMiniaturizable,
  NSBackingStoreType.NSBackingStoreBuffered,
  false,
);
window.setTitle_(jsString('AppKit Controls — Node TypeScript'));
window.center();

const content = window.contentView();
let top = MARGIN;
const spinner = mkSpinner();
// A module-level const, not block-scoped: NSControl.target is a non-retaining (weak) property,
// so nothing native keeps this instance alive — a live JS reference for the process lifetime is
// what does (matching how `window`/`label` stay alive in hello-window's own app.ts).
const galleryController = new GalleryController();

top = header(content, WINDOW_H, top, 'Buttons & Toggles');
top = row(content, WINDOW_H, top, 'Push button', mkPushButton(), 120, 30);
top = row(content, WINDOW_H, top, 'Checkbox', mkCheckbox(), 170, 22);
{
  // The radio pair on one row (two controls, advance the cursor once) — wired to
  // GalleryController's explicit exclusion callback (see the module doc above).
  const rowH = 22;
  const capTop = top + Math.floor((rowH - 18) / 2);
  label(content, WINDOW_H, 'Radio group', MARGIN, capTop, LABEL_W, 18, {
    align: NSTextAlignment.NSTextAlignmentRight,
    color: CAPTION_COLOR,
  });
  const radioA = mkRadio('Option A', true);
  const radioB = mkRadio('Option B', false);
  galleryController.registerRadios([radioA, radioB]);
  for (const radio of [radioA, radioB]) {
    radio.setTarget_(galleryController);
    radio.setAction_('selectRadio:');
  }
  place(content, WINDOW_H, radioA, CTRL_X, top, 100, rowH);
  place(content, WINDOW_H, radioB, CTRL_X + 110, top, 100, rowH);
  top = top + rowH + 14;
}

top = header(content, WINDOW_H, top, 'Value Selectors');
top = row(content, WINDOW_H, top, 'Slider', mkSlider(), 200, 24);
top = row(content, WINDOW_H, top, 'Stepper', mkStepper(), 20, 28);
top = row(content, WINDOW_H, top, 'Progress', mkProgressBar(), 200, 16);
top = row(content, WINDOW_H, top, 'Spinner', spinner, 28, 28);

top = header(content, WINDOW_H, top, 'Pickers & Fields');
top = row(content, WINDOW_H, top, 'Pop-up', mkPopup(), 160, 26);
top = row(content, WINDOW_H, top, 'Combo box', mkCombo(), 160, 26);
top = row(content, WINDOW_H, top, 'Text field', mkTextField(), 200, 24);
top = row(content, WINDOW_H, top, 'Secure', mkSecureField(), 200, 24);
top = row(content, WINDOW_H, top, 'Colour well', mkColorWell(), 50, 26);
top = row(content, WINDOW_H, top, 'Date', mkDatePicker(), 180, 26);

top = header(content, WINDOW_H, top, 'Display');
top = row(content, WINDOW_H, top, 'SF Symbol', mkImageView(), 52, 52);

// AW_UCG_SMOKE=1 (the host construction pre-flight, matching hello-window's AW_HELLO_SMOKE
// convention): every FFI crossing above must still succeed, but skip actually showing the
// window — the launcher (embed_main.mm) does not enter `[NSApp run]` in this mode either.
if (!process.env.AW_UCG_SMOKE) {
  window.makeKeyAndOrderFront_(app);
  app.activate();
  spinner.startAnimation_(app); // spinner is now in the view tree
  console.log('Controls Gallery opened. Quit with Cmd-Q.');
}
