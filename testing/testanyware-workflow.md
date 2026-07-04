# TestAnyware GUI-testing methodology

The operational how-to for driving a GUI app in a live macOS VM through
**TestAnyware** — the runbook behind [`test-model.md`](test-model.md) layers 8–9
(AppSpec sample-app · GUI/accessibility). `test-model.md` is the *model* (which
layers exist and where they are homed); this is the *runbook* (how you actually
drive the VM).

**GUI apps are never run on the host.** Every sample app is verified visually in
an isolated macOS VM via TestAnyware — a launched window would steal focus, move
the mouse, and interfere with the host. This is a standing rule.

## Where this fits: TestAnyware vs AppSpec

Two tools sit in front of a running binding, and it matters which you reach for:

- **AppSpec** (`~/Development/AppSpec`, external) is the **automated** path. It
  drives a `#lang app-spec` scenario suite against a running implementation in a
  VM, through TestAnyware, and reports pass/fail. For the standard app portfolio
  this is the primary verifier — each app's suite lives at
  `apps/macos/<app>/scenarios/*.rkt` and its implementations at
  `targets/<t>/app-implementations/macos/<app>/`. Run those suites via AppSpec;
  do not hand-drive what a scenario already covers. See
  [`test-model.md`](test-model.md) §"The §34 seam" and **ADR-0052**.
- **TestAnyware** (`~/Development/TestAnyware`, external, **brew-installed**) is
  the **substrate** AppSpec drives on top of, and the tool you use **directly**
  for the manual loop: provisioning a VM, exploratory or one-off GUI driving,
  capturing screenshots for docs, and hand-debugging a scenario that AppSpec
  reports as failing. This document is that direct methodology.

The three-layer boundary is **TestAnyware** (VM substrate) → **AppSpec** (toolkit
+ `#lang app-spec` formats, holds no app data) → **APIAnyware** (this repo, holds
the app specs + implementations). See `CONTEXT.md` "App model / AppSpec".

## Prerequisites

- **`testanyware`** on `PATH` — it is **brew-installed** (`/opt/homebrew/bin/testanyware`).
  Do **not** build it from a source checkout; there is no `.build/debug/testanyware`
  in the workflow. The CLI is self-documenting:

  ```bash
  testanyware llm-instructions      # authoritative agent-facing usage
  testanyware <command> --help      # per-command surface
  ```

  Treat those two commands as the source of truth for the command surface — this
  doc summarises it, but the CLI is authoritative and cannot go stale.
- A **built implementation** to test: a bundled `.app` under
  `targets/<t>/app-implementations/macos/<app>/` (built per that target's
  `docs/reference.md`), for one of the four live targets — **racket · chez ·
  gerbil · sbcl**.
- The **common app spec** the implementation is held to: `apps/macos/<app>/docs/spec.md`
  plus the `logging-contract.md` / `observable-state.md` contracts and the
  `scenarios/*.rkt` suite.

## Command surface (summary)

Verb-first; coordinates are VNC-display pixels (capture is downscaled, so a
pixel read off a screenshot is **not** a click coordinate — get click targets
from `agent snapshot`, never from the PNG):

- `vm start|stop|list` — VM lifecycle.
- `screenshot -o f.png [--region x,y,w,h] [--window NAME]` · `screen-size`.
- `input {click,move,drag,mouse-down,mouse-up,key,type}` — synthetic input.
- `agent {health,windows,snapshot,inspect,press,set-value,window-move,window-resize,window-close}`
  — accessibility-tree queries + element-addressed actions (screen-absolute
  coordinates from `positionX/Y`).
- `exec "cmd"` — in-guest shell (no WindowServer session — see *Launching* below).
- `upload <local> <remote>` · `download <remote> <local>`.

## VM lifecycle

```bash
vmid=$(testanyware vm start --platform macos)   # clone the golden image
export TESTANYWARE_VM_ID=$vmid                  # subsequent commands need no connection flag
# ... drive the VM ...
testanyware vm stop "$vmid"                      # deletes the clone
```

The golden image is `testanyware-golden-macos-tahoe`; user `admin`, home
`/Users/admin`, desktop unlocked (no password). Each `vm start` is a throwaway
clone — `vm stop` discards it.

## Uploading the app

Upload is **direct** — a single `upload` handles large payloads (a few-hundred-MB
file in about a second). The old `split -b 4m` chunk-and-reassemble recipe is
**obsolete**; do not reintroduce it.

```bash
testanyware upload ./MyApp.app.tgz /Users/admin/MyApp.app.tgz
testanyware exec "cd /Users/admin && tar xzf MyApp.app.tgz && xattr -dr com.apple.quarantine MyApp.app"
```

Per-target provisioning (whether the VM needs a language runtime staged, or the
bundle is self-contained) is target-specific and **documented at the source of
truth**, not duplicated here — see each target's `targets/<t>/docs/reference.md`
and the per-app `apps/macos/<app>/docs/run-results.md` for the exact, current
recipe (e.g. standalone chez/sbcl bundles need no runtime staged; racket apps
exec the system Racket and so need it provisioned).

## Launching an app

GUI apps must be launched with **`open -n`**, not a direct `exec` of the bundle
stub: the `exec` channel has no WindowServer session, so a direct stub exec
prints its banner and exits without a window.

```bash
testanyware exec "open -n --stdout /tmp/app.log --stderr /tmp/app.log /Users/admin/MyApp.app"
```

## The manual verification loop

The direct TestAnyware loop is **screenshot → analyse → act → verify → repeat**,
LLM-driven (not scripted):

1. **Launch** the app (`open -n`).
2. **Capture** the initial state (`screenshot` / `agent snapshot`) — verify the
   window appears with the expected title and layout.
3. **Walk the scenarios.** Drive the behaviour the app's `scenarios/*.rkt` suite
   and `apps/macos/<app>/docs/spec.md` describe. For each step: capture, analyse
   (does the state match the expected behaviour?), act (`input` / `agent` against
   an element's reported centre), verify.
4. **Categorise any mismatch** — binding bug (fix the emitter), runtime bug (fix
   the target runtime), app bug (fix the implementation), or a TestAnyware/AppSpec
   tooling bug — then fix, rebuild, relaunch, and continue.
5. **Record** the outcome in the app's `apps/macos/<app>/docs/run-results.md`
   (status, evidence, and any run-mechanism gotchas discovered).

Interaction gotchas (click-through on non-key windows, capture-then-parked-click
focus swallow, coordinate-space scale, OCR small-text garbling) are real and
cost time; the current catalogue lives in each app's `run-results.md` and in the
project memory, not inlined here where it would rot.

## See also

- [`test-model.md`](test-model.md) — the multi-layer test model this runbook sits
  under (layers 8–9 are the AppSpec/GUI executor).
- [`README.md`](README.md) — the one-screen map of this `testing/` home.
- `apps/macos/docs/_index.md` — the sample-app portfolio and per-app status
  (derived by `apianyware-conformance`, ws6).
- **ADR-0052** — AppSpec as the external LLM-driven spec/test toolkit.
