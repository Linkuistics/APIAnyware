# TypeScript runloop-integration spike — findings

**Date:** 2026-07-05
**Leaf:** `libuv-runloop-primacy-spike-k6` (grove `add-typescript-target-language`)
**Decision framing:** ADR-0054 §3 settled the **polarity** (2c: the native Cocoa runloop is
authoritative and pumps Node's libuv loop as a guest, in `kCFRunLoopCommonModes`); the
`libuv-runloop-primacy-research-k5` analysis + **ADR-0056** pre-judged the **mechanism** — Electron's
helper-thread shape (c) as the proven baseline, single-thread `CFFileDescriptor` (b) *"preferred iff
the spike proves it fires on the kqueue `uv_backend_fd`."* This spike de-risks that mechanism
first-hand on arm64, selects (b)/(c), and reconciles ADR-0056 §2 in place. Throwaway-harness
discipline, exactly like `ts-substrate-spike-k3`: a minimal napi-rs addon + Swift bridge + a small
v8 pump shim, **no emitter, no IR, no build integration** — evidence, not a binding.

**Host / toolchain (cited at the decision site, per `driving.md`):**
macOS 26.5.1 (build 25F80), arm64 (Apple Silicon). Swift 6.3.3 (swiftlang-6.3.3.1.3, Target
arm64-apple-macosx26.0). Node v26.4.0 — **libuv 1.52.1** linked as a shared dylib
(`/opt/homebrew/opt/libuv/lib/libuv.1.dylib`), V8 in `libnode.147.dylib`. **Deno 2.9.1** (stable,
aarch64). Rust/cargo 1.93.1. napi-rs: `napi` 2.16.17 · `napi-derive` 2.16.13 · `napi-build` 2.3.2 ·
`cc` for the v8 shim. Node C++ headers from `<node_prefix>/include/node` (`v8.h` needs C++20).

**Repro:** this directory. `bash build.sh` builds the Swift bridge dylib (`swift/libtsrlbridge.dylib`,
the two mechanisms + nested-runloop trigger), the v8 pump shim (`addon/pump_shim.cc`), and the
napi-rs addon (`addon/`, copied to `addon.node`). `bash run.sh` runs every acceptance test. libuv
embedding symbols and `objc_msgSend` are resolved via `dlsym(RTLD_DEFAULT, …)` (both are loaded into
the host process); V8/Node symbols in the shim resolve at load time via napi_build's
`-undefined dynamic_lookup`. Throwaway spike code; the point is evidence, not a binding.

---

## Verdict

**The decisive unknown is resolved GREEN, but it does not, alone, flip the decision.**

1. **CFFileDescriptor DOES fire on the kqueue `uv_backend_fd` on macOS 26.5.1** (test 6). The
   "dead kqueue fd" fear — libuv's *"a kqueue fd in another kqueue pollset … never generates
   events"* warning, the single gap ADR-0056 said k6 must close — **is disproven on current macOS.**
   Mechanism (b) is therefore **viable**, not dead-on-arrival.

2. **Both mechanisms pass every acceptance test** — nested-runloop survival (the 2c decisive
   criterion), the facilities constraint, idle behaviour, and clean teardown — first-hand on arm64.

3. **The dominant risk turned out NOT to be the fd-wake mechanism at all**, but the **embedding
   entry architecture + pump body**, a concern **shared by (b) and (c)** and therefore *orthogonal*
   to the (b)-vs-(c) choice (findings A–C below). This is the real gating work for the runtime
   build leaf.

4. **Decision: ship (c), the helper-thread mechanism** (the ADR baseline). "Fires" proved (b)
   *possible*, not *better*: (b)'s only practical edge over (c) — idle power — is **marginal**
   (both idle at ~1 pass; test 4), while (b) depends on **undocumented** CFFileDescriptor-on-kqueue
   behaviour for the core event-loop integration — a longevity risk that cuts against the target's
   durability-first philosophy (D1), which (c) avoids by using only documented primitives (`poll` +
   `uv_backend_fd`/`uv_backend_timeout` + `CFRunLoopSource`). This **refines** ADR-0056 §2's original
   "fires → (b) ships" rule: fires is necessary but not sufficient. **(b) is retained as a
   documented future optimisation** now that the dead-fd blocker is cleared.

5. **Deno leg (as predicted):** the libuv embedding API is **absent** on Deno 2.9.1 (the integration
   does not port); the tsfn bounce + dispatch **do** port. Confirms the k5 source-level finding
   first-hand.

---

## Acceptance tests (each first-hand, arm64)

### Test 6 — CFFileDescriptor viability (the decider)  ·  GREEN — fd FIRES

**Claim under test:** does a `CFFileDescriptor` registered on libuv's kqueue `uv_backend_fd`
actually fire on current macOS? Strict probe: mechanism (b), **no synthetic pinger, no timers** —
the only loop-wake sources are real libuv threadpool completions.

```
stats: uv_run passes=5  fd_fires=4  timer_fires=1
crypto.pbkdf2 delivered under NSApp.run(): true (19ms)
fs.readFile delivered under NSApp.run(): true (32ms)
CFFileDescriptor fires on the kqueue uv_backend_fd: YES
```

`fd_fires > 0` from **real threadpool completions** (not synthetic pokes) is the proof: the
CoreFoundation path *does* receive events from the kqueue backend fd on macOS 26.5.1. Repeatable
across runs (also observed `fd_fires=28–30` when driven by a 50 ms `uv_async_send` pinger). **The
decisive gap ADR-0056 flagged is closed: (b) is viable.**

> Caveat recorded honestly: no Apple or libuv *primary source* documents this behaviour as
> contractual. It works on 26.5.1; nothing guarantees it across future macOS releases. This is the
> durability argument in the decision above, not an observed failure.

### Test 3 — Nested-runloop survival (the 2c decisive criterion)  ·  GREEN + CONTROL GREEN

The direct first-hand test of ADR-0054 §3 / ADR-0056 §1. A background pinger generates libuv
wake-ups while the main thread enters a **nested** `CFRunLoopRunInMode(NSEventTrackingRunLoopMode,
1.0s)` — reproducing AppKit's modal/menu/resize nested runloops. uv_run passes *during* the nested
window are counted.

| mechanism · mode | passes during 1.0 s nested runloop | result |
|---|--:|---|
| (c) helper · **commonModes** | **17** | GREEN — libuv serviced across the nested mode |
| (c) helper · defaultMode (CONTROL) | **0** | GREEN — **starved**, as predicted |
| (b) cffd · **commonModes** | **17** | GREEN |
| (b) cffd · defaultMode (CONTROL) | **0** | GREEN — starved |

This is the k5 analysis's *decisive measured criterion*, now confirmed first-hand: a source in
`kCFRunLoopCommonModes` keeps firing through AppKit's nested runloops; a **default-mode-only source
is starved (0 passes)** — exactly the 2b failure that made 2c the polarity. The
`kCFRunLoopCommonModes` requirement (ADR-0056 §1) is a **correctness invariant**, now demonstrated,
not asserted. (Mode membership is a CFRunLoop property, so it holds identically for both mechanisms.)

### Test 2 — Facilities not broken (the governing constraint)  ·  GREEN (libuv-driven) + one caveat

Under `NSApp.run()` with (c) pumping the main loop as a guest:

```
worker_threads:      sum=499500 (expect 499500)  delivered @102ms   GREEN
threadpool (pbkdf2): delivered @101ms                                GREEN
setTimeout accuracy: (target→actual ms) 100→173, 250→325, 500→575    GREEN
setImmediate:                                                        GREEN
stale-timeout (timer added after a quiescent gap must still fire):   GREEN — fired
pump passes=6  (no busy-spin: the loop slept between deadlines)
```

Every facility the constraint names — `worker_threads` (own thread, own loop, untouched),
the libuv **threadpool** (completion delivered on the loop thread with ~100 ms latency, i.e. the
pbkdf2 compute time itself), timer accuracy, `setImmediate`, and the **stale-`uv_backend_timeout`
case** (a timer added after a gap still fires — the lock-step (c) self-corrects because the helper
re-reads `uv_backend_timeout` after every `uv_run` pass) — is **preserved**. Identical GREEN for (b).

**Caveat (a first-class finding — see C below):** *pure* Promise / `await` / `process.nextTick`
chains that touch no libuv handle **stall** while a **blocking napi call (`runApp`) is on the
stack**, because V8 suppresses the microtask checkpoint inside a synchronous native callback. This
is an **entry-architecture** limitation of the *spike harness* (it calls a blocking `runApp()` from
JS), **not** of either mechanism, and **not** a (b)-vs-(c) differentiator. The production runtime
avoids it by owning thread 0 natively with no ambient blocking JS call (the Electron model). All
work with a libuv handle of its own (timers, I/O, threadpool, worker messages) is unaffected.

### Test 4 — Idle behaviour (busy-poll eliminated)  ·  GREEN

Genuinely quiescent `NSApp.run(2.0s)` — no timers, no I/O, no pinger:

| mechanism | uv_run passes in 2 s idle | process CPU |
|---|--:|--:|
| (c) helper-thread | **1** (helper blocked in `poll`) | 41.8 ms |
| (b) CFFileDescriptor | **1** (runloop slept) | 41.2 ms |
| (3) 4 ms-poll baseline (probe 2c) | **514** (~250 wakes/s) | 55.7 ms |

Both event-driven mechanisms let the runloop sleep — the busy-poll is eliminated (1 pass vs the
baseline's 514). The CPU delta is modest over a 2 s window (fixed AppKit/setup overhead dominates),
but the **pass count is the clean signal**: (c)/(b) do essentially nothing when idle, the 4 ms poll
wakes hundreds of times — exactly the App-Nap anti-pattern Apple's energy guide warns against.
Notably **(c) does not busy-spin when idle** (the ~50 k spins seen mid-investigation were a
*symptom* of the undrained-immediate pathology of finding C, not steady-state behaviour).

### Test 5 — Teardown (no deadlock)  ·  GREEN

The non-obvious trap (ADR-0056 §4): (c)'s helper may be blocked on **either** the semaphore **or**
`poll(uv_backend_fd, timeout=-1)`; teardown must wake it from **both** (`uv_sem_post` **and**
`uv_async_send`) before `uv_thread_join`, else join deadlocks. With a 4 s watchdog:

```
(c) helper-thread: teardown returned in 0.1ms (helper joined, no deadlock)   GREEN
(b) cffd:          teardown returned in 0.0ms (no thread to join)            GREEN
```

The **double-wake-before-join** works: a helper asleep in `poll` is woken by the `uv_async_send`,
one asleep on the semaphore by the `uv_sem_post`, so `pthread_join` always returns.

### Deno leg — embedding API absent, tsfn ports (as predicted)

| runtime | `uv_backend_fd` | `uv_backend_timeout` | `uv_run` | `uv_loop_alive` | tsfn bounce |
|---|:-:|:-:|:-:|:-:|:-:|
| Node v26.4.0 (control) | ✓ | ✓ | ✓ | ✓ | GREEN [1,2,3] |
| **Deno 2.9.1** | ✗ | ✗ | ✗ | ✗ | GREEN [1,2,3] |

First-hand confirmation of the k5 source-level finding: Deno's napi shim **omits** the libuv
embedding API, so the runloop-pumps-Node integration **does not port to Deno as-is** (expected RED
for the integration); the `napi_threadsafe_function` bounce + dispatch **do** port (GREEN). Probed
with a bare `dlsym` (`aw_rl_has_symbol`); `start()` is *not* called on Deno — its missing-symbol path
`fatalError`s by design, which is itself the RED. Fed to `project_native_runloop_authoritative`.

---

## Shared pump-body findings (both mechanisms) — the real gating work

These three surfaced *while making either mechanism work* and are **independent of the (b)-vs-(c)
choice**. They are the substantive de-risking result of this spike and the runtime build leaf's
principal risk. Each corrects a way the substrate-spike probe 2c "worked by accident" (it exercised
only `setInterval` + tsfn, never `setImmediate`, promises, or real workloads).

**A. The pump MUST wrap `uv_run` in a `v8::HandleScope`.** A bare `uv_run(UV_RUN_NOWAIT)` driven
from a CFRunLoop callback **crashes fatally** in `node::Environment::CheckImmediate`
(`v8::ToLocalChecked` on an empty `MaybeLocal`) the first time JS calls `setImmediate` — there is no
active `HandleScope`. Node's own `SpinEventLoop` and Electron's `UvRunOnce` run `uv_run` inside
`HandleScope` + `Context::Scope`. napi's public surface exposes neither the scope entry adequately
nor (B); the spike adds a **~15-line C++ shim** (`pump_shim.cc`) resolving V8 symbols against
`libnode`. **Consequence for ADR-0056 §Consequences:** the addon's pump is not "call `uv_run`"; it
is "reproduce Node's loop-iteration body," and needs Node's C++ embedding / V8 primitives, not napi
alone.

**B. `NSApp.run()` must be entered at the TOP LEVEL, never nested inside Node's `uv_run`.** Entering
`NSApp.run()` from within a Node callback (e.g. a `setImmediate`) puts the pump's `uv_run(NOWAIT)`
**nested inside Node's own `uv_run(DEFAULT)`** still on the stack — the forbidden non-reentrant
`uv_run` the k5 analysis flagged. It corrupts Node's immediate queue (`Cannot read properties of
undefined (reading '_idleNext')`) on any real `setImmediate` workload. The production model is the
inverse — **AppKit owns thread 0 from the start; libuv is pumped as a guest, never via a nested
`uv_run`** — which is also the ADR-0054 §3 polarity.

**C. Pure microtask / `await` / `nextTick` work cannot drain while a blocking napi call holds the
stack.** Even with the correct scoped pump (A) and top-level entry (B), a `PerformMicrotaskCheckpoint`
is a **no-op** here: measured `MicrotasksScope::GetCurrentDepth() == 0` and policy `kExplicit`, yet
the checkpoint does not run — V8 keeps a **microtask suppression** active because a synchronous C++
API callback (`runApp`) is on the stack (microtasks are meant to run only at the JS boundary).
libuv-driven callbacks (timers, I/O, threadpool, worker messages) still run — only work with **no
libuv handle of its own** is deferred until the ambient call returns. **The fix is architectural,
not mechanical:** the runtime must let the native side own `main()` with Node embedded and pumped
from the top of the runloop with **no ambient blocking JS call** — precisely why Electron/NativeScript
own `main` natively (`NSApplicationMain`) rather than calling a blocking `run()` from JS. A
`node app.js` that calls a blocking `runApp()` is the wrong shape.

Together A–C say the mechanism (fd-wake) was never the hard part; **the embedding contract is** —
and it is the same contract for (b) and (c).

---

## The (b)-vs-(c) decision, weighed

| criterion | (c) helper-thread | (b) CFFileDescriptor |
|---|---|---|
| fires / services libuv under `NSApp.run()` | ✓ (proven at Electron scale) | ✓ **fd fires on kqueue backend fd (test 6)** |
| survives AppKit nested runloops (commonModes) | ✓ 17/1 s | ✓ 17/1 s |
| facilities preserved (worker/threadpool/timers) | ✓ | ✓ |
| idle — busy-poll eliminated | ✓ (1 pass) | ✓ (1 pass) |
| clean teardown, no deadlock | ✓ (double-wake-before-join) | ✓ (nothing to join) |
| primitives used | **documented, stable** (`poll`, `uv_backend_fd/timeout`, `CFRunLoopSource`) | relies on **undocumented** CFFileDescriptor-on-kqueue behaviour |
| proven in production | **Electron / NodeGui / yode, at scale** | no shipping precedent found |
| complexity | a helper thread + lock-step semaphore | single-thread, but a one-shot re-enable + observer-re-armed timer for non-I/O work |

Both clear every acceptance bar. (b)'s theoretical advantages — single-thread, sleeps when idle —
are real but **matched by (c) in practice** (test 4: both idle at 1 pass). Against that marginal
edge, (b) stakes the target's **core event-loop integration** on CFFileDescriptor firing on a kqueue
fd — behaviour that **works on 26.5.1 but no primary source guarantees**, and that libuv explicitly
warns is platform-dependent. For a binding meant to outlive OS releases (the same durability
philosophy that chose N-API for engine-agnosticism, D1), that is the wrong thing to depend on when a
**proven, fully-documented** alternative (c) exists at equal measured cost.

**→ Ship (c).** Keep (b) documented as a viable future optimisation (the dead-fd fear is cleared),
to revisit only if idle-power measurements on the *real* runtime — under the correct entry
architecture (finding B/C) — show a material advantage worth the durability risk.

---

## Findings adopted (forward pointers)

- **ADR-0056 §2 reconciled in place** (edit, not supersede): mechanism decided = **(c) helper-thread
  shape**; records that k6 proved CFFileDescriptor fires on the kqueue `uv_backend_fd` (clearing the
  dead-fd risk, so (b) is a viable future optimisation), and that (c) ships on durability +
  proven-at-scale grounds. §Consequences gains findings A–C (scoped pump; top-level entry;
  microtask-suppression → native-owns-main entry architecture) as the runtime build leaf's gating
  work.
- **`typescript` glossary entry (`CONTEXT.md`)** updated: mechanism no longer "(b)/(c) pending k6" —
  (c) decided; the entry-architecture requirement noted.
- **`project_native_runloop_authoritative` grove** inherits: the Deno embedding-API-absent
  confirmation, and the entry-architecture principle (native owns `main`; pump at the top of the
  runloop with no ambient blocking JS call; the pump reproduces Node's loop body — scope +
  microtask checkpoint — not just `uv_run`).

## No-source-found / honesty notes

- No Apple or libuv primary source documents `CFFileDescriptor` firing on a kqueue `uv_backend_fd`
  as contractual; the GREEN in test 6 is **empirical on macOS 26.5.1**, not a guarantee — the crux of
  the durability argument for (c).
- The spike harness enters `NSApp.run()` via a **blocking napi call**, which is *not* the production
  entry architecture (finding C). Consequences that depend on entry shape (pure-microtask draining;
  fs/promises multi-step chains) are reported against that harness and flagged; libuv-handle-backed
  facilities are architecture-independent and pass.
- Deno leg probed by `dlsym` presence + tsfn delivery; the full mechanism was **not** run on Deno
  (its missing-symbol path `fatalError`s by design — that *is* the RED).
