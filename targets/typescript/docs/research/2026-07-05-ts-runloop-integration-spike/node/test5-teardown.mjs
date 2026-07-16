// test5-teardown.mjs <mechanism> — ACCEPTANCE TEST #5: clean shutdown, no deadlock.
//
// The non-obvious trap (ADR-0056 §4): mechanism (c)'s helper thread may be blocked on EITHER the
// semaphore OR poll(uv_backend_fd, timeout=-1). Teardown must wake it from BOTH (uv_sem_post AND
// uv_async_send) before uv_thread_join, else join deadlocks against a helper asleep in poll. We
// start the mechanism, run briefly, then teardown with a hard watchdog: if teardown hangs, the
// watchdog fires RED. A returning teardown within the budget = GREEN (helper joined cleanly).
import { createRequire } from "node:module";
const require = createRequire(import.meta.url);
const b = require("../addon.node");
const mech = Number(process.argv[2] || "1");
const name = mech === 1 ? "(c) helper-thread" : mech === 2 ? "(b) cffd" : "(3) baseline";

b.registerCallback(() => {});
b.setupApp();
b.start(mech, true);
b.startPinger(50);

// Watchdog: teardown MUST return well within this budget; a deadlocked join would blow it.
const watchdog = setTimeout(() => {
  console.log(`\nTEST 5 ${name}: RED — teardown DEADLOCKED (watchdog fired)`);
  process.exit(1);
}, 4000);

console.log(`  ${name}: NSApp.run(1.0s), then teardown with double-wake-before-join...`);
b.runApp(1.0);
b.stopPinger();

const t0 = process.hrtime.bigint();
b.teardown();                       // <-- the double-wake-before-join under test
const ms = Number(process.hrtime.bigint() - t0) / 1e6;
clearTimeout(watchdog);

console.log(`\n  teardown returned in ${ms.toFixed(1)}ms (helper joined, no deadlock)`);
console.log(`TEST 5 ${name}: GREEN — clean shutdown, no deadlock`);
process.exit(0);
