# rule-reading-k67

## Goal

Read the whole rule-reading set through the proof charter and leave
`language.md`, `contracts.md` and `profiles.md` ready for the following
human-directed document corrections.

## Context

- Read the node brief and documentation plan §4–§7 and §9.7. This is the
  whole-document proof after two drafts, copy-edit and art.
- G9 is `figures/g9-model.{puml,svg}`. G10 comprises shell, clause, names,
  callable, places, environment, pattern, outcome, callback-use, dependency
  and access source/SVG pairs. Native PlantUML EBNF productions match
  `grammar.ebnf`; the shared `railroad-key.puml` explains their notation.
- Art resolved every required/optional slot and cleared its handoffs. L2/C1
  share the place view. C5/C6/A2 link the callable overview and add details;
  G3 provider and G7 timing explanations remain linked. The node brief records
  reusable paths and why both optional syntax details were retained.
- Canonical pre-draft revision: `87221b8c` for all three pages. Strip each
  paired reading-aid block including its trailing blank separator to compare
  original normative bytes. Grammar, conformance record, F1 catalogue and
  buffers/objects/callbacks fixtures are frozen.

## Work

Read every page, including normative boundaries, examples, tables, captions,
alt text, diagram keys and next/back routes. Apply the document contract across
all proof classes. Check package/declaration containment and the separate
member relation, named receiver and callback slots, import and provider aliases,
reference/type/place distinctions, grammar branches and semantic restrictions.
Keep the geometry/canvas example names, placeholder digest and synthetic F1
provider limits explicit. Inspect the complete Handler extracts at A2 and C6:
`callbacks.ail` lines 19–37 include the declaration's closing brace.

Inspect figures beside their examples and follow direct-rule and
overview-to-rule routes. Run `task docs:check`; after the final edit repeat
canonical byte comparisons. Intentional diagram edits require
`task docs:diagrams:write` followed by checks and visual inspection. Art's
checks establish consistency, not a parser, semantic validator or human
comprehension. `first-path-reading-k64` owns the human assessment.

On closing rule-reading-k49, check its Done when and promote the reusable
example/figure paths and boundaries from the node brief to the root brief so
orientation, concepts and tutorial corrections receive them. Retire and commit
this leaf with any parent-chain closure, then signal as the proof skill directs.

## Done when

- The complete set passes the document contract and repository checks.
- Canonical text/anchors, grammar, catalogue and frozen examples are preserved.
- No unresolved proof findings remain; reuse context is promoted on node close.

## Notes

This node has an explicit human-directed correction bound. Record substantive
earlier-stage defects for `first-path-reading-k64`; do not start another
unattended correction run. Do not infer human understanding from editorial
checks or treat the pending reader checkpoint as proof work.

## Decisions (running log)

D1. The whole-document read found no actionable defect in the three rule pages
or their reading aids. Keep the delivered prose and figures unchanged. Checked
package containment separately from member ownership; import/provider aliases,
receiver and callback slots, bare types, references and places; lifetime,
outcome and callback obligations; and each provider-support boundary against
the canonical rules and frozen fixtures. The Handler extracts include their
closing brace. Rendered G9 and every G10 view agree with the adjacent examples,
keys and grammar productions. No correction run or reviewer was needed.

D2. Direct L2 entry supplies the two-package model before dependent reference
syntax. The overview reaches each canonical page; their local rule links,
glossary/prerequisite routes, detail-to-overview links and explanation/example
routes supply onward navigation. The node has no remaining handed-forward
entry. Full reference inventory work remains with the queued reference node;
human comprehension remains with `first-path-reading-k64`.

D3. Graph generation `2026-09-23T09:55:55Z` is older than the document edits;
coverage reports changed/untracked Markdown and excluded design/example
material. Evidence for this proof comes from direct source reads and rendered
figures, not graph completeness or structural code claims.

D4. `task docs:check` passed: links and example fences checked across 19 files,
17 documentation pages reachable, and all 23 SVGs reproduced. Before/after
SHA-256 digests matched for the 92 subjects: all files under the interface-language
directory and specification tools (excluding Python caches), root Taskfile,
documentation plan and audit. Every G10 production token sequence matches
`grammar.ebnf`. Removing the complete paired reading-aid blocks and their blank
separators recovers `language.md`, `contracts.md` and `profiles.md` byte for byte
from `87221b8c`, including rule anchors and F1. The grammar, conformance record
and buffers/objects/callbacks fixtures also match that revision byte for byte.
These are consistency and preservation checks, not parsing, semantic validation
or evidence of human understanding.
