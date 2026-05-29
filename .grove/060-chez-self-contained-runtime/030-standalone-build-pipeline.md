# 030-standalone-build-pipeline

**Kind:** work

## Goal
Productionise the spike's hand-driven scripts into `bundle-chez`: a new
`standalone.rs` module that builds a self-contained open-world `.app` for a chez
sample app. End state: `bundle_app(spec, source_root, output_dir)` produces a
`hello-window` `.app` that **launches and draws its window with no system Chez**,
built entirely through the Rust bundler (not shell scripts).

## Context
- Authoritative recipe + every gotcha: the spike report
  `docs/research/2026-05-29-chez-standalone-spike.md` (build pipeline §, findings
  F2–F9) and the design spec `docs/specs/2026-05-29-chez-standalone-distribution-design.md`
  (§2 pipeline, §3 wrapper, §4 prelude, §5 layout, §6 crate shape).
- Spike repro sources are committed under
  `docs/research/2026-05-29-chez-standalone-spike-evidence/` (`embed_main.c`,
  `hw-entry.ss`, `build_whole.sh`, `link_standalone.sh`, `assemble_app.sh`) —
  port these into the bundler, don't reinvent.
- `bundle-chez` today (`bundle.rs`, `deps.rs`, `launch.rs`, `precompile.rs`,
  `spec.rs`): the deps walker is reused; the wrapper generator builds on it.
- **Single mode** (D6 / ADR-0009): build open-world only. No build-mode enum.
- Idiom posture: [[feedback-chez-target-idiomatic-not-portable]].

## Done when
- `standalone.rs` runs the spec §2 pipeline end-to-end from Rust:
  whole-program compile → `make-boot-file` (full scheme boot) → `cc`-link
  `embed_main` + `libkernel.a` (+ `liblz4.a`/`libz.a`; **not** `main.o`, F9) →
  assemble `.app` → codesign. Kernel-artifact paths discovered from the host
  Chez install (build-time dependency; documented for `060`).
- **Top-level-program wrapper generator (F2, spec §3):** the bundler computes the
  duplicate-import collision set from the app's import closure (reuse `deps.rs` +
  an `environment-symbols` probe) and emits `(except <facade> <names>…)` clauses
  so framework facades yield to `runtime/objc` and `(chezscheme)`. App authors
  keep `--script`-style entries.
- **Dylib-search prelude (F3, spec §4):** a prelude object linked ahead of the
  app sets `(library-directories)` to an exe-relative `../Resources` path — no
  `chdir`, no `--libdirs` stub.
- **Layout + signing (F4/F5, spec §5):** boot + `lib/libAPIAnywareChez.dylib`
  under `Contents/Resources/`; `codesign --verify --strict` passes; unique
  CDHash per app under `APIAnyware Local Signing`.
- **Banner suppression (F6):** `(suppress-greeting #t)` before `Sscheme_start`.
- `hello-window` built via `bundle_app` launches and draws its window in a
  no-Chez VM ([[feedback-use-testanyware]]). (Full portfolio VM-verify is `050`.)
- Source-exec path **left working** alongside the new path — its deletion is
  `040` (never without a green path).

## Notes
- May decompose into a node if the Rust orchestration + wrapper-gen + prelude
  prove too big for one focused session.
- Keep racket untouched — the stub-launcher is shared crate surface.
- Regenerate/rebuild aggressively after pipeline changes
  ([[feedback-regenerate-pipeline-aggressively]]).
</content>
