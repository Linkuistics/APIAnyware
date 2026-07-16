# typescript (Node) macOS binding — user guide (§22)

The entry point for **using** the generated Node TypeScript binding for macOS. This target ships no
separate `docs/developer-guide.md` (see this page's own closing note), so this is the primary
walkthrough: what you are using, how to import it, the object model, alloc/init, protocols/
delegates, subclassing, threading, errors, lifetime, and the escape hatches. The deepest mechanism
detail (dispatch tables, the memory model's retain axis, the pump, distribution) is in
[`../../../docs/reference.md`](../../../docs/reference.md); the target model behind it is mapped in
[`../../../docs/overview.md`](../../../docs/overview.md).

## What you are using

A class-and-method binding over directly-dispatched Objective-C, projected as **real ES6 classes**
mirroring the ObjC graph (`class NSButton extends NSControl`, ADR-0055) — not a namespace of free
procedures (racket/chez) and not a Scheme/CLOS manifest graph (gerbil/sbcl). Every instance wraps a
**branded, disposable native handle**: an `NSButton` handle cannot be passed where an `NSArray` is
expected, and every wrapper is deterministically releasable via `Symbol.dispose`/`using`. The type
surface — every class, method, and constant — is **generated `.d.ts`**, co-emitted from the same IR
pass as the runtime body, so `tsc --noEmit --strict` over the whole corpus is a real, standing
correctness check no dynamically-typed target here has (`../../../docs/language-characteristics.md`).
The runtime you import from is deliberately **dumb** (ADR-0055 §2): it consults no call-time
signature table — every generated call site already knows its own dispatch entry, wrap primitive,
and value kind.

## The binding layout

Two directories, split by axis (platform vs. JS runtime — the two-target Node/JSC split,
`../../../docs/overview.md`):

| dir | what it holds |
|---|---|
| `bindings/macos/generated/<framework>/` | emitted per-class `.ts` + `.d.ts` (gitignored — produced by `apianyware-generate --target typescript`) |
| `bindings/macos/reports/<app>/` | TestAnyware VM-verification evidence (screenshots, `report.md`, `bundle-report.md`) per sample app |
| `bindings/node/runtime/src/` | the hand-written `@apianyware/runtime` npm package (`dispatch.ts`, `classes.ts`, `lifetime.ts`, `result.ts`/`errors.ts`, `callbacks.ts`/`delegate.ts`/`blocks.ts`/`subclass.ts`/`super.ts`, `marshal.ts`, `structs.ts`) — every emitted module imports its seam symbols from here |
| `bindings/node/native/src/` | the Swift-native N-API addon (`APIAnywareTypeScript.node`), this target's sole native unit |
| `app-implementations/macos/<app>/` | sample app sources; each carries its own `learnings.md` + `build.sh` |

See [`../../../README.md`](../../../README.md) for the full target-unit map.

## Requiring bindings

Each framework is its own module — `import { NSButton } from '@apianyware/appkit'` — so an app that
touches three frameworks imports three barrels plus `@apianyware/runtime` for the seam types it
names directly (`Result`, `CGRect`, `SubclassOverride`, …):

```ts
import { NSApplication, NSWindow, NSWindowStyleMask, NSBackingStoreType } from '@apianyware/appkit';
import { NSString } from '@apianyware/foundation';
import { __alloc, __cfstr, __wrapOwned } from '@apianyware/runtime';
```

**Load-order caveat.** Every emitted class registers itself with the native class registry from an
ES2022 **static block** in its own body (`static { __registerClass('NSWindow', NSWindow); }`), and a
static block runs at class-definition time — i.e. at the *importing* module's own static-import
time, before any of that module's own top-level code runs. Nothing must statically import a
framework barrel before the native addon's dispatch backend is installed (`__installDispatch`), or
the registration call reaches a throwing `NOT_LOADED` sentinel. The sample apps' `bootstrap.mjs`
installs the addon first and only then dynamically imports the app module — see
[`../../../app-implementations/macos/hello-window/`](../../../app-implementations/macos/hello-window/)
for the pattern your own app entry point should follow.

## Writing against the binding

A first program opens a window — the shape every sample app follows (trimmed from
[`../../../app-implementations/macos/hello-window/app.ts`](../../../app-implementations/macos/hello-window/app.ts)):

```ts
import { NSApplication, NSApplicationActivationPolicy, NSBackingStoreType,
         NSWindow, NSWindowStyleMask } from '@apianyware/appkit';
import { NSString } from '@apianyware/foundation';
import { __alloc, __cfstr, __wrapOwned } from '@apianyware/runtime';

function jsString(s: string): NSString {
  return __wrapOwned(NSString, __cfstr(s))!;
}

const app = NSApplication.sharedApplication();
app.setActivationPolicy_(NSApplicationActivationPolicy.NSApplicationActivationPolicyRegular);

const styleMask = NSWindowStyleMask.NSWindowStyleMaskTitled | NSWindowStyleMask.NSWindowStyleMaskClosable;
const window = __alloc(NSWindow).initWithContentRect_styleMask_backing_defer_(
  { origin: { x: 0, y: 0 }, size: { width: 400, height: 200 } },
  styleMask,
  NSBackingStoreType.NSBackingStoreBuffered,
  false,
);
window.setTitle_(jsString('Hello from Node TypeScript'));
window.center();
window.makeKeyAndOrderFront_(app);
app.activate();
```

Does **not** call `app.run()` — the native launcher owns `main()` and calls `[NSApp run]` itself,
after your module finishes loading (ADR-0056); a JS call to `run()` would reintroduce the blocking
JS→native call the pump architecture exists to avoid.

Note the shapes, all from the emitter (full table in
[`platform-docs-mapping.md`](platform-docs-mapping.md)):

- **Construction is `alloc`/`init`, not `new`.** `__alloc(Cls)` is the shared `+alloc` primitive
  (one for every class, not generated per-class); `.initWith…()` is the class's own generated
  instance method. The TS `constructor` is internal — never call it directly (ADR-0055 §6).
- **Properties are getter/setter method pairs**, not TS `get`/`set` accessors: `title` is
  `title(): NSString | null` / `setTitle_(t: NSString): void` — the `_` on the setter is the
  selector-preserving rule below applied to `setTitle:`, and the bare getter has no colon so it
  keeps its plain name.
- **Selector → method name is structure-preserving and injective** (ADR-0039/ADR-0055 §3): each `:`
  becomes `_`, camelCase humps are kept. `length` → `length()`; `objectAtIndex:` →
  `objectAtIndex_()`; `setObject:forKey:` → `setObject_forKey_()`. `cancel` and `cancel:` — distinct
  selectors — stay distinct method names (`cancel()` vs. `cancel_()`).
- **Nullable returns are `T | null`**, from the same nullability annotations the Apple docs carry —
  check `NSStringOrNull` returns before using them the way you would in Swift/ObjC's own `nil`
  convention.
- **Geometry structs are nested plain objects**, mirroring the C struct: `CGRect` is
  `{ origin: { x, y }, size: { width, height } }` (not a flat 4-tuple), so `rect.origin` is itself a
  valid `CGPoint` argument. The nine-member POD family (`CGRect`, `CGPoint`, `CGSize`, `NSRange`, …)
  are plain by-value objects — no handle, no disposal — imported `type`-only from `@apianyware/runtime`.
- **`NSString` has no built-in JS-string convenience** — build one with `__cfstr` + `__wrapOwned`
  (the `jsString` helper above; every sample app defines its own copy) and read one back through
  whatever accessor the target string exposes. Constants of type `NSString` are pre-built the same
  way at module load (see `platform-docs-mapping.md`'s constants row).
- **Enums and option sets are real TS `enum`s** (`NS_ENUM`/`NS_OPTIONS` both) — combine option flags
  with `|`, as the style mask above does.

## Protocols and delegates

A **protocol** generates a real TS `interface` (`@optional` members are `?`); implement it with a
**plain object literal** — no subclass, no manual keep-alive. The runtime's delegate machinery
synthesizes a per-protocol forwarding ObjC class the first time you set the delegate slot, and a
strong native association ties its lifetime to the owning object (ADR-0059 §3/§6). From
[`../../../app-implementations/macos/mini-browser/app.ts`](../../../app-implementations/macos/mini-browser/app.ts):

```ts
import type { WKNavigationDelegate } from '@apianyware/webkit';

const navigationDelegate: WKNavigationDelegate = {
  webView_didStartProvisionalNavigation_(_webView, _navigation) { setStatus('Loading…'); },
  webView_didFinishNavigation_(webView, _navigation) { refreshChrome(webView); },
  webView_didFailNavigation_withError_(_webView, _navigation, error) { showError(error, 'Load'); },
};
webView.setNavigationDelegate_(navigationDelegate);
```

Only the methods you implement are wired — the forwarder's `respondsToSelector:` answers from a
per-instance snapshot taken when you set the slot, so `@optional` fidelity is exact (no invisible
extra rows, the bug NativeScript's equivalent bridge shipped with).

## Subclassing

To receive framework callbacks a plain delegate object can't (a custom `NSView`'s `drawRect:`, a
target-action handler), derive a real `class ... extends`. The runtime synthesizes one ObjC subclass
per JS class (ADR-0059 §4). From
[`../../../app-implementations/macos/drawing-canvas/app.ts`](../../../app-implementations/macos/drawing-canvas/app.ts):

```ts
import { __allocSubclass, __bindSubclass, __methodMarshal, RAW, RET_RAW } from '@apianyware/runtime';

const CANVAS_MARSHAL = __methodMarshal({
  'drawRect:': { args: [RAW], ret: RET_RAW },
});

class DrawingCanvasView extends NSView {
  constructor() {
    super(__allocSubclass(DrawingCanvasView));
    __bindSubclass(this, CANVAS_MARSHAL);
  }
  drawRect_(dirtyRect: CGRect): void { /* … */ }
}
```

The value-kind descriptor (`__methodMarshal`) tells the runtime how to convert each overridden
selector's arguments/return — a raw pointer, a wrapped object, a `SEL`, a `Class` — since the
inbound ABI collapses all pointer-shaped kinds to one code and cannot recover this by itself (the
inbound dual of the SEL/Class value surface below). Call the ObjC super implementation with
`this.$super.<method>(…)`, never a bare `super.method()` — native `super.` would re-enter the
override's own forwarding IMP and recurse forever (the same trap sbcl's CLOS bridge documents for
`call-next-method`). `dealloc` is overridable the same way, and always chains
`this.$super.dealloc()` when you override it.

Plain target-action (`setTarget_`/`setAction_`) also needs a real ObjC-backed instance — an
`NSObject` subclass with no view/window superclass — for the same reason a `TKButtonDelegate`
literal wouldn't work for it: the target slot dispatches back through `objc_msgSend`, which needs a
live receiver, not a JS object.

## Threading

Native Cocoa's runloop is authoritative — `[NSApp run]` owns thread 0, and Node's own event loop is
pumped as a guest. Everything you write runs on thread 0 unless you explicitly reach for
`worker_threads`; those still work exactly as Node documents (the pump's one governing constraint is
that it must not break the runtime's own threading facilities). A callback arriving from a
non-main-thread source (a GCD completion, a background framework callback) is bounced to thread 0
before it reaches your JS — you never need to hop yourself the way a raw native module might
require. The one thing to avoid: **never synchronously block thread 0** (a blocking wait, a
synchronous `dispatch_sync`-alike) while a bound object might be releasing off-main — the bounce
that delivery needs cannot service the origin thread while it's parked. See
[`../../../docs/ffi-model.md`](../../../docs/ffi-model.md) for the pump mechanism.

## Errors

Two Cocoa error sources, split by semantics (ADR-0058) — **not** unified into one throw channel:

- **`NSError**` (routine, recoverable)** surfaces as a type-visible `Result<T>`:

  ```ts
  const r = someObject.writeToFile_atomically_encoding_error_(path, true, encoding);
  if (!r.ok) { console.error(r.error); return; }
  // r.value is the success payload; the compiler will not let you read it on the failure arm.
  ```

  `unwrap(r)` is the opt-in bridge to a thrown `NSErrorError` when you'd rather escalate than check.
- **`NSException` (disaster/boundary)** is always **thrown**, as `NSExceptionError extends
  ObjCError extends Error` — catch with an ordinary `try`/`catch` and `instanceof ObjCError` to
  catch either Cocoa failure kind at one boundary.

A Swift `throws` API routes through the same `Result` channel as `NSError**` (both are "routine" by
Cocoa's own convention). See [`platform-docs-mapping.md`](platform-docs-mapping.md) for the per-shape
mapping.

## Lifetime — dispose, don't wait for GC

Every wrapped object should be released deterministically with `using` (TS 5.2+) or an explicit
`obj[Symbol.dispose]()`:

```ts
{
  using scratch = __alloc(NSMutableString).init();
  scratch.appendString_(jsString('draft'));
} // released here, synchronously
```

A `FinalizationRegistry` backstop reclaims anything you forget to dispose, but GC timing is
non-deterministic — treat it as a safety net, not your primary lifetime story, especially for
anything that owns real system resources (an open file, a large image buffer). Using a disposed
wrapper throws `ObjectDisposedError` rather than silently reading a dangling handle. AppKit UI
objects that live for the app's lifetime (windows, views, the shared `NSApplication`) simply never
get disposed — that's normal; only reach for `using` around objects with a genuinely bounded scope.

## Where to go next

- [`platform-docs-mapping.md`](platform-docs-mapping.md) — translate an Apple API-doc page into the
  TypeScript names.
- [`api-coverage.md`](api-coverage.md) — what is and isn't covered, and how faithfully.
- [`unsafe-escape-hatches.md`](unsafe-escape-hatches.md) — reaching APIs the binding doesn't model.
- [`../../../docs/reference.md`](../../../docs/reference.md) — the deep target reference (dispatch tables,
  memory model, threading, error mechanics, callback machinery, distribution, quirks).

**No separate `docs/developer-guide.md`.** This page covers the full user-facing story — import
order, object model, alloc/init, protocols/delegates, subclassing, threading, errors, and lifetime —
the same ground racket's `developer-guide.md` covers for its target, so a second document would
duplicate rather than add (the chez/gerbil/sbcl precedent: 3 of the 4 prior targets made the same
call). Packaging and VM-verification are covered by [`../../../docs/reference.md`](../../../docs/reference.md)
§10 and the shared `testing/testanyware-workflow.md`, neither of which is user-guide content.
