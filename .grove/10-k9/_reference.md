# reference-k9 — brief

## Goal

Land the reference: `reference/README.md`, `notation.md`, `types.md`,
`declarations.md` (with the applicability table) and the `clauses-*.md`
files, plus page-one blocks on the normative and supporting files. Any clause,
declaration kind, type or rule can then be looked up with fixed fields and a
link to its canonical rule (plan outcome 5).

## Contract

The structure brief is the documentation plan's §9.4, at `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md`. It states
the reader and their outcome, the ordered sections and the purpose of each,
and the emphasis and non-goals. The same plan's §4 (prose contract), §5
(page-one block and example labels), §6 (figures) and §7 (checks) govern
every stage. The gate is `task docs:check`, plus any task this document adds.

## Pipeline

`draft` → `copy-edit` → `art` → `proof`, cut lazily: each stage's last act
adds the next unless a live later sibling already holds it. Stage leaves carry
this document's bare stem as their slug. Defects a later stage owns go under
`## Handed forward` in this brief; the list is created by the first stage that
needs it. Figure slots that `draft` leaves for `art` go there too.

## Done when

- Every item in the enumerated inventory has an entry: grammar productions,
  clause names from the normative tables' first columns, rule identifiers and
  mutations N01–N33. `task docs:coverage` (added by this node) passes.
- Entries use the §9.4 fields in order. Every "rejected when" field cites a
  rule, and every meaning is a labelled non-normative summary.
- The normative files' rule text is unchanged apart from page-one blocks.
- The concept pages, tutorial and glossary link to entries where they name a
  clause.

## Decomposition

Four draft sessions, in order. Only the last cuts `copy-edit`.

1. `reference/README.md`, `notation.md`, `types.md` and `declarations.md`,
   with the applicability table, the page-one blocks on the normative and
   supporting files, and `task docs:coverage`. Its inventory fixes the entry
   list for the remaining sessions.
2. Clauses for package, environment and common declaration scope.
3. Clauses for callable effects and input obligations, including buffers and
   strings.
4. Clauses for outcomes, callback use, access paths, patterns and the fixture
   profile, plus the mutation-to-rule and alphabetical indexes.

The plan's §2 split may change once the inventory is counted; session 1
records any change there.
