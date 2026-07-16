# drawing-canvas — learnings (Node TypeScript target, ladder app 7/7 — the LAST app)

The portfolio's custom-view showcase, and the first Node TypeScript app to subclass `NSView`
itself (every earlier subclass was a plain `NSObject` target-action/notification controller).
Built and VM-verified on the first attempt — `tsc` compiled clean, the construction pre-flight
passed on both host and VM first try, and every spec §14 exemplar scenario this session drove
passed on the first live attempt. No runtime or emitter change was needed: the two prerequisite
gaps (`inbound-struct-arg-surface-k123`'s struct-parameter widening,
`coregraphics-context-function-surface-k124`'s CGContext admission) closed everything this app's
own spec needed, matching sbcl's own "it just composed" capstone finding for this same app.

## Finding: an inbound subclass override with an OBJECT argument needs an explicit `CallbackMarshal` — the first ladder app to hit this

Every earlier ladder app's `NSObject` subclass overrode only RAW-kind selectors (an ignored
target-action sender, a notification token) and so never passed a `marshal` to `__bindSubclass`
— `mouseDown_`/`mouseDragged_`/`mouseUp_` here are the ladder's first inbound overrides that need
a real wrapped object (`NSEvent`), and without a marshal that argument arrives as a bare `bigint`
handle (marshal.ts's own module doc explains why: the native side cannot itself know which
pointer-shaped arg is an object to wrap — that knowledge is TS-side policy). The fix, once
understood, was mechanical: hand-build a `__methodMarshal({...})` from the exact `args`/`ret`
shapes already sitting in `NSView`/`NSResponder`'s own generated `static readonly __overridable`
entries (`OBJ` for the three event params, `RAW` for `drawRect:`'s `CGRect`) and pass it to
`__bindSubclass(this, marshal)`. One easy-to-miss requirement: **every** overridden selector must
have an entry in the marshal, even one (`drawRect:`) that needs no actual conversion — `marshal.ts`'s
`driver` throws on an uncovered selector once *any* marshal is registered for that callback id, so
a partial marshal is a hard runtime error the first time the missing selector fires, not a silent
pass-through. Confirmed correct first-hand in-VM: `mouseDown_`/`mouseDragged_`/`mouseUp_` all
called `event.locationInWindow()` successfully across every drag in this session.

## Finding: `drawRect:`'s struct parameter needed no marshal entry at all to arrive correctly — confirming k123's own claim, not just trusting it

`inbound-struct-arg-surface-k123`'s own native test proved a struct-typed inbound parameter
arrives as a real `{origin,size}` object with **no marshal registered at all** (native's
`napiFromBounceArgs` already converts it before the TS side ever sees it). This session's
`drawRect_(_dirtyRect: CGRect)` — which never reads its own parameter, since the app repaints the
full stroke set on every call per spec §6 — still needed the selector *listed* in
`CANVAS_MARSHAL` (RAW-to-RAW) purely to satisfy the "every arriving selector must resolve"
contract above, not because the struct itself needed converting. Worth restating for the next
subclass override that takes a struct: the conversion is free, the *listing* is not optional once
a marshal exists for that callback.

## Finding: AppKit's "click that activates a window is swallowed" behaviour is a real,
recurring VM-driving trap here — not an app bug

Confirmed twice this session, in two different circumstances:

1. **A fresh app launch, first-ever click.** The very first `input click` after
   `window.makeKeyAndOrderFront_`/`app.activate()` landed on the canvas but painted **no** dot —
   the window was not yet key, so (per `NSView.acceptsFirstMouse:`'s default `NO`) the whole
   mouse-down→mouse-up gesture was consumed activating the window/app, never reaching
   `mouseDown_`. A second, identical click at the same point painted the dot normally.
2. **Switching key window BETWEEN two windows of the SAME already-active app did NOT reproduce
   this** — after the colour panel opened and took key status, a raw `input click` back on the
   canvas (still the same frontmost app, just a different window) delivered normally and painted
   a dot in one action, no reactivating throwaway click needed first. Only the very first
   ever-click after a fresh launch showed the swallow.

**Practical rule for driving any future subclass-override-drawing app in-VM:** after a fresh
launch, send one throwaway click before trusting the first real gesture's result; a window-to-
window focus change within the same running app does not need this. This generalizes sbcl's own
`drawing-canvas` learnings note ("a bare `input move` between mouse-down/up releases the VNC
button — use `input drag`") — both are the same category of finding: the input-delivery model has
sharp edges around gesture boundaries that a screenshot-driven session can silently misattribute
to an app bug if not checked with a second attempt.

## Finding: this golden image's in-VM agent has a broken *mutating* action route, read routes are fine

`agent press`, `agent set-value`, and `agent inspect` all returned `HTTP 400 Bad Request` with an
**empty body** for every query tried (by role+label, with and without `--window`, with and
without the `…` ellipsis character) — `agent health`, `agent windows`, and `agent snapshot` (the
read-only routes) all worked normally throughout the same session. Worked around entirely with
raw VNC `input click`/`input drag` at accessibility-reported coordinates, verified after each
action with a fresh `agent snapshot`/`agent windows` read — every scenario this app's spec needed
was still fully driven and verified, just not through the semantic action routes. Worth flagging
for whoever next provisions or updates the macOS golden image; not investigated further here
(out of scope for an app-verification session) — no prior Node TypeScript ladder app's own
learnings recorded this, so it may be new drift in this particular golden rather than a
long-standing gap.

## Finding: the capture-at-mouse-down model is correct first-hand, both axes independently

Verified live, not just read off the spec: raising the width slider mid-session and drawing a new
stroke left the earlier (thinner) stroke's width untouched; picking a new colour and drawing
another new stroke left every earlier stroke's (and the dot's) colour untouched — both against
the SAME running canvas instance, in the same session, so this is a genuine round-trip proof of
"strokes freeze their tool state at mouse-down," not two independent checks that could coincidentally
each look right in isolation.

## VM-provisioning / tooling notes (continuing prior apps' own)

- **The Homebrew dylib closure is identical to every earlier ladder app's own 20-formula set**
  (same `libnode`/`libuv` transitive graph, 59 MB compressed `lib/`-only vendoring,
  `/opt/homebrew/opt/<formula>` symlinks recreated pointing at the vendored Cellar version dirs).
  The native addon needed zero additional vendoring — its `otool -L` closure is entirely system
  frameworks/dylibs.
- **No new `-framework` link was needed** — `build.sh` links only `AppKit`/`Foundation`/
  `CoreFoundation`, same as hello-window's. The direct-C CoreGraphics calls
  (`CGContextSetRGBStrokeColor` etc.) and `NSGraphicsContext.CGContext()` cross through the
  already-built native addon's own dispatch tables, not through the launcher binary's own link
  step — unlike WebKit (mini-browser/note-editor) or PDFKit (pdfkit-viewer), CoreGraphics needed
  no launcher-level framework addition at all.
- **Deployment preserved the same relative directory structure as the host** (the established
  cross-app convention): `bootstrap.cjs` resolves the native addon via
  `../../../bindings/node/native/build/APIAnywareTypeScript.node` relative to its own directory,
  and the deploy tarball placed `app-implementations/macos/drawing-canvas/` and
  `bindings/node/native/build/` at that exact relative offset under
  `/Users/admin/apianyware-deploy/targets/typescript/...` on the guest — resolved with no path
  rewriting, the smallest deploy tarball of the ladder so far (1.6 MB compressed, vs. note-editor's
  larger WebKit-adjacent footprint) since this app links no extra framework.

## This is the last rung

`drawing-canvas` is the seventh and final child of `sample-apps-k112`'s decompose — once this leaf
retires, that node has no live leaves left in its subtree, so the parent chain (`ts-node-build-k14`)
needs a human-confirmed check for whether Step 8 (`bundle-typescript`, ADR-0060) is the next
concrete leaf to grow, per that node's own roadmap.
