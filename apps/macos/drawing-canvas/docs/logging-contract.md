# Drawing Canvas — Logging Contract

> **Porting guide.** Every implementation of Drawing Canvas MUST satisfy this contract to be
> verifiable by the AppSpec scenario runner. It follows the hello-window contract
> ([../../hello-window/docs/logging-contract.md](../../hello-window/docs/logging-contract.md), the
> worked template) and extends it with **canvas events**: the spec's behavioural core — the
> capture-at-mouse-down stroke model (§2/§7) — lives on a custom `NSView` whose strokes are
> framebuffer pixels, OCR-meaningless and AX-invisible (spec §12), and the app otherwise emits
> **no per-operation output at all** (§13 — the single launch line is the only stdout). Without
> log events, stroke lifecycle and tool state are not assertable at all — so the impl logs its
> canvas-state transitions (the scenekit-viewer `[scene]` channel mirror).

## Why a log file (not stdout)

Same rationale as hello-window (see that contract's "Why a log file" for the full derivation):
the runner launches a GUI impl via `open` (LaunchServices), which **discards stdout**, and
instead **tails a structured event-log file** the impl writes itself
(`AppSpec/runner/log-tail.rkt`; `wait-ready` in `setup-scenario!`). Every log assertion
(`wait-for-log`, `expect-log`, `wait-ready`) reads **events.log**, never stdout.

Spec §3 step 6 mandates a one-line launch diagnostic **beginning `Drawing Canvas`** on standard
output. Reconciled as in hello-window: the impl SHOULD keep its existing stdout line
(human-friendly when run unbundled, literally true to §3) **and** MUST emit the same line to
events.log (so the runner sees it) — dual emission.

## The events.log file

- **Path resolution** (the impl, on startup): the value of `DRAWING_CANVAS_EVENTS_LOG` if set and
  non-empty; otherwise the **fixed default** `/tmp/drawing-canvas/events.log`. The impl
  descriptor's `#:events-path` mirrors the same default, so the runner tails the right file
  whether or not the env var propagates through LaunchServices under `launch-via 'open`.
- **Lifecycle:** truncated on impl startup (parent dir created if missing). The runner also
  truncates it between scenarios; the two truncations compose cleanly.
- **Buffering:** line-buffered, flushed after every record.
- **Single writer:** every event in this contract is emitted on the main thread — startup and the
  launch line before `-run`; the `[canvas]` events from the canvas subclass's mouse overrides
  (AppKit event dispatch), the slider and Clear action handlers, and the colour panel's
  colour-changed action (the shared `NSColorPanel` is **in-process** and sends its continuous
  action on the main thread, which the Cocoa run loop serialises); shutdown on the terminate
  path — so one port with post-write flush suffices.

## Line format

```
[<module>] <event-name> <key>=<value> <key>=<value>\n
```

Strings are double-quoted with `\\`/`\"`/newline escaped; numbers/booleans/symbols emit bare.
This app's events use `<module>` ∈ {`lifecycle`, `canvas`}.

## Lifecycle events

| Event line | Emitted when | Runner consumer | Matcher |
|---|---|---|---|
| `[lifecycle] startup` | first record, right after opening events.log — before window/canvas construction, well before `-run` | `wait-ready` readiness probe (`setup-scenario!`) | `#px"\\[lifecycle\\] startup"` |
| the launch line, bare, beginning `Drawing Canvas` | once the window is key+front and the app activated, before `-run` (spec §3 step 6) | `wait-for-log` / `expect-log` | `#rx"Drawing Canvas"` |
| `[lifecycle] shutdown reason=<r>` | on the terminate path (`applicationWillTerminate` / Quit), before exit | `quit-impl!` / the Command-Q scenario | reason ∈ {`menu`, `signal`, `error`} |

Notes:
- The launch line **begins with** `Drawing Canvas` (the spec asserts the prefix); the remainder
  is impl-specific and **stays unaligned** (today: racket/chez/gerbil `Drawing Canvas running.
  Close window or Ctrl+C to exit.`; sbcl `Drawing Canvas opened. Drag to draw; Color… changes
  the stroke colour, the slider its width, Clear empties the canvas. Quit with Cmd-Q.` — all
  conform; the scenekit-viewer prefix-rule precedent). Emit it as a **bare line** (not
  bracketed) and keep the existing stdout print (dual emission). The window *title* is the same
  text on a different channel (OCR/AX) — see [observable-state.md](observable-state.md).
- `startup` must land **before** the impl blocks in the AppKit run loop, or `wait-ready` times
  out.
- `shutdown reason=menu` is the Command-Q / menu-Quit path — the exercised terminate path;
  `reason=signal` covers SIGTERM; `reason=error` an uncaught exception. (All four runtimes
  ignore SIGTERM under `nsapplication-run` — the ui-controls-gallery k94 observation — so the
  signal path stays unexercised in practice.) **Closing the window emits nothing** (§3 expects
  keep-running with no close-to-quit opt-in, flagged to-confirm; a `shutdown` observed on
  window-close at live-run would be a spec-quality finding, recorded not asserted).
- The pre-instrumentation impls install no application delegate (spec §3); the instrumentation
  adds the `applicationWillTerminate:` hook exactly as the prior six apps' instrument stages did
  in all four impls.

## Canvas events (the drawing-specific part)

Five events — the stroke lifecycle of §7.2 and the tool/clear transitions of §8 — and **no
others** (the panel's opening needs no event: the panel is an observable window, see
[observable-state.md](observable-state.md)). All are emitted **post-state**: after the
operation's whole rule has run (state stored, in-progress flag set/cleared, redraw requested),
so a `wait-for-log` hit guarantees the app state — though the repaint may lag; rendered
appearance is never log-asserted anyway (screenshots are the pixel channel).

| Event line | Emitted when | §14 assertion served | Matcher (example) |
|---|---|---|---|
| `[canvas] stroke-begun r=0 g=0 b=0 width=2` | end of the §7.2 mouse-down rule — the stroke seeded with its **frozen** colour+width, in-progress flag set | the gesture reached the canvas (the k130 click-delivery witness); the frozen tool state at begin | `#px"\\[canvas\\] stroke-begun r=0 g=0 b=0 width=2"` (launch tool state is deterministic) |
| `[canvas] stroke-committed r=0 g=0 b=0 width=2 points=1` | end of the §7.2 mouse-up rule — in-progress flag cleared; the stroke's data is final | **the freeze proof**: the committed tuple equals the tool state at *its own* mouse-down, not at commit; dot-vs-drag via `points` | after driving colour/width and drawing: `#px"stroke-committed r=0 g=150 b=255 width=11 points=\\d+"` |
| `[canvas] color-changed r=0 g=150 b=255` | the panel handler's **success path only** (§8.1 step 4) — after the device-RGB components are stored | live recolour of subsequent strokes (the app-state half; pixels stay screenshot-level) | `#px"\\[canvas\\] color-changed r=\\d+ g=\\d+ b=\\d+"`, or the recorded driven values |
| `[canvas] width-changed width=11` | the slider's action (§8.2) — after the width is stored | slider changes subsequent stroke width (the app-state half) | `#px"\\[canvas\\] width-changed width=11"` (bind the recorded actual) |
| `[canvas] cleared count=2` | end of the §8.3 Clear rule — collection emptied, in-progress state cancelled | Clear empties the canvas; Clear-on-empty is a safe no-op (`count=0`); **the stroke-set cardinality channel** (below) | `#px"\\[canvas\\] cleared count=0"` / `count=2` |

Semantics + realization notes:
- **Key order is fixed** as shown: `r` `g` `b` `width` on the stroke events (`points` last on
  `committed`), so multi-key regex matchers can rely on adjacency.
- **`r`/`g`/`b` are the stored current colour's device-RGB components × 255, rounded to the
  nearest integer** (bare integers 0–255 — the scenekit-viewer rule: the line format has no
  tuple form, and integer keys keep matchers trivial). The stored components are device-RGB by
  construction (§8.1 normalizes before extracting; conversion failure keeps the previous
  components — consistent across all four impls), so no alignment seed is needed. **The initial
  colour is black `r=0 g=0 b=0` — deterministic** (unlike scenekit's appearance-dependent
  `systemRedColor`), so launch-state stroke events are exactly bindable.
- **`width` is the stored width rounded to the nearest integer** (bare integer; initial 2.0 →
  `width=2`). The freeze proof needs only *agreement* between events formatting the same stored
  double, which shared rounding guarantees; a click-driven slider value is bound from the
  recorded actual anyway (the k112 recorded-actuals rule), so fractional fidelity buys nothing.
- **`points`** = the stroke's stored point count — the down point plus the drag points; **the
  release is not appended** (§7.2). `points=1` is deterministic for a motionless click (the §7.2
  dot boundary — the discriminator for the bare-click-paints-a-dot assertion). For a drag the
  count depends on event-delivery cadence (driver/VNC timing) — suites **never bind an exact
  drag count**; match shape (`points=\d+`) or assert the dot case exactly.
- **The stroke events fire only for gestures that reach the canvas.** A press on a toolbar
  control emits nothing (no stroke exists — §7.2: a drag begun on a control appends nothing).
  Absence is never asserted directly; **the `cleared` event's `count` key is the positive
  channel for stroke-set cardinality** — follow a should-draw-nothing gesture with a Clear and
  assert `count=0` (this is why `cleared` carries the count and why it is **always emitted**,
  including on an already-empty canvas).
- **`color-changed` is success-path only; silent no-ops emit nothing.** A nil panel colour and a
  failed device-RGB conversion are silent (§8.1 boundaries) — no event, no error line. The two
  impls' stderr `colorChanged:` guard diagnostics (racket, chez) stay on **stderr** — never
  events.log, and not contract (§8.1: error-swallowing-with-log is not an invariant); gerbil and
  sbcl carry no such guard and need no alignment. Dismissing the panel picks nothing — silent.
- **Never count events, never assume cross-gesture ordering.** Within one gesture the order is
  deterministic (`stroke-begun` precedes its `stroke-committed`; nothing intervenes from a
  single pointer). Both continuous controls may emit **many** lines during a drag — the slider
  is wired continuous (§5.1) and the panel is rewired continuous on every open (§8.1);
  *continuous delivery through the driver is itself to-confirm in-VM (spec flags both)* — and a
  repeated Clear re-emits (`count=0`). Match the specific line you drove to — the pdfkit-viewer
  rule.
- **No per-drag-point events.** Mouse-drag appends are deliberately unlogged — per-point volume
  buys nothing assertable (coordinates are driver-chosen), and the count rides `points=` on
  commit instead (the k123 per-keystroke-volume precedent, capped at source).
- **Alpha is deliberately not logged** — stroke opacity is fixed at 1.0 (§7.1/§13); the spec
  asserts nothing about transparency.
- **Instrumentation must not change visible behaviour** — no new UI, no dialogs (§13 excludes
  them), no alignment of the launch-line remainder, no canvas drawing changes.

## Test-config compatibility

As hello-window: the descriptor's REQUIRED `#:test-config-path` is passed as
`DRAWING_CANVAS_TEST_CONFIG`. The canvas reads **no** runtime config — honour the env var
gracefully (absent/empty ⇒ "no config"), fixed default mirrored by the descriptor
`/tmp/drawing-canvas/test-config.scm`; a missing file is not an error.

## Conformance checklist (per impl — the instrument+build children implement this)

- [ ] On startup: resolve events-path (`DRAWING_CANVAS_EVENTS_LOG` →
      `/tmp/drawing-canvas/events.log`), truncate-open line-buffered, create the parent dir.
- [ ] Emit `[lifecycle] startup` as the first record, before window/canvas construction /
      `-run`.
- [ ] Emit the bare launch line beginning `Drawing Canvas` to events.log once the window is
      key+front (keep the existing stdout print).
- [ ] Emit `[canvas] stroke-begun` at the end of the §7.2 mouse-down rule and
      `[canvas] stroke-committed` at the end of the mouse-up rule, each carrying the stroke's
      **frozen** `r`/`g`/`b`/`width` (device-RGB × 255 and width, both rounded to bare
      integers), `committed` adding `points=<n>`; keys in the fixed order.
- [ ] Emit `[canvas] color-changed` from the panel handler's success path only, post-store
      (same integer formatting).
- [ ] Emit `[canvas] width-changed` from the slider's action, post-store (integer formatting).
- [ ] Emit `[canvas] cleared count=<n>` at the end of every Clear action (`n` = strokes
      removed; `0` on an empty canvas — always emitted).
- [ ] Keep the stderr `colorChanged:` guard diagnostics (where they exist) off events.log.
- [ ] Emit `[lifecycle] shutdown reason=<menu|signal|error>` on the terminate path (add the
      `applicationWillTerminate:` hook as the prior apps' instrumentation did), then
      flush+close.
- [ ] Honour `DRAWING_CANVAS_TEST_CONFIG` gracefully (no config needed; absent ⇒ default).
- [ ] Build to a `.app` whose `CFBundleIdentifier` equals the descriptor's `#:bundle-id`
      (`com.linkuistics.drawing-canvas-<impl>`; sbcl's `build.sh` today writes the unsuffixed
      `com.linkuistics.drawing-canvas` and omits the kind-required
      `CFBundleInfoDictionaryVersion` — both align at the instrument stage, the k104/k114
      mirror).
