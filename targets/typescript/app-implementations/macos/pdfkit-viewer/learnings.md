# pdfkit-viewer — learnings (Node TypeScript target, ladder app 4/7)

The first app to exercise `@apianyware/pdfkit`, a modal `NSOpenPanel`, and an
`NSNotificationCenter` observer. One runtime-level finding (framework linking), one design
finding (routing all four selectors through one handler), and the usual VM-provisioning/tooling
notes.

## Finding: PDFKit needs to be explicitly linked into the launcher — unlike AppKit/Foundation/SceneKit

The construction pre-flight initially failed: `__alloc(PDFView).init()` returned `null`
(`TypeError: Cannot read properties of null (reading 'init')`), because `PDFView.__cls`'s
`__class('PDFView')` — a bare `objc_getClass("PDFView")` inside the addon, no `dlopen` — resolved
to nil. Neither `embed_main.mm`'s link step nor the native addon's own build.sh links PDFKit
(or, for that matter, SceneKit) explicitly; both rely on the framework's classes already being
registered with the ObjC runtime by the time the addon calls `objc_getClass`.

**Root cause (confirmed empirically, not assumed):** re-running scenekit-viewer's own
`AW_SKV_SMOKE=1` construction pre-flight in this same environment still passes — `SCNView`
resolves fine with no explicit SceneKit link anywhere in the toolchain. So *some* frameworks are
already resident in the process by the time `objc_getClass` runs (almost certainly because they
sit in the dyld shared cache and get pulled in some other way this session didn't fully
root-cause), but **PDFKit is not one of them in this environment**. This matches a hint already
on record: sbcl's own `pdfkit-viewer` needed `:load-residual t` specifically for PDFKit
(`constants.lisp`) while "every other PDFKit/AppKit call is plain ObjC" — i.e., a prior target
already found PDFKit needs special handling other frameworks in this portfolio didn't.

**Fix:** add `-framework PDFKit` to `embed_main.mm`'s `swiftc` link line in `build.sh` (alongside
the existing `-framework AppKit -framework Foundation -framework CoreFoundation`) — confirmed by
`otool -L` that PDFKit is now a load command of the launcher binary, and the construction
pre-flight then passes cleanly on both host and VM. **A later rung reaching a framework this
ladder hasn't touched yet should not assume "no explicit link needed" from scenekit-viewer's
precedent** — if `__alloc(SomeClass).init()` returns `null` (not a JS exception, no error thrown,
just `null`), check `otool -L` on the launcher for that framework before looking anywhere else;
adding `-framework <Name>` to the link line is the fix, matching what any native ObjC/Swift app
targeting that framework would do anyway.

## Finding: one handler object cleanly carries a target-action trio AND a notification callback

`PdfController` generalizes scenekit-viewer's `SceneController` (three target-actions, no
notification) and ui-controls-gallery's `GalleryController` (one target-action) to four
selectors of two different *kinds* — `openDocument:`/`goPrev:`/`goNext:` (target-action) and
`pageChanged:` (an `NSNotificationCenter` callback) — with **no new runtime machinery**: the
notification callback is just another entry in the same `SubclassOverride[]` list
(`['pageChanged:', 'v@:@']`), and `NSNotificationCenter.defaultCenter().addObserver_selector_name_object_`
takes the controller as a plain `NSObject` observer, exactly as `setTarget_` does. The
`__subclassAlloc`/`__bindSubclass` primitives don't distinguish "this selector fires via
target-action" from "this selector fires via a notification" — both are just messages sent to
the synthesized subclass. Confirmed end-to-end in-VM: the same `pageChanged:` entry fired
identically whether the page change originated from a button click or a two-finger scroll (no
button involved at all).

## Finding: the generated non-null return types needed defensive guards at three call sites, confirmed necessary in practice

Continuing the pattern scenekit-viewer's `learnings.md` already flagged (real ObjC calls that can
hand back nil despite an asserted non-null TS return type): `PDFDocument.initWithURL_` (spec §6's
whole failed-open protocol), `NSSavePanel.URL()` (spec §6's nil-URL boundary), and
`PDFView.currentPage()` (spec §7.2's transient-nil-mid-swap boundary) all needed `if (!x)`
guards despite typing `this`/`NSURL`/`PDFPage` (non-nullable). Unlike scenekit-viewer's SCNView
case (where the nil path was never actually exercised in-VM), **this app's own cancel-panel
boundary test exercises the `NSSavePanel.URL()` nil-adjacent path for real** (Escape dismisses
the panel with a non-OK `runModal()` response, short-circuiting before `URL()` is even read) —
so this leaf is the first in the ladder to prove the guard load-bearing, not just defensive.

## Finding: `setAllowedFileTypes:` is genuinely absent from this corpus; `UTType` + `setAllowedContentTypes:` is a clean substitute

The four Lisp targets all use the deprecated `NSSavePanel.setAllowedFileTypes:` (a `.pdf`-string
array). It is not in this target's generated corpus at all (deprecated-and-unavailable selectors
are excluded from extraction). The modern replacement, `setAllowedContentTypes:` (an `NSArray` of
`UTType`), **is** generated — `@apianyware/uniformtypeidentifiers` exists and
`UTType.typeWithFilenameExtension_('pdf')` resolves the same `.pdf` filter. No `UTType.pdf` class
*property* is in the generated surface (Swift static class properties on a framework type don't
show up as ObjC class methods here), but the filename-extension factory is a direct, equally
correct substitute for this app's actual need (filter the panel to `.pdf`) — the spec itself
asserts the *operation*, not the deprecated selector. Building the one-element `NSArray` needed
`NSMutableArray.initWithCapacity_` + `addObject_` (no variadic `arrayWithObjects:` factory is
generated, matching the sbcl reference's own workaround).

## Finding: `goToPreviousPage:`/`goToNextPage:`'s ignored sender has no null-safe way to spell "nil" at the type level

Spec §7.1: PDFKit ignores the sender argument entirely. The emitted signature types it as
non-nullable `NSObject` (the SDK header carries no nullability annotation on this parameter), so
there is no way to pass an honest "nil" without an unsafe cast. Rather than casting, `goPrev_`/
`goNext_` pass `this` (the handler itself, always a valid non-null object) — behaviourally
identical since the value is provably ignored (confirmed in-VM: navigation and the resulting
label updates work correctly). A later rung hitting the same "SDK doesn't annotate nullable, but
runtime nil is legal" gap should prefer a valid stand-in object over a cast, matching this leaf's
and scenekit-viewer's `SCNView`-options precedent.

## VM-provisioning finding: a VM was already running at session start, fully clean

Unlike prior sessions' fresh `vm start`, this session found a golden-clone VM already running
(`testanyware vm list` showed it) with an empty-but-provisioned `/opt/homebrew` — reused it
directly rather than cloning a new one, saving the clone time. Stopped it at the end of this
session per the standard workflow. A later session should check `vm list` before `vm start`;
reusing a running clone is safe as long as its `/opt/homebrew` state is inspected first (this one
had no prior formulas extracted, so full provisioning was still needed).

## Tooling finding: `agent press` still 400s; VNC coordinate clicks are the reliable path

Consistent with every prior ladder app's own finding: `agent press --role button --label "..."`
returned a bare `HTTP 400` for the toolbar buttons here too. Worked around identically —
`testanyware input click <x> <y>` against coordinates read from `agent snapshot`'s
`positionX`/`positionY` (+ half the element's own size for the center). Also confirmed:
`testanyware input scroll` rejects a bare negative `--dy -40` (clap parses it as a stray flag);
`--dy=-40` (the `=` form) is required for a negative value.

## Findings for later rungs

- **The two-file bootstrap split, the `AW_*_SMOKE` construction-preflight convention, and the dev
  launcher (`embed_main.mm`) all carried over unchanged again**, modulo this leaf's own
  `-framework PDFKit` addition — a later rung reaching a framework outside
  {AppKit, Foundation, CoreFoundation, SceneKit} should expect it may need its own explicit
  `-framework` addition too; check with `otool -L` before assuming it "just works" the way
  SceneKit did.
- **`globals.d.ts` needs both `process` and `console`** (this app's launch diagnostic uses both),
  same as ui-controls-gallery/scenekit-viewer.
- **A modal panel driven by keyboard (Cmd-Shift-G) is the reliable open-panel pattern** — it is
  hosted out-of-process on modern macOS (spec §11), so accessibility-driven clicks inside it are
  not guaranteed reachable; the four Lisp targets' own VM verification already established this,
  and it held here too.
