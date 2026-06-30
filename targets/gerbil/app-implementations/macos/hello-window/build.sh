#!/usr/bin/env bash
# Build the hello-window gerbil sample app into a .app bundle for the AppSpec
# acceptance test (acceptance-test-k21 / impl-conformance-k23, gerbil child k31).
#
# The gerbil impl is a self-contained `gxc -exe` standalone .app (ADR-0009):
# libgambit.a links statically, so the Gerbil/Gambit runtime is embedded and the
# app launches on a machine with no Gerbil installed; the only Homebrew runtime
# dep (the Gerbil stdlib's openssl@3) is vendored + relocated into
# Contents/Frameworks by bundle-gerbil. The bottle gerbil toolchain
# (/opt/homebrew/Cellar/gerbil-scheme/<ver>) is a build-time dependency only —
# already installed via `brew install gerbil-scheme`, but not symlinked onto
# PATH; the bundler globs the Cellar directly (compile.rs discover_gerbil_bin_dir).
#
# One shared prerequisite is gitignored / absent in a clean checkout and
# regenerated here if missing: the generated gerbil bindings
# (apianyware-generate --target gerbil — the sharded generics/NNN.ss + the
# appkit/foundation class modules, ADR-0023). The previous build.sh wrongly
# assumed them present and only linked a bare exe; this one drives the full
# bundle via bundle-gerbil (the reusable driver that generalises the old exe
# steps: clang the -fblocks companion, gxc -O the closure into a persistent
# cache, gxc -exe -O the app, then vendor + relocate openssl, then codesign).
#
# Bundle id: bundle-gerbil derives the id from apps/macos/hello-window/docs/spec.md's
# first H1 -> "Hello Window.app" / com.linkuistics.HelloWindow. The acceptance
# test installs FOUR impls in one VM, so each needs a DISTINCT id + .app name (k27
# descriptors: com.linkuistics.hello-window-<impl> at /Applications/HelloWindow-<impl>.app).
# The cargo bundler has NO per-impl-id flag (same gap as racket k28 / chez k29 —
# NOT the sbcl k30 case, whose build.sh writes Info.plist itself), so we
# post-process the default output: rename the .app, set CFBundleIdentifier, and
# re-sign (codesign seals Info.plist, so the post-mv edit invalidates the
# bundler's signature; `codesign --verify --strict` passes after the re-sign).
# A native --bundle-id flag on the bundlers is the proper long-term home — an
# APIAnyware tooling concern, not app data, not AppSpec.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"   # .../app-implementations/macos/hello-window
WS="$(cd "$HERE/../../../../.." && pwd)"               # workspace root
BINDINGS="$WS/targets/gerbil/bindings/macos/generated"
BUILD="$HERE/build"
BUNDLE_ID="com.linkuistics.hello-window-gerbil"        # == k27 descriptor #:bundle-id
APP_NAME="HelloWindow-gerbil"                          # -> $BUILD/$APP_NAME.app; installs at /Applications/$APP_NAME.app (#:binary)

cd "$WS"

# --- prerequisite: generated gerbil bindings (regenerate if absent) ---
if [ ! -f "$BINDINGS/generics.ss" ]; then
  echo "== [prereq] generate gerbil bindings (sharded generics + appkit/foundation) =="
  cargo run -q -p apianyware-generate -- --target gerbil
fi

# --- bundle (default id), then rename + set the per-impl bundle id ---
echo "== bundle (clang companion + sharded-generics gxc -O + gxc -exe -O — slow on a cold cache) =="
cargo run -q --example bundle_app -p apianyware-bundle-gerbil -- hello-window
SRC="$BUILD/Hello Window.app"
DST="$BUILD/$APP_NAME.app"
rm -rf "$DST"
mv "$SRC" "$DST"
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $BUNDLE_ID" "$DST/Contents/Info.plist"
# Re-sign after the plist edit (bundle level, matching bundle-gerbil's ad-hoc
# sign): re-seals CodeResources with the new Info.plist hash. The nested vendored
# dylibs keep their own valid signatures.
codesign --force --sign - "$DST" >/dev/null 2>&1 || true

echo "== built: $DST =="
echo "   CFBundleIdentifier = $(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$DST/Contents/Info.plist")"
codesign --verify --strict "$DST" && echo "   codesign --verify --strict: OK"
