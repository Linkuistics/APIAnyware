# 030-plan-post-purge

**Kind:** planning

## Goal
Grill the remaining grove work against the real post-purge diff and grow
the tree. Three workstreams need decomposition before any of them can
become work leaves:

1. **Rename `racket-oo` → `racket`** — crate names, workspace members,
   on-disk directories under `generation/crates/` and
   `generation/targets/`, CLI `--lang` value, registry id, golden test
   paths, the `LanguageInfo.id` / `display_name`, knowledge file
   `knowledge/targets/racket-oo.md`, plan/spec/historical docs that
   reference the slug, and (if it earns it) the [[target-vs-language]]
   trait/flag rename flagged in `CONTEXT.md`.
2. **Chez target design** — confirm or revise the prior design intent
   (libobjc via Chez `foreign-procedure`, mandatory Swift dylib,
   guardian-managed `objc-object`, `NSError**` → `(values result
   error)`, R6RS `library` per class) against what the post-purge,
   post-rename emitter scaffold actually looks like. Open question: is
   most of the work in `emit-chez/` a fork of `emit-racket-oo/` with a
   different code-writer, or a separate emitter sharing only the shared
   `emit/` infrastructure? Grill until the answer is sharp.
3. **Chez build + sample-app portfolio** — the `emit-chez` crate, the
   `generation/targets/chez/` runtime (Scheme bridge + Swift dylib),
   every framework `racket` emits must also emit under `chez`, and all
   7 sample apps must build and pass TestAnyware on macOS.

The grilling will likely surface a fourth workstream — the
`docs/adding-a-language-target.md` rewrite — that needs to land *after*
rename + chez exist (so the doc describes the real world) but before
the grove is retired (per the root BRIEF's done-when).

## Context
- Root BRIEF: `.grove/BRIEF.md`.
- ADR-0004 (the authority for paradigm retirement): `docs/adr/0004-retire-paradigm-dimension.md`.
- The post-purge code, especially:
  - `generation/crates/emit/src/binding_style.rs` — now-slimmed
    `LanguageEmitter` trait + `LanguageInfo`. Read this before grilling
    the chez emitter signature.
  - `generation/crates/emit-racket-oo/` — what a target's emitter
    actually looks like today (post-purge but pre-rename).
  - `generation/crates/cli/src/{generate,registry}.rs` — how targets
    plug into the CLI.
  - `generation/targets/racket-oo/` — what a target's on-disk runtime +
    apps + lib layout looks like; the chez analogue must answer the
    same questions (runtime structure, Swift dylib, sample app layout).
  - `generation/crates/bundle-racket-oo/` — bundler crate per target;
    chez likely needs a sibling `bundle-chez/`.
- `CONTEXT.md` — glossary; the `Target vs. Language` ambiguity flagged
  there may or may not earn an ADR + edits in this grove.
- The chez decomposition done 2026-05-23 is **not on main**; surviving
  design intent lives in project memory (slug `chez`, not
  `chez-functional`, per [[project-grove-skill]]).
- Pre-existing test failures (LLM-annotation drift in foundation/appkit
  snapshot subsets, SDK-path drift) are real but out of scope for this
  grove; flag, do not fix here.

## Done when
- A planning grilling session has run (`grilling.md`).
- `CONTEXT.md` has been amended inline for any new term that came up —
  at minimum, the chez-target vocabulary if the slug, layout, or
  per-target structure surfaces a missing term.
- Any genuinely hard-to-reverse decisions are captured as ADR(s) —
  candidates flagged by the grilling include: how chez handles
  `NSError**`, whether `emit-chez` shares the racket emitter via
  refactor or stands alone, whether the rename also pulls the
  `LanguageEmitter` trait / `--lang` flag into "Target" terminology.
- Subsequent leaves are seeded under `.grove/`:
  - `040-…` for the rename (likely one work leaf; promote to a node if
    grilling reveals it's bigger).
  - `050-…/` as a *node* for chez design + build (the design alone is
    a planning task; the build is several work leaves).
  - Optional `060-…` placeholder for `docs/adding-a-language-target.md`
    rewrite, if it doesn't fold naturally into the chez node.
- A PRD MAY be written at `docs/prd/` if the chez design hits a clear
  agreement point with the user; not mandatory.

## Notes
The brief explicitly defers chez planning to *after* the purge so the
design can be grilled against real code rather than a stale mental
model. Resist the temptation to copy the prior chez decomposition
verbatim — re-derive it, treating the prior intent as a hypothesis to
challenge, not a plan to execute.

Numbering: pick the next leaf prefix after the live siblings, not after
the retired ones. Today the live root has no leaves, so the next leaf
seeded by this planning task is `040-` (this task is `030-`, and the
done leaves `010-` and `020-` count as taken).
