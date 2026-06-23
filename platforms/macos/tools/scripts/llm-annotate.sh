#!/usr/bin/env bash
# Provider-agnostic LLM annotation script for macOS API methods.
#
# Reads resolved IR, sends batches of methods to an LLM provider for
# semantic annotation, and writes the results as FrameworkAnnotations JSON.
#
# Usage:
#   ./platforms/macos/tools/scripts/llm-annotate.sh                    # annotate all frameworks
#   ./platforms/macos/tools/scripts/llm-annotate.sh Foundation AppKit   # specific frameworks
#
# Prerequisites:
#   - Copy config.example.toml to config.toml and set your API key
#   - jq, curl must be available
#   - The API key env var (from config.toml) must be set
#
# After running this script, merge heuristic + LLM annotations:
#   cargo run -p apianyware-analyze -- annotate

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/config.toml"

# --- Parse config ---
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Error: $CONFIG_FILE not found. Copy config.example.toml to config.toml and configure."
    exit 1
fi

# Simple TOML parsing (good enough for flat config)
get_config() {
    local key="$1"
    grep "^${key}" "$CONFIG_FILE" | sed 's/.*= *"//' | sed 's/".*//'
}

BASE_URL=$(get_config "base_url")
MODEL=$(get_config "model")
API_KEY_ENV=$(get_config "api_key_env")
RESOLVED_DIR=$(get_config "resolved_dir")
ANNOTATED_DIR=$(get_config "annotated_dir")
PROMPT_TEMPLATE=$(get_config "prompt_template")
BATCH_SIZE=$(get_config "batch_size")
TEMPERATURE=$(get_config "temperature")

API_KEY="${!API_KEY_ENV:-}"
if [[ -z "$API_KEY" ]]; then
    echo "Error: ${API_KEY_ENV} environment variable is not set."
    exit 1
fi

RESOLVED_PATH="${PROJECT_ROOT}/${RESOLVED_DIR}"
ANNOTATED_PATH="${PROJECT_ROOT}/${ANNOTATED_DIR}"
PROMPT_PATH="${PROJECT_ROOT}/${PROMPT_TEMPLATE}"

mkdir -p "$ANNOTATED_PATH"

# --- Discover frameworks ---
if [[ $# -gt 0 ]]; then
    FRAMEWORKS=("$@")
else
    FRAMEWORKS=()
    for f in "${RESOLVED_PATH}"/*.json; do
        [[ -f "$f" ]] || continue
        FRAMEWORKS+=("$(basename "$f" .json)")
    done
fi

if [[ ${#FRAMEWORKS[@]} -eq 0 ]]; then
    echo "No frameworks found in ${RESOLVED_PATH}"
    exit 1
fi

echo "Annotating ${#FRAMEWORKS[@]} framework(s): ${FRAMEWORKS[*]}"

# --- Read prompt template ---
PROMPT_SYSTEM=$(cat "$PROMPT_PATH")

# --- Process each framework ---
for FW_NAME in "${FRAMEWORKS[@]}"; do
    RESOLVED_FILE="${RESOLVED_PATH}/${FW_NAME}.json"
    OUTPUT_FILE="${ANNOTATED_PATH}/${FW_NAME}.llm.json"

    if [[ ! -f "$RESOLVED_FILE" ]]; then
        echo "Warning: ${RESOLVED_FILE} not found, skipping ${FW_NAME}"
        continue
    fi

    echo "Processing ${FW_NAME}..."

    # Extract class/method summary for the LLM
    # Filter to methods with block params, error params, or delegate patterns
    METHOD_SUMMARY=$(jq -r '
        [.classes[] | {
            class_name: .name,
            methods: [
                (.methods // [])[] ,
                (.category_methods // [] | .[].methods // [])[]
            ] | select(
                (.params // [] | any(.type.kind == "block")) or
                (.params // [] | last | select(.name | test("error"; "i")) | .type.kind == "pointer") or
                (.selector | test("delegate|datasource|target|observer"; "i"))
            ) | {
                selector,
                class_method,
                params: [.params[]? | {name, type: .type.kind}]
            }
        } | select(.methods | length > 0)]
    ' "$RESOLVED_FILE" 2>/dev/null || echo "[]")

    if [[ "$METHOD_SUMMARY" == "[]" || -z "$METHOD_SUMMARY" ]]; then
        echo "  No interesting methods found in ${FW_NAME}, skipping"
        continue
    fi

    METHOD_COUNT=$(echo "$METHOD_SUMMARY" | jq 'map(.methods | length) | add // 0')
    echo "  Found ${METHOD_COUNT} interesting methods"

    # Build the user prompt
    USER_PROMPT="Annotate the following methods from the ${FW_NAME} framework.

Methods to annotate:
${METHOD_SUMMARY}

Return a JSON object matching the FrameworkAnnotations schema described in the system prompt."

    # Call the LLM API
    RESPONSE=$(curl -s "${BASE_URL}/messages" \
        -H "Content-Type: application/json" \
        -H "x-api-key: ${API_KEY}" \
        -H "anthropic-version: 2023-06-01" \
        -d "$(jq -n \
            --arg model "$MODEL" \
            --arg system "$PROMPT_SYSTEM" \
            --arg user "$USER_PROMPT" \
            --argjson temp "${TEMPERATURE:-0}" \
            '{
                model: $model,
                max_tokens: 8192,
                temperature: $temp,
                system: $system,
                messages: [{role: "user", content: $user}]
            }'
        )" 2>/dev/null)

    # Extract JSON from response
    ANNOTATION_JSON=$(echo "$RESPONSE" | jq -r '.content[0].text // empty' 2>/dev/null || true)

    if [[ -z "$ANNOTATION_JSON" ]]; then
        echo "  Warning: No response from LLM for ${FW_NAME}"
        echo "  Response: $(echo "$RESPONSE" | head -c 500)"
        continue
    fi

    # Try to extract JSON from markdown code blocks if present
    if echo "$ANNOTATION_JSON" | grep -q '```json'; then
        ANNOTATION_JSON=$(echo "$ANNOTATION_JSON" | sed -n '/```json/,/```/p' | sed '1d;$d')
    fi

    # Validate JSON
    if echo "$ANNOTATION_JSON" | jq empty 2>/dev/null; then
        echo "$ANNOTATION_JSON" | jq '.' > "$OUTPUT_FILE"
        echo "  Wrote ${OUTPUT_FILE}"
    else
        echo "  Warning: Invalid JSON response for ${FW_NAME}, saving raw response"
        echo "$ANNOTATION_JSON" > "${OUTPUT_FILE}.raw"
    fi
done

echo ""
echo "Done. Run the heuristic merge to combine annotations:"
echo "  cargo run -p apianyware-analyze -- annotate"
