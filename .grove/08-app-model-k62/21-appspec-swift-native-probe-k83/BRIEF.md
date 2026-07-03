# appspec-swift-native-probe-k83 — brief

**Kind:** node (was a work leaf; decomposed on entry 2026-07-04)

## Goal

The AppSpec treatment for **swift-native-probe** (the Swift-native API-coverage probe
app): decide the right-sized spec/suite for a probe whose character is *coverage
verification output*, not GUI richness — then apply it (reverse-gen, contracts,
suite, live-run) at that size. Eighth and **last** app through the toolkit (after
hello-window, ui-controls-gallery, pdfkit-viewer, scenekit-viewer, mini-browser,
note-editor, drawing-canvas).

## Context

- Same toolkit + homes as the sibling leaves (hello-window k64/k67–k74 the template;
  the seven richer precedents' promoted outcomes k77–k82 apply; AppSpec
  `capabilities/*/workflow.md`; data **here** per ADR-0052: spec/contracts/scenarios
  under `apps/macos/swift-native-probe/`, impl instrumentation under
  `targets/<t>/app-implementations/macos/swift-native-probe/`).
- **Scope judgement was the first task** — settled below (Right-sizing decision).
- `targets/*/app-implementations/macos/` also carries **swift-native-method-probe**
  with no `apps/macos/` dir; whether it merits its own spec or a note is
  `portfolio-coverage-tie-in-k85`'s call — do not absorb it here (only note the
  relationship: the sbcl probe *merges* that method/init slice into this one).

## Right-sizing decision (the deliverable — settled 2026-07-04 from the four impls)

Reverse-gen the four impls surfaced a **deep cross-impl divergence**, not a cosmetic one:

- **racket/chez/gerbil**: a **2-shape** probe — CreateML `timestampSeed()` (free fn) +
  `MLCreateErrorDomain` (constant). Window 560×240, byte-identical layout, identical
  footer, launch line `Swift-Native Probe opened.`.
- **sbcl**: a **5-shape** probe — `hypot(3,4)=5.0`, `NSNotFound`, `NSNumber(42).intValue`,
  `Scanner.scanUpToString`, `IndexSet` round-trip. Window 640×300, different footer
  wording, stdout `Swift-native results (all via libAPIAnywareSbcl trampolines):`. It
  **merges** the method/init slice the other three keep in the separate
  `swift-native-method-probe` app (spec §comments; 060 ladder design).

The **projection-free invariant** is therefore **not** the CreateML symbol set (a
per-target realization) — it is the **coverage-proof structure** (a gui-app window titled
"Swift-Native API Coverage"; a target-named heading "… via libAPIAnyware<Target>
trampolines"; name→value rows rendering **live** trampoline results; a footer noting the
symbols are Swift-native / no C symbol / reached via @_cdecl) plus an **all-probes-pass
proof obligation**. The specific coverage set is per-target; the *proof* is universal.

Right-size: a **logging-contract-centric lean suite** (the brief's own hypothesis —
"launch → all-probes-pass event → Command-Q"). The observable window carries only
structural assertions (title exact; heading/footer stable substrings; ≥1 live row); the
real coverage proof lives in the **log** — per-shape `[probe]` events (each with a
correctness check vs a known-good expected) + a summary `[probe] complete … all-ok=<bool>`
that a scenario asserts target-agnostically. Close-keeps-running holds on all four
(no terminate-on-close delegate). No new frameworks → **no corpus regeneration** in
instrument-builds (unlike drawing-canvas's CoreGraphics work): pure log-emission +
per-shape correctness checks + rebuild.

## Decomposed on entry (2026-07-04) — lean 3-child node, materialized lazily

Leaner than the rich apps' 5–6 children (reverse-gen + conformance-data merged into one
spec+contracts child; forward-gen + live-run merged, given ~3 scenarios). Grow the next
as each retires; a child may decompose further on entry (the standing pattern).

1. **`spec-and-contracts-k141`** — reverse-gen the projection-free spec (`docs/spec.md`
   replaced in place: the coverage-proof abstraction, the sbcl 5-shape vs 2-shape
   divergence as a rule, the right-sizing rationale recorded) + the logging contract
   (`docs/logging-contract.md`: lifecycle triad + per-shape probe events + all-pass
   summary) + observable-state (`docs/observable-state.md`). No impl churn, no bundler
   change (keep `spec.md`). Skeleton-first. **[this session]**
2. **`instrument-builds-k<next>`** — instrument all four impls to the k141 contract
   (per-shape correctness check + `[probe]` events + events-log + lifecycle triad),
   rebuild ×4, CLI-smoke. May decompose per-impl on entry (the k133/k124 mirror) —
   though the shared-layout three make one pass plausible. **[grown next]**
3. **`forward-gen-live-run-k<next>`** — the ~3-scenario forward-gen suite
   (steady-state/all-probes-pass · command-q-terminates · close-keeps-running) +
   run-values, then Tier-2 live-run all four impls → `docs/run-results.md`. **[grown last;
   closes this node's Done-when]**

## Done when (node complete)

All four impls run the forward-gen suite green in a live VM ([[vm_verify_every_app]] —
CLI smoke never satisfies the done-bar); `docs/run-results.md` records the outcome table +
per-impl findings; the right-sizing rationale is recorded in the spec. Commits name the
child handles.
