#!/usr/bin/env bash
# Build hello-window (ladder rung 1/7, Node TypeScript target): regenerate prerequisites if
# absent, compile the app + its @apianyware/* closure, then link the dev launcher (embed_main.mm,
# adapted from native/harness/embed_main.mm — see its own doc; NOT the shipped Step-8 launcher).
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ts_root="$(cd "$here/../../.." && pwd)"                 # targets/typescript
repo_root="$(cd "$ts_root/../.." && pwd)"
native="$ts_root/bindings/node/native"
runtime="$ts_root/bindings/node/runtime"
out_dir="$here/build"
out="$out_dir/hello-window-launcher"

mkdir -p "$out_dir"

# 1. Prerequisites: generated bindings, the native addon, the runtime's own devDependencies
#    (only `typescript`, for this app's own compile — the runtime's dist/ is NOT used; this app
#    compiles runtime/src straight into its own build/js/, see tsconfig.json).
if [[ ! -f "$ts_root/bindings/macos/generated/appkit/index.ts" ]]; then
  echo "== [prereq] generate typescript bindings =="
  (cd "$repo_root" && cargo run -q -p apianyware-generate -- --target typescript)
fi
if [[ ! -f "$native/build/APIAnywareTypeScript.node" ]]; then
  echo "== [prereq] build the native addon =="
  bash "$native/build.sh"
fi
if [[ ! -d "$runtime/node_modules/typescript" ]]; then
  echo "== [prereq] npm install the runtime devDependencies (tsc) =="
  (cd "$runtime" && npm install)
fi

# 2. Compile app.ts + its transitive @apianyware/* closure (17 frameworks + the runtime) into
#    build/js/ — a real tsc emit (enums need real transformation, not Node's strip-only type
#    stripping), extensionless/bare specifiers resolved at runtime by loader.mjs. tsc still emits
#    on a type error (noEmitOnError is not set) — deliberately: the corpus carries a known,
#    already-triaged TS2559 residual (corpus-typecheck-gate-k75's own posture: blocks/
#    non-curated-structs/vacuous-conformance, none reachable from this app), so this build fails
#    on any OTHER diagnostic but tolerates exactly that one code.
echo "== [1/2] tsc compile =="
tsc_out="$(node "$runtime/node_modules/typescript/bin/tsc" -p "$here/tsconfig.json" 2>&1)" || true
unexpected="$(printf '%s\n' "$tsc_out" | grep -v 'TS2559' || true)"
if [[ -n "$unexpected" ]]; then
  echo "$tsc_out" >&2
  echo "error: tsc reported diagnostics beyond the known TS2559 residual" >&2
  exit 1
fi
if [[ ! -f "$here/build/js/app-implementations/macos/hello-window/app.js" ]]; then
  echo "error: tsc did not emit app.js" >&2
  exit 1
fi

# 3. The native launcher: Node embedder headers/libs (mirrors native/harness/build.sh exactly).
node_bin="$(command -v node)"
node_prefix="$(dirname "$(dirname "$(node -e 'process.stdout.write(process.execPath)')")")"
node_inc="$node_prefix/include/node"
node_lib_dir="$node_prefix/lib"
libnode="$(ls "$node_lib_dir"/libnode.*.dylib 2>/dev/null | head -1 || true)"
if [[ ! -f "$node_inc/node.h" || -z "$libnode" ]]; then
  echo "error: node embedder headers or libnode dylib not found (inc=$node_inc lib=$node_lib_dir)" >&2
  exit 1
fi
rpath_dir="$(dirname "$(otool -D "$libnode" | tail -1)")"
libuv="$(otool -L "$libnode" | grep -oE '/[^ ]*libuv\.[0-9]+\.dylib' | head -1 || true)"
if [[ ! -f "$libuv" ]]; then
  echo "error: shared libuv dylib not found (libnode links: $(otool -L "$libnode" | grep -i uv))" >&2
  exit 1
fi

echo "== [2/2] link the launcher =="
clang++ -std=c++20 -O2 -fno-exceptions -c "$native/src/pump_shim.cc" -I"$node_inc" -o "$out_dir/pump_shim.o"
clang++ -std=c++20 -O2 -ObjC++ -c "$here/embed_main.mm" \
  -I"$node_inc" -o "$out_dir/embed_main.o"
swiftc -O \
  -parse-as-library \
  -o "$out" \
  "$native/src/pump.swift" \
  "$out_dir/pump_shim.o" \
  "$out_dir/embed_main.o" \
  "$libnode" \
  "$libuv" \
  -framework AppKit -framework Foundation -framework CoreFoundation \
  -lc++ \
  -Xlinker -rpath -Xlinker "$rpath_dir"

echo "built: $out"
file "$out"

echo ""
echo "host construction pre-flight (no window shown): AW_HELLO_SMOKE=1 $out"
echo "real run (VM only — pops a real window):        $out"
