#!/usr/bin/env bash
# Build the drawing-canvas sbcl sample app into a self-contained .app bundle (060, app 9).
#
# The 7-app ladder's shared pipeline, in the dylib variant (as mini-browser/note-editor). This
# app needs libAPIAnywareSbcl for ONE native facility: the `aw_sbcl_subclass_*` bounce shim its
# TWO subclasses use (`canvas-view`: drawRect:/mouse events; `canvas-controller`: toolbar
# target-actions) — NOT for trampoline residual (every AppKit/Foundation call is plain ObjC,
# the CoreGraphics calls are direct `ns:cg-*` C aliens). No block bridge. So:
#   0. ensure the dylib is built (swift build);
#   1. stage the dylib at a FIXED path (/tmp/libAPIAnywareSbcl.dylib) so the dumped image
#      records THAT path for its `*shared-objects*` auto-reopen at revive (ADR-0038 §5);
#   2. host construction PRE-FLIGHT — load dylib + frameworks (incl. CoreGraphics residual)
#      + synthesize BOTH subclasses + build the window/canvas/toolbar + wire target-action,
#      without the run loop, so a marshalling/synthesis break fails before the dump;
#   3. `save-lisp-and-die :executable t` (dump.lisp) recording the staged dylib path;
#   4. wrap the exe in DrawingCanvas.app + drop the dylib in Contents/Frameworks (so the
#      VM-verify step can upload it alongside the bundle; the recorded load path is /tmp);
#   5. REVIVE smoke — run the dumped exe (AW_CANVAS_SMOKE) so the dump+revive WITH the dylib
#      (subclass re-synthesis + dispatcher re-registration) is proven on the host before VM.
#
# Production packaging (relocate the dylib into Contents/Frameworks + re-resolve it
# exe-relative, code signing) is 070-distribution's `bundle-sbcl`. The VM must have the dylib
# at /tmp/libAPIAnywareSbcl.dylib (the only provisioning beyond the standalone exe); no network.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"        # apps/drawing-canvas
REPO="$(cd "$HERE/../../../../.." && pwd)"                  # repo root
BUILD="$HERE/build"
APP="$BUILD/DrawingCanvas.app"
EXE_NAME="drawing-canvas"
DYLIB_SRC="$REPO/swift/.build/arm64-apple-macosx/debug/libAPIAnywareSbcl.dylib"
DYLIB_STAGE="/tmp/libAPIAnywareSbcl.dylib"

export SDKROOT="$(xcrun --sdk macosx --show-sdk-path)"

echo "== [0/5] ensure dylib is built =="
if [[ ! -f "$DYLIB_SRC" ]]; then
  ( cd "$REPO" && swift build --package-path swift --product APIAnywareSbcl )
fi

echo "== [1/5] stage dylib at $DYLIB_STAGE (recorded for revive auto-reopen) =="
cp -f "$DYLIB_SRC" "$DYLIB_STAGE"

rm -rf "$BUILD"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Frameworks"

echo "== [2/5] host construction pre-flight =="
AW_CANVAS_SMOKE=1 sbcl --non-interactive --disable-debugger --load "$HERE/run.lisp"

echo "== [3/5] dump standalone executable =="
sbcl --non-interactive --disable-debugger --load "$HERE/dump.lisp" -- \
  "$APP/Contents/MacOS/$EXE_NAME" "$DYLIB_STAGE"
chmod +x "$APP/Contents/MacOS/$EXE_NAME"

echo "== [4/5] write Info.plist + vendor dylib into the bundle =="
cp -f "$DYLIB_SRC" "$APP/Contents/Frameworks/libAPIAnywareSbcl.dylib"
cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key>            <string>Drawing Canvas</string>
  <key>CFBundleDisplayName</key>     <string>Drawing Canvas</string>
  <key>CFBundleExecutable</key>      <string>$EXE_NAME</string>
  <key>CFBundleIdentifier</key>      <string>com.linkuistics.drawing-canvas</string>
  <key>CFBundlePackageType</key>     <string>APPL</string>
  <key>CFBundleVersion</key>         <string>1.0</string>
  <key>CFBundleShortVersionString</key> <string>1.0</string>
  <key>NSPrincipalClass</key>        <string>NSApplication</string>
  <key>NSHighResolutionCapable</key> <true/>
  <key>LSMinimumSystemVersion</key>  <string>13.0</string>
</dict>
</plist>
PLIST

echo "== [5/5] revive smoke (dump+revive WITH the dylib + both subclasses) =="
AW_CANVAS_SMOKE=1 "$APP/Contents/MacOS/$EXE_NAME"

echo "== built: $APP =="
otool -L "$APP/Contents/MacOS/$EXE_NAME" | sed 's/^/   /'
du -h "$APP/Contents/MacOS/$EXE_NAME" | sed 's/^/   /'
