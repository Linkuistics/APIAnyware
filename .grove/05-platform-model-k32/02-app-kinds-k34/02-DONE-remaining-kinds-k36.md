# remaining-kinds-k36

**Kind:** work

## Goal

ws4 child 2, **second sub-child**: author the **other six** app-kinds against the
grammar `mechanism-k35` proved, extend the standing test guard to all seven, and
discharge `platforms/macos/app-kinds/README.md`. This completes the app-kinds node
(`app-kinds-k34`).

## Context (inherited — see `grove-llm brief-chain`; node BRIEF + ADR-0049 carry the model)

- **The grammar is settled and proven** (`mechanism-k35`): `app-kind "<name>" { doc?
  process{entry run-loop termination} activation bundle{…} test-obligation* }`,
  contract `schemas/spec-format/app-kind.kdl-schema`, reader `apianyware-app-kinds`
  (`platforms/macos/tools/app-kinds`). The `gui-app` exemplar
  (`app-kinds/gui-app/{kind.apiw, docs/}`) is the template — mirror its shape +
  prose register. **No crate/schema changes should be needed**; if a kind needs a
  vocabulary the enums lack, that is a real design beat — extend the enum **and** the
  schema **and** `CONTEXT.md` together, and say so in the commit.
- **Controlled enums** (from `kind.rs` / the schema): entry ∈ {`c-main`,
  `ns-application-main`, `host-loaded`}; run-loop ∈ {`none`, `ns-application`,
  `cf-run-loop`, `host-driven`}; termination ∈ {`return`, `ns-application-terminate`,
  `signal`, `host-controlled`}; activation ∈ {`regular`, `accessory`=`LSUIElement`,
  `background`=`LSBackgroundOnly`, `hosted`}; bundle ∈ {`none`, `app`, `mdimporter`,
  `appex`}. Semantic rules the validator enforces: `bundle "none"` carries no
  metadata; `extension-point` ⟹ `mdimporter`/`appex`; require/obligation uniqueness;
  name = containing directory.
- **The six kinds** (proposed process models — confirm against source while
  authoring; each is platform truth, projection-free):
  | kind | entry | run-loop | termination | activation | bundle | notes |
  |---|---|---|---|---|---|---|
  | `cli-tool` | c-main | none | return | background | none | bare Mach-O; no Info.plist |
  | `menu-bar-daemon` | ns-application-main | ns-application | ns-application-terminate | accessory | app | `NSPrincipalClass`; `LSUIElement`=true; status item |
  | `launch-agent` | c-main | cf-run-loop | signal | background | none | launchd-managed; `LSBackgroundOnly`; the agent **plist** lives with the app-spec, not the kind |
  | `spotlight-importer` | host-loaded | host-driven | host-controlled | hosted | mdimporter | `extension-point` + importer principal-class key — **decide mdimporter (legacy CFPlugIn) vs appex (`com.apple.spotlight.import`)** while authoring; the §14 docs name (`importer-bundles`) leans `.mdimporter` |
  | `quicklook-extension` | host-loaded | host-driven | host-controlled | hosted | appex | `extension-point` = `com.apple.quicklook.thumbnail` / `com.apple.quicklook.preview` |
  | `finder-sync-extension` | host-loaded | host-driven | host-controlled | hosted | appex | `extension-point` = `com.apple.FinderSync` |
- **Per-kind `docs/` (§14 sketch — author these exact files):**
  - `cli-tool/docs/`: `lifecycle.md`, `test-obligations.md`
  - `menu-bar-daemon/docs/`: `status-items.md`, `lsui-element.md`, `test-obligations.md`
  - `launch-agent/docs/`: `launchd.md`, `lifecycle.md`, `test-obligations.md`
  - `spotlight-importer/docs/`: `importer-bundles.md`, `indexing-tests.md`, `host-process-constraints.md`
  - `quicklook-extension/docs/`: `extension-bundles.md`, `test-obligations.md`
  - `finder-sync-extension/docs/`: `extension-bundles.md`, `test-obligations.md`
- **Ground in real shapes:** the bundlers (`targets/_shared/tools/stub-launcher`,
  `targets/*/tools/bundle-*`) for Info.plist keys; Apple's launchd / extension /
  Spotlight conventions for the hosted kinds. Keep every kind projection-free.

## Done when

- Six `app-kinds/<kind>/kind.apiw` authored (the kinds above) + their per-kind `docs/`.
- The `tests/kind_registry.rs` guard extended to assert **all seven** kinds present
  (with an exact count, like the patterns `all_brief_kinds_present` guard) and each
  well-formed; tests green.
- `platforms/macos/app-kinds/README.md` discharged (TODO removed; prose reflects the
  realized model + the seven authored kinds).
- `cargo check --workspace`, clippy, fmt all green; no emit-golden movement.

## Notes

- This is the node's **last child**. After it retires, the retire-cascade asks before
  treating **app-kinds-k34** done; promote anything durable from the node brief upward
  (most already landed in ADR-0049 + `CONTEXT.md`). Then ws4 grows child 3
  (**platform-tests**, node-brief D3) — whose `tests/app-kinds/<kind>.apiw` bodies
  resolve the `test-obligation` refs these kinds declare.
- If authoring all six + 14 docs proves too big for one focused session,
  `leaf-decompose` (e.g. first child = the three standalone kinds; second = the three
  hosted extensions) and do only the first.
