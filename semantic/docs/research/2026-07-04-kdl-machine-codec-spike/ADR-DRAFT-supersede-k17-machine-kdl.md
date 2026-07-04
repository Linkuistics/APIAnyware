# DRAFT ADR — Machine IR moves to KDL via a non-preserving codec (supersedes the ADR-0046 k17 Update)

> **STATUS: DRAFT.** This is a draft for `02-build-plan-k151` to raise as a real ADR **after** the
> user's D2 go/no-go on the [spike numbers](./README.md). It is written GO-shaped because the spike
> recommends GO, but the decision is the user's; if the call is NO-GO, `02` instead records a short
> "k17 reconfirmed with current tooling — machine IR stays JSON" note and drops this draft. Do not
> merge as-is. Number it at raise time (next free ADR id).

## Status

Proposed — supersedes the **"Update — spike outcome (2026-06-24, leaf `kdl-serde-spike-k17`)"**
section of [ADR-0046](../../../../adr/0046-spec-interchange-format-kdl-everywhere.md) (the JSON
retreat for `extracted`/`resolved`). ADR-0046's core decision (KDL 2.0 for the authored `.apiw`
layer; provenance carriage; the per-family triad) stands unchanged. Only the **machine-side format**
flips: `extracted.json` / `resolved.json` → **KDL**.

## Context

The k17 Update invoked ADR-0046 §5's documented JSON retreat because the **format-preserving
document-model `kdl` crate** parsed the large IR ~80–100× slower than `serde_json` — too heavy for
the "regenerate aggressively" inner loop. k17 measured **only** that path and noted no fast serde-KDL
codec existed, but explicitly did not test a **machine-oriented (non-preserving)** codec, since a
write-once/read-mechanically artifact needs no format preservation.

The `machine-format-spike-k150` spike (2026-07-04) measured that untested path — see
[`README.md`](./README.md). Findings:

- **Correctness settled and extended.** Lossless round-trip on **both** `extracted` **and**
  `resolved` shapes (k17 only tested `extracted`), across a 7-family / 0.74 MB → 92 MB sample; the
  emitted text is **spec-valid KDL 2.0** (the official crate parses it back to the identical value).
- **Performance clears the D2 bar (~≤5× `serde_json`).** A hand-written non-preserving JiK codec runs
  at **~1.28× `serde_json`** (raw text↔`Value`) and **~2.4–2.5× read / ~2.9–3.2× write** on the full
  production typed path via the cheapest implementation (a `Value` bridge). The k17 document-model
  path re-confirmed at **~84×**. The 80–100× cost was the format preservation, not KDL.
- **Ecosystem still has no drop-in fast serde-KDL codec** (serde bridges route through the doc-model
  and inherit the tax; the one live non-doc-model crate `knus` needs a full non-serde IR re-derive).
  The hand-written codec is the production path.
- **Full-corpus generate-loop delta** is fractions of a second to low single-digit seconds
  (+~2.2 s on a full 4-target regenerate at a ~400 MB corpus, cheapest impl) — versus minutes for the
  doc-model path.

## Decision

1. **`extracted.json` / `resolved.json` become machine KDL** (filenames TBD by `02` — likely
   `extracted.kdl` / `resolved.kdl`, restoring ADR-0046 §2's original intent). The authored
   `annotations.apiw` was already KDL; the whole spec triad is now KDL — **one format, one schema
   language.**
2. **Codec = a hand-written non-preserving JiK serializer/deserializer** over `serde_json::Value`,
   homed in `semantic/tools/spec-format` (with the KDL-Schema engine + the `json→kdl` converter).
   Implementation depth (`Value`-bridge vs native serde format) is `02`'s call on the spike's
   headroom numbers; the `Value`-bridge clears the bar today.
3. **Machine schema is a KDL-Schema** over the IR, validated by the **existing generic engine**
   (`validate_against_schema`) — the machine-JSON-Schema seam every prior workstream deferred to ws8
   **dissolves**; there is no second schema language.
4. **Golden-neutral at the emit layer is a hard invariant of the migration.** The generator reads the
   same typed `Framework`; only the on-disk encoding changes. Generator output must stay
   byte-identical (emit goldens unmoved). `02`'s cutover leaf holds this via goldens-as-truth.

## Consequences

- ws8's "formal validation of every artifact" collapses to KDL-Schema + one proven engine; the
  `CONTEXT.md` "machine IR is JSON" facts and the _Avoid_ note flip.
- The machine artifacts become human-readable KDL, directly serving goldens-as-truth review.
- Toolchain: the codec is pure Rust over `serde_json` (no new heavy dep; the format-preserving `kdl`
  crate is **not** on the machine read/write path — it stays for authored `.apiw` only). No rustc
  bump required (unlike `facet-kdl`/`kdl ^6.5`).
- Reversibility: still a serde-adjacent back-end swap (the IR is `Value`-expressible), so the retreat
  to JSON remains available if a future issue surfaces — symmetric with the k17 Update it supersedes.

## Alternatives considered

- **Keep JSON (reconfirm k17).** Rejected by the spike: the performance objection was specific to the
  document model and does not hold for a machine codec; keeping JSON would leave ws8 maintaining a
  second schema language (machine JSON-Schema) for no perf benefit.
- **An ecosystem serde-KDL crate.** None clears the bar (survey in the report).
- **`knus` / `facet-kdl` derive path.** A full non-serde IR re-derive (and, for `facet-kdl`, a rustc
  bump) — disproportionate to a back-end swap.
