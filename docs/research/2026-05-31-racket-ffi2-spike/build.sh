#!/usr/bin/env bash
# build.sh — compile the spike native dylib. THROWAWAY (leaf 040/010).
set -euo pipefail
cd "$(dirname "$0")"

export SDKROOT="${SDKROOT:-macosx}"   # host xcrun default-SDK workaround (auto-memory)

OUT="libspike.dylib"

clang -dynamiclib -fobjc-arc -O2 \
  -framework Foundation \
  -o "$OUT" \
  dispatch.m callback_thread.m

echo "built $(pwd)/$OUT"
otool -L "$OUT" | head -5 || true
nm -gU "$OUT" | grep aw_spike || true
