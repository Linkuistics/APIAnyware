# remove-paradigms — brief

## Goal
Retire the **paradigm / binding-style dimension** from APIAnyware: one
target = one binding style, implicit in the target and not reified as data.
Delete the `BindingStyle` enum and the speculative variants that have never
produced output, and rename the lone surviving target `racket-oo` → `racket`.

The driving principle: each target's idioms are best expressed in *one*
binding style. The dimension was YAGNI made concrete — only
`BindingStyle::ObjectOriented` has ever been emitted. Collapsing it
sharpens the existing target's identity and makes adding the next target
(Chez, …) materially simpler. The escape hatch — should some future target
genuinely want two flavours — is to register two targets, not to
reintroduce the dimension.

## Done when
- ADR `0004-retire-paradigm-dimension.md` is on `main`, recording the
  decision, the rationale, and the two-targets escape hatch.
- `BindingStyle`, `LanguageInfo::supported_styles` / `default_style`, the
  `style: BindingStyle` parameter on `LanguageEmitter::emit_framework`,
  and the misleading multi-paradigm docstring at the head of
  `generation/crates/emit/src/binding_style.rs` are gone.
- The nested `generated/oo/<framework>/` output directory has been
  flattened to `generated/<framework>/`.
- The `racket-oo` identity slug is renamed to `racket` everywhere it is
  an identity: target directory, emit/bundle crate names, Cargo workspace
  members, CLI `--lang`, knowledge target/matrix files, READMEs, website,
  docs. Mechanism names that are not identity (e.g.
  `runtime/objc-subclass.rkt`) are left alone.
- The pipeline (collect → analyse → generate) and the snapshot / smoke /
  sample-app tests pass with the dimension removed; snapshot fixtures are
  regenerated for the new output layout.

## Decomposition
Two leaves seeded now — lazy decomposition per the grove spine. The
remaining work (the rename, the doc sweep, the validation gate) becomes
subsequent leaves grown by a later planning task that can look at the
real post-purge diff.

- `010-adr-paradigm-retirement` — write ADR-0004 and link it from
  `BRIEF.md` and `CONTEXT.md`. Small, no code change.
- `020-purge-binding-style-machinery` — delete the enum, drop the `style`
  parameter, drop `supported_styles` / `default_style`, flatten
  `generated/oo/`. **Does not** rename `racket-oo` → `racket` — that lands
  as a later leaf so each diff stays mechanically reviewable.

## Pointers
- ADRs a session here must read: `docs/adr/0004-retire-paradigm-dimension.md`
  (raised by leaf 010; cited from leaf 020 onward).
- Glossary terms in play: **target**, **binding style**, **paradigm**
  (retired). See `CONTEXT.md`.
- Design specs: none — this is internal cleanup, no PRD warranted.

## Notes
- The Rust trait names `LanguageEmitter` / `LanguageInfo` and the CLI
  flag `--lang` are intentionally **out of scope** despite reading as
  "language" rather than "target". See the flagged ambiguity in
  `CONTEXT.md`. That cleanup earns its own grove if it earns anything.
- Sample apps live under `generation/targets/racket-oo/apps/`; the
  rename cascades the path. Per standing user guidance, any GUI
  verification happens in a macOS VM via TestAnyware, never from the CLI.
- This grove was originally floated as a prerequisite of a `chez` grove;
  it stands alone because the retirement is repo-wide and downstream
  groves (Chez, future targets) will depend on it.
