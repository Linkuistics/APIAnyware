# schemas/docs/ — validation-model documentation

Per the documentation-placement rule (REFACTOR.md §10), schema docs live here: the
prose explaining the validation model and a per-artifact schema reference (which
schema validates which file, how to run validation).

## Authored so far

- [`spec-format-schema.md`](spec-format-schema.md) — the authored `.apiw` overlay
  contract: which schema validates it, why it is language-neutral, how non-Rust
  tools consume it, and the ws8 boundary. Authored by **workstream 2**.

TODO: the rest of the validation-model prose (machine JSON Schema, app-kinds,
AppSpecs, capability profiles, conformance reports, how to run validation in CI)
is authored in **workstream 8**.
