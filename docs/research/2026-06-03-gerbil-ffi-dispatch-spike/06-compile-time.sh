#!/usr/bin/env bash
# Spike item 6: compile-time DX vs generated-FFI volume (Q1 axis 2, user steer).
# Emit N typed define-c-lambda msgSend wrappers (the per-method chez-shape
# emission) for growing N and time `gxc -exe`. A fat-native-lib approach emits a
# FIXED tiny Gerbil surface regardless of method count, so its compile time is
# ~constant — this measures the slope the native lib removes.
set -euo pipefail
export PATH="/opt/homebrew/Cellar/gerbil-scheme/0.18.2/bin:$PATH"
unset GERBIL_HOME

gen () { # $1 = N  -> writes gen_$1.ss
  local n="$1" f="gen_$1.ss"
  {
    echo '(import :std/foreign)'
    echo '(export main)'
    printf '(begin-ffi ('
    for i in $(seq 0 $((n-1))); do printf 'm%d ' "$i"; done
    echo ')'
    echo '  (c-declare "#include <objc/runtime.h>")'
    echo '  (c-declare "#include <objc/message.h>")'
    echo '  (c-declare "typedef unsigned long NSUInteger;")'
    for i in $(seq 0 $((n-1))); do
      printf '  (define-c-lambda m%d ((pointer void) (pointer void)) unsigned-int "___return((unsigned)((NSUInteger (*)(id, SEL))objc_msgSend)((id)___arg1,(SEL)(void*)___arg2)+%d);")\n' "$i" "$i"
    done
    echo ')'
    echo '(def (main . _) (displayln "ok"))'
  } > "$f"
}

echo "N,wrappers,compile_seconds,lines_generated_c"
for N in 10 50 100 250 500 1000; do
  gen "$N"
  rm -f ~/.gerbil/lib/static/gen_${N}* "gen_$N" 2>/dev/null || true
  start=$(python3 -c 'import time;print(time.monotonic())')
  gxc -exe -O -o "gen_$N" -ld-options "-framework Foundation" "gen_$N.ss" >/dev/null 2>&1
  end=$(python3 -c 'import time;print(time.monotonic())')
  secs=$(python3 -c "print(f'{$end-$start:.2f}')")
  cloc=$(wc -l < ~/.gerbil/lib/static/gen_${N}.c 2>/dev/null || echo "?")
  echo "$N,$N,$secs,$cloc"
done
