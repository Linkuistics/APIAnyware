# App-kinds — the kinds of macOS application a target can build

A map over the authoritative registry, not a re-author. An **app-kind** is
**platform process-model truth**: how a program of that kind starts, runs, and
stops; how it presents to the window server; what on-disk container and Info.plist
keys it requires; and which platform-level test obligations it carries. It is a
**distinct entity** with its own authored `.apiw` registry
([ADR-0049](../../../adr/0049-app-kinds-as-distinct-platform-process-model-entity.md)),
parsed and validated by the `platforms/macos/tools/app-kinds` crate
(`apianyware-app-kinds`).

The authoritative reference — the seven-kind table, the `kind.apiw` grammar, the
controlled vocabularies, and what consumes a kind — is
[`app-kinds/README.md`](../app-kinds/README.md). Read it for the detail; this page
only places the entity relative to its neighbours.

## Three axes that look alike but are not

App-kind, app-spec, and pattern-kind are three **orthogonal** entities that share
only the *authored-registry mechanism* — never the entity:

| Entity | Domain | What it is | Axis |
| --- | --- | --- | --- |
| **app-kind** | `platforms/macos/app-kinds/` | a *category* of macOS program (process-model truth) | platform category |
| **app-spec** | `apps/macos/<app>/` (ws7) | one *concrete* app that **names** its kind | concrete instance of a category |
| **pattern-kind** | `semantic/pattern-kinds/` (ws3) | a reusable *API-usage* shape (`bracket`, `observer`) | orthogonal API-usage axis |

So a concrete app (an app-spec) *names* the app-kind it is — a `gui-app`, a
`menu-bar-daemon` — and that is a category ↔ instance relationship along the
*process-model* axis. Pattern-kinds sit on a wholly separate axis (how an app
*uses* APIs), sharing only the fact that both are authored `.apiw` registries. The
app-kind registry deliberately lives in `platforms/` and *mirrors* the
`apianyware-patterns` mechanism without reusing its entity — folding the two
together would breach the domain rule (platform truth stays in `platforms/`,
ADR-0049).

## The seven kinds (summary)

The seven kinds span the three process shapes a macOS program takes — **standalone**
programs the system launches and **hosted** plug-ins another process loads:

- **standalone:** `cli-tool`, `gui-app`, `menu-bar-daemon` (an `accessory`
  `LSUIElement` `.app`), `launch-agent`;
- **hosted:** `spotlight-importer` (a legacy `.mdimporter` CFPlugIn),
  `quicklook-extension` and `finder-sync-extension` (NSExtension `.appex`
  bundles).

The full table — entry / run-loop / termination / activation / bundle per kind —
and the `kind.apiw` grammar are in [`app-kinds/README.md`](../app-kinds/README.md).
Each kind's own directory carries `docs/` describing its lifecycle, bundle
structure, and test obligations (e.g.
[`app-kinds/gui-app/docs/lifecycle.md`](../app-kinds/gui-app/docs/lifecycle.md)).

## Projection-free, and what consumes a kind

`kind.apiw` states what a kind **is**, never how any target language builds it (the
domain rule — projection lives in `targets/`, workstream 6). Three consumers read
the registry:

- **ws6** target emitters/bundlers project a kind's bundle and process model to a
  build (`.app` layout, Info.plist / launchd-plist emission);
- a **ws7** app-spec (`apps/macos/<app>/`) *names* its kind;
- the `test-obligation` references are forward pointers whose **bodies** are
  authored in [`../tests/app-kinds/<kind>.apiw`](../tests/) and executed by the
  testing architecture (workstream 9) — the declare-now / execute-later seam
  covered in [`testing-obligations.md`](testing-obligations.md).
