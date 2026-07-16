# TypeScript error model: `NSError**` as a type-visible `Result`, `NSException` as a thrown `ObjCError`, unified only on the throw channel

Decides the **Node `typescript`** target's error surface (Q5) — how the two Cocoa error
sources reach TS. **`NSError**` out-parameters surface as a discriminated-union
`Result<T> = { ok: true; value: T } | { ok: false; error }`** (the routine, recoverable
channel, made *type-visible*; the error arm is typed as the runtime root `NSObject` — §1
layering — over a handle to the real `NSError`); **`NSException` is thrown** as an `Error`
subclass (the disaster/boundary channel). The two channels are **split by Cocoa
semantics** — `NSError` is Cocoa's "routine, branch locally," `NSException` its
"disaster, don't recover" — and that split coincides exactly with the target project's TS
style (*`Result` for domain failures; throw only at system boundaries*). This is the chez
**ADR-0006** posture (`NSError**` in-band, does not raise) for the error channel and the
sbcl **ADR-0037** posture (a unified `Error` root) for the throw channel — the
TS-idiomatic synthesis of two Lisp precedents that deliberately diverged.

## Context — a split the precedents don't force and the type system rewards

Prior targets diverge on error surface, deliberately (ADR-0004/0005, one idiomatic style
per target): chez surfaces `NSError**` as in-band `(values result error)` and **does not
raise**; the CL family (sbcl ADR-0037, contract ADR-0033) surfaces *both* sources as
**signalled conditions** under one `ns:objc-error` root. So there is **no cross-target
error-*surface* invariant** to be consistent with — only the mechanism invariant every
target shares (key on the primary return, below). That frees Q5 to pick the surface that
fits TS.

Two forces pick it:

- **Cocoa's own semantic split.** `NSError**` is designed for routine, recoverable
  failure — Apple's guidance is that most callers branch on it locally; `NSException` is
  "typically only used for disaster recovery, not error handling" (research §B2, D6), and
  both prior arts found `NSException` surfacing **historically crash-prone**. The two
  sources are not one kind of thing.
- **The target's raison d'être is static types.** A `throw` is *invisible* to TS — there
  are no checked exceptions, so a throwing `foo(): NSData` gives zero static signal it is
  fallible. A `Result<NSData>` return makes fallibility **visible in the type** — the
  headline win this target exists to deliver (root `BRIEF.md`). Reserving the throw
  channel for the genuinely-exceptional `NSException` keeps the common recoverable path
  type-checked.

These coincide with the target project's TS coding style verbatim — *"Throw only at
system boundaries… Use a discriminated union or `Result` type for domain failures… Avoid
`try/catch` as control flow"* — so the split is idiomatic **and** invariant-respecting,
not a tension between them. The **captured steer** (Q2.3: lean to the cross-target/
analysis invariant over local idiom) still binds one sub-decision — the selector name
(§5) — but does not force the *surface*, because no surface invariant exists.

**chez's anti-throw argument does not apply here.** ADR-0006 rejected raising partly
because a raise through a `with-autorelease-pool` body needs `dynamic-wind` to drain — an
always-on cost. Under **ADR-0057 §8** the TS target injects **no per-entry pool** (uniform
+1 demotes the pool to a temporary-drain over AppKit's ambient runloop pool), so a throw
poisons no pool boundary. The throw channel is free to exist.

**Settled upstream (carried in):** objects — incl. `NSError` and `NSException` — are real
ES6 classes with their ObjC accessors (ADR-0055); selectors map by the injective `:`→`_`
rule with **no elision** (ADR-0055 §3); the JS event loop runs on AppKit's thread 0
(ADR-0056); lifetime is deterministic-dispose + FR backstop (ADR-0057).

## Decision

### 1. `NSError**` → a type-visible `Result` discriminated union

A selector whose trailing parameter is `NSError**` returns
`Result<T> = { ok: true; value: T } | { ok: false; error: NSObject }` — the plain
discriminated union (not a class), the target style's exact shape. On success `ok: true`
carries the wrapped primary return; on failure `ok: false` carries the bound **`NSError`**
wrapper (ADR-0055). The method **does not throw** on the `NSError` path; the failure is
in-band, `if (!r.ok)`-branchable, and the `ok` discriminant makes `r.value` unreachable on
the failure arm (the compiler forces the check — the type-visibility win the bare-tuple form
cannot give). Unlike sbcl — where a CL **condition** is a distinct type from the CLOS object
it carries (ADR-0037) — a JS value can *be* the object, so no special error *class* wraps it.

**Layering — the error arm's static type is the runtime root `NSObject`, not `NSError`.**
The `@apianyware/runtime` package owns only `NSObject`; `NSError`/`NSException` are ordinary
Foundation classes (ADR-0055) whose package `@apianyware/foundation` imports *from* the
runtime — so the runtime cannot *name* `NSError` in `Result` without a package cycle, and the
frozen `.d.ts` confirms consumers import only `Result` (never `NSError`) from the runtime. So
the error arm is typed `NSObject`. The **runtime value's handle references a real Foundation
`NSError`** — the discriminated-union fallibility win is unaffected — but because the frozen
emitter passes only the *primary* return's class to the `__result*` helpers and emits no
class-registration hook, the dumb runtime mints the error wrapper as a plain `NSObject`
(a valid, lifetime-managed handle to the native `NSError`), not a typed `NSError` instance.
Typed `.domain` / `.code` / `.userInfo` / `.localizedDescription()` access is a **future
Foundation class-registration refinement** — the runtime gaining a slot `@apianyware/foundation`
populates with the real `NSError` class — out of scope for the dumb runtime and not reachable
until Foundation is generated; until then a consumer re-wraps the handle through the Foundation
`NSError` class. (This is a static-type + wrapper-class concession the cross-package cycle
forces; it does not weaken the type-visible fallibility surface, which is `Result` either way.)

### 2. `NSException` → a thrown `Error` subclass

An `NSException` escaping a dispatched message is **thrown** as `NSExceptionError` — a
JS-native `Error` subclass wrapping the `NSException` object-model instance. `.message` is
the exception's reason (JS-native ergonomics: stack trace, `instanceof Error`);
`.exception` exposes the wrapped `NSException` for `.name` / `.userInfo`; `cause` is
preserved. It is thrown, not returned, because it is the disaster/boundary channel — not a
value a caller branches on.

### 3. The thrown-side hierarchy + `unwrap` escalation

The **throw** channel recovers sbcl's unified root (ADR-0037's `ns:objc-error`) — but only
over what is actually thrown:

- **`class ObjCError extends Error`** — the thrown-side root;
  `catch (e) { if (e instanceof ObjCError) … }` catches any thrown Cocoa failure. (It is
  deliberately **not** a superclass of `ObjectDisposedError` — a use-after-dispose is a
  programming fault, not a Cocoa error, and must not be swept up by an `ObjCError` handler.)
- **`class NSExceptionError extends ObjCError { readonly exception: NSObject }`** — §2,
  the `NSException` path (sbcl `ns:objc-exception` analogue). `.message` is the exception's
  `-reason`, captured native-side and carried in the `…_e` discriminant (the root-typed wrapper
  exposes no `-reason` accessor); `cause` flows through `ErrorOptions`.
- **`class NSErrorError extends ObjCError { readonly error: NSObject }`** — the
  **escalated** `NSError` path (sbcl `ns:cocoa-error` analogue): produced only when a
  caller chooses to *bubble* a `Result` failure as a throw.

  (`.exception` / `.error` are typed `NSObject` for the §1 layering reason — the runtime cannot
  name the Foundation classes; the handles reference the real `NSException` / `NSError`.)
- **`function unwrap<T>(r: Result<T>): T`** — returns `r.value`, or throws
  `new NSErrorError(r.error)`. It exists because the target style says *never throw a plain
  object* and *let errors bubble to a single handler per layer*: escalating a `Result` to a
  throw must go through a proper `Error` subclass, and `unwrap` is that bridge (the Rust
  `Result::unwrap` idiom, familiar to this target's author).

So `Result` is the default type-visible surface for `NSError**`; `unwrap` is the opt-in
path to the throw channel; and `ObjCError` unifies everything that reaches that channel —
the sbcl root, realized only where TS actually throws.

### 4. The Swift-`throws` bridge feeds the `Result` channel

A Swift-native `s:` method (reached via a trampoline, ADR-0025/0054) that is `throws`
surfaces its error across the flat C ABI as an `NSError**` (the sbcl **ADR-0029/0038
`ThrowsBridge`** analogue) and therefore returns a **`Result`**, identically to a native
`NSError**` selector. Swift `throws` is Swift's *routine, recoverable* error mechanism —
the same semantic class as `NSError`, not `NSException` — so it belongs on the `Result`
channel. One surface (`Result`) serves both the direct `NSError**` selector and the
Swift-`throws` trampoline.

### 5. Selector name: keep the injective `_error_`, drop only the out-parameter

The `error:` selector component **stays in the generated method name** under the injective
rule (ADR-0055 §3): `dataWithContentsOfFile:options:error:` →
`dataWithContentsOfFile_options_error_`. Only the **out-parameter is dropped from the JS
argument list** — the runtime allocates the `NSError*` and passes `&err`; the caller never
supplies it. The `_error_` in the name *is* the signal that the method returns a `Result`.
This is where the **captured steer** binds: eliding `error:` from the name (→
`dataWithContentsOfFile_options_`) would read marginally cleaner but breaks injectivity —
it can collide with a real `dataWithContentsOfFile:options:` — reintroducing exactly the
collision machinery ADR-0055 §3 banished. The analysis-level invariant wins over the
cosmetic gain, per the steer.

## Mechanics

- **Key on the primary return, not on the error being set.** ObjC signals failure by
  returning `nil`/`NO` **and** populating `NSError**`; the out-param may hold garbage on
  success. The generated dispatch builds `ok: false` **only** when the primary return
  indicates failure (`nil` for object returns, `NO`/`false` for `BOOL`), per Apple's "check
  the return value, not the error" rule — the mechanism invariant every target shares (sbcl
  ADR-0037, chez ADR-0006).
- **The `@catch` must be native.** An `NSException` cannot be allowed to unwind through the
  C ABI into V8 — it would corrupt the stack / crash the pump (ADR-0056). The native core
  **`@catch`es** it (the sbcl ADR-0037 mechanic) and returns a structured failure discriminant
  to the boundary; the **TS runtime** then constructs the `Result` or throws the
  `NSExceptionError`. The `@catch` itself lives in **a small ObjC unit the Swift `@_cdecl`
  entry calls** (`awexc.m`, realised by `error-catch-entries-k49`): Swift cannot `@catch` an
  ObjC exception, and one must never unwind *through a Swift frame* — so the `objc_msgSend`
  runs inside the ObjC `@try`/`@catch`, no Swift frame between the throw and the catch. Policy
  shape lives in TS, catch/detect mechanism in the native core — the same seam split as
  retain-on-wrap (ADR-0057 §4). The wire
  shape is the runtime's **`NativeErrorResult`** discriminant —
  `{ thrown: true; exception; reason } | { thrown: false; primary; error }` — defined in
  `@apianyware/runtime` because the runtime is built before the addon: the native `…_e` entry
  sets only the `thrown` axis (via `@catch`), and the TS `__result*` helper keys `ok`/`false`
  on the `primary` (nil / `NO`). This is the contract Step 4's `@_cdecl` `…_e` entries must
  produce.
- **A scalar primary's success value is not always a bare flag** (reconciled by
  `nonbool-fallible-scalar-result-k101`). The failure keying above is uniform — zero/`NO` on
  the primary means `ok:false` for every scalar shape — but a **BOOL** primary carries no
  further information beyond that flag (`__resultScalar`, `Result<boolean>`, success value
  hard-coded `true`), while a **non-BOOL integer scalar** (`writeJSONObject(_:toStream:
  options:error:) -> Int`, a byte count) has a nonzero success value that *is* data the
  caller wants, so it rides through unmodified (`__resultScalarValue`, `Result<number>`).
  The emitter picks between the two off the same ABI shape (`AbiType`) the entry name is
  already content-addressed by (`AbiType::Bool` vs. any other error-routable scalar code) —
  one predicate, no new IR fact.
- **The IR marker drives it.** `emit-typescript` detects the trailing `NSError**`
  parameter (the same IR marker chez ADR-0006 keys on) → emits a `Result`-returning body
  with the out-param dropped; a `throws` Swift entry routes through the `ThrowsBridge`. A
  mis-marked signature is an over-/under-reported failure, so the marker is an
  analysis-phase correctness invariant (the ADR-0039 "integrity is upstream" posture).
- **The error-out routability frontier** (realised at corpus scale by
  `outbound-dispatch-table-k58`). Because the fallible `objc_msgSend` runs inside
  `awexc.m`'s one generic `@try`/`@catch` (a `uintptr_t` args array + a `uintptr_t`
  primary — the price of "no Swift frame between throw and catch"), a fallible signature
  is routable only when every **visible param and the primary return travel in integer
  registers**: object/SEL pointers, `BOOL`, and integer scalars (bit-pattern packed), with
  visible argc bounded by the shim's dispatch switch (`AW_ERR_MAX_ARGS` = 8, mirrored by
  `native_dispatch::ERROR_OUT_MAX_ARGS` — the two constants must stay equal). A fallible
  method carrying a float/double/struct/C-string anywhere in that signature, a `void`
  primary (cannot key failure), or more visible args **defers, recorded** — the emitter
  admission (`is_supported_method_ctx`) and the entry table share the one decision
  (`NativeSig::error_out_from_method`), so no call site can name an `…_e` entry the shim
  cannot serve (154 such deferrals on the 2026-07 corpus, counted in the generate log). A
  future leaf may widen the frontier with typed generated `@try` wrappers; that widens
  `error_out_from_method` and the table together.

## Considered options

- **Throw both sources under one root (sbcl ADR-0037, copied).** Rejected: turns routine
  recoverable `NSError**` failures into stack-unwinding — the opposite of the target style's
  *avoid try/catch as control flow* — and, fatally for *this* target, makes fallibility
  **invisible** to the type system (no checked exceptions). sbcl chose it because signalled
  conditions are the CL family's normative idiom (ADR-0033); TS's idiom and its type-surface
  raison d'être both point the other way. Recorded as the cross-target contrast.
- **Bare tuple `[T | null, NSError | null]` (PyObjC/chez literal).** Rejected: a bare tuple
  cannot express "exactly one element is non-null," so the compiler cannot force the check
  (`r.value!` needs a non-null assertion) — the discriminated-union `Result` strictly
  dominates it and is the shape the target style names explicitly. chez chose
  multiple-values because that is idiomatic Scheme; TS has no first-class multiple return,
  so the rationale does not transfer.
- **Elide `error:` from the method name (JSExport/NativeScript).** Rejected §5 —
  non-injective, reintroduces the collision machinery ADR-0055 §3 removed; the captured
  steer favours the invariant.
- **A single unified channel of any kind.** Rejected: the two Cocoa sources are
  semantically different kinds of failure; collapsing them (whether all-throw or all-Result)
  loses the distinction Cocoa, the type system, and the target style all draw.

## Consequences

- **`emit-typescript`** emits, per fallible selector, a `Result`-returning body (out-param
  dropped, name keeps `_error_`) with the native key-on-primary-return + `@catch` glue; and
  exports the error types into the `.d.ts` from the same IR pass (ADR-0055 one-artifact
  rule): `Result<T>`, `ObjCError`, `NSExceptionError`, `NSErrorError`, and `unwrap`.
  `NSError` / `NSException` are already object-model classes. This satisfies the leaf's
  done-when: **the error types appear in the generated `.d.ts`.**
- **The runtime library** owns the `Result` constructors, the `ObjCError` hierarchy,
  `unwrap`, `__cfstr`, the `NativeErrorResult` wire type, and the boundary code that reads the
  native failure discriminant to build a `Result` or throw. **The native core** owns the
  `@catch` + primary-return detection, Swift-native (ADR-0010).
- **Deferred: typed error/exception wrappers.** Because the error arm is typed `NSObject` and
  the dumb runtime mints the wrapper as `NSObject` (§1 layering), the `.domain`/`.userInfo`/…
  accessors are not statically reachable. A later refinement — a runtime class-registration
  slot `@apianyware/foundation` populates with the real `NSError`/`NSException` classes — would
  make `__result*` mint typed wrappers without the runtime ever *naming* the Foundation
  classes. It is deferred (the frozen emitter passes only the primary class and emits no
  registration; Foundation is not yet generated), not foreclosed.
- **Hard to reverse:** every fallible generated method's return type, the thrown hierarchy,
  and the `_error_`-retaining name are baked into the emitter, every generated module, every
  sample app's source, and every `.d.ts` consumer — a cross-binding + cross-app rewrite to
  change (the same irreversibility chez ADR-0006 / sbcl ADR-0037 call out).
- **Boundaries to sibling decisions.** The object graph incl. `NSError`/`NSException` and
  the injective name rule are ADR-0055; lifetime is ADR-0057 (the `NSError`/`NSException`
  wrappers dispose like any handle; a thrown `NSExceptionError` holding a wrapper does not
  leak — the wrapper's own +1 and FR backstop apply); threading /
  `@catch`-must-not-cross-the-pump is ADR-0056; the Swift-`throws` trampoline is
  ADR-0025/0054. Callback/delegate exceptions crossing the bg→main bounce are settled by
  **ADR-0059** (`ts-callbacks-design-k9`) — a JS exception thrown inside an inbound callback
  is caught at the trampoline boundary (the mirror of this ADR's native-`@catch`; it must not
  unwind the C ABI into the runloop, research D5/§B2), reported via `onCallbackError`, then
  coerced to a typed default; no `NSException` re-raise by default. Built on this hierarchy.

See ADR-0006 (chez `NSError**`-in-band contrast, the `values` posture this echoes as
`Result`), ADR-0037 (sbcl unified condition hierarchy — the `ObjCError` root this echoes on
the throw channel — and the key-on-primary-return + native-`@catch` mechanics),
ADR-0029/0038 (the `ThrowsBridge` this reuses for Swift `throws`), ADR-0033 (the CL
contract's signalled-condition choice, the reason sbcl differs), ADR-0055 (objects incl.
`NSError`/`NSException`; the injective §3 name rule §5 honours), ADR-0057 §8 (no per-entry
pool — why the throw channel is free), ADR-0056 (thread-0 pump the `@catch` protects),
ADR-0004/0005 (one idiomatic style per target), and
`targets/typescript/docs/research/2026-07-05-js-objc-bridge-prior-art.md` (§Synthesis D6,
§B2 PyObjC) for the prior-art evidence.
