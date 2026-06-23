#!/usr/bin/env bash
# Build + run the gerbil Swift-native METHOD-trampoline CLI smoke (ADR-0030, leaf
# 050-gerbil/010-build). Proves the two 030 known-good exemplars resolve through
# libAPIAnywareGerbil's receiver-handle `@_cdecl` trampolines and run from a gerbil
# exe via define-c-lambda:
#   - pop-B Foundation.IndexSet: init(integer:) → contains(_:) → insert(_:) D3 write-back
#   - pop-A Foundation.URLSession.data(from: file://…) async → real (Data, URLResponse)
# (The permanent run-smokes.sh chaining + VM-verify is the sibling leaf 020.)
#
# Prerequisites (run from the repo root):
#   SDKROOT=macosx ./target/debug/apianyware-macos-generate --target gerbil \
#       --input-dir collection/ir/collected
#   (cd swift && SDKROOT=macosx swift build --product APIAnywareGerbil)
set -euo pipefail

GERBIL_BREW="$(brew --prefix gerbil-scheme)"
export PATH="$GERBIL_BREW/bin:$PATH"
unset GERBIL_HOME || true
export SDKROOT="$(xcrun --sdk macosx --show-sdk-path)"

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"      # .../lib/runtime/tests
LIB="$(cd "$HERE/../.." && pwd)"                           # .../lib  (package root)
RT="$LIB/runtime"
REPO="$(cd "$LIB/../../../.." && pwd)"                     # repo root
FW="$LIB/foundation"

# Locate the swift build artifact — prefer release over debug.
DYLIB_DIR=""
for triple_dir in "$REPO"/swift/.build/*/; do
  for profile in release debug; do
    if [ -f "$triple_dir$profile/libAPIAnywareGerbil.dylib" ]; then
      DYLIB_DIR="$triple_dir$profile"; break 2
    fi
  done
done
if [ -z "$DYLIB_DIR" ]; then
  echo "!! libAPIAnywareGerbil.dylib not found under $REPO/swift/.build/*/{release,debug}" >&2
  echo "   build it: (cd swift && SDKROOT=macosx swift build --product APIAnywareGerbil)" >&2
  exit 2
fi
if [ ! -f "$FW/indexset.ss" ] || [ ! -f "$FW/nsurlsession.ss" ]; then
  echo "!! generated foundation bindings not found; run generate --target gerbil first" >&2
  exit 2
fi

export GERBIL_LOADPATH="$LIB"
export GERBIL_PATH="${GERBIL_PATH:-$(mktemp -d)/gerbil}"
OUT="$(mktemp -d)"

echo "== compiling clang companion (native_block.c, -fblocks) =="
BLK_O="$OUT/native_block.o"
clang -fblocks -isysroot "$SDKROOT" -c "$RT/native_block.c" -o "$BLK_O"

SWIFT_LD="-L$DYLIB_DIR -lAPIAnywareGerbil -Wl,-rpath,$DYLIB_DIR"

# Precompile the import closure (gxc -exe does NOT recurse): runtime, the shared
# generics module, then the foundation modules the smoke imports — deps first.
echo "== precompiling runtime modules =="
gxc -O -ld-options "-lobjc $BLK_O" \
    "$RT/ffi.ss" "$RT/native-core.ss" "$RT/objc.ss" \
    "$RT/swift-trampoline.ss" "$RT/async-bridge.ss"
echo "== precompiling generics shards + facade (ADR-0023 sharded generics) =="
# gxc -exe does not recurse, so the whole sharded generics closure must be
# precompiled: every `generics/NNN.ss` shard, then the `generics.ss` facade.
gxc -O "$LIB"/generics/*.ss
gxc -O "$LIB/generics.ss"
echo "== precompiling foundation trampoline modules =="
# The foundation modules name both `objc_msgSend`/`objc_getClass`/`sel_registerName`
# (the msgSend crossings → -lobjc) and the dylib's `aw_gerbil_swift_*` entries.
# (After k38 the Swift-overlay `urlsession.ss` merged into `nsurlsession.ss`, which now
# also carries `nsurlsession-data-from` — the async `data(from:)` method.)
gxc -O -ld-options "-lobjc $SWIFT_LD" \
    "$FW/indexset.ss" "$FW/nsurl.ss" "$FW/nsurlsession.ss"
# The CoreFoundation run-loop pump for the async exemplar.
gxc -O -ld-options "-framework CoreFoundation" "$HERE/cf-runloop.ss"

echo "== linking + running smoke =="
LD="-lobjc -framework AppKit -framework Foundation -framework CoreFoundation $BLK_O \
    -L$DYLIB_DIR -lAPIAnywareGerbil -Wl,-rpath,$DYLIB_DIR"
gxc -exe -o "$OUT/smoke-swift-method" -ld-options "$LD" "$HERE/smoke-swift-method.ss"

"$OUT/smoke-swift-method" | sed 's/^/   /'
if "$OUT/smoke-swift-method" | grep -q 'SWIFT-METHOD-OK'; then
  echo "SWIFT-METHOD SMOKE OK"
else
  echo "!! smoke did not report OK"; exit 1
fi
