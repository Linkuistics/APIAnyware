# APIAnyware task runner.
#
# lint-annotations — the LLM annotation side-channel gate + report (ADR-0050 §5;
#   ws5 `retire-tooling-k49`). Replaces the retired bash/python scaffolding with
#   the typed `apianyware-analyze annotations` subcommands.
#
#   `annotations stale` is the gate: it exits 1 when any family's committed
#   `annotations.apiw` overlay has drifted from the current resolved API surface
#   (orphaned / new-surface / shape-changed) — so this target fails CI exactly
#   when an overlay needs regenerating. `annotations audit` is informational
#   (always exit 0): per-family disagreement + per-tier win distribution read
#   from each `resolved.json`'s `fact_provenance` carriage.
#
#   PRECONDITION: both read the gitignored per-family `resolved.json`. Run the
#   resolve pipeline first (`apianyware-collect` then `apianyware-analyze`) so the
#   surface is current; each subcommand emits an actionable error if it is absent.

.PHONY: lint-annotations

lint-annotations:
	cargo run --release -q -p apianyware-analyze -- annotations stale
	cargo run --release -q -p apianyware-analyze -- annotations audit
