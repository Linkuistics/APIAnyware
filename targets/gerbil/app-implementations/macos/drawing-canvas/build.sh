#!/usr/bin/env bash
# Build the drawing-canvas gerbil sample app into a .app bundle for the
# AppSpec suite (gerbil-instrument-build-k136; mirrors the note-editor
# build.sh, the k127 recipe).
#
# The gerbil impl is a self-contained `gxc -exe` standalone .app (ADR-0009):
# libgambit.a links statically, so the Gerbil/Gambit runtime is embedded and the
# app launches on a machine with no Gerbil installed; the only Homebrew runtime
# dep (the Gerbil stdlib's openssl@3) is vendored + relocated into
# Contents/Frameworks by bundle-gerbil. The bottle gerbil toolchain
# (/opt/homebrew/Cellar/gerbil-scheme/<ver>) is a build-time dependency only —
# not symlinked onto PATH; the bundler globs the Cellar directly
# (compile.rs discover_gerbil_bin_dir). The bottle's Gambit config hardcodes
# C_COMPILER="gcc-15" — keep a gcc-15 on PATH (brew gcc@15, or the
# /tmp/aw-gcc15-shim symlink) or gambuild-C fails with "command not found".
#
# Two shared prerequisites are gitignored / absent in a clean checkout and
# regenerated here if missing:
#   - the generated gerbil bindings (apianyware-generate --target gerbil — the
#     sharded generics/NNN.ss + the class modules, ADR-0023). The prereq keys
#     on the CoreGraphics module (coregraphics/functions.ss), not generics.ss:
#     the canvas strokes render via direct CG C calls, and a binding tree
#     generated before the k134 CoreGraphics collection has generics but no
#     coregraphics modules (the k99/k135 rule, mirrored here);
#   - libAPIAnywareGerbil.dylib (swift build --product of the gerbil adapter,
#     ADR-0029 — --product relinks the dylib; --target does not). Gerbil *links*
#     the trampoline dylib at `gxc -exe` (chez dlopens), so the link fails
#     loudly with undefined aw_gerbil_swift_* without it. The check is
#     EXISTENCE only — and the "git-clean → dylib current" shortcut does NOT
#     hold after a regenerate: CoreGraphics GROWS the trampoline residual
#     (175 -> 221 by `grep -c @_cdecl`, the k134/k136 finding), so after any
#     regenerate verify currency (`nm -gU <dylib> | grep -c
#     aw_gerbil_swift_m_CoreGraphics`) and relink BEFORE bundling (the k107
#     order: generate -> relink -> bundle).
#
# Bundle id: bundle-gerbil derives the id from the spec's first H1 ->
# "Drawing Canvas.app" / com.linkuistics.DrawingCanvas. The suite installs
# FOUR impls in one VM, so each needs a DISTINCT id + .app name (descriptor:
# com.linkuistics.drawing-canvas-gerbil at
# /Applications/DrawingCanvas-gerbil.app). The bundler has no per-impl-id flag,
# so we post-process the default output: rename the .app, set
# CFBundleIdentifier, and re-sign (codesign seals Info.plist, so the post-mv
# edit invalidates the bundler's signature). A native --bundle-id flag on the
# bundlers remains the proper long-term home — an APIAnyware tooling concern.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"   # .../app-implementations/macos/drawing-canvas
WS="$(cd "$HERE/../../../../.." && pwd)"               # workspace root
BINDINGS="$WS/targets/gerbil/bindings/macos/generated"
BUILD="$HERE/build"
BUNDLE_ID="com.linkuistics.drawing-canvas-gerbil"      # == descriptor #:bundle-id
APP_NAME="DrawingCanvas-gerbil"                        # -> $BUILD/$APP_NAME.app; installs at /Applications/$APP_NAME.app (#:binary)

cd "$WS"

# --- prerequisites: generated bindings (incl. CoreGraphics) + adapter dylib ---
if [ ! -f "$BINDINGS/coregraphics/functions.ss" ]; then
  echo "== [prereq] generate gerbil bindings + trampolines (CoreGraphics absent) =="
  cargo run -q -p apianyware-generate -- --target gerbil
fi
if ! compgen -G "$WS/targets/gerbil/adapters/macos/.build/*/libAPIAnywareGerbil.dylib" > /dev/null \
   && ! compgen -G "$WS/targets/gerbil/adapters/macos/.build/*/*/libAPIAnywareGerbil.dylib" > /dev/null; then
  echo "== [prereq] swift build adapter dylib (--product relinks the dylib; --target does not) =="
  ( cd "$WS/targets/gerbil/adapters/macos" && swift build --product APIAnywareGerbil )
fi

# --- bundle (default id), then rename + set the per-impl bundle id ---
echo "== bundle (clang companion + sharded-generics gxc -O + gxc -exe -O — slow on a cold cache) =="
cargo run -q --example bundle_app -p apianyware-bundle-gerbil -- drawing-canvas
SRC="$BUILD/Drawing Canvas.app"
DST="$BUILD/$APP_NAME.app"
rm -rf "$DST"
mv "$SRC" "$DST"
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $BUNDLE_ID" "$DST/Contents/Info.plist"
# Re-sign after the plist edit (bundle level, matching bundle-gerbil's ad-hoc
# sign): re-seals CodeResources with the new Info.plist hash. The nested vendored
# dylibs keep their own valid signatures.
codesign --force --sign - "$DST" >/dev/null 2>&1 || true

echo "== built: $DST =="
echo "   CFBundleIdentifier = $(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$DST/Contents/Info.plist")"
codesign --verify --strict "$DST" && echo "   codesign --verify --strict: OK"
