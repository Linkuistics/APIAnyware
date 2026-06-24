# schemas/ — formal validation

The `schemas/` domain holds the formal schemas that validate every artifact in the
repository (REFACTOR.md §8): the extracted / annotations / resolved platform specs,
app-kind definitions, common AppSpecs, target capability profiles, and conformance
reports. This is the "obvious place for schemas" the success criteria demand
(§45.13) and the home the root README points validation at (§11).

## Authored so far

- **`spec-format/`** — the **authored `.apiw` overlay** schema
  (`annotations.kdl-schema`), the language-neutral KDL Schema contract for the
  authored semantic overlay (ADR-0046 §3). Authored by **workstream 2**
  (`spec-format-k16` → `kdl-schema-k19`), validated by the `apianyware-spec-format`
  crate's validator step. See [`docs/spec-format-schema.md`](docs/spec-format-schema.md).

## TODO (workstream 8)

The remaining schemas are authored in workstream 8 (schemas + validation):

- the **JSON Schema** for the machine `extracted.json` / `resolved.json` (the
  machine IR is JSON, ADR-0046's k17 retreat — only the authored overlay is KDL);
- schemas for **app-kinds**, common **AppSpecs**, target **capability profiles**,
  and **conformance reports**;
- the validation **tooling/CI** that runs every schema.
