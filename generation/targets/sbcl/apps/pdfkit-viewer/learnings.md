# pdfkit-viewer — learnings (sbcl target, 060 ladder, the 5th app)

A minimal PDF viewer: modal `NSOpenPanel` → `PDFDocument` → `PDFView`, ◀/▶ page nav, and a
"Page n of N" label kept in sync by a `PDFViewPageChangedNotification` observer. First sbcl
app to use **PDFKit**, a **modal open panel**, and an **`NSNotificationCenter` observer**;
PDFKit was not in any target's local IR, so this leaf ran the pipeline for it
(resolve→annotate→enrich `--only PDFKit` + `--target sbcl`; the `PDFKit.llm.json` annotation
already existed). It surfaced one real runtime gap (fixed) and confirmed several contract
patterns.

## Runtime gap FIXED: `define-objc-constant` is stale across a dump — re-resolve at startup

**The first ladder app to need a framework STRING CONSTANT inside a dumped image**
(`PDFViewPageChangedNotification`, the observer's name). `define-objc-constant` expanded to a
`defparameter` over a foreign read done ONCE at load; that pointer is dead after
`save-lisp-and-die` (the NSString global lives in the framework, re-mapped in the revived
process). The macro's own section comment had flagged this and deferred the fix to
070-distribution — but a 060 app needs it now, and the startup re-resolution pass it belongs
to already lives in the 050 runtime.

**Fix (`lib/runtime/objc.lisp` + `startup.lisp`):** the macro now also registers a
re-evaluator thunk in `*objc-constant-reresolvers*`; a new `:objc-constants` entry on the
`*startup-reresolve-hooks*` seam re-runs every value form AFTER the startup pass re-`dlopen`s
frameworks (so the `extern-alien` globals resolve). Guarded per-constant (a symbol that no
longer resolves keeps its stale value rather than killing the image — mirrors
`aw-reresolve-classes`'s skip-on-miss). Inert for a dev `sbcl --load` (init-hooks ran at boot
before any constant registered) and for a residual-free app (registry empty). This is the
same seam scenekit-viewer used for its dispatcher re-registration.

> Why `load-shared-object` makes this correct: `aw-load-framework` uses
> `sb-alien:load-shared-object`, so frameworks land in `*shared-objects*` and SBCL re-resolves
> the foreign linkage table at image start (before `*init-hooks*`). Re-running a value form in
> the step-6 hook therefore reads the freshly-resolved global — re-deriving the constant the
> baked `defparameter` could not.

**Verified:** the host revive smoke (`### revived pdfkit-viewer construction OK`), a
discriminating round-trip in `smoke-startup-reresolution.lisp` (the dump `setf`s a baked
Foundation constant to nil — only the pass can restore it → CONST OK), and live in the VM
(the label tracks page changes, which it can only do if the observer's re-resolved
notification name is correct).

## Patterns confirmed

- **Inherited methods dispatch by plain CLOS inheritance.** `NSOpenPanel`'s designated
  factory is `+openPanel`, but `setAllowedFileTypes:` / `runModal` / `URL` are declared on
  `NSSavePanel`. Because `ns:ns-open-panel` subclasses `ns:ns-save-panel`, the generated
  `(defmethod … ((self ns:ns-save-panel)) …)` applies to the open-panel instance unchanged —
  no per-target inherited-dispatch idiom needed (gerbil/chez route via the declaring class's
  proc; CLOS does it for free).
- **One synthesized subclass, four selectors, two roles.** The same `pdf-controller` is both
  the target-action target (build-time `set-target_`/`set-action_`) and the notification
  observer (runtime `add-observer:selector:name:object:`). All four selectors reach the
  delegate through the one main-bounced forwarding dispatcher.
- **`make-instance` returns nil for a failed ObjC init.** `(make-instance 'ns:pdf-document
  :init-with-url url)` → `aw-wrap` of the `initWithURL:` result; a non-PDF URL yields nil
  (initWithURL: → null id → `aw-wrap` → nil), so `(when doc …)` is the whole guard — the
  contract's typed-init path (ADR-0040) folds the failable-init case in cleanly.
- **`setAllowedFileTypes:` (deprecated since 12.0) still works** on macos-tahoe — a
  one-element `NSMutableArray` of `@"pdf"`. Matches the racket/chez/gerbil source; modern
  `setAllowedContentTypes:` needs UniformTypeIdentifiers/`UTType`, not generated.
- **Display mode + auto-scale.** `setAutoScales: YES` + `kPDFDisplaySinglePageContinuous`
  (enum constant `ns:k-pdf-display-single-page-continuous` = 1) gives a fit-width continuous
  scroll; ◀/▶ scroll page-to-page and each posts the page-changed notification.
- **PDFKit is pure ObjC** — adding it regenerated `Trampolines.swift` byte-identically (zero
  Swift-native residual), so the existing dylib served unchanged; frameworks load
  `:load-residual nil` EXCEPT PDFKit (`:load-residual t`, for its `constants.lisp`).

## VM-driving lessons (TestAnyware, building on scenekit-viewer's)

- **NSOpenPanel is out-of-process** (`com.apple.appkit.xpc.openAndSavePanelService` on modern
  macOS), so `agent snapshot` does not see its buttons under the app. Drive it by keyboard:
  Cmd-Shift-G → type the full file path → Return (selects it; the panel even renders a live
  preview) → Return again activates the default (blue) **Open** button. No AX click needed.
- **Screenshot ≈ click-space 1:1 on this golden.** Unlike the scenekit session's ~0.75×
  note, here `screen-size`, the screenshot PNG, and the `input click`/AX space were all
  1024×768 and aligned (AX `Open…` center (198,109) matched the PNG pixel). Still get targets
  from `agent snapshot`, but the screenshot was directly clickable too.
- **Screenshot immediately after a page-turn click can catch a pre-repaint frame** (the AX
  tree updated — ▶ already disabled — while the PNG still showed the previous page). A ~1 s
  settle before the screenshot fixes it; the AX `enabled` flags are the reliable
  source of truth for navigation state.
- **`/opt/homebrew` is root-owned on the no-Homebrew golden** — place the absolute-path
  libzstd dep with `sudo cp` (passwordless sudo works), not a plain `upload` (which 513s).
- Generate the test PDF on the host with CoreGraphics (`beginPDFPage`/`CTLineDraw`), each
  page a distinct colour + big "PAGE n", so page navigation is unambiguous in screenshots.
