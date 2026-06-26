# apps/macos/ — common macOS app data

Per-app data for APIAnyware's common macOS applications: one directory per app, holding
that app's target-independent **AppSpec data** — a description/spec/PRD, the
(generated-and-validated) test suites, and the contracts. Free of projection, so the
same data drives racket, chez, gerbil, sbcl, and future targets alike (REFACTOR §15).
The per-target **implementations** live under
`targets/<t>/app-implementations/macos/<app>/` (§16), VM-verified there; this tree holds
the spec they all realize, not the implementations.

## Consumed from the external AppSpec project (ADR-0052)

An app spec is **not** a grove-native `.apiw` entity — it is authored against, and run
by, the external **AppSpec** project (`~/Development/AppSpec`), the LLM-driven spec/test
toolkit that consumes this tree and drives a live macOS VM through TestAnyware. The
authoring model is **human-in-the-loop, LLM-driving** (ADR-0052, the ws5 philosophy of
ADR-0050 applied to apps):

1. **reverse-gen** — point at an app's existing implementation → LLM-generate the
   description/spec/PRD detailed enough to *reliably replicate* it (human-annotated);
2. **forward-gen** — LLM-synthesize test suites that *correlate with* the spec, from
   best-practice guidelines, attack-vectors, and patterns/anti-patterns
   (human-validated);
3. **run** — the AppSpec runner replays the suites against any implementation.

Grove-domain structural facts an app carries — its **app-kind** (ADR-0049 instance
side), the **pattern-kinds** it exercises, the **display-name** (the bundlers read it
from the description's first H1) — stay **prose** in the app's description until a
machine consumer needs them (no machine manifest yet; lazy).

## Catalogue

`docs/_index.md` is the app catalogue; `docs/2026-04-16-sample-app-portfolio-design.md`
is the authoritative portfolio design. Each app currently carries co-located prose under
`<app>/docs/` (`spec.md` = description, `learnings.md` = app-universal learnings,
`test-strategy.md` = TestAnyware validation checklist) from `co-locate-docs-k9`.

> **Status (workstream 7):** the relationship, data boundary, and vocabulary are settled
> (ADR-0052; `CONTEXT.md` *App model / AppSpec*). Still to come as later ws7 children —
> reverse-gen each app's spec/PRD from its implementation (human-validated), build the
> AppSpec grove (where the spec **format** firms), then forward-gen suites + VM-verify.
> The on-disk file layout here is therefore **format-flexible**, not yet finalized; the
> bundlers keep reading the display-name from `<app>/docs/spec.md`'s first H1 until then.
