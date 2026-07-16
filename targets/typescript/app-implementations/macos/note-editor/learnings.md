# note-editor — learnings (Node TypeScript target, ladder app 6/7)

The widest feature surface of the Node TypeScript ladder so far: `NSTextView`/`NSSplitView`/
`NSScrollView`, `NSUndoManager`, and the first **production** exercise (outside the native test
harness) of the escaping-block `NSSavePanel` sheet completion handler that
`block-call-site-emission-k120` unblocked, and of the `NSTextView.allowsUndo`/
`NSResponder.undoManager` surface `text-undo-surface-gap-k121` unblocked. Built and VM-verified —
no runtime or emitter changes needed, matching sbcl's own capstone note-editor's "it just composed"
result for this target too. One genuine, newly-surfaced-in-VM finding (undo history bleeding
across a New/Open document swap), one spec "(unknown — to confirm in-VM)" boundary resolved live,
and the usual VM-provisioning notes (identical shape to pdfkit-viewer/mini-browser's own).

## Finding: `NSUndoManager` history is not reset by `setString:` — Undo can splice stale edits into a freshly loaded document

Not a bug in this app or in the TypeScript binding — confirmed, reproducible, inherent AppKit
behaviour, worth recording because it was caught live in this session and none of the four
reference implementations' specs (nor their own source) call for clearing it either.

**What happened:** after a first editing/save session, clicking `New` (clean → no alert) reset the
buffer via `textView.setString_('')`, a fresh string `"Draft text that should not be saved."` was
typed, `Save…` was cancelled (Escape), then `Open…` (after the Discard alert) loaded
`fixture-note.md` via `textView.setString_(fileContents)`. Clicking `Undo` once at that point did
**not** no-op and did **not** revert the fixture load — it corrupted the just-opened fixture text,
deleting its first 37 characters (`"# FIXTURE NOTE\n\nA paragraph with **b"`) and leaving
`"old**, *italic*, and \`code\` spans."` as the new first line, with the title flipping to
`— edited —`.

**Root cause (confirmed by exact character count, not assumed):** `"Draft text that should not be
saved."` is exactly 37 characters. `NSUndoManager` records `NSTextView` edits as **character-range
replacements against buffer positions**, not semantic diffs, and `setString:` — used by both `New`
(§8.2) and `Open` (§8.3) to swap the whole buffer — does **not** clear or invalidate the pending
undo stack. So the most recent real *typing* group left on the stack (inserting the 37-character
draft string at position 0 of what was then an empty buffer) was still there when `Undo` fired
after `Open` had since replaced the buffer with unrelated content; the undo manager faithfully
replayed "delete range [0, 37)" against the *new* text, which happens to correspond exactly to the
fixture's own leading `"# FIXTURE NOTE\n\nA paragraph with **b"`.

**Not a checklist failure:** the spec's own §15 Undo/Redo scenario is scoped to "after typing into
a fresh document," which this session also verified cleanly on its own (relaunch → type `# Hello`
→ repeated `Undo` reverts cleanly to the placeholder → `Redo` restores it, with **no** stale
history in play since the process was fresh). The corruption only appears when the operator
sequence is "type a lot, `New`/`Open` away from it, then `Undo`" — a real, occasionally-surfacing
edge case shared by every reference implementation's own design (none call
`textView.undoManager()?.removeAllActions()`, or an equivalent, on `New`/`Open`; the spec is silent
on it), not something this app's own TypeScript-specific code does differently. Left unfixed here
per this task's scope (the app is believed complete/correct against the spec, and the spec itself
does not mandate clearing undo history) — worth flagging if a future spec revision or a dedicated
correctness pass wants to close it (the fix, if wanted, is a one-line
`this.textView.undoManager()?.removeAllActions()` in both `doNew`/`loadFile`).

## Finding: the SavePanel sheet's block completion handler works end-to-end in real production use

`app.ts`'s own header comment already noted the sheet call site (`beginSheetModalForWindow_
completionHandler_`) was unblocked by `block-call-site-emission-k120` and exercised by
`native/test/undo-manager.mjs`-adjacent test harnesses; this app is the first to run it as real
production traffic, live in a VM. Confirmed working exactly as designed across two distinct calls
in this session: the sheet opened prefilled `untitled.md` (extension hidden per macOS display
convention), Cmd-Shift-G + a real path + Return dismissed it, the completion handler re-entered the
JS closure with the modal response, read `panel.URL()`/`.path()`, and wrote the file — byte-exact
(135 bytes, `diff`-confirmed) against what was typed. The Escape-cancel path was exercised too
(response ≠ `NSModalResponseOK`, short-circuits before any write) with no special handling needed
beyond the guard already in `promptSave`.

## Finding: the per-keystroke allocation load sbcl's own learnings flagged is a non-issue here too

sbcl's `note-editor` learnings flagged this app (full Markdown rebuild + `loadHTMLString` on every
keystroke) as the highest allocation-pressure sample in the whole portfolio, and the specific case
that killed gerbil's weak-delegate observer under GC. This session typed several dozen keystrokes
continuously across a heading, a paragraph with three inline spans, a two-item list, and a fenced
block, with the preview re-rendering live on every one — no dropped notifications, no dead
callback, no lag. The module-scope `const controller` reference (`app.ts`'s own comment already
calls out why) is sufficient here exactly as it is for every other ladder app's controller — this
target's dispatch backend has no weak-reference GC hazard analogous to gerbil's `make-delegate`
wrappers, so the concern sbcl's own notes raised does not carry over structurally, matching what
mini-browser's own delegate-lifetime finding already established for a different callback shape.

## Finding: `nsToString`'s per-character cost stayed invisible at this app's real string sizes

The note bodies exercised in this session topped out at 135 bytes (the saved file) and 123 bytes
(the fixture) — well within "short strings" territory. No visible per-character-crossing lag was
observed reading `textView.string()` back on every save/keystroke. This is consistent with
mini-browser's own learnings, which flagged this helper's `characterAtIndex_` loop as a future
reconsideration point only for "a text document's full contents" at real scale — this app's actual
VM-driven documents never got large enough to test that boundary; the helper remains
correctness-sufficient and untouched.

## Finding (spec boundary resolved in-VM): closing the window hides it; the process keeps running

Spec §3.10/§13/§15 flagged this explicitly as "(unknown — to confirm in-VM)," with a caveat that
three of the four reference implementations' own printed guidance ("Close window or Ctrl+C to
exit") suggested the opposite. This app's own launch line carries no such suggestion (`"Note Editor
opened. ... Quit with Cmd-Q."` — no close-window mention at all). Confirmed live: clicking the
window's close control removes it from `testanyware agent windows`'s output, but the process still
appears in `pgrep` immediately after — closing does **not** quit. Matches the app's own
construction (`app.ts` installs no `NSApplicationDelegate` at all, so there is nothing to opt into
terminate-after-last-window-closed), and confirms the spec's own prediction over the printed-text
red herring.

## VM-provisioning / tooling notes (continuing prior apps' own)

- **The Homebrew dylib closure is identical to pdfkit-viewer's/mini-browser's own 20-formula set**
  (same `libnode`/`libuv` transitive graph, 59 MB compressed `lib/`-only vendoring, `/opt/homebrew/
  opt/<formula>` symlinks recreated pointing at the vendored Cellar version dirs). The native addon
  needed zero additional vendoring — its `otool -L` closure is entirely system frameworks/dylibs.
- **No new `-framework` link was needed.** `build.sh` already links `AppKit`/`Foundation`/
  `CoreFoundation`/`WebKit` (WebKit carried over from mini-browser); every class this app newly
  touches (`NSTextView`, `NSSplitView`, `NSScrollView`, `NSUndoManager`, `NSSavePanel`) is plain
  AppKit — no PDFKit-style "not resident in the process" surprise this time.
- **Cmd-Shift-G with a full path to a not-yet-existing file auto-fills the Save panel's name
  field** with the typed basename (confirmed again here: typing
  `/Users/admin/Documents/ts-note-verify.md` via Go-to-Folder against the save sheet navigated to
  `Documents` *and* set the name field to `ts-note-verify`) — matching the established
  cross-target precedent for the open-panel case: it works the same way for the save sheet.
- **`agent snapshot` does not expose the static status label as a distinct queryable value** the
  way it does editable/button elements, consistent with mini-browser's own finding; status text was
  read via screenshot/OCR-by-inspection throughout this session instead.
- **Deployment preserved the same relative directory structure as the host**: `bootstrap.cjs`
  resolves the native addon via `../../../bindings/node/native/build/APIAnywareTypeScript.node`
  relative to its own directory — the deploy tarball placed `app-implementations/macos/
  note-editor/` and `bindings/node/native/build/` at that exact relative offset under
  `/Users/admin/apianyware-deploy/targets/typescript/...` on the guest, and it resolved with no
  path rewriting, exactly as pdfkit-viewer's/mini-browser's own notes predicted for a future app.
