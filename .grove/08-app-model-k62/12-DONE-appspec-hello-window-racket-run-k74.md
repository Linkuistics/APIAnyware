# appspec-hello-window-racket-run-k74

**Kind:** work (cross-grove **record** — app data authored *into* this repo by the AppSpec toolkit grove
per ADR-0013; recorded here, not driven as an APIAnyware session)

## What this records

The **AppSpec toolkit grove** (`~/Development/AppSpec`, branch `appspec-toolkit`) is running to completion
during the `appspec-grove-pause-k66` pause. Its `03-racket-runtime-run-k34` leaf (under
`acceptance-test-k21/04-live-run-k25`) ran the Tier-2 live suite against the **fourth impl, racket** — the
one `02-provision-install-run-k33` (recorded as k73) deferred because racket, unlike the self-contained
Chez/SBCL/Gerbil dumps, needs a full Racket runtime in the VM. This leaf records the racket run landing
into this worktree (ADR-0013: AppSpec drives the run + holds no app data; the data's home is APIAnyware).

## Authored in this commit (the racket-run landing)

- **`apps/macos/hello-window/docs/run-results.md`** — the racket row filled in (PASS/PASS/PASS) and the
  racket build/runtime finding updated from "deferred" to the provisioned-and-ran record (the runtime
  recipe + the candidate self-contained-rebuild build improvement).

No `run-values.rkt` change: the close-button geometry is shared across the four impls and was already
refined to `(776, 231)` by k73 — racket's close `AXButton` reads at centre ≈ `(775, 230)`, within a pixel.

## Outcome — all four impls now clean

| impl | 01 steady-state | 02 Command-Q | 03 close-button `recording:` |
|---|---|---|---|
| chez   | PASS | PASS | PASS (keeps running) |
| sbcl   | PASS | PASS | PASS (keeps running) |
| gerbil | PASS | PASS | PASS (keeps running) |
| **racket** | **PASS** | **PASS** | **PASS** (keeps running) |

racket ran as a single-invocation full suite → `3/3`. The mandated **Command-Q termination** invariant
passed; the **`recording:` close-button** scenario passed → a pass **confirms** the gui-app "keeps
running" expectation for racket too (ADR-0010 D4; reverse-gen may now drop the `(to confirm in-VM)`
marker for all four impls). The four §10 gaps stayed reported, not forced.

## How racket's runtime was provisioned (the recipe — option 1, no VM network)

1. **Racket runtime.** The host `/opt/homebrew/bin/racket` is a **symlink** to `/Applications/Racket
   v9.2/bin/racket`, so the Racket that *built* the bundle source and the one that *runs* it are the
   same binary (**v9.2 [cs]**, arm64) — zero version skew. Uploaded `/Applications/Racket v9.2` (975 MB;
   ~306 MB gzipped, sha256-verified in the VM); symlinked `/opt/homebrew/bin/racket` → it.
2. **The `ffi2` collection.** `racket-app/runtime/ffi2-seam.rkt` requires `ffi2`, provided by the
   standard **`ffi2-lib`** package (`github.com/racket/racket`) installed **user-scope** at
   `~/Library/Racket/9.2` (760 K) — *not* inside the Racket install. Uploaded that tree →
   `~admin/Library/Racket/9.2` (`pkgs.rktd` holds only catalog source + checksum, no absolute paths, so
   it is path-portable). Without it: `collection not found for module path: ffi2`.
3. **Precompile.** Cold launch was ~14 s of pure first-run source compilation (over the AppSpec
   run-harness's 10 s `wait-ready` window); `racket file.rkt` writes no `.zo`. `raco make` of the bundle
   (16 `.zo`, ~12 s once) cut cold launch to ~0.3 s. A provisioning step, not a build/toolkit change.

The AppSpec-side `running-app?` predicate needed **no** change — the launcher passes the **absolute**
bundle script path, so `pgrep -f <#:binary>` (the k73 fix) matches racket too.

## Findings carried back (for APIAnyware on resume)

- **Candidate build improvement — make racket self-contained.** `raco distribute`/`raco exe --gui`, or
  bundle the `ffi2` collection + ship precompiled `.zo`, so the racket `.app` travels without a host
  Racket runtime (the analogue of the sbcl `libzstd.1.dylib`-vendoring candidate, k73). k28 chose the
  shared-runtime build deliberately; this is an APIAnyware **build** decision (do not reach into
  `targets/` from AppSpec beyond the existing `build.sh`), surfaced here for the resume.
- The toolkit-side validation record is `AppSpec/capabilities/forward-gen/validation.md` §6.6.1.

## Closes the Tier-2 run

With racket landed, **all four impls have run** (k73 = chez/sbcl/gerbil; this = racket). What remains in
the AppSpec grove is `05-adjudicate-and-close-k26` — fold the cross-impl acceptance verdict + author
run's `workflow.md` — which lands here as a later record.

_Recorded as DONE on landing — a provenance record of completed cross-grove authoring, not pending
APIAnyware work; `appspec-grove-pause-k66` remains the live pick target. ADR-0013 (AppSpec drives the run,
homes the data here); ADR-0052 (no app data in the toolkit)._
