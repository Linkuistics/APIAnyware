#!/usr/bin/env bash
# Foreign-thread callback safety spike for the sbcl target (D2, ADR-0035).
# Reproduces the question chez/gerbil settled with their own threading spikes:
# can a foreign (non-SBCL-created) OS thread safely run Lisp under GC pressure?
set -euo pipefail
cd "$(dirname "$0")"
clang -dynamiclib -O2 -o /tmp/libspike.dylib spike.c
echo "=== sbcl foreign-thread callback spike (each test in a fresh process) ==="
for t in native-concurrent foreign-serial foreign-concurrent; do
  out=$(SPIKE_TEST=$t sbcl --non-interactive --disable-debugger --load spike.lisp 2>&1) && code=0 || code=$?
  surv=$(echo "$out" | grep -c "SURVIVED" || true)
  reason=$(echo "$out" | grep -iE "cannot suspend|fatal error" | head -1 || true)
  printf "%-20s exit=%-3s survived=%s  %s\n" "$t" "$code" "$surv" "$reason"
done
