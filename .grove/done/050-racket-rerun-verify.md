# 050-racket-rerun-verify

**Kind:** work

## Goal

Close the racket vertical slice: **rerun the full pipeline** for racket after the
030/040 changes and **VM-verify** that Swift-native coverage works on real macOS.

## Context

"Regenerate aggressively" — after collection/analysis/generation changes, rerun
the whole pipeline, don't trust stale checkpoints. The project done-bar requires
**VM-verify via TestAnyware**, not a CLI smoke (see project feedback memories
`vm-verify-every-app`, `use-testanyware`, `sample-apps-perfect`).

## Done when

- Full `collect → analyse → generate` rerun for racket completes clean.
- A racket sample app that exercises a Swift-native API (or a dedicated probe) is
  **VM-verified via TestAnyware** in a macOS VM — visually confirmed, not just
  compiled.
- Any regressions in the existing ObjC surface ruled out (the IR change must not
  perturb the directly-bound majority).

## Notes

- If no existing racket sample app touches Swift-native APIs, add a minimal probe
  app or extend one — coordinate with the apps portfolio.
- This leaf validates ADR-0025's "Consequences" claims on real evidence (cf. D3:
  the model ADR stays stable; this is where the mechanism earns its keep).
