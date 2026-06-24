#!/usr/bin/env bash
# Regenerate analysis + generation artifacts when source code is newer than
# their checkpoint outputs. Used as the work-phase bootstrap hook to
# prevent the stale-checkpoint failure mode where a downstream task forms
# fix hypotheses against artifacts produced by an older source revision.
#
# Freshness rule per stage: regen iff the newest mtime among the stage's
# inputs (source code + upstream artifact) is strictly greater than the
# newest mtime among the stage's outputs. Catches both source edits and
# upstream drift (a fresh `extracted.json` above a stale `resolved.json` is
# the canonical case).
#
# The spec triad (ADR-0046) is co-located per family under
# `platforms/macos/api/<Framework>/`: `extracted.json` + `annotations.apiw`
# (analyze inputs) beside `resolved.json` (analyze output), so the analyze
# freshness check is filtered by file name, not by directory.
#
# Stages:
#   1. analyze: inputs are semantic/tools/{datalog,resolve,enrich,spec-format}/src
#               + platforms/macos/tools/annotate/src + the per-family
#               `extracted.json` + `annotations.apiw`. Output: the per-family
#               `resolved.json`. The authored overlay is the committed
#               `annotations.apiw`; analyze folds it in (§28 precedence).
#   2. generate: inputs are the emit crates (targets/_shared/tools/emit,
#                targets/<t>/tools/emit-<t>) + targets/_shared/tools/generate-cli
#                + the per-family `resolved.json`. Output:
#                targets/<t>/bindings/macos/<generated_subdir>/. Runs all
#                registered emitters by default.
#
# Collection (cargo run -p apianyware-collect) is intentionally not
# regenerated here: it costs ~2 minutes and is gated on SDK header changes
# rather than source code changes, which is a manual decision.
#
# Usage:
#   ./platforms/macos/tools/scripts/regenerate-stale-pipeline.sh           # all targets
#   ./platforms/macos/tools/scripts/regenerate-stale-pipeline.sh --target racket
#
# Exits non-zero on any cargo failure so a calling work-phase hook can
# abort the cycle before launching claude.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
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

# Newest mtime among files named <name> under <root>. 0 if none / no root.
# Used for the co-located spec triad, where input (`extracted.json` /
# `annotations.apiw`) and output (`resolved.json`) share one directory tree.
newest_mtime_named() {
    local name="$1" root="$2" result
    [[ -d "$root" ]] || { echo 0; return; }
    result=$(find "$root" -type f -name "$name" -exec stat -f '%m' {} + 2>/dev/null | sort -rn | head -1)
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

ANALYZE_SRC_INPUTS=(
    semantic/tools/datalog/src
    semantic/tools/resolve/src
    platforms/macos/tools/annotate/src
    semantic/tools/enrich/src
    semantic/tools/spec-format/src
    semantic/tools/analyze-cli/src
    semantic/tools/types/src
)
API_ROOT=platforms/macos/api

# Filter to existing source paths only so missing dirs don't break find.
ANALYZE_SRC_PATHS=()
for p in "${ANALYZE_SRC_INPUTS[@]}"; do
    [[ -e "$p" ]] && ANALYZE_SRC_PATHS+=("$p")
done

if [[ ${#ANALYZE_SRC_PATHS[@]} -eq 0 ]]; then
    echo "Error: no analyze source paths exist under $PROJECT_ROOT" >&2
    exit 1
fi

# Analyze inputs: source code, plus the per-family machine `extracted.json` and
# the authored `annotations.apiw`. Output: the per-family `resolved.json`.
ANALYZE_INPUT_NEWEST=$(newest_mtime "${ANALYZE_SRC_PATHS[@]}")
for n in \
    "$(newest_mtime_named extracted.json "$API_ROOT")" \
    "$(newest_mtime_named annotations.apiw "$API_ROOT")"; do
    [[ "$n" -gt "$ANALYZE_INPUT_NEWEST" ]] && ANALYZE_INPUT_NEWEST=$n
done
ANALYZE_OUTPUT_NEWEST=$(newest_mtime_named resolved.json "$API_ROOT")

if needs_regen "$ANALYZE_INPUT_NEWEST" "$ANALYZE_OUTPUT_NEWEST"; then
    echo "=== analyze: inputs newer than resolved IR — regenerating ==="
    cargo run --quiet -p apianyware-analyze
    # Refresh after regen so the generation stage sees the new mtime.
    ANALYZE_OUTPUT_NEWEST=$(newest_mtime_named resolved.json "$API_ROOT")
else
    echo "=== analyze: resolved IR up to date ==="
fi

# --- Stage 2: generate ---

GENERATE_SRC_INPUTS=(
    targets/_shared/tools/emit/src
    targets/_shared/tools/generate-cli/src
    targets/racket/tools/emit-racket/src
    targets/chez/tools/emit-chez/src
    targets/gerbil/tools/emit-gerbil/src
    targets/sbcl/tools/emit-sbcl/src
)
GENERATE_SRC_PATHS=()
for p in "${GENERATE_SRC_INPUTS[@]}"; do
    [[ -e "$p" ]] && GENERATE_SRC_PATHS+=("$p")
done

GENERATE_SRC_NEWEST=0
if [[ ${#GENERATE_SRC_PATHS[@]} -gt 0 ]]; then
    GENERATE_SRC_NEWEST=$(newest_mtime "${GENERATE_SRC_PATHS[@]}")
fi

# Generation input is newest of (gen sources, resolved IR newest).
GENERATE_INPUT_NEWEST=$GENERATE_SRC_NEWEST
if [[ "$ANALYZE_OUTPUT_NEWEST" -gt "$GENERATE_INPUT_NEWEST" ]]; then
    GENERATE_INPUT_NEWEST=$ANALYZE_OUTPUT_NEWEST
fi

# Decide which targets to check.
if [[ -n "$LANG_FILTER" ]]; then
    TARGETS=("$LANG_FILTER")
else
    TARGETS=()
    if [[ -d targets ]]; then
        for d in targets/*/; do
            tgt="$(basename "$d")"
            [[ "$tgt" == "_shared" ]] && continue
            [[ -d "${d}bindings/macos" ]] || continue
            TARGETS+=("$tgt")
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
    # Per-target emitted-bindings subdir under bindings/macos/: chez interleaves
    # its emitted libraries with the runtime under apianyware/; the rest emit into
    # generated/ (matches each emitter's TargetInfo::generated_subdir).
    case "$tgt" in
        chez) sub="apianyware" ;;
        *) sub="generated" ;;
    esac
    out="targets/${tgt}/bindings/macos/${sub}"
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
