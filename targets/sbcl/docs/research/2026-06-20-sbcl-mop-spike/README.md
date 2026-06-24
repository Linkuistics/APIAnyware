# SBCL MOP-projection spikes — first-hand de-risking for ADR-0034

Design-phase spikes that de-risk the five mechanisms the `sbcl` object model
(ADR-0034) depends on, run against **SBCL 2.6.5 (arm64, macOS)** and the **live
ObjC runtime**. The grove leaf `030-design/020-object-model` mandated verifying
these first-hand rather than assuming them — the prior-art survey
(`targets/_shared/docs/research/cl-cocoa-bridges-across-the-family.md`) is CCL-centric and left
them un-de-risked (its §6 gaps), and §5.1 actively *refuted* a plausible
assumption (that CCL routes ivars through `slot-value-using-class`).

Run all: `sbcl --version` then each script below. Nothing here is part of the
build; it is reproducible evidence for the ADR.

## What each spike proves

| Script | Question | Result |
|---|---|---|
| `1-amop-conformance.lisp` | Do the `sb-mop` hooks the projection needs exist as specializable GFs? | **Yes** — `validate-superclass`, `compute-effective-slot-definition`, `slot-value-using-class`, `direct/effective-slot-definition-class`, `compute-slots`, `class-slots`, `finalize-inheritance`, `allocate-instance`, `ensure-class-using-class` are all GFs; `objc-class` subclasses `standard-class` cleanly. (`ensure-class`, `standard-instance-access` are plain functions — expected.) |
| `gen-binding.py` + `2-compile-cost.lisp` | Does gerbil's ADR-0023 generic-function explosion reproduce in SBCL? | **No.** 6,500 `defgeneric` + 40,000 `defmethod` over 2,000 metaclass-backed classes: **8.4 s cold, single-threaded, 658 MB peak** (`defgeneric` 0.20 s; `defmethod` 7.71 s; load 0.43 s). Gerbil's equivalent was ~5h, fixed to 8.4 min only by sharding+no-`-O`+parallelism. A worst-case single generic with 3,000 methods: 4.06 s (no per-GF superlinearity). |
| `3-slot-mechanism.lisp` | Can ObjC ivars be projected as foreign slots reachable via `slot-value`? (§5.1 refuted the assumed hook for CCL) | **Yes for SBCL** — `slot-value-using-class` + a custom foreign slot-definition class carrying a baked bit-offset, discriminating foreign ivars from plain-Lisp slots. Read/write proven at offsets 0 and 64 against malloc'd memory; the plain `ptr` slot falls through to standard storage. |
| `4-subclass-synthesis.lisp` | Is `allocate-instance` the `make-instance` hook, and can SBCL drive `objc_allocateClassPair`? | **Yes** — `make-instance` fires `allocate-instance` specialized on `objc-class`; real `objc_allocateClassPair` + `objc_registerClassPair` from `sb-alien` synthesizes a class the live runtime then resolves by name with the correct superclass. |
| `5-startup-re-resolution.sh` | Does `save-lisp-and-die` keep foreign `Class`/`SEL` pointers? Is a re-resolution pass mandatory? | **Pointers are lost; the pass is mandatory & sufficient.** A revived image sees `objc_getClass "NSString"` → NULL until Foundation is re-`dlopen`ed (while `NSObject`, in always-mapped libobjc, survives). Baked class-name and selector *strings* survive the dump; re-resolution after re-`dlopen` yields valid pointers. This is the CCL-`revive-objc-classes` pattern, confirmed for SBCL. |

## Why the cost result differs from gerbil

Gerbil's blow-up lived in **Gambit's `:std/generic` macro library** — each
`defgeneric` macro-expanded into a large unit that `gsc -target C` then choked on
superlinearly in unit size. SBCL's `defgeneric`/`defmethod` are **native CLOS
special operators** the compiler lowers directly: no macro explosion, no giant
intermediate C translation unit. Same shared IR ⇒ same selector count, but the
cross-target *cost* does not carry, because it was a property of the host
compiler's macro layer, not of the IR. Hence the sbcl emitter needs **no**
generics-sharding / no-`-O` / parallel-compile machinery.
