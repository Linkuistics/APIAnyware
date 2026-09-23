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
