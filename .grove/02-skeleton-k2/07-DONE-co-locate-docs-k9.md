# co-locate-docs-k9

**Kind:** work

## Goal

Dissolve the top-level `docs/` tree per §10 ("documentation lives with its subject"),
move the central record dirs to the root, and slim the README to a map.

- **`docs/adr/` → root `adr/`** (ADR-0045): `git mv`, then rewrite the ~45
  `docs/adr/NNNN…` cross-references in code + docs to `adr/NNNN…`. Global numbering +
  filenames unchanged.
- **`docs/prd/` → root `prd/`** (same cross-cutting-record logic as ADRs, ADR-0045
  Consequences).
- **Co-locate the rest by subject (§10 map):**
  - `docs/pipeline/{collection,analysis,...}.md` → the domain each documents
    (collection→`platforms/macos/docs/`, analysis/enrich→`semantic/docs/`,
    type-mapping/emitter-contract→`targets/_shared/docs/`); genuinely cross-cutting
    overviews → a short root-README section or `semantic/docs/`.
  - `docs/specs/*` → the subject's domain (`*-racket-trampoline*`→`targets/racket/docs/design/`,
    `*-cl-family*`→`targets/_shared/docs/`, workspace-design→`semantic/docs/`).
  - `docs/research/*` → subject domain (cl-cocoa-bridges→`targets/_shared/docs/research/`).
  - `docs/apps/*` → `apps/macos/` portfolio docs.
  - `docs/testing/*` → leave a `TODO` pointer to workstream 9 (testing architecture);
    park under `semantic/docs/testing/` or root for now.
  - `docs/guides/*` (adding-a-language-target, codesigning) → `targets/_shared/docs/` /
    relevant home.
  - `docs/superpowers/*` → a tooling/process home (not domain docs) — park with a TODO.
- **`README.md` → repo map only** (§11): what APIAnyware is + where platform/target/app
  specs + schemas live + how to run validation/generation/tests. Link local docs.
- **`website/`** (index.md, meta.yml): keep at root (project website, not domain docs).

## Context

See node brief — §10/§11 doc-placement, ADR-0045 (ADR/PRD root homes), CONTEXT.md
"Documentation structure" (per-language co-location, ADRs central). Target/per-language
docs already moved with their target in k8; this leaf handles the *central* `docs/` tree.

## Done when

No top-level `docs/` remains; `adr/` + `prd/` at root with cross-refs rewritten; other
docs co-located by subject (TODOs where a later workstream owns the final placement);
README is a map; `cargo build` green; committed as `co-locate-docs-k9`.

## Notes

CONTEXT.md "Documentation structure" section describes the *old* `docs/` tree — update
it to the new co-located reality here (it's a glossary term being resolved). Verify no
dead `docs/...` links remain in code/docs after the move (grep).
