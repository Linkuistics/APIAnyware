# reverse-gen-k122

**Kind:** work

## Goal

Reverse-gen the projection-free, replication-grade **note-editor spec** from the
four VM-verified impls, per the AppSpec reverse-gen workflow
(`~/Development/AppSpec/capabilities/reverse-gen/{workflow,prompt}.md`): dispatch the
read-only subagent, validate its modeling notes (anchor order: app-kind contract >
impl behaviour > human prose), and write the accepted spec to
`apps/macos/note-editor/docs/spec.md` (replacing the precursor prose — the lowest
anchor). The commit is the propose→review→accept boundary (ADR-0050/0052).

## Context

- Inputs: impls at `targets/{racket,chez,gerbil,sbcl}/app-implementations/macos/
  note-editor/` (sbcl carries extra build/run/dump scripts + a README); app-kind
  contract `platforms/macos/app-kinds/gui-app/kind.apiw`; precursor prose
  `apps/macos/note-editor/docs/spec.md` (**spec.md only** — no `learnings.md` /
  `test-strategy.md` precursors exist for this app, a thinner lowest-anchor set than
  k113 had); portfolio catalogue `apps/macos/docs/_index.md` (complexity = portfolio
  rank — note-editor is **row 3 of 7**, vs the precursor's claimed 6/7: the k113
  correction class); pattern-kind registry `semantic/pattern-kinds/`; closed verb set
  `~/Development/AppSpec/app-spec/main.rkt`.
- Templates: `apps/macos/hello-window/docs/spec.md` (the k64 exemplar — H1 = display
  name for the bundlers; provenance line; §1 structural facts; behavioural-exemplar
  final § mapped to the closed scenario-verb set) and
  `apps/macos/mini-browser/docs/spec.md` (the k113 precedent — WKWebView content +
  async completion observability + per-behaviour in-VM verifiability shape).
- Watch for stale-prose risks (the k86/k95/k104/k113 lesson: precursor claims that
  match *no* impl get cut) — the precursor is **heavily racket-flavoured**
  (`file->string`, `make-objc-block`, "Racket-native" file I/O) and claims 6/7
  complexity; verify every layout / toolbar / dirty-state / panel / undo claim
  against what the four impls actually realize.
- **App-specific:** persistence mutates on-disk state — note per impl the save
  path mechanics (NSSavePanel sheet + completion block vs direct write), where
  file I/O happens (target-native vs Cocoa API — a projection hole if it varies),
  and what each save/open/new/undo action makes observable (title, status label,
  `setDocumentEdited:` close-box dot, log lines). The WKWebView preview renders via
  `loadHTMLString:` (no navigation) — note per impl whether render completion is
  observable (delegate? nothing?) and what of the rendered HTML is AX/OCR-visible
  in-VM (the k80 web-area findings apply). NSAlert unsaved-changes flow: note the
  exact trigger set (New only? Open too? window close? quit?) per impl — the
  boundary/error lines the omission guard wants. Panels are out-of-process-style
  system chrome: driver guidance (keyboard-driven Cmd-Shift-G etc., the k103 rule)
  belongs in §13.

## Done when

`apps/macos/note-editor/docs/spec.md` is the validated reverse-gen spec (first H1
bundler-safe — the display name), committed with the modeling notes reviewed;
unsupported claims grounded or cut, gaps honestly marked `(to confirm in-VM)`.

## Notes

The behavioural-exemplar section is the forward-gen input for the later suite child —
it should enumerate type→preview-rerender, dirty-state transitions, save (first +
subsequent), open, new-with-unsaved-changes alert, undo/redo, and empty state as
observable assertions where in-VM-verifiable, not just launch/quit
([[sample_apps_perfect]]). Where a behaviour has no observable witness (preview
render completion, sheet dismissal), that gap is a finding, not a failure — it seeds
the conformance/instrument children.

## Status — done 2026-07-03 (validated & accepted)

Subagent dispatched per the AppSpec workflow; modeling notes worked; load-bearing
witnesses mechanically re-verified against all four sources (window 900×600 / min
520×360 ×4; title rule `<name> — Note Editor` / `<name> — edited — Note Editor` +
basename ×4; status vocabulary Ready/Opened/Saved/`Open failed: `/`Save failed: `/
New-document ×4; alert style/message-per-trigger/informative/Discard-then-Cancel ×4;
`untitled.md` name-field rule ×4; confirm-discard callers = New+Open ONLY ×4; no
observer removal, no app delegate, no `applicationShouldTerminate*` ×4; toolbar order
New/Open…/Save…/Undo/Redo/status + firstBaseline + spacing 8 ×4; split `setVertical:`
×4; richText #f / allowsUndo / usesFindBar / fixed-pitch-13 / status-system-11 ×4
incl. the 3-of-4 alignment variation; `loadHTMLString:baseURL:` nil base ×4; save
branch path→direct-write else sheet; heading 1–6-hash+whitespace guard; extensions
md/markdown/txt). Zero discrepancies; spec accepted verbatim. Key acceptances:

- **Complexity corrected 6/7 → 3/7** (catalogue rank; the k113 correction class).
- **Precursor over-claims cut:** close-to-quit (no delegate anywhere; app-kind
  `ns-application-terminate` wins — the hello-window correction repeated); in-template
  JS renderer (all four render app-side, template is CSS-only); links support (no rule
  in any renderer); "system font" editor (all four `userFixedPitchFontOfSize: 13`);
  Cmd-Z/Cmd-Shift-Z (no Edit menu exists — buttons are the only undo surface);
  persistent path-in-status (vocabulary is transient); title-shows-path (basename).
- **Common-mode flags confirmed standing:** (1) data-loss on quit/close — the unsaved
  guard covers New/Open only, quit/close silently discard (unanimous ×4, verified;
  spec carries it as explicit boundary §3.10/§8.5.10 + in-VM marker); (2)
  process-lifetime observer never unregistered (×4; `observer` kind cited with
  unexercised-law caveat); (3) `NSModalResponseOK`/`NSAlertFirstButtonReturn`
  hand-defined in every impl (collector gap, noted §11.1).
- **File I/O is deliberately target-native** (each impl's own comments) — elevated to
  a stated design rule (§1/§8), the projection hole handled as an abstract operation.
- **Handoff to conformance/instrument children:** launch-line prefixes diverge
  (racket/chez/gerbil `Note Editor running. Close window or Ctrl+C to exit.` vs sbcl
  `Note Editor opened. … Quit with Cmd-Q.`) — the contract must pick the prefix rule
  (k114 mirror); **the app currently emits NO per-operation log lines** — the status
  label is the sole message surface, and preview render completion is unobservable —
  so save/open/new/dirty (+ possibly render) need contract log events to be assertable
  without OCR races (the `[nav]` precedent); failure `<detail>` diverges (racket
  exn-message vs path ×3) — a contract-alignment candidate; the dirty dot is
  unobservable, the window AX title is the channel (sbcl VM notes); NSOpenPanel file
  cells absent from the AX tree → Cmd-Shift-G drive; alert/sheet/panel AX shapes need
  observable-state rows; persistence needs a writable VM dir (~/Documents precedent) +
  per-scenario cleanup discipline.
