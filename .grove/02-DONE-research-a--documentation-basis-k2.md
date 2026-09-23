# documentation-basis-k2

## Goal

Research the technical-writing books the human supplied and related primary
guidance, then derive an evidence-based editorial approach for reviewing AIL.
The readers know language design, aesthetics and developer expectations but are
unfamiliar with the API binding domain. The purpose is informed evaluation and
feedback on the proposed language, not production API integration.

## Context

- Human reading list:
  https://richardrabil.com/2024/08/18/the-best-books-on-technical-writing-an-in-depth-analysis/.
- The human's supplied editing prompt names Diátaxis, Docs for Developers,
  Developing Quality Technical Information (IBM Press), and Google/Microsoft
  style guidance. Its operative criteria are in the root brief.
- Downstream consumer: `reviewer-documentation-k3`, which owns the initial
  documentation audit, detailed page architecture and editorial task tree.
- Current AIL material is linked in the root brief. Inspect enough of it to
  ground the research in its particular density and domain-explanation problem.

## Questions to answer

1. Which guidance helps a language-design reviewer understand an unfamiliar
   problem domain and judge a language proposal? How does that differ from
   documenting an implemented SDK for an experienced API user?
2. How should tutorial, review/task guide, reference and explanation cooperate?
   Identify where rigid separation would remove necessary context and how
   cross-links, local introductions and progressive disclosure avoid that.
3. What makes examples useful for evaluating syntax, semantic consistency,
   expressiveness and authoring effort? Address progressive fragments, complete
   examples, failure cases, expected observations and honest tool limitations.
4. What concrete tests of reader outcomes and document quality should planning,
   drafting, copy-editing, figures and proof use? Distinguish evidence-based
   recommendations from arbitrary style scores or blanket rules.
5. What navigation, reference-entry structure, glossary, tables and diagrams
   reduce review effort without removing necessary technical detail? How can
   reviewers arriving on any page recover its context?

## Done when

- A concise survey exists at
  `semantic/docs/research/documentation-basis-a.md`, co-located under the
  semantic domain per the project's documentation convention.
- The survey inventories the article's main, supplemental, further-reading
  and adjacent-design books, distinguishing titles actually examined from
  relevant-but-inaccessible or lower-priority titles. Prioritise useful evidence
  rather than conducting an indiscriminate full-book reading exercise.
- Applied recommendations cite publisher/author material, legitimate available
  excerpts or official guidance. Record edition and exactly what was inspected;
  never imply a whole book was read when only a contents page or excerpt was
  available. Explicitly record access gaps and inconclusive searches.
- The survey covers the questions above, reconciles conflicts among sources,
  and maps recommendations to this audience, the current AIL documents and
  practical acceptance criteria for `reviewer-documentation-k3`.
- Include the walk-away check for proposed tooling/publishing approaches:
  whether the Markdown, examples and diagrams remain legible without the tool.
  Do not recommend a publishing stack solely because a source uses it.
- The limits of the human-supplied editing prompt are assessed against primary
  sources; IBM's quality dimensions are not reduced to passive-voice counting,
  and "production-ready documentation" does not imply a production-ready AIL.

## Notes

This is one breadth-seeking survey, not a vendor pair. Do not grow the tree;
the downstream planning leaf already exists. Do not rewrite the AIL documents
or propose changes to the language in this research leaf.

The requirements session read the article and sampled the primary pages below.
These are starting points, not a completed literature review or evidence of
full-text access. Verify any claim the survey actually uses:

- [IBM Press book overview](https://www.pearson.com/en-gb/subject-catalog/p/developing-quality-technical-information-a-handbook-for-writers-and-editors/P200000000159?view=educator)
  and [IBM content quality guidance](https://www.ibm.com/docs/en/technical-content?topic=standards-content-quality).
- [Mark Baker's expanded book outline](https://everypageispageone.com/the-book/)
  and [publisher page](https://xmlpress.net/publications/eppo/).
- [Technical Editing, fifth edition](https://www.pearson.com/en-us/subject-catalog/p/technical-editing/P200000002181):
  overview and contents, not full text.
- [Technical Communication, Markel and Selber, thirteenth edition](https://store.macmillanlearning.com/us/product/Technical-Communication/p/1319245005):
  overview and contents, not full text. The article also discusses Lannon and
  Gurak's different book with the same title; do not conflate them.
- [Docs for Developers, first edition](https://link.springer.com/book/10.1007/978-1-4842-7217-6):
  publisher overview, not full text.

The article also points to Document Design, Technical Writing 101, Information
Development, eLearning by Design, Central Works in Technical Communication,
Reporting Technical Information, DITA Best Practices, Managing Writers, Docs
Like Code, Docs-as-Ecosystem, The Product is Docs, Don't Make Me Think,
Information Architecture for the World Wide Web, The Design of Everyday Things
and Web Style Guide. Triage them explicitly; their presence in a list is not
itself evidence for an editorial rule. Separate the author's reviewed titles
from books the author says they have not read and reader-comment suggestions.

## Decisions (running log)

D1. The inventory is built from the article's own text (downloaded and
converted locally, 2026-09-23), not from a fetch summary. A read status is
recorded only where the article states one; section placement is otherwise the
only claim made. The article never mentions Diátaxis or Google's guide, lists
Docs for Developers under books its author has not read, and mentions only the
print Microsoft Manual of Style.

D2. The survey adds sources beyond the article: proposal genres addressed to
expert reviewers (RFC, PEP, Swift Evolution, W3C TAG explainers, TC39),
language documentation self-descriptions, and empirical work on notations, API
documentation, minimalism, examples and readability formulas. The article's
scope is communicators documenting products; this reader's task is evaluating a
notation, which that corpus does not address.

D3. The human's verbatim editing prompt is not in the repository or in a
readable local transcript. The prompt assessment works from the brief chain's
record of it (root brief and plan-k1) and says so.

D4. Diátaxis's "complex hierarchies" page, which held its landing-page and
"not four boxes" guidance, was removed from the live site on 2026-08-03. The
survey cites the current pages first and that page only as history, pinned to
its source commit.

D5. Mid-session, the human asked for a benefit-ranked list of books to buy in a
usable electronic form (preferably PDF). They also stated an eventual aim:
codify this knowledge into grove skills scoped to editorial stages (draft,
copy-edit, art, proof) in the grove repository, rather than one large
documentation skill, noting that much of it concerns prose, expression,
pedagogic structure and reader psychology. The survey therefore organises its
quality criteria by the stage that applies them and gives pedagogy and
psychology evidence equal standing with technical accuracy. It also records
access gaps with legitimate e-format sources. Writing those skills is separate
work in another repository, so no leaf is added here.

D6. The human widened the diagram medium: PlantUML, D2 and Mermaid are equal
notations for this documentation set. Every diagram commits its source and a
tool-generated SVG, and C4-style levels order diagrams from high to low
abstraction. The human also wants grove's requirements and design skills to
gain C4 and hierarchical decomposition, and wants the documentation practice
applied to requirements-gathering and design conversations. Both belong to the
grove repository; the human approved filing a GitHub issue there.

D7. The human approved reading targeted chapters through their O'Reilly
account in their logged-in browser, quoting briefly with citations.

D8. The human suggested that AsciiDoc or DocBook might suit this richer
documentation better than Markdown, and named Typst, with its diagram
packages, as another possible production target. They also noted that C4 has
its own diagram tooling and workflow. The format changes the root brief, so it
stays open. The survey evaluates Markdown, AsciiDoc, DocBook and Typst, plus
the C4 and diagram toolchains, with walk-away checks. Planning must settle the
format with the human before any draft.

D9. With the human's O'Reilly session connected, selected sections (not whole
chapters) were read in full text from DQTI chapters 7, 8, 9 and 13, *Docs for
Developers* chapters 5, 6 and 9, and Clark and Mayer's *e-Learning and the
Science of Instruction* (5th ed.) chapters 6, 9 and 13. *Every Page Is Page One* is not on O'Reilly. The human's
Zotero library supplied full PDFs of Clements et al., *Documenting Software
Architectures* (2nd ed.), and Rozanski and Woods (2005); both were read in
targeted sections. Johnson, *Designing with the Mind in Mind* (2010), was
checked for its chapter list only. The Obsidian vault held no
technical-writing books. The survey records each depth separately, and
purchase priorities favour titles no accessible channel provides in full.

D10. At the human's request, the evidence was filed in the grove repository as
Linkuistics/grove #14 (overview of stage-scoped documentation knowledge) with
#15 `draft`, #16 `copy-edit`, #17 `art`, #18 `proof` and reader testing, and
#19 document format, plus comments on #9 (C4, hierarchical decomposition and
conversation practice) and #12 (writing-for-understanding). The diagram-medium
decision stays in the root brief rather than an ADR until planning settles the
format with the human; both conventions can then be recorded together.
