# forward-gen-suite-k120

**Kind:** work

## Goal

Forward-gen the mini-browser `#lang app-spec` scenario suite + `run-values.rkt` +
the **local fixture pages** from the k113 spec + k114 contracts, via the AppSpec
forward-gen workflow (`~/Development/AppSpec/capabilities/forward-gen/workflow.md`) —
the scenekit k111 stage. Suite homes at `apps/macos/mini-browser/scenarios/`.

## Context

- **Template:** the scenekit-viewer suite (`apps/macos/scenekit-viewer/scenarios/` +
  `run-values.rkt`, k111) and the pdfkit k102 exemplar (hard vs `recording:` cluster
  split, `;; spec:` per-assertion tracing, coverage-or-gap rule
  `AppSpec/capabilities/forward-gen/validation.md` L1b, two-run consensus for a suite
  gating four impls, presentation-settled `wait-for-log` probe before coordinate
  clicks).
- **Inputs:** `apps/macos/mini-browser/docs/{spec,logging-contract,observable-state}.md`.
  The observable-state assertion → observation-path map is the suite's skeleton —
  every spec assertion verb-backed or a documented gap.
- **All four impls are instrumented + built** (k116–k119): the suite can assume the
  contract events (`[lifecycle] startup`, bare launch line beginning `Mini Browser`,
  the three `[nav]` events, `shutdown reason=menu`) and the descriptors at
  `targets/<t>/app-implementations/macos/mini-browser/mini-browser-impl.rkt`
  (`com.linkuistics.mini-browser-<impl>` at `/Applications/MiniBrowser-<impl>.app`).
  Launch-line remainders, loading-text/failure-phase spellings, and home URLs
  (racket/chez `www.apple.com`; gerbil/sbcl `example.com`) diverge by design — match
  the `Mini Browser` prefix and the normalized log keys only.
- **The fixture story (k114):** two local HTML pages driven via `file://` URLs typed
  into the address field — the whole success path rides them (**the VM has no
  network**). Author the pages with the suite (home them under
  `apps/macos/mini-browser/scenarios/` per the workflow's fixture guidance; the
  contract's example path is `/tmp/mini-browser/fixtures/…` in the VM — the live-run
  leaf uploads them there).
- **The no-network launch reality (k113):** the launch-time home load FAILS in-VM —
  the §7.3 modal NSAlert is the expected launch observable; `[nav] failed` is the
  deterministic pre-modal dismissal cue (`wait-for-log "[nav] failed"` → settle →
  `press "Return"`). Which phase the offline initial load reports (expected
  `request`) is a to-confirm-in-VM row — match `#px"\\[nav\\] failed"` loosely until
  firmed.
- **The file:// probe results (k80 brief, k116) bind matchers:** the success path is
  OPEN (`loadRequest:` renders local HTML); `[nav] finished` carries **`title=""` on
  EVERY file:// load** (never assert a fixture title there) and the window title
  stays at the `Mini Browser` fallback (window-title tracking is unassertable
  offline); `can-go-back` flips `true` across a file→file hop — history enablement
  asserts via the `finished` booleans (the AX `enabled` flag is dropped by the
  snapshot transform; the address field's AX value is empty → OCR/log are its
  channels, k113).
- **Contract rules the scenarios must respect:** never count events, never assume
  cross-navigation ordering (match the specific driven-to line — reload and ◀/▶ fire
  the same pairs); the §6.2 silent no-ops (empty input / `Invalid URL:`) emit
  nothing — the status line is their observable, absence is never asserted; the
  `https://` prepend is witnessed by `[nav] started url=` even offline; bind
  `started url=` values only where the scenario drove a known load.
- **Driver guidance:** drive the address field by **triple-click** (select-all) →
  type → Return (NSTextField Cmd-A does not take reliably over VNC — the 060 VM
  reports); the alert's Return-dismissal follows the `failed` cue.

## Done when

The suite + `run-values.rkt` + fixture pages are authored and validated per the
forward-gen workflow's checks (scenario↔spec correlation review; coverage-or-gap map
complete); committed. Running the suite live is the Tier-2 live-run leaf's bar (grow
it on retire — the k80 stage 5, closing the node's Done-when).

## Notes

Window geometry is 800×600 content across all four impls but control metrics may
diverge (racket's compact 22px precedent) — apply the k77 per-impl geometry practice:
measure from `agent snapshot --mode layout`, two-launch determinism diff before
binding values, per-impl `run-values-<impl>.rkt` only where layouts diverge. WKWebView
AX exposure (how much of the fixture DOM surfaces as `AXWebArea` subtree in-VM) is
itself a spec-quality finding to record.
