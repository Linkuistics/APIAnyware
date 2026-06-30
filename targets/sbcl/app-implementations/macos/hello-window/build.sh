#!/usr/bin/env bash
# Build the hello-window sbcl sample app into a .app bundle for the AppSpec acceptance test
# (acceptance-test-k21 / impl-conformance-k23, sbcl child k30).
#
# hello-window's AppKit/Foundation calls are all pure ObjC (no Swift-native trampoline
# residual), but the app is NOT dylib-free: the AppSpec logging contract's
# `applicationWillTerminate:` delegate (→ `[lifecycle] shutdown reason=menu`) needs an
# ObjC→Lisp callback, which on SBCL MUST route through libAPIAnywareSbcl's subclass bounce
# shim (a `define-alien-callable` installed as an IMP would run Lisp on a foreign thread —
# the ADR-0035 crash). So this is the dylib variant (like note-editor), NOT the original
# pure-standalone build:
#   1. regenerate the sbcl bindings + Swift-native trampolines if absent
#      (apianyware-generate --target sbcl) — gitignored/absent in a clean checkout;
#   2. swift-build the adapter dylib if absent (libAPIAnywareSbcl), for the subclass shim;
#   3. stage the dylib at a FIXED path (/tmp/libAPIAnywareSbcl.dylib) so the dumped image
#      records THAT path for its `*shared-objects*` auto-reopen at revive (ADR-0038 §5);
#   4. host construction PRE-FLIGHT — load dylib + frameworks + synthesize the delegate +
#      build the UI, without the run loop, so a marshalling/subclass break fails before the dump;
#   5. `save-lisp-and-die :executable t` (dump.lisp) recording the staged dylib path;
#   6. wrap the exe in HelloWindow-sbcl.app (Info.plist + dylib vendored into
#      Contents/Frameworks so the VM-verify can upload it alongside the bundle);
#   7. REVIVE smoke — run the dumped exe (AW_HELLO_SMOKE) so dump+revive WITH the dylib
#      (subclass re-synthesis + dispatcher re-registration) is proven on the host before the VM.
#
# Bundle id: the acceptance test installs FOUR impls in one VM, so each needs a DISTINCT
# bundle id + .app name (k27 descriptors: com.linkuistics.hello-window-<impl> at
# /Applications/HelloWindow-<impl>.app). hello-window's build.sh writes Info.plist itself, so
# the per-impl id is set directly (no post-mv PlistBuddy + re-sign dance the racket/chez cargo
# bundlers needed — those derive the id from the spec H1). The VM must have the dylib at
# /tmp/libAPIAnywareSbcl.dylib (the only provisioning beyond the standalone exe).
#
# Production packaging (dylib relocation exe-relative, ASDF system, signing) is
# 070-distribution's `bundle-sbcl`; this is the dev build.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"        # app-implementations/macos/hello-window
REPO="$(cd "$HERE/../../../../.." && pwd)"                  # workspace root
BUILD="$HERE/build"
APP_NAME="HelloWindow-sbcl"                                 # -> $BUILD/$APP_NAME.app; installs at /Applications/$APP_NAME.app (#:binary)
APP="$BUILD/$APP_NAME.app"
EXE_NAME="hello-window"
BUNDLE_ID="com.linkuistics.hello-window-sbcl"               # == k27 descriptor #:bundle-id
BINDINGS="$REPO/targets/sbcl/bindings/macos"
DYLIB_SRC="$REPO/targets/sbcl/adapters/macos/.build/arm64-apple-macosx/debug/libAPIAnywareSbcl.dylib"
DYLIB_STAGE="/tmp/libAPIAnywareSbcl.dylib"

export SDKROOT="$(xcrun --sdk macosx --show-sdk-path)"

# --- prerequisites: generated bindings + adapter dylib (regenerate if absent) ---
if [ ! -f "$BINDINGS/generated/appkit.lisp" ]; then
  echo "== [prereq] generate sbcl bindings + trampolines =="
  ( cd "$REPO" && cargo run -q -p apianyware-generate -- --target sbcl )
fi
if [ ! -f "$DYLIB_SRC" ]; then
  echo "== [prereq] swift build adapter dylib (subclass bounce shim) =="
  ( cd "$REPO" && swift build --package-path targets/sbcl/adapters/macos --product APIAnywareSbcl )
fi

echo "== [1/4] stage dylib at $DYLIB_STAGE (recorded for revive auto-reopen) =="
cp -f "$DYLIB_SRC" "$DYLIB_STAGE"

rm -rf "$BUILD"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Frameworks"

echo "== [2/4] host construction pre-flight =="
AW_HELLO_SMOKE=1 sbcl --non-interactive --disable-debugger --load "$HERE/run.lisp"

echo "== [3/4] dump standalone executable (records dylib path $DYLIB_STAGE) =="
sbcl --non-interactive --disable-debugger --load "$HERE/dump.lisp" -- \
  "$APP/Contents/MacOS/$EXE_NAME" "$DYLIB_STAGE"
chmod +x "$APP/Contents/MacOS/$EXE_NAME"

echo "== [4/4] write Info.plist + vendor dylib into the bundle =="
cp -f "$DYLIB_SRC" "$APP/Contents/Frameworks/libAPIAnywareSbcl.dylib"
cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key>            <string>Hello Window</string>
  <key>CFBundleDisplayName</key>     <string>Hello Window</string>
  <key>CFBundleExecutable</key>      <string>$EXE_NAME</string>
  <key>CFBundleIdentifier</key>      <string>$BUNDLE_ID</string>
  <key>CFBundlePackageType</key>     <string>APPL</string>
  <key>CFBundleVersion</key>         <string>1.0</string>
  <key>CFBundleShortVersionString</key> <string>1.0</string>
  <key>NSPrincipalClass</key>        <string>NSApplication</string>
  <key>NSHighResolutionCapable</key> <true/>
  <key>LSMinimumSystemVersion</key>  <string>13.0</string>
</dict>
</plist>
PLIST

# REVIVE smoke: run the dumped exe with AW_HELLO_SMOKE so the dump+revive WITH the dylib
# (startup re-resolution: frameworks + dylib reopen + subclass dispatcher re-register, then
# `ensure-hw-delegate` re-synthesis) is proven on the host before the VM round-trip.
echo "== revive smoke (dump+revive WITH the dylib + delegate re-synthesis) =="
AW_HELLO_SMOKE=1 "$APP/Contents/MacOS/$EXE_NAME"

# No codesign step on the exe: `save-lisp-and-die` already ad-hoc signs the dumped exe on
# arm64 (so it launches), and that signature must be left intact — `codesign --force` fails
# strict validation on the appended-core layout, and `install_name_tool` cannot edit it (the
# core sits past __LINKEDIT). The vendored dylib carries its own (swift-build ad-hoc) signature;
# Info.plist is unsigned (the bundle id is read from it directly).
echo "== built: $APP =="
echo "   CFBundleIdentifier = $BUNDLE_ID"
otool -L "$APP/Contents/MacOS/$EXE_NAME" | sed 's/^/   /'
codesign -dv "$APP/Contents/MacOS/$EXE_NAME" 2>&1 | grep -iE 'Signature|adhoc' | sed 's/^/   /'
du -h "$APP/Contents/MacOS/$EXE_NAME" | sed 's/^/   /'
