#!/bin/bash
# build_whole.sh — compile hw-entry.ss + its whole import closure to a
# single tree-shaken whole-program object (hw-whole.so), the shared input
# for BOTH the open-world boot (petite+scheme+hw-whole) and the
# closed-world boot (petite+hw-whole).
set -euo pipefail
CHEZ=/opt/homebrew/bin/chez
HERE="$(cd "$(dirname "$0")" && pwd)"
cd "$HERE"

echo "== whole-program compile (closure incl. AppKit facade) =="
/usr/bin/time -l "$CHEZ" --quiet 2>compile.time <<'EOF'
(generate-wpo-files #t)
(compile-imported-libraries #t)
(library-directories "chez-tree")
(printf "compiling hw-entry.ss (this compiles the whole import closure)...\n")
(flush-output-port (current-output-port))
(compile-program "hw-entry.ss")
(printf "compile-program done; running compile-whole-program...\n")
(flush-output-port (current-output-port))
(compile-whole-program "hw-entry.wpo" "hw-whole.so" #f)
(printf "wrote hw-whole.so\n")
EOF
echo "== done; sizes =="
ls -la hw-whole.so hw-entry.so 2>/dev/null || true
tail -5 compile.time
