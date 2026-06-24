# convention-detection-k30

**Kind:** work

## Goal

**ws3 child 3 — the convention producer:** port the (now-retired) imperative
`detect_patterns` heuristic detector to **`ascent` datalog rules** that derive
**`source=convention` pattern-instances** into `Framework.patterns` (D3, ADR-0047).
This is the first real *producer* of the first-class carriage that child 2
(`instance-carriage-k29`) shipped — patterns become live for the real corpus.

Detection is **Cocoa-specific knowledge**, so the rules live in
`platforms/macos/tools/` (with/beside `apianyware-conventions`, by the ADR-0047
precedent — *not* shared `semantic/tools/datalog`, which holds only the engine).
Each derived `pattern_instance` tuple **names the rule that produced it**, so the
`source = convention:<rule>` provenance falls out of the derivation trace for free
(D2/D3). Multi-role assembly (a `bracket` binds acquire+release+operation*) is a
`readback`-layer concern — the `conventions` crate already has that layer.

## Context (inherited — see `grove-llm brief-chain`)

Design settled — build to it, do **not** re-grill. Read the node `BRIEF.md` (D2/D3,
DP-pass) + the PRD; then build on what child 2 shipped:

- **The carriage (use it wholesale):** `apianyware_types::pattern_instance::{PatternInstance,
  Participant, InstanceSource}` on `Framework.patterns`. A producer:
  1. builds each instance's `roles: BTreeMap<String, Vec<Participant>>` (Participant ∈
     type / operation / parameter / pattern-ref);
  2. stamps `source = InstanceSource::Convention` + `provenance = Some("convention:<rule>")`;
  3. sets `id = PatternInstance::compute_id(&kind, &roles)` (DP4 content hash);
  4. sets `home` via `registry.instance_home(&instance)` (DP3);
  5. **validates** each produced instance with `registry.validate_instance(&instance)`
     before it lands (catches kind/role/cardinality/binds drift at the producer — the
     natural wiring point child 2 deliberately left to the producer).
- **The kinds to target** (`semantic/pattern-kinds/`, loaded via `PatternKindRegistry::load_dir`):
  the old stereotypes map to authored kinds — `factory-cluster`, `observer`, `paired-state`,
  `delegate`, `bracket` (the old ResourceLifecycle/TransactionBracket), `enumeration`,
  `error-out`, `target-action`, `builder`. Bind their declared roles (e.g. bracket:
  `acquire`/`operation`/`release`; observer: registration roles; parent-child: `parent`
  (primary)/`child`).
- **Reference for the detection LOGIC:** the retired
  `platforms/macos/tools/annotate/src/pattern_detection.rs` (deleted in
  `instance-carriage-k29`; recover from git history) — its heuristics
  (`detect_factory_clusters`/`detect_observer_pairs`/`detect_paired_state`/
  `detect_delegate_protocols`/`detect_resource_lifecycles`) are the rules to re-express
  declaratively. Re-express the LOGIC; the OUTPUT type is now `PatternInstance`.
- **ADR-0047** (convention heuristics as datalog) + `apianyware-conventions` (the existing
  convention datalog producer + readback layer) — the home and the pattern to follow.
- **CONTEXT.md → "Convention-tier pattern detection (datalog; D3)"** + "Semantic model".

## Done when

- A datalog producer in `platforms/macos/tools/` derives `source=convention`
  `PatternInstance`s into `Framework.patterns`, each provenance-stamped
  `convention:<rule>`, content-id'd (DP4), home-resolved (DP3), and registry-validated.
- Wired into the pipeline (annotate/resolve) so the real corpus's `resolved.json` carries
  convention pattern-instances (the `resolved.json` shift is expected — ADR-0048).
- **Emit goldens green** across racket/chez/gerbil/sbcl: emit does **not** project
  instances (that is ws6), so populating `Framework.patterns` must not move emit output.
- `cargo build` + clippy + touched-crate suites green.

## Notes (steers)

- **Goldens-green is the scope gate.** Producing instances populates `Framework.patterns`;
  no consumer projects them until ws6, so emit output is unchanged. Verify on regenerated
  Foundation+AppKit (load BOTH together — `apianyware-analyze --only Foundation,AppKit` —
  so AppKit's Foundation-inherited methods resolve; `--only AppKit` alone reorders
  cross-framework `all_methods` and breaks the AppKit emit snapshot). `resolved.json` is
  gitignored; the emit golden dirs are the invariant.
- **Carriage minimal (k26/D6 steer):** `annotate` runs once per SDK update — don't
  over-engineer prose-derived extras; the per-fact cache/regen/review workflow is **ws5's**.
- **Validation belongs at the producer** (child 2 shipped `validate_instance` but did not
  thread it into the empty live pipeline — wire it here, where instances are first born).
- After this retires, only **child 4** (semantic vocabulary docs) remains before the ws3
  retire-cascade.
