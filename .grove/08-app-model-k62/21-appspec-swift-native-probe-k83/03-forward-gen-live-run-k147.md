# forward-gen-live-run-k147

**Kind:** work

## Goal

The **merged** forward-gen + Tier-2 live-run stage for swift-native-probe — the leaner
3-child-node design (the parent brief child 3; forward-gen-suite + live-run merged given
~3 scenarios, unlike the richer apps' split k138/k139). Two halves in one session:

1. **Forward-gen** the `#lang app-spec` scenario suite + `run-values.rkt` from the k141
   spec + contracts, via the AppSpec forward-gen workflow
   (`~/Development/AppSpec/capabilities/forward-gen/workflow.md`). Suite homes at
   `apps/macos/swift-native-probe/scenarios/`.
2. **Tier-2 live-run** the suite against **all four impls** in a macOS VM (AppSpec run
   workflow `~/Development/AppSpec/capabilities/run/workflow.md`; the runner *consumes*
   the downstream suite across the boundary — ADR-0013, never copies), adjudicate every
   red, and record the cross-impl verdict table + per-impl findings in
   `apps/macos/swift-native-probe/docs/run-results.md`. **This is the node's done-bar**
   ([[vm_verify_every_app]] — CLI smoke never satisfies it); **eighth and last app**
   through the toolkit. Its retirement empties `appspec-swift-native-probe-k83` (cascade
   check up to `app-model-k62`, whose next live sibling is `apps-layout-finalize-k84`).

**May decompose on entry** (the standing pattern — `leaf-decompose`, first child only) if
one session proves too big; the lean design intends one pass (the suite is small and the
window is static — see below).

## Context — this app is a STATIC coverage-proof window (the log carries the proof)

Unlike the seven richer precedents, the probe has **no coordinate-driven controls, no
strokes, no panels, no fixtures** — it opens a fixed window of read-only labels and blocks.
So (per the k141 right-sizing decision + `observable-state.md`):

- **The coverage proof lives in the LOG, not the window.** The two universal, **byte-identical
  across all four impls** log assertions are the suite's spine: `[probe] complete count=<n>
  ok=<n> all-ok=#t` (matcher `#px"\\[probe\\] complete .*all-ok=#t"` — the single
  target-agnostic coverage assertion; `count` is 2 for racket/chez/gerbil, 5 for sbcl, but
  `all-ok=#t` is universal) and the bare launch line `Swift-Native Probe opened.` (matcher
  `#rx"Swift-Native Probe opened\\."` — **identical in events.log across all four**, even
  though sbcl's *stdout* echo differs; stdout is discarded under `open`). `[lifecycle]
  startup` is the `wait-ready` readiness probe.
- **The window carries only STRUCTURAL assertions:** title `Swift-Native API Coverage`
  (**exact, all four** — the one exact cross-impl window fact); a target-named heading
  substring (projection-free — "…via libAPIAnyware<Target> trampolines"; match a stable
  substring like `trampolines`, or per-impl expected, **never** the exact library name as a
  cross-impl assertion); a footer stable substring (2-shape: "objc_exposed"/"@_cdecl
  trampolines"; sbcl's footer wording differs); ≥1 name→value row present.
- **sbcl is a DIFFERENT app** (the load-bearing k141 finding): 5-shape, window **640×300**,
  different heading/footer wording, merges the method/init slice. racket/chez/gerbil are
  2-shape, **560×240**. The suite must be target-agnostic: the `all-ok=#t` summary + the
  launch line + the exact title hold for all four; per-shape rows and window size are
  per-target realizations. Bind the *proof*, not the coverage set.

## Handoffs from `instrument-builds-k142` (see the parent BRIEF's outcomes section)

- **Emission is byte-identical across the shared-layout three (racket/chez/gerbil)** modulo
  the non-deterministic `timestampSeed` value line — so ONE target-agnostic assertion set
  binds all three; the `timestampSeed` value is matched **structurally** (a number), never
  by value.
- **Descriptors** at `targets/<t>/app-implementations/macos/swift-native-probe/swift-native-probe-impl.rkt`
  (`com.linkuistics.swift-native-probe-<impl>` at `/Applications/SwiftNativeProbe-<impl>.app`;
  events under `/tmp/swift-native-probe/`; `#:launch-via 'open`).
- **Four built `.app`s** (bundle sizes: racket 67M, chez 4.9M, gerbil 56M, sbcl 92M). Each
  `build.sh` is CLI-smoke-green on the full k141 contract; `AW_PROBE_SMOKE` is the headless
  gate.
- **gerbil-only smoke artifact (does NOT affect the live VM):** under `AW_PROBE_SMOKE` the
  gerbil bundle emits the probe/complete/launch block **doubled** (module top-level `(main)`
  + the `gxc -exe` entry's exported-main call, both returning without a run loop). In the
  real VM GUI run main#1 blocks in `nsapplication-run` and the process `exit()`s on
  terminate → the events.log is **single + clean**. Do not be alarmed by a doubled
  build-time smoke log; the runner tails a fresh truncated log per scenario.
- **Menu-bar title divergence:** gerbil's menu bar reads `Swift Native Probe` (no hyphen)
  vs the others' `Swift-Native Probe`. This is a *menu-bar* fact, not an events.log one —
  prefer the AX window title (`Swift-Native API Coverage`, exact ×4) / log channels over a
  cross-impl menu-bar OCR assertion; or fold the per-impl title in (the pdfkit/gallery
  precedent).
- **shutdown reason=menu delegate wired ×4 but unexercised by CLI-smoke** — scenario 02
  (Command-Q) is its first real exercise (all four ignore SIGTERM under `nsapplication-run`,
  the k88/k94 finding — the menu-quit path is the one that works; `pkill -9` for teardown).

## The ~3 scenarios (parent brief child 3)

1. **`01` steady-state / all-probes-pass** — launch → `wait-ready` on `[lifecycle] startup`
   → `wait-for-log` on `[probe] complete .*all-ok=#t` + `Swift-Native Probe opened.` → the
   window structural assertions (title exact; heading/footer substrings; ≥1 row).
2. **`02` command-q-terminates** — Command-Q → `[lifecycle] shutdown reason=menu` → process
   exits (the mandated invariant; `quit-impl!` escalates to `pkill -9`, the scenekit
   `611f73c` precedent).
3. **`03` close-keeps-running** — click the window close button → **process keeps running**
   (no terminate-on-close delegate; the hello-window §3.8 / five-prior-apps finding). Needs
   the close-button coordinate (the only geometry the suite needs) — measure per impl
   (sbcl's 640×300 window differs from the 560×240 three).

## Run-mechanism residuals to adjudicate against (never patch the suite — D4)

The standing classes from the prior seven apps (full catalogue in the parent-of-parent
`app-model-k62` outcomes): the **k103 OCR small-text class** (title-bar garble on racket's
compact 22px metrics — the AX window title is the firm channel; prefer AX-exact over
whole-screen OCR); the **k94 delayed-truncate residual** (a scenario after a failure hits an
empty-log red with the app provably up → re-run solo); **SIGTERM ignored** under
`nsapplication-run` (`pkill -9`); the **Tahoe notification-banner** OCR-pollution gotcha
(dismiss by hover + close-X). A `recording:` / spec-quality red is adjudicated, not a suite
bug.

## Done when

- The `#lang app-spec` suite + `run-values*.rkt` committed under
  `apps/macos/swift-native-probe/` (validated per the forward-gen workflow: coverage-or-gap
  complete, two-run consensus plan stated).
- All four impls run the suite in a live VM with **every red adjudicated** (impl defect /
  spec finding / run-mechanism class — each named); `docs/run-results.md` records the
  outcome table + per-impl findings + the promoted swift-native-probe outcomes for the node.
- Any run-mechanism toolkit fix the run forces is committed **AppSpec-side** with a note here
  (app data — suite, run-values, run-results — homes **here**, ADR-0052).
- Commits name `forward-gen-live-run-k147`.

## Notes

- **Inputs, all in place:** the k141 `docs/{spec,logging-contract,observable-state}.md`; the
  four instrumented+built impls (`instrument-builds-k142`); the AppSpec toolkit
  (`~/Development/AppSpec`, three capabilities).
- Template: the note-editor (k129) / drawing-canvas (k138/k139) suites + the pdfkit k102
  exemplar rules (hard vs `recording:` cluster split, `;; spec:` per-assertion tracing,
  two-run consensus for a suite gating four impls). This app is *simpler* than all of them
  (static window) — the suite should be the smallest in the portfolio.
- Never run the GUI from the CLI ([[use_testanyware]]); the live verify is TestAnyware/VM.
