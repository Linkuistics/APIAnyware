#!/usr/bin/env bash
# Build the Swift-native N-API addon → build/APIAnywareTypeScript.node
# (napi-dispatch-spine-k35, ADR-0054 §2 Swift-native core language — no napi-rs / Rust).
#
# The napi_* symbols are left undefined at link time (-undefined dynamic_lookup) and
# resolved at dlopen against the Node host binary — the standard non-Rust N-API addon
# link. Node-API headers come from the active `node`'s Cellar include dir (reproducible;
# no node-gyp). Build product is gitignored (ADR-0013/0038: reproducible from source).
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
out_dir="$here/build"
out="$out_dir/APIAnywareTypeScript.node"

# Node-API headers: <node-prefix>/include/node (Homebrew keg or any node install).
node_bin="$(command -v node)"
node_prefix="$(dirname "$(dirname "$(readlink -f "$node_bin" 2>/dev/null || echo "$node_bin")")")"
node_inc="$node_prefix/include/node"
if [[ ! -f "$node_inc/node_api.h" ]]; then
  # Homebrew's bin/node is a symlink into the versioned Cellar; resolve headers there.
  node_inc="$(dirname "$(dirname "$(node -e 'process.stdout.write(process.execPath)')")")/include/node"
fi
if [[ ! -f "$node_inc/node_api.h" ]]; then
  echo "error: node_api.h not found (looked in $node_inc)" >&2
  exit 1
fi

mkdir -p "$out_dir"
echo "building $out (node headers: $node_inc)"

# The generated entry tables — the outbound dispatch table (outbound-dispatch-table-k58), the
# inbound IMP/block/super table (inbound-trampoline-table-k60), the Swift-native `s:` residual
# trampolines (swift-residual-cli-pass-k65), and the plain-C free-function table
# (fn-table-codegen-k69) — following the racket ADR-0013 build order: generate → build.
# Gitignored — reproducible from the IR. Each keeps a distinct file stem: the hand-written
# src/trampolines.swift would otherwise collide with TrampolineTable's object file.
generated_dispatch="$here/src/Generated/DispatchTable.swift"
generated_inbound="$here/src/Generated/InboundTable.swift"
generated_trampolines="$here/src/Generated/TrampolineTable.swift"
generated_functions="$here/src/Generated/FunctionTable.swift"
for generated in "$generated_dispatch" "$generated_inbound" "$generated_trampolines" \
  "$generated_functions"; do
  if [[ ! -f "$generated" ]]; then
    echo "error: $generated not found." >&2
    echo "  Generate it first (from the repo root):" >&2
    echo "    cargo run -p apianyware-generate -- --target typescript" >&2
    exit 1
  fi
done

# The outbound error-out (`…_e`) exception-catch shim (ADR-0058): Swift cannot `@catch` an
# NSException (and one must never unwind through a Swift frame), so the fallible objc_msgSend
# is done in this one ObjC unit. MRC (no ARC) on purpose — it retains the caught exception /
# out-param NSError +1 by hand. Compiled to an object and linked into the same `.node`
# (ADR-0011 hermetic single unit). It needs node_api.h (via shim.h), hence -I"$node_inc".
clang -c -O -fno-objc-arc \
  -I"$node_inc" \
  -o "$out_dir/awexc.o" \
  "$here/src/awexc.m"

swiftc \
  -O \
  -import-objc-header "$here/src/shim.h" \
  -Xcc -I"$node_inc" \
  -emit-library \
  -o "$out" \
  -Xlinker -undefined -Xlinker dynamic_lookup \
  "$here/src/napi_support.swift" \
  "$here/src/dispatch.swift" \
  "$generated_dispatch" \
  "$generated_inbound" \
  "$generated_trampolines" \
  "$generated_functions" \
  "$here/src/trampolines.swift" \
  "$here/src/fn_resolve.swift" \
  "$here/src/inbound.swift" \
  "$here/src/bounce.swift" \
  "$out_dir/awexc.o"

echo "built: $out"
file "$out"
