# reverse-gen-k95

**Kind:** work

## Goal

Reverse-gen the projection-free, replication-grade **pdfkit-viewer spec** from the
four VM-verified impls, per the AppSpec reverse-gen workflow
(`~/Development/AppSpec/capabilities/reverse-gen/{workflow,prompt}.md`): dispatch the
read-only subagent, validate its modeling notes (anchor order: app-kind contract >
impl behaviour > human prose), and write the accepted spec to
`apps/macos/pdfkit-viewer/docs/spec.md` (replacing the precursor prose — the lowest
anchor). The commit is the propose→review→accept boundary (ADR-0050/0052).

## Context

- Inputs: impls at `targets/{racket,chez,gerbil,sbcl}/app-implementations/macos/
  pdfkit-viewer/`; app-kind contract `platforms/macos/app-kinds/gui-app/kind.apiw`;
  precursor prose `apps/macos/pdfkit-viewer/docs/{spec,learnings,test-strategy}.md`;
  portfolio catalogue `apps/macos/docs/_index.md` (complexity = portfolio rank).
- Templates: `apps/macos/hello-window/docs/spec.md` (the k64 exemplar — H1 = display
  name for the bundlers; provenance line; §1 structural facts; behavioural-exemplar
  final § mapped to the closed scenario-verb set) and
  `apps/macos/ui-controls-gallery/docs/spec.md` (the k86 rich-surface precedent —
  anti-unification across impls, variabilized title/size, roster floor).
- Watch for stale-prose risks (the k86 lesson: precursor claims that match *no* impl
  get cut) — verify every document-loading / page-navigation / zoom claim against
  what the impls actually realize, including how each impl obtains its PDF (bundled
  resource? generated at runtime? open panel?) — that grounds the later fixture
  decision.

## Done when

`apps/macos/pdfkit-viewer/docs/spec.md` is the validated reverse-gen spec (first H1
bundler-safe — the display name), committed with the modeling notes reviewed;
unsupported claims grounded or cut, gaps honestly marked `(to confirm in-VM)`.

## Notes

The behavioural-exemplar section is the forward-gen input for the later suite child —
it should enumerate document-open, page-navigation (next/prev, bounds), zoom, and any
sidebar/thumbnail behaviour as interactive assertions, not just launch/quit
([[sample_apps_perfect]]). Note per-impl PDF-acquisition variance explicitly — it
constrains the fixture design.

## Status — done 2026-07-02 (validated & accepted)

Subagent dispatched per the AppSpec workflow; modeling notes worked; load-bearing
witnesses mechanically re-verified against all four sources (window 720×540 / min
480×360 / PDF view 720×492 / toolbar 12,500,696,32 / spacing 8 / FirstBaseline;
label strings + 1-based `Page n of N`; launch-diagnostic `PDFKit Viewer` prefix;
`NSModalResponseOK`=1 hand-defined ×4; allowed-file-types ×4 — gerbil via
declaring-class `nssavepanel-*`; absence of delegates and `removeObserver`;
auto-scales + single-page-continuous ×4; canGoTo* enablement ×4). Key acceptances:

- **Fixture finding (constrains the later suite child):** *no impl bundles, generates,
  or hard-codes a document* — the open panel is the only document source; the suite
  must provision an N ≥ 3-page fixture into the VM and drive the out-of-process panel
  by keyboard (Cmd-Shift-G → path → Return ×2). Spec §6/§13 carry the rule.
- **Quit-contract witness asymmetry resolved at validation:** the notes flagged that
  only sbcl's menu body was in the supplied inputs; verified the shared
  `install-standard-app-menu!` helper bodies directly (racket `app-menu.rkt`, chez +
  gerbil `cocoa.ss/.sls`) — all build `"Quit " + name` / `terminate:` / key `q`, so
  §8 stands confirmed, no weakening.
- **Close-to-quit corrected** exactly as hello-window/k86: three impls' printed
  "Close window … to exit" guidance is prose-in-impl; app-kind
  `ns-application-terminate` + no-delegate structure win; close behaviour is an
  in-VM gap.
- **Precursor over-claims cut:** the "first app to exercise a non-AppKit framework /
  first to observe a framework NSNotification" portfolio narrative (catalogue lists
  `NSNotificationCenter` for note-editor too); the catalogue row's stale "(blocked on
  Quartz collection fix)" remark ignored (rank 7/7 used as-is — index rework is
  k85's).
- **Common-mode flags accepted as spec fact with self-contained phrasing:** deprecated
  `setAllowedFileTypes:` (modern `setAllowedContentTypes:` needs UTType, outside the
  generated surface); hand-defined `NSModalResponseOK`; app-lifetime observer (no
  balancing unregister — deliberate, §7.3/§12).
- Validation edits on acceptance: made §6.1/§7.3/§7.4 self-contained (no dangling
  modeling-notes references — the k86 lesson); complexity descriptor matched to the
  accepted-spec style; (proposed) tags dropped after confirming `target-action` /
  `observer` / `parent-child` against the registry + rank 7 against the catalogue.
- **Exemplar gaps recorded:** window-resize auto-scale + the 480×360 floor have no
  driving verb in the closed set — spec prose only, no runnable assertion.
