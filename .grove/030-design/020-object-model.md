# 020-object-model

**Kind:** planning

## Goal

Settle the **MOP realization** — how ObjC's class system projects into CLOS via
SBCL's Metaobject Protocol — and raise the object-model + dispatch ADR(s). This is
the headline of the whole target (D3).

## Context

Read: `done/010-plan` (D3, D3a, the static-emit-vs-dynamic-synthesis
reconciliation), `done/020-…` research **§B1–B5, §5.1, §6.1, §7.1/§7.3/§7.4**,
CONTEXT.md *MOP projection / `objc-class` metaclass* (now records **D6** dispatch),
gerbil object-model precedent **ADR-0020** (manifest class graph + dual dispatch;
the "vacuous receiver-only dispatch" reasoning) and **ADR-0023** (the generics
compile-cost blow-up + sharding fix). ADR-0010 (static emit from shared IR).

## Decisions to carry in (settled upstream — do not re-litigate)

- **Dispatch = D6:** per-selector `defgeneric`/`defmethod` **specialized on the
  receiver** over the real metaclass-backed class graph (CLOS generic dispatch +
  method combination + `call-next-method`; *not* multiple-argument dispatch).
- **Static emit + runtime MOP:** the **emitter statically generates the CLOS class
  graph** (`defclass … :metaclass objc-class` + per-selector generics); the **MOP
  machinery lives in the runtime**. Diverges from CCL's dynamic synthesis.

## What to design first-hand (un-de-risked by 020)

- **SBCL AMOP conformance (020 §6.1):** verify `sb-mop` actually supports the
  hooks the projection needs — `validate-superclass`, `allocate-instance`,
  `compute-effective-slot-definition`, `slot-value-using-class`, `ensure-class`.
  Confirm against `sb-mop`, do **not** assume.
- **Slot/ivar mechanism (020 §5.1 — refuted assumption):** the named hook
  (`slot-value-using-class` + `compute-foreign-slot-accessors`) is **not**
  confirmed even for CCL. Re-derive the SBCL mechanism first-hand — likely foreign
  direct slots with baked bit-offsets reachable via `slot-value` (020 §7.1), but
  prove it. Note SDK-drift risk on baked offsets.
- **`make-instance` → alloc/init; subclassing** (020 §B4): CLOS
  `make-instance` → `allocate-instance` → `objc_allocateClassPair` for Lisp
  subclasses; `validate-superclass`; the no-init-initargs alloc-only nuance.
- **Generic-function explosion / compile cost (D6 carry-forward risk):** a
  `defgeneric`+`defmethod` per (selector × class) across all frameworks may
  reproduce gerbil's ADR-0023 blow-up. Design the mitigation (sharding? lazy
  generic creation? a `defmethod`-per-class-batched scheme?) here.
- **Static-vs-dynamic + startup re-resolution (020 §B5):** a dumped image carries
  baked class metadata but **stale foreign `Class`/`SEL` pointers**; design the
  CCL-`revive-objc-classes`-equivalent **startup re-resolution pass** (re-resolve
  every `Class`/`SEL` from its baked string identity). Load-bearing for `070`
  `save-lisp-and-die`; note in `040-trampoline-layer` how much of this burden the
  Swift library's own load-time setup absorbs.

## Done when

- Each item above settled with a recorded decision (AMOP-conformance result,
  slot mechanism, dispatch realization + compile-cost mitigation, subclass
  synthesis, startup re-resolution).
- Object-model + dispatch ADR(s) raised.
- Feeds the SBCL target design spec (assembled in `040`).

## Notes

- Grow a further child leaf only if the compile-cost mitigation or the
  static-emit pass turns out to need its own focused session.
