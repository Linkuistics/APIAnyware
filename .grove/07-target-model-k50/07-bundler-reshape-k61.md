# bundler-reshape-k61

**Kind:** work

## Goal

The **seventh and final** child of ws6 (`target-model-k50`, D7): discharge the **D6 bundler
residuals** and **re-sync the new-target guide's step paths** to the domain tree. This is the
clean-up child that closes the gap the skeleton's relocate left open — the bundlers still want a
single colocated `source_root`, and `targets/_shared/docs/adding-a-language-target.md` still narrates
the pre-refactor `generation/`-era layout. No new authored `.apiw` entity, no new model: this is the
last buildable-step of the skeleton-first reshape (root D4). On its retirement, ws6
(`target-model-k50`) has no live leaf left → it is implicitly done (confirm node-done with the user;
ws6 was the workstream most others fed, so promote its durable seams to the **root** brief), and the
root grows the next workstream lazily (ws7 apps / ws8 schemas / ws9 testing).

## Context (the D6 residuals + the established doc-set shape)

**The two D6 bundler residuals** (target-model-k50 brief D6; `TODO.md` "Two residual ws6 items"):

1. **The bundler wants a single colocated `source_root`; the §18 split moved apps and bindings
   apart.** Each `bundle-<t>` reads apps + the binding package root + the dylib from **one** root, but
   the domain tree puts app-implementations under `targets/<t>/app-implementations/macos/<app>/` and
   the binding package root + dylib under `targets/<t>/bindings/macos/`. The emit-dependent bundler
   tests currently **stitch one root back with a directory-symlink fixture**
   (`racket_root`/`gerbil_root`/`chez_root`). **Teach the four bundlers
   (`targets/{racket,chez,gerbil,sbcl}/tools/bundle-<t>`) the apps-root / bindings-root split
   natively**, so the symlink fixture is no longer needed.
2. **`bundle-racket/examples/bundle_app.rs` reads a stale spec path.** It still reads app specs from
   `knowledge/apps/<app>/spec.md`; the spec now lives at `apps/macos/<app>/docs/spec.md` (the test
   path was already repointed in `migration-finalize-k10`, but the example was parked for ws6 because
   it cannot bundle from the new tree until the bundler learns the split). Fix the example read.

**Adjacent test-guard cleanup** (`TODO.md` note): chez's closure-walk test
`computes_hello_window_collision_set` (in `bundle-chez`) has the same committed-runtime guard shape
the other bundler tests had, but is `#[ignore]`d (heavy ~75 s, needs chez) so it escaped the
`migration-finalize-k10` emit-present-guard sweep. **Fold an emit-present guard into it** now that ws6
is touching the chez bundler (the TODO explicitly defers this to "whenever ws6 next touches the chez
bundler" — that is now).

**Re-point the bindings-README markers.** The racket + chez `bindings/macos/README.md` "Open
follow-ups" sections carry markers explicitly parked **→ ws6 child 7 (bundler reshape)**: the dylib
home (`lib/` vs §42's `build/`) and "bundler expects a single colocated `source_root`". Resolve or
re-state these as this child discharges them (gerbil/sbcl have no bindings README — see below).

**The new-target guide is `generation/`-era.** `targets/_shared/docs/adding-a-language-target.md`
(25k) still narrates the **pre-refactor** layout throughout — `generation/crates/<crate>`,
`generation/targets/{id}/`, `generation/targets/{id}/runtime/`, `knowledge/apps/`,
`generation/crates/cli/src/registry.rs`, `generation/targets/{id}/test-results/`, etc. **Re-sync every
step path** to the domain tree: crates at `<domain>/tools/<crate>` (skeleton crate-home convention) /
`targets/<t>/tools/<crate>`, the shared emit substrate at `targets/_shared/` (ADR-0044), runtimes at
`targets/<t>/bindings/<platform>/runtime/`, app-implementations at
`targets/<t>/app-implementations/<platform>/<app>/`, VM-verify reports at
`targets/<t>/bindings/<platform>/reports/`, specs at `apps/macos/<app>/docs/spec.md`. (The guide's
own header already flags it describes the pre-refactor structure — this is the resync that clears
that banner.)

**Bake doc-production into the guide (the mapping-docs-k56 outcome).** ws6 child 6 established the
**per-target doc-set shape**, now durable across all four live targets: each target carries **§18
target docs** at `targets/<t>/docs/{overview,language-characteristics,ffi-model,idiom-map,
representability}.md` (a map + four deep-dives, the §18 `idiom-map.md` a thin pointer to the
authoritative `idioms/docs/idiom-map.md`) and **§22 binding mapping docs** at
`targets/<t>/bindings/<platform>/docs/{user-guide,platform-docs-mapping,api-coverage,
unsafe-escape-hatches}.md` — every doc *pointing at* the target's authored `.apiw` entities and
citing `apianyware-conformance` for derived coverage (constraint 4, no recomputable facts copied).
A target with a deep `reference.md` but no `developer-guide.md` (chez/gerbil/sbcl) makes the §22
`user-guide.md` its primary user doc. **The guide-resync must add this doc-production step** so a
fifth target produces its doc layer by following the guide (restructure-docs rule: docs co-located
beside their subject; ADR-0024 ADRs stay central).

## Done when

- The four `bundle-<t>` crates bundle natively from the **apps-root / bindings-root split** (no
  symlink fixture); `bundle-racket/examples/bundle_app.rs` reads `apps/macos/<app>/docs/spec.md`;
  chez's `computes_hello_window_collision_set` carries an emit-present guard; the racket/chez
  bindings-README ws6 markers are discharged. **Goldens unmoved** (a bundler reshape is a packaging
  concern, not an emit change — root brief "goldens-as-truth" gate); workspace + the bundler tests
  green (emit-present tests stay skip-as-pass on a clean checkout with no local
  `apianyware-generate` run — that discipline is preserved, not regressed).
- `targets/_shared/docs/adding-a-language-target.md` step paths are re-synced to the domain tree
  (zero `generation/`-era paths remain in live steps), and it carries the §18/§22 **doc-production
  step** (the mapping-docs-k56 doc-set shape).
- `TODO.md`'s "Two residual ws6 items" + the chez-test note are struck (or updated to reflect
  completion); any remaining cross-ws residual is left for its owning workstream, not absorbed here.

## Notes

- Commit handle: `bundler-reshape-k61`. **Final ws6 child** — on retire, `target-model-k50` (ws6) is
  implicitly done: confirm node-done with the user, then promote ws6's durable seams to the **root**
  brief (a "Target-model outcomes" block mirroring the existing skeleton/spec-format/semantic/platform/
  llm-side-channel promotions): the authored-vs-derived entity split (D1), the 7-rung
  capability/representability ladder + `weirdness → capability` floor (D2/ADR-0051), the one shared
  `targets/_shared/tools/target-model` crate (D5), the data-driven `pattern_dispatch` seam with
  *apply-projection* deferred (D3), the established per-target doc-set shape (child 6), and the
  standing ws7/ws8/ws9 seams (D6). The root then grows ws7/ws8/ws9 lazily.
- **Scope discipline:** this is packaging + docs, **not** an emit change and **not** the deferred
  *apply-projection* follow-on (D3 — that moves goldens in all four targets and is a separate,
  golden-intentional grove). If applying projection or any golden-moving work surfaces, externalize it
  as its own leaf, don't absorb it.
- Reference: target-model-k50 brief D6/D7; `TODO.md` (ws6 residual section); the skeleton crate-home
  convention + ADR-0044 (`targets/_shared/`); the four targets' now-complete doc sets as the
  doc-production exemplar.
