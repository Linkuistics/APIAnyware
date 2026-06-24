#!/usr/bin/env bash
# Build the ui-controls-gallery sbcl sample app into a self-contained .app bundle (060/040).
#
# The 7-app ladder's shared pipeline (see hello-window/build.sh for the full rationale):
#   1. host construction PRE-FLIGHT — load bindings + build every control + the window
#      without the run loop, so a marshalling break fails the build before the dump;
#   2. `save-lisp-and-die :executable t` (dump.lisp) -> a standalone executable. Pure ObjC,
#      so the exe needs no libAPIAnywareSbcl dylib (`otool -L` shows only system libs +
#      libzstd, SBCL's core-compression dep);
#   3. wrap in UIControlsGallery.app (Info.plist + Contents/MacOS/), so it launches with
#      `open -n` in a WindowServer session. Bundle id under com.linkuistics.*.
#
# Production packaging (dylib relocation, ASDF system, signing) is 070-distribution's
# bundle-sbcl; this is the dev build, like gerbil's app build.sh preceded bundle-gerbil.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"        # apps/ui-controls-gallery
BUILD="$HERE/build"
APP="$BUILD/UIControlsGallery.app"
EXE_NAME="ui-controls-gallery"

export SDKROOT="$(xcrun --sdk macosx --show-sdk-path)"

rm -rf "$BUILD"
mkdir -p "$APP/Contents/MacOS"

echo "== [1/3] host construction pre-flight =="
AW_GALLERY_SMOKE=1 sbcl --non-interactive --disable-debugger --load "$HERE/run.lisp"

echo "== [2/3] dump standalone executable =="
sbcl --non-interactive --disable-debugger --load "$HERE/dump.lisp" -- "$APP/Contents/MacOS/$EXE_NAME"
chmod +x "$APP/Contents/MacOS/$EXE_NAME"

echo "== [3/3] write Info.plist =="
cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key>            <string>Controls Gallery</string>
  <key>CFBundleDisplayName</key>     <string>Controls Gallery</string>
  <key>CFBundleExecutable</key>      <string>$EXE_NAME</string>
  <key>CFBundleIdentifier</key>      <string>com.linkuistics.ui-controls-gallery</string>
  <key>CFBundlePackageType</key>     <string>APPL</string>
  <key>CFBundleVersion</key>         <string>1.0</string>
  <key>CFBundleShortVersionString</key> <string>1.0</string>
  <key>NSPrincipalClass</key>        <string>NSApplication</string>
  <key>NSHighResolutionCapable</key> <true/>
  <key>LSMinimumSystemVersion</key>  <string>13.0</string>
</dict>
</plist>
PLIST

# No codesign step — `save-lisp-and-die` already ad-hoc signs the dumped exe on arm64 and
# that signature must be left intact (post-dump Mach-O surgery is impossible; see the
# hello-window 070-distribution findings). libzstd stays at its absolute Homebrew path.
echo "== built: $APP =="
otool -L "$APP/Contents/MacOS/$EXE_NAME" | sed 's/^/   /'
codesign -dv "$APP/Contents/MacOS/$EXE_NAME" 2>&1 | grep -iE 'Signature|adhoc' | sed 's/^/   /'
du -h "$APP/Contents/MacOS/$EXE_NAME" | sed 's/^/   /'
