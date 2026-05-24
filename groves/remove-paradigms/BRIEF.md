# remove-paradigms — brief

## Goal
Retire the **paradigm / binding-style dimension** from the APIAnyware
codebase: one language target = one binding style. Eliminate the data,
flags, layered apps, and conditional code that exist only to support
multiple paradigms per target.

The driving principle: each target's idioms are best expressed in *one*
binding style. The "paradigm" abstraction was speculative scaffolding that
never paid for its complexity; collapsing it makes adding the next target
(Chez, …) materially simpler and clarifies the existing `racket-oo`
target's identity as simply **`racket`**.

## Done when
- A repo-wide ADR records the retirement and the rationale.
- The `racket-oo` target has been renamed to `racket` everywhere
  (directories, slugs, generated artifacts, docs).
- The `BindingStyle` enum, the `--style` CLI flag, and the `apps/oo/`
  layer (or whatever the analogous splits turn out to be) are gone or
  reduced to the single remaining style per target.
- The pipeline (collect → analyse → generate) and snapshot/smoke/sample
  tests pass on `main` with the dimension removed.
- Docs (`docs/adding-a-language-target.md`, READMEs, design specs) reflect
  one-target-one-style.

## Decomposition
Deliberately under-decomposed at the root. The first child is a planning
task whose job is to *grill the scope* — establish the true extent of
"paradigm-coded" code, decide what survives the collapse, raise the
governing ADR, and grow this tree into the actual work nodes (rename,
removals, doc updates, validation).

## Pointers
- ADRs a session here must read: *(none yet — the planning task will raise
  the governing ADR; subsequent leaves will cite it)*
- Glossary terms in play: paradigm, binding style, target, racket-oo
  *(none yet in `CONTEXT.md` — to be seeded inline by the planning task)*
- Design specs: *(none yet — write only if the increment earns a PRD)*

## Notes
- This grove was originally a prerequisite node *inside* a `chez` grove
  (see the prior project memory). It is lifted to its own grove because
  the retirement is repo-wide and stands alone; downstream groves (Chez,
  future targets) will depend on it.
- No `CONTEXT.md` exists at the repo root yet. The first planning task
  should seed it with the terms it resolves (paradigm, binding-style,
  target, OO layer) per `CONTEXT-FORMAT.md`.
- Sample apps and GUI verification: see the standing guidance about
  TestAnyware-driven verification in user memory — *no* GUI runs from
  the CLI in any work task this grove spawns.
