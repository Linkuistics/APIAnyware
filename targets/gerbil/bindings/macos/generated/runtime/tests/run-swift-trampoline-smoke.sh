#!/usr/bin/env bash
# Build + run the gerbil Swift-native trampoline CLI smoke (ADR-0029, leaf
# 070/020). Proves the §6a exemplars (CreateML.timestampSeed / MLCreateErrorDomain)
# resolve through libAPIAnywareGerbil's @_cdecl trampolines and run from a gerbil
# exe via define-c-lambda. (The VM-verify is node 070/030.)
#
# Prerequisites (run from the repo root):
#   SDKROOT=macosx cargo run --release -q -p apianyware-generate -- --target gerbil
#   (cd targets/gerbil/adapters/macos && SDKROOT=macosx swift build --product APIAnywareGerbil)
set -euo pipefail

GERBIL_BREW=/opt/homebrew/Cellar/gerbil-scheme/0.18.2
export PATH="$GERBIL_BREW/bin:$PATH"
unset GERBIL_HOME || true
export SDKROOT="$(xcrun --sdk macosx --show-sdk-path)"

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"      # .../generated/runtime/tests
LIB="$(cd "$HERE/../.." && pwd)"                           # .../generated  (gerbil-bindings package root)
RT="$LIB/runtime"
# The Swift dylib now builds into the per-target adapter package's .build (gerbil
# left the umbrella swift/.build in move-gerbil-material-k13).
ADAPTER="$(cd "$LIB/../../../adapters/macos" && pwd)"     # targets/gerbil/adapters/macos
# Locate the swift build artifact — prefer release over debug (the bundler ships
# release; ADR-0029). Scan per-triple build dirs so the host triple resolves.
DYLIB_DIR=""
for triple_dir in "$ADAPTER"/.build/*/; do
  for profile in release debug; do
    if [ -f "$triple_dir$profile/libAPIAnywareGerbil.dylib" ]; then
      DYLIB_DIR="$triple_dir$profile"; break 2
    fi
  done
done

if [ -z "$DYLIB_DIR" ]; then
  echo "!! libAPIAnywareGerbil.dylib not found under $ADAPTER/.build/*/{release,debug}" >&2
  echo "   build it: (cd targets/gerbil/adapters/macos && SDKROOT=macosx swift build -c release --product APIAnywareGerbil)" >&2
  exit 2
fi
if [ ! -f "$LIB/createml/functions.ss" ]; then
  echo "!! generated createml bindings not found; run generate --target gerbil first" >&2
  exit 2
fi

export GERBIL_LOADPATH="$LIB"
export GERBIL_PATH="${GERBIL_PATH:-$(mktemp -d)/gerbil}"
OUT="$(mktemp -d)"

# The native core's ObjC block literals need the clang -fblocks companion (same as
# run-smokes.sh); native-core links its aw_make_block_* symbols.
echo "== compiling clang companion (native_block.c, -fblocks) =="
BLK_O="$OUT/native_block.o"
clang -fblocks -isysroot "$SDKROOT" -c "$RT/native_block.c" -o "$BLK_O"

# Precompile the import closure (gxc -exe does NOT recurse — gerbil reference §):
# runtime modules, then the createml trampoline bindings the smoke imports.
echo "== precompiling runtime + createml trampoline modules =="
SWIFT_LD="-L$DYLIB_DIR -lAPIAnywareGerbil -Wl,-rpath,$DYLIB_DIR"
gxc -O -ld-options "-lobjc $BLK_O" \
    "$RT/ffi.ss" "$RT/native-core.ss" "$RT/objc.ss" "$RT/swift-trampoline.ss"
# The createml trampoline modules name `aw_gerbil_swift_*` symbols; gxc -O links a
# loadable object, so the dylib must be on its link line here too.
gxc -O -ld-options "$SWIFT_LD" "$LIB/createml/functions.ss" "$LIB/createml/constants.ss"

# Link the smoke against libAPIAnywareGerbil (recorded by its @rpath install name,
# so -rpath the build dir) + the frameworks the native core needs. CreateML is
# pulled in transitively by the dylib; naming it explicitly is harmless.
echo "== linking + running smoke =="
LD="-lobjc -framework AppKit -framework Foundation $BLK_O \
    -L$DYLIB_DIR -lAPIAnywareGerbil -Wl,-rpath,$DYLIB_DIR"
gxc -exe -o "$OUT/smoke-swift-trampoline" -ld-options "$LD" "$HERE/smoke-swift-trampoline.ss"

"$OUT/smoke-swift-trampoline" | sed 's/^/   /'
if "$OUT/smoke-swift-trampoline" | grep -q 'SWIFT-TRAMPOLINE-OK'; then
  echo "SWIFT-TRAMPOLINE SMOKE OK"
else
  echo "!! smoke did not report OK"; exit 1
fi
