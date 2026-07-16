# TypeScript substrate re-evaluation — desk-research findings

**Date:** 2026-07-06
**Leaf:** `substrate-desk-research-k12` (the research half of `ts-substrate-reeval-k11`,
grove `add-typescript-target-language`)
**Decision framing:** ADR-0054 chose **Node reference runtime + N-API generated typed native
dispatch (napi-rs + Swift dylib)** on the **D1 longevity hedge** (engine-agnostic via N-API), and
ADR-0056 built the **libuv-pump** machinery that hedge implies. The `ts-memory-design-k7` grill
reopened, at the user's steer (2026-07-05), **two substrate axes**:

1. **Engine** — embed Apple's **JavaScriptCore.framework** directly (all-Swift/ObjC core, no Rust,
   no N-API; JSC has *no* libuv / no mandatory competing loop) vs keep **Node + V8 + N-API**.
2. **Core language** (only if Node stays) — **Swift-native N-API** vs **napi-rs (Rust)**, given that
   dispatch is emitter-*generated* (ADR-0055), so napi-rs's macro ergonomics may no longer earn it.

This is the **research half** (k5→k6 pattern): desk analysis, primary sources, walk-away checks per
option, and the **first-hand unknowns named** so the spike sibling is well-scoped. It **does not**
rework any ADR — a substrate ADR flips only on first-hand evidence (the k3/k6 bar). The spike sibling
(`ts-substrate-jsc-spike-k13`) runs the named unknowns and does the in-place ADR rework.

**Method:** five-agent parallel fan-out, one per axis (engine capabilities · `JSManagedValue` memory ·
JSC precedents/post-mortems · Swift-native N-API · distribution), each demanding a primary-source URL
per load-bearing claim and recording absences as findings (`driving.md`).

**Host (for the first-hand touches recorded below; the spike will re-cite):** macOS 26.5.1 (build
25F80), arm64. Two agents made read-level first-hand checks — `JavaScriptCore.framework` present with
the public embedding headers in the current SDK, and `osascript -l JavaScript` + `ObjC.import` +
`$.NSMakeRect` struct-return working — grounding the "system framework, JXA still ships" claims. All
*build*-level unknowns are deferred to the spike (§Named first-hand unknowns).

**Verdict (preliminary — pending the spike + one user steer): lean JavaScriptCore on every technical
axis for a *native macOS ObjC-binding* target; the single genuine cost is JS ecosystem (npm /
`worker_threads` / libuv), which is a product-vision judgment, not a spike question. Independently:
drop Rust/napi-rs regardless of the engine decision.**

---

## Decision (user steer, 2026-07-06) — TWO targets, Node first

The grilling of this research resolved the re-evaluation **not** as "flip the substrate to JSC," but by
recognising the deeper truth the research surfaced (§I3, §counter-case): **Node-APIAnyware and
JSC-APIAnyware are two different *products*, so they are two separate *targets*, not one target with an
engine switch.** The user's decision:

1. **Two separate TypeScript targets** — a **Node** target ("the Node ecosystem, on macOS, with Cocoa
   access") and a **JSC** target ("typed TS directly over Cocoa, native"). This deliberately reopens the
   Q1 "single `typescript` target" framing (root brief · ADR-0004/0011) — justified because the two are
   different products, not two idioms of one.
2. **Node first** — it is the *harder, richer* target (the libuv pump/ADR-0056, N-API, the threading
   reconciliation), so building it first yields the most learning and experience; the JSC target is
   *easier* (the pump dissolves, the core is all-Swift, distribution is trivial) and benefits from that
   experience done **second**. Sequencing hard→easy compounds the learning; doing the easy one first
   would waste it.
3. **The Node ADRs stand.** ADR-0054 (substrate), ADR-0056 (pump), ADR-0057 (memory) describe the **Node**
   target — target #1 — and proceed as-is. The prior k3/k5/k6 spikes were the Node target all along, not
   a rejected alternative. ADR-0057's "reworks if k11 flips to JSC" caveat is **resolved** (no flip).
4. **Core-language refinement for the Node target:** the research's durable finding (drop Rust →
   **Swift-native N-API**, 3 native units → 2, §D) applies to the Node target too — recorded as the lean
   in ADR-0054, to confirm at the Node runtime build-leaf (research unknown #8).
5. **The JSC target is externalised** as a separate future workstream (a new grove), **grounded in this
   FINDINGS doc** — this whole document is that target's substrate/memory/distribution design base. Its
   spike legs (JSC dispatch, `JSManagedValue`, `NSApp.run()` coexistence, async shim — §Named unknowns
   1–10 minus #8) belong to that grove, not this one. Naming (`typescript` vs a distinct id per target)
   is settled when the JSC grove starts.

**Net for this grove (`add-typescript-target-language`): it delivers the *Node* TypeScript target.** The
`ts-substrate-reeval-k11` node retires resolved; the loop continues to the Node target's remaining design
leaves (Q5 error, Q6 callbacks, Q7 distribution) and then its build leaves.

---

## A. Engine capability — JavaScriptCore on macOS 26 (Agent 1)

**A1. JSC is a public, stable, non-deprecated *system* framework.** `JSVirtualMachine`/`JSContext`/
`JSValue`/`JSManagedValue`/`JSExport` — the ObjC/Swift object API since macOS 10.9 / iOS 7, no
deprecation flags, present in the current SDK at `/System/Library/Frameworks/JavaScriptCore.framework`
(binary lives in the dyld shared cache since Big Sur — nothing to bundle).
- https://developer.apple.com/documentation/javascriptcore ·
  https://developer.apple.com/tutorials/data/documentation/javascriptcore/jsvirtualmachine.json ·
  https://nshipster.com/javascriptcore/

**A2. The pump dissolves — JSC has no competing mandatory event loop.** JSC provides **only**
ECMAScript built-ins: no `setTimeout`/`setInterval`, no `fetch`/`fs`/`console`, no event loop, no
default module loader (ES-module loading via `JSScript` + `moduleLoaderDelegate` exists but is
**private SPI** in `JSContextPrivate.h` — App-Store-risky; the **public** path is a single bundled JS
artifact via `evaluateScript:`, which is the standard shipping model anyway — see §F3). It executes
only when the embedder calls in; its deferred work (GC, microtask timer)
rides "the runloop on which it was initialized." Initialize the `JSVirtualMachine` on the main thread
and it cooperates with `NSApplication.run()`'s CFRunLoop — **the app's runloop stays authoritative and
JSC insists on no loop of its own.** This is the decisive contrast with Node/libuv and it means the
**entire ADR-0056 pump (helper thread, `uv_run(NOWAIT)`, common-modes source, `pump_shim.cc`)
disappears** under JSC.
- https://developer.apple.com/tutorials/data/documentation/javascriptcore.json ·
  https://developer.apple.com/forums/thread/768129 (setTimeout is host-provided, not an engine
  built-in) · https://developer.apple.com/tutorials/data/documentation/javascriptcore/jsvirtualmachine.json

**A3. Microtask draining: at the outermost native→JS return.** An Apple Frameworks engineer: *"JSC
will drain microtasks every time it returns from the first, still running call into JavaScript."* So
queued Promise `.then` jobs run before `evaluateScript`/`invokeMethod` unwinds to native — there is no
macrotask queue unless you build one (via Cocoa: `NSTimer`/`dispatch_after`).
- https://developer.apple.com/forums/thread/678277 · https://bugs.webkit.org/show_bug.cgi?id=161942

**A4. `WeakRef`/`FinalizationRegistry`: solid since Safari 14.1 (2021); cleanup fires on the
VM-owning JS thread, not a GC thread.** WebKit's `JSFinalizationRegistry.cpp` schedules the callback
via `vm.deferredWorkTimer->scheduleWorkSoonIfActive(...)` *after* the GC flip — i.e. on the
main-thread runloop when the VM is main-initialized. So **ADR-0057 §7 (FR-on-main, no queue, no
bounce) holds under JSC** — same guarantee as Node/V8. The "may not run at all" caveat is
engine-agnostic and unchanged.
- https://webkit.org/blog/11648/new-webkit-features-in-safari-14-1/ ·
  https://raw.githubusercontent.com/WebKit/WebKit/main/Source/JavaScriptCore/runtime/JSFinalizationRegistry.cpp ·
  https://caniuse.com/mdn-javascript_builtins_finalizationregistry

**A5. The one real caveat — ES2024 Explicit Resource Management (`using`/`Symbol.dispose`) is NOT
enabled-by-default in macOS-26 JSC.** The ERM plumbing (`@@dispose`, `@@asyncDispose`,
`SuppressedError`, `DisposableStack`) landed **behind a runtime flag** (`useExplicitResourceManagement`,
STP 220); the `using` *declaration syntax* and `Symbol.dispose` are marked unsupported in stable Safari
through v27 (caniuse/MDN). **But ADR-0057 §1 already anticipated this: `using` downlevels through `tsc`
+ a `Symbol.dispose` polyfill, so it does not depend on native engine support** — making this a
spike-verify item, not a blocker. Whether an embedder can flip the flag through the *public*
framework API is undocumented (no public toggle found).
- https://webkit.org/blog/16973/release-notes-for-safari-technology-preview-220/ ·
  https://caniuse.com/mdn-javascript_statements_using · https://caniuse.com/mdn-javascript_builtins_symbol_dispose

**A6. Threading: one `JSVirtualMachine` = the unit of locking; parallelism via separate VMs.** Access
to a VM must be serialized (other threads block on the VM lock); values can't cross VMs; true
concurrency = one VM per thread. No `worker_threads`-style shared-nothing message passing built in —
but a UI target's model is main-thread JS + GCD workers bounced to main (Cocoa-native).
- https://developer.apple.com/tutorials/data/documentation/javascriptcore/jsvirtualmachine.json

**Walk-away check (JSC engine):** delete the JS layer and what remains is entirely native and legible —
a `JSVirtualMachine`/`JSContext` on the main thread driven by the app's own `NSApplication.run()`
CFRunLoop, reaching ObjC through the existing engine-invariant `@_cdecl objc_msgSend` dispatch. No
residual runtime to unwind: no libuv, no bundled Node, nothing to ship. Contrast Node+V8+N-API, where
deleting JS still leaves libuv's mandatory loop and the embedded Node runtime to reconcile with Cocoa.

**Takeaway → ADR-0054 §3 / ADR-0056 (whole).** JSC is a clean engine fit whose threading model is
*cooperative* with `NSApplication.run()` and imposes no competing loop — the ADR-0056 pump dissolves.
Sole caveat: JSC's ES level trails V8 (`using` behind a flag) → the downlevel path is a spike item.

---

## B. Memory — `JSManagedValue` as a supported third option (Agent 2)

**B1. What it is.** A `JSManagedValue` is a *conditionally retained* `JSValue`: the framework header
states it is retained "as long as the `JSValue` is reachable through the JavaScript object graph, **or
through the Objective-C object graph reported to the `JSVirtualMachine` using
`addManagedReference:withOwner:`**." The JSC GC treats a registered `owner` as an opaque node and
follows the *declared* native→JS edge — **co-ownership without fusing the object models** (the GC never
makes ObjC objects into GC objects).
- https://raw.githubusercontent.com/WebKit/WebKit/main/Source/JavaScriptCore/API/JSManagedValue.h ·
  https://developer.apple.com/documentation/javascriptcore/jsvirtualmachine/addmanagedreference(_:withowner:) ·
  test: https://github.com/WebKit/WebKit/blob/main/Source/JavaScriptCore/API/tests/testapi.mm

**B2. It is current and Apple-supported — the decisive contrast with MacRuby.** Non-deprecated on
every platform incl. **visionOS 1.0** (Apple carries it forward, not merely maintains legacy). MacRuby
died because its co-ownership mechanism — libauto — was *withdrawn*; the managed-reference mechanism is
the opposite: still shipping, still documented, the public JSC↔Cocoa interop contract, demonstrated as
*the* supported pattern at WWDC 2013 §615.
- https://developer.apple.com/documentation/javascriptcore/jsmanagedvalue · https://asciiwwdc.com/2013/sessions/615

**B3. It solves exactly the delegate/callback cycle.** WWDC §615 walks the native `MyButton` holding
its JS `onClickHandler` while the handler references the button back; the fix is a `JSManagedValue` +
`addManagedReference:withOwner:` — "a garbage-collected reference: if JavaScript can find the owner it
keeps the reference alive, otherwise it's released." This is precisely the Q6 delegate-retain cycle.
NativeScript, by contrast, used the **"splice"** (strong/weak flip on the ObjC refcount crossing 1↔2)
— the racy, heap-fusing approach ADR-0057 already rejects, and its own docs list its failure modes
("half-dead" window, non-deterministic premature collection). **NativeScript is a cautionary tale for
the rejected path, not an example of the managed-reference path.**
- https://asciiwwdc.com/2013/sessions/615 · https://panayotcankov.github.io/nativescript-3.2.0-memory-management/

**B4. Verdict: PARTIAL.** A genuine, Apple-supported, non-fusing third option (softens §5's FR
dependence — with JSC the engine's own ObjC-aware wrapper GC performs native release and safely holds
JS callbacks, a stronger backstop than "may-never-run" FR) — **but it does not make reclamation
deterministic** (still GC-timed) and imposes its own obligations: correct/reachable `owner`, balanced
register/unregister, per-VM scoping, GC on the init-thread runloop (no API to change), no reach into
pure ObjC-side cycles. So: keep `Symbol.dispose`/`using` as the *primary* deterministic release; frame
managed references as *"a stronger, engine-native backstop that also breaks native↔JS callback
cycles,"* **not** "removes the need for a GC backstop."

**Takeaway → ADR-0057 §Engine caveat + §5/§7.** The ADR's hypothesis is **confirmed on "supported third
option," PARTIAL on "softens FR dependence."** Under JSC, ADR-0057's spine (uniform +1, uniquing,
two-heap seam, `Symbol.dispose` primary) is unchanged; §5 gains `JSManagedValue` as the engine-native
backstop + cycle-breaker; §7 (FR-on-main) still holds (A4). Gate the collect-behaviour claim on the spike.

---

## C. Precedents & post-mortems — the load-bearing distinction (Agent 3)

**C1. System framework vs *forked* JSC is the whole game.** Every "JSC burned us" post-mortem is about
maintaining a **forked, built-from-source** JSC, not the system framework:
- **NativeScript `ios-jsc`** built JSC from a **WebKit git submodule**; their stated migration reason
  was the *fork's* cost ("significantly diverged… every upgrade can take up to 3 person-months",
  "non-embedding friendly") plus **iOS's third-party-JIT ban** (V8's jitless mode was the enabler).
  Neither argues against the *system* framework. https://github.com/NativeScript/ios-jsc ·
  https://blog.nativescript.org/the-new-ios-runtime-powered-by-v8/
- **Bun** clones and builds `oven-sh/WebKit` (thousands of upstream commits synced per release) —
  another *forked-JSC* datapoint; it proves JSC is a production-grade engine chosen over V8 for
  startup/throughput, and says nothing against the system framework.
  https://bun.com/reference/bun/jsc · https://bun.com/blog/how-bun-supports-v8-apis-without-using-v8-part-1

**C2. The genuine *system*-JSC embeds prove the bridge works.** **JXA** — Apple's own system-JSC ObjC
bridge (2014, shipped continuously to macOS 26.5.1, verified live: `ObjC.import`, `$.NSMakeRect` struct
return) — demonstrates Cocoa calls, struct returns, blocks, C functions, delegates via `registerSubclass`,
pass-by-reference. Its "abandonware" reputation targets the **JXA/OSA scripting DSL**, not
`JavaScriptCore.framework` (a native app uses `JSContext`/`JSExport` directly, bypassing OSA).
**React Native (iOS, pre-Hermes)** linked the **system** JSC — the largest-scale system-JSC embed in
history; the move to Hermes was iOS jitless startup/memory, not a framework failure.
- https://developer.apple.com/library/archive/releasenotes/InterapplicationCommunication/RN-JavaScriptForAutomation/Articles/OSX10-10.html ·
  https://github.com/react-native-community/javascriptcore · https://reactnative.dev/docs/hermes

**C3. The macOS/iOS JIT asymmetry kills the last iOS-derived objection.** iOS forbids third-party JIT
(embedded JSC → interpreter only, ~7.5× slower). **macOS grants JIT to a third-party JSContext app via
the public `com.apple.security.cs.allow-jit` entitlement**; omit it and JSC still runs correctly on the
LLInt interpreter (slower, no crash). Our target is macOS → full-JIT available.
- https://developer.apple.com/documentation/BundleResources/Entitlements/com.apple.security.cs.allow-jit ·
  https://dev.to/alastaircoote/to-jsc-or-not-to-jsc-running-javascript-on-ios-in-2020-44ba

**C4. Longevity: system JSC is the *more* durable macOS bet.** Public ObjC API under
Safari/WebKit/WKWebView/JXA/Mail/Notes — freezing/removing it would break the OS; shipped unbroken
2014→2026. (Reasoned inference — Apple promises no framework's longevity — flagged as such.) Contrast
Node: a third-party runtime you bundle, update, notarize, and keep macOS-compatible in perpetuity.
This **reframes the D1 hedge** — ADR-0054 §4 chose N-API to avoid betting on one JS *runtime* amid
JS-runtime churn; on macOS specifically, **Apple's own engine is not subject to that churn**, so the
hedge's premise weakens (see §Synthesis).
- https://docs.webkit.org/Deep%20Dive/JSC/JavaScriptCore.html · https://developer.apple.com/documentation/javascriptcore

**Walk-away / longevity verdict:** system JSC — public ObjC API, JIT-eligible on macOS, zero binary
weight, zero fork maintenance — is a *more* durable macOS substrate than bundled Node.

**Takeaway → ADR-0054 §4 (D1 reframing) + ADR-0056 dissolution.** The anti-JSC corpus indicts *forked*
JSC and *iOS* JIT limits; **neither binds a system-JSC macOS app.**

---

## D. Core language — Swift-native N-API vs napi-rs (only if Node stays) (Agent 4)

**D1. Swift-native N-API is proven prior art.** `kabiroberai/node-swift` (maintained, v1.4.0
2025-07-20) builds real `.node` addons: a 6-line C shim (`NAPI_MODULE_INIT()` → `@_cdecl` Swift entry),
`napi_*` declared via a SwiftPM `.systemLibrary` module map, `swift build` on a `.dynamic` product
linked with `-undefined dynamic_lookup`, renamed `.node`. (A pure `@_cdecl("napi_register_module_v1")`
entry is mechanically valid on macOS but not the path node-swift exercises → a minor spike item.)
- https://github.com/kabiroberai/node-swift · https://nodejs.org/api/n-api.html

**D2. Given generated dispatch, napi-rs's headline value evaporates.** napi-rs's pitch is "no
hand-writing js binding" — but our per-signature glue is **emitter-generated already**. Its safe
wrappers are reproduced by node-swift in Swift. Its one non-redundant gift is the batteries-included
`ThreadsafeFunction` wrapper (the raw C TSFN API is famously error-prone) — but that is a thin,
re-implementable convenience node-swift already mirrors.
- https://napi.rs/ · https://napi.rs/docs/concepts/threadsafe-function

**D3. The C++ pump shim is orthogonal — needed either way.** Driving Node's embedded loop is the V8
**C++** API (`HandleScope`/`Context::Scope`/`node::SpinEventLoop`, `MicrotasksScope::PerformCheckpoint`)
— no C ABI; napi's public surface is insufficient. Swift can't consume V8's C++ class API, so a C++ TU
is required whether the addon is Rust or Swift. **"Drop Rust for Swift" does not avoid the shim.**
- https://nodejs.org/api/embedding.html · https://v8.github.io/api/head/classv8_1_1MicrotasksScope.html

**D4. Unit count 3 → 2, a real simplification.** napi-rs path = Swift dylib (dispatch) + Rust `.node` +
C++ shim = **3**. Swift-native = Swift dylib *that is itself the `.node`* (dispatch + N-API surface) +
C++ shim = **2**. It **absorbs** the addon into the already-required Swift dylib and **deletes the
entire Rust toolchain** (cargo, `napi`/`napi-derive`, `@napi-rs/cli`); the C++ shim is untouched.

**D5. Top risk: Swift concurrency on the loop thread.** node-swift issues #45/#49 (`@MainActor` code
silently never runs off the MainActor; async promise-settling crashes on macOS 15.4+ "no NodeAsyncQueue"
— a custom-executor↔loop-thread seam). If the Swift residual is *synchronous* C-ABI dispatch, the risk
is small; if it leans on `async`/actors on the loop thread, napi-rs's maturity could justify keeping Rust.
- https://github.com/kabiroberai/node-swift/issues/45 · https://github.com/kabiroberai/node-swift/issues/49

**Takeaway → ADR-0054 §2 (core-language) — but likely MOOT.** If Node stays: lean **Swift-native**
(3→2 units, no Rust), defer the final call to the build-leaf, keep napi-rs only if the spike exposes
concurrency-executor trouble. **If JSC wins, there is no N-API at all** and this axis dissolves — but
the convergent signal is durable: **Rust/napi-rs should go regardless of the engine decision.**

---

## E. Distribution — system JSC vs bundled Node (Agent 5)

**E1. Bundled Node is Electron-class friction.** Node SEA (Stability 1.1, still pre-stable) embeds a
`NODE_SEA_BLOB` into a **copy of the ~46 MB node binary**, which mutates the Mach-O and forces a
strip-and-re-sign; every nested Mach-O (`node`/SEA + every `.node` + every `.dylib`) must be signed
inside-out or notarization fails; V8 needs **two mandatory** hardened-runtime entitlements
(`allow-jit` + `allow-unsigned-executable-memory`) — Electron 20+ *crashes* on arm64 without them.
- https://nodejs.org/api/single-executable-applications.html · https://www.electron.build/docs/features/code-signing/notarization/ ·
  https://github.com/electron-userland/electron-builder/issues/4385

**E2. Embedded system JSC adds nothing.** `JavaScriptCore.framework` lives in the dyld shared cache;
it is never copied into the app (like AppKit/Foundation). The `.app` becomes a bog-standard Cocoa app:
native `main()`/`NSApplicationMain`, one `Info.plist`, one signature over the app binary (+ at most one
per-target dylib). JIT needs only **one *optional*** `allow-jit` (interpreter fallback if omitted; the
high-tier JIT's Apple-private entitlements are irrelevant — the public path works).
- https://wadetregaskis.com/reminder-macos-system-frameworks-binaries-are-hidden-since-big-sur/ ·
  https://developer.apple.com/documentation/security/hardened-runtime

**E3. TCC identity is cleaner.** Grants attach to bundle id + code-signature designated requirement.
Single-process JSC → one binary, one stable/spoof-resistant identity. Node/Electron's multi-helper,
injectable-runtime architecture yields duplicate TCC entries and permission-inheritance hijack (the
`electroniz3r` class of attack).
- https://developer.apple.com/library/archive/technotes/tn2206/_index.html · https://github.com/r3ggi/electroniz3r

**E4. Quantified delta:** size ~46–50 MB → **0**; signed Mach-Os **N → 1–2**; entitlements **2
mandatory (crash-on-missing) → 1 optional (graceful)**; notarization Electron-class → ordinary
single-binary; TCC multi-helper → one clean identity. Tauri (system WebView, ~3 MB) vs Electron
(~150 MB) is the empirical proof of the system-engine path.

**Takeaway → Q7 (`ts-distribution-design-k10`).** JSC **dissolves the documented D8 gap**: with no
Node binary to wrap, the `.app` is exactly the native-launcher-stub bundle the Lisp targets already
produce (sbcl ADR-0041 precedent). Distribution is strictly cheaper under JSC on every axis.

---

## F. TypeScript developer experience — compile / load / debug (Agent 6)

**F1. No engine runs TypeScript — the build is engine-independent.** `tsc`/a bundler emits plain JS
(types erased); `.d.ts` is a build/type-check artifact. The engine sees only JS, so the build step is
identical for JSC or Node. (TS handbook: "there aren't any browsers or other runtimes that can just
run TypeScript unmodified.")
- https://www.typescriptlang.org/docs/handbook/2/basic-types.html · https://www.typescriptlang.org/docs/handbook/compiler-options.html

**F2. What Node gives that JSC does not — all *dev-loop* conveniences.** Node's native type-stripping
(`--experimental-strip-types`, unflagged v23.6+, stable v25.2+) is **erase-only** — enums, namespaces,
decorators, param-properties still require `tsc` — and Node **removed** `--experimental-transform-types`
in **v26.0**, so Node-26-era is erase-only too. Plus `tsx`/`ts-node` and the npm build ecosystem. All
run at build time; a *shipping* app is pre-compiled either way. JSC structurally lacks only the
`node file.ts` one-liner, not any shipping capability.
- https://nodejs.org/api/typescript.html

**F3. Module loading — bundle to one artifact (public), don't use the SPI.** JSC has no default
resolver. **Public + App-Store-safe:** bundle all compiled JS to one artifact via
`JSContext.evaluateScript:` (`macos(10.10)`) — the standard shipping model. **Private SPI (avoid):**
ES modules via `JSScript`(`kJSScriptTypeModule`) + `moduleLoaderDelegate` are declared in
`JSContextPrivate.h`, not the public header — private-API rejection risk. The bundler resolves imports
at build time, so this is a bundling/distribution point, not a TS gap.
- public: https://github.com/WebKit/WebKit/blob/main/Source/JavaScriptCore/API/JSContext.h ·
  SPI: https://github.com/WebKit/WebKit/blob/main/Source/JavaScriptCore/API/JSContextPrivate.h

**F4. Debugging — the real DX delta.** `JSContext.isInspectable` is **public since macOS 13.3**
(`jsContext.isInspectable = true`; attach via Safari → Develop); Web Inspector consumes source maps to
step original TS. Functional and supported, but a different, less-turnkey workflow than Node's
`--inspect` → Chrome DevTools/VS Code (one flag, first-class). **Stepping original TS in an *embedded*
`JSContext` via source map is unproven-in-hand → a named spike item.**
- https://webkit.org/blog/13936/enabling-the-inspection-of-web-content-in-apps/

**F5. TS language features are engine-invariant.** Types/interfaces/generics erase; enums, decorators,
`using`/`Symbol.dispose` **downlevel through `tsc`** to ES2020+ JS. `using` needs `target ≤ ES2022` +
a two-line `Symbol.dispose ??= Symbol("Symbol.dispose")` polyfill — mechanical, not spike-blocking.
- https://www.typescriptlang.org/docs/handbook/release-notes/typescript-5-2.html

**Verdict: TS support is MARGINALLY degraded under JSC — dev-loop conveniences only (native TS-run,
turnkey debugger), never shipping capability. Does not move the engine recommendation.**

---

## G. Build-vs-adopt — are we reinventing something? (Agent 7)

**G1. The mechanism exists; APIAnyware's architecture does not.** Typed-TS-on-Cocoa is *not* novel —
but every prior tool dispatches through a **runtime libffi + metadata blob consulted per call**:
- **JXA** — Apple's JSC bridge, but *automation scripting* (an OSA component), **runtime dynamic
  message-passing**, untyped by Apple (community `@jxa/*` typings derive from app **sdef** scripting
  dictionaries, not Cocoa framework headers). Opposite architecture on APIAnyware's defining axis.
  https://developer.apple.com/library/archive/releasenotes/InterapplicationCommunication/RN-JavaScriptForAutomation/Articles/OSX10-10.html · https://github.com/JXA-userland/JXA
- **NativeScript-macOS** (`runtime-node-api`/`napi-ios`) — the closest neighbour: it **does**
  auto-generate `.d.ts` and build real AppKit apps — **but** "based on Node-API and **libffi**," with
  **metadata "consulted when an unknown entry is encountered"** and marshalling per call. The dumb-data
  blob interpreted by a *smart* runtime — the exact inversion of APIAnyware.
  https://github.com/NativeScript/runtime-node-api · https://docs.nativescript.org/guide/metadata · https://blog.nativescript.org/macos-node-api-preview/
- **NodObjC** — runtime libffi + BridgeSupport, untyped, **abandoned** (fails on modern Node).
  https://github.com/TooTallNate/NodObjC/issues/73
- **Deno/Bun FFI** — raw runtime FFI, manual per-call `objc_msgSend` casts, no typed binding.
  https://docs.deno.com/runtime/fundamentals/ffi/

**G2. The genuine differentiator is architectural, not capability.** None ship **generated
ahead-of-time per-signature native dispatch behind a dumb runtime with zero call-time metadata lookup,
hermetically isolated per target** (ADR-0010/0013/0055). That triad eliminates the runtime
metadata/marshalling tax — a *performance/architecture* differentiator. Typed-TS-on-Cocoa exists;
*this way of doing it* does not. **Verdict: not reinventing** — and the JSC engine choice makes the
differentiation *sharper* (all-Swift generated core vs NativeScript's libffi interpreter).

---

## H. Ecosystem accounting — what dropping Node actually costs (Agent 7)

**H1. React Native is the anchor: bundled npm JS runs on JSC at scale.** RN's engine is JSC (or
Hermes); Metro "bundles all your JavaScript code, along with the `node_modules`." Pure-JS npm packages
(lodash, date-fns, parsers) bundle and run; the NativeScript-macOS preview pulls a pure-JS npm package
(`popmotion`) into a JSC/Node-API app. esbuild `platform: neutral` exists for exactly this.
- https://reactnative.dev/docs/javascript-environment · https://reactnative.dev/docs/metro · https://esbuild.github.io/api/#platform

**H2. What is genuinely lost.** (a) npm packages that `require` **Node built-ins** (`fs`/`net`/`http`/
`stream`/`crypto`/`child_process`/`os`/`worker_threads`) without a shim — RN's own docs: "these modules
… are **not automatically available** in other environments such as browsers and React Native"; (b) any
package shipping a native **`.node` addon** (Node-ABI). This is the "servers, CLIs, native-binding"
slice of npm.
- https://github.com/parshap/node-libs-react-native

**H3. What is retained.** All **pure-JS npm** (the large majority of utility/parse/date/math/state
libs), **all build tooling** (`tsc`/esbuild/vitest/eslint run on the dev machine's Node, never ship),
and **all of Cocoa** via the generated bindings. Concurrency returns via **shared-nothing
`JSVirtualMachine`-per-thread** (Web-Worker-like) + GCD.

**H4. Capability substitution for a *native* app.** Node stdlib capabilities are all reachable through
the generated Cocoa bindings: `fs`→`NSFileManager`; `net`/`http`→`NSURLSession`/Network.framework;
`crypto`→CryptoKit/Security; `child_process`→`NSTask`; concurrency→GCD/`NSOperationQueue`. Capability
loss ≈ 0 for a native app; what's lost is the *Node API shape* + packages hard-bound to it.

**Verdict: "we lose npm" is misleading for a native macOS target.** The loss is the **Node runtime API
surface + native-addon npm** — bounded, Cocoa-substitutable, and a subset RN already runs past at scale.

---

## I. Async model + polyfill effort — the "two products" axis

**I1. `async`/`await`/`Promise` are NOT lost — they are engine-native.** They are ECMAScript built-ins
(ES2015/2017); JSC has had them for years, and JSC drains the microtask queue on the outermost
native→JS return (§A3), so `Promise.then`/`await` chains resolve. What is lost is **not the async
*language*, but the host-provided async *primitives* that async code awaits**: `setTimeout`/
`setInterval`, I/O callbacks, `fetch` — none are engine built-ins (§A2). `queueMicrotask` is a
WHATWG global (not ECMAScript), so it needs a one-line `Promise.resolve().then` shim; `console` needs
an `NSLog`/`os_log` shim.

**I2. The Cocoa runloop *is* the event loop.** Under JSC there is no libuv, but `NSApplication.run()`'s
CFRunLoop is a full event loop. Async primitives are thin bridges onto it: `setTimeout` →
`dispatch_after`/`NSTimer`; async I/O → `NSURLSession`/GCD **resolving a JS Promise from the ObjC
completion** (bounced to main, the resolver held by a `JSManagedValue` — §B). This machinery is exactly
the Q6 callback/threading layer the target builds anyway; async-that-awaits-Cocoa is its natural output.

**I3. Polyfill effort — two philosophies, and they are two products (the user's framing, confirmed).**
- **Minimal Cocoa-idiomatic shim (small).** `setTimeout`/`setInterval`/`queueMicrotask` + `console` +
  the Promise↔Cocoa-completion bridge — low hundreds of lines, most of it the Q6 layer already on the
  roadmap. I/O/networking/crypto are **not** reshaped as `fs`/`fetch`; they are exposed as Cocoa
  (`NSURLSession`, `NSFileManager`, CryptoKit) through the bindings — idiomatic per the Q2.3 steer
  (invariant over local idiom). This is the **"typed TS directly over Cocoa"** product.
- **Node-stdlib-compat polyfills (large, open-ended).** Reimplement `fs`/`net`/`http`/`stream`/`crypto`/
  `buffer`/`process` with Node's shapes so Node-shaped npm packages "just work." A fidelity treadmill
  you never finish, and native-addon packages still fail. **Even React Native declines this** — it
  ships browser globals + native modules and says Node core "is not available," leaving polyfills as
  opt-in community shims (`node-libs-react-native`). Chasing Node-compat on JSC is re-implementing Node
  badly; if Node's ecosystem/DX is the requirement, that argues for **keeping Node**, not polyfilling it
  onto JSC. This is the **"the Node ecosystem, on macOS, with Cocoa access"** product.

**Verdict:** async/await survives on JSC with a *small* shim (timers + console + microtask +
Promise-bridge). The *large* effort only appears if you insist JSC impersonate Node — which is the wrong
tool for that job. **The polyfill question therefore resolves by product identity, not by effort
estimate** (§Synthesis).

---

## Synthesis — the decision, the honest counter-case, the reframing

### Decision matrix (native macOS ObjC-binding target)

| Axis | JavaScriptCore (system) | Node + V8 + N-API | Winner |
|---|---|---|---|
| Native-core shape | all Swift/ObjC — no Rust, no N-API, **no libuv, no C++ pump shim** | Swift dylib + (Rust or Swift) N-API addon + C++ pump shim | **JSC** (ADR-0010 north star) |
| Threading / runloop | cooperative; **ADR-0056 pump dissolves** | libuv pump as guest (ADR-0056 machinery) | **JSC** |
| Memory | +`JSManagedValue` supported backstop + cycle-break (B4) | FR-only backstop ("may never run") | **JSC** (partial) |
| Distribution | 0 MB, 1–2 signatures, 1 optional entitlement (E4) | ~50 MB, N signatures, 2 mandatory entitlements | **JSC** (decisive) |
| Longevity | Apple's own engine; not subject to JS-runtime churn on macOS | third-party runtime; engine-agnostic N-API hedge | **JSC on macOS** (reframes D1) |
| ES2024 `using` native | behind a flag → **downlevel via `tsc`** (A5) | native (V8) | Node (minor; downlevel closes it) |
| TS developer experience | build-time = identical; loses dev-loop conveniences (F) | native `node file.ts`, turnkey `--inspect` | Node (marginal; dev-loop only) |
| `async`/`await`/`Promise` | **engine-native**; awaited primitives (timers/I/O) are a small Cocoa shim (I) | native + libuv-backed timers/I/O | wash (small shim) |
| Reinvention / architecture | sharpens the differentiator (generated core vs libffi interpreter) (G) | same | **JSC** (neither reinvents) |
| Ecosystem | loses **Node runtime API + native-addon npm** (bounded, Cocoa-substitutable, RN-proven); pure-JS npm bundles fine (H) | full npm, `worker_threads`, libuv threadpool | **Node** |

**Nine of ten axes favor or are neutral-to JSC; the ecosystem axis is the whole counter-case — and it
is a *product-identity* choice, not a technical deficit (§below).**

### The honest counter-case — and why it is a *product* choice, not a technical one

The decisive reframing (the user's, confirmed by §H/§I): **JSC is not a weaker Node — it is a
different product.** The ecosystem axis is real but bounded, and what remains is a product-identity
fork, not a capability gap:

1. **What is *not* lost:** `async`/`await`/`Promise` (engine-native, §I1); pure-JS npm (bundles, §H1);
   all build tooling (§H3); all of Cocoa via the bindings (§H4). The earlier "we lose pure-JS npm"
   framing was wrong — RN runs bundled npm on JSC at scale.
2. **What *is* lost:** the **Node runtime API surface** (`fs`/`net`/`http`/`stream`/`worker_threads` —
   the shapes TS/JS devs know) and **native-addon npm**. Capabilities return via Cocoa; the *familiar
   Node shapes* and the *ecosystem of packages hard-bound to them* do not (§H2/§H4).
3. **The two products (the crux):**
   - **JSC-APIAnyware = "typed TS directly over Cocoa"** — all-Swift core, system framework, tiny
     `.app`, the pump gone; you write against `NSURLSession`/`NSFileManager`, not `fetch`/`fs`. A
     **small** Cocoa-idiomatic shim (timers/console/microtask/Promise-bridge — §I3) is all the
     "polyfill" needed. Aligns with the ADR-0010 north star.
   - **Node-APIAnyware = "the Node ecosystem, on macOS, with Cocoa access"** — familiar Node shapes and
     npm, at the cost of a bundled ~50 MB runtime, the libuv pump (ADR-0056), Electron-class
     distribution, and a Rust-or-Swift N-API core. Chasing Node-compat *on JSC* is re-implementing Node
     badly (§I3) — if this is the product, keep Node.
   - This is **the** decision, and it is the user's: not "is JSC good enough" (it is, technically) but
     "which product is `typescript`." The polyfill-effort question resolves here — *small* for the JSC
     product, *open-ended and wrong-tool* for the Node product.
4. **D1 hedge is inverted, not free.** ADR-0054 §4 chose N-API to avoid betting on one JS *runtime*;
   JSC bets on Apple's engine — arguably safer on macOS (C4), and the Node/Deno/Bun portability was
   already half-illusory (the loop seam doesn't port). §4's philosophy is rewritten, not merely edited.
5. **First-hand unknowns remain** — the k3/k6 bar is not yet cleared for JSC (below).

### Core-language axis — resolved independently of the engine

Whichever engine wins, **Rust/napi-rs should go**: under JSC there is no N-API; under Node, Swift-native
N-API beats napi-rs given generated dispatch (D4). This is the cleanest durable conclusion of the
research and does not wait on the spike.

### Preliminary recommendation

- **Engine: JavaScriptCore**, strong lean *if* the product is "typed TS over Cocoa, native macOS
  app" (which the ADR-0010 north star, the distribution win, and the pump dissolution all point to) —
  pending (a) the spike clearing the named unknowns and (b) an explicit **product-identity** steer from
  the user (§counter-case #3): the JSC product accepts Node-shaped-ecosystem loss for an all-Swift,
  system-framework, zero-bundle native app; the Node product keeps npm/Node-shapes at the cost of the
  bundled runtime + pump. This is not "is JSC good enough" — it is "which product is `typescript`."
- **Core language: moot under JSC** (all-Swift/ObjC core); if Node were kept, Swift-native N-API. Either
  way, **drop Rust/napi-rs.**
- **Polyfill posture (if JSC):** a *small* Cocoa-idiomatic shim (timers + console + `queueMicrotask` +
  the Promise↔Cocoa-completion bridge, mostly the Q6 layer) — **not** Node-stdlib-compat shims (§I3).

---

## Named first-hand unknowns (what the spike sibling must clear — the k3/k6 bar)

**JSC leg (decisive):**
1. **Dispatch through JSC** — drive the generated `@_cdecl objc_msgSend` entries via the JSC C API
   (wrapping them as `JSObjectMakeFunctionWithCallback`/host functions), probe-1 shape **incl. the x8
   `CGRect` struct-by-value return** (the marshalling-depth wall — must re-prove through JSC, as k3 did
   through napi-rs).
2. **`NSApplication.run()` coexistence is trivial** — a `JSVirtualMachine` on thread 0 under a real
   `NSApp.run()` with **no pump**; confirm timers/microtasks/GC deferred-work ride the main CFRunLoop
   and which runloop mode(s) they use (survive modal/nested modes?).
3. **bg→main callback** — probe-3 shape: GCD worker → main via `dispatch_async(main)` invoking a
   **`JSManagedValue`-held** JS function; confirm no off-main JS re-entry.
4. **`JSManagedValue` delegate-cycle** — build the WWDC button↔handler cycle, register the managed
   reference, drop both roots, confirm the ObjC object `-dealloc`s after GC (not leaked, not prematurely
   killed); measure last-root-dropped→release latency; which thread runs the release.
5. **`using`/`Symbol.dispose` downlevel** — confirm `tsc`-downlevelled `using` + a `Symbol.dispose`
   polyfill drives `[Symbol.dispose]` correctly on macOS-26 JSC (native ERM off by default, A5); and
   whether the flag is reachable via any public means.
6. **FR-on-main + prompt-enough** — confirm `FinalizationRegistry` cleanup fires on the main CFRunLoop
   under `NSApp.run()` and reclaims under normal GC pressure (A4 implies yes from source).
7. **Nested microtask interleave** — when the dispatch layer calls a JS callback via `JSValue.call`
   from *within* a native trampoline, are pending microtasks drained at that inner boundary or only the
   outermost (A3 covers only the outermost)?
8. **Async shim** — a `setTimeout`/`setInterval` on `dispatch_after`/`NSTimer` + a `Promise` resolved
   from an `NSURLSession`/GCD completion (bounced to main) drives `await` correctly under `NSApp.run()`
   (proves the Cocoa-runloop-as-event-loop model, §I2); `queueMicrotask` one-line shim.
9. **Pure-JS npm on JSC** — bundle a real pure-JS package (e.g. date-fns / a parser) with esbuild
   (`platform:neutral`/`browser`) and confirm it evaluates and runs in an embedded `JSContext`
   (ESM/CJS interop; no `process`/`Buffer` needed), and spot the real "silently needs a Node builtin"
   rate on a representative dependency set (§H1/§H2).
10. **Debug original TS in an embedded `JSContext`** — `isInspectable = true`, attach Safari Web
    Inspector, set a breakpoint in the `.ts`, confirm the source map resolves it (public API exists;
    embedded-context + source-map end-to-end unproven, §F4).

**Swift-native N-API leg (contingency — run only if the product steer keeps Node in contention):**
8. A Swift `.node` (node-swift-style or direct `@_cdecl`) **loads + dispatches** under the target Node
   major on arm64; a **`napi_threadsafe_function` bounce from Swift** works (Swift error → `napi_throw`,
   no unwind across the C ABI); coexists with the C++ pump shim; and — if Swift `async`/actors touch the
   loop thread — the custom-executor↔loop binding survives (node-swift #49 class).

---

## Findings adopted (forward pointers — reworked by the spike sibling, not here)

- **ADR-0054** — §1 dispatch is engine-invariant (C2/§C: `JSExport` is not a framework bridge; keep the
  generated `@_cdecl` entries). §2 core becomes all-Swift/ObjC under JSC (no Rust, no N-API). §3 polarity
  simplifies (JSC cooperative, no pump). §4 D1 rationale rewritten (C4 reframing).
- **ADR-0056** — **largely dissolves** under JSC (no libuv, no pump, no `pump_shim.cc`); the bg→main
  bounce becomes `dispatch_async(main)` + `JSManagedValue`, not `napi_threadsafe_function`.
- **ADR-0057** — spine unchanged; §5 gains `JSManagedValue` (B4); §7 FR-on-main still holds (A4); §8
  pools simplify (ambient AppKit pool + launcher `@autoreleasepool`, no pump passes). §Engine caveat
  resolved.
- **`CONTEXT.md`** *TypeScript target toolchain* — reworked when the decision is **settled** (spike),
  not here.
- **Cross-target** — `project_native_runloop_authoritative`: under JSC the "pump each runtime as a
  guest" concern doesn't arise (JSC has no competing loop) — a datapoint for that grove.
