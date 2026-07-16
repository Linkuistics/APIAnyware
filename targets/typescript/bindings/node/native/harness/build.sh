#!/usr/bin/env bash
# Build the k42 test harness: a native main()-owner that embeds Node under AppKit and pumps libuv
# as a guest (ADR-0056 mechanism (c)). NOT the shipped launcher (that is Step 8 / bundle-typescript).
#
# Links three languages into one executable: the reusable pump core (src/pump.swift +
# src/pump_shim.cc) and the ObjC++ embedder/harness (harness/embed_main.mm), against the embedded
# libnode + AppKit. swiftc drives the final link so the Swift runtime is pulled in; the C++/ObjC++
# translation units are compiled to objects first with clang++.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
native="$(cd "$here/.." && pwd)"
src="$native/src"
out_dir="$here/build"
out="$out_dir/embed_harness"

# Node-API / embedder + V8 headers: <node-prefix>/include/node.
node_bin="$(command -v node)"
node_prefix="$(dirname "$(dirname "$(node -e 'process.stdout.write(process.execPath)')")")"
node_inc="$node_prefix/include/node"
node_lib_dir="$node_prefix/lib"
# The shared libnode dylib (libnode.<abi>.dylib). Homebrew's node ships it (built --shared).
libnode="$(ls "$node_lib_dir"/libnode.*.dylib 2>/dev/null | head -1 || true)"
if [[ ! -f "$node_inc/node.h" || -z "$libnode" ]]; then
  echo "error: node embedder headers or libnode dylib not found (inc=$node_inc lib=$node_lib_dir)" >&2
  exit 1
fi
# Runtime rpath: the dylib's install-name dir (stable across the versioned Cellar path).
rpath_dir="$(dirname "$(otool -D "$libnode" | tail -1)")"
# libnode statically embeds libuv but does NOT re-export uv_run etc.; the shared libuv it links
# (an absolute-install-name dylib) does. Link it directly so pump_shim.o's uv_run resolves, and so
# pump.swift's dlsym(RTLD_DEFAULT, "uv_*") finds them at runtime.
libuv="$(otool -L "$libnode" | grep -oE '/[^ ]*libuv\.[0-9]+\.dylib' | head -1 || true)"
if [[ ! -f "$libuv" ]]; then
  echo "error: shared libuv dylib not found (libnode links: $(otool -L "$libnode" | grep -i uv))" >&2
  exit 1
fi

mkdir -p "$out_dir"
echo "building $out"
echo "  node headers: $node_inc"
echo "  libnode:      $libnode  (rpath $rpath_dir)"

# 1. The V8-scoped pump body (pump_shim.cc) — needs the V8/Node C++ headers.
clang++ -std=c++20 -O2 -fno-exceptions -c "$src/pump_shim.cc" -I"$node_inc" -o "$out_dir/pump_shim.o"

# 2. The ObjC++ embedder/harness — Node embedder API + AppKit. APP_DIR baked so it require()s app.cjs.
clang++ -std=c++20 -O2 -ObjC++ -c "$here/embed_main.mm" \
  -I"$node_inc" -DAPP_DIR="$here" -o "$out_dir/embed_main.o"

# 3. Link everything via swiftc (pulls in the Swift runtime), with the pump Swift source + the objects.
swiftc -O \
  -parse-as-library \
  -o "$out" \
  "$src/pump.swift" \
  "$out_dir/pump_shim.o" \
  "$out_dir/embed_main.o" \
  "$libnode" \
  "$libuv" \
  -framework AppKit -framework Foundation -framework CoreFoundation \
  -lc++ \
  -Xlinker -rpath -Xlinker "$rpath_dir"

echo "built: $out"
file "$out"
