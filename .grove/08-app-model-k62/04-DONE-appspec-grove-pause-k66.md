# appspec-grove-pause-k66

**Kind:** work (a pause-point / hand-off leaf — the work *is* running another grove)

## Goal

The **pause point** of workstream 7 (ADR-0052 step 5; node BRIEF child 4): hand off from
`structural-refactoring` to the **AppSpec toolkit grove**, run that grove to completion,
then resume here. k65 (`build-appspec-grove-k65`) authored the seed/PRD and staged the
cross-grove seeds in this repo; k66 performs the actual **delivery + initialization +
run** — the steps k65 deliberately could not, because the AppSpec grove did not yet exist
and this grove must not edit the AppSpec repo until the hand-off (Q-boundary).

## The hand-off (the carrier checklist from the seed §6)

The durable seed is `apps/macos/docs/appspec-toolkit-seed.md` (committed in this repo).
Its companions are `apps/macos/docs/reverse-gen-workflow.md` and
`apps/macos/hello-window/docs/spec.md` (the format-inputs). To run the hand-off:

1. **Read** the seed + its two companions. They carry: the three-capability vision
   (reverse-gen / forward-gen / run), the reconciliation of AppSpec's *dormant-but-working
   v1 substrate* (§2), the proposed grove decomposition (§4), and the three cross-grove
   seeds (§5: capability shapes; spec/PRD format; the patterns/attack-vectors/guidelines
   **open interface question**).
2. **Initialize the AppSpec grove** (now permitted — this is the hand-off): `cd
   ~/Development/AppSpec`; confirm there is no live `.grove/` (v1's grove is finished);
   `grove-llm root-init appspec-toolkit` (or a slug of choice). Note: `grove-llm
   inbox-add` does **not** exist (seed §6) — there is no inbox to drain; seed the new
   grove's first planning leaf directly from the seed doc instead.
3. **Seed the first planning leaf's brief** from the seed's §3 (vision) + §4
   (decomposition spine) + §5 (the three seeds); **home the durable PRD parts** under
   `~/Development/AppSpec/docs/prd/` (the AppSpec grove owns its repo now).
4. **Run the AppSpec grove** (`grove do appspec-toolkit` from `~/Development/AppSpec`) to
   completion — the toolkit is *"largely prompts + workflows"* (reverse-gen capability,
   spec/PRD format firming, forward-gen capability, run generalization, end-to-end proof
   on hello-window). **This is a separate grove and a separate effort**; k66 is the marker
   that it runs *here* in the sequence, not that this session executes all of it.
5. **Resume `structural-refactoring`** and retire k66.

## Scope / boundary

- The AppSpec grove is a **distinct grove in a distinct repo**; its internals (the
  cleanup that de-couples Modaliser app data out of the toolkit, the path-drift repoints,
  the generators) are **its** work, not this grove's. k66 *starts and runs* it; it does
  not pre-decide its decomposition (grove is for incremental discovery).
- Resolving seed 3's open interface question (forward-gen patterns/attack-vectors vs
  APIAnyware's `semantic/pattern-kinds`) is the **AppSpec grove's** call, informed by the
  recommendation in the seed (keep distinct + reference by id). If it concludes APIAnyware
  must *change* a `semantic/`/`platforms/` entity to support the interface, that returns
  here as a **new ws3/ws4 leaf** (externalize, don't absorb).

## Done when

The AppSpec toolkit grove has been initialized, seeded from
`apps/macos/docs/appspec-toolkit-seed.md`, and **run to completion** (its own grove-finish
cycle); the AppSpec project now owns its toolkit + firmed spec/PRD format. The hand-off
back is legible: whatever the AppSpec grove settled the "formal spec" format to be is
known, so the **post-pause ws7 children can be grown on k66's retirement** —
- **forward-gen suites + AppSpec-runner VM-verify** for the sample apps (one VM-verified
  leaf per app; standing rule [[vm_verify_every_app]]),
- **`apps/macos/` layout-finalize** (now that the format firmed),
- **portfolio index + conformance/coverage tie-in**.

Commit names `appspec-grove-pause-k66`.

## Hand-off log (2026-06-26 — delivery + initialization done; pause open)

The hand-off (carrier checklist steps 1–3) is **complete**; the AppSpec grove is
initialized, seeded, and ready to drive. **k66 stays live** — the pause is open until the
AppSpec grove is *run to completion* (step 4), which is its own self-driving effort.

**Delivered into `~/Development/AppSpec` (branch `appspec-toolkit`, commit `f197b64`):**
- `.grove/` — root `BRIEF.md` (toolkit workstream charter) + first planning leaf
  `01-appspec-toolkit-k1.md` (grill + decompose; agenda seeded from PRD §3/§4/§5).
- `docs/prd/2026-06-26-appspec-toolkit.md` — the durable workstream PRD (vision, v1-substrate
  reconciliation, skeleton-first decomposition spine, the three cross-grove seeds), reframed
  AppSpec-native from this repo's `apps/macos/docs/appspec-toolkit-seed.md`.
- `docs/prd/seed-inputs/{reverse-gen-workflow,hello-window-spec}.md` + `README.md` — the two
  companion format-inputs, copied byte-identical as frozen reference data (not AppSpec app
  data — ADR-0052 boundary held).
- AppSpec `main` left **pristine** (no `.grove/`, no grove state); the bootstrap lives on the
  `appspec-toolkit` branch so `grove do` takes its clean resume path (branch present, worktree
  gone → re-attach).

**Confirmed at hand-off:** no live `.grove/` and no `grove-meta` branch on AppSpec `main`
(the v1 grove was finished + deleted — seed §2 prediction held); `grove-llm inbox-add` does
not exist (seed §6) — delivery used the durable-PRD route, not an inbox push.

**Resume condition (for the future session that re-picks k66):** check whether the AppSpec
grove has finished (its `grove do appspec-toolkit` finish cycle ran — branch merged/removed,
or `pick` there reports no live leaves). If finished, **retire k66** and grow the post-pause
ws7 children (forward-gen suites + AppSpec-runner VM-verify; `apps/macos/` layout-finalize;
portfolio index + coverage tie-in — see "Done when"). If not, the pause remains open.

**Next action (human-driven):** `cd ~/Development/AppSpec && grove do appspec-toolkit`.

## Resume log (2026-07-02 — pause closed; k66 retired)

**The AppSpec toolkit grove ran to completion** — the resume condition holds on every
check: `~/Development/AppSpec` is back on `main` only, `.grove/` deleted ("Finish
appspec-toolkit grove: delete .grove/ task tree", `6c999cc`), the `appspec-toolkit`
branch merged + removed. The toolkit's settled shape: three capabilities at
`capabilities/{reverse-gen,forward-gen,run}/`, each with `workflow.md` (+ `prompt.md` /
`validation.md` for the two generators); the final leaves adjudicated the cross-impl
acceptance verdict and authored run's `workflow.md`.

**What landed here during the pause** (cross-grove records k67–k74, per ADR-0013 /
ADR-0052 — AppSpec drives, APIAnyware homes the data): hello-window went end-to-end —
conformance data (k67), per-target instrument+build ×4 (k68–k71), the forward-gen
suite (k72), and Tier-2 live runs with **all four impls 3/3** (k73 chez/sbcl/gerbil;
k74 racket). The "formal spec" format is thereby firmed as the hello-window shape:
`docs/{spec,logging-contract,observable-state,run-results}.md` + `scenarios/*.rkt` +
`run-values.rkt`.

**Post-pause children grown on this retirement** (the Done-when list + the two
carried-back run findings, externalized not absorbed):

- `sbcl-vendor-libzstd-k75` + `racket-self-contained-bundle-k76` — the k73/k74 build
  findings (sequenced first: every later live run pays the provisioning cost they remove).
- `appspec-{ui-controls-gallery,pdfkit-viewer,scenekit-viewer,mini-browser,note-editor,
  drawing-canvas,swift-native-probe}-k77..k83` — one AppSpec-cycle leaf per remaining
  app, each carrying the live-VM done-bar ([[vm_verify_every_app]]); each expected to
  `leaf-decompose` on entry (hello-window took 8 leaves).
- `apps-layout-finalize-k84` (incl. `test-strategy.md` disposition, bundler
  display-name decision, the k74-licensed `(to confirm in-VM)` marker drop) and
  `portfolio-coverage-tie-in-k85` (closes the node k62 Done-when).

Housekeeping: the run-harness's cwd-relative `spec/artifacts/` dump (untracked debris
from the pause-period live runs; `runner/lifecycle.rkt` writes it under the invoking
cwd) is now gitignored — the durable record is each app's `docs/run-results.md`.

## Notes

Reference: `apps/macos/docs/appspec-toolkit-seed.md` (the seed/PRD + the three seeds + the
carrier checklist + the `inbox-add` tooling-gap note); ADR-0052; node `app-model-k62`
BRIEF (D5 — ws7's deliverables + the deferred post-pause children); the root brief's
*App model* decomposition #7. If running the full AppSpec grove in-session proves too
large for one focused session, that is expected — the AppSpec grove is self-driving
(`grove do`), and k66 is retired once it has finished and this grove resumes.
