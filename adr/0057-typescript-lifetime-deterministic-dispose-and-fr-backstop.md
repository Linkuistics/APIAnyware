# TypeScript lifetime: deterministic `Symbol.dispose` primary, `FinalizationRegistry` best-effort backstop, over uniform-+1 uniqued wrappers released on main

Decides the **typescript** target's memory/lifetime model for wrapped ObjC `id`s — the
contract that makes the ADR-0055 branded handle *disposable*, closing ADR-0055 §7. It is
the TS realization of the two-mechanism lifetime shape established by chez **ADR-0007**
(guardian + entry-point pool), gerbil **ADR-0019** (Gambit will + pool), and sbcl
**ADR-0036** (`sb-ext:finalize` + main-thread release queue) — but with the mechanism
**re-polarised**, because JavaScript's GC finalizer is fundamentally unlike the Lisp
targets': theirs is guaranteed, JS's is not.

## Context — why the Lisp lifetime model cannot be copied

The four Lisp targets **trust the GC hook** as the death trigger (chez guardian drain,
gerbil will, sbcl `finalize`) because their finalizers are guaranteed to run and hand the
runtime exactly the dead objects. **JavaScript's `FinalizationRegistry` is explicitly not
guaranteed** — MDN and V8 are emphatic that cleanup callbacks "may be called then, or some
time later, or **not at all**," never run at shutdown, and "shouldn't [be relied] on for
essential program logic" (research §C4). A missed FR callback is a leaked ObjC object; no
FR ordering can sequence child-before-parent release. So the GC hook that is *primary* for
the Lisp targets can only be a *backstop* here, and a **deterministic** primary is needed
in its place — which ES2024 `using`/`Symbol.dispose` provides and the Lisp targets never
had.

A second, independent force shapes the model: **JavaScript has no ARC.** ObjC/Swift code is
safe holding a +0 autoreleased object across statements only because ARC inserts a retain
at the point of assignment. The binding cannot intercept `const x = …` / `this.f = …` to do
the same, so it must reconstruct ARC's store-time guarantee at the **wrap boundary** — every
wrapper owns a retain, uniformly.

And the load-bearing warning: **do not fuse the JS object model / GC with ObjC's.** MacRuby
did exactly that (Ruby objects *were* ObjC objects under libauto GC) and died when Apple
moved GC→ARC — a primary-source post-mortem (research §C1). The JS heap and the ObjC heap
stay two cooperating systems joined by an **explicit, replaceable retain/release seam**
(aligns with ADR-0011 and the per-target lifetime ADRs).

**Settled upstream (carried in):** the substrate is a single Swift-native N-API addon
(ADR-0054, confirmed Swift-native by `napi-dispatch-spine-k35`); each instance is a **branded,
disposable native handle** on the root `NSObject`
class (ADR-0055 §7, which this ADR closes); the threading model has the native Cocoa
runloop authoritative and the **JS event loop on AppKit's thread 0** (ADR-0056).

## Decision

### 1. Two cooperating heaps, two release mechanisms

The JS and ObjC heaps stay separate, joined by an explicit retain/release seam. Two release
mechanisms, in priority order:

1. **Primary — deterministic `Symbol.dispose` / `using` (ES2024).** The root `NSObject`
   hosts `[Symbol.dispose]`; `using foo = NSFoo.alloc().init()` releases at scope exit, in
   program order. (`using` downlevels through the TS compiler, so it does not depend on
   native engine support.)
2. **Backstop — `FinalizationRegistry`.** Every wrapper is registered; the FR fires only
   when the deterministic path was skipped (§6).

This is the chez/sbcl/gerbil two-mechanism shape **re-polarised**: deterministic-primary,
GC-backstop — a correctness divergence forced by JS's unreliable FR, not idiom.

### 2. Uniform +1 at the wrap boundary

The wrap boundary normalises **both** ObjC ownership conventions to *the wrapper owns
exactly one +1*: a **+0 autoreleased** return (everything outside
`alloc`/`new`/`copy`/`mutableCopy`) is **retained** on wrap; a **+1 owned** return is not
re-retained. Disposal is then uniform — dispose/FR release exactly one retain regardless of
provenance. This is forced by the no-ARC problem above: without it, a +0 handle stored in a
JS field is a use-after-free the instant control reaches a turn boundary and pools drain.
The +0/+1 annotation stays load-bearing in the IR — it decides retain-or-not *at wrap*, not
wrapper lifetime.

Because ADR-0055 generates class bodies statically, the emitter carries the split, emitting
one of **three** runtime wrap primitives (never a runtime introspection). The first two are the
**outbound** pair, and they are symmetric: an `id` returned to JS always arrives carrying exactly
one +1 — the native dispatch entry **fold-normalises** a +0 return to +1 (§4), and a +1 return
already owns its one — so on a live duplicate *both* release that now-redundant incoming +1, and on
a fresh mint *both* keep it. The third is the **inbound** primitive, and it is the exact opposite:
nothing hands JS a +1 at all.

- **`__wrapRetained(id)`** (+0, its native entry folded the +1 in, §4): existing live wrapper →
  **`release(id)` to balance the fold's redundant +1** (the re-fetch case, e.g. `view.superview`
  in a loop — without it the fold leaks one +1 per re-fetch), return it; else mint, insert,
  register FR (keep the fold's +1).
- **`__wrapOwned(id)`** (+1, its native entry did **not** fold, §4): existing live wrapper →
  **`release(id)` to balance the redundant incoming +1** (the real `[immutableString copy]`-
  returns-self case), return it; else mint, insert, register FR (keep the method's +1).
- **`__wrapBorrowed(id)`** (**+0 borrowed** — an *inbound* object argument: the values an ObjC
  caller hands a JS delegate / block / subclass override, ADR-0059 §8): the caller owns the object,
  no entry folded a retain in, and the method's convention gave none away. So there is **no
  redundant incoming +1 to balance**, and the two cases invert: existing live wrapper → **return it,
  taking and releasing nothing** (zero native crossings — the common case, the same `sender` on every
  event); else **`retain(id)` to take our own +1**, then mint, insert, register FR. The retain is
  forced by the same no-ARC argument as §2 itself — JS cannot intercept `this.lastSender = sender`,
  so a stored borrowed handle would be a use-after-free at the next turn boundary. An inbound
  trampoline **cannot fold** the retain the way an outbound entry does, because it is
  content-addressed by *ABI signature* and the ABI collapses `id`/`SEL`/`Class` into one pointer
  code — it does not know which of its args are objects (ADR-0059 §8); so this one primitive pays a
  crossing, and only on the fresh mint.

All three converge on the invariant: **one wrapper owning exactly one +1.** (The outbound two differ
only in *where* the incoming +1 came from — the native fold vs the method's convention — which is
decided entirely by *which* native entry the emitter routes to, §4; their runtime-side release logic
is identical. The inbound one differs in that there *is* no incoming +1.) Verified first-hand
(`inbound-value-kinds-k79`, 2026-07-11), measured off `-retainCount` rather than asserted: a fresh
borrowed wrap takes the object 1 → 2, two redeliveries hold it at 2 (no leak per event), and
disposing the wrapper returns it to 1.

### 3. Wrapper uniquing — one live wrapper per `id`

A runtime-side **`Map<id, WeakRef<NSObject>>`** guarantees at most one live wrapper per
ObjC `id`. Required, not cosmetic: without it, repeated read-only access (`view.superview`
in a loop) mints a fresh +1 each time (retain leak), and pointer identity (`sender ===
this.button`, `Set`/`Map` keys) breaks — idiom AppKit leans on constantly. The **uniform +1
makes the raw `id` a sound key**: the wrapper's retain pins the id for the entry's whole
life, so the object cannot be dealloced-and-address-reused while an entry for it is live.
This observes the ObjC heap without governing it (contrast the MacRuby fusion / NativeScript
"splice").

**The FR-lag window, and the guarded slot removal it forces.** JS's `FinalizationRegistry`
decouples *collection* (the `WeakRef` goes dead) from *notification* (the callback fires
"some time later," §5), so between a wrapper's collection and its FR firing the map slot
holds a **dead `WeakRef`**. A re-wrap of the same still-alive `id` in that window derefs the
dead slot → miss → mints a fresh wrapper `W2` (a second, transient +1 — bounded and
GC-reclaimed, *never* a UAF, because the original +1 still pins the `id`). The hazard is what
the *stale* FR does when it finally fires: a naive **unconditional** `Map.delete(id)` would
evict `W2`'s **live** entry, breaking `===` for a reachable wrapper and cascading (`W2`'s
later FR then evicts `W3`, …). So the FR callback's slot removal is **guarded — it deletes
the slot only when the slot's current occupant is itself dead** (`Map.get(id)?.deref() ===
undefined`); a live occupant is *by construction* a newer wrapper that must keep its slot
(§5). `release(id)` stays **unconditional** — each wrapper releases exactly the one +1 it
took; only slot *reclamation* is guarded. With the guard, "one live wrapper per **reachable**
`id`" holds across the FR-lag window: the sole ever-coexisting duplicate is an unreachable
zombie awaiting reclamation, which no JS code can observe.

### 3b. Which class a wrapper mints as — the declared one, else the nearest bound ancestor

*(settled `dynamic-class-wrap-k88`, 2026-07-12.)* §2/§3 fix *when* a wrapper is minted and what it
owns; they never said **what class it is**. The emitter passed the class the IR **declared** for the
slot — and for a slot the IR declares no class for (a bare `id`, an ObjC generic param: **1380
positions** in AppKit + Foundation alone) it passed the root. So `NSArray.array().objectAtIndex_(0)`
returned an `NSObject` carrying **none of `NSString`'s methods**, and a protocol-qualified slot could
not be honestly typed by its interface at all (ADR-0055 §4b) — the type would promise members the
value lacks.

The wrap primitives therefore take a **class-less arm** (`__wrapRetained(id)`, one arg — the arity *is*
the fact, so a call site cannot forget which it knows), and it resolves the class **from the object**:

- **A declared class still wins.** The IR knows what the runtime will not say: a declared `NSString` is
  really a `__NSCFString`, and no binding declares *that*.
- **Otherwise: `object_getClass`, then climb `class_getSuperclass` to the nearest class the binding
  declares.** The climb is the mechanism, not a fallback — Cocoa is built from **class clusters**, so an
  object's own class is *usually* private and absent from every header: a string is an
  `NSTaggedPointerString`, an array an `__NSSingleObjectArrayI` (both measured first-hand,
  `test/dynamic-class.mjs`). Resolving to the literal class would hand back a method-less stand-in for
  almost every real object — the same lie, relocated. Every method the bound ancestor exposes is one the
  object genuinely responds to, because ObjC inheritance says so.
- **With no bound ancestor at all**, ADR-0055 §5b's **stand-in** still answers: the true handle, the true
  name, a stable identity.

This is the **gerbil rule** (ADR-0020, `CONTEXT.md` *Class registry*: "`object_getClass` → the exact bound
type, with the runtime walking the ObjC superclass chain to the nearest bound ancestor when a class is
unbound"), which `class_binding.rs` already applies to a *type reference* (ADR-0055 §1b's degrade arm).
This is the same rule at the **value** boundary — so the two agree, rather than one target's runtime
quietly doing better than another's.

**The class-less arm carries the slot's declared conformance** *(added `protocol-binding-surface-k89`,
2026-07-12.)* Resolution is dynamic, so the arm can only *statically* promise the root — but the slot's
declared type may be narrower. A `id<P>` return declares `P & NSObject` (ADR-0055 §4b's covariant arm),
so the emitted body writes `__wrapRetained<P & NSObject>(__ret)`: a defaulted type parameter
(`<T extends NSObject = NSObject>`, so every unqualified `id` call site stays byte-identical) carrying
the conformance the **ObjC header declares**. It changes nothing at run time — the class still comes
from the object, never from `T` — and it is sound for the same reason the whole arm is: what the header
declares about an object's conformance is a fact `tsc` cannot derive and ObjC guarantees. Rendered from
the same predicate as the signature, so the wrap and the type it satisfies are one string by
construction.

**Cost.** Resolution lives inside the mint, never at the call site, so a **live wrapper still costs zero
extra native crossings** — the common case (the same `sender` on every event) must not get more expensive,
and does not (measured). The climb is memoized on the object's runtime `Class` (classes are permanent), so
it runs once per distinct cluster class. A memo taken before a nearer ancestor's module was imported stays
a *sound but less specific* alias — §5b's existing stand-in trade-off, unchanged.

Rejected: **resolve at the call site** (`__wrapRetained(__ctorOf(__ret), __ret)`) — transparent in the
emitted body, but it crosses to `object_getClass` on *every* `id` return including the live-wrapper fast
path, which is the one path ADR-0057 §3's uniquing exists to keep crossing-free. Rejected: **leave the
receive side degraded** and bind protocol qualifiers only in param position — honest, and defensible on
variance grounds (a qualifier is a requirement, and a requirement can only be imposed on whoever *supplies*
the value), but it freezes the `id`→bare-root degradation permanently and buys nothing the climb does not.

### 4. Where the seam lives — policy in TS, mechanism Swift-native

The **TS runtime owns policy** (the uniquing map, `WeakRef`, the FR, the `disposed` flag,
`[Symbol.dispose]`, and *when* to retain/release). The **native core owns mechanism** —
`objc_retain`/`objc_release` (or `Unmanaged`) — Swift-native per the north star that the
native library is the binding (ADR-0010) and the target-level steer to keep performance-
critical code in Swift. **Retain-on-wrap folds into the Swift `@_cdecl` dispatch entry, iff
+0** (baseline): a **+0-returning** entry `objc_retain`s before returning, so the `id` arrives
at JS already +1 with no extra JS→native crossing. A **+1-convention return**
(`alloc`/`new`/`copy`/`mutableCopy`/`ns_returns_retained`) must **not** be folded — the
method's own +1 *is* the wrapper's +1 — so the emitter content-addresses the ownership into the
entry name (a `…_o` suffix parallel to the `…_e` error axis) and routes it to a **distinct
non-folding** entry (`__wrapOwned` takes the +1 directly). Getting the fold *exactly once* — +0
in the entry, +1 not at all, and the redundant incoming +1 released whenever uniquing hits a
live wrapper (§2) — is what makes every wrapped object reach JS at a uniform +1. `release` is a
native primitive the dispose/FR paths call. The **FR held-value is the raw `id`, never the
wrapper** (the sbcl ADR-0036 rule — else the wrapper never becomes collectable); dispose
**unregisters** the FR token so a disposed object never double-fires.

**The fold is gated on the wrap boundary, not on the ABI shape.** An entry folds iff the emitted
`.ts` *wraps* the return (`is_object_type` — `Class`/`id`/`instancetype`) **and** that return is
+0. The dispatch ABI collapses every pointer-like into one shape, so a `Class` ref and a `SEL`
also cross as pointer handles — but neither is wrapped, and folding them is wrong twice over:
nothing would ever release a retained class, and `objc_retain` on a selector is undefined
behaviour (a `SEL` is not an object). The two families realise the same rule through different
channels, because the fold's *key* differs. A **method**'s convention is a property of its
selector, so it content-addresses into the entry name — a **three-state retain axis**: the bare
name (+0 object, folds), the `…_o` sibling (+1 object, no fold), and the `…_n` sibling (a
pointer that is no object — `SEL`/`Class` — no fold, no wrap), all computed by the one
emitter predicate (`method_retain_axis`) that also picks the wrap primitive, so a call site
and its entry can never disagree. A **free C function**'s is a
property of its symbol (the CF **Create Rule** on the name — ADR-0054 §1a) while its Swift body
is shared per ABI signature, so the flag rides the per-symbol `AwFnDesc` descriptor that
`napi_create_function`'s `data` payload carries, and the shared body branches on it. Verified
first-hand (`fn-table-codegen-k69`, 2026-07-09): a folded +0 return (`NSTemporaryDirectory()`)
holds `retainCount` 2 inside its autorelease pool and survives the drain at 1, while an unfolded
+1 return (`MTLCopyAllDevices()`) holds exactly 1 — and the 233 folding entries are exactly the
233 emitted `__wrapRetained` call sites, disjoint from the 7 `__wrapOwned` ones. On the method
channel (`ptr-return-fold-gate-k70`, 2026-07-11): the corpus's 52 non-object pointer call sites
(24 `SEL` returns, 28 `Class` returns) route to 3 non-folding `_n` entries (998 → 1001), the
plain/owned/error populations unchanged, and a `Class` handle round-trips the `_n` entry
identically (no fold), battery green.

**A third channel: the constant-read entries** (`pointer-constant-ownership-k92`,
2026-07-15). A module-load constant read (ADR-0055 §6) is a third outbound-`+0` shape
alongside methods and free functions, and it answers to the identical rule: the fold is
gated on the wrap boundary (`is_object_type`), never on the ABI shape being `Ptr` alone.
`AbiType::from_type_ref` deliberately collapses every pointer-like — an object, a
`Class`/`SEL` metatype, a block, a raw `void *`, even an **array-decayed** global (`extern
const unsigned char X[]`, whose "pointer value" is the symbol's own address) — onto one
code, `P`; a constant's entry name forks on ownership the same way a method's does,
content-addressed by the **result shape alone** (a constant has no selector to carry the
axis, so it lives directly on `constant_entry_name`'s `is_object` parameter): the bare
`aw_ts_const_P` (an `id`/`Class`/`instancetype` global — folds a `+1`, the emitter wraps it)
or the distinct non-folding `aw_ts_const_P_n` (an opaque pointer — never wrapped, never
retained, read through unconverted as a `bigint`, mirroring the method channel's `_n`
sibling). Unlike the method/free-function channels, this one had **no** `_n`-shaped sibling
before k92 — every pointer-shaped constant, object or not, retained through the bare `P`
entry — so a genuinely non-object global crashed or corrupted on `objc_retain` dereferencing
a nonexistent `isa`. Measured first-hand, both the defect and the fix: `CoreSpotlightVersionString`
(`extern const unsigned char[]`, whose loaded "id" is ASCII banner text) reliably SIGSEGVs
through the old bare `P` entry and reads cleanly (no crash, an inert `bigint`) through the new
`P_n` entry; corpus-wide, 4161 constants (4156 raw-pointer-kind + 5 block-kind, zero
`SEL`/`Class`-kind) are pointer-shaped and not objects — after this leaf, all 4161 route
through `P_n`, so the corpus retains zero non-objects. The array-decayed case still reads the
*wrong value* (the first 8 bytes of the array's content, not a meaningful handle) — a
marshalling-honesty gap, not a lifetime one, left to a sibling leaf.

**"No wrap" is a lifetime claim, not a marshalling one** (`sel-classref-surface-k72`,
2026-07-11). The `_n` entry stays raw, and neither kind ever enters the lifetime machinery — no
retain, no `Map<id, WeakRef>` uniquing, no disposal. But both still **convert** at the `.ts`
boundary, because neither is a `bigint` at the TS surface: a `SEL` is its selector-name `string`
and a `Class` is the bound constructor (ADR-0055 §3/§5b). That conversion is pure `.ts`-side
policy (`__selName` / `__classCtor`), so it changes no entry name and leaves the native tables
untouched — the ADR-0055 §2 seam holding exactly as designed. A **fallible** `…error:` method
with a `SEL`/`Class` primary is therefore **deferred** by the method filter (population today:
zero): the `Result<T>` helpers wrap an object or pass a scalar through, and neither can carry a
handle that must convert.

**The retain axis has a fourth reader: the object a JS callback *returns*** (`inbound-value-kinds-k79`,
2026-07-11). An inbound return crosses JS→ObjC, so it is the mirror of the wrap boundary, and it
answers to the *same* three states — computed by the *same* `method_retain_axis` predicate, never
re-derived (the emitter stamps the axis into the value-kind descriptor the callback registers,
ADR-0059 §8):

- **`+0`-convention selector** (the default) → **`objc_retainAutorelease`**. This is the actual ObjC
  `+0`-return contract — the caller owns nothing and the reference is valid until the pool drains —
  and it is what makes a JS override's `return NSMenu.alloc().init()` safe *by construction*, because
  the returned reference is then independent of the JS wrapper's +1 (which the FR may reclaim the
  moment the callback's frame unwinds). Handing back the bare `__unwrap` handle instead would leave
  the object alive only for as long as a collectable JS wrapper happened to hold it.
- **`+1`-convention selector** (an overridden `copyWithZone:` / `init` / `new`, reached inbound) →
  **`objc_retain`**, no autorelease: the caller *owns* the returned object. An autorelease here would
  under-retain and crash the caller once the pool drained.
- **`SEL` / `Class`** → neither (`__sel` / `__classArg` convert; retaining a class leaks and
  `objc_retain` on a selector is UB — the same reason the `_n` entry exists).

The pool the `+0` arm needs is the ambient one (§8): on thread 0, AppKit's per-runloop-iteration pool;
off-main, the framework thread invoking a value-returning callback already needs one for *any* `+0`
return. Verified first-hand, measured off `-retainCount`: a `+0` return reaches the caller at 2 (the
wrapper's +1 plus the pending autorelease's) and drains to 1; an `owned` return reaches it at 2 and
**survives** the drain.

The N-API boundary language is now settled **Swift-native** (ADR-0054 §2, confirmed by
`napi-dispatch-spine-k35`); the Node-vs-embedded-JavaScriptCore engine split is
**`ts-substrate-reeval-k11`** (two separate targets). The model above is invariant to both —
`retain`/`release` stays a native primitive the dispose/FR paths call, and the retain-fold
into the dispatch entry (§4) is Swift either way; only the physical boundary moved (into the
one Swift `.node`, no Rust crossing).

### 5. `FinalizationRegistry` contract — silent best-effort release

FR fires → **`release(id)` unconditionally, then remove the map slot *only if it still holds
a dead `WeakRef`* (`Map.get(id)?.deref() === undefined`) — on-main, silently.** The guard
closes the FR-lag race (§3): a stale FR firing after the slot was re-taken by a live wrapper
still releases its own +1 but leaves the newer wrapper's slot intact. It works precisely
because the held-value is the **raw `id`** (§4): the callback never claims to know *whose*
slot it holds, so it does not compare identities — it removes the slot only when *nothing
live* occupies it, which is the sound condition regardless of which wrapper the FR belongs
to. Best-effort *release*, not a warn-only detector: under §2 a dropped handle is the **normal** path
for every graph-handed object (build a view, add it to the window, drop the JS ref), so
warning would false-positive on every handoff and not-releasing would leak most graph
objects. Safe because release runs on thread 0 (§7), so any triggered AppKit `dealloc` is
UI-safe.

This **refines the research's "leak-detector" framing**: under uniform-+1, FR is the leak-
*preventer* (reclaimer), and the *genuine* leak — FR **never firing** (shutdown → the OS
reclaims; or pathological no-GC-pressure churn) — is undetectable from inside the callback.
So leak *detection* is a **separate, opt-in facility** (a live-wrapper high-water count / a
debug dump of still-registered handles at shutdown), **off by default**; FR reclamation is
always silent. On Node/V8 under normal GC pressure FR does run, so orphaned +1s reclaim
eventually — the practical leak is bounded to shutdown and pathological churn.

### 6. Use-after-dispose is a thrown error, not a UAF

Dispose flips a `disposed` flag and removes the map entry; any subsequent use of the handle
throws **`ObjectDisposedError`** rather than calling into a released `id`. Dispose means "the
wrapper relinquishes its +1 and is dead," not "the object is definitely freed" (the ObjC graph
may still retain it) — so aliased handles fail loudly instead of corrupting memory. Dispose's
map removal is **unconditional and needs no §3/§5 guard**: dispose runs on a *reachable*
wrapper, which is necessarily the slot's current occupant (a live wrapper is never displaced
from the slot, so a second wrapper for the same `id` cannot coexist while this one is
reachable), and dispose **unregisters its own FR token** (§4) so no stale FR fires for it
later. The FR-lag race is therefore FR-path-specific. **Ordering
(refined by ADR-0059 §4/Mechanics):** the flag flip + map-entry removal happen **after** the
`release` — and any *synchronous* `dealloc` it triggers (refcount → 0 on thread 0) — completes,
not before. So a dynamically-subclassed object's JS `dealloc` override runs against a *live*
handle (`this.removeObserver_`, `this.$super.dealloc()` dispatch normally), and a re-entrant wrap
of self *during* dealloc hits the still-live map entry (no fresh +1 resurrecting an object
mid-dealloc). Post-`dispose` aliases still throw. For an object with no JS `dealloc` override the
order is immaterial (release does not re-enter JS).

### 7. No main-thread release queue

Unlike sbcl ADR-0036 — whose `sb-ext:finalize` runs off-main and therefore needs a queue to
drain `release` on main — **both** TS release paths already run on thread 0:
`[Symbol.dispose]`/`using` synchronously in JS, and FR callbacks on the main JS thread
(verified: V8/Node run cleanup callbacks on the agent's own thread, as a queued task after
the microtask checkpoint, never on a background/GC thread). Under ADR-0056 that thread *is*
AppKit's thread 0, so every **binding-initiated** `release`→`dealloc` is UI-safe with **no queue
and no bounce.** (The claim scopes to *the binding's* release paths; the *framework's* own release
of a wrapped object is ObjC's and may fire off-main — for a plain wrapped `id` that is a
thread-safe `objc_release`, and for a **dynamically-subclassed object with a JS `dealloc`** ADR-0059
§4 bounces the override synchronously to thread 0.) Two conventions are documented (not mechanisms
built): **main-thread affinity** — AppKit/UI objects are created, used, and released on main, never
wrapped or disposed on `worker_threads` (Cocoa's own rule; safe by construction because wrappers do
not structured-clone across worker isolates; non-UI Foundation value objects have thread-safe
`dealloc` and a worker may release its own directly); and the **Q6 re-entrancy coupling**, now
settled — a dynamically-subclassed object with a JS `dealloc` re-entering JS during a synchronous
dispose is safe because the §6 ordering keeps the handle live through the override, and off-main
framework dealloc bounces synchronously to thread 0 (**ADR-0059 §4**).

### 8. Autorelease pools — lean ambient model + a user primitive

Uniform +1 **demotes the autorelease pool from a lifetime mechanism to a temporary-drain**
(it only drains ObjC-internal temporaries and the pending autorelease of retained +0
returns). On the main thread the **ambient AppKit per-runloop-iteration pool** plus the
native launcher's outermost `main()` `@autoreleasepool` (ADR-0056 entry architecture) cover
it — no per-entry pool is injected, and the pump's `uv_run(NOWAIT)` passes and the
background→main callbacks all run inside runloop iterations. A user-facing
**`withAutoreleasePool(fn)`** primitive covers what the ambient pool does not: hot
synchronous JS loops on main that never yield, and `worker_threads` doing ObjC work (the
thread-local-pool obligation, PyObjC §B2). The obligation is documented as observable user
behaviour, exactly as the Lisp family does (ADR-0036 §Consequences); the mechanism is the
primitive. Where chez/sbcl make the entry-point pool structurally load-bearing, TS makes it
an optional drain — a direct consequence of uniform +1.

### 9. No disposal cascade across the graph

Disposing a wrapper does **not** recursively dispose child wrappers. Each wrapper owns one
independent +1; the ObjC graph cascades `dealloc` through its own refcounting when a parent
deallocs. Disposal **order across the graph is irrelevant** (releasing a parent while
children are still referenced just decrements it; children stay alive via the parent's
retains and their own independent +1s), and disposing a parent never dangles a child
wrapper. No double-free.

## Considered options

- **Trust the GC hook as primary (the Lisp model, copied).** Rejected §1 — JS's FR "may not
  run at all"; a leaked ObjC object per miss, no ordering, no shutdown drain.
- **Honor the ObjC +0/+1 split with pool-scoped +0 handles (chez/sbcl faithful).** Rejected
  §2 — JS has no ARC store-time retain, so a stored +0 handle is a silent UAF at the next
  turn boundary.
- **Fold the retain *unconditionally* in the native entry (both +0 and +1), then cancel it
  in the runtime for +1.** Rejected §4 — a +1 return would arrive +2 and every +1 mint would
  pay an extra `release` crossing to cancel the fold; and it muddies the entry (always
  over-retain, always correct downstream). The +0-only fold keeps the entry honest and taxes
  no +1 mint. **Fold in the runtime `__wrapRetained` instead of the entry** is also rejected —
  it reintroduces the extra JS→native crossing on the common +0 path the entry-fold exists to
  avoid.
- **NativeScript "splice" — flip the wrapper strong/weak on the ObjC refcount crossing
  1↔2.** Rejected §3 — reduces FR reliance but **fuses the two heaps' liveness** (the
  MacRuby/§C1 red-line) and is racy ("half-dead splice", research B1).
- **A main-thread release queue (sbcl ADR-0036).** Rejected §7 — unnecessary here because
  both release paths already run on thread 0; the queue exists in sbcl only because its
  finalizer is off-main.
- **Unconditional `Map.delete(id)` in the FR callback.** Rejected §3/§5 — because JS's FR
  decouples collection from notification, a stale FR can fire after the slot was re-taken by
  a live wrapper; an unconditional delete would evict that newer wrapper, break `===`, and
  cascade. The guarded remove (`Map.get(id)?.deref() === undefined`) closes the window at no
  cost to the raw-`id` held-value.
- **Warn-only FR leak detector.** Rejected §5 — false-positives on every normal graph
  handoff and fails to reclaim; FR must release.
- **Explicit autorelease pool at every JS→ObjC entry (strict Lisp convention).** Rejected
  §8 — redundant with AppKit's ambient pool on the common path, taxes every entry.

## Consequences

- **The runtime library** owns the uniquing map, the `WeakRef`/FR registration, the
  `disposed` flag + `ObjectDisposedError`, the `__wrapRetained`/`__wrapOwned`/`__wrapBorrowed`
  primitives, the `NSObject[Symbol.dispose]` hook, and `withAutoreleasePool`. **The native core** owns
  `retain`/`retainAutorelease`/`release`, with retain folded into the `@_cdecl` dispatch entries on
  the outbound `+0` path (the inbound path cannot fold — §2). Load-bearing:
  bugs here surface as use-after-free or as Activity-Monitor growth — the same failure
  signature as the chez guardian / sbcl release queue.
- **`emit-typescript`** emits the correct wrap primitive per method from the IR's +0/+1
  ownership annotation; a wrong annotation is an over- or under-retain, so ownership is an
  analysis-phase correctness invariant (the ADR-0039-style "integrity is upstream" posture).
- **Sample-app authors** get an obligation, not shared code: wrap hot non-runloop loops and
  any worker-thread ObjC work in `withAutoreleasePool`; keep AppKit objects on main.
  Documented in the target reference.
- **Hard to reverse:** the `[Symbol.dispose]` root hook, uniform +1, the uniquing map, and
  the two wrap primitives are baked into the runtime and every generated module.
- **Engine scope (resolved 2026-07-06).** This is the **Node** TypeScript target's lifetime model, and
  it stands. `ts-substrate-reeval-k11` did **not** flip the engine; it established that Node and embedded
  JavaScriptCore are two separate *targets* (ADR-0054 §Target scope). So the model spine (§§1–4, 9) and
  the Node tail (§§5, 7, 8 — grilled against Node+N-API) are simply this target's model. The **JSC
  target's** lifetime model — where `JSManagedValue` is a supported third option softening §5's FR
  dependence, the ADR-0056 pump is absent (simplifying §8's entry points), and §7's bg-bounce is
  `dispatch_async(main)` rather than `napi_threadsafe_function` — is designed separately in that target's
  future grove, grounded in `targets/typescript/docs/research/2026-07-06-ts-substrate-reeval/FINDINGS.md`
  §B (which confirmed `JSManagedValue` is Apple-supported and PARTIAL on softening FR). No rework of this
  ADR is pending.

Target-local under **ADR-0011**. See ADR-0007 / ADR-0019 / ADR-0036 (the Lisp two-mechanism
precedents this re-polarises), ADR-0054 (substrate), ADR-0055 §7 (the branded-handle
instance this closes), ADR-0056 (threading — thread-0 JS loop, the bg→main bounce),
ADR-0039 (selector integrity as an analysis invariant, the posture §2's wrap primitives
inherit), and `targets/typescript/docs/research/2026-07-05-js-objc-bridge-prior-art.md`
(§Synthesis D4, §C1 MacRuby, §C4 FinalizationRegistry-vs-`Symbol.dispose`, §B2 PyObjC) plus
MDN FinalizationRegistry, v8.dev/features/weak-references, and Cloudflare "we shipped
FinalizationRegistry… why you should never use it" for the FR-unreliability + FR-on-main
evidence.
