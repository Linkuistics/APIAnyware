# pdfkit-viewer-k31

**Kind:** work

## Goal

The fifth ladder app (guide Step 7): a **PDFKit Viewer** — open a `.pdf` via a modal
`NSOpenPanel`, render it in a `PDFView`, navigate pages via ◀/▶ toolbar buttons, and keep a
"Page n of N" label in sync via the `PDFViewPageChangedNotification` observer. Built against
the CL-family interface contract (ADR-0033) and **TestAnyware VM-verified**. The sbcl analogue
of racket/chez/gerbil's pdfkit-viewer.

Distinctive (vs. scenekit-viewer, the prior custom-delegate app):
- First sbcl app to use **PDFKit** (a freshly generated framework — PDFKit was not yet in any
  target's local IR; its `PDFKit.llm.json` annotation already existed).
- First to use a **modal `NSOpenPanel`** (`runModal`, inherited from `NSSavePanel`) and an
  **`NSNotificationCenter` observer** — the one synthesized delegate carries FOUR selectors and
  doubles as both the target-action target (`openDocument:`/`goPrev:`/`goNext:`) AND the
  notification observer (`pageChanged:`).

## Context

Needs the emitter (040) + runtime (050) working, **plus PDFKit generated** — run the pipeline
for it (resolve→annotate→enrich `--only PDFKit`, then `--target sbcl` generation; the LLM
annotation already exists at `analysis/ir/llm-annotations/PDFKit.llm.json`). Like
scenekit-viewer the app LOADS `libAPIAnywareSbcl` for the subclass bounce shim
(`aw_sbcl_subclass_*`), not trampoline residual (every PDFKit/AppKit call is plain ObjC →
frameworks load `:load-residual nil`). VM provisioning: the dylib at
`/tmp/libAPIAnywareSbcl.dylib` + libzstd + a sample `.pdf` to open.

## Done when

- pdfkit-viewer built + VM-verified (Open… → NSOpenPanel → PDF renders; ◀/▶ navigate; "Page n
  of N" label tracks every page change with correct boundary enable/disable; Cmd-Q); a sample
  `.pdf` provisioned to the VM; `learnings.md` + `test-results/pdfkit-viewer/report.md` (+
  screenshots) recorded.

## Status — DONE (2026-06-23): built + VM-verified; runtime constant-re-resolution gap fixed

Built + **TestAnyware VM-verified** (golden macos-tahoe). Artifacts written. (Generated
PDFKit tree on disk, gitignored; the dylib + `PDFKitViewer.app` built. `Trampolines.swift`
unchanged — PDFKit is pure ObjC, zero Swift-native residual.)

**Verified live in the VM** (`test-results/pdfkit-viewer/report.md`, 4 screenshots):
- Empty state "No PDF loaded", ◀/▶ disabled.
- `Open…` → modal `NSOpenPanel` (`runModal`, inherited from NSSavePanel) → open `sample.pdf`
  → `PDFView` renders page 1, label "Page 1 of 3", ◀ disabled / ▶ enabled.
- ▶ → "Page 2 of 3" (**via the `pageChanged:` notification** — `goNext:` only turns the page);
  ▶ → "Page 3 of 3", ▶ disabled (upper boundary); ◀ → label tracks down to "Page 2 of 3".
- Cmd-Q → TERMINATED-OK.

**RUNTIME GAP FIXED — `define-objc-constant` re-resolution at startup** (`lib/runtime/objc.lisp`
+ `startup.lisp`). pdfkit-viewer is the **first ladder app to need a framework string constant
inside a dumped image** (`PDFViewPageChangedNotification`). The macro read the foreign value
once at load — a dead pointer across `save-lisp-and-die` (its own section comment had deferred
the fix to 070). The macro now registers a re-evaluator; a new `:objc-constants`
`*startup-reresolve-hooks*` entry re-runs each value form after framework re-`dlopen`, so the
constant surface is re-derived in a revived image (the observer would never fire otherwise).
Inert for dev `sbcl --load` / residual-free apps. Extended `smoke-startup-reresolution.lisp`
with a discriminating round-trip (the dump corrupts a baked constant to nil → only the pass
restores it → CONST OK); runtime integration smoke suite green.

## Notes

- Written against the CL-family contract (ADR-0033) for portability. Per-app artifacts:
  `apps/pdfkit-viewer/{pdfkit-viewer.lisp, run.lisp, dump.lisp, build.sh, README.md,
  learnings.md}` + `test-results/pdfkit-viewer/report.md`.
