# Interface Language Specification Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. This is a specification-writing plan; production parsers, libraries and APIAnyware changes are outside its scope.

**Goal:** Produce a coherent first normative language draft, its baseline mapping and a conformance corpus from the approved architecture.

**Architecture:** A dedicated declaration language carries authoritative semantic contracts. Versioned profiles interpret source-language constructs and access mechanisms; tooling-owned catalogues define ABIs. All producers use the same publication rules.

**Tech Stack:** Markdown specification, EBNF grammar, textual language examples. Existing Rust code is evidence only.

**Result:** First normative draft delivered under
[`semantic/specification/interface-language`](../../specification/interface-language/README.md).
This completes the bounded specification-writing plan. Production profiles,
full-baseline representability, independent-producer exercises and executable
semantic conformance remain adoption gates, as stated in the draft.

## Global Constraints

- The language contains **complete, authoritative specifications only**.
- The language has a **dedicated interface-language syntax**.
- Documents identify ABIs; tooling owns the supported ABI definitions.
- Bindings, documentation and LLM views preserve the same semantic contract.
- Integration, production parsers and language libraries are later phases.

## Task 1: Define the language and semantic contract

**Files:** Create `semantic/specification/interface-language/README.md`, `grammar.ebnf`, `language.md`, `contracts.md`, `profiles.md`.

**Interfaces:** Consumes the approved design and research. Produces grammar productions and named semantic rules referenced by every example and baseline mapping.

- [x] Define tokens, identities, packages, imports, environment selection, types, declarations and contract syntax.
- [x] Define the type/contract vocabulary, applicability, defaults, contradictions and required facts on every outcome.
- [x] Define access paths, representation dependencies, ABI selection, compatibility domains and consumer refusal rules.
- [x] Read the grammar and clause catalogue against each other; resolve unmatched constructs and duplicate semantic authorities.

## Task 2: Map the existing model

**Files:** Create `semantic/specification/interface-language/baseline.md`.

**Interfaces:** Consumes the bounded source corpus in `semantic/tools/types/src/{ir,type_ref,annotation,provenance,pattern_instance,enrichment}.rs` and `semantic/tools/patterns/src/kind.rs` in the OCaml workspace, with main-workspace differences recorded. Produces a field/variant disposition inventory: represented, upstream evidence, derived view, consumer policy or explicit publication blocker.

- [x] Enumerate source structs/fields/variants before classifying them.
- [x] Check current-main and OCaml-specific differences, including sendability and actor facts.
- [x] Map every enumerated item to a specific language rule or a stated external responsibility.
- [x] State where the current IR cannot supply a complete contract and publication therefore needs additional analysis.

## Task 3: Exercise the specification

**Files:** Create `semantic/specification/interface-language/examples/` and `conformance.md`.

**Interfaces:** Consumes Tasks 1–2. Produces complete synthetic fixture specifications, rejection mutations, documentation/LLM views and a consumer-independent conformance checklist.

- [x] Cover resource ownership, dependent borrows, buffers, callbacks, outcomes, concurrency, objects/properties and multiple access mechanisms.
- [x] Provide invalid variants that isolate unresolved facts, reference errors, conflicting clauses, lifetime gaps and ABI-selection failures.
- [x] Check each example against grammar and mandatory-clause rules; identify the fixture catalogue dependencies without claiming live native invocation.
- [x] Define exact round-trip, closure, diagnostic and consumer obligations for future implementations.

## Task 4: Review and publish the draft

**Files:** Update the specification set, `semantic/docs/README.md`, and this plan.

**Interfaces:** Consumes the draft and its evidence. Produces a cross-linked specification with explicit version/status and checked local links.

- [x] Obtain focused independent review of the grammar/semantics and publication/ABI boundary; classify and resolve material findings.
- [x] Check local links, code fences, source-inventory disposition coverage and specification/fixture consistency.
- [x] Record exact verification limits; do not claim a parser, executable conformance implementation or APIAnyware adoption exists.
- [x] Describe the documentation change in Jujutsu and report the resulting artifacts.
