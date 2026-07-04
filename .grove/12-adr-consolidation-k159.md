# adr-consolidation-k159

**Kind:** work

## Goal

Compress the ADR corpus (`adr/0001`–`adr/0053`) into a **minimum coherent set of current-state,
in-place ADRs** per the **D9 policy** (root BRIEF "ADR policy" section) and the
`linkuistics:decision-records` skill. Every ADR must read as the decision **as it now stands**:

- **Fold out all design history** — remove every supersession chain ("supersedes / superseded by
  ADR-N") and every dated "Update — …" / changelog / history section; edit the *owning* ADR in place so
  it states only the current decision (git holds the history).
- **Merge / split / retire** redundant or near-duplicate ADRs so the set is minimum-coherent.
- **Reconcile every inbound citation** the rework touches — the briefs (`.grove/**/BRIEF.md`), the other
  ADRs, `CONTEXT.md`, `docs/`/domain prose, and any code comments — so no ADR reference dangles.

This is the **last workstream** (root BRIEF decomposition #10). It runs **before grove-finish** and
**dovetails with the finish cycle's step 1** ("promote anything from the briefs that should outlive the
grove — ADRs, docs, glossary"). Do **not** run the finish cycle here — it is the next session's, after
this leaf retires.

## Context

Bootstrap reads: `CONTEXT.md`; the root `.grove/BRIEF.md` (the **"ADR policy"** section + every
`… outcomes` section's ADR references); the `linkuistics:decision-records` skill (philosophy, format,
the when-to-write test, edit/merge/split/delete-in-place, identity-by-slug); this task.

- **The D9 policy is already standing.** ADRs from **ws8 onward** were raised current-state / in-place
  (e.g. ws8 folded the machine-KDL decision **into ADR-0046 in place** rather than raising a superseding
  ADR-0053; ws9's **ADR-0053** is a genuinely new current-state decision, not a chain). So the residue to
  compress is concentrated in the **pre-D9 ADRs (0001–0042)** raised before the policy, plus a few known
  spots below. Audit the whole corpus, but expect the newer ADRs to already comply.
- **Known residues flagged by earlier workstreams** (confirm + fix, then sweep for more):
  - **ADR-0046 §k26** — a provenance "Update — …" history section (flagged by ws5 and ws8).
  - **ADR-0024** — migration-narrative "Consequences" prose (the `knowledge/` → `docs/` fold, a
    now-dissolved intermediate `docs/testing/` tree) describing a past restructure rather than the
    current state.
  - Sweep 0001–0042 for supersession language and dated update blocks (the paradigm-retirement,
    IR-format, and target-addition ADRs are the likeliest carriers).
- **ADR home + naming.** ADRs are central at the root **`adr/`** (ADR-0045; ADR-0024 carve-out), named
  `NNNN-<slug>.md`. The `linkuistics:decision-records` skill argues **identity by slug, not number** —
  decide **explicitly** whether de-numbering to pure slug names (`adr/<slug>.md`) is in scope for this
  pass or a churn too large to justify (53 files + every citation). Record the call in this leaf's log.
- **Merges change the numbered set.** If two ADRs merge or one retires, decide how to handle the freed
  number (leave a gap vs renumber) — renumbering ripples into every citation, so prefer leaving gaps
  unless the skill's slug-identity direction is adopted wholesale.

## Done when

- **No ADR contains** a supersession chain or a dated "Update/history/changelog" section; each reads as
  a single current-state decision. (`grep -riE 'supersed|^#+ *update|changelog' adr/` returns nothing but
  legitimate current-state prose.)
- Redundant/near-duplicate ADRs are merged or retired; the set is minimum-coherent.
- **No dangling ADR citation** anywhere outside `.grove/` history (briefs, other ADRs, `CONTEXT.md`,
  domain `docs/`, code) — every `ADR-N` reference resolves to a live ADR.
- **Goldens unchanged** (docs-only) and **`make validate` green**.
- One focused commit naming `adr-consolidation-k159` (or, if decomposed, the node's children each do).

## Notes

- **Audit first.** Enumerate which ADRs carry history / supersession / redundancy before editing —
  produce the worklist, then transform. If the corpus proves large enough to warrant per-cluster
  sessions, `grove-llm leaf-decompose` this into a node and do only the first child this session
  (grove: current-item-proves-bigger → decompose, first child only).
- **Method:** `linkuistics:decision-records` (this pass is the canonical application of it).
- **Golden-neutral** (docs only) — flag loudly if any change would move emit output (it should not).
- After this retires, the grove has no live leaf → the **grove-finish** cycle (propose to the user;
  promote briefs, delete `.grove/`, merge to `main`, remove worktree, `grove-llm complete --done`).
