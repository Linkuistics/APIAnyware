# apps/ — common target-independent behavioural exemplars

The `apps/` domain holds common AppSpec definitions (REFACTOR.md §8, §7.3, §15):
descriptions of what an application *does*, shared across all targets and free of
any projection. Generated apps are conformance tests, not demos (§7.8) — an
AppSpec here is the behavioural contract that every target's implementation must
satisfy. Target *implementations* of these specs do **not** live here; they live
under `targets/<t>/app-implementations/<platform>/<app>/` (§45.5, §45.11).

TODO: `apps/macos/<app>/` specs are authored/extracted in workstream 7 (apps). No
content this leaf (skeleton-only).
