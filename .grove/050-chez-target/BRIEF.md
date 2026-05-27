# 050-chez-target — brief

## Goal
Ship the `chez` target at full functional parity with the (post-rename)
`racket` target: emitter crate, runtime, Swift dylib, every currently-emitted
framework, all 7 sample apps building and passing TestAnyware. End state is
two-target symmetry on disk and on the CLI.

## Decisions inherited from the 030 grilling

These are the load-bearing decisions already made — they shape every leaf
under this node. Do **not** re-grill them.

1. **Idiom posture (ADR-0005).** chez emits **maximally idiomatic Chez
   Scheme**, not portable R6RS. `(import (chezscheme))`, `foreign-procedure`,
   guardians, condition system, ftype-pointer are all in-scope. The target
   does not run on Larceny/Sagittarius/etc. and does not try to.

2. **Emitter topology — standalone sibling.** `emit-chez/` is a brand-new
   crate next to `emit-racket/` (post-040 rename). Both depend on the shared
   `emit/` crate. No code is shared between the two emitters except via
   `emit/`. The dialect-specific parts (class form, FFI form, module form,
   error handling) diverge enough that a fork would carry dead Racket-isms
   forever.

3. **NSError\*\* shape — `(values result error)`.** Every method that takes
   `NSError**` in ObjC returns two Scheme values: the result, and an error
   (`#f` on success, a Scheme record on failure). Caller uses
   `let-values` / `call-with-values`. Hard-to-reverse (signatures
   everywhere) — ADR-worthy; the 050/010 planning leaf writes it.

4. **Lifetime model — guardian + autoreleasepool.** Each ObjC `id` is
   wrapped in an `objc-object` record registered with a Chez guardian; the
   guardian is drained to send `release` to collected pointers. **Outer
   `@autoreleasepool` wraps every entry point** (event handlers, app `main`,
   FFI callbacks) so transient objects never hit the guardian. Combines
   two mechanisms deliberately — ADR-worthy; the 050/010 planning leaf
   writes it.

5. **Module form — Chez `library` with `(chezscheme)` import.** One
   library per class, one file per library, `main.sls` re-export per
   framework. Mirrors the racket on-disk layout. Inside the library: full
   Chez idiom (foreign-procedure, ftype, guardians), not R6RS subset.

6. **Block bridging — `foreign-callable` + ftype struct layout.** A
   Scheme procedure is wrapped via `foreign-callable` to yield a C
   function pointer; the `Block_layout` and `Block_descriptor_1` structs
   are constructed via `ftype-pointer`. Implementation lives in
   `generation/targets/chez/apianyware/runtime/block.sls`.

7. **Chez implementation — Chez Scheme ≥ 10** (10.4.1 is installed on the
   dev host as of seeding). The ADR-0005 idiom posture explicitly allows
   assuming this version.

8. **Sample-app portfolio — mirror racket 1:1.** Same 7 apps:
   `drawing-canvas`, `hello-window`, `mini-browser`, `note-editor`,
   `pdfkit-viewer`, `scenekit-viewer`, `ui-controls-gallery`. All must
   build and pass TestAnyware before the node retires.

9. **Bundler — sibling crate `bundle-chez/`.** Mirrors `bundle-racket/`'s
   role: package a chez app source tree into a `.app` via the
   `stub-launcher`. Decide details in the planning leaf.

10. **Swift dylib — `libAPIAnywareChez.dylib`, separate from
    `libAPIAnywareRacket.dylib`.** The Swift-side bridge surface is
    target-specific (Scheme values ↔ Swift, not Racket values ↔ Swift),
    so it's a sibling product of the Swift build.

## Done when

- `emit-chez` crate exists, builds, and implements `LanguageEmitter`.
- `generation/targets/chez/` mirrors `generation/targets/racket/`:
  `runtime/`, `lib/`, `apps/`, `docs/`, `generated/`, `README.md`.
- The CLI registry contains both `racket` and `chez`; `--list-languages`
  shows both.
- Every framework that `racket` currently emits also emits under `chez`
  via the CLI (same enriched-IR input, same framework set).
- Sample apps build and pass TestAnyware. The bar is the same as for
  racket — see [[feedback-sample-apps-perfect]].
- ADRs 0006 (NSError shape), 0007 (lifetime model), 0008 (emitter
  topology) are written by the planning leaf as their respective
  designs crystallise — but only those three, per `grilling.md`'s
  "ADRs sparingly" guidance. Mechanical details (module form,
  block-bridge layout, dylib name) live in the design spec / runtime
  source, not in ADRs.
- `knowledge/targets/chez.md` exists with first-pass target-wide
  learnings.
- The `docs/adding-a-language-target.md` rewrite (leaf 060) is **not**
  part of this node's done-criteria; it's a top-level peer that runs
  after this node retires.

## Decomposition

This node begins with a planning task because too many implementation
details remain unresolved to draft a flat plan. The planning leaf grills
the chez design spec into existence, then seeds the work leaves.

Initial leaves (more grow as planning surfaces them):

- `010-design-emit-chez.md` — planning leaf. Writes the chez design spec
  at `docs/specs/<date>-chez-target-design.md`; writes ADRs 0006 (NSError
  shape, citing decision 3 above), 0007 (lifetime model, citing 4), 0008
  (emitter topology, citing 2); optionally writes a PRD if the design hits
  a clear agreement point; grows work leaves under this node for:
  emit-chez crate scaffold, runtime scaffold, framework emission, swift
  dylib, sample-app ports.

## Pointers
- ADRs to read at this level: `docs/adr/0004-retire-paradigm-dimension.md`,
  `docs/adr/0005-chez-target-emits-idiomatic-chez.md`. (Grove-internal
  ADRs 0001–0003 are about grove itself; not needed here.)
- Glossary terms in play: **Target**, **Target idiom**, **Binding style**
  — see `CONTEXT.md`.
- Reference code:
  - `generation/crates/emit/src/binding_style.rs` — the `LanguageEmitter`
    trait and `LanguageInfo` (the chez emitter implements both).
  - `generation/crates/emit-racket/` (post-040; today `emit-racket-oo/`) —
    reference shape only; *not* a fork base.
  - `generation/targets/racket/runtime/` (post-040) — every Racket
    runtime file has a chez counterpart to design. `block.rkt`,
    `dynamic-class.rkt`, `delegate.rkt`, `cf-bridge.rkt`,
    `objc-base.rkt`, `objc-subclass.rkt`, `type-mapping.rkt`,
    `swift-helpers.rkt`, `main-thread.rkt`, `coerce.rkt` are the
    interesting ones.
- Prior art: project memory entry [[project-grove-skill]] notes a chez
  decomposition done 2026-05-23 that is **not** on main. Surviving
  intent there matches the inherited decisions above (slug `chez`,
  guardian-managed objects, `(values result error)`, R6RS library per
  class) — but with the 030 grilling's refinements layered on
  (autoreleasepool, idiom-not-portable, Chez `library` with `(chezscheme)`
  import). Treat the prior decomposition as confirmation, not as a plan
  to copy.

## Notes
- The Swift bridge surface (`libAPIAnywareChez.dylib`) is its own subproject
  — likely sized like a couple of leaves rather than one. The planning
  leaf decides whether it's a single work leaf or its own sub-node.
- TestAnyware harness for chez apps will need the same VM-driven
  pipeline as racket; sample-app validation cannot run from the CLI.
  See [[feedback-use-testanyware]].
- Regenerate the pipeline aggressively after any source change in
  emit-chez or the chez runtime — see
  [[feedback-regenerate-pipeline-aggressively]].
