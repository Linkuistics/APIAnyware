# 020-chez-library-loading

**Kind:** planning

## Goal
Settle how the chez target resolves `(import (apianyware …))` library
references — both unbundled (`chez --script
generation/targets/chez/apps/<app>/<app>.sls` from the worktree root)
and bundled (`Resources/chez-app/apps/<app>/<app>.sls` inside the
`.app`). Currently neither works: chez's default name-to-path
algorithm maps `(apianyware runtime objc)` to
`<libdir>/apianyware/runtime/objc.sls`, but the source tree has
`runtime/objc.sls` and `generated/<fw>/<cls>.sls` (no `apianyware/`
prefix on disk), and the bundle layout in design spec §8 mirrors that
shape.

This leaf is **planning** — grill the options with the user, pick one,
record the decision (ADR-worthy if non-trivial; design-spec update is
likely), then either land the implementing changes in this leaf or
seed a sibling work leaf for them.

## Context
- Empirical evidence (this leaf was seeded after a failed attempt):
  `CHEZSCHEMELIBDIRS=generation/targets/chez chez --import-notify
  --script .../hello-window.sls` shows chez searching
  `<libdir>/apianyware/runtime/objc.{sls,ss,scm,...}` — no fallback.
- `generation/targets/chez/runtime/verify.ss` works around this by
  pre-loading each runtime file with `(load …)` before any `(import
  …)`. Doesn't scale: the entry script can't know every framework
  file the app transitively pulls in.
- `generation/crates/bundle-chez/scripts/extract-deps.ss` already
  computes the transitive file set, so the bundle copies the right
  files — the gap is purely about telling chez where to look.
- Design spec §8 bundle layout:
  ```text
  Resources/chez-app/
    apps/<script>/<script>.sls
    runtime/*.sls
    generated/<fw>/*.sls
    lib/libAPIAnywareChez.dylib
  ```
- The Swift stub today execs `chez --script <bundle-path-to-entry>`
  with no env-var setup and no extra flags
  (`generation/crates/stub-launcher/src/generate.rs`).

## Options to grill (recommended order)

The grilling should compare these against:
- Symmetry with racket (which uses relative `(require "../foo.rkt")` —
  no library-name resolution involved).
- Effort + churn.
- Robustness (does it survive both unbundled and bundled runs without
  per-app shims?).
- ADR-0005 idiom posture (idiomatic Chez wins over portable hacks).

1. **Source-tree rearrange.** Move
   `generation/targets/chez/runtime/*` →
   `generation/targets/chez/apianyware/runtime/*`, and
   `generation/targets/chez/generated/<fw>/*` →
   `generation/targets/chez/apianyware/<fw>/*`. Update the emitter
   output dir + the bundle layout + verify.ss. Then unbundled
   `chez --libdirs generation/targets/chez --script <entry>` and
   bundled `chez --libdirs Resources/chez-app --script <entry>` both
   resolve naturally. Adds the `--libdirs` flag to the stub's
   `runtime_args`.
2. **Custom `library-search-handler` in a bootstrap library.** Keep
   the source tree shape. Ship a hand-written
   `runtime/bootstrap.sls` (or similar) that, when first imported,
   installs a `library-search-handler` mapping
   `(apianyware <category> <name>...)` to the on-disk convention.
   Every entry script imports the bootstrap as its first form.
   Chez-idiomatic; no source-tree churn; but the bootstrap must be
   reachable *before* the handler is installed — chicken-and-egg
   the bootstrap itself can sidestep by being loaded via `(load …)`
   from the entry, or via `--libdirs runtime` since `(apianyware
   bootstrap)` would resolve under `runtime/apianyware/bootstrap.sls`
   if we cheat one file's path.
3. **Symlink farm.** Create a synthetic `apianyware/` directory under
   `generation/targets/chez/` with subdirectory symlinks
   (`apianyware/runtime → ../runtime`,
   `apianyware/<fw> → ../generated/<fw>` per framework). Same farm
   gets recreated in the bundle. Cheap to mechanise but: 284
   symlinks per bundle is ugly, breaks `find`/`grep` ergonomics,
   and double-counts files for tools that follow symlinks.
4. **Per-script bootstrap inline.** Every entry script begins with
   `(import (chezscheme))` + a manual
   `library-search-handler` install + then the real
   `(import (apianyware …))` forms. Self-contained per app, but
   duplicates the bootstrap in every app and survives only as long
   as authors paste it correctly.

These are the options I'd start with — the grilling should challenge
them and surface anything missed.

## Done when
- A grilling session reaches a decision the user signs off on.
- Either ADR-0009 (or the next free number) records the decision, or
  — if the choice is mechanical — a one-paragraph update to
  `docs/specs/2026-05-27-chez-target-design.md` §8 captures it.
- Either the implementation lands in this leaf, or a sibling work
  leaf is seeded with the concrete tasks.
- Unbundled `chez --script` of `hello-window.sls` (or a minimal
  equivalent if 030 hasn't run yet) loads its `(apianyware …)`
  imports without an `Exception: library … not found`.

## Notes
- Don't pre-commit to a specific option; the grilling is the work.
- Whatever's chosen must work for **all** future apps, not just
  hello-window. The 110–140 sample-app ports will inherit the
  decision.
- If the answer is "rearrange the source tree", expect ~3 small
  follow-up leaves (emitter output dir, bundle layout, verify.ss +
  README updates) rather than packing it all here.
