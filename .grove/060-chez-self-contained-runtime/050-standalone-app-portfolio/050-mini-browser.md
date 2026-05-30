# 050-mini-browser

**Kind:** work

## Goal
Build `mini-browser` as an open-world standalone `.app` and VM-verify it in a
no-Chez VM.

## Context
- **Async multi-callback delegate** — WKNavigationDelegate (spec §7). New axis vs
  `040`: callbacks fire **asynchronously off the run loop** (navigation
  start/finish/fail), each entering Scheme from the ObjC side at an arbitrary
  later time. Stresses the [[CONTEXT.md]] entry-point autoreleasepool convention
  and guardian lifetime under the embedded boot — transient objects from an async
  callback must drain at the pool boundary, not leak or get collected mid-flight.
- WebKit reach + network: confirm `(apianyware webkit)` links and the standalone
  binary can actually load a remote/local page in the VM (TCC/network sandbox).

## Done when
- `mini-browser.app` builds via `bundle_app` (open-world standalone).
- TestAnyware run in a no-Chez VM is green: a page loads and renders, navigation
  callbacks fire (URL/title updates), visual bar met.
- Any async-callback lifetime or WebKit-standalone quirk noted in
  `knowledge/targets/chez.md`.

## Notes
- A crash *after* navigation completes (not during launch) points at guardian
  collection of an object still held by an in-flight async callback — the
  autoreleasepool/guardian interaction under whole-program optimisation.
