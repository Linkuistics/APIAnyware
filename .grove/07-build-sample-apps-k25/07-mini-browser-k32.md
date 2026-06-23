# mini-browser-k32

**Kind:** work

## Goal

The 060 ladder's 6th app: a Mini Browser (WKWebView + address bar + ◀/▶/Reload + status
line), proving the **async multi-callback WKNavigationDelegate** shape on sbcl. Written
against the CL-family contract; VM-verified.

## Context

Needs the emitter (040) + runtime (050) + WebKit generated. WebKit was absent from the IR,
so this leaf ran the pipeline for it (resolve→annotate→enrich `--only WebKit` + `--target
sbcl`). The riskiest delegate shape so far (gerbil precedent: async, main-thread callbacks).

## Done when

- App built + **TestAnyware VM-verified**, with `learnings.md` + `test-results/.../report.md`.

## Notes

**DONE 2026-06-23.** ✅ Built + VM-verified.

- One `browser-controller` (`define-objc-subclass` of NSObject, `(:protocols
  "WKNavigationDelegate")`) — FIRST GUI app to use formal protocol conformance — carries
  EIGHT selectors: the 4 nav callbacks (2-arg `v@:@@`, 3-arg `v@:@@@` — first multi-arg
  delegate selectors) + the 4 toolbar target-actions. The one forwarding dispatcher reads
  arg shape live off the NSMethodSignature, so no per-arity machinery; nav callbacks arrive
  on main (ADR-0035 bounce a no-op).
- **Runtime gap FIXED** (`lib/runtime/subclass.lisp`): `aw-selector->generic-name` still
  DROPPED colons (pre-ADR-0039), so `reload:` collided with WKWebView's emitted 0-arg
  `reload` (`FIND-METHOD-LENGTH-MISMATCH`). Now follows ADR-0039 (colon→`_`), matching the
  emitter; first app whose hand-written delegate selector names a real emitted method.
  Seven-smoke runtime suite stays green.
- VM-verified live: example.com renders, status async-tracks to "Done", address bar resolves
  canonical URL, bare host `example.org`→`https://example.org/` (normalise), ◀/▶ bidirectional
  history with correct enable/disable, Reload, title tracks once KVO settles, Cmd-Q clean.
- Every framework `:load-residual nil` (pure-ObjC surface); dylib loaded only for the
  subclass bounce shim. WebKit regenerated Trampolines.swift (220 entries) clean; zero
  Swift-native residual on this path.
- Artifacts: `apps/mini-browser/{mini-browser.lisp,run.lisp,dump.lisp,build.sh,README.md,
  learnings.md}` + `test-results/mini-browser/report.md` + 3 screenshots.
