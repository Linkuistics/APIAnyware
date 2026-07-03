#!/usr/bin/env bash
# Build the swift-native-probe sbcl sample app into a self-contained .app bundle for the
# AppSpec scenario runner (instrument+build child sbcl-impl-k143; contract:
# apps/macos/swift-native-probe/docs/logging-contract.md).
#
# This REPLACES the app's original 060-era hand-rolled /tmp-staged wrap with the production
# bundler (apianyware-bundle-sbcl, ADR-0041) — the drawing-canvas k137 / note-editor k128
# treatment. The bundler drives this app's own dump.lisp (save-lisp-and-die :executable t),
# compiles the DYLD_FALLBACK stub launcher (CFBundleExecutable) that sets
# DYLD_FALLBACK_LIBRARY_PATH=<bundle>/Contents/Frameworks and execv's the dumped image, and
# vendors BOTH non-system dylibs into Frameworks/:
#   - libzstd.1.dylib       — SBCL's core-compression dep, a hard LC_LOAD_DYLIB on the image
#                             at an absolute /opt/homebrew path a vanilla VM lacks (post-dump
#                             install_name_tool is impossible — the Lisp core sits past
#                             __LINKEDIT — so the stub's DYLD fallback resolves it by leaf
#                             name at launch);
#   - libAPIAnywareSbcl.dylib — needed here for TWO facilities: the §6d Swift-native
#                             trampoline RESIDUAL (CoreGraphics.hypot + the Foundation
#                             NSNotFound/NSNumber/Scanner/IndexSet symbols the five shapes
#                             exercise) AND the `aw_sbcl_subclass_*` bounce shim the
#                             `applicationWillTerminate:` terminate delegate uses. The dump
#                             records the @executable_path/../Frameworks/ namestring
#                             (ADR-0038 §5 / AW_NATIVE_DYLIB_RECORD_AS, set by the bundler),
#                             so the revived image reopens the vendored copy exe-relative.
# Net: the .app travels alone — the VM needs NOTHING staged (no /tmp dylib, no libzstd).
#
# Prerequisite key: the COREGRAPHICS binding artifact (hypot lives in coregraphics/, and an
# appkit-keyed check would false-pass a tree with no CG bindings — the chez/gerbil k99/k100
# finding). Swift-native-probe adds NO new framework (unlike drawing-canvas's CoreGraphics
# growth): every trampoline it exercises already exists in the shipped bindings + the fresh
# dylib, so this is instrumentation + rebuild, not a corpus regen. Anything that DOES
# regenerate must relink via `swift build --product` (not --target) or the smoke hits a
# stale-dylib "symbol not found" ([[swift_build_product_vs_target]]).
#
# Bundle id: the bundler derives the id from the spec's first H1 → "Swift-Native Probe.app"
# / com.linkuistics.Swift-NativeProbe. The live-run stage installs FOUR impls in one VM, so
# each needs a DISTINCT bundle id + .app name (com.linkuistics.swift-native-probe-sbcl at
# /Applications/SwiftNativeProbe-sbcl.app), hence the post-mv PlistBuddy + re-sign dance
# below — same as the prior seven apps (a native --bundle-id flag on the bundlers remains
# the proper long-term home). The bundler's plist carries the kind-required
# CFBundleInfoDictionaryVersion (the k132 finding the old hand-rolled plist omitted — the
# reason this app moved off the hand-rolled wrap).
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"        # app-implementations/macos/swift-native-probe
WS="$(cd "$HERE/../../../../.." && pwd)"                    # workspace root
BUILD="$HERE/build"
APP_NAME="SwiftNativeProbe-sbcl"                            # -> $BUILD/$APP_NAME.app; installs at /Applications/$APP_NAME.app (#:binary)
BUNDLE_ID="com.linkuistics.swift-native-probe-sbcl"        # == descriptor #:bundle-id
BINDINGS="$WS/targets/sbcl/bindings/macos"
DYLIB_SRC="$WS/targets/sbcl/adapters/macos/.build/arm64-apple-macosx/debug/libAPIAnywareSbcl.dylib"

export SDKROOT="$(xcrun --sdk macosx --show-sdk-path)"
cd "$WS"

# --- prerequisites: generated bindings (keyed on CoreGraphics) + adapter dylib ---
# The bundler would also swift-build the dylib on demand, but the pre-flight below needs it
# first (run.lisp resolves this build path).
if [ ! -f "$BINDINGS/generated/coregraphics/functions.lisp" ]; then
  echo "== [prereq] generate sbcl bindings + trampolines (CoreGraphics absent) =="
  cargo run -q -p apianyware-generate -- --target sbcl
  echo "== [prereq] relink adapter dylib (trampoline set changed) =="
  swift build --package-path targets/sbcl/adapters/macos --product APIAnywareSbcl
fi
if [ ! -f "$DYLIB_SRC" ]; then
  echo "== [prereq] swift build adapter dylib (trampoline residual + subclass bounce shim) =="
  swift build --package-path targets/sbcl/adapters/macos --product APIAnywareSbcl
fi

echo "== [1/3] host construction pre-flight (probes every shape + emits the k141 contract) =="
AW_PROBE_SMOKE=1 sbcl --non-interactive --disable-debugger --load "$HERE/run.lisp"

# --- bundle (default id), then rename + set the per-impl bundle id ---
echo "== [2/3] bundle (dump + stub + vendor libzstd/libAPIAnywareSbcl + sign) =="
cargo run -q --example bundle_app -p apianyware-bundle-sbcl -- swift-native-probe
SRC="$BUILD/Swift-Native Probe.app"
DST="$BUILD/$APP_NAME.app"
rm -rf "$DST"
mv "$SRC" "$DST"
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $BUNDLE_ID" "$DST/Contents/Info.plist"
# Re-sign after the plist edit: codesign seals Info.plist, so the post-mv edit invalidates
# the bundler's signature. Match the bundler's identity choice (the persistent local identity
# when the keychain has it, else ad-hoc); the dumped image under Resources/ is sealed by
# hash, never re-signed (ADR-0041).
IDENTITY="APIAnyware Local Signing"
if ! security find-identity -p codesigning -v 2>/dev/null | grep -q "$IDENTITY"; then
  IDENTITY="-"
fi
codesign --force --sign "$IDENTITY" "$DST"

# REVIVE smoke through the stub: AW_PROBE_SMOKE makes the revived image call every
# Swift-native trampoline + build the UI + emit the k141 contract (exercising the startup
# re-resolution pass AND the §6d residual-dylib reopen via @executable_path/../Frameworks/)
# then exit 0 without the run loop — proving on the host, before the VM round-trip, the stub
# exec, the dump+revive-WITH-the-dylib path (ADR-0038 §5), and the contract emission.
echo "== [3/3] revive smoke (stub → image → vendored-dylib reopen + contract emission) =="
AW_PROBE_SMOKE=1 "$DST/Contents/MacOS/swift-native-probe"

echo "== built: $DST =="
echo "   CFBundleIdentifier = $(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$DST/Contents/Info.plist")"
echo "   CFBundleInfoDictionaryVersion = $(/usr/libexec/PlistBuddy -c 'Print :CFBundleInfoDictionaryVersion' "$DST/Contents/Info.plist")"
echo "   stub otool -L (must show no /opt/homebrew):"
otool -L "$DST/Contents/MacOS/swift-native-probe" | sed 's/^/   /'
echo "   vendored (Contents/Frameworks):"
ls "$DST/Contents/Frameworks" | sed 's/^/   /'
du -sh "$DST" | sed 's/^/   /'
