# 040-retire-source-exec

**Kind:** work

## Goal
Make the open-world standalone path the **only** chez bundle path. Delete the
source-exec machinery and the system-Chez dependency it carried, now that `030`
has a green standalone build.

## Context
- Runs **after** `030` is green (never without a green path — spec §6).
- D6 / ADR-0009: source-exec is retired entirely; single mode; no build-mode enum.
- The deletions and the obsoleted follow-ups are enumerated in the design spec
  `docs/specs/2026-05-29-chez-standalone-distribution-design.md` §6–§7.

## Done when
- **Deleted from `bundle-chez`:** `launch.rs` (the `launch.ss` bootstrap),
  `precompile.rs` (the precompile pass), the Chez-version coupling, and the
  `DEFAULT_CHEZ_PATH` constant.
- **`AppSpec` trimmed:** `runtime_path` and `skip_precompile` fields removed;
  `from_script_name` updated; doctests/examples in `lib.rs` updated to the
  standalone surface.
- **Stub-launcher execv-into-system-chez path for chez removed.** Racket's
  stub-launcher path is **untouched** (shared crate — verify racket still bundles
  & runs).
- All `bundle-chez` tests green against the standalone-only surface; no dangling
  references to the deleted symbols across the workspace.
- **Obsoleted follow-ups recorded as closed** (spec §7): leaf-160 Chez-version
  coupling, the menu-bar-name `execv` gotcha (chez.md 🟢 2026-05-26), the
  golden-image Chez pre-install note (050 brief). Update `knowledge/targets/chez.md`
  to strike the now-moot entries.

## Notes
- This is a satisfying-cleanup leaf: mostly deletion + reference-chasing. Keep the
  commit focused on removal; behavioural change already landed in `030`.
- If any sample app still imports source-exec-only helpers, that surfaces in `050`
  — note it forward rather than patching apps here.
</content>
