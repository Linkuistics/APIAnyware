# 150-knowledge-chez

**Kind:** work

## Goal
Write `knowledge/targets/chez.md` — first-pass target-wide learnings,
authored after the 020-140 implementation work. Captures the
non-obvious bits a future maintainer (or future you) will need.

## Context
- All findings accumulated across leaves 020-140 — read the commit log
  of this node for the surprises.
- Design spec §9 (knowledge file scope).
- `knowledge/targets/racket.md` if present; otherwise the writing
  style sets the precedent.

## Done when
- `knowledge/targets/chez.md` exists and covers:
  - The lifetime mental model (guardian + entry-point autoreleasepool,
    why both, what to do when authoring app code).
  - The `(values result error)` calling convention for fallible
    procedures.
  - Sample-app authoring rules — `define-entry-point` for every
    callback/event handler, `with-autorelease-pool` for off-run-loop
    loops, `lock-object` for any closure passed to a long-lived
    `foreign-callable`.
  - Chez-only escape hatches — raw `foreign-procedure`, direct
    `objc_msgSend` from `runtime/ffi.sls`, custom blocks via
    `make-objc-block`.
  - Observed gotchas: callable-pinning races, ftype-value-vs-pointer
    confusions, anything else the 020-140 leaves surface.
- Short, opinionated, written-after-the-fact (not a spec).
- Cross-links to the ADRs and the design spec where appropriate.

## Notes
- This is the final leaf in the node. After this leaf retires, the
  node retires, and the 060-rewrite-adding-language-target.md peer can
  consume both `knowledge/targets/racket.md` and `chez.md` for its
  rewrite.
