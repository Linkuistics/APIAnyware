# The per-target native library is the binding

**Status:** accepted

APIAnyware's **fundamental design goal**: for each target language we write a
**native (Swift) library, purpose-built and optimised for that one target to
bind to**, which maps the macOS API model idiomatically into the target language
and owns the hard runtime concerns — memory management, callbacks, closures,
lifetimes, threading — using wherever possible the FFI/embedding C-API and
libraries the *target language itself* provides (Racket CS's C embedding API;
Chez's `foreign-procedure` / ftype). In the limit, **the binding can be provided
almost entirely in the native library**, with the generated/scripting-side
surface kept thin and static. We choose this over a target-language-heavy binding
because LLM-assisted coding makes a bespoke, fully-optimised native library per
target affordable — work that would otherwise be too expensive, repetitive, and
error-prone to hand-write across many targets.

## Considered options

- **Target-language-heavy binding (prior emphasis).** The Rust emitter writes
  most FFI logic as target-language source (`ffi/unsafe/objc` + `tell` for
  racket, `foreign-procedure` for chez); the native helper dylib covers only what
  the target language cannot express. Less native code per target, but the
  binding logic (lifetimes, callbacks, coercions) is re-implemented in each
  target language, interpreted, and slower.
- **Native-library-is-the-binding (chosen).** A per-target Swift library owns the
  binding logic and presents a deliberately idiomatic surface; the
  target-language side is a thin, static seam into it. More native code per
  target, but correct-once logic, maximal performance (compiled core, thin
  crossing), and an idiomatic mapping designed on purpose rather than emerging
  from mechanical emission.

## Consequences

- **The Rust emitter's role narrows** — toward emitting thin, idiomatic
  target-language shims plus loader/metadata that call into the native library,
  rather than open-coding FFI. How far each target moves is pragmatic
  ("if optimal"): existing targets evolve toward the goal, not a big-bang rewrite.
- **Per-target native libraries grow and diverge by design** — each optimised for
  one target's embedding C-API; they are *not* a shared portable core. This is
  the ADR-0005 idiom posture applied to the *native* layer: cross-target symmetry
  stays at on-disk-layout / IR-decision level, not at native-source level.
- **Performance is a first-class goal:** a fat native core behind a thin static
  FFI crossing.
- **The Racket 9.2 + ffi2 migration is reframed:** ffi2 becomes the thin, static
  seam by which Racket calls the fat `libAPIAnywareRacket` native library (via
  Racket CS's C embedding facilities), *not* the mechanism for a Racket-heavy
  binding. See the grove `update-racket-to-9.2-and-use-ffi2`.
- **Deepens ADR-0005** (idiomatic per target) and complements **ADR-0004** (one
  target per shape): the idiomatic mapping is now delivered chiefly through the
  native library's deliberate design rather than through emitted FFI source.

See `CONTEXT.md` (the "Fundamental design goal" preamble) for the canonical
statement.
