// test6-cffd-viability.mjs — THE DECISIVE TEST (ADR-0056 §2, acceptance test #6).
//
// Does a CFFileDescriptor actually fire on libuv's kqueue uv_backend_fd on current macOS?
// libuv warns "embedding a kqueue fd in another kqueue pollset … never generates events" on
// some platforms, and NO primary source confirms the CF path. This spike closes that gap.
//
// STRICT probe: mechanism (b) with NO synthetic pinger and NO timers — the ONLY loop-wake
// sources are real libuv threadpool completions (fs.readFile, crypto.pbkdf2). Their done-async
// makes the backend fd readable. If the CFFileDescriptor callback fires (stats.fd_fires>0) AND
// both completions are delivered under NSApp.run(), the kqueue fd is LIVE → (b) is VIABLE.
// If fd_fires stays 0 (the documented dead-fd failure), (b) is not viable → (c) ships.
//
// Entry sequencing (learned first-hand): let Node's bootstrap ticks drain before ceding
// thread 0 — enter NSApp.run() via setImmediate, schedule probes from within the loop.
import { createRequire } from "node:module";
import { readFile } from "node:fs/promises";
import { pbkdf2 } from "node:crypto";
const require = createRequire(import.meta.url);
const b = require("../addon.node");

let fsDelivered = false, fsMs = -1, pbkdfDelivered = false, pbkdfMs = -1;

b.registerCallback(() => {});
b.setupApp();
b.start(2, true);              // mechanism (b) CFFileDescriptor, commonModes — NO pinger

setImmediate(() => {
  const t0 = Date.now();
  // Pure threadpool I/O — the ONLY thing that can wake the loop now is the fd firing.
  readFile(new URL(import.meta.url)).then(() => { fsDelivered = true; fsMs = Date.now() - t0; });
  pbkdf2("pw", "salt", 200000, 32, "sha256", () => { pbkdfDelivered = true; pbkdfMs = Date.now() - t0; });
});

console.log("  mechanism (b) CFFileDescriptor; NO pinger, NO timers — pure threadpool wake.");
setImmediate(() => b.runApp(1.5));   // cede thread 0 after bootstrap ticks drain

// runApp blocks ~1.5s; both completions must arrive via the fd firing on the kqueue backend fd.
setTimeout(() => {
  const s = b.getStats();
  console.log(`\n  stats: uv_run passes=${s.passes}  fd_fires=${s.fdFires}  timer_fires=${s.timerFires}`);
  console.log(`  fs.readFile delivered: ${fsDelivered}${fsDelivered ? ` (${fsMs}ms)` : ""}`);
  console.log(`  crypto.pbkdf2 delivered: ${pbkdfDelivered}${pbkdfDelivered ? ` (${pbkdfMs}ms)` : ""}`);
  const fdFired = s.fdFires > 0;
  const viable = fdFired && fsDelivered && pbkdfDelivered;
  console.log("");
  console.log(`  CFFileDescriptor fires on the kqueue uv_backend_fd: ${fdFired ? "YES" : "NO"}`);
  console.log(viable
    ? "TEST 6: GREEN — (b) CFFileDescriptor is VIABLE on current macOS (kqueue fd is live)"
    : "TEST 6: RED — (b) not viable (dead kqueue fd); mechanism (c) helper-thread ships");
  b.teardown();
  process.exit(viable ? 0 : 1);
}, 1900);
