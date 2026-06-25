# app-kinds-k34

**Kind:** work

## Goal

ws4 **child 2**: realize the macOS **app-kinds** model (node-brief decision D2) — a
**distinct entity** with its own authored `.apiw` registry. Build the new
`platforms/macos/tools/app-kinds` crate (parse + KDL-Schema + controlled vocab +
focused validator, *mirroring* the `apianyware-patterns` mechanism), author the seven
`kind.apiw` definitions + per-kind `docs/`, and discharge
`platforms/macos/app-kinds/README.md`.

## Context (inherited — see `grove-llm brief-chain`)

- **D2 (node brief):** an app-kind is **macOS process-model truth** — entry/run-loop/
  termination model, bundle type + required Info.plist keys + `LSUIElement`/
  extension-point identifiers, test-obligation references. **Zero projection.** Distinct
  from a pattern-kind (ws3, `semantic/`, an *API-usage* axis) and from a ws7 app-spec
  (`apps/macos/<app>/`, one concrete app that *names* its kind). Lives in `platforms/`
  (domain rule); folding into `apianyware-patterns` would be a domain violation.
- **The seven kinds** (already enumerated in `app-kinds/README.md`): `cli-tool`,
  `gui-app`, `menu-bar-daemon`, `launch-agent`, `spotlight-importer`,
  `quicklook-extension`, `finder-sync-extension`. Each is one directory
  `app-kinds/<kind>/{kind.apiw, docs/}` (REFACTOR §14).
- **Mirror child 1's pattern exactly** (`platform-manifest-k33`, now retired): the
  authoritative KDL-Schema is `schemas/spec-format/app-kind.kdl-schema` (sibling of
  `platform.kdl-schema` / `pattern-kinds.kdl-schema`); the crate's `schema.rs` embeds it
  via `include_str!` and delegates to `apianyware_spec_format::validate_against_schema`;
  `apiw.rs`/`kind.rs` carry the typed parse + the semantic checks the generic schema
  can't state; a `tests/` guard loads + validates every committed `kind.apiw`.
- **Candidate ADR (raise it here):** the **app-kind model** — a small ADR parallel to
  ADR-0048 (pattern-kind model), documenting the distinct-entity decision, the
  process-model vocabulary, and the platforms-domain crate home. It clears the
  grilling bar (hard-to-reverse: a crate + schema + 7 authored files; surprising: "why
  not reuse pattern-kinds?"; real trade-off: reuse vs domain-purity).
- **ws8 seam:** author the `.apiw` KDL-Schema + focused in-crate validator only; the
  machine-JSON schema + CI validation tooling stay ws8 (mirrors ws3 D7).
- **Ground the vocabulary in source/§14:** before inventing the `kind.apiw` grammar,
  read REFACTOR §14's per-kind `docs/` sketch (lifecycle / bundle-structure /
  status-items / lsui-element / launchd / extension-bundles / test-obligations) and the
  existing bundlers (`targets/*/tools/bundle-*`) for the real bundle/Info.plist shapes
  the kinds describe — but keep the **kind** definition projection-free (the bundler is a
  *target* consumer, not part of the platform truth).

## Done when

- `platforms/macos/tools/app-kinds` crate exists (parse + schema + vocab + validator),
  workspace member, builds + tests green.
- `schemas/spec-format/app-kind.kdl-schema` authored (authoritative contract).
- Seven `app-kinds/<kind>/kind.apiw` authored + per-kind `docs/`, each loading +
  validating under a standing test guard.
- The app-kind-model ADR raised (parallel to ADR-0048).
- `platforms/macos/app-kinds/README.md` discharged (TODO removed; prose updated).
- Existing test sweep green; no emit-golden movement (app-kinds have no consumer yet —
  ws6/ws7 consume them later).

## Notes (steers)

- **This may itself be node-sized.** If the crate + schema + seven kinds + ADR proves
  bigger than one focused, low-context session, `leaf-decompose` it (e.g. first child =
  crate + schema + one exemplar kind; later children = the remaining kinds + ADR) and do
  only the first child. Judge at pick time.
- Keep `kind.apiw` minimal and **projection-free** — describe the platform process model,
  not how any target builds it (that is ws6).
- After this child retires, grow child 3 (**platform-tests**), then child 4
  (**platform-docs**) — node-brief D5. After child 4 retires, the retire-cascade asks
  before treating **workstream 4** done; then **ws5** grows next (root-brief decomposition).
