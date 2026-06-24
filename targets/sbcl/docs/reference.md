# sbcl — Target Reference

Written-after-the-fact learnings for the `sbcl` generation target, captured at
the close of the `add-sbcl-clos-target` grove (2026-06). Like the chez and gerbil
references it is deliberately shorter than `racket.md`: where the targets agree
(pipeline, IR, framework set, sample-app portfolio, TestAnyware bar) read the
racket reference. This file covers only what is *sbcl-specific* and was
*surprising in practice*. Per project convention, gotcha entries carry a date and
a 🔴/🟡/🟢 priority.

SBCL is the fourth target and the **first member of the CL family** — the only
family whose members share a spec-level interface contract (ADR-0033). Two
documents are CL-family-wide and main-tier, *not* in this unit; read them as the
authoritative cross-target records:

- Contract spec: `targets/_shared/docs/design/2026-06-20-cl-family-interface-contract.md` (ADR-0033)
  — the portable `ns:`/CLOS surface. This target is its **SBCL realization**.
- 020 survey: `targets/_shared/docs/research/cl-cocoa-bridges-across-the-family.md` — prior-art +
  landscape across SBCL/CCL/AllegroCL/LispWorks.

Companion design + decisions (all central in `adr/`):

- Design spec: `docs/design/2026-06-20-sbcl-target-design.md` (the two-layer
  realization; read the ADRs below as the live state).
- ADR-0034 — object model + dispatch: the `objc-class` metaclass MOP projection,
  per-selector receiver-specialized generics, static emit + startup re-resolution.
- ADR-0035 — callbacks bounce to the main thread (foreign-thread Lisp entry is
  GC-unsafe — spiked first-hand, 5/5 crash).
- ADR-0036 — lifetime = `sb-ext:finalize` + a main-thread release queue +
  entry-point pool.
- ADR-0037 — `NSError**` / `throws` / `NSException` → a flat `ns:objc-error`
  **condition** hierarchy (signalled, not a `(values result error)` tuple — the
  CL-family idiom, diverging from chez/gerbil).
- ADR-0038 — `libAPIAnywareSbcl` is the target's **sole** native compilation unit
  (trampolines + the bounce/IMP/marshalling concerns gerbil kept in ObjC).
- ADR-0039 — selector-structure-preserving generic names (colon→`_`, hump→`-`).
- ADR-0040 — typed `make-instance` init appliers, and **FP-trap masking** (§2).
- ADR-0041 — `bundle-sbcl` self-containment without `install_name_tool` (§10).
- ADR-0042 — value-struct CLOS projection (`ns:value-struct`, §9).

## 1. Reader's mental model

SBCL projects the macOS ObjC API into **idiomatic CLOS**, reaching ObjC directly
and the Swift-native delta through one dylib. Two layers, the ADR-0025 framing:

- **Upper layer (Lisp).** The `objc-class` metaclass + `sb-mop` hooks; the static
  class graph; per-selector receiver-specialized generics; `make-instance` →
  alloc/init; `define-objc-subclass`; lifetime; conditions; the startup
  re-resolution pass.
- **FFI seam (`sb-alien`, compiled FFI — ADR-0015).** `objc_msgSend` reached
  **directly** (the trampoline is *elided* — see the complete-API model in
  `CONTEXT.md`); only the Swift-native residual routes through `aw_sbcl_*` C-ABI
  entries.
- **Lower layer (`libAPIAnywareSbcl`, ADR-0038).** The sole native unit: the
  generated Swift-native `@_cdecl` trampolines, the opaque-value box, the
  `throws`/async bridges, the foreign→main-thread callback bounce, and ObjC
  subclass-IMP synthesis.

Three commitments distinguish sbcl from the Scheme targets:

1. **A MOP projection, not a manifest `defclass` graph (ADR-0034).** ObjC's class
   system is projected into CLOS *through the metaobject protocol*: an `objc-class`
   metaclass (a `standard-class` subclass) backs every bound ObjC class; the
   runtime-owned root `ns:ns-object` carries the foreign `ptr` (the `id`); the full
   ancestor chain is reified. This goes **further** than gerbil's manifest graph
   (ADR-0020) and rejects the single-wrapper-class "vacuous" shape (ADR-0018) —
   dispatch rides a *real* metaclass-backed class graph, with ivars as foreign
   slots via `slot-value-using-class`.
2. **Per-selector generic dispatch over the real graph (D6, ADR-0034 §3).** One
   `defgeneric` per selector (in `ns:`, the named surface) + one `defmethod` per
   (class × selector), **specialized on the receiver** — CLOS generic dispatch +
   method combination + `call-next-method` for subclass overrides. Not
   multiple-argument dispatch (ObjC is single-receiver). The "generic explosion"
   risk is *closed*: a full AppKit+Foundation-scale spike (6,500 generics + 40,000
   methods) compiled **cold in ~8.4 s, single-threaded** — so **no sharding, no
   special flags, no parallel compile** (gerbil's ADR-0023 5-hour pathology lived
   in Gambit's `:std/generic` macro, not in SBCL's native CLOS).
3. **Errors are signalled conditions, not tuples (ADR-0037).** The CL-family idiom
   diverges from chez/gerbil's `(values result error)`: a Cocoa error surfaces as
   a signalled `ns:cocoa-error` / `ns:objc-exception` condition, caught with
   `handler-case`. This is part of the *contract*, observable across CL impls.

The runtime is nine modules under `lib/runtime/` (`packages` · `ffi` · `objc` ·
`swift-trampoline` · `subclass` · `lifetime` · `conditions` · `threading` ·
`startup`, plus `reader-syntax`). The module table, dev load order, and smoke
suite live in `lib/runtime/README.md` — read it before touching the runtime.

## 2. Toolchain & the FP-trap landmine

`brew install sbcl` → SBCL **2.6.5** / arm64 (the version every spike and smoke
was run against). No bottle gymnastics like gerbil's — the Homebrew SBCL works
directly. `sb-alien` is compiler-integrated, so there is no external FFI library
to provision. Export `SDKROOT="$(xcrun --sdk macosx --show-sdk-path)"` for the
Swift dylib build, as elsewhere in the repo.

🔴 **2026-06-23 — SBCL enables IEEE FP traps by default; AppKit crashes without
masking them (ADR-0040 §2).** SBCL is unusual: `:invalid` / `:divide-by-zero` /
`:overflow` are *on* at boot, where almost every other runtime masks them.
AppKit/CoreGraphics routinely produce NaN/∞ intermediates during ordinary layout —
even a bare `[[NSWindow alloc] init]` trips `:invalid` — so an unmasked SBCL
crashes *any* GUI app with `FLOATING-POINT-INVALID-OPERATION`. The runtime clears
the traps (`(sb-int:set-floating-point-modes :traps '())`, `aw-mask-fp-traps`) at
load **and** in the startup re-resolution hook, because FP modes are thread-local
and do **not** survive a `save-lisp-and-die` revive. The bounce model (§7) keeps
all Cocoa callbacks on the main thread — the thread that masks — so foreign
threads never need their own masking. CCL and cl-objc mask identically; this is a
known Lisp-Cocoa requirement, not an sbcl quirk we invented.

## 3. FFI — the `sb-alien` seam (ADR-0015)

The seam (`lib/runtime/ffi.lisp`) reaches ObjC **directly**, no shim:

- **One `objc_msgSend` SAP, recast per call site.** `objc_msgSend` is
  selector-polymorphic, so it cannot be a single `define-alien-routine`. Its
  address is taken **once as a raw SAP** (`+objc-msgsend+`) and `sap-alien`-recast
  to the exact `(function <ret> sap sap <args>…)` type **per call site** — the
  compiled-FFI analogue of chez's per-signature `foreign-procedure`. arm64 needs
  **no `objc_msgSend_stret`/`_fpret`** variant: the plain entry returns
  structs/floats correctly via x8 (verified with `-rangeOfString:`).
- **Classes + selectors resolve lazily from baked strings, cached** (`aw-class` /
  `aw-sel` over `*class-cache*`/`*sel-cache*`). A framework must be `dlopen`ed
  (`aw-load-framework`, via `sb-alien:load-shared-object`) before its classes
  resolve. **Never bake a `Class`/`SEL` pointer** — bake the *string* and
  re-resolve per process (the dump survives because of this — §10).
- **Geometry crosses by value** as `(sb-alien:struct <name>)`, with
  `NSRect`/`CGRect` canonicalised to `ns-rect`. The FFI mapper emits the struct
  ref and delegates the `define-alien-type` to the runtime; the nine canonical
  geometry structs (point/size/rect/range/insets/transforms/`cg-vector`, arm64
  layout) live in the seam. By-value passing is confirmed end-to-end (a live
  `NSRange {6, 5}` through `+objc-msgsend+`).

🟢 **2026-06-23 (drawing-canvas) — by-value struct RETURNS are directly
slot-readable; no accessor helper needed (divergence from gerbil).**
`-[NSEvent locationInWindow]` returns `(sb-alien:struct ns-point)`; arm64 routes
the HFA return cleanly, so `(sb-alien:slot (ns:location-in-window ev) 'x)` reads x
directly, and a returned struct chains straight into another method's struct arg
(`convert-point:fromView:`). Gerbil needed hand-written `point-x`/`point-y`
accessors because Gambit's FFI returns by-value structs differently; sbcl's
`sb-alien` needs none.

🔴 **2026-06-23 (swift-native-probe) — `t` and `nil` are illegal lambda-list
formals; the emitter must rename them.** `CGAffineTransformInvert(_ t:)` kebab'd
its C parameter name straight to `t`, a CL **defined constant** illegal as a
variable — so the whole `coregraphics/functions.lisp` raised at load and any
`:load-residual t` of CoreGraphics failed. Fixed emitter-side
(`naming::is_cl_reserved_formal`) at *both* formal sites (`emit_functions` C args
and `emit_generics` CLOS params), falling back to positional `argN`. Protects
every residual-loading app; goldens unchanged. (After collision resolution `t-1`
etc. are fine — only the bare constant is reserved.)

## 4. Object model & dispatch (ADR-0034)

The headline distinctive (§1). Practical consequences seen across the ladder:

- **Inherited methods dispatch by plain CLOS inheritance — for free.** A method
  declared on a superclass applies to a subclass instance with no per-target
  idiom: `setStringValue:` is emitted only on `ns:ns-control` yet dispatches onto
  `NSSlider`/`NSStepper`/…; `NSOpenPanel`'s `runModal`/`URL` are declared on
  `NSSavePanel` and reach the open-panel instance because `ns:ns-open-panel`
  subclasses `ns:ns-save-panel`. Grepping a subclass file for an inherited setter
  returns 0 — that is correct, not a gap. (chez/gerbil route via the declaring
  class's proc; CLOS does it structurally.)
- **`make-instance` → alloc/init, with a typed init applier (ADR-0040 §1).** No
  init initargs ⇒ `alloc`+`-init`. A designated init with arguments is baked into
  `*objc-init-registry*` *with its argument types*, and `aw-apply-init` builds the
  typed `alien-funcall` from them — so `NSWindow`'s
  `initWithContentRect:styleMask:backing:defer:` (an `NSRect` by value + two enums
  + a `BOOL`) constructs via `(make-instance 'ns:ns-window :content-rect r
  :style-mask … :backing … :defer …)`. By-value geometry flows cleanly through the
  `&rest initargs` plist into the applier's `(struct ns-rect)` arg, copied by value
  inside the `aw-with-rect` dynamic extent.
- **`make-instance` returns `nil` for a failed ObjC init.** A failable init
  (`initWithURL:` on a non-PDF) yields a null `id` → `aw-wrap` → `nil`, so
  `(when doc …)` is the whole guard. The typed-init path folds failable inits in
  cleanly.

🟡 **2026-06-23 (hello-window → ui-controls-gallery) — the init registry is keyed
by EXACT class; inherited *typed* inits do not resolve via `make-instance` on a
subclass — but this never bites in practice.** `aw-apply-init` does
`(gethash class *objc-init-registry*)` with no superclass walk, so an inherited
`initWithFrame:` (registered on `NSView`) is invisible to `make-instance` on a
subclass. hello-window predicted this would "bite the controls app hard"; it did
**not**, because modern AppKit construction is either a **class convenience
constructor** (`+buttonWithTitle:target:action:`, emitted as an
`(eql (find-class 'ns:…))` class-method generic, returning a +0 autoreleased
instance) or **bare `make-instance`** (alloc + `-init` + `setFrame:` + setters).
Neither needs a typed *inherited* init. **Decision: do not add the superclass-walk
for the ladder** — it stays a clean future enhancement (the applier already
dispatches its selector dynamically via `objc_msgSend`, so only the registry
*lookup* would need to walk the CPL). Add it the first time a real app needs a
typed inherited init, with its own tests, not before.

🟢 **Ownership matters at +0 storage sites.** A convenience constructor returns +0
autoreleased and is wrapped `(aw-wrap …)` *without* the retained flag (the
entry-point pool drains it; the superview retains on `addSubview:`). The alloc/init
path is +1 and wraps with `t`. Both are correct; see §5 for the bug that taught us
to **own, not borrow** anything you *store*.

### Selector → generic names (ADR-0039)

A selector maps to one generic symbol that **preserves selector structure**: each
`:` → `_`, each camelCase hump → `-`. So `objectAtIndex:` → `ns:object-at-index_`,
`setObject:forKey:` → `ns:set-object_for-key_`, `cancel` → `ns:cancel` but
`cancel:` → `ns:cancel_`. The map is **injective** — colon and hump never merge —
so distinct selectors never collide and need no rename table.

🔴 **2026-06-23 (mini-browser) — a per-target runtime that re-derives
selector→generic for its subclass macros MUST follow ADR-0039 too.** ADR-0039
fixed the *emitter*, but the **parallel reimplementation** in `subclass.lisp`'s
`aw-selector->generic-name` (used by `define-objc-method`) still dropped colons.
So `reload:` (a 1-arg target-action) mapped to `ns:reload` — the **same** symbol as
WKWebView's emitted 0-arg `reload` — and CLOS rejected the 2-arg defmethod on the
1-arg generic at load (`FIND-METHOD-LENGTH-MISMATCH`, caught by the construction
pre-flight before any VM trip). Fixed by syncing the runtime to ADR-0039
(`reload:` → `ns:reload_`). The structural invariant restored: every colon
contributes both an `_` to the name and an argument to the method, so a selector
that *does* name a real generic matches its arity. Earlier apps' selectors
(`openDocument:`, `pageChanged:`) never named a real method, so the gap stayed
latent. (The same rule binds every target whose runtime re-derives
selector→generic — see ADR-0039 and `CONTEXT.md` "Preserve selector structure".)

## 5. Lifetime — `sb-ext:finalize` + a main-thread release queue (ADR-0036)

The two-mechanism chez/gerbil shape (ADR-0007/0019) with one SBCL twist:
**finalizers run off-main.** `sb-ext:finalize` (idiomatic, O(dead) like a guardian)
is the GC-death trigger, but it runs on a dedicated `"finalizer"` thread — and an
off-main `dealloc` of an AppKit object is UB. So a finalizer captures only the raw
`id` and **enqueues** it; a **main-thread drain** at the entry-point pool boundary
sends `release` (UI-safe). Autoreleased +0 transients drain at the same pool
boundary. The off-main issue is *UI-affinity*, not GC-safety — the finalizer
thread is SBCL-native, hence suspendable (unlike the foreign threads of §7).

- **Off-run-loop loops must wrap themselves** in `(with-autorelease-pool …)` — the
  same rule Cocoa imposes on ObjC command-line tools, same as chez/gerbil. The
  pool is `unwind-protect`-based, so a signalled non-local exit still drains it.

🟢 **2026-06-23 (note-editor) — the gerbil weak-delegate GC bug CANNOT recur on
sbcl (structural).** note-editor rebuilds Markdown→HTML and calls `loadHTMLString`
on *every keystroke* — the exact allocation storm that reaped gerbil's
`make-delegate` wrappers under GC and killed all its callbacks (the most important
fix of the gerbil run). On sbcl `*subclass-instances*` is a **strong** hash table,
so a synthesized controller owning observers + target-actions is pinned for the
process; the per-keystroke storm never reaps it. The 050 design choice (strong
back-ref, not weak) made the capstone's allocation profile a non-event.

🔴 **2026-06-23 (scenekit-viewer) — a +0 accessor result you STORE must be owned,
not borrowed.** Recolouring a SceneKit geometry then swapping the geometry rendered
the new shape **white**. `color-using-color-space:` returns a +0 autoreleased
`NSColor` the Lisp slot merely borrowed; SceneKit allocates a fresh `firstMaterial`
per geometry, so `setGeometry:` deallocated the old material — the colour's last
owner — before the re-apply, leaving a dangling `id`. Fix: make Lisp an **owner** —
`own-color` retains to +1 (`%objc-retain`) and re-wraps with `aw-wrap … t`, arming
the main-thread release finalizer that balances it. The same +0→+1 promotion
`aw-make-nsstring` does for its transient. **Pattern: any +0 accessor result you
store (vs. immediately pass on) must be owned, or it dies with whatever currently
retains it.**

## 6. Error model — signalled `ns:objc-error` conditions (ADR-0037)

The CL-family idiom, **diverging from chez/gerbil's `(values result error)`**: a
Cocoa error surfaces as a **signalled CL condition**, caught with `handler-case`.
Flat hierarchy, split by source: root `ns:objc-error : cl:error`; `ns:cocoa-error`
(the `NSError**` path — `domain`/`code`/`user-info`/`localized-description`
readers); `ns:objc-exception` (the `NSException` path). The condition types are
**distinct symbols** from the projected CLOS classes `ns:ns-error`/`ns:ns-exception`
(the condition *wraps* the object). No per-domain subclasses (callers branch on
`domain`/`code`, keeping cross-impl conformance cheap); minimal restarts
(`use-value` / `continue` / `return-nil`). One signaller (`signal-cocoa-error`)
serves **both** the direct `NSError**` path and the Swift-`throws` trampoline's
`ThrowsBridge`. It signals **only** when the primary return indicates failure
(`nil`/`NO`) — Apple's "check the return, not the error", since `NSError**` may be
garbage on success.

## 7. Threading & callbacks — the foreign-vs-native split (ADR-0035)

SBCL is a genuinely multi-threaded runtime (`sb-thread`, real preemptive OS
threads), so — unlike gerbil's single-VM Gambit — the question "can a foreign
thread run Lisp?" was open and had to be **spiked, not assumed**. The threading
spike (`targets/sbcl/docs/research/2026-06-20-sbcl-threading-spike/`, SBCL 2.6.5 / arm64)
settled it:

| Who runs the consing callback | Result |
|---|---|
| 8 **SBCL-native** `sb-thread`s (control) | **SURVIVED** |
| **1** foreign GCD worker | survived |
| **8 concurrent** foreign GCD workers | **CRASHED 5/5** |

The crash is deterministic: a fatal `ENOTSUP` inside `SB-KERNEL::GC-STOP-THE-WORLD`
— SBCL cannot stop-the-world-suspend a thread it merely **attached** for a callback
(only threads it created). So the rule that governs every callback in this target:

> **A foreign OS thread (a GCD worker, a framework completion thread) must NEVER
> run Lisp.** Foreign-thread callbacks **bounce to the main thread** — SBCL-native,
> suspendable, owner of the AppKit run loop — before any Lisp runs.

The bounce is **native** (in `libAPIAnywareSbcl`, ADR-0038): the block body / the
subclass `forwardInvocation:` hops to main via `dispatch_sync` (synchronous,
because a callback **borrows** its framework-owned `id` arguments for the call's
extent — an async hop would run Lisp against freed objects), then calls the
registered Lisp dispatcher. On the main thread already (the UI common case — AppKit
delegates fire on main) it calls straight in: zero hop. The regression gate
(`lib/runtime/tests/smoke-threading-callbacks.lisp`) reproduces the
8-concurrent-worker storm under GC pressure and now **survives 5/5**.

### What this means for an app author

- **Background COMPUTE → `sb-thread` (`with-background-work`).** This is where sbcl
  is *richer than gerbil*: SBCL-native worker threads **do** run concurrent Lisp
  safely (the spike's control survived). Do pure-Lisp work on them freely.

  ```lisp
  (with-background-work (:name "reindex")
    (let ((result (expensive-pure-lisp-computation)))
      ;; To touch ObjC / the UI with the result, deliver it onto the main thread:
      (aw-on-main (lambda () (update-some-view result)))))
  ```

- **`aw-on-main`** runs a thunk on the main thread and blocks until it finishes —
  the UI-safe hand-off from a worker. (It drains only while the main thread
  services the run loop, i.e. under `[NSApp run]`.)

- **Blocks — `aw-block` is automatic.** A bound method taking an ObjC block
  argument accepts a plain Lisp closure; the emitted binding wraps it with
  `aw-block`. The closure receives the block's arguments at its natural arity (up
  to 3), as raw values — coerce an object arg with `aw-wrap`, read an index with
  `sb-sys:sap-int`:

  ```lisp
  (ns:enumerate-objects-using-block array
    (lambda (obj idx stop)
      (declare (ignore stop))
      (format t "~D: ~A~%" (sb-sys:sap-int idx) (nsstring->string obj))))
  ```

  A value-returning block's closure must end in a coercible value (a bound
  instance, an integer, a SAP, `t`/`nil`); a `void` block's return is ignored.
  Pass `nil` for "no block". (Bridgeable blocks are the integer-class signatures —
  pointer / `BOOL` / `NSInteger`-family args and result; by-value struct or
  `c-string` block slots keep their method deferred,
  [`emit-sbcl::is_bridgeable_block`].)

🟡 **2026-06-23 (note-editor) — `aw-block` has no lazy dispatcher init, unlike the
subclass path.** The subclass dispatcher self-registers on the first
`define-objc-method`, but `aw-block` errors on a null block if the dispatcher was
never registered. A dev `run.lisp`/`dump.lisp` must call
`(aw-init-block-dispatcher)` right after `aw-load-native-dylib`; the dumped image
gets it via the startup re-resolution pass. A block-bridge liveness gate in the
construction pre-flight makes a missing init fail before the VM trip.

### The one caveat (shared with racket/gerbil)

A **value-returning** callback whose result the main thread is *itself*
synchronously blocked awaiting would deadlock (the bounce is `dispatch_sync`). Void
completions are immune. And long synchronous work on the main thread starves
background callbacks, since the bounce drains only when the run loop turns — let the
run loop breathe.

### Async methods

A Swift-native `async` method's completion is delivered **on the main thread** by
`AsyncBridge.swift` (it marshals the payload on the cooperative pool, then hops via
`MainActor.run`), so the Lisp continuation runs main-side, GC-safe — the same
guarantee blocks get. (Async residual trampolines are emitted by a follow-up leaf;
the Lisp continuation seam binds to the bridge there.)

## 8. Subclassing — *deriving in Lisp = deriving in ObjC* (ADR-0034 §5)

`(define-objc-subclass canvas-view (ns:ns-view) …)` + one `define-objc-method` per
overridden selector synthesizes a **real ObjC subclass** (`objc_allocateClassPair`
+ IMP install + `objc_registerClassPair`) so the frameworks dispatch callbacks into
the user's CLOS methods. The IMP is **not** a per-selector codegen: per overridden
selector the dylib installs libobjc's `_objc_msgForward`, and overrides two NSObject
hooks once per synthesized class — `methodSignatureForSelector:` (pure Swift, builds
the `NSMethodSignature` reflectively from the baked encoding, pre-forwarding on the
calling thread) and `forwardInvocation:` (bounces to main, then calls the **one**
registered Lisp dispatcher with the `NSInvocation`). The ObjC runtime reifies
args/return per the signature, so this single reflective trampoline is
**ABI-correct for every selector shape** (structs, floats) with no per-selector
codegen — unlike gerbil's fixed-family `void*`-tail shims.

- **State in CLOS slots.** A synthesized class carries app state in `:initform`
  slots, mutated via `(setf (slot-value self 'x) …)` — the sbcl idiom for gerbil's
  closure variables. Pure UI helpers read with `slot-value` (not accessors) so they
  compile *before* the inner `define-objc-subclass` runs.
- **Override the ObjC super with `call-super`, NOT `call-next-method`.** A bound
  method sends `objc_msgSend` to *self*, which re-enters the forwarding IMP →
  infinite recursion. `call-super` (`objc_msgSendSuper`) reaches the inherited ObjC
  implementation; `call-next-method` is for Lisp-subclass-of-Lisp-subclass chains.
- **Synthesize inside a function** called from `-main`, not at top level — the ObjC
  class pair lives in libobjc, not the Lisp heap, so it does not survive a dump;
  re-synthesizing in the revived image is idempotent.

🟢 **2026-06-23 (drawing-canvas) — `drawRect:`'s NSRect arg IS delivered on sbcl
(divergence from gerbil).** The forwarding dispatcher reads the live `NSInvocation`
signature and recovers NSView's real `drawRect:` encoding (`v@:{CGRect=…}`) via
`class_getInstanceMethod`, so the override is `(self rect)` with `rect` a raw SAP
(the struct case of `aw-read-arg`, correctly sized via `NSGetSizeAndAlignment`).
Gerbil's generic trampoline *drops* the undeliverable struct, making its override
`(self)`-only.

🔴 **2026-06-23 (scenekit-viewer) — re-register the forwarding dispatcher at
revive.** The dispatcher SAP handed to the dylib is a foreign pointer into *this
image's* alien-callable trampolines — meaningless after a dump. The startup reset
hook now clears `*dispatcher-registered*` and re-registers (when the dylib is
loaded; a pure-ObjC app is a no-op). Same class of bug as the block dispatcher.

## 9. Swift-native trampoline residual (the §6d invariant, ADR-0038)

SBCL reaches ObjC directly, so `libAPIAnywareSbcl` carries only the **Swift-native
residual** — `objc_exposed == false` functions/constants plus the receiver-handle
method/init frontier — bound by typed `sb-alien` call sites. The residual is a
**deterministic function of the shared IR** (the §6d invariant: **51 fn + 7 const +
576 init + 554 method** trampolines, byte-identical across racket/chez/gerbil/sbcl)
— which is *why* the CL family converges: same analysis → same C ABI → same surface.
A framework with no residual loads `:load-residual nil` and needs no dylib (every
pure-ObjC GUI app on the ladder); only a residual-using framework loads
`:load-residual t` and the dylib.

- **Swift `String` parameters take a Lisp string, not an `ns:ns-string`.** A
  residual binding bridges the arg itself via `aw-swift-string-arg`. Passing `@"…"`
  (an instance) is a type error. *Object* args take wrapped instances; *String*
  args take Lisp strings.
- **Object returns wrap to their exact bound type** via the ADR-0034 MOP class
  registry (the gerbil ADR-0029 analogue) — not a raw pointer.
- **value-OPAQUE vs value-STRUCT-owner (ADR-0042).** A non-class Swift value
  (`IndexSet`, `CharacterSet`) can be driven as a raw `AwSbclValueBox` handle
  through hand-bound trampolines (init → method(box) → `aw-box-free`) — the
  value-opaque shape. Giving it a **CLOS class** `(defclass ns:<struct>
  (ns:value-struct) ())` + `make-instance` + receiver-specialized `defmethod` is
  the value-struct-owner shape (ADR-0042). The `ns:value-struct` root holds the box
  in a `ptr` slot — the *same slot name* `ns:ns-object` uses — so `aw-ptr` reads it
  unchanged, and its finalizer frees the box **directly off the finalizer thread**
  (a value box has no UI `dealloc` affinity, unlike a wrapped `id`). This is a
  **cross-target divergence**: gerbil keeps value structs procedural (Scheme has no
  `defun`/`defgeneric` symbol collision); SBCL's single `ns:` package forces the
  CLOS class.

🟢 **k38 (cross-cutting, FIXED in shared collection) — Swift-overlay class names
vs ObjC runtime names.** `NSScanner` reached the IR under its Swift-overlay name
`Scanner`, splitting one runtime class into two IR classes (ObjC methods on one,
Swift-native methods on the other) because the merge matches by `name`. The probe
worked around it with a `:ptr` hack. Fixed at the source: `extract-swift` keys an
ObjC-bridged class on its **ObjC runtime name recovered from the clang USR**
(`objc_runtime_class_name`), so the merge **unifies** the overlay with its clang
twin (~31 Foundation classes collapsed). Being in **shared collection**, the fix
applies to all targets. The probe now uses the natural path
`(make-instance 'ns:ns-scanner :init-with-string @"…")`. The GUI ladder was never
affected (NSButton/NSWindow keep their ObjC names). (See `CONTEXT.md` "ObjC
runtime class name".)

## 10. Self-contained distribution — `bundle-sbcl` (ADR-0041)

A sbcl `.app` is a `save-lisp-and-die :executable t` image (the SBCL runtime +
all bindings embedded), behind a thin Swift **stub** (`CFBundleExecutable`) that
`execv`s it. Self-containment is closed **at runtime, never by editing the image** —
the defining constraint of this target's bundler:

🔴 **2026-06-23 (hello-window 070) — a dumped image cannot be `install_name_tool`'d
or re-signed (ADR-0041, supersedes ADR-0038 §6 / design spec §6).**
`save-lisp-and-die` appends the Lisp core *after* the exe's `__LINKEDIT` segment, so
`install_name_tool` refuses it (*"the `__LINKEDIT` segment does not cover the end of
the file"*) and `codesign --force` rejects it under strict validation. But SBCL
**already ad-hoc signs** the dumped exe (so it launches on arm64), and that
signature **must be left intact**. So `bundle-sbcl` does **not** reuse
`bundle-gerbil`'s `install_name_tool` relocation — every path fix is a runtime
concern. The two gaps:

- **`libzstd` (a hard `LC_LOAD_DYLIB` by absolute Homebrew path — SBCL's
  core-compression dependency).** Vendored into `Contents/Frameworks/`; the stub
  sets `DYLD_FALLBACK_LIBRARY_PATH=<bundle>/Contents/Frameworks` so dyld resolves
  the absent absolute path **by leaf name**. The stub is ad-hoc/self-signed
  (non-hardened-runtime), so `DYLD_*` survives the `execv`.
- **`libAPIAnywareSbcl` (residual apps — `dlopen`ed, not a load command).**
  Re-opened via a relocated `@executable_path/..` `*shared-objects*` namestring (the
  `AW_NATIVE_DYLIB_RECORD_AS` hook on `aw-load-native-dylib`). SBCL auto-reopens
  `*shared-objects*` at image start, so the `aw_sbcl_*` symbols re-link for free.

```text
<App>.app/Contents/
  MacOS/<script>            ← thin Swift stub (sets DYLD_FALLBACK, execv's the image)
  Resources/<script>        ← the save-lisp-and-die image (keeps its own ad-hoc sig)
  Frameworks/
    libzstd.1.dylib         ← vendored; resolved by leaf name via DYLD_FALLBACK
    libAPIAnywareSbcl.dylib ← vendored (residual apps); reopened @executable_path/..
  Info.plist                ← CFBundleName = "<App>", com.linkuistics.* id
```

The startup re-resolution pass (§3) is what makes a *dumped GUI* image work: on
revive it re-`dlopen`s Foundation/AppKit, re-resolves `objc_msgSend` + every
`Class`/`SEL` from baked strings, re-masks the FP traps (§2), re-registers the
block/forwarding dispatchers (§7/§8), and re-runs framework-constant value forms
(below) — all on `sb-ext:*init-hooks*` before the toplevel.

🔴 **2026-06-23 (pdfkit-viewer) — a framework string constant is stale across a
dump; re-resolve it at startup.** `define-objc-constant` (e.g.
`PDFViewPageChangedNotification`, an observer's `name`) expanded to a
`defparameter` over a foreign read done **once at load**; that pointer is dead
after a dump (the NSString global is re-mapped in the revived process). Fix: the
macro also registers a re-evaluator thunk; the `:objc-constants` startup hook
re-runs every value form *after* frameworks are re-`dlopen`ed, guarded per-constant
(a now-unresolvable symbol keeps its stale value rather than killing the image).

## 11. Verification

Same bar as the other targets: CLI/`--load` smoke proves linking and load order,
**never** that the GUI works. Every sample app was VM-verified as a standalone
`save-lisp-and-die` `.app` in a **no-SBCL VM** via TestAnyware; reports +
screenshots under `test-results/<app>/`, per-app notes under `apps/<app>/
learnings.md`. VM provisioning is minimal — the standalone exe + `libzstd` (an
absolute Homebrew path the golden lacks) + the residual dylib for residual apps.
The runtime smoke suite (`lib/runtime/tests/`, run via
`run-integration-smoke.sh`) culminates in `smoke-integration.lisp`, which loads the
emitter's actual golden output on the runtime against live Foundation — the first
thing in the grove to compose the whole stack, and the gate that surfaced the
runtime integration fixes (see `lib/runtime/README.md`).

🟢 **The `@"…"` NSString reader macro is the app-author's string primitive
(hello-window contract gap, fixed).** An app written against the contract has no
portable way to make an `NSString` (setters take an *object*, not a Lisp string).
`@"text"` reads as `(aw-wrap (aw-make-nsstring "text") t)` — a lifetime-managed
`ns:ns-string` (CCL installs `@` globally too). It is installed **non-terminating**
into the readtable, so `@"…"` is the *only* valid `@` form: name a dynamic-string
helper anything but `@…` (a helper named `@str` is read as the macro applied to the
symbol `str`). `#/` (selector literal) is **deferred** — the surface is named
generics, not raw `objc_msgSend`, so no app needs it.

App-author VM-driving lessons worth carrying forward (TestAnyware, golden =
macos-tahoe): drive modal `NSOpenPanel`/`NSSavePanel` by keyboard (Cmd-Shift-G →
full path → Return → Return) since they are out-of-process and absent from the AX
tree; press **Return** for a panel's default button rather than clicking;
**triple-click** an `NSTextField` to select-all (Cmd-A is unreliable over VNC); use
`input drag` (button held) for strokes/continuous-action controls — a bare
`input move` releases the VNC button; and trust **AX `enabled` flags** over
screenshot rendering for navigation state. Place the absolute-path `libzstd` dep
with `sudo cp` (the golden's `/opt/homebrew` is root-owned).

## 12. When does the sbcl target shine?

Extends the chez/gerbil "when it shines" notes:

- **sbcl** — the **most idiomatic-CLOS** experience and the **richest object
  model** of any target: a real metaclass-backed class graph you can subclass and
  override (`(define-objc-subclass MyView (ns:ns-view) …)` *is* an ObjC subclass
  AppKit dispatches into), foreign ivars as CLOS slots, errors as conditions you
  `handler-case`, and — uniquely — **safe concurrent background compute** on
  `sb-thread` workers (gerbil/racket marshal everything through the main thread). A
  fast compiled FFI (`sb-alien` open-codes the `objc_msgSend` call site) with no
  generic-explosion tax. Ships as a self-contained dumped-image `.app`. It is the
  **first member of the CL family** — application source written against the
  `ns:`/CLOS contract is portable to future CL impls (CCL/AllegroCL/LispWorks),
  with each impl's binding mechanism private. Costs: a heavier `.app` (the embedded
  SBCL runtime), the FP-trap masking + startup re-resolution machinery a dumped
  image needs, and a bundler that closes self-containment at runtime because a
  dumped image cannot be edited. Best when you want **Cocoa as native CLOS** —
  metaclasses, generic functions, conditions, the MOP — in a fast, mature,
  genuinely-threaded Lisp.
