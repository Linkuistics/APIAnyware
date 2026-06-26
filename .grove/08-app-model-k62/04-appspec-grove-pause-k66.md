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

## Notes

Reference: `apps/macos/docs/appspec-toolkit-seed.md` (the seed/PRD + the three seeds + the
carrier checklist + the `inbox-add` tooling-gap note); ADR-0052; node `app-model-k62`
BRIEF (D5 — ws7's deliverables + the deferred post-pause children); the root brief's
*App model* decomposition #7. If running the full AppSpec grove in-session proves too
large for one focused session, that is expected — the AppSpec grove is self-driving
(`grove do`), and k66 is retired once it has finished and this grove resumes.
