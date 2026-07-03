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
2. **`instrument-builds-k142`** ✅ *(node, complete 2026-07-04 — decomposed per-impl on
   entry; see **instrument-builds outcomes** below)* — instrumented all four impls to the
   k141 contract (per-shape correctness check + `[probe]` events + events-log + lifecycle
   triad), rebuilt ×4, CLI-smoked. Decomposed per-impl (`sbcl-impl-k143`, `racket-impl-k144`,
   `chez-impl-k145`, `gerbil-impl-k146`) because CreateML was absent from this worktree's
   corpus/bindings/dylibs for the Scheme trio (a false "no corpus regen" premise) → each
   needed a targeted per-target CreateML bring-in.
3. **`forward-gen-live-run-k147`** *(grown 2026-07-04 on `gerbil-impl-k146` retirement)* —
   the ~3-scenario forward-gen suite (steady-state/all-probes-pass · command-q-terminates ·
   close-keeps-running) + run-values, then Tier-2 live-run all four impls →
   `docs/run-results.md`. **[live; closes this node's Done-when]**

## instrument-builds outcomes (promoted from `instrument-builds-k142` on retirement)

All four impls emit the full k141 contract, each CLI-smoke-green + built to a suffixed-id
`.app`. The durable handoffs `forward-gen-live-run-k147` consumes:

- **Emission is byte-identical across the shared-layout three (racket/chez/gerbil)** modulo
  the non-deterministic `timestampSeed` value line — the coverage-proof structure is
  universal; only the live seed differs. So the forward-gen suite binds **one target-agnostic
  assertion set** (`[probe] complete …all-ok=#t` + the bare `Swift-Native Probe opened.`
  launch line, both byte-identical ×4; `timestampSeed` matched structurally, never by value).
  **sbcl is a different app** (5-shape, 640×300, different heading/footer wording) — its
  `all-ok=#t` + launch line + exact title `Swift-Native API Coverage` still hold; per-shape
  rows + window size are per-target realizations.
- **Emitter shape:** racket uses a separate `events.rkt` module; chez/gerbil emit **inline**
  (`snp-` helpers, the drawing-canvas house style) built from bare host primitives so they
  ride the statically-linked prelude; sbcl uses an `events` package. Structural
  `timestampSeed` ok-check is `(integer?+exact?)` (Schemes) — never value-equality.
- **Descriptors** at `targets/<t>/app-implementations/macos/swift-native-probe/swift-native-probe-impl.rkt`
  (`com.linkuistics.swift-native-probe-<impl>` at `/Applications/SwiftNativeProbe-<impl>.app`;
  events under `/tmp/swift-native-probe/`; `#:launch-via 'open`). **New `build.sh` authored
  for each of the four** (none existed); each self-heals the per-target CreateML bring-in
  (generate `--target <t>` + `swift build --product` relink, reusing the shared corpus racket
  k144 brought into `platforms/macos/api/CreateML/`; collect/analyze only if the corpus is
  also absent — targeted, additive, **goldens unmoved**).
- **Four bundle sizes:** racket 67M (raco distribute), chez 4.9M (whole-program compile),
  gerbil 56M (`gxc -exe` whole-closure), sbcl 92M (save-lisp-and-die).
- **gerbil-only smoke artifact (does NOT reach the live VM):** under `AW_PROBE_SMOKE` the
  gerbil bundle emits the probe/complete/launch block **doubled** (module top-level `(main)`
  + the `gxc -exe` entry's exported-main call, both returning without a run loop). In the
  real VM GUI run main#1 blocks in `nsapplication-run` and the process `exit()`s on
  terminate → the events.log is single + clean.
- **Menu-bar title divergence:** gerbil's menu bar reads `Swift Native Probe` (no hyphen) vs
  the others' `Swift-Native Probe` — a menu-bar fact, not an events.log one. Prefer AX window
  title / log channels over a cross-impl menu-bar OCR assertion.
- **shutdown reason=menu delegate wired ×4 but unexercised by CLI-smoke** (exits before the
  run loop) — scenario 02 (Command-Q) is its first real exercise (all four ignore SIGTERM
  under `nsapplication-run`; the menu-quit path is the working one).

## Done when (node complete)

All four impls run the forward-gen suite green in a live VM ([[vm_verify_every_app]] —
CLI smoke never satisfies the done-bar); `docs/run-results.md` records the outcome table +
per-impl findings; the right-sizing rationale is recorded in the spec. Commits name the
child handles.
