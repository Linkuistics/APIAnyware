# 010-adr-0004-retire-paradigms

**Kind:** work

## Goal
Write `docs/adr/0004-retire-paradigm-dimension.md` capturing why the
`BindingStyle` enum and the broader paradigm dimension are being retired,
and what the escape hatch is for a hypothetical future two-flavour target.

## Context
- `CONTEXT.md` "Paradigm (retired)" entry — the existing prose is the
  starting draft; tighten and formalise it for the ADR.
- `generation/crates/emit/src/binding_style.rs` (lines 18, 32, 42, 61, 63)
  — the code being retired in leaf 020.
- `git show 081aa0a` — the prior (abandoned) remove-paradigms grove's
  planning notes may have phrasing or consequence-bullets worth lifting.
- `docs/adr/0001`–`0003` for the established ADR format and tone in this
  repo.

## Done when
- `docs/adr/0004-retire-paradigm-dimension.md` exists.
- **Decision:** retire the `BindingStyle` enum, its `style` parameter on
  `LanguageEmitter::emit_framework`, and the `supported_styles` /
  `default_style` fields on `LanguageInfo`.
- **Consequences** call out at minimum:
  1. Downstream targets bind one style per target by construction.
  2. Escape hatch is to register two targets (e.g. `chez-class`,
     `chez-functional`), **not** to reintroduce the dimension.
  3. `EmitResult`'s counters are not paradigm-coded — leave that struct
     alone.
  4. `generated/oo/<framework>/` flattens to `generated/<framework>/`.
- Commit is docs-only — no code changes in this leaf.

## Notes
The ADR earns its place per the grilling-procedure triple: it is hard to
reverse (reintroducing BindingStyle is non-trivial), surprising without
context (a future reader will wonder why no multi-paradigm support), and
the result of a real trade-off (YAGNI vs future flexibility).
