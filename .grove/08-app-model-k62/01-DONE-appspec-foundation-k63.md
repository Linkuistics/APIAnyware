# appspec-foundation-k63

**Kind:** work

## Goal

Lay the ws7 **foundation**: make `apps/macos/` state the APIAnyware↔AppSpec↔TestAnyware
**relationship** + the **data boundary**, record the load-bearing decision as an ADR, and
reconcile the **glossary**. Skeleton-first and deliberately format-flexible — this child
establishes *meaning and boundary*, not a rigid file layout (the layout firms once the
AppSpec grove settles what a "formal spec" is — node BRIEF D5).

## Deliverables

1. **ADR-0052** (`adr/0052-appspec-external-llm-driven-toolkit.md`) — *AppSpec is an
   external LLM-driven spec/test toolkit; APIAnyware consumes it.* Records: the three-layer
   boundary (TestAnyware substrate → AppSpec toolkit, no app data → APIAnyware app data);
   APIAnyware *consumes/references* AppSpec per REFACTOR §34, does **not** reinvent it; **no
   grove-native `.apiw` AppSpec entity / schema / validator** (the deliberate asymmetry from
   the grove's `.apiw`-everywhere convention — justified because the concept is owned by an
   external project; supersedes the brief's presumed "ws7 authors the AppSpec `.apiw` Schema +
   validator" + the ws8/ws9 seams that presumed it); the **generated-spec model** (LLM
   reverse-gen from an impl + human-validate, mirroring ws5's git-as-review-boundary; suites
   forward-gen from specs + guidelines + attack-vectors + patterns, human-validated);
   structural facts (app-kind/coverage/display-name) stay **prose** until a machine consumer
   needs them (D3); the AppSpec toolkit is developed in **its own grove** at a pause point (D5).
   Cite REFACTOR §15/§16/§33/§34, ADR-0049 (the app-kind category side), ADR-0050 (the ws5
   git-review parallel). Follow `adr/README.md` / ADR-FORMAT.

2. **`CONTEXT.md` glossary reconcile** — a new **App model / AppSpec** section adopting the
   AppSpec project's vocabulary (authority = `~/Development/AppSpec` `CONTEXT.md`): **AppSpec
   (the project)**, **App**, **Implementation/impl** (*avoid "target"*), **Scenario**,
   **Scenario suite**, **Contract**, plus **reverse-gen / forward-gen**. Explicitly
   **disambiguate the three colliding "AppSpec" meanings**: (1) the external project [the
   authority]; (2) the briefs' loose "common app-spec entity" use [now → "the app's AppSpec
   data under `apps/macos/<app>/`"]; (3) the bundler Rust struct
   `apianyware_bundle_racket::AppSpec` [Info.plist/signing bundle config — unrelated; flag the
   collision]. Terse glossary entries only (CONTEXT-FORMAT discipline — no implementation
   detail).

3. **`apps/README.md` + `apps/macos/README.md` rewrite** — replace the stale "promote each
   spec.md to a first-class AppSpec" TODO with the settled model: `apps/macos/<app>/` is the
   home of each app's **AppSpec data** (description/spec/PRD + future generated suites +
   contracts), authored against the **external AppSpec project's** format and run by its
   runner over TestAnyware; the data boundary; the LLM-driven reverse/forward-gen +
   human-in-the-loop workflow; a *format-still-forming* note (layout finalizes after the
   AppSpec grove); pointers to `~/Development/AppSpec`, REFACTOR §34, ADR-0052. Keep it a map,
   not a spec.

## Out of scope (externalize — do NOT absorb)

- **No per-app prose reconciliation / file moves / `spec.md`→`overview.md` rename** — layout
  firms later; the bundler display-name read stays on `spec.md` (zero churn this child).
- **No reverse-gen of any app's spec** — that is the *next* child (the exemplar).
- **No AppSpec-grove build, no seeds, no test suites** — later children / the pause point.

## Done when

ADR-0052 committed; `CONTEXT.md` carries the reconciled app-model vocabulary; `apps/README.md`
+ `apps/macos/README.md` state the boundary/relationship + the generated-spec model. Pipeline
untouched (doc/ADR/glossary only — goldens cannot move). Commit names the handle
`appspec-foundation-k63`.

## Notes

Reference: node `BRIEF.md` (Decisions running log D1/D2/D2′/D3/D5 — the converged design);
`~/Development/AppSpec` (`README.md` + `CONTEXT.md` — the authority on AppSpec's vocabulary +
boundary); REFACTOR §15/§16/§33/§34; ADR-0049 (app-kinds, the category side), ADR-0050 (ws5
git-as-review-boundary, the philosophical parallel).
