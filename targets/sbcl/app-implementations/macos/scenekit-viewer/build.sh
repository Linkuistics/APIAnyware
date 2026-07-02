#!/usr/bin/env bash
# Build the scenekit-viewer sbcl sample app into a self-contained .app bundle for the
# AppSpec scenario runner (instrument+build child sbcl-instrument-build-k110; contract:
# apps/macos/scenekit-viewer/docs/logging-contract.md).
#
# The bundle step is the production bundler (apianyware-bundle-sbcl, ADR-0041), not the
# retired hand-rolled wrap (this app's original 060-era /tmp-staged variant): it drives
# this app's dump.lisp, compiles the Swift stub launcher (CFBundleExecutable) that sets
# DYLD_FALLBACK_LIBRARY_PATH=<bundle>/Contents/Frameworks and execv's the dumped image,
# and vendors BOTH non-system dylibs into Frameworks/:
#   - libzstd.1.dylib      — SBCL's core-compression dep, a hard LC_LOAD_DYLIB on the
#                            image at an absolute /opt/homebrew path a vanilla VM lacks
#                            (post-dump install_name_tool is impossible — the Lisp core
#                            sits past __LINKEDIT — so the stub's DYLD fallback resolves
#                            it by leaf name at launch);
#   - libAPIAnywareSbcl.dylib — the subclass bounce shim the scene-controller's callbacks
#                            need (dlopen'd, not a load command): the terminate delegate
#                            and the target-actions are ObjC→Lisp entries (ADR-0035).
#                            The dump records the @executable_path/../Frameworks/
#                            namestring (ADR-0038 §5 / AW_NATIVE_DYLIB_RECORD_AS), so the
#                            revived image reopens the vendored copy exe-relative.
# Net: the .app travels alone — the VM needs NOTHING staged (no /tmp dylib, no libzstd).
#
# Prerequisite key: the SCENEKIT binding artifact (not appkit) — an appkit-keyed check
# would false-pass a tree with no SceneKit bindings (the chez/gerbil k99/k100 finding).
# A regen also rewrites Trampolines.swift (SceneKit itself adds ZERO Swift-native
# residual entries, but the dylib must stay in lockstep with the regenerated set or the
# smokes hit stale-dylib "symbol not found"): `swift build --product` (not --target —
# the product relinks).
#
# Bundle id: the bundler derives the id from the spec's first H1 → "SceneKit Viewer.app"
# / com.linkuistics.SceneKitViewer. The live-run stage installs FOUR impls in one VM, so
# each needs a DISTINCT bundle id + .app name (com.linkuistics.scenekit-viewer-<impl> at
# /Applications/SceneKitViewer-<impl>.app), hence the post-mv PlistBuddy + re-sign dance
# below — same as hello-window / ui-controls-gallery / pdfkit-viewer (a native
# --bundle-id flag on the bundlers remains the proper long-term home).
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"        # app-implementations/macos/scenekit-viewer
WS="$(cd "$HERE/../../../../.." && pwd)"                    # workspace root
BUILD="$HERE/build"
APP_NAME="SceneKitViewer-sbcl"                              # -> $BUILD/$APP_NAME.app; installs at /Applications/$APP_NAME.app (#:binary)
BUNDLE_ID="com.linkuistics.scenekit-viewer-sbcl"            # == descriptor #:bundle-id
BINDINGS="$WS/targets/sbcl/bindings/macos"
DYLIB_SRC="$WS/targets/sbcl/adapters/macos/.build/arm64-apple-macosx/debug/libAPIAnywareSbcl.dylib"

export SDKROOT="$(xcrun --sdk macosx --show-sdk-path)"
cd "$WS"

# --- prerequisites: generated bindings (keyed on SceneKit) + adapter dylib ---
# The bundler would also swift-build the dylib on demand, but the pre-flight below
# needs it first (run.lisp resolves this build path).
if [ ! -f "$BINDINGS/generated/scenekit/scnview.lisp" ]; then
  echo "== [prereq] generate sbcl bindings + trampolines (SceneKit absent) =="
  cargo run -q -p apianyware-generate -- --target sbcl
  echo "== [prereq] relink adapter dylib (trampoline set changed) =="
  swift build --package-path targets/sbcl/adapters/macos --product APIAnywareSbcl
fi
if [ ! -f "$DYLIB_SRC" ]; then
  echo "== [prereq] swift build adapter dylib (subclass bounce shim) =="
  swift build --package-path targets/sbcl/adapters/macos --product APIAnywareSbcl
fi

echo "== [1/3] host construction pre-flight =="
AW_SCENEKIT_SMOKE=1 sbcl --non-interactive --disable-debugger --load "$HERE/run.lisp"

# --- bundle (default id), then rename + set the per-impl bundle id ---
echo "== [2/3] bundle (dump + stub + vendor libzstd/libAPIAnywareSbcl + sign) =="
cargo run -q --example bundle_app -p apianyware-bundle-sbcl -- scenekit-viewer
SRC="$BUILD/SceneKit Viewer.app"
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

# REVIVE smoke through the stub: AW_SCENEKIT_SMOKE makes the revived image build the UI
# (delegate re-synthesis + the dispatcher re-registration this app was the first to
# exercise) and exit 0 without the run loop, proving on the host — before the VM
# round-trip — the stub exec, the startup re-resolution pass, and the vendored-dylib
# reopen via @executable_path/../Frameworks/.
echo "== [3/3] revive smoke (stub → image → vendored-dylib reopen + re-synthesis) =="
AW_SCENEKIT_SMOKE=1 "$DST/Contents/MacOS/scenekit-viewer"

echo "== built: $DST =="
echo "   CFBundleIdentifier = $(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$DST/Contents/Info.plist")"
echo "   stub otool -L (must show no /opt/homebrew):"
otool -L "$DST/Contents/MacOS/scenekit-viewer" | sed 's/^/   /'
echo "   vendored (Contents/Frameworks):"
ls "$DST/Contents/Frameworks" | sed 's/^/   /'
du -sh "$DST" | sed 's/^/   /'
