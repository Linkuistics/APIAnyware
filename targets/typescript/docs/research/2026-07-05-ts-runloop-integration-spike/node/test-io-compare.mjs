// test-io-compare.mjs <mechanism> — re-wake reliability head-to-head (the (b)-vs-(c) decider).
//
// Runs an identical wake-stressing workload under a chosen mechanism, with NO pinger and NO
// keep-alive timer, so delivery depends ENTIRELY on the mechanism re-firing on each libuv
// completion:
//   - a CHAIN of 6 sequential crypto.pbkdf2 (each scheduled from the previous callback) —
//     tests whether the mechanism reliably re-fires for back-to-back single-step completions;
//   - a multi-step fs.readFile (open→read→close) — tests re-fire across a completion chain
//     with threadpool gaps between steps.
// A mechanism that MISSES re-wakes will stall the chain mid-flight (deliveries << expected).
//
// argv: 1 = (c) helper thread, 2 = (b) CFFileDescriptor.
import { createRequire } from "node:module";
import { readFile } from "node:fs/promises";
import { pbkdf2 } from "node:crypto";
const require = createRequire(import.meta.url);
const b = require("../addon.node");

const mech = Number(process.argv[2] || "2");
const name = mech === 1 ? "(c) helper-thread" : "(b) CFFileDescriptor";
const CHAIN = 6;
const t0 = Date.now();
const chainMs = [];
let fsMs = -1;

b.registerCallback(() => {});
b.setupApp();
b.start(mech, true);

function runPbkdf(i) {
  pbkdf2("pw", "salt", 120000, 32, "sha256", () => {
    chainMs.push(Date.now() - t0);
    if (i + 1 < CHAIN) runPbkdf(i + 1);
  });
}

setImmediate(() => {
  runPbkdf(0);
  readFile(new URL(import.meta.url)).then(() => { fsMs = Date.now() - t0; });
});
setImmediate(() => b.runApp(2.0));

setTimeout(() => {
  const s = b.getStats();
  const fsOk = fsMs >= 0 && fsMs < 2000;
  const chainOk = chainMs.length === CHAIN && Math.max(...chainMs) < 2000;
  console.log(`\n  mechanism ${name}`);
  console.log(`  stats: passes=${s.passes} fd_fires=${s.fdFires} timer_fires=${s.timerFires} helper_polls=${s.helperPolls} source_fires=${s.sourceFires}`);
  console.log(`  pbkdf2 chain delivered in-window: ${chainMs.length}/${CHAIN}  times(ms)=[${chainMs.join(", ")}]`);
  console.log(`  fs.readFile delivered in-window: ${fsOk}  (${fsMs}ms)`);
  const green = fsOk && chainOk;
  console.log(green
    ? `RESULT ${name}: GREEN — every completion re-woke the loop promptly, no stall`
    : `RESULT ${name}: RED — re-wake MISSED; multi-step/chained I/O stalled under NSApp.run()`);
  b.teardown();
  process.exit(green ? 0 : 1);
}, 2100);
