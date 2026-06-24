# instance-carriage-k29

**Kind:** work

## Goal

**ws3 child 2 — the carriage:** make pattern-**instances** first-class in the machine triad.
Extend `semantic/tools/types` (the IR) + `semantic/tools/resolve` so `resolved.json` carries
first-class **pattern-instances** — a kind's roles bound to concrete framework participants,
provenance-stamped (ADR-0046 §4) — **replacing** the loosely-typed `Framework.api_patterns:
Vec<ApiPattern>` list. Each instance references an authored kind **by name** and is validated
against the **`apianyware-patterns` registry** child 1 (`pattern-kind-registry-k28`) shipped.

No *detection* yet (that is child 3's `ascent` datalog) and no *projection* (ws6/emit). This
child defines the **carriage** only (D6): the typed instance model + its `resolved.json` serde +
the kind-ref validation + the two identity/home rules below. Goldens stay green (nothing emits
pattern-instances yet, so the projected output is unchanged even as `api_patterns` is replaced).

Deliverables:

1. **Typed instance model** in `apianyware-types` — a `PatternInstance` (kind name + role→
   participant bindings + the ADR-0046 §4 `source`/`confidence`/`provenance` stamp), with a
   **participant** ∈ {type, operation/selector, parameter, **pattern-instance-ref**} (D5). Replaces
   `ApiPattern`/`PatternStereotype` on `Framework`.
2. **`resolved.json` carriage** — `resolve` writes/reads pattern-instances; kind references are
   validated against the registry (`PatternKindRegistry::load_dir(semantic/pattern-kinds/)`), and
   each instance's role-bindings are checked against the kind's declared roles (names + cardinality
   + `binds` kind).
3. **DP4 — content-derived instance identity.** An instance's id is a function of
   `(kind, sorted role-bindings)` (a content hash), **not** a sequential label like
   `"AppKit#notif-destroy-1"` — so re-detection/SDK-drift yields the same id and D5 pattern-refs stay
   stable. Echoes the convention datalog's `(receiver, selector)` keying + the grove content-hash
   instinct.
4. **DP3 — deterministic cross-framework home rule.** An instance whose roles span two frameworks
   (e.g. NSView parents a CoreAudio type) needs a *deterministic* home: candidate = the framework of
   the kind's **designated primary role**, tie-broken deterministically (cf. gerbil `ClassRegistry`
   cross-framework resolution). Define it explicitly — do **not** leave "primary participant"
   undefined on ties. The kind schema may need a `primary` marker on a role (decide here; if so,
   extend `pattern-kinds.kdl-schema` + the `apianyware-patterns` model minimally).

## Context (inherited — see `grove-llm brief-chain`)

Design is **settled** — build to it, do **not** re-grill. Read:
- **PRD** `prd/2026-06-25-semantic-pattern-kind-model.md` (the model + `resolved.json` instance
  example + the staged decomposition this child is #2 of).
- **ADR-0048** (two-level kind/instance split D1; provenance-tiered instances; composition D5).
- **ADR-0046 §4** (the `source`/`confidence`/`provenance` carriage + precedence
  `manual > llm > convention > extraction`) — instances reuse it wholesale.
- **CONTEXT.md → "Semantic model"** (pattern-instance, role/participant, Law/controlled-vocabulary).
- The node `BRIEF.md` running log (esp. **D1, D5, D6**) + **doubt pass DP3/DP4** (this child owns them).
- **What child 1 shipped (build on it):** `apianyware-patterns` — `PatternKind`/`Role`/`RoleBinds`/
  `Cardinality`/`Law`, the `PatternKindRegistry` loader, and `semantic/pattern-kinds/*.apiw`. The
  registry is how you validate an instance's `kind=` + role-bindings.
- **Prefiguring code to replace:** `apianyware-types::annotation::{ApiPattern, PatternStereotype,
  PatternConstraint}` + wherever `Framework.api_patterns` is produced/consumed (grep it).

## Done when

- `apianyware-types` carries a typed `PatternInstance` (+ participant enum) on `Framework`,
  replacing `ApiPattern`/`PatternStereotype`; `resolve` reads/writes it in `resolved.json`.
- Kind refs + role-bindings validate against the `apianyware-patterns` registry.
- DP4 content-hash identity + DP3 cross-framework home rule implemented + unit-tested.
- `cargo build` + existing test suites + **emit goldens** all green (no emit/projection change).

## Notes (steers)

- **Carriage minimal (D6).** ws3 defines the carriage; the per-fact cache/regen/review/diff
  *workflow* + disagreement/precedence audit is **ws5's**. `annotate` runs once per SDK update —
  do not over-engineer prose-derived extras (the k26 steer).
- **Goldens-green is the scope gate.** Replacing `api_patterns` must not move emit output (no
  consumer projects instances until ws6). If a `resolved.json` golden exists and shifts, that is
  expected (the IR changed); the **emit** goldens are the invariant.
- **Detection is NOT here** (child 3, `ascent` datalog in `platforms/macos/tools/`). This child may
  hand-author a fixture instance or two for tests, but the convention producer is the next leaf.
