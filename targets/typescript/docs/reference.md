# typescript (Node) — Target Reference

The consolidated target-wide learnings from Steps 2–8 of `adding-a-language-target.md` —
the worked-example doc a future target's author (or a future maintainer of this one) reads
first. Design rationale lives in the ADRs (0054–0061) and is cited, not restated; the
exhaustive per-build-child mechanism narrative lives in
[`../bindings/node/native/README.md`](../bindings/node/native/README.md) and is distilled,
not copied, here.

## 0. Toolchain

Confirmed host during the build: macOS 26.5.1 arm64, Swift 6.3.3, Apple clang 21,
Node v26.4.0 (shared `libnode.147.dylib` + shared `libuv.1.dylib`, Homebrew), TypeScript
5.9.3. Node-API headers come from the active `node`'s Cellar include dir — **no node-gyp,
no Rust**. The native addon builds with `swiftc` + `clang` directly
(`bindings/node/native/build.sh`); the runtime builds with `tsc`
(`bindings/node/runtime/package.json`).

## 1. Overview

`typescript` binds macOS system frameworks for Node.js as real ES6 classes over directly-
dispatched Objective-C (ADR-0055), with a single Swift-native N-API addon
(`APIAnywareTypeScript.node`) as the sole native unit (ADR-0011). Build order is always
**generate → build**: `apianyware-generate --target typescript` renders the emitted TS/`.d.ts`
+ the four Swift `Generated/*.swift` entry tables from the committed IR, then
`bindings/node/native/build.sh` compiles the addon against them.

## 2. Emitter architecture (`tools/emit-typescript/`)

The crate implements the shared `TargetEmitter` contract (`targets/_shared/tools/emit/`,
ADR-0044) for `typescript`. Its modules, grouped by concern:

- **Class/type surface**: `class_binding.rs` (the `TypeRefKind::Class` binds/degrades/defers
  triage — ADR-0055 §1b), `class_graph.rs` (the declared-class recognition set + parent
  resolution + degradation floor), `class_surface.rs` (per-class method/param rendering),
  `protocol_binding.rs` / `protocol_graph.rs` (protocol emittability + the class/protocol
  namespace-collision rename, ADR-0055 §4c), `enum_graph.rs` / `emit_enums.rs`.
- **Emission**: `emit_class.rs`, `emit_dts.rs`, `emit_functions.rs`, `emit_protocol.rs`,
  `emit_constants.rs`, `emit_framework.rs` (the per-framework barrel + orchestration).
- **Dispatch/ABI**: `native_dispatch.rs` (entry-name content-addressing, incl. the `…_o`/`…_e`
  retain/exception axes), `dispatch_table.rs` / `inbound_table.rs` / `function_table.rs`
  (the four generated Swift tables — see §3), `ffi_type_mapping.rs`, `swift_abi.rs`,
  `ptr_value.rs` (the SEL/Class value crossing), `trampoline.rs` (the Swift-native `s:`
  residual, ADR-0061).
- **Cross-cutting**: `naming.rs` (selector→name, incl. reserved-identifier escaping),
  `imports.rs` (import-honesty: value-import only a declared class, the runtime root, or a
  bound superclass), `method_filter.rs`, `override_widening.rs` (SDK-incompatible-override
  union rendering), `delegate_spec.rs` (`arg_kind`/`ret_kind` value classification, shared by
  outbound dispatch, the delegate spec, and the subclass catalogue), `subclass_surface.rs`.

**One decision, N readers** is the load-bearing discipline across this crate: `naming.rs`'s
`param_identifier`, `class_binding.rs`'s bind/degrade/defer triage, and `delegate_spec.rs`'s
value-kind classification are each computed **once** and read verbatim by every emitter,
table collector, and import walker that needs the fact — never re-derived at a second site.
Every defect this target's build surfaced past the initial spine was some variant of a
*lossy map reused as a key* (a class-name lowercasing, an ABI-shape code standing in for an
ownership fact, a raw registry key conflated with a rendered display name) — worth checking
for explicitly whenever a new map is introduced as a lookup key.

## 3. The generated entry tables

Four Swift tables, rendered by `apianyware-generate --target typescript` into
`bindings/node/native/src/Generated/` (gitignored, byte-stable across regeneration —
`BTreeSet` ordering):

| table | content | registered by |
|---|---|---|
| `DispatchTable.swift` | outbound `aw_ts_msg_<code>` (+ `…_o` non-folding, `…_e` `@catch` siblings) | `awRegisterGeneratedDispatch` |
| `InboundTable.swift` | inbound `aw_ts_inb_<code>` typed IMPs, block-maker switches, `aw_ts_super_<code>` `$super` sends | `awGeneratedInboundIMP(forEncoding:)` / `awRegisterGeneratedSuperSends` |
| `TrampolineTable.swift` | the Swift-native `s:` free-function residual, `aw_ts_swift_<Module>_<name>`, keyed per **symbol** not per signature | `awRegisterGeneratedTrampolines` |
| `FunctionTable.swift` | the plain-C free-function corpus, `aw_ts_fn_<name>` (2192 exports / 317 shared bodies) | consulted directly by generated call sites |

**The mirror invariant**: the entry set the emitted `.ts` call sites *reference* must equal
the set the table collectors *generate* — unit-tested over the whole corpus, and asserted
against the frontier (not a call site) where none exists yet (the inbound table, ahead of
any call site referencing a given override). Over-collection is the safe failure mode: an
unused generated entry is a harmless dead export; a missing one is a runtime `TypeError`.

## 4. Memory model (ADR-0057)

Every wrapped ObjC object reaches JS at a **uniform +1**, tracked in a `Map<id, WeakRef>`
uniquing table (`__wrapRetained` for a +0/borrowed return, `__wrapOwned` for a genuine +1
convention return — `alloc`/`new`/`copy`/`init…`). Deterministic disposal is **primary**:
`Symbol.dispose` + TS 5.2 `using` declarations release the wrapped object immediately when
its scope exits. A `FinalizationRegistry` is the **best-effort backstop** for a caller that
forgets to dispose — GC timing is non-deterministic, so it is a safety net, never the
primary contract. `__wrapRetained`/`__wrapOwned` both `release` the incoming +1 on a
live-duplicate re-fetch (the wrapper already owns the one +1) — this is the general
retain-fold rule, extended to a **third channel** (constants,
`pointer-constant-ownership-k92`) beyond the original two (methods, free functions): a
constant read's ownership is a **wrap-boundary fact**, forked on the shared
`is_object_type` predicate, never derived from the lossy `AbiType` ABI-shape code that
collapses every pointer-like to one `Ptr` shape.

## 5. Error model (ADR-0058)

`NSError**` out-parameters surface as a type-visible `Result<T>` (`ok: true, value` /
`ok: false, error`); `unwrap(r)` escalates a failure to a thrown `NSExceptionError`/
`NSErrorError`. `NSException` (from a genuinely fallible call) is caught **natively** — an
`@try`/`@catch` in `src/awexc.m`, a small hand-written MRC ObjC unit, because Swift cannot
`@catch` an `NSException` and an exception must never unwind a C ABI through a Swift frame.
A Swift `throws` API routes through the same `Result` channel. The selector keeps the
injective `_error_` token (from ADR-0039's `:`→`_` mapping) even where the `NSError**`
parameter itself is elided from the TS signature.

## 6. Callbacks, blocks, delegates, subclassing (ADR-0059)

Four inbound surfaces share one machinery (generated typed `@_cdecl` trampolines, the
inbound dual of the outbound dispatch table):

- **Dynamic subclass** — `objc_allocateClassPair` + a generated typed IMP per override,
  content-addressed by `"<selector>|<encoding>"`.
- **Delegate/protocol conformance** — one synthesized forwarding class **per protocol**
  (memoized, never per-object), a per-instance `respondsToSelector:` bitset snapshot stamped
  at set-time (exact `@optional` fidelity — the load-bearing correctness point NativeScript's
  invisible-rows bug got wrong).
- **Blocks** — `NS_NOESCAPE` gets a direct-invoke fast path with no registry persistence
  (the runtime brackets make/release around the call); the escaping/unknown default wraps a
  real heap block, pins the JS function in the runtime's callback registry for the block's
  life, and tears down via the same bounce mechanism §7 uses.
- **`$super` / overridable `dealloc` / added methods** — generated `aw_ts_super_<code>`
  entries dispatch via `objc_msgSendSuper` (method lookup begins at the emitted parent,
  skipping the synthesized subclass's own override — the ADR-0034 recursion trap native
  `super.` would hit); a shared `-dealloc` IMP on every synthesized class runs a JS override
  against a still-live handle, then chains `[super dealloc]` only if there was none.

Keep-alive for every inbound surface is a strong `objc_setAssociatedObject`/registry entry,
released on the dealloc path above — the loop that pins a bound subclass/delegate for as
long as ObjC can call it, and only that long. Exception containment (`onCallbackError`)
wraps every inbound delivery so a JS throw never unwinds a C ABI.

## 7. Threading (ADR-0056)

Native Cocoa runloop authoritative; libuv pumped as a guest — see `ffi-model.md` for the
polarity and its rationale. Mechanically: `src/pump.swift` (a helper thread polling
`uv_backend_fd`, signalling a `kCFRunLoopCommonModes` source, lock-stepping one
`uv_run(NOWAIT)` per wake through a semaphore) + `src/pump_shim.cc` (the V8-scoped pump
body: `uv_run(NOWAIT)` inside `HandleScope`+`Context::Scope`+microtask checkpoint — a bare
`uv_run` from a runloop callback crashes `CheckImmediate` on the first `setImmediate`, and
N-API's public surface exposes neither the scope nor the checkpoint). Off-main callback
delivery bounces through a **singleton** `napi_threadsafe_function`
(`src/bounce.swift`): `void` bounces are fire-and-forget backpressured enqueues;
value-returning and synchronous-`dealloc` bounces block the origin thread on a completion
semaphore. **Deadlock caveat**: a value-returning or `dealloc` bounce while thread 0 is
itself synchronously blocked (a `dispatch_sync`, a thread join) deadlocks — thread 0 cannot
service the tsfn. The mitigation is discipline, not a mechanism: never synchronously block
thread 0 while a bound object may be releasing off-main.

## 8. Runtime library (`bindings/node/runtime/src/`)

The hand-written `@apianyware/runtime` npm package every emitted module imports its seam
symbols from: `dispatch.ts` (the generated-entry call surface the emitted `.ts` calls),
`classes.ts` (the base class + `alloc`/`init` machinery), `lifetime.ts` (`__wrapRetained`/
`__wrapOwned`, the dispose/FR wiring), `result.ts`/`errors.ts` (the `Result<T>` channel +
`ObjCError`/`NSExceptionError`/`NSErrorError`), `callbacks.ts`/`delegate.ts`/`blocks.ts`/
`subclass.ts`/`super.ts` (the four inbound surfaces' JS-side registries and brackets),
`marshal.ts` (value coercion), `structs.ts` (the nine-member POD geometry family — `CGRect`
etc., runtime-owned and type-only, nested to mirror the C struct), `seam.type-test.ts` (a
compile-time guard on the seam's own type surface, pending the corpus gate going green).
Every module has a co-located `*.test.ts` (`vitest`).

## 9. Verification

- **Native addon tests** (`bindings/node/native/test/*.mjs`) — headless, Foundation-only
  integration checks per mechanism (dispatch, inbound, delegate, blocks, `$super`, retain,
  error, constants, Swift-native residual, geometry, dynamic-class-wrap). Run via
  `node test/<name>.mjs` after `build.sh`.
- **Embedder harness** (`bindings/node/native/harness/`) — the one battery that needs AppKit
  actually loaded: the libuv pump, the bg→main bounce, off-main inbound delivery, escaping
  blocks, off-main dealloc, and the CGRect struct-return path (which needs AppKit loaded to
  exercise; the addon-only tests use the headless-safe `NSRange`).
- **Snapshot/golden tests** — `emit-typescript/tests/snapshot_test.rs`, the shared
  `GoldenTest` harness (TestKit synthetic + real Foundation-IR layers). Step 6 of
  `adding-a-language-target.md` is satisfied by this; no separate Step-6 leaf was grown.
- **Corpus-typecheck gate** — see `representability.md` §Measurement. The standing,
  whole-corpus type-surface guard; still red on a known, owned residual (33 TS2559 as of
  `sample-apps-k112`).

## 10. Sample apps & bundling

All **seven** portfolio apps (`app-implementations/macos/`) are built and TestAnyware
VM-verified, each with its own dev `build.sh` (regenerate → `tsc` → link a **dev-only**
launcher) and a `bindings/macos/reports/<app>/report.md` + `learnings.md`. Every app's
`embed_main.mm` proves the ADR-0060 §1 embedding sequence: a native `main()` embeds Node via
`CommonEnvironmentSetup`/`LoadEnvironment` **without** entering `SpinEventLoop`/
`uv_run(DEFAULT)`, then hands control to `[NSApp run]` with the pump running.

Distribution (`tools/bundle-typescript/`, ADR-0060) turns a built app into a real,
self-contained `.app`: a **per-app-compiled** native launcher (not a shared stub — the
runloop polarity above forbids an `execv`-to-shared-runtime model), the app's `tsc`-compiled
JS as a loose `.mjs` tree under `Contents/Resources/app/`, the addon at
`Contents/Frameworks/APIAnywareTypeScript.node`, and a vendored + `@rpath`-relocated `libnode`
closure (transitively walked — the Homebrew `libnode` dynamically links ~20 further
dylibs, a correction to ADR-0060 §2's "minimal vendoring" assumption). Signed inside-out.
All seven apps have a `bundle-report.md` confirming `otool -L`/`codesign --verify` on both
host and VM guest.

## 11. Known quirks / gotchas

- **A generic superclass reference is a printed instantiation**, not a plain identifier —
  `extract-swift`'s name extraction must strip `<…>` before splitting on `.`, or a
  module-qualified generic argument can truncate the base name into a bare fragment
  (`generic-class-name-surface-k78`).
- **A refined ObjC pointer (`__kindof`, a protocol-qualified `id<P>`) needs its base class
  read off the *pointee*, not the pointer** — `NSArray<ObjectType>.get_objc_type_arguments()`
  on the wrong side silently drops the whole parameterization
  (`objc-object-type-lowering-k85`).
- **Two conformed protocols can legitimately derive two rows for one `(class, selector)`
  key** (e.g. `NSTextInputClient`/`NSTextInput` on `NSTextView`) — `resolve` needs a stated
  precedence (non-deprecated wins), or the ambiguity rides through and downstream dedup
  order becomes iteration-order-dependent (`corpus-reproducibility-k86`).
- **ObjC has two namespaces (class, protocol); TypeScript has one** — a name declared as
  both is re-encoded (`<Name>Protocol`), never silently dropped
  (`protocol-class-name-collapse-k90`).
- **A parameter name is a binding position, not a member position** — a reserved word
  (`arguments`, `function`, `interface`) parses fine as a selector-derived method name but
  not as a parameter; escape at `naming::param_identifier`, and fix every body-expression
  reader that touches the parameter by name, not just its declared signature
  (`reserved-identifier-surface-k91`).
- **A lossy ABI-shape code is not an ownership fact.** `AbiType` deliberately collapses
  every pointer-like value to one `Ptr` code for *dispatch*; reusing that code to decide
  *retain-or-not* is the recurring defect species this target hit on three separate channels
  (methods, free functions, constants) — fork on the wrap-boundary predicate
  (`is_object_type`), never the ABI code.

## See also

- ADRs 0010, 0011, 0025, 0013, 0004, 0005 (foundational), 0024 (docs co-location), 0039
  (selector integrity, ported), 0042 (value-type split, ported), 0054–0061 (this target).
- [`../bindings/node/native/README.md`](../bindings/node/native/README.md) — the full,
  child-leaf-by-child-leaf build narrative this page distills.
- [`../bindings/node/docs/`](../bindings/node/docs/) — the §22 binding-mapping docs.
