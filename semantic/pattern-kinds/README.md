# semantic/pattern-kinds/ — first-class pattern & relationship definitions

Multi-API patterns and relationships are **first-class semantic entities**, not
generator flags (REFACTOR.md §7.5, §31, §32; ADR-0048). Each **pattern-kind** is
a reusable, framework- *and* target-independent definition — a set of **roles**
(typed participant slots) and a set of **laws** (constraints) — authored once
here as `<name>.apiw` and referenced by platform specs and projected by targets.

One entity covers both *behavioral* contracts and *structural* relationships:
a relationship (§31) is the **degenerate** pattern-kind — typed roles + ownership/
lifetime laws, no operation sequence — folded in rather than a sibling entity
(ADR-0048 D4). See `CONTEXT.md → "Semantic model"` for the vocabulary.

## The `.apiw` shape

```kdl
pattern-kind "bracket" {
    doc "Acquire a resource, operate on it, then release it; release runs even on failure."
    role "acquire"   binds="operation" cardinality="1"
    role "operation" binds="operation" cardinality="*"
    role "release"   binds="operation" cardinality="1"
    ordering { before "acquire" "operation"; before "operation" "release" }
    law "error" {
        token "cleanup-required-after-partial-failure"
        doc "The release operation must run even when an operation fails."
    }
}
```

- **`role`** — `binds` ∈ `type` | `operation` | `parameter` | `pattern` (the last
  two enable single-operation-scoped relationships and composition, ADR-0048
  D5/DP2); `cardinality` ∈ `1` | `?` | `*` | `+` (default `1`).
- **`ordering`** — a happens-before graph over role names; present on behavioral
  kinds, absent on structural relationships.
- **`law`** — a constraint whose `token`s are drawn from **REFACTOR §30's
  controlled vocabularies** (the `category` selects the set: ownership / lifetime
  / threading / error / callback / buffer / relationship). Laws are *not* free
  prose — that is what keeps the registry non-vacuous (doubt-pass DP1). `doc`
  carries human nuance the tokens cannot.

## The authored kinds

Behavioral (§32 + the legacy `PatternStereotype`): `bracket`, `builder`,
`observer`, `delegate`, `factory-cluster`, `paired-state`, `target-action`,
`enumeration`, `error-out`, `subscription`, `two-call-sizing`, `buffer-fill`,
`typestate`.

Structural relationships (§31): `parent-child`, `callback-destroy-notifier`,
`collection-element-ownership`.

## Tooling

- **Schema (source of truth):** `schemas/spec-format/pattern-kinds.kdl-schema` —
  the language-neutral KDL Schema contract (ADR-0046 §3 / ADR-0048 D7).
- **Crate:** `semantic/tools/patterns` (`apianyware-patterns`) — the typed model,
  the `.apiw` parser/loader (`PatternKindRegistry`), the §30 controlled
  vocabularies, and a focused validator (structural validation reuses
  `apianyware-spec-format`'s generic KDL-Schema engine).

## What lives elsewhere

A pattern-**instance** (a kind's roles bound to a concrete framework's
participants, provenance-stamped) is *platform* knowledge carried in the machine
triad (`platforms/macos/api/<F>/resolved.kdl`), **not** here (ADR-0048 D1). Its
carriage extends `semantic/tools/types` + `resolve`; the convention-tier datalog
detection lives in
[`platforms/macos/tools/pattern-detection`](../../platforms/macos/tools/pattern-detection).

## Documentation

The conceptual prose for this model lives in [`../docs/`](../docs/):
[`overview.md`](../docs/overview.md) (the domain + the kind/instance split),
[`pattern-model.md`](../docs/pattern-model.md) (roles, laws, ordering,
composition), and [`api-pattern-catalog.md`](../docs/api-pattern-catalog.md) (the
per-kind roster). The glossary is `CONTEXT.md → "Semantic model"`.
