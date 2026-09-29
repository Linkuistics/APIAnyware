# concepts-k95

## Goal

Correct the source-language and platform framing of the overview, API model
and syntax rationale, as requested at full-set-reading-k12.

## Context

- Human feedback and dispositions: full-set-reading-k12, D6 onward.
- Structure brief: documentation plan §9.2, *Full-set scope correction*;
  intended source/consumer scope in §1.
- The node brief defines the bounded document and single-run limit.

## Work

1. Read the bounded document: `README.md`, `explanation/model.md` and
   `explanation/choices.md` under `semantic/specification/interface-language/`.
2. Establish the intended .NET, Linux/Wayland/GTK/KDE, Rust and other typed-library
   scope. Distinguish described APIs from consumers; interpreted and dynamically
   typed languages remain consumers. Keep the source-side preference tentative.
   Describe intended breadth without claiming a common C ABI or supplied providers.
3. Revise *A dedicated syntax* and its summary row to assess a source language's
   syntax against the common model without privileging Swift.
4. Enumerate and classify source/platform framing across the published set,
   including summaries and captions. Change directly affected prose; preserve
   accurate history, explicitly synthetic fixture names and provider limitations.
   Do not mechanically remove every Swift mention.
5. Preserve the eleven model concepts, canonical wording, grammar and every
   committed `.ail` file. Q7 remains later syntax exploration, and the later
   conversational rewrite is outside this correction. Verify preservation and
   run the documentation checks.

## Done when

- Overview, model and rationale consistently state the intended source/consumer
  breadth without privileged Swift framing or invented support claims.
- Retained source-specific mentions and changed summaries have a reason.
- Canonical wording, grammar and examples are preserved; `task docs:check` passes.

## Notes

The ordered run k95 → k96 → k97 → k98 is already queued. Add no duplicate tail
or automatic rerun. Hand later-stage defects forward in the node brief;
other scope returns to the human. The rest of the set is accepted for now.
