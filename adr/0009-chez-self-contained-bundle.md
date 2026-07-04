# Chez apps bundle as self-contained binaries; source-exec retired, single mode

A chez sample app is distributed as a `.app` whose `Contents/MacOS/<App>`
binary **embeds the Chez kernel and a whole-program boot image**. It has no
runtime dependency on a system Chez install: the prior model — a Swift stub that
`execv`s `/opt/homebrew/bin/chez --script` over a tree of precompiled `.so`
libraries — is **retired**, and with it `launch.ss`, the precompile pass, the
Chez-version coupling, and `DEFAULT_CHEZ_PATH`.

The self-contained binary is built **open-world** (full `scheme` boot embedded:
the runtime compiler, `eval`, and `load` are present), which is the **single
chez bundle shape**. A second, **closed-world** mode (`compile-whole-program`
sealed against a `petite`-only boot) was proven by the spike but **not adopted**.

Evidence: `targets/chez/docs/research/2026-05-29-chez-standalone-spike.md`. Design:
`targets/chez/docs/design/2026-05-29-chez-standalone-distribution-design.md`.

## Considered options

- **Keep source-exec (the prior model).** Rejected on the spike numbers:
  104 MB / ~13.9 s cold launch vs. 4.5 MB / ~0.29 s for the standalone (~30×
  smaller, ~50× faster), *and* it keeps the system-Chez dependency that the
  self-contained-runtime bundle exists to remove. Dev iteration does not
  need a bundle — the unbundled `chez --libdirs <tree> --script <entry>` run
  serves that on a dev machine (which has Chez), so retiring the source-exec
  *bundle* path costs the dev loop nothing.
- **Ship both open-world and closed-world as a per-app build mode** (node
  decisions D2/D3/D5). Rejected on the numbers: closed-world's gain over
  open-world is only ~1 MB / ~60 ms, but closed-world for any *dispatch-using*
  app is **physically impossible** without a separate, eval-free dispatch backend
  — a `petite`-boot sealed program cannot compile the `foreign-callable` forms
  that `dispatch.sls` synthesises at runtime (spike F1: "cannot compile
  foreign-callable: compiler is not loaded"). Building that backend (static
  trampoline enumeration, proven against a delegate app) is a large project for a
  marginal size/launch gain. Not worth it.
- **Open-world standalone, single mode (chosen).** Full self-containment at
  4.5 MB / 0.29 s for every app, with no new dispatch engineering: the existing
  `eval`-synthesised `dispatch.sls` substrate remains the sole dispatch backend,
  and requirement 1 (runtime dynamic Scheme load) is satisfied universally and
  for free because the boot embeds the compiler.

## Consequences

- **Requirement 1 reverts to universal.** Node decision D2 had amended the
  user's "dynamic Scheme load at runtime" requirement into a per-mode capability.
  With closed-world dropped, that amendment is void — every chez app can `eval`
  and `load` at runtime, as originally asked.
- **No `AppSpec` build-mode enum.** With one shape and source-exec gone, the
  three-variant enum proposed in D5 (`SourceExec | StandaloneOpen |
  StandaloneClosed`) does not exist; `skip_precompile` and `runtime_path` are
  removed. If closed-world ever earns its place, it is re-introduced as a variant
  then — consistent with ADR-0004's "register/extend lazily" hatch.
- **Build-time cost moves up-front.** `compile-whole-program` is ~160 s /
  ~1.6 GB peak RSS per app, paid at bundle time (was: paid as a one-time
  precompile, or amortised at launch). This is a bundler/CI cost, not a user-
  facing one; the shipped launch is ~50× faster.
- **Several deferred follow-ups evaporate** (recorded in the design spec §7):
  the Chez-version-coupling follow-up, the menu-bar-name `execv` gotcha, and the
  golden-image Chez pre-install note — all presupposed a system Chez that no
  longer exists in the shipped artifact.
- **Hard to reverse in one direction, easy in the other.** Deleting
  `launch.rs`/`precompile.rs` and the version-coupling machinery is a real
  removal; resurrecting source-exec would mean rebuilding it. But *adding*
  closed-world later is additive (a new boot recipe + the eval-free backend), so
  the single-mode choice does not foreclose it.
- **Glossary impact.** `Closed-world build` is marked *(retired)* in
  `CONTEXT.md`; `Open-world build` becomes the description of the sole chez
  standalone shape rather than one pole of a contrast.
- **Racket is untouched.** Racket's stub-launcher distribution path is shared
  crate surface and explicitly out of scope; only the chez bundler changes.
</content>
