#!/usr/bin/env bash
# Build the hello-window racket sample app into a .app bundle for the AppSpec
# acceptance test (acceptance-test-k21 / impl-conformance-k23, racket child k28).
#
# Unlike the self-contained sbcl/gerbil dumps, the racket impl depends on the
# SHARED racket binding package: the generated per-framework .rkt bindings
# (apianyware-generate) and libAPIAnywareRacket.dylib (swift build of the
# adapter). Both are gitignored and absent in a clean checkout, so this script
# regenerates them if missing, then bundles.
#
# Bundle id: the cargo bundler (apianyware-bundle-racket) derives the id from
# the spec's first H1 -> "Hello Window.app" / com.linkuistics.HelloWindow. The
# acceptance test installs FOUR impls in one VM, so each needs a DISTINCT bundle
# id + .app name (k27 descriptors: com.linkuistics.hello-window-<impl> at
# /Applications/HelloWindow-<impl>.app). The bundler has no per-impl-id flag, so
# we post-process the default output to the descriptor's id + name. (A native
# --bundle-id flag on the bundler is the proper long-term home — an APIAnyware
# tooling concern, not app data.)
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"   # .../app-implementations/macos/hello-window
WS="$(cd "$HERE/../../../../.." && pwd)"               # workspace root
BINDINGS="$WS/targets/racket/bindings/macos"
BUILD="$HERE/build"
BUNDLE_ID="com.linkuistics.hello-window-racket"        # == k27 descriptor #:bundle-id
APP_NAME="HelloWindow-racket"                          # -> $BUILD/$APP_NAME.app; installs at /Applications/$APP_NAME.app (#:binary)

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
echo "== bundle =="
cargo run -q --example bundle_app -p apianyware-bundle-racket -- hello-window
SRC="$BUILD/Hello Window.app"
DST="$BUILD/$APP_NAME.app"
rm -rf "$DST"
mv "$SRC" "$DST"
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $BUNDLE_ID" "$DST/Contents/Info.plist"

echo "== built: $DST =="
echo "   CFBundleIdentifier = $(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$DST/Contents/Info.plist")"
