#!/bin/bash
# assemble_app.sh <open|closed> — wrap a staged standalone into a signed
# .app and report the CDHash. Layout: the boot + lib/ sit next to the
# binary in Contents/MacOS/ (embed_main.c chdirs to the exe dir and probes
# ./lib/...). Signs the nested dylib first, then the bundle, with the
# persistent local identity (stable CDHash + TCC continuity).
set -euo pipefail
MODE="${1:?usage: assemble_app.sh <open|closed>}"
HERE="$(cd "$(dirname "$0")" && pwd)"; cd "$HERE"
IDENTITY="APIAnyware Local Signing"

case "$MODE" in
  open)   RUN=run_open;   BIN=hw_open;   BOOT=hw-open.boot;   APP="Hello Window Open.app";   BID="com.linkuistics.HelloWindowOpen";;
  closed) RUN=run_closed; BIN=hw_closed; BOOT=hw-closed.boot; APP="Hello Window Closed.app"; BID="com.linkuistics.HelloWindowClosed";;
  *) echo "bad mode"; exit 1;;
esac

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources/lib"
cp "$RUN/$BIN"  "$APP/Contents/MacOS/$BIN"
# boot + lib are DATA resources (codesign --strict rejects non-Mach-O in
# Contents/MacOS/); embed_main.c finds them via ../Resources.
cp "$RUN/$BOOT" "$APP/Contents/Resources/$BOOT"
cp "$RUN/lib/libAPIAnywareChez.dylib" "$APP/Contents/Resources/lib/"

cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key><string>${APP%.app}</string>
  <key>CFBundleDisplayName</key><string>${APP%.app}</string>
  <key>CFBundleIdentifier</key><string>$BID</string>
  <key>CFBundleExecutable</key><string>$BIN</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleVersion</key><string>1.0</string>
  <key>CFBundleShortVersionString</key><string>1.0</string>
  <key>LSMinimumSystemVersion</key><string>13.0</string>
  <key>NSHighResolutionCapable</key><true/>
</dict>
</plist>
PLIST

# Sign nested Mach-O (dylib) first, then the bundle as a whole.
codesign --force --sign "$IDENTITY" --timestamp=none \
  "$APP/Contents/Resources/lib/libAPIAnywareChez.dylib"
codesign --force --sign "$IDENTITY" --timestamp=none \
  --identifier "$BID" "$APP"

echo "== verify =="
codesign --verify --strict --verbose=2 "$APP" 2>&1 || echo "VERIFY FAILED"
echo "== CDHash / identity =="
codesign -dvvv "$APP" 2>&1 | grep -E "Identifier|CDHash|Authority|TeamIdentifier|Signature" | head
echo "== bundle size =="; du -sh "$APP"
echo "== assembled $APP =="
