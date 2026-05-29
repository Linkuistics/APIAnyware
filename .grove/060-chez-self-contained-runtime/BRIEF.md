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
*Amended by D6: no enum — single mode.*

**D6 — Closed-world dropped; source-exec retired; single open-world standalone
mode (2026-05-29, user steer on the spike numbers).** With the spike returning
GO, the user decided: (a) **retire source-exec entirely** — standalone-only
distribution, no system-Chez dependency; (b) **drop closed-world** — open-world
already delivers full self-containment (4.5 MB / 0.29 s), closed-world's ~1 MB /
~60 ms gain does not justify building the eval-free dispatch backend its
dispatch-using apps would require (spike F1). This **supersedes D2/D3** (no
two-dispatch-backend split; the `eval`-synthesised `dispatch.sls` is the sole
backend; requirement 1 reverts to universal) and **amends D5** (no `AppSpec`
build-mode enum — one bundle shape). Durable record: **ADR-0009** +
`docs/specs/2026-05-29-chez-standalone-distribution-design.md`. This is the
planning output of `020`.

## Children
- **`010-spike-dual-mode-standalone.md`** (work/spike) — *done.* The gate (D1).
  Returned **GO**: native standalone proven for `hello-window` in both modes,
  launches in a no-Chez VM. Report: `docs/research/2026-05-29-chez-standalone-spike.md`.
- **`020-decide-spec-and-grow.md`** (planning) — *this leaf.* Read the numbers,
  made the calls (D6: source-exec retired, closed-world dropped, single
  open-world mode). Wrote ADR-0009 +
  `docs/specs/2026-05-29-chez-standalone-distribution-design.md`, updated the
  glossary, and grew the implementation leaves below.

Grown by `020` (open-world single-mode tree — the closed-world / eval-free
dispatch children the original brief anticipated are **not** built, per D6):

- **`030-standalone-build-pipeline.md`** (work) — productionise the spike into
  `bundle-chez/standalone.rs`: whole-program compile → boot → cc-link → assemble
  + sign, the top-level-program wrapper (spike F2), the dylib-search prelude (F3),
  the `Resources/` boot+dylib layout (F4), banner suppression (F6).
  `hello-window` builds & launches as a self-contained `.app` via `bundle_app`.
  Source-exec stays in place (green path).
- **`040-retire-source-exec.md`** (work) — delete `launch.rs`/`precompile.rs`,
  `launch.ss`, the version-coupling, `DEFAULT_CHEZ_PATH`, and the
  `skip_precompile`/`runtime_path` `AppSpec` fields; record the obsoleted
  follow-ups (leaf-160, menu-bar gotcha, golden-image note).
- **`050-standalone-app-portfolio.md`** (work) — convert all 7 sample apps to
  standalone and VM-verify each in a no-Chez VM ([[feedback-use-testanyware]],
  [[feedback-vm-verify-every-app]]); the parity bar from the grove-root brief.
  May decompose into per-app leaves when picked.
- **`060-standalone-toolchain-docs.md`** (work) — original requirement 2: the
  required Chez kernel artifacts, where they come from, the exact build pipeline,
  the dev-repro recipe. Feeds `070-rewrite-adding-language-target`.

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
