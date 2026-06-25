# platforms/macos/tests/ — platform-level semantic test declarations

The **declaration half** of macOS platform-level semantic tests (REFACTOR.md
§14/§33): projection-free, target-independent statements of what a macOS API
semantic or app-kind obligation *must hold*. They are authored and
**schema-validated here but NOT executed** — this directory is platform truth, not
a test runner.

**Declare now, execute later.** Workstream 4 (this directory) authors and validates
the declarations + the raw fixtures they read. **Workstream 9** owns the *execution*
half — the multi-layer test model (§33) and the TestAnyware / AppSpec integration
(§34) that drives a declaration against a *running target binding* in a VM;
**workstream 6** owns the per-target execution hooks. A declaration says what the
**platform** semantic/obligation is — never how any target satisfies it (`targets/`,
ws6) and never how it is run (ws9). The mirror of the ws3→ws8 seam.

## Layout

```
tests/
├── api-semantics/        # family 1 — per-facet API-semantic expectations
│   ├── ownership.apiw
│   ├── callbacks.apiw
│   ├── threading.apiw
│   └── errors.apiw
├── app-kinds/            # family 2 — per-app-kind obligation bodies
│   ├── cli-tool.apiw
│   ├── gui-app.apiw
│   ├── menu-bar-daemon.apiw
│   ├── launch-agent.apiw
│   ├── spotlight-importer.apiw
│   ├── quicklook-extension.apiw
│   └── finder-sync-extension.apiw
└── fixtures/             # raw inputs the obligations read (inert data)
    ├── sample-documents/sample.txt
    └── spotlight/sample.txt
```

## Two declaration families

These are **distinct entities sharing only the mechanism** (the ADR-0049
distinct-entity precedent), so each has its own sibling KDL-Schema under
[`schemas/spec-format/`](../../../schemas/spec-format/) and its own focused validator
submodule. Both are parsed, schema-validated, and loaded by the
[`platforms/macos/tools/platform-tests`](../tools/platform-tests/) crate
(`apianyware-platform-tests`); a standing guard in that crate's `tests/` loads and
validates every committed file on `cargo test`.

### `api-semantics/<facet>.apiw`

Per convention facet (one file each: `ownership`, `callbacks`, `threading`,
`errors` — the facet is the file stem), the §30 source-semantic **weirdness** a
concrete `(receiver, selector)` shape exhibits, plus the projection-free
expectations a binding must preserve. These align with the four convention facets
the `apianyware-conventions` datalog computes and are grounded in real
Foundation/AppKit shapes. The §30 `weirdness` vocabulary is **facet-conditional**
(the facet selects the allowed token set), so it is enforced by the crate's focused
validator (`api_semantics::vocab`), not by a schema `enum`. Contract:
[`api-semantics.kdl-schema`](../../../schemas/spec-format/api-semantics.kdl-schema).

```kdl
api-semantics "ownership" {
    api "NSString" "stringWithString:" {
        weirdness "autoreleased"
        expect "result-is-not-owned" { doc "The +0 factory result is autoreleased; the caller must not release it." }
    }
}
```

### `app-kinds/<kind>.apiw`

The obligation **bodies** that resolve the `test-obligation` refs each of the seven
app-kinds declares (`../app-kinds/<kind>/kind.apiw`). Each body is a set of
projection-free `expect`ations of what a program of that kind must satisfy, plus the
`fixture`s the obligation reads. The standing guard cross-resolves every body against
the app-kind registry — no orphan body, no unresolved ref. Contract:
[`app-kind-tests.kdl-schema`](../../../schemas/spec-format/app-kind-tests.kdl-schema).

```kdl
app-kind-tests "spotlight-importer" {
    obligation "indexing" {
        fixture "fixtures/spotlight/sample.txt"
        expect "extracted-values-match-fixture" { doc "The extracted attribute values match the fixture's known metadata." }
    }
}
```

## `fixtures/` — the raw inputs

Inert data the obligations read, by path relative to this `tests/` directory. Each is
the **smallest input that makes its obligation meaningful** — a tiny text document
with known, assertable content — not a corpus. The committed set covers exactly the
obligations that read a fixture today:

| fixture | read by |
| --- | --- |
| [`fixtures/sample-documents/sample.txt`](fixtures/sample-documents/sample.txt) | `quicklook-extension` (`preview`), `finder-sync-extension` (`sync-badging`) |
| [`fixtures/spotlight/sample.txt`](fixtures/spotlight/sample.txt) | `spotlight-importer` (`indexing`) |

A fixture carries known metadata/content (a title, an author, a distinctive body
token) so the workstream-9 runner can assert the extracted values *match the fixture*,
not merely that *some* value was produced. Fixtures are authored **lazily** — a
directory exists only when a committed declaration references it (constraint 4); the
`api-semantics` family references none (its declarations are `(receiver, selector)`
shapes, not fixture-reading obligations). The crate's standing guard checks every
committed `fixture` ref resolves to a real file here.
