# app-kinds-k34 — brief

**Kind:** node (ws4 child 2)

## Goal

Realize the macOS **app-kinds** model (node-brief decision D2) — a **distinct
entity** with its own authored `.apiw` registry. Build the new
`platforms/macos/tools/app-kinds` crate (parse + KDL-Schema + controlled vocab +
focused validator, *mirroring* the `apianyware-patterns` mechanism), author the seven
`kind.apiw` definitions + per-kind `docs/`, raise the app-kind-model ADR, and discharge
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
- **Mirror child 1's pattern exactly** (`platform-manifest-k33`, retired) and the
  `apianyware-patterns` registry: the authoritative KDL-Schema is
  `schemas/spec-format/app-kind.kdl-schema` (sibling of `platform.kdl-schema` /
  `pattern-kinds.kdl-schema`); the crate's `schema.rs` embeds it via `include_str!` and
  delegates to `apianyware_spec_format::validate_against_schema`; `kind.rs`/`apiw.rs`
  carry the typed parse + the semantic checks the generic schema can't state; a
  `registry.rs` loads a directory of authored kinds; a `tests/` guard loads + validates
  every committed `kind.apiw`.
- **App-kind controlled vocab is *flat* enums** (entry / run-loop / termination /
  activation / bundle-type), unlike a pattern law's category-conditional token set — so
  they live directly as serde enums in `kind.rs` *and* as `enum` constraints in the
  schema (exactly like the manifest's `DiscoverSource`); the focused validator handles
  only the cross-field semantics the schema can't state. No separate `vocab.rs` side
  table is warranted.
- **ws8 seam:** author the `.apiw` KDL-Schema + focused in-crate validator only; the
  machine-JSON schema + CI validation tooling stay ws8 (mirrors ws3 D7).
- **Ground the vocabulary in source/§14:** REFACTOR §14's per-kind `docs/` sketch
  (lifecycle / bundle-structure / status-items / lsui-element / launchd /
  extension-bundles / test-obligations) and the real bundle/Info.plist shapes the
  bundlers emit (`targets/_shared/tools/stub-launcher`, `targets/*/tools/bundle-*`:
  `CFBundlePackageType=APPL`, `LSUIElement`, `NSPrincipalClass`, `LSMinimumSystemVersion`,
  `NSExtensionPointIdentifier`, …) — but keep the **kind** definition projection-free (the
  bundler is a *target* consumer, not part of the platform truth).

## Done when (node done-bar — across children)

- `platforms/macos/tools/app-kinds` crate exists (parse + schema + vocab + validator +
  registry), workspace member, builds + tests green.
- `schemas/spec-format/app-kind.kdl-schema` authored (authoritative contract).
- Seven `app-kinds/<kind>/kind.apiw` authored + per-kind `docs/`, each loading +
  validating under a standing test guard.
- The app-kind-model ADR raised (parallel to ADR-0048).
- `platforms/macos/app-kinds/README.md` discharged (TODO removed; prose updated).
- Existing test sweep green; no emit-golden movement (app-kinds have no consumer yet —
  ws6/ws7 consume them later).

## Decomposition (skeleton-first; children grow lazily)

1. **mechanism** *(`mechanism-k35`, this session)* — the new crate (parse + schema embed
   + typed enums + registry + focused validator + standing test guard),
   `schemas/spec-format/app-kind.kdl-schema`, **one exemplar kind end-to-end**
   (`gui-app` — the richest: bundle + Info.plist + principal class + activation + run
   loop, the best grammar proof) with its `docs/`, and the **app-kind-model ADR**
   (parallel to ADR-0048). Establishes + de-risks the `kind.apiw` grammar the remaining
   six kinds mechanically follow. Workspace member; builds + tests green.
2. **remaining-kinds** *(grows after child 1 retires)* — author the other six kinds
   (`cli-tool`, `menu-bar-daemon`, `launch-agent`, `spotlight-importer`,
   `quicklook-extension`, `finder-sync-extension`) + their per-kind `docs/`; extend the
   test guard to all seven; discharge `platforms/macos/app-kinds/README.md`.

## Notes (steers)

- Keep `kind.apiw` minimal and **projection-free** — describe the platform process model,
  not how any target builds it (that is ws6).
- After this node retires, grow child 3 (**platform-tests**), then child 4
  (**platform-docs**) — node-brief D5. After child 4 retires, the retire-cascade asks
  before treating **workstream 4** done; then **ws5** grows next (root-brief decomposition).
