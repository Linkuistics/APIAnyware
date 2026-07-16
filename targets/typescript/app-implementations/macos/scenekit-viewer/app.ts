// scenekit-viewer — the Node TypeScript target's SceneKit-viewer sample app (ladder rung 3/7): a
// 640×480 window with a toolbar (geometry picker + colour button) over an SCNView showing a lit,
// continuously spinning geometry the user swaps and recolours via the shared NSColorPanel.
// Mirrors the racket/chez/gerbil/sbcl `scenekit-viewer` apps
// (`apps/macos/scenekit-viewer/docs/spec.md`).
//
// Loaded by bootstrap.cjs strictly AFTER the dispatch backend is installed — see hello-window's
// app.ts for why (an ES module's static imports evaluate before anything else in the importing
// file runs, so every generated class's own `static { __registerClass(...) }` needs a live
// dispatch backend at import time).
//
// Does NOT call `NSApplication.run()`: the native launcher (embed_main.mm) owns `main()` and
// calls `[NSApp run]` itself, AFTER this module finishes (ADR-0056), same as hello-window.
//
// First app in this ladder with THREE distinct target-action wirings routed to one handler
// object (spec §10's rule) — the picker's `geometryChanged:`, the colour button's `openColor:`,
// and the shared colour panel's `colorChanged:` (wired at runtime, on every activation, in
// continuous mode) — built on the same `__subclassAlloc`/`__bindSubclass` primitives
// ui-controls-gallery's `GalleryController` already proved end-to-end for a single selector.
//
// Colour persistence (spec §7, the app's load-bearing behaviour): SceneKit hands every new
// geometry a FRESH default material, so the current colour is held as controller state and
// RE-APPLIED after every swap (§7.2) — never read back from the view.

import {
  NSApplication,
  NSApplicationActivationPolicy,
  NSAutoresizingMaskOptions,
  NSBackingStoreType,
  NSBezelStyle,
  NSButton,
  NSColor,
  NSColorPanel,
  NSColorSpace,
  NSMenu,
  NSMenuItem,
  NSPopUpButton,
  NSStackView,
  NSUserInterfaceLayoutOrientation,
  NSWindow,
  NSWindowStyleMask,
} from '@apianyware/appkit';
import { NSDictionary, NSString } from '@apianyware/foundation';
import {
  SCNAction,
  SCNBox,
  SCNCylinder,
  SCNNode,
  SCNScene,
  SCNSphere,
  SCNTorus,
  SCNView,
} from '@apianyware/scenekit';
import type { SCNGeometry } from '@apianyware/scenekit';
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

// ── The geometry catalogue (spec §6) — a pure index -> geometry mapping, shared by the initial
// construction and every swap. Any index outside 0–3 (including popup's -1 "no selection") falls
// through to the cube — the spec's own defensive default, unreachable through the four-item
// picker. ─────────────────────────────────────────────────────────────────────────────────────
function makeGeometry(index: number): SCNGeometry {
  switch (index) {
    case 1:
      return SCNSphere.sphereWithRadius_(1.2);
    case 2:
      return SCNTorus.torusWithRingRadius_pipeRadius_(1.0, 0.35);
    case 3:
      return SCNCylinder.cylinderWithRadius_height_(1.0, 2.0);
    default:
      return SCNBox.boxWithWidth_height_length_chamferRadius_(2.0, 2.0, 2.0, 0.1);
  }
}

// ── The apply rule (spec §7.2), single write-path to the material: node -> geometry ->
// firstMaterial -> diffuse -> contents, every step nil-guarded (a freshly built node/geometry
// always carries these in practice, but the emitted return types assert non-null even where the
// real ObjC call can hand back nil — see learnings.md). ─────────────────────────────────────────
function applyColor(node: SCNNode, color: NSColor): void {
  const geometry = node.geometry();
  if (!geometry) return;
  const material = geometry.firstMaterial();
  if (!material) return;
  const diffuse = material.diffuse();
  if (!diffuse) return;
  diffuse.setContents_(color);
}

// ── The target-action handler (spec §10: one app-side object owns all three actions). Built
// directly on the raw `__subclassAlloc`/`__bindSubclass` primitives, as ui-controls-gallery's
// `GalleryController` — the same shape, now wiring three selectors instead of one. ─────────────
const NSOBJECT_CLASS = __class('NSObject');
const SCENE_CONTROLLER_METHODS: readonly SubclassOverride[] = [
  ['geometryChanged:', 'v@:@'],
  ['openColor:', 'v@:@'],
  ['colorChanged:', 'v@:@'],
];

class SceneController extends NSObject {
  private readonly node: SCNNode;
  private readonly picker: NSPopUpButton;
  private readonly app: NSApplication;
  private currentColor: NSColor;

  constructor(node: SCNNode, picker: NSPopUpButton, app: NSApplication, initialColor: NSColor) {
    super(__subclassAlloc(SceneController, NSOBJECT_CLASS, SCENE_CONTROLLER_METHODS));
    __bindSubclass(this);
    this.node = node;
    this.picker = picker;
    this.app = app;
    this.currentColor = initialColor;
  }

  // The picker's action: read the selection, build+assign its geometry, then re-apply the
  // current colour (§7.2 — a fresh geometry means a fresh, uncoloured firstMaterial). Nothing
  // else — no action, camera, or scene manipulation.
  geometryChanged_(_sender: bigint): void {
    this.node.setGeometry_(makeGeometry(this.picker.indexOfSelectedItem()));
    applyColor(this.node, this.currentColor);
  }

  // The colour button's action (§7.3): (re)wire the shared panel to this controller in
  // continuous mode and show it — rewired on EVERY activation, matching every implementation.
  openColor_(_sender: bigint): void {
    const panel = NSColorPanel.sharedColorPanel();
    panel.setTarget_(this);
    panel.setAction_('colorChanged:');
    panel.setContinuous_(true);
    panel.makeKeyAndOrderFront_(this.app);
  }

  // The panel's action (§7.4): read the panel's colour, normalise to device RGB, and on success
  // store + apply it. A nil colour or a failed conversion is a silent keep-previous no-op — the
  // boundary spec §7.4 leaves unspecified beyond "no crash, no state change".
  colorChanged_(_sender: bigint): void {
    const panel = NSColorPanel.sharedColorPanel();
    const raw = panel.color();
    if (!raw) return;
    const converted = raw.colorUsingColorSpace_(NSColorSpace.deviceRGBColorSpace());
    if (!converted) return;
    this.currentColor = converted;
    applyColor(this.node, this.currentColor);
  }
}

// ── App menu (Quit -> -[NSApplication terminate:]), as hello-window/ui-controls-gallery. ────────
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
installAppMenu(app, 'SceneKit Viewer');

const window = __alloc(NSWindow).initWithContentRect_styleMask_backing_defer_(
  rect(0, 0, 640, 480),
  NSWindowStyleMask.NSWindowStyleMaskTitled |
    NSWindowStyleMask.NSWindowStyleMaskClosable |
    NSWindowStyleMask.NSWindowStyleMaskMiniaturizable |
    NSWindowStyleMask.NSWindowStyleMaskResizable,
  NSBackingStoreType.NSBackingStoreBuffered,
  false,
);
window.setTitle_(jsString('SceneKit Viewer'));
window.center();
window.setMinSize_({ width: 480, height: 360 });

const content = window.contentView();

// SCNView: fills everything below the toolbar band, camera control + default lighting on, dark
// grey backdrop, resizes with the window in both dimensions (spec §5.2). `initWithFrame:options:`
// is SCNView's OWN designated initializer (unlike NSView's plain `initWithFrame:`, which SCNView
// does not override) — an empty options dictionary stands in for Apple's nil-options convention
// (no emitted signature in this corpus is nullable at an object parameter yet; see learnings.md).
const scnView = __alloc(SCNView).initWithFrame_options_(rect(0, 0, 640, 432), __alloc(NSDictionary).init());
scnView.setAutoresizingMask_(
  NSAutoresizingMaskOptions.NSViewWidthSizable | NSAutoresizingMaskOptions.NSViewHeightSizable,
);
scnView.setAllowsCameraControl_(true);
scnView.setAutoenablesDefaultLighting_(true); // SCNSceneRenderer protocol
scnView.setBackgroundColor_(NSColor.darkGrayColor());
content.addSubview_(scnView);

// Scene + the one geometry node (spec §6): built at the root, never positioned, spun forever —
// replacing node.geometry does not cancel actions on the node, so the spin survives every swap.
const scene = SCNScene.scene();
scnView.setScene_(scene);
const geometryNode = SCNNode.nodeWithGeometry_(makeGeometry(0));
scene.rootNode().addChildNode_(geometryNode);
const initialColor = NSColor.systemRedColor();
applyColor(geometryNode, initialColor);
geometryNode.runAction_(SCNAction.repeatActionForever_(SCNAction.rotateByX_y_z_duration_(0, 1.5, 0, 4.0)));

// Toolbar: geometry picker + colour button in a horizontal stack, pinned to the top edge (spec
// §5.1). Individual control frames passed at construction are stack arrangement details, not
// part of the contract — the stack view repositions its arranged subviews itself.
const picker = __alloc(NSPopUpButton).initWithFrame_pullsDown_(rect(0, 0, 150, 26), false);
picker.addItemWithTitle_(jsString('Cube'));
picker.addItemWithTitle_(jsString('Sphere'));
picker.addItemWithTitle_(jsString('Torus'));
picker.addItemWithTitle_(jsString('Cylinder'));

// A module-level const, not block-scoped: NSControl.target/action are non-retaining (weak)
// properties (ui-controls-gallery's GalleryController finding), so a live JS reference for the
// process lifetime is what keeps this instance alive.
const sceneController = new SceneController(geometryNode, picker, app, initialColor);
picker.setTarget_(sceneController);
picker.setAction_('geometryChanged:');

const colorButton = NSButton.buttonWithTitle_target_action_(jsString('Colour…'), sceneController, 'openColor:');
colorButton.setBezelStyle_(NSBezelStyle.NSBezelStyleRounded);

const toolbar = __alloc(NSStackView).init();
toolbar.setFrame_(rect(12, 440, 616, 32));
toolbar.setOrientation_(NSUserInterfaceLayoutOrientation.NSUserInterfaceLayoutOrientationHorizontal);
toolbar.setSpacing_(8);
toolbar.addArrangedSubview_(picker);
toolbar.addArrangedSubview_(colorButton);
toolbar.setAutoresizingMask_(
  NSAutoresizingMaskOptions.NSViewWidthSizable | NSAutoresizingMaskOptions.NSViewMinYMargin,
);
content.addSubview_(toolbar);

// AW_SKV_SMOKE=1 (the host construction pre-flight, matching hello-window's AW_HELLO_SMOKE
// convention): every FFI crossing above must still succeed, but skip actually showing the
// window — the launcher (embed_main.mm) does not enter `[NSApp run]` in this mode either.
if (!process.env.AW_SKV_SMOKE) {
  window.makeKeyAndOrderFront_(app);
  app.activate();
  console.log('SceneKit Viewer opened. Quit with Cmd-Q.');
}
