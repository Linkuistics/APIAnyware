# concepts-k56

## Goal

Apply the human's examples-and-notation requirements to `explanation/contracts.md`, `explanation/packages.md` and `explanation/choices.md`.

## Context

- Human assessment and H5–H7: first-path-reading-k48, D2–D5.
- Structure brief: documentation plan §9.2; general requirements:
  §4–§6 and §9.7.
- Rule-reading-k49 supplies the canonical examples, language model and selected
  railroad views. Read their landed form and this node's Handed forward list.
- Paths are relative to semantic/specification/interface-language/.

## Work

Introduce a small package shell and the language model before the package page's identity discussion. Use two named packages to teach local/imported declarations and aliases; show a top-level nominal declaration and member with its receiver and slot references. Reuse rule-reading's concrete examples and G9/G10 where useful. Inspect all three pages for first introductions that lack located snippets, including clause, place, outcome, callback, pattern and access syntax. Retain the existing domain/API/language distinctions and Q1–Q6.

Read the whole document under this stage's charter. Preserve original AIL
semantics, example contracts, proposed status and synthetic boundaries.
Work belonging to another stage follows the node's declared handoff and
escalation rules; do not silently absorb it.

## Done when

- This stage's charter is satisfied for the whole named document under the
  revised structure brief, with the disposition of each relevant H5/H6 location
  recorded in the task's notes.
- Snippets, prose and figures agree with their grammar and canonical rules;
  complete/fragment labels remain truthful.
- `task docs:check` passes. Mechanical checks and editorial inspection are
  reported separately from human comprehension.

## Notes

This is the human-directed second correction run. The escalation and authority
are in the node brief; no further automatic rerun is authorized. Record any
unresolved residue for first-path-reading-k64 and seek human direction when
necessary. The next stage is already queued under this node; do not add a duplicate.

## Decisions (running log)

D1 — The named structure brief is plan §9.2: reader/outcome is “The primary
reader, after orientation” who can “explain how AIL states each obligation”;
the three ordered section lists define the sequence and purpose; “Honest
trade-offs” and the non-goals of exhaustive reference, tutorial steps and
proposed fixes define emphasis and exclusions. Preserve that plan, adding the
explicitly requested package/model opening before Four identities.

D2 — Reuse the landed geometry/canvas fragments and G9/G10 for the package
model. Keep the all-zero import pin visibly a placeholder. Locate contract
fragments inside named declarations and nested scopes; back added fragments
with checked source regions under examples/concepts/. Leave the frozen complete
fixture packages and normative rules unchanged. Reuse existing figure assets;
the queued art stage owns their presentation review.

D3 — The leaf's one fresh-context reviewer inspected the contract fragment
source and its prose/omission labels against the grammar, normative rules and
frozen fixtures. The narrow claim under test was that giving the fragments
visible enclosing declarations preserves their stated contract and exposes
scope without implying completeness. No material findings were reported, so
there are no findings to classify or a second review to commission. The review
was technical inspection; it supplies no evidence of human comprehension.

## H5/H6 location dispositions

The whole three-page set was read for structure and technical truth. The
following inventory follows its substantive introductions; summary tables
were checked against the same local examples. H5 concerns local/imported
names and members; H6 concerns notation without containing context.

| Page/location | Disposition and authority |
|---|---|
| Contracts: From signature to contract | Watch package/type/function shell, parameter/result punctuation and nested outcome; located Store comparison; G10 clause railroad. L1–L4, C1/C3/C5. |
| Contracts: Naming what a contract talks about | Callable signatures around single-pointee and buffer-element places, a result record for `.handle`, G10 place railroad; `$store` and `@view::store` share a previously shown referent. L2/L4, C1/C4/C5. |
| Contracts: Who owns what | `view`, `destroy`, `create` and `subscribe` enclose transfer/retention clauses and outcomes. Borrow/consume and owned/borrow comparisons retain their fixture meaning. C2/C3/C5. |
| Contracts: How long a borrow lasts | Enclosing `view` outcomes, a constructed mutable `replace` signature and mutation, and `fixed_bytes` constant locate owner/invalidator/static forms. C1/C3/C5/C7. |
| Contracts: Every way a call can end | Nullable constructor and Boolean copy signatures enclose both outcome partitions. Existing inout/unchanged contrast remains a cited value alternative, not an additional complete example. C3/C5. |
| Contracts: Buffers and strings | Binary `view` and constructed text `greeting` locate extent/contents; `copy_bytes` locates direction, aliasing and mutation beside its pointer parameter. C3/C4. |
| Contracts: Callbacks | `Handler` invocation versus `subscribe` use block; constructed `notify` call scope; `unsubscribe` locates the external callback-slot precondition. C3/C6. |
| Contracts: Threads and sharing | Resource/object and function bodies separate nominal from per-call facts; the Counter member/receiver relation is explained locally; profile clause belongs to Counter. L2/L5, C2/C3, F1. |
| Contracts: Lifecycles and patterns | Type bodies locate lifecycle; package bodies locate pattern/instance; constructed operation signatures establish the subject slots for `before`. L6, C2. |
| Contracts: Extending with profiles | Separate `view`/`fetch` bodies locate sync/async; the latter explicitly needs semantics beyond F1. ABI/layout discussion stays domain prose. C3, A1–A3/F1. |
| Packages: Opening and Four identities | Geometry and canvas shells, G9 before dependent reference notation, local/imported/member/receiver/slot table, G10 names, canonical tuples, and located source/access spellings. All-zero import remains an unresolved placeholder. L1/L2/L4/L5, A2. |
| Packages: What a package claims / Where it holds | Package bodies locate surface/exports and environment declarations; nominal bodies locate availability. G2 remains a schematic, distinct from the fixtures. L3. |
| Packages: What it depends on | Reuses named Geometry import rather than inventing another alias; package-scoped `use profile`/`use abi` shows exact F1 tokens and alias positions. L2/A1/F1. |
| Packages: Reaching the code | Two paths enclosed by `read_count`, explicit member/receiver, G3 then the finer G10 access track; constant/global bodies locate address versus load mechanisms. A2–A4/F1, L5/C7. |
| Packages: Providers / Fixture / Views | Retains domain-first provider/layout and synthetic-status explanations; earlier local provider/access examples supply their referents. Projection discussion retains its complete two-view link and owner/lifetime prerequisite. A1–A5/F1. |
| Choices: Opening and Publication | Located view and subscription distinguish domain/API/notation; package surface/exports and resource lifecycle locate the closure example. L2/L3, C1/C2/C3/C5/C6. |
| Choices: Applicable facts / Ownership | Type-scoped isolation pair; complete fixture `view` keeps its counted clauses; explicit `destroy` contrasts entry transfer with the labelled non-AIL signature alternative. C2/C3/C5. |
| Choices: Clause syntax / Environments / Profiles | G10 clause grammar beside the same examples; package environment and function availability; object/member bodies locate profile/core facts; sync/async remain separately labelled. L1/L3/L5, C3/A1/F1. |
| Choices: Dedicated syntax / Pressure cases / Q1–Q6 | These compare designs and scope, rather than introduce a new supported form. Kept domain explanations, rule routes, alternative costs, hypothetical-status labels and all six open questions. No new language decision. |

D4 — Existing G2–G7 semantics and assets remain in place; reused G9 and G10
source/SVG pairs carry adjacent keys and grammar limits. No new figure is
needed for this draft. The already queued art stage checks their placement and
rendered reading at the new reuse sites. Copy-edit owns the expanded prose's
sentence-level reading. These handoffs do not delegate unresolved technical
truth. Human first-path-reading-k64 still owns comprehension assessment.

## Verification and disposition

- `task docs:check` passed: links and example checks each reported 19 files,
  all 17 Markdown pages were reachable, and every one of the 23 named SVGs
  regenerated identically. Each SVG result was read, not inferred from a total.
- The before/after subject maps were identical by path and SHA-256 for 96
  files: the interface-language tree (including example sources and figure
  source/style/SVG pairs), documentation checker directory excluding Python
  caches, root Taskfile, documentation plan and audit. Manifest SHA-256:
  `fa87c7b5859fd054cf2da9df08fc9cd3d696eb13a0a66c35b7b664b3fd94b111`.
  No checked subject was edited during the run.
- Byte comparisons with the parent commit confirmed unchanged `language.md`,
  `contracts.md`, `profiles.md`, `grammar.ebnf`, and all three original complete
  conformance `.ail` examples. The Q1–Q6 register also matched its parent text.
  The complete `view` still has 23 clauses (14 function, five outcome, four
  access); new fragments are separately labelled incomplete teaching extracts.
- Direct source inspection checked grammar nesting and cited L/C/A/F1 claims,
  figure source relations and the reused railroad productions. Structure follows
  plan §9.2, with the mandated model opening before identity. Direct entry into
  each page supplies its reader context, snippet location and route to rules.
  This is inspection and reproducibility evidence, not AIL semantic execution,
  real-provider support, rendered-art approval or human comprehension.
- Graph Tier 2 project and coverage were confirmed at generation
  `2026-09-23T09:55:55Z`. The design and example directories are excluded;
  relevant Markdown/figure metadata is changed or untracked. All task evidence
  therefore comes from direct reads and comparisons. No code-structure or
  graph-completeness claim is made.

D5 — The draft's structure and technical-truth obligations are discharged for
this leaf. The copy-edit/art handoffs are recorded in the node brief. Live
siblings concepts-k57, concepts-k58 and concepts-k59 already hold the remaining
stages, so add no successor and perform no node close/promotion. Retire and seal
concepts-k56 in one focused jj change; the next session starts on an empty
change. The human checkpoint remains pending, with no further automatic
correction run authorized.
