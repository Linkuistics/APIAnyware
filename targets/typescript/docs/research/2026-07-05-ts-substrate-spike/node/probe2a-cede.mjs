// probe2a-cede.mjs — the "cede thread 0" model: Node calls NSApplication.run()
// on its own main thread. Questions:
//   (1) does the window draw + does the Cocoa runloop actually run? (autoquit fires)
//   (2) does Node's libuv loop still get serviced while NSApp.run owns thread 0?
import { createRequire } from "node:module";
const require = createRequire(import.meta.url);
const b = require("../addon.node");

let nodeTimerFired = false;
// Scheduled on Node's libuv loop; will only fire if libuv is pumped during NSApp.run.
setTimeout(() => { nodeTimerFired = true; console.log("  [node] libuv setTimeout(300ms) FIRED"); }, 300);

const onMain = b.setupApp();
console.log(`  setupApp onMain=${onMain}`);
console.log("  calling run_app(1.5s autoquit) — this BLOCKS Node's JS thread inside NSApp.run()...");

const t0 = Date.now();
b.runApp(1.5);                       // blocks here until NSApp.stop + autoquit
const dt = Date.now() - t0;

console.log(`\n  NSApp.run() returned after ${dt}ms`);
console.log(`  Cocoa runloop ran (autoquit fired -> we got here): GREEN`);
console.log(`  Node libuv timer fired DURING NSApp.run: ${nodeTimerFired ? "YES" : "NO"}`);
console.log(nodeTimerFired
  ? "  => coexistence WITHOUT integration (surprising)"
  : "  => libuv STALLS under cede — needs loop integration for Node timers/promises");
process.exit(0);
