#!/usr/bin/env bash
# Build + run the gerbil runtime smoke programs (CLI smoke; VM-verify is node
# 070/090). Discovered/validated at leaf 050/010, extended at 050/020 (native
# bridges). Run from the repo root or anywhere — paths are resolved relative to
# this script.
set -euo pipefail

GERBIL_BREW=/opt/homebrew/Cellar/gerbil-scheme/0.18.2
export PATH="$GERBIL_BREW/bin:$PATH"
unset GERBIL_HOME || true
export SDKROOT="$(xcrun --sdk macosx --show-sdk-path)"

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"     # .../lib/runtime/tests
LIB="$(cd "$HERE/../.." && pwd)"                          # .../lib  (package root)
RT="$LIB/runtime"
export GERBIL_LOADPATH="$LIB"
export GERBIL_PATH="${GERBIL_PATH:-$(mktemp -d)/gerbil}"
OUT="$(mktemp -d)"

# The native core's ObjC block literals (make-objc-block) cannot be parsed by the
# bottle's default gcc-15 — compile that ONE companion translation unit with
# clang -fblocks and link its .o into every smoke (each transitively imports the
# objc runtime → native-core, which calls the companion's aw_make_block_* symbols).
# See runtime/native_block.c + runtime/README.md "native bridges".
echo "== compiling clang companion (native_block.c, -fblocks) =="
BLK_O="$OUT/native_block.o"
clang -fblocks -isysroot "$SDKROOT" -c "$RT/native_block.c" -o "$BLK_O"

# The background-callback smoke (smoke-dispatch, ADR-0022) has its own clang
# harness (dispatch/CFRunLoop/^blocks) linked into that smoke only.
echo "== compiling smoke-dispatch harness (smoke_dispatch.c, -fblocks) =="
DISP_O="$OUT/smoke_dispatch.o"
clang -fblocks -isysroot "$SDKROOT" -c "$HERE/smoke_dispatch.c" -o "$DISP_O"

# AppKit (transitively Foundation) — smoke-subclass synthesizes an NSView subclass
# and drives it through NSWindow/NSApplication; the others only need Foundation,
# but linking AppKit everywhere is harmless.
LD="-lobjc -framework AppKit -framework Foundation $BLK_O"

echo "== compiling runtime modules (static cache) =="
# Order matters: subclass.ss imports objc.ss imports native-core.ss imports ffi.ss.
# native-core's loadable object references the companion's block-maker symbols, so
# the .o must be on its link line here too.
gxc -O -ld-options "-lobjc $BLK_O" \
    "$RT/ffi.ss" "$RT/native-core.ss" "$RT/objc.ss" "$RT/subclass.ss"

rc=0
for smoke in smoke-data-plane smoke-dual-surface smoke-native-bridges smoke-subclass smoke-geometry smoke-dispatch; do
  echo "== $smoke =="
  # smoke-dispatch links its own clang harness (the background-callback driver).
  ld="$LD"; [ "$smoke" = "smoke-dispatch" ] && ld="$LD $DISP_O"
  gxc -exe -o "$OUT/$smoke" -ld-options "$ld" "$HERE/$smoke.ss"
  if "$OUT/$smoke" | sed 's/^/   /'; then :; fi
  if ! "$OUT/$smoke" | grep -qE 'SMOKE-OK|DUAL-OK|BRIDGES-OK|SUBCLASS-OK|GEOMETRY-OK|DISPATCH-OK'; then
    echo "   !! $smoke did not report OK"; rc=1
  fi
done

# Swift-native trampoline smoke (ADR-0029) — the permanent regression guard for
# the complete-API trampoline path. It has its OWN runner because it links the
# extra `-lAPIAnywareGerbil` line (the dylib the trampolines live in) that the
# pure-ObjC smokes above never need. Chained here so "verifying the runtime"
# always exercises the trampoline require-shape (the `define-c-lambda` bindings
# resolving) + the constant-trampoline round-trip at module init. Requires the
# generated createml bindings + the built dylib; if either is absent we SKIP with
# a build instruction rather than fail (a fresh checkout has neither until the
# pipeline + swift build have run).
echo "== smoke-swift-trampoline (ADR-0029 Swift-native guard) =="
TRAMPOLINE_DYLIB=""
for triple_dir in "$LIB"/../../../../swift/.build/*/; do
  for profile in release debug; do
    [ -f "$triple_dir$profile/libAPIAnywareGerbil.dylib" ] && TRAMPOLINE_DYLIB="found" && break 2
  done
done
if [ -z "$TRAMPOLINE_DYLIB" ] || [ ! -f "$LIB/createml/functions.ss" ]; then
  echo "   SKIP — needs generate --target gerbil + swift build -c release --product APIAnywareGerbil"
elif "$HERE/run-swift-trampoline-smoke.sh" | sed 's/^/   /'; then
  echo "   smoke-swift-trampoline OK"
else
  echo "   !! smoke-swift-trampoline FAILED"; rc=1
fi

[ $rc -eq 0 ] && echo "ALL SMOKES OK" || echo "SMOKE FAILURES"
exit $rc
