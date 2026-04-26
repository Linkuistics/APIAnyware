# Modaliser-Racket — Prioritised Plan

_Last updated: 2026-04-11_

## Project Status

All 9 core implementation phases complete. App is functional: modal keyboard capture,
state machine, config loading, services, window management, chooser, and app bundling
with Swift stub launcher all work. 14 test suites (23 test files) passing.

**Primary blocker:** Overlay panel crashes after creation. Everything else is polish.

## Priority Order

### P0 — Unblock overlay (do next)

| # | Task | Category | Status | Rationale |
|---|------|----------|--------|-----------|
| 1 | Main-thread dispatch for UI ops | `[ui]` | not_started | Root cause of overlay crash. Background threads touching WKWebView is undefined behaviour in Cocoa. Flagged since Phase 3R — 4 sessions acknowledged the risk without fixing it. |
| 2 | Overlay panel crash | `[ui]` | in_progress | Depends on #1. Once main-thread dispatch exists, re-test panel creation. May resolve entirely, or may reveal a secondary issue. |

**Why this ordering:** The overlay crash has been `in_progress` since Session 10b with
no clear path forward. The memory and session log repeatedly note that `after-delay`
runs on background threads and WKWebView needs the main thread. Fixing dispatch first
gives a clean foundation to debug any remaining crash.

### P1 — Config completeness (after overlay works)

| # | Task | Category | Status | Rationale |
|---|------|----------|--------|-----------|
| 3 | `'remember` / `'id-field` properties | `[config]` | not_started | MRU ordering in chooser. Self-contained, no dependencies. Nice-to-have for daily use. |

### P2 — Robustness (low priority)

| # | Task | Category | Status | Rationale |
|---|------|----------|--------|-----------|
| 4 | `save-window-frame!` AX PID extraction | `[window-mgmt]` | not_started | Race condition with multi-instance apps. Unlikely in practice. |
| 5 | `restore-window` fullscreen guard | `[window-mgmt]` | not_started | Edge case requiring two commands within a delay window. |

### P3 — In-repo (was cross-project before the 2026-04-26 reorg)

| # | Task | Category | Status | Rationale |
|---|------|----------|--------|-----------|
| 6 | Racket contracts for bindings | `[tooling]` | not_started | Improves DX for all APIAnyware-Racket apps, not Modaliser-specific. Work belongs under `APIAnyware-MacOS/generation/targets/racket-oo/lib/` (no longer cross-project — this plan now lives in APIAnyware-MacOS). |

## Next Work Session

Pick task #1 (main-thread dispatch). Approach:
- Add `dispatch_async` + `dispatch_get_main_queue` FFI bindings to a new `APIAnyware-MacOS/generation/targets/racket-oo/apps/modaliser/ffi/dispatch.rkt`
- Create a `call-on-main-thread` helper that wraps a thunk in a dispatch_async block
- Retrofit `APIAnyware-MacOS/generation/targets/racket-oo/apps/modaliser/ui/panel-manager.rkt` to route all WKWebView calls through it
- Re-test overlay creation — if crash resolves, mark both #1 and #2 done
