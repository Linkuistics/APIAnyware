# Hello Window — Logging Contract

> **Porting guide.** Every implementation of Hello Window MUST satisfy this contract to be
> verifiable by the AppSpec scenario runner. It is the de-Modalisered v1 logging contract
> (`AppSpec/docs/plans/2026-04-18-app-spec-v1.md`; reference emitter
> `generation/targets/racket-oo/apps/modaliser/.../lib/events.rkt`), narrowed to the three events
> Hello Window's scenario suite actually consumes.

## Why a log file (not stdout)

The runner launches a GUI impl with `<config-env>=<test-config-path> <log-env>=<events-path> open
"<binary>"` (`AppSpec/runner/lifecycle.rkt` `launch-impl!`). Under `open` (LaunchServices) the app's
**stdout is discarded** — it is not captured anywhere the runner can read. The runner instead **tails a
structured event-log file** the impl writes itself (`AppSpec/runner/log-tail.rkt` `make-log-tail-fn`:
`wc -c` + `tail -c`; `AppSpec/testanyware-sdk/macos-helpers.rkt` `wait-ready`). So every log assertion
(`wait-for-log`, `expect-log`, `wait-ready`) reads **events.log**, never stdout.

Spec §10 phrases the launch diagnostic as *"Standard output contains a line beginning `Hello Window
opened.`"*. That wording is reconciled, not contradicted: the impl SHOULD keep emitting the line to
stdout (human-friendly when run unbundled, and literally true to §10) **and** MUST also emit it to
events.log (so the runner sees it). See "Events" below. *(Spec-quality note for reverse-gen: §10's
"Standard output" is imprecise about the runner's actual read path — the impl's event log — but the
verb mapping `wait-for-log`/`expect-log` is correct. Flagged, not edited: the firmed spec is changed
only by a deliberate human-reviewed pass.)*

## The events.log file

- **Path resolution** (the impl, on startup): the value of the `<log-env>` env var
  (`HELLO_WINDOW_EVENTS_LOG`) if set and non-empty; otherwise the **fixed default**
  `/tmp/hello-window/events.log`. The fixed default is the safety net for `launch-via 'open`, where the
  env var may not propagate through LaunchServices — the descriptor's `#:events-path` **mirrors the same
  default**, so the runner tails the right file whether or not the env var propagates. (The v1 Modaliser
  contract used `$XDG_CACHE_HOME/<app>/events.log`; `/tmp/hello-window/events.log` is used here to avoid
  home-dir resolution under the VM's launch user.)
- **Lifecycle:** truncated on impl startup (`open-output-file #:exists 'truncate/replace`); parent dir
  created if missing. The runner *also* truncates it between scenarios (`setup-scenario!`), so the impl's
  startup-truncate and the runner's between-scenario truncate compose cleanly.
- **Buffering:** line-buffered, flushed after every record (so a tail sees each line promptly).
- **Single writer:** the Cocoa run loop serialises the main-thread callbacks that emit, so one port with
  post-write flush suffices (no lock needed for this app).

## Line format

```
[<module>] <event-name> <key>=<value> <key>=<value>\n
```

Strings are double-quoted with `\\`/`\"`/newline escaped; numbers/booleans/symbols emit bare. Hello
Window's three events use no key/value pairs except `shutdown`'s `reason`.

## Events (the runner's consumers, with exact matchers)

| Event line | Emitted when | Runner consumer | Matcher |
|---|---|---|---|
| `[lifecycle] startup` | after the single-instance/init step, before `-run` | `wait-ready` readiness probe (`setup-scenario!`) | `#px"\\[lifecycle\\] startup"` |
| `Hello Window opened.` | once the window is key+front (the §10 launch diagnostic) | scenario `01` `wait-for-log` | `#rx"Hello Window opened\\."` |
| `[lifecycle] shutdown reason=<r>` | in `applicationWillTerminate` / the Quit path, before exit | `quit-impl!` / scenario `03` (Command-Q) | reason ∈ {`menu`, `signal`, `error`} |

Notes:
- `Hello Window opened.` is written to events.log as a **bare line** (not bracketed) so the
  `#rx"Hello Window opened\\."` substring matches; the impl also keeps its existing stdout `displayln`
  of the same text (dual emission, per "Why a log file" above).
- `startup` must land **before** the impl blocks in the AppKit run loop (`-run`), or `wait-ready` times
  out. Emit it after init, then enter the run loop.
- `shutdown reason=menu` is the Command-Q / menu-Quit path (scenario `03` quits via
  `osascript … to quit`); `reason=signal` covers SIGTERM; `reason=error` an uncaught exception.

## Test-config compatibility

The descriptor's `#:test-config-path` is REQUIRED by the schema (`AppSpec/app-spec/impl.rkt`) and passed
as `<config-env>=<test-config-path>` (`HELLO_WINDOW_TEST_CONFIG`). Hello Window reads **no** runtime
config — it has no configurable behaviour — so the contract is: **honour the env var if a future
variant needs it, default gracefully (treat absent/empty as "no config")**. The fixed default mirrored
by the descriptor is `/tmp/hello-window/test-config.scm`; a missing file is not an error.

## Conformance checklist (per impl — the build children k28–k31 implement this)

- [ ] On startup: resolve events-path (env var → `/tmp/hello-window/events.log`), truncate-open
      line-buffered, `make-directory*` the parent.
- [ ] Emit `[lifecycle] startup` after init, **before** entering `-run`.
- [ ] Emit the bare line `Hello Window opened.` to events.log (keep the existing stdout line too).
- [ ] Emit `[lifecycle] shutdown reason=<menu|signal|error>` on the terminate path, then flush+close.
- [ ] Honour `<config-env>` gracefully (no config needed; absent ⇒ default).
- [ ] Build to a `.app` whose `CFBundleIdentifier` equals the descriptor's `#:bundle-id`
      (`com.linkuistics.hello-window-<impl>`).
