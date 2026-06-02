#!/usr/bin/env bash
# run.sh — build + run the whole ffi2 spike, capture results. THROWAWAY (040/010).
# Each callback mode runs in its own process with an external watchdog so a
# SIGILL crash or a deadlock is recorded rather than killing the whole run.
set -uo pipefail
cd "$(dirname "$0")"
export SDKROOT="${SDKROOT:-macosx}"

echo "######## BUILD ########"
clang -dynamiclib -fobjc-arc -O2 -framework Foundation -lffi \
  -o libspike.dylib dispatch.m callback_thread.m
echo "build rc=$?"
nm -gU libspike.dylib | grep aw_spike || true
echo

echo "######## DISPATCH BENCHMARK ########"
racket bench-dispatch.rkt 2>&1
echo "dispatch rc=$?"
echo

echo "######## CALLBACK THREAD MATRIX ########"
run_mode () {
  local m="$1"
  echo "---- mode: $m ----"
  racket callback-thread.rkt "$m" >".out.$m" 2>&1 &
  local pid=$!
  ( sleep 20; kill -9 "$pid" 2>/dev/null ) & local watcher=$!
  wait "$pid"; local rc=$?
  kill "$watcher" 2>/dev/null
  cat ".out.$m"
  if [ "$rc" -eq 0 ]; then
    echo "   verdict: OK (rc=0)"
  elif [ "$rc" -eq 137 ]; then
    echo "   verdict: KILLED by watchdog — DEADLOCK/HANG (rc=$rc)"
  elif [ "$rc" -ge 128 ]; then
    echo "   verdict: CRASHED signal=$((rc-128)) (rc=$rc)  [SIGILL=4 SIGABRT=6 SIGSEGV=11]"
  else
    echo "   verdict: nonzero rc=$rc"
  fi
  rm -f ".out.$m"
  echo
}

for m in cproc-main cproc-pthread cproc-gcd ffi2-main ffi2-pthread ffi2-gcd; do
  run_mode "$m"
done

echo "######## DONE ########"
