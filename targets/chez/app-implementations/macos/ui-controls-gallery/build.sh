#!/usr/bin/env bash
# Build the ui-controls-gallery chez sample app into a .app bundle for the
# AppSpec suite (chez-instrument-build-k90; mirrors the hello-window build.sh,
# the k69 recipe).
#
# The chez impl is a self-contained open-world standalone .app (ADR-0009): the
# Chez kernel + a whole-program boot are baked into the binary, so it launches
# on a machine with no Chez installed. Host Chez is a build-time dependency
# only. Two shared prerequisites are gitignored / absent in a clean checkout and
# regenerated here if missing:
#   - the generated chez bindings (apianyware-generate --target chez), which also
#     emit the chez Swift-native trampolines; and
#   - libAPIAnywareChez.dylib (swift build of the chez adapter), mandatory under
#     bindings/macos/lib/ (bundle-chez fails fast without it).
#
# Bundle id: the cargo bundler (apianyware-bundle-chez) derives the id from the
# spec's first H1 -> "UI Controls Gallery.app" / com.linkuistics.UIControlsGallery.
# The suite installs FOUR impls in one VM, so each needs a DISTINCT bundle id +
# .app name (descriptor: com.linkuistics.ui-controls-gallery-chez at
# /Applications/UIControlsGallery-chez.app). The bundler has no per-impl-id flag,
# so we post-process the default output to the descriptor's id + name. (A native
# --bundle-id flag on the bundlers remains the proper long-term home — an
# APIAnyware tooling concern, not app data.)
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"   # .../app-implementations/macos/ui-controls-gallery
WS="$(cd "$HERE/../../../../.." && pwd)"               # workspace root
BINDINGS="$WS/targets/chez/bindings/macos"
BUILD="$HERE/build"
BUNDLE_ID="com.linkuistics.ui-controls-gallery-chez"   # == descriptor #:bundle-id
APP_NAME="UIControlsGallery-chez"                      # -> $BUILD/$APP_NAME.app; installs at /Applications/$APP_NAME.app (#:binary)

cd "$WS"

# --- prerequisites: generated bindings + adapter dylib (regenerate if absent) ---
if [ ! -f "$BINDINGS/apianyware/appkit.sls" ]; then
  echo "== [prereq] generate chez bindings + trampolines =="
  cargo run -q -p apianyware-generate -- --target chez
fi
if [ ! -f "$BINDINGS/lib/libAPIAnywareChez.dylib" ]; then   # -f follows the symlink; false if dangling
  echo "== [prereq] swift build adapter dylib =="
  ( cd "$WS/targets/chez/adapters/macos" && swift build )
fi

# --- bundle (default id), then rename + set the per-impl bundle id ---
echo "== bundle (whole-program compile — slow, ~minutes) =="
cargo run -q --example bundle_app -p apianyware-bundle-chez -- ui-controls-gallery
SRC="$BUILD/UI Controls Gallery.app"
DST="$BUILD/$APP_NAME.app"
rm -rf "$DST"
mv "$SRC" "$DST"
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $BUNDLE_ID" "$DST/Contents/Info.plist"
# Re-sign after the plist edit: codesign seals Info.plist, so the post-mv edit
# invalidates the bundler's signature. Match the bundler's identity choice (the
# persistent local identity when the keychain has it, else ad-hoc).
IDENTITY="APIAnyware Local Signing"
if ! security find-identity -p codesigning -v 2>/dev/null | grep -q "$IDENTITY"; then
  IDENTITY="-"
fi
codesign --force --sign "$IDENTITY" "$DST"

echo "== built: $DST =="
echo "   CFBundleIdentifier = $(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$DST/Contents/Info.plist")"
du -sh "$DST" | sed 's/^/   /'
