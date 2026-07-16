// Seam-honesty type test (compile-only; not run by vitest, not shipped in the build).
// It mirrors the FROZEN emit-typescript output shape (the goldens under
// tools/emit-typescript/tests/golden/) to prove the runtime's *types* satisfy every generated
// call site — the ADR-0011 seam is honest. `tsc --noEmit` (the `typecheck` script) enforces it.
//
// Exercises the object-model + lifetime surface (ADR-0055/0057) and the error-model call sites
// (Result / __result* / unwrap / __cfstr; ADR-0058). Foundation classes the goldens name
// (NSString, NSError) are stood in for by the local NSObject subclass — the point is that the
// runtime's *types* accept the generated shapes, not the specific class identities.

import {
  type CGPoint,
  type CGRect,
  CLS,
  type DelegateSpec,
  NSObject,
  type NSRange,
  OBJ,
  RAW,
  RET_OBJ,
  type Result,
  SEL,
  __blockMarshal,
  __cfstr,
  __class,
  __dispatch,
  __methodMarshal,
  __protocolAdopt,
  __protocolArg,
  __resultRetained,
  __resultScalar,
  __sel,
  __unwrap,
  __wrapOwned,
  __wrapRetained,
  unwrap,
} from './index.js';

// A hand-written mini "emitted class" — byte-shaped like tkobject.ts / tkview.ts.
class Widget extends NSObject {
  static readonly __cls: bigint = __class('Widget');

  static make(name: NSObject): Widget {
    // The FFI return is untyped; the emitted body passes it straight to __wrapRetained with
    // NO cast — this only compiles if __dispatch entries return an assignable-to-bigint type.
    const __ret = __dispatch.aw_ts_msg_P_P(Widget.__cls, __sel('make:'), __unwrap(name));
    return __wrapRetained(Widget, __ret) as Widget;
  }

  initWithParent_(parent: Widget): Widget | null {
    const __ret = __dispatch.aw_ts_msg_P_P(
      __unwrap(this),
      __sel('initWithParent:'),
      __unwrap(parent),
    );
    return __wrapOwned(Widget, __ret);
  }

  tag(): number {
    // any → number return, no cast (the emitter relies on this).
    return __dispatch.aw_ts_msg_0_q(__unwrap(this), __sel('tag'));
  }

  setTag_(tag: number): void {
    __dispatch.aw_ts_msg_q_v(__unwrap(this), __sel('setTag:'), tag);
  }

  parent(): Widget | null {
    const __ret = __dispatch.aw_ts_msg_0_P(__unwrap(this), __sel('parent'));
    return __wrapRetained(Widget, __ret);
  }

  // Fallible factory: an `…error:` selector drops the NSError** out-param and returns a
  // Result<T> — object primary through __resultRetained over the `…_e` entry (tkobject.ts golden).
  static openFile_error_(path: Widget): Result<Widget> {
    return __resultRetained(
      Widget,
      __dispatch.aw_ts_msg_P_P_e(Widget.__cls, __sel('openFile:error:'), __unwrap(path)),
    );
  }

  // Fallible BOOL writer: scalar primary through __resultScalar → Result<boolean> (tkobject.ts golden).
  writeToFile_error_(path: Widget): Result<boolean> {
    return __resultScalar(
      __dispatch.aw_ts_msg_P_b_e(__unwrap(this), __sel('writeToFile:error:'), __unwrap(path)),
    );
  }
}

// A fallible call site's two arms + the unwrap escalation (ADR-0058 §1/§3). The `ok` discriminant
// makes `value` unreachable on the failure arm and `error` unreachable on the success arm — the
// compiler forces the branch. The failure arm carries the runtime-root NSObject (layering, §1).
function consumesFallible(path: Widget): void {
  const r = Widget.openFile_error_(path);
  if (!r.ok) {
    const e: NSObject = r.error;
    void e;
    return;
  }
  const opened: Widget = r.value;
  void opened;
  const doc: Widget = unwrap(Widget.openFile_error_(path)); // escalate a failure to a throw
  void doc;
}

// A CFSTR-backed NSString constant (constants.ts golden): __cfstr yields a +1 owned id the
// caller takes ownership of via __wrapOwned. (The golden's non-null `!` is written `as` here —
// this package's lint forbids `!`, as elsewhere in this fixture; both narrow `Widget | null`.)
const Greeting: Widget = __wrapOwned(Widget, __cfstr('Hello, TestKit')) as Widget;

// Deterministic disposal via ES2024 `using` (ADR-0057 §1) — NSObject hosts [Symbol.dispose].
function drivesUsing(seed: Widget): void {
  using w = Widget.make(seed);
  w.setTag_(7);
  const t: number = w.tag();
  void t;
}

// A branded NSObject is not assignable to a subclass parameter, and vice-versa is fine.
function brandingHolds(o: NSObject, w: Widget): void {
  void __unwrap(o);
  const up: NSObject = w; // subclass → base: OK
  void up;
  // @ts-expect-error — a plain object with a matching dispose shape is NOT an NSObject (nominal brand, ADR-0055 §7)
  const fake: NSObject = { [Symbol.dispose]() {} };
  void fake;
}

// ── The POD geometry surface (ADR-0055 §5) ───────────────────────────────────────────────────
// A hand-written mini "emitted class" shaped like the generated nswindow.ts — the `hello-window`
// call site, which is the Step-7 blocker `pod-struct-types-k73` closes. A POD crosses by value:
// no wrap, no unwrap, no disposal — the object goes straight to the dispatch entry and comes
// straight back, so this only compiles if the runtime's POD types accept the raw `__dispatch`
// return with no cast.

class Window extends NSObject {
  static readonly __cls: bigint = __class('Window');

  static alloc(): Window {
    const __ret = __dispatch.aw_ts_msg_0_P(Window.__cls, __sel('alloc'));
    return __wrapOwned(Window, __ret) as Window;
  }

  initWithContentRect_styleMask_backing_defer_(
    contentRect: CGRect,
    style: number,
    backingStoreType: number,
    flag: boolean,
  ): Window | null {
    const __ret = __dispatch.aw_ts_msg_RQQB_P(
      __unwrap(this),
      __sel('initWithContentRect:styleMask:backing:defer:'),
      contentRect,
      style,
      backingStoreType,
      flag,
    );
    return __wrapOwned(Window, __ret);
  }

  frame(): CGRect {
    return __dispatch.aw_ts_msg_0_R(__unwrap(this), __sel('frame'));
  }

  setFrameOrigin_(point: CGPoint): void {
    __dispatch.aw_ts_msg_O_v(__unwrap(this), __sel('setFrameOrigin:'), point);
  }

  rangeOfTitle(): NSRange {
    return __dispatch.aw_ts_msg_0_G(__unwrap(this), __sel('rangeOfTitle'));
  }
}

// The hello-window call site: construct a nested CGRect literal, open a window, read its frame
// back, and pass the frame's `origin` **straight** to a CGPoint-taking method. That last line is
// the whole reason CGRect is nested rather than flat — `r.origin` IS a CGPoint, so the geometry
// composes with no hand-spreading (ADR-0055 §5).
function opensAWindow(): void {
  const contentRect: CGRect = { origin: { x: 0, y: 0 }, size: { width: 480, height: 320 } };
  const w = Window.alloc().initWithContentRect_styleMask_backing_defer_(contentRect, 15, 2, false);
  if (w === null) return;
  using win = w;

  const f: CGRect = win.frame();
  const width: number = f.size.width; // nested access, faithful to `struct CGRect`
  void width;
  win.setFrameOrigin_(f.origin); // CGPoint ← CGRect.origin, no spreading

  const r: NSRange = win.rangeOfTitle();
  const len: number = r.length;
  void len;
}

// The type surface is load-bearing, not decorative: a **flat** rect — the shape the addon used to
// marshal before this leaf reconciled it with ADR-0055 §5 — is now a compile error, not a silently
// zeroed geometry at runtime (the readers default a missing field to 0).
function rejectsAFlatRect(win: Window): void {
  // @ts-expect-error — {x,y,width,height} is not a CGRect; the C struct nests an origin and a size
  const flat: CGRect = { x: 0, y: 0, width: 480, height: 320 };
  void flat;
  // @ts-expect-error — and a flat literal is rejected at the call site too
  win.setFrameOrigin_({ width: 1, height: 2 });
}

// --- The INBOUND value surface (ADR-0059 §8) ---------------------------------------------------
// The shape a *future* emitted delegate spec must have (k74's later children): a protocol
// `interface` typing the JS side, and a `DelegateSpec` carrying the per-method value-kind
// descriptors that make those declared types real. No emitted module carries one yet — this is the
// seam contract they will be written against, held honest by `tsc --noEmit` in the meantime.

interface WidgetDelegate {
  widget_didChange_?(widget: Widget, reason: NSObject): void;
  widgetDidCommand_?(selector: string): void;
  classForWidget_?(widget: Widget): typeof NSObject;
  menuForWidget_?(widget: Widget): Widget | null;
}

// ── The protocol-qualified slot (`protocol-binding-surface-k89`, ADR-0055 §4b) ────────────────
//
// The emitter now types `id<WidgetDelegate>` by its interface. The two positions render
// differently, and this is the compile-time proof that both are honest:
//
//   param  (contravariant — what we accept)  → `WidgetDelegate`
//   return (covariant     — what we promise) → `WidgetDelegate & NSObject`
//
// The return's intersection is not decoration. Without it the value would be NARROWER than what
// the API really hands back, and `rejectsNothingLegal` below — a legal ObjC call — would stop
// compiling. It is honest only because `dynamic-class-wrap-k88` mints the wrapper into the
// object's real class, so the object genuinely carries both the interface's members and the
// root's.
class Host extends NSObject {
  static readonly __cls: bigint = __class('Host');

  // `- setDelegate:(id<WidgetDelegate>)` — the emitted body, verbatim (`emitted-delegate-spec-k84`).
  // A bound slot does not `__unwrap`: it bridges. `__protocolArg` discriminates the two things the
  // type admits — a wrapped ObjC object (unwrap it) and a plain JS object (mint a forwarder from the
  // spec) — so the *param* arm's promise in ADR-0055 §4b is backed by a real value at last. The owner
  // is the receiver; the key is the slot; `true` is §6's default-associate arm.
  setDelegate_(delegate: WidgetDelegate): void {
    __dispatch.aw_ts_msg_P_v(
      __unwrap(this),
      __sel('setDelegate:'),
      __protocolArg(__unwrap(this), 'setDelegate:#0', delegate, WidgetDelegateSpec, true),
    );
  }

  // `- initWithDelegate:(id<WidgetDelegate>)` — the INITIALIZER shape. An initializer's delegate is
  // stored by the object `init` RETURNS, which ObjC lets differ from the one `alloc` produced — so
  // the arg is handed over with no owner (`0n`) and adopted onto `__ret` once it exists.
  initWithDelegate_(delegate: WidgetDelegate): Host {
    const __a0 = __protocolArg(0n, 'initWithDelegate:#0', delegate, WidgetDelegateSpec, true);
    const __ret = __dispatch.aw_ts_msg_P_P_o(__unwrap(this), __sel('initWithDelegate:'), __a0);
    __protocolAdopt(__ret, 'initWithDelegate:#0', delegate, __a0, true);
    return __wrapOwned(Host, __ret)!;
  }

  // `- delegate` → `id<WidgetDelegate>` (nullable). The IR names no class, so the body takes the
  // class-less wrap arm — carrying the DECLARED conformance as the type argument, which is the one
  // fact `tsc` cannot derive for itself and the ObjC header states outright.
  delegate(): (WidgetDelegate & NSObject) | null {
    const __ret = __dispatch.aw_ts_msg_0_P(__unwrap(this), __sel('delegate'));
    return __wrapRetained<WidgetDelegate & NSObject>(__ret);
  }
}

// The bound return is usable AS the interface — the whole point of binding.
function readsThroughTheInterface(host: Host): void {
  const d = host.delegate();
  d?.widgetDidCommand_?.('go:'); // P's members, on a value the runtime resolved dynamically
  d?.[Symbol.dispose](); // …and the object root's, which a bare `P` return would have lost
}

// THE NON-NARROWING PROPERTY. `-[NSMutableArray addObject:(id)]` renders `NSObject`, so handing it
// a protocol-qualified return is a legal ObjC call that MUST keep compiling. A bare `WidgetDelegate`
// return would fail here — an interface is not assignable to a class — which is exactly why the
// covariant arm intersects the root.
function passesABoundReturnIntoAnIdSlot(host: Host, sink: (o: NSObject) => void): void {
  const d = host.delegate();
  if (d !== null) sink(d);
}

// The negative control — write the test that FAILS, or the one above proves nothing. A bare
// interface carries none of `NSObject`'s brand, so this is precisely the error the covariant arm
// exists to prevent: had `delegate()` returned `WidgetDelegate` alone, `passesABoundReturnIntoAnIdSlot`
// would have failed on this very assignment. (And it is why the *param* arm must NOT intersect the
// root: `setDelegate_` has to keep accepting a plain JS object literal.)
function aBareInterfaceIsNotAnObject(d: WidgetDelegate, sink: (o: NSObject) => void): void {
  // @ts-expect-error — an interface is not assignable to the branded runtime root
  sink(d);
}

const WidgetDelegateSpec: DelegateSpec = {
  protocol: 'WidgetDelegate',
  methods: [
    ['widget:didChange:', 'v@:@@'],
    ['widgetDidCommand:', 'v@:@'],
    ['classForWidget:', '@@:@'],
    ['menuForWidget:', '@@:@'],
  ],
  // No setter, no property key, no associate flag: those describe a *slot*, and one protocol types
  // many. The call site passes them — which is what lets ONE spec serve all 122 bound slots in the
  // corpus, setter and non-setter alike.
  //
  // Keyed by RAW selector; every method in `methods` covered (a partial descriptor throws at
  // delivery — marshal.ts). `OBJ` carries no class: the class-less wrap resolves the object's REAL
  // one (ADR-0057 §3b), which is always at least as specific as the declared one — so a spec module
  // imports nothing but the runtime, and cannot cycle with the classes it would otherwise name.
  marshal: __methodMarshal({
    'widget:didChange:': { args: [OBJ, OBJ], ret: RAW },
    'widgetDidCommand:': { args: [SEL], ret: RAW },
    'classForWidget:': { args: [OBJ], ret: CLS },
    'menuForWidget:': { args: [OBJ], ret: RET_OBJ() }, // +0 convention → retain-autoreleased
  }),
};

// A JS object literal typed by the interface — the ADR-0055 §4 delegate shape. It receives WRAPPERS
// and returns them; the runtime, not the author, does the handle marshalling.
function installsADelegate(owner: Host): void {
  const delegate: WidgetDelegate = {
    widget_didChange_(widget, reason) {
      void widget.tag(); // the arg is a real bound Widget — it dispatches
      void reason;
    },
    widgetDidCommand_(selector) {
      void selector.length; // a SEL is a string here, never a bigint
    },
    classForWidget_: () => Widget,
    menuForWidget_: (widget) => widget,
  };
  // Installed through the EMITTED setter — the literal reaches ObjC because the setter bridges it,
  // not because a hand-written runtime call did. That is the whole of k84.
  owner.setDelegate_(delegate);
}

// A block's descriptor has no selector — its registered target IS the callable.
const enumerateMarshal = __blockMarshal({ args: [OBJ, RAW, RAW], ret: RAW });
void enumerateMarshal;

export {
  Widget,
  Window,
  Host,
  readsThroughTheInterface,
  passesABoundReturnIntoAnIdSlot,
  aBareInterfaceIsNotAnObject,
  WidgetDelegateSpec,
  drivesUsing,
  brandingHolds,
  consumesFallible,
  installsADelegate,
  opensAWindow,
  rejectsAFlatRect,
  Greeting,
};
