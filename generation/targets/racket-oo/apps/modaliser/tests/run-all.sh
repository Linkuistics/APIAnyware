#!/usr/bin/env bash
# tests/run-all.sh — run the Racket test suite with per-file timeouts and
# silent-failure detection.
#
# Walks tests/test-*.rkt and runs each file with a hard timeout so a single
# hanging test cannot stall the whole suite. Set TIMEOUT=N (seconds) to
# override the per-file budget; 30 is generous enough for cold-cache loads
# of the heavier UI modules.
#
# Silent-failure backstop: rackunit's `check-*` forms record failures to the
# reporter but do not affect the process exit code (memory: "rackunit check-*
# forms exit 0 on failure"). After each file runs, the runner greps the
# captured output for rackunit failure markers and treats any hit as a
# failure even if the process exited 0. This catches the silent-failure
# pattern universally without per-file restructuring.
#
# Exit code is 0 only if every file exits 0 AND emits no failure markers.

set -u
shopt -s nullglob

cd "$(dirname "$0")/.."

TIMEOUT="${TIMEOUT:-30}"

# GNU coreutils timeout — stock macOS has neither `timeout` nor `gtimeout`,
# so brew's coreutils is a hard prerequisite.
if command -v timeout >/dev/null 2>&1; then
    TIMEOUT_BIN=timeout
elif command -v gtimeout >/dev/null 2>&1; then
    TIMEOUT_BIN=gtimeout
else
    echo "ERROR: neither 'timeout' nor 'gtimeout' is on PATH" >&2
    echo "       brew install coreutils" >&2
    exit 2
fi

LOG=$(mktemp -t modaliser-test.XXXXXX)
trap 'rm -f "$LOG"' EXIT

passed=0
failed=0
silent=0
hung=0
fail_list=()

# rackunit failure marker regex. The reporter prints a "FAILURE" header line
# followed by a "name: <check-form>" line for every failed check. Either
# anchor is sufficient to identify a silent failure when rc=0.
RACKUNIT_FAILURE_RE='^FAILURE$|^name:[[:space:]]+check-'

for f in tests/test-*.rkt; do
    start=$SECONDS
    "$TIMEOUT_BIN" -k 1 "$TIMEOUT" racket "$f" >"$LOG" 2>&1
    rc=$?
    elapsed=$((SECONDS - start))

    # Silent-failure backstop: a clean exit with rackunit failure markers
    # in the output is treated as a failure.
    if [ $rc -eq 0 ] && grep -qE "$RACKUNIT_FAILURE_RE" "$LOG"; then
        rc=99
    fi

    case "$rc" in
        0)
            printf '[OK]      %s (%ds)\n' "$f" "$elapsed"
            passed=$((passed + 1))
            ;;
        124|137)
            printf '[TIMEOUT] %s (>%ds)\n' "$f" "$TIMEOUT"
            hung=$((hung + 1))
            fail_list+=("$f (timeout)")
            ;;
        99)
            printf '[SILENT]  %s (rackunit failure markers in output)\n' "$f"
            silent=$((silent + 1))
            fail_list+=("$f (silent rackunit failure)")
            grep -nE "$RACKUNIT_FAILURE_RE|^-{20}|^message:|^location:|^actual:|^expected:" "$LOG" \
                | sed 's/^/  /' | head -40
            ;;
        *)
            printf '[FAIL]    %s (rc=%d)\n' "$f" "$rc"
            failed=$((failed + 1))
            fail_list+=("$f (rc=$rc)")
            sed 's/^/  /' "$LOG" | tail -20
            ;;
    esac
done

echo
echo "Summary: $passed passed, $failed failed, $silent silent, $hung timed out"

if [ ${#fail_list[@]} -gt 0 ]; then
    echo "Failures:"
    for entry in "${fail_list[@]}"; do
        echo "  - $entry"
    done
    exit 1
fi
