#!/usr/bin/env bash
# Build the swift-native-probe chez sample app into a self-contained .app bundle
# for the AppSpec scenario runner (instrument+build child chez-impl-k145;
# contract: apps/macos/swift-native-probe/docs/logging-contract.md).
#
# The chez impl is a self-contained open-world standalone .app (ADR-0009): the
# Chez kernel + a whole-program boot are baked into the binary, so it launches on
# a machine with no Chez installed. Host Chez is a build-time dependency only.
# Mirrors the drawing-canvas / note-editor chez build.sh, plus the racket
# swift-native-probe sibling's CreateML prereq (racket-impl-k144).
#
# Bundle id: the bundler (apianyware-bundle-chez) derives the id from the spec's
# first H1 → "Swift-Native Probe.app" / com.linkuistics.Swift-NativeProbe. The
# live-run stage installs FOUR impls in one VM, so each needs a DISTINCT bundle id
# + .app name (com.linkuistics.swift-native-probe-chez at
# /Applications/SwiftNativeProbe-chez.app), hence the post-mv PlistBuddy + re-sign
# dance below — same as the prior seven apps + the sbcl/racket siblings (a native
# --bundle-id flag on the bundlers remains the proper long-term home).
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"   # .../app-implementations/macos/swift-native-probe
WS="$(cd "$HERE/../../../../.." && pwd)"                # workspace root
BINDINGS="$WS/targets/chez/bindings/macos"
BUILD="$HERE/build"
BUNDLE_ID="com.linkuistics.swift-native-probe-chez"    # == descriptor #:bundle-id
APP_NAME="SwiftNativeProbe-chez"                        # -> $BUILD/$APP_NAME.app; installs at /Applications/$APP_NAME.app (#:binary)
IMPL="$HERE/swift-native-probe.sls"

export SDKROOT="$(xcrun --sdk macosx --show-sdk-path)"
cd "$WS"

# --- prerequisite: the CreateML Swift-native residual (per-target bring-in) ---
# The probe's two shapes — CreateML.timestampSeed (free fn) + MLCreateErrorDomain
# (constant) — are Swift-native (objc_exposed: false, no C symbol), so they need
# the chez bindings apianyware/createml/ AND the @_cdecl trampolines in
# libAPIAnywareChez. CreateML is NOT in the chez bindings of this worktree by
# default. The SHARED corpus (platforms/macos/api/CreateML/resolved.json) is
# brought in ONCE by the racket sibling (racket-impl-k144) and persists (gitignored)
# in this worktree, so chez only re-runs its PER-TARGET generate + relink — no
# collect/analyze, no golden move (CreateML is additive; verified k144). Self-heals
# a clean checkout (corpus absent) with the same targeted collect/analyze. Keyed on
# the emitted chez binding. NB this is a per-framework bring-in, NOT the
# 153-framework mass regen the spec's "no corpus regeneration" note warned against.
if [ ! -f "$BINDINGS/apianyware/createml/functions.sls" ]; then
  echo "== [prereq] bring CreateML into the chez bindings (absent) =="
  if [ ! -f "$WS/platforms/macos/api/CreateML/resolved.json" ]; then
    echo "== [prereq] CreateML corpus absent — targeted collect + analyze =="
    cargo run -q -p apianyware-collect  -- --only CreateML
    cargo run -q -p apianyware-analyze  -- --only CreateML
  fi
  cargo run -q -p apianyware-generate -- --target chez
  echo "== [prereq] relink adapter dylib (CreateML trampolines added; --product, not --target) =="
  swift build --package-path targets/chez/adapters/macos --product APIAnywareChez
fi
# Generic dylib check (follows the symlink; false if dangling) — build if the
# prereq block did not already.
if [ ! -f "$BINDINGS/lib/libAPIAnywareChez.dylib" ]; then
  echo "== [prereq] swift build adapter dylib =="
  swift build --package-path targets/chez/adapters/macos --product APIAnywareChez
fi

# --- [1/3] source pre-flight smoke (probes every shape + emits the k141 contract) ---
# The chez source resolves directly via --libdirs (unlike racket, whose requires
# only resolve through the bundler's SourceRoots split), so smoke the FULL contract
# on the source BEFORE the slow whole-program bundle. AW_PROBE_SMOKE builds the
# window + emits the contract then exits WITHOUT the run loop (headless — no GUI is
# serviced/composited, so nothing grabs the host).
echo "== [1/3] source pre-flight smoke (probes + k141 contract, no run loop) =="
PRE_LOG="$(mktemp -d)/events.log"
SWIFT_NATIVE_PROBE_EVENTS_LOG="$PRE_LOG" AW_PROBE_SMOKE=1 \
  chez --libdirs "$BINDINGS" --script "$IMPL" >/dev/null 2>&1 || true
assert_contract() {  # $1 = events.log path, $2 = label
  local log="$1" label="$2"
  echo "   --- events.log ($label) ---"
  sed 's/^/   /' "$log"
  grep -q '^\[lifecycle\] startup$'                                       "$log" || { echo "ERROR ($label): no [lifecycle] startup"; exit 1; }
  grep -q '^\[probe\] result .*name="CreateML.timestampSeed" ok=#t'       "$log" || { echo "ERROR ($label): timestampSeed probe not ok"; exit 1; }
  grep -q '^\[probe\] result .*name="CreateML.MLCreateErrorDomain" ok=#t' "$log" || { echo "ERROR ($label): MLCreateErrorDomain probe not ok"; exit 1; }
  grep -q '^\[probe\] complete count=2 ok=2 all-ok=#t$'                    "$log" || { echo "ERROR ($label): coverage not all-ok"; exit 1; }
  grep -q '^Swift-Native Probe opened\.$'                                 "$log" || { echo "ERROR ($label): no launch line"; exit 1; }
  echo "   smoke OK ($label): startup + 2 probes ok + all-ok=#t + launch line"
}
assert_contract "$PRE_LOG" "source"

# --- [2/3] bundle (default id), then rename + set the per-impl bundle id ---
echo "== [2/3] bundle (whole-program compile — slow, ~minutes) =="
cargo run -q --example bundle_app -p apianyware-bundle-chez -- swift-native-probe
SRC="$BUILD/Swift-Native Probe.app"
DST="$BUILD/$APP_NAME.app"
rm -rf "$DST"
mv "$SRC" "$DST"
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $BUNDLE_ID" "$DST/Contents/Info.plist"
# Re-sign after the plist edit: codesign seals Info.plist, so the post-mv edit
# invalidates the bundler's signature. Match the bundler's identity choice (the
# persistent local identity when the keychain has it, else ad-hoc).
IDENTITY="APIAnyware Local Signing"
if ! security find-identity -p codesigning -v 2>/dev/null | grep -q "$IDENTITY"; then
  IDENTITY="-"
fi
codesign --force --sign "$IDENTITY" "$DST"

# --- [3/3] revive smoke through the bundled whole-program image ---
# AW_PROBE_SMOKE makes the bundled image call both Swift-native trampolines
# (timestampSeed + MLCreateErrorDomain), build + order-front the window, emit the
# full k141 contract, then exit 0 WITHOUT the run loop — proving ON THE HOST,
# before the VM round-trip, that the whole-program compile carries the CreateML
# @_cdecl residual + the contract emission survives the bundle.
echo "== [3/3] revive smoke (bundled image → CreateML trampolines + k141 contract) =="
DIST_EXE="$DST/Contents/MacOS/swift-native-probe"
test -x "$DIST_EXE" || { echo "ERROR: bundled exe missing"; exit 1; }
SMOKE_LOG="$(mktemp -d)/events.log"
SWIFT_NATIVE_PROBE_EVENTS_LOG="$SMOKE_LOG" AW_PROBE_SMOKE=1 "$DIST_EXE" >/dev/null 2>&1 || true
assert_contract "$SMOKE_LOG" "bundle"

echo "== built: $DST =="
echo "   CFBundleIdentifier = $(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$DST/Contents/Info.plist")"
du -sh "$DST" | sed 's/^/   /'
