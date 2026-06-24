#!/usr/bin/env bash
# Build the hello-window sbcl sample app into a self-contained .app bundle (060/020).
#
# Pipeline (the 7-app ladder's shared shape; later apps reuse it):
#   1. host construction PRE-FLIGHT — load bindings + build the UI without the run loop,
#      so a marshalling break fails the build before the dump;
#   2. `save-lisp-and-die :executable t` (dump.lisp) -> a standalone executable embedding
#      the SBCL runtime + the binding library + the app. hello-window is PURE ObjC, so the
#      exe needs no libAPIAnywareSbcl dylib — `otool -L` shows only system libs/frameworks;
#   3. wrap the exe in HelloWindow.app (Info.plist + Contents/MacOS/), so it launches with
#      `open -n` in a WindowServer session (a bare exec has none — see the testanyware
#      recipe). Bundle id under com.linkuistics.* (project convention).
#
# The production packaging (dylib relocation for residual-using apps, ASDF system, code
# signing) is 070-distribution's `bundle-sbcl`; this is the dev build, like gerbil's
# app build.sh preceded bundle-gerbil.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"        # apps/hello-window
BUILD="$HERE/build"
APP="$BUILD/HelloWindow.app"
EXE_NAME="hello-window"

export SDKROOT="$(xcrun --sdk macosx --show-sdk-path)"

rm -rf "$BUILD"
mkdir -p "$APP/Contents/MacOS"

echo "== [1/3] host construction pre-flight =="
AW_HELLO_SMOKE=1 sbcl --non-interactive --disable-debugger --load "$HERE/run.lisp"

echo "== [2/3] dump standalone executable =="
sbcl --non-interactive --disable-debugger --load "$HERE/dump.lisp" -- "$APP/Contents/MacOS/$EXE_NAME"
chmod +x "$APP/Contents/MacOS/$EXE_NAME"

echo "== [3/3] write Info.plist =="
cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key>            <string>Hello Window</string>
  <key>CFBundleDisplayName</key>     <string>Hello Window</string>
  <key>CFBundleExecutable</key>      <string>$EXE_NAME</string>
  <key>CFBundleIdentifier</key>      <string>com.linkuistics.hello-window</string>
  <key>CFBundlePackageType</key>     <string>APPL</string>
  <key>CFBundleVersion</key>         <string>1.0</string>
  <key>CFBundleShortVersionString</key> <string>1.0</string>
  <key>NSPrincipalClass</key>        <string>NSApplication</string>
  <key>NSHighResolutionCapable</key> <true/>
  <key>LSMinimumSystemVersion</key>  <string>13.0</string>
</dict>
</plist>
PLIST

# No codesign step: `save-lisp-and-die` already ad-hoc signs the dumped exe on arm64 (so
# it launches), and that signature must be left intact — `codesign --force` fails "strict
# validation" on the appended-core layout, and `install_name_tool` cannot edit it either
# (the core sits past __LINKEDIT). Two 070-distribution consequences fall out, recorded as
# findings: (1) the libzstd load path stays absolute — a target without Homebrew must
# provide /opt/homebrew/opt/zstd/lib/libzstd.1.dylib, OR bundle-sbcl dumps against an SBCL
# runtime built --without-zstd / relocatable; (2) post-dump Mach-O surgery is off the table,
# so any path rewriting must happen at runtime (DYLD_*) or via the runtime SBCL chosen.
echo "== built: $APP =="
otool -L "$APP/Contents/MacOS/$EXE_NAME" | sed 's/^/   /'
codesign -dv "$APP/Contents/MacOS/$EXE_NAME" 2>&1 | grep -iE 'Signature|adhoc' | sed 's/^/   /'
du -h "$APP/Contents/MacOS/$EXE_NAME" | sed 's/^/   /'
