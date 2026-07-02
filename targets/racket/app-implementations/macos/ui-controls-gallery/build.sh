#!/usr/bin/env bash
# Build the ui-controls-gallery racket sample app into a SELF-CONTAINED .app
# bundle for the AppSpec suite (racket-instrument-build-k89; mirrors the
# hello-window build.sh, self-contained per racket-self-contained-bundle-k76).
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
# Bundle id: the bundler derives the id from the spec's first H1 -> "UI
# Controls Gallery.app" / com.linkuistics.UIControlsGallery. The suite installs
# FOUR impls in one VM, so each needs a DISTINCT bundle id + .app name
# (descriptor: com.linkuistics.ui-controls-gallery-racket at
# /Applications/UIControlsGallery-racket.app), hence the post-mv PlistBuddy +
# re-sign dance below — same as hello-window (a native --bundle-id flag on the
# bundlers remains the proper long-term home).
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"   # .../app-implementations/macos/ui-controls-gallery
WS="$(cd "$HERE/../../../../.." && pwd)"               # workspace root
BINDINGS="$WS/targets/racket/bindings/macos"
BUILD="$HERE/build"
BUNDLE_ID="com.linkuistics.ui-controls-gallery-racket" # == descriptor #:bundle-id
APP_NAME="UIControlsGallery-racket"                    # -> $BUILD/$APP_NAME.app; installs at /Applications/$APP_NAME.app (#:binary)

cd "$WS"

# --- prerequisites: shared racket binding (regenerate if absent) ---
if [ ! -f "$BINDINGS/generated/appkit/nsapplication.rkt" ]; then
  echo "== [prereq] generate racket bindings =="
  cargo run -q -p apianyware-generate -- --target racket
fi
if [ ! -f "$BINDINGS/lib/libAPIAnywareRacket.dylib" ]; then   # -f follows the symlink; false if dangling
  echo "== [prereq] swift build adapter dylib =="
  ( cd "$WS/targets/racket/adapters/macos" && swift build )
fi

# --- bundle (default id), then rename + set the per-impl bundle id ---
echo "== [1/2] bundle (raco exe + raco distribute + stub + sign) =="
cargo run -q --example bundle_app -p apianyware-bundle-racket -- ui-controls-gallery
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

# --- self-containment report (the VM run is the real verify) ---
echo "== [2/2] self-containment report =="
DIST_EXE="$DST/Contents/Resources/racket-dist/bin/ui-controls-gallery"
test -x "$DIST_EXE" || { echo "ERROR: distributed exe missing"; exit 1; }
if otool -L "$DST/Contents/MacOS/ui-controls-gallery" "$DIST_EXE" | grep -q /opt/homebrew; then
  echo "ERROR: a bundle executable links /opt/homebrew"; exit 1
fi
find "$DST/Contents/Resources/racket-dist/lib" -name 'libAPIAnywareRacket.dylib' | grep -q . \
  || { echo "ERROR: libAPIAnywareRacket.dylib not carried into the dist"; exit 1; }

echo "== built: $DST =="
echo "   CFBundleIdentifier = $(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$DST/Contents/Info.plist")"
du -sh "$DST" | sed 's/^/   /'
