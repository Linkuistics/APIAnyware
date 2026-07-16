// test4-idle.mjs <mechanism> — ACCEPTANCE TEST #4: idle behaviour (busy-poll eliminated).
//
// With the loop genuinely quiescent (no timers, no I/O, no pinger), an event-driven mechanism
// lets the runloop sleep — idle CPU ≈ 0. The 4ms-poll baseline (mechanism 3) wakes ~250×/s and
// burns CPU (Apple's App-Nap anti-pattern). We measure process CPU over a 2s idle NSApp.run().
import { createRequire } from "node:module";
const require = createRequire(import.meta.url);
const b = require("../addon.node");
const mech = Number(process.argv[2] || "1");
const name = mech === 1 ? "(c) helper-thread" : mech === 2 ? "(b) cffd" : "(3) 4ms-poll baseline";

b.registerCallback(() => {});
b.setupApp();
b.start(mech, true);                 // NO pinger, NO timers — genuinely idle

const c0 = process.cpuUsage();
console.log(`  ${name}: idle NSApp.run(2.0s), measuring CPU...`);
b.runApp(2.0);
const c = process.cpuUsage(c0);

const cpuMs = (c.user + c.system) / 1000;
const s = b.getStats();
console.log(`\n  ${name}`);
console.log(`  idle CPU over 2.0s wall = ${cpuMs.toFixed(1)}ms (user ${(c.user/1000).toFixed(1)} + sys ${(c.system/1000).toFixed(1)})`);
console.log(`  uv_run passes=${s.passes} helper_polls=${s.helperPolls} timer_fires=${s.timerFires}`);
const idleGood = cpuMs < 150;        // event-driven: tens of ms; 4ms poll: hundreds
console.log(mech === 3
  ? `TEST 4 BASELINE: reference busy-poll CPU (expect high) = ${cpuMs.toFixed(1)}ms`
  : (idleGood
      ? `TEST 4 ${name}: GREEN — idle CPU low (runloop sleeps; busy-poll eliminated)`
      : `TEST 4 ${name}: RED — idle CPU high (${cpuMs.toFixed(1)}ms)`));
b.teardown();
process.exit(0);
