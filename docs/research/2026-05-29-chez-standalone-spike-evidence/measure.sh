#!/bin/bash
# measure.sh — uniform cold-launch (time-to-run-loop) measurement.
# Launches a command, polls its combined output for "Hello Window opened",
# records wall time, kills it. Runs N times; prints each + median.
# Warm-cache measurement (files cached after first run) — noted in report.
set -uo pipefail
LABEL="${1:?label}"; N="${2:?runs}"; shift 2
HERE="$(cd "$(dirname "$0")" && pwd)"; cd "$HERE"
now() { python3 -c 'import time;print(time.time())'; }
times=()
for run in $(seq 1 "$N"); do
  OUT=$(mktemp)
  start=$(now)
  ( exec env PATH=/usr/bin:/bin "$@" >"$OUT" 2>&1 ) &
  pid=$!
  t=""
  for i in $(seq 1 400); do   # up to ~20s, 50ms granularity
    if grep -q "Hello Window opened" "$OUT" 2>/dev/null; then
      t=$(python3 -c "print(f'{$(now)-$start:.3f}')"); break
    fi
    kill -0 $pid 2>/dev/null || break
    sleep 0.05
  done
  kill -TERM $pid 2>/dev/null; wait $pid 2>/dev/null
  rm -f "$OUT"
  [ -n "$t" ] && { echo "  $LABEL run $run: ${t}s"; times+=("$t"); } \
              || echo "  $LABEL run $run: NO MARKER"
done
if [ "${#times[@]}" -gt 0 ]; then
  med=$(printf '%s\n' "${times[@]}" | sort -n | awk '{a[NR]=$1} END{print a[int((NR+1)/2)]}')
  echo "  $LABEL MEDIAN: ${med}s  (over ${#times[@]} runs)"
fi
