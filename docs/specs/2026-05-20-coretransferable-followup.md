# Follow-up FU-1 — `annotate` only iterates `framework.classes`

**Filed:** 2026-05-21, from Task 7 of the Core Pipeline Hardening plan.
**Status:** open follow-up — deliberately out of scope for the hardening plan.
**Origin:** the CoreTransferable sub-case named in
`docs/specs/2026-05-20-core-pipeline-hardening-design.md` (Item 1), resolved by
the Task 5 investigation (`2026-05-20-core-pipeline-hardening-item1-findings.md`
§9, §13).

## Problem

`annotate` (`analysis/crates/annotate/src/lib.rs`) walks `framework.classes`
exclusively. Any framework whose public API is entirely non-class — Swift
protocol/struct/enum declarations — therefore receives **zero** annotations even
when collection and resolution are correct. `CoreTransferable` is the clearest
case: it is a standalone (non-overlay) framework that genuinely declares no
classes — only the `Transferable` / `TransferRepresentation` protocols and nine
representation structs — so it is annotated as if it had no API at all. The same
gap affects the non-class members of the cross-import overlays restored in
Task 6 (their struct/protocol API surface), and any other protocol/struct/enum-only
framework.

This is **not** caused by the `is_foreign_module_type_decl` filter and is not
fixed by Task 6: the Task 5 investigation confirmed `CoreTransferable`'s
`classes = 0` is correct collection output. The gap is purely downstream, in
`annotate`.

## Why it is out of scope here

The Core Pipeline Hardening plan's Task 7 done-criterion is satisfied without
this fix: all six cross-import overlay modules regained at least one foreign
`Class` node, so they are annotated. Closing FU-1 means extending `annotate` to
also iterate `framework.protocols` / `structs` / `enums` — a genuine feature
change to the annotation layer with its own heuristics and golden-test churn,
larger than a hardening cleanup.

## Suggested fix (for whoever picks this up)

Extend `annotate` to iterate protocols, structs, and enums in addition to
classes, mapping each member to the existing annotation heuristics. Account for
the threading / ownership / block heuristics that currently assume a class
receiver. Re-run the pipeline and review annotation-count deltas per framework.

---

# Follow-up FU-2 — stale `SharedWithYouCore.llm.json`

**Filed:** 2026-05-21, from Task 7 of the Core Pipeline Hardening plan.
**Status:** open follow-up — annotation-content cleanup, out of hardening scope.

## Problem

After Task 6's filter fix and a full re-collection,
`./analysis/scripts/check-llm-annotation-drift.sh` (the gate wired up in Task 4)
reports drift in exactly two frameworks: `CoreTransferable` (FU-1 above) and
`SharedWithYouCore`. This dropped from eight before Task 6 — the six cross-import
overlay modules cleared once they regained classes.

`SharedWithYouCore` has 13 classes in collected IR, but `llm-extract` logs
"no interesting methods, skipping" for it and writes no
`analysis/ir/llm-summaries/SharedWithYouCore.methods.json`. A checked-in
`analysis/ir/llm-annotations/SharedWithYouCore.llm.json` nonetheless exists, so
the drift check flags it as "no matching .methods.json": the annotation file was
authored when the framework still had methods the extractor classed as
interesting, and a later extraction change made all of them uninteresting.

This is genuine annotation staleness — exactly what the Task 4 gate exists to
catch — but resolving it is annotation-content work, not pipeline hardening.

## Suggested fix (for whoever picks this up)

Decide per the project's annotation policy: either refresh
`SharedWithYouCore.llm.json` against the current method set (re-annotate via a
subagent), or remove it if `SharedWithYouCore` legitimately has no annotation-
worthy API. Then `check-llm-annotation-drift.sh` returns to a clean state
(modulo FU-1).
