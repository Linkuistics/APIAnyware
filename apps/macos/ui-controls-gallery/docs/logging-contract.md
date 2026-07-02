# UI Controls Gallery — Logging Contract

> **Porting guide.** Every implementation of UI Controls Gallery MUST satisfy this contract to be
> verifiable by the AppSpec scenario runner. It follows the hello-window contract
> ([../../hello-window/docs/logging-contract.md](../../hello-window/docs/logging-contract.md), the
> worked template) and extends it with **control state-change events**: the runner's `expect-ax`
> verb matches AXRole + exact AXTitle only — it has no value/state read — so the spec §13
> interaction assertions (radio exclusivity, checkbox toggle, slider/stepper clamping) are
> observable only if the impl logs them.

## Why a log file (not stdout)

Same rationale as hello-window (see that contract's "Why a log file" for the full derivation): the
runner launches a GUI impl via `open` (LaunchServices), which **discards stdout**, and instead
**tails a structured event-log file** the impl writes itself (`AppSpec/runner/log-tail.rkt`;
`wait-ready` in `setup-scenario!`). Every log assertion (`wait-for-log`, `expect-log`,
`wait-ready`) reads **events.log**, never stdout.

Spec §3.6 mandates a one-line launch diagnostic **containing `Controls Gallery`** on standard
output. Reconciled as in hello-window: the impl SHOULD keep its existing stdout line
(human-friendly when run unbundled, literally true to §3.6) **and** MUST emit the same line to
events.log (so the runner sees it) — dual emission.

## The events.log file

- **Path resolution** (the impl, on startup): the value of `UI_CONTROLS_GALLERY_EVENTS_LOG` if set
  and non-empty; otherwise the **fixed default** `/tmp/ui-controls-gallery/events.log`. The impl
  descriptor's `#:events-path` mirrors the same default, so the runner tails the right file
  whether or not the env var propagates through LaunchServices under `launch-via 'open`.
- **Lifecycle:** truncated on impl startup (parent dir created if missing). The runner also
  truncates it between scenarios; the two truncations compose cleanly.
- **Buffering:** line-buffered, flushed after every record.
- **Single writer:** every event in this contract is emitted on the main thread — startup and the
  launch line before `-run`, the `[controls]` events from Cocoa action callbacks the run loop
  serialises, shutdown on the terminate path — so one port with post-write flush suffices.

## Line format

```
[<module>] <event-name> <key>=<value> <key>=<value>\n
```

Strings are double-quoted with `\\`/`\"`/newline escaped; numbers/booleans/symbols emit bare.
This app's events use `<module>` ∈ {`lifecycle`, `controls`}.

## Lifecycle events

| Event line | Emitted when | Runner consumer | Matcher |
|---|---|---|---|
| `[lifecycle] startup` | first record, right after opening events.log — before gallery construction, well before `-run` | `wait-ready` readiness probe (`setup-scenario!`) | `#px"\\[lifecycle\\] startup"` |
| the launch line, bare, containing `Controls Gallery` | once the window is key+front and the app activated, before `-run` (spec §3.6) | `wait-for-log` / `expect-log` | `#rx"Controls Gallery"` |
| `[lifecycle] shutdown reason=<r>` | on the terminate path (`applicationWillTerminate` / Quit), before exit | `quit-impl!` / the Command-Q scenario | reason ∈ {`menu`, `signal`, `error`} |

Notes:
- The launch line's full text is impl-specific (§3.6 asserts only the substring — e.g. racket's
  `UI Controls Gallery running. …` and sbcl's `Controls Gallery opened. …` both conform); emit it
  as a **bare line** (not bracketed) and keep the existing stdout print (dual emission).
- `startup` must land **before** the impl blocks in the AppKit run loop, or `wait-ready` times out.
- `shutdown reason=menu` is the Command-Q / menu-Quit path; `reason=signal` covers SIGTERM;
  `reason=error` an uncaught exception.

## Control state-change events (the gallery-specific part)

Exactly the four controls with spec §7 interactive contracts emit events — **no others**. §7's
"no app-level handling" list (push button, popup, combo, date picker, color well, image view) is
behaviour the spec *excludes*; instrumenting those would contradict it, and construction-time
self-reports (e.g. `popup-populated items=3`) would be over-specified logging that burdens every
impl for an assertion better served by a future AX verb (see observable-state.md "gap
observables"). Each event is emitted from the control's action callback, **after** the state
change it names is applied:

| Event line | Emitted when | §13 assertion served | Matcher (example) |
|---|---|---|---|
| `[controls] radio-selected option="Option B"` | a radio button's action fires; `option` = the sender's title | radio exclusivity | `#px"radio-selected option=\"Option B\""` |
| `[controls] checkbox-changed state=on` (or `off`) | the checkbox's action fires; `on` iff the post-toggle state is checked | checkbox toggles | `#px"checkbox-changed state=(on\|off)"` |
| `[controls] slider-changed value=63` | the slider's action fires; `value` = the double value rounded to nearest integer | slider in-range / clamps | `#px"slider-changed value=100"` at the max end |
| `[controls] stepper-changed value=5` | the stepper's action fires; `value` = the (integral) value as an integer | stepper clamps | `#px"stepper-changed value=10"` at the top |

Semantics + realization notes:
- **`radio-selected` names the group's sole selection** after the callback returns: an impl either
  clears siblings explicitly in the handler (racket/chez/gerbil today) or relies on the platform's
  sibling-group exclusion (sbcl — same superview + shared action). Either realization conforms; the
  event is emitted in both. An impl with a third `Option C` emits its title the same way.
- **Values are formatted as integers** (round-to-nearest for the slider's double; the stepper's
  0–10 step-1 values are integral), so matchers are trivial and the clamped ends are exactly
  `0`/`100` (slider) and `0`/`10` (stepper).
- **Consumers must not assume initial states.** The checkbox's initial checked state and the
  slider/stepper presets are spec §6 holes (sbcl launches its checkbox ON, the others OFF); the
  toggle scenario asserts a *flip* (two clicks → two events with opposite `state`), never a fixed
  `on`/`off` sequence.
- A continuous slider may emit **many** `slider-changed` lines per drag; each action invocation
  emits one line. Consumers match the value they drove to (typically the last event).
- **Instrumentation must not change visible behaviour.** The live value labels tracking
  slider/stepper remain optional per-impl embellishments (spec §12); adding the logging callbacks
  must not add or remove UI. **Never log text-field or secure-field contents** — the text-entry
  assertion rides OCR, and logging secure input would be wrong outright.

## Test-config compatibility

As hello-window: the descriptor's REQUIRED `#:test-config-path` is passed as
`UI_CONTROLS_GALLERY_TEST_CONFIG`. The gallery reads **no** runtime config — honour the env var
gracefully (absent/empty ⇒ "no config"), fixed default mirrored by the descriptor
`/tmp/ui-controls-gallery/test-config.scm`; a missing file is not an error.

## Conformance checklist (per impl — the instrument+build children implement this)

- [ ] On startup: resolve events-path (`UI_CONTROLS_GALLERY_EVENTS_LOG` →
      `/tmp/ui-controls-gallery/events.log`), truncate-open line-buffered, create the parent dir.
- [ ] Emit `[lifecycle] startup` as the first record, before gallery construction / `-run`.
- [ ] Emit the bare launch line containing `Controls Gallery` to events.log once the window is
      key+front (keep the existing stdout print).
- [ ] Wire + emit the four `[controls]` events from the radio / checkbox / slider / stepper action
      callbacks (post-state, integer-formatted values; add target-action wiring where an impl
      lacks it — sbcl's checkbox/slider/stepper today).
- [ ] Emit `[lifecycle] shutdown reason=<menu|signal|error>` on the terminate path, then
      flush+close.
- [ ] Honour `UI_CONTROLS_GALLERY_TEST_CONFIG` gracefully (no config needed; absent ⇒ default).
- [ ] Build to a `.app` whose `CFBundleIdentifier` equals the descriptor's `#:bundle-id`
      (`com.linkuistics.ui-controls-gallery-<impl>`).
