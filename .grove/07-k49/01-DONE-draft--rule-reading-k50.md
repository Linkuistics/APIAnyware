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

## Decisions (running log)

D1 — The named structure brief, documentation plan §9.7, supplies all three
preconditions: “The primary reader arrives directly at a rule”; ordered
placements 1–6; and explicit Emphasis/Non-goals paragraphs. Its reader outcome
is to place constructs in the model and distinguish local/imported declarations,
members and slots. The human-approved correction already settles the design;
this session executes that structure rather than reopening planning.

D2 — Bound every addition with `<!-- reading-aid: ID -->` and
`<!-- /reading-aid -->`, including its trailing separator, so removing those
blocks reproduces the pre-edit page byte for byte. Add small constructed
fragments under `examples/rule-reading/`; label missing contracts and any
placeholder package digest locally. Keep the frozen conformance examples and
grammar untouched. The existing example task checks the new fences.

D3 — L2 uses invented `example::geometry` version `1` and `example::canvas`
version `1`, imported as `Geometry`. `Point`, `Canvas`, `position` and `Filter`
provide the model, bare types, member/receiver and operation/callback slots.
G9/G10 are explicit art handoffs with the same identifiers and grammar
productions. The second draft is already live; it owns cutting copy-edit.

D4 — Spend the single in-session review allowance on the L2 model and name
resolution examples. Claim to test: the two-package/member/slot account can be
read literally without teaching a different identity or resolution rule. This
matters because it is the human's reported failure point; snippet equality
cannot test that property. The reviewer gets the bounded artifact and canonical
contract, not this claim or the drafting rationale. All other additions receive
source-based self-inspection; no second reviewer is planned.

D5 — The single reviewer found no concrete issues in the bounded L2 read,
including its examples and slot-binding fragment, after direct checks against
the canonical grammar and rules. There are no findings to reconcile. This is
one aimed technical review, not a reader-comprehension result or a review of
the other sections. No additional review context was materialised.

D6 — Read the complete expanded page against L1–L6, relevant C1–C7/A1–A3/F1
rules and the grammar. All inventory rows below now have their local support.
The original clause-shaped token enumeration is: accessors, available, base,
bind, deprecated, doc, exports, extends, extension, feature, implements,
isolation, law, link, literal, member, mutable, overrides, platform, receiver,
requirement, runtime, satisfies, since, source, storage, subject, surface,
target, toolchain, values. Each appears in a located snippet or its explicitly
described variant; the L5 keyed clauses additionally have the two-input and
aggregate-state contrasts. The reference stage still owns exhaustive reference
entries; this inventory accounts for introductions, not every permitted value.

The original L1–L6 rule order and exact paragraphs are retained. Read the direct
`language.md#l2` route: package definitions and the member relation precede the
reference account, with canonical paragraphs alongside and local links to L6
slot uses. Read the README → language route: page context identifies draft
status, aid boundaries, full examples and the tutorial; exact rule anchors and
the existing explanation/glossary routes resolve. The model and railroad slots
are recorded for art, not claimed as rendered diagrams. No human-comprehension,
parser acceptance, semantic validation or native-runtime result is claimed.

D7 — Final verification passed: `task docs:check` checked 19 files, reached
all 17 Markdown pages, matched the AIL fences to source, and regenerated all
11 existing SVGs identically. The 65 repository input paths and SHA-256 digests
matched item by item before and after the run: the interface-language tree,
documentation-checker directory (ignored caches excluded), root Taskfile,
documentation plan and audit. Manifest SHA-256:
`a4cbbd3dfa87a0dcce8f65a5084a40c32f1f0f8d2c429c346e795e957655f36c`.
The measured `language.md` SHA-256 is
`44dbfd928d6b87c650d7298c80885068855063a30675f3752bcfac114a47c254`.

Separately, stripping the bounded additions recovered `language.md` byte for
byte against parent revision `87221b8c` and the pre-edit copy. A deliberate
MUST-to-MAY mutation in the recovered rule text failed that comparison.
Boundary identifiers are unique and all opening/closing markers match; rule
anchors are identical. Direct byte comparisons also confirmed the grammar,
contracts, profiles (including F1), conformance document and three frozen
fixture examples unchanged. No checker or Taskfile implementation changed.
The last edits after this measurement are task/brief retirement bookkeeping,
outside those measured inputs.

Graph evidence: Tier 2, project
`Users-antony-Development-APIAnyware.improve-api-interface-language-docs`,
generation `2026-09-23T09:55:55Z`. The bounded language-page search returned
nine module/section/file rows with no further page, but represented the old
page. Coverage marked edited Markdown stale and new fragments excluded under
the examples directory; the plan/research directories are excluded too.
All material documentation evidence came from direct current-source reads;
no code-structure or graph-completeness claim follows.

D8 — Retire `rule-reading-k50` with the local aids, checked fragment sources
and precise G9/G10 handoffs in the node brief. The next live sibling is
`rule-reading-k51`, whose brief-chain includes those conventions and handoffs.
It owns contracts/profiles and cutting copy-edit, so no duplicate stage is
added here. The parent node still has live work; no node closes and no
parent-chain promotion is due. No language decision changed, so the ADR set
needs no revision.

## Construct inventory and local support

The inventory follows all six original sections, including their prose and
table introductions. It is bounded to `language.md`; contract/profile detail
remains the next draft's work.

| Introduction | Landed local support |
|---|---|
| L1 text, identifier/integer/string/Boolean tokens, comments, contextual names | A commented shell and concrete valid/invalid spellings beside the lexical rules |
| L1 header, document/package/items, clause/constructor/list, closed vocabulary | Shell and `deprecated(since(...), ...)`; distinguish parsing from validity; G10 document/item/clause/value slot |
| L2 package/version/declaration identity, nominal/member ownership, local/imported | Geometry/Canvas shells, package-level siblings, concrete identity tuple; G9 slot |
| L2 alias, declaration/operation/callback slot references, named receiver, bare types, places | Located function/callback fragments and a name-to-target table; G10 import/reference/name/callable/parameter/place slots |
| L2 shared namespace, parameter/outcome uniqueness, reserved names | Small single-defect mutations and allowed reuse across different callables |
| L2 digest, resolution set/closure, acyclic imports, consistent pins, provider aliases | Explicit placeholder boundary, two-package resolution walkthrough and fixture dependency extract |
| L3 surface, exports, support closure, environment configuration, availability | Located package/environment/declaration fragment, exact-config and completeness cases |
| L4 scalar/value/reference/unit, constructors, records/fields, recursion, aliases/resources | Located type fragments and paired distinctions; ownership links |
| L4 enum/flags cases/domains, profile types | Closed/open value cases; grammar-only profile type with explicit unsupported-provider boundary |
| L5 clause scope/repetition by place/role/tuple, aggregate state | Located repeated-input example and parent/child state contrast; L6 roles/laws |
| L5 doc/link/source/deprecated, base/implements/extends/member/receiver/requirement | Located declaration fragments with exact applicability and omissions |
| L5 overrides/satisfies/extension, accessors/storage, literal/mutable, public/deprecation and derived views | Nominal/member/property and constant/global fragments; profile and compatibility boundaries |
| L6 pattern/instance, four role kinds/cardinalities, bindings, releases/before/subject, composition and availability | Frozen lifetime extract plus constructed roles and ordering fragments; explain real obligations and both invalid cycles |
