// probe3.mjs — background-thread callback delivered to JS via napi_threadsafe_function.
// A GCD global-queue block (background thread) pokes the tsfn, which schedules the
// JS callback on Node's loop thread. Validates the D5 bounce on the normal Node loop
// (probe 2 tests it while NSApplication owns thread 0).
import { createRequire } from "node:module";
const require = createRequire(import.meta.url);
const b = require("../addon.node");

const N = 5;
const got = [];
const start = process.hrtime.bigint();

b.registerCallback((token) => {
  const dtus = Number(process.hrtime.bigint() - start) / 1000;
  got.push(token);
  console.log(`  JS callback fired: token=${token}  (+${dtus.toFixed(0)}us)`);
  if (got.length === N) {
    // GCD's *global* queue is concurrent — the N blocks run on different worker
    // threads, so arrival order is nondeterministic by design. Correctness here is
    // *delivery completeness*: every token delivered exactly once to JS, no crash.
    const complete = [...got].sort((a, b) => a - b).every((t, i) => t === i + 1);
    console.log(`\n  received ${got.length}/${N}; tokens=${JSON.stringify(got)} complete=${complete}`);
    console.log(`  (arrival order is nondeterministic — GCD global queue is concurrent)`);
    console.log(complete ? "PROBE 3: GREEN" : "PROBE 3: RED (missing/duplicate token)");
    process.exit(complete ? 0 : 1);
  }
});

// Fire N background dispatches. Each hops GCD-worker -> tsfn -> JS main.
for (let i = 1; i <= N; i++) b.fireBg(i);
console.log(`  fired ${N} background dispatches; waiting for JS callbacks...`);

// Safety valve: if the loop is starved and nothing arrives, fail loudly.
setTimeout(() => {
  console.log(`\n  TIMEOUT: only ${got.length}/${N} callbacks arrived`);
  console.log("PROBE 3: RED (callbacks did not arrive)");
  process.exit(1);
}, 4000);
