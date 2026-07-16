# Target: typescript (Node)

TypeScript bindings for macOS system frameworks on **Node.js**, generated as real ES6
classes over directly-dispatched Objective-C, with a single Swift-native N-API addon as
the native core. This is the **Node** TypeScript target — the harder, richer half of the
two-target TypeScript split (see `docs/overview.md`); the JSC target is a separate future
grove.

## For developers and maintainers

- [`docs/reference.md`](docs/reference.md) — the deep target reference: FFI mechanism,
  dispatch, memory model, error handling, callback machinery, distribution, quirks.
- [`docs/design/`](docs/design) — the Step 1 design spec.
- [`docs/research/`](docs/research) — the prior-art survey and the two substrate spikes
  that de-risked the native core before it was built.
- [`bindings/node/native/README.md`](bindings/node/native/README.md) — the exhaustive,
  child-leaf-by-child-leaf build history of the native addon; `docs/reference.md`
  distills it, this is the full record.

For cross-cutting context shared by all targets, read the main `docs/` tier (pipeline,
app-portfolio specs, emitter-contract, ADRs 0010/0011). This target has no Scheme sibling
to compare against — it is the first non-Lisp, first statically-typed target
(`CONTEXT.md`, `typescript` entry).

## For developers using the bindings

Read [`bindings/node/docs/user-guide.md`](bindings/node/docs/user-guide.md) — the
entry point for writing a Node TypeScript app against the generated macOS bindings.

## Target structure

- `tools/emit-typescript/` — the Rust emitter crate: analysed `Framework` IR → idiomatic
  TS + `.d.ts` (ADR-0055).
- `tools/bundle-typescript/` — the Rust bundler crate: turns a built sample app into a
  self-contained, TestAnyware-VM-verified `.app` (ADR-0060, Step 8).
- `bindings/node/runtime/` — the hand-written `@apianyware/runtime` npm package (the
  "dumb runtime" every emitted module imports its seam symbols from).
- `bindings/node/native/` — the Swift-native N-API addon (`APIAnywareTypeScript.node`),
  this target's sole native unit (ADR-0011).
- `bindings/macos/generated/<framework>/` — emitted per-framework TS + `.d.ts` (gitignored
  — produced by `apianyware-generate --target typescript`).
- `bindings/macos/reports/<app>/` — TestAnyware VM-verification evidence (screenshots,
  `report.md`, `bundle-report.md`) per sample app.
- `app-implementations/macos/<app>/` — sample app implementations; each carries its own
  `learnings.md` (per-target-per-app realization notes) and `build.sh`.
- `docs/` — co-located target documentation (see above).
