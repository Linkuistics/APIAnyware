# platforms/macos/api/ — per-API-family source specs

One directory per macOS API family (REFACTOR.md §14), named conventionally
(`CoreFoundation`, `Foundation`, `AppKit`, … — §41 keeps conventional API-family
names rather than kebab-case). Each family holds the **spec triad** (ADR-0046):

| File | Producer | Tracked? | Role |
|------|----------|----------|------|
| `extracted.kdl` | `apianyware-collect` | gitignored | mechanical extraction facts (the datalog fact base) — KDL |
| `annotations.apiw` | manual + accepted-LLM | **committed** | the one authored semantic overlay — KDL (`.apiw`) |
| `resolved.kdl` | `apianyware-analyze` | gitignored | the deterministic merged graph; the generator input — KDL |

The whole spec stack is **KDL** (ADR-0046 §5). The machine artifacts use a
hand-written non-preserving **JSON-in-KDL (JiK) codec** over `serde_json::Value`
(~1.2–3.2× `serde_json`); the authored overlay uses the format-preserving `kdl`
document model, where diagnostics and layout matter and the authoring eval backs
it. (That document model is ~84× on the multi-MB IR — the k17 measurement — so the
"regenerate aggressively" machine loop deliberately routes through the fast codec,
not the `kdl` crate.) The machine files are **regenerable** from the SDK + the
overlay and so are gitignored; only `annotations.apiw` is versioned
(regenerating it from scratch costs millions of tokens — see [ADR-0046](../../../adr/0046-spec-interchange-format-kdl-everywhere.md)).

The pipeline (`pipeline-cutover-k20`): `collect → extracted.kdl`; `analyze` runs
the in-process passes (`linked` datalog cross-reference → annotate-merge → enrich)
folding in `annotations.apiw` by §28 precedence and writes `resolved.kdl`;
`generate` consumes `resolved.kdl`. The four phase-shaped checkpoints under the
former `collection/ir/` + `analysis/ir/` are retired; the intermediate stages are
in-process, not on disk.

The flat `_llm-annotations/*.llm.json` staging side-channel was folded into the
per-family `annotations.apiw` overlays and retired here (`pipeline-cutover-k20`,
via the `semantic/tools/spec-format` converter). The richer LLM side-channel
*workflow* — caching, regeneration, review→accept, diff/provenance tooling over the
`.apiw` overlay — is **workstream 5** (see `TODO.md`).
