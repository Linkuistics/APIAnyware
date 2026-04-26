# Modaliser-Racket

Racket reimplementation of the Modaliser modal keyboard system for macOS, using
racket-oo bindings under `APIAnyware-MacOS/generation/targets/racket-oo/`. All
core phases complete: app lifecycle, keyboard capture, state machine, overlay
UI, window management, services, chooser UI, config compatibility, app bundling
with Swift stub launcher, and MRU support for chooser selectors.

**Status (2026-04-26):** End-to-end VM verification complete. App launches,
installs CGEvent tap, loads user config, and processes leader key + action keys.
Overlay renders correctly (screenshot captured). Status-bar icon visible in
Tahoe menu bar. Full F18→overlay keyboard chain not demonstrable over VNC
(tart extended F-key propagation gap, not a Modaliser bug). Test suite: 30 OK /
0 fail. Structured event logging
(`APIAnyware-MacOS/generation/targets/racket-oo/apps/modaliser/lib/events.rkt`)
wired in 7 modules. Cross-impl spec verification lives in `AppSpec/` and is
tracked by its own plan (`app-spec-v1`).

## Tasks

### impl-window-move-logging-gap

**Category:** `bug`
**Status:** `not_started`
**Dependencies:** none

**Description:**

Surfaced by Task 24.

`APIAnyware-MacOS/generation/targets/racket-oo/apps/modaliser/services/window-manager.rkt` `center-window` and `restore-window` call
`ax-set-position!`/`ax-set-size!` without emitting `[window] move`. The
logging contract at `APIAnyware-MacOS/knowledge/apps/modaliser/logging-contract.md` says the event
fires on any Modaliser-initiated position/size change; only
`move-window` honors that. The Task 24 windows scenario
(`APIAnyware-MacOS/knowledge/apps/modaliser/scenarios/windows/01-focus-move-restore.rkt`) asserts the
contract-compliant behavior and will fail on live-VM against the
current impl until this is closed.

**What's needed:**
- Add `(log-event 'window 'move 'x … 'y … 'w … 'h …)` after the AX
  writes in `center-window` (single call site) and `restore-window`
  (two call sites: the delayed fullscreen-exit continuation and the
  immediate non-fullscreen branch). Use `exact->inexact` on all four
  values for consistency with the existing `move-window` emission.
- `toggle-fullscreen` stays silent intentionally — AX fullscreen
  doesn't yield rectangular geometry.

**Why this is its own task:** the fix touches host-side impl code and
therefore requires VM-based verification (`APIAnyware-MacOS/generation/targets/racket-oo/apps/modaliser/tests/run-all.sh` is
VM-only per `memory/feedback_impl_tests_vm_only.md`). A dedicated session
should: (1) make the impl change, (2) bootstrap a VM with Racket +
coreutils + TCC Accessibility grant for the racket binary, (3) run
the impl suite, (4) commit. Roughly 10–15 min of VM time.

**Gating:** independent of other tasks. Closing this makes the Task 24
windows scenario pass on live-VM; scenarios remain contract-correct
in the meantime.

**Results:** _pending_

---
