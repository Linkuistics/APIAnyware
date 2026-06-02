# 040-regenerate-and-vm-verify — brief

## Goal
Regenerate the full chez pipeline against the self-contained `APIAnywareChez`
(post de-Common, post thread-safety) and **VM-verify every chez sample app
visually via TestAnyware** — the grove's done-bar (root BRIEF).

## Decomposition
Split into the mechanical half and the visual half (this leaf was too big for one
focused session — regenerate + rebuild dylib + bundle 7 apps + VM-verify 7 apps):
- **010-regenerate-build-bundle** — re-emit framework libs, rebuild the
  self-contained dylib, bundle all 7 standalone `.app`s, CLI-sanity each.
- **020-vm-verify-sample-apps** — VM-verify every app visually via TestAnyware to
  the "visually perfect" bar; fix regressions; grow per-app leaves lazily.

## Context
- Standing project rules: regenerate the pipeline aggressively after any
  collection/analysis/generation change; VM-verify every sample app (CLI smoke
  does **not** satisfy this); `SDKROOT=macosx` workaround.
- Comes after 020 (de-Common) and 030 (thread safety) so it verifies the final
  shape. Design: `docs/specs/2026-06-02-chez-native-binding-design.md` §6.

## Done when
- Full chez pipeline regenerates clean (`SDKROOT=macosx`); build green; the
  standalone `.app` bundles link against the self-contained `libAPIAnywareChez.dylib`.
- **Every chez sample app VM-verifies visually via TestAnyware** — launched in a
  macOS VM, observed window/interaction correct (per `feedback_vm_verify_every_app`
  + `feedback_sample_apps_perfect`: double-click, edit, empty state all matter).
- Any visual regressions fixed; re-verified.

## Notes
- This is the last live leaf; when it retires, the grove is ready to **Finish**
  (promote → delete `.grove/` → merge → inbox cleanup → remove worktree → delete
  branch). Confirm with the user before teardown.
- VM provisioning + launch recipe: `reference_testanyware_cli` memory.
