// probe2b-pump.mjs — co-operative pump model: Node's libuv loop stays PRIMARY;
// Cocoa events are drained from a JS timer (aw_ts_pump). No nested uv_run, so no
// reentrancy hazard. Proves a Cocoa window coexists with a live Node loop on thread 0.
import { createRequire } from "node:module";
const require = createRequire(import.meta.url);
const b = require("../addon.node");

let cocoaEvents = 0, nodeTicks = 0, cbs = 0;

b.registerCallback((token) => { cbs++; });

const onMain = b.setupApp();
console.log(`  setupApp onMain=${onMain} (window should be visible)`);

// Node loop primary: drain Cocoa events every 8ms.
const pumpTimer = setInterval(() => { cocoaEvents += b.pump(50); }, 8);
// Independent proof Node's loop is alive and doing normal work.
const workTimer = setInterval(() => {
  nodeTicks++;
  b.fireBg(nodeTicks);          // exercise the tsfn bounce with the window up
}, 100);

setTimeout(() => {
  clearInterval(pumpTimer);
  clearInterval(workTimer);
  console.log(`  Cocoa events drained: ${cocoaEvents}`);
  console.log(`  Node timer ticks during window-up: ${nodeTicks} (libuv alive: ${nodeTicks > 0})`);
  console.log(`  tsfn callbacks delivered with window up: ${cbs}`);
  const green = onMain && nodeTicks > 0 && cbs > 0;
  console.log(green ? "PROBE 2b: GREEN (coexistence, Node loop primary)" : "PROBE 2b: RED");
  process.exit(green ? 0 : 1);
}, 1800);
