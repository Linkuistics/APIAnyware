# platforms/macos/api/ — per-API-family source specs

One directory per macOS API family (REFACTOR.md §14), named conventionally
(`CoreFoundation`, `Foundation`, `AppKit`, … — §41 keeps conventional API-family
names rather than kebab-case). Each family holds the **spec triad** (ADR-0046, as
amended by the k17 machine-KDL no-go):

| File | Producer | Tracked? | Role |
|------|----------|----------|------|
| `extracted.json` | `apianyware-collect` | gitignored | mechanical extraction facts (the datalog fact base) — JSON |
| `annotations.apiw` | manual + accepted-LLM | **committed** | the one authored semantic overlay — KDL (`.apiw`) |
| `resolved.json` | `apianyware-analyze` | gitignored | the deterministic merged graph; the generator input — JSON |

The machine artifacts are JSON (the k17 spike measured the only production-grade
KDL-2.0 library at ~80–100× slower to parse than `serde_json` on the real multi-MB
IR, so ADR-0046 §5's JSON retreat was invoked); only the authored overlay is KDL,
where the authoring eval backs it. The machine files are **regenerable** from the
SDK + the overlay and so are gitignored; only `annotations.apiw` is versioned
(regenerating it from scratch costs millions of tokens — see [ADR-0046](../../../adr/0046-spec-interchange-format-kdl-everywhere.md)).

The pipeline (`pipeline-cutover-k20`): `collect → extracted.json`; `analyze` runs
the in-process passes (`linked` datalog cross-reference → annotate-merge → enrich)
folding in `annotations.apiw` by §28 precedence and writes `resolved.json`;
`generate` consumes `resolved.json`. The four phase-shaped checkpoints under the
former `collection/ir/` + `analysis/ir/` are retired; the intermediate stages are
in-process, not on disk.

The flat `_llm-annotations/*.llm.json` staging side-channel was folded into the
per-family `annotations.apiw` overlays and retired here (`pipeline-cutover-k20`,
via the `semantic/tools/spec-format` converter). The richer LLM side-channel
*workflow* — caching, regeneration, review→accept, diff/provenance tooling over the
`.apiw` overlay — is **workstream 5** (see `TODO.md`).
