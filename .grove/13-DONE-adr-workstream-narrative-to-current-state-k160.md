# adr-workstream-narrative-to-current-state-k160

**Kind:** work

## Goal

Finish the ADR consolidation begun in `adr-consolidation-k159`: fold the **workstream-process
coordination narrative** out of the ADR *bodies* so each ADR reads as **the decision as it now
stands**, not as a plan of who-builds-what across the (now-complete) nine workstreams. k159 removed
the mechanical residue — `Status` lines, supersession chains, dated `Update` sections — and did the
merges/citations; **this leaf reconciles the remaining forward-looking / process framing**, which k159
deliberately did not touch (it was beyond that leaf's explicit Done-when bars but is squarely within
the shared Goal "every ADR reads as the decision as it now stands").

Three bands, in priority order:

1. **Factually-stale seam notes (current-state ERRORS — must fix).** Several ADRs still assert a
   *machine JSON Schema owned by workstream 8* — but ws8 **dissolved** that seam (machine IR went
   KDL; `schemas/docs/validation-model.md`: *"There is no JSON Schema anywhere in the stack"*; ADR-0046
   §5). Confirmed carriers: **ADR-0048** (`ws8 owns the machine JSON Schema + validation tooling/CI`),
   **ADR-0049** (`the machine-JSON schema … stay workstream 8`), **ADR-0051** (`the *machine* JSON Schema
   … stay workstream 8`). Sweep for any other "ws-N will build X" where X was later **retired or
   renamed** (e.g. `resolved.json`→`resolved.kdl`, the apply-projection deferral). Reframe to the
   current-state fact (the seam dissolved / the artifact is KDL / the owner domain), not a future promise.
2. **Future-tense "Seams for the remaining workstreams" sections.** ADR-0048/0049/0050/0051/0052/0053
   carry sections that read as "here is what the *next* workstream will own." With all nine workstreams
   complete, fold each into a present-tense **design-boundary** statement (the boundary is real and
   worth keeping — *which domain owns what* — only the future/workstream framing is history). Replace
   `ws8 owns …`/`ws9 will build …` with the domain/artifact that owns it today. Keep the boundary;
   drop the tense and the `wsN` labels where they add nothing.
3. **Dangling grove-leaf pointers.** ADR bodies cite `.grove/` task nodes by handle (`leaf 050`,
   `leaf \`030-design/040-trampoline-layer\``, `grove leaf 090/010`, `this grove`, etc.). After
   grove-finish deletes `.grove/`, these dangle. Decide per-reference: **drop** the pointer (the ADR
   states the decision without needing to name the leaf that produced it — the skill's "discard the
   narrative of how the team arrived there"), or **repoint** to a durable artifact (a doc, an ADR).
   ADR-0001–0003 are *about* grove itself — their "grove" references are the subject, **keep**.

## Context

Bootstrap reads: `CONTEXT.md`; the root `.grove/BRIEF.md` (the **ADR policy** section + the ws2–ws9
outcomes, which name the current domain owners for each seam); the `linkuistics:decision-records` skill
(esp. "discard the narrative of *how the team arrived there*"); the `adr-consolidation-k159` running log
(the D1 keep-numbers / D2 merges decisions this continues); this task.

- **This is the same "reads as current state" mandate, one band deeper.** k159 fixed structure; k160
  fixes the *prose framing*. Use the **ws2–ws9 outcomes in the root BRIEF** as the authority for who
  owns each boundary now (they already restate every seam as a settled fact, e.g. "the ws8 machine-JSON
  seam is **retired, not fulfilled**", "per-target execution hooks are ws6's = the target model's").
- **Keep the boundary, drop the process.** A note like "ws6 consumes the platform model; the model is
  ws6's input, never the projection spec" is a **real current-state boundary** (platform ⊥ projection) —
  reframe it ("projection lives in `targets/`, never `platforms/`"), don't delete it. Only the
  *workstream-scheduling* veneer is history.
- **Golden-neutral (docs only).** As k159: touching only ADR/doc Markdown; flag loudly if any change
  would move emit output (it must not). `make validate` stays green (no `.apiw`/schema touched).
- **Numbering unchanged.** k159's D1 stands — keep `NNNN-<slug>.md` filenames + `ADR-NNNN` citations;
  gaps at 0018/0045 stay gaps. No new merges expected (k159 settled the minimum coherent *set*; k160 is
  prose only), but retire/merge if band-2 reframing surfaces a genuinely redundant pair.

## Done when

- **No ADR asserts a machine JSON Schema** or any other seam ws8 dissolved; `grep -rn 'JSON Schema' adr/`
  returns nothing that contradicts `schemas/docs/validation-model.md`. No "ws-N will build/own X" where X
  was retired or renamed.
- **No ADR body reads as a forward plan of workstream ownership.** The "Seams for the remaining
  workstreams" sections are folded into present-tense design-boundary prose (or removed where the
  boundary is stated elsewhere). `grep -rniE 'seams? for the remaining|will own|remains \*\*ws' adr/`
  is clean.
- **No dangling grove-leaf pointer** in an ADR body (`grep -rniE 'leaf \`|grove leaf|build leaf' adr/`
  resolves to kept-subject references only, i.e. ADR-0001–0003 about grove itself).
- **Goldens unchanged** (docs-only) and **`make validate` green**.
- One focused commit naming `adr-workstream-narrative-to-current-state-k160`.

## Notes

- **Audit first, like k159.** Enumerate the stale-note carriers and the seam-section owners (the root
  BRIEF outcomes give the current owner for each) before editing; produce the worklist, then transform.
- **Method:** `linkuistics:decision-records` (continues k159's canonical application of it).
- After this retires, the grove has **no live leaf** → the **grove-finish** cycle (propose to the user;
  promote briefs, delete `.grove/`, merge to `main`, remove worktree, `grove-llm complete --done`). This
  is now the true last content leaf before finish (k159 handed the second cluster here).
