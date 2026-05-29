# 060-chez-self-contained-runtime — brief

## Goal
Make a chez `.app` self-contained — it must launch on a machine with **no
Chez Scheme installed**, with no `brew install chezscheme` provisioning step.
Today the stub-launcher `execv`s the *system* `/opt/homebrew/bin/chez`
(`bundle.rs` `DEFAULT_CHEZ_PATH`), so the bundle hard-depends on a host Chez.

The grilling (2026-05-29) settled the shape: a chez bundle becomes a **native
standalone binary** built in one of **two per-app modes** — **Open-world** (full
`scheme` boot embedded; runtime `eval`/`load` available) and **Closed-world**
(`compile-whole-program`-sealed; no runtime compiler). See the glossary and the
decisions log below. The bundle-the-runtime-tree direction survives only as the
*fallback* if the spike refutes native.

## Decisions (running log) — the planning output of this node

**D1 — Spike-first as a gate (2026-05-29).** The native-compilation path is
treated as a *hypothesis*, not a foundation. The node's first child is a spike
that must prove native end-to-end — dynamic `eval`/`load` works in the shipped
binary, a delegate/block callback fires (the dispatch `eval` substrate), FFI +
`lock-object` + guardians survive the embedded kernel, and it launches in a VM
with **no Chez installed** — *before* any implementation work leaves are
committed. If the spike refutes native, the node pivots to the
bundle-the-runtime-tree fallback with its size/launch trade-offs documented.
Rationale: the riskiest claims are empirical (open-world runtime `eval`
coexisting with a closed-world standalone link); only a running binary resolves
them.

**D2 — Open-world / closed-world is a per-app build mode (2026-05-29, user
steer).** Self-contained-ness is not one shape; the bundler offers two standalone
build modes chosen per-app by the app's nature (glossary: **Open-world build**,
**Closed-world build**). This **amends the original requirement 1** (below):
runtime dynamic Scheme loading is a *capability the open-world mode provides*, not
a tax every app pays. The deep consequence is that the two modes map onto **two
dispatch backends** — open-world keeps today's `eval`-synthesized
`foreign-callable` trampolines (`dispatch.sls`, chez.md 🔴 2026-05-27);
closed-world replaces them with trampolines **enumerated from the app's static
usage and emitted as literal forms at build time**. Boot size is the visible
difference; the dispatch backend is the real engineering content.

**D3 — The spike proves both modes for `hello-window` (2026-05-29).**
`hello-window` uses no dispatch (design spec §7 baseline), so its closed-world
build needs **zero** `foreign-callable` trampolines — proving the whole-program
seal-and-link mechanics without first solving the eval-free dispatch backend. The
spike delivers a head-to-head size/cold-launch comparison and validates the
per-app toggle from day one, cheaply. The eval-free dispatch backend (D2) is
proven **later**, in a closed-world build of a delegate-using app, as its own
node. The open-world half must still include a *synthetic* dynamic-load proof
(`eval`/`load` a form not seen at link time), since `hello-window` loads nothing.

**D4 — Source-exec retirement is deferred to a post-spike decision (2026-05-29,
user steer).** Whether chez bundles drop the source-exec (stub-launcher + system
Chez) path — and with it `launch.ss`/precompile/version-coupling — is decided
*after* the spike, on the numbers. This makes a **head-to-head measurement a
spike deliverable**: cold-launch time and bundle size for (a) today's source-exec
baseline, (b) open-world standalone, (c) closed-world standalone, for
`hello-window`. Racket's stub-launcher path is untouched regardless. Until the
decision lands, the source-exec path stays working (never without a green path).

**D5 — The standalone builder is a new mode in `bundle-chez` (2026-05-29).**
`AppSpec` gains a build-mode enum — `SourceExec | StandaloneOpen |
StandaloneClosed` — superseding the `skip_precompile` bool. The native-link
orchestration (`compile-whole-program` → `make-boot-file` → `cc`-link
`main.o`+`libkernel.a` → assemble + codesign) lives in a new `bundle-chez`
module (`standalone.rs`), reusing the existing deps walker, `spec`, codesign, and
install-name machinery. Promote to a sibling crate only if it later grows
unwieldy. Racket's stub-launcher path is untouched.

## Children
- **`010-spike-dual-mode-standalone.md`** (work/spike) — the gate (D1). Prove
  open-world AND closed-world standalone for `hello-window` (D3), capture the
  three-way numbers (D4), confirm it launches in a VM with Chez uninstalled.
  Outputs a spike report with a go/no-go and the measurements.
- **`020-decide-spec-and-grow.md`** (planning) — runs *after* the spike. Reads
  the numbers, makes the D4 source-exec-retirement call, writes the design-spec
  section (chosen approach, bundle layout, build pipeline, what's obsoleted),
  raises ADRs (standalone build modes; the D2 two-dispatch-backend / requirement-1
  amendment), then grows the implementation work leaves — including the
  closed-world eval-free dispatch backend, the open/closed builder modes, the
  toolchain docs (original requirement 2), and a per-app VM-verify leaf
  ([[feedback-use-testanyware]]). Grown lazily once the spike's reality is known,
  so the tree isn't speculated ahead of evidence.

## Original requirements (from the user, 2026-05-29 — requirement 1 amended by D2)

1. **Dynamic Scheme load at runtime.** *Amended by D2:* now a per-mode
   capability (open-world provides it), not a universal mandate. The open-world
   spike must still *prove* it (build a `foreign-callable` via `eval` at runtime
   and `load`/`eval` a fresh form not seen at link time).
2. **Document the tooling — and expect to build our own.** No turnkey Chez
   "produce a signed macOS `.app`" command exists; the path is a multi-step dance
   (`compile-whole-program` → `make-boot-file` → `cc`-link → assemble +
   codesign). The tool (D5: a `bundle-chez` mode) **and its toolchain docs** —
   required Chez artifacts, where they come from, exact build steps, dev-repro
   recipe — are a first-class deliverable, not a side effect. Owned by `020`.

## Context (background for the children)
- **Current bundling:** `generation/crates/bundle-chez/` stages `.sls` (+ leaf-160
  `launch.ss`), precompiles to `.so`, copies `libAPIAnywareChez.dylib`, and the
  Swift stub execs the system chez `--libdirs … --script …/launch.ss`. See
  `knowledge/targets/chez.md` §6–7 and the design spec
  `docs/specs/2026-05-27-chez-target-design.md`.
- **Native-path machinery is present** (verified 2026-05-29 on Chez 10.4.1):
  `compile-program`, `compile-whole-program`, `compile-whole-library`,
  `make-boot-file`, `generate-wpo-files` all bound; kernel artifacts
  (`libkernel.a`, `main.o`, `scheme.h`, `scheme.boot`, `petite.boot`,
  `liblz4.a`, `libz.a`) confirmed in
  `/opt/homebrew/Cellar/chezscheme/10.4.1/lib/csv10.4.1/tarm64osx/`.
  Authoritative recipe: Chez Scheme User's Guide §2.8 / "Using Chez Scheme"
  (`cisco.github.io/ChezScheme/csug10.0/use.html`) and the `main.c`/kernel
  entry-points section (§4.9).
- 🔴 **Load-bearing constraint — the open-world dispatch substrate needs the
  compiler at runtime.** `runtime/dispatch.sls` builds `foreign-callable` forms
  with `quasiquote` and **`eval`s them in `(interaction-environment)`** (chez.md
  🔴 2026-05-27) — how blocks, delegates, and dynamic subclasses get arbitrary
  runtime signatures. A `petite`-only boot has no compiler, so open-world **must
  embed the full `scheme` boot**. The closed-world backend (D2) is the
  eval-free alternative: trampolines enumerated from static usage.
- **FFI must survive whole-program optimisation.** The target leans on
  `foreign-procedure`, `foreign-callable`, `load-shared-object`, `lock-object`,
  ftypes, guardians. The spike must show a `compile-whole-program` build still
  loads `libAPIAnywareChez.dylib` + `libobjc.dylib` at runtime and that
  `foreign-callable`/`lock-object` behave under the embedded kernel.
- **TCC / codesigning.** A native standalone binary is signed directly and
  already has a unique CDHash, so the unique-CDHash-per-app rationale carries over
  for free — but confirm the `com.linkuistics.*` bundle-id + persistent
  local-signing-identity story (`bundle.rs` `LOCAL_SIGNING_IDENTITY`) still grants
  TCC, and that an embedded-boot binary inside `.app/Contents/MacOS/` signs
  acceptably.

## Notes
- Sequenced **before** `070-rewrite-adding-language-target.md` (reordered
  2026-05-29 at the user's request): the doc's bundler/distribution section must
  describe the *final* distribution model, not the soon-stale exec-system-chez
  one. The doc rewrite waits on this node's outcome.
- This may obsolete several deferred follow-ups at once: leaf-160 version
  coupling (no system chez → no version mismatch), the menu-bar-name gotcha
  (chez.md 🟢 2026-05-26), and the golden-image Chez pre-install note (050
  brief) — all evaporate for a standalone binary. `020` records that in the spec.
- Regenerate/rebuild aggressively after pipeline changes
  ([[feedback-regenerate-pipeline-aggressively]]); idiom posture still applies
  ([[feedback-chez-target-idiomatic-not-portable]]).
</content>
</invoke>
