#!/usr/bin/env bash
# run.sh — build + run the async-method in-process smoke (030-racket/020).
#
# Compiles the racket runtime sources + async-method-smoke.swift into a
# libAPIAnywareRacket.dylib at the canonical path the runtime modules load
# (targets/racket/bindings/macos/lib/), runs the racket driver, then restores the
# original symlink (the smoke build is non-destructive — a trap puts it back).
set -euo pipefail
cd "$(dirname "$0")"
ROOT="$(cd ../../../../../.. && pwd)"
LIB="$ROOT/targets/racket/bindings/macos/lib/libAPIAnywareRacket.dylib"

# Remember the original (a symlink into the racket adapter package's .build) and
# restore it on exit.
ORIG_TARGET="$(readlink "$LIB" 2>/dev/null || true)"
restore() {
  rm -f "$LIB"
  if [ -n "$ORIG_TARGET" ]; then ln -s "$ORIG_TARGET" "$LIB"; fi
}
trap restore EXIT

export SDKROOT=macosx
SDK="$(xcrun --show-sdk-path)"

echo "building libAPIAnywareRacket.dylib (runtime + smoke trampolines)…"
rm -f "$LIB"
swiftc -emit-library -swift-version 6 \
  -sdk "$SDK" -target arm64-apple-macos14 \
  -o "$LIB" \
  "$ROOT"/targets/racket/adapters/macos/sources/*.swift \
  async-method-smoke.swift

echo "running racket async-method smoke…"
racket async-method-smoke.rkt
