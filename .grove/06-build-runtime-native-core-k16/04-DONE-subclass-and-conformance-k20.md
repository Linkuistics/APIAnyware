# subclass-and-conformance-k20

**Kind:** work

## Goal

Build **ObjC subclass synthesis + protocol conformance** (ADR-0034 §5) — deriving
in CLOS = deriving in ObjC. The contract surface (§3.4/§3.5) the app layer + the
delegate/callback world depend on. "The runtime drives conformance": 040 bakes only
names, the runtime reads ABI signatures from the **live** protocol.

- **`define-objc-subclass`** (contract §3.4) → a `defclass` with `:metaclass
  objc-class` whose effective-class hook synthesizes a real ObjC subclass:
  `objc_allocateClassPair(super, name, 0)` → install IMPs → `objc_registerClassPair`.
  Driven Lisp-side via `sb-alien`. Lift from spike `4-subclass-synthesis.lisp` (the
  Lisp driver) — the IMP **builder** half lives in 010's `SubclassSynth.swift`.
- **`define-objc-method`** (contract §3.5) → a `defmethod` on the synthesized subclass
  that an installed IMP routes the ObjC call into. **Per-selector IMP install via the
  dylib's native bounce-shim** (ADR-0038 §4) — a raw `define-alien-callable` IMP is
  **forbidden** (it would run Lisp on a foreign thread, the ADR-0035 crash). The IMP
  is the 010-chosen mechanism (generated-per-selector vs `NSInvocation`); 040 calls
  `class_addMethod` with the shim + routes it to the Lisp method via the dispatch table.
- **Protocol conformance** — consume `register-objc-protocol`
  `(register-objc-protocol "<ObjCName>" :required ((<sel> ns:<gen>) …) :optional (…))`
  (040/030 emitter bakes names only). The runtime: `objc_getProtocol("<ObjCName>")` +
  `class_addProtocol` + per-selector IMP install, reading each method's ObjC **type
  encoding from the live protocol** (`protocol_getMethodDescription`) at conformance
  time. The required/optional split mirrors ObjC. Delegate-only `defgeneric`s (emitted
  by `emit_protocol`) are specialized by a Lisp subclass via `define-objc-method`.
- **Dispatch table** keyed by `(synthesized-class . selector) → Lisp closure` the shim
  consults (the gerbil `native-core.ss` IMP-table analogue, but the shim bounces to
  main per ADR-0035 — the foreign-thread safety is 060's wiring; 040 owns the table +
  the install).

## Context

Node BRIEF (the `register-objc-protocol` block + "ObjC subclass synthesis"). Design
spec §2 (subclass via the contract macro) + ADR-0034 §5 + ADR-0038 §4 (bounce-shim).
Contract spec §3.4/§3.5. Spike: `2026-06-20-sbcl-mop-spike/4-subclass-synthesis.lisp`
(verified `objc_allocateClassPair`/`class_addMethod`/`objc_registerClassPair`).
Reference: `generation/targets/gerbil/lib/runtime/subclass.ss` (transparent extensible
subclassing — the shadowing forms + the class-pair plumbing, ADR-0020) +
`native-core.ss` (the IMP dispatch tables). Needs 010 (the bounce-shim IMP) + 030 (the
metaclass + the bound super to derive from).

## Done when

- `define-objc-subclass` of a bound class (e.g. an `NSObject`/`NSView` subclass) +
  `define-objc-method` overriding a selector synthesizes a real ObjC class
  (`objc_getClass` finds it; `class_getSuperclass` is right); instantiating it +
  sending the overridden selector runs the **Lisp** method.
- A framework calls back into an installed IMP (e.g. set the instance as a delegate /
  target and trigger the selector) and the Lisp override runs — **on the main thread**
  (the 010 shim bounces; full foreign-thread wiring is 060, but the main-thread path
  is exercised here).
- `class_addProtocol` conformance: a synthesized class conforms to a real protocol,
  `class_conformsToProtocol` is true, the `protocol_getMethodDescription`-derived
  encoding installs correctly.

## Notes

- The **forbidden** path (raw `define-alien-callable` IMP) is a real foot-gun — leave
  an inline comment at the IMP-install site pointing at ADR-0035 so no later session
  "simplifies" the bounce away.
- `setDelegate:`/`target` do **not** retain — the app must keep the synthesized
  instance reachable (the gerbil ADR-0019 lifetime note; 050 owns the lifetime model).
