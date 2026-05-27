# APIAnyware macOS bindings

This repo generates language-native bindings to the macOS system frameworks
(collect → analyse → generate pipeline) and ships sample apps that exercise
those bindings on real macOS.

## Language

**Target**:
A complete pipeline output for one language — its emitter crate, bundler
crate, runtime support, sample apps, and knowledge files. Examples:
`racket` (current), `chez` (planned). The on-disk unit is
`generation/targets/<name>/`.
_Avoid_: language (ambiguous — source-language? target-language?),
platform (means macOS, not the destination of generation).

**Binding style**:
The shape in which a target exposes its generated APIs (e.g. class-and-method
vs. plain-function). After paradigm-retirement, exactly **one** binding style
per target — implicit in the target, never reified as data or selected at
the CLI.
_Avoid_: paradigm, style (alone), flavour.

**Target idiom**:
The *style* of source a target's emitter writes. Each target commits to
**maximum idiom compliance for its specific implementation** — not to a
portable subset shared across implementations of the same language family.
For chez this means `(import (chezscheme))`, `foreign-procedure`, guardians,
and any Chez extension that makes the generated code read like code a Chez
programmer would actually write; it explicitly does **not** mean "portable
R6RS that any Scheme can load". Cross-target symmetry lives at the on-disk
layout level (per-class files, `main` re-export, runtime/ + generated/
layout) and at the IR-decision level (what gets emitted), not at the
source-form level (how it's spelled).
_Avoid_: portable, dialect-neutral.

**`objc-object`**:
The single Scheme record type wrapping an ObjC `id` pointer. Used uniformly by
**both** targets (`racket` and `chez`) — no per-class record subtype exists;
generated class files are namespaces of procedures keyed by class, not record
hierarchies that mirror the ObjC class graph. For chez specifically, the
record's lifetime is managed by a Chez guardian rather than per-instance
finalizers — see `docs/adr/0007-chez-lifetime-model.md`.
_Avoid_: `objc-handle`, `objc-ref`, `nsobject` (the last clashes with the
class).

**Entry-point autoreleasepool**:
The convention that every **outer entry into Scheme-driven ObjC code** — the
app `main`, every event handler dispatched from `NSRunLoop`, every callback
invoked from the ObjC side (delegate methods, blocks, `foreign-callable`
trampolines) — wraps its body in an `@autoreleasepool`. Transient
autoreleased objects produced during the entry's lifetime drain at the pool
boundary and never reach the guardian. Specific to the chez lifetime model;
the racket runtime relies on per-thread autorelease pools instead. See
`docs/adr/0007-chez-lifetime-model.md`.
_Avoid_: "main pool" (ambiguous with NSRunLoop's autorelease pool).

**Paradigm** _(retired)_:
Formerly a dimension reified by the `BindingStyle` enum
(`ObjectOriented | Functional | Procedural`), allowing one target to emit
multiple binding styles from the same enriched IR. Retired: only
`ObjectOriented` was ever produced; the other variants were speculative
scaffolding. **If a future target genuinely needs two flavours, register
two targets** (e.g. `chez-class`, `chez-functional`) rather than
reintroducing this dimension.
_Avoid_: do not reuse this word in the new design.

## Flagged ambiguities

- **Target vs. Language.** The Rust trait is `LanguageEmitter` /
  `LanguageInfo` and the CLI flag is `--lang`, but the on-disk unit is
  `generation/targets/<name>/` and includes more than an emitter (runtime,
  sample apps, bundler). Canonical term: **target**. Renaming the trait /
  flag is in-scope for the paradigm-retirement grove only if it falls out
  naturally from other edits; otherwise follow-up work.

## Example dialogue

> **Dev**: Should we add a `--style functional` to the CLI for the new Chez
> target so it shares the racket emitter?
>
> **Domain**: No — the paradigm dimension is retired. If Chez wants a
> functional shape, it's a separate **target** (`chez` or `chez-functional`)
> with its own emitter crate, its own sample apps, its own knowledge entries.
> The CLI only knows about targets; binding style is implicit per target.
