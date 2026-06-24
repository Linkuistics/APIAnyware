#!/usr/bin/env bash
# Build the hello-window gerbil sample app into a self-contained exe.
#
# Toolchain: the **bottle** (Homebrew) gerbil. `gxc -exe` links libgambit.a, so
# the exe embeds the Gerbil/Gambit runtime — `otool -L` shows only system libs +
# frameworks + (the Gerbil stdlib's) openssl@3. No `--enable-shared=no` static
# source toolchain is needed (FINDINGS §5 corrected at leaf 070/020; spec §7).
# The openssl@3 dylibs are vendored/relocated by bundle-gerbil (leaf 070/030).
#
# Build model: `gxc -exe` does NOT recursively compile imports, so the app's
# binding-library closure (runtime modules + shared generics.ss + each imported
# class module's parent chain) is pre-compiled once into a persistent GERBIL_PATH
# cache, then the exe is linked. This is the spec §3 "compile the binding library
# once, amortise across apps" model. The clang `-fblocks` native_block.o companion
# (runtime README "Building") joins every link line.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"          # app-implementations/macos/hello-window
ROOT="$(cd "$HERE/../../../../.." && pwd)"                    # repo root
LIB="$ROOT/targets/gerbil/bindings/macos/generated"          # gerbil-bindings package root

export PATH="/opt/homebrew/Cellar/gerbil-scheme/0.18.2/bin:$PATH"
unset GERBIL_HOME || true
export SDKROOT="$(xcrun --sdk macosx --show-sdk-path)"
export GERBIL_LOADPATH="$LIB"
export GERBIL_PATH="${GERBIL_PATH:-$HERE/build/gerbil-cache/gerbil}"

BUILD="$HERE/build"; mkdir -p "$BUILD"
BLK="$BUILD/native_block.o"

echo "== clang companion (native_block.c, -fblocks) =="
clang -fblocks -isysroot "$SDKROOT" -c "$LIB/runtime/native_block.c" -o "$BLK"

echo "== pre-compile binding-library closure (topological order) =="
gxc -O -ld-options "-lobjc $BLK" \
  "$LIB/generics.ss" \
  "$LIB/runtime/ffi.ss" "$LIB/runtime/native-core.ss" "$LIB/runtime/objc.ss" "$LIB/runtime/cocoa.ss" \
  "$LIB/appkit/nsresponder.ss" "$LIB/appkit/nsview.ss" "$LIB/appkit/nscontrol.ss" \
  "$LIB/appkit/nstextfield.ss" "$LIB/appkit/nsapplication.ss" "$LIB/appkit/nswindow.ss" \
  "$LIB/appkit/nsfont.ss" "$LIB/appkit/enums.ss"

echo "== link exe =="
gxc -exe -O -o "$BUILD/hello-window" \
  -ld-options "-lobjc -framework AppKit -framework Foundation $BLK" \
  "$HERE/hello-window.ss"

echo "== built: $BUILD/hello-window =="
otool -L "$BUILD/hello-window"
