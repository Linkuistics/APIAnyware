# fixtures-readme-k41

**Kind:** work (platform-tests child 4 — the **last** child; pure content + README, no new mechanism)

## Goal

Populate the raw **fixtures** the committed app-kind obligations reference, and
**discharge `platforms/macos/tests/README.md`** (still a ws4 TODO). This is the final
platform-tests child (mechanism ✓, app-kind obligations ✓, api-semantics ✓,
**fixtures + README**). No new schema, crate, or submodule — minimal representative
inputs + prose only.

## Context (see `grove-llm brief-chain`; node BRIEF D3/D5 + ADR-0046)

- **Fixtures = the raw inputs an obligation reads** (node-brief D3/D5 child 4). The
  committed app-kind obligation bodies (`tests/app-kinds/<kind>.apiw`) declare
  `fixture` refs by path relative to `platforms/macos/tests/`. The genuinely-referenced
  set today (grep `fixture ` under `tests/app-kinds/`):

  | fixture path | referenced by |
  |---|---|
  | `fixtures/sample-documents/sample.txt` | `quicklook-extension`, `finder-sync-extension` |
  | `fixtures/spotlight/sample.txt` | `spotlight-importer` |

  The **api-semantics** declarations reference **no** fixtures (they are
  `(receiver, selector)` shapes, not fixture-reading obligations), so nothing new is
  owed there.
- **Minimal + representative, NOT a corpus** (D3 steer). Each fixture is the smallest
  input that makes its obligation meaningful (a tiny text document with known,
  assertable content for the importer/preview/sync cases). The node-brief D5 wider
  sketch `tests/fixtures/{pasteboard,spotlight,sample-documents,sample-images}/` is a
  *menu*, not a mandate: author a directory **only if a committed declaration references
  it** (lazy/constraint 4 — `pasteboard` and `sample-images` have **no** referrer today,
  so default to skipping them; revisit only if a future obligation cites them). The
  session decides; record the call.
- **Discharge `tests/README.md`** (the ws4 marker, TODO at line ~8). Prose reflects the
  realized declarations: the two declaration families (`app-kinds/` obligations +
  `api-semantics/` facets), the `fixtures/` inputs, and the **declare-now /
  execute-later** seam (ws4 authors + schema-validates; ws9 executes via the multi-layer
  test model + TestAnyware/AppSpec). Map the directory layout. This is child 4's to
  discharge (it was deferred from every earlier platform-tests child).
- **Schema-validated, not executed** (the standing done-bar): no runner, no VM, no
  TestAnyware under `platforms/`. A fixture is inert data.

## Done when

- Every committed `fixture` ref resolves to an existing, minimal, representative file
  (`fixtures/sample-documents/sample.txt`, `fixtures/spotlight/sample.txt` at minimum).
- `platforms/macos/tests/README.md` discharged (TODO removed; prose reflects the two
  families + fixtures + the declare-now/execute-later seam + the directory map).
- The fixture-set scope decision (which of the D5 `{pasteboard,…,sample-images}` dirs
  earn a file) is recorded in this leaf / the node running log.
- `cargo test -p apianyware-platform-tests`, clippy, fmt green; **nothing executed**
  (ws9); no emit-golden movement.

## Notes (steers)

- **Consider a fixture-existence guard.** The `app-kind-tests` schema comment already
  flags "a conforming guard may check existence once fixtures land." A small, optional
  addition to the standing `tests/` guard — every `fixture` ref in the obligation
  registry resolves to a real file under `tests/` — would make the declaration↔fixture
  link a standing invariant. Author it if cheap; it is a nice-to-have, not required.
- **Pure content + prose.** No grammar, schema, crate, or submodule changes — the
  mechanism is complete (children 1–3). If that proves wrong, decompose; otherwise one
  session.
- After this leaf retires, the platform-tests-k37 node has no live child → the
  retire-cascade **asks before treating it done**, promotes its brief upward, then asks
  again about **ws4 (`platform-model-k32`)**, which still owes its **child 4
  `platform-docs`** (node-brief D5: `docs/{overview,api-extraction,app-kinds,
  testing-obligations}.md` + discharge `docs/README.md` + finalize `api/README.md`).
  Grow `platform-docs` via `leaf-add` on `platform-model-k32`. Only after *that* retires
  does ws4 finish and **ws5** (LLM analysis side-channel) grow next (root-brief
  decomposition).

## Outcome (recorded)

- **Fixture-set scope (done-bar decision).** Authored exactly the two directories with a
  committed referrer: `fixtures/sample-documents/sample.txt` (quicklook `preview` +
  finder-sync `sync-badging`) and `fixtures/spotlight/sample.txt` (spotlight `indexing`).
  **Skipped** the D5 menu's `pasteboard/` and `sample-images/` — **no committed
  declaration references them** (lazy / constraint 4). Each fixture is a tiny text doc
  carrying known, assertable content (title/author/body token) so the ws9 runner can
  assert *extracted values match the fixture*, not merely that *a* value was produced.
- **Fixture-existence guard added** (the nice-to-have). New standing-guard test
  `every_fixture_ref_resolves` (in `app_kind_tests_registry.rs`): every committed
  `fixture` ref resolves to a real file under `platforms/macos/tests/`, with a `>= 3`
  floor against a silent regression to zero refs. The schema comment that anticipated it
  is left as-is (it documents the seam).
- **`tests/README.md` discharged** — TODO removed; prose maps the layout and covers both
  declaration families + `fixtures/` + the declare-now/execute-later seam.
- **No new mechanism.** Pure content + prose + one guard test; no schema, crate, grammar,
  or submodule change. `cargo test -p apianyware-platform-tests` (33 tests), clippy, fmt
  green; nothing executed; no emit-golden movement.
