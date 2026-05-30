# 060-standalone-toolchain-docs

**Kind:** work

## Goal
Write the toolchain documentation for the chez self-contained build — the
**original requirement 2** ("document the tooling — and expect to build our
own"). A reader must be able to reproduce a self-contained `.app` from scratch:
what Chez artifacts are needed, where they come from, the exact build steps, and
the dev-repro recipe.

## Context
- Runs after `030`/`040`/`050` — documents the *final, verified* pipeline, not an
  aspiration. There is no turnkey Chez "produce a signed macOS `.app`" command;
  the path is the multi-step dance the bundler now automates.
- Source material: the design spec
  `docs/specs/2026-05-29-chez-standalone-distribution-design.md` (§2 pipeline,
  §4 prelude, §5 layout), the spike report's build-pipeline § and findings, and
  the shipped `standalone.rs`.
- This **feeds `070-rewrite-adding-language-target`**: that doc's
  bundler/distribution section must describe the self-contained model this node
  settled, so this leaf is its prerequisite (the node was sequenced ahead of 070
  for exactly this reason — node BRIEF Notes).

## Done when
- A toolchain doc (suggest `knowledge/targets/chez.md` distribution section, or a
  dedicated `docs/` page) covers:
  - the **required Chez kernel artifacts** (`petite.boot`, `scheme.boot`,
    `libkernel.a`, `liblz4.a`, `libz.a`, `scheme.h`) and where they come from
    (Homebrew Cellar path; how the bundler discovers them);
  - the **exact build pipeline** (whole-program compile → boot → cc-link →
    assemble + sign), with the F9 "don't link `main.o`" and F4 "boot under
    Resources" gotchas called out;
  - the **dev-repro recipe** — how to build one app's standalone `.app` by hand /
    via the bundler, and how to run it in a no-Chez VM ([[reference-testanyware-cli]]);
  - the build-time cost note (~160 s / ~1.6 GB whole-program compile per app) and
    that it is a bundler/CI cost, not user-facing.
- Cross-links: the doc points at ADR-0009 and the distribution design spec; stale
  source-exec / precompile docs are removed or marked superseded.

## Notes
- Same authoring bar as `knowledge/targets/racket.md` — short, opinionated,
  written-after-the-fact.
- Mermaid for any pipeline diagram, not ASCII ([[feedback-no-ascii-diagrams]]).
</content>
