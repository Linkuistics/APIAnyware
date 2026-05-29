# 030-adopt-racket-9.2-toolchain

**Kind:** work

## Goal
Provision and pin Racket 9.2 (with `ffi2-lib` installed) as the toolchain this
target builds and runs against, so leaf 040's ffi2 code can actually be built
and verified.

## Context
- Depends on 020's "Toolchain/install" finding for the canonical provisioning
  method (Homebrew formula? official installer? `raco pkg install ffi2-lib`).
- Repo has no Racket version pin today (grep found none) — this leaf introduces
  one wherever the project expects it (CI, dev docs, bundler assumptions).
- `generation/targets/racket/lib/libAPIAnywareRacket.dylib` is a symlink into
  `swift/.build/...`; confirm it rebuilds cleanly under the new toolchain.
- Standing constraint: `SDKROOT=macosx` workaround for collect/extract/build.

## Done when
- Racket 9.2 is installed and discoverable; `ffi2-lib` is installed
  (`raco pkg show ffi2-lib` succeeds).
- The version is pinned/documented wherever the project records toolchain
  versions (and CI if applicable).
- `libAPIAnywareRacket` and the generated bindings build under 9.2 (a green
  build; ffi2 migration of the *code* is 040's job, not this leaf's).

## Notes
- This leaf is about the *environment*, not the FFI code. If something in the
  existing `ffi/unsafe` code fails to load under 9.2, note it for 040 rather
  than fixing it here — we are going straight to ffi2, not maintaining old ffi.
