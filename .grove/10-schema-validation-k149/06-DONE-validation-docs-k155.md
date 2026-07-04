# validation-docs-k155

**Kind:** work

## Goal

Give the `schemas/` domain its **validation-model prose** (`schemas/docs/`): the model that ties the
whole validation story together — authored `.apiw` vs the machine IR; **one KDL schema language + one
generic engine** (no JSON Schema); the three complementary layers (the `apianyware-validate` umbrella
command + the per-crate `tests/*_registry.rs` in-crate guards + the `lint-annotations` drift gate);
where validation runs (local `make validate`; **CI deferred** — none exists); and derived reports
staying **on-demand** (D8). Update `schemas/README.md` to match, and pin any new validation term in
`CONTEXT.md`.

## Context

The last ws8 build leaf — everything it documents is now built (k152 codec, k153 machine schema, k154
umbrella). Decisions to reflect: node BRIEF running log D4–D8; ADR-0046 §5. Existing prose to
extend/correct: `schemas/docs/{README,spec-format-schema}.md`, `schemas/README.md`,
`schemas/spec-format/README.md`.

## Done when

- `schemas/docs/` carries the validation-model prose (the layers, the one-schema-language story, the
  authored-vs-machine split, where validation runs, reports-on-demand).
- `schemas/README.md` updated; a `CONTEXT.md` "Validation" vocabulary note added if a term needs
  pinning (e.g. `apianyware-validate`, "validation umbrella").
- The ws8 node done-bar ("the `schemas/` domain has its validation-model prose") is met.
- Golden-neutral (prose only).

## Notes

- Record the **derived-report deferral trigger** (D8): reports (conformance coverage,
  capability/representability) stay derived/uncommitted/un-schema'd (constraint 4; ws6/ws7); note the
  "IF a real machine consumer of a report materializes" reopen condition.
- **On retiring this leaf, the `schema-validation-k149` node has no live leaf left → parent-chain
  cascade.** Ask the user, then promote the node BRIEF's durable outcomes (the D1–D9 decisions, the
  ws8 seams) upward into the root BRIEF as a "**schemas + validation outcomes**" section — mirroring
  how every prior workstream promoted on retirement. The next root workstream is **ws9 (testing
  architecture)**, grown after this node retires; the **ADR-consolidation** step (root BRIEF
  decomposition #10) follows ws9.
