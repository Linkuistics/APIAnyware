# pdfkit-viewer (sbcl target)

The 060 ladder's **fifth app**: a PDFKit Viewer — open a `.pdf` via a modal `NSOpenPanel`,
render it in a `PDFView`, navigate pages via ◀/▶ toolbar buttons, and keep a "Page n of N"
label in sync via the `PDFViewPageChangedNotification` observer. Written against the
CL-family interface contract (ADR-0033 / the contract spec) — names only the `ns:` surface,
`make-instance` typed inits (§3.3), the per-selector generics (§3.2, incl. the NSOpenPanel /
NSNotificationCenter class factories via `(eql (find-class 'ns:…))`), the `@"…"` NSString
reader (§3.2), and the subclass macros `define-objc-subclass` / `define-objc-method`
(§3.4/§3.5). The sbcl analogue of racket/chez/gerbil's pdfkit-viewer.

**Distinctive:** first sbcl ladder app to use **PDFKit**, a **modal `NSOpenPanel`**
(`runModal`, inherited from `NSSavePanel` by plain CLOS inheritance), and an
**`NSNotificationCenter` observer**. ONE synthesized `pdf-controller` (`define-objc-subclass`
of `NSObject`) carries FOUR forwarded selectors and is simultaneously the target-action
target (`openDocument:`/`goPrev:`/`goNext:`) AND the notification observer (`pageChanged:`).
The page label updates flow through the **notification**, not an explicit call, so it stays
correct however the page turned.

Also the first ladder app to need a framework **string constant** inside a dumped image
(`PDFViewPageChangedNotification`); this leaf added the runtime's startup re-resolution of the
`define-objc-constant` surface (`lib/runtime/objc.lisp` + `startup.lisp`), so the baked
notification name is re-derived in the revived image before `-main` registers the observer.

Every PDFKit/AppKit call is plain ObjC (`:load-residual nil`) except PDFKit
(`:load-residual t`, for its `constants.lisp`); the app loads `libAPIAnywareSbcl` **only** for
the `aw_sbcl_subclass_*` bounce shim (as scenekit-viewer), not trampoline residual.

## AppSpec instrumentation (sbcl-instrument-build-k101)

Instrumented to the logging contract
(`apps/macos/pdfkit-viewer/docs/logging-contract.md`): `events.lisp` (pure CL, the
`pv-events` package, loaded first by run.lisp/dump.lisp) writes the structured
`/tmp/pdfkit-viewer/events.log` (`PDFKIT_VIEWER_EVENTS_LOG` overrides) the AppSpec
runner tails — `[lifecycle] startup`/`shutdown`, the bare launch line, and the two
`[document]` events (`opened` / `page-changed`), each post-state via `refresh-pdf-ui`'s
returned `(page . total)`. The `pdf-controller` gains the `applicationWillTerminate:`
delegate hook (fifth forwarded selector). Impl descriptor: `pdfkit-viewer-impl.rkt`.

## Build

```sh
targets/sbcl/app-implementations/macos/pdfkit-viewer/build.sh
```

Produces `build/PDFKitViewer-sbcl.app` (`CFBundleIdentifier
com.linkuistics.pdfkit-viewer-sbcl`) via the production bundler
(`apianyware-bundle-sbcl`, ADR-0041): the app's `dump.lisp`
(`save-lisp-and-die :executable t`) behind the Swift stub, with **libzstd** and
**libAPIAnywareSbcl** vendored into `Contents/Frameworks/` — the bundle travels alone
(no `/tmp` staging; `sbcl-vendor-libzstd-k75`). build.sh regenerates the sbcl bindings
if PDFKit is absent from the local tree (keyed on `generated/pdfkit/pdfview.lisp`) and
relinks the dylib in lockstep, then runs the host construction **pre-flight** + a
**revive smoke** through the stub (subclass re-synthesis + dispatcher re-registration +
**constant re-resolution**).

## VM-verify (never run GUI apps from the CLI — use TestAnyware)

Upload the bundle (it travels alone), `xattr -dr com.apple.quarantine`, `open -n`, plus
a sample `.pdf`. Drive the (out-of-process) NSOpenPanel by keyboard: Cmd-Shift-G → type
the path → Return → Return. The key behaviour to verify is the "Page n of N" label
tracking **every** page change (it flows through the `PDFViewPageChangedNotification`
observer) with correct ◀/▶ boundary enable/disable — and, instrumented, the matching
`[document]` events in `/tmp/pdfkit-viewer/events.log`. The Tier-2 live-run leaf drives
the full scenario suite.
