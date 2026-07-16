// debug-chains.mjs <mechanism> — FAITHFUL production structure: AppKit owns thread 0 from the
// TOP LEVEL (no outer Node uv_run on the stack), libuv pumped as a guest. Schedule probes at
// top level, then cede thread 0 synchronously — the pump's uv_run(NOWAIT) is the ONLY uv_run,
// so no nested-uv_run reentrancy. Tests microtask/await/setImmediate/nextTick chains + fs.
import { createRequire } from "node:module";
import { readFile } from "node:fs/promises";
const require = createRequire(import.meta.url);
const b = require("../addon.node");
const mech = Number(process.argv[2] || "2");

const ev = [];
const t0 = Date.now();
const mark = (s) => ev.push(`${s}@${Date.now() - t0}`);

b.registerCallback(() => {});
b.setupApp();

// Schedule all probes at top level (queued before we cede thread 0).
let p = Promise.resolve();
for (let i = 0; i < 200; i++) p = p.then(() => {});
p.then(() => mark("microtaskChain200"));
(async () => { for (let i = 0; i < 200; i++) await Promise.resolve(); mark("awaitChain200"); })();
let n = 0;
const step = () => (++n < 200 ? setImmediate(step) : mark("immediateChain200"));
setImmediate(step);
let m = 0;
const tick = () => (++m < 200 ? process.nextTick(tick) : mark("nextTickChain200"));
process.nextTick(tick);
readFile(new URL(import.meta.url)).then(() => mark("readFile")).catch((e) => mark("readFileERR:" + e.code));

// A native watchdog would be ideal, but we simply report from a top-level timer that fires
// after the run window (scheduled here; it runs once NSApp.run returns and Node resumes).
setTimeout(() => {
  const s = b.getStats();
  console.log(`\n  mech=${mech} passes=${s.passes} fd=${s.fdFires} polls=${s.helperPolls} t0polls=${s.timeoutZeroPolls} lastTimeout=${s.lastTimeout}`);
  console.log("  events:", JSON.stringify(ev));
  b.teardown();
  process.exit(0);
}, 1700);

// Cede thread 0 to AppKit at the top level (no outer Node uv_run). Blocks ~1.5s.
b.start(mech, true);
b.runApp(1.5);
