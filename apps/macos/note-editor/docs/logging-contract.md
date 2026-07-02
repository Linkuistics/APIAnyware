# Note Editor — Logging Contract

> **Porting guide.** Every implementation of Note Editor MUST satisfy this contract to be
> verifiable by the AppSpec scenario runner. It follows the hello-window contract
> ([../../hello-window/docs/logging-contract.md](../../hello-window/docs/logging-contract.md), the
> worked template) and extends it with **document and preview events**: the spec's load-bearing
> async pattern is the **save sheet's completion handler** (§8.4) — the save resolves on the
> sheet's schedule, so save completion is not assertable without a log record; the app otherwise
> has **no per-operation message surface beyond the 11-pt status label** (§6.3 — the OCR
> small-text class), and **preview render completion is entirely unobservable** (§5.4) — so the
> impl logs its document-state transitions and its render hand-offs.

## Why a log file (not stdout)

Same rationale as hello-window (see that contract's "Why a log file" for the full derivation):
the runner launches a GUI impl via `open` (LaunchServices), which **discards stdout**, and
instead **tails a structured event-log file** the impl writes itself
(`AppSpec/runner/log-tail.rkt`; `wait-ready` in `setup-scenario!`). Every log assertion
(`wait-for-log`, `expect-log`, `wait-ready`) reads **events.log**, never stdout.

Spec §3 step 8 mandates a one-line launch diagnostic **beginning `Note Editor`** on standard
output. Reconciled as in hello-window: the impl SHOULD keep its existing stdout line
(human-friendly when run unbundled, literally true to §3) **and** MUST emit the same line to
events.log (so the runner sees it) — dual emission.

## The events.log file

- **Path resolution** (the impl, on startup): the value of `NOTE_EDITOR_EVENTS_LOG` if set and
  non-empty; otherwise the **fixed default** `/tmp/note-editor/events.log`. The impl
  descriptor's `#:events-path` mirrors the same default, so the runner tails the right file
  whether or not the env var propagates through LaunchServices under `launch-via 'open`.
- **Lifecycle:** truncated on impl startup (parent dir created if missing). The runner also
  truncates it between scenarios; the two truncations compose cleanly.
- **Buffering:** line-buffered, flushed after every record.
- **Single writer:** every event in this contract is emitted on the main thread — startup, the
  initial render, and the launch line before `-run`; the `[document]`/`[preview]` events from
  the five action handlers, the text-change notification observer, and the save sheet's
  completion handler, all of which AppKit delivers on the main thread; shutdown on the
  terminate path — so one port with post-write flush suffices.

## Line format

```
[<module>] <event-name> <key>=<value> <key>=<value>\n
```

Strings are double-quoted with `\\`/`\"`/newline escaped; numbers/booleans/symbols emit bare.
Booleans emit as the bare symbols **`true` / `false`** (the contract defines the bytes — a
runtime's native boolean print form, e.g. `#t`, does not conform). This app's events use
`<module>` ∈ {`lifecycle`, `document`, `preview`}.

## Lifecycle events

| Event line | Emitted when | Runner consumer | Matcher |
|---|---|---|---|
| `[lifecycle] startup` | first record, right after opening events.log — before window/split-view construction, well before `-run` | `wait-ready` readiness probe (`setup-scenario!`) | `#px"\\[lifecycle\\] startup"` |
| the launch line, bare, beginning `Note Editor` | once the window is key+front and the app activated, before `-run` (spec §3 step 8) | `wait-for-log` / `expect-log` | `#rx"Note Editor"` |
| `[lifecycle] shutdown reason=<r>` | on the terminate path (`applicationWillTerminate` / Quit), before exit | `quit-impl!` / the Command-Q scenario | reason ∈ {`menu`, `signal`, `error`} |

Notes:
- The launch line **begins with** `Note Editor` (the spec asserts the prefix); the remainder is
  impl-specific and **stays unaligned** (today: racket/chez/gerbil `Note Editor running. Close
  window or Ctrl+C to exit.`; sbcl `Note Editor opened. Type Markdown on the left; preview
  renders on the right. Quit with Cmd-Q.` — all conform; the scenekit-viewer prefix-rule
  precedent). Emit it as a **bare line** (not bracketed) and keep the existing stdout print
  (dual emission).
- The launch sequence is synchronous main-thread code, so its event order is deterministic:
  `[lifecycle] startup` → `[preview] rendered placeholder=true chars=0` (the §3 step 5 initial
  render) → the bare launch line (§3 step 8). `startup` must land **before** the impl blocks in
  the AppKit run loop, or `wait-ready` times out.
- `shutdown reason=menu` is the Command-Q / menu-Quit path — the exercised terminate path;
  `reason=signal` covers SIGTERM; `reason=error` an uncaught exception. (All four runtimes
  ignore SIGTERM under `nsapplication-run` — the ui-controls-gallery k94 observation — so the
  signal path stays unexercised in practice.) `shutdown` fires on quit-with-unsaved-edits too —
  §3.10 mandates no guard on the terminate path. **Closing the window emits nothing** (no
  terminate happens, §3.10); a `shutdown` on window-close observed at live-run would be a
  spec-quality finding.
- The pre-instrumentation impls install no application delegate (spec §3); the instrumentation
  adds the `applicationWillTerminate:` hook exactly as the prior five apps' instrument stages
  did in all four impls.

## Document events (the editor-specific part)

Six events — the document-model transitions of §8 plus the §6.2 dirty flip — and **no others**
(the cancel/no-op boundaries are silent, see below). All are emitted **post-state**: after the
operation's whole rule has run (text, path, dirty flag, title refresh, preview re-render where
the rule includes one, status line), so a `wait-for-log` hit guarantees every state channel —
though the repaint may lag; settle before screenshots.

| Event line | Emitted when | §15 assertion served | Matcher (example) |
|---|---|---|---|
| `[document] new path="" dirty=false` | end of the §8.2 New rule | New clears everything; clean New proceeds without an alert | `#px"\\[document\\] new"` |
| `[document] opened path="/tmp/note-editor/fixtures/fixture-note.md" dirty=false` | end of the §8.3 Open success path, after `runModal` returns OK and the read+state update completes | Open loads a file (the reliable open-completed cue after the Cmd-Shift-G drive) | `#px"\\[document\\] opened path=\"/tmp/note-editor/fixtures/fixture-note\\.md\""` |
| `[document] saved path="/tmp/note-editor/work/untitled.md" dirty=false` | end of the §8.4 write+state update — **both branches**: the direct write, and **inside the sheet's completion handler** (the async re-entry witness) | first save via the sheet; **subsequent saves are direct** (a `saved` with no sheet interaction is the witness); the file-write cue for `expect-file`/`read-file` | `#px"\\[document\\] saved path=\"/tmp/note-editor/work/untitled\\.md\" dirty=false"` |
| `[document] open-failed path="/tmp/note-editor/fixtures/locked.md" dirty=false` | the §8.5.6 read-failure path, after the status line is set | read failure surfaces; model untouched | `#px"\\[document\\] open-failed"` |
| `[document] save-failed path="/System/nope.md" dirty=true` | the §8.5.7 write-failure path, after the status line is set | write failure surfaces; the dirty title persists | `#px"\\[document\\] save-failed"` |
| `[document] dirty-changed path="" dirty=true` | the §6.2 clean→dirty **flip only** (step 1), after the title refresh — never per-keystroke | typing marks the document dirty (the log half; the window AX title is the state half) | `#px"\\[document\\] dirty-changed .*dirty=true"` |

Semantics + realization notes:
- **Key order is fixed** as shown: `path` then `dirty`, on every `[document]` event, so
  multi-key regex matchers can rely on adjacency.
- **`path`** — on the state events (`new`/`opened`/`saved`/`dirty-changed`): the **post-state
  current path**, empty string when unset (so `new` always carries `path=""`, and a
  `dirty-changed` on an Untitled document does too). On the failure events
  (`open-failed`/`save-failed`): the **attempted file's absolute path** — the model is
  unchanged by rule (§8.5.6/7), so the attempted path is the informative datum. This is the
  **normalized failure channel**: the *visible* status keeps each impl's realized `<detail>`
  (racket: the exception message; chez/gerbil/sbcl: the path — spec §6.3) and the contract does
  **not** mandate visible-text alignment; the stable visible observables are the
  `Open failed: ` / `Save failed: ` prefixes, and the event's `path` key is the exact-matchable
  channel (the mini-browser `phase`-normalization precedent).
- **`dirty`** — the post-state flag. `new`/`opened`/`saved` carry `dirty=false` by rule (the
  §6.1 title rule derives from exactly this `path`+`dirty` pair, so each event line states the
  state the window title must now reflect — the mini-browser `finished`-carries-the-refresh
  precedent). The failure events carry the (unchanged) flag as it stands.
- **`dirty-changed` fires only on the transition**, not on every notification: §6.2 step 1 sets
  the flag only when not already set. The dirty→clean direction needs no event of its own —
  `new`/`opened`/`saved` *are* those transitions.
- **Undo/Redo emit no dedicated events.** A text-mutating Undo/Redo is expected to drive the
  same notification path as typing (§9 — platform coupling, to confirm in-VM), so its
  observable log trace is `dirty-changed` (when the flag flips) + `[preview] rendered`; the
  live-run stage uses exactly these events to firm §9's coupling unknown. A no-op Undo/Redo
  (§8.5.8) is silent.
- **Silent no-ops emit nothing:** the §8.1 alert dismissed with Cancel, the open panel
  cancelled, the save sheet cancelled, the §8.4 nil-URL/empty-path guards, clean New/Open
  passing straight through the (skipped) alert, no-op Undo/Redo, window close. The state
  channels (AX title, status line) are their observables; **absence of an event is never
  asserted**.
- **The §8.1 confirmation alert emits nothing** — it is a synchronous response to the runner's
  own click (unlike mini-browser's async failure alert, which needed a pre-modal cue), so the
  runner waits on the alert's AX/OCR presence directly.
- **Never count events, never assume cross-operation ordering.** Within one driven operation
  the order is deterministic (`dirty-changed` → `rendered` within a first keystroke;
  `rendered` → `new`/`opened` within a New/Open, since those rules re-render mid-rule and the
  document event is post-state; `saved` follows no render at all — §7 excludes Save). Suites
  match the specific line they drove to, never a count or a strict global sequence.
- **Instrumentation must not change visible behaviour** — no new UI, no extra dialogs, no
  alignment of the launch-line remainder or the visible failure `<detail>` realizations.

## Preview events

One event, mirroring the scenekit `[scene]` pattern (unobservable content → the log carries the
app-state half; the pixels stay OCR/screenshot):

| Event line | Emitted when | §15 assertion served | Matcher (example) |
|---|---|---|---|
| `[preview] rendered placeholder=false chars=7` | at every §7 render, immediately **after** the `loadHTMLString:` hand-off | placeholder at launch/New/undo-to-empty; the preview tracks edits and Open (the app-side half; the rendered pixels are OCR's) | `#px"\\[preview\\] rendered placeholder=true chars=0"` after undo-to-empty; `#px"rendered placeholder=false chars=7"` after typing 7 characters |

Semantics + realization notes:
- **Key order fixed:** `placeholder` then `chars`.
- **`placeholder`** = `true` iff the §7.1 placeholder body was rendered (editor text empty or
  whitespace-only after trimming), else `false`.
- **`chars`** = the count of Unicode scalar values of the **editor text the render consumed**
  (the Markdown source, not the HTML; `0` for the empty document). Suites bind exact values
  only for ASCII content they themselves drove.
- **The event witnesses the hand-off, not the pixels.** Render completion remains unobservable
  (§5.4 — no callback exists); this event proves the §7 trigger ran and what it consumed.
  Whether the result is visible/legible rides OCR (spec §13's to-confirm), and the split makes
  OCR failures adjudicable: a present `rendered` line + a failed OCR read is a run-mechanism
  red, not an impl defect.
- **Triggers** (§7): startup, **every** text-change notification, New, Open — **not** Save.
  Per-keystroke volume is expected and fine (the runner tails; suites match the *final* state
  line they drove to — e.g. `chars=7` after typing `# Hello` — never counts). No-render on
  Save is **not** asserted (absence rule).

## Test-config compatibility

As hello-window: the descriptor's REQUIRED `#:test-config-path` is passed as
`NOTE_EDITOR_TEST_CONFIG`. The editor reads **no** runtime config — honour the env var
gracefully (absent/empty ⇒ "no config"), fixed default mirrored by the descriptor
`/tmp/note-editor/test-config.scm`; a missing file is not an error.

## Conformance checklist (per impl — the instrument+build children implement this)

- [ ] On startup: resolve events-path (`NOTE_EDITOR_EVENTS_LOG` →
      `/tmp/note-editor/events.log`), truncate-open line-buffered, create the parent dir.
- [ ] Emit `[lifecycle] startup` as the first record, before window/split-view construction /
      `-run`.
- [ ] Emit `[preview] rendered placeholder=<b> chars=<n>` at every §7 render (startup's initial
      render included), immediately after the `loadHTMLString:` hand-off, keys in the fixed
      order.
- [ ] Emit the bare launch line beginning `Note Editor` to events.log once the window is
      key+front (keep the existing stdout print).
- [ ] Emit `[document] dirty-changed` on the §6.2 clean→dirty flip only, after the title
      refresh.
- [ ] Emit `[document] new` / `opened` / `saved` post-state at the end of each §8 rule —
      `saved` in **both** branches, the sheet branch **inside the completion handler**; keys in
      the fixed order `path` `dirty` (booleans as bare `true`/`false`, unset path as `""`).
- [ ] Emit `[document] open-failed` / `save-failed` from the §8.5.6/7 failure paths with the
      **attempted** path + the post-state dirty flag, after the status line is set.
- [ ] Emit `[lifecycle] shutdown reason=<menu|signal|error>` on the terminate path (add the
      `applicationWillTerminate:` hook as the prior apps' instrumentation did), then
      flush+close.
- [ ] Honour `NOTE_EDITOR_TEST_CONFIG` gracefully (no config needed; absent ⇒ default).
- [ ] Build to a `.app` whose `CFBundleIdentifier` equals the descriptor's `#:bundle-id`
      (`com.linkuistics.note-editor-<impl>`; sbcl's `build.sh` today writes the unsuffixed
      `com.linkuistics.note-editor` and omits the kind-required
      `CFBundleInfoDictionaryVersion` — both align at the instrument stage, the k104/k114
      mirror).
