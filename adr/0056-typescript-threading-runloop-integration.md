# TypeScript threading: the native runloop pumps libuv as a guest; background callbacks bounce to main

Decides the **typescript** target's threading model — the first target whose runtime owns
a **competing, mandatory event loop** (Node's libuv), so the first that must *integrate*
two loops on thread 0 rather than merely cede it. Builds on **ADR-0054 §3** (the settled
polarity: the native Cocoa runloop is authoritative and pumps the runtime's loop as a
guest) and completes the **main-thread-bounce family** for this target — the analogue of
racket **ADR-0014**, gerbil **ADR-0022**, sbcl **ADR-0035**, but wider, because those four
runtimes have no mandatory main-thread loop and this one does.

**Target scope (2026-07-06).** This is the **Node** TypeScript target's threading model (ADR-0054
§Target scope). The whole pump exists *because Node owns libuv*. The separate **JSC** TypeScript target
(future grove) has **no** competing loop — a `JSVirtualMachine` rides `NSApplication.run()`'s CFRunLoop
cooperatively — so this entire ADR **dissolves** there (no pump, no `pump_shim.cc`; the bg→main bounce
becomes `dispatch_async(main)` + a `JSManagedValue`-held resolver). See
`targets/typescript/docs/research/2026-07-06-ts-substrate-reeval/FINDINGS.md` §A2/§I2. Nothing below
changes for the Node target.

**Governing constraint (the user's, made first-class here):** *the binding must not break
the runtime's own threading facilities.* For Node that means the whole concurrency model —
libuv timers, the libuv **threadpool** (fs/dns/crypto/zlib completions delivered on the
loop thread), **`worker_threads`**, and the `process.nextTick`/microtask contract — must
keep behaving, not merely "libuv keeps ticking." This constraint drives every decision
below.

Evidence: `targets/typescript/docs/research/2026-07-05-libuv-runloop-primacy.md` (primary
sources — Electron `node_bindings_mac.cc`, libuv `test/test-embed.c` + docs, Node N-API
docs, NodeGui/NativeScript source, Apple CFRunLoop/AppKit/CFFileDescriptor docs) and the
substrate spike `2026-07-05-ts-substrate-spike/FINDINGS.md` (probes 2 + 3, first-hand
arm64) and the runloop-integration spike
`2026-07-05-ts-runloop-integration-spike/FINDINGS.md` (`libuv-runloop-primacy-spike-k6`,
first-hand arm64), which **settled the mechanism** (§2) and surfaced the entry-architecture
findings (§Consequences). The mechanism selection is now decided on first-hand measurement,
not pre-judgement.

## Context — why this target needs its own threading ADR

The Lisp four **cede** thread 0 to `[NSApp run]` and bounce background callbacks to main;
they have no loop of their own to reconcile. Node does: libuv *is* Node's scheduler for
timers, I/O, and threadpool-completion delivery. ADR-0054 §3 settled that AppKit — not
libuv — owns thread 0 (a macOS GUI app must let AppKit own the main thread; and a
libuv-primary manual event pump starves during AppKit's routine nested runloops — modal
sessions, menu tracking, live-resize — because those run the main runloop in a mode a
default-mode source never sees). This ADR settles *how* libuv is then serviced without
breaking Node's facilities, and *how* off-main callbacks re-enter JS.

## Decision

### 1. Service libuv from the authoritative runloop via a source in `kCFRunLoopCommonModes`

The addon reaches Node's `uv_loop_t*` through the stable **`napi_get_uv_event_loop`** and
services it with **single non-blocking passes — `uv_run(loop, UV_RUN_NOWAIT)`** — driven
from the main Cocoa runloop. The servicing source (and any associated timer) **must be
registered in `kCFRunLoopCommonModes`**, not the default mode, so it keeps firing during
AppKit's nested modal/tracking runloops. This is a correctness invariant, not a tuning
knob: a default-mode-only source reproduces the 2b starvation this polarity exists to
avoid. The main thread **never** runs `uv_run(UV_RUN_DEFAULT)` in steady state (that would
be Node owning the loop); the sole `UV_RUN_DEFAULT` is the teardown drain (§4). Nested
`uv_run` (a `NOWAIT` pass inside an outer `DEFAULT`, as the substrate spike's 4 ms poll
did) is **forbidden** — libuv documents `uv_run` as non-reentrant; the spike's nested pump
ran by accident, not by contract, and does not ship.

### 2. Mechanism: Electron's helper-thread shape (c) — decided; CFFileDescriptor (b) a viable future optimisation

**Decided (k6 spike, 2026-07-05, first-hand arm64):** the shipped mechanism is **(c), the
Electron helper-thread shape.** The k6 spike built both head-to-head and measured them against
every acceptance criterion; both pass. It **also resolved the decisive unknown GREEN** —
`CFFileDescriptor` *does* fire on the kqueue `uv_backend_fd` on macOS 26.5.1, so (b) is **viable,
not dead**. But "fires" proved (b) *possible*, not *better*: (b)'s only practical edge (idle
power) is matched by (c) in practice (both idle at ~1 pass/2 s), while (b) stakes the core
event-loop integration on **undocumented** CFFileDescriptor-on-kqueue behaviour — a longevity risk
that cuts against the durability-first philosophy (D1) which chose N-API for engine-agnosticism.
(c) uses only documented, stable primitives and is proven at Electron scale. **(c) ships; (b) is
retained as a documented future optimisation**, to revisit only if idle-power on the real runtime
(under the correct entry architecture, §Consequences) justifies the durability risk. This **refines**
the earlier "fires → (b) ships" rule: fires is necessary, not sufficient. Evidence:
`targets/typescript/docs/research/2026-07-05-ts-runloop-integration-spike/FINDINGS.md`.

Both shapes must handle the two documented scars: the **stale-`uv_backend_timeout`** hazard (the
backend fd signals I/O only — timers/idle/pending-close do not touch it, so a timer added after the
timeout is read is missed unless the wait is interrupted; libuv #1565, user-visible as Electron
`setTimeout`-stops-firing #7079) and **concurrent loop mutation** (Electron #894).

- **(c) Helper thread — SHIPPED.** A dedicated thread blocks on `uv_backend_fd` (via `poll`,
  timeout = `uv_backend_timeout`); on wake it signals the main runloop (`CFRunLoopSourceSignal` +
  `CFRunLoopWakeUp`) and waits on a semaphore; the main thread runs one `uv_run(NOWAIT)` and posts
  the semaphore — **lock-stepped** one-poll-per-one-`uv_run` so the two threads never touch the loop
  concurrently. The stale-timeout hazard is **largely self-corrected** in strict lock-step (k6
  finding): the helper re-reads `uv_backend_timeout` after *every* `uv_run` pass, and the main
  thread runs `uv_run` only inside the helper-signalled source, so no timer can be added between the
  helper's timeout-read and its `poll` — verified first-hand (a timer added after a quiescent gap
  still fires). A `uv_async` self-pipe is retained for **teardown** (to break a `poll(timeout=-1)`)
  and as belt-and-suspenders. Teardown does the **double-wake-before-join** (semaphore *and*
  `uv_async_send`) — verified deadlock-free. Battle-tested Electron/yode/NodeGui design; services
  libuv with minimal latency, preserving facility timing.

- **(b) Single-threaded `CFFileDescriptor` — VIABLE, not shipped (future optimisation).** Register
  `uv_backend_fd` as a `CFFileDescriptor` runloop source in `kCFRunLoopCommonModes` + a
  `CFRunLoopTimer` armed to `uv_backend_timeout` (re-armed each turn from a `kCFRunLoopBeforeWaiting`
  observer); on either wake, `uv_run(NOWAIT)` then re-enable the one-shot `CFFileDescriptor`. No
  helper thread; the runloop sleeps when idle. **k6 disproved the dead-fd fear** — the fd fires on
  real threadpool completions (test 6) — so libuv's "kqueue-in-kqueue never generates events"
  warning does **not** apply to the CoreFoundation path on macOS 26.5.1. **But** that behaviour is
  undocumented by both Apple and libuv, and (b)'s idle advantage over (c) proved marginal (test 4),
  so it does not justify the durability risk today.

### 3. Background → main callback bounce via `napi_threadsafe_function`

A callback arriving on a non-main thread (a GCD worker, a framework completion thread, a
libuv threadpool thread) must **never** re-enter JS off-main: JS runs on the loop thread,
which is AppKit's thread 0. The native core bounces via **`napi_threadsafe_function`** (the
substrate spike probe 3 proved this natively — 5/5 concurrent GCD dispatches delivered to
the JS loop thread, and delivered *while* `NSApp.run()` owned thread 0). This is the exact
role racket/gerbil/sbcl fill with a `dispatch_*`-to-main trampoline (ADR-0014/0022/0035);
the N-API primitive gives it first-class and is the ABI-stable path the Node docs recommend
over touching `uv_loop_t` directly. Value-returning vs void and the `dispatch_sync`-while-
main-blocked **deadlock caveat** carry over unchanged from the family; void completions are
immune.

### 4. Teardown drains both loops without deadlock

Clean shutdown (mechanism (c)): set an `embed_closed` flag; wake the helper thread from
**both** blocking points — the semaphore *and* the `poll` (via `uv_async_send` on a dummy
handle, so a `timeout=-1` poll returns) — else `uv_thread_join` deadlocks against a helper
asleep in `poll`; join; drain leftover semaphore posts; then, with no concurrency left, run
the single `uv_run(UV_RUN_DEFAULT)` drain after `uv_walk`+`uv_close` so closing handles
finish, then `uv_loop_close`. Mechanism (b): invalidate the `CFFileDescriptor` + timer +
observer, then the same libuv drain (no thread to join). The double-wake-before-join is the
non-obvious deadlock trap — **verified deadlock-free first-hand by k6** (teardown returns in
~0.1 ms, helper joined).

## Consequences

- **The runtime's facilities are preserved because only the *main* loop is pumped as a
  guest.** `worker_threads` each run their own `uv_run(UV_RUN_DEFAULT)` on their own thread,
  untouched; the libuv threadpool runs on its own threads and its completions are delivered
  promptly via §2's low-latency wake; timers and `nextTick`/microtasks drain within each
  `uv_run(NOWAIT)` pass. k6 verifies each first-hand (not just "ticks fire" but
  worker_threads run + join, a threadpool `fs`/`crypto` completion's latency, `nextTick`/
  `setImmediate`/microtask ordering, and timer accuracy incl. the stale-timeout fix).
- **Long synchronous main-thread work still starves the other loop** — inherent to any
  single-main-thread model, unchanged from ADR-0035/0022. A long native/AppKit call blocks
  the runloop (libuv deferred, not lost — the helper keeps detecting readiness); a long JS
  call blocks AppKit. Mitigation is the family's: heavy work goes off-main
  (`worker_threads` / the threadpool / `sb-thread`-equivalent), results bounced via §3.
  Sample-app authors must let the runloop turn; documented in the target reference.
- **Build order / where it lives.** The pump + the `napi_threadsafe_function` machinery, the
  `@_cdecl` dispatch, and the Swift-native residual all live in the **single Swift-native
  N-API addon** (ADR-0054 §2, confirmed Swift-native by `napi-dispatch-spine-k35`; the pump's
  C++ `pump_shim.cc` links into that same `.node`). The mechanism (c) is confirmed by k6; the
  pump child commits it.

- **The pump is "reproduce Node's loop-iteration body," not "call `uv_run`" (k6 findings A–C).**
  The runtime build leaf's principal risk is the embedding contract, *shared by any mechanism*,
  not the fd-wake. Three requirements, each learned first-hand:
  - **(A) Scope the pump.** A bare `uv_run(UV_RUN_NOWAIT)` from the runloop callback **crashes**
    in `node::Environment::CheckImmediate` (`v8::ToLocalChecked` on an empty `MaybeLocal`) on the
    first `setImmediate` — no `HandleScope`. The pump must run `uv_run` inside `v8::HandleScope` +
    `Context::Scope` and drive a microtask checkpoint, à la Node's `SpinEventLoop` / Electron's
    `UvRunOnce`. napi's public surface is insufficient — this needs Node's C++ embedding / V8
    primitives (k6 used a small `pump_shim.cc`).
  - **(B) AppKit owns thread 0 from the top level.** Entering `NSApp.run()` from *within* a Node
    callback nests the pump's `uv_run` inside Node's own `uv_run` — the forbidden non-reentrant
    `uv_run` — corrupting the immediate queue on real `setImmediate` workloads. This is just the
    ADR-0054 §3 polarity, made load-bearing: the native side owns the thread from the start.
  - **(C) No ambient blocking JS→native call while pumping.** While a synchronous napi call is on
    the stack, V8 **suppresses the microtask checkpoint** (verified: depth 0, policy `kExplicit`,
    checkpoint still a no-op), so pure Promise/`await`/`nextTick` work that touches no libuv handle
    stalls. libuv-handle-backed facilities (timers, I/O, threadpool, `worker_threads`) are
    unaffected. The runtime must therefore adopt the **Electron/NativeScript entry architecture** —
    the native side owns `main()` (`NSApplicationMain`-style) with Node embedded and pumped from
    the top of the runloop — **not** a `node app.js` that calls a blocking `run()`. This shapes how
    the target's sample apps are launched (a native launcher, not a bare `node` invocation).
- **`napi_get_uv_event_loop` is Node-specific in effect.** Stable Node-API v2, but the docs
  warn it leaks libuv's ABI (stable only within a libuv major). This is the seam that does
  **not** port cross-runtime: Deno returns a shim loop and omits `uv_backend_fd`/
  `uv_backend_timeout`/`uv_run` (does not port as-is); Bun has no `uv_run` (#18546). §3's
  tsfn bounce and the ADR-0054 dispatch *do* port. Cross-target repercussions are the
  `project_native_runloop_authoritative` grove's, which inherits the runtime-kind
  distinction (mandatory-loop → pump as guest; own-threads-no-loop → cede + bounce, never
  drive the scheduler from the runloop) and the "must not break the runtime's facilities"
  invariant.
- Target-local under **ADR-0011**. Evidence: the primacy analysis (2026-07-05), the
  substrate spike (2026-07-05), and the runloop-integration spike
  `libuv-runloop-primacy-spike-k6` (2026-07-05, first-hand arm64) which decided the mechanism
  ((c)) and surfaced the entry-architecture requirements (A–C above).
