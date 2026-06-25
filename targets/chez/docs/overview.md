# chez — target overview (§18)

The **chez** target binds the macOS system frameworks for **Chez Scheme**, as a class-and-method
binding over directly-dispatched Objective-C, with a native adapter (`APIAnywareChez`) for the
Swift-native residual and for callbacks, shipped as a **self-contained `.app`** (ADR-0009). It is
the project's second target — built after racket, and the one whose threading model diverges
sharply from it.

This page is the **map** of the chez target model. The substance lives in the authored `.apiw`
entities and the deep-dive docs it points at; nothing here is restated from them.

## What the target is — the descriptor at a glance

The authoritative descriptor is [`../target.apiw`](../target.apiw) (REFACTOR §17). Its seven facets:

| facet | value | meaning |
|---|---|---|
| `family` | `scheme` | the language family |
| `dialect` | `r6rs` | an R6RS base (`(import (chezscheme))`) — but **maximally Chez-idiomatic**, not portable R6RS (ADR-0005) |
| `implementation` | `chez-scheme` | the concrete implementation |
| `ffi-backend` | `foreign-procedure` | Chez's native typed C-FFI |
| `runtime-model` | `compiled-ffi` | each method ABI is **open-coded at compile time** (ADR-0015) — *not* reached dynamically like racket's `interpreted-ffi` |
| `projection-policy` | `thin-direct` | direct ObjC (trampoline-elided); only the Swift-native delta crosses the adapter |
| `adapter-strategy` | `trampoline-and-bridges` | the dylib hosts the Swift-native trampolines + the **foreign-callable** callback bridges (thread *activation*, ADR-0016) |

## The doc map

The chez target's documentation is layered. Start at the layer that matches your need:

- **Using the binding** — [`../bindings/macos/docs/user-guide.md`](../bindings/macos/docs/user-guide.md)
  (the §22 entry point). Unlike racket, chez ships **no separate `developer-guide.md`**, so the
  user guide is the primary user-facing walkthrough — first program, the `(apianyware …)` require
  model, threading, errors, packaging — and it defers only the deepest detail to `reference.md`.
- **The §18 target model** (this directory):
  - [`language-characteristics.md`](language-characteristics.md) — Chez Scheme as a binding host.
  - [`ffi-model.md`](ffi-model.md) — `foreign-procedure` compiled dispatch, the five-cluster
    runtime, the trampoline-elided posture, the `APIAnywareChez` adapter.
  - [`idiom-map.md`](idiom-map.md) — pointer to the authoritative §21 idiom render.
  - [`representability.md`](representability.md) — the 7-rung ladder and how a per-API status is
    derived.
- **The §22 binding mapping docs** ([`../bindings/macos/docs/`](../bindings/macos/docs/)) —
  `platform-docs-mapping.md` (Apple docs → chez names), `api-coverage.md` (the derived coverage
  report), `unsafe-escape-hatches.md` (dropping to raw FFI).
- **Deep reference** — [`reference.md`](reference.md) (the five-cluster runtime, lifetime model,
  dispatch, FFI type-coercion, chez-specific gotchas). The internal design history is under
  [`design/`](design/) and [`research/`](research/).

## The authored model this documents

The prose here is the human face of chez's six authored `.apiw` entities (all under
`targets/chez/`), parsed by the shared `apianyware-target-model` crate:

| entity | file | documented by |
|---|---|---|
| descriptor (§17) | [`../target.apiw`](../target.apiw) | this page + `language-characteristics` + `ffi-model` |
| capability profile (§20) | [`../capability.apiw`](../capability.apiw) | `language-characteristics` + `representability` |
| idiom catalogue (§21) | [`../idioms/catalogue.apiw`](../idioms/catalogue.apiw) | `idiom-map` (+ [`../idioms/docs/idiom-map.md`](../idioms/docs/idiom-map.md)) |
| projection policy (§23) | [`../policies/macos/projection.apiw`](../policies/macos/projection.apiw) | `ffi-model` |
| adapter spec (§24–26) | [`../adapters/macos/spec.apiw`](../adapters/macos/spec.apiw) | `ffi-model` |
| conformance (§37) | [`../conformance/macos.apiw`](../conformance/macos.apiw) | `../bindings/macos/docs/api-coverage.md` |

The macOS API model the binding is *over* is platform-domain knowledge under
[`platforms/macos/`](../../../platforms/macos/) — not duplicated here (the domain rule: this
directory says how *chez* expresses the platform, never what the platform means).
