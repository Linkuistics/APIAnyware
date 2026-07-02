# appspec-mini-browser-k80 — brief

## Goal

The full AppSpec cycle for **mini-browser** (the WKWebView browser): reverse-gen the
spec from the four VM-verified impls, instrument to the contracts, rebuild, forward-gen
the scenario suite, Tier-2 live-run all four impls. Fifth app through the toolkit
(after hello-window, ui-controls-gallery, pdfkit-viewer, scenekit-viewer).

## Context

- **hello-window is the worked template** (k64/k67–k74); **ui-controls-gallery
  (`appspec-ui-controls-gallery-k77`), pdfkit-viewer (`appspec-pdfkit-viewer-k78`) and
  scenekit-viewer (`appspec-scenekit-viewer-k79`) are the richer precedents** — apply
  their promoted outcomes (parent brief outcome sections): per-impl geometry practice
  (measure from `agent snapshot --mode layout`, two-launch determinism diff, per-impl
  `run-values-<impl>.rkt` only where layouts diverge); the Tier-2-only defect classes
  (launch presentation; ambiguous layout); the OCR small-text run-mechanism class
  (incl. the camel-cap casing shape — prefer AX-exact where both channels assert the
  same fact) + delayed-truncate residual (adjudicate by artifact review / solo re-run,
  never by patching the suite); `acceptsFirstMouse` is control-dependent (first click
  after a panel/other window has key may DELIVER to a pop-up); menu-open-ending
  scenarios are now safe (AppSpec `611f73c` quit escalation); the Tahoe
  notification-banner gotcha.
- Drive via the AppSpec capability workflows:
  `~/Development/AppSpec/capabilities/{reverse-gen,forward-gen,run}/workflow.md`.
  Data homes **here** (ADR-0052; AppSpec ADR-0013): spec/contracts/scenarios under
  `apps/macos/mini-browser/`, impl instrumentation under
  `targets/<t>/app-implementations/macos/mini-browser/`.
- **App-specific: the VM has no network** (the k74 racket provisioning ran option 1,
  no VM network) — scenarios must load a **local fixture page** (`file://` or a
  bundled HTML fixture), never a live URL. Navigation state (URL field text,
  back/forward enablement, page title / window title) is the observable core; the
  rendered page contents sit in a WKWebView whose AX exposure needs probing (webviews
  surface as `AXWebArea` subtrees — how much of the fixture DOM is AX/OCR-observable
  in-VM is itself a spec-quality finding, the scenekit precedent). WKWebView loads
  are **asynchronous** — navigation-completion needs a contract log event
  (`didFinish`-family delegate callback) to be assertable without sleeps.
- **Decomposed on entry (2026-07-03)** — per-stage children mirroring
  `appspec-scenekit-viewer-k79`, materialized lazily (grow the next as each retires;
  stages may merge where they genuinely fit one session):
  1. **`reverse-gen-k113`** ✅ *(done 2026-07-03)* — the projection-free spec from
     the four impls (replaced the precursor `docs/spec.md`), via the AppSpec
     reverse-gen workflow. Key handoffs: per-impl **home-URL hole** (racket/chez
     `www.apple.com`, gerbil/sbcl `example.com`); **no-network launch reality** —
     the initial load fails → the §7.3 modal NSAlert is the expected launch-time
     observable, and `file://` renderability is an open in-VM gap gating the
     offline success path; exemplar split network-independent vs network-required;
     launch-line prefixes diverge (`running.` vs sbcl `opened.`); loading-text and
     failure-phase spellings diverge; title lags didFinish on first loads; AX
     caveats (address-field AX value empty → OCR; ◀/▶ via AX `enabled` flag).
  2. **`conformance-data-k114`** ✅ *(done 2026-07-03)* — both contracts authored.
     Key handoffs: the `[nav]` vocabulary (started/finished/failed; finished carries
     url/title/can-go-back/can-go-forward in fixed key order, booleans bare
     `true`/`false` — the operative history-enablement channel, the k96 `expect-ax
     #:enabled?` gap re-verified still open; failed carries normalized lowercase
     `phase` + `message`, emitted **pre-runModal** as the dismissal cue); launch-line
     prefix rule, **no visible-behaviour alignment** anywhere; fixture story = two
     local HTML pages driven via `file://` typed into the address field, the whole
     success path **file://-gated** (probe seeded to instrument-builds); sbcl
     `build.sh` bundle-id/plist alignment flagged (k104 mirror).
  3. **`instrument-builds-k115`** — all four impls instrumented + rebuilt (expected
     to decompose on entry, one child per impl); carries the `file://` host probe.
  4. **forward-gen-suite** — the scenario suite + fixture page + `run-values.rkt`.
  5. **live-run** — Tier-2 live-run all four impls → `docs/run-results.md`
     (closes this node's Done-when).

## Done when

All four impls run the forward-gen suite green in a live VM ([[vm_verify_every_app]] —
CLI smoke never satisfies the done-bar); `docs/run-results.md` records the outcome
table + per-impl findings. Commits name the child handles.

## Notes

URL entry + load, back/forward navigation (enablement + effect), page-title tracking,
and reload are the behavioural core; observable state captures the URL field, nav
button enablement, window/page title, and contract log events — with all navigation
against a local fixture, never the network.
