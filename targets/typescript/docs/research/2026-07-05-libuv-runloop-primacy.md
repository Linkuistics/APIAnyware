# libuv ↔ macOS CFRunLoop primacy — analysis & production-mechanism recommendation

**Date:** 2026-07-05
**Leaf:** `libuv-runloop-primacy-research-k5` (grove `add-typescript-target-language`)
**Kind:** research + design (empowered to revise ADR-0054 §3 in place; produces the Q4
threading ADR, ADR-0056)
**Method:** four-angle primary-source fan-out — Electron source (`node_bindings*.cc`) +
Chromium message pump; libuv `test/test-embed.c` + `loop.rst`/`design.rst`/`async.rst` +
Node N-API docs + Deno `ext/napi` source; NodeGui/qode + NativeScript
(ios-jsc / ns-v8ios) source; Apple CFRunLoop / AppKit / CFFileDescriptor / Energy docs.
Every load-bearing claim carries a primary-source URL; each system carries a walk-away
check and a post-mortem; "no source found" is recorded as a finding.

---

## Bottom line

1. **Primacy: Model 2c (native Cocoa runloop authoritative) is CONFIRMED — now on a
   decisive measured criterion, not principle.** ADR-0054 §3 stands, edited in place to
   record *why*. The decisive fact: **AppKit routinely spins its own nested runloops on
   thread 0** (modal sessions, menu tracking, live-resize), during which a **Model 2b**
   libuv-primary manual event pump *never regains control* and libuv is starved. Model 2c
   survives because a runloop source registered in `kCFRunLoopCommonModes` keeps firing
   across those nested modes. This is routine UI (every right-click menu, every window
   resize), not an edge case.

2. **The governing constraint (user, 2026-07-05): the binding must not break the
   runtime's own threading facilities.** The goal is not "keep libuv ticking" but
   *preserve the runtime's entire concurrency model* — for Node: libuv timers, the libuv
   **threadpool** (fs/dns/crypto completions delivered on the loop thread), **`worker_threads`**,
   and the `nextTick`/microtask contract. This elevates from "does it tick" to "does every
   facility still behave," discriminates the mechanisms, and dictates the cross-target
   principle (below).

3. **Mechanism: the Q4 ADR mandates Electron's helper-thread shape (option c) as the
   proven baseline, and the k6 spike evaluates the single-threaded CFFileDescriptor shape
   (option b) head-to-head** — because (b) is simpler and more power-efficient *if* a
   `CFFileDescriptor` reliably fires on libuv's kqueue `uv_backend_fd`, which **no primary
   source confirms and libuv actively warns against**. Spike de-risks (b); the winner is
   production; (c) is the guaranteed fallback.

4. **Cross-target (scoping, not scope-creep): the embedding technique is Node-on-libuv-on-Unix.**
   Source-verified: Deno's `napi_get_uv_event_loop` returns a **shim** and does **not**
   implement `uv_backend_fd`/`uv_backend_timeout`/`uv_run` — so the technique **does not
   port to Deno as-is** (this *corrects* ADR-0054's "expected to port" note). Bun has no
   `uv_run` at all. Fed to the `project_native_runloop_authoritative` grove, not absorbed.

---

## Q1 — Primacy: 2b vs 2c, decided on criteria

The spike (`ts-substrate-spike-k3`) proved *both* polarities *run* in a trivial scenario
(2b: 17 ticks; 2c: 21 ticks). Tick-counting is not the criterion. The decisive question
is what happens under real AppKit behaviour and the runtime-facilities constraint.

### The decisive criterion: AppKit spins its own nested runloops on thread 0

AppKit does not merely "run an event loop you can pump manually." For several routine
interactions it **takes over thread 0 with its own nested runloop**, and returns control
only when the interaction ends:

- **Modal sessions / dialogs.** `NSApplication.runModal(for:)` — Apple: *"This method runs
  a modal event loop for the specified window synchronously … While the app is in that
  loop … **It also does not perform any tasks (such as firing timers) that are not
  associated with the modal run loop.**"*
  ([runModal(for:)](https://developer.apple.com/documentation/appkit/nsapplication/runmodal(for:)))
  `NSAlert.runModal()` is an app-modal dialog
  ([NSAlert.runModal](https://developer.apple.com/documentation/appkit/nsalert/runmodal())).
- **Menu tracking.** Apple: *"because menu tracking occurs in the
  `NSEventTrackingRunLoopMode`, you must add the timer to the run loop in that mode."*
  ([Views in Menu Items](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/MenuList/Articles/ViewsInMenuItems.html))
- **Mouse/resize tracking.** Apple: *"the application's main thread is unable to process
  any other requests during an event-tracking loop and **timers might not fire as
  expected**."*
  ([Handling Mouse Events](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/EventOverview/HandlingMouseEvents/HandlingMouseEvents.html))

A run loop runs **one mode at a time**, and *"only sources associated with that mode are
monitored and allowed to deliver their events"*
([Threading Programming Guide — Run Loops](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Multithreading/RunLoopManagement/RunLoopManagement.html)).

**Model 2b (libuv primary, drain Cocoa via `nextEventMatchingMask`) fails here.** During a
modal session or a tracking loop, AppKit's nested runloop owns thread 0; the outer
libuv-driven pump does not run again until the modal/tracking loop returns. libuv — and
therefore every Node timer, threadpool completion, and microtask on the main loop — is
**starved for the entire duration**. This is the very hazard Apple documents ("timers
might not fire as expected"). It is unavoidable in 2b because 2b's control point *is* the
outer pump, and AppKit has taken the thread.

**Model 2c (Cocoa authoritative) survives — by exactly one mechanism.** Cocoa's
`kCFRunLoopCommonModes` set *"includes the default, modal, and event tracking modes by
default"*
([Run Loops, Table 3-1](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Multithreading/RunLoopManagement/RunLoopManagement.html)).
A libuv-servicing source registered in `kCFRunLoopCommonModes` therefore **keeps firing
during modal sessions, menu tracking, and live resize** — the windows where 2b is dead.
(CFRunLoop confirms recursive/nested activations are a supported, first-class thing:
*"Run loops can be run recursively … create nested run loop activations on the current
thread's call stack."*
[CFRunLoop](https://developer.apple.com/documentation/corefoundation/cfrunloop).)

**Corollary — naive 2c is not enough either.** A libuv source added to the *default mode
only* also dies during tracking/modal loops. The 2c decision therefore comes with a
hard requirement: **register the libuv source (and any timer) in `kCFRunLoopCommonModes`**,
not the default mode. This is a build-leaf correctness invariant, recorded in ADR-0056.

### The runtime-facilities constraint reinforces 2c

Beyond nested loops, `[NSApp run]` provides the standard event-dispatch cycle (autorelease
pool draining, modal/tracking handling, `sendEvent:`), which a hand-rolled
`nextEventMatchingMask` pump must re-implement and which Apple frames as an expert
"short-circuit" path
([NSApplication.run()](https://developer.apple.com/documentation/appkit/nsapplication/run()),
[nextEvent(matching:…)](https://developer.apple.com/documentation/appkit/nsapplication/nextevent(matching:until:inmode:dequeue:))).
A macOS GUI app that reimplements the AppKit loop to keep libuv primary is fighting the
framework and inherits every nested-loop starvation above. Letting AppKit own thread 0
(2c) and servicing libuv as a guest is the design that keeps *both* the native UI facility
*and* the runtime's loop intact.

**Verdict:** confirm ADR-0054 §3 (2c). The reversal cost of 2b (starvation on routine UI +
reimplementing AppKit's loop) is decisive and independent of the spike's tick counts.

### Prior art agrees on polarity

Both mature JS-runtime-on-Cocoa systems make the **native loop authoritative and the JS
engine a guest** (see Q3): NativeScript enters via `NSApplicationMain` and grafts JS onto
the main CFRunLoop; NodeGui hands the main thread to Qt's `exec()` (Qt on macOS =
CFRunLoop) and services libuv underneath. Neither runs the JS/libuv loop primary on the
main thread. This is independent convergence on 2c.

---

## Q2 — Integration mechanism

Three candidate mechanisms for servicing libuv from the authoritative Cocoa runloop:

- **(a) Polling timer** — a `CFRunLoopTimer` (the spike's 4 ms) calls `uv_run(NOWAIT)`
  periodically. **Rejected.** Adds up to one interval of latency to *every* libuv callback,
  burns CPU when idle, defeats runloop sleep + App Nap (Apple: *"Timers prevent the CPU
  from going to or staying in the idle state"*;
  [Minimize Timer Usage](https://developer.apple.com/library/archive/documentation/Performance/Conceptual/power_efficiency_guidelines_osx/Timers.html)),
  and its `uv_run(NOWAIT)` runs **nested** inside the outer `uv_run(DEFAULT)` — which libuv
  documents as unsupported: *"uv_run() is not reentrant. It must not be called from a
  callback."* ([loop.rst](https://raw.githubusercontent.com/libuv/libuv/v1.x/docs/src/loop.rst)).
  The spike's nested pump "worked" by accident, not by contract.

- **(b) Single-threaded, event-driven** — register `uv_backend_fd(loop)` as a
  `CFFileDescriptor` runloop source in `kCFRunLoopCommonModes`; arm a `CFRunLoopTimer` to
  `uv_backend_timeout(loop)`, re-computed each turn (via a `kCFRunLoopBeforeWaiting`
  observer); on either wake, call `uv_run(NOWAIT)` and re-enable the one-shot
  `CFFileDescriptor`. No helper thread; the runloop sleeps when idle (App-Nap friendly).

- **(c) Helper thread (Electron shape)** — a dedicated thread blocks on `uv_backend_fd`
  (via `poll`/`kevent`/`epoll`, timeout = `uv_backend_timeout`); on wake it signals the
  main runloop (`CFRunLoopSourceSignal` + `CFRunLoopWakeUp`) and blocks on a semaphore; the
  main thread runs exactly one `uv_run(NOWAIT)` and posts the semaphore. Lock-stepped
  one-poll-per-one-NOWAIT so the two threads never touch the loop concurrently.

### The canonical embedding contract (libuv)

libuv's only official embedding guidance is `test/test-embed.c` plus a one-line pointer in
`loop.rst`: *"This can be used in conjunction with `uv_run(loop, UV_RUN_NOWAIT)` to poll in
one thread and run the event loop's callbacks in another."* The canonical loop
([test-embed.c](https://raw.githubusercontent.com/libuv/libuv/v1.x/test/test-embed.c)):

```c
while (uv_loop_alive(loop)) {
  do {
    struct pollfd p = { .fd = uv_backend_fd(loop), .events = POLLIN };
    rc = poll(&p, 1, uv_backend_timeout(loop));   // recomputed every iteration
  } while (rc == -1 && errno == EINTR);
  uv_run(loop, UV_RUN_NOWAIT);
}
```

Two load-bearing facts: **the fd path is Unix-only** (`#if`-guarded out on Windows/AIX/QNX,
which fall back to `uv_run(UV_RUN_ONCE)`), and **`uv_backend_timeout` must be recomputed
every iteration** — it is not a fixed value.

### The two scars every mechanism must handle

1. **Stale `uv_backend_timeout` → `setTimeout` silently stops.** The backend fd signals
   *I/O* readiness only; timers, idle handles, and pending-close callbacks do **not** touch
   the fd (libuv `design.rst` step 7: the timeout is `0` for those cases, else the closest
   timer's delay). So an embedder that reads `uv_backend_timeout` once and then blocks on
   the fd will **miss timer work added afterward**. This is a real Electron bug: libuv
   [#1565](https://github.com/libuv/libuv/issues/1565) (*"Electron … solved this with an
   ugly hack"*), user-visible as
   [Electron #7079](https://github.com/electron/electron/issues/7079) (`setTimeout`
   fires ~900 times then stops on macOS). Electron carries a **downstream, never-merged
   libuv patch** `UV_LOOP_INTERRUPT_ON_IO_CHANGE`
   ([PR #3308](https://github.com/libuv/libuv/pull/3308), verified `merged:false`), enabled
   via `uv_loop_configure`. Without that patch, the portable fix is a `uv_async` self-pipe
   the embedder `uv_async_send`s whenever JS may have added a handle, to break the poll and
   recompute the timeout. `uv_async_send` **does** wake the backend fd (the async handle is
   registered in the backend poller), though libuv coalesces repeated sends
   ([async.rst](https://raw.githubusercontent.com/libuv/libuv/v1.x/docs/src/async.rst)).

2. **Concurrent loop mutation.** If the helper thread and the main thread both touch the
   loop, state corrupts. Electron's semaphore lock-step (one poll ↔ one `uv_run(NOWAIT)`)
   exists precisely because of a real race
   ([Electron #894](https://github.com/electron/electron/issues/894): multiple JS contexts
   let *"the semaphore … increase arbitrarily, and … the embed thread to run while the main
   thread is calling `uv_run`"*, symptom: `setImmediate` stops firing).

### The unverified risk that decides (b) vs (c)

libuv warns, verbatim: *"Embedding a kqueue fd in another kqueue pollset doesn't work on
all platforms. **It's not an error to add the fd but it never generates events.**"*
([loop.rst](https://raw.githubusercontent.com/libuv/libuv/v1.x/docs/src/loop.rst)). On
macOS `uv_backend_fd` is a **kqueue** fd. Option (b)'s `CFFileDescriptor` may internally
register that fd on CoreFoundation's own kqueue/dispatch pollset — the exact "kqueue in
kqueue" shape the warning describes. **No primary source** (Apple or libuv) confirms
`CFFileDescriptor` reliably fires on a kqueue backend fd on current macOS — recorded as an
explicit *no-source-found*. Option (c) sidesteps this entirely: the helper thread `poll`s
the fd directly, the demonstrated-working path (libuv's classic embed example `kevent`s it
from a helper thread).

### Recommendation

**ADR-0056 mandates (c) the Electron helper-thread shape as the proven production
baseline** — it preserves the runtime's facilities with minimal latency, is battle-tested
at Electron scale, and avoids both the nested-`uv_run` violation and the unverified
CFFileDescriptor risk. **The k6 spike evaluates (b) head-to-head first-hand**, because (b)
is materially simpler (no helper thread to create/join, no cross-thread wake, no
`CFRunLoopPerformBlock`-style lifetime hazard) and more power-efficient (the main runloop
sleeps in its own sleep step) — *if* `CFFileDescriptor` fires reliably on the kqueue
backend fd. If the spike proves (b), it is production and (c) is the fallback; if (b) shows
the documented "never generates events" failure, (c) ships. Either way the mechanism ships
on first-hand evidence, not a hope. zcbenz's own post-mortem is the tiebreaker for the
default: he *"tried lots of hacks to extract the underlying file descriptors … and fed
them to libuv … but I still met edge cases that did not work,"* and chose the helper thread
because *"I was using the system calls for polling instead of libuv APIs, it was thread
safe"* ([Electron Internals: Message Loop Integration](https://www.electronjs.org/blog/electron-internals-node-integration)).

---

## Q3 — Prior art (post-mortems + walk-away checks)

### Electron — `node_bindings_mac.cc` (the canonical reference)

**Mechanism (option c), source-verified** (`shell/common/node_bindings.cc`,
`node_bindings_mac.cc` @ `electron/main`): a helper thread `EmbedThreadRunner` alternates
`uv_sem_wait` → `PollEvents` → `WakeupMainThread`; `PollEvents` on macOS is a single
`poll(uv_backend_fd, timeout=uv_backend_timeout)` (Linux: `epoll_wait`; **not** `kevent` —
recorded correction to the common "blocks via kevent" description); `WakeupMainThread`
`PostTask`s `UvRunOnce` to the main thread, which runs `uv_run(loop, UV_RUN_NOWAIT)` then
`uv_sem_post`. **The main thread never runs `UV_RUN_DEFAULT` in steady state** — the only
`UV_RUN_DEFAULT` is the teardown drain. The Chromium side of the wake is
`CFRunLoopSourceSignal` + `CFRunLoopWakeUp`
([message_pump_apple.mm](https://raw.githubusercontent.com/chromium/chromium/main/base/message_loop/message_pump_apple.mm)).

**Post-mortem:** the stale-timeout family (#1565 / #7079 / PR #3308) above; the multi-context
semaphore race (#894); the modern fix moved from a manual `on_watcher_queue_updated` hook
(present through ~v10) to the libuv-level `UV_LOOP_INTERRUPT_ON_IO_CHANGE`. High-idle-CPU
reports exist (#24385 traced to a *libuv* backwards-clock spin, not the embed thread) but
**no primary source attributes battery drain to the embed thread's wake frequency** —
recorded as no-source-found; the design is anti-busy-poll by construction (it sleeps in
`poll` until a real deadline/event).

**Walk-away check:** the transferable core is a three-line contract — *one timing thread
blocks on `uv_backend_fd` with `uv_backend_timeout`; on wake it posts a zero-delay block to
the main runloop and blocks on a semaphore; the main thread runs one `uv_run(NOWAIT)` and
releases the semaphore.* The two non-obvious must-copies: the semaphore lock-step (#894) and
a way to interrupt the poll when JS adds a timer (#1565). Fully legible without Electron.

### NodeGui / qode — Node + Qt (Qt on macOS = CFRunLoop)

**Polarity:** Qt (the GUI loop) is primary; libuv is the guest — qode README: *"When a Gui
message loop is injected, qode will use it as the primary event loop and will process
NodeJs requests on the main thread … by listening to the libuv's events."* The injected
loop *is* Qt's `exec()` (`integration.cpp`: `QtRunLoopWrapper` → `app->exec()`, registered
via `qode::InjectCustomRunLoop`). **This is 2c** (native GUI loop authoritative).

**Mechanism:** the *documented plan* (NodeGui [#11](https://github.com/nodegui/nodegui/issues/11))
was a `QSocketNotifier` on `uv_backend_fd` → `uv_run(NOWAIT)`, but that code is **not** in
the shipped addon (a code search for `uv_backend_fd` in `nodegui/nodegui` returned zero
files — recorded finding). The shipped pump lives in the **qode** fork, a *"heavily modified
fork of yode"* which is itself zcbenz's — i.e. the **same helper-thread lineage as Electron**
(qode README credits *"Cheng Zhao for yode and many of the ideas"*). **Honesty caveat:** the
exact qode C++ pump lines could **not** be retrieved (auth-gated GitHub code search, 429s,
404s) — the mechanism is *lineage-inferred*, not line-verified in qode.

**Post-mortem:** no NodeGui-specific 100%-CPU issue found (no-source-found). The failure mode
this architecture avoids is documented in a related integration
([trevorlinton gist](https://gist.github.com/trevorlinton/5cc934f9264629d4e85c),
"uvcf goes to 100% cpu"): fd-triggering every main-loop turn is *"a LOT of overhead and
causes 100%+ CPU"*, mitigated only by coarse polling — the exact poll-vs-CPU trade the
helper thread escapes. Sharp edge in NodeGui's own code: `QtRunLoopWrapper` ends with
`exit(exitCode)`, bypassing Node's graceful shutdown.

**Walk-away check:** *seam yes, mechanism no.* `InjectCustomRunLoop(&QtRunLoopWrapper)`
legibly says "GUI-primary, libuv-guest," but the pump is buried in the Node fork and only
re-derivable via the yode/Electron lineage.

### NativeScript (macOS/iOS) — JSC or V8, **no libuv**

**Mechanism:** NativeScript deletes libuv on Apple platforms and grafts the JS loop directly
onto CFRunLoop. JSC runtime (source-verified, `GlobalObject.mm`): a
`CFRunLoopObserver(kCFRunLoopBeforeWaiting)` + a `CFRunLoopSource` drain the microtask queue
each runloop turn (`drainMicrotasks`), attached to the runloop via `scheduleInRunLoop:forMode:`.
Timers are `CFRunLoopTimer`s added in `kCFRunLoopCommonModes` (ns-v8ios `Timers.cpp`) or
`dispatch_after` on the main queue. macOS entry is `NSApplicationMain(0, null)`
([macOS Node-API preview](https://blog.nativescript.org/macos-node-api-preview/)) — **AppKit
owns thread 0, JS is a guest** (2c again).

**Post-mortem — two facility-breaking scars, both predicted by the constraint:**
(1) worker threads have no running CFRunLoop, so `setTimeout` inside a worker **never fires**
([ns-v8ios #14](https://github.com/NativeScript/ns-v8ios-runtime/issues/14)) — the direct
cost of making timers a CFRunLoop facility; (2) pinning promise resolution to the origin
thread via `CFRunLoopPerformBlock` **leaks one wrapper per resolution** because CFRunLoop
gives no completion/disposal hook
([ns-v8ios #100](https://github.com/NativeScript/ns-v8ios-runtime/issues/100) / [NativeScript #9151](https://github.com/NativeScript/NativeScript/issues/9151):
*"there is simply no logic in place to handle the disposal at all"*). Background→main is a
manual sharp edge ([NativeScript #6851](https://github.com/NativeScript/NativeScript/issues/6851)).

**Walk-away check:** highly legible — all public CoreFoundation/GCD: a `BeforeWaiting`
observer draining microtasks, `CFRunLoopTimer` timers, `CFRunLoopPerformBlock`+`CFRunLoopWakeUp`
for cross-thread. Carries two must-avoid lessons: own the `CFRunLoopPerformBlock` wrapper
lifetime yourself, and workers need their own running loop.

### Node embedding docs — the API surface

`napi_get_uv_event_loop` is Node-API v2, `Stability: 2 - Stable`, but the docs caveat it
*"may result in an addon that does not work across Node.js major versions"* (it leaks
libuv's ABI, stable only within a libuv major)
([n-api.md](https://raw.githubusercontent.com/nodejs/node/main/doc/api/n-api.md)). The docs
steer toward `ThreadSafeFunction` as the ABI-stable cross-thread path — which is exactly the
substrate's `napi_threadsafe_function` background→main bounce (spike probe 3). **Walk-away:**
the embedding contract is `uv_backend_fd` + `uv_backend_timeout` + `uv_run(NOWAIT)` +
`uv_loop_alive`, all documented and stable within a libuv major.

---

## Q4 — Blocking & teardown

**Long synchronous work on the main thread starves the other loop — inherent to 2c and
unavoidable in any single-main-thread model.** A long AppKit/native call blocks the runloop,
so the libuv pump doesn't run and libuv is starved; symmetrically, a long synchronous JS
call blocks the runloop, so AppKit is unresponsive. This is the same caveat the Lisp targets
carry (ADR-0035/0022: *"sample-app authors doing long main-thread work must let the run loop
turn"*). What the helper-thread mechanism *does* add: libuv I/O **readiness** is still
detected (the helper keeps polling) even while the main thread is blocked — the work is
merely *deferred* to when the main thread returns, not *lost*. The mitigation is unchanged
across targets: heavy work goes off the main thread (Node `worker_threads` / the libuv
threadpool; sbcl `sb-thread`), with results bounced back via `napi_threadsafe_function`.

**Teardown, source-verified (Electron `StopPolling`):** clean shutdown must (1) set an
`embed_closed` flag; (2) wake the helper thread from **both** possible blocking points — the
semaphore (`uv_sem_post`) *and* the `poll` (an `uv_async_send` on a dummy handle makes the
backend fd readable, breaking a `timeout=-1` poll) — else `uv_thread_join` deadlocks while
the helper sleeps in `poll`; (3) `uv_thread_join`; (4) drain leftover semaphore posts; (5)
only then, with no concurrency, run the single `uv_run(UV_RUN_DEFAULT)` drain after
`uv_walk`+`uv_close` to let closing handles finish, then `uv_loop_close`. Option (b)'s
teardown is simpler (no thread to join): invalidate the `CFFileDescriptor` + `CFRunLoopTimer`
+ remove the observer, then the same libuv drain. **The double-wake-before-join is the
non-obvious deadlock trap** and is recorded as an acceptance test for k6.

---

## Q5 — Cross-target note (scoping, not scope-creep)

The recommended mechanism is a **Node-on-libuv-on-Unix** technique. Its generalization is the
`project_native_runloop_authoritative` grove's job; this leaf feeds it the following, cleanly
scoped:

- **The cross-target principle, stated precisely.** "Native Cocoa runloop authoritative,
  pump each runtime as a guest" must **distinguish two kinds of runtime**, or it breaks the
  facilities it's meant to preserve:
  - Runtimes with a **mandatory main-thread event loop** (Node/libuv, Deno, Bun) → the
    *main loop* is pumped as a guest; the runtime's **other** threads (worker_threads,
    threadpool) run natively and untouched.
  - Runtimes with **their own thread system but no mandatory main-thread loop** (the Lisp
    four — sbcl real `sb-thread`, racket, gerbil green threads) → they **cede** thread 0 to
    `[NSApp run]` and **bounce** background callbacks to main (ADR-0014/0022/0035); their
    schedulers are **never driven from the runloop**. Attempting to "pump sbcl as a guest"
    would break `sb-thread`.

  The unifying invariant is not "one loop pumps all" but **"the binding must not break the
  runtime's own threading facilities"** (the user's constraint). Each runtime needs its own
  "pump once" primitive: Node `uv_run(NOWAIT)`; Bun has none (issue #18546); Deno — see below.

- **Deno does not port as-is (corrects ADR-0054).** Source-verified in `denoland/deno`
  (`ext/napi`): `napi_get_uv_event_loop` returns the **`Env` pointer cast to `uv_loop_t*`**
  (a shim, not a libuv loop), and Deno's uv polyfill (`ext/napi/uv.rs`, Tokio-backed
  `uv_compat`) implements `uv_async_*`/`uv_timer_*`/`uv_thread_*` etc. but **not**
  `uv_backend_fd`, `uv_backend_timeout`, `uv_run`, or `uv_loop_alive`. So the embedding
  technique cannot work on Deno unchanged — a Deno GUI host needs Deno's own loop-drain
  primitive, like Bun. ADR-0054's "Deno uses libuv-compatible Node-API, so §3's integration
  is expected to port there" is **overturned** and edited. (No Deno *docs* source states
  this — inferred from the authoritative source tree; recorded as such.)

- **Bun:** no `uv_run` (JSC loop; [#18546](https://github.com/oven-sh/bun/issues/18546)) —
  out of scope, named, unchanged from the spike finding.

---

## Findings adopted (forward pointers)

- **ADR-0054 §3** edited in place: 2c confirmed with the nested-runloop decisive criterion +
  the `kCFRunLoopCommonModes` requirement + the threading-facilities constraint; the
  "nested `uv_run` proven clean" caveat corrected (officially unsupported); the Deno
  "expected to port" note corrected (does not port as-is); mechanism deferred to ADR-0056.
- **ADR-0056 (new)** — the TS threading model (the Q4 ADR): 2c polarity, mechanism =
  (c) baseline / (b)-if-proven, `kCFRunLoopCommonModes` invariant, `napi_threadsafe_function`
  background→main bounce (the ADR-0014/0022/0035 analogue), the threading-facilities
  constraint, and teardown — cites this finding by primary source.
- **`libuv-runloop-primacy-spike-k6`** — concrete acceptance tests written into its brief
  (implement (c); evaluate (b) head-to-head; the facility + teardown tests; measure vs the
  4 ms-poll baseline).
- **`ts-substrate-spike-k3` FINDINGS** probe 2 forward-pointer updated to reference this
  analysis and ADR-0056.
- **`project_native_runloop_authoritative` grove** — inherits the precise cross-target
  principle (Q5) and the two-kinds-of-runtime distinction.

---

## Citations

**Electron / Chromium (source @ main, curl'd raw bytes):**
- `shell/common/node_bindings.cc`, `node_bindings_mac.cc`, `node_bindings_linux.cc` — https://github.com/electron/electron/tree/main/shell/common
- Chromium `base/message_loop/message_pump_apple.mm` — https://raw.githubusercontent.com/chromium/chromium/main/base/message_loop/message_pump_apple.mm
- "Electron Internals: Message Loop Integration" (zcbenz) — https://www.electronjs.org/blog/electron-internals-node-integration
- Electron #894 — https://github.com/electron/electron/issues/894 · #7079 — https://github.com/electron/electron/issues/7079 · #24385 — https://github.com/electron/electron/issues/24385

**libuv / Node:**
- `docs/src/loop.rst` — https://raw.githubusercontent.com/libuv/libuv/v1.x/docs/src/loop.rst · `design.rst` — https://raw.githubusercontent.com/libuv/libuv/v1.x/docs/src/design.rst · `async.rst` — https://raw.githubusercontent.com/libuv/libuv/v1.x/docs/src/async.rst
- `test/test-embed.c` (current + v1.9.0) — https://raw.githubusercontent.com/libuv/libuv/v1.x/test/test-embed.c
- libuv #1565 — https://github.com/libuv/libuv/issues/1565 · PR #3308 (`UV_LOOP_INTERRUPT_ON_IO_CHANGE`, closed/unmerged) — https://github.com/libuv/libuv/pull/3308
- Node N-API `napi_get_uv_event_loop` — https://raw.githubusercontent.com/nodejs/node/main/doc/api/n-api.md (rendered https://nodejs.org/api/n-api.html#napi_get_uv_event_loop)

**Deno (source @ main):**
- `ext/napi/node_api.rs`, `ext/napi/uv.rs`, `ext/napi/lib.rs` — https://github.com/denoland/deno/tree/main/ext/napi

**NodeGui / qode / NativeScript:**
- qode README — https://github.com/nodegui/qode · NodeGui `integration.cpp` — https://raw.githubusercontent.com/nodegui/nodegui/master/src/cpp/lib/core/Integration/integration.cpp · NodeGui #11 — https://github.com/nodegui/nodegui/issues/11 · yode — https://github.com/yue/yode · trevorlinton gist — https://gist.github.com/trevorlinton/5cc934f9264629d4e85c
- NativeScript ios-runtime `GlobalObject.mm` — https://raw.githubusercontent.com/NativeScript/ios-runtime/master/src/NativeScript/GlobalObject.mm · ns-v8ios `Runtime.mm`/`Timers.cpp` — https://github.com/NativeScript/ns-v8ios-runtime · macOS Node-API preview — https://blog.nativescript.org/macos-node-api-preview/ · #14 — https://github.com/NativeScript/ns-v8ios-runtime/issues/14 · #100 — https://github.com/NativeScript/ns-v8ios-runtime/issues/100 · NativeScript #6851 — https://github.com/NativeScript/NativeScript/issues/6851 · #9151 — https://github.com/NativeScript/NativeScript/issues/9151

**Apple (developer.apple.com / library archive):**
- Run Loops (Threading Programming Guide) — https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Multithreading/RunLoopManagement/RunLoopManagement.html · CFRunLoop — https://developer.apple.com/documentation/corefoundation/cfrunloop · kCFRunLoopCommonModes — https://developer.apple.com/documentation/corefoundation/kcfrunloopcommonmodes
- runModal(for:) — https://developer.apple.com/documentation/appkit/nsapplication/runmodal(for:) · runModalSession(_:) — https://developer.apple.com/documentation/appkit/nsapplication/runmodalsession(_:) · NSAlert.runModal() — https://developer.apple.com/documentation/appkit/nsalert/runmodal()
- NSEventTrackingRunLoopMode — https://developer.apple.com/documentation/appkit/nseventtrackingrunloopmode · Views in Menu Items — https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/MenuList/Articles/ViewsInMenuItems.html · Handling Mouse Events — https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/EventOverview/HandlingMouseEvents/HandlingMouseEvents.html
- NSApplication.run() — https://developer.apple.com/documentation/appkit/nsapplication/run() · nextEvent(matching:…) — https://developer.apple.com/documentation/appkit/nsapplication/nextevent(matching:until:inmode:dequeue:)
- CFFileDescriptor — https://developer.apple.com/documentation/corefoundation/cffiledescriptor · CFFileDescriptorCreateRunLoopSource — https://developer.apple.com/documentation/corefoundation/cffiledescriptorcreaterunloopsource(_:_:_:)
- App Nap — https://developer.apple.com/library/archive/documentation/Performance/Conceptual/power_efficiency_guidelines_osx/AppNap.html · Minimize Timer Usage — https://developer.apple.com/library/archive/documentation/Performance/Conceptual/power_efficiency_guidelines_osx/Timers.html

**No-source-found (recorded per discipline):** `CFFileDescriptor` firing reliably on a
libuv kqueue `uv_backend_fd` on current macOS (Apple + libuv both silent — the decisive gap
k6 must close); qode's own C++ pump source (auth-gated); battery drain attributed to
Electron's embed-thread wake frequency; an auto-drain `CFRunLoopObserver` in NativeScript's
*V8* runtime (it drains microtasks explicitly); Deno *docs* (as opposed to source)
describing its `uv_loop_t` shim.
