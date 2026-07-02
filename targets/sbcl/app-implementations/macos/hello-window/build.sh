#!/usr/bin/env bash
# Build the hello-window sbcl sample app into a self-contained .app bundle for the
# AppSpec acceptance test (acceptance-test-k21 / impl-conformance-k23, sbcl child k30;
# made fully self-contained by sbcl-vendor-libzstd-k75).
#
# The bundle step is the production bundler (apianyware-bundle-sbcl, ADR-0041), not a
# hand-rolled wrap: it drives this app's dump.lisp, compiles the Swift stub launcher
# (CFBundleExecutable) that sets DYLD_FALLBACK_LIBRARY_PATH=<bundle>/Contents/Frameworks
# and execv's the dumped image, and vendors BOTH non-system dylibs into Frameworks/:
#   - libzstd.1.dylib      — SBCL's core-compression dep, a hard LC_LOAD_DYLIB on the
#                            image at an absolute /opt/homebrew path a vanilla VM lacks;
#                            post-dump install_name_tool is impossible (the Lisp core
#                            sits past __LINKEDIT), so the stub's DYLD fallback resolves
#                            it by leaf name at launch;
#   - libAPIAnywareSbcl.dylib — the subclass bounce shim the terminate delegate needs
#                            (dlopen'd, not a load command): the dump records the
#                            @executable_path/../Frameworks/ namestring (ADR-0038 §5 /
#                            AW_NATIVE_DYLIB_RECORD_AS), so the revived image reopens
#                            the vendored copy exe-relative.
# Net: the .app travels alone — the VM needs NOTHING staged (no /tmp dylib, no libzstd).
#
# hello-window's AppKit/Foundation calls are all pure ObjC (no Swift-native trampoline
# residual), but the app is NOT dylib-free: the AppSpec logging contract's
# `applicationWillTerminate:` delegate (→ `[lifecycle] shutdown reason=menu`) needs an
# ObjC→Lisp callback, which on SBCL MUST route through libAPIAnywareSbcl's subclass bounce
# shim (a `define-alien-callable` installed as an IMP would run Lisp on a foreign thread —
# the ADR-0035 crash).
#
# Bundle id: the bundler derives the id from the spec's first H1 → "Hello Window.app" /
# com.linkuistics.HelloWindow. The acceptance test installs FOUR impls in one VM, so each
# needs a DISTINCT bundle id + .app name (k27 descriptors: com.linkuistics.hello-window-<impl>
# at /Applications/HelloWindow-<impl>.app), hence the post-mv PlistBuddy + re-sign dance
# below — same as the racket/chez build.sh (a native --bundle-id flag on the bundlers
# remains the proper long-term home).
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"        # app-implementations/macos/hello-window
WS="$(cd "$HERE/../../../../.." && pwd)"                    # workspace root
BUILD="$HERE/build"
APP_NAME="HelloWindow-sbcl"                                 # -> $BUILD/$APP_NAME.app; installs at /Applications/$APP_NAME.app (#:binary)
BUNDLE_ID="com.linkuistics.hello-window-sbcl"               # == k27 descriptor #:bundle-id
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
AW_HELLO_SMOKE=1 sbcl --non-interactive --disable-debugger --load "$HERE/run.lisp"

# --- bundle (default id), then rename + set the per-impl bundle id ---
echo "== [2/3] bundle (dump + stub + vendor libzstd/libAPIAnywareSbcl + sign) =="
cargo run -q --example bundle_app -p apianyware-bundle-sbcl -- hello-window
SRC="$BUILD/Hello Window.app"
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

# REVIVE smoke through the stub: AW_HELLO_SMOKE makes the revived image build the UI and
# exit 0 without the run loop, proving on the host — before the VM round-trip — the stub
# exec, the startup re-resolution pass (re-dlopen, re-resolve objc_msgSend, re-mask FP
# traps, re-register the subclass dispatcher), the vendored-dylib reopen via
# @executable_path/../Frameworks/, and the delegate re-synthesis.
echo "== [3/3] revive smoke (stub → image → vendored-dylib reopen) =="
AW_HELLO_SMOKE=1 "$DST/Contents/MacOS/hello-window"

echo "== built: $DST =="
echo "   CFBundleIdentifier = $(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$DST/Contents/Info.plist")"
echo "   stub otool -L (must show no /opt/homebrew):"
otool -L "$DST/Contents/MacOS/hello-window" | sed 's/^/   /'
echo "   vendored (Contents/Frameworks):"
ls "$DST/Contents/Frameworks" | sed 's/^/   /'
du -sh "$DST" | sed 's/^/   /'
