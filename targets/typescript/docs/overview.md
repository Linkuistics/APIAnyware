# typescript (Node) — target overview (§18)

The **typescript** target binds the macOS system frameworks for **Node.js**, as a
class-and-method binding over directly-dispatched Objective-C, with a single Swift-native
N-API addon (`APIAnywareTypeScript.node`) as the native core. It is the project's fifth
target, the first that is not a Lisp/Scheme, and the first with a static type system.

This page is the **map** of the typescript target model. The substance lives in the ADRs
it points at and the deep-dive docs below; nothing here is restated from them.

## What the target is — the facets

The four live Lisp targets (racket/chez/gerbil/sbcl) carry a formal, authored
`target.apiw` descriptor (§17) rated across seven facets. That authoring layer
(`target.apiw`, `capability.apiw`, `idioms/`, `policies/`, `conformance/` — the
`apianyware-target-model` crate, `structural-refactoring` grove workstream 6) has not yet
been extended to `typescript`: `apianyware-conformance`'s `LIVE_TARGETS` list is still the
original four. This target's equivalent facts are recorded centrally instead, in ADRs
0054–0061 — narrated here rather than as authored `.apiw` data:

| facet | value | meaning | source |
|---|---|---|---|
| `family` | (none — TypeScript has no Lisp/Scheme lineage) | the first non-Lisp target | CONTEXT.md `typescript` |
| `dialect` / `implementation` | `typescript` on **Node.js** ≥ 20 | the reference runtime; the binding is engine-agnostic (also runs on Bun/Deno for dispatch, not GUI-integration) | ADR-0054 §4 |
| `ffi-backend` | **N-API** (Node-API) | the C-ABI addon boundary; a fixed signature per generated entry, unlike a Lisp target's ability to re-cast `objc_msgSend` per call site | ADR-0054 |
| `runtime-model` | **generated typed native dispatch** | one `@_cdecl` napi callback per distinct ObjC method ABI signature, content-addressed (the racket ADR-0013 shape) | ADR-0054, ADR-0013 |
| `projection-policy` | **trampoline-elided** | the vast directly-reachable ObjC surface dispatches with no native adapter in the path; only the Swift-native residual + pointer constants cross it | ADR-0025, ADR-0061 |
| `adapter-strategy` | a single Swift-native `.node`, no Rust | the native core hosts N-API directly (`napi_register_module_v1`) rather than a separate dylib behind a scripting-language FFI | ADR-0054 §2 |

## The doc map

- **Using the binding** — [`../bindings/node/docs/user-guide.md`](../bindings/node/docs/user-guide.md)
  (the §22 entry point) — the primary user-facing doc for this target (no separate
  `developer-guide.md`; judged not warranted, see `../bindings/node/docs/user-guide.md`'s
  own scope note).
- **The §18 target model** (this directory):
  - [`language-characteristics.md`](language-characteristics.md) — TypeScript/Node as a
    binding host: static structural typing, the event loop, GC + `FinalizationRegistry`.
  - [`ffi-model.md`](ffi-model.md) — N-API, generated typed dispatch, the runloop-pumps-libuv
    polarity, the native adapter.
  - [`idiom-map.md`](idiom-map.md) — where the source-concept → TypeScript-construct mapping
    actually lives for this target (no `idioms/catalogue.apiw` exists yet).
  - [`representability.md`](representability.md) — how well the binding covers the macOS API
    surface, and how that is measured for a target outside the §20/§37 authored model.
- **The §22 binding mapping docs** ([`../bindings/node/docs/`](../bindings/node/docs/)) —
  `platform-docs-mapping.md` (Apple docs → TypeScript names), `api-coverage.md`,
  `unsafe-escape-hatches.md`.
- **Deep reference** — [`reference.md`](reference.md) (dispatch mechanism, memory model,
  threading, error handling, callbacks, distribution, quirks). The design history is under
  [`design/`](design/) and [`research/`](research/).

## The two-target split

TypeScript is delivered as **two separate targets** by JS substrate (root brief
`ts-substrate-reeval-k11`, 2026-07-06): this unit is the **Node** target, built first (the
harder, richer one — the libuv pump, N-API, threading). A future **JSC** target ("typed TS
directly over Cocoa": all-Swift core, embedded system `JavaScriptCore.framework`, no pump
to dissolve, `JSManagedValue` memory) is a separate grove, grounded in
[`research/2026-07-06-ts-substrate-reeval/FINDINGS.md`](research/2026-07-06-ts-substrate-reeval/FINDINGS.md).
Everything under `targets/typescript/` today is the Node target.
