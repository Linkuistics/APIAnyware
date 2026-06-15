#!/usr/bin/env bash
# Build the foreign-thread probe and run each stage in its own process,
# capturing exit codes (134 = SIGABRT/SIGSEGV → crash). THROWAWAY spike.
# The serialized stages run once; the `concurrent` race stage runs N times
# (a data race is probabilistic — cf. the chez spike's 500x loop).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PATH="/opt/homebrew/Cellar/gerbil-scheme/0.18.2/bin:$PATH"
unset GERBIL_HOME || true
export SDKROOT="$(xcrun --sdk macosx --show-sdk-path)"
export GERBIL_PATH="$HERE/build/gerbil"
BUILD="$HERE/build"; mkdir -p "$BUILD"
N="${1:-30}"

echo "== clang probe.m (-fblocks for the GCD ^block) =="
clang -fblocks -isysroot "$SDKROOT" -c "$HERE/probe.m" -o "$BUILD/probe.o" || exit 2

echo "== gxc -exe link =="
gxc -exe -O -o "$BUILD/probe" \
  -ld-options "-framework Foundation $BUILD/probe.o" \
  "$HERE/callback.ss" || exit 3

echo
for stage in direct pthread gcd; do
  echo "########## stage: $stage ##########"
  "$BUILD/probe" "$stage"
  echo "(exit code: $?)"
  echo
done

echo "########## stage: concurrent (x$N — race) ##########"
crashes=0
for i in $(seq 1 "$N"); do
  out="$("$BUILD/probe" concurrent 2>&1)"; rc=$?
  if [ $rc -ne 0 ]; then
    crashes=$((crashes+1))
    echo "--- run $i: CRASH rc=$rc ---"
    echo "$out" | tail -4
  fi
done
echo "concurrent: $crashes/$N runs crashed (nonzero exit)"
echo
echo "=== one verbose concurrent run for the record ==="
"$BUILD/probe" concurrent; echo "(exit code: $?)"
