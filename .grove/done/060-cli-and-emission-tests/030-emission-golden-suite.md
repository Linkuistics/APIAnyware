# 030-emission-golden-suite

**Kind:** work

## Goal

Add an emission/golden test suite for `emit-gerbil`: snapshot the generated Gerbil for
a representative framework subset and pin it as committed goldens (goldens-as-truth).

## Context

Follows the racket/chez precedent. Two complementary layers:
- **Synthetic fixtures** (always run, no IR needed): the shared
  `apianyware_macos_emit::test_fixtures::build_snapshot_test_framework` rich TestKit
  fixture already drives racket's `generate.rs` integration tests — reuse it so gerbil
  emission is exercised in CI without any enriched IR on disk.
- **Real-framework goldens** (goldens-as-truth, enriched IR gitignored): snapshot a
  representative real subset; the test **skips-as-pass** when local enriched IR is
  absent (per `project_racket_enriched_ir_gitignored` — IR is 16-90 MB, not committed).

Check how racket/chez structure their snapshot tests + golden files before settling the
gerbil layout (likely a `tests/` integration test reading committed `.ss` goldens).

## What to do

- A golden/snapshot test asserting the generated Gerbil for the synthetic rich
  framework is well-formed and stable (facade + per-class `.ss` + data modules).
- Wire gerbil into the `all_emitters_handle_rich_framework`-style coverage in the CLI
  integration tests (currently asserts racket + chez = 2 emitters; gerbil makes 3).
- If a real-subset golden layer is added, gate it on local IR presence (skip-as-pass).

## Done when

- Emission tests assert well-formed gerbil output + match goldens for a representative
  framework subset.
- `cargo test` green across `emit-gerbil` and the CLI; CI stays green with no local IR.

## Notes

This leaf closes the node's done-bar. After it, retire the 060 node (promote any
durable decisions upward) and `pick` advances to 070 (bundle-gerbil).
