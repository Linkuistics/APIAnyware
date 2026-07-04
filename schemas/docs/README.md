# schemas/docs/ — validation-model documentation

Per the documentation-placement rule (REFACTOR.md §10), schema docs live here: the
prose explaining the validation model and a per-artifact schema reference (which
schema validates which file, how to run validation).

## Contents

- [`validation-model.md`](validation-model.md) — **the validation model**: one schema
  language + one generic engine, the authored-vs-machine split, the three complementary
  layers (`apianyware-validate` umbrella · per-crate `tests/*_registry.rs` guards ·
  `lint-annotations` drift gate), where validation runs (local `make`; CI deferred), and why
  derived reports stay on-demand. Authored by **workstream 8** (`validation-docs-k155`).
- [`spec-format-schema.md`](spec-format-schema.md) — the authored `.apiw` overlay
  contract: which schema validates it, why it is language-neutral, how non-Rust
  tools consume it. Authored by **workstream 2**.

The per-schema reference (all thirteen contracts, their files, their producing crates) is
[`../spec-format/README.md`](../spec-format/README.md).
