# Targets are hermetically isolated; only the API analysis is shared

**Status:** accepted

Each language target is **hermetically isolated**: its generator (emitter), its
runtime, and its native (Swift) library are entirely self-contained and share
**nothing** with other targets. The *only* thing common across targets is the
**API analysis** — the `collect → analyse` half of the pipeline that produces the
macOS API model (the IR). Everything downstream of analysis (`generate` +
runtime + native library) is per-target and shares no substrate. The existing
`APIAnywareCommon` shared Swift layer is therefore **dissolved**, its code split
into each per-target native library.

This extends **ADR-0010** (the per-target native library *is* the binding) with
the isolation clause, and completes the idiom posture of **ADR-0005** (each
target maximally idiomatic): a shared substrate and maximal per-target idiom are
in tension, and we resolve it in favour of idiom + isolation.

## Considered options

- **Shared native substrate (status quo: `APIAnywareCommon`).** Targets share a
  common Swift layer (message-send, string/struct marshalling, memory, class
  lookup). Less duplication while targets are similar — but the shared
  abstractions become a straitjacket the moment a paradigmatically different
  target arrives, and they pull every target toward a lowest-common-denominator
  shape that fights ADR-0005's "maximally idiomatic" goal.
- **Hermetic isolation (chosen).** No shared native/runtime substrate; only the
  analysis IR is common. Some duplication across the Scheme-family targets today,
  but each target is free to be maximally idiomatic, and adding an alien-paradigm
  target costs nothing in shared-abstraction churn.

## Consequences

- **`APIAnywareCommon` is dissolved** — its code is absorbed into each of
  `APIAnywareRacket`, `APIAnywareChez`, `APIAnywareGerbil`, and the shared target
  is deleted from `swift/Package.swift`. Each produces a self-contained dylib with
  no shared dependency. (Executed in the `update-racket-to-9.2-and-use-ffi2`
  grove, which therefore owns keeping all three targets building + their Swift
  tests green.)
- **The only cross-target sharing is the analysis IR.** `collect` + `analyse`
  (the macOS API model / enriched IR) stay shared; `generate`, runtime, and
  native library are per-target. The emitter framework may share *mechanism*
  (code-writing utilities) but not target *semantics*.
- **Motivated by paradigm diversity.** Future targets — Prolog, Haskell, Idris2,
  TypeScript — are paradigmatically alien to today's Scheme-ish targets; a
  substrate built around the current three would be the wrong abstraction for
  them. Isolation trades a little duplication now for never paying the
  wrong-abstraction tax later.
- **Duplication across similar targets is accepted by design** — and is cheap
  because LLM-assisted coding makes a bespoke per-target native library
  affordable (the ADR-0010 economics).

See `CONTEXT.md` (the "Fundamental design goal" preamble) for the canonical
statement.
