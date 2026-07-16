# TypeScript substrate spike — findings

**Date:** 2026-07-05
**Leaf:** `ts-substrate-spike-k3` (grove `add-typescript-target-language`)
**Decision framing:** Q1 (runtime substrate + dispatch) was settled by
`typescript-target-k1` as **B1** — Node reference runtime · N-API generated typed
native dispatch (napi-rs + Swift dylib) · engine-agnostic via N-API · trampoline-
elided — on durability + threading + philosophy grounds, but three claims rested on
research citations and the racket precedent, **not yet on a first-hand arm64 run**.
This spike runs them. It mirrors the racket ffi2 spike (`targets/racket/docs/research/
2026-05-31-racket-ffi2-spike/FINDINGS.md`): the ADR lands with the spike's own
results as evidence, not before.

**Host / toolchain (cited at the decision site, per `driving.md`):**
macOS 26.5.1 (build 25F80), arm64 (Apple Silicon). Swift 6.3.3
(swiftlang-6.3.3.1.3, Target arm64-apple-macosx26.0). Node v26.4.0. Bun 1.3.14
(0d9b296a). Rust/cargo 1.93.1. napi-rs: `napi` 2.16.17 · `napi-derive` 2.16.13 ·
`napi-build` 2.3.2 · `napi-sys` 2.4.0. **Deno: not installed on this host — probe 4
Deno leg not run first-hand (env gap, recorded honestly below).**

**Repro:** this directory. `bash build.sh` builds the throwaway Swift bridge dylib
(`swift/libtsbridge.dylib`, hand-written `@_cdecl` msgSend entries) and the napi-rs
addon (`addon/`, copied to `addon.node`). `bash run.sh` runs every probe. Throwaway
spike code — a handful of hand-written dispatch entries + a minimal addon; **no
emitter, no IR, no build integration** (the point is evidence, not a binding).

**Verdict: probes 1–3 GREEN. B1 confirmed on first-hand arm64. Write the substrate
ADR.** Probe 4 (portability) GREEN for Bun on the dispatch substrate + threadsafe-
function bounce, with one precise Node-specific caveat (below); Deno leg deferred.

---

## Probe 1 — generated dispatch through napi-rs  ·  GREEN

**Claim under test (Gap 1, napi-rs↔Swift path):** a napi-rs (Rust) N-API addon can
load a Swift dylib exposing generated `@_cdecl` msgSend dispatch entries, and Node
can call them — including an **arm64 x8 struct-by-value return**.

**Mechanism (mirrors ADR-0013 exactly).** Each entry is a Swift `@_cdecl` func that
`unsafeBitCast`s `objc_msgSend` — fetched once via `dlsym(RTLD_DEFAULT,
"objc_msgSend")` because Swift's ObjectiveC overlay marks it unavailable — to a
concrete `@convention(c)` shape per distinct ABI signature. The napi-rs addon links
the dylib (`extern "C"`) and surfaces the entries to JS; ObjC pointers (id/SEL/Class)
cross as **BigInt opaque handles**.

**Results (`node/probe1.mjs`, Node v26.4.0):**

| sub-probe | shape | result |
|---|---|--:|
| `objc_getClass("NSString")` | Class → handle | `0x1f5e52100` ✓ |
| `[NSString stringWithUTF8String:"hello, spike"]` | (id,SEL,char\*)→id | handle ✓ |
| `-[str length]` | (id,SEL)→**u64 scalar** | `12` ✓ |
| `[NSScreen mainScreen]` | (id,SEL)→id | handle ✓ |
| `-[NSScreen frame]` | (id,SEL)→**CGRect by value** | `{0,0,5120,2160}` ✓ |
| out-buffer cross-check of the same frame | (id,SEL,double\*)→void | matches by-value ✓ |

**Reading.** The generated-typed dispatch mechanism crosses the napi-rs↔Swift seam
intact. The **CGRect struct-by-value return** — 32 bytes, returned via arm64's x8
indirect-return register — arrives correctly through **two independent paths** (Swift
returns `CGRect` by value into Rust's `#[repr(C)]` struct; and, separately, writes
the four doubles into a caller buffer), which agree exactly (`5120×2160`, a real
Retina frame). This is the marshalling-depth thesis in miniature (racket ADR-0013
§struct-return) re-proven through Rust rather than Racket. **Retires Gap 1 for the
napi-rs↔Swift path.**

## Probe 2 — AppKit owns thread 0 under Node  ·  GREEN (mechanism identified)

**Claim under test (Gap 5, the load-bearing unknown):** a Node process can call
`NSApplication.run()` on the main thread, draw a window, and stay responsive — and
we must establish *by what mechanism* Node's libuv loop and the Cocoa runloop coexist
on thread 0.

**Setup.** `aw_ts_setup_app()` builds `NSApplication.shared` + a titled window and
reports `Thread.isMainThread`. Three models were run as a controlled comparison; each
schedules a Node `setInterval` on the libuv loop, whose firing (or not) is the probe.

| model | who owns thread 0 | Cocoa window | Node libuv timers fire | verdict |
|---|---|---|---|---|
| **2a cede** (`NSApp.run()`, no pump) | AppKit | ✓ draws, runloop runs (autoquit fires) | **NO (0 ticks)** | libuv STALLS |
| **2b co-op pump** (Node loop primary, drain Cocoa via `nextEvent`) | libuv | ✓ | ✓ (17 ticks/1.8s) | coexist |
| **2c integrated** (`NSApp.run()` + main-runloop timer pumps `uv_run(NOWAIT)`) | AppKit | ✓ | ✓ (21 ticks/2s) | **coexist** |

**Key result — 2a vs 2c is the controlled proof.** First-hand: **`setup_app` reports
`onMain=true`** — *Node's main thread IS AppKit's main thread* (the process's thread
0), so calling AppKit from a synchronous napi call is legal and the window draws.
Under naive **cede (2a)**, `NSApplication.run()` runs the Cocoa runloop (the
`DispatchQueue.main.asyncAfter` autoquit fires and `run()` returns cleanly) but Node's
`setTimeout(300ms)` **never fires** — libuv is starved. Under **integrated (2c)**,
`NSApplication.run()` genuinely owns thread 0 (it blocks the JS thread for 2s) while a
4ms main-runloop `Timer` calls `uv_run(loop, UV_RUN_NOWAIT)`; now **21 Node
`setInterval` ticks AND 21 threadsafe-function callbacks fire *during* `NSApp.run()`**.
Since Node's own `uv_run(UV_RUN_DEFAULT)` is suspended (we never returned to it), the
only thing that can service those libuv timer + async handles is the pump — so the
21-vs-0 difference is dispositive.

**Mechanism identified: runloop integration via `napi_get_uv_event_loop`.** The Rust
addon reaches Node's `uv_loop_t*` through the **stable N-API function
`napi_get_uv_event_loop(env, &loop)`**, then hands it to the Swift runloop timer,
which pumps it. **Retires Gap 5 with a concrete, first-hand mechanism, not a hope.**

**Recommended direction (per user steer, 2026-07-05): the native runloop is
authoritative and pumps Node — the 2c model, not 2b.** A macOS GUI app *must* let
Cocoa own thread 0 (the ADR-0010 north star: the app is a native macOS app); Node's
libuv loop becomes the *guest*, pumped from within the Cocoa runloop. This is the
right ownership polarity and it generalizes across targets (see *Cross-target
implication* below).

**One honest caveat for the build leaf (not a feasibility blocker).** The 4ms polling
timer calls `uv_run(NOWAIT)` while Node's outer `uv_run(DEFAULT)` is still on the
stack (technically nested). It ran clean over 21 pumps / 2s with no crash or assert,
but production should refine the poll into an **event-driven** integration:
`uv_backend_fd(loop)` registered as a `CFFileDescriptor`/kqueue source on the main
runloop (wake on libuv I/O) + a runloop timer armed to `uv_backend_timeout(loop)` (wake
for the next libuv timer). That removes both the busy-poll and the nesting. This is
Q4 (threading) build-leaf work; the spike's job — prove coexistence is achievable and
name the mechanism — is done.

## Probe 3 — background-thread callback bounced to main  ·  GREEN

**Claim under test (D5 threading story, native):** a GCD `dispatch_async` (global
queue) block, via the native bridge + `napi_threadsafe_function`, delivers to a JS
callback on the loop thread with no crash/deadlock.

**Results (`node/probe3.mjs`, Node v26.4.0).** A Swift `DispatchQueue.global().async`
block invokes a Rust `extern "C"` trampoline on a **GCD worker thread**
(`Thread.isMainThread=false`, logged), which pokes a napi-rs `ThreadsafeFunction`; the
tsfn schedules the JS callback on the loop thread. Fired 5 concurrent dispatches:
**all 5 delivered to JS (~1.1ms), correct tokens, no crash/deadlock.** Arrival order
is nondeterministic — GCD's *global* queue is concurrent (the 5 blocks run on
different worker threads: the `[swift]` log shows order `1,4,3,5,2`) — so correctness
is *delivery completeness* (every token exactly once), which held. **Validates the D5
bounce natively.** Combined with probe 2c, the same tsfn delivery works *while
`NSApp.run()` owns thread 0* (21/21 callbacks under NSApp.run).

## Probe 4 — portability hedge, first-hand  ·  GREEN (Bun substrate) with one caveat

**Claim under test:** the *same* `.node` addon is engine-agnostic across Node/Deno/Bun
— the longevity argument (D1) the whole "Node is *reference*, not *the* runtime"
framing rests on.

**Bun 1.3.14 (first-hand), same unmodified `addon.node`:**

| probe | Bun result |
|---|--:|
| **1 — dispatch incl. CGRect struct return** | **GREEN** (identical output to Node, `{0,0,5120,2160}`) |
| **3 — threadsafe-function bounce** | **GREEN** (5/5 delivered, ~1.1–1.6ms) |
| **2c — integrated `uv_run` pump** | **RED — clean panic**: `unsupported uv function: uv_run` (Bun issue #18546) |

**Reading — this sharpens the CONTEXT claim.** Bun clears the **dispatch substrate**
*and* the **threadsafe-function bounce** on the exact same binary — the load-bearing
portability points. The only failure is the **Node-specific runloop-integration
mechanism**: Bun's loop is JavaScriptCore-based, not libuv; it shims
`napi_get_uv_event_loop` but does **not** implement `uv_run`, so the probe-2c pump
panics. A Bun-hosted GUI app would need Bun's own "drain the event loop once"
primitive instead of `uv_run(NOWAIT)` — a per-runtime threading-integration detail,
not a dispatch-substrate gap.

Two corrections to the pre-spike framing, both from first-hand evidence:
1. **The "struct-by-value wall" does NOT disqualify Bun for this substrate.** That
   wall is a **`bun:ffi`** limitation (Bun's *own* FFI can't return `CGRect` by
   value). Our substrate is **N-API**: the struct is marshalled natively (Swift→Rust)
   *below Bun's view* — Bun only ever receives a plain `{x,y,w,h}` object. Bun passed
   the CGRect probe. The glossary's struct-wall reason for ruling Bun out as
   *reference* should be retired; Bun's disqualification as *reference* rests instead
   on **(a)** the libuv/`uv_run` GUI-integration gap and **(b)** ecosystem longevity.
2. **Deno leg not run first-hand** (Deno absent on host; auto-installer blocked by
   policy — not worked around). The engine-agnostic claim for Deno remains as the
   research cites it (NativeScript `runtime-node-api` runs on Node+Deno). **Follow-up:
   a first-hand Deno run (dispatch + tsfn + loop integration) should confirm this**;
   Deno *does* use libuv-compatible Node-API, so `uv_run` integration is expected to
   port there where it did not to Bun.

---

## Synthesis — the decision

Probes 1–3 are **GREEN on first-hand arm64**: the B1 substrate works end-to-end —
generated `@_cdecl` msgSend dispatch through napi-rs (incl. the x8 CGRect struct
return), AppKit owning thread 0 under Node with libuv serviced, and the bg→main
threadsafe-function bounce, including all three composed (the bounce delivering while
`NSApp.run()` owns thread 0). **The fork does not reopen; write the substrate ADR**
(TS analogue of racket ADR-0013 / sbcl ADR-0038) citing these results, and drop the
`typescript` glossary entry's "spike-pending" qualifier.

Probe 4 confirms the dispatch substrate + tsfn bounce are engine-agnostic (Bun,
first-hand) and localizes the one runtime-specific seam (loop integration) precisely.

**Feeds `ts-design-grill-k4` (Q4, threading):** the recommended model is **native
Cocoa runloop authoritative, pumping Node's libuv loop as a guest** (probe 2c), with
the event-driven `uv_backend_fd` refinement as the build target.

> **Followed up (2026-07-05) → `libuv-runloop-primacy-research-k5`.** The primacy
> analysis (`../2026-07-05-libuv-runloop-primacy.md`) promoted 2c from principle to a
> **decisive measured criterion** (AppKit's nested modal/tracking runloops starve a
> libuv-primary 2b pump; a source in `kCFRunLoopCommonModes` survives them) and settled
> the mechanism in **ADR-0056**: Electron's helper-thread shape as the proven baseline,
> a single-threaded `CFFileDescriptor`-on-`uv_backend_fd` shape evaluated head-to-head by
> `libuv-runloop-primacy-spike-k6`. The 4 ms **nested `uv_run`** noted below is
> **officially unsupported** (libuv: `uv_run` "is not reentrant") — it ran by accident and
> does **not** ship. Deno correction: the embedding API is **absent** on Deno
> (`uv_backend_fd`/`uv_backend_timeout`/`uv_run` unimplemented; the loop is a shim), so the
> integration does **not** port to Deno as-is — only dispatch + tsfn do.

## Cross-target implication (raised by user, 2026-07-05 → its own grove)

The user observed that "native Swift runloop pumps the runtime" is likely **the right
polarity for *all* targets, not just TypeScript** — and asked for a **separate grove**
to investigate the repercussions. The spike supports the intuition: a macOS GUI app
must let Cocoa own thread 0, so any runtime with its own event loop (Node/libuv;
Deno; Bun's JSC loop; a future Python/asyncio target) should be **pumped as a guest**
from within the authoritative Cocoa runloop, and runtimes without a mandatory loop
(the Lisp four) simply cede. This would unify the per-target main-thread story
(cf. ADR-0014/0022/0035 main-thread bounce; ADR-0049 app-kinds). Each runtime needs
its own "pump once" primitive — Node: `uv_run(NOWAIT)`; **Bun: no `uv_run`, needs its
own** (issue #18546); Deno: libuv-compatible, expected to port. **This is out of scope
for `add-typescript-target-language`** and is captured for a new grove rather than
absorbed here (grove decompose discipline).
