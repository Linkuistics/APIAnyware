// debug-io.mjs <mechanism> — isolate single-step vs multi-step threadpool completions,
// with error capture and helper busy-spin instrumentation.
import { createRequire } from "node:module";
import { readFile } from "node:fs/promises";
import { pbkdf2 } from "node:crypto";
import * as fs from "node:fs";
const require = createRequire(import.meta.url);
const b = require("../addon.node");
const mech = Number(process.argv[2] || "2");

const ev = [];
const t0 = Date.now();
const mark = (s) => ev.push(`${s}@${Date.now() - t0}`);

b.registerCallback(() => {});
b.setupApp();
b.start(mech, true);

const fd = fs.openSync(new URL(import.meta.url), "r");
const buf = Buffer.alloc(64);

setImmediate(() => {
  // single-step threadpool ops (callback API)
  pbkdf2("pw", "s", 100000, 16, "sha256", (e) => mark(e ? "pbkdf2ERR" : "pbkdf2"));
  fs.read(fd, buf, 0, 64, 0, (e) => mark(e ? "fsReadERR" : "fsRead"));       // single-step
  fs.stat(new URL(import.meta.url), (e) => mark(e ? "statERR" : "stat"));    // single-step
  // multi-step promise chain
  readFile(new URL(import.meta.url)).then(() => mark("readFile")).catch((e) => mark("readFileERR:" + e.code));
});
setImmediate(() => b.runApp(1.5));

setTimeout(() => {
  const s = b.getStats();
  console.log(`\n  mech=${mech} passes=${s.passes} fd=${s.fdFires} timer=${s.timerFires} polls=${s.helperPolls} t0polls=${s.timeoutZeroPolls} lastTimeout=${s.lastTimeout}`);
  console.log("  events:", JSON.stringify(ev));
  fs.closeSync(fd);
  b.teardown();
  process.exit(0);
}, 1700);
