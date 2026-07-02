# live-run-k121

**Kind:** work

## Goal

Tier-2 live-run the mini-browser forward-gen suite (k120) against all four impls in a
live macOS VM via the AppSpec run capability
(`~/Development/AppSpec/capabilities/run/workflow.md`) → `docs/run-results.md` with the
outcome table + per-impl findings. Closes the `appspec-mini-browser-k80` node's
Done-when ([[vm_verify_every_app]] — CLI smoke never satisfies the bar).

## Context

- **Suite:** `apps/macos/mini-browser/scenarios/` (13 scenarios: 01 post-dismissal
  steady-state cluster; 02 offline failure boundary; 03 blank-input; 04 `recording:`
  invalid-URL; 05 prepend witness; 06 empty-history clicks; 07 typed-URL fixture load;
  08 `recording:` fixture-renders OCR; 09 Go≡Return; 10 history walk (enables/back/
  forward); 11 reload; 12 Command-Q; 13 `recording:` close-button). Every scenario
  opens with the launch-alert dismissal preamble (`wait-for-log "[nav] failed"` →
  settle 1.0 → Return → settle) — the VM has no network, so the failing home load's
  modal is part of launch (k80 brief).
- **Fixtures:** upload `apps/macos/mini-browser/fixtures/{page-one,page-two}.html` to
  `/tmp/mini-browser/fixtures/` in the VM **before** the runs (chunked upload per
  [[testanyware_cli]]); the suite types the `file://` URLs bound in `run-values.rkt`.
- **run-values.rkt is PROVISIONAL** — coordinates are spec-derived estimates
  (window frame ≈ (560,115) 800×628 on 1920×1080; toolbar centre-line ≈ fb y 171).
  **Re-measure every coordinate** from `agent snapshot --mode layout` (AX centre,
  framebuffer px) with a **two-launch determinism diff per impl** before binding
  (k77/k94 practice); sibling `run-values-<impl>.rkt` only where layouts genuinely
  diverge (racket's compact 22px metrics are the standing suspect; pdfkit and scenekit
  share-sets differed — measure, never assume).
- **Descriptors:** `targets/<t>/app-implementations/macos/mini-browser/
  mini-browser-impl.rkt` (`com.linkuistics.mini-browser-<impl>` at
  `/Applications/MiniBrowser-<impl>.app`, events/test-config under
  `/tmp/mini-browser/`). Install each built `.app` in the VM (racket needs the
  provisioned runtime — the k74 recipe; sbcl vendors libzstd since k75).
- **To confirm/record at live-run** (the suite's deliberate loosenesses + provisional
  rows): which `phase` the offline initial load reports (expected `request` — then firm
  the 01/02 matchers on regen); NSURL's rejection of space-bearing input (04
  recording); WKWebView-rendered-text OCR (08 recording); close-button keep-running
  (13 recording); first-fixture-load + back-nav `can-go-back` actuals (10's unbound
  booleans); reload's provisional `started url=` value; ◀/▶ **enabled flags** at empty
  state + both history boundaries from **raw** `agent snapshot --mode layout`
  (adjudication channel — the k96 `expect-ax #:enabled?` gap stands); WKWebView AX
  exposure (`AXWebArea`? — spec-quality finding to record); the failure alert's AX
  shape/text.
- **Standing run-mechanism residuals** (adjudicate by artifact review / solo re-run,
  never by patching the suite): OCR small-text class (k103; `failed:`/`Invalid URL`
  are OCR-gated 11-pt reads; camel-cap casing shape k112), delayed-truncate red after
  a failure (k94), Tahoe notification banner (k103).

## Done when

All four impls run the suite green (recording outcomes read per D4 — a red that
adjudicates to a spec finding is recorded, not patched); `docs/run-results.md` records
the outcome table + per-impl findings + firmed provisional rows; `run-values.rkt`
carries live-measured values. Commit names `live-run-k121`.

## Notes

Spec-quality findings k120 seeds for the next reverse-gen regeneration (record
alongside the run outcomes): the `Invalid URL: <text>` suffix is ambiguous between
§6.2 "normalized" and observable-state "typed"; §13 lacks a rendering-outcome line
(08's anchor is the observable-state map row); the `[nav] failed` event carries no
`url` key (a second failure is indistinguishable from the launch failure in the
buffer — a candidate contract enrichment); window-title tracking is offline-
unassertable (the k116 title-lag platform fact) and stays network-gated.
