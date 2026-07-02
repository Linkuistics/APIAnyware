# Mini Browser — Logging Contract

> **Porting guide.** Every implementation of Mini Browser MUST satisfy this contract to be
> verifiable by the AppSpec scenario runner. It follows the hello-window contract
> ([../../hello-window/docs/logging-contract.md](../../hello-window/docs/logging-contract.md), the
> worked template) and extends it with **navigation events**: the spec's load-bearing feature is
> the **asynchronous, multi-callback navigation delegate** (§2/§7) — loads resolve on the
> framework's schedule, so navigation completion and failure are not assertable without a log
> record; and the ◀/▶ history-button **enabled flags** (§11's reliable history observable) are
> still dropped by the AppSpec AX-snapshot transform (see
> [observable-state.md](observable-state.md) "gap observables") — so the impl logs its
> navigation-state transitions, mirroring the four delegate callbacks.

## Why a log file (not stdout)

Same rationale as hello-window (see that contract's "Why a log file" for the full derivation): the
runner launches a GUI impl via `open` (LaunchServices), which **discards stdout**, and instead
**tails a structured event-log file** the impl writes itself (`AppSpec/runner/log-tail.rkt`;
`wait-ready` in `setup-scenario!`). Every log assertion (`wait-for-log`, `expect-log`,
`wait-ready`) reads **events.log**, never stdout.

Spec §3 step 7 mandates a one-line launch diagnostic **beginning `Mini Browser`** on standard
output. Reconciled as in hello-window: the impl SHOULD keep its existing stdout line
(human-friendly when run unbundled, literally true to §3) **and** MUST emit the same line to
events.log (so the runner sees it) — dual emission.

## The events.log file

- **Path resolution** (the impl, on startup): the value of `MINI_BROWSER_EVENTS_LOG` if set and
  non-empty; otherwise the **fixed default** `/tmp/mini-browser/events.log`. The impl
  descriptor's `#:events-path` mirrors the same default, so the runner tails the right file
  whether or not the env var propagates through LaunchServices under `launch-via 'open`.
- **Lifecycle:** truncated on impl startup (parent dir created if missing). The runner also
  truncates it between scenarios; the two truncations compose cleanly.
- **Buffering:** line-buffered, flushed after every record.
- **Single writer:** every event in this contract is emitted on the main thread — startup and the
  launch line before `-run`; the `[nav]` events from the four `WKNavigationDelegate` callbacks,
  which WebKit delivers on the main thread (a fact each implementation's notes record from live
  runs — spec §10); shutdown on the terminate path — so one port with post-write flush suffices.

## Line format

```
[<module>] <event-name> <key>=<value> <key>=<value>\n
```

Strings are double-quoted with `\\`/`\"`/newline escaped; numbers/booleans/symbols emit bare.
Booleans emit as the bare symbols **`true` / `false`** (the contract defines the bytes — a
runtime's native boolean print form, e.g. `#t`, does not conform). This app's events use
`<module>` ∈ {`lifecycle`, `nav`}.

## Lifecycle events

| Event line | Emitted when | Runner consumer | Matcher |
|---|---|---|---|
| `[lifecycle] startup` | first record, right after opening events.log — before window/web-view construction, well before `-run` | `wait-ready` readiness probe (`setup-scenario!`) | `#px"\\[lifecycle\\] startup"` |
| the launch line, bare, beginning `Mini Browser` | once the window is key+front and the app activated, before `-run` (spec §3 step 7) | `wait-for-log` / `expect-log` | `#rx"Mini Browser"` |
| `[lifecycle] shutdown reason=<r>` | on the terminate path (`applicationWillTerminate` / Quit), before exit | `quit-impl!` / the Command-Q scenario | reason ∈ {`menu`, `signal`, `error`} |

Notes:
- The launch line **begins with** `Mini Browser` (the spec asserts the prefix); the remainder is
  impl-specific and **stays unaligned** (today: racket/chez/gerbil `Mini Browser running. Close
  window or Ctrl+C to exit.`; sbcl `Mini Browser opened. Type a URL + Return, navigate with
  ◀/▶/Reload. Quit with Cmd-Q.` — all conform; the scenekit-viewer prefix-rule precedent). Emit
  it as a **bare line** (not bracketed) and keep the existing stdout print (dual emission). The
  window *title* is the same text on a different channel (OCR/AX) — see
  [observable-state.md](observable-state.md).
- `startup` must land **before** the impl blocks in the AppKit run loop, or `wait-ready` times out.
  The initial load is kicked before the window is shown (spec §3 step 5), but its `[nav]` events
  only arrive once the run loop services the delegate — so the expected launch order is `startup`
  → launch line → `[nav] started` → `[nav] failed` (offline), with only `startup`-first guaranteed.
- `shutdown reason=menu` is the Command-Q / menu-Quit path — the exercised terminate path;
  `reason=signal` covers SIGTERM; `reason=error` an uncaught exception. (All four runtimes ignore
  SIGTERM under `nsapplication-run` — the ui-controls-gallery k94 observation — so the signal path
  stays unexercised in practice.)
- The pre-instrumentation impls install no application delegate (spec §3); the instrumentation
  adds the `applicationWillTerminate:` hook exactly as the prior four apps' instrument stages did
  in all four impls.

## Navigation events (the browser-specific part)

Exactly three events — the navigation-state transitions of spec §7, one per §7 sub-rule (the two
failure callbacks fold into one event exactly as §7.3 folds them into one rule) — and **no
others** (the §6.2 non-navigation boundaries are silent, see below). `started` and `finished` are
emitted **after** the state change they name is fully applied (post-state), so a `wait-for-log`
hit guarantees the chrome state — though the repaint may lag; settle before screenshots:

| Event line | Emitted when | §13 assertion served | Matcher (example) |
|---|---|---|---|
| `[nav] started url="https://example.com/"` | `didStartProvisionalNavigation` (§7.1), after the status line is set to the loading message | loading phase reached; **the `https://` prepend rule, offline** (`url` witnesses the normalized form even when the load then fails) | `#px"\\[nav\\] started"`; prepend: `#px"started url=\"https://not-a-url"` |
| `[nav] finished url="file:///tmp/mini-browser/fixtures/page-two.html" title="Fixture Page Two" can-go-back=true can-go-forward=false` | `didFinishNavigation` (§7.2), after the **whole** chrome-refresh rule has run (buttons, title, address, status) | success; canonical-URL write-back; window-title tracking; **history enablement** (the enabled-flag gap's operative channel) | `#px"\\[nav\\] finished url=\"file:.*can-go-back=true can-go-forward=false"` at the history head |
| `[nav] failed phase=request message="A server with the specified hostname could not be found."` | at entry to the §7.3 failure rule, **after the message is computed, before the modal alert runs** (see the deviation note) | offline initial load fails loudly; failure phase; the runner's **pre-dismissal cue** | `#px"\\[nav\\] failed"`; firmed later: `#px"failed phase=request"` |

Semantics + realization notes:
- **Key order is fixed** as shown (`url` · `title` · `can-go-back` · `can-go-forward`; `phase` ·
  `message`) so multi-key regex matchers can rely on adjacency.
- **`url`** = the web view's `URL` property's `absoluteString` at callback time, **empty string
  when nil**. On `finished` this is exactly the §7.2 address-field write-back value (canonical
  form). On `started` it is the provisional URL *(fidelity on provisional starts — nil windows,
  back/forward targets — to confirm in-VM; matchers bind `started url=` values only where the
  scenario drove a known load)*.
- **`title`** = the web view's `title` at callback time, empty string when nil — the same §7.2
  read. The **first-load title lag** (§7.2) means a first `finished` may carry `title=""` for a
  titled page — matchers must not assume a title before a *second* navigation.
- **`can-go-back` / `can-go-forward`** = the web view's history getters, read in the same §7.2
  refresh that sets the button enablement — the log value and the AX `enabled` flag are the same
  fact on two channels, and the log is the assertable one (the `expect-ax #:enabled?` gap,
  [observable-state.md](observable-state.md)).
- **`phase`** ∈ {`request`, `load`} — **normalized lowercase**: `request` = the provisional
  failure callback, `load` = the committed one (§7.3). The *status line's* phase word keeps each
  impl's realized spelling (sbcl capitalizes: `Load failed: …`) — the contract does **not**
  mandate visible-text alignment (the spec's stable observable is `failed: `); the normalized log
  key is the exact-matchable channel. Which callback fires for the offline initial load —
  expected `request` — is **to confirm in-VM**; match `#px"\\[nav\\] failed"` loosely until firmed.
- **`message`** = the error's `localizedDescription`, or the literal `Unknown error` on the §7.3
  nil-error boundary (the event is still emitted; no alert follows). Platform-formatted text —
  match substrings or record actuals, never assume exact wording.
- **The `failed` emission point deviates from the post-state discipline, deliberately.** §7.3
  runs a *blocking* modal alert mid-rule and writes the status line only after dismissal — a
  post-state event could never cue the runner to dismiss. Emitting after the message is computed
  but **before `runModal`** gives the offline scenarios a deterministic dismissal cue
  (`wait-for-log "[nav] failed"` → settle → `press "Return"`) without OCR-racing the platform
  alert chrome. The *post*-dismissal status line (`<phase> failed: <message>`) is asserted
  separately via OCR (`failed:`).
- **Silent no-ops emit nothing.** The §6.2 boundaries — empty input (`Enter a URL to navigate`)
  and URL parse failure (`Invalid URL: <text>`) — never reach `loadRequest:`: **no `[nav]`
  event**, no error line. The status line (AX/OCR) is their observable; absence of an event is
  never asserted.
- **Never count events, never assume cross-navigation ordering.** Reload and ◀/▶ fire the same
  `started`/`finished` pairs as a typed navigation; within one driven navigation `started`
  precedes its `finished`/`failed`, but suites match the specific line they drove to (the
  pdfkit-viewer rule), never a count or a strict global sequence.
- **Instrumentation must not change visible behaviour** — no new UI, no extra dialogs, and no
  alignment of the loading-text / phase-word / home-URL realizations (spec §6.1/§7.1/§7.3 leave
  them impl-realized).

## Test-config compatibility

As hello-window: the descriptor's REQUIRED `#:test-config-path` is passed as
`MINI_BROWSER_TEST_CONFIG`. The browser reads **no** runtime config — honour the env var
gracefully (absent/empty ⇒ "no config"), fixed default mirrored by the descriptor
`/tmp/mini-browser/test-config.scm`; a missing file is not an error.

## Conformance checklist (per impl — the instrument+build children implement this)

- [ ] On startup: resolve events-path (`MINI_BROWSER_EVENTS_LOG` →
      `/tmp/mini-browser/events.log`), truncate-open line-buffered, create the parent dir.
- [ ] Emit `[lifecycle] startup` as the first record, before window/web-view construction / `-run`.
- [ ] Emit the bare launch line beginning `Mini Browser` to events.log once the window is
      key+front (keep the existing stdout print).
- [ ] Emit `[nav] started` from `didStartProvisionalNavigation`, post-state (loading status set),
      with the `url` read.
- [ ] Emit `[nav] finished` from `didFinishNavigation` after the whole §7.2 refresh, with the
      fixed key order `url` `title` `can-go-back` `can-go-forward` (booleans as bare
      `true`/`false`).
- [ ] Emit `[nav] failed` from both failure callbacks at rule entry — message computed, **before**
      `runModal` — with normalized `phase` ∈ {`request`, `load`} and the `message` string
      (`Unknown error` on the nil-error boundary).
- [ ] Emit `[lifecycle] shutdown reason=<menu|signal|error>` on the terminate path (add the
      `applicationWillTerminate:` hook as the prior apps' instrumentation did), then flush+close.
- [ ] Honour `MINI_BROWSER_TEST_CONFIG` gracefully (no config needed; absent ⇒ default).
- [ ] Build to a `.app` whose `CFBundleIdentifier` equals the descriptor's `#:bundle-id`
      (`com.linkuistics.mini-browser-<impl>`; sbcl's `build.sh` today writes the unsuffixed
      `com.linkuistics.mini-browser` and omits the kind-required
      `CFBundleInfoDictionaryVersion` — both align at the instrument stage, the scenekit-viewer
      k104-seed mirror).
