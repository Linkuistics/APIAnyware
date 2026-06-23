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

## Build

```sh
# prerequisites: PDFKit generated (resolve→annotate→enrich --only PDFKit, then --target sbcl)
# + the dylib built
SDKROOT=macosx cargo run -p apianyware-macos-analyze -- resolve  --only PDFKit
SDKROOT=macosx cargo run -p apianyware-macos-analyze -- annotate --only PDFKit --llm-dir analysis/ir/llm-annotations
SDKROOT=macosx cargo run -p apianyware-macos-analyze -- enrich   --only PDFKit
SDKROOT=macosx cargo run -p apianyware-macos-generate -- --target sbcl
SDKROOT=macosx swift build --package-path swift --product APIAnywareSbcl
# then:
generation/targets/sbcl/apps/pdfkit-viewer/build.sh
```

Produces `build/PDFKitViewer.app` (a standalone `save-lisp-and-die :executable t` dump).
`build.sh` stages the dylib at `/tmp/libAPIAnywareSbcl.dylib` (the revive auto-reopen path,
ADR-0038 §5), runs the host construction **pre-flight** + a **revive smoke** (dump+revive
**with** the dylib + subclass re-synthesis + dispatcher re-registration + **constant
re-resolution**) before the bundle.

## VM-verify (never run GUI apps from the CLI — use TestAnyware)

Provision the VM with `/opt/homebrew/opt/zstd/lib/libzstd.1.dylib` (via `sudo` — the golden
has no Homebrew), `/tmp/libAPIAnywareSbcl.dylib`, and a sample `.pdf`. Upload the bundle,
`xattr -dr com.apple.quarantine`, `open -n`. Drive the (out-of-process) NSOpenPanel by
keyboard: Cmd-Shift-G → type the path → Return → Return. The key behaviour to verify is the
"Page n of N" label tracking **every** page change (it flows through the
`PDFViewPageChangedNotification` observer) with correct ◀/▶ boundary enable/disable. See
`test-results/pdfkit-viewer/report.md`.
