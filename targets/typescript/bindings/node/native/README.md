# `APIAnywareTypeScript` — the native adapter (Swift-native N-API addon)

The Node TypeScript target's native core: a single Swift `.node` addon that provides the
bodies for the dispatch seam the runtime declares (`@apianyware/runtime`, `dispatch.ts`).
It is the `typescript` target's **sole native unit** (ADR-0011 hermetic isolation) — the
first concrete application of ADR-0010 (the per-target native library *is* the binding) to
an N-API runtime.

## Core language: Swift-native N-API, no Rust (ADR-0054 §2, confirmed here)

`ts-substrate-spike-k3` proved the dispatch mechanism through a **napi-rs (Rust) addon +
Swift dylib** (two native units). `napi-dispatch-spine-k35` confirmed first-hand that the
napi-rs layer can be **dropped**: a Swift `@_cdecl("napi_register_module_v1")` unit hosts
N-API directly — imports the Node-API C headers, builds napi values (functions, bigints,
strings, objects, doubles), reads JS arguments, and does the generated `objc_msgSend`
dispatch — all in one `.node`. The N-API symbols are resolved at `dlopen` against the Node
host (`-undefined dynamic_lookup`), so no `napi_*` implementation is linked here and the
addon stays engine-agnostic (ADR-0054 §4).

This collapses the native core from three units to two (**the Swift `.node` *is* the addon**,
plus the C++ `pump_shim.cc` a later child adds for the libuv pump) and drops the Rust
toolchain. Because dispatch is emitter-*generated*, napi-rs's macro ergonomics earned
nothing — the marshalling that napi-rs did (read JS args → call the raw dispatch entry →
return JS value) is generated Swift here instead. The frozen emitter output (JS call sites,
content-addressed entry names) is **unchanged** by this decision — only the Swift side's
shape moves (each `aw_ts_msg_*` entry is now a napi callback that dispatches inline).

**Residual risk for later children:** Swift *concurrency* on the libuv loop thread (the
pump / tsfn bounce, ADR-0056) was not exercised by this outbound-only spine — FINDINGS §D5
flagged it as the one place napi-rs might have been retained. If the pump child (ADR-0056)
hits Swift-concurrency-on-the-loop-thread trouble, revisit; the outbound dispatch substrate
is settled Swift-native.

## Layout

```
src/shim.h              bridging header — #include <node_api.h>
src/napi_support.swift  N-API marshalling helpers (read/make bigint, string, number, object, array, call)
src/dispatch.swift      objc runtime bindings + fixed primitives (incl. selectorName/className — sel_getName/class_getName, the inverses of getSelector/getClass that let a SEL return come back as its name and a Class return resolve to its bound constructor; ADR-0055 §3/§5b) + aw_ts_const_<code> constant reads + module init (the per-signature aw_ts_msg_* table is GENERATED, below)
src/trampolines.swift   the object-return marshalling PROBE (aw_ts_swift_probe_objectReturn) — fixed machinery; the per-symbol aw_ts_swift_<Module>_<name> residual trampolines are GENERATED, below (ADR-0061, ADR-0027 → TS)
src/awexc.m             the ObjC (MRC) exception-catch shim: objc_msgSend inside @try/@catch for the …_e entries (ADR-0058) — the one non-Swift unit
src/inbound.swift       inbound MACHINERY: delivery cores, subclass/delegate synthesis, the shared respondsToSelector:/dealloc IMPs, block bracket (ADR-0059) — the per-signature tables are GENERATED, below
src/Generated/          gitignored, rendered from the IR by `apianyware-generate --target typescript` (build order: generate → build.sh); one napi/IMP entry per distinct ABI signature, content-addressed, so call sites and tables agree with no shared state
  DispatchTable.swift   outbound: aw_ts_msg_<code> (+ the …_o non-folding +1 and …_e @catch siblings) + awRegisterGeneratedDispatch  (outbound-dispatch-table-k58)
  InboundTable.swift    inbound: aw_ts_inb_<code> typed IMPs + awGeneratedInboundIMP(forEncoding:) (k61); the noescape/escaping block-maker switches (k62); aw_ts_super_<code> $super entries + awRegisterGeneratedSuperSends (k63)
  TrampolineTable.swift Swift-native s: residual: one call-by-name aw_ts_swift_<Module>_<name> napi callback per residual free function + awRegisterGeneratedTrampolines (swift-residual-cli-pass-k65) — 43 entries, keyed per SYMBOL, not per signature
src/bounce.swift        off-main bg→main bounce (napi_threadsafe_function) + postCallbackCompletion + installValueReturningDeliverer + installBlockReleaseDeliverer + awBounceDealloc (ADR-0056 §3 / ADR-0059 §4)
src/pump.swift          the libuv pump — ADR-0056 mechanism (c), the helper-thread shape (reusable core)
src/pump_shim.cc        the V8-scoped pump body — uv_run(NOWAIT) in HandleScope+Context::Scope+microtask checkpoint (finding A)
build.sh                clang (awexc.m) + swiftc → build/APIAnywareTypeScript.node  (-undefined dynamic_lookup)
harness/embed_main.mm   the k42 test harness: an ObjC++ main()-owner that embeds Node under AppKit + drives the pump
harness/app.cjs         the harness JS: the k6 facilities battery + finding-C tests + a real dispatch round-trip + the k43 bounce test + the k44 off-main-delivery test + the k45 escaping-block test + the k46 off-main-dealloc test
harness/build.sh        clang++ (pump_shim.cc, embed_main.mm) + swiftc link → harness/build/embed_harness (links libnode + libuv + AppKit)
test/spine.mjs          integration check: outbound — round-trips a golden-shaped binding
test/inbound.mjs        integration check: inbound — a JS subclass override called by Foundation
test/delegate.mjs       integration check: inbound — a JS delegate called by NSKeyedArchiver
test/block.mjs          integration check: inbound — a JS closure called as an NS_NOESCAPE block
test/super.mjs          integration check: inbound — $super, overridable dealloc, added methods (§4)
test/retain.mjs         integration check: outbound — retain-fold reconciliation, uniform +1 via -retainCount
test/error.mjs          integration check: outbound — the …_e @catch entries: native NSException, NSError writer, fold-iff-+0
test/sel-class.mjs      integration check: outbound — the SEL/Class VALUE surface: setAction:/action round-trips a selector name, a Class return resolves to the bound constructor, a private class (NSTaggedPointerString) round-trips via a stand-in (sel-classref-surface-k72)
test/constants.mjs      integration check: outbound — the aw_ts_const_<code> reads: pointer-valued object global (+1 fold), scalar global
test/swift-native.mjs   integration check: outbound — the aw_ts_swift_* residual trampoline: CoreGraphics.hypot(CGFloat,CGFloat) call-by-name (ADR-0061)
test/swift-native-object.mjs integration check: outbound — the aw_ts_swift_* object-return marshalling shape: String→NSString bridge → +1 handle → __wrapOwned (ADR-0061 §3)
test/geometry.mjs       integration check: outbound — the POD geometry family (ADR-0055 §5): the by-value struct crossing both ways, through free functions (NSInsetRect/NSContainsRect), method dispatch (+[NSValue valueWithRect:] / -rectValue), and the hello-window shape (-[NSWindow initWithContentRect:styleMask:backing:defer:] → -frame → frame.origin into -setFrameOrigin:); the JS object mirrors the C struct, so CGRect is nested (pod-struct-types-k73)
test/dynamic-class.mjs  integration check: outbound — the DYNAMIC class wrap (ADR-0057 §3b): a slot the IR names no class for (`-[NSArray objectAtIndex:]` → `id`) mints as the nearest BOUND ancestor, not a bare NSObject, so the real class's methods are actually there. Measures the class-cluster fact that forces the superclass climb (an NSString is really an NSTaggedPointerString, an NSArray an __NSSingleObjectArrayI), proves the live-wrapper path still costs zero class crossings, reads ownership off -retainCount, and negative-controls a wholly-unbound hierarchy (NSDateFormatter → the §5b stand-in) (dynamic-class-wrap-k88)
```

## What the spine provides (napi-dispatch-spine-k35)

The fixed `NativeDispatch` primitives (`getClass`, `getSelector`, `release`,
`pushAutoreleasePool`, `popAutoreleasePool`, `cfstr`) + a handful of content-addressed
`aw_ts_msg_<codes>` entries (`0_Q`, `0_q`, `q_v`, `0_P`, `P_P`, `0_R`, `P_G`) — enough to
run one emitted-golden-shaped binding end-to-end.

## What the inbound direction provides (subclass-inbound-on-main-k37)

The **on-thread-0 dynamic-subclass** slice of ADR-0059 (`src/inbound.swift`):

- `installCallbackInvoker(fn)` — capture the thread-0 `napi_env` + a `napi_ref` to the runtime's
  `__invokeCallback`, so an **env-less ObjC IMP** can reach JS (the inbound crux: unlike the
  outbound napi callbacks, a trampoline is invoked by the ObjC runtime with no `env`). Legal only on
  thread 0.
- `defineSubclass(baseClass, name, overrides)` — `objc_allocateClassPair` + a back-ref ivar
  (`__aw_cbid`) + `class_addMethod` a **generated typed inbound trampoline** per `"<selector>|<enc>"`
  override (content-addressed by ObjC type encoding — the inbound dual of the `aw_ts_msg_*` codes).
- `allocInit(cls)` / `setBackRef(instance, callbackId)` — construct a `+1` instance and stamp its JS
  `CallbackId` into the ivar.
- The `q@:@` trampoline (`-compare:`-shaped, NSInteger return) delivers synchronously to
  `__invokeCallback` and returns the JS value — or the typed nil/0 default on a JS throw / stale id
  (the ADR-0058 native-`@catch` mirror; no exception unwinds the C ABI). Every raw ObjC id stays a
  `UInt` touched only through `@convention(c)` calls — never bridged to a Swift `AnyObject` (which
  would insert an ARC release and over-release the live receiver).

## What the delegate direction provides (delegate-inbound-on-main-k38)

The **on-thread-0 delegate / data-source** slice of ADR-0059 §3/§6 (`src/inbound.swift`), the delegate
surface built on the subclass child's shared machinery:

- `defineForwarder(protocol, name, overrides)` — synthesize ONE **per-protocol** forwarding class
  (base `NSObject`, memoized by the runtime — never per-object): the back-ref ivar (`__aw_cbid`), a
  responds-snapshot ivar (`__aw_responds`), a typed trampoline IMP per `"<selector>|<enc>"` override,
  and a shared **`respondsToSelector:` override** that answers from the per-instance snapshot; a
  registered ObjC `Protocol` is `class_addProtocol`'d best-effort.
- `setRespondsBits(instance, bits)` — stamp the **set-time `respondsToSelector:` snapshot** (bit `i`
  set iff the JS delegate implements protocol method `i`) into the instance's bitset ivar, so
  `@optional` fidelity is *exact* and per-instance — the load-bearing correctness point (a class-level
  answer is NativeScript's invisible-rows bug). Bounded to 64 methods/protocol (a hard runtime error
  past that; see `runtime/src/delegate.ts`).
- `bindDelegate(owner, setterSel, forwarder, associate, propertyKey)` — the set-time compound op:
  send `owner.<setter>(forwarder)`, install the strong `objc_setAssociatedObject` **keep-alive** iff
  `associate` (the delegate-retain caveat — most delegate setters don't retain), and balance the
  caller's alloc `+1` so the association (weak slot) or the framework (strong slot) is the sole owner.
- `allocInitWithObject(cls, initSel, arg)` — a one-object-arg `+1`-owned designated initializer
  (companion to `allocInit`), e.g. `-[NSKeyedArchiver initForWritingWithMutableData:]`.
- New trampolines `q@:` (no-arg NSInteger) and `@@:@@` (two-id → id); new outbound entries
  `aw_ts_msg_P_B` (BOOL query, e.g. `-respondsToSelector:`), `aw_ts_msg_PP_v`, `aw_ts_msg_0_v`.

Proven headless by `test/delegate.mjs`: `respondsToSelector:` fidelity (implemented → YES, unimplemented
→ NO, inherited → YES), value-returning delivery, boundary containment; and — genuinely
framework-driven — **NSKeyedArchiver** (whose `delegate` is *unretained*) drives `archiver:willEncodeObject:`
on a JS delegate kept alive *only* by the association, while a second delegate sharing the same class but
not implementing it is never called (per-instance snapshot honored end-to-end).

## What the blocks direction provides (block-noescape-on-main-k39)

The **on-thread-0 `NS_NOESCAPE`** slice of ADR-0059 §2 (`src/inbound.swift`), the blocks surface built
on the subclass/delegate children's shared delivery core — the direct-invoke fast path, tsfn-free (the
**escaping** default half is the k45 section below):

- `makeBlock(callbackId, signature)` — build a **real ObjC block** whose invoke is the typed inbound
  trampoline for `signature`, capturing the `CallbackId`. A block has **no selector and no back-ref
  ivar** (unlike the subclass/delegate IMPs): the id is captured directly in a `@convention(block)`
  Swift closure, so the runtime's `__invokeCallback` reaches the fn via its `call.selector ===
  undefined` branch (the registered target *is* the callable). The closure is `_Block_copy`'d to the
  heap (so it survives the make→dispatch JS round-trip) and returned as a block-pointer handle the
  emitted call site passes as the block argument to the **ordinary outbound entry** (a block crosses as
  an `id` — `-enumerateObjectsUsingBlock:` reuses `aw_ts_msg_P_v`). `signature` content-addresses the
  block ABI, e.g. `PQP_v` = `void (^)(id obj, NSUInteger idx, BOOL *stop)` (the shared inbound code alphabet — a `BOOL*` out-pointer is a pointer `P`, crossing to JS as a raw handle).
- `releaseBlock(handle)` — `_Block_release` the heap block, balancing its `_Block_copy` +1. The runtime
  brackets `makeBlock`/`releaseBlock` (+ the callback register/release) around the outbound call
  (`__withNoescapeBlock`, `runtime/src/blocks.ts`), so the JS fn is held **only for the call's
  duration** — no tsfn, no heap persistence (the `NS_NOESCAPE` guarantee).

The invoke marshals its args **typed per the block signature** (`obj` → an id handle, `idx` → a JS
number), delivers via the shared `invokeInbound` with no selector, and contains a throwing body at the
boundary (the ADR-0058 `@catch` mirror). Proven headless by `test/block.mjs`: a JS closure passed to
`-[NSArray enumerateObjectsUsingBlock:]` is invoked **synchronously on thread 0** for each element in
order (the JS body observes them), a second enumerate re-brackets cleanly (the fn is not leaked /
over-released), and a throw-every-element body is contained once per element (no C-ABI unwind).

## What $super / dealloc / added methods provides (super-dealloc-on-main-k40)

The **on-thread-0 dynamic-subclass §4 surface** of ADR-0059 (`src/inbound.swift`), built on the
subclass/delegate/block children's shared machinery — three pieces, one leaf:

- **`$super` (`objc_msgSendSuper`).** Per-signature `aw_ts_super_<code>` entries — the super-send
  analogue of the outbound `aw_ts_msg_*`, content-addressed the same way. Each takes `(recvHandle,
  superClassHandle, selHandle, …args)`, builds an `objc_super {receiver, super_class}` (a Swift
  `(UInt, UInt)` tuple passed by address), and dispatches via `objc_msgSendSuper` — **method lookup
  begins at `super_class`** (the emitted parent's `__cls`), so it reaches the base impl and skips the
  synthesized subclass's own override (the ADR-0034 `call-next-method` infinite-recursion trap native
  `super.` would hit). **GENERATED since `super-send-table-k63`** — rendered from the IR into
  `src/Generated/InboundTable.swift`, registered by `awRegisterGeneratedSuperSends`, replacing the
  hand-written `aw_ts_super_0_v` / `aw_ts_super_P_B` pair (whose drifted `P_B` canonicalises to
  `P_b`). The frontier is the **IMP frontier** — a super-send exists exactly where an override can —
  and the code alphabet is the same `InboundSig::code_string` that names the IMPs, so no second
  alphabet exists. One extra axis: a super-send's *return* crosses to JS like an outbound return, so
  it carries the ADR-0057 §4 retain-fold (`+0` folds `objcRetain`; a `+1` return — an overridden
  `init`/`copy` reached through `$super` — routes to the non-folding `…_o` sibling).
- **Overridable `dealloc`, on thread 0.** A shared `-dealloc` IMP is installed on **every** synthesized
  subclass / forwarder (`installDeallocIMP`, encoding `v@:`). On dealloc it resolves the back-ref →
  `CallbackId`, delivers to the runtime's `__deliverDealloc` (which runs the JS `dealloc` override if
  one exists — against a **live** handle, ADR-0057 §6 ordering — and **drops the `callbacks`-registry
  keep-alive**), then — only if there was **no** JS override — chains `[super dealloc]` natively
  (`super_class = class_getSuperclass(object_getClass(self))`; an override is obligated to chain
  `this.$super.dealloc()` itself, matching ObjC). This **closes the k37/k38 registry-release loop**: the
  strong registry entry that pinned a bound subclass/delegate is finally released when the ObjC instance
  dies. `installDeallocDeliverer(fn)` captures the thread-0 `napi_env` + a `napi_ref` to
  `__deliverDealloc` (the env-less-IMP crux, installed alongside `installCallbackInvoker`).
- **Added ObjC-reachable methods (`class_addMethod`).** A target-action `-buttonClicked:(id)sender`
  (a selector **not** on the base) installs via the same synthesis path as an override; new trampoline
  `v@:@` (void, one id arg) serves it, and `c@:@` serves a value-returning BOOL override (`-isEqual:`).

Proven headless by `test/super.mjs`: a value-returning `$super` reaches base identity with no recursion;
a subclass with a JS `dealloc` (dispose path) runs it against a live handle, chains super, and releases
its registry entry; a subclass with **no** override still releases it (native super-chain); a forwarder
releases it on direct release **and** on a genuine **NSKeyedArchiver** association drop; a
`class_addMethod`-added target-action reaches JS with its sender and contains a throwing body.

## What the libuv pump + embedder harness provides (embed-pump-harness-k42)

The **libuv pump** (ADR-0056 mechanism (c)) that services Node's event loop as a guest on AppKit's
thread 0 — the first child of `libuv-pump-k41`, realising the finding-A/B/C entry architecture
**first-hand under the production shape** (not the k6 blocking-call harness):

- **`src/pump.swift`** (reusable native core) — the helper-thread pump: a dedicated thread `poll`s
  `uv_backend_fd` (timeout = `uv_backend_timeout`, re-read every pass), signals a
  `kCFRunLoopCommonModes` `CFRunLoopSource` on thread 0, and lock-steps **one** `uv_run(NOWAIT)` per
  wake through a semaphore (the two threads never touch the loop concurrently). `@_cdecl` surface:
  `aw_rl_pump_start(loop, pumpV8)` / `aw_rl_pump_nudge` / `aw_rl_pump_teardown` / `aw_rl_pump_stats` +
  the nested-runloop markers. libuv symbols resolve via `dlsym(RTLD_DEFAULT, …)` (the shared libuv the
  host links). CoreFoundation only — no AppKit dependency; the launcher owns the app lifecycle.
- **`src/pump_shim.cc`** (reusable native core) — the V8-scoped pump body (finding A): `uv_run(NOWAIT)`
  inside `v8::HandleScope` + `Context::Scope` + `PerformMicrotaskCheckpoint`. A bare `uv_run` from a
  runloop callback crashes `node::Environment::CheckImmediate` on the first `setImmediate`; napi's
  public surface exposes neither the scope nor the checkpoint, so this small C++ shim is required.
- **`harness/embed_main.mm`** (test-only) — a minimal native `main()`-owner (**not** the shipped
  `bundle-typescript` launcher; that is Step 8 / ADR-0060): embeds Node via `InitializeOncePerProcess`
  + `MultiIsolatePlatform` + `CommonEnvironmentSetup` + `LoadEnvironment` (links `libnode` + shared
  `libuv`), keeps the V8 isolate entered on thread 0, hands thread 0 to `NSApp.run()`, and starts the
  pump. Reads the JS results back via V8; owns the nested-runloop-survival verdict natively.

Proven first-hand on arm64 by `harness/build/embed_harness`: under `NSApp.run()` with the pump
servicing libuv as a guest, the k6 facilities battery is GREEN — `setTimeout`/`setImmediate`,
threadpool completion (`crypto`/`fs`), `worker_threads` (own thread, runs + joins), `nextTick`/
microtask ordering, and the **stale-`uv_backend_timeout`** case — **plus the finding-C tests the k6
blocking-call harness structurally could not pass** (a `process.nextTick`/Promise microtask enqueued
from a libuv timer callback drains, because the native side owns `main()` with no ambient blocking
JS→native call). Nested-runloop survival is re-confirmed (a common-modes source keeps firing across a
1.0 s `NSEventTrackingRunLoopMode` window; a default-mode control starves). The real seam round-trips
too: the ESM `@apianyware/runtime` + the `-undefined dynamic_lookup` `.node` load into the **embedded**
Node, `__installDispatch` binds, and `-[NSString length]` dispatches — addon + runtime + embedder +
pump coexisting in one process. Teardown is clean (the pump closes its own `uv_async` handle so the
embedder's `uv_loop_close` does not abort).

**Not yet**: the **plain-C free-function `aw_ts_fn_<name>` entry table** (~2299 symbols — the
`fn-entry-table` child; the emitted `.ts` names them, the addon exports none, so every
`functions.ts` C call is a JS `TypeError` today); the **hardened teardown**
(uv_walk/uv_close/`uv_run(UV_RUN_DEFAULT)`/`uv_loop_close`, verified deadlock-free — a
`libuv-pump-k41` sibling); the **remaining Swift-native `s:` free-function residual** — `throws` →
`Result` and the near-empty wider-scalar alphabet (recorded-deferred, not built — ADR-0061 §3),
plus the method/init/value-struct residual (a recorded follow-up-grove deferral, ADR-0061 §4).
(The retain-fold reconciliation, ADR-0057 §4, the error-`@catch` `…_e` entries producing
`NativeErrorResult`, ADR-0058, the `aw_ts_const_<code>` constant reads, ADR-0025/0055 §6, the
outbound/inbound generated tables, **and** the generated Swift-native `s:` residual trampoline
table — **scalar** and **object / bridged-value / string returns**, ADR-0061/0027 — are **done**;
see their sections below.)

## What the background→main bounce provides (tsfn-bounce-k43)

The **off-main callback delivery** half of ADR-0056 §3 (`src/bounce.swift`) — the second child of
`libuv-pump-k41`, built on the pump above. A callback arriving on any **non-main** thread (a GCD
worker, a framework completion thread, a libuv threadpool thread) must never re-enter JS off-main; it
bounces to thread 0 (where JS runs, AppKit's thread 0) via a **singleton `napi_threadsafe_function`**
created once on thread 0 (`installValueReturningDeliverer`, from `__ensureInbound`). Off-main the addon
touches **no napi** — the call is carried as raw C values in a heap `BounceCall`, `passRetained` into
the tsfn `data`, and re-marshalled to napi values by the tsfn's `call_js` **on thread 0**.

- **void** — `awBounceVoid`: a **blocking-mode** tsfn enqueue (backpressure, no silent drop — `0`
  queue-size + `napi_tsfn_blocking`); the bg thread does **not** wait. Thread 0 runs the runtime's
  `__invokeCallback` and ignores the return (a JS throw is already contained + reported there, §7).
- **value-returning** — `awBounceValue`: the blocking tsfn enqueue **plus a completion semaphore** the
  bg thread blocks on (the `dispatch_sync`-to-main analogue). Thread 0 runs the runtime's
  `__deliverValueReturning(completion, call)`, which **always** posts the result back through
  **`postCallbackCompletion`** — marshal `result.value` into the completion's slot per its ABI return
  kind (or the typed default `0` on a contained `threw`), then post the semaphore exactly once (a
  thread-0 `posted` guard coordinates the deliver path with the `call_js` teardown fallback). The bg
  thread wakes, reads the slot, and returns it as the C-ABI return.

The **deadlock caveat** (ADR-0056 §3) carries over: a value-returning bounce while thread 0 is
*synchronously blocked* deadlocks (thread 0 cannot run the `call_js`) — the `dispatch_sync` analogue;
void bounces are immune. The tsfn is `unref`'d so it never itself keeps the loop alive (the pump owns
liveness) — which is also why a plain `node test/*.mjs` still exits after `__ensureInbound` runs.

The *actual* off-main trampolines that detect off-main and choose a mode are built by
`off-main-delivery-k44` (below); this leaf provides the mechanism they route through. Proven first-hand
on arm64 under `harness/build/embed_harness` (`aw_test_bounce` + `harness/app.cjs`): from a **real GCD
background thread**, a value-returning bounce round-trips `41 → 42` back through the completion
semaphore; a throwing callback still unblocks the bg thread with the typed default `0` (the always-post
discipline); a void bounce delivers on thread 0. Every bounced callback lands on thread 0 (`isMainThread`
verified from JS), never off-main.

## What the off-main inbound delivery provides (off-main-delivery-k44)

The **off-main dual** of the on-thread-0 delivery core (`src/inbound.swift`) — the fifth
`inbound-trampolines-k36` child, consuming the `tsfn-bounce-k43` mechanism above. The shared
subclass/delegate delivery core (`deliverInt64` / `deliverId` / `deliverVoid` / `deliverBool`) now
detects when a typed inbound trampoline fires on a **non-main** thread (`pthread_main_np() == 0`) and
routes through the bounce instead of the direct on-thread-0 path — never re-entering JS off-main. The
on-thread-0 fast path is unchanged (the branch is a single `if` at the top of each `deliver*`). Because
both the subclass and delegate surfaces share this core, **one change makes both off-main-aware**.

Off-main a trampoline may touch **no napi and no registry** (ADR-0059 Mechanics): it only reads the
back-ref ivar (a raw pointer read) and the selector off `_cmd` (`sel_getName`), gathers its id args as
raw `[BounceArg]` `.handle`s, and hands them to the bounce — the registry read + JS invocation + napi
all happen on thread 0 inside the tsfn `call_js`.

- **void** (e.g. an added `v@:@` target-action) → `awBounceVoid`: fire-and-forget; the bg thread does
  not wait (a JS throw is contained + reported on thread 0).
- **value-returning** (`q@:@` `NSInteger`, `@…@` id, `c@:@` `BOOL`) → `awBounceValue` with the matching
  `BounceReturnKind`: block the bg thread on the completion semaphore, then **reinterpret the returned
  `UInt64` slot** as the typed C-ABI return (`Int64(bitPattern:)` for `NSInteger`, `UInt` for an id,
  `!= 0` for `BOOL`). The always-post discipline holds on a contained JS throw — the bg thread unblocks
  with the typed default `0`.

The **deadlock caveat** (ADR-0056 §3) carries over: a value-returning bounce while thread 0 is
*synchronously blocked* deadlocks; void is immune. The off-main synchronous `dealloc` bounce (§4) — the
last off-main path — is built by `dealloc-off-main-k46` (its own section below). (The escaping
heap-block + off-main teardown — the other off-main half of blocks, §2 — is also built; see the
escaping-blocks section.)

Proven first-hand on arm64 under `harness/build/embed_harness` (`aw_test_off_main_delivery` +
`harness/app.cjs`, the real-trampoline analogue of k43's mechanism-only `aw_test_bounce`): a JS subclass
of `NSObject` overrides value-returning + void selectors, then from a **real GCD background thread** an
`objc_msgSend` of each overridden selector bounces to thread 0 — the value-returning override
round-trips its JS return `42` through the semaphore, a throwing override still unblocks the bg thread
with `0`, a void override delivers on thread 0, and **every** override's JS body ran on thread 0
(`isMainThread` verified from JS), never off-main.

## What the escaping blocks direction provides (block-escaping-off-main-k45)

The **escaping / unknown** default path of ADR-0059 §2 (`src/inbound.swift`) — the off-main dual of the
`NS_NOESCAPE` fast path (k39) and the sixth `inbound-trampolines-k36` child. A JS function passed where an
ObjC block parameter is expected where the block **escapes** — stored by the framework and invoked later
(a completion handler, a notification block, a stored observer), possibly **off thread 0** — is wrapped
into a **real heap ObjC block that outlives the enclosing call**, with the JS function **pinned** for as
long as the block can fire and every invoke delivered on thread 0.

- `makeEscapingBlock(callbackId, signature)` — build a heap block whose invoke is the typed inbound
  trampoline for `signature` (`_v` = `void (^)(void)`, `P_v` = `void (^)(id)`, `P_B` = `BOOL (^)(id)`),
  `_Block_copy`'d to the heap and returned as the sole `+1`. Delivery reuses the shared core: on thread 0
  it invokes `invokeInbound` directly (the fast path — a value-returning block needs the result *now*, so
  it must not bounce to self); off thread 0 it routes through the **singleton** `awBounceVoid` /
  `awBounceValue` (k43/k44) — void fire-and-forget, value-returning round-tripped through the completion
  semaphore. A throwing body is contained + reported on thread 0 inside `__invokeCallback` (no C-ABI
  unwind through the pump, §7).

**The one genuine design choice (ADR-0059 §2 reconciled in place).** The JS function is held by the
**runtime registry** (a monotonic `CallbackId`, exactly like the noescape path), **not** a per-block
delivery/holder tsfn. So delivery reuses the singleton bounce and containment/reporting flow through the
registry-keyed `__invokeCallback` uniformly. The tsfn's §2 role is thereby **refined to teardown**: when
the framework does the last `_Block_release` — on **any** thread — the block's captured Swift
`EscapingBlockHolder` (a strong capture in the `@convention(block)` closure, so its dispose helper releases
it) has its `deinit` fire on that thread and **`awBounceReleaseCallback`s the registry drop to thread 0**
(via the singleton bounce's new `release` path + `installBlockReleaseDeliverer` → the runtime's
`__releaseCallback`) — the ADR-0057 release-on-thread-0 seam. Rationale: because containment lives in the
registry-keyed `__invokeCallback`, the fn must be in the registry regardless — so a per-block tsfn could
only *route teardown*, a job the singleton already does without a per-block `uv_async_t` (the ADR §2
handle-exhaustion concern). Every property the ADR requires holds: pinned while live, released on
teardown, teardown legal off-main, the JS-ref drop on thread 0. This is exactly **why escaping needs the
tsfn seam and noescape does not**: noescape teardown is synchronous on thread 0 in the runtime `finally`
(`__withNoescapeBlock`); escaping teardown is asynchronous, possibly off-main, and only the tsfn can
legally route the drop from any thread to thread 0. The runtime bracket is `__makeEscapingBlock`
(`runtime/src/blocks.ts`) — register the fn, ask for the block, and **do not release** (no `finally`); the
native teardown drops the registry entry.

Proven first-hand on arm64 under `harness/build/embed_harness` (`aw_test_escaping_block_delivery` +
`harness/app.cjs`): the runtime makes a void `_v`, a value-returning `P_B`, and a throwing `_v` escaping
block, then from a **real GCD background thread** — *after* the make calls returned — each stored block is
invoked via its raw Block ABI invoke funcptr: the void block fires on thread 0, the `P_B` block round-trips
`true` through the completion semaphore, the throwing block's JS throw is contained + reported exactly once
via `onCallbackError` (no unwind reaches the bg invoke), **every** body ran on thread 0 (`isMainThread`
verified from JS), and the **last `_Block_release` off-main** tears each block down — the off-main holder
`deinit` release-bounces the registry drop to thread 0, so all three registry entries are gone by the
notify (off-main teardown, no leak, no UAF).

## What the off-main synchronous dealloc bounce provides (dealloc-off-main-k46)

The **off-main half of ADR-0059 §4's `dealloc`** (`src/inbound.swift` + `src/bounce.swift`) — the off-main
dual of the on-thread-0 `dealloc` (k40) and the **last** `inbound-trampolines-k36` off-main path. The
framework can drop the last ref to a synthesized subclass / delegate-forwarder instance **off thread 0** (a
superview released on a bg/GCD queue, a completion holding the last ref released on a framework thread), so
the shared `-dealloc` IMP must run the JS `dealloc` override **and** the registry-release teardown **on
thread 0** even then — via a **synchronous** bounce.

- **`dealloc_imp` branches on `pthread_main_np()`.** On thread 0 → the existing direct `deliverDealloc`
  path (unchanged). Off thread 0 → **`awBounceDealloc(cbid)`**: block the deallocating thread until thread
  0 has run `__deliverDealloc` (the JS override + the registry drop) and returns `hadOverride`, then chain
  `[super dealloc]` **iff `!hadOverride`** on the deallocating thread. Off thread 0 the IMP touches **no
  napi / no registry** — the cbid is a raw pointer read (`readBackRef`), and the deliver + release happen on
  thread 0 inside the bounce `call_js` (ADR-0059 Mechanics).
- **Why synchronous, never async (the load-bearing correctness point).** ObjC `-dealloc` frees the object's
  storage the instant the IMP returns, and the JS override reads the JS back-ref — so the override **must**
  complete before the IMP returns. An *async* bounce would let ObjC free the object before the override
  runs → **UAF of the JS back-ref**. So dealloc is the one off-main **void**-returning path that *blocks*
  the producing thread: it borrows the value-returning machinery (a `BounceCompletion` semaphore), its
  "value" being the `hadOverride` bool that tells the IMP whether to chain `[super dealloc]`.
- **The bounce mode.** `BounceCall` gains a `dealloc` flag (parallel to the escaping-block `release` flag —
  the single-tsfn shape is kept). The tsfn `call_js` dealloc branch **delegates thread-0 delivery to
  inbound.swift's `deliverDealloc`** (which owns `gDeallocRef` / `__deliverDealloc`), so the on-thread-0 IMP
  and the off-main bounce share one dealloc-delivery seam. **Always-post:** a throwing / absent override, a
  missing deliverer, or a napi fault still posts the completion — the default `hadOverride = false` chains
  `[super dealloc]` itself (never a hung deallocating thread, never a leak on the fault path).
- **Deadlock caveat (observable) — broader here than for value-returning.** A synchronous dealloc bounce
  while thread 0 is *synchronously blocked* (a `dispatch_sync` to an off-main queue,
  `-waitUntilAllOperationsAreFinished`, a thread join) deadlocks — thread 0 cannot service the tsfn
  (`uv_run` is non-reentrant). Same ADR-0056 §3 / ADR-0059 §5 caveat the value-returning path carries, but
  its **trigger surface is larger**: a value-returning bounce fires only when the programmer *invokes* a
  value-returning callback, whereas a dealloc bounce fires *implicitly* whenever any bound instance's last
  release lands off-main — and the value-returning mitigation ("keep those callbacks on main") does not
  apply, since a refcount reaching 0 is not something the app schedules. The mitigation is the stronger
  discipline: **do not synchronously block thread 0 while bound objects may be releasing off-main** (keep
  the runloop turning). The bounce also stalls whatever thread ran the last release for the round-trip —
  releasing a bound object on a real-time/QoS thread pays one thread-0 turn of latency.
- **Which thread runs `[super dealloc]` differs by override presence.** With a JS override, the override
  chains `this.$super.dealloc()` on thread 0, so the object's storage is freed on thread 0; with no
  override, the IMP chains `[super dealloc]` on the deallocating thread — the same thread pure ObjC would
  free on. Main-thread-affine classes (AppKit views) inherit Cocoa's obligation to release on the main
  thread; the binding does not lift it for the no-override off-main path (an app obligation, surfaced in
  the target reference docs, not this native seam).

Proven first-hand on arm64 under `harness/build/embed_harness` (`aw_test_dealloc_off_main` + `harness/app.cjs`,
the off-main analogue of super.mjs's on-thread-0 dealloc): the runtime makes three synthesized-subclass
instances — an **override** that chains `[super dealloc]` on thread 0 (`hadOverride` true), a **no-override**
instance (`hadOverride` false → the IMP chains `[super dealloc]` on the bg thread), and a **throwing**
override (contained + reported, still unblocks + still drops the registry) — then from a **real GCD
background thread** does the **last `objc_release`** of each: each `-dealloc` fires off-main, bounces, and
the JS override runs on thread 0 (`isMainThread` verified from JS), every instance's `callbacks`-registry
keep-alive is dropped off-main (the k37/k38 loop close), and the bg thread never hangs (always-post — even
the throwing override unblocks it).

## What the retain-fold reconciliation provides (retain-fold-k48)

The **outbound object-return retain rule** of ADR-0057 §4 (`src/dispatch.swift` + the runtime's
`lifetime.ts`), the first child of `retain-and-error-catch-k47` — the general per-signature
reconciliation the spine deferred. Every wrapped object reaches JS at a **uniform +1** with no
over-/under-retain, across both ownership conventions and the uniquing path:

- **Fold iff +0.** A +0 (autoreleased) object return is `objc_retain`'d inside its `aw_ts_msg_*`
  entry (arrives +1); a **+1-convention return** (`alloc`/`new`/`copy`/`mutableCopy`/
  `ns_returns_retained`, `init…`) must **not** be folded. The emitter now content-addresses the
  ownership into the entry name — a **`…_o` suffix** parallel to the `…_e` error axis
  (`native_dispatch.rs`) — so a +1 method routes to a distinct **non-folding** entry
  (`aw_ts_msg_0_P_o` / `P_P_o` / `q_P_o` here; `__wrapOwned` takes the +1 directly). Without the
  split, a +1 method through the folding entry double-retains (arrives +2).
- **Symmetric existing-wrapper release.** Because the incoming `id` always carries exactly one +1
  (fold-normalised for +0, method-native for +1), both `__wrapRetained` and `__wrapOwned`
  **`release` that +1 on a live-duplicate re-fetch** — the live wrapper already owns the one +1.
  `__wrapRetained` previously did **not**, leaking the fold on every re-fetch of an already-wrapped
  +0 object (`view.superview` in a loop). Fixed in `lifetime.ts`.

Proven headless by `test/retain.mjs` (arm64, Foundation-only, `-retainCount` as ground truth): a +0
object re-fetched via `-firstObject` mints one +1 and re-fetch adds none (the fold is released),
dispose balances back to the array's baseline, and a +1 `-mutableCopy` through `aw_ts_msg_0_P_o`
reaches JS at retainCount 1 (no double-retain).

## What the error-out `…_e` @catch entries provide (error-catch-entries-k49)

The **outbound error mechanism** of ADR-0058 (`src/dispatch.swift` + `src/awexc.m` +
`src/napi_support.swift`), the second child of `retain-and-error-catch-k47` — a
`aw_ts_msg_<codes>_e` sibling per fallible ABI signature that turns the two Cocoa error sources into
the runtime's `NativeErrorResult` discriminant (`result.ts`). The `@_cdecl` decides **only the
exception axis + the retain convention**; the `NSError**`→`Result` *policy* stays in TS (`__result*`).

- **The `@catch` is native, and it must be ObjC.** An escaping `NSException` unwinding the C ABI into
  V8 would corrupt the stack / crash the ADR-0056 pump. Swift's `do`/`catch` cannot catch an ObjC
  exception, and one must never unwind *through a Swift frame* (UB). So the fallible `objc_msgSend`
  runs in **`src/awexc.m`** — one small **MRC** ObjC unit — directly inside `@try`/`@catch`, with no
  Swift frame between the throw and the catch. Swift reads only the structured `AWErrorOutResult`
  (`primary`, `error`, `exception`, `reason`); no exception ever reaches Swift. `awexc.m` retains the
  caught exception + the out-param `NSError` **+1** by hand (the fold `__wrapRetained` expects) and
  `strdup`s the `-reason` — never bridging either to an ARC-managed Swift `AnyObject` (the ARC
  over-release trap).
- **Key on the primary return, not the error.** The `…_e` entry synthesizes the `NSError*` cell and
  passes `&err`; the TS `__result*` keys `ok:false` on a nil object / `NO` scalar primary (Apple's
  "check the return, not the error"), reading `error` only then. A caught exception → `{thrown:true,
  exception, reason}` → the runtime throws `NSExceptionError`.
- **Fold-iff-+0 on the object primary** (ADR-0057 §4, inherited from the retain-fold child): a **+0**
  fallible object primary folds in its `aw_ts_msg_<codes>_e` entry (`__resultRetained` →
  `__wrapRetained`); a **+1** one routes to the non-folding `…_o_e` sibling (`__resultOwned` →
  `__wrapOwned`). Scalar/`BOOL` primaries never fold (nothing wrapped).

Proven headless by `test/error.mjs` (arm64, Foundation-only): a real `NSInvalidArgumentException`
(`-[NSString stringByAppendingString:]` nil arg) is caught native-side, its `-reason` captured, and
`__resultRetained` throws `NSExceptionError`; `-[NSFileManager removeItemAtPath:error:]` keys
`ok:false` + wraps the `NSError` on a missing path (and `unwrap` → `NSErrorError`) and `ok:true` on a
real temp file; and the +0 (`objectForKey:`, folding `P_P_e`) vs +1 (`mutableCopyWithZone:`,
non-folding `P_P_o_e`) object primaries both reach JS at a uniform +1 via `-retainCount`.

## What the constant reads provide (constants-k51)

The **`aw_ts_const_<code>` reads** (`src/dispatch.swift`) — the bodies the emitter's already-emitted
constant call sites (`emit_constants.rs`, ADR-0055 §6) bind to. A constant global's *value* is a
**link-time fact** (ADR-0025): there is no IR literal, so each entry `dlsym(RTLD_DEFAULT, name)`s the
named global (`dlsym` returns `&global`, the storage address) and loads its value by the constant's
**result ABI shape**, content-addressed by `native_dispatch::constant_entry_name`.

- **The closed alphabet, one entry per shape.** `aw_ts_const_P` (a pointer-valued object global),
  `aw_ts_const_N` (a `const char *` C-string global), and the scalar codes `b c C s S i I q Q f d`
  (`AbiType::code`). ~13 entries total — a small fixed set keyed on the **result shape**, not the
  per-symbol *generated* full table (a later emit-typescript concern). Struct-valued globals are
  deferred by the emitter, so no struct const entry exists. `cfstr` (a CFSTR macro, no symbol) is a
  separate primitive.
- **The `P` read folds a `+1` (the load-bearing correctness point, ADR-0057 §4).** A constant global
  holds a **borrowed +0** id; the runtime's `__wrapRetained` expects a uniform `+1` (it releases that
  +1 on a live-duplicate re-fetch). So `aw_ts_const_P` `objcRetain`s the loaded id before returning —
  exactly like the +0 object-return dispatch entries (`aw_ts_msg_0_P`). `objcRetain` is null-safe: a
  missing symbol yields 0 → `__wrapRetained` → `null` (graceful degradation, the `aw_getClass` posture;
  scalar reads yield the shape's zero).

Proven headless by `test/constants.mjs` (arm64, Foundation-only): the pointer-valued object global
`NSCocoaErrorDomain` (an `NSString * const`) reads through `aw_ts_const_P`, wraps borrowed at a uniform
+1, and reaches JS as the correct string (`-isEqualToString:`, `-length` == 18); the scalar global
`NSFoundationVersionNumber` (a `const double`) reads through `aw_ts_const_d` as the right number; and an
absent symbol reads as `null` / 0. (`N` and the other scalar widths are provided identically and
exercise once a matching C-string / integer global appears — the `P`/`d` pair proves the dlsym+deref
mechanism the whole closed alphabet shares.)

## What the Swift-native `s:` residual trampolines provide (fn-trampoline-spine-k53 → swift-residual-cli-pass-k65)

The **`aw_ts_swift_<Module>_<name>` entries** (`src/Generated/TrampolineTable.swift`, **43 of them**)
— the mechanism half of the Swift-native residual ADR-0025's trampoline-elision cannot reach directly.
A `objc_exposed == false` free function has **no C symbol** (unlike an ObjC/C function, which
dispatches through the direct `aw_ts_fn_<name>` entry, or a constant global, which `dlsym`s): it is
reachable *only* across the Swift ABI. So the addon carries, per residual function, a napi callback
that `import`s the owning framework module and calls the API **by name**, letting swiftc own Swift-ABI
correctness — the TS/N-API port of racket's ADR-0027 (ADR-0061). The TS divergence: the entry is
registered in the **exports object** (`napiDefine`), not exported as a `@_cdecl` symbol racket
`dlsym`s (an `@_cdecl` here duplicates the symbol). The entry is content-addressed by **module +
symbol** (a bare name collides across modules), so the emitter's `.ts` call site
(`__dispatch.aw_ts_swift_<…>`) and the generated Swift agree with no shared counter. Note the table is
keyed **per symbol**, not per signature — a Swift function is called by its own name, unlike the
`objc_msgSend` recasts the outbound table collapses.

Scope: the **scalar** shape (scalar / `CGFloat` args → scalar / `CGFloat` / void return,
`fn-trampoline-spine-k53`) **plus object / Foundation-bridged value / string returns**
(`object-bridged-returns-k55`, ADR-0061 §3). Recorded-deferred, not built: `throws` → `Result` and the
near-empty wider-scalar alphabet (ADR-0061 §3); genuinely unbindable: **generic** free functions (21)
and Swift **operator** declarations (13 — `+`, `/`, `&&`… have no TS identifier and their sanitised
entry names would collide). The method/init/value-struct residual is a recorded follow-up-grove
deferral (ADR-0061 §4). Proven headless by `test/swift-native.mjs` (arm64):
`CoreGraphics.hypot(CGFloat, CGFloat)` — a Swift-native declaration with no reachable C symbol for its
CGFloat overload — dispatched by name through the **generated** trampoline, `(3,4)→5`, `(5,12)→13`,
`(1,1)→√2`.

**`TypeRefKind::Class` is overloaded — read this before touching `crate::trampoline`.** A
`.swiftinterface`-sourced decl lowers *every* Swift nominal type to `kind: "class"`, so real-IR
`hypot` arrives as `(Class{CGFloat}, Class{CGFloat}) -> Class{CGFloat}` and `lgamma`/`remquo` return
`Class{Tuple}` — while CoreGraphics's IR declares exactly eight classes, none of them either. Two
guards precede the object arm: a **scalar-backed value type** (`CGFloat`) marshals by value whatever
kind carries the name, and an object return binds only for a name in the **ObjC-class recognition
set** (the IR's declared classes). Without the first, generated `hypot` would `passRetained` a
`__SwiftValue` box; without the second, `remquo` would bridge a Swift tuple through `as AnyObject?`.
The same overload still afflicts the *method* surface — that is `swift-nominal-type-surface-k66`.

**Object returns (`object-bridged-returns-k55`).** The call result bridges to an `id`
(`as AnyObject?` — `String`→`NSString`, `Array`→`NSArray`, or identity for a class instance) and the
trampoline hands JS a **+1** handle (`Unmanaged.passRetained`, `napiMakeRetainedObject`) the runtime's
`__wrapOwned` takes (ADR-0057 §4 uniform +1) — *always* `__wrapOwned`, not the CF-Create-Rule
heuristic the direct-C path uses. An SDK survey found **no** headless, non-throwing, object-returning
Swift-native *free* function exists (the object residual is at the *method* level, ADR-0061 §4), so
unlike `hypot` there is no by-name-reach exemplar; the object-return **marshalling shape** is proven
headless by `test/swift-native-object.mjs` against the hand-written `aw_ts_swift_probe_objectReturn`
probe (a real `String`→`NSString` bridge round-trips a correct +1 handle) — the probe is *fixed
machinery*, so it stays in `src/trampolines.swift` while every per-symbol entry is generated — and the
codegen by the goldens/units, including a **strong mirror invariant** (`collected == referenced`:
every `aw_ts_swift_*` token the emitted `.ts` names has a generated entry, and no entry is dead).

## Build & test

```sh
bash build.sh                                    # → build/APIAnywareTypeScript.node
(cd ../runtime && npm run build)                 # the runtime dist/ the checks import
node test/spine.mjs                              # outbound: construct → dispatch → wrap → dispose
node test/inbound.mjs                            # inbound: Foundation calls a JS subclass override
node test/delegate.mjs                           # inbound: NSKeyedArchiver calls a JS delegate
node test/block.mjs                              # inbound: NSArray calls a JS closure as a block
node test/super.mjs                              # inbound: $super, overridable dealloc, added methods (§4)
node test/retain.mjs                             # outbound: retain-fold reconciliation, uniform +1
node test/error.mjs                              # outbound: the …_e @catch entries (NSException / NSError / fold-iff-+0)
node test/constants.mjs                          # outbound: the aw_ts_const_<code> reads (pointer-valued object global +1 fold / scalar global)
node test/swift-native.mjs                        # outbound: the aw_ts_swift_* residual trampoline (CoreGraphics.hypot call-by-name)
node test/swift-native-object.mjs                 # outbound: the aw_ts_swift_* object-return marshalling (String→NSString → +1 handle → __wrapOwned)

bash harness/build.sh                            # → harness/build/embed_harness (needs build.sh + runtime dist first)
./harness/build/embed_harness                    # pump + bg→main bounce + off-main inbound delivery + escaping blocks + off-main dealloc: embed Node under AppKit, run the facilities + bounce + off-main + escaping-block + dealloc battery (exit 0 = all GREEN)
```

Toolchain (confirmed host): macOS 26.5.1 arm64, Swift 6.3.3, Apple clang 21, Node v26.4.0 with a
shared `libnode.147.dylib` + shared `libuv.1.dylib` (Homebrew), Node-API + embedder + V8 headers from
the active `node`'s Cellar include dir. No node-gyp, no Rust. The harness links `libnode`/`libuv`
directly (an executable, not a `-undefined dynamic_lookup` addon), so it needs the shared dylibs;
the `.node` addon build is unchanged.

Note: AppKit is not loaded in a plain `node` process, so AppKit classes (`NSScreen`, …)
resolve to the null Class headless — the CGRect (`0_R`) x8 struct-return exercises live once
a native launcher loads AppKit (the sample-app milestone). The spine's struct-return proof
uses Foundation's `NSRange` (`-[NSString rangeOfString:]`, code `P_G`), which is headless-safe.
