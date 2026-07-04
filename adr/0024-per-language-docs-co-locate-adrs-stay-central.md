# Docs co-locate with their subject; the cross-cutting ADR/PRD log stays central at top-level `adr/`/`prd/`

Documentation splits into two tiers by the same axis ADR-0011 uses for code, and
there is **no large top-level `docs/` directory** (REFACTOR.md §10): documentation
lives beside the thing it documents. **Per-subject docs co-locate** inside the unit
they describe — a target's reference, design spikes, FFI model, and per-app
realization notes live under `targets/<lang>/docs/` (+ per-app `learnings.md`); a
domain's docs live in that domain (`semantic/docs/`, `platforms/macos/docs/`,
`schemas/docs/`, `testing/`) — never in a shared central pile that interleaves
several subjects. This carries ADR-0011's locality posture into the docs a
contributor reads while working on one subject.

**The one exception is the cross-cutting decision/record log.** ADRs (and PRDs)
belong to no single domain: the ADR set is a connected graph that crosses target
and domain boundaries — later targets cite earlier ones (gerbil ADRs cite chez
ADRs), and the capability, interface-contract, and format decisions span domains —
so co-locating or per-domain renumbering would sever those edges. They stay
**central** in small, single-purpose **top-level** directories: `adr/` (the global
decision log) and `prd/` (product requirement docs), each holding only its record
type. This is **not** a reintroduced large top-level `docs/`: `adr/`/`prd/` are
focused record homes, not a documentation tree, and are §10's explicit carve-out
(success-criterion §45.7 reads against a re-accreting `docs/`, not against these).

## Considered options

- **Central `docs/targets/<lang>/` tree.** One top-level docs root with a
  per-target subtree. Discoverable in one place, but it re-centralizes exactly what
  ADR-0011's isolation separates: the unit on disk and the docs about it drift
  apart, and "everything about one subject in one place" is lost the moment the
  docs live elsewhere. Rejected.
- **Per-domain / co-located ADRs** (`semantic/docs/adr/`, `targets/<t>/docs/adr/`, …).
  Move each domain's ADRs into its unit and renumber locally. Rejected: it breaks
  the connected decision graph — cross-target citation edges become dangling or
  ambiguous — and buries a cross-cutting log inside one domain (ADR-0034 is
  SBCL-specific and ADR-0021 gerbil-specific, but neither belongs *to* the SBCL or
  gerbil unit as a record). No locality gain the central log does not already give.
- **Keep the log under a `docs/adr/`.** Lowest churn, and a `docs/` holding *only*
  `adr/` is arguably within §10's spirit — but it leaves a top-level `docs/`
  directory standing, which §10 and §45.7 read against, and invites later
  re-accretion of other docs into it. Rejected in favour of a top-level `adr/`.
- **Co-locate per-subject docs; keep the ADR/PRD log central at top-level
  `adr/`/`prd/` (chosen).** Everything about one subject lives in its unit except
  the cross-cutting records, whose value *is* their connectivity. The
  discoverability cost of the central record tier is paid back by the read-vs-produce
  split in the new-target authoring guide
  (`targets/_shared/docs/adding-a-language-target.md`).

## Consequences

- **Each unit owns a canonical doc layout.** A target carries `docs/reference.md`,
  the `docs/{overview,language-characteristics,ffi-model,idiom-map,representability}.md`
  set, `docs/design/`, `docs/research/`, and per-app `learnings.md`; a target is not
  "done" until its docs exist in this structure — the new-target authoring guide
  makes producing them an explicit, sequenced step with a read-the-shared /
  produce-the-per-subject split.
- **The ADR log keeps global, stable numbering under `adr/`.** Numbering is global
  and the parent path is top-level (not under a `docs/`); a future reader asking
  "why a top-level `adr/` when §10 bans a top-level `docs/`?" is answered above —
  ADRs are the deliberate central exception. `prd/` follows the same
  cross-cutting-record logic. `adr/` also establishes the pattern for any genuinely
  cross-cutting *record* artifact that belongs to no single domain.
- **Duplication across similar subjects is accepted by design**, as in ADR-0011 —
  each Scheme-family target repeats some setup in its own `reference.md` rather than
  sharing a central "read racket.md for the common bits" doc. The same ADR-0010
  economics (LLM-assisted authoring) make per-subject docs affordable.

See `REFACTOR.md` (§10, §11, §45.7) and `CONTEXT.md` ("Documentation structure")
for the glossary definitions.
