# add-chez-target — brief

## Goal
Bring the codebase to a two-target world: add **Chez Scheme** as a peer of
the existing Racket target, while retiring the never-used paradigm /
`BindingStyle` dimension and renaming `racket-oo` → `racket`. End state:
`chez` and `racket` sit symmetrically on disk and on the CLI, with `chez`
at full functional parity with `racket` (all currently-emitted frameworks,
all 7 sample apps building and passing TestAnyware).

## Done when
- ADR-0004 records the paradigm-dimension retirement (decision + the
  "register two targets" escape hatch + consequences).
- `BindingStyle` enum and every place it threads (the `style` parameter
  on `LanguageEmitter::emit_framework`, `supported_styles` /
  `default_style` on `LanguageInfo`, snapshot paths, the registry) are
  gone.
- `generated/oo/<framework>/` flattened to `generated/<framework>/`.
- `racket-oo` is renamed to `racket` throughout (crate names, workspace
  members, on-disk directories, CLI `--lang` value, registry keys,
  golden test paths).
- `chez` target ships: `emit-chez` crate, `generation/targets/chez/`
  runtime, Swift dylib, every framework `racket` emits also emits under
  `chez`, all 7 sample apps build and pass TestAnyware validation.
- `docs/adding-a-language-target.md` is rewritten for the post-purge,
  post-rename, two-target world.

## Decomposition
The grove begins with the bundled-in housekeeping (paradigm retirement +
rename) because adding `chez` against today's asymmetric scaffolding
would visibly entrench what we're about to remove. The chez build itself
is planned **lazily** — its first leaf will be a planning task, because
the prior chez design intent (libobjc `foreign-procedure`, mandatory
Swift dylib, guardian-managed `objc-object`, NSError** →
`(values result error)`, R6RS `library` per class) is *direction* not
*commitment* and needs grilling against the actual post-purge code.

Initial leaves (more grow as the work surfaces them):

- `010-adr-0004-retire-paradigms.md` — write the ADR. Docs only.
- `020-purge-binding-style.md` — delete the enum and its threading;
  flatten generated dirs; tests stay green.

The rename, the chez planning, the chez build, and the sample-app
portfolio are **deliberately unplanned right now**. The planning task
that follows leaf 020 will seed them, once the post-purge diff is real.

## Pointers
- ADRs to read: `docs/adr/0001`–`0003` (grove itself); ADR-0004 is what
  leaf 010 produces.
- Glossary terms in play: **Target**, **Binding style**, **Paradigm**
  (retired) — see `CONTEXT.md`.
- Design specs: `docs/specs/2026-05-22-grove-skill-design.md` (grove
  internals — this grove will eventually delete itself per the
  finish-the-grove ritual).
- Process guide to be **updated** by this grove (out of date today):
  `docs/adding-a-language-target.md`.
- Prior art for the abandoned remove-paradigms work:
  `git show 081aa0a` (grilling + plan) and `git show 2dd22d1` (seed).
  The chez-grove decomposition from 2026-05-23 is **not** on `main` —
  surviving design intent lives in project memory only.

## Notes
- The grove is launched from `.grove-worktrees/add-chez-target/` on
  branch `add-chez-target`.
- The `Target vs Language` ambiguity flagged in `CONTEXT.md` (Rust trait
  is `LanguageEmitter`, CLI flag is `--lang`, on-disk unit is "target")
  is **out of scope** for this grove unless it falls out naturally from
  edits we're making anyway. Earns its own grove if it earns anything.
- The current `CONTEXT.md` examples line ("Examples: `racket` (current),
  `chez` (planned)") lags the actual code (`racket-oo` is current). The
  rename leaf will bring code and glossary into alignment; don't fix it
  prematurely.
