#lang app-spec
;; forward-generated from Swift-Native Probe §10 on 2026-07-04, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "post-launch steady state: all probes pass"
  #:description "When Swift-Native Probe has launched and reached its post-launch steady state, then the process is running, the launch diagnostic and the target-agnostic all-probes-pass coverage summary are in the event log, the projection-free window title and the Swift-native heading substring are on screen, and the window (AXTitle exact), at least one static-text coverage row (and no editable text field), and the Quit menu item are present in the accessibility tree. Pure observations of one shared launch; the coverage proof is the log's all-ok=#t summary, not the per-target, small-text on-screen row values (spec §6/§9, k103 small-text class)."

  ;; run: bundle-id — bound at run time from the impl descriptor / per-app run-values config (ADR-0011).
  ;; An internal define inside the scenario thunk so it resolves at run time, not at load —
  ;; keeping the suite loadable outside the runner (validation L1a).
  (define bundle-id (run-value 'bundle-id))

  ;; spec: §10 — Process is running after launch.
  ;; harness: runner/harness-observations.rkt — (expect-running-app bundle-id); #:running? defaults to #t.
  (expect-running-app bundle-id)

  ;; spec: §10 — Readiness / launch diagnostic. (the bare, unbracketed launch line; the '[lifecycle] startup' half of this line is the runner's wait-ready readiness probe, done at setup — there is no wait-ready in the closed verb set, so the suite asserts only the launch line here.)
  ;; harness: runner/harness-logs.rkt — the log verbs take a REGEXP; the literal '.' is escaped so it is not a wildcard. Matcher from logging-contract.md.
  (wait-for-log #rx"Swift-Native Probe opened\\.")

  ;; spec: §10 — All probes passed (the coverage proof — target-agnostic). THE coverage assertion.
  ;; harness: runner/harness-logs.rkt — REGEXP; matcher verbatim from logging-contract.md — '.*' spans 'count=<n> ok=<n> '; bind all-ok=#t (universal on a fully-bound Swift-native path), NEVER the per-target count (2 for racket/chez/gerbil, 5 for sbcl). Emitted before the launch line, so it is already accumulated when this fires (wait-for-log searches the whole scenario buffer).
  (wait-for-log #px"\\[probe\\] complete .*all-ok=#t")

  ;; spec: §10 — Window title is correct. (on-screen channel — the title bar is projection-free and OCR-legible, unlike the small-text rows; also serves as the render-settle probe.)
  ;; harness: runner/harness-observations.rkt — wait-for-ocr matches a literal substring (string-contains?); polls to absorb render latency.
  (wait-for-ocr "Swift-Native API Coverage")

  ;; spec: §10 — Window title is correct. (accessibility channel — §10 sanctions 'expect-ocr AND/OR expect-ax window AXTitle'. The title is projection-free here, so #:title's exact equal? match IS expressible — unlike hello-window's per-impl title; observable-state.md §AX confirms the AXWindow AXTitle equals this exactly.)
  ;; harness: runner/harness-observations.rkt — expect-ax matches #:role and #:title (exact equal? on AXTitle); default #:scope 'anywhere finds the window across the whole snapshot.
  (expect-ax #:role 'AXWindow #:title "Swift-Native API Coverage")

  ;; spec: §10 — The heading identifies the Swift-native surface.
  ;; harness: runner/harness-observations.rkt — expect-ocr is a literal substring; assert the stable,
  ;; projection-free heading tail "trampolines" (the parent brief's explicitly-sanctioned substring
  ;; option), NEVER the per-impl library name libAPIAnyware<Target>.
  ;; run refinement (k147): the equally-projection-free "Swift-native APIs" garbles under whole-screen OCR
  ;; — the small-font capital-I in "APIs" reads as lowercase l ("APls"), the k103 small-text class — while
  ;; the heading renders correctly (AXStaticText value + screenshot both exact). "trampolines" is all-lower,
  ;; longer, and OCR-reliable across all four impls (incl. racket's compact 22px metrics); it identifies the
  ;; Swift-native surface (heading + footer both name the @_cdecl trampolines). AX-exact is unavailable here
  ;; (the full heading is per-impl; expect-ax #:title is exact-only), so an OCR-reliable substring is the
  ;; projection-free channel — the scenekit "prefer the reliable read for the same fact" precedent.
  (expect-ocr "trampolines")

  ;; spec: §10 — At least one coverage row is present as static text.
  ;; harness: runner/harness-observations.rkt — the static-text node exists by role; expect-ax has no #:value, so the (per-target, small-text, sometimes non-deterministic) row value is carried by the log, not asserted here.
  (expect-ax #:role 'AXStaticText)

  ;; spec: §10 — At least one coverage row is present as static text. (structural dual: the labels are static text, NOT editable fields — the "no interactive editing" guard from spec §2 "no user-input handling beyond the standard window and menu chrome" + §9 static-text accessibility + observable-state.md §AX, made precise for this line.)
  ;; harness: runner/harness-observations.rkt — expect-no-ax keys on #:role; #:scope 'app-content narrows the walk to the app-under-test's window content so the window's own title-bar AXStaticText chrome and foreign desktop widgets do not trip the negative (the drawing-canvas k140 finding, directly inherited).
  (expect-no-ax #:role 'AXTextField #:scope 'app-content)

  ;; spec: §10 — Quit menu exists.
  ;; harness: runner/harness-observations.rkt — #:title is exact equal?; "Quit Swift-Native Probe" is a whole-string invariant ("Quit " + the fixed display name). The Command-Q key-equivalent ATTRIBUTE has no expect-ax form (portfolio gap 2) — its behaviour is covered by scenario 02.
  (expect-ax #:role 'AXMenuItem #:title "Quit Swift-Native Probe"))
