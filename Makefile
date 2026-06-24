# APIAnyware task runner.
#
# lint-annotations — gate against stale / redundant LLM annotations.
#   Replaces the retired Ravel-Lite triage pre-hook. Requires the pipeline
#   to have been run at least once (analysis/ir/ checkpoints must exist).

.PHONY: lint-annotations

lint-annotations:
	./platforms/macos/tools/scripts/check-llm-annotation-drift.sh --skip-regen
	mkdir -p /tmp/empty-llm-dir /tmp/heuristic-only-annotated
	cargo run --release -q -p apianyware-analyze -- annotate \
		--output-dir /tmp/heuristic-only-annotated --llm-dir /tmp/empty-llm-dir
	python3 ./platforms/macos/tools/scripts/audit-llm-redundancy.py
