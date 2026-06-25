# platform-docs-k42

**Kind:** work (ws4 child 4 — the **last** platform-model child; pure prose, no new mechanism)

## Goal

Author the macOS platform-model **documentation** (node-brief D5 child 4) and
**discharge the doc placeholders** — the prose that explains the realized platform
model (manifest, per-family API specs, app-kinds, test obligations) to a human. This
is ws4's fourth and final child (manifest ✓, app-kinds ✓, platform-tests ✓,
**platform-docs**). After it retires, ws4 (`platform-model-k32`) is done and **ws5**
(LLM analysis side-channel) grows next.

## Context (see `grove-llm brief-chain`; node BRIEF D5 + the promoted outcomes sections)

- **D5 doc set:** `platforms/macos/docs/{overview,api-extraction,app-kinds,
  testing-obligations}.md` + discharge `platforms/macos/docs/README.md`. (Per D5 also
  "finalize `api/README.md`" — but `api/README.md` was already fully authored by
  `pipeline-cutover-k20`/manifest work and carries **no** TODO; verify and leave it, or
  touch only if it drifted. The genuine placeholder to discharge is `docs/README.md`,
  TODO at ~line 8.)
- **Reconcile with existing docs, don't duplicate.** `platforms/macos/docs/` already
  holds `collection.md` (the extraction/collection prose), `annotation-workflow.md`
  (the LLM-annotation operational prose), and `codesigning-identity.md`. The D5
  `api-extraction.md` overlaps `collection.md` + `annotation-workflow.md` — decide
  per-session whether `api-extraction.md` is a thin **map/index** that points at the
  existing two (preferred — lazy, constraint 4) or a new consolidating doc. Don't
  re-author what `collection.md`/`annotation-workflow.md` already cover; link to them.
- **What each doc covers (the realized model — read the briefs + READMEs, don't invent):**
  - `overview.md` — the macOS source platform as a whole: the platform/semantic boundary
    (platform = what the API *means* incl. hard properties; target = how representable,
    ws6), the four sub-models (manifest, `api/`, `app-kinds/`, `tests/`), and the
    platform-neutral `platforms/<platform>/` shape that absorbs a 2nd platform.
  - `api-extraction.md` — how a family's spec triad is produced (`extracted.json` /
    `annotations.apiw` / `resolved.json`, ADR-0046; the `collect → analyze → generate`
    pipeline). Mostly an index over `collection.md` + `annotation-workflow.md` +
    `api/README.md`.
  - `app-kinds.md` — the seven app-kinds (process-model truth, ADR-0049); points at
    `app-kinds/README.md` + per-kind `docs/`. Index, not a re-author.
  - `testing-obligations.md` — the **two declaration families** + the declare-now /
    execute-later seam (the promoted platform-tests outcomes carry D6/D7); points at
    `tests/README.md`.
- **Glossary:** `CONTEXT.md` (read every session). Add any platform-doc terms that
  resolve; most platform-model vocab already landed (platform spec, app-kind, api-semantics
  declaration, the platform/semantic boundary).

## Done when

- `platforms/macos/docs/{overview,api-extraction,app-kinds,testing-obligations}.md`
  authored (or the reconciled subset — record the call), each grounded in the realized
  model and **linking to** rather than duplicating the co-located READMEs/existing docs.
- `platforms/macos/docs/README.md` discharged (TODO removed; maps the docs/ contents).
- `api/README.md` verified final (no lingering TODO); touched only if drifted.
- The doc-set scope decision (which D5 docs are full vs. thin indexes over existing prose)
  recorded in this leaf.
- `cargo test -p apianyware-platform-tests`, clippy, fmt green (no code change expected —
  this is prose); **nothing executed**; no emit-golden movement.

## Notes (steers)

- **Pure prose, no new mechanism.** No grammar, schema, crate, or submodule changes —
  the platform model is complete (children 1–3). Mermaid for any diagram, never ASCII art.
- **Lazy / link, don't duplicate** (constraint 4). Prefer thin index docs that point at
  the authoritative co-located READMEs and existing `docs/` prose over re-authoring.
- After this leaf retires, the platform-model-k32 node has no live child → the
  retire-cascade **asks before treating ws4 done**, promotes its brief upward (to the
  root brief, mirroring the Skeleton/Spec-format/Semantic-model outcomes sections), then
  **ws5** (LLM analysis side-channel) grows next via `leaf-add` on the grove root
  (root-brief decomposition #5).
