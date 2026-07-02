# forward-gen-suite-k93

**Kind:** work

## Goal

Forward-gen the ui-controls-gallery `#lang app-spec` scenario suite + `run-values.rkt`
from the k86 spec + k87 contracts, via the AppSpec forward-gen workflow
(`~/Development/AppSpec/capabilities/forward-gen/workflow.md`) — the hello-window k72
stage. Suite homes at `apps/macos/ui-controls-gallery/scenarios/`.

## Context

- **Template:** hello-window's suite (`apps/macos/hello-window/scenarios/` +
  `run-values.rkt`) — the worked k72 exemplar (scenario shape, `expect-*` verb use,
  the coverage-or-gap rule `AppSpec/capabilities/forward-gen/validation.md` L1b).
- **Inputs:** `apps/macos/ui-controls-gallery/docs/{spec,logging-contract,
  observable-state}.md`. The observable-state §13 assertion→path map IS the suite's
  skeleton — every §13 line is verb-backed or a documented gap (the gap set: AX
  value/state reads, popup/combo counts, secure-field non-echo, graphical states).
- **All four impls are instrumented + built** (k89–k92): the suite can assume the
  contract's events (`[lifecycle] startup`, launch line containing `Controls Gallery`,
  the four `[controls]` post-state events, `shutdown reason=menu`) and the descriptor
  paths under `targets/<t>/app-implementations/macos/ui-controls-gallery/`.
- **Cross-impl variance the scenarios must respect** (contract): checkbox initial state
  is a §6 hole (sbcl launches ON) — assert the *flip*, never a fixed on/off sequence;
  radio roster is A/B(+C in racket/chez/gerbil; sbcl has A/B only) — assert Option A/B
  titles only; launch-line full text is impl-specific (match the substring); a
  continuous slider emits many lines per drag (match the driven-to value, typically
  last); window titles vary (OCR `Controls`, not `Controls Gallery`).

## Done when

The suite + `run-values.rkt` are authored and validated per the forward-gen workflow's
checks (scenario↔spec correlation review; coverage-or-gap map complete); committed.
Running the suite live is the Tier-2 leaf's bar (grow it on retire).
