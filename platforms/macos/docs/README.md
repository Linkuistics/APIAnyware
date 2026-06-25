# platforms/macos/docs/ — macOS platform documentation

Per the documentation-placement rule (REFACTOR.md §10: "documentation lives with
its subject"), macOS platform docs live here — the prose explaining how the macOS
source platform is described, extracted, annotated, and tested.

## The platform-model prose

Read in order:

1. **[`overview.md`](overview.md)** — what the `platforms/macos/` domain is: the
   platform-as-meaning rule, the platform/semantic and platform/target boundaries,
   the four sub-models (manifest, `api/`, `app-kinds/`, `tests/`), and the
   platform-neutral shape that absorbs a second platform.
2. **[`api-extraction.md`](api-extraction.md)** — how a family's spec triad
   (`extracted.json` / `annotations.apiw` / `resolved.json`, ADR-0046) is produced
   by the `collect → analyze → generate` pipeline. A map over the authoritative
   `../api/README.md` + `collection.md`.
3. **[`app-kinds.md`](app-kinds.md)** — the seven kinds of macOS application a
   target can build (process-model truth, ADR-0049), and how an app-kind differs
   from an app-spec and a pattern-kind. A map over `../app-kinds/README.md`.
4. **[`testing-obligations.md`](testing-obligations.md)** — the two platform-level
   test-declaration families and the declare-now / execute-later seam. A map over
   `../tests/README.md`.

The terse vocabulary is in `CONTEXT.md → "Platform model"`; the decisions are the
running log in the `platform-model-k32` grove brief, with
[ADR-0046](../../../adr/0046-spec-interchange-format-kdl-everywhere.md) (the `.apiw`
overlay) and [ADR-0049](../../../adr/0049-app-kinds-as-distinct-platform-process-model-entity.md)
(app-kinds as a distinct entity) the two that earned an ADR.

## Operational prose (pre-existing)

This directory also holds operational docs that predate the platform-model
documentation:

- **[`collection.md`](collection.md)** — extraction/collection learnings (libclang
  pitfalls, availability filtering, the Swift-overlay-name unification, the
  synthetic-framework pattern).
- **[`annotation-workflow.md`](annotation-workflow.md)** — the LLM analysis
  side-channel over the committed `annotations.apiw` overlay (ADR-0050): the spec
  triad, §28 source precedence, live staleness detection (`annotations stale`), the
  resolve-time disagreement audit (`annotations audit`), and git-as-accept. The
  *when to run* cadence is once per SDK update.
- **[`annotation-subagent-prompt.md`](annotation-subagent-prompt.md)** — the prompt
  `/analyze` dispatches to one Claude Code subagent per stale family to re-author
  its `annotations.apiw` over the structural annotatable shape.
- **[`codesigning-identity.md`](codesigning-identity.md)** — the persistent local
  code-signing identity that keeps sample-app CDHashes (and TCC grants) stable
  across rebuilds.
