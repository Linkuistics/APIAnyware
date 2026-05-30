# 020-ui-controls-gallery

**Kind:** work

## Goal
Build `ui-controls-gallery` as an open-world standalone `.app` and VM-verify it in
a no-Chez VM.

## Context
- First **dispatch-using** app in the ladder: sync delegate — NSTextField action
  handlers + NSButton target/action (spec §7). This is the first standalone build
  to exercise the `eval`-synthesised `foreign-callable` trampolines
  (`dispatch.sls`) **inside the embedded `scheme` boot**. The spike proved the
  embedded compiler exists; this is the first *real* dispatch-using app to run on
  it, so a dispatch regression localises here.
- Larger import closure than hello-window (358 LOC racket) → first chance for
  wrapper collisions beyond the known 4.

## Done when
- `ui-controls-gallery.app` builds via `bundle_app` (open-world standalone).
- TestAnyware run in a no-Chez VM is green: controls render, button/textfield
  actions fire (delegate dispatch works in the standalone binary), visual polish
  bar met ([[feedback-sample-apps-perfect]]).
- Any new wrapper collisions or dispatch-under-whole-program quirks noted in
  `knowledge/targets/chez.md`.

## Notes
- If dispatch fails here, it is the embedded-boot `eval` substrate, not the app —
  confirm the runtime `eval` path survives whole-program optimisation before
  touching app code.
