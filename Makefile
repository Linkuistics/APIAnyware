# APIAnyware task runner.
#
# validate — the one validation mechanism (ws8 `validate-umbrella-k154`,
#   ADR-0046 §5). `apianyware-validate` tree-walks every authored `.apiw` artifact
#   and dispatches each to its producing crate's KDL-Schema validator, failing
#   (exit 1) on any schema violation or any `.apiw` that matches no known layout.
#   Runs on a fresh checkout with no pipeline output (authored artifacts are
#   committed). To also validate the derived machine IR (extracted.kdl /
#   resolved.kdl — gitignored, ~2 s/MB, minutes-scale on a materialized corpus),
#   run `apianyware-validate --machine` directly; it is opt-in and NOT part of this
#   target, which stays fast enough to run often.
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

.PHONY: validate lint-annotations

validate:
	cargo run --release -q -p apianyware-validate

lint-annotations:
	cargo run --release -q -p apianyware-analyze -- annotations stale
	cargo run --release -q -p apianyware-analyze -- annotations audit
