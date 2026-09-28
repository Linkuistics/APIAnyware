# concepts-k59

## Goal

Verify the complete examples-and-notation correction across `explanation/contracts.md`, `explanation/packages.md` and `explanation/choices.md`.

## Context

- Human assessment and H5–H7: first-path-reading-k48, D2–D5.
- Structure brief: documentation plan §9.2; general requirements:
  §4–§6 and §9.7.
- Rule-reading-k49 supplies the canonical examples, language model and selected
  railroad views. Read their landed form and this node's Handed forward list.
- Paths are relative to semantic/specification/interface-language/.

## Work

Walk packages and contracts from direct entry and from orientation, then choices. Verify local/imported declarations, member association, receivers, slots and places against L2/L5/C1; verify all other examples against their cited rules. Inspect the rendered views beside their snippets and preserve all six open questions.

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
necessary. No ordinary successor is needed; first-path-reading-k64 is already queued after all corrected documents.

## Decisions (running log)

D1 — The whole three-page read, canonical-rule comparison and inspection of
G2–G7, G9 and the four reused G10 views found no actionable defect. Preserve
the published pages and examples. The node has no outstanding Handed forward
entry and needs no correction run. This finding establishes editorial
consistency only; first-path-reading-k64 retains the human comprehension check.

## H5/H6 location dispositions

Read contracts, packages and choices in full, including every snippet label,
table, figure key and closing route. Compared their claims with L1–L6,
C1–C8, A1–A5/F1, the grammar and the three complete conformance fixtures.

| Location | Proof disposition |
|---|---|
| Packages: shell, model, imports and members (H5/H6) | Geometry defines Point; canvas imports it as Geometry. Canvas and position share package scope, with member association and an ordinary named receiver. G9, the local snippet and L2/L5 agree. |
| Packages: references, slots and four identities (H6) | Local/imported declaration references, callable-slot references, local places and bare type names keep distinct contexts. G10 names supplies spelling only. Source Canvas.position, symbol canvas_position and the declaration tuple remain separate. |
| Packages: surface, exports, dependencies and environments | G2 stays schematic. Private support retains authority without becoming an export. The two test environments differ by compiler selection. Geometry's zero placeholder is distinct from F1's test tokens; neither is presented as an ordinary resolved production pin. |
| Packages: access and providers | G3 and the located getter use one ABI entry with two conventions and faithful paths. G10 access agrees with EBNF while A2 supplies requiredness. Address versus load and stable versus source/artifact compatibility retain their separate meanings. |
| Packages: fixture and projections | F1's supported boundary, complete-model access, consumer restrictions and binding infeasibility agree with the rules and conformance record. No native execution is claimed. |
| Contracts: signature, clause and place introductions (H6) | Watch and Store remain separate examples. The local callables establish the values before clauses use them; G10 clause/places agree with EBNF. Pointer, pointee, buffer elements and record leaves retain separate obligations. |
| Contracts: ownership and borrow duration | Input borrowing, consumption, strong retention and returned ownership stay distinct. G4 is watch-only; G5 separates immutable Store from the constructed mutable case. Input call validity supplies no returned lifetime, and replace invalidates at entry. |
| Contracts: outcomes and buffers | Null failure is readable and carries no ownership obligation. Failed copy output is unreadable. Partition and storage tables agree with C4/C5, including payload length versus terminator capacity. |
| Contracts: callbacks | Handler invocation and registration schedule remain separate. Constructed notify has call scope; subscribe has owner scope and permits zero notifications. G7 and prose locate quiescence at unsubscribe return and keep outside_callback and the absence of a termination promise. |
| Contracts: threads, lifecycles and patterns | Executor, overlap and re-entry remain independent. Unique and counted release tables agree with C2/F1; G6 describes only the immutable unique Store. The constructed before law tracks the same resource through two explicit subject slots. |
| Contracts: profiles | Located sync/async examples distinguish core spelling from required provider support. The hypothetical async form adds no fixture capability; validation remains separate from implementation truth. |
| Choices: publication, explicit facts and ownership placement | The domain/API/notation comparison retains its three levels. The full view has 14 body, five outcome and four access clauses. The alternative ownership notation is labelled hypothetical; its mutable store is distinct from the immutable fixture. |
| Choices: clause vocabulary, environments and profiles (H6) | The located examples and reused clause railroad distinguish syntax from vocabulary and validity. The version-range comparison remains an alternative, and the profile fragments retain their containing declarations. |
| Choices: coverage and Q1–Q6 | Pressure cases retain their distinct provider/language needs. All six questions remain open and linked to their locations; no rationale, semantic rule or production support is invented. |

## Journey and whole-document checks

- Followed the overview map into contracts, then packages and choices, and
  checked their direct-entry prerequisites, glossary routes, canonical-rule
  citations and tutorial exit. The L2 model and glossary use the same geometry,
  canvas, position and Filter names as the concepts page.
- Inspected full rendered views of G2–G7, G9 and G10 names/clause/places/access
  using temporary PNGs from the committed SVGs with rsvg-convert. Names,
  legends, reading order, optional/repeated syntax paths and surrounding
  snippets agree. No cropped thumbnail was used as visual evidence.
- Applied the survey's proof criteria R1 and R3–R5 to this bounded set.
  R2's exhaustive indexed-reference inventory belongs to the queued reference
  node; these explanations explicitly have no exhaustive-clause-coverage goal.
- The three pages' proposed status, fragment labels, synthetic boundaries,
  terms and Q1–Q6 agree. There is no outstanding hand-forward entry or
  unresolved defect to promote to the human checkpoint.
- No new reader evidence or process remedy was established, so no further
  Grove issue comment is warranted. The human's requested treatment still
  awaits assessment at first-path-reading-k64.

## Verification

- `task docs:check` passed with exit 0. Links and example checks each covered
  19 files; all 17 Markdown pages were reachable. Every named result for the
  23 SVGs was OK. External URLs were reported, not fetched.
- Before/after path lists and SHA-256 maps matched item for item for 96
  subjects: the interface-language tree, documentation tools excluding Python
  caches, Taskfile, documentation plan and audit. Manifest SHA-256:
  `e4f45d36f21a6a05eb01da9474669cc64dd6456b37e0d16171324d66944f79a0`.
  No checked input changed during the run.
- Tier 2 graph project status and exact-path coverage were checked at
  generation `2026-09-23T09:55:55Z`. Relevant Markdown metadata is changed or
  untracked; design/research/examples and some SVGs are excluded. Direct
  document, source and rendered-image reads supplied the proof evidence.
  No structural-code or graph-completeness claim is made.
- The bounded jj diff contains only this task's record and the root brief's
  promotion. Reader-facing pages, normative text, grammar, fixtures, fragments
  and figure sources/SVGs remain unchanged. The checks establish extract/link
  consistency and reproducible rendering; they do not parse or execute AIL,
  test a native API or establish human comprehension.

D2 — The concepts node's Done when holds: all three explanations meet their
structure brief, rule citations and labels remain intact, Q1–Q6 remain open,
the required figures have source/SVG pairs, and landing/glossary routes reach
the pages. Retire concepts-k59 and close concepts-k6, promoting the reusable
notation and example boundaries to the root brief. The root still has live
tutorial, checkpoint, reference and guide work, so the cascade stops there.
No language or architectural decision changed and no new glossary definition
is needed; the existing ADR set requires no revision. Seal the record,
promotion and retirement together in one jj commit before signalling completion.
