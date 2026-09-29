# reference-k9 — brief

## Goal

Land the reference: `reference/README.md`, `notation.md`, `types.md`,
`declarations.md` (with the applicability table) and the `clauses-*.md`
files, plus verified context blocks and lookup routes on the normative and
supporting files. Any clause,
declaration kind, type or rule can then be looked up with fixed fields and a
link to its canonical rule (plan outcome 5).

## Contract

The structure brief is the documentation plan's §9.4, at `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md`. It states
the reader and their outcome, the ordered sections and the purpose of each,
and the emphasis and non-goals. The same plan's §4 (prose contract), §5
(page-one block and example labels), §6 (figures) and §7 (checks) govern
every stage. The gate is `task docs:check`, plus any task this document adds.

The 2026-09-28 requirements in first-path-reading-k48 apply to every entry:
locate each introduced form within a small explained example, and reuse the
language-model/railroad aids landed by rule-reading-k49. Local/imported
declarations, a top-level member with its receiver, and declaration/slot/place
references are explicit acceptance cases. Normative page-one blocks and labelled
reading aids now land in rule-reading; preserve them, verify their routes and
add links to the new reference. Normative wording and grammar stay unchanged.
The next human checkpoint, first-path-reading-k64, precedes this node; read and
incorporate its decisions before drafting.

The reader is familiar with railroad diagrams (first-path-reading-k64).
Explain the AIL productions and their example spellings; omit generic lessons
on reading tracks, alternatives, optional paths and repetition. Use the syntax
figures without instructional legend boxes. Preserve the language-model context
and the explanations of AIL's name resolution and semantic constraints.

The human's 2026-09-29 priority is to explain the model and describe AIL by
reference to it, because the language serves as a tool. Give each entry a
clear connection to the model concept and task it expresses.
model-first-documentation-k68 reconciled plan §9.4 with that priority: the
reference is the exact-lookup path, separate from the learning route, and
consumes the canonical model account in `explanation/model.md` rather than
restating it. Each entry gains an *Expresses* field naming its plan §10
concept and linking the concept's anchor; `reference/README.md` gains a
model-concept index; the disposition list records each entry's concept and
`docs:coverage` fails on an entry with none. The concepts run (concepts-k76)
lands the model-concept routes in the canonical reading aids; preserve them,
with the bordered aids, bold labels and explicit anchors, and add lookup
routes beside them. Use §10's concept names exactly as the model page does,
including any change `model-reading` made.

## Pipeline

`draft` → `copy-edit` → `art` → `proof`, cut lazily: each stage's last act
adds the next unless a live later sibling already holds it. Stage leaves carry
this document's bare stem as their slug. Defects a later stage owns go under
`## Handed forward` in this brief; the list is created by the first stage that
needs it. Figure slots that `draft` leaves for `art` go there too.

## Done when

- Every candidate in the enumerated inventory is classified, and every
  entry-class item has an entry. The candidates come from every normative
  source — grammar, tables, running prose, example clause heads, rule
  identifiers and mutations N01–N33 — as the plan's §7 specifies; the
  prose-defined clauses listed in audit F5 are among them. `task
  docs:coverage` (added by this node) passes with nothing pending.
- The landing map links `reference/README.md`, and every clause file is
  linked from it, in the session that lands it (plan §3, *Staging*).
- Entries use the §9.4 fields in order. Every "rejected when" field cites a
  rule, and every meaning is a labelled non-normative summary.
- The normative rule text and grammar are unchanged. The separately labelled
  reading aids and page-one blocks from rule-reading remain usable and link
  to the new entries.
- The concept pages, tutorial and glossary link to entries where they name a
  clause.

## Decomposition

Four draft sessions, in order. Only the last cuts `copy-edit`.

1. `reference/README.md`, `notation.md`, `types.md` and `declarations.md`,
   with the applicability table, verified normative context/lookup routes,
   page-one blocks on supporting files, and `task docs:coverage` with its candidate extraction
   and disposition list. Its classified inventory fixes the entry list for the
   remaining sessions.
2. Clauses for package, environment and common declaration scope.
3. Clauses for callable effects and input obligations, including buffers and
   strings.
4. Clauses for outcomes, callback use, access paths, patterns and the fixture
   profile, plus the mutation-to-rule and alphabetical indexes.

The plan's §2 split may change once the inventory is counted; session 1
records any change there.
