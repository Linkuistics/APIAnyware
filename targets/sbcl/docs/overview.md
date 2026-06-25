# sbcl — target overview (§18)

The **sbcl** target binds the macOS system frameworks for **Steel Bank Common Lisp** (2.6.5 / arm64),
as a **MOP projection of Objective-C into CLOS** over directly-dispatched ObjC, with
`libAPIAnywareSbcl` as the target's **sole native compilation unit** for the Swift-native residual,
shipped as a **self-contained dumped-image `.app`**. It is the project's fourth target — built after
racket, chez, and gerbil — and the **first member of the CL family**: application source written
against its portable `ns:`/CLOS contract is portable to a future CL-family member (CCL, AllegroCL,
LispWorks), with each implementation's binding mechanism private (ADR-0033).

This page is the **map** of the sbcl target model. The substance lives in the authored `.apiw`
entities and the deep-dive docs it points at; nothing here is restated from them.

## What the target is — the descriptor at a glance

The authoritative descriptor is [`../target.apiw`](../target.apiw) (REFACTOR §17). Its seven facets:

| facet | value | meaning |
|---|---|---|
| `family` | `common-lisp` | the language family — sbcl is its first member (the family-wide `ns:`/CLOS contract, ADR-0033) |
| `dialect` | `ansi-cl` | the standardised dialect the contract is written against |
| `implementation` | `sbcl` | the concrete implementation (Steel Bank Common Lisp 2.6.5) |
| `ffi-backend` | `sb-alien` | SBCL's compiler-integrated alien FFI — no external FFI library |
| `runtime-model` | `compiled-ffi` | each crossing is **open-coded at compile time** — one typed `sb-alien` signature per method ABI (ADR-0015) — like chez/gerbil, *not* racket's dynamic `interpreted-ffi` |
| `projection-policy` | `thin-direct` | direct ObjC (trampoline-elided); only the Swift-native delta crosses the adapter |
| `adapter-strategy` | `sole-native-unit` | `libAPIAnywareSbcl` is the target's **one** native unit — it hosts the Swift-native trampolines **and** the main-thread bounce, subclass-IMP synthesis, and OpaqueHandle/Throws/Async marshalling (ADR-0038) — a **fourth** strategy value, broader than gerbil's `trampoline-only` and chez's `trampoline-and-bridges` |

The `sole-native-unit` strategy is sbcl's structural signature: a Lisp compiles neither ObjC nor
Swift inline, so unlike gerbil — which keeps its callback / block / subclass bridges in gsc-compiled
Gerbil — sbcl has **no second native home**. The dylib is the *one* place native code lives.

## The doc map

The sbcl target's documentation is layered. Start at the layer that matches your need:

- **Using the binding** — [`../bindings/macos/docs/user-guide.md`](../bindings/macos/docs/user-guide.md)
  (the §22 entry point). Like chez and gerbil and unlike racket, sbcl ships **no separate
  `developer-guide.md`**, so the user guide is the primary user-facing walkthrough — first program,
  the dev load model (`aw-app-load-framework` + `:load-residual`), `make-instance` with typed init
  keywords, the per-selector generics, subclassing, threading, conditions, packaging — and it defers
  only the deepest detail to `reference.md`.
- **The §18 target model** (this directory):
  - [`language-characteristics.md`](language-characteristics.md) — Common Lisp / SBCL as a binding host.
  - [`ffi-model.md`](ffi-model.md) — the `sb-alien` compiled seam, the `objc_msgSend` SAP recast per
    call site, the `sole-native-unit` `libAPIAnywareSbcl` dylib, the thin-direct posture.
  - [`idiom-map.md`](idiom-map.md) — pointer to the authoritative §21 idiom render.
  - [`representability.md`](representability.md) — the 7-rung ladder and how a per-API status is
    derived (sbcl sits a rung **below** chez on thread re-entrancy — the bounce, level with
    racket/gerbil — and carries one §37 research item, the Swift-native *method* trampoline gap).
- **The §22 binding mapping docs** ([`../bindings/macos/docs/`](../bindings/macos/docs/)) —
  `platform-docs-mapping.md` (Apple docs → sbcl names), `api-coverage.md` (the derived coverage
  report), `unsafe-escape-hatches.md` (dropping to raw `sb-alien`).
- **Deep reference** — [`reference.md`](reference.md) (the `objc-class` metaclass model, per-selector
  generic dispatch, the FP-trap masking, the finalize + main-thread-release-queue lifetime, the
  condition hierarchy, the dumped-image bundler, and the sbcl-specific gotchas). The internal design
  history is under [`design/`](design/) and [`research/`](research/) (the MOP spike + the threading
  spike — first-hand evidence on SBCL 2.6.5 / arm64).

## The authored model this documents

The prose here is the human face of sbcl's six authored `.apiw` entities (all under `targets/sbcl/`),
parsed by the shared `apianyware-target-model` crate:

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
directory says how *sbcl* expresses the platform, never what the platform means).

## Two documents are CL-family-wide, not in this unit

Because sbcl is the family's first member, two records cross target boundaries and live in the shared
tier, read as the authoritative cross-target sources:

- [`../../_shared/docs/design/2026-06-20-cl-family-interface-contract.md`](../../_shared/docs/design/2026-06-20-cl-family-interface-contract.md)
  (ADR-0033) — the portable `ns:`/CLOS contract surface every CL target conforms to. This target is
  its **SBCL realization**.
- [`../../_shared/docs/research/cl-cocoa-bridges-across-the-family.md`](../../_shared/docs/research/cl-cocoa-bridges-across-the-family.md)
  — the prior-art + landscape survey across SBCL / CCL / AllegroCL / LispWorks.
