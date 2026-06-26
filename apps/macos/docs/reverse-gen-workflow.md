# Reverse-gen workflow — generating an app spec from its implementations

This is the **bootstrap** reverse-gen workflow (ADR-0052): how APIAnyware produces a
common, target-independent **app spec** from an app's existing implementations *today*,
inside Claude Code, **pending** the external AppSpec project's own reverse-gen tooling.
It is also a **format-input seed** for the AppSpec grove (`~/Development/AppSpec`) — that
grove will generalize reverse-gen into the toolkit; until then, Claude Code subagents
are the LLM-driven tooling (the standing economic constraint that LLM-driven generation
runs inside Claude Code).

**Worked exemplar:** `apps/macos/hello-window/docs/spec.md` — the first spec produced by
this workflow (`reverse-gen-exemplar-k64`).

## What reverse-gen is

Point at an app's existing, VM-verified implementation(s) → LLM-generate a
**projection-free, replication-grade specification** detailed enough that another
engineer or an LLM could re-implement the app in *any* language and get a behaviourally
identical result. The durable human-adjacent artifact is the **spec**, not a hand-written
test suite (forward-gen produces suites later, from the spec). Git is the
propose → review → accept boundary — the ws5 side-channel philosophy (ADR-0050) applied
to app specs.

## The loop (one app)

1. **Read all implementations.** The four targets each ship a VM-verified impl at
   `targets/<t>/app-implementations/macos/<app>/`. Read *every* one: the spec captures
   only what is true of **all** of them; anything that differs across impls is either a
   projection detail to drop or a fact to express as a **rule** (see below). Also read
   the precursor prose under `apps/macos/<app>/docs/` (`spec.md`, `learnings.md`,
   `test-strategy.md`) — these are hand-authored precursors the generated spec upgrades,
   and may contain *over-claims to correct* (see the hello-window lesson).
2. **Generate (subagent).** Dispatch a subagent with the reverse-gen prompt (shape
   below) and the input paths. It returns the complete spec markdown **plus modeling
   notes** for the reviewer — it does not write files.
3. **Human-validate.** Review the returned spec and the modeling notes; reconcile every
   cross-impl disagreement and every claim not grounded in source against an authoritative
   anchor (the platform **app-kind**, the API surface, the source). Correct, then write
   the spec to `apps/macos/<app>/docs/spec.md`. The commit *is* the human-acceptance
   boundary (ADR-0050).

## The reverse-gen prompt (shape)

The subagent prompt must enforce:

- **Projection-free.** Describe *what* the app does and means — never how a
  target/language expresses it. No language idiom, function names, or FFI mechanics. Any
  fact that varies across impls becomes a **rule**, not a realization (e.g. the window
  title `"Hello from Racket"` / `…Chez` / `…Gerbil` / `…SBCL` → the rule
  `"Hello from " + <implementation identity>`).
- **Bundler-safe first line.** The spec's first markdown H1 must be the app **display
  name** (`# Hello Window`) and nothing may precede it but blank lines — the bundlers read
  the display name from that first H1 (`apps/macos/<app>/docs/spec.md`).
- **Structural-facts header (prose, near the top).** app-kind (the
  `platforms/macos/app-kinds/` instance it names), display name, complexity, API
  frameworks, the pattern-kinds it exercises. Prose, not a machine manifest (lazy — a
  machine manifest is authored only when a real consumer needs one, ADR-0052/D3).
- **Replication-grade coverage** (REFACTOR §15 concept list): purpose/intent, app-kind &
  lifecycle, window/control layout *with the why* of each property, the application menu,
  the **API surface** as a table of Objective-C selectors (these are platform truth →
  projection-free), the API-usage patterns, observable outcomes, accessibility
  expectations.
- **Behavioural exemplar / acceptance (§7.8).** Enumerate the app's verifiable
  behaviours as *observable* assertions mapped to the AppSpec scenario-runner verbs
  (`expect-ocr`, `expect-ax`, `expect-running-app`, `expect-log`/`wait-for-log`,
  `expect-file`; inputs `press`/`type`/`chord`/`click-at`/`move-mouse`; state
  `read-mru`/`kill-impl!`/`restart-impl!`; sync `wait`/`wait-for-ocr`). This is the
  forward-gen input — **enumeration only, no scenario code** (suites come from the
  AppSpec toolkit post-pause).
- **Provenance note.** A short italic line after the H1: reverse-generated (LLM) from the
  N existing VM-verified implementations on <date>, human-validated via git review.
- **Two-part return.** The complete spec markdown, then separately the **modeling
  notes**: the projection-free abstractions made, the cross-impl disagreements and how
  they were resolved, and what was deliberately left out as per-impl detail. The notes
  are the review aid; they do not go in the spec file.

## Lesson from the exemplar (why human-validation is load-bearing)

The hello-window precursor `spec.md` *and* `test-strategy.md` both claimed *"closing the
window terminates the app."* Reverse-gen across all four impls found that **none** of
them wire up `applicationShouldTerminateAfterLastWindowClosed:` (no app delegate at all),
and the **`gui-app` app-kind**'s termination model is `ns-application-terminate` (Quit via
`terminate:`), *not* last-window-closed. The generated-then-validated spec corrects the
over-claim: termination is **Quit-driven**, close-button behaviour is flagged for live-VM
confirmation. Reverse-gen's value is this **reconciliation across sources** (impl source +
platform app-kind contract + precursor prose), not transcription — and the authoritative
anchor for a behavioural claim is the platform truth (the app-kind), not the prose.

## Scope boundary

This produces the **spec** only. `#lang app-spec` **scenario suites** (forward-gen) and
the live-VM AppSpec-runner verification come from the AppSpec toolkit after this grove's
pause point (ADR-0052; node `app-model-k62`). The on-disk layout under
`apps/macos/<app>/` stays **format-flexible** until the AppSpec grove settles what a
"formal spec" is — so this workflow writes `docs/spec.md` in place and changes nothing
else.
