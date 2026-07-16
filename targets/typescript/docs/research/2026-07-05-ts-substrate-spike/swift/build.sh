#!/usr/bin/env bash
# build.sh — compile the throwaway spike Swift bridge dylib. (ts-substrate-spike-k3)
set -euo pipefail
cd "$(dirname "$0")"

OUT="$(pwd)/libtsbridge.dylib"

# Absolute install_name: the .node addon links against this path and resolves it
# at runtime with no rpath dance (fine for a throwaway spike).
swiftc -emit-library Bridge.swift \
  -o "$OUT" \
  -framework Foundation -framework AppKit -framework CoreGraphics \
  -Xlinker -install_name -Xlinker "$OUT"

echo "built $OUT"
otool -L "$OUT" | head -6 || true
echo "--- exported aw_ts_* symbols ---"
nm -gU "$OUT" | grep aw_ts || true
