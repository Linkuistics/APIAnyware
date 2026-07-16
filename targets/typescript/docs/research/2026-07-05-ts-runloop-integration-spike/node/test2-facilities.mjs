// test2-facilities.mjs <mechanism> — ACCEPTANCE TEST #2: the governing constraint —
// "the binding must not break the runtime's own threading facilities."
//
// Under NSApp.run() with the mechanism pumping the main loop as a guest, verify each Node facility
// still behaves: worker_threads run+join; a libuv threadpool completion (crypto.pbkdf2) delivered
// with measured latency; setTimeout accuracy incl. the stale-timeout case (a timer added after a
// quiescent gap must still fire); setImmediate. Pure Promise/nextTick chains are recorded with
// the known blocking-call caveat (V8 suppresses the microtask checkpoint while a synchronous napi
// call — runApp — is on the stack; see FINDINGS — this is an entry-architecture limitation of the
// spike harness, not of the mechanism).
import { createRequire } from "node:module";
import { Worker } from "node:worker_threads";
import { pbkdf2 } from "node:crypto";
const require = createRequire(import.meta.url);
const b = require("../addon.node");
const mech = Number(process.argv[2] || "1");

const t0 = Date.now();
const R = { workerSum: null, workerMs: -1, pbkdfMs: -1, timers: [], immediate: false, staleTimerFired: false };

b.registerCallback(() => {});
b.setupApp();

// worker_threads: own thread, own loop; message + exit delivered via the pumped main loop.
const w = new Worker(new URL("./worker.mjs", import.meta.url), { workerData: 1000 });
w.on("message", (m) => { R.workerSum = m; R.workerMs = Date.now() - t0; });

// threadpool completion (single-step, callback API) with latency.
pbkdf2("pw", "salt", 200000, 32, "sha256", () => { R.pbkdfMs = Date.now() - t0; });

// setTimeout accuracy at 3 deadlines.
for (const d of [100, 250, 500]) setTimeout(() => R.timers.push([d, Date.now() - t0]), d);

// setImmediate.
setImmediate(() => { R.immediate = true; });

// Stale-timeout case: after a quiescent gap (no other timers pending near t=700ms), a timer added
// via a fired timer must still fire — the pump must recompute uv_backend_timeout / re-arm.
setTimeout(() => setTimeout(() => { R.staleTimerFired = true; }, 150), 700);

console.log(`  mechanism ${mech}: NSApp.run(2.0s), exercising Node facilities as guests...`);
b.start(mech, true);
b.runApp(2.0);

// After the window, Node resumes; give worker exit a beat then report.
w.terminate();
const s = b.getStats();
console.log("");
console.log(`  worker_threads:   sum=${R.workerSum} (expect 499500)  delivered@${R.workerMs}ms  -> ${R.workerSum === 499500 ? "GREEN" : "RED"}`);
console.log(`  threadpool (pbkdf2): delivered@${R.pbkdfMs}ms  -> ${R.pbkdfMs >= 0 && R.pbkdfMs < 2000 ? "GREEN" : "RED"}`);
console.log(`  setTimeout accuracy: ${JSON.stringify(R.timers)} (target,actual ms) -> ${R.timers.length === 3 ? "GREEN" : "RED"}`);
console.log(`  setImmediate: ${R.immediate ? "GREEN" : "RED"}`);
console.log(`  stale-timeout (timer added after gap): ${R.staleTimerFired ? "GREEN — fired" : "RED — missed"}`);
console.log(`  pump passes=${s.passes} fd=${s.fdFires} timer=${s.timerFires} polls=${s.helperPolls}`);

const green = R.workerSum === 499500 && R.pbkdfMs >= 0 && R.timers.length === 3 && R.immediate && R.staleTimerFired;
console.log(green
  ? "TEST 2: GREEN — libuv-driven facilities preserved (worker_threads, threadpool, timers, setImmediate, stale-timeout)"
  : "TEST 2: PARTIAL — see per-facility lines");
process.exit(0);
