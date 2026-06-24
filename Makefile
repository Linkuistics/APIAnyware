# APIAnyware task runner.
#
# lint-annotations — gate against stale / redundant LLM annotations.
#   SUPERSEDED by the pipeline cutover (pipeline-cutover-k20, ADR-0046): the
#   `_llm-annotations` side-channel + `analysis/ir/` checkpoints are retired, and
#   `apianyware-analyze` no longer has an `annotate --llm-dir` subcommand (the
#   authored overlay is the committed per-family `annotations.apiw`). This target
#   targets the OLD layout; reworking the lint over `.apiw` is workstream 5 (TODO.md).

.PHONY: lint-annotations

lint-annotations:
	./platforms/macos/tools/scripts/check-llm-annotation-drift.sh --skip-regen
	mkdir -p /tmp/empty-llm-dir /tmp/heuristic-only-annotated
	cargo run --release -q -p apianyware-analyze -- annotate \
		--output-dir /tmp/heuristic-only-annotated --llm-dir /tmp/empty-llm-dir
	python3 ./platforms/macos/tools/scripts/audit-llm-redundancy.py
