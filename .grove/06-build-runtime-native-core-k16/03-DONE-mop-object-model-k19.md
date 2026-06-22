# mop-object-model-k19

**Kind:** work

## Goal

Build the **headline**: ObjC's class system projected into CLOS through `sb-mop`
(ADR-0034 §1–4). Not a single wrapper (gerbil pre-rejected as vacuous), not a
manifest graph without the MOP (gerbil's shape) — a real metaobject projection. All
required hooks are **verified to exist + specialize first-hand** (spike 1, SBCL
2.6.5/arm64) — this leaf wires the verified mechanism, it does not re-spike.

- **`objc-class` metaclass** (ADR-0034 §1): a `standard-class` subclass; its
  `validate-superclass` installs cleanly (mixed `objc-class`/`standard-class` supers).
  Lift from spike `1-amop-conformance.lisp`.
- **`ns:ns-object`** — the runtime-owned root carrying the foreign `ptr` slot (the
  ObjC `id`). Never emitted by 040; every emitted `defclass` chains up to it.
- **`register-objc-class`** `(register-objc-class 'ns:<cls> "<ObjCName>" "<ObjCSuper>")`
  — populate the `aw-wrap` class registry (020's stub) + the Class string table 070's
  re-resolution pass consumes. Empty super string = independent ObjC root / synthesized
  bare node.
- **Dispatch (D6, ADR-0034 §2):** the emitted per-selector `defgeneric` (in `ns:`) +
  `defmethod` per (class × selector) **specialized on the receiver** just work over
  this metaclass — 030 confirms the emitted bodies dispatch + `call-next-method`
  through the reified chain. **No** generics sharding / special flags / parallel-compile
  (§3 closed the explosion risk — spike `2-compile-cost.lisp`: 6.5k generics + 40k
  methods cold-compiled in 8.4 s).
- **Slots / ivars (ADR-0034 §4):** `slot-value-using-class` over a custom **foreign
  slot-definition class** keyed off `:offset` in the slot spec
  (`(<name> :offset <BITS> :ctype <:kw>)`); `direct-slot-definition-class` selects it;
  `slot-value-using-class` `ecase`s on `:ctype` (`:int`/`:double`/…). Bit-offset ÷ 8
  (spike 3). **Opt-in fast path** over the always-safe accessor-selector default;
  currently the IR surfaces no ivar layout so the table is empty — wire the mechanism +
  the empty-table path. Open item §8 (SDK-drift: re-resolve via `ivar_getOffset` at
  startup or pin the SDK) — note the choice; the accessor path is the safe default.
  Lift from spike `3-slot-mechanism.lisp`.
- **`make-instance` → `allocate-instance` (specialized on `objc-class`) → `alloc`/`init`**
  (ADR-0034 §5; no init initargs ⇒ alloc-only). **`register-objc-init`**
  `(register-objc-init 'ns:<cls> "<initSelector>" (:kw …))` consumption — the
  alloc/init initarg mapping (one keyword per selector component); `init` itself is the
  bare alloc/init default. 030 owns the `make-instance`/`allocate-instance`/
  `initialize-instance` wiring; 040 only bakes the table.

## Context

Node BRIEF (METACLASS + ROOT, DISPATCH BODY, FOREIGN IVAR SLOT SPECS, the
`register-objc-class`/`register-objc-init` baked tables). Design spec §2 + ADR-0034
§1–6. Spikes (first-hand verified mechanism — **lift, don't re-derive**):
`2026-06-20-sbcl-mop-spike/{1-amop-conformance,2-compile-cost,3-slot-mechanism}.lisp`
+ the spike README. Reference: `generation/targets/gerbil/lib/runtime/objc.ss` (the
class-graph root + `wrap`/`->ptr` + constructor registry — but gerbil has **no**
metaclass; sbcl goes further). Needs 020's seam (`aw-wrap`/`aw-class`/`aw-sel`/dispatch).

## Done when

- The metaclass + root load; `validate-superclass` accepts a bound `defclass`.
- Against a **real** emitted framework binding (e.g. a Foundation slice): instantiate
  via `make-instance` (alloc/init), send several selectors via the emitted generics
  (incl. one through `call-next-method` up the chain), read a value back. Class methods
  (receiver-specialized on the class metaobject) dispatch.
- The foreign-slot mechanism compiles + the empty-table path is inert (no ivar specs
  in the IR yet); a hand-constructed `:offset`/`:ctype` slot reads correctly (spike-3
  shape) to prove the path.

## Notes

- `aw-wrap` resolving the *exact* bound class (not a super) is load-bearing for object
  returns — verify a covariant return (`-self`, `+alloc`) wraps to the right class.
- Subclass **synthesis** is 040; 030 is the bound-class projection + instantiation only.
