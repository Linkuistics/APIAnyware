# PDFKit Viewer — Logging Contract

> **Porting guide.** Every implementation of PDFKit Viewer MUST satisfy this contract to be
> verifiable by the AppSpec scenario runner. It follows the hello-window contract
> ([../../hello-window/docs/logging-contract.md](../../hello-window/docs/logging-contract.md), the
> worked template) and extends it with **document events**: the spec §13 document-open and
> page-navigation assertions turn on state the runner cannot read otherwise — the nav-button
> enabled flags are dropped by the current AX-snapshot transform (see
> [observable-state.md](observable-state.md) "gap observables"), and the label's OCR can catch a
> pre-repaint frame — so the impl logs its document-state transitions.

## Why a log file (not stdout)

Same rationale as hello-window (see that contract's "Why a log file" for the full derivation): the
runner launches a GUI impl via `open` (LaunchServices), which **discards stdout**, and instead
**tails a structured event-log file** the impl writes itself (`AppSpec/runner/log-tail.rkt`;
`wait-ready` in `setup-scenario!`). Every log assertion (`wait-for-log`, `expect-log`,
`wait-ready`) reads **events.log**, never stdout.

Spec §3 step 7 mandates a one-line launch diagnostic **beginning `PDFKit Viewer`** on standard
output. Reconciled as in hello-window: the impl SHOULD keep its existing stdout line
(human-friendly when run unbundled, literally true to §3) **and** MUST emit the same line to
events.log (so the runner sees it) — dual emission.

## The events.log file

- **Path resolution** (the impl, on startup): the value of `PDFKIT_VIEWER_EVENTS_LOG` if set and
  non-empty; otherwise the **fixed default** `/tmp/pdfkit-viewer/events.log`. The impl
  descriptor's `#:events-path` mirrors the same default, so the runner tails the right file
  whether or not the env var propagates through LaunchServices under `launch-via 'open`.
- **Lifecycle:** truncated on impl startup (parent dir created if missing). The runner also
  truncates it between scenarios; the two truncations compose cleanly.
- **Buffering:** line-buffered, flushed after every record.
- **Single writer:** every event in this contract is emitted on the main thread — startup and the
  launch line before `-run`; the `[document]` events from the open-button action callback and the
  page-changed notification observer, both of which the Cocoa run loop serialises (the default
  notification center delivers on the posting thread, and PDFKit posts on main); shutdown on the
  terminate path — so one port with post-write flush suffices.

## Line format

```
[<module>] <event-name> <key>=<value> <key>=<value>\n
```

Strings are double-quoted with `\\`/`\"`/newline escaped; numbers/booleans/symbols emit bare.
This app's events use `<module>` ∈ {`lifecycle`, `document`}.

## Lifecycle events

| Event line | Emitted when | Runner consumer | Matcher |
|---|---|---|---|
| `[lifecycle] startup` | first record, right after opening events.log — before window/PDF-view construction, well before `-run` | `wait-ready` readiness probe (`setup-scenario!`) | `#px"\\[lifecycle\\] startup"` |
| the launch line, bare, beginning `PDFKit Viewer` | once the window is key+front and the app activated, before `-run` (spec §3 step 7) | `wait-for-log` / `expect-log` | `#rx"PDFKit Viewer"` |
| `[lifecycle] shutdown reason=<r>` | on the terminate path (`applicationWillTerminate` / Quit), before exit | `quit-impl!` / the Command-Q scenario | reason ∈ {`menu`, `signal`, `error`} |

Notes:
- The launch line **begins with** `PDFKit Viewer` (the spec asserts the prefix); the remainder is
  impl-specific. Emit it as a **bare line** (not bracketed) and keep the existing stdout print
  (dual emission).
- `startup` must land **before** the impl blocks in the AppKit run loop, or `wait-ready` times out.
- `shutdown reason=menu` is the Command-Q / menu-Quit path — the exercised terminate path;
  `reason=signal` covers SIGTERM; `reason=error` an uncaught exception. (All four runtimes ignore
  SIGTERM under `nsapplication-run` — the ui-controls-gallery k94 observation — so the signal path
  stays unexercised in practice.)
- The pre-instrumentation impls install no application delegate (spec §3); the instrumentation
  adds the `applicationWillTerminate:` hook exactly as the hello-window and ui-controls-gallery
  instrument stages did in all four impls.

## Document events (the viewer-specific part)

Exactly two events — the document-state transitions of spec §6/§7. Each is emitted **after** the
state change it names is applied (post-state: label text and button enabled states already set
when the line is written, so a `wait-for-log` hit guarantees the UI state — though the repaint may
lag; settle before screenshots, spec §13):

| Event line | Emitted when | §13 assertion served | Matcher (example) |
|---|---|---|---|
| `[document] opened file="fixture.pdf" pages=3` | the open-button action handler's **success path only** (§6 step 7) — after the document is stored, assigned to the view, and the UI-refresh rule (§7.2) has run | open loads page 1 (the reliable open-completed signal) | `#px"\\[document\\] opened file=\"fixture\\.pdf\" pages=3"` |
| `[document] page-changed page=2 pages=3` | the page-changed notification observer callback (§7.3), after the UI-refresh rule has applied the label + button states | advance / back / boundary / non-button navigation | `#px"\\[document\\] page-changed page=3 pages=3"` at the last page |

Semantics + realization notes:
- **`file` is the opened URL's last path component** (e.g. `fixture.pdf`), never the full path:
  the open panel canonicalizes paths (`/tmp/…` may come back `/private/tmp/…`), so the basename is
  the stable identity the suite can exact-match. How an impl derives it is free
  (`-[NSURL lastPathComponent]`, `-[NSString lastPathComponent]` on `path`, or the language's own
  basename). `pages` = the document's `pageCount`. The PDF's metadata title is deliberately **not**
  used (often absent, and outside the exercised surface — spec §9).
- **`page` is 1-based and always equals the label's *n*** (`Page n of N`); `pages` equals *N*. The
  event mirrors the label, including its boundary fallback: a transiently nil current page (§7.2)
  logs `page=1`. All values are bare integers.
- **Silent no-ops emit nothing.** Cancel, a nil panel URL, and a failed `initWithURL:` (§6
  boundaries) are spec-mandated silent no-ops — no event, no error line. Absence of `opened` *is*
  the contract; consumers assert the persisting empty state via OCR/AX
  ([observable-state.md](observable-state.md)), never via a negative log read.
- **`opened` fires once per successful open**, including an open that replaces an already-loaded
  document (§6 step 7).
- **Consumers must not count `page-changed` events or assume their ordering relative to
  `opened`.** Assigning a document may itself fire the page-changed notification **(platform
  behaviour — to confirm in-VM)**, so a successful open may log `page-changed page=1 …` as well;
  keyboard-arrow and scroll navigation (§7.1) also fire it, possibly several times. Match the
  specific line you drove to (e.g. `page=2 pages=3`), never a count or a strict sequence.
- **Instrumentation must not change visible behaviour** — no new UI, and no error dialogs (spec
  §12 excludes them).

## Test-config compatibility

As hello-window: the descriptor's REQUIRED `#:test-config-path` is passed as
`PDFKIT_VIEWER_TEST_CONFIG`. The viewer reads **no** runtime config — honour the env var
gracefully (absent/empty ⇒ "no config"), fixed default mirrored by the descriptor
`/tmp/pdfkit-viewer/test-config.scm`; a missing file is not an error.

## Conformance checklist (per impl — the instrument+build children implement this)

- [ ] On startup: resolve events-path (`PDFKIT_VIEWER_EVENTS_LOG` →
      `/tmp/pdfkit-viewer/events.log`), truncate-open line-buffered, create the parent dir.
- [ ] Emit `[lifecycle] startup` as the first record, before window/PDF-view construction / `-run`.
- [ ] Emit the bare launch line beginning `PDFKit Viewer` to events.log once the window is
      key+front (keep the existing stdout print).
- [ ] Emit `[document] opened` from the open handler's success path only, post-state
      (`file` = URL basename, `pages` = pageCount).
- [ ] Emit `[document] page-changed` from the page-changed notification observer, post-state
      (1-based `page`, total `pages`).
- [ ] Emit `[lifecycle] shutdown reason=<menu|signal|error>` on the terminate path (add the
      `applicationWillTerminate:` hook as hello-window's instrumentation did), then flush+close.
- [ ] Honour `PDFKIT_VIEWER_TEST_CONFIG` gracefully (no config needed; absent ⇒ default).
- [ ] Build to a `.app` whose `CFBundleIdentifier` equals the descriptor's `#:bundle-id`
      (`com.linkuistics.pdfkit-viewer-<impl>`).
