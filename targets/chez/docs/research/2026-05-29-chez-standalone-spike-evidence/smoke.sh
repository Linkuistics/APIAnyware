#!/bin/bash
# smoke.sh <run-dir> <binary> — launch a staged standalone binary, capture
# whether it reaches the AppKit run loop ("Hello Window opened"), and time
# boot->run-loop.  CLI smoke only: proves linking + FFI + import resolution
# reach [NSApp run]; it does NOT prove the window draws (VM = Phase G).
# Self-contained check: launched with PATH stripped of Homebrew so no stray
# `chez`/`scheme` is reachable.
set -uo pipefail
RUN="${1:?run dir}"; BIN="${2:?binary}"
HERE="$(cd "$(dirname "$0")" && pwd)"; cd "$HERE"
OUT="$RUN/smoke.out"; : >"$OUT"

now() { python3 -c 'import time;print(time.time())'; }
echo "== launching $RUN/$BIN (PATH=/usr/bin:/bin; no system chez) =="
start=$(now)
( exec env PATH=/usr/bin:/bin "./$RUN/$BIN" >"$OUT" 2>&1 ) &
pid=$!
reached=""
for i in $(seq 1 100); do          # up to ~20s
  if grep -q "Hello Window opened" "$OUT" 2>/dev/null; then
    reached=$(python3 -c "print(f'{$(now)-$start:.2f}')"); break
  fi
  kill -0 $pid 2>/dev/null || break
  sleep 0.2
done
sleep 0.4
kill -TERM $pid 2>/dev/null; wait $pid 2>/dev/null
echo "--- captured output ---"; cat "$OUT"; echo "------------------------"
if [ -n "$reached" ]; then echo "SMOKE PASS: reached run loop in ${reached}s"
else echo "SMOKE FAIL: did not reach run loop"; fi
