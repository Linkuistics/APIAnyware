# spec-and-contracts-k141

**Kind:** work

## Goal

The reverse-gen + conformance-data stages for **swift-native-probe**, merged into one
right-sized session (the probe is 1/7; both docs are thin). Produce, under
`apps/macos/swift-native-probe/docs/`:

1. **`spec.md`** — the projection-free spec, reverse-generated from the four VM-verified
   impls (replaces the current racket-centric one in place). Its invariant is the
   **coverage-proof structure**, not the CreateML symbol set; the sbcl 5-shape vs
   racket/chez/gerbil 2-shape divergence is expressed as a **rule** (the coverage set is a
   per-target realization; the all-probes-pass proof is universal). Records the
   **right-sizing rationale** (parent brief "Right-sizing decision").
2. **`logging-contract.md`** — the porting-guide event vocabulary every impl must emit:
   the lifecycle triad (hello-window k67 template: `[lifecycle] startup`, a
   `Swift-Native Probe opened.` launch diagnostic, `[lifecycle] shutdown reason=<r>`) +
   per-shape `[probe]` events (each carrying `name`, `ok=<bool>` vs a known-good expected,
   and the live `value`) + a summary `[probe] complete count=<n> ok=<n> all-ok=<bool>`.
   The `all-ok` summary is the target-agnostic coverage assertion the suite consumes.
3. **`observable-state.md`** — what the VM observes of a conformant build: process
   running; window title `Swift-Native API Coverage` (exact, all four); heading/footer
   stable substrings (projection-free — never the per-target library name exact); ≥1
   name→value row present; Command-Q terminates; close-button keeps the process running
   (the hello-window §3.8 finding — all four impls, no terminate-on-close delegate).

## Context

- **Inputs read (reverse-gen step 1):** all four impls
  (`targets/{racket,chez,gerbil,sbcl}/app-implementations/macos/swift-native-probe/`); the
  `gui-app` app-kind contract (`platforms/macos/app-kinds/gui-app/kind.apiw` — the top
  anchor: activation `regular`, termination `ns-application-terminate`); the precursor
  `apps/macos/swift-native-probe/docs/spec.md` (lowest anchor — over-claims by being
  racket-specific). Templates: `apps/macos/hello-window/docs/{spec,logging-contract,
  observable-state}.md` (the closest-complexity worked exemplar).
- **Reverse-gen discipline** (AppSpec `capabilities/reverse-gen/workflow.md`): the spec
  captures only what is true of **all** impls; differences are realizations to drop or
  facts to express as rules. Over-claiming is the dominant failure mode — keep gaps honest
  ("to confirm in-VM"). The `reverse-gen` subagent type is not registered in this worktree;
  for a 1/7 probe whose impls are already read, author directly with the discipline.
- **The load-bearing reverse-gen finding** (parent brief): sbcl is a *different* app
  (5-shape, 640×300, merges the method/init slice) from racket/chez/gerbil (2-shape,
  560×240). The spec's abstraction must survive that; the logging contract's `all-ok`
  summary is what makes the suite target-agnostic. Note (don't absorb) the
  `swift-native-method-probe` sibling — its own-spec question is k85's.
- **Why a log file** (hello-window logging-contract): under `open` (LaunchServices) stdout
  is discarded; the runner tails an `events.log`. So the existing per-impl `printf`/
  `displayln`/`format` to stdout is NOT enough — instrument-builds (k<next>) adds the
  events-log emission. This child only **specifies** the contract; it writes no impl code.

## Done when

- `docs/spec.md`, `docs/logging-contract.md`, `docs/observable-state.md` authored, all
  projection-free, all consistent with the four impls + the `gui-app` anchor.
- The right-sizing rationale is in `spec.md`.
- No impl file touched, no bundler change (the display-name H1 read still resolves — keep
  the first H1 = display name).
- Committed naming `spec-and-contracts-k141`.

## Notes

- Skeleton-first: docs only, no scenario suite, no instrumentation (those are the next two
  children).
- The bundlers read the display name from `docs/spec.md`'s first H1 (`bundler-reshape-k61`)
  — keep the first H1 exactly the display name (`Swift-Native Probe` or `Swift-Native API
  Coverage`; match what the bundlers/impls expect — check before renaming).
