# racket — target overview (§18)

The **racket** target binds the macOS system frameworks for **Racket CS 9.2**, as a
class-and-method binding over directly-dispatched Objective-C, with a native adapter
(`APIAnywareRacket`) for the Swift-native residual and for callbacks. It is the project's
reference target — the first built, and the most heavily documented.

This page is the **map** of the racket target model. The substance lives in the authored
`.apiw` entities and the deep-dive docs it points at; nothing here is restated from them.

## What the target is — the descriptor at a glance

The authoritative descriptor is [`../target.apiw`](../target.apiw) (REFACTOR §17). Its seven
facets:

| facet | value | meaning |
|---|---|---|
| `family` | `scheme` | the language family |
| `dialect` | `racket` | the dialect within it |
| `implementation` | `racket-cs` | the concrete implementation (Chez-backed Racket CS) |
| `ffi-backend` | `ffi2` | the primary C-function FFI layer (ObjC dispatch stays on `ffi/unsafe/objc`) |
| `runtime-model` | `interpreted-ffi` | FFI call sites reached dynamically, not open-coded (ADR-0015) |
| `projection-policy` | `thin-direct` | direct ObjC (trampoline-elided); only the Swift-native delta crosses the adapter |
| `adapter-strategy` | `trampoline-and-bridges` | the dylib hosts ADR-0013 typed dispatch + trampolines + callback/marshalling bridges |

## The doc map

The racket target's documentation is layered. Start at the layer that matches your need:

- **Using the binding** — [`../bindings/macos/docs/user-guide.md`](../bindings/macos/docs/user-guide.md)
  (the §22 entry point) → [`developer-guide.md`](developer-guide.md) (the comprehensive,
  task-oriented user guide: first program, requiring bindings, delegates, completion blocks,
  threading, packaging, VM-verify).
- **The §18 target model** (this directory):
  - [`language-characteristics.md`](language-characteristics.md) — Racket CS as a binding host.
  - [`ffi-model.md`](ffi-model.md) — ffi2 + `ffi/unsafe/objc`, the ADR-0013 typed dispatch, the
    trampoline-elided posture, the `APIAnywareRacket` adapter.
  - [`idiom-map.md`](idiom-map.md) — pointer to the authoritative §21 idiom render.
  - [`representability.md`](representability.md) — the 7-rung ladder and how a per-API status is
    derived.
- **The §22 binding mapping docs** ([`../bindings/macos/docs/`](../bindings/macos/docs/)) —
  `platform-docs-mapping.md` (Apple docs → racket names), `api-coverage.md` (the derived coverage
  report), `unsafe-escape-hatches.md` (dropping to raw FFI).
- **Deep reference** — [`reference.md`](reference.md) (emitter architecture, contract design, FFI
  type-coercion rules, runtime library, framework gotchas). The internal design history is under
  [`design/`](design/) and [`research/`](research/).

## The authored model this documents

The prose here is the human face of racket's six authored `.apiw` entities (all under
`targets/racket/`), parsed by the shared `apianyware-target-model` crate:

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
directory says how *racket* expresses the platform, never what the platform means).
