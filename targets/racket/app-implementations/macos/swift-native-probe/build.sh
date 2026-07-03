#!/usr/bin/env bash
# Build the swift-native-probe racket sample app into a SELF-CONTAINED .app
# bundle for the AppSpec scenario runner (instrument+build child racket-impl-k144;
# contract: apps/macos/swift-native-probe/docs/logging-contract.md).
#
# The bundle step is the production bundler (apianyware-bundle-racket's
# self-contained mode): it stages the colocated source tree, runs `raco exe`
# (embeds the full module graph — generated bindings, runtime, and the ffi2
# collection from the build host's ffi2-lib package) and `raco distribute`
# (machine-portable dist carrying libAPIAnywareRacket.dylib via the runtime's
# define-runtime-path references), then compiles the Swift stub launcher
# (CFBundleExecutable) that execv's the distributed executable at
# Contents/Resources/racket-dist/bin/. Net: the .app travels alone — the VM
# needs NOTHING staged. Mirrors the note-editor / drawing-canvas build.sh.
#
# Bundle id: the bundler derives the id from the spec's first H1 → "Swift-Native
# Probe.app" / com.linkuistics.Swift-NativeProbe. The live-run stage installs
# FOUR impls in one VM, so each needs a DISTINCT bundle id + .app name
# (com.linkuistics.swift-native-probe-racket at /Applications/SwiftNativeProbe-racket.app),
# hence the post-mv PlistBuddy + re-sign dance below — same as the prior seven
# apps + the sbcl sibling (a native --bundle-id flag on the bundlers remains the
# proper long-term home).
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"   # .../app-implementations/macos/swift-native-probe
WS="$(cd "$HERE/../../../../.." && pwd)"                # workspace root
BINDINGS="$WS/targets/racket/bindings/macos"
BUILD="$HERE/build"
BUNDLE_ID="com.linkuistics.swift-native-probe-racket"  # == descriptor #:bundle-id
APP_NAME="SwiftNativeProbe-racket"                     # -> $BUILD/$APP_NAME.app; installs at /Applications/$APP_NAME.app (#:binary)

export SDKROOT="$(xcrun --sdk macosx --show-sdk-path)"
cd "$WS"

# --- prerequisite: the CreateML Swift-native residual (racket-impl-k144 bring-in) ---
# The probe's two shapes — CreateML.timestampSeed (free fn) + MLCreateErrorDomain
# (constant) — are Swift-native (objc_exposed: false, no C symbol), so they need
# generated/createml/ AND the @_cdecl trampolines in libAPIAnywareRacket. Unlike the
# other racket apps, CreateML is NOT in the base corpus of this worktree (only its
# annotations.apiw; no resolved.json, zero CreateML trampolines in the dylib). Bring
# it in TARGETED + ADDITIVE: no existing emit golden covers CreateML, so goldens-as-
# truth holds (verified k144). Self-heals a clean worktree; keyed on the emitted
# binding. NB this is a per-framework bring-in, NOT the 153-framework mass regen the
# spec's "no corpus regeneration" note warned against.
if [ ! -f "$BINDINGS/generated/createml/functions.rkt" ]; then
  echo "== [prereq] bring CreateML into the corpus + racket bindings (absent) =="
  cargo run -q -p apianyware-collect  -- --only CreateML
  cargo run -q -p apianyware-analyze  -- --only CreateML
  cargo run -q -p apianyware-generate -- --target racket
  echo "== [prereq] relink adapter dylib (CreateML trampolines added; --product, not --target) =="
  swift build --package-path targets/racket/adapters/macos --product APIAnywareRacket
fi
# Generic dylib check (follows the symlink; false if dangling) — build if the
# prereq block did not already.
if [ ! -f "$BINDINGS/lib/libAPIAnywareRacket.dylib" ]; then
  echo "== [prereq] swift build adapter dylib =="
  swift build --package-path targets/racket/adapters/macos --product APIAnywareRacket
fi

# --- bundle (default id), then rename + set the per-impl bundle id ---
echo "== [1/3] bundle (raco exe + raco distribute + stub + sign) =="
cargo run -q --example bundle_app -p apianyware-bundle-racket -- swift-native-probe
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

# --- self-containment report (the VM run is the real verify) ---
echo "== [2/3] self-containment report =="
DIST_EXE="$DST/Contents/Resources/racket-dist/bin/swift-native-probe"
test -x "$DIST_EXE" || { echo "ERROR: distributed exe missing"; exit 1; }
if otool -L "$DST/Contents/MacOS/swift-native-probe" "$DIST_EXE" | grep -q /opt/homebrew; then
  echo "ERROR: a bundle executable links /opt/homebrew"; exit 1
fi
find "$DST/Contents/Resources/racket-dist/lib" -name 'libAPIAnywareRacket.dylib' | grep -q . \
  || { echo "ERROR: libAPIAnywareRacket.dylib not carried into the dist"; exit 1; }

# REVIVE smoke through the stub: AW_PROBE_SMOKE makes the bundled image call both
# Swift-native trampolines (timestampSeed + MLCreateErrorDomain), build + order-front
# the window, and emit the full k141 contract, then exit 0 WITHOUT the run loop — so no
# GUI ever renders (headless). This proves ON THE HOST, before the VM round-trip, the
# stub exec + the CreateML @_cdecl residual + the contract emission. The requires
# ("../../generated/…") only resolve through the bundler's SourceRoots split, so the
# built bundle — not `racket <src>` — is the smoke's only runnable form.
echo "== [3/3] revive smoke (stub → image → CreateML trampolines + k141 contract) =="
SMOKE_LOG="$(mktemp -d)/events.log"
SWIFT_NATIVE_PROBE_EVENTS_LOG="$SMOKE_LOG" AW_PROBE_SMOKE=1 "$DST/Contents/MacOS/swift-native-probe" >/dev/null 2>&1 || true
echo "   --- events.log ---"
sed 's/^/   /' "$SMOKE_LOG"
grep -q '^\[lifecycle\] startup$'                     "$SMOKE_LOG" || { echo "ERROR: no [lifecycle] startup"; exit 1; }
grep -q '^\[probe\] result .*name="CreateML.timestampSeed" ok=#t'       "$SMOKE_LOG" || { echo "ERROR: timestampSeed probe not ok"; exit 1; }
grep -q '^\[probe\] result .*name="CreateML.MLCreateErrorDomain" ok=#t' "$SMOKE_LOG" || { echo "ERROR: MLCreateErrorDomain probe not ok"; exit 1; }
grep -q '^\[probe\] complete count=2 ok=2 all-ok=#t$'  "$SMOKE_LOG" || { echo "ERROR: coverage not all-ok"; exit 1; }
grep -q '^Swift-Native Probe opened\.$'                "$SMOKE_LOG" || { echo "ERROR: no launch line"; exit 1; }
echo "   smoke OK: startup + 2 probes ok + all-ok=#t + launch line"

echo "== built: $DST =="
echo "   CFBundleIdentifier = $(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$DST/Contents/Info.plist")"
du -sh "$DST" | sed 's/^/   /'
