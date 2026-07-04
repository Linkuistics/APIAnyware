# App-kinds as a distinct platform process-model entity

**Relates to:** ADR-0046 (spec format / `.apiw` KDL overlays / generic KDL-Schema
validation — app-kinds reuse it), ADR-0048 (first-class semantic pattern-kinds —
the *parallel* model this one is deliberately distinct from), ADR-0043 (toolchain
crates distributed into domains — the platforms-domain crate home).

## Context

REFACTOR §13/§14 require `platforms/macos/` to carry **app-kinds** — `cli-tool`,
`gui-app`, `menu-bar-daemon`, `launch-agent`, `spotlight-importer`,
`quicklook-extension`, `finder-sync-extension` — each one directory
`app-kinds/<kind>/{kind.apiw, docs/}`. An app-kind describes a *kind of macOS
application*: how a program of that kind starts, runs, and stops; how it presents to
the window server; what on-disk container and Info.plist keys it requires; and what
platform-level test obligations it carries.

Two questions are not obvious and a reviewer will ask them. **(1)** Is an app-kind
the same thing as a semantic pattern-kind (ADR-0048), reusing the
`apianyware-patterns` registry and its roles/laws model? They share a shape — an
authored `.apiw` registry of named definitions with a focused validator — and reuse
is tempting. **(2)** Where does it live, and does it carry any *projection* (how a
target builds the bundle)?

## Decision

**An app-kind is a distinct entity with its own authored `.apiw` registry, homed in
the platforms domain, and is projection-free.**

1. **Distinct entity, not a pattern-kind.** A pattern-kind (`semantic/`) is an
   *API-usage* axis — roles + laws over a framework's types and operations,
   framework- *and* target-independent. An app-kind is a *macOS process-model* axis
   — entry / run-loop / termination model, activation policy, bundle type + required
   Info.plist keys + extension-point identifier, test-obligation references. The two
   share only the *mechanism* (authored `.apiw` + KDL-Schema + focused validator),
   not the *entity*: an app-kind has no roles and no §30 laws, and a pattern-kind has
   no bundle or run loop. Folding app-kinds into `apianyware-patterns` would conflate
   two orthogonal axes and put platform process-model truth in the universal
   `semantic/` domain — a domain violation. They get separate schemas
   (`app-kind.kdl-schema` vs `pattern-kinds.kdl-schema`) and separate crates.

2. **Platforms-domain crate home.** The reader/validator is a new crate
   `platforms/macos/tools/app-kinds` (crate-home convention, ADR-0043: a crate lives
   under `tools/` of the domain it serves). App-kinds are macOS platform truth, so
   they home in `platforms/macos/`, not `semantic/`. A second platform reuses the
   `platforms/<p>/app-kinds/` shape unchanged (§14 platform-neutrality).

3. **Flat controlled vocabularies, expressed in the schema.** Unlike a pattern law's
   *category-conditional* token set (which forced `apianyware-patterns` to carry a
   side `vocab` table the KDL-Schema couldn't state), an app-kind's controlled
   vocabularies — `entry` / `run-loop` / `termination` / `activation` / `bundle`
   type — are **flat enums**. They are expressed directly as `enum` constraints in
   `app-kind.kdl-schema` and as serde enums in the typed model (exactly like the
   platform manifest's `DiscoverSource`). The focused validator adds only the
   *cross-field* coherence the generic schema cannot state: a `bundle "none"` (bare
   Mach-O executable) carries no bundle metadata; an `extension-point` implies a
   hosted bundle (`mdimporter` / `appex`); required Info.plist keys and
   test-obligation refs are unique; and the kind's name matches its **containing
   directory** (identity is the directory, since every file is named `kind.apiw`).

4. **Projection-free.** `kind.apiw` states what a kind *is* — platform truth — never
   how any target language emits it (no "generate the racket NSApplication main").
   The bundlers (`targets/*/tools/bundle-*`) are *consumers* of this truth, in the
   `targets/` domain; they are not part of it.

## Consequences

- **Domain boundary held:** macOS process-model truth lives in `platforms/`;
  `semantic/` stays a universal API-usage vocabulary. The surprising part — that the
  obvious reuse of `apianyware-patterns` is *declined* — is the reason this ADR
  exists.
- **Mechanism reuse without entity reuse:** the crate mirrors `apianyware-patterns`
  (parse + schema embed + registry + focused validator + a standing `tests/` guard)
  and `apianyware-platform-manifest` (platforms-domain home + `include_str!` schema
  embed), so there is a well-trodden template, but the data model is its own.
- **Validation:** the `app-kind.kdl-schema` contract + the focused in-crate validator live
  with the model (mirroring ADR-0048); the shared KDL-Schema engine that `apianyware-validate`
  runs validates it like every other artifact — there is no separate machine-JSON schema
  (ADR-0046 §5).
- **Projection boundary:** target emitters/bundlers project a kind's bundle/process model to a
  target's build (`.app` layout, Info.plist emission, launchd plist) by *reading*
  the registry; the projection lives in `targets/`, never in the kind.
- **Test-obligation boundary (declare / execute):** `kind.apiw` carries only
  *test-obligation references*; the obligation bodies are authored in
  `platforms/macos/tests/app-kinds/<kind>.apiw`, and their execution belongs to the test model
  (`testing/`, ADR-0053), not the kind.
- **Why this clears the ADR bar:** hard-to-reverse (a new crate + a new schema + an
  on-disk domain placement + seven authored kinds to follow), surprising (the
  reuse-vs-distinct call against the very-similar ADR-0048 mechanism), a real
  trade-off (reuse one registry mechanism vs keep two orthogonal axes domain-pure —
  the project chose domain purity).
