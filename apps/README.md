# apps/ — common target-independent app data

The `apps/` domain holds the **app-specific data** for each common application
(REFACTOR.md §8, §7.3, §15): descriptions of what an application *does*, shared across
all targets and free of any projection. Generated apps are conformance tests, not demos
(§7.8). Target *implementations* of these apps do **not** live here; they live under
`targets/<t>/app-implementations/<platform>/<app>/` (§16).

## The app spec is consumed from an external project, not minted here

An "AppSpec" is **owned by an external sibling project**, not by a grove-native `.apiw`
entity (ADR-0052, REFACTOR §34). Three layers, three repos:

- **TestAnyware** (`~/Development/TestAnyware`) — the VM-automation substrate.
- **AppSpec** (`~/Development/AppSpec`) — the LLM-driven **spec/test toolkit + formats**
  (the scenario language, harness/Driver/runner, generators, TestAnyware SDK). *Holds no
  app data.* APIAnyware **consumes/references** it.
- **APIAnyware** — this `apps/<platform>/<app>/` tree holds each app's data; the
  implementations live under `targets/`.

The data per app: a description/spec/PRD, generated-and-validated test suites, and
contracts — authored against AppSpec's format(s) and run by its runner over TestAnyware.
They are produced **LLM-driven, human-in-the-loop** (reverse-gen a spec from an existing
implementation → human-annotate → forward-gen suites → human-validate → run against any
impl), the ws5 git-as-review-boundary philosophy (ADR-0050) applied to apps.

See `apps/macos/README.md` for the macOS app catalogue and `CONTEXT.md` (*App model /
AppSpec*) for the vocabulary.

> **Status (workstream 7):** the relationship + boundary + vocabulary are settled
> (ADR-0052). The concrete on-disk **file layout** under `apps/macos/<app>/` is left
> *format-flexible* until the AppSpec grove settles what a "formal spec" is — so it is
> deliberately **not** finalized here.
