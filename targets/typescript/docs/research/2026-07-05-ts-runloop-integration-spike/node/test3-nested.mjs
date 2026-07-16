// test3-nested.mjs <mechanism> <commonModes 1|0> — ACCEPTANCE TEST #3, the direct test of the
// 2c decisive criterion (ADR-0054 §3 / ADR-0056 §1).
//
// AppKit routinely spins its OWN nested runloop on thread 0 (modal sessions, menu tracking,
// live-resize) in a NON-default mode. A libuv-servicing source in kCFRunLoopCommonModes keeps
// firing across those modes; a default-mode-only source is STARVED. We reproduce the nested
// runloop with CFRunLoopRunInMode(NSEventTrackingRunLoopMode, …) while a background pinger keeps
// generating libuv wake-ups, and measure uv_run passes DURING the nested window.
//
// commonModes=1 (the shipped config): passes keep incrementing across the nested window → SURVIVES.
// commonModes=0 (the CONTROL): passes FREEZE during the nested window → the documented 2b failure.
import { createRequire } from "node:module";
const require = createRequire(import.meta.url);
const b = require("../addon.node");
const mech = Number(process.argv[2] || "1");
const common = process.argv[3] !== "0";

b.registerCallback(() => {});
b.setupApp();
b.start(mech, common);
b.startPinger(50);                       // uv_async_send every 50ms → a libuv wake to service
b.scheduleNested(400, 0, 1.0);          // at +400ms, enter a 1.0s nested event-tracking runloop

const label = `${mech === 1 ? "(c) helper" : mech === 2 ? "(b) cffd" : "(3) 4ms"} · ${common ? "commonModes" : "defaultMode CONTROL"}`;
console.log(`  ${label}: NSApp.run(2.0s); nested event-tracking runloop at +0.4s for 1.0s...`);
b.runApp(2.0);
b.stopPinger();

const s = b.getStats();
const duringNested = Number(s.nestedEnd - s.nestedStart);
console.log(`\n  ${label}`);
console.log(`  uv_run passes total=${s.passes}; DURING the 1.0s nested runloop = ${duringNested}`);
// With a 50ms pinger, ~20 passes are expected across a 1.0s nested window if the source survives.
const survives = duringNested >= 8;
if (common) {
  console.log(survives
    ? "TEST 3: GREEN — commonModes source SURVIVES the nested runloop (libuv not starved)"
    : "TEST 3: RED — commonModes source was starved (unexpected)");
  process.exit(survives ? 0 : 1);
} else {
  console.log(!survives
    ? "TEST 3 CONTROL: GREEN — default-mode source is STARVED during the nested runloop (as predicted; proves the kCFRunLoopCommonModes requirement)"
    : "TEST 3 CONTROL: RED — default-mode source unexpectedly survived");
  process.exit(!survives ? 0 : 1);
}
