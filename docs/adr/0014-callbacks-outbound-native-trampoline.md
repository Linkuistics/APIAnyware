# Callbacks stay outbound through native trampolines; ffi2 callbacks rejected

**Status:** accepted

For the inbound path (Objective-C invoking Racket — delegates, blocks, target/
action, completion handlers), the `racket` target keeps **outbound** embedding:
Racket creates a `_cprocedure`/`function-ptr` callback and registers it behind a
**native Swift trampoline** that owns the ObjC side and the thread-safety, with
foreign-thread invocations bounced to a Racket-safe thread. We **reject** ffi2
callbacks and **reject** inbound Racket-CS C-embedding.

## Context

020 flagged the foreign-thread callback behaviour as the migration's biggest
unknown: on Racket CS, a `_cprocedure` callback **SIGILLs when invoked from a
non-main OS thread**, and `#:async-apply` deadlocks under `nsapplication-run`.
The ffi2 migration raised the hope that ffi2 callbacks might behave differently.

## Spike findings (decisive)

- **ffi2 callbacks do not fix the foreign thread.** Invoked from a fresh
  `pthread` or a GCD worker, an ffi2 callback **SIGILLs exactly like
  `_cprocedure`** — it never fires. ffi2's atomic-mode model does not make a
  thread the Racket CS runtime never started safe to enter.
- **ffi2 callbacks with `void` return are broken upstream**
  (`ffi2-lib .../core.rkt:986` applies `(ffi2-type-c->racket void_t)`, which is
  `#f` → "not a procedure: #f"). `void` is the dominant delegate/handler return
  shape, so this alone disqualifies them. Every void-callback spelling fails;
  only non-void works. (Worth reporting upstream; we do not depend on a fix.)
- **The existing native trampolines already solve it correctly:**
  `DelegateBridge.swift` (dynamic class + IMP trampolines + per-instance dispatch
  table), `BlockBridge.swift` (global-block ABI + copy/dispose refcount),
  `main-thread.rkt` (bounce foreign-thread work to main via `dispatch_async_f`
  before any Racket runs), `GCPrevention.swift` (pin callback vs GC).

## Considered options

- **Outbound + native trampoline (chosen).** Matches the evidence and is the
  current architecture; the native library owns threading and lifetime (ADR-0010).
- **ffi2 callbacks.** Rejected: foreign-thread SIGILL + void-return bug.
- **Inbound Racket-CS C-embedding** (Swift links the CS C-API to drive Racket
  closures/GC directly). Rejected: no evidence it is needed, far larger surface,
  and it confronts the same foreign-thread activation problem one level lower.

## Decision

Stay outbound. Keep `_cprocedure`/`function-ptr` callback creation in Racket,
registered through the native Swift trampolines, with foreign-thread safety owned
natively. The pure-Racket fallbacks (`make-delegate/racket`, pure-Racket block
ABI) are deleted when the dylib becomes mandatory.

## Consequences

- The callback/delegate/block layer is **kept and deepened**, not replaced by the
  ffi2 migration; ffi2 governs only the outbound C-function + dispatch seam
  (ADR-0013).
- Foreign-thread callbacks remain a *native* concern (bounce to main); no Racket
  code runs on an unregistered OS thread.
- Evidence: `docs/research/2026-05-31-racket-ffi2-spike/FINDINGS.md`; design:
  `docs/specs/2026-05-31-racket-native-binding-design.md`. Target-local under
  **ADR-0011** (`APIAnywareRacket`).
