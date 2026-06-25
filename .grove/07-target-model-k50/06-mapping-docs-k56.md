# mapping-docs-k56

**Kind:** work

## Goal

Author the **prose documentation** layer of the target model (ws6 child 6, D7) — the §22
**binding mapping docs** and the §18 **target docs** for each of the four live targets
(racket / chez / gerbil / sbcl), and **discharge the per-target ws6 README TODO markers** the
skeleton (`skeleton-k2`) left behind. This is the one **prose-`.md`** child — no new `.apiw`
entity, no crate, no schema (D1 classified these as the prose face of the target model). The
authored-`.apiw` entities (descriptor / capability / idioms / policy / adapter-spec /
conformance) are all done; this child writes the human-facing docs *over* them.

## Context (see `grove-llm brief-chain` — esp. node BRIEF D1 prose-`.md` bullet + D7 child 6)

- **D1 prose-`.md` face:** the docs split into two families, both per-target:
  - **§22 mapping docs** at `targets/<t>/bindings/<platform>/docs/`: `user-guide.md`,
    `platform-docs-mapping.md`, `api-coverage.md`, `unsafe-escape-hatches.md` (the names D1
    lists — adjust to what each target actually needs; lazy, not a fixed checklist).
  - **§18 target docs** at `targets/<t>/docs/`: `overview.md`, `language-characteristics.md`,
    `ffi-model.md`, `idiom-map.md`, `representability.md`.
- **Reuse the authored model, don't restate it.** Each doc should *point at* the authored
  `.apiw` it documents (the `target.apiw` facets → `overview`/`language-characteristics`/
  `ffi-model`; the `idioms/catalogue.apiw` → `idiom-map`; the `capability.apiw` +
  representability floor → `representability`; the `adapters/<platform>/spec.apiw` +
  `policies/<platform>/projection.apiw` → the mapping docs). `api-coverage.md` can cite /
  embed the **derived** coverage the new `apianyware-conformance` CLI emits (don't hand-author
  recomputable numbers — constraint 4; reference the CLI / `--json`).
- **Discharge the README markers.** The skeleton pinned deferred ws6 content with co-located
  `TODO (workstream 6)` markers in each target's placeholder READMEs (+ the `TODO.md` index).
  **First action:** `grep -rn "workstream 6\|ws6\|TODO" targets/*/docs targets/*/bindings/*/docs
  targets/*/README.md` (and `TODO.md`) to find every ws6 doc marker, so the child writes
  *exactly* what was promised and clears the markers.
- **Boundaries:** these are *target*-domain docs (how a target expresses the platform), never
  platform or semantic docs. Co-located beside their subject (the restructure-docs grove rule).
  The §18 new-target guide step-path resync is **child 7's** (bundler reshape + guide resync),
  not this one.

## Done when

- Each live target carries its §22 `bindings/<platform>/docs/*.md` + §18 `docs/*.md`, grounded
  in (and pointing at) that target's authored `.apiw` entities + the derived coverage; no
  recomputable facts hand-copied.
- Every `TODO (workstream 6)` doc marker in the four targets' READMEs / `TODO.md` is discharged
  (or explicitly re-pointed to child 7 if it is a guide-resync marker).
- No code / golden changes (prose only); workspace stays green.

## Notes

- Commit handle: `mapping-docs-k56`. Remaining ws6 child after this (grow lazily): 7 bundler
  reshape + guide resync (the D6 bundler residuals + `targets/_shared/docs/
  adding-a-language-target.md` step-path resync).
- **May decompose.** Four targets × ~nine docs is potentially large; if it does not fit one
  focused session, `leaf-decompose` into per-target (or per-doc-family) children and do only the
  first this session (grove Decompose step). Per-target richness is affordable because the LLM
  makes it so ([[maximize_target_idiom_and_perf]]).
