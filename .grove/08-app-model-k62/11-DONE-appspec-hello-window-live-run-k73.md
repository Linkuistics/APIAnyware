# appspec-hello-window-live-run-k73

**Kind:** work (cross-grove **record** — app data authored *into* this repo by the AppSpec toolkit grove
per ADR-0013; recorded here, not driven as an APIAnyware session)

## What this records

The **AppSpec toolkit grove** (`~/Development/AppSpec`, branch `appspec-toolkit`) is running to completion
during the `appspec-grove-pause-k66` pause. Its `02-provision-install-run-k33` leaf (under
`acceptance-test-k21/04-live-run-k25`) performs the **Tier-2 live run**: provision a macOS VM, install the
built `.app` bundles, and replay the forward-generated suite (k72) against each impl, capturing outcomes.
This leaf records the app-data landing of that run into this worktree (ADR-0013: AppSpec drives the run +
holds no app data; the data's home is APIAnyware).

## Authored in this commit (the live-run landing)

- **`apps/macos/hello-window/run-values.rkt`** — the close-button coordinates **refined from the live VM**:
  the provisional `(332, 284)` (assumed 1024×768) → **`(776, 231)`**, measured on the real 1920×1080
  framebuffer (`agent snapshot --mode layout`: window AX origin `(760, 215)` size `400×232`; close
  `AXButton` centre `(776, 231)`). The four impls share this fixed-size centred-window geometry.
- **`apps/macos/hello-window/docs/run-results.md`** — the durable per-impl run-results record: the
  outcome table, the close-button measurement, and the per-impl build/runtime findings.

## Outcome (three impls clean; racket deferred)

| impl | 01 steady-state | 02 Command-Q | 03 close-button `recording:` |
|---|---|---|---|
| chez   | PASS | PASS | PASS (keeps running) |
| sbcl   | PASS | PASS | PASS (keeps running) |
| gerbil | PASS | PASS | PASS (keeps running) |
| racket | deferred (needs a Racket runtime in the VM) |||

The mandated **Command-Q termination** invariant passed on all three; the **`recording:` close-button**
scenario passed on all three → a pass **confirms** the gui-app "keeps running" expectation (ADR-0010 D4;
reverse-gen may drop the `(to confirm in-VM)` marker for these three). The four §10 gaps stayed reported,
not forced.

## Findings carried back (for APIAnyware on resume)

- **sbcl is not a fully self-contained dump** — its `hello-window` links Homebrew
  `/opt/homebrew/opt/zstd/lib/libzstd.1.dylib` (SBCL core zstd compression) by absolute path, absent in a
  vanilla VM. The run staged the host dylib in the VM. **Candidate build improvement:** vendor
  `libzstd.1.dylib` into the `.app` (the build vendors only `libAPIAnywareSbcl.dylib` today).
- **racket is not self-contained** — the `.app` ships uncompiled `.rkt` source run via
  `/opt/homebrew/bin/racket`, so it needs a full Racket runtime (~975 MB) in the VM, or a self-contained
  `raco distribute` rebuild. Externalized upstream as AppSpec grove leaf `03-racket-runtime-run-k34`; its
  racket row + any rebuild lands here as a later record.
- **chez / gerbil** are genuinely self-contained (chez: no Homebrew deps; gerbil: vendored
  `libssl.3`/`libcrypto.3` via `@executable_path`).
- **Three AppSpec-side run-mechanism fixes** the first live run forced (recorded in the toolkit, not here):
  the `running-app?` predicate (match `#:binary`, not bundle-id), the `quit-impl!` `is running` guard, and
  a `cat`-based log tailer (the old `wc -c` size probe gated on a flaky agent rc). See
  `AppSpec/capabilities/forward-gen/validation.md` §6.6.

## Still to land (later AppSpec children — separate records into this repo)

`03-racket-runtime-run-k34` (the racket run, once a runtime is provisioned) and
`05-adjudicate-and-close-k26` (fold the cross-impl acceptance verdict + author run's `workflow.md`).

_Recorded as DONE on landing — a provenance record of completed cross-grove authoring, not pending
APIAnyware work; `appspec-grove-pause-k66` remains the live pick target. ADR-0013 (AppSpec drives the run,
homes the data here); ADR-0052 (no app data in the toolkit)._
