#!/bin/bash
# build_phase_a.sh — Phase A: trivial embedded open-world binary.
# Proves the kernel-embed + concatenated-boot mechanics before FFI.
set -euo pipefail

KERNEL=/opt/homebrew/Cellar/chezscheme/10.4.1/lib/csv10.4.1/tarm64osx
CHEZ=/opt/homebrew/bin/chez
HERE="$(cd "$(dirname "$0")" && pwd)"
cd "$HERE"

echo "== 1. compile hello.ss -> hello.so =="
"$CHEZ" --quiet <<EOF
(compile-file "hello.ss" "hello.so")
(printf "compiled hello.so\n")
EOF

echo "== 2. make self-contained open-world boot (petite + scheme + app) =="
"$CHEZ" --quiet <<EOF
(make-boot-file "hello-open.boot" '()
  "$KERNEL/petite.boot"
  "$KERNEL/scheme.boot"
  "hello.so")
(printf "wrote hello-open.boot\n")
EOF

echo "== 3. cc-link embedding host =="
# NB: do NOT link the kernel's main.o — it defines its own main(); we
# supply our own embed_main.c.  libkernel.a provides the Schky kernel.
cc -O2 -I"$KERNEL" -DBOOTNAME='"hello-open.boot"' \
   -o hello_open embed_main.c \
   "$KERNEL/libkernel.a" "$KERNEL/liblz4.a" "$KERNEL/libz.a" \
   -liconv -lncurses -lz \
   -framework Foundation

echo "== 4. sizes =="
ls -la hello_open hello-open.boot

echo "== 5. run (no system chez on PATH) =="
env PATH=/usr/bin:/bin ./hello_open
echo "exit: $?"
