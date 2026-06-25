# platform-manifest-k33

**Kind:** work

## Goal

ws4 **child 1**: author the macOS **platform manifest** — the single authored,
policy-only `platforms/macos/platform.apiw` (node-brief decision D1) — plus its `.apiw`
KDL-Schema and a focused validator that keeps it green. Discharge the two top-of-tree
placeholder READMEs (`platforms/README.md`, `platforms/macos/README.md`). Smallest,
most foundational ws4 child; it sets the authored-`.apiw` + focused-validator pattern
that child 2 (app-kinds) mirrors.

## Context (inherited — see `grove-llm brief-chain`)

- **D1 (node brief):** the manifest is **authored policy only**, KDL (`.apiw`, *not*
  `platform.yaml` — ADR-0046 killed YAML). It carries `sdk`, the `deployment-target`
  floor, and the framework roster as a curated **include/ignore policy**. The resolved
  roster (`ls api/`) and the cross-family dependency graph are **derived, uncommitted**.
- **Grounded in source** (read these, don't reinvent):
  - Ignore-list: `IGNORED_FRAMEWORKS = ["DriverKit", "Tk"]` in
    `platforms/macos/tools/extract-objc/src/sdk.rs:75` — DriverKit = C++ headers (libclang
    fails); Tk = Tcl/Tk, not a native macOS framework. Carry **these exact entries +
    reasons** into the manifest.
  - Include policy is **discovery**, not a list: `discover_frameworks` scans
    `{SDK}/System/Library/Frameworks/` for umbrella-header frameworks; plus the
    `SUBFRAMEWORK_ALLOWLIST = ["ApplicationServices"]`
    (`extract_declarations.rs:1292`) and the synthetic pseudo-frameworks
    (`extract-objc/synthetic-frameworks/`, the libdispatch/etc. pattern). State this as
    *policy*; do **not** enumerate the 153 families.
  - Floors: **`macos14.0`** is the source-availability floor (digester target,
    `extract-swift/src/digester.rs:121`) → this is the manifest's `deployment-target`.
    The adapter `.macOS(.v26)` floor (`targets/*/adapters/macos/Package.swift`) is a
    **target build** concern (ws6) — **not** in the platform manifest (domain rule).
  - SDK *version* (e.g. 15.4) is discovered at extraction (`sdk.rs:discover_sdk`) →
    **derived**, not authored. Author only the SDK *name* (`macosx`).
- **Format machinery to reuse:** the `.apiw` KDL parse + KDL-Schema + focused-validator
  pattern already exists for pattern-kinds (`semantic/tools/patterns` +
  `schemas/spec-format/pattern-kinds.kdl-schema`) and for ws2's
  `annotations.kdl-schema`. Follow that shape for `platform.apiw`.
- **ws8 seam:** author the `.apiw` KDL-Schema + a focused in-repo validator only; the
  machine-JSON schema + CI validation tooling stay ws8 (mirrors ws3 D7).

## Done when

- `platforms/macos/platform.apiw` exists — authored, policy-only, KDL — carrying `sdk`,
  `deployment-target` (14.0, the availability floor), and the framework `include`
  (discovery policy) / `ignore` (DriverKit, Tk + reasons) policy. No derived roster, no
  dep-graph, no per-family facts, **no projection**.
- A `platform.apiw` **KDL-Schema** (under `schemas/`, beside the existing spec-format
  schemas) + a **focused validator** that parses `platform.apiw` and asserts it conforms
  — runnable in the test sweep (goldens-green; the validator is the regression guard).
- `platforms/README.md` and `platforms/macos/README.md` **discharged** — the `TODO
  (workstream 4)` manifest markers removed, prose updated to describe the now-real
  `platform.apiw`.
- Workspace builds; the existing test sweep stays green (no emit-golden movement — the
  manifest has no consumer yet).

## Notes (steers)

- **Where does the validator live?** Prefer the lightest home that keeps it green: a
  test/module beside the spec-format schema tooling, or a tiny crate under
  `platforms/macos/tools/` if a crate is genuinely warranted (crate-home convention).
  Don't over-build — there is no runtime consumer of the manifest in ws4 (ws6 reads the
  floor later). Match the patterns-registry validator's weight, not more.
- **Doubt pass (driving.md):** the manifest grammar is mildly hard-to-reverse (children
  + ws6 read it). Before it stands, sanity-check the KDL shape against the pattern-kind
  `.apiw` conventions so the authored vocabulary is consistent across the repo.
- Keep `platform.apiw` **minimal** — the k26 "annotate the canonical API, don't
  over-engineer" steer applies: author policy, not derivable data.
