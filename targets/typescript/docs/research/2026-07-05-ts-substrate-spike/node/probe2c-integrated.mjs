// probe2c-integrated.mjs — the integrated model: NSApplication.run() genuinely
// owns thread 0, and a main-runloop timer pumps libuv (uv_run NOWAIT) so Node's
// loop stays serviced. This is the "runloop integration" mechanism, using the
// stable N-API hook napi_get_uv_event_loop to reach Node's uv loop.
//
// Measures, WHILE NSApp.run() blocks the JS thread:
//   - Node setInterval ticks  (proves libuv timers fire under NSApp.run)
//   - tsfn callbacks delivered (proves bg->main bounce reaches JS under NSApp.run)
import { createRequire } from "node:module";
const require = createRequire(import.meta.url);
const b = require("../addon.node");

let nodeTicks = 0, cbs = 0;
b.registerCallback((token) => { cbs++; });

// These are scheduled on Node's libuv loop; they can only fire if libuv is being
// pumped from within the Cocoa runloop while NSApp.run() owns thread 0.
const iv = setInterval(() => { nodeTicks++; b.fireBg(nodeTicks); }, 100);

b.setupApp();
console.log("  calling run_app_integrated(2.0s) — NSApp.run() owns thread 0, uv pumped every 4ms...");
b.runAppIntegrated(2.0);          // blocks inside NSApp.run() for ~2s
clearInterval(iv);

console.log(`\n  Node setInterval ticks DURING NSApp.run(): ${nodeTicks}`);
console.log(`  tsfn callbacks delivered DURING NSApp.run(): ${cbs}`);
const green = nodeTicks >= 10 && cbs >= 10;   // ~20 expected over 2s @100ms
console.log(green
  ? "PROBE 2c: GREEN (NSApp.run owns thread 0 AND libuv serviced — full coexistence)"
  : "PROBE 2c: RED (libuv not serviced under NSApp.run)");
process.exit(green ? 0 : 1);
