# 060-rewrite-adding-language-target

**Kind:** work

## Goal
Rewrite `docs/adding-a-language-target.md` to describe the real
post-purge, post-rename, two-target world. The current doc is
paradigm-era — it references `BindingStyle`, `supported_styles`,
`default_style`, and a `{lang}-{paradigm}` slug convention — all retired
by ADR-0004. After this leaf, the doc is recipe-accurate against the
`racket` and `chez` targets that actually exist.

## Context
- ADR-0004 retired the paradigm dimension.
- ADR-0005 records that targets emit maximally idiomatic source for their
  specific implementation, not portable subsets — the doc must reflect
  that "each target is its own thing", with cross-target symmetry
  living at on-disk layout, not at source form.
- Leaf 040 renamed `racket-oo` → `racket`. The doc still says `racket-oo`
  in places — fix.
- Node 050 produced the chez design spec at
  `docs/specs/YYYY-MM-DD-chez-target-design.md`; the doc should point at
  it as the second concrete example of "what a target's design spec
  looks like".

## Done when
- `docs/adding-a-language-target.md` has no `BindingStyle` /
  `supported_styles` / `default_style` / `{lang}-{paradigm}` references.
- The `LanguageInfo` example uses the post-purge fields only (`id`,
  `display_name`).
- The doc has **two** concrete examples (racket + chez) wherever it
  used to gesture at one.
- The "Step 1: Plan the target" section points at ADR-0005 as the
  canonical statement of the idiom posture every new target inherits.
- A reader following the doc end-to-end could plausibly stand up a
  third target (the doc is no longer hypothetical-paradigm-shaped).
- Pre-existing test suite still green (this leaf is docs-only; no code
  changes expected).

## Notes
- This is the **last** live leaf in the grove. After committing this
  leaf and retiring it, the parent chain walk should empty the grove
  root — at which point the user is asked to confirm grove retirement
  per the grove finish ritual (promote anything brief-level that
  outlives the grove, then `git rm -r .grove/` in one focused commit
  before merging the branch).
- The doc historically lived under `docs/`; keep that location. Don't
  create a parallel target-author guide elsewhere.
