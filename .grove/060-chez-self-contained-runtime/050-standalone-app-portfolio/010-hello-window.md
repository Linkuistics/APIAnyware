# 010-hello-window

**Kind:** work

## Goal
Re-verify `hello-window` as a **production** open-world standalone `.app` (built
through the real `bundle_app` path, not the spike scaffolding) and confirm it
launches + renders correctly in a no-Chez VM.

## Context
- Baseline app: class construction + accessor procedures, no dispatch (spec §7).
  Its closed-world half drove the spike; `030` productionised the open-world
  pipeline against it. This leaf is the **regression anchor** — if the production
  bundler diverged from the spike, it shows here first, on the simplest app.
- Wrapper collision set is the known 4 (spike F2). No new collisions expected.

## Done when
- `hello-window.app` builds via `bundle_app` (open-world standalone).
- TestAnyware run in a no-Chez VM is green: window appears, title correct, no
  banner/console noise (F6).
- Any divergence from the spike build is noted in `knowledge/targets/chez.md`.

## Notes
- Smoke-launch from the CLI is **not** sufficient ([[feedback-use-testanyware]]);
  the no-Chez VM run is the bar.
