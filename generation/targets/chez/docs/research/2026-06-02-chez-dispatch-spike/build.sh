#!/usr/bin/env bash
# Build the chez dispatch/marshalling spike dylib. THROWAWAY.
set -euo pipefail
cd "$(dirname "$0")"

FFI_PREFIX="$(brew --prefix libffi 2>/dev/null || echo /opt/homebrew/opt/libffi)"

clang -dynamiclib -fobjc-arc -O2 \
  -I"${FFI_PREFIX}/include" \
  -o libchezspike.dylib \
  spike.m \
  -L"${FFI_PREFIX}/lib" -lffi \
  -framework Foundation

echo "built libchezspike.dylib"

# Foreign-thread probe dylib. -undefined dynamic_lookup so Sactivate_thread /
# Sdeactivate_thread resolve against the chez executable at load time.
clang -dynamiclib -O2 -o libthreadprobe.dylib callback_thread.m \
  -framework Foundation -undefined dynamic_lookup
echo "built libthreadprobe.dylib"
