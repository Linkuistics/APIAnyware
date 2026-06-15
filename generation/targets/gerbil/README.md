# Target: gerbil

Gerbil Scheme bindings for macOS system APIs — Chez-convergent
`define-c-lambda` FFI, manifest-driven object model (dual `{}` / `:std/generic`
surfaces), self-contained `.app` distribution via the BOTTLE toolchain.

## For developers and maintainers

- [`docs/reference.md`](docs/reference.md) — target-wide, written-after-the-fact
  learnings; covers only what is *gerbil-specific* and was surprising in practice.
- [`docs/design/`](docs/design) — per-target design specs (target design).
- [`docs/research/`](docs/research) — spikes and evidence (FFI/dispatch,
  threading).

For cross-cutting context shared by all targets, read the main `docs/` tier
(pipeline, app-portfolio specs, emitter-contract, ADRs 0010/0011). Where the two
Schemes agree, the chez reference (`generation/targets/chez/docs/reference.md`)
is the companion read.

## Target structure

- `lib/` — Gerbil runtime modules (`lib/runtime/`) and Swift dylib symlink
- `apps/` — sample app implementations; each `apps/<app>/` carries a
  `learnings.md` (per-target-per-app realization notes)
- `docs/` — co-located target documentation (see above)
- `test-results/` — TestAnyware evidence (screenshots, reports)
