// deno-leg.mjs — runs on BOTH node and deno. Confirms first-hand the k5 source-level finding:
// Deno's napi shim OMITS the libuv embedding API (uv_backend_fd / uv_backend_timeout / uv_run /
// uv_loop_alive), so the runloop-pumps-Node integration does NOT port to Deno as-is (expected RED
// on Deno, present on Node). The tsfn bounce + dispatch DO port (expected GREEN on both).
//
// We probe with hasSymbol (a bare dlsym — no fatal path) and DO NOT call start() on Deno (its
// missing-symbol path fatalErrors by design).
import { createRequire } from "node:module";
const require = createRequire(import.meta.url);
const b = require("../addon.node");

const runtime = typeof Deno !== "undefined" ? `Deno ${Deno.version.deno}` : `Node ${process.version}`;
console.log(`  runtime: ${runtime}`);

const embed = ["uv_backend_fd", "uv_backend_timeout", "uv_run", "uv_loop_alive"];
const present = Object.fromEntries(embed.map((s) => [s, b.hasSymbol(s)]));
console.log("  libuv embedding symbols in-process:", JSON.stringify(present));
const allPresent = embed.every((s) => present[s]);
const nonePresent = embed.every((s) => !present[s]);

// tsfn bounce (background dispatch -> JS): expected to port to both runtimes.
let tsfnOk = false;
const N = 3, got = [];
b.registerCallback((token) => {
  got.push(token);
  if (got.length === N) {
    tsfnOk = [...got].sort((a, z) => a - z).every((t, i) => t === i + 1);
    finish();
  }
});
for (let i = 1; i <= N; i++) b.fireBg(i);

let done = false;
function finish() {
  if (done) return;
  done = true;
  const isDeno = typeof Deno !== "undefined";
  console.log(`  tsfn bounce (bg->JS): ${tsfnOk ? "GREEN — delivered " + JSON.stringify(got) : "RED"}`);
  if (isDeno) {
    console.log(nonePresent
      ? "DENO LEG: GREEN(as-predicted-RED-capability) — embedding API ABSENT on Deno (integration does NOT port); tsfn " + (tsfnOk ? "ports ✓" : "FAILED")
      : "DENO LEG: UNEXPECTED — some embedding symbols present on Deno");
  } else {
    console.log(allPresent
      ? "NODE CONTROL: GREEN — embedding API present on Node (integration is Node-capable)"
      : "NODE CONTROL: RED — embedding symbols missing on Node (unexpected)");
  }
  process.exit(0);
}
setTimeout(() => { console.log("  (tsfn timeout)"); finish(); }, 3000);
