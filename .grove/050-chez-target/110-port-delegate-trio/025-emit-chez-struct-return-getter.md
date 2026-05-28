## 025-emit-chez-struct-return-getter

**Kind:** work

## Goal
Make struct-return getters (NSRect / NSEdgeInsets / any by-value struct
larger than two registers) work at runtime under chez. Today the
emitter generates them as:

```
(define %msg-nsview-frame-getter (foreign-procedure "objc_msgSend" (void* void*) (& NSRect)))
(define (nsview-frame self) (%msg-nsview-frame-getter (coerce-arg self) %sel-nsview-frame-getter))
```

Calling `nsview-frame` on a real NSView at runtime raises
`incorrect number of arguments 2 to #<procedure %msg-nsview-frame-getter>`.

Root cause: Chez's foreign-procedure declares `(& <ftype>)` returns
that exceed the indirect-result threshold (NSRect = 32 bytes, > 16 on
arm64) require the caller to pre-allocate a result buffer and pass a
hidden pointer as the **first** argument. The arm64 ABI uses the `x8`
register for this; Chez exposes it as an explicit Scheme-side
argument. The generator emits the wrapper with only `(self, sel)` —
no result buffer — so chez sees an arity mismatch.

NSPoint / NSSize (≤16 bytes) fit in vector registers and don't need
the hidden arg — that's why `%msg-point` works in cocoa.sls today.

## Done when
- A real fix for the emitter that, for each by-value struct return
  larger than 16 bytes, emits the wrapper allocating a result buffer
  and passing it as the leading arg. The wrapper still returns the
  ftype-pointer to the caller.
- `nsview-frame`, `nsview-bounds`, and any other affected getter call
  cleanly at runtime — verified by relaunching the
  `ui-controls-gallery` bundle (its `(nsview-frame content-view)` call
  is the canary).
- Document the threshold and the wrapper shape in
  `docs/specs/<date>-chez-target-design.md` (or wherever struct ABI
  notes live).

## Context
- Discovered 2026-05-28 while CLI-smoke-testing the scenekit-viewer
  port (leaf 020 of this node). scenekit-viewer itself does **not**
  exercise struct-return getters and bundles cleanly; ui-controls-gallery
  does (`nsview-frame`) and dies on launch.
- The body-order fix to `ui-controls-gallery.sls` landed in leaf 020's
  commit (defines must precede expressions in an R6RS body; the
  pre-existing source mixed them, which `chez --script` rejects at
  load). That fix is independent of this emitter gap and is what
  unblocks the discovery of this gap.
- Working precedent for the smaller (≤16-byte) case lives in
  `generation/targets/chez/apianyware/runtime/cocoa.sls`'s
  `%msg-point` (returns `(& NSPoint)` via plain `(void* void*)` arg
  list, no result pointer needed).

## Pointers
- Emitter: `generation/crates/emit-chez/src/` — the function-emission
  path that produces `%msg-…-getter` and the wrapper.
- Failing call site: `(nsview-frame content-view)` in
  `generation/targets/chez/apps/ui-controls-gallery/ui-controls-gallery.sls`.
- Working precedent for ≤16-byte struct returns:
  `generation/targets/chez/apianyware/runtime/cocoa.sls:%msg-point`.
- Chez foreign-procedure docs:
  https://cisco.github.io/ChezScheme/csug10/foreign.html (section on
  `(& <ftype>)` return types).

## Notes
- Don't try to side-step by switching to `objc_msgSend_stret`. On arm64
  there is no `_stret` variant — Apple deliberately unified the calling
  convention. The fix has to handle the indirect-result hidden arg via
  Chez's foreign-procedure facility, not by selecting a different
  symbol.
- The same fix path likely covers NSEdgeInsets (16 bytes — borderline
  but emitter should classify consistently) and any structs introduced
  by future framework expansion.
