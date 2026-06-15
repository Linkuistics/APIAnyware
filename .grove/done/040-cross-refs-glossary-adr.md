# 040-cross-refs-glossary-adr

**Kind:** work

## Goal

Repair every reference broken by the moves in 020/030, verify the glossary
against the final layout, and write the co-location ADR.

## Context

Per PRD `docs/prd/2026-06-14-docs-restructure-main-and-per-language.md`. Runs
after the file moves (020, 030) so the new paths are stable.

## Done when

- Every internal markdown link broken by the moves is fixed (relative links
  between docs, links into docs from code READMEs).
- Code/README pointers updated: root `README.md`, per-target `README.md`s, any
  `CLAUDE.md`/memory pointers, references to the old `knowledge/` rules.
- `CONTEXT.md` glossary terms ("Main docs / main tier", "Per-language docs /
  co-located target docs", added in the 010 planning session) verified against
  the final layout and corrected if any path drifted.
- New ADR written: **"Per-language docs co-locate in the target unit; ADRs stay
  central"** (next free number after 0023). Extends ADR-0011 to docs; records
  the ADR-as-exception rationale (connected cross-target decision graph). Cite
  the PRD.

## Notes

Leaf 050 (authoring guide) and 060 (verification) follow. Keep the ADR atomic —
the decision, alternatives rejected (per-target renumbering; central docs/targets
tree), and consequences.
