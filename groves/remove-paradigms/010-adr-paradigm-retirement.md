# 010-adr-paradigm-retirement

**Kind:** work

## Goal
Land ADR-0004 on `main` recording the retirement of the paradigm /
binding-style dimension, and link it from the brief and glossary so every
subsequent leaf cites it instead of re-arguing the decision.

## Context
- Brief chain (root `BRIEF.md`) is the mandate.
- `CONTEXT.md` already carries the **Paradigm (retired)** entry; this
  leaf adds the missing ADR number to its body.
- Existing ADRs: `docs/adr/0001..0003-*.md`. The next number is `0004`.
- Format: `.claude/skills/grove/ADR-FORMAT.md`.

## Done when
- `docs/adr/0004-retire-paradigm-dimension.md` exists, follows
  `ADR-FORMAT.md`, and records:
  - **Decision** — retire the paradigm dimension; one target = one
    binding style, implicit in the target.
  - **Rationale** — only `BindingStyle::ObjectOriented` has ever been
    emitted; the other variants are speculative scaffolding. Cite
    `generation/crates/emit/src/binding_style.rs` and the
    `emit-racket-oo` / `cli` call sites.
  - **Consequences** — `BindingStyle` deleted, `style` parameter
    dropped, `supported_styles` / `default_style` dropped,
    `generated/oo/` flattened, `racket-oo` renamed to `racket`.
    Escape hatch for a future two-flavour target: register two targets.
  - **Status** — Accepted.
- Root `BRIEF.md` Pointers section cites the new ADR by number (it
  currently names the file; this leaf confirms the number once the file
  exists).
- `CONTEXT.md`'s **Paradigm (retired)** entry changes "Retired:" to
  "Retired by ADR-0004:".

## Notes
- Code is untouched in this leaf. The mechanical purge and rename are
  separate leaves so this commit is small and reviewable as a pure
  decision artifact.
- One focused commit, e.g. `docs(adr): retire paradigm dimension (0004)`
  — message body should summarise the rationale.
