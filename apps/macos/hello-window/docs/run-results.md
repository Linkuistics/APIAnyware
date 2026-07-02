# Hello Window — live-VM run results

Durable record of the Tier-2 acceptance run: the forward-generated `#lang app-spec` suite
(`scenarios/`) replayed against the built impls in a macOS VM via TestAnyware. Authored **into** this
repo by the AppSpec toolkit grove's `02-provision-install-run-k33` leaf (ADR-0013: AppSpec drives the
run and holds no app data; the data's home is here). The toolkit-side validation record is
`AppSpec/capabilities/forward-gen/validation.md` §6.6.

## Run environment

- **Date:** 2026-06-30.
- **VM:** `testanyware vm start --platform macos` (golden `testanyware-golden-macos-tahoe`),
  framebuffer **1920×1080** (non-HiDPI).
- **Suite:** `apps/macos/hello-window/scenarios/` (forward-gen Tier-2 output, leaf k72).
- **Runner:** `racket AppSpec/runner/main.rkt --impl <descriptor> --run-values run-values.rkt
  --vm <id> run scenarios/` — the runner consumes this worktree across the ADR-0013 boundary.

## Outcomes

| impl | 01 steady-state | 02 Command-Q terminates | 03 close-button `recording:` | notes |
|---|---|---|---|---|
| **chez**   | PASS | PASS | **PASS** (keeps running) | self-contained dump |
| **sbcl**   | PASS | PASS | **PASS** (keeps running) | needed Homebrew `libzstd.1.dylib` staged in VM (see below) |
| **gerbil** | PASS | PASS | **PASS** (keeps running) | self-contained (vendored libssl/libcrypto); ran as a single-invocation full suite `3/3` |
| **racket** | PASS | PASS | **PASS** (keeps running) | needs a Racket runtime provisioned in the VM (see below); ran as a single-invocation full suite `3/3` |

- **`02` Command-Q termination** (the mandated §6 / gui-app invariant) PASSED on **all four** run impls.
- **`03` close-button `recording:` scenario** PASSED on **all four** — a **pass confirms** the §3.8 /
  ns-application-terminate "close hides the window, the app keeps running" expectation. Per ADR-0010
  D4 this signals reverse-gen may drop the `(to confirm in-VM)` marker (chez/sbcl/gerbil/racket). It is
  **not** a spec-quality failure.
- **Assertion boundary held:** the run asserted only the runnable subset; the four §10 gaps (window
  size/position, the Command-Q key-equivalent, the dynamic no-edit) stayed **reported, not forced**.

## Close-button coordinates — measured live

`run-values.rkt` previously held the provisional `(332, 284)` (computed for an assumed 1024×768
framebuffer). On the live **1920×1080** display, `agent snapshot --mode layout` reads:

- window AX origin `(760, 215)`, size `400×232` — `[NSWindow center]` biases the window **above**
  true centre, so the vertical formula was wrong; the horizontal `(W−400)/2 = 760` was right;
- the leftmost traffic-light `AXButton "close button"` at `(768, 223)` size `16×16` → centre
  **`(776, 231)`**.

The four impls share this fixed-size centred-window geometry, so the two literals
(`close-button-x 776`, `close-button-y 231`, now in `run-values.rkt`) apply to all of them. No
async-settle `(wait …)` was needed — every `expect-running-app` resolved single-shot.

## Build / runtime findings (per impl)

- **sbcl is not a fully self-contained dump — RESOLVED 2026-07-02 (`sbcl-vendor-libzstd-k75`; see
  the re-run section below).** The k30 dev-wrapped `.app` linked Homebrew
  `/opt/homebrew/opt/zstd/lib/libzstd.1.dylib` (SBCL core zstd compression) by absolute path —
  absent in a vanilla VM (`dyld: Library not loaded … libzstd.1.dylib`, abort); this run staged the
  host dylib at that path in the VM. Fix: `build.sh` converged onto the production bundler
  (`apianyware-bundle-sbcl`, ADR-0041 — stub launcher + `DYLD_FALLBACK_LIBRARY_PATH` + vendored
  `libzstd.1.dylib`/`libAPIAnywareSbcl.dylib`), which also retired the `/tmp/libAPIAnywareSbcl.dylib`
  VM staging.
- **racket is not self-contained — RESOLVED 2026-07-02 (`racket-self-contained-bundle-k76`; see
  the racket re-run section below).** Original finding: it needs a Racket runtime (provisioned;
  ran 3/3, k34, 2026-06-30).
  The `.app` ships **uncompiled `.rkt` source** (`Contents/Resources/racket-app/`) that its Swift
  launcher runs via `/opt/homebrew/bin/racket`; a vanilla VM has no Racket (`Hello Window: exec failed:
  No such file or directory`). `targets/racket/.../build.sh` already flags this (racket "depends on the
  SHARED racket binding package"). The AppSpec `03-racket-runtime-run-k34` leaf provisioned the runtime
  (no VM network) and ran the suite — **3/3, identical to the other three impls**. What it took:
  - Uploaded the host **Racket v9.2** install (`/Applications/Racket v9.2`, 975 MB; the host's
    `/opt/homebrew/bin/racket` is a symlink to it, so build-time ≡ run-time Racket — zero version skew)
    and symlinked `/opt/homebrew/bin/racket` → it in the VM.
  - Uploaded the **`ffi2-lib`** package (standard `github.com/racket/racket` pkg, installed user-scope
    at `~/Library/Racket/9.2`, 760 K) — `racket-app/runtime/ffi2-seam.rkt` requires the `ffi2`
    collection, which is **not** in the Racket install. Without it: `collection not found … ffi2`.
  - **`raco make`-precompiled** the bundle (cold launch ~14 s of pure source compilation → ~0.3 s),
    because `racket file.rkt` writes no `.zo` and the run-harness `wait-ready` window is 10 s.
  - The close-button geometry is shared (`AXButton` centre ≈ `(775, 230)` vs the measured `(776, 231)`)
    — no re-measure or coord change needed.
  - **Candidate build improvement:** make racket self-contained — `raco distribute`/`raco exe --gui`,
    or bundle the `ffi2` collection + ship precompiled `.zo` — so the bundle travels without a host
    Racket (the analogue of the sbcl libzstd-vendoring candidate). k28 chose the shared-runtime build
    deliberately, so this is an APIAnyware build decision for when it resumes, not made by k34.
    **Taken up and resolved by k76 (below).**
- **chez / gerbil** are genuinely self-contained dumps (chez has no Homebrew deps; gerbil vendors
  `libssl.3`/`libcrypto.3` under `Contents/Frameworks/` via `@executable_path`).

The toolkit fixes the run forced (the `running-app?` predicate, the `quit-impl!` `is running` guard,
and the `cat`-based log tailer) are AppSpec-side; see `validation.md` §6.6.

## Re-run — sbcl self-contained bundle (2026-07-02, `sbcl-vendor-libzstd-k75`)

The sbcl impl was rebuilt with `build.sh` converged onto the production bundler
(`apianyware-bundle-sbcl`): Swift stub CFBundleExecutable (`DYLD_FALLBACK_LIBRARY_PATH` →
`Contents/Frameworks/`, `execv`s the image at `Contents/Resources/`), `libzstd.1.dylib` +
`libAPIAnywareSbcl.dylib` vendored, dylib namestring recorded `@executable_path/../Frameworks/…`
at dump. The suite was re-run in a **vanilla VM** (fresh `testanyware-golden-macos-tahoe` clone,
1920×1080) with **nothing staged** — verified absent: `/opt/homebrew/opt/zstd/…` and
`/tmp/libAPIAnywareSbcl.dylib`.

| impl | 01 steady-state | 02 Command-Q terminates | 03 close-button `recording:` | notes |
|---|---|---|---|---|
| **sbcl** | PASS | PASS | PASS | fully self-contained; zero VM provisioning; startup emitted ~400 ms after `open` |

Scenarios were graded per-scenario invocation (the k73 chez/sbcl mode; sanctioned by run
`workflow.md` §3): 01 passed twice, 02 twice, 03 twice across the session's invocations.

**Run-mechanism finding (AppSpec/TestAnyware-side, carried for a future toolkit session):** in a
single-invocation full-suite run the 01→02 transition reproducibly failed `wait-ready` (`did not
emit [lifecycle] startup within 10s`) — **with the app provably up**: the failure artifact's
`events.log.tail` contains `[lifecycle] startup` + `Hello Window opened.` and the AX snapshot shows
the window rendered. In-VM measurement of the exact setup sequence (quit → settle → truncate →
`open`) puts the startup line at **~400 ms** — the app is not slow; the *observation path* stalls:
a `testanyware exec` session issued after recent `open`/`osascript` activity can deliver its output
but hang its close until the CLI's 30 s cap, and one such stalled poll inside `wait-ready`'s 10 s
window fails the scenario. Scenario 02 passes solo after the channel idles. Successor to the k33
`wc -c`→`cat` tailer finding (`validation.md` §6.6); the fix belongs to the AppSpec runner
(e.g. a per-poll deadline / retry inside `wait-ready`) or the TestAnyware exec channel, not to any
impl. The k73 full-suite 3/3 rows (gerbil, racket) are unaffected; chez/sbcl were per-scenario
there too.

## Re-run — racket self-contained bundle (2026-07-02, `racket-self-contained-bundle-k76`)

The racket impl was rebuilt with the production bundler's new **self-contained mode**
(`apianyware-bundle-racket::bundle_app_self_contained`): `raco exe` embeds the app's full module
graph (generated bindings + runtime + the `ffi2` collection from the build host's `ffi2-lib`
package) into one executable; `raco distribute` makes it machine-portable and carries
`libAPIAnywareRacket.dylib` via the runtime's new `define-runtime-path` references
(swift-helpers.rkt / ffi2-dispatch.rkt — the old resolved-module-path lookup baked build-machine
paths and could never survive `raco exe`); a relocatable Swift stub `execv`s
`Contents/Resources/racket-dist/bin/hello-window`. The k68/k28 shared-runtime choice is revisited
and reversed for sample apps with the k73/k74 live-run cost evidence in hand (975 MB runtime +
760 K user-scope package + ~14 s first-launch compile, all per-VM).

The suite was re-run in a **vanilla VM** (fresh `testanyware-golden-macos-tahoe` clone, 1920×1080)
with **nothing staged** — verified absent before install: `/opt/homebrew/bin/racket` and
`~/Library/Racket`. Upload: 17 MB gzipped (was ~306 MB runtime + package); pre-flight `open` put
`[lifecycle] startup` in events.log well inside the 10 s `wait-ready` window (no `raco make`
provisioning step).

| impl | 01 steady-state | 02 Command-Q terminates | 03 close-button `recording:` | notes |
|---|---|---|---|---|
| **racket** | PASS | PASS | PASS | fully self-contained; zero VM provisioning; 82 MB `.app` |

Scenarios were graded per-scenario invocation (the k73/k75 mode; sanctioned by run `workflow.md`
§3) with idle gaps between invocations to sidestep the exec-channel close-stall documented above.
All four impls are now genuinely self-contained: chez/gerbil (dumps), sbcl (k75), racket (this).
