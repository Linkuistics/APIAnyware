#!/usr/bin/env bash
# run.sh — reproduce the ts-substrate-spike probes. Builds then runs each probe.
# Probes 2a/2b/2c flash a Cocoa window and grab focus for ~1.5-2s each (autoquit).
set -uo pipefail
cd "$(dirname "$0")"

./build.sh

run() { echo; echo "=================== $1 ==================="; shift; "$@"; echo "exit=$?"; }

run "PROBE 1  dispatch (Node)"            node node/probe1.mjs
run "PROBE 3  threadsafe fn (Node)"       node node/probe3.mjs
run "PROBE 2a cede (Node)"                node node/probe2a-cede.mjs
run "PROBE 2b co-op pump (Node)"          node node/probe2b-pump.mjs
run "PROBE 2c integrated pump (Node)"     node node/probe2c-integrated.mjs
run "PROBE 4  Bun dispatch"               bun  node/probe1.mjs
run "PROBE 4  Bun threadsafe fn"          bun  node/probe3.mjs
echo
echo "PROBE 4  Bun integrated pump — expected RED (Bun lacks uv_run, issue #18546):"
bun node/probe2c-integrated.mjs 2>&1 | grep -iE "unsupported uv|panic|PROBE 2c" | head -3
echo
echo "(Deno leg not run: Deno not installed on this host.)"
