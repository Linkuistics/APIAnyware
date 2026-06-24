#!/usr/bin/env bash
# Build + run the SBCL runtime smoke suite — the per-leaf smokes (050/010–070) plus
# the INTEGRATION node done-bar (050/080, smoke-integration.lisp). CLI/`--load` smoke;
# the VM-verify bar belongs to 060-sample-apps (feedback-vm-verify-every-app). This is
# the repeatable green baseline 060/070 inherit. Run from anywhere — paths resolve
# relative to this script.
set -euo pipefail

export SDKROOT="$(xcrun --sdk macosx --show-sdk-path)"

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"        # .../bindings/macos/runtime/tests
REPO="$(cd "$HERE/../../../../../.." && pwd)"               # repo root (6 up: tests→runtime→macos→bindings→sbcl→targets→repo)
SWIFT_DIR="$REPO/targets/sbcl/adapters/macos"              # the §18 per-target Swift adapter package
DYLIB="$SWIFT_DIR/.build/arm64-apple-macosx/debug/libAPIAnywareSbcl.dylib"

# libAPIAnywareSbcl is the SBCL target's sole native unit (ADR-0038): the subclass /
# threading / integration smokes all load it, so build it first. The integration smoke
# additionally compiles the Swift residual fixture (swiftc) + the C foreign-thread
# harness (clang) itself at run time, so no other prebuild is needed.
echo "== swift build --product APIAnywareSbcl =="
( cd "$SWIFT_DIR" && swift build --product APIAnywareSbcl )
[ -f "$DYLIB" ] || { echo "!! $DYLIB not built"; exit 1; }

rc=0
run () {  # run <smoke-stem> <ok-pattern>
  local stem="$1" pat="$2"
  echo "== $stem =="
  if SDKROOT=macosx sbcl --non-interactive --disable-debugger \
       --load "$HERE/$stem.lisp" 2>&1 | sed 's/^/   /' | grep -qE "$pat"; then
    echo "   $stem OK"
  else
    echo "   !! $stem did NOT report PASS"; rc=1
  fi
}

# Per-leaf unit smokes (each leaf's own done-bar), then the integration node done-bar.
run smoke-ffi-seam              'SMOKE PASS'
run smoke-object-model          'SMOKE PASS'
run smoke-lifetime-conditions   'SMOKE PASS'
run smoke-subclass-conformance  'SMOKE PASS'
run smoke-threading-callbacks   'PASS \(0 failure'
run smoke-startup-reresolution  'SMOKE PASS'
run smoke-bundle-relocate       'SMOKE PASS'
run smoke-integration           'node done-bar\): PASS'

[ $rc -eq 0 ] && echo "ALL SBCL RUNTIME SMOKES OK" || echo "SBCL RUNTIME SMOKE FAILURES"
exit $rc
