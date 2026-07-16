# typescript (Node) — FFI model (§18)

How the typescript binding crosses into native code. The choices here are recorded in ADRs
0054/0025/0013/0056/0057/0058/0059/0061 (no `target.apiw`/`policies/`/`adapters/spec.apiw`
exist for this target yet — see `overview.md`). This page is their prose; the mechanism
detail in full is [`reference.md`](reference.md), and the exhaustive per-child build history
is [`../bindings/node/native/README.md`](../bindings/node/native/README.md).

## One FFI layer: N-API, generated

Unlike the Lisp targets (an interpreted C-function FFI plus a separate ObjC message-dispatch
layer), TypeScript has **one** boundary: **N-API** (Node-API), the ABI-stable C surface
every Node native addon crosses through. N-API's own primitives (`napi_call_function`,
generic value marshalling) are too slow and too loosely typed to dispatch ~300k ObjC method
signatures directly, so the emitter generates one **typed, content-addressed** `@_cdecl`
napi callback per distinct ABI signature — the racket ADR-0013 shape, ported to N-API
(ADR-0054). Each entry reads its JS args with the correct N-API accessor for that arg's ABI
code, `unsafeBitCast`s `objc_msgSend` to the matching `@convention(c)` function-pointer
shape, and marshals the result back — a coercion-free typed crossing generated once per
signature, not per call.

`runtime-model`: unlike ffi2's dynamic dispatch, a TypeScript call site is a **direct JS
function call** into the addon's exports object (`__dispatch.aw_ts_msg_<code>(...)`) — no
runtime symbol lookup per call, since N-API `napi_define_properties` binds every generated
entry once at module load (`awRegisterGeneratedDispatch`).

## The projection posture — trampoline-elided

The vast **directly-reachable ObjC surface** dispatches through the generated `aw_ts_msg_*`
table with **no native adapter in the path** beyond the addon itself (ADR-0025) — there is
no separate `adapters/macos/` package the way the four Lisp targets have; the addon *is*
both the generated-dispatch host and the adapter, because N-API forces a single loadable
unit anyway. Three residual categories still need special handling:

| construct | route |
|---|---|
| directly-reachable ObjC method/init | generated `aw_ts_msg_<code>` napi callback — the addon's own dispatch table |
| fallible method (`NSError**` / may-throw) | the non-folding `…_e` sibling entry — native `@try`/`@catch` in `src/awexc.m` (ADR-0058) |
| Swift-native free function (`s:` USR, no C symbol) | a by-name `aw_ts_swift_<Module>_<name>` napi callback (ADR-0061, the racket ADR-0027 analogue) |
| constant global | `aw_ts_const_<code>` — `dlsym`s the symbol, loads by result shape (ADR-0025 link-time-fact posture) |
| escaping/noescape ObjC block | a synthesized heap or stack-scoped ObjC block whose invoke is a generated inbound trampoline (ADR-0059 §2) |
| delegate / protocol conformance | a per-protocol synthesized forwarding class, set-time `respondsToSelector:` snapshot (ADR-0059 §3) |
| dynamic subclass override | `objc_allocateClassPair` + a generated typed inbound trampoline per override (ADR-0059 §4) |

## Threading — native runloop authoritative (ADR-0056)

The **native Cocoa runloop is authoritative**: a native `main()` owns thread 0
(`NSApplication.run()`), and Node's libuv event loop is **pumped as a guest** — a helper
thread polls `uv_backend_fd` and signals a `kCFRunLoopCommonModes` source that lock-steps
one `uv_run(NOWAIT)` per wake (mechanism (c), chosen over a single-thread `CFFileDescriptor`
shape (b) that was proven viable but not shipped). This is the opposite polarity from a
plain `node app.js`, and it is why this target's distribution model cannot reuse a shared
runtime binary (see `reference.md` §Distribution). Any callback arriving on a non-main
thread (GCD completion, libuv threadpool, a framework callback) **bounces** to thread 0
through a singleton `napi_threadsafe_function` before touching JS — `void` bounces are
fire-and-forget, value-returning and `dealloc` bounces block the origin thread on a
completion semaphore. The governing constraint (user-stated): the binding must not break
the runtime's own threading facilities — `worker_threads`, the libuv threadpool, timers, and
microtask ordering all run natively under `NSApp.run()`, verified first-hand.

## The native adapter — `APIAnywareTypeScript.node`

The single Swift-native N-API addon (ADR-0054 §2; `bindings/node/native/`), this target's
**sole native unit** (ADR-0011 hermetic isolation). It hosts, in one loadable `.node`: the
generated outbound dispatch table, the generated inbound trampoline table (IMPs, block
makers, `$super` sends), the generated Swift-native residual trampoline table, the
plain-C free-function table, the fixed delivery/bounce machinery (`src/bounce.swift`), the
libuv pump (`src/pump.swift` + `src/pump_shim.cc`), and the one non-Swift unit — `src/awexc.m`,
an MRC ObjC shim, because Swift cannot `@catch` an `NSException` and one must never unwind a
C ABI through a Swift frame. N-API symbols resolve at `dlopen` (`-undefined dynamic_lookup`)
against whichever host loads the addon, so it runs unmodified on Node, and — for dispatch,
not GUI integration — on Bun and (with caveats) Deno.

## See also

- [`representability.md`](representability.md) — how the thin-direct posture and its
  residuals are measured for this target.
- [`reference.md`](reference.md) — the full dispatch/memory/threading/error mechanism.
- [`../bindings/node/docs/user-guide.md`](../bindings/node/docs/user-guide.md) — the
  user-facing threading and dispose contract.
