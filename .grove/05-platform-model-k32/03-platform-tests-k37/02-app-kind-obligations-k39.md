# app-kind-obligations-k39

**Kind:** work (platform-tests child 2 — the remaining six kinds)

## Goal

Author `tests/app-kinds/<kind>.apiw` for the **six non-gui-app kinds**, resolving
every `test-obligation` ref each kind declares into an obligation body of
projection-free `expect`ations. The grammar + crate + guard already exist
(`test-mechanism-k38`); this is **pure content** — the standing guard's
`every_obligation_file_resolves_its_kind_refs` covers each new file automatically.

## Context (see `grove-llm brief-chain`; node BRIEF + ADR-0049 ws9 seam)

- **The mechanism is built.** `apianyware-platform-tests` validates
  `tests/app-kinds/<kind>.apiw` against `app-kind-tests.kdl-schema`; the
  `fixture "<rel-path>"` grammar branch already exists (child 1 added + unit-tested
  it) for the importer/preview kinds, so no schema work is needed unless a new shape
  surfaces.
- **The obligation refs to resolve** (each kind's `kind.apiw` `test-obligation`
  lines; bodies = each kind's `docs/test-obligations.md` / `indexing-tests.md` prose,
  the written source):

  | kind | obligation refs |
  |---|---|
  | `cli-tool` | `lifecycle` |
  | `menu-bar-daemon` | `lifecycle`, `accessory-activation`, `status-item` |
  | `launch-agent` | `lifecycle`, `background-activation` |
  | `spotlight-importer` | `importer-bundle`, `indexing` |
  | `quicklook-extension` | `extension-bundle`, `preview` |
  | `finder-sync-extension` | `extension-bundle`, `sync-badging` |

  (`gui-app` — `lifecycle`, `bundle-structure` — done as the child-1 exemplar.)
- **Each kind's `lifecycle` body differs** (a cli-tool's lifecycle ≠ a gui-app's) —
  author each from that kind's own process model + prose, do not copy gui-app's.
- **Fixture-reading obligations** (`indexing`, `preview`, `sync-badging`) reference
  fixtures via `fixture "fixtures/.../…"` — the fixture **files** are populated in
  child 4, so reference the intended paths now (existence-checking activates in
  child 4). Keep refs minimal + representative.

## Done when

- All six `<kind>.apiw` authored; the guard's cross-resolution (declared bodies ==
  kind refs) passes for **all seven** kinds.
- `cargo test -p apianyware-platform-tests`, clippy, fmt green; no emit-golden
  movement; declarations not executed.

## Notes

- Projection-free + target-independent throughout (`expect` prose says what must
  hold, never how a target satisfies it or how it is run).
- After this retires, grow child 3 (**api-semantics** — the sibling
  `api-semantics.kdl-schema` + `src/api_semantics/` submodule + the four
  `tests/api-semantics/*.apiw` + §30 weirdness vocab), then child 4 (fixtures +
  `tests/README.md` discharge).
