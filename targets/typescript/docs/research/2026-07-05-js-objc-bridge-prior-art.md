# JS/TS↔ObjC bridges & runtime FFIs — prior art for the `typescript` target

**Status:** research finding (commissioned by grove `add-typescript-target-language`,
leaf `js-objc-bridge-prior-art-k2`). Feeds the design grilling
`typescript-target-k1`: the runtime + dispatch model, object/`.d.ts` surface,
memory, threading, error, callback, and distribution decisions.
**Date:** 2026-07-05.
**Method:** five-angle fan-out web research (NativeScript · Deno FFI · Bun FFI ·
Node FFI ecosystem · transferable-lessons cluster) → primary-source fetch →
cross-angle corroboration of the load-bearing crux (three independent angles
confirmed the `objc_msgSend`-recast capability via three different APIs). Every
load-bearing claim carries a primary-source URL; current-version facts (Deno
2.9.1, Bun 1.3.14, koffi 3.1.0, napi 3.8.5, PyObjC 12.2.1 — all 2026) were
checked against live docs/changelogs/issue trackers, not training memory. Where a
search came up empty, the absence is recorded as a finding (§Gaps).

> **How to read this doc.** The design grilling should treat the [capability
> matrix](#the-crux--d1d2-per-runtime-ffi-capability-matrix) and the
> [Synthesis](#synthesis--pre-judging-d1d8) as the pre-judged evidence base and
> spend its budget on what they leave open, not on re-deriving what is settled
> here. Each surveyed system ends with a **takeaway** naming the design
> question(s) its lesson informs. Where a tempting claim could not be verified,
> it is flagged inline rather than stated as fact.

---

## Headline

**The crux (D2) is a decisive YES for three of the four candidate runtimes, so
`typescript` is *not* forced into racket's fat generated-native-dispatch shape
(ADR-0013) the way the Lisp-family assumption implied — trampoline elision
(ADR-0025) is reachable in TypeScript.** Deno (`Deno.UnsafeFnPointer`), Bun
(`bun:ffi` `CFunction`), and Node (`koffi.call(ptr, proto)`) can each take the
single `objc_msgSend` address and recast it to a fresh concrete ABI signature per
call site at runtime — the exact move the arm64 ABI demands (ADR-0013's "each
call site must be cast to a concrete `@convention(c)` shape"). A **real working
Deno↔ObjC bridge** (`DjDeveloperr/deno_objc`) already does precisely this over
`libobjc.dylib`.

**But three findings reshape the design before it is grilled:**

1. **Struct-by-value splits the field.** Deno and koffi pass/return `CGRect`/
   `NSRect`-style structs by value; **Bun cannot** — `bun:ffi` has no aggregate
   `FFIType`, the feature request has sat open since 2023, and there is *no*
   workaround for by-value *returns*
   ([oven-sh/bun#6139](https://github.com/oven-sh/bun/issues/6139)). That alone
   disqualifies Bun for AppKit/CoreGraphics geometry, and `bun:ffi` is anyway
   self-labelled *experimental, not for production*, with Bun's own docs steering
   native work to a **Node-API module** ([bun.sh/docs/api/ffi](https://bun.sh/docs/api/ffi)).
2. **Background-thread callback delivery is where the runtimes diverge hardest,
   and only N-API answers it cleanly.** Every JS engine is single-threaded, so an
   ObjC callback firing on a background thread must be marshalled to the JS
   thread. Deno, Bun, and koffi all do this *by queueing to the isolate/main
   thread* with real deadlock and crash failure modes; **N-API's
   `napi_threadsafe_function` is the only first-class, multi-thread-safe path**
   ([nodejs.org/api/n-api](https://nodejs.org/api/n-api.html)).
3. **A native (Swift) library is unavoidable regardless of elision.** ADR-0025
   still requires a per-target trampoline for the **Swift-native delta**, and
   *every* mature bridge surveyed (NativeScript, NodObjC, PyObjC, RubyCocoa) is
   `objc_msgSend`-based and therefore stuck at the **ObjC ceiling** — none reach
   pure-Swift value types / generics / async. So "fully-elided = zero native
   code" is not actually on the table for the complete-API model; the real
   question is how *thin* the native library can be.

**Convergent signal.** NativeScript's *newest* runtime
(`runtime-node-api` / `napi-ios`) is an **engine-agnostic Node-API + libffi**
ObjC bridge that reaches Foundation/AppKit/Metal, added **macOS/AppKit**, and
runs on **both Node and Deno**
([NativeScript/runtime-node-api](https://github.com/NativeScript/runtime-node-api)).
A serious team independently landed on Node-API as the ObjC-bridge substrate —
direct corroboration that the Node-API route is viable for exactly this target.

⇒ The grilling's live fork is **Deno-elision** (pure-FFI, `UnsafeFnPointer`
recast, thinnest possible native library) **vs. Node-API generated-dispatch**
(racket-shaped, ABI-stable, best threading). **Bun is dominated** (struct wall +
experimental) and the dead `node-ffi` lineage is out.

---

## Part A — The runtime FFI substrates (D1 + D2, the crux)

### A1. Deno FFI — `Deno.dlopen` / `UnsafeFnPointer` / `UnsafeCallback`

**Mechanism.** Deno's FFI declares symbols through `Deno.dlopen(path, symbols)`
and — critically — can construct a typed callable from an **arbitrary address**
via `new Deno.UnsafeFnPointer(pointer, { parameters, result })`, added expressly
"to call functions that are not present as symbols"
([docs.deno.com UnsafeFnPointer](https://docs.deno.com/api/deno/~/Deno.UnsafeFnPointer);
motivating issue [denoland/deno#13336](https://github.com/denoland/deno/issues/13336)).
Memory primitives (`UnsafePointer.create/value/of`, `UnsafePointerView`
`getCString`/`getPointer`/…) and struct types (`{ struct: [...] }`) round it out
([docs.deno.com/runtime/fundamentals/ffi](https://docs.deno.com/runtime/fundamentals/ffi/)).

**The crux — YES, demonstrated in working code.** `DjDeveloperr/deno_objc`
`dlopen`s `libobjc.dylib`, loads `objc_msgSend` as a **static `{ type: "pointer" }`
address** (not a pre-bound callable), and for *every* selector reads the ObjC type
encoding at runtime (`method_copyReturnType`/`method_copyArgumentType`) and
builds a **fresh `UnsafeFnPointer` over that one address** with the selector's
concrete signature, then `.call(...)`s it
([deno_objc/src/objc.ts](https://raw.githubusercontent.com/DjDeveloperr/deno_objc/main/src/objc.ts)).
Struct encodings (`CGRect` → 4×f64) map to `{ struct: [...] }` for both args and
returns ([deno_objc/src/encoding.ts](https://raw.githubusercontent.com/DjDeveloperr/deno_objc/main/src/encoding.ts)).
It supports dynamic class creation with JS-implemented methods, `NSBundle`
framework import (`objc.import("AppKit")`), autorelease pools, and a JSX/AppKit
demo.

**Walk-away check.** With `deno_objc` uninstalled, the *technique* remains fully
legible — the recast-per-selector algorithm is documented API usage, and the
LuaJIT `ffi.cast` bridges are the same shape. What does **not** transfer is its
naive encoder (it maps ObjC `long` → `i32` — wrong on LP64 where `long` is 8
bytes) and its per-call `UnsafeFnPointer` allocation (no signature cache) — both
are quality bugs a generated binder fixes, not design lessons.

**Failure modes (cited).**
- **Off-thread callbacks never run on the calling thread.** A callback fired from
  a native/background thread is marshalled to the isolate thread and runs there
  synchronously on an event-loop turn; it **cannot return a value to the
  background thread** ([denonomicon: thread-safe callbacks](https://denonomicon.deno.dev/callbacks/thread-safe)).
  Breaks any ObjC API expecting a synchronous result from an off-main-thread
  callback (GCD blocks, KVO, `NSURLSession` delegates).
- **Deadlock:** a *synchronous* FFI call that blocks awaiting a foreign-thread
  callback freezes the isolate — it can't drain the loop to run the callback
  (same source).
- **High-frequency callback crash** (`DisallowJavascriptExecutionScope`,
  [denoland/deno#22947](https://github.com/denoland/deno/issues/22947)); past
  nested-struct-by-value crash, since fixed
  ([#17482](https://github.com/denoland/deno/issues/17482) / PR #18531).
- **No signature type-checking at the boundary** — a wrong `parameters`/`result`
  is UB/segfault, entirely on the generator.

**Maintenance + distribution.** FFI was **stabilized in Deno 2.0** (PR
[#25213](https://github.com/denoland/deno/pull/25213); only `--allow-ffi`
permission now, no `--unstable-ffi`); latest **v2.9.1, 2026-07-01**
([releases](https://github.com/denoland/deno/releases)). `deno compile` produces a
standalone binary that can use FFI; **system** dylibs (`/usr/lib/libobjc.dylib`,
`Foundation`) are `dlopen`ed by absolute path and need no bundling, while
app-private dylibs must be `--include`d and are unpacked to a temp dir at runtime
([docs.deno.com/runtime/fundamentals/ffi](https://docs.deno.com/runtime/fundamentals/ffi/)).

**Takeaway.** The strongest **elision** substrate: proven end-to-end, struct-by-
value present, FFI stable and actively maintained, clean single-binary story.
Informs **D1** (top elision candidate), **D2** (elision reachable), **D8**
(distribution). Its one architectural liability is **D5** off-thread callbacks.

### A2. Bun FFI — `bun:ffi` (`dlopen` / `CFunction` / `JSCallback`)

**Mechanism.** `bun:ffi` exposes `dlopen(path, symbols)` and — the crux enabler —
`CFunction({ ptr, args, returns })`, which builds a callable from an **arbitrary
address** ("Since this doesn't use `dlsym()`, you have to provide a valid ptr").
Each distinct signature is **JIT-compiled to a bespoke C trampoline via embedded
TinyCC** ([bun.sh/docs/api/ffi](https://bun.sh/docs/api/ffi)). Bun's engine is
**JavaScriptCore** — the same family NativeScript's original iOS runtime embedded.

**The crux — YES, but no exemplar and a fatal marshalling gap.** You can wrap the
`objc_msgSend` address in many `CFunction` shapes (or call `dlopen` once per
signature); the recast itself works. **However:**
- **Struct-by-value is flatly unsupported.** `FFIType` has no aggregate type;
  feature request [oven-sh/bun#6139](https://github.com/oven-sh/bun/issues/6139)
  is open since Sep 2023. You cannot declare a `CGRect`/`CGPoint`/`NSRange`
  argument or return by value; the only workarounds are pointer-to-struct or
  **expanding struct members into scalar params** (as the `bunray` raylib binding
  does — [theoparis/bunray](https://github.com/theoparis/bunray)), which must be
  hand-matched to the arm64 aggregate ABI and has **no answer at all for by-value
  returns**. A large fraction of AppKit/CoreGraphics geometry selectors are
  therefore unreachable without hand-rolled shims.
- **`bun:ffi` is officially experimental.** The docs banner: *"`bun:ffi` is
  experimental, with known bugs and limitations, and should not be relied on in
  production. The most stable way to interact with native code from Bun is to
  write a Node-API module."*

**Walk-away check.** No Bun↔ObjC bridge exists to borrow (searches found the
`objc_msgSend`-recast pattern only in LuaJIT, Nim, Go, Ruby, pure C — never Bun).
The LuaJIT ObjC bridge ([fjolnir gist](https://gist.github.com/fjolnir/2211379))
is the nearest algorithmic template. `bunray` is the concrete proof of both the
capability *and* the struct limitation.

**Failure modes (cited).** Struct-by-value wall (above); **off-thread callbacks
crash-prone** — `threadsafe: true` is documented reliable only from JS `Worker`
threads, delivery from arbitrary native threads is a *"future version"* item that
has segfaulted ([#15925](https://github.com/oven-sh/bun/issues/15925)); no
variadic ([#12389](https://github.com/oven-sh/bun/issues/12389)); no async
callbacks; pointers stuffed into 53-bit JS `number`s. `bun build --compile`
supports `bun:ffi` and absolute-path system-dylib `dlopen`, embedding app dylibs
via `with { type: "file" }` ([bun.com/docs/bundler/executables](https://bun.com/docs/bundler/executables)).

**Takeaway.** **Dominated.** Passes D2's recast test but fails struct-by-value
(D3 marshalling) and off-thread callbacks (D5), atop experimental status (D1
maintenance risk). Its own docs point to the Node-API route. Keep as a fallback
data point, not a primary candidate.

### A3. Node FFI ecosystem — koffi, the N-API addon route, and the dead lineage

Node offers **two** viable substrates plus one dead one.

**koffi (the modern runtime FFI — Node's D2 answer).** `Koromix/koffi` 3.1.0
(2026-06-29, active) decouples *prototype* from *pointer*: declare any signature
with `koffi.proto('int F(int,int)')`, then call an **arbitrary address** with
`koffi.call(ptr, proto, ...args)` or materialise a reusable function via
`koffi.decode(ptr, proto)` ([koffi.dev/pointers](https://koffi.dev/pointers)).
So the same `objc_msgSend` address is callable under many protos — crux **YES**.
koffi additionally does **variadic** (`'...'` + type/value pairs) and
**struct-by-value both directions** ([github.com/Koromix/koffi](https://github.com/Koromix/koffi)).
Its callback story is the weakness: JS callbacks "must run on the main thread," a
foreign-thread call is **queued to the main thread** and "can deadlock … if your
main thread never lets the JS event loop run" ([koffi.dev/callbacks](https://koffi.dev/callbacks)).
No koffi↔ObjC exemplar exists ("no primary source found" — greenfield).

**The N-API addon route (the racket-shaped, generated-dispatch answer).** Instead
of a runtime FFI, generate a **compiled native addon** that vends **typed C-ABI
dispatch entries, one per selector signature** — the exact ADR-0013 shape. This
buys:
- **ABI stability across Node majors.** Node-API is "ABI stable across versions
  of Node.js … allow[ing] modules compiled for one major version to run on later
  major versions without recompilation"
  ([nodejs.org/api/n-api](https://nodejs.org/api/n-api.html)) — the durability
  `node-ffi` fatally lacked.
- **First-class background-thread callbacks.** `napi_threadsafe_function` /
  napi-rs `ThreadsafeFunction` (v3 redesigned to be `Arc`-shareable across
  threads) is the clean, multi-thread-safe path the runtime FFIs can't match
  ([napi.rs threadsafe-function](https://napi.rs/docs/concepts/threadsafe-function),
  [announce-v3](https://napi.rs/blog/announce-v3)). napi-rs is healthy (napi
  3.8.5, cli 3.7.2, 2026).
- **Convergence.** NativeScript's `runtime-node-api` is exactly this —
  "engine-agnostic NativeScript runtime based on Node-API and libffi" reaching
  ObjC (Foundation/AppKit/Metal), runnable under **both Node and Deno**
  ([github.com/NativeScript/runtime-node-api](https://github.com/NativeScript/runtime-node-api)).

**The dead lineage (post-mortem).** `NodObjC` (`TooTallNate/NodObjC`, node-ffi +
BridgeSupport XML) already did per-selector `objc_msgSend` recasting — a fresh
libffi CIF per signature, cached in `msgSendCache` via `new ffi.Library(null, {
objc_msgSend: [rtn, args] })` ([NodObjC core](https://tootallnate.github.io/NodObjC/core.html)).
But last publish was **2015**, and its `node-ffi`/`ffi-napi` dependency is
**dead**: `ffi-napi@4.0.3` is from 2021, and its own tracker begs "PLEASE ARCHIVE
THIS REPO — the code fails on modern Node.js" (Windows Node ≥18, Linux/macOS Node
≥21), recommending migration **to koffi**
([node-ffi-napi#269](https://github.com/node-ffi-napi/node-ffi-napi/issues/269)).
NodObjC is effectively non-functional on Apple-silicon modern Node. **Takeaway:
its recast *technique* is validated prior art; its *substrate* is a warning about
node-gyp/ABI fragility — the reason to prefer koffi (prebuilt N-API) or a
generated N-API addon (ABI-stable).**

**Takeaway (Part A3).** Node gives the grilling *both* poles of the ADR-0025 vs
ADR-0013 axis: **koffi = elision on Node** (but weak threading), **N-API addon =
generated typed dispatch** (best threading + durability, heavier build). Informs
**D1**, **D2**, **D5**, **D8**.

---

## Part B — The production metadata bridges (whole-pipeline prior art)

### B1. NativeScript (iOS/macOS) — the closest prior art to *everything*

**Three runtime generations, one dispatch model.** NativeScript rewrote its iOS
runtime twice, but the dispatch architecture — **compile-time metadata blob +
generic libffi → `objc_msgSend`** — is constant across all three:
1. `ios-jsc` — original JavaScriptCore runtime, frozen at v6.5.6 (Sept 2022)
   ([NativeScript/ios-jsc](https://github.com/NativeScript/ios-jsc)).
2. `NativeScript/ios` — JSC replaced by **V8 in `--jitless` mode**, current
   (v9.0.3, Jan 2026) ([the-new-ios-runtime-powered-by-v8](https://blog.nativescript.org/the-new-ios-runtime-powered-by-v8/)).
3. `runtime-node-api` / `napi-ios` — **engine-agnostic Node-API + libffi**, added
   **macOS/AppKit + visionOS**, preview since Aug 2024
   ([macos-node-api-preview](https://blog.nativescript.org/macos-node-api-preview/)).

**Mechanism.** A Clang-based **metadata generator** parses the SDK headers at
build time into a compact binary blob embedded in the app; the runtime consults it
and marshals **every** call through **libffi** at runtime, ending in
`objc_msgSend` — a real crash stack shows `ArgConverter::Invoke` →
`Interop::CallFunctionInternal` → `FFICall`
([docs: metadata](https://docs.nativescript.org/guide/metadata),
[ns-v8ios-runtime#32](https://github.com/NativeScript/ns-v8ios-runtime/issues/32)).
The **same metadata generates the `.d.ts`** (`ns typings ios` →
`@nativescript/types-ios`), so one artifact feeds both dispatch and the type
surface ([generate-typings](https://docs.nativescript.org/guide/native-code/generate-typings)).
Memory is a **"splice"** linking each ObjC instance to its JS wrapper, flipping
the wrapper strong/weak as the ObjC refcount crosses 1↔2 using JSC's engine-
integrated GC roots ([memory-management](https://old.docs.nativescript.org/core-concepts/memory-management)).
JS is **pinned to the main thread's runloop**; background work uses JSON-only
Workers ([multithreading](https://docs.nativescript.org/guide/multithreading)).
`NSError**` methods drop the out-param and **throw** a JS error (or capture via
`interop.Reference`) ([ios-marshalling](https://docs.nativescript.org/guide/ios-marshalling)).

**Walk-away check.** Borrowable and engine-independent: the **metadata-generator-
over-headers** pattern, **one-artifact-feeds-runtime-and-`.d.ts`** invariant, the
**splice** GC↔refcount *design*, and the `NSError**`→throw/`Reference` idiom.
Mechanism-specific and non-transferable: the **generic-libffi-per-call dispatch**
(the opposite of generated typed dispatch, and the source of its perf/startup
tax), the JSC-`protect` engine roots, and the `--jitless` App-Store workaround.

**Failure modes (cited).**
- **Metadata size ⇒ startup/app-size tax.** Official docs concede including all
  APIs means "performance could be degraded at runtime … larger metadata … and
  app size could increase" — the whole reason for `native-api-usage.json`
  filtering ([docs: metadata](https://docs.nativescript.org/guide/metadata)).
  Real reports of 7–14 s iOS cold starts
  ([NativeScript#9865](https://github.com/NativeScript/NativeScript/issues/9865)).
  *(No primary source found quantifying the blob in MB — the concern is
  documented qualitatively only.)*
- **The Swift-only `@objc` wall.** "the SwiftMessages class is not exposed to
  Objective-C, and therefore not accessible from NativeScript"; the only fix is a
  hand-written `@objc`/`@objcMembers` wrapper. Swift structs, enums, generics,
  tuples, non-`@objc` members are all unreachable
  ([swift-symbols-inaccessible](https://blog.nativescript.org/swift-symbols-inaccessible/)).
  **This is the hard ceiling APIAnyware's Swift-native ambition (ADR-0025) must
  clear — NativeScript offers zero prior art for it.**
- **Leaky GC↔refcount reconciliation** (multi-cycle `JS→Native→JS` chains free
  linearly; large-native-object pressure invisible to GC; "half-dead splice"
  race) ([ios-jsc#1035](https://github.com/NativeScript/ios-jsc/issues/1035)).
- **NSException handling fragile / under-documented**
  ([ios-jsc#1044](https://github.com/NativeScript/ios-jsc/issues/1044)).
- **Background→main callback hop is a manual sharp edge** (`CFRunLoopPerformBlock`
  by hand) ([NativeScript#6851](https://github.com/NativeScript/NativeScript/issues/6851)).
- **Two-runtime maintenance burden** drove the V8 rewrite (their forked JSC
  "diverged significantly," upgrades "up to 3 person-months")
  ([v8 runtime post](https://blog.nativescript.org/the-new-ios-runtime-powered-by-v8/)).

**macOS status.** AppKit is real but **preview-grade and only via the Node-API
runtime** — the JSC and V8 iOS runtimes never targeted AppKit. `napi-ios` has "no
releases published"; one flagship shipped app exists
(`nativescript-macos-solid`, on the Mac App Store, macOS 14+ arm64
[repo](https://github.com/ammarahm-ed/nativescript-macos-solid)). **Not dead,
actively revived under Node-API, but not yet a mature macOS binding** — leaving
room, and confirming Node-API viability.

**Takeaway.** The definitive whole-pipeline prior art. **D1**: validates
metadata-over-headers but exposes its runtime-consultation tax (favours *pre-
generated* dispatch). **D2**: the canonical counter-example — generic-libffi-per-
call is the slow path to avoid. **D3**: one-artifact→`.d.ts` is the architecture;
its opaque-JS-object protocol modelling is a weakness to improve. **D4**: splice
design borrowable but leaky. **D5**: bg→main hop must be a first-class primitive,
not left to users. **D6**: `NSError**`→throw idiom. **D8**: metadata+frameworks
into the signed `.app` is well-trodden. Above all it **red-lines the Swift-only
ceiling** as the differentiator.

### B2. PyObjC — the canonical still-maintained metadata bridge (decades of lessons)

Not JS, but the deepest continuously-maintained metadata bridge (v12.2.1,
2026-06-19, Python ≥3.10, arm64 [PyPI](https://pypi.org/project/pyobjc/)), and its
lessons transfer directly.

- **Method resolution.** Purely mechanical: "the Python method name equivalent is
  simply the selector with colons replaced by underscores" (`doX:withY:` →
  `doX_withY_`); keyword collisions escape with a trailing `__`; PyObjC "does not
  ever rename selectors" ([intro](https://pyobjc.readthedocs.io/en/latest/core/intro.html)).
  → **D3:** colon→underscore is *one* option (JSExport prefers colon-elision +
  camelCase — B4); pick TS's deliberately.
- **Metadata — the "runtime introspection can't give you this" lesson.** ObjC
  type encodings are lossy, so PyObjC layers hand/BridgeSupport metadata for
  exactly what the runtime can't express: **struct layouts** (`createStructType`),
  **pointer direction** (`_C_IN`/`_C_OUT`/`_C_INOUT`), **C array bounds**, and
  **variadics** ([metadata/manual](https://pyobjc.readthedocs.io/en/latest/metadata/manual.html)).
  → **D3:** APIAnyware's IR/annotation overlay must carry these from day one — a
  names-only or encodings-only model is provably insufficient.
- **`NSError**` → tuple (strong D6 prior art).** PyObjC does **not** use an
  exception channel for `NSError**`; it folds out-params into the return: `[return,
  *out-args]`, one element returned bare, several as a **tuple** — canonical
  `rowCount, colCount = m.getNumberOfRows_columns_(None, None)`; a `…error:` method
  returns `(result, error)`, with `objc.NULL` the sentinel for "pass real NULL"
  ([intro](https://pyobjc.readthedocs.io/en/latest/core/intro.html)). True
  `NSException`s bridge bidirectionally, Python exception stashed in `userInfo`
  ([exceptions](https://pyobjc.readthedocs.io/en/latest/notes/exceptions.html)),
  but ObjC exceptions "are typically only used for disaster recovery, not error
  handling" — i.e. `NSError**`→tuple is the *normal* path.
- **Memory / threading.** Refcounts auto-bridged, but **autorelease pools are
  thread-local** and must be modelled per-thread; ObjC calls release the GIL,
  creating documented `performSelectorOnMainThread` re-entrancy deadlocks that
  PyObjC guards with safe wrappers ([threading-helpers](https://pyobjc.readthedocs.io/en/latest/api/threading-helpers.html)).
  → **D4/D5:** the JS analogue of the GIL is the single JS thread; provide safe
  main-thread-dispatch wrappers that never let a callback exception escape the
  runloop.
- **Dynamic subclassing / delegates (D7).** A Python subclass of a Cocoa class
  *becomes* a real ObjC class; `@objc.python_method` opts a method *out* of the
  selector vtable; formal/informal protocol objects model `@protocol`. Delegates
  "often do **not** retain," so keep a reference
  ([intro](https://pyobjc.readthedocs.io/en/latest/core/intro.html)).
- **Swift boundary:** ObjC-ceiling, explicitly — "Frameworks marked 'Swift only'
  … cannot be wrapped by PyObjC"
  ([framework-wrappers](https://pyobjc.readthedocs.io/en/latest/notes/framework-wrappers.html)).

**Walk-away check.** Everything above is documented independent of a running
PyObjC and borrowable: the selector-mapping rule, the lossy-encoding→metadata-
overlay necessity, the `NSError**`→tuple idiom, the delegate-retain caveat.

**Takeaway.** The richest source for **D3** (metadata overlay), **D6** (the
`NSError**`→tuple pattern to weigh against NativeScript's throw), **D7**
(subclass-as-ObjC-class + protocol modelling), and **D4/D5** (per-thread
autorelease, main-thread re-entrancy).

### B3. NodObjC — covered in [A3](#a3-node-ffi-ecosystem--koffi-the-n-api-addon-route-and-the-dead-lineage)

Its BridgeSupport dependency also matters for **D3**: BridgeSupport XML is Apple's
old metadata format, and shipped files **lag the SDK** (e.g. Eclipse SWT bug
[#546697](https://bugs.eclipse.org/bugs/show_bug.cgi?id=546697) "bridgesupport
files … quite outdated"). → APIAnyware should generate its own metadata from the
SDK (as it already does), not depend on shipped BridgeSupport.

---

## Part C — Transferable lessons (memory, embedding, static typing)

### C1. MacRuby / RubyCocoa — why MacRuby died (the load-bearing D4 warning)

**RubyCocoa** was a libffi + BridgeSupport bridge, deprecated by Apple in favour
of MacRuby in 2008 ([Wikipedia: RubyCocoa](https://en.wikipedia.org/wiki/RubyCocoa)).
**MacRuby** went further — a *reimplementation of Ruby on the ObjC runtime + its
garbage collector + LLVM*, where Ruby objects **were** ObjC objects and memory was
**ObjC GC (libauto)** ([MacRuby repo](https://github.com/MacRuby/MacRuby)).

**The post-mortem (verbatim, primary).** The MacRuby README states the cause of
death: **"Due to Apple's abandonment of the Objective-C Garbage Collector
(libauto) which MacRuby relied heavily on, future development of MacRuby is on an
indefinite hiatus."** Apple deprecated ObjC GC in favour of **ARC** and made it a
hard App Store requirement ("Mac Apps That Use Garbage Collection Must Move to
ARC", deadline 2015-05-01 [Apple news](https://developer.apple.com/news/?id=02202015a)).
Organisationally, momentum collapsed after lead Laurent Sansonetti left Apple and
the team pivoted to the commercial RubyMotion (which **replaced GC with ARC**)
([macruby mailing-list thread](https://groups.google.com/g/macruby/c/JbzaHTljLPs),
[Wikipedia: MacRuby](https://en.wikipedia.org/wiki/MacRuby)).

**Walk-away lesson (D4/D5).** A language runtime that **fuses its object identity
and GC with Apple's memory-management regime is existentially fragile to Apple's
platform changes** — the GC→ARC shift alone was fatal. The bridges that *never*
fused (PyObjC, RubyCocoa) outlived MacRuby by a decade-plus; PyObjC still ships in
2026. **For APIAnyware: do not make the JS object model *be* the ObjC object
model, and do not bind the memory strategy to any single Apple mechanism.** Keep
the JS heap and ObjC heap as two cooperating systems joined by an **explicit,
replaceable retain/release seam.** (This aligns with ADR-0011 isolation and the
existing per-target lifetime ADRs — chez 0007, sbcl 0036.)

### C2. JavaScriptCore `JSExport` / JSC C API — why a raw FFI is needed on top

Apple's JavaScriptCore framework (`JSContext`/`JSValue`/`JSExport`) embeds a JS
engine and marshals values, but `JSExport` is a **manual, curated, per-class
allow-list**, not an automatic framework bridge. From Apple's `JSExport.h`
verbatim: *"By default no methods or properties of the Objective-C class will be
exposed to JavaScript; however methods and properties may explicitly be
exported"* — per class, by adopting a `<JSExport>` protocol; selector→JS-name
strips colons and capitalises the next letter
([JSExport.h](https://raw.githubusercontent.com/phoboslab/JavaScriptCore-iOS/master/JavaScriptCore/API/JSExport.h)).
Crucially it **"cannot call arbitrary C functions or use raw C-ABI access"** and
is limited to passing ObjC blocks ([NSHipster: JavaScriptCore](https://nshipster.com/javascriptcore/)).
The lower-level JSC C API (`JSObjectMakeFunctionWithCallback`) is still hand-wired
embedding, not `objc_msgSend`/C-ABI dispatch.

**Takeaway.** JSC embedding gives the *engine and value marshalling* for free but
exposes **zero** framework surface automatically. APIAnyware needs a **raw FFI /
`objc_msgSend` dispatch layer**; JSExport is the wrong tool for whole-framework
coverage. (Relevant because Bun *is* JSC and NativeScript *embedded* JSC — neither
gets framework coverage from `JSExport`; both add an FFI/metadata layer.)

### C3. objc2 / swift-bridge — how a statically-typed language models the graph (D3)

- **objc2** (Rust, v0.6.4, active) models ObjC's dynamic graph in a static type
  system: `extern_class!` creates a type carrying its **superclass/inheritance**,
  `extern_protocol!` creates a **separate trait** for a protocol, methods via
  `extern_methods!`, dispatch via `msg_send!` with **compile-time,
  encoding-checked** type safety; memory is a **`Retained<T>` smart pointer**
  (replacing the older `Id<T>`) giving automatic retain/release within the
  ownership model ([docs.rs/objc2](https://docs.rs/objc2/latest/objc2/)).
- **swift-bridge** (Rust↔Swift, v0.1.59, Jan 2026) generates a typed C-ABI shim
  **on both sides** from a declarative `#[swift_bridge::bridge]` module —
  transparent value structs, opaque handles, `async`, `Result`/`Option`/`Vec`
  ([github.com/chinedufn/swift-bridge](https://github.com/chinedufn/swift-bridge)).

**Takeaway (D3 + Swift-delta).** objc2 is the closest static-typed analogue for
the `.d.ts` shape: model each class as a **named type carrying its inheritance
chain**, each protocol as a **separate interface** classes declare conformance
to, and wrap every instance in a **`Retained<T>`-style branded handle** so the
memory contract lives *in the type* (TS: a branded/disposable handle, not a bare
object — dovetails with C4's `Symbol.dispose`). For the **Swift-native delta**
(ADR-0025), swift-bridge is the pattern: a **generated C-ABI shim on both sides**
is how you cross the Swift ABI without the ObjC runtime — the mechanism to reach
the Swift-only surface PyObjC/NativeScript structurally cannot.

### C4. FinalizationRegistry vs. `Symbol.dispose` — the D4 memory verdict

**FinalizationRegistry (ES2021) is not sufficient as the primary `release`
hook.** MDN is emphatic (primary):
- *"a conforming JavaScript implementation … is not required to call cleanup
  callbacks … may be called then, or some time later, or **not at all**."*
- No timing/ordering guarantees; **won't run** when the program shuts down (tab
  close) or when the registry itself becomes unreachable.
- *"best avoided if possible"*; *"developers **shouldn't rely on cleanup
  callbacks for essential program logic**"*
  ([MDN: FinalizationRegistry](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/FinalizationRegistry)).

A missed callback = a leaked ObjC object (retain never balanced); skipped-at-
shutdown = a leak on every exit; no ordering = can't sequence child-before-parent
release. **The production pattern is deterministic disposal: ES2024 `using` /
`await using` with `Symbol.dispose` / `Symbol.asyncDispose`** — MDN frames
resource management as *"not an optional feature about optimization, **but a core
feature to write correct programs**"*
([MDN: Resource management](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Resource_management)).
`deno_bindgen` already ships native handles that dispose via `using`
([denoland/deno_bindgen](https://github.com/denoland/deno_bindgen)).

**Verdict (D4).** Make handles **`Symbol.dispose`-implementing** (`using h =
NSFoo.alloc().init()` → deterministic `release`) as the *primary* mechanism, and
register the same handles with a **FinalizationRegistry purely as a leak-detector
backstop** that warns if the deterministic path was skipped. This is the analogue
of the Lisp targets' finalize/guardian hooks (sbcl `finalize` ADR-0036, chez
guardian ADR-0007) — but where those trust the GC hook, the JS evidence says the
GC hook cannot be trusted alone. **`.d.ts` generation** likewise follows
napi-rs / deno_bindgen: the type surface is a **build artifact generated from
metadata**, never hand-maintained ([napi.rs](https://napi.rs/)).

---

## The crux — D1/D2 per-runtime FFI capability matrix

Each cell cited above; **✔** = documented + (where noted) demonstrated, **✘** =
unsupported, **~** = supported-with-caveat.

| Capability | **Deno FFI** | **Bun `bun:ffi`** | **Node koffi** | **Node N-API addon** |
|---|:--:|:--:|:--:|:--:|
| **Recast one address → arbitrary per-call-site signature** (the elision test) | ✔ `UnsafeFnPointer`; **proven** in `deno_objc` | ✔ `CFunction(ptr,…)` | ✔ `koffi.call(ptr,proto)` | ✔ generated at build time (per-signature C cast) |
| **Variadic C calls** | ✘ (not needed on arm64) | ✘ ([#12389](https://github.com/oven-sh/bun/issues/12389)) | ✔ (`'...'`) | ✔ (static per-site) |
| **Struct-by-value arg + return** (`CGRect`/`NSRect`; x8 return) | ✔ `{ struct }` | **✘ hard gap** ([#6139](https://github.com/oven-sh/bun/issues/6139)) | ✔ both directions | ✔ native C ABI |
| **JS→native callback** | ✔ `UnsafeCallback` | ✔ `JSCallback` | ✔ `koffi.register` | ✔ |
| **Thread-safe callback from a bg thread** | ~ queued to isolate; can't return sync; deadlock risk | ~ Worker-only; native-thread crash-prone | ~ queued to main; deadlock risk | **✔ first-class `ThreadsafeFunction`** |
| **Pointer r/w, `dlopen`, symbol-from-address** | ✔ | ✔ (address via FFI `dlsym`) | ✔ | ✔ |
| **Maintenance health** | ✔ stable (Deno 2.0+), v2.9.1 2026-07 | ~ **experimental**, "not for production" | ✔ active, 3.1.0 2026-06 | ✔ ABI-stable, napi 3.8.5 2026 |
| **Standalone signed binary** | ✔ `deno compile` (system dylibs free) | ✔ `bun build --compile` | via Node SEA/pkg | prebuilt `.node` in an app |
| **Existing ObjC bridge to borrow** | ✔ `deno_objc` | ✘ none | ✘ none | ✔ `napi-ios` (Node+Deno) |

**Reading the matrix.** This *is* the answer to whether `typescript` is a
fully-elided target or needs a fat native library. **Elision is reachable**
(row 1 is ✔ everywhere) — but **Bun is eliminated** by the struct-by-value gap +
experimental status, and the **background-thread-callback row is the true
discriminator**: it is the one capability no runtime FFI delivers cleanly and only
the N-API addon does. Because the **Swift-native delta needs a native library
regardless** (ADR-0025) and threading may push logic native anyway, the "pure
loader, zero native code" ideal is not actually attainable — narrowing the fork to
**Deno-elision (thinnest native library)** vs **Node-API generated-dispatch
(racket-shaped native library)**.

---

## Synthesis — pre-judging D1–D8

What the evidence **settles** (the grilling may overturn with new evidence, but
the burden is now on the counter-argument):

**D1 — Runtime + FFI substrate.** **A single target, not three.** Bun is
dominated (struct wall + experimental; its own docs point to Node-API). The dead
`node-ffi`/NodObjC lineage is out. The choice is **Deno** vs **Node (via an N-API
addon)** — and note the **Node-API substrate is engine-agnostic and already runs
on both Node and Deno** (`napi-ios`), so a Node-API target is not strictly "Node
only." One idiom per target (ADR-0004) + hermetic isolation (ADR-0011) both argue
*against* spawning `deno`/`bun`/`node` as separate targets: pick one runtime, make
it maximally idiomatic. **Recommended default into the grilling: a single
`typescript` target on Deno if elision is prioritised, or delivered as an N-API
addon if background-thread correctness + ABI durability dominate — decide on D5.**

**D2 — Dispatch model (the crux).** **Elision applies — TypeScript is *not*
forced into ADR-0013's generated-dispatch-for-every-call shape.** Direct
`objc_msgSend` recasting works (proven on Deno, documented on Bun/koffi). The
open sub-question is *hybrid depth*: even choosing elision, a native library is
required for (a) the **Swift-native delta** (ADR-0025) and possibly (b)
**struct-by-value or bg-thread-callback** paths a given runtime handles poorly.
So the model is **elision for the directly-reachable ObjC hot path + a
(thin-to-medium) Swift trampoline library for the residual** — the ADR-0025 model
exactly, with the elision boundary drawn per the chosen runtime's FFI gaps rather
than assumed empty as it is for the Lisp four. If Node-API is chosen, the "hot
path" itself becomes generated typed dispatch (ADR-0013 shape) and elision folds
into codegen.

**D3 — Object model, idiom, `.d.ts`.** **Generate the `.d.ts` from the same
metadata that drives dispatch** (NativeScript's proven one-artifact architecture;
napi-rs/deno_bindgen auto-`.d.ts`). Model the graph the **objc2 way**: each ObjC
class → a named TS type carrying its **inheritance chain**; each protocol → a
**separate interface** classes declare conformance to (improving on NativeScript's
opaque-JS-object protocols); each instance → a **branded/disposable handle**, not
a bare object. The **metadata overlay must carry what runtime introspection
can't** (PyObjC's lesson: struct layouts, pointer direction, array bounds,
variadics) — APIAnyware's IR + LLM-derived annotations already aim here. Idiomatic
TS surface: classes + methods, `async`→`Promise`, structural types; selector→name
mapping is a *deliberate* choice (colon-elision+camelCase per JSExport vs
underscore per PyObjC).

**D4 — Memory.** **`FinalizationRegistry` alone is insufficient — MDN says so
explicitly.** Primary mechanism = **deterministic `Symbol.dispose` / `using`**
(ES2024), FinalizationRegistry only as a **leak-detector backstop**. Do **not**
fuse the JS object model/GC with ObjC's — **MacRuby died of exactly that** when
Apple moved GC→ARC. Keep an **explicit, replaceable retain/release seam** between
the two heaps (aligns with ADR-0011 and the per-target lifetime ADRs). Autorelease
pools are **thread-local** (PyObjC) — model one per JS entry/thread.

**D5 — Threading / main-thread affinity.** **This is the deciding capability.**
Every JS engine is single-threaded; an ObjC callback on a background thread must
hop to the JS thread. Runtime FFIs (Deno/Bun/koffi) all **queue to the isolate/
main thread with deadlock or crash failure modes**; **only N-API's
`ThreadsafeFunction` is first-class multi-thread-safe.** If the target must
correctly handle bg-thread ObjC callbacks (GCD, `NSURLSession` delegates, KVO,
notifications off-main) — and a real macOS app will — this **weighs heavily toward
the Node-API route**, or toward confining Deno/Bun callbacks to the main thread
with an explicit, first-class main-thread-dispatch primitive (never left to users,
per NativeScript's manual-`CFRunLoopPerformBlock` sharp edge). Also unresolved:
the **AppKit-must-own-thread-0** problem when the JS runtime owns the process
(NativeScript pins JS to the main runloop) — the grilling must confirm the chosen
runtime can cede thread 0 to AppKit.

**D6 — Error model.** Two proven idioms to choose between: **PyObjC's `NSError**`
→ `(result, error)` tuple** (with a NULL sentinel) vs **NativeScript's throw-a-JS-
Error** (with `interop.Reference` to capture). For idiomatic TS, **throw `Error`
subclasses for `NSException`** (disaster path) and decide `NSError**` per-idiom —
a tuple/`Result` reads more type-safely in TS, a throw reads more idiomatically;
lean throw-for-exceptions, and weigh tuple-vs-throw for `NSError**` in grilling.
Note both prior arts found **`NSException` surfacing historically crash-prone** —
treat it as a first-class design item, not an afterthought.

**D7 — Callbacks / blocks / delegates / dynamic subclassing.** All reachable from
the runtime FFIs: **closures → ObjC blocks** via `UnsafeCallback`/`JSCallback`/
`koffi.register`; **JS object → delegate** via the PyObjC pattern (a JS
class/registered object *becomes* a real ObjC class, with an opt-out for
pure-JS methods and formal/informal protocol modelling); **dynamic subclassing**
(`objc_allocateClassPair`) is reachable — `deno_objc` already creates classes with
JS-implemented methods (IMP-backed callbacks). Delegate-retain caveat (PyObjC): a
delegate often is **not** retained by its setter — the binding must keep the
reference alive (ties back to D4's disposal seam).

**D8 — Distribution.** `deno compile` and `bun build --compile` both produce a
single binary that can FFI system dylibs by absolute path (no bundling of
`libobjc`/`Foundation`); app-private dylibs are `--include`d (Deno) or embedded
`with { type: "file" }` (Bun). An N-API addon ships as a prebuilt `.node` inside a
Node app (or Node SEA). **Open (a real gap):** none of the surveyed compile paths
documents producing a proper **`.app` bundle with `Info.plist` / correct
`CFBundleName` / per-app TCC identity** — a bare compiled binary is not a bundle,
and macOS TCC (camera/mic/automation prompts) keys on bundle identity. This maps
to the ADR-0009/0041 self-containment problem and **must be designed** (likely: the
bundler wraps the compiled binary into a `.app` skeleton with a generated
`Info.plist`, as the existing targets' bundlers do).

---

## Gaps (absences are findings)

Recorded so a future reader doesn't re-run the same fruitless search:

1. **No green-arm64 CI evidence for `deno_objc`.** Its *design* is arm64-correct
   (routes all returns through one `objc_msgSend`, no `_stret`/`_fpret` — exactly
   the unified arm64 convention) and its *mechanism* ran on macOS CI, but the last
   push was 2023-06 on a then-x86_64 runner with the AppKit test commented out.
   Treat "works on arm64" as **strongly supported by design**, not independently
   CI-verified. The grilling should reproduce a minimal `objc_msgSend` +
   struct-return call on arm64 Deno first-hand before committing.
2. **No `koffi↔objc` or `bun↔objc` exemplar exists** — both are greenfield; the
   recast capability is proven by docs, not by a shipped ObjC binding.
3. **NativeScript metadata blob size** is documented only qualitatively (startup/
   size concern), never quantified in MB.
4. **The `.app`/`CFBundleName`/TCC-identity story for `deno compile` / `bun build
   --compile`** was not established by any primary source (D8 above) — design gap.
5. **AppKit-owns-thread-0 under a JS runtime** is confirmed as a real constraint
   (NativeScript pins JS to the main runloop) but the exact mechanism for a
   *compiled Deno/Bun* binary to cede thread 0 to `NSApplication` was not found —
   verify first-hand in grilling.
6. **Benchmarks for elision-on-Deno vs generated-N-API-dispatch** were not found
   (racket's ADR-0013 numbers are for Racket, not JS). Per-call `objc_msgSend`
   cost in each runtime is unmeasured prior art — a spike, not a survey, will
   settle it (as the racket ffi2 spike did).

---

## Walk-away checks (per system)

- **`deno_objc` uninstalled:** the *recast-per-selector technique* stays fully
  legible (documented `UnsafeFnPointer` usage; LuaJIT bridges are the same shape).
  Its encoder bugs and per-call allocation do **not** transfer — a generated
  binder supersedes them.
- **NativeScript uninstalled:** the *metadata-generator-over-headers* pattern, the
  *one-artifact→runtime+`.d.ts`* invariant, the *splice* GC↔refcount design, and
  the `NSError**`→throw idiom remain documented and borrowable; the *generic-
  libffi-per-call* mechanism is the part deliberately not borrowed, and the
  *Swift-`@objc` ceiling* is the wall it proves APIAnyware must clear.
- **PyObjC uninstalled:** the selector-mapping rule, the lossy-encoding→metadata-
  overlay necessity, the `NSError**`→tuple idiom, the subclass-as-ObjC-class +
  protocol model, and the delegate-retain caveat are all documented and survive.
- **MacRuby uninstalled:** the highest-value walk-away — its GC→ARC death is the
  primary-source proof that **fusing a language runtime's memory model with
  Apple's is existentially fragile**, legible from the repo README alone.
- **JSExport / objc2 / swift-bridge:** the *lessons* survive without the tools —
  "JSC embedding gives no framework surface, a raw FFI is required," the
  static-typed class/protocol/`Retained<T>` shape for `.d.ts`, and the
  both-sides-generated-C-ABI-shim pattern for the Swift delta.

---

### Sources (primary unless noted)

**Deno:** [FFI fundamentals](https://docs.deno.com/runtime/fundamentals/ffi/),
[UnsafeFnPointer](https://docs.deno.com/api/deno/~/Deno.UnsafeFnPointer),
[UnsafeCallback.threadSafe](https://docs.deno.com/api/deno/~/Deno.UnsafeCallback.threadSafe),
[denonomicon thread-safe callbacks](https://denonomicon.deno.dev/callbacks/thread-safe),
[#13336](https://github.com/denoland/deno/issues/13336),
[#25213 (FFI stable in 2.0)](https://github.com/denoland/deno/pull/25213),
[#22947](https://github.com/denoland/deno/issues/22947),
[#17482](https://github.com/denoland/deno/issues/17482),
[releases](https://github.com/denoland/deno/releases),
[DjDeveloperr/deno_objc](https://github.com/DjDeveloperr/deno_objc)
([objc.ts](https://raw.githubusercontent.com/DjDeveloperr/deno_objc/main/src/objc.ts),
[encoding.ts](https://raw.githubusercontent.com/DjDeveloperr/deno_objc/main/src/encoding.ts)).
**Bun:** [bun:ffi docs](https://bun.sh/docs/api/ffi),
[executables](https://bun.com/docs/bundler/executables),
[#6139 struct-by-value](https://github.com/oven-sh/bun/issues/6139),
[#12389 variadic](https://github.com/oven-sh/bun/issues/12389),
[#15925 cross-thread crash](https://github.com/oven-sh/bun/issues/15925),
[releases](https://github.com/oven-sh/bun/releases),
[theoparis/bunray](https://github.com/theoparis/bunray),
[fjolnir LuaJIT ObjC bridge](https://gist.github.com/fjolnir/2211379).
**Node:** [koffi.dev pointers](https://koffi.dev/pointers) /
[functions](https://koffi.dev/functions) / [callbacks](https://koffi.dev/callbacks) /
[changelog](https://koffi.dev/changelog),
[Koromix/koffi](https://github.com/Koromix/koffi),
[nodejs.org/api/n-api](https://nodejs.org/api/n-api.html),
[napi.rs threadsafe-function](https://napi.rs/docs/concepts/threadsafe-function) /
[announce-v3](https://napi.rs/blog/announce-v3),
[TooTallNate/NodObjC](https://github.com/TooTallNate/NodObjC)
([core](https://tootallnate.github.io/NodObjC/core.html)),
[node-ffi-napi#269 (archive plea)](https://github.com/node-ffi-napi/node-ffi-napi/issues/269),
[ffi-napi npm](https://registry.npmjs.org/ffi-napi).
**NativeScript:** [metadata](https://docs.nativescript.org/guide/metadata),
[ios-marshalling](https://docs.nativescript.org/guide/ios-marshalling),
[generate-typings](https://docs.nativescript.org/guide/native-code/generate-typings),
[multithreading](https://docs.nativescript.org/guide/multithreading),
[memory-management](https://old.docs.nativescript.org/core-concepts/memory-management),
[swift-symbols-inaccessible](https://blog.nativescript.org/swift-symbols-inaccessible/),
[V8 runtime](https://blog.nativescript.org/the-new-ios-runtime-powered-by-v8/),
[macOS Node-API preview](https://blog.nativescript.org/macos-node-api-preview/),
[runtime-node-api](https://github.com/NativeScript/runtime-node-api),
[napi-ios](https://github.com/NativeScript/napi-ios),
[nativescript-macos-solid](https://github.com/ammarahm-ed/nativescript-macos-solid),
[#9865 startup](https://github.com/NativeScript/NativeScript/issues/9865),
[ios-jsc#1035](https://github.com/NativeScript/ios-jsc/issues/1035),
[#6851 main-thread hop](https://github.com/NativeScript/NativeScript/issues/6851).
**PyObjC:** [intro](https://pyobjc.readthedocs.io/en/latest/core/intro.html),
[metadata/manual](https://pyobjc.readthedocs.io/en/latest/metadata/manual.html),
[exceptions](https://pyobjc.readthedocs.io/en/latest/notes/exceptions.html),
[threading-helpers](https://pyobjc.readthedocs.io/en/latest/api/threading-helpers.html),
[framework-wrappers](https://pyobjc.readthedocs.io/en/latest/notes/framework-wrappers.html),
[PyPI](https://pypi.org/project/pyobjc/).
**MacRuby/RubyCocoa:** [MacRuby repo](https://github.com/MacRuby/MacRuby),
[Apple GC→ARC news](https://developer.apple.com/news/?id=02202015a),
[macruby list thread](https://groups.google.com/g/macruby/c/JbzaHTljLPs),
[Wikipedia: MacRuby](https://en.wikipedia.org/wiki/MacRuby) (secondary),
[Wikipedia: RubyCocoa](https://en.wikipedia.org/wiki/RubyCocoa) (secondary).
**JSExport / static bridges / memory:**
[JSExport.h](https://raw.githubusercontent.com/phoboslab/JavaScriptCore-iOS/master/JavaScriptCore/API/JSExport.h),
[NSHipster JavaScriptCore](https://nshipster.com/javascriptcore/),
[docs.rs/objc2](https://docs.rs/objc2/latest/objc2/),
[chinedufn/swift-bridge](https://github.com/chinedufn/swift-bridge),
[MDN FinalizationRegistry](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/FinalizationRegistry),
[MDN Resource management](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Resource_management),
[denoland/deno_bindgen](https://github.com/denoland/deno_bindgen),
[napi.rs](https://napi.rs/),
[BridgeSupport(5)](https://keith.github.io/xcode-man-pages/BridgeSupport.5.html),
[Eclipse SWT bug #546697](https://bugs.eclipse.org/bugs/show_bug.cgi?id=546697),
[arm64 objc_msgSend (mikeash)](https://www.mikeash.com/pyblog/friday-qa-2017-06-30-dissecting-objc_msgsend-on-arm64.html) (secondary).
