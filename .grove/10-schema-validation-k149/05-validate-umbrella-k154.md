# validate-umbrella-k154

**Kind:** work

## Goal

Deliver the **one validation mechanism** the ws8 done-bar demands: a single tree-walking
`apianyware-validate` command that validates **every authored `.apiw`** against its schema **and**
the **machine IR** against the machine KDL-Schema (k153), in one invocation. Home it in a **new crate
`schemas/tools/validate/`** — `schemas/` becomes an active tool home (D6), per the crate-home
convention (a crate lives under the domain it serves). Wire it into a `make validate` target
alongside `lint-annotations`.

## Context

Depends on `machine-kdl-schema-k153` (the machine schema to validate the IR against). The mechanism
is a **lean driver over the machinery that already exists**, not new machinery (mirror ws5's
"lean mechanism over git + the pipeline, not a subsystem"):

- **Reuse** `apianyware_spec_format::validate_against_schema` + the per-crate `SCHEMA_TEXT` constants
  / `validate_apiw` already used by every producing crate — the umbrella walks the tree and dispatches
  each artifact to its existing schema; it does not re-implement validation.
- **The per-crate `tests/*_registry.rs` stay** as in-crate guards — the umbrella is a *runnable*
  command (dev + `make`), not a replacement for the tests.
- **Crate-home convention** (skeleton outcomes, root BRIEF): shared crate under the domain it serves →
  `schemas/tools/validate/`. Register it in the root `Cargo.toml` `members`.
- **CI is deferred (D5).** No `.github/workflows/` — none exists today, so CI is net-new
  infrastructure, out of ws8's lean scope. Wiring is `make validate` (see the `lint-annotations`
  block in `Makefile` as the pattern).
- Decision record: node BRIEF running log D5/D6; ADR-0046 §5 (one schema language).

## Done when

- `apianyware-validate` validates all authored `.apiw` artifacts (against their schemas) + the
  machine `extracted.kdl` / `resolved.kdl` (against the machine KDL-Schema) in one run, with
  actionable per-artifact errors + a non-zero exit on failure.
- `make validate` runs it (alongside `lint-annotations`); the crate is a root `Cargo.toml` member.
- The "one validation mechanism over every authored artifact + the machine IR" done-bar is met.
- Golden-neutral (tooling only — no emit path touched).

## Notes

- Keep it lean: dispatch to existing schemas + the shared engine; do not duplicate per-artifact rules.
- CI (GitHub Actions) is explicitly **out of scope** (D5) — record it as a deferred, separately-scoped
  concern if worth a trigger note, don't build it.
- The machine IR is gitignored/derived — the command should validate it when materialized and give an
  actionable "run the pipeline first" message when absent (mirror `make lint-annotations`'s precondition).
- **Machine-IR validation perf (finding from k153):** `validate_machine_kdl` runs on the shared engine,
  whose front door is the format-preserving `kdl::KdlDocument::parse` — the ~84×-`serde_json` parser JiK
  exists to bypass. Measured **~2 s/MB**, ~98% of it that parse; a flattened `resolved.kdl` can exceed
  80 MB (AppKit), so validating the full materialized corpus is a **minutes-scale** operation. k153's
  registry test bounds this with a cumulative work budget. The umbrella must **not** silently validate
  the whole corpus on every `make validate` — decide the policy (opt-in `--machine` flag / bounded set /
  a `jik`-parser fast path that validates the `serde_json::Value` instead of the `KdlDocument`). The
  fast-path — a `Value`-based validation engine reusing the schema *model* — is the clean fix but is
  **new machinery** (the current engine is `KdlNode`-based); weigh it against the lean-driver mandate.
