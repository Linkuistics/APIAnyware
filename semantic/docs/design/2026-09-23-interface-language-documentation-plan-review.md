# Review of the AIL documentation plan

Review date: 2026-09-23. Review task: `reviewer-documentation-k25`.
Producer: `reviewer-documentation-k3`, commit `8103dd6b`.

This is an inspection-only review of the audit, documentation plan and planned
subtree against the root requirements, ADR-0024, the relevant survey criteria
and Grove's planning/editorial procedures. Locations below refer to the producer
commit, before any tree renumbering. The specification corpus is unchanged from
the audit's cited revision, `1c4b8e7ec3da`.

Three findings warrant triage. High means the plan can miss a required outcome;
medium means an execution or accuracy defect that should be corrected before the
affected work runs. This review changes neither the plan nor the language.

## Findings

### R1 — High: the reference inventory excludes clauses defined outside tables

**Locations:** documentation plan §7, lines 243–246;
`.grove/10-k9/01-draft--reference-k16.md:17–20`; audit F5, lines 152–154.

The coverage check enumerates clause names from the first columns of normative
tables. The audit supplies the same premise: the vocabulary exists only in
tables. That premise is false. Required clauses are also defined in ordinary
prose:

- `language.md:70–87` defines `surface`, `exports`, `target`, `platform`,
  `toolchain`, `runtime`, `feature` and `available`;
- `language.md:131` requires `values`, and L6 defines `bind`, `law` and
  `subject` outside tables;
- `contracts.md:112–128` defines `extent` and `contents`, and C5's opening
  paragraph defines `when` and `meaning`;
- `profiles.md:40–41` requires `callback_abi` and `representation`, and F1's
  closing prose defines `fixture::sendability` and `fixture::actor`.

These are counterexamples, not a replacement inventory. Enumerating grammar
productions does not recover them: `grammar.ebnf:37` admits a generic clause
name. A section-level rule entry also does not provide the promised fixed-field
entry for each clause. The later reference leaves expressly use this inventory
to decide their entry lists, so the omission can survive to a passing coverage
check and an incomplete reference.

**Required correction:** inventory vocabulary from all normative definitions,
including prose and profile vocabulary, and reconcile it with the grammar and
examples. The inventory needs an explicit disposition for each item. A missing
prose-defined clause must be detectable by the coverage check. Correct the audit
premise and its downstream planning/check contracts together.

### R2 — Medium: draft leaves defer discoverability to later siblings

**Locations:** `.grove/07-k6/01-draft--concepts-k14.md:15–24` and
`02-draft--concepts-k19.md:22–23`; tutorial `tutorial-k15` and
`tutorial-k20:22`; review-guide `review-guide-k17` and `review-guide-k24:20`.

The first concepts draft lands `explanation/contracts.md`; the second owns
adding all three concept pages to the landing map and adding their glossary
terms. Likewise, the first tutorial draft lands its index and parts 1–3, but
the second owns links from the landing and concept pages. The first review-guide
draft lands the walkthroughs before its index exists, with the landing link
assigned to the second draft.

Orientation explicitly avoids links to future pages, so those earlier pages
cannot rely on inbound links already being present. Each first draft can meet
its local completion conditions and pass `docs:check` while remaining
undiscoverable from the existing reader route. `docs:links` checks destinations;
it does not detect an orphan. This contradicts the producer's requirement that
each increment leave every landed page navigable and Grove's independently
useful leaf test.

There is also no set-wide staging rule for forward references: the orientation
brief says not to link absent pages, but later briefs require next-page routes,
tutorial part lists and reference cross-links before every destination exists.

**Required correction:** make each draft responsible for an inbound link and a
usable return/next route when its pages land. State one temporary-link policy
for all increments, including tutorial and reference subdivisions. Later
integration can complete the map, but should not be the first point at which
earlier pages become reachable.

### R3 — Medium: the audit infers a semantic change from capitalization alone

**Locations:** audit F10, lines 243–253; producer decision D5; documentation
plan §9.4's instruction to explain the current BCP 14 scope.

F10 correctly distinguishes BCP 14's uppercase special meanings from ordinary
English, but its disposition then says that changing a word's case changes its
normative force. That categorical conclusion does not follow. RFC 8174 §2
explicitly permits normative text without its keywords and leaves lowercase
words with their normal English meanings. A lowercase requirement can already
impose the same obligation. [RFC 8174 §2](https://www.rfc-editor.org/rfc/rfc8174.html#section-2)

AIL's own `language.md:3–4` defines uppercase words for "this draft";
`README.md:25–26` identifies all three rule documents and the grammar as
normative. Neither says that lowercase requirements lack force. Absence of a
repeated convention on each page therefore does not establish a language-level
scope defect either.

**Required correction:** distinguish inconsistent presentation from an actual
uncertain obligation. Q1 may remain an author-confirmation question, but it
needs an uncertain rule or explicitly limited premise, not a general inference
from case. Preserve the restriction on editing normative wording; this finding
does not authorize changing the language or normalizing its keywords. Correct
the claim before it is propagated into the notation reference and explanations.

## Remaining review questions

- **Audit spot checks:** the principal specification and example line counts
  match; lowercase `must` counts are 9, 32 and 23. The cited grammar clause
  production, slot spelling and quiescence row are at the stated lines. The
  domain-context diagnosis, external-checkout link problem and separation of
  normative text from teaching material remain supported. These are spot
  checks, not certification of every numerical or first-use claim.
- **Q2–Q6:** these are legitimate language-review prompts about terminology,
  rationale, notation, discoverability and diagnostic granularity. Presentation
  improvements can make them easier to assess without deciding them. Q3's
  missing recorded rationale is not evidence that no rationale exists.
- **Structure briefs:** §9.1–§9.6 state quotable readers/outcomes, ordered
  content and purposes, emphasis and non-goals. The glossary's alphabetical
  entry format and the cross-set navigation worklist are sufficient for their
  respective scopes. No missing-brief finding.
- **Order and kinds:** the reference follows the first reading checkpoint and
  precedes the review guide as intended. `requirements` fits the checkpoints'
  job of eliciting the human's verdict and resulting revision requirements.
  `draft` fits authoring navigation and the Step 2 index. The proxy remains
  explicitly limited evidence, not a substitute for the human.
- **Sizing:** the semantic-core explanation and first reference draft are the
  largest assignments. The latter combines four pages, an applicability table,
  page-one blocks and a coverage tool. These deserve early decomposition if
  their actual inventories exceed one session, but inspection alone does not
  establish a further sizing defect. The four-file clause split is explicitly
  adjustable after enumeration. R1 must be resolved before trusting that count.
- **Green reference stages:** explicitly reported pending entries are a planned
  intermediate state; full coverage is required at `reference-k23`. That is
  viable if the checker distinguishes pending future work from missing entries
  in a landed slice. It does not excuse incomplete final coverage.
- **Scope:** the plan preserves normative wording, except for anchors and
  navigation/page-one material, and leaves frozen conformance packages alone.
  It does not claim the old EBNF recognizer or the `.apiw` validator as evidence.
- **L3 subsets:** D6 is supported by L3 and `README.md:48–51`: unrelated APIs
  may be omitted while the included surface retains its whole dependency
  closure. This does not permit postponing required clauses. In particular,
  A2 requires access blocks on the creation/destruction functions already in
  tutorial part 1. Read part 5's access-path topic as deferred explanation,
  not deferred presence. Every earlier complete checkpoint still needs those
  blocks and its complete provider dependencies.

## Inspection limits

No tests, builds, lint, formatting, renderer or AIL validation commands ran.
Evidence is document reading, bounded literal searches, line counts and the
producer's VCS diff, plus the primary RFC text cited above. This checkout has
no matching codebase-memory project; no structural-code or graph-completeness
claim is made. No reader-comprehension result is claimed.
