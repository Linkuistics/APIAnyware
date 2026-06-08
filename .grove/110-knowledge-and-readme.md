# 110-knowledge-and-readme

**Kind:** work

## Goal

Write `knowledge/targets/gerbil.md` and update the README target-status to mark
`gerbil` complete — closing the 9-step guide (`docs/adding-a-language-target.md`).

## Context

Reference: `knowledge/targets/chez.md`, `knowledge/targets/racket.md`. The 9th
guide step. Most learnings already exist as durable artifacts to draw from:
ADR-0017/0018/0019, the design spec, and the 020 FINDINGS.

## Done when

- `knowledge/targets/gerbil.md` populated with target-wide learnings:
  - Toolchain provisioning (FINDINGS §0): `gsc`/ghostscript collision, the three
    Cellar `~~`-resolution symlinks, the stale-`.o.lock` hazard.
  - **Two-toolchain rule** (spec §1, FINDINGS §3b): measure on the bottle,
    distribute on the static build; the ~10× static-prelude `-O` codegen gap.
  - FFI compiled as ObjC; `define-c-lambda` per signature; `___CAST` for `const`.
  - Object model: procedural core (hot) + opt-in `:std/generic` veneer (when to
    drop down); `objc-obj` handle.
  - Lifetime: Gambit wills + entry-point `@autoreleasepool`; the CLI-tool
    `with-autorelease-pool` rule for loops outside the run loop.
  - Error model: `(values result error)`.
  - Distribution: `gxc -exe` static toolchain + openssl@3 relocation; no `-static`.
  - **Precompilation:** binding libraries compile once to `.ssi`+`.o1`; apps reuse
    — per-method compile cost is a binding-regen-loop cost, not per-app.
  - Threading model (from the 080 spike).
- README target-status row for `gerbil` updated to complete.

## Notes

This leaf empties the build subtree → triggers the grove Finish cycle (ask the
user before retiring the root). Final commit of the workstream.
