---
title: APIAnyware
---

APIAnyware extracts, analyzes, and generates native platform API bindings for non-mainstream programming languages. Rather than producing thin C wrappers, it creates bindings that feel native to each target language — a Haskell user gets monadic error handling, a Smalltalk user gets message-passing objects, an OCaml user gets modules and variants.

**APIAnyware** is the first platform target, covering the full macOS API surface (Objective-C, C, and Swift). Sibling projects for Linux and Windows are planned.

## Architecture

A three-phase pipeline, each phase communicating via JSON checkpoint files:

```
Collection ──► Analysis ──► Generation
```

**Collection** parses macOS SDK headers via libclang and Swift modules via swift-api-digester, automatically discovering 218 ObjC frameworks and 151 Swift modules and producing raw API metadata with full provenance and documentation references.

**Analysis** resolves inheritance via Datalog (Ascent), adds semantic annotations (block invocation style, parameter ownership, threading constraints, error patterns, API usage patterns) via heuristics and LLM analysis, then enriches with Datalog-derived relations. API pattern recognition identifies stereotypical multi-method contracts — builder sequences, resource lifecycles, observer pairs — enabling emitters to produce idiomatic wrappers like `with-path` (Lisp/Scheme), `withCGContext` (Haskell), or RAII guards (Zig) automatically.

**Generation** emits per-language bindings with runtime support libraries and Swift helper dylibs. Each emitter reads the same enriched IR but produces output shaped to the target language's idioms and conventions.

## Current Status

The full pipeline is implemented and working end-to-end. The first language target, **Racket OO**, is substantially complete: 283 frameworks generated (~7,500 files), all 8 sample apps in the portfolio implemented, app bundling via proper macOS `.app` bundles (correct `CFBundleName` and per-app TCC identity), and 249 Rust + 64 Swift tests covering the pipeline.

All other language targets (Chez Scheme, Gerbil, Common Lisp, Haskell, Idris2, OCaml, Prolog/Mercury, Rhombus, Pharo Smalltalk, Zig) are planned but not yet started.

## Target Languages

| Language | Style(s) | Status |
|---|---|---|
| Racket (incl. Rhombus) | OO (classes) + functional | OO emitter complete; functional emitter stub |
| Chez Scheme | Functional | Planned |
| Gerbil Scheme | OO + functional | Planned |
| Common Lisp (SBCL, CCL) | CLOS + functional | Planned |
| Haskell | Monadic + lens-based | Planned |
| Idris2 | Dependently-typed wrappers | Planned |
| OCaml | Modules + OO | Planned |
| Prolog / Mercury | Relational | Planned |
| Pharo Smalltalk | Message-passing OO | Planned |
| Zig | Low-level procedural | Planned |

Languages with both OO and functional paradigms produce multiple binding styles from the same enriched IR.

## Why APIAnyware Exists

Non-mainstream languages are excluded from native platform development not because they lack capability, but because nobody has written the bindings. Writing bindings by hand is prohibitively expensive — macOS alone exposes tens of thousands of APIs across dozens of frameworks. APIAnyware solves this at scale: extract once, analyze once, generate for every language.

## Related Projects

APIAnyware generates the bindings. Other Linkuistics projects build on them:

- **TestAnyware** — VM-based GUI testing for applications built with generated bindings
- **TheGreatExplainer** — automated documentation and tutorials from the enriched IR
- **\*Pro IDEs** — each target language has a dedicated IDE built using APIAnyware bindings
