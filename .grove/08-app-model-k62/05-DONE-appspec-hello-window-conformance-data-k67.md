# appspec-hello-window-conformance-data-k67

**Kind:** work (cross-grove **record** — app data authored *into* this repo by the AppSpec toolkit grove
per ADR-0013; recorded here, not driven as an APIAnyware session)

## What this records

The **AppSpec toolkit grove** (`~/Development/AppSpec`, branch `appspec-toolkit`) is running to completion
during the `appspec-grove-pause-k66` pause. Its `impl-conformance-k23` node authors hello-window's app
data **into this worktree** (ADR-0013: AppSpec drives the run + holds no app data; the data's home is
APIAnyware). This leaf records the **first landing** — the conformance contract + descriptors, from
AppSpec leaf `contract-and-descriptors-k27`.

## Authored in this commit (the contract + descriptors landing)

- **`apps/macos/hello-window/docs/logging-contract.md`** — the per-app logging contract (porting guide):
  the impl writes a structured **events.log** (path from `$HELLO_WINDOW_EVENTS_LOG`, fixed default
  `/tmp/hello-window/events.log`), emitting `[lifecycle] startup`, the bare `Hello Window opened.`
  diagnostic, and `[lifecycle] shutdown reason=…`. De-Modalisered from the v1 contract
  (`AppSpec/docs/plans/2026-04-18-app-spec-v1.md` + `.../modaliser/.../lib/events.rkt`).
- **`apps/macos/hello-window/docs/observable-state.md`** — what the VM observes (spec §9/§10) mapped to
  runner verbs (process/OCR/AX), with the deferred gap-2/gap-3 observables flagged (not assertion
  preconditions).
- **`targets/<t>/app-implementations/macos/hello-window/hello-window-impl.rkt`** for `t ∈ {racket, chez,
  sbcl, gerbil}** — four `#lang app-spec/impl` descriptors, each `runner/main.rkt --impl`-loadable.
  Per-impl `#:name`/`#:bundle-id` (`com.linkuistics.hello-window-<impl>`)/`#:binary`
  (`/Applications/HelloWindow-<impl>.app`, VM install path); shared contract fields (`#:log-env
  HELLO_WINDOW_EVENTS_LOG`, `#:config-env HELLO_WINDOW_TEST_CONFIG`, `#:launch-via 'open`,
  `#:events-path`/`#:test-config-path` mirroring the impl's fixed defaults).

## Findings carried back (for APIAnyware on resume)

- **Spec §10 wording is imprecise** (flagged, not edited): it says the launch diagnostic is on *"Standard
  output"*, but the runner tails the impl's **events.log** (stdout is discarded under `open`). The impl
  emits to both; the verb mapping (`wait-for-log`) is correct. A deliberate human-reviewed §10 reword is
  optional future work — recorded in `logging-contract.md`.
- **The four impl sources already `displayln` `Hello Window opened.`** but only to stdout — they are
  **not yet conformant** (the runner needs it in events.log). The instrumentation lands in the AppSpec
  build children (below).
- A toolkit-side runner robustness fix (the `--impl` loader now resolves `#lang app-spec/impl` against
  AppSpec's own root, so a **downstream** descriptor loads) was made on the **AppSpec** side — no
  APIAnyware change.

## Still to land (later AppSpec children — separate commits/records into this repo)

`racket/chez/sbcl/gerbil-instrument-build-k28..k31`: each **instruments** its impl source to the logging
contract and **builds** it to a `.app` (bundle id `com.linkuistics.hello-window-<impl>`), then commits
the source change + build into this repo. Gerbil also needs the `gerbil-scheme` toolchain. The
forward-gen suite + per-app run-values config (AppSpec `03-forward-gen-suite-k24`) and the live VM run
(`04`/`05`) follow.

_Recorded as DONE on landing — this is a provenance record of completed cross-grove authoring, not pending
APIAnyware work; `appspec-grove-pause-k66` remains the live pick target. ADR-0013 (AppSpec drives the run,
homes the data here); ADR-0052 (no app data in the toolkit)._
