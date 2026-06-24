#!/usr/bin/env bash
# Build the swift-native-probe sbcl sample app into a self-contained .app (060/030).
#
# The FIRST ladder app that needs libAPIAnywareSbcl (the §6d Swift-native residual). The
# pipeline extends hello-window's with the dylib:
#   0. ensure the dylib is built (swift build) and the generated residual is fresh;
#   1. stage the dylib at a FIXED path (/tmp/libAPIAnywareSbcl.dylib) so the dumped image
#      records THAT path for its `*shared-objects*` auto-reopen at revive (ADR-0038 §5);
#   2. host construction PRE-FLIGHT — load dylib + residual + build the UI without the run
#      loop, so a marshalling break fails the build before the dump;
#   3. `save-lisp-and-die :executable t` (dump.lisp) recording the staged dylib path;
#   4. wrap the exe in SwiftNativeProbe.app + drop the dylib in Contents/Frameworks (so the
#      VM-verify step can upload it alongside the bundle; the recorded load path is /tmp);
#   5. REVIVE smoke — run the dumped exe (AW_PROBE_SMOKE) so the dump+revive WITH the dylib
#      (the §6d residual surviving the dump) is proven on the host before the VM round-trip.
#
# The production packaging (relocate the dylib into Contents/Frameworks + re-resolve it
# exe-relative, code signing) is 070-distribution's `bundle-sbcl`. The VM must have the
# dylib at /tmp/libAPIAnywareSbcl.dylib (the only provisioning beyond the standalone exe).
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"        # app-implementations/macos/swift-native-probe
REPO="$(cd "$HERE/../../../../.." && pwd)"                  # repo root
BUILD="$HERE/build"
APP="$BUILD/SwiftNativeProbe.app"
EXE_NAME="swift-native-probe"
DYLIB_SRC="$REPO/targets/sbcl/adapters/macos/.build/arm64-apple-macosx/debug/libAPIAnywareSbcl.dylib"
DYLIB_STAGE="/tmp/libAPIAnywareSbcl.dylib"

export SDKROOT="$(xcrun --sdk macosx --show-sdk-path)"

echo "== [0/5] ensure dylib is built =="
if [[ ! -f "$DYLIB_SRC" ]]; then
  ( cd "$REPO" && swift build --package-path targets/sbcl/adapters/macos --product APIAnywareSbcl )
fi

echo "== [1/5] stage dylib at $DYLIB_STAGE (recorded for revive auto-reopen) =="
cp -f "$DYLIB_SRC" "$DYLIB_STAGE"

rm -rf "$BUILD"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Frameworks"

echo "== [2/5] host construction pre-flight =="
AW_PROBE_SMOKE=1 sbcl --non-interactive --disable-debugger --load "$HERE/run.lisp"

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
  <key>CFBundleName</key>            <string>Swift Native Probe</string>
  <key>CFBundleDisplayName</key>     <string>Swift Native Probe</string>
  <key>CFBundleExecutable</key>      <string>$EXE_NAME</string>
  <key>CFBundleIdentifier</key>      <string>com.linkuistics.swift-native-probe</string>
  <key>CFBundlePackageType</key>     <string>APPL</string>
  <key>CFBundleVersion</key>         <string>1.0</string>
  <key>CFBundleShortVersionString</key> <string>1.0</string>
  <key>NSPrincipalClass</key>        <string>NSApplication</string>
  <key>NSHighResolutionCapable</key> <true/>
  <key>LSMinimumSystemVersion</key>  <string>13.0</string>
</dict>
</plist>
PLIST

echo "== [5/5] revive smoke (dump+revive WITH the dylib) =="
AW_PROBE_SMOKE=1 "$APP/Contents/MacOS/$EXE_NAME"

echo "== built: $APP =="
otool -L "$APP/Contents/MacOS/$EXE_NAME" | sed 's/^/   /'
du -h "$APP/Contents/MacOS/$EXE_NAME" | sed 's/^/   /'
