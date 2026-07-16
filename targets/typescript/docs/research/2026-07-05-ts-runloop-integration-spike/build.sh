#!/usr/bin/env bash
# build.sh — build the throwaway runloop-integration spike: Swift bridge dylib + napi-rs .node.
set -euo pipefail
cd "$(dirname "$0")"

echo "== 1/2 Swift bridge dylib =="
./swift/build.sh

echo "== 2/2 napi-rs addon =="
( cd addon && cargo build --release )
cp addon/target/release/libtsrlspike.dylib addon.node
echo "copied -> $(pwd)/addon.node"
otool -L addon.node | grep -E "tsrlbridge|node" || true
echo "done."
