# concepts-k96

## Goal

Copy-edit the bounded source/platform correction for the settled reader,
scope and prose contract.

## Context

- Documentation plan §9.2, *Full-set scope correction*; §1 and §4–§5.
- concepts-k95 and the node brief's handed-forward items.
- Full-set-reading-k12 records the human's words and explicitly later aims.

## Work

Read the whole bounded document and affected summaries identified by k95.
Keep the actor distinction clear: the described API/library, the producer of
its description and the consumer language or tool. Make the wider intended
scope concrete without implying a common C ABI or production provider support.
Fix sentences and terminology within the copy-edit charter, retaining useful
source-specific examples. The general conversational rewrite and clause-specific
syntax design are later work. Preserve Q7's open status, rules and examples.

## Done when

- The corrected pages express the settled source/consumer scope with clear
  actors and the existing prose contract.
- No general rewrite, language redesign or unsupported coverage claim is added.
- Handed-forward items are resolved within charter or recorded;
  `task docs:check` passes.

## Notes

concepts-k97 and concepts-k98 are already queued. Do not grow a duplicate tail
or another correction run. Record earlier-stage residue for the human.

## Decisions (running log)

D1 — Read the three pages' k95 changes (jj diff of concepts-k95) against plan
§4. Fixes: negative or stative phrasings recast positively in the README scope
section ("assumes no common C ABI" → "does not assume one C ABI shared…",
"establishes no exclusion" → "rules out no language as such"); "provider" and
"consumer" linked to the glossary at first use on the page (README, model,
choices) so each term keeps one meaning; "different languages again" and "the
other APIs' contracts" replaced by concrete wording; "either notation" in
choices now names the two alternatives it refers to. Actors stay distinct:
caller (program), consumer (tool), producer, provider.
D2 — No restructuring, no rule/grammar/example change, Q7 untouched.
`task docs:check` passes (0 pending, 0 errors). No later-stage defect found;
art (k97) and proof (k98) already stand, so no leaf added.
