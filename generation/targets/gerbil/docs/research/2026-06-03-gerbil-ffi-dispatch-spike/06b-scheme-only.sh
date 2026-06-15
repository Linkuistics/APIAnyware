#!/usr/bin/env bash
# Spike item 6b: isolate the cost. Emit N PURE-SCHEME wrappers, each a thin
# Gerbil proc calling ONE shared msgSend FFI entry with a distinct selector —
# the fat-native-lib shape (one generic native dispatch entry; per-method code
# is Scheme the system parses, NOT per-method C codegen). Compare its slope to
# 06's per-method define-c-lambda slope. If 06b stays flat while 06 climbs, the
# expense is per-method C codegen, not method count → fat native lib wins Q1.
set -euo pipefail
export PATH="/opt/homebrew/Cellar/gerbil-scheme/0.18.2/bin:$PATH"
unset GERBIL_HOME

gen () {
  local n="$1" f="gens_$1.ss"
  {
    echo '(import :std/foreign)'
    echo '(export main)'
    echo '(begin-ffi (msg-send sel)'
    echo '  (c-declare "#include <objc/runtime.h>")'
    echo '  (c-declare "#include <objc/message.h>")'
    echo '  (c-declare "typedef unsigned long NSUInteger;")'
    echo '  (define-c-lambda sel (char-string) (pointer void) "sel_registerName")'
    echo '  (define-c-lambda msg-send ((pointer void) (pointer void)) unsigned-int'
    echo '    "___return((unsigned)((NSUInteger (*)(id, SEL))objc_msgSend)((id)___arg1,(SEL)(void*)___arg2));"))'
    # N pure-Scheme thin wrappers over the single shared FFI entry:
    for i in $(seq 0 $((n-1))); do
      printf '(def (w%d obj) (msg-send obj (sel "selector%d")))\n' "$i" "$i"
    done
    echo '(def (main . _) (displayln "ok"))'
  } > "$f"
}

echo "N,scheme_wrappers,compile_seconds,lines_generated_c"
for N in 10 50 100 250 500 1000; do
  gen "$N"
  rm -f ~/.gerbil/lib/static/gens_${N}* "gens_$N" 2>/dev/null || true
  start=$(python3 -c 'import time;print(time.monotonic())')
  gxc -exe -O -o "gens_$N" -ld-options "-framework Foundation" "gens_$N.ss" >/dev/null 2>&1
  end=$(python3 -c 'import time;print(time.monotonic())')
  secs=$(python3 -c "print(f'{$end-$start:.2f}')")
  cloc=$(wc -l < ~/.gerbil/lib/static/gens_${N}.c 2>/dev/null || echo "?")
  echo "$N,$N,$secs,$cloc"
done
