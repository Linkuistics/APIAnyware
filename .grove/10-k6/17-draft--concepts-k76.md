# concepts-k76

## Goal

Give every direct rule entry a route to the model: add the model page to the
canonical pages' page-one blocks and a one-sentence model-concept route to the
first reading aid of each rule section, preserving the rule text exactly.
Apply the example-led refinement to the non-normative aids, glossary and
landing-page routes so they explain meaning and link to the grammar.

## Context

- Structure briefs: plan §9.7 items 7–8 and §9.2's *Canonical reading-aid routes*
  and *Example-led refinement*. Human direction: model-reading-k73.
  Concepts and anchors: plan §10 (its *Rules* column maps rule sections to
  concepts).
- Aid convention and preservation check: rule-reading-k49's brief (*Draft
  conventions and reuse*): paired `reading-aid` comments, blockquote border,
  bold label, explicit anchors, comparison against revision `87221b8c`.
- concepts-k74 and concepts-k75 for the concept-page sections those routes
  may also name.
- Concepts-k85's grammar home and migrated canonical G10 links; retain its
  section anchors and all local examples.

## Done when

- The page-one blocks of `language.md`, `contracts.md` and `profiles.md` name
  the model page in *Before this*.
- Each rule section L1–L6, C1–C8, A1–A5 and F1 opens its first reading aid
  with one sentence naming the §10 concept(s) its constructs express, linked
  to `explanation/model.md` anchors; a section without an aid gets a short
  bordered one. The mapping used is recorded in this leaf.
- Stripping all paired reading-aid blocks still reproduces the three pages
  byte for byte from `87221b8c`; the grammar, conformance record and frozen
  examples are unchanged. The check has been seen to fail on a deliberate
  mutation before its clean result is credited.
- The non-normative aids and glossary explain AIL-specific meaning and
  relationships, without teaching familiar punctuation. Canonical rule text
  is never reworded to remove syntax commentary. Every local example and
  semantic distinction stays; moving the railroads does not turn an aid into
  links alone.
- The landing page and glossary link the grammar-reference sections for
  exact syntax and the canonical aids for meaning; previous anchors and
  incoming links still resolve. No G10 embed remains on these pages.
- `task docs:check` passes.

## Notes

Last draft session of the bounded run. Copy-edit, art and proof are already
queued as live later siblings, so cut nothing at the end. Change no rule text,
anchor, grammar or fixture.
