// worker.mjs — trivial worker_threads body: compute, post back, exit. Runs on its OWN thread
// with its OWN libuv loop (untouched by the main-loop pump) — the governing-constraint check.
import { parentPort, workerData } from "node:worker_threads";
let sum = 0;
for (let i = 0; i < workerData; i++) sum += i;
parentPort.postMessage(sum);
