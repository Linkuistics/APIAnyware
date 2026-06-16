# 030-value-struct-handle-params

**Kind:** work

## Goal

Wire the **17** functions still recorded `deferred_nonbridged_struct_param` after
040/040/010 — those whose deferred param is a genuine **nameable Swift value
struct** (`MLTensor`, `MLUntypedColumn`, `MLDataTable`, `ProcessCodeRequirement`,
…) — so the `@_cdecl` body unboxes the named type
(`awRacketUnbox(a!, as: T.self)`) and the racket side passes through the opaque
handle it already holds. This is the literal "unbox a named-type param" path the
parent node named; 040/040/010 recovered the larger CGFloat scalar-typedef subset
(44) and proved the *spec §5a kick-back* this leaf executes.

## Context

- **Why split from 010** (spec §5a, `docs/specs/2026-06-15-racket-trampoline.md`):
  the 69-function bucket was 44 CGFloat-only (a scalar misclassification, already
  recovered), 6 closure params (`deferred_closure_param`), 2 `id`/`Any`
  (`deferred_unnameable_param`), and **17 genuine value-struct/CF/reference/
  bridged-collection params** — this leaf's target.
- The residual structs are **opaque framework objects** with no public scalar
  fields, so this is **handle pass-through** (`awRacketUnbox(a!, as: T.self)`),
  **not** the per-field `aw_racket_box_<T>_<field>` accessors the spec's first
  draft imagined. Accessors reopen only if a transparent value-struct consumer
  appears (spec §5a).

## Design forks to resolve (grill or decide in-leaf)

1. **Soundness — value vs reference.** `awRacketUnbox(_, as: T.self)` is sound only
   when racket's handle is an `AwValueBox` (a Swift value struct). The IR already
   distinguishes them: a **value struct** is retained in `Framework.structs`; a
   CF/ObjC **reference** type (`SecCode`, `NSDecimalNumber`) is in `classes` or
   absent. Gate `BoxedHandle` on "param type name ∈ the IR's struct-name set";
   reference-type params stay deferred (their own class-handle path is separate).
2. **Pass/emitter agreement (the real plumbing).** Entry names are content-addressed
   so the global pass and the per-framework emitter must classify **identically** —
   but a struct param's type may be defined in another module, and the emitter sees
   only its own framework. Thread a **global struct-name set** into both
   `collect_trampolines` and `classify_function` (the emitter calls the latter with
   just its framework today). Resolve: same-module-only (cheap, emitter-local) vs a
   threaded global set (complete). Pick the smallest sound option.
3. **Mixed-param functions.** Some (e.g. `MetricKit.mxSignpost`) mix a value-struct
   param with a `StaticString`/`UnsafeRawPointer`/`NSArray` param that does **not**
   pass through — those stay deferred (record the blocking param's reason). Only
   trampoline when *every* deferred param is a sound boxed handle.
4. **Smoke / "resolves and runs".** The residual exposes **no free function
   returning** these types, so racket has no in-residual way to obtain a handle to
   feed back — swiftc type-checking the unbox + by-name call is the build-green
   evidence, but an end-to-end run needs a producer (a class/instance handle, or a
   constructor trampoline). Decide the smoke story before claiming the done-bar; if
   no producer is reachable, record that honestly and lean on swiftc verification +
   a synthetic-fixture racket assertion test (the 040/020 §6 deviation pattern).

## Done when

- The codegen emits, for each newly-wired decl, the `@_cdecl` that unboxes its
  value-struct param(s) via `awRacketUnbox(a!, as: T.self)`; the emitter binds the
  entry (`_aw-lib`, `_pointer` arg) with the same content-addressed name.
- A clean `--target racket` generate **reduces** `deferred_nonbridged_struct_param`
  from 17 (report before/after); reference-type / mixed-unboxable params stay
  recorded with a reason, not silently dropped.
- Builds green (`swift build` + `cargo test --workspace`, snapshots updated). The
  unbox + by-name call type-checks against the real frameworks; an end-to-end run
  if a handle producer is reachable, else swiftc + assertion-test evidence per the
  fork-4 decision.

## Notes

- Racket-only (ADR-0011); chez (060) / gerbil (070) inherit nothing here.
- If a bucket turns out larger than one focused leaf, decompose rather than
  overrun. If the spec is underspecified, kick back to update it (the 040/030
  pattern), don't guess.
