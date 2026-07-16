# TypeScript callbacks: generated typed inbound trampolines carry JS closures→blocks, JS objects→delegates, and JS classes→ObjC subclasses

Decides the **Node `typescript`** target's inbound-callback model (Q6) — how JS functions and
objects cross *into* ObjC and how ObjC calls back *out* to JS. It is the **inbound dual of
ADR-0054's outbound generated typed native dispatch**: every ObjC-side entry (a block's invoke, a
delegate IMP, a subclass-override IMP) is a **generated `@_cdecl` trampoline, one per distinct ABI
signature**, so the inbound direction keeps the same *statically-generated, dumb-runtime* posture
the outbound direction has. It completes the main-thread-bounce family for this target — the
analogue of racket **ADR-0014**, gerbil **ADR-0022**, sbcl **ADR-0035** (the inbound half) — but
richer, because those four have no mandatory main-thread loop and this one integrates with
ADR-0056's pump.

Four inbound surfaces, one shared machinery: **closures → ObjC blocks**, **JS object → delegate**
(the PyObjC pattern, typed by the ADR-0055 §4 protocol `interface`), **JS class → dynamic ObjC
subclass** (`objc_allocateClassPair`), all delivered over the ADR-0056 §3 background→main bounce and
held alive across the ADR-0057 retain/release seam. This is the grilled + doubt-passed dual of the
outbound dispatch (ADR-0054) and error `@catch` (ADR-0058); the threading *mechanism* is ADR-0056's,
consumed here, not re-decided. **§8** completes it with the one thing the machinery leaves open — the
JS-facing **value types**: what a callback actually receives and returns, and who owns it.

## Context — the inbound dual, alien the same two ways

ADR-0054 built the *outbound* crossing (JS→ObjC) as generated typed native dispatch — one `@_cdecl`
entry per ABI signature, content-addressed, dumb runtime, pay codegen at build time. Q6 is the
mirror: ObjC→JS. The research (§Synthesis D7) pre-judged the *reachability* of every surface
(closures→blocks, JS-object→delegate, `objc_allocateClassPair` subclassing — `deno_objc` already
creates JS-implemented classes) and flagged the **delegate-retain caveat** (a delegate setter often
does not retain — the binding must keep the JS side alive), but left the *shape* open: does the
inbound direction reflect at runtime (the sbcl ADR-0034 §5 `_objc_msgForward` + live `NSInvocation`
model) or generate typed trampolines like the outbound direction?

**Settled upstream (carried in):** objects — incl. protocol `interface`s and value structs — are
real ES6 classes (ADR-0055); selectors map by the injective `:`→`_` rule with no elision (ADR-0055
§3); the JS event loop runs on AppKit's **thread 0** and background callbacks bounce via
`napi_threadsafe_function` (ADR-0056 §3); lifetime is uniform-+1 deterministic-dispose with a
`Map<id,WeakRef>` uniquing and **all `release` on thread 0** (ADR-0057); an `NSException` is caught
*natively* before it can unwind through the C ABI (ADR-0058) — Q6 is the JS-exception mirror.

## Decision

### 1. Generated typed inbound trampolines (the inbound dual of ADR-0054)

Every ObjC-side inbound entry — a block's invoke function, a delegate forwarding IMP, a subclass
override IMP — is a **generated `@_cdecl` inbound trampoline, one per distinct ABI signature**,
content-addressed by signature exactly like the outbound `aw_ts_msg_<param-codes>_<ret-code>`
entries. Signatures are all known statically from the IR (protocol methods, overridable class
methods), so the trampoline marshals *typed*, the runtime consults **no** metadata at call time
(the ADR-0055 §2 dumb-runtime property, now on the inbound side), and inbound reuses the outbound
`@convention(c)` signature-dedup infrastructure. Each trampoline: marshal the C-ABI args → deliver
to the JS thread (§5) → invoke the JS function/method (by injective selector→name) → marshal the
return back.

Rejected: **live `NSInvocation` forwarding** (install `_objc_msgForward`; one generic dispatcher
reads the ABI off `NSMethodSignature` per call — sbcl ADR-0034 §5). Natural for CLOS/Lisp dynamism,
but it reintroduces the per-call runtime dynamism this target chose the generated-dispatch substrate
to avoid (the NativeScript pathology, ADR-0055 §2). Live `NSInvocation` reflection is retained
**only as the escape hatch** for a signature the emitter never saw (a novel selector a JS subclass
*adds*, §4) — symmetric to ADR-0054's outbound libffi/`objc2` fallback.

### 2. Closures → ObjC blocks

A JS function passed where an ObjC block parameter is expected is wrapped by the native core into a
real ObjC block whose invoke *is* the §1 typed trampoline for that block's ABI signature; the addon
converts JS-function → block-pointer before the outbound `@_cdecl` call. The `.d.ts` types the
parameter as a TS function type `(a: A, b: B) => R` from the IR block signature.

- **Escaping / unknown (default): a heap block that pins the JS function across the call and routes both
  its delivery and its teardown through the *same* ADR-0056 §3 bounce.** The JS function is held by the
  callback registry (the monotonic `CallbackId` keep-alive the noescape path also uses) for as long as the
  block can fire; the heap block captures a native holder so the framework's last release drives teardown.
  Delivery reuses the **singleton** bounce (the same primitive that delivers every other off-main callback):
  on thread 0 the block invokes directly, off thread 0 it bounces (void fire-and-forget / value-returning +
  completion semaphore, §5). Teardown is the load-bearing off-main property: when the framework releases a
  stored completion handler off-main, the holder's dispose is legal on **any** thread and routes the
  registry-drop back to thread 0 through the bounce's release path (the ADR-0057 release-on-thread-0 seam).
  A raw `napi_ref` cannot do this — its mutation is JS-thread-only; the tsfn's any-thread enqueue is what
  makes off-main teardown legal. (Realised `block-escaping-off-main-k45`: the JS function lives in the
  **registry**, not a per-block tsfn's `func`, because containment/reporting flow through the registry-keyed
  `__invokeCallback` uniformly — so a per-block tsfn could only *route teardown*, a job the singleton bounce
  already does without a per-block `uv_async_t` (the handle-exhaustion concern below). The tsfn's role here
  is thereby refined to teardown; every externally-observable property — pinned while live, released on
  teardown, teardown legal off-main, the JS-ref drop on thread 0 — is unchanged.)
- **`@noescape` fast path (baseline where known): no tsfn.** Where the IR / LLM annotation marks the
  block `NS_NOESCAPE` (`enumerateObjectsUsingBlock:` and its kin), the block is invoked **directly on
  thread 0** and the JS function is held only for the call's duration — no tsfn, no heap persistence.
  This is baseline, not a deferred optimisation: always-tsfn-per-block would spin up and tear down a
  tsfn (each carrying a `uv_async_t`) per enumeration callback, exhausting libuv handles on a hot loop.
  Escaping/unknown keeps the heap-block+tsfn (correctness-first — an escaping block that outlives the
  call must hold the JS function; guessing wrong is a UAF or a leak).

### 3. JS object → delegate and JS class → subclass: one machinery, two surfaces

Both need a real ObjC class (via `objc_allocateClassPair`) whose IMPs are §1 typed trampolines
forwarding selected selectors to a JS side, both hold that JS side alive over the ADR-0057 seam, both
ride the §5 bounce. They differ only in class-synthesis keying and whether the ObjC object is a
genuine new hierarchy member — so it is **one machinery, two surfaces**:

- **Delegate / data-source** (`setDelegate_(jsObj)`, `jsObj` a plain object literal *or* a class
  instance, both blessed by ADR-0055 §4). The runtime wraps it in an instance of a **per-protocol
  generic forwarding ObjC class** — `objc_allocateClassPair` **once per protocol**, memoized (no
  per-object churn; `objc_disposeClassPair` is fraught, so classes are never disposed), conforming to
  the protocol, one typed-trampoline IMP per protocol method, one back-ref ivar to the JS object.
  **`respondsToSelector:` returns YES iff the JS side implements the injective-mapped method** — so
  `@optional` fidelity is *exact* (the framework's optional-probing works; NativeScript's opaque-object
  delegates got this wrong). Because the forwarding class installs IMPs for *all* protocol methods and
  `respondsToSelector:` is sent on arbitrary threads, the responds-set is a **per-instance native
  snapshot taken at set-time on thread 0** (a bitset on the forwarder), never a live off-main JS
  consult; post-set mutation of the JS object's method set is unsupported (matching ObjC's fixed method
  set).
- **Dynamic subclass** (`class MyView extends NSView {…}`, extending the ADR-0055 ES6 class). One
  **synthesized ObjC subclass per JS class** (memoized by JS class), a typed-trampoline IMP per
  JS-overridden selector, instances back-referencing their JS instance via one installed ivar. A
  genuine new hierarchy member (`isKindOfClass: NSView`, storable in the view graph, receives
  `drawRect:`). Also covers `class X implements P` (base `NSObject`).

Rejected: **"everything is a subclass"** (synthesize a class even for a plain-object delegate — PyObjC
literal) — object literals have no stable key → per-object class churn, and undisposable classes
accumulate. **Two separate mechanisms** — duplicates the shared IMP/holding/bounce.

**What the emitted corpus supplies: one `DelegateSpec` per bound protocol** *(realised
`emitted-delegate-spec-k84`, 2026-07-12).* §3 says the runtime "wraps it in an instance of a
per-protocol generic forwarding class" — but the runtime cannot know a protocol's method list, its
selectors, or their inbound value kinds (§8). Those are emitter facts. So each framework emits a
`delegates.ts` carrying a `SPEC_<P>` per **bound** protocol (ADR-0055 §4b) — the protocol name, its
methods, and their §8 marshal descriptor — and every bound `id<P>` parameter in the corpus passes its
argument through **`__protocolArg(owner, key, value, SPEC_<P>, associate)`**. The spec set **is** the
bind set: `SPEC_<P>` exists exactly when `protocol_binding` says `Bound`, so a slot can never name a
spec that was not emitted.

Two consequences worth stating, because both were surprises:

- **The discrimination is at the *value*, not the slot.** A bound slot's type admits *both* a JS literal
  and a wrapped ObjC object (ADR-0055 §4b's variance table), so `__protocolArg` tests the value:
  `NSObject` → `__unwrap`; anything else → mint the forwarder. The slot cannot decide this statically,
  and pretending it could is what a "delegate-shaped setter" special case would have done.
- **It is not a delegate feature.** Nothing here keys on the word *delegate* — the machinery is reached
  from **every** bound `id<P>` param the corpus has. Measured over AppKit + Foundation: **122** bridged
  slots, of which **120** associate and **2** skip (§6), and **17** are initializer params (§6's owner
  is the *return*, not the receiver). The name-sniffing ADR-0047 §4 exists to retire never reappears.

### 4. The dynamic-subclass surface: `$super`, `dealloc`, added methods

- **Super-send → a typed `this.$super` accessor.** `this.$super.drawRect_(r)` — a proxy typed as the
  superclass interface (fully compiler-checked) that dispatches via **`objc_msgSendSuper`** to the
  immediate superclass; the type-safe TS analogue of sbcl's `call-super`. Native `super.method_()`
  **cannot** drive ObjC super-chaining: it resolves to the parent ES6 method whose body does
  `objc_msgSend` to self, whose ObjC class *is* the subclass → re-enters the override → infinite
  recursion (the sbcl ADR-0034 `call-next-method` trap), and JS exposes no super-signal to the method
  body. So native `super.` is documented as *not* the super path and the generated parent method
  guards the footgun. The accessor calls a **generated per-signature `aw_ts_super_<code>` napi
  entry** — content-addressed by the same alphabet as the §1 inbound trampolines, over the same
  frontier (a super-send exists exactly where an override can), but an *outbound* call shape rather
  than an IMP. Its pointer return therefore crosses the wrap boundary like any other, and so carries
  the **ADR-0057 §4 fold axis unchanged**: a `+0` return folds `objc_retain` into the entry, a
  `+1`-convention return (an overridden `init`/`copy` reached through `$super` — the canonical
  `self = [super initWithFrame:]`) routes to the distinct non-folding `…_o` sibling, and a pointer
  return that is no object (`SEL`, the `Class` metatype) routes to the non-folding, non-wrapping
  `…_n` sibling — all three states computed by the one `method_retain_axis` predicate the outbound
  table and the call sites read. Rejected: a
  string-selector `callSuper('drawRect_', r)` (loses compile-time name/arity/type checking — cuts
  against the static-types raison d'être); runtime super-context tracking (fragile, races on
  reentrancy).
- **`dealloc` is overridable, chains `this.$super.dealloc()`, and is delivered like any callback (§5),
  never *async*-bounced.** An async-bounced dealloc would let ObjC `dealloc` complete before the JS
  override runs → UAF of the JS back-ref. On thread 0 it runs directly; **off thread 0 it is
  *synchronously* bounced** (the framework can drop the last ref off-main — a superview released on a
  bg queue — so `dealloc` is not "always on thread 0"): block the deallocating thread, run the JS
  override + teardown on thread 0, then return so ObjC `dealloc` completes after. It carries the §5
  deadlock caveat — **broader here than for a value-returning callback**: a dealloc bounce fires
  *implicitly* whenever a bound instance's last release lands off-main (not only when the programmer
  invokes a value-returning callback), so the §5 "keep those callbacks on main" mitigation does not
  apply — the discipline is instead *do not synchronously block thread 0 while bound objects may be
  releasing off-main*. Two consequences follow from the synchronous block: the deallocating thread is
  stalled for one thread-0 turn (so releasing a bound object on a real-time/QoS thread pays that
  latency), and — because an override chains `this.$super.dealloc()` on thread 0 while a no-override
  instance chains `[super dealloc]` on the deallocating thread — a main-thread-affine class (an AppKit
  view) inherits Cocoa's obligation to release on the main thread on the no-override path (an app
  obligation, not lifted by the binding).
- **Added ObjC-reachable methods** (a target-action `buttonClicked_(sender)`, a new delegate selector)
  register via `class_addMethod` + a typed trampoline IMP (standard signatures pre-generated; a
  never-seen signature falls to the §1 `NSInvocation` escape hatch). **Instance state stays JS-side** —
  no user-added ObjC ivars; the runtime installs exactly one back-ref ivar (ObjC instance → JS
  instance). `this.$super.dealloc()` is a documented user obligation (forgetting it leaks the object,
  as in ObjC).

### 5. Delivery / threading — consumes ADR-0056 §3, applies the ADR-0035 split

- **On thread 0** (UI delegates, target-actions, main-thread callbacks fire within the AppKit runloop
  where JS already lives): **call JS directly and synchronously, no bounce** — the only way a
  value-returning delegate method (`numberOfRowsInTableView_`, `tableView_shouldSelectRow_`) can return
  its result synchronously, which the framework needs *now*; zero overhead (ADR-0035 "on main already,
  call inward").
- **Off thread 0, void:** **`napi_threadsafe_function` in *blocking* mode** — block the producing bg
  thread until the item is enqueued (backpressure, not the value round-trip). Blocking, not
  non-blocking: a non-blocking tsfn silently *drops* on a full queue, which is data loss for
  side-effectful delegate methods (`didReceiveData`, stream events). A stalled thread 0 therefore
  applies backpressure to the producer — acceptable; silent loss is not.
- **Off thread 0, value-returning** (rare — most value-returning delegate methods are main-thread UI):
  a **tsfn-blocking enqueue + a completion semaphore the JS side posts** after computing, then return
  the result to the framework — the `dispatch_sync`-value-returning analogue (ADR-0035), realized over
  tsfn because the N-API primitive is async-only.

Two constraints ride along, both documented as observable behaviour:
- **Deadlock caveat (ADR-0035, broadened).** A value-returning off-main callback deadlocks whenever
  thread 0 is *synchronously blocked* awaiting the bg thread — including, importantly, when thread 0 is
  inside *ordinary framework code* (`dispatch_sync`, `-waitUntilAllOperationsAreFinished`, a thread
  join), not only an explicit semaphore-await: `uv_run` is non-reentrant (ADR-0056), so a blocked
  thread 0 cannot drain the tsfn queue. This is the fundamental single-main-thread constraint
  (ADR-0056 §Consequences / ADR-0035). Void completions are immune. Mitigation is the family's: keep
  value-returning callbacks on main, and let the runloop turn.
- **No `await` in a synchronous callback (ADR-0056 finding C).** While a synchronous inbound callback's
  napi call is on the stack, V8 suppresses the microtask checkpoint, so a pure-Promise `await` inside
  the callback body won't resolve until the stack unwinds (libuv-backed async — timers, I/O,
  `worker_threads` — is unaffected). A callback needing async work schedules it rather than awaiting
  inline; an `async` method used in a *value-returning* slot cannot deliver a value (see §7).

### 6. Delegate / callback keep-alive — the delegate-retain caveat

Delegate / target / observer properties are overwhelmingly `weak`/`assign` — the setter does not
retain — so the binding must keep the forwarder alive. **Mechanism: a strong associated object on the
ObjC owner** — `objc_setAssociatedObject(owner, propertyKey, forwarder, OBJC_ASSOCIATION_RETAIN)` at
set-time, keyed per delegate-property, old forwarder released on re-set (the standard PyObjC/Cocoa
pattern). The forwarder then lives **exactly as long as the ObjC owner** — robust even when the JS
owner-wrapper is GC'd while the ObjC owner survives via the ObjC graph. Conditioned on the IR
ownership qualifier: `weak`/`assign` → associate; known-`strong` → skip (the framework already
retains); default-associate when absent (Cocoa delegates are `weak` by convention).

*(Reconciled `delegate-slot-typing-k80`, 2026-07-11; **realised** `property-ownership-ir-k82`,
2026-07-11.)* **The "IR ownership qualifier" this section conditions on did not exist** when §6 was
written, so the associate-or-skip test always took its default-associate arm. `extract-objc` read
`get_objc_attributes()` and kept only `.copy`, discarding `weak`/`strong`/`assign`/`unsafe_retained`;
the gap was filled by a **naming heuristic** (`weak_param` sniffing the substring `delegate`) and a
sparse LLM annotation (~2 % of AppKit setters). The qualifier is now **extracted from the declaration**
(`ir::Property.ownership`) and reaches the setter's parameter through a priority-0 convention rule that
outranks the name sniff (ADR-0047 §4). §6's test therefore now runs on a declared fact — and its
default-associate arm remains, and remains safe (over-associating a strong slot over-retains slightly;
it never crashes).

Two things the measurement changed about how §6 reads:

- **The skip arm is real, and it was firing wrong.** `NSURLSessionTask.setDelegate:` is declared
  `strong`; the name sniff called it `weak`, so §6 would have *associated* a forwarder onto a slot the
  framework already retains. It now takes the skip arm on a declared fact. This is the only slot in
  AppKit + Foundation where the declaration flips the retain axis — the arm is narrow, but it is not
  hypothetical.
- **`weak` and `assign` are one arm, and must be tested as one.** 17 pre-ARC delegate slots
  (`NSXMLParser`, `NSStream`, `NSFileManager`, …) declare `assign`, not `weak`. Both are
  non-retaining, so both associate; a reader testing only for `weak` silently drops them. The fact §6
  conditions on is the **retain axis**, never one spelling of it.

*(Realised `emitted-delegate-spec-k84`, 2026-07-12.)* Emitting the arms settled three things §6 had
left as prose:

- **The association key is `(selector, parameter index)`** — `'initWithFileType:delegate:#1'` — not the
  property name. §6 said "keyed per delegate-property", which only names a key for the slots that *are*
  properties; the machinery runs on every bound `id<P>` param (§3), and a selector with two protocol
  params needs two distinct keys. The key must be derivable from the call site alone, and this one is.
- **An initializer's owner is its *return*, not its receiver.** `initWithFileType:delegate:` is called
  on the *unfinished* object; associating the forwarder onto the receiver would key it to the object
  `init` is entitled to discard. So the emitted body hoists the arg, sends, and *then*
  `__protocolAdopt(__ret, key, …)` onto what came back. 17 corpus params are in this position. §6 never
  contemplated it because a property setter has no such gap between receiver and owner.
- **The skip arm needs a keep-alive too, and it is not the association.** A skipped slot (the framework
  retains) must still survive the *call itself* — the forwarder is minted at +1 and released
  immediately. So the skip arm hands it to `objc_retainAutorelease`: alive to the end of the turn, owned
  by whoever retains it. That, and associate-then-release on the other arm, is what lets `__protocolArg`
  be **nested inline at any argument index** rather than needing a native set-and-hold bracket.

Both arms are exercised in the corpus: of 122 bridged slots, **120 associate and 2 skip**
(`NSURLSessionTask.setDelegate:` — the slot k82 predicted — and
`NSTextSelection.setSecondarySelectionLocation:`).

The forwarder holds the JS side via a **`napi_threadsafe_function`** (any-thread-releasable), and its
own dealloc — which can fire off-main when the owner deallocs off-main — does **only** the tsfn
release; the JS-touching finalize routes to thread 0 via the tsfn (the §4 dealloc-off-main principle).

Honest consequence: this creates an inherent **ObjC-owner ⟷ JS-delegate cross-heap cycle** when the JS
delegate references the JS owner (the "controller is its own delegate" shape). A *weak* JS-side hold
cannot fix it — the delegate-retain caveat *requires* a strong hold (a transient object-literal
delegate has no other JS root) — so the cycle is **broken deterministically by disposing the owner**
(`using` / `[Symbol.dispose]` relinquishes the JS wrapper's +1 → ObjC owner deallocs → the association
releases the chain). Pure-ObjC delegate cycles have the same shape; this one spans two heaps.

Rejected: JS-side-hold-only (the JS wrapper can be GC'd while the ObjC owner lives → dangling; does not
keep the ObjC forwarder alive) and belt-and-suspenders (redundant with the association).

### 7. Inbound-callback JS-exception containment — the ADR-0058 mirror

A JS exception escaping a block invoke / delegate method / subclass override must be **caught at the
trampoline boundary** — never allowed to unwind through the C ABI into the framework's runloop (the
mirror of ADR-0058's native-`@catch`; unwinding would corrupt the stack / crash the pump). Containment
= **catch → report → typed default:**

- **Catch always** — no JS exception crosses the C ABI.
- **Report** via a dedicated **`onCallbackError` hook defaulting to Node's `uncaughtException`
  semantics** (`process.emit('uncaughtException', e)`), carrying the selector/callback context. The
  hook invocation is itself guarded (a throw *inside* the handler is swallowed-and-logged, never a
  nested C-ABI-boundary unwind).
- **Return control cleanly:** a **void** callback returns; a **value-returning** callback returns a
  **typed zero/nil default** (nil for objects, `NO`/0 for scalars); and — critically — the §5 off-main
  round-trip **always posts its completion semaphore**, on the JS-threw path *and* on a tsfn
  enqueue-failure path (`napi_closing`/`queue_full`), so the blocked bg thread never hangs and no
  torn-down env is dereferenced.
- An **`async` method in a value-returning slot** cannot deliver a value (§5 forbids inline `await`);
  the runtime coerces to the typed default **and reports** via `onCallbackError` (not silent).
- **No `NSException` re-raise by default** — the disaster/boundary channel ADR-0058 keeps narrow and
  both prior arts flagged crash-prone, and unwinding it through the pump is the hazard we prevent. A
  per-selector opt-in re-raise is a deferred future option, not baseline.

Rejected: re-raise-as-`NSException` baseline (crash-prone); propagate/abort (one callback bug tears
down the whole GUI app).

### 8. The inbound **value** surface — the kind travels with the callback

§§1–7 decide the inbound *machinery*; they never say what a JS callback actually **receives** and
**returns**. It receives the types the emitted interface declares — a wrapped object where an object
is declared, a `string` where a `SEL` is, the bound constructor where a `Class` is — and may return
the same. This is the **inbound dual of the outbound value surface** (ADR-0055 §3/§5b, `PtrValue`),
and it is a separate decision from §1 because of where the two directions can put the knowledge.

**The kind cannot live in the trampoline.** §1's trampolines are content-addressed by **ABI
signature**, and at the ABI an `id`, a `SEL`, a `Class`, a block and a raw pointer *are one thing* —
they all collapse to the pointer code `P` / encoding `@`. That collapse is what lets a few dozen
trampolines cover the whole corpus, so it stays; but it means the trampoline cannot know which of its
pointer args is an object to wrap. Nor could it act on that knowledge: wrapping needs the ADR-0057 §3
uniquing map, the ADR-0055 §5b ctor registry and the selector memo — all TS-side policy. Outbound,
the emitted call site converts because it knows the declared type statically; inbound, the call site
is one generic funnel (`__invokeCallback`).

**So the declared type travels with the callback, as a per-method descriptor the emitter derives from
the IR and the *registrant* supplies** (`__registerCallback(target, marshal)`): one **arg kind** per
visible parameter (`raw` / `obj` / `sel` / `cls`) and one **return kind**. The runtime stays
dumb in the ADR-0055 §2 sense — it consults no signature table at call time; it applies a descriptor
handed to it, exactly as an emitted call site applies the wrap primitive the emitter chose.

**The `obj` kind carries no class** *(reconciled `emitted-delegate-spec-k84`, 2026-07-12).* It used to:
§8 argued that an `obj` kind must name the **declared** class, because an `NSString`-declared arg is
really a `__NSCFString` that no binding declares, so resolving by dynamic class would degrade every
class-cluster object to a stand-in. **`dynamic-class-wrap-k88` removed the premise.** The class-less
wrap arm does not resolve to the object's literal class — it climbs `class_getSuperclass` to the
nearest **bound** ancestor (`__NSCFString` → `NSMutableString` → `NSString`), which is the declared
class in the ordinary case and *strictly better* than it when the declaration is a bare `id`. So the
declared class bought nothing, and it cost something real: naming a class makes the spec module
**value**-import it, and a `delegates.ts` that value-imports its framework's classes closes a cycle
back through the barrel — putting the `const SPEC_<P>` in its TDZ exactly when a class body needs it.
`OBJ` is now a constant, not a constructor, and `delegates.ts` imports nothing from its own framework.
A descriptor that names less can say more.

**Lifetime — the two arms, both answering to ADR-0057:**

- **Args are borrowed** (`+0`: the ObjC caller owns them, no entry folded a retain, no convention gave
  one away) and wrap through **`__wrapBorrowed`** (ADR-0057 §2, the third wrap primitive): a live
  wrapper is returned as-is (**zero** native crossings — the same `sender` on every event); a fresh
  one takes its own +1. The retain is forced by ADR-0057 §2's own no-ARC argument, which applies
  identically here: JS cannot intercept `this.lastSender = sender`, so a stored borrowed handle would
  be a use-after-free at the next turn boundary. A hot enumeration block over N distinct objects mints
  N wrappers, reclaimed by the FR — *identical to an outbound loop*, not a new cost. Rejected: a
  second, non-owning wrapper species (it turns `this.lastSender = sender` into a silent trap and puts
  an exception into the one model that has none).
- **Returns follow the ADR-0057 §4 three-state retain axis** — the *same* `method_retain_axis`
  predicate the outbound table, the emitted call sites and the §4 `$super` entries read (one decision,
  N readers): a `+0`-convention selector hands back `objc_retainAutorelease`, a `+1`-convention one
  (an overridden `copyWithZone:`/`init`) `objc_retain`, a `SEL`/`Class` neither. Rejected: hand back
  the bare `__unwrap` handle — it under-retains a `+1`-convention override (a crash) and leaves the
  returned object alive only as long as a collectable JS wrapper happens to hold it.

**A descriptor fault is loud, and contained.** A descriptor that does not cover an arriving selector
is an emitter/spec bug, not a value to guess at — it throws, and §7's containment reports it and
substitutes the typed default. Silently passing the raw handle through under a declared `NSApplication`
is the exact lie this section removes. A callback registered with **no** descriptor traffics in raw
handles — the pre-descriptor behaviour, which is what the native-level test batteries are written
against; the emitter never produces a *partial* one, so a generated call site is either fully
marshalled or absent.

The seam split is the family's: **policy in TS** (which kind, which ctor, when to retain), **mechanism
in Swift** (`objc_retain` / `objc_retainAutorelease`). Realised and verified first-hand by
`inbound-value-kinds-k79` (2026-07-11), with the ownership claims *measured* off `-retainCount`.

## Mechanics

- **Thread-0 invariants.** Class synthesis (`objc_allocateClassPair` + `objc_registerClassPair`),
  `napi_ref`/`WeakRef`/`Map` mutation, and the `respondsToSelector:` snapshot all run **only from
  thread-0-initiated paths** (`new MyView()`, delegate-set, dispatch). This is a correctness invariant,
  not a convenience: concurrent `objc_registerClassPair` on a duplicate name aborts, and napi/`Map`
  ops off thread 0 crash. Every off-main inbound path routes JS-touching work to thread 0 via the tsfn
  (or the synchronous dealloc bounce).
- **`dispose` ordering (reconciles ADR-0057 §6 in place).** `dispose` flips the `disposed` flag and
  removes the `Map` entry **after** `release` — and any *synchronous* `dealloc` triggered by it —
  completes, not before. So a JS `dealloc` override runs against a *live* handle (`this.removeObserver_`,
  `this.$super.dealloc()` dispatch normally), and a re-entrant wrap of self *during* dealloc hits the
  still-live map entry (no fresh +1 resurrecting an object mid-dealloc). Post-`dispose` aliases still
  throw `ObjectDisposedError`.
- **The seam split (ADR-0057 §4 / ADR-0058).** Policy lives in the **TS runtime** (the tsfn/forwarder
  registry, the associated-object keep-alive, the `respondsToSelector:` snapshot, the `disposed`
  ordering, `onCallbackError`); the C-ABI-crossing **mechanism** is **Swift-native** (the `@_cdecl`
  trampolines, `objc_msgSendSuper`, `objc_allocateClassPair`/`class_addMethod`, the boundary catch,
  the semaphore round-trip) — the same policy-TS / mechanism-Swift seam as retain-on-wrap and the
  error `@catch`.
- **The IR drives it.** `emit-typescript` emits an inbound trampoline per distinct block/delegate/
  overridable ABI signature (dedup shared with outbound); block params → TS function types; protocol
  `interface`s (ADR-0055 §4) type delegate slots; `NS_NOESCAPE` (IR / annotation) selects the §2 fast
  path; the property ownership qualifier selects §6's associate-or-skip. A mis-marked signature or
  ownership qualifier is an over-/under-retain or a missed callback — analysis-phase correctness
  invariants (the ADR-0039 "integrity is upstream" posture).

## Considered options

- **Live `NSInvocation` forwarding for the inbound direction (sbcl ADR-0034 §5).** Rejected §1 —
  per-call runtime reflection, against this target's generated-dispatch thesis; kept only as the
  un-typable escape hatch.
- **Always heap-block + tsfn per block.** Rejected §2 — exhausts libuv handles on hot `NS_NOESCAPE`
  enumeration; the `@noescape` direct-invoke fast path is baseline.
- **"Everything is a subclass" / two separate delegate+subclass mechanisms.** Rejected §3 — per-object
  class churn / duplication.
- **Native `super.method_()` for super-chaining; string-selector `callSuper`.** Rejected §4 — infinite
  recursion / loses static checking.
- **Non-blocking void tsfn.** Rejected §5 — silent callback loss under load.
- **Re-raise JS exceptions as `NSException`.** Rejected §7 — crash-prone disaster-channel unwind
  through the pump.
- **Marshal inbound values in the trampoline / resolve the wrapper by the object's *dynamic* class.**
  Rejected §8 — the trampoline is ABI-content-addressed and the ABI collapses `id`/`SEL`/`Class` into
  one pointer code, so it cannot know the kinds; and the dynamic class of a class-cluster object
  (`__NSCFString` for a declared `NSString`) is one no binding declares, so it would degrade to a
  stand-in. The declared type is what the IR knows, so the descriptor carries it.
- **A second, non-owning wrapper species for borrowed inbound args.** Rejected §8 — cheaper on hot
  paths, but it makes `this.lastSender = sender` a silent trap and puts an exception into a lifetime
  model whose whole strength is that it has none (ADR-0057 §2).
- **Hand back the bare `__unwrap` handle from a callback's object return.** Rejected §8 — it
  under-retains a `+1`-convention override (`copyWithZone:`) and leaves a `+0` return alive only for
  as long as a collectable JS wrapper happens to hold it.

## Consequences

- **`emit-typescript`** emits, from the same IR pass that drives ADR-0054 outbound dispatch: the typed
  inbound trampolines (per distinct block/delegate/overridable signature), the block-param TS function
  types, the delegate/subclass surface types into the `.d.ts` (ADR-0055 one-artifact rule), **and the
  per-method value-kind descriptors §8 rides on** (the arg/return kinds, and the `method_retain_axis`
  state of an object return). The `NS_NOESCAPE` and property-ownership IR markers gate §2/§6.
- **The runtime library** owns: the tsfn/forwarder registries, `objc_allocateClassPair` synthesis
  (memoized per-protocol and per-JS-class, thread-0-only), the associated-object keep-alive, the
  `respondsToSelector:` native snapshot, `this.$super`, the `dispose`-ordering reconciliation, the
  semaphore round-trip driver, `onCallbackError`, **and the §8 value conversion** (the kind
  descriptors, `__wrapBorrowed`, the retain-axis return arm). **The native core** owns the C-ABI
  trampolines, `objc_msgSendSuper`, `class_addMethod`, the boundary catch, the synchronous dealloc
  bounce, **and the `retain`/`retainAutorelease` primitives §8's lifetime arms call** —
  Swift-native (ADR-0010).
- **Sample-app authors** get obligations, not shared code (documented in the target reference): chain
  `this.$super.dealloc()`; don't `await` a pure Promise inside a synchronous callback; keep
  value-returning callbacks on main; dispose an owner to break a delegate cycle. The
  no-await-in-synchronous-callback and value-returning-deadlock rules shape how sample-app delegates
  are written.
- **Hard to reverse:** the generated-typed-inbound-trampoline shape, the one-machinery-two-surfaces
  delegate/subclass model, the `this.$super` spelling, the registry-hold + singleton-bounce-teardown
  escaping-block lifetime (§2), and the
  catch→report→default containment are baked into the emitter, the runtime, every generated module's
  `.d.ts`, and every sample app that defines a delegate or subclass — a cross-binding + cross-app
  rewrite to change (the irreversibility ADR-0055/0057/0058 also carry).
- **Boundaries to sibling decisions.** The object graph + protocol `interface`s + injective names are
  ADR-0055; the outbound dispatch this duals is ADR-0054; the bg→main bounce mechanism is ADR-0056 §3
  (consumed, not re-decided); the uniform-+1 retain seam, the `Map` uniquing, and `ObjectDisposedError`
  are ADR-0057 (this ADR reconciles its §6 `dispose`-ordering in place); the native `@catch` this
  mirrors is ADR-0058. An **ADR-0057 uniquing edge** the doubt pass surfaced (a wrapper GC'd before its
  `FinalizationRegistry` fires, the same `id` re-surfacing, the pending FR then removing the wrong map
  entry → `===` identity breakage in the race window, not a UAF) is **out of this ADR's scope** — an
  ADR-0057 mechanism concern, externalized as leaf `ts-lifetime-fr-uniquing-race-k13`, not decided
  here.
- Target-local under **ADR-0011**. The design is grilled + **adversarially doubt-passed** (a
  fresh-context reviewer tasked to disprove; its findings on off-main `dealloc`, off-main
  `respondsToSelector:`, the enqueue-failure semaphore hang, the `dispose` ordering, and the
  handle-exhaustion / silent-drop trade-offs are folded into §§2–7 above).

See ADR-0054 (the outbound dispatch this is the inbound dual of), ADR-0055 (objects, protocol
`interface`s §4, injective names §3, the branded handle), ADR-0056 §3 (the bg→main bounce mechanism
consumed here), ADR-0057 (the retain/release seam, uniquing, `dispose` ordering §6 reconciled here),
ADR-0058 (the native-`@catch` this mirrors), ADR-0014/0022/0035 (the Lisp-family inbound-bounce
precedents), ADR-0034 §5 (the sbcl live-`NSInvocation` forwarding this rejects for the generated-typed
dual), ADR-0010/0011 (north star + isolation), ADR-0039 (integrity-is-upstream), `CONTEXT.md`
(*typescript callback / delegate model*), and
`targets/typescript/docs/research/2026-07-05-js-objc-bridge-prior-art.md` (§Synthesis D7, §B2 PyObjC,
§C `deno_objc`) for the prior-art evidence.
