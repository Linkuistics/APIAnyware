# 020-ffi-dispatch-spike

**Kind:** work (spike)

## Goal

A throwaway-grade but rigorously-measured spike that settles the two deferred
design forks (Q1 dispatch model, Q2 object model) and de-risks distribution,
with Gambit numbers rather than analogy to Chez. Output is evidence under
`docs/research/<date>-gerbil-ffi-dispatch-spike/` (FINDINGS.md + harness +
screenshots), modelled on `docs/research/2026-06-02-chez-dispatch-spike/`.

## Context

Gerbil is a **compiled-FFI target** (Scheme → Gambit → C → native). ADR-0015
found Chez's typed `foreign-procedure` already sits at the native dispatch floor,
so a native shim only adds a hop — and it explicitly flags that this "may apply to
future compiled-FFI targets" but is "target-specific." This spike is exactly that
verification for Gerbil. See the 010-plan running log for the full Q1/Q2/Q3
rationale; `CONTEXT.md` for the Gerbil toolchain vocabulary.

**Prerequisite — Gerbil is NOT installed on this machine** (`gerbil`/`gxc` absent).
Step zero: install/build Gerbil 0.18.x. Note the wrinkle: `static-exe` needs a
Gerbil configured `--enable-shared=no`, which a stock `brew install gerbil-scheme`
may not provide — be ready to build from source. Record exactly what was needed
(it becomes the toolchain-provisioning note for `knowledge/targets/gerbil.md`).

## Done when

The spike has produced measured answers (FINDINGS.md) to all five, each with a
recommendation back to Q1/Q2/distribution:

1. **FFI reachability** — a Gerbil program using `begin-ffi`/`define-c-lambda`
   calls `objc_getClass`, `sel_registerName`, `objc_msgSend` and round-trips a
   string (e.g. `+[NSString stringWithUTF8String:]` → `-[NSString UTF8String]`).
   Document the `:std/foreign` shape that works.
2. **Dispatch cost (settles Q1)** — ns/call for a direct typed `define-c-lambda`
   msgSend vs a native-shim call, on a simple shape AND a CGRect struct-return.
   Compare to ADR-0015's chez floor (~6 ns / ~10.5 ns). Recommend chez-model
   (ADR-0015) vs racket-model (ADR-0013) on the basis of these numbers.
3. **OO-layering tax (validates the Q2 direction)** — the leading design is to
   LAYER a native-OO veneer (`defmethod`/generic functions) over a procedural core
   (single handle-struct + per-class procedures). Measure the **veneer tax**:
   direct procedure call (the base layer) vs `defmethod`-over-procedure dispatch
   (the veneer), ns/call on compiled Gerbil. Also measure the two veneer shapes so
   030 can choose: generic functions specialized on the *single* handle struct
   (method-name resolution only) vs a `defclass` hierarchy mirroring the ObjC
   class graph. Output: a price tag for the opt-in OO layer, not a go/no-go gate —
   the procedural core is the foundation regardless.
4. **Struct-by-value returns** — CGRect (and an NSRect-shaped struct) crossing the
   FFI by value via Gerbil/Gambit `c-struct`/`(struct ...)`. Confirm correctness;
   note the idiomatic `c-struct` form.
5. **Static-exe + framework link (de-risks distribution)** — ◑ RE-HOMED. The
   `--enable-shared=no` source toolchain was built (`build-gerbil-static.sh` →
   `~/.local/gerbil-0.18.2-static`); the capability is confirmed by upstream docs
   + our `--disable-shared` config + the working dynamic framework-link path
   (items 1–4). The on-machine `gxc -static -exe … -framework AppKit` launchable-
   binary verification is moved to the distribution/bundler leaf 030 will create
   (it is the same ADR-0009 bundler work and needs this exact toolchain). See
   FINDINGS §5.
6. **Compile-time DX (NEW — second dispatch axis; user steer).** Measure
   `gxc`/`gsc`/`cc` wall-clock as a function of generated-FFI *volume*: compile
   N×{10,100,1000} typed `define-c-lambda` msgSend wrappers (the per-method chez
   ADR-0015 shape) and chart compile time vs N; contrast with the fixed cost of
   calling a precompiled native lib through a thin seam (the racket ADR-0013
   shape). Rationale: ADR-0015 weighed ONLY runtime ns/call; for Gerbil
   (Scheme→Gambit→C→cc) generated-source volume drives compile time, and Chez
   already proved long compiles are a DX PITA. This axis may favour a FATTER
   native lib for Gerbil even though direct dispatch is runtime-optimal — making
   Gerbil legitimately diverge from Chez (ADR-0011 licenses it). Output: a
   runtime-vs-compile-time trade-off table for 030.

## Notes

- Throwaway code is fine; the FINDINGS.md + the harness are the durable artifacts.
- A drawn NSWindow at the end is a nice-to-have proof-of-life, not the bar — the
  bar is the five measured answers. (Full VM-verified hello-window is a later
  build leaf, per the guide's app ladder.)
- Capture toolchain-provisioning steps verbatim for `knowledge/targets/gerbil.md`.
- ADR-0011 (hermetic isolation): do NOT reach into emit-chez/chez runtime for
  shared code; borrow *patterns* only.
