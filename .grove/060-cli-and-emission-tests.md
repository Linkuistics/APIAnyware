# 060-cli-and-emission-tests

**Kind:** work

## Goal

Register `gerbil` as a CLI target and add emission (golden) tests for `emit-gerbil`.

## Context

Design: `docs/specs/2026-06-03-gerbil-target-design.md` §1, §8. The CLI knows only
targets (one binding style per target, no paradigm axis — ADR-0004). Reference:
how `chez` is registered in the generate CLI + chez's emission/golden tests.

## Done when

- `apianyware-macos-generate --target gerbil` resolves and drives `emit-gerbil`.
- Emission tests assert the generated Gerbil is well-formed and matches goldens
  for a representative framework subset (goldens-as-truth, per the racket/chez
  precedent; enriched IR may be gitignored — snapshot tests skip-as-pass without
  local IR).
- `cargo test` green for `emit-gerbil`.

## Notes

Keep the gerbil target hermetically separate (ADR-0011) — no shared substrate with
racket/chez beyond the IR.
