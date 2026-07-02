# appspec-swift-native-probe-k83

**Kind:** work

## Goal

The AppSpec treatment for **swift-native-probe** (the Swift-native API-coverage probe
app): decide the right-sized spec/suite for a probe whose character is *coverage
verification output*, not GUI richness — then apply it (reverse-gen, contracts,
suite, live-run) at that size.

## Context

- Same toolkit + homes as the sibling leaves (hello-window k64/k67–k74 the template;
  AppSpec `capabilities/*/workflow.md`; data at `apps/macos/swift-native-probe/` +
  per-target `app-implementations/macos/swift-native-probe/`).
- **Scope judgement is the first task**: the probe exists to exercise the
  Swift-native trampoline surface (ADR-0025..0032) and report, so its observable
  contract may be almost entirely the **logging contract** (probe results emitted as
  events) with a minimal window. A lean suite (launch → all-probes-pass event →
  Command-Q) may be the *correct* full treatment — right-sizing is the deliverable,
  not maximal scenario count. Decompose only if the chosen size demands it.
- `targets/*/app-implementations/macos/` also carries **swift-native-method-probe**
  with no `apps/macos/` dir; whether it merits its own spec or a note is
  `portfolio-coverage-tie-in-k85`'s call — do not absorb it here.

## Done when

All four impls run the suite green in a live VM ([[vm_verify_every_app]]);
`docs/run-results.md` authored; the right-sizing rationale recorded in the spec.
Commits name this handle (or child handles if decomposed).
