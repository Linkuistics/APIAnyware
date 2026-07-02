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

## Outcome (2026-07-02) — suite authored, validated, committed

**Generation: two-run consensus** (workflow step-3 escalation — the suite gates four
impls). Two independent forward-gen subagents on the same inputs agreed on **every**
§13→verb mapping, every cluster, and the same three gaps — no oracle-hallucination
signal. Three judgment-call divergences, reconciled: (1) the §12 "no app-specific
handling" exclusion realized as the push-button `expect-not-log #px"\\[controls\\]"`
negative (run A emitted it; run B flagged it for the reviewer — included: spec-stated
exclusion + the logging contract's closed event set ground it, and it is
discriminating); (2) run B's self-documenting run-value key names adopted; (3) run A's
`\\[controls\\]`-anchored matchers + `\b` guards on `value=0`/`value=10` adopted.

**The suite: 11 scenarios** (`scenarios/NN-<slug>.rkt`): `01` hard steady-state cluster
(process, launch line, 5 OCR reads, 5 firm AX roles); `02`/`03` pure-observation
`recording:` clusters (placeholders OCR; uncertain AXDateField/AXBusyIndicator roles —
kept out of `01` so a provisional failure cannot fail the hard cluster); `04`–`08`
`recording:` interaction scenarios riding the k87 `[controls]` events (radio sole-
selection event; checkbox FLIP — both `state=on` and `state=off` after two clicks,
order-agnostic; text-entry OCR; slider/stepper clamp values `100`/`0` and `10`/`0`,
stepper driven by first-class `for` loops ×12); `09` hard §12 negative (push-button
click → no `[controls]` event within 2 s); `10` hard Command-Q (chord → `shutdown
reason=menu` → process gone); `11` `recording:` close-button keeps-running. Every
interaction scenario opens with the `wait-for-log #rx"Controls Gallery"`
presentation-settled probe (the contract emits the line only once the window is
key+front — the spec-anchored gate before clicking run-supplied coordinates).

**Coverage map (17 §13 lines):** 14 covered (traced per-assertion via `;; spec:`),
**3 documented gaps** exactly as the observable-state skeleton records: secure-field
non-echo (needs AX value read / negative OCR — a pass-by-construction test was NOT
emitted), popup item count (needs AX children-count), progress-bar preset (needs AX
value read; visual check at live-run). Partial-halves also recorded: radio
deselected-A rides the event's sole-selection semantics (AX state read gapped);
slider "within range" existence-only in `01` (clamp events witness the range).
Not-Included: close-to-quit → `11`; push-button handling → `09`; file-I/O exclusion
unrealizable (no path stated — none invented); readouts/scrolling are holes, not
exclusions (a negative would fail conforming impls); custom drawing unobservable.

**Validation (validation.md instrument):** L1a — 11/11 `LOAD OK` under the runner's
collection path; `run-values.rkt` loads via `load-run-values-config` (18 keys ==
the suite's coordinate roster); each file registers exactly one scenario. L1c —
`01/02/03` mutating=0; each mutating scenario carries exactly one PRE-mutation
readiness probe + only own-effect reads after the mutation (D2's rule holds; the
mechanical ≤1-obs counter predates readiness probes — judgement note, both
generators converged on the probe independently). L1d — 7 realizable to-confirm
lines → 7 `recording:` scenarios with pass-confirms/failure-is-a-finding
descriptions; 3 inexpressible to-confirm lines → loud gaps.

**Handed to the Tier-2 live-run leaf:** all 18 coordinate values in `run-values.rkt`
are provisional ZEROS — layouts are impl-varying (§4/§5), so unlike hello-window
there is no shared geometry formula; the live-run stage must measure per impl via
`agent snapshot --mode layout` (and may keep per-impl run-values files —
`--run-values` binds per invocation; the descriptor wins only on `bundle-id`).
Run-tuning risks noted: rapid-click coalescing (05/08), track-click-jumps-knob
assumption (07), async settles via in-set `(wait …)` where needed.
