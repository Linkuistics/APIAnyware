# orientation-k72

## Goal

Proof the orientation document after the model-first run: the whole of
`README.md`, `explanation/unsaid.md`, `explanation/model.md` and
`glossary.md`, with G11.

## Context

- Structure briefs: plan §9.1 and §9.8; concept contract: plan §10; route:
  plan §3. Earlier proofs of this node (orientation-k39, orientation-k55).
- The node brief's `## Handed forward` list.

## Done when

- The route landing page → domain page → model page works from a cold start,
  and two direct entries at concept anchors supply their own context.
- Every §10 concept has its anchor, section and map row; every construct in
  the map occurs in the rule text; every map link resolves; each concept
  section cites its rules and states no obligation beyond them.
- The orientation pages' earlier explanations, examples, figures and anchors
  survive, and the k64 residues named in orientation-k69 are gone.
- `task docs:check` passes. No handed-forward entry remains open.
- Any residue that would need another stage is recorded for `model-reading`
  rather than cut as a correction run.

## Notes

Last stage of the bounded run. Cut nothing: `model-reading` follows this node
and owns the human assessment of the model account. Editorial consistency
checks establish neither human comprehension nor a stage's effectiveness.
When the node has no live leaf left, close it and promote to the root brief
what later runs need: the concept anchors, G11's paths and any §10 change.

## Decisions (running log)

- D1: The whole-document read found no actionable defect. Keep the eleven
  concepts, their order and the model-to-notation map unchanged. The watch
  examples remain alternative contracts; ownership, validity, outcomes and
  callback schedules agree across the four pages and G11. No correction run
  or additional reviewer is needed.
- D2: Use `#validity` and `#callbacks` for the two direct-entry checks. Each
  provides a local watch case, its domain motivation, variants, rule citations
  and routes to notation and practice. The cold-start route runs from the
  landing page through the domain explanation to the model and canonical
  rules. These are consistency checks, not evidence of human comprehension.
- D3: Close orientation-k5 after retiring this leaf. The original orientation
  obligations and the model-first completion conditions are satisfied; the
  node has no outstanding hand-forward list. Promote the stable concept
  anchors, G11 paths and the draft's L5 citation addition to the root brief.
  No language decision changed, so no ADR change is warranted.

## Verification

- Read all four orientation pages, including the glossary's examples and
  tables, against plan §3–§7, §9.1, §9.8 and §10 and the canonical L/C/A
  rules. Walked landing → domain → model → canonical rules and direct
  entries at `#validity` and `#callbacks`. No actionable defect or residue
  for another stage was found.
- Enumerated all eleven explicit concept anchors and the map's eleven rows;
  both match §10 in order. Enumerated every code spelling in the map:
  all occur in canonical prose except schematic `@operation::slot`, whose
  qualified slot form is defined in L2/L6. An initial verification assertion
  wrongly expected three grammar keywords to be absent from that prose;
  corrected the assertion and reran the check. No document change followed.
- Compared the earlier three pages against `793cd745`: headings, explicit
  anchors, fenced examples and image embeds are preserved. Omission controls
  detected changes. The stale railroad-key and end-marker descriptions are
  gone from README/glossary; the earlier revision supplies positive controls.
  The three canonical rule files, grammar and frozen buffers/objects/callbacks
  examples are byte-identical to that revision.
- Inspected rendered G1, G4, G9 and both G11 views against their sources,
  adjacent prose and captions. Their relationships agree, labels remain
  legible and the alternative watch contracts stay explicit.
- `task docs:check` passed: 20 Markdown files, 18 reachable pages, matching
  AIL extracts and all 26 SVGs reproduced. SHA-256 digests before and after
  matched for all 104 measured input files: Taskfile, plan, audit, the
  interface-language tree and documentation tools, excluding Python caches.
- Tier 2 graph coverage was checked for the relied-on documentation and
  figures. Generation remains `2026-09-23T09:55:55Z`; relevant Markdown
  metadata is changed/untracked, design files are excluded and some SVGs
  are excluded. Direct source reads and rendered inspection supplied the
  evidence; no structural code or graph-completeness claim was made.
- The proof establishes consistency and preservation. Human understanding
  and judgement of the concept set remain for model-reading-k73; no stage
  effectiveness claim or new process remedy follows from these findings.
