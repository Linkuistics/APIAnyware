#!/bin/bash
set -euo pipefail

# build.sh — Create Modaliser.app bundle with Swift stub launcher
#
# Compiles a per-app Swift stub binary that execv's into the Racket runtime.
# This gives the app a unique CDHash so macOS TCC grants Accessibility and
# Screen Recording permissions independently, rather than sharing them with
# every process using the same Racket binary.
#
# The resulting .app has:
#   - Unique Mach-O arm64 executable (compiled Swift stub, ~50KB)
#   - execv into /opt/homebrew/bin/racket with bundled main.rkt
#   - Proper bundle ID, entitlements, and usage descriptions
#   - AppIcon.icns generated from source PNG
#   - Code signature for stable TCC permissions

APP_NAME="Modaliser"
RUNTIME="/opt/homebrew/bin/racket"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"          # apps/modaliser/
BUILD_DIR="${PROJECT_DIR}/build"
APP_BUNDLE="${BUILD_DIR}/${APP_NAME}.app"
CONTENTS="${APP_BUNDLE}/Contents"
MACOS_DIR="${CONTENTS}/MacOS"
RESOURCES="${CONTENTS}/Resources"
APP_DIR="${RESOURCES}/racket-app"

# Resolve absolute paths to siblings of the layout. PROJECT_DIR is
# generation/targets/racket-oo/apps/modaliser/, so the racket-oo target
# root is two levels up, and the original Modaliser repo is six levels
# up + ../Modaliser (sibling of APIAnyware-MacOS).
BINDINGS_ROOT="$(cd "${PROJECT_DIR}/../.." && pwd)"
DEV_ROOT="$(cd "${BINDINGS_ROOT}/../../../.." && pwd)"

# Original Modaliser's icon (sibling project at $DEV_ROOT/Modaliser)
ICON_SOURCE="${DEV_ROOT}/Modaliser/Resources/AppIcon.png"

cd "$PROJECT_DIR"

echo "Building ${APP_NAME}.app (Swift stub launcher)..."

# --- Step 1: Create bundle directory structure ---
rm -rf "$APP_BUNDLE"
mkdir -p "$MACOS_DIR" "$APP_DIR"

# --- Step 2: Generate and compile Swift stub ---
STUB_SOURCE="${BUILD_DIR}/_stub_launcher.swift"

cat > "$STUB_SOURCE" << 'SWIFT'
import Foundation

let runtime = "/opt/homebrew/bin/racket"

guard let script = Bundle.main.path(forResource: "main", ofType: "rkt", inDirectory: "racket-app") else {
    fputs("Modaliser: could not find main.rkt in app bundle\n", stderr)
    exit(1)
}

let argv = [runtime, script]
let cArgv = argv.map { strdup($0) } + [nil]
execv(runtime, cArgv)

fputs("Modaliser: exec failed: \(String(cString: strerror(errno)))\n", stderr)
exit(1)
SWIFT

swiftc -O -o "${MACOS_DIR}/${APP_NAME}" "$STUB_SOURCE"
rm -f "$STUB_SOURCE"

echo "Swift stub compiled: $(file "${MACOS_DIR}/${APP_NAME}" | sed "s|${MACOS_DIR}/${APP_NAME}: ||")"

# --- Step 3: Copy project source files into Resources/racket-app/ ---
for dir in core ffi lib services ui; do
    cp -R "${PROJECT_DIR}/${dir}" "${APP_DIR}/${dir}"
done

cp "${PROJECT_DIR}/main.rkt" "${APP_DIR}/main.rkt"

# Strip host-compiled .zo bytecode. Files under compiled/ are machine-
# and Racket-version-specific; shipping them poisons a bundle transferred
# to another machine (wrong linklets, contract errors at load time).
find "${APP_DIR}" -type d -name compiled -prune -exec rm -rf {} +

# Set up bindings as absolute symlinks to APIAnyware-MacOS
mkdir -p "${APP_DIR}/bindings"
ln -s "${BINDINGS_ROOT}/generated" "${APP_DIR}/bindings/generated"
ln -s "${BINDINGS_ROOT}/lib"       "${APP_DIR}/bindings/lib"
ln -s "${BINDINGS_ROOT}/runtime"   "${APP_DIR}/bindings/runtime"

echo "Project files copied to Resources/racket-app/"

# --- Step 4: Install custom Info.plist ---
cp "${SCRIPT_DIR}/Info.plist" "${CONTENTS}/Info.plist"

# --- Step 5: Generate and install .icns from AppIcon.png ---
if [ -f "$ICON_SOURCE" ]; then
    echo "Generating AppIcon.icns..."
    ICONSET_DIR="${BUILD_DIR}/AppIcon.iconset"
    ICNS_FILE="${RESOURCES}/AppIcon.icns"
    rm -rf "$ICONSET_DIR"
    mkdir -p "$ICONSET_DIR"

    for size in 16 32 128 256 512; do
        sips -z "$size" "$size" "$ICON_SOURCE" --out "${ICONSET_DIR}/icon_${size}x${size}.png" > /dev/null
        retina=$((size * 2))
        sips -z "$retina" "$retina" "$ICON_SOURCE" --out "${ICONSET_DIR}/icon_${size}x${size}@2x.png" > /dev/null
    done

    iconutil --convert icns --output "$ICNS_FILE" "$ICONSET_DIR"
    rm -rf "$ICONSET_DIR"
    echo "Generated AppIcon.icns"
else
    echo "Warning: ${ICON_SOURCE} not found, skipping icon generation."
fi

# --- Step 6: Clear quarantine/provenance attributes ---
xattr -cr "$APP_BUNDLE"

# --- Step 7: Code sign ---
# A stable codesigning identity keeps TCC grants alive across rebuilds.
# Ad-hoc signing changes the CDHash on every build, silently invalidating
# Accessibility / Screen Recording grants. See README "Codesigning & TCC
# permissions" for the one-time Keychain Access setup.
echo "Signing ${APP_NAME}.app..."
if security find-identity -v -p codesigning | grep -q "Modaliser Dev"; then
    codesign --force --sign "Modaliser Dev" "$APP_BUNDLE"
else
    cat <<'WARN' >&2

WARNING: no 'Modaliser Dev' codesigning identity found — falling back to
         ad-hoc signing. Every rebuild will produce a new CDHash, so TCC
         will silently invalidate Accessibility and Screen Recording
         grants and the app will fall into its "permission not granted"
         branch on relaunch.

         Fix once via Keychain Access > Certificate Assistant > Create a
         Certificate (Self Signed Root, Code Signing, name "Modaliser
         Dev"). See README section "Codesigning & TCC permissions".

WARN
    codesign --force --sign - "$APP_BUNDLE"
fi

echo ""
echo "Built: ${APP_BUNDLE}"
echo "  Binary: $(file "${MACOS_DIR}/${APP_NAME}" | sed "s|${MACOS_DIR}/${APP_NAME}: ||")"
echo "  CDHash: $(codesign -dvvv "$APP_BUNDLE" 2>&1 | grep CDHash | head -1)"
echo ""
echo "To launch:"
echo "  open ${APP_BUNDLE}"
echo ""
echo "To install (symlink to /Applications):"
echo "  ln -sf ${APP_BUNDLE} /Applications/${APP_NAME}.app"
