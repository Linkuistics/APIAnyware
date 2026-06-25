# mapping-docs-k56 — brief

**Kind:** node (the prose-documentation layer of the target model — ws6 child 6, D7)

## Goal

Author the **prose documentation** layer of the target model — the §22 **binding mapping docs**
and the §18 **target docs** for each of the four live targets (racket / chez / gerbil / sbcl),
and **discharge the per-target ws6 doc markers** the skeleton (`skeleton-k2`) left behind. This
is the one **prose-`.md`** node — no new `.apiw` entity, no crate, no schema (D1 classified these
as the prose face of the target model). The authored-`.apiw` entities (descriptor / capability /
idioms / policy / adapter-spec / conformance) are all done (children 1–5); this node writes the
human-facing docs *over* them.

## Decomposition — per-target children (grown lazily)

Decomposed **per target** (the hermetic-isolation seam — each target's docs point at *its own*
authored `.apiw` + reconcile *its own* pre-existing docs; per-target richness is the value,
[[maximize_target_idiom_and_perf]]). Four children, materialized lazily (only the live one
exists; grow the next on retire):

1. **racket-docs** *(`racket-docs-k57`, this session)* — first; racket is the reference target
   and the richest reuse case (it already ships `docs/developer-guide.md` + `docs/reference.md`),
   so it **sets the doc pattern** the other three mirror (the ws4 manifest-first move).
2. **chez-docs** — grow on racket retire.
3. **gerbil-docs** — grow on chez retire.
4. **sbcl-docs** — grow on gerbil retire.

## Shared mandate (every per-target child inherits this)

- **D1 prose-`.md` face — two doc families, both per-target:**
  - **§22 mapping docs** at `targets/<t>/bindings/macos/docs/`: `user-guide.md`,
    `platform-docs-mapping.md`, `api-coverage.md`, `unsafe-escape-hatches.md` (the D1 names —
    **adjust to what each target actually needs; lazy, not a fixed checklist**).
  - **§18 target docs** at `targets/<t>/docs/`: `overview.md`, `language-characteristics.md`,
    `ffi-model.md`, `idiom-map.md`, `representability.md`.
- **Reuse the authored model, don't restate it.** Each doc *points at* the authored `.apiw` it
  documents: `target.apiw` facets → `overview`/`language-characteristics`/`ffi-model`;
  `idioms/catalogue.apiw` (+ the child-3 `idioms/docs/idiom-map.md`) → `idiom-map`;
  `capability.apiw` + the representability floor → `representability`; `adapters/macos/spec.apiw`
  + `policies/macos/projection.apiw` → the mapping docs. `api-coverage.md` **cites the
  `apianyware-conformance` CLI** (`--target <t>`, `--json`) for the derived coverage — never
  hand-author recomputable numbers (constraint 4).
- **Don't duplicate child-3's `idioms/docs/idiom-map.md`.** It is the authoritative §21 idiom
  render; the §18 `docs/idiom-map.md` is a thin pointer to it (discoverability), not a second copy.
- **Reconcile, don't fork, pre-existing docs.** racket's `developer-guide.md` (a full user guide)
  and each target's `reference.md` are pipeline-era deep dives — the new §22/§18 docs orient to
  them and defer depth, rather than restating. (Leave their stale `generation/targets/<t>/` path
  drift alone — that is the skeleton's `TODO.md` path-drift residual, not a doc-prose concern.)
- **Discharge the doc markers.** `grep -rn "workstream 6\|ws6\|TODO" targets/<t>/docs
  targets/<t>/bindings/macos targets/<t>/README.md` per target. The racket/chez bindings-README
  "Open follow-ups" markers are mostly **bundler/dylib reshape** (child 7's D6 territory) or
  already-resolved code concerns — **re-point those to child 7, don't pretend they are doc work**.
  Discharge only the genuine *doc-content* markers.
- **Boundaries:** *target*-domain docs (how a target expresses the platform), never platform or
  semantic docs; co-located beside their subject (the restructure-docs rule). The §18 new-target
  guide step-path resync is **child 7's** (`adding-a-language-target.md`), not this node's.

## Done when (the node — each child clears its own slice)

- Each live target carries its §22 `bindings/macos/docs/*.md` + §18 `docs/*.md`, grounded in (and
  pointing at) that target's authored `.apiw` entities + the derived coverage; no recomputable
  facts hand-copied.
- Every genuine `ws6` *doc* marker in the four targets' READMEs is discharged (or re-pointed to
  child 7 if it is a bundler/guide-resync marker).
- No code / golden changes (prose only); workspace stays green.

## Notes

- Remaining ws6 child after this node (grow lazily on node retire): **7 bundler reshape + guide
  resync** (the D6 bundler residuals + `targets/_shared/docs/adding-a-language-target.md`
  step-path resync).
- On retiring the node, promote the per-target doc-set shape upward only if a later workstream
  needs it; the per-target docs themselves are durable artifacts that stay in place.
