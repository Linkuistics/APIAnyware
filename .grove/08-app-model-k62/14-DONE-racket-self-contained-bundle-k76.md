# racket-self-contained-bundle-k76

**Kind:** work

## Goal

Make the racket `.app` bundles self-contained. Today they ship **uncompiled `.rkt`
source** run via `/opt/homebrew/bin/racket`, so a vanilla VM needs a full Racket
runtime (~975 MB; ~306 MB gzipped upload) plus the user-scope `ffi2-lib` package —
k73 deferred the racket run over this, and k74 provisioned it all manually. The k68
build chose shared-runtime deliberately; this leaf revisits that as a **build**
decision with the live-run evidence in hand.

## Context

- Bundler: `targets/racket/tools/bundle-racket`. Candidate routes (k74):
  `raco distribute` / `raco exe --gui`, **or** vendor the `ffi2` collection into the
  bundle + ship precompiled `.zo`.
- The `ffi2` collection comes from the user-scope package `ffi2-lib`
  (`~/Library/Racket/9.2`, 760 K, path-portable) — without it:
  `collection not found for module path: ffi2`.
- Cold-launch source compilation (~14 s) exceeded the AppSpec run-harness's 10 s
  `wait-ready` window; `raco make` (16 `.zo`) cut it to ~0.3 s. Whichever route,
  **precompiled `.zo` is mandatory**.
- Full provisioning recipe + findings: `apps/macos/hello-window/docs/run-results.md`
  and k74 (`12-DONE-appspec-hello-window-racket-run-k74.md`).

## Done when

- The racket hello-window `.app` launches in a vanilla VM with **no** host Racket
  runtime or `ffi2` staging, inside the run-harness `wait-ready` window.
- The hello-window AppSpec suite re-runs green (3/3) against the rebuilt bundle
  ([[vm_verify_every_app]] — the VM re-run is the done-bar).
- `run-results.md`'s racket build/runtime finding updated (recipe → superseded by
  the self-contained build, or the residual documented).
- Commit names `racket-self-contained-bundle-k76`.

## Notes

Target-build work homed under ws7 because the need is AppSpec-run portability (the
racket runtime upload is the single largest per-run provisioning cost across the
remaining per-app leaves). AppSpec-side nothing changes — the launcher already passes
the absolute `#:binary` path (k73 `running-app?` fix matches any launch shape).
