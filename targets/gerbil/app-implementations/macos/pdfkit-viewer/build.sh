#!/usr/bin/env bash
# Build the pdfkit-viewer gerbil sample app into a .app bundle for the
# AppSpec suite (gerbil-instrument-build-k100; mirrors the ui-controls-gallery
# build.sh, the k91 recipe).
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
#     on the PDFKit shard (pdfkit/pdfview.ss), not generics.ss: a binding tree
#     generated before the k98 PDFKit collection has generics but no pdfkit
#     modules (the k99 chez finding, mirrored here);
#   - libAPIAnywareGerbil.dylib (swift build --product of the gerbil adapter,
#     ADR-0029 — --product relinks the dylib; --target does not). This app's
#     closure pulls Swift-native trampoline references, and gerbil *links* the
#     trampoline dylib at `gxc -exe` (chez dlopens), so the link fails loudly
#     with undefined aw_gerbil_swift_* without it (bundle-gerbil
#     discover_swift_dylib omits the -lAPIAnywareGerbil args when no artifact
#     exists).
#
# Bundle id: bundle-gerbil derives the id from the spec's first H1 ->
# "PDFKit Viewer.app" / com.linkuistics.PDFKitViewer. The suite installs FOUR
# impls in one VM, so each needs a DISTINCT id + .app name (descriptor:
# com.linkuistics.pdfkit-viewer-gerbil at /Applications/PDFKitViewer-gerbil.app).
# The bundler has no per-impl-id flag, so we post-process the default output:
# rename the .app, set CFBundleIdentifier, and re-sign (codesign seals
# Info.plist, so the post-mv edit invalidates the bundler's signature). A native
# --bundle-id flag on the bundlers remains the proper long-term home — an
# APIAnyware tooling concern.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"   # .../app-implementations/macos/pdfkit-viewer
WS="$(cd "$HERE/../../../../.." && pwd)"               # workspace root
BINDINGS="$WS/targets/gerbil/bindings/macos/generated"
BUILD="$HERE/build"
BUNDLE_ID="com.linkuistics.pdfkit-viewer-gerbil"       # == descriptor #:bundle-id
APP_NAME="PDFKitViewer-gerbil"                         # -> $BUILD/$APP_NAME.app; installs at /Applications/$APP_NAME.app (#:binary)

cd "$WS"

# --- prerequisites: generated bindings (incl. PDFKit) + adapter dylib ---
if [ ! -f "$BINDINGS/pdfkit/pdfview.ss" ]; then
  echo "== [prereq] generate gerbil bindings + trampolines (PDFKit absent) =="
  cargo run -q -p apianyware-generate -- --target gerbil
fi
if ! compgen -G "$WS/targets/gerbil/adapters/macos/.build/*/libAPIAnywareGerbil.dylib" > /dev/null \
   && ! compgen -G "$WS/targets/gerbil/adapters/macos/.build/*/*/libAPIAnywareGerbil.dylib" > /dev/null; then
  echo "== [prereq] swift build adapter dylib (--product relinks the dylib; --target does not) =="
  ( cd "$WS/targets/gerbil/adapters/macos" && swift build --product APIAnywareGerbil )
fi

# --- bundle (default id), then rename + set the per-impl bundle id ---
echo "== bundle (clang companion + sharded-generics gxc -O + gxc -exe -O — slow on a cold cache) =="
cargo run -q --example bundle_app -p apianyware-bundle-gerbil -- pdfkit-viewer
SRC="$BUILD/PDFKit Viewer.app"
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
