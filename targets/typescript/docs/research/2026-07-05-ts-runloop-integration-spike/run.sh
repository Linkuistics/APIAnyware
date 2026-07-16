#!/usr/bin/env bash
# run.sh — reproduce the runloop-integration spike. Builds then runs every acceptance test.
# The tests flash a Cocoa window and grab focus for ~1-2s each (autoquit under NSApp.run()).
# mechanism ids: 1 = (c) helper-thread, 2 = (b) CFFileDescriptor, 3 = 4ms-poll baseline (probe 2c).
set -uo pipefail
cd "$(dirname "$0")"

./build.sh

run() { echo; echo "=================== $1 ==================="; shift; "$@"; echo "exit=$?"; }

# TEST 6 — DECISIVE: does CFFileDescriptor fire on the kqueue uv_backend_fd? (selects b vs c)
run "TEST 6  CFFileDescriptor viability"        node node/test6-cffd-viability.mjs

# TEST 3 — the 2c decisive criterion: commonModes survives nested runloop; default-mode starved.
run "TEST 3  nested survival (c) commonModes"   node node/test3-nested.mjs 1 1
run "TEST 3  nested CONTROL  (c) defaultMode"   node node/test3-nested.mjs 1 0
run "TEST 3  nested survival (b) commonModes"   node node/test3-nested.mjs 2 1

# TEST 2 — governing constraint: facilities preserved (worker_threads/threadpool/timers/immediate).
run "TEST 2  facilities (c)"                     node node/test2-facilities.mjs 1
run "TEST 2  facilities (b)"                     node node/test2-facilities.mjs 2

# TEST 4 — idle: busy-poll eliminated (c)/(b) vs the 4ms baseline.
run "TEST 4  idle (c)"                           node node/test4-idle.mjs 1
run "TEST 4  idle (b)"                           node node/test4-idle.mjs 2
run "TEST 4  idle BASELINE 4ms poll"            node node/test4-idle.mjs 3

# TEST 5 — teardown: no deadlock (double-wake-before-join).
run "TEST 5  teardown (c)"                       node node/test5-teardown.mjs 1
run "TEST 5  teardown (b)"                       node node/test5-teardown.mjs 2

# Deno leg — embedding API absent on Deno (does not port); tsfn ports. Node control first.
run "DENO LEG  Node control"                     node  node/deno-leg.mjs
run "DENO LEG  Deno"                             deno  run -A node/deno-leg.mjs

# Diagnostics that evidence the shared pump-body findings (scope crash / nested-uv_run / microtask
# suppression under the blocking-call harness). Not pass/fail — see FINDINGS.md.
run "DIAG  microtask/await/immediate chains (c)" node node/debug-chains.mjs 1
run "DIAG  single vs multi-step I/O (c)"         node node/debug-io.mjs 1
run "DIAG  re-wake head-to-head (b) vs (c)"      node node/test-io-compare.mjs 2
echo
echo "See FINDINGS.md for the reading of every result and the (b)-vs-(c) decision."
