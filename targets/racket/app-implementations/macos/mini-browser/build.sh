#!/usr/bin/env bash
# Build the mini-browser racket sample app into a SELF-CONTAINED .app
# bundle for the AppSpec suite (racket-instrument-build-k116; mirrors the
# scenekit-viewer build.sh, self-contained per racket-self-contained-bundle-k76).
#
# The bundle step is the production bundler (apianyware-bundle-racket's
# self-contained mode): it stages the colocated source tree, runs
# `raco exe` (embeds the full module graph — generated bindings, runtime, and
# the ffi2 collection from the build host's ffi2-lib package) and
# `raco distribute` (machine-portable dist carrying libAPIAnywareRacket.dylib
# via the runtime's define-runtime-path references), then compiles the Swift
# stub launcher (CFBundleExecutable) that execv's the distributed executable at
# Contents/Resources/racket-dist/bin/. Net: the .app travels alone — the VM
# needs NOTHING staged.
#
# Bundle id: the bundler derives the id from the spec's first H1 -> "Mini
# Browser.app" / com.linkuistics.MiniBrowser. The suite installs FOUR impls in
# one VM, so each needs a DISTINCT bundle id + .app name (descriptor:
# com.linkuistics.mini-browser-racket at /Applications/MiniBrowser-racket.app),
# hence the post-mv PlistBuddy + re-sign dance below — same as hello-window /
# ui-controls-gallery / pdfkit-viewer / scenekit-viewer (a native --bundle-id
# flag on the bundlers remains the proper long-term home).
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"   # .../app-implementations/macos/mini-browser
WS="$(cd "$HERE/../../../../.." && pwd)"               # workspace root
BINDINGS="$WS/targets/racket/bindings/macos"
BUILD="$HERE/build"
BUNDLE_ID="com.linkuistics.mini-browser-racket"        # == descriptor #:bundle-id
APP_NAME="MiniBrowser-racket"                          # -> $BUILD/$APP_NAME.app; installs at /Applications/$APP_NAME.app (#:binary)

cd "$WS"

# --- prerequisites: shared racket binding (regenerate if absent) ---
# Keyed on this app's framework artifact (the k99 finding): a binding tree
# generated before the WebKit collection has appkit/ but no webkit/.
if [ ! -f "$BINDINGS/generated/webkit/wkwebview.rkt" ]; then
  echo "== [prereq] generate racket bindings =="
  cargo run -q -p apianyware-generate -- --target racket
fi
if [ ! -f "$BINDINGS/lib/libAPIAnywareRacket.dylib" ]; then   # -f follows the symlink; false if dangling
  echo "== [prereq] swift build adapter dylib =="
  ( cd "$WS/targets/racket/adapters/macos" && swift build )
fi

# --- bundle (default id), then rename + set the per-impl bundle id ---
echo "== [1/2] bundle (raco exe + raco distribute + stub + sign) =="
cargo run -q --example bundle_app -p apianyware-bundle-racket -- mini-browser
SRC="$BUILD/Mini Browser.app"
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

# --- self-containment report (the VM run is the real verify) ---
echo "== [2/2] self-containment report =="
DIST_EXE="$DST/Contents/Resources/racket-dist/bin/mini-browser"
test -x "$DIST_EXE" || { echo "ERROR: distributed exe missing"; exit 1; }
if otool -L "$DST/Contents/MacOS/mini-browser" "$DIST_EXE" | grep -q /opt/homebrew; then
  echo "ERROR: a bundle executable links /opt/homebrew"; exit 1
fi
find "$DST/Contents/Resources/racket-dist/lib" -name 'libAPIAnywareRacket.dylib' | grep -q . \
  || { echo "ERROR: libAPIAnywareRacket.dylib not carried into the dist"; exit 1; }

echo "== built: $DST =="
echo "   CFBundleIdentifier = $(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$DST/Contents/Info.plist")"
du -sh "$DST" | sed 's/^/   /'
