# 020-decide-spec-and-grow

**Kind:** planning

## Goal
With the spike's evidence in hand (`010`), make the deferred decisions, write the
durable design record, and **grow the implementation tree** for the chosen path.
This leaf turns proven mechanics into committed work.

## Context
- Runs **only after** `010` returns a go (or a documented refutation). Read the
  spike report, the node `BRIEF.md` (D1–D5), the design spec
  `docs/specs/2026-05-27-chez-target-design.md`, and `knowledge/targets/chez.md`.
- This is where the original requirement 2 (BRIEF) lands: the **toolchain docs**
  are a first-class deliverable.

## Done when
- **D4 decided on the numbers.** Using the spike's three-way cold-launch/size
  table, decide whether chez bundles go standalone-only (retiring the source-exec
  path + `launch.ss`/precompile/version-coupling) or keep source-exec. Record the
  decision and its rationale; if it's durable + surprising + a real trade-off,
  raise an ADR.
- **Design record written.** A new spec section (or new spec) captures: the
  chosen build pipeline, the `AppSpec` build-mode enum (D5), open/closed bundle
  layouts, the two dispatch backends (D2), what the standalone path **obsoletes**
  (leaf-160 version coupling, the menu-bar-name gotcha, golden-image Chez
  pre-install), and the spike's measurements.
- **ADRs raised** where warranted — candidates: standalone build modes
  (open/closed as a per-app dimension); the D2 requirement-1 amendment +
  two-dispatch-backend split. Only if hard-to-reverse + surprising + a real
  trade-off (grilling.md bar).
- **Work leaves grown** (lazily — only what the spike's reality justifies),
  likely including:
  - the `bundle-chez` `StandaloneOpen` builder mode (`standalone.rs`, D5);
  - the `bundle-chez` `StandaloneClosed` builder mode;
  - the **closed-world eval-free dispatch backend** (trampolines enumerated from
    static usage — D2's real engineering content; likely its own sub-node, proven
    against a delegate-using app);
  - the **toolchain docs** (original requirement 2): required Chez artifacts,
    where they come from, exact build steps, dev-repro recipe;
  - a per-app **VM-verify** leaf — launch in a VM with Chez uninstalled
    ([[feedback-use-testanyware]]);
  - retirement leaves for whatever D4 obsoletes.

## Notes
- Do not pre-grow these before the spike — that is the runaway-tree anti-pattern
  (driving.md). Grow them here, once `010`'s evidence is real.
- If `010` refuted native, this leaf instead specs the bundle-the-runtime-tree
  fallback (ship `scheme`/`petite` + boot inside the `.app`, stub execs the
  bundled binary) with its size/launch trade-offs, and grows that tree instead.
- Feeds `070-rewrite-adding-language-target.md`: its distribution section must
  describe the model this leaf settles.
</content>
