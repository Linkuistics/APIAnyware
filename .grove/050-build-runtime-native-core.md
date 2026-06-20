# 050-build-runtime-native-core

**Kind:** work

## Goal

Build the SBCL runtime + native core (guide Steps 3–4). **Design fully settled in
030-design — read the SBCL target design spec
(`generation/targets/sbcl/docs/design/2026-06-20-sbcl-target-design.md`) + ADRs
0034–0038 first; this leaf implements them, it does not re-decide.**

- the `sb-alien` FFI seam (compiled FFI, ADR-0015);
- the **MOP machinery** (ADR-0034): the `objc-class` metaclass + the verified
  `sb-mop` hooks (`slot-value-using-class` over baked foreign-offset slots /
  `allocate-instance` / dispatch); per-selector receiver-specialized generics
  (**no** gerbil-style sharding — ADR-0034 §3 closed that risk); `make-instance`
  → `alloc`/`init`;
- **ObjC subclass synthesis** (ADR-0034 §5): `objc_allocateClassPair` /
  `objc_registerClassPair` driven Lisp-side via `sb-alien`; per-selector IMP
  install via the **dylib's native bounce-shim** (ADR-0038 §4) — a raw
  `define-alien-callable` IMP is forbidden (it would run Lisp on a foreign thread);
- **lifetime** (ADR-0036): `sb-ext:finalize` + **main-thread release queue** +
  entry-point `with-autorelease-pool` (finalizers run off-main → enqueue raw `id`,
  drain `release` on main);
- **threading/callbacks** (ADR-0035): foreign-thread callbacks **bounce to the
  main thread** (the chez `Sactivate_thread` activation model is **rejected** —
  spiked, crashed 5/5); `sb-thread` is for SBCL-**native** background compute only,
  *not* a bounce substitute;
- **conditions** (ADR-0037): the `ns:objc-error` / `ns:cocoa-error` /
  `ns:objc-exception` hierarchy + the single `signal-cocoa-error` signaller (keyed
  on the primary return, serving both `NSError**` and the `ThrowsBridge`);
- the **startup re-resolution pass** (ADR-0034 §6): re-`dlopen` direct-msgSend
  frameworks + re-resolve every `Class`/`SEL` from baked string identity, composing
  with the dylib's own auto-reopen (ADR-0038 §5 — the dylib re-links its own symbols
  + its linked framework subset for free; this Lisp pass owns the rest);
- **`libAPIAnywareSbcl` — the SBCL target's SOLE native unit** (ADR-0038): one
  SwiftPM dynamic lib hosting `Generated/Trampolines.swift` + `OpaqueHandle` +
  `ThrowsBridge` + `AsyncBridge` + `CallbackBounce` + `SubclassSynth` (broader than
  gerbil's trampoline-only dylib because SBCL has no ObjC-in-`gsc` home; still does
  *not* absorb the MOP object model). Includes the per-signature bounce-shim IMP
  mechanism (generated-per-selector vs `NSInvocation` — choose here, design spec §8).

## Context

Design fixed in **030-design**: the SBCL target design spec (synthesis) + the
complete-API model ADRs 0025/0026 + the CL-family contract (ADR-0033 / contract
spec) + the sibling ADRs 0034 (object model) / 0035 (bounce) / 0036 (lifetime) /
0037 (conditions) / 0038 (trampoline lower layer). Read those. Peers: racket/chez/
gerbil Swift trampoline dylibs — but note sbcl's dylib is **broader** (sole native
unit, ADR-0038), and sbcl wraps `id` returns to bound type via the ADR-0034 MOP
registry (the gerbil ADR-0029 §2 analogue). ObjC is reached directly via `sb-alien`
`objc_msgSend` (trampoline elided); only the Swift-native residual goes through the
dylib.

## Done when

- Runtime loads in SBCL; the MOP object model works end-to-end (instantiate,
  dispatch, subclass, callback) against a real framework; a background-release
  smoke (ADR-0036) and the §6d-invariant trampoline residual resolve.

## Notes

- Decomposes (MOP, bridges, lifetime, threading, dylib) when picked.
