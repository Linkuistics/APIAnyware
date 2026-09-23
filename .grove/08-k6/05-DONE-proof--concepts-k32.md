# concepts-k32


## Goal

Read and finish the complete three-page concept set against the documentation
contract, leaving the node ready for the tutorial and reader checkpoint.



## Context

- Read `explanation/contracts.md`, `explanation/packages.md` and
  `explanation/choices.md` under `semantic/specification/interface-language/`.
  The structure/prose/visual contract is the documentation plan §4–§7 and §9.2;
  apply the research survey's proof criteria (§9).
- Art added G2/G3 to packages and G5/G6/G7 to contracts, reused G1 on all three
  pages and retained G4. Source and generated SVG are in `figures/`; role and
  arrow meanings are in `figures/style/vocabulary.txt` and `ail.puml`.
- G2 is schematic: distinguish private support from exports, and do not read
  its imported-package box as an import in the frozen fixtures. G3 shows two
  whole-contract alternatives with explicit selection, one synthetic ABI entry,
  two conventions, stable fixture compatibility versus a source recipe.
- Check G5's separate input call region and returned owner borrow, plus its
  explicitly constructed mutable-store variant. G6 is only the immutable
  unique-store lifecycle; the separate ordering fragment has a role table.
- G7 distinguishes a constructed call-scoped operation from successful
  synthetic subscription. It shows a possible in-flight invocation during
  teardown, `outside_callback`, and quiescence at destructor return without
  promising callback delivery or termination.
- Added tables cover selectors, outcomes, buffer extent, thread permissions,
  pattern roles, pins, data access, design trade-offs and the clause count.
  Every added figure has adjacent explanatory prose; examples and Q1–Q6 were
  preserved. No earlier-stage correction run or hand-forward item is pending.
- `task docs:check` passed after art, including byte-for-byte regeneration of
  seven SVGs. Art visually inspected the five new renders. These checks do not
  establish semantic conformance, native behavior or human comprehension.

## Done when

- All three pages have received the whole-document proof, including examples,
  rules, accessible figures, synthetic identities and navigation.
- `task docs:check` passes on the final bytes. Preserve Q1–Q6 as open questions.
- Retire this leaf, check the `concepts-k6` node's Done when, and promote any
  context the subsequent tutorial needs before sealing the focused jj commit.
  Add no successor in the ordinary case; use the editorial correction-run
  procedure only for a defect that actually requires it.

## Decisions (running log)

- The whole-document read found no correction requiring a text or figure
  change. Retain the three concept pages, their examples and Q1–Q6 as written.
  Cross-checked the explanations against L1–L6, C1–C8, A1–A5/F1, the grammar,
  all three frozen examples, the conformance record and the cited design/audit
  passages. Inspected the five new rendered figures against their source,
  legends and adjacent prose, and checked the landing/glossary routes.
- No handed-forward defect or correction run remains. The concept node's
  deliverables meet its Done when; promote the reusable figure and example
  distinctions to the root brief for the tutorial. Reference-inventory coverage
  belongs to the pending reference increment; human comprehension remains for
  the scheduled reader checkpoint. This proof does not establish native
  behaviour or executable semantic conformance.
- Final verification: `task docs:check` passed (13 files checked for links,
  11 pages reachable, 13 files checked for examples, all seven SVGs regenerated
  byte-for-byte). Before/after SHA-256 manifests matched for the specification
  tree, documentation tools, semantic design/research documents and Taskfile.
  No document bytes changed during the check. The gate checks documentation
  mechanics, not semantic validity; the rule/example comparison above was
  inspection. No ADR change is warranted by a proof that changes no rule or
  design decision.
