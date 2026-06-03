# 030-replan-from-spike

**Kind:** planning

## Goal

Re-grill the design forks deferred by 010-plan, now armed with the 020 spike's
measured evidence; settle them; capture durable decisions; then decompose the
build subtree so the loop can execute it.

## Context

010-plan deferred Q1 (dispatch model: chez ADR-0015 direct dispatch vs racket
ADR-0013 generated native dispatch) and Q2 (object model: single-handle-struct +
procedure-namespaces vs `defmethod`/generic-function vs native `defclass`
hierarchy) to the 020 spike. Read 020's
`docs/research/<date>-gerbil-ffi-dispatch-spike/FINDINGS.md` first — its
recommendations pre-judge most of this grilling.

## Done when

- Q1 settled from spike numbers on **two axes**: runtime ns/call AND compile-time
  DX (gxc/gsc/cc wall-clock vs generated-FFI volume). ADR-0015 weighed only
  runtime; for Gerbil (Scheme→Gambit→C→cc) generated-source volume drives compile
  time — and Chez already proved long compiles are a DX PITA — so a fatter native
  lib (racket ADR-0013 shape) may win for Gerbil despite direct dispatch being
  runtime-optimal. The Q1 ADR must record BOTH axes (where ADR-0015 recorded one)
  and is free to diverge from Chez (ADR-0011 licenses per-target divergence).
- Q2 settled from spike numbers (running log here).
- Design spec written: `docs/specs/<date>-gerbil-target-design.md` (per the
  9-step guide Step 1: language/id, toolchain, idiom commitments, dylib?,
  emitter crate, runtime location, distribution model).
- Durable/surprising/hard-to-reverse trade-offs raised as ADRs (e.g. a Gerbil
  dispatch ADR paralleling 0015, a lifetime ADR paralleling 0007 using Gambit
  wills/`still`, an error-model ADR paralleling 0006). ADRs sparingly.
- `CONTEXT.md` extended with resolved Gerbil design terms.
- Build subtree grown (leaves added/decomposed) covering the 9-step checklist:
  emitter crate (`emit-gerbil`), runtime, Swift dylib (if needed), CLI
  registration, emission tests, the 7 sample apps **each with a VM-verify leaf**,
  bundler integration (`static-exe` per the guide Step 8),
  `knowledge/targets/gerbil.md`, README status.
- **Carried over from 020 (spike item 5 — now CHARACTERIZED, FINDINGS §5):** the
  macOS distribution recipe is known — `gxc -exe` against the `--enable-shared=no`
  toolchain (`~/.local/gerbil-0.18.2-static/bin/gxc`) embeds the runtime
  statically; `-static` (fully-static) is unsupported on macOS; the only gap is
  vendoring+relocating the Gerbil stdlib's **openssl@3** dylib dep into the `.app`
  (chez-style). 030's distribution/bundler leaf APPLIES this (dylib relocation +
  VM-verified hello-window), it no longer needs to discover it.

## Notes

Still-open axes this leaf must also walk (not just Q1/Q2):
- **Lifetime model** — Gambit wills/`still` objects vs a guardian-equivalent;
  the entry-point autoreleasepool convention (ADR-0007) likely transfers.
- **Error model** — `(values result error)` (chez ADR-0006) vs Gerbil
  exceptions/conditions.
- **Block / delegate / dynamic-class bridging** — what must live in the Swift
  native lib (ADR-0010/0016) vs Scheme side.
- **Threading** — foreign-thread activation analogue (ADR-0016); does Gambit's
  thread model need the same treatment?
