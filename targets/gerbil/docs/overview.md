# gerbil — target overview (§18)

The **gerbil** target binds the macOS system frameworks for **Gerbil Scheme** (0.18.x on the
vendored Gambit), as a **manifest `defclass` class graph** over directly-dispatched Objective-C,
with a strictly **trampoline-only** native adapter (`APIAnywareGerbil`) for the Swift-native
residual, built to a **self-contained static executable**. It is the project's third target —
built after racket and chez, and the **paradigm experiment**: where racket and chez bind through
flat free procedures over one opaque object, gerbil reifies the ObjC hierarchy as a real class
graph with three dispatch surfaces.

This page is the **map** of the gerbil target model. The substance lives in the authored `.apiw`
entities and the deep-dive docs it points at; nothing here is restated from them.

## What the target is — the descriptor at a glance

The authoritative descriptor is [`../target.apiw`](../target.apiw) (REFACTOR §17). Its facets
(gerbil omits `dialect` — for Gerbil the dialect and the implementation coincide):

| facet | value | meaning |
|---|---|---|
| `family` | `scheme` | the language family |
| `implementation` | `gerbil` | the concrete implementation (Gerbil on vendored Gambit) |
| `ffi-backend` | `std-foreign` | Gerbil's `:std/foreign` `define-c-lambda` |
| `runtime-model` | `compiled-ffi` | each crossing is **open-coded at compile time** (gxc → Gambit → C → native, ADR-0015/0017) — like chez, *not* racket's dynamic `interpreted-ffi` |
| `projection-policy` | `thin-direct` | direct ObjC (trampoline-elided); only the Swift-native delta crosses the adapter |
| `adapter-strategy` | `trampoline-only` | the dylib hosts **only** the Swift-native trampolines; the ObjC/callback bridges live in gsc-compiled Gerbil, *not* the native unit (ADR-0029) — chez's contrast is `trampoline-and-bridges` |

## The doc map

The gerbil target's documentation is layered. Start at the layer that matches your need:

- **Using the binding** — [`../bindings/macos/docs/user-guide.md`](../bindings/macos/docs/user-guide.md)
  (the §22 entry point). Like chez and unlike racket, gerbil ships **no separate
  `developer-guide.md`**, so the user guide is the primary user-facing walkthrough — first program,
  the `:gerbil-bindings/…` import model, the three dispatch surfaces, subclassing, threading,
  errors, packaging — and it defers only the deepest detail to `reference.md`.
- **The §18 target model** (this directory):
  - [`language-characteristics.md`](language-characteristics.md) — Gerbil Scheme as a binding host.
  - [`ffi-model.md`](ffi-model.md) — `define-c-lambda` compiled dispatch, the gsc-compiled native
    core, the trampoline-only `APIAnywareGerbil` dylib, the thin-direct posture.
  - [`idiom-map.md`](idiom-map.md) — pointer to the authoritative §21 idiom render.
  - [`representability.md`](representability.md) — the 7-rung ladder and how a per-API status is
    derived (gerbil sits a rung **below** chez on thread re-entrancy — the bounce, not activation).
- **The §22 binding mapping docs** ([`../bindings/macos/docs/`](../bindings/macos/docs/)) —
  `platform-docs-mapping.md` (Apple docs → gerbil names), `api-coverage.md` (the derived coverage
  report), `unsafe-escape-hatches.md` (dropping to raw FFI).
- **Deep reference** — [`reference.md`](reference.md) (the manifest object model, the dual-surface
  dispatch + fast-path layering, the lifetime will, the toolchain bottle, the gerbil-specific
  gotchas). The internal design history is under [`design/`](design/) and [`research/`](research/).

## The authored model this documents

The prose here is the human face of gerbil's six authored `.apiw` entities (all under
`targets/gerbil/`), parsed by the shared `apianyware-target-model` crate:

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
directory says how *gerbil* expresses the platform, never what the platform means).
