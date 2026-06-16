# 030-smoke-verify

**Kind:** work

## Goal

Prove the trampoline mechanism works on **real** macOS Swift-native API, not just
synthetic fixtures — the leaf-level "resolves and runs" done-bar. Full rerun +
VM-verify across all sample apps is 050; this is the focused end-to-end proof.

## Scope

- From the **actual recovered residual** (regenerate enriched IR; grep for
  `objc_exposed: false` top-level funcs/constants), pick:
  - at least **one real Swift-native function** whose signature the 020 taxonomy
    handles (prefer a scalar or String/Foundation-bridged one), and
  - at least **one real pointer-valued Swift constant**.
- Generate → `swift build` → load the generated `.rkt` from racket and **call
  them**, confirming the function returns the right value and the constant
  resolves to a live address through `libAPIAnywareRacket`.
- Record which symbols were used (so 050 / future targets have a known-good
  exemplar).

## Done when

- Whole build green (`cargo test --workspace` + `swift build`).
- A short, repeatable racket smoke (script or test) calls the chosen real
  function and reads the chosen real constant via the trampoline and passes.
- The chosen symbols + the smoke recipe are noted (promote into the spec or a
  target doc on node retirement).

## Notes

- CLI smoke only here; the project done-bar's VM-verify lands in 050
  (`feedback-vm-verify-every-app`).
- If a "real" symbol exposes a taxonomy gap, kick back to 020 (or update spec §3),
  don't paper over it.
