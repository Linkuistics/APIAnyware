#!/usr/bin/env bash
# Build the swift-native-probe gerbil sample app into a self-contained .app
# bundle for the AppSpec scenario runner (instrument+build child gerbil-impl-k146;
# contract: apps/macos/swift-native-probe/docs/logging-contract.md).
#
# The gerbil impl is a self-contained `gxc -exe` standalone .app (ADR-0009):
# libgambit.a links statically, so the Gerbil/Gambit runtime is embedded and the
# app launches on a machine with no Gerbil installed; the only Homebrew runtime
# dep (the Gerbil stdlib's openssl@3) is vendored + relocated into
# Contents/Frameworks by bundle-gerbil. The bottle gerbil toolchain
# (/opt/homebrew/Cellar/gerbil-scheme/<ver>) is a build-time dependency only —
# not symlinked onto PATH; the bundler globs the Cellar directly. Mirrors the
# drawing-canvas / note-editor gerbil build.sh, plus the chez/racket
# swift-native-probe siblings' CreateML prereq (racket-impl-k144, chez-impl-k145).
#
# Bundle id: bundle-gerbil derives the id from the spec's first H1 →
# "Swift-Native Probe.app" / com.linkuistics.Swift-NativeProbe. The live-run
# stage installs FOUR impls in one VM, so each needs a DISTINCT bundle id +
# .app name (com.linkuistics.swift-native-probe-gerbil at
# /Applications/SwiftNativeProbe-gerbil.app), hence the post-mv PlistBuddy +
# re-sign dance below — same as the prior seven apps + the sbcl/racket/chez
# siblings (a native --bundle-id flag on the bundlers remains the proper
# long-term home).
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"   # .../app-implementations/macos/swift-native-probe
WS="$(cd "$HERE/../../../../.." && pwd)"                # workspace root
BINDINGS="$WS/targets/gerbil/bindings/macos/generated"
ADAPTER="$WS/targets/gerbil/adapters/macos"
BUILD="$HERE/build"
BUNDLE_ID="com.linkuistics.swift-native-probe-gerbil"  # == descriptor #:bundle-id
APP_NAME="SwiftNativeProbe-gerbil"                      # -> $BUILD/$APP_NAME.app; installs at /Applications/$APP_NAME.app (#:binary)

export SDKROOT="$(xcrun --sdk macosx --show-sdk-path)"
cd "$WS"

# --- gcc-15 shim (the bottle Gambit config hardcodes C_COMPILER="gcc-15") ------
# Homebrew now ships gcc-16 only, so `gambuild-C` fails with "gcc-15: command
# not found" ([[gerbil_gcc15_drift]]). If gcc-15 is absent, symlink it to gcc-16
# in a shim dir and prepend that to PATH.
if ! command -v gcc-15 >/dev/null 2>&1; then
  if command -v gcc-16 >/dev/null 2>&1; then
    SHIM_DIR="/tmp/aw-gcc15-shim"
    mkdir -p "$SHIM_DIR"
    ln -sf "$(command -v gcc-16)" "$SHIM_DIR/gcc-15"
    export PATH="$SHIM_DIR:$PATH"
    echo "== [prereq] gcc-15 absent — shimmed to gcc-16 at $SHIM_DIR =="
  else
    echo "WARNING: neither gcc-15 nor gcc-16 on PATH — gerbil gxc build may fail"
  fi
fi

# --- prerequisite: the CreateML Swift-native residual (per-target bring-in) ---
# The probe's two shapes — CreateML.timestampSeed (free fn) + MLCreateErrorDomain
# (constant) — are Swift-native (objc_exposed: false, no C symbol), so they need
# the gerbil bindings generated/createml/ AND the @_cdecl trampolines in
# libAPIAnywareGerbil. CreateML is NOT in the gerbil bindings of this worktree by
# default. The SHARED corpus (platforms/macos/api/CreateML/resolved.kdl) is
# brought in ONCE by the racket sibling (racket-impl-k144) and persists
# (gitignored) in this worktree, so gerbil only re-runs its PER-TARGET generate +
# relink — no collect/analyze, no golden move (CreateML is additive; verified
# k144). Self-heals a clean checkout (corpus absent) with the same targeted
# collect/analyze. Keyed on the emitted gerbil binding. NB this is a per-framework
# bring-in, NOT the 153-framework mass regen the spec's "no corpus regeneration"
# note warned against.
#
# Unlike chez (which dlopens libAPIAnywareChez), gerbil LINKS the trampoline
# dylib at `gxc -exe` (ADR-0029 §4), so the CreateML @_cdecl residual must be in
# the dylib BEFORE bundling — generate → relink → bundle (the k107 order).
if [ ! -f "$BINDINGS/createml/functions.ss" ]; then
  echo "== [prereq] bring CreateML into the gerbil bindings (absent) =="
  if [ ! -f "$WS/platforms/macos/api/CreateML/resolved.kdl" ]; then
    echo "== [prereq] CreateML corpus absent — targeted collect + analyze =="
    cargo run -q -p apianyware-collect  -- --only CreateML
    cargo run -q -p apianyware-analyze  -- --only CreateML
  fi
  cargo run -q -p apianyware-generate -- --target gerbil
  echo "== [prereq] relink adapter dylib (CreateML trampolines added; --product, not --target) =="
  ( cd "$ADAPTER" && swift build --product APIAnywareGerbil )
fi
# Adapter dylib existence check (debug or release build path) — build if the
# prereq block did not already. gxc -exe links -lAPIAnywareGerbil, so the link
# fails loudly with undefined aw_gerbil_swift_* without it.
if ! compgen -G "$ADAPTER/.build/*/libAPIAnywareGerbil.dylib" > /dev/null \
   && ! compgen -G "$ADAPTER/.build/*/*/libAPIAnywareGerbil.dylib" > /dev/null; then
  echo "== [prereq] swift build adapter dylib (--product relinks the dylib; --target does not) =="
  ( cd "$ADAPTER" && swift build --product APIAnywareGerbil )
fi

# --- [1/2] bundle (default id), then rename + set the per-impl bundle id -------
# gerbil cannot smoke the source directly (it needs compilation, unlike chez's
# --libdirs --script), so the full-contract smoke is the bundle revive below.
echo "== [1/2] bundle (clang companion + sharded-generics gxc -O + gxc -exe -O — slow on a cold cache) =="
cargo run -q --example bundle_app -p apianyware-bundle-gerbil -- swift-native-probe
SRC="$BUILD/Swift-Native Probe.app"
DST="$BUILD/$APP_NAME.app"
rm -rf "$DST"
mv "$SRC" "$DST"
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $BUNDLE_ID" "$DST/Contents/Info.plist"
# Re-sign after the plist edit: codesign seals Info.plist, so the post-mv edit
# invalidates the bundler's signature. The nested vendored dylibs keep their own
# valid signatures.
codesign --force --sign - "$DST" >/dev/null 2>&1 || true

# --- [2/2] revive smoke through the bundled whole-program image ---------------
# AW_PROBE_SMOKE makes the bundled image call both Swift-native trampolines
# (timestampSeed + MLCreateErrorDomain), build + order-front the window, emit the
# full k141 contract, then exit 0 WITHOUT the run loop — proving ON THE HOST,
# before the VM round-trip, that the whole-program compile carries the CreateML
# @_cdecl residual + the contract emission survives the bundle. The window is
# never serviced/composited (no run loop), so nothing grabs the host.
echo "== [2/2] revive smoke (bundled image → CreateML trampolines + k141 contract) =="
DIST_EXE="$DST/Contents/MacOS/swift-native-probe"
test -x "$DIST_EXE" || { echo "ERROR: bundled exe missing"; exit 1; }
SMOKE_LOG="$(mktemp -d)/events.log"
SWIFT_NATIVE_PROBE_EVENTS_LOG="$SMOKE_LOG" AW_PROBE_SMOKE=1 "$DIST_EXE" >/dev/null 2>&1 || true
echo "   --- events.log (bundle) ---"
sed 's/^/   /' "$SMOKE_LOG"
grep -q '^\[lifecycle\] startup$'                                       "$SMOKE_LOG" || { echo "ERROR (bundle): no [lifecycle] startup"; exit 1; }
grep -q '^\[probe\] result .*name="CreateML.timestampSeed" ok=#t'       "$SMOKE_LOG" || { echo "ERROR (bundle): timestampSeed probe not ok"; exit 1; }
grep -q '^\[probe\] result .*name="CreateML.MLCreateErrorDomain" ok=#t' "$SMOKE_LOG" || { echo "ERROR (bundle): MLCreateErrorDomain probe not ok"; exit 1; }
grep -q '^\[probe\] complete count=2 ok=2 all-ok=#t$'                    "$SMOKE_LOG" || { echo "ERROR (bundle): coverage not all-ok"; exit 1; }
grep -q '^Swift-Native Probe opened\.$'                                 "$SMOKE_LOG" || { echo "ERROR (bundle): no launch line"; exit 1; }
echo "   smoke OK (bundle): startup + 2 probes ok + all-ok=#t + launch line"

echo "== built: $DST =="
echo "   CFBundleIdentifier = $(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$DST/Contents/Info.plist")"
codesign --verify --strict "$DST" && echo "   codesign --verify --strict: OK"
du -sh "$DST" | sed 's/^/   /'
