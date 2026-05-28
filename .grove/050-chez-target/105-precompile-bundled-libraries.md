# 105-precompile-bundled-libraries

**Kind:** work

## Goal
Eliminate the ~75s first-launch compile cost paid by every bundled chez
sample app. Pre-compile each `.sls` file under
`Resources/chez-app/apianyware/` into a sibling `.so` during bundling, so
Chez's `import` lookup finds the compiled object first and skips the
on-demand compile pass entirely. Cold-launch falls from ~75s to
near-instant; idle RSS baseline likely drops too (less syntax data
retained).

## Context
- Surfaced during `100-port-hello-window/040-testanyware-verify` —
  bundled hello-window took ~75s to draw its window because Chez was
  compiling `apianyware/appkit.sls` (70k lines) on first import. See
  `generation/targets/chez/test-results/hello-window/report.md`.
- Chez compile model: when `import` resolves `(apianyware appkit)` to
  `<libdir>/apianyware/appkit.sls`, Chez first probes for
  `appkit.so`. If present and newer than the `.sls`, it's loaded
  directly. If absent or stale, Chez compiles the `.sls` and (for
  `--script` invocations) discards the compiled image without writing
  it out. So `.so` next to `.sls` is the on-disk lever — no flags or
  runtime changes required at the call site.
- Bundling pipeline: `generation/crates/bundle-chez/` already lays out
  `Resources/chez-app/apianyware/<fw>.sls` (the facade) and
  `Resources/chez-app/apianyware/<fw>/<class>.sls` (per-class). It
  also copies `runtime/*.sls`. All of these are candidates.
- Chez API for pre-compile: `compile-library` produces `.so` next to
  `.sls`. Needs `(library-directories)` set to the same root the
  runtime uses. Order matters — a facade can't compile until its
  per-class dependencies are compiled. Likely strategy: walk the
  layout depth-first, compiling per-class libraries first, then
  facades, then app entry-point if applicable.
- Per-Chez-version artifact: `.so` files are tied to the exact Chez
  version that produced them. The bundle's stub-launcher execs
  `/opt/homebrew/bin/chez`; if the host's Chez upgrades, stale `.so`
  files become invalid. Two reasonable answers: (a) Chez auto-rejects
  stale `.so` and recompiles (back to slow), or (b) error out. Need
  to verify Chez's actual behaviour and document it.

## Done when
- `bundle-chez` runs a pre-compile pass that produces `.so` siblings for
  every bundled `.sls` (runtime, per-class generated, per-framework
  facades, and the app entry-point itself if Chez supports
  pre-compiling scripts).
- A re-bundled chez `hello-window` launches in the VM in **under 5
  seconds** to first window draw (measured via TestAnyware), versus
  ~75s today. The bar is "feels instant relative to racket".
- The bundle still launches correctly when only `.so` files are present
  next to `.sls`, and also correctly when `.so` is stripped (i.e.
  pre-compile is an optimization, not a requirement).
- Bundle size growth is recorded in the leaf's commit (rough number
  — `du -sh "Hello Window.app"` before/after).
- The `bundle-chez` test suite still passes.
- Re-running the existing `040-testanyware-verify` flow against the
  re-bundled app produces a screenshot indistinguishable from
  `screenshot-001-launch.png`, with launch time noted in
  `test-results/hello-window/report.md`.
- A short note in `generation/crates/bundle-chez/README.md` (or the
  chez target README) explains the pre-compile step, its
  Chez-version-locking caveat, and how to skip it if useful for
  debugging (env var, cargo feature, or function arg — pick one).

## Notes
- Compilation order is load-bearing. A `(library (apianyware appkit))`
  re-export depends on every `(apianyware appkit <class>)` already
  being importable; trying to `compile-library` the facade first will
  trigger a full source compile of every dependency. Compile leaves
  before roots.
- Compile errors during the pre-compile pass should fail the bundle
  build loudly — silent fallback to "ship `.sls` only, compile at
  runtime" would mask emitter regressions. The pre-compile step *is*
  a useful build-time sanity check on the emitter output.
- The pre-compile step runs `chez` from the host. Path resolution:
  reuse `DEFAULT_CHEZ_PATH` from `bundle-chez::bundle` and feed it the
  same `--libdirs <Resources>/chez-app/` the stub-launcher will use.
- Out of scope: dropping the facade in favour of per-class imports at
  the call site. That's a separate emitter-shape decision (see the
  "granular imports" thread in the 100-port-hello-window retirement
  notes). Pre-compile is orthogonal — it accelerates whatever shape
  the emitter currently produces.
- This leaf is sized for one session. If pre-compile turns out to
  need a Chez script wrapper (rather than calling
  `compile-library` from Rust via subprocess), that wrapper still
  fits the budget — it's tens of lines of Scheme.
