#!/usr/bin/env bash
# Regenerate analysis + generation artifacts when source code is newer than
# their checkpoint outputs. Used as the work-phase bootstrap hook to
# prevent the stale-checkpoint failure mode where a downstream task forms
# fix hypotheses against artifacts produced by an older source revision.
#
# Freshness rule per stage: regen iff the newest mtime among the stage's
# inputs (source code + upstream checkpoint) is strictly greater than the
# oldest mtime among the stage's outputs. Catches both source edits and
# upstream drift (fresh `collected/` above stale `enriched/` is the
# canonical case).
#
# Stages:
#   1. analyze: inputs are analysis/crates/{datalog,resolve,annotate,enrich}/src
#               + collection/ir/collected. Output: analysis/ir/enriched.
#               LLM annotations in analysis/ir/annotated/*.llm.json are
#               preserved across reruns by load_existing_llm_annotations()
#               (which filters out heuristic-sourced entries) as long as
#               --llm-dir is omitted.
#   2. generate: inputs are generation/crates/emit{,-*}/src
#                + analysis/ir/enriched. Output: generation/targets/{lang}/
#                generated. Runs all registered emitters by default.
#
# Collection (cargo run -p apianyware-collect) is intentionally not
# regenerated here: it costs ~2 minutes and is gated on SDK header changes
# rather than source code changes, which is a manual decision.
#
# Usage:
#   ./analysis/scripts/regenerate-stale-pipeline.sh           # all targets
#   ./analysis/scripts/regenerate-stale-pipeline.sh --target racket
#
# Exits non-zero on any cargo failure so a calling work-phase hook can
# abort the cycle before launching claude.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$PROJECT_ROOT"

LANG_FILTER=""
if [[ $# -gt 0 ]]; then
    case "$1" in
        --target)
            LANG_FILTER="$2"
            ;;
        *)
            echo "Usage: $0 [--target <target>]" >&2
            exit 1
            ;;
    esac
fi

# --- Mtime helpers (BSD stat: stat -f '%m') ---
#
# */compiled/* is excluded because Racket's `raco make` writes .zo/.dep
# bytecode there with mtimes unrelated to the Rust generator's outputs.
#
# Stale rule: newest input mtime > newest output mtime.
#
# We use newest-vs-newest, not newest-vs-oldest, because the generator
# does not necessarily touch every file in its output tree on every run.
# Files emitted by an earlier generator version that the current
# generator no longer produces are orphaned with their original mtime
# and would cause an oldest-output rule to register perpetual staleness.
# The canonical drift case the hook exists to catch is "fresh upstream
# checkpoint, stale downstream checkpoint", and newest-vs-newest catches
# that correctly: if any file in the input tree is newer than the
# newest file in the output tree, the output is definitely stale.

# Newest mtime among files under the given paths. 0 if no files exist.
newest_mtime() {
    local result
    result=$(find "$@" -type f -not -path '*/compiled/*' -exec stat -f '%m' {} + 2>/dev/null | sort -rn | head -1)
    echo "${result:-0}"
}

# Returns 0 (true) if regen is needed: input is strictly newer than
# output, or output is empty/missing.
needs_regen() {
    local input_newest="$1"
    local output_newest="$2"
    if [[ "$output_newest" == "0" ]]; then
        return 0
    fi
    [[ "$input_newest" -gt "$output_newest" ]]
}

# --- Stage 1: analyze ---

ANALYZE_INPUTS=(
    analysis/crates/datalog/src
    analysis/crates/resolve/src
    analysis/crates/annotate/src
    analysis/crates/enrich/src
    analysis/crates/cli/src
    collection/crates/types/src
    collection/ir/collected
)
ANALYZE_OUTPUT=analysis/ir/enriched

# Filter to existing paths only so missing dirs don't break find.
ANALYZE_INPUT_PATHS=()
for p in "${ANALYZE_INPUTS[@]}"; do
    [[ -e "$p" ]] && ANALYZE_INPUT_PATHS+=("$p")
done

if [[ ${#ANALYZE_INPUT_PATHS[@]} -eq 0 ]]; then
    echo "Error: no analyze input paths exist under $PROJECT_ROOT" >&2
    exit 1
fi

ANALYZE_INPUT_NEWEST=$(newest_mtime "${ANALYZE_INPUT_PATHS[@]}")
ANALYZE_OUTPUT_NEWEST=0
[[ -d "$ANALYZE_OUTPUT" ]] && ANALYZE_OUTPUT_NEWEST=$(newest_mtime "$ANALYZE_OUTPUT")

if needs_regen "$ANALYZE_INPUT_NEWEST" "$ANALYZE_OUTPUT_NEWEST"; then
    echo "=== analyze: sources newer than enriched IR — regenerating ==="
    cargo run --quiet -p apianyware-analyze
    # Refresh after regen so the generation stage sees the new mtime.
    ANALYZE_OUTPUT_NEWEST=$(newest_mtime "$ANALYZE_OUTPUT")
else
    echo "=== analyze: enriched IR up to date ==="
fi

# --- Stage 2: generate ---

GENERATE_SRC_INPUTS=(
    generation/crates/emit/src
    generation/crates/emit-racket/src
    generation/crates/cli/src
)
GENERATE_SRC_PATHS=()
for p in "${GENERATE_SRC_INPUTS[@]}"; do
    [[ -e "$p" ]] && GENERATE_SRC_PATHS+=("$p")
done

GENERATE_SRC_NEWEST=0
if [[ ${#GENERATE_SRC_PATHS[@]} -gt 0 ]]; then
    GENERATE_SRC_NEWEST=$(newest_mtime "${GENERATE_SRC_PATHS[@]}")
fi

# Generation input is newest of (gen sources, enriched IR newest).
GENERATE_INPUT_NEWEST=$GENERATE_SRC_NEWEST
if [[ "$ANALYZE_OUTPUT_NEWEST" -gt "$GENERATE_INPUT_NEWEST" ]]; then
    GENERATE_INPUT_NEWEST=$ANALYZE_OUTPUT_NEWEST
fi

# Decide which targets to check.
if [[ -n "$LANG_FILTER" ]]; then
    TARGETS=("$LANG_FILTER")
else
    TARGETS=()
    if [[ -d generation/targets ]]; then
        for d in generation/targets/*/; do
            [[ -d "$d" ]] || continue
            TARGETS+=("$(basename "$d")")
        done
    fi
fi

# A target is stale if any of its source-controlled inputs is newer than
# the oldest file under its generated/ tree. Targets without an existing
# generated/ tree are skipped: the freshness hook is a drift guardrail,
# not a first-time setup tool, and a not-yet-implemented target never
# produces a generated/ dir at all and would otherwise look stale on
# every run.
STALE_TARGETS=()
for tgt in "${TARGETS[@]}"; do
    out="generation/targets/${tgt}/generated"
    if [[ ! -d "$out" ]]; then
        echo "=== generate: skipping ${tgt} (no generated/ — run cargo manually for first-time generation) ==="
        continue
    fi
    out_newest=$(newest_mtime "$out")
    if needs_regen "$GENERATE_INPUT_NEWEST" "$out_newest"; then
        STALE_TARGETS+=("$tgt")
    fi
done

if [[ ${#STALE_TARGETS[@]} -eq 0 ]]; then
    echo "=== generate: all targets up to date ==="
else
    if [[ -n "$LANG_FILTER" ]]; then
        echo "=== generate: regenerating ${LANG_FILTER} ==="
        cargo run --quiet -p apianyware-generate -- --target "$LANG_FILTER"
    elif [[ ${#STALE_TARGETS[@]} -eq ${#TARGETS[@]} ]]; then
        echo "=== generate: regenerating all targets (${STALE_TARGETS[*]}) ==="
        cargo run --quiet -p apianyware-generate
    else
        echo "=== generate: regenerating stale targets (${STALE_TARGETS[*]}) ==="
        for tgt in "${STALE_TARGETS[@]}"; do
            cargo run --quiet -p apianyware-generate -- --target "$tgt"
        done
    fi
fi

echo "=== regenerate-stale-pipeline: done ==="
