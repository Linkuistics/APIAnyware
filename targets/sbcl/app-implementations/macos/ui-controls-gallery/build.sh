#!/usr/bin/env bash
# Build the ui-controls-gallery sbcl sample app into a self-contained .app bundle for the
# AppSpec scenario runner (instrument+build child sbcl-instrument-build-k92; contract:
# apps/macos/ui-controls-gallery/docs/logging-contract.md).
#
# The bundle step is the production bundler (apianyware-bundle-sbcl, ADR-0041), not a
# hand-rolled wrap: it drives this app's dump.lisp, compiles the Swift stub launcher
# (CFBundleExecutable) that sets DYLD_FALLBACK_LIBRARY_PATH=<bundle>/Contents/Frameworks
# and execv's the dumped image, and vendors BOTH non-system dylibs into Frameworks/:
#   - libzstd.1.dylib      — SBCL's core-compression dep, a hard LC_LOAD_DYLIB on the
#                            image at an absolute /opt/homebrew path a vanilla VM lacks
#                            (post-dump install_name_tool is impossible — the Lisp core
#                            sits past __LINKEDIT — so the stub's DYLD fallback resolves
#                            it by leaf name at launch);
#   - libAPIAnywareSbcl.dylib — the subclass bounce shim the logging contract's callbacks
#                            need (dlopen'd, not a load command): the terminate delegate
#                            AND the four [controls] target-actions are ObjC→Lisp entries
#                            (ADR-0035). The dump records the
#                            @executable_path/../Frameworks/ namestring (ADR-0038 §5 /
#                            AW_NATIVE_DYLIB_RECORD_AS), so the revived image reopens the
#                            vendored copy exe-relative.
# Net: the .app travels alone — the VM needs NOTHING staged (no /tmp dylib, no libzstd).
#
# Bundle id: the bundler derives the id from the spec's first H1 → "UI Controls Gallery.app"
# / com.linkuistics.UIControlsGallery. The live-run stage installs FOUR impls in one VM, so
# each needs a DISTINCT bundle id + .app name (com.linkuistics.ui-controls-gallery-<impl> at
# /Applications/UIControlsGallery-<impl>.app), hence the post-mv PlistBuddy + re-sign dance
# below — same as hello-window's build.sh (a native --bundle-id flag on the bundlers remains
# the proper long-term home).
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"        # app-implementations/macos/ui-controls-gallery
WS="$(cd "$HERE/../../../../.." && pwd)"                    # workspace root
BUILD="$HERE/build"
APP_NAME="UIControlsGallery-sbcl"                           # -> $BUILD/$APP_NAME.app; installs at /Applications/$APP_NAME.app (#:binary)
BUNDLE_ID="com.linkuistics.ui-controls-gallery-sbcl"        # == descriptor #:bundle-id
BINDINGS="$WS/targets/sbcl/bindings/macos"
DYLIB_SRC="$WS/targets/sbcl/adapters/macos/.build/arm64-apple-macosx/debug/libAPIAnywareSbcl.dylib"

export SDKROOT="$(xcrun --sdk macosx --show-sdk-path)"
cd "$WS"

# --- prerequisites: generated bindings + adapter dylib (regenerate if absent) ---
# The bundler would also swift-build the dylib on demand, but the pre-flight below
# needs it first (run.lisp resolves this build path).
if [ ! -f "$BINDINGS/generated/appkit.lisp" ]; then
  echo "== [prereq] generate sbcl bindings + trampolines =="
  cargo run -q -p apianyware-generate -- --target sbcl
fi
if [ ! -f "$DYLIB_SRC" ]; then
  echo "== [prereq] swift build adapter dylib (subclass bounce shim) =="
  swift build --package-path targets/sbcl/adapters/macos --product APIAnywareSbcl
fi

echo "== [1/3] host construction pre-flight =="
AW_GALLERY_SMOKE=1 sbcl --non-interactive --disable-debugger --load "$HERE/run.lisp"

# --- bundle (default id), then rename + set the per-impl bundle id ---
echo "== [2/3] bundle (dump + stub + vendor libzstd/libAPIAnywareSbcl + sign) =="
cargo run -q --example bundle_app -p apianyware-bundle-sbcl -- ui-controls-gallery
SRC="$BUILD/UI Controls Gallery.app"
DST="$BUILD/$APP_NAME.app"
rm -rf "$DST"
mv "$SRC" "$DST"
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $BUNDLE_ID" "$DST/Contents/Info.plist"
# Re-sign after the plist edit: codesign seals Info.plist, so the post-mv edit
# invalidates the bundler's signature. Match the bundler's identity choice (the
# persistent local identity when the keychain has it, else ad-hoc); the dumped image
# under Resources/ is sealed by hash, never re-signed (ADR-0041).
IDENTITY="APIAnyware Local Signing"
if ! security find-identity -p codesigning -v 2>/dev/null | grep -q "$IDENTITY"; then
  IDENTITY="-"
fi
codesign --force --sign "$IDENTITY" "$DST"

# REVIVE smoke through the stub: AW_GALLERY_SMOKE makes the revived image build the UI
# (including the controller re-synthesis + wiring) and exit 0 without the run loop,
# proving on the host — before the VM round-trip — the stub exec, the startup
# re-resolution pass, and the vendored-dylib reopen via @executable_path/../Frameworks/.
echo "== [3/3] revive smoke (stub → image → vendored-dylib reopen) =="
AW_GALLERY_SMOKE=1 "$DST/Contents/MacOS/ui-controls-gallery"

echo "== built: $DST =="
echo "   CFBundleIdentifier = $(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$DST/Contents/Info.plist")"
echo "   stub otool -L (must show no /opt/homebrew):"
otool -L "$DST/Contents/MacOS/ui-controls-gallery" | sed 's/^/   /'
echo "   vendored (Contents/Frameworks):"
ls "$DST/Contents/Frameworks" | sed 's/^/   /'
du -sh "$DST" | sed 's/^/   /'
