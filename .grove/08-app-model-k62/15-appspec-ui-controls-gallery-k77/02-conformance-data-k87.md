# conformance-data-k87

**Kind:** work

## Goal

Author the ui-controls-gallery **conformance data** — the per-app contracts every impl
must satisfy so the forward-gen suite can observe it:
`apps/macos/ui-controls-gallery/docs/logging-contract.md` +
`docs/observable-state.md`. The hello-window k67 pair is the worked template.

## Context

- Input: the accepted reverse-gen spec (`docs/spec.md`, k86) — especially §3.6 (launch
  diagnostic rule: line contains `Controls Gallery`), §7 (interactive behaviour), §11
  (observable outcomes/accessibility), §13 (behavioural exemplar).
- The contracts double as the porting guide (AppSpec vocabulary: Contract). They will
  drive the per-target instrument+build children (k68–k71 patterns) — richer here:
  interactive controls (slider/stepper/radio/checkbox) likely need state-change log
  lines to make interactions observable beyond AX/OCR.
- Template: `apps/macos/hello-window/docs/{logging-contract,observable-state}.md`.

## Done when

Both contract docs exist under `apps/macos/ui-controls-gallery/docs/`, consistent with
the spec's exemplar assertions (every scenario observation verb has a contract-backed
observation path), committed.

## Notes

Keep the contract minimal but sufficient for the §13 assertions — over-specified
logging burdens all four instrument children.
