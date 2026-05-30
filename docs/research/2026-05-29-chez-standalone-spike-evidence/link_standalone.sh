#!/bin/bash
# link_standalone.sh <open|closed> — build a self-contained hello-window
# binary from the shared hw-whole.so.
#   open   : boot = petite + scheme + app   (compiler present; eval/load work)
#   closed : boot = petite + app            (no compiler; eval refused)
set -euo pipefail
MODE="${1:?usage: link_standalone.sh <open|closed>}"
KERNEL=/opt/homebrew/Cellar/chezscheme/10.4.1/lib/csv10.4.1/tarm64osx
CHEZ=/opt/homebrew/bin/chez
HERE="$(cd "$(dirname "$0")" && pwd)"
cd "$HERE"

case "$MODE" in
  open)   BOOT=hw-open.boot;   BIN=hw_open
          "$CHEZ" --quiet <<EOF
(make-boot-file "$BOOT" '() "$KERNEL/petite.boot" "$KERNEL/scheme.boot" "hw-whole.so")
(printf "wrote $BOOT (open-world: petite+scheme+app)\n")
EOF
          ;;
  closed) BOOT=hw-closed.boot; BIN=hw_closed
          "$CHEZ" --quiet <<EOF
(make-boot-file "$BOOT" '() "$KERNEL/petite.boot" "hw-whole.so")
(printf "wrote $BOOT (closed-world: petite+app, no compiler)\n")
EOF
          ;;
  *) echo "unknown mode $MODE"; exit 1;;
esac

# Stage a self-contained run dir: binary + boot + lib/ next to each other.
RUN="run_$MODE"
rm -rf "$RUN"; mkdir -p "$RUN/lib"
cp chez-tree/lib/libAPIAnywareChez.dylib "$RUN/lib/"
cp "$BOOT" "$RUN/"

cc -O2 -I"$KERNEL" -DBOOTNAME="\"$BOOT\"" \
   -o "$RUN/$BIN" embed_main.c \
   "$KERNEL/libkernel.a" "$KERNEL/liblz4.a" "$KERNEL/libz.a" \
   -liconv -lncurses -lz \
   -framework Foundation -framework AppKit

echo "== $MODE staged in $RUN/ =="
ls -la "$RUN" "$RUN/lib"
du -sh "$RUN"
