# note-editor — learnings (sbcl target, 060 ladder, the 7th app, the capstone)

A Markdown editor with a live HTML preview: an `NSTextView` editor (in an
`NSScrollView`) on the left, a `WKWebView` preview on the right, an `NSSplitView`
between them, a New/Open…/Save…/Undo/Redo toolbar + status line. The widest feature
surface of any sbcl sample, and the FIRST to cross a **block bridge**. Built + fully
**VM-verified** first try — **zero runtime changes, zero emitter changes** (every
binding it needs was already generated, and the 050 block/subclass machinery worked
as designed). The widest "it just composed" result of the ladder.

## The headline: the block bridge worked with zero app-side ceremony

`NSSavePanel`'s `beginSheetModalForWindow:completionHandler:` is the first ObjC **block**
any sbcl sample app passes. The emitter already wraps the handler arg in
`(aw-block handler)` (token-less — `threading.lisp`), so the app just hands it a raw
Lisp closure:

```lisp
(ns:begin-sheet-modal-for-window_completion-handler_ panel window
  (lambda (response)
    (when (= (sb-sys:sap-int response) +ns-modal-response-ok+)
      (let ((url (ns:url panel)))
        (when url (write-current-file controller (ns->str (ns:path url))))))))
```

`aw-block` boxes the closure (capturing only an integer id), the dylib's
`aw_sbcl_make_block` builds the native block, and on sheet dismiss the block body
**bounces to main** (ADR-0035 — a no-op here, the completion fires on main) and
re-enters Lisp through the one `aw-block-dispatcher`. **VM-verified live:** clicking
Save wrote `~/Documents/sbcl-note-verify.md` (112 bytes) with byte-exact editor content
— proving the NSModalResponse crossed the sync bounce as a SAP (`sb-sys:sap-int` →
1 = `NSModalResponseOK`) and the closure's `current-editor-text` read marshalled back.
This is the callback-OUT direction of "the native library IS the binding" (ADR-0010),
the block analogue of mini-browser's delegate callbacks.

## The one dispatcher-init asymmetry that bit (caught at design time, not runtime)

The **subclass** dispatcher lazily self-registers inside `aw-install-override` (the
first `define-objc-method`), but `aw-block` has **no lazy init** — it errors on a null
block if the dispatcher was never registered. So the dev `run.lisp`/`dump.lisp` must
call `(aw-init-block-dispatcher)` explicitly right after `aw-load-native-dylib`. The
dumped image instead gets it via the `*init-hooks*` startup re-resolution pass (which
clears the stale registered flag + re-registers when the dylib is loaded —
`threading.lisp`). A host-side **block-bridge liveness gate** in the construction
pre-flight (`(aw-block (lambda (r) …))` → assert non-null SAP) makes a missing
`aw-init-block-dispatcher` fail before the VM round-trip, not during it.

## The gerbil weak-delegate GC bug CANNOT recur on sbcl (structural)

note-editor is the most allocation-heavy sample (a full Markdown→HTML rebuild +
`loadHTMLString` on **every keystroke**), the exact load that reaped gerbil's
`make-delegate` wrappers under GC and killed all callbacks (the most important fix of
the gerbil run). On sbcl `*subclass-instances*` is a **strong** hash table
(`ffi.lisp`), so the synthesized `note-controller` that owns the observer + the five
target-actions is pinned for the process — the per-keystroke storm never reaps it.
Verified live: the live preview tracked continuous typing across many keystrokes (H1,
inline, list, fenced block) with no callback death. The 050 lifetime design (strong
back-ref, not weak) made the capstone's allocation profile a non-event.

## Patterns confirmed

- **One subclass, six selectors, two roles.** `note-controller` carries five
  target-actions (`newDoc:`…`redoDoc:`) + one notification observer (`textDidChange:`).
  The toolbar selectors fall back to the synthesized default `v@:@`; the observer is
  the same 1-arg `v@:@` shape pdfkit-viewer's `pageChanged:` used. No collision: all
  six kebab generic names (`ns:new-doc_`…`ns:text-did-change_`) are fresh — none shadow
  an emitted 0-arg method (the `reload:`/`reload` class of bug mini-browser fixed). The
  ADR-0039-aligned runtime `aw-selector->generic-name` (mini-browser's fix) emits the
  `_`-per-colon names that keep them distinct.
- **Editor STATE in controller SLOTS.** `current-path`/`dirty` are `:initform`
  slots, mutated via `(setf (slot-value self 'dirty) t)` — the sbcl idiom for gerbil's
  closure variables. The pure UI helpers read them with `slot-value` (not accessors),
  so they compile before the inner `define-objc-subclass` runs (the mini-browser /
  pdfkit-viewer pattern).
- **Editing methods on the NSText superclass.** `ns:string` / `ns:set-string_` are
  defined on `NSText`; `NSTextView` inherits them via the generic. `allowsUndo` is on
  `NSTextView`; `undoManager` is on `NSResponder` (`ns:undo-manager`). The whole text
  surface resolves through the CLOS inheritance graph, no per-class duplication.
- **`loadHTMLString:baseURL:` with a nil base URL.** `(ns:load-html-string_base-url_
  web-view html nil)` — `aw-ptr` of nil → the null SAP, so the contract's outbound
  object coercion handles "no base URL" with no special case. HTML-as-string preview
  (vs. mini-browser's URL navigation); VM-verified rendering H1/H2, bold/italic/code,
  lists, and fenced blocks.
- **AppKit `:load-residual t` for ONE constant.** `NSTextDidChangeNotification`
  (`ns:ns-text-did-change-notification`) lives in AppKit's `constants.lisp`, so AppKit
  loads `:load-residual t` (the swift-native-probe path; pdfkit did the same for
  PDFKit). The constant is a wrapped `define-objc-constant` — passed straight as the
  `name` arg to `add-observer_selector_name_object_` (whose selector arg is a bare
  string the runtime `aw-sel`s).
- **The `@` reader macro is greedy** — a helper named `@str` is read as the `@`
  reader macro applied to the symbol `str`, not as a symbol. Name dynamic-string
  helpers anything but `@…`; this app uses `nsstr`. (`@"literal"` is the only valid
  `@` form.)
- **Markdown→HTML is pure Lisp**, ported faithfully from the racket/chez/gerbil
  renderer (hand-rolled, no regex): `with-output-to-string` + `loop`/`labels` replace
  Scheme's `open-output-string` + named-let. It crosses the binding exactly once per
  render (the single `loadHTMLString`), so list/fence/heading rendering is a Lisp
  concern, not a binding concern — but all paths were VM-verified live anyway.

## VM-driving lessons (TestAnyware, building on mini-browser's)

- **`input type` parses a leading `-` as a flag.** `testanyware input type "- first item"`
  printed the usage hint and typed nothing (the `-` looked like an option). Use
  `input type -- "- first item"` (the `--` flag terminator) for any text starting with
  `-` or `` ` `` — needed for Markdown list markers and fence lines.
- **Press Return for a panel's default button** instead of clicking it. The NSSavePanel
  Save button and the NSAlert Discard button (the first `addButtonWithTitle:`, hence
  default) both fire on Return — scale-independent, no AX coords needed. This sidesteps
  the screenshot-vs-click scale ambiguity entirely for modal confirmation.
- **NSOpenPanel file cells aren't in the AX tree** (the panel snapshots as a bare
  `splitter`). Select a file with **Cmd-Shift-G (Go to Folder) + the full path +
  Return** — fully scale-independent — then Return again to Open. Type-select would also
  work but is ambiguous when two files share a prefix (`sample`/`sbcl`).
- **Title-bar AX is the reliable dirty/name signal.** `agent windows` reported
  "Untitled — edited — Note Editor" → "sbcl-note-verify.md — Note Editor" across the
  save, tracking `setDocumentEdited:` + the document name far more legibly than the
  close-box dot in a screenshot.
- **Provisioning = the two dylibs, no network.** Standalone exe + `/tmp/libAPIAnywareSbcl.dylib`
  + the zstd core-compression dylib (`/opt/homebrew/opt/zstd/lib/libzstd.1.dylib`, placed
  via `sudo` — the golden has no Homebrew). The preview is local `loadHTMLString`, so
  unlike mini-browser this app needs **no network**.
