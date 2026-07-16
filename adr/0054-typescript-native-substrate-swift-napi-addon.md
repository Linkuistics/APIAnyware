# The TypeScript target's native substrate: generated typed native dispatch through a Swift-native N-API addon

The **typescript** target reaches Objective-C through **generated typed native
dispatch** — the racket **ADR-0013** mechanism — hosted in a **single Swift-native
N-API addon** (`@_cdecl` entries hosting the Node-API C surface directly; no napi-rs /
Rust). That one `.node` is the target's native core: the first concrete application of
**ADR-0010** (the per-target native library *is* the binding) to a non-Lisp, N-API
runtime. It is a **trampoline-elided** target (**ADR-0025**): ObjC reached directly
through the generated entries; the Swift-native `s:` residual + pointer constants
handled by a thin trampoline layer (the TS analogue of racket **ADR-0027** / sbcl
**ADR-0038**). Governed by **ADR-0011** (per-target hermetic isolation).

The Swift-native single-unit core (the napi-rs layer dropped) is **confirmed first-hand**
by `napi-dispatch-spine-k35`, whose spine stood up the addon and round-tripped an
emitted-golden-shaped binding against it (§2, §Consequences). The substrate spike
(`ts-substrate-spike-k3`) proved the dispatch *mechanism* through an interim napi-rs +
dylib pair; the mechanism (§1), engine-agnosticism (§4), and thread-0 polarity (§3) are
unchanged by dropping napi-rs — only the native-unit composition (§2) collapses.

### Target scope — the TypeScript family splits by JS substrate into two targets

**Decided 2026-07-06 (user steer, `ts-substrate-reeval-k11`).** The substrate re-evaluation established
that a JS/TS binding on **Node + V8 + N-API** and one on **embedded system JavaScriptCore** are two
different *products*, not two idioms of one target — so the TypeScript family is **two separate targets**,
reopening the Q1 "single `typescript` target" framing on purpose:

- **The Node TypeScript target — *this ADR* (target #1, built first).** "The Node ecosystem, on macOS,
  with Cocoa access." Everything below describes it. Built first because it is the harder, richer target
  (the libuv pump — ADR-0056 — N-API, the threading reconciliation), so it yields the most learning.
- **The JSC TypeScript target (target #2, a separate future grove).** "Typed TS directly over Cocoa,
  native." All-Swift/ObjC core (no Rust, no N-API, no libuv), embedded system JavaScriptCore, the
  ADR-0056 pump dissolved, `JSManagedValue` memory, ~0 MB distribution. Its full substrate/memory/
  distribution design base is `targets/typescript/docs/research/2026-07-06-ts-substrate-reeval/FINDINGS.md`;
  it is not built by this grove.

**Core-language refinement (this Node target) — confirmed Swift-native (`napi-dispatch-spine-k35`).**
Because dispatch is emitter-*generated*, napi-rs's macro ergonomics no longer earn their place — a
**Swift-native N-API** addon collapses the interim two-unit core (Swift dylib + Rust addon) into **one
loadable `.node`** (which internally links the C++ `pump_shim.cc` TU the ADR-0056 pump child adds) and
drops the Rust toolchain entirely. This
was the lean; k35 **confirmed it first-hand** (§2). One residual risk stays open for the pump child
(ADR-0056), not this substrate decision: Swift *concurrency* on the libuv loop thread (FINDINGS §D5) was
not exercised by the outbound-only spine — revisit napi-rs *only* if the pump hits that wall. The
`@_cdecl` dispatch mechanism (§1) is unchanged by the language choice.

This ADR fixes the **substrate** (dispatch mechanism, native-unit composition,
engine-agnosticism, thread-0 ownership polarity). The detailed threading, lifetime,
object-model, error, callback, and distribution decisions (Q2–Q7) are raised by
`ts-design-grill-k4`; the threading ADR in particular (the TS analogue of sbcl
**ADR-0035**) *builds on* the thread-0 finding recorded here.

Every claim below is confirmed by a first-hand arm64 spike:
`targets/typescript/docs/research/2026-07-05-ts-substrate-spike/FINDINGS.md`
(the racket ADR-0013 precedent — the ADR lands with the spike's own results, not
before). Host/toolchain cited there.

## Context — the first N-API target, alien on FFI reach

The four existing targets are Lisps whose FFIs re-cast `objc_msgSend`'s address per
call site. JS/TS runtimes (Node, Deno, Bun) reach C only through a runtime FFI or an
N-API addon with a *fixed signature per symbol*. Q1 (`typescript-target-k1`) settled
the substrate as **B1** — Node reference runtime · N-API generated typed native
dispatch · engine-agnostic via N-API · trampoline-elided — on durability + threading
+ philosophy grounds. Three B1 claims rested on citations and the racket precedent,
not a first-hand run through a napi-rs addon; the spike ran them.

Two facts drive the shape:

- **arm64 forbids variadic `objc_msgSend`.** Each call site must cast it to a concrete
  `@convention(c)` pointer of the exact ABI shape — so typed native dispatch needs one
  compiled entry per distinct signature (ADR-0013). This is language-independent; it
  recurs here unchanged.
- **The N-API boundary is plain C, and Swift hosts C directly.** N-API is a pure C ABI
  (`napi_*` functions over opaque handles); Swift's C interop imports the Node-API headers
  and `@_cdecl` exports the module-init entry (`napi_register_module_v1`), so the *same*
  swiftc unit that generates the `@_cdecl` dispatch also hosts N-API — no separate Rust
  addon. Because dispatch is emitter-*generated*, napi-rs's macro ergonomics buy nothing.
  So, like the Lisp targets' *single* native unit (sbcl ADR-0038), the TS target's native
  core is **one** compiled unit (`napi-dispatch-spine-k35`, §2).

## Decision

### 1. Generated typed native dispatch, Swift-hosted (ADR-0013 shape)

`emit-typescript` generates **one Swift `@_cdecl` dispatch entry per distinct method
ABI signature**, exactly as racket/chez/gerbil/sbcl do. Each entry fetches
`objc_msgSend` once via `dlsym(RTLD_DEFAULT, "objc_msgSend")` (Swift's ObjectiveC
overlay marks it unavailable) and `unsafeBitCast`s it to the concrete
`@convention(c)` shape. Entry names are content-addressed by ABI signature
(`aw_ts_msg_<param-codes>_<ret-code>`), reconstructible by the emitter with no shared
counter — the ADR-0013 precedent.

*Spike evidence (probe 1, GREEN):* a scalar return (`-[NSString length]` → 12), `id`
round-tripping, and — the load-bearing case — a **CGRect struct-by-value return**
(`-[NSScreen frame]` → `{0,0,5120,2160}`) crossing the arm64 x8 indirect-return path
correctly, agreeing across a by-value return and an out-buffer cross-check. This is
the marshalling-depth thesis (ADR-0013 §struct-return) re-proven through Rust, and
the exact wall that rules Bun's *own* FFI out (see §4).

*Historical note — the interim two-unit spike.* `ts-substrate-spike-k3` proved the
dispatch mechanism through a **napi-rs (Rust) addon linking a Swift dylib** (a two-unit
pair) because that was the fastest way to a first-hand result. `napi-dispatch-spine-k35`
then confirmed the Rust layer is unnecessary — Swift hosts N-API directly — so the shipped
core is one unit (§2). Whether any hot signature ever wants a hand-tuned variant is an
emitter-tuning question (Q2), not a substrate reversal.

#### 1a. Free C functions are per-symbol exports over per-signature bodies

Everything above concerns **methods**, which multiplex through one `objc_msgSend` address
selected by selector — so the whole corpus folds into 998 signature-keyed entries. A **free
C function** is called *by its own address*, so it cannot fold: its 2192 exports (the
`objc_exposed` functions within the bindable frontier) are a floor. Its *bodies*, however,
differ only by ABI signature — 317 of them.

So the addon registers each `aw_ts_fn_<symbol>` export against a **shared per-signature napi
callback**, passing the symbol's descriptor (name, owning framework, retain convention, cached
address) as `napi_create_function`'s **`data`** payload; the callback reads it back through
`napi_get_cb_info` and casts the resolved address to the `@convention(c)` shape it was
generated for. Exports keys — and therefore the emitted `.ts` call sites and the
collected-equals-referenced mirror invariant — are untouched.

The descriptor carries the **retain convention** because it is the only per-symbol channel: the
body is shared per signature, so one `aw_ts_fnsig_P_P` serves both a +0 and a +1 object return.
A C function's object return follows the CF **Create Rule** (`Create`/`Copy` in the name → +1
owned → `__wrapOwned`; else +0 → `__wrapRetained`), and under uniform-+1 the **+0 case must fold
an `objc_retain`** in the entry — `__wrapRetained` does not retain, it takes a handle whose entry
already folded (ADR-0057 §4). Hence **no `…_o` sibling here**: the outbound family needs one only
because a single entry name serves many selectors, whereas here the export *is* the symbol. The
fold is gated on the return being a real object (`is_object_type`), not on its ABI being a
pointer — `NSClassFromString` returns a `Class` and `NSSelectorFromString` a `SEL`, neither
wrapped, neither folded. Realised whole-corpus by `fn-table-codegen-k69`: **2192 exports over 317
bodies**, 233 folding, in the generated `Generated/FunctionTable.swift`, with a unit proving
*collected == referenced* and the addon's `test/functions.mjs` proving both retain arms against a
live autorelease pool.

Each address is resolved on the entry's **first call** and cached: `dlsym(RTLD_DEFAULT)`,
then `dlopen` of the owning framework, then `dlsym` again. Laziness is forced, not chosen: a
cold `dlsym` over the corpus resolves **1 of 2192** symbols (the addon links only
libSystem/CoreFoundation/CreateML/Foundation/libobjc, while the corpus spans 73 frameworks),
a post-`dlopen` one resolves **2166**, and loading all 72 loadable frameworks up front costs
~90 ms and drags Metal/WebKit/Ruby/Tcl into every process. The **26** symbols that resolve
nowhere even once their framework is loaded — Ruby's header-only and deprecated declarations,
DirectoryService's two `dsIsDirService*Running` — **throw a JS `Error` naming symbol and
framework**; the addon never calls a null address and never silently no-ops.

Two consequences worth stating because they are invisible in the code. `dlopen` is the only
honest probe of a system framework: since Big Sur the binaries live solely in the **dyld
shared cache**, so the canonical `/System/Library/Frameworks/<N>.framework/<N>` path
`dlopen`s while `stat` reports it absent. And one IR "framework" is not a bundle at all —
`libdispatch`, which lives in libSystem and is always loaded — so its descriptors are marked
unbundled and a genuine miss is not misattributed to a missing image.

*Rejected, because both will otherwise be re-proposed.* **One baked Swift body per symbol**
buys nothing: it cannot reference the symbol directly either (`Ruby`, `Tcl`, `GLUT`, `vecLib`
expose no Swift module to `import`), so it `dlsym`s exactly as the shared body does — at 2192
bodies instead of 317, roughly doubling the generated Swift. **Resolving at registration**
yields a table of null addresses, per the 1-of-2192 measurement above. The sibling
`aw_ts_const_<code>(name)` mechanism is *not* the precedent to copy: it is a closed 13-entry
alphabet that takes the symbol name as a call argument, `dlsym`s per read, and degrades
silently to a zero value on a missing symbol.

### 2. The native core is one unit: a single Swift-native N-API addon (confirmed k35)

- **`APIAnywareTypeScript.node`** — one Swift-native N-API addon that Node/Deno load
  directly. It (a) `@_cdecl` exports `napi_register_module_v1` and hosts the Node-API C
  surface (the `napi_*` symbols resolved at `dlopen` against the host via `-undefined
  dynamic_lookup` — no `napi_*` implementation linked, so the addon stays engine-agnostic,
  §4); (b) generates one napi-callback dispatch entry per ABI signature that reads its
  JS `bigint`/scalar/string args, `unsafeBitCast`s `objc_msgSend`, and marshals the result
  back — the marshalling napi-rs used to do, now generated Swift; (c) carries the
  trampoline-elided Swift-native residual (`objc_exposed == false`) — its **mechanism** is
  **ADR-0061** (call-by-name napi-callback trampolines, `aw_ts_swift_*`), with the scalar
  free-function slice and the pointer/scalar constants (ADR-0055 §6) realised and the
  method/init/value-struct frontier a recorded follow-up-grove deferral — plus the fixed runtime
  primitives (class/selector lookup, release, autorelease pools, `cfstr`); and (d) will own the
  `napi_threadsafe_function`
  machinery (§3, ADR-0056) and reach the host loop via `napi_get_uv_event_loop`. ObjC
  pointers (id/SEL/Class) cross to JS as **BigInt opaque handles**; the durable
  object-model surface (branded/disposable handles + `.d.ts`) is ADR-0055.

One unit, the TS analogue of the sbcl §1 native unit (ADR-0038), keeps the ADR-0011
hermetic-isolation posture: the whole addon is per-target hermetic. The **frozen emitter
output is unaffected** by the one-vs-two-unit choice — the JS call sites and
content-addressed entry names are identical; only the Swift side hosts the marshalling that
was napi-rs's. `napi-dispatch-spine-k35` stood the unit up first-hand (Swift 6.3.3, Node
v26.4.0, arm64): the fixed primitives + a handful of `aw_ts_msg_*` entries load and an
emitted-golden-shaped binding round-trips (construct → dispatch → wrap → dispose), incl. a
struct-by-value return, with **no napi-rs / Rust**.

### 3. Thread-0 ownership: the native Cocoa runloop is authoritative and pumps the runtime

A macOS GUI app must let **AppKit own thread 0** (the ADR-0010 north star: the app is
a native macOS app). The spike settled the load-bearing unknown (research Gap 5): can
`NSApplication.run()` own thread 0 while Node's libuv loop still functions?

**Decision — the native runloop is authoritative and pumps the language runtime's
loop as a guest, not the reverse.** `NSApplication.run()` owns thread 0; the host
runtime's event loop is serviced from within the Cocoa runloop. For Node, the addon
reaches `uv_loop_t*` via the stable **`napi_get_uv_event_loop`** and pumps it
(`uv_run(NOWAIT)`) from a main-runloop source **registered in `kCFRunLoopCommonModes`**
(the load-bearing detail — see below).

*Spike evidence (probe 2, GREEN, controlled):* `setup_app` reports the Node main
thread **is** AppKit's thread 0. Naive cede (`NSApp.run()`, no pump) draws the window
and runs the Cocoa loop but **starves libuv** (0 Node timer ticks). The integrated
model (`NSApp.run()` + a runloop timer pumping `uv_run(NOWAIT)`) yields **21 Node
`setInterval` ticks and 21 threadsafe-function callbacks firing *during*
`NSApp.run()`** — dispositive, since Node's own `uv_run(DEFAULT)` is suspended.

*The polarity is validated here against the primacy analysis*
(`targets/typescript/docs/research/2026-07-05-libuv-runloop-primacy.md`), which
promoted §3 from a principle-plus-one-probe call to a **decisive measured criterion**:
AppKit routinely spins its *own* nested runloops on thread 0 (modal sessions, menu
tracking, live-resize — Apple: a modal loop "does not perform any tasks … not
associated with the modal run loop"; a tracking loop leaves "the main thread … unable
to process any other requests … timers might not fire"). During those, a **libuv-primary
manual pump (2b) never regains control and libuv starves** — routine UI, not an edge
case. 2c survives *only because* a source in `kCFRunLoopCommonModes` (= default + modal
+ event-tracking) keeps firing across those nested modes; a default-mode-only source
would die too. The governing constraint is broader than "keep libuv ticking": **the
binding must not break the runtime's own threading facilities** (Node's libuv
threadpool completions, `worker_threads`, timers, the `nextTick`/microtask contract).
2c with the common-modes source is the only model that preserves both the native UI
loop and the full runtime concurrency model.

*Mechanism deferred to the threading ADR (ADR-0056).* The spike's 4 ms polling pump
calls `uv_run(NOWAIT)` **nested inside** the outer `uv_run(DEFAULT)` — which libuv
documents as unsupported ("`uv_run()` is not reentrant. It must not be called from a
callback"); it ran without crashing by accident of the implementation, not by contract,
so production **must not** ship the nested poll. ADR-0056 fixes the mechanism
(Electron's helper-thread shape as the proven baseline; a single-threaded
`CFFileDescriptor`-on-`uv_backend_fd` shape evaluated head-to-head by the k6 spike),
the common-modes invariant, and the bg→main callback bounce (`napi_threadsafe_function`,
the sbcl ADR-0035 analogue, spike probe 3 GREEN natively).

### 4. Engine-agnostic via N-API — Node is *reference*, not *the* runtime

The one `.node` addon is portable across N-API hosts, so Node is the *reference*
runtime without betting the target's future on it (the D1 longevity hedge).

*Spike evidence (probe 4, first-hand on Bun 1.3.14):* the **same** unmodified addon
passes dispatch (incl. the CGRect struct return) **and** the threadsafe-function
bounce on Bun. The only Bun failure is the *Node-specific* loop integration — Bun's
JSC loop shims `napi_get_uv_event_loop` but not `uv_run` (clean panic; Bun issue
#18546), so §3's pump is Node/Deno-shaped and a Bun GUI host would need Bun's own
loop-drain primitive.

This **corrects the pre-spike framing**: the "struct-by-value wall" that ruled Bun out
as *reference* is a **`bun:ffi`** limitation (Bun's own FFI can't return `CGRect` by
value) — **moot for the N-API substrate**, where the struct is marshalled natively
below the runtime's view. Bun's disqualification as *reference* rests instead on **(a)**
the libuv/`uv_run` GUI-integration gap and **(b)** ecosystem longevity, not the struct
wall. The Deno leg was not run first-hand (Deno absent on the spike host); the primacy
analysis then **corrected the earlier "expected to port" claim** by reading Deno's
source (`denoland/deno` `ext/napi`): Deno's `napi_get_uv_event_loop` returns a **shim**
(the `Env` pointer cast to `uv_loop_t*`) and its Tokio-backed uv polyfill implements
`uv_async_*`/`uv_timer_*` but **not** `uv_backend_fd`/`uv_backend_timeout`/`uv_run` — so
§3's embedding integration **does not port to Deno unchanged**; a Deno GUI host needs
Deno's own loop-drain primitive (like Bun). Dispatch + tsfn are still expected to port;
only the loop-integration seam is Node-specific.

## Consequences

- **`emit-typescript`** generates the Swift napi-callback dispatch table — one entry per
  ABI signature, each reading its JS args, dispatching `objc_msgSend`, and marshalling the
  result (gitignored, reproducible from the IR, per ADR-0013/0038). A libffi/`objc2`
  fallback is retained for any statically un-typable signature (ADR-0013 escape hatch).
- **Build order:** `generate → swift build (APIAnywareTypeScript.node, linked with
  `-undefined dynamic_lookup`)` — one step, no cargo. The `.node` is vendored into the app
  bundle by `bundle-typescript` (Q7, `ts-design-grill-k4`); the Swift runtime is OS-resident
  (macOS ≥ 12), so no vendored Swift runtime (sbcl ADR-0038 §6 precedent).
- **Hard to reverse:** the single-Swift-native-unit shape, the Swift-hosted `@_cdecl`
  dispatch + napi-hosting convention, the BigInt-handle boundary, and the native-runloop-
  authoritative polarity are baked into the emitter, every sample app, and the bundler.
- **Cross-target implication (out of scope; new grove).** The §3 polarity generalizes,
  but the primacy analysis sharpened *how*: the principle is **not** "one loop pumps
  all." It splits by runtime kind — runtimes with a **mandatory main-thread loop**
  (Node/libuv; Deno; Bun; a future Python/asyncio) get their *main loop* pumped as a
  guest while their *other* threads run natively; runtimes with **their own thread
  system but no mandatory main-thread loop** (the Lisp four — sbcl `sb-thread`, racket,
  gerbil green threads) **cede** thread 0 and **bounce** (ADR-0014/0022/0035), their
  schedulers **never** driven from the runloop (doing so would break `sb-thread`). The
  unifying invariant is **"the binding must not break the runtime's own threading
  facilities."** A separate grove investigates the repercussions across
  ADR-0014/0022/0035 and ADR-0049 (app-kinds); it inherits this distinction rather than
  rediscovering it. Captured, not absorbed here.
- Applies the **ADR-0010** economics (generated bespoke native code per target),
  target-local under **ADR-0011**, and the elided limit of the **ADR-0025** complete-
  API model.

See `CONTEXT.md` (*TypeScript target toolchain*), ADR-0013 (the dispatch mechanism
this realizes), ADR-0038 (the closest native-unit sibling), ADR-0025 (trampoline
elision), ADR-0010/0011 (the north star + isolation), and the spike FINDINGS for the
first-hand evidence. The Q2–Q7 ADRs (`ts-design-grill-k4`) will cite this as the
substrate they build on.
