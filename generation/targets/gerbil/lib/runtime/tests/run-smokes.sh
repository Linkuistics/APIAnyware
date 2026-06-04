#!/usr/bin/env bash
# Build + run the gerbil runtime smoke programs (CLI smoke; VM-verify is node
# 070/090). Discovered/validated at leaf 050/010. Run from the repo root or
# anywhere — paths are resolved relative to this script.
set -euo pipefail

GERBIL_BREW=/opt/homebrew/Cellar/gerbil-scheme/0.18.2
export PATH="$GERBIL_BREW/bin:$PATH"
unset GERBIL_HOME || true
export SDKROOT="$(xcrun --sdk macosx --show-sdk-path)"

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"     # .../lib/runtime/tests
LIB="$(cd "$HERE/../.." && pwd)"                          # .../lib  (package root)
export GERBIL_LOADPATH="$LIB"
export GERBIL_PATH="${GERBIL_PATH:-$(mktemp -d)/gerbil}"
OUT="$(mktemp -d)"

LD="-lobjc -framework Foundation"

echo "== compiling runtime modules (static cache) =="
gxc -O -ld-options "-lobjc" "$LIB/runtime/ffi.ss" "$LIB/runtime/objc.ss"

rc=0
for smoke in smoke-data-plane smoke-dual-surface; do
  echo "== $smoke =="
  gxc -exe -o "$OUT/$smoke" -ld-options "$LD" "$HERE/$smoke.ss"
  if "$OUT/$smoke" | sed 's/^/   /'; then :; fi
  if ! "$OUT/$smoke" | grep -qE 'SMOKE-OK|DUAL-OK'; then
    echo "   !! $smoke did not report OK"; rc=1
  fi
done

[ $rc -eq 0 ] && echo "ALL SMOKES OK" || echo "SMOKE FAILURES"
exit $rc
