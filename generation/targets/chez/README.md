# Target: chez

Chez Scheme bindings for macOS system APIs — idiomatic Chez (Chez extensions
preferred over R6RS-only forms), self-contained `.app` distribution, native
binding via Chez's FFI/embedding C-API.

## For developers and maintainers

- [`docs/reference.md`](docs/reference.md) — target-wide, written-after-the-fact
  learnings; covers only what is *chez-specific* and was surprising in practice.
- [`docs/design/`](docs/design) — per-target design specs (target design,
  standalone distribution, native binding).
- [`docs/research/`](docs/research) — spikes and evidence (standalone build,
  dispatch/threading).

For cross-cutting context shared by all targets, read the main `docs/` tier
(pipeline, app-portfolio specs, emitter-contract, ADRs 0010/0011).

## Target structure

- `apianyware/` — Chez runtime modules
- `apps/` — sample app implementations; each `apps/<app>/` carries a
  `learnings.md` (per-target-per-app realization notes)
- `lib/` — Swift dylib symlink
- `docs/` — co-located target documentation (see above)
- `test-results/` — TestAnyware evidence (screenshots, reports)
