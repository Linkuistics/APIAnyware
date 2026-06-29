#!/usr/bin/env bash
# Build the hello-window chez sample app into a .app bundle for the AppSpec
# acceptance test (acceptance-test-k21 / impl-conformance-k23, chez child k29).
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
# spec's first H1 -> "Hello Window.app" / com.linkuistics.HelloWindow. The
# acceptance test installs FOUR impls in one VM, so each needs a DISTINCT bundle
# id + .app name (k27 descriptors: com.linkuistics.hello-window-<impl> at
# /Applications/HelloWindow-<impl>.app). The bundler has no per-impl-id flag, so
# we post-process the default output to the descriptor's id + name. (A native
# --bundle-id flag on the bundler is the proper long-term home — an APIAnyware
# tooling concern, not app data; same finding as the racket child k28.)
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"   # .../app-implementations/macos/hello-window
WS="$(cd "$HERE/../../../../.." && pwd)"               # workspace root
BINDINGS="$WS/targets/chez/bindings/macos"
BUILD="$HERE/build"
BUNDLE_ID="com.linkuistics.hello-window-chez"          # == k27 descriptor #:bundle-id
APP_NAME="HelloWindow-chez"                            # -> $BUILD/$APP_NAME.app; installs at /Applications/$APP_NAME.app (#:binary)

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
cargo run -q --example bundle_app -p apianyware-bundle-chez -- hello-window
SRC="$BUILD/Hello Window.app"
DST="$BUILD/$APP_NAME.app"
rm -rf "$DST"
mv "$SRC" "$DST"
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $BUNDLE_ID" "$DST/Contents/Info.plist"
# Re-sign after the plist edit: codesign seals Info.plist, so the post-mv edit
# invalidates the signature the bundler applied. Match bundle-chez's ad-hoc sign.
codesign --force --sign - "$DST" >/dev/null 2>&1 || true

echo "== built: $DST =="
echo "   CFBundleIdentifier = $(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$DST/Contents/Info.plist")"
