# SceneKit Viewer — Logging Contract

> **Porting guide.** Every implementation of SceneKit Viewer MUST satisfy this contract to be
> verifiable by the AppSpec scenario runner. It follows the hello-window contract
> ([../../hello-window/docs/logging-contract.md](../../hello-window/docs/logging-contract.md), the
> worked template) and extends it with **scene events**: the spec's behavioural core — the
> geometry swap and the colour that survives it — happens inside the SCNView's rendered viewport,
> which is pixel-level and invisible to both OCR and the AX tree, and the closed verb set has no
> drag or pixel-diff verb (spec §13). Without log events the two key behaviours (swap applied;
> colour stored and re-applied across swaps) are not assertable at all — so the impl logs its
> scene-state transitions.

## Why a log file (not stdout)

Same rationale as hello-window (see that contract's "Why a log file" for the full derivation): the
runner launches a GUI impl via `open` (LaunchServices), which **discards stdout**, and instead
**tails a structured event-log file** the impl writes itself (`AppSpec/runner/log-tail.rkt`;
`wait-ready` in `setup-scenario!`). Every log assertion (`wait-for-log`, `expect-log`,
`wait-ready`) reads **events.log**, never stdout.

Spec §3 step 6 mandates a one-line launch diagnostic **beginning `SceneKit Viewer`** on standard
output. Reconciled as in hello-window: the impl SHOULD keep its existing stdout line
(human-friendly when run unbundled, literally true to §3) **and** MUST emit the same line to
events.log (so the runner sees it) — dual emission.

## The events.log file

- **Path resolution** (the impl, on startup): the value of `SCENEKIT_VIEWER_EVENTS_LOG` if set and
  non-empty; otherwise the **fixed default** `/tmp/scenekit-viewer/events.log`. The impl
  descriptor's `#:events-path` mirrors the same default, so the runner tails the right file
  whether or not the env var propagates through LaunchServices under `launch-via 'open`.
- **Lifecycle:** truncated on impl startup (parent dir created if missing). The runner also
  truncates it between scenarios; the two truncations compose cleanly.
- **Buffering:** line-buffered, flushed after every record.
- **Single writer:** every event in this contract is emitted on the main thread — startup and the
  launch line before `-run`; the `[scene]` events from the picker's action callback and the colour
  panel's colour-changed action callback (the shared `NSColorPanel` is **in-process** and sends
  its continuous action on the main thread, which the Cocoa run loop serialises); shutdown on the
  terminate path — so one port with post-write flush suffices.

## Line format

```
[<module>] <event-name> <key>=<value> <key>=<value>\n
```

Strings are double-quoted with `\\`/`\"`/newline escaped; numbers/booleans/symbols emit bare.
This app's events use `<module>` ∈ {`lifecycle`, `scene`}.

## Lifecycle events

| Event line | Emitted when | Runner consumer | Matcher |
|---|---|---|---|
| `[lifecycle] startup` | first record, right after opening events.log — before window/scene construction, well before `-run` | `wait-ready` readiness probe (`setup-scenario!`) | `#px"\\[lifecycle\\] startup"` |
| the launch line, bare, beginning `SceneKit Viewer` | once the window is key+front and the app activated, before `-run` (spec §3 step 6) | `wait-for-log` / `expect-log` | `#rx"SceneKit Viewer"` |
| `[lifecycle] shutdown reason=<r>` | on the terminate path (`applicationWillTerminate` / Quit), before exit | `quit-impl!` / the Command-Q scenario | reason ∈ {`menu`, `signal`, `error`} |

Notes:
- The launch line **begins with** `SceneKit Viewer` (the spec asserts the prefix); the remainder
  is impl-specific (today: racket/chez/gerbil `SceneKit Viewer running. Close window or Ctrl+C to
  exit.`; sbcl `SceneKit Viewer opened. Quit with Cmd-Q.` — all conform). Emit it as a **bare
  line** (not bracketed) and keep the existing stdout print (dual emission). The window *title*
  is the same text on a different channel (OCR/AX) — see
  [observable-state.md](observable-state.md).
- `startup` must land **before** the impl blocks in the AppKit run loop, or `wait-ready` times out.
- `shutdown reason=menu` is the Command-Q / menu-Quit path — the exercised terminate path;
  `reason=signal` covers SIGTERM; `reason=error` an uncaught exception. (All four runtimes ignore
  SIGTERM under `nsapplication-run` — the ui-controls-gallery k94 observation — so the signal path
  stays unexercised in practice.)
- The pre-instrumentation impls install no application delegate (spec §3); the instrumentation
  adds the `applicationWillTerminate:` hook exactly as the hello-window, ui-controls-gallery, and
  pdfkit-viewer instrument stages did in all four impls.

## Scene events (the viewer-specific part)

Exactly two events — the scene-state transitions of spec §6/§7 — and **no others** (the colour
panel's opening needs no event: the panel is an observable window, see
[observable-state.md](observable-state.md)). Each is emitted **after** the state change it names
is fully applied (post-state), so a `wait-for-log` hit guarantees the app state — though the
GPU repaint may lag; rendered appearance is never log-asserted anyway:

| Event line | Emitted when | §13 assertion served | Matcher (example) |
|---|---|---|---|
| `[scene] geometry-changed shape="Sphere" r=0 g=128 b=255` | the picker's action handler (§6 swap) — after the catalogue geometry is assigned **and** the current colour re-applied (§7.2) | geometry swap tracks selection; **colour persists across a swap** (the key behaviour) | `#px"\\[scene\\] geometry-changed shape=\"Sphere\""`; persistence, after driving the colour to 0/128/255: `#px"geometry-changed shape=\"Sphere\" r=0 g=128 b=255"` |
| `[scene] color-changed r=0 g=128 b=255` | the panel's colour-changed handler, **success path only** (§7.4 step 3) — after the converted colour is stored and applied | live recolour (the app-state half; the rendered half stays pixel-level) | `#px"\\[scene\\] color-changed r=\\d+ g=\\d+ b=\\d+"`, or the exact driven values |

Semantics + realization notes:
- **`shape` is the applied catalogue title** (`Cube` / `Sphere` / `Torus` / `Cylinder`) —
  identical to the picker's selected-item title through the four-item picker. The out-of-range →
  cube defensive default (§6) is unreachable through the UI and needs no distinct event.
- **`r`/`g`/`b` are the stored current colour's device-RGB components × 255, rounded to the
  nearest integer** (bare integers 0–255; the leaf's `rgb=<r,g,b>` tuple candidate is realized as
  three keys because the line format has no tuple value form, and integer keys keep matchers
  trivial — the gallery precedent). Format at emit time by converting the stored colour with
  `colorUsingColorSpace:` device-RGB: a §7.4-stored colour is already device-RGB; only the
  initial `systemRedColor` converts at emit, and its numeric components are OS/appearance-
  dependent — **consumers must never assume the initial colour's values** (match shape-only until
  a colour has been driven).
- **Why `geometry-changed` carries the colour:** the §13 key behaviour — the chosen colour
  survives a swap — becomes a **single-line assertion** (drive a known colour, swap, match the
  folded values). The verb set has no cross-line value capture, so the event must carry the
  post-swap colour itself; it also mirrors §6 exactly (a swap *is* geometry + colour re-apply).
- **`color-changed` is success-path only; silent no-ops emit nothing.** A nil panel colour and a
  failed device-RGB conversion are silent no-ops (§7.4 boundaries) — no event, no error line;
  absence of the event *is* the contract. This requires the invariant *the stored colour is
  always device-RGB*: the one impl that stores the unconverted panel colour on conversion failure
  (the §7.4 divergence) aligns to keep-previous at the instrument stage (the k104 seed). The two
  impls' stderr `colorChanged:` guard diagnostics stay on stderr — never events.log.
- **Never count events, never assume ordering.** The panel is wired continuous (§7.3): a drag
  emits **many** `color-changed` lines, a single click one-or-more *(click delivery — to confirm
  in-VM; §13 flags the no-drag-verb constraint)*. Re-selecting the picker's already-current item
  re-runs the handler (§6 is unconditional — a fresh geometry of the same shape) and logs again.
  Match the specific line you drove to — the pdfkit-viewer rule.
- **Alpha is deliberately not logged** — the exercised §7 surface never varies it (the panel
  defaults to opaque; the spec asserts nothing about transparency).
- **Instrumentation must not change visible behaviour** — no new UI, and no error dialogs (spec
  §12 excludes them).

## Test-config compatibility

As hello-window: the descriptor's REQUIRED `#:test-config-path` is passed as
`SCENEKIT_VIEWER_TEST_CONFIG`. The viewer reads **no** runtime config — honour the env var
gracefully (absent/empty ⇒ "no config"), fixed default mirrored by the descriptor
`/tmp/scenekit-viewer/test-config.scm`; a missing file is not an error.

## Conformance checklist (per impl — the instrument+build children implement this)

- [ ] On startup: resolve events-path (`SCENEKIT_VIEWER_EVENTS_LOG` →
      `/tmp/scenekit-viewer/events.log`), truncate-open line-buffered, create the parent dir.
- [ ] Emit `[lifecycle] startup` as the first record, before window/scene construction / `-run`.
- [ ] Emit the bare launch line beginning `SceneKit Viewer` to events.log once the window is
      key+front (keep the existing stdout print).
- [ ] Emit `[scene] geometry-changed` from the picker's action handler, post-state (`shape` =
      applied catalogue title, folded `r`/`g`/`b` = stored colour as device-RGB integers).
- [ ] Emit `[scene] color-changed` from the panel handler's success path only, post store+apply
      (same integer formatting).
- [ ] Hold the stored-colour-is-always-device-RGB invariant (align the §7.4 stores-raw
      divergence to keep-previous — the k104 seed).
- [ ] Emit `[lifecycle] shutdown reason=<menu|signal|error>` on the terminate path (add the
      `applicationWillTerminate:` hook as the prior apps' instrumentation did), then flush+close.
- [ ] Honour `SCENEKIT_VIEWER_TEST_CONFIG` gracefully (no config needed; absent ⇒ default).
- [ ] Build to a `.app` whose `CFBundleIdentifier` equals the descriptor's `#:bundle-id`
      (`com.linkuistics.scenekit-viewer-<impl>`; sbcl's `build.sh` today writes the unsuffixed
      `com.linkuistics.scenekit-viewer` and omits the kind-required
      `CFBundleInfoDictionaryVersion` — both align at the instrument stage, the k104 seed).
