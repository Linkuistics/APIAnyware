# rule-reading-k50

## Goal

Add the rule-reading structure and local teaching examples to `language.md`,
including the language model and syntax-view slots required by the human's L2
feedback.

## Context

- Structure brief: documentation plan §9.7; prose/examples/figures: §4–§6.
- `first-path-reading-k48`, D2–D5, records the human's words and disposition.
- Authorities: `language.md` L1–L6, `grammar.ebnf`, and the existing glossary,
  conformance examples and tutorial packages, all under
  `semantic/specification/interface-language/`.

## Work

Read the whole page and enumerate its construct introductions. Add small
explained excerpts with enough enclosing package/declaration context to read
them. At L1 establish the document/package shell and clause form. At L2 use
two named packages and an alias to teach local/imported declarations; place a
nominal declaration and member beside one another at package level, explaining
the member relation and named receiver. Locate every reference form in the
human's quoted paragraph, including operation/callback slots, and distinguish
references from callable-local places and bare type names. Show the concrete
identity tuple separately from source/access spelling. Continue through L3–L6.

Preserve original normative wording and anchors. Bound added non-normative
material so the original can be recovered for comparison. Pair figure slots
with the named grammar productions, prose and exact example identifiers; art
owns rendering. Store snippet sources in a suitable examples subdirectory and
use the existing example check. Label fragments honestly; never present a
placeholder import digest as a verified complete package.

## Done when

- Each construct introduction has an accounted-for local teaching context;
  the L2 acceptance cases are illustrated and explained.
- All added snippets are inspected against grammar and rules and checked
  against source files; original rule text and grammar are preserved.
- `task docs:check` passes, routes use existing destinations, and G9/G10
  slots are recorded for art in the node brief.

## Notes

The later draft sibling `rule-reading-k51` is already queued. Do not add
copy-edit here. No parser or validator is implemented. Keep proposed status,
synthetic boundaries and open language questions intact.
