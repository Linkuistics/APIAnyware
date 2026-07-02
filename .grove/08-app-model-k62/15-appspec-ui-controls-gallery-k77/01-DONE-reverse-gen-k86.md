# reverse-gen-k86

**Kind:** work

## Goal

Reverse-gen the projection-free, replication-grade **ui-controls-gallery spec** from
the four VM-verified impls, per the AppSpec reverse-gen workflow
(`~/Development/AppSpec/capabilities/reverse-gen/{workflow,prompt}.md`): dispatch the
read-only subagent, validate its modeling notes (anchor order: app-kind contract >
impl behaviour > human prose), and write the accepted spec to
`apps/macos/ui-controls-gallery/docs/spec.md` (replacing the precursor prose — the
lowest anchor). The commit is the propose→review→accept boundary (ADR-0050/0052).

## Context

- Inputs: impls at `targets/{racket,chez,gerbil,sbcl}/app-implementations/macos/
  ui-controls-gallery/`; app-kind contract `platforms/macos/app-kinds/gui-app/kind.apiw`;
  precursor prose `apps/macos/ui-controls-gallery/docs/{spec,learnings,test-strategy}.md`;
  portfolio catalogue `apps/macos/docs/_index.md` (complexity = portfolio rank; the
  precursor's `3/7` predates the 2026-04-27 retirements — catalogue now ranks it #2).
- Template: `apps/macos/hello-window/docs/spec.md` (the k64 exemplar — H1 = display
  name for the bundlers; provenance line; §1 structural facts; behavioural-exemplar
  final § mapped to the closed scenario-verb set).
- Known stale-prose risks: precursor claims `NSImage imageNamed:` with SF Symbol
  "star.fill" and "textual with stepper" date picker — verify against what the impls
  actually realize.

## Done when

`apps/macos/ui-controls-gallery/docs/spec.md` is the validated reverse-gen spec
(first H1 still `UI Controls Gallery` — bundler-safe), committed with the modeling
notes reviewed; unsupported claims grounded or cut, gaps honestly marked
`(to confirm in-VM)`.

## Notes

The behavioural-exemplar section is the forward-gen input for the later suite child —
it should enumerate per-control interactive assertions (slider drag → label update,
radio exclusivity, checkbox toggle, stepper, popup, scrolling), not just launch/quit
([[sample_apps_perfect]]).

## Status — done 2026-07-02 (validated & accepted)

Subagent dispatched per the AppSpec workflow; modeling notes worked; surprising
witnesses mechanically re-verified against the sources (sbcl title/size/mask, radio
A/B-only, swapped popup/combo item sets, YMD-only picker, progress 60.0, extras;
racket resizable+min-size, `NSActionTemplate`; delegate absence across all four).
Key acceptances:

- **sbcl is the anti-unification forcing impl** (independent of the racket→chez→gerbil
  copy lineage — the notes' shared-ancestry discount): scrollability demoted to a
  layout realization (§12 Not Included), title/size/section-map/live-readouts
  variabilized, roster floor = 14 control kinds (sbcl extras permitted above it).
- **Close-to-quit corrected** exactly as hello-window: printed "Close window … to exit"
  guidance is unbacked prose-in-impl; app-kind `ns-application-terminate` + no-delegate
  structure win; close behaviour is an in-VM gap.
- **Precursor over-claims cut/routed:** combo "(editable)", image "imageNamed: star.fill"
  (matched *no* impl), "3/7" complexity (stale — catalogue ranks #2), quality criteria.
  Masking/toggle glosses kept only as (to confirm in-VM), matching the hello-window
  calibration.
- Validation edits on acceptance: dropped the (proposed) tags after confirming
  complexity/pattern-kinds against the supplied taxonomy; made §3.8/§7 self-contained
  (no dangling modeling-notes references).
