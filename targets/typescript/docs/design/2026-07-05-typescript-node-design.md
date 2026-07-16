# TypeScript (Node) — target design

The Step 1 design spec (`adding-a-language-target.md`) for the fifth APIAnyware target,
written retroactively at Step 9 once the build settled — the design itself was reached
through a `grove`-driven grilling process (Q1–Q7) that recorded each decision as a central
ADR rather than a single up-front spec. This page is the map the template asks for; the
ADRs are the substance and are cited, not restated.

## Language / display name

**TypeScript**, on the **Node.js** runtime (display name: "TypeScript (Node)"). TypeScript
is delivered as **two separate targets** by JS substrate — a Node binding and an embedded
JavaScriptCore binding are different products, not two idioms of one language (root brief
`ts-substrate-reeval-k11`, 2026-07-06). This spec, and everything under `targets/typescript/`,
is the **Node** target. The JSC target is a separate future grove, grounded in
[`../research/2026-07-06-ts-substrate-reeval/FINDINGS.md`](../research/2026-07-06-ts-substrate-reeval/FINDINGS.md).

## Target id

`typescript` — the CLI `--target typescript` value and the on-disk dir name
(`targets/typescript/`). A plain language id, no `{lang}-{paradigm}` slug (ADR-0004).

## Implementation(s)

Node.js ≥ 20, TypeScript ≥ 5.9 (`@apianyware/runtime`'s `engines`/`devDependencies`).
Confirmed host during the build: Node v26.4.0, Swift 6.3.3, Apple clang 21, macOS 26.5.1
arm64. The binding is **engine-agnostic** by construction (N-API, ADR-0054 §4) — Node is
the *reference* runtime, not an exclusive one; see `ffi-model.md`.

## Idiom commitments

Real ES6 classes mirroring the ObjC class graph, generated static `.d.ts` alongside a dumb
runtime, injective `:`→`_` selector names, protocols as TS `interface`s, a POD/Swift-value
split for by-value types, TS `enum`s, `T | null` from annotations, faithful `alloc`/`init` —
the full object-model + `.d.ts` surface is **ADR-0055**. Unlike the four Lisp targets,
TypeScript is paradigmatically alien on two axes at once: it is the first **non-Lisp** target
and the first with a **static type system**, so the `.d.ts` surface is a first-class
deliverable no prior target has (CONTEXT.md `typescript` entry).

## Native core

`APIAnywareTypeScript.node` — a single **Swift-native N-API addon**, no Rust
(ADR-0054 §2, confirmed first-hand by `napi-dispatch-spine-k35`): a Swift
`@_cdecl("napi_register_module_v1")` unit hosts the Node-API C surface directly, resolved at
`dlopen` (`-undefined dynamic_lookup`) against the host, so the addon stays engine-agnostic.
This collapsed the originally-planned two-unit shape (napi-rs + Swift dylib, proven by the
`ts-substrate-spike-k3` spike) to one loadable `.node`. See `bindings/node/native/README.md`
for the full per-child build history and `ffi-model.md`/`reference.md` for the dispatch
mechanism.

## Emitter crate

`emit-typescript` (`targets/typescript/tools/emit-typescript`) — the `generate` stage:
reads the analysed `Framework` IR, writes idiomatic TS + `.d.ts` per ADR-0055.

## Runtime location

`targets/typescript/bindings/node/runtime/` — the `@apianyware/runtime` npm package (the
"dumb runtime": uniquing map, wrap primitives, `Symbol.dispose` hook, `FinalizationRegistry`
backstop, `Result`/error roots, callback machinery). The emitted per-framework modules
(`targets/typescript/bindings/macos/generated/`) import their seam symbols from it.

## Distribution model

A per-app-compiled native launcher **owns `main()`** and embeds a vendored, pinned
`libnode` directly (the Electron shape) — **not** a shared stub or a self-contained dumped
image, because ADR-0056's threading polarity (native Cocoa runloop authoritative, libuv
pumped as a guest) forbids the ambient blocking `node app.js` model every other target's
distribution could otherwise share. Full design: **ADR-0060**; mechanics:
`targets/typescript/tools/bundle-typescript/README.md`.

## How the design was actually reached

Q1 (substrate + dispatch) settled 2026-07-05 (`typescript-target-k1`), de-risked end-to-end
by `ts-substrate-spike-k3`. Q2 (object model + `.d.ts`) settled 2026-07-05 → ADR-0055. Q3–Q7
(memory, error, callbacks, distribution) each grilled to its own ADR (0057–0060). A substrate
re-evaluation (`ts-substrate-reeval-k11`, 2026-07-06) reopened the engine/core-language
question mid-build and resolved the two-target split above. The full grilling record — the
running decision log, the WDYT/pushback exchanges, the rejected alternatives — lived in this
grove's own task tree (`.grove/`, ephemeral by design) rather than a second copy here; the
ADRs are what survives it.

## See also

- ADR-0054 (substrate + dispatch), ADR-0055 (object model + `.d.ts`), ADR-0056 (threading),
  ADR-0057 (lifetime), ADR-0058 (errors), ADR-0059 (callbacks), ADR-0060 (distribution),
  ADR-0061 (trampoline structure).
- [`../overview.md`](../overview.md) — the §18 map this design feeds.
- [`../research/`](../research/) — the prior-art survey and the two substrate spikes.
