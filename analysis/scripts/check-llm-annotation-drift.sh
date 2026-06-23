#!/usr/bin/env bash
# Validate every checked-in .llm.json against a freshly-regenerated method
# summary. Catches annotation staleness immediately after an extraction fix
# changes the method set for one or more frameworks (canonical case:
# foreign-module type-decl filter, 2026-04-20, affecting 16 frameworks).
#
# Workflow:
#   1. Re-run `llm-extract` against the current resolved IR so the
#      `.methods.json` summaries match what the current extractor produces.
#   2. For each `analysis/ir/llm-annotations/*.llm.json`, run `llm-validate`
#      against its matching summary.
#   3. Print a summary; exit non-zero if any framework failed.
#
# Use as a post-extraction-fix verification step, or wire into a triage hook
# to gate annotation drift between cycles.
#
# Usage:
#   ./analysis/scripts/check-llm-annotation-drift.sh
#   ./analysis/scripts/check-llm-annotation-drift.sh --skip-regen   # use existing summaries

set -euo pipefail
IFS=$'\n\t'

script_dir="$(cd "$(dirname "$0")" && pwd)"
project_root="$(cd "${script_dir}/../.." && pwd)"
cd "${project_root}"

annotations_dir="analysis/ir/llm-annotations"
summaries_dir="analysis/ir/llm-summaries"
resolved_dir="analysis/ir/resolved"

skip_regen=0
if [[ "${1:-}" == "--skip-regen" ]]; then
  skip_regen=1
fi

if [[ ! -d "${annotations_dir}" ]]; then
  echo "error: ${annotations_dir} not found (no .llm.json files to validate)" >&2
  exit 2
fi

if [[ "${skip_regen}" -eq 0 ]]; then
  if [[ ! -d "${resolved_dir}" ]]; then
    echo "error: ${resolved_dir} missing — run \`apianyware-analyze resolve\` first" >&2
    exit 2
  fi
  echo "regenerating ${summaries_dir} from ${resolved_dir} ..."
  cargo run -q -p apianyware-analyze -- llm-extract \
    --input-dir "${resolved_dir}" \
    --output-dir "${summaries_dir}"
fi

if [[ ! -d "${summaries_dir}" ]]; then
  echo "error: ${summaries_dir} missing — re-run without --skip-regen" >&2
  exit 2
fi

failed=()
checked=0

for llm_file in "${annotations_dir}"/*.llm.json; do
  [[ -e "${llm_file}" ]] || continue
  framework="$(basename "${llm_file}" .llm.json)"
  methods_file="${summaries_dir}/${framework}.methods.json"
  checked=$((checked + 1))

  if [[ ! -f "${methods_file}" ]]; then
    # Annotation exists for a framework no longer in the current method
    # summary — either the framework was removed, renamed, or its methods
    # all became uninteresting after an extraction change.
    failed+=("${framework} (no matching .methods.json)")
    continue
  fi

  if ! cargo run -q -p apianyware-analyze -- llm-validate \
    --methods-file "${methods_file}" \
    --llm-file "${llm_file}" >/dev/null 2>&1; then
    failed+=("${framework}")
  fi
done

echo
if [[ "${#failed[@]}" -eq 0 ]]; then
  echo "ok: all ${checked} .llm.json files validate against current resolved IR"
  exit 0
fi

echo "drift detected in ${#failed[@]} of ${checked} annotated frameworks:" >&2
for f in "${failed[@]}"; do
  echo "  - ${f}" >&2
done
echo >&2
echo "next: re-run llm-validate per framework for full error detail, then" >&2
echo "      dispatch subagents to refresh the affected .llm.json files" >&2
echo "      (see analysis/scripts/llm-annotate-orchestration.md)." >&2
exit 1
