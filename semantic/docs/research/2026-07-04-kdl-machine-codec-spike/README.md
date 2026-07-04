# Spike: machine-oriented (non-format-preserving) KDL codec for the large IR

**Date:** 2026-07-04 · **Context:** `structural-refactoring` grove, workstream 8
(`schema-validation-k149`), leaf `machine-format-spike-k150` · **Gates:** the D1/D2 steer to
move the machine IR (`extracted.json` / `resolved.json`) to KDL *conditionally on performance*
(the `schema-validation-k149` brief). **Supersedes-or-reconfirms:**
[ADR-0046](../../../../adr/0046-spec-interchange-format-kdl-everywhere.md)'s **k17 Update** (the
JSON retreat) and its report
[`../2026-06-24-kdl-machine-serde-spike/`](../2026-06-24-kdl-machine-serde-spike/README.md).

## TL;DR

**GO is recommended.** A machine-oriented codec — the path k17 never tested — moves the machine
IR to KDL at **~1.28× `serde_json`** on the raw codec (text↔`Value`), and **~2.4–2.5× read /
~2.9–3.2× write** on the full production (typed) path via the simplest implementation. Both clear
the **D2 soft target (~≤5× `serde_json`, full-corpus round-trip in low seconds)** with roughly 2×
headroom. Round-trip is **lossless on both `extracted` and `resolved` shapes** (k17 only tested
`extracted`), and the emitted text is **spec-valid KDL 2.0**. The k17 NO-GO was correct *for the
path it measured* (the format-preserving document-model `kdl` crate, re-confirmed here at **~84×**);
it does **not** bind a non-preserving codec. **The user makes the final go/no-go on these numbers
(D2).**

## Question

k17 asked whether the large IR can be KDL. It answered **NO on performance**, but only measured
the **format-preserving** document-model `kdl` crate (`=6.3.4`) — which keeps owned source spans +
per-node whitespace to round-trip comments and layout — at ~80–100× `serde_json`. It flagged that
**no fast serde-KDL path existed then** (`serde_kdl` abandoned on KDL 1.0; the derive crates 0.x
non-serde). k17 explicitly left one path untested:

> A machine artifact (written once, read back mechanically) needs **no** format preservation.

This spike measures exactly that path — a **machine-oriented (non-preserving) codec** — on the same
fixtures, plus the `resolved` shape k17 never touched. **Correctness was already settled by k17**
(the IR is losslessly expressible in KDL 2.0); the open question is **performance**.

## Method

- **Same fixtures as k17, apples-to-apples**, regenerated for this grove: AppKit
  (`extracted` 12.7 MB / `resolved` 92.2 MB) and Foundation (`extracted` 8.7 MB / `resolved`
  17.8 MB), plus five more materialized families (WebKit, SceneKit, PDFKit, CoreGraphics,
  CreateML) for a **7-family, 0.74 MB → 92 MB** sample across **both shapes**. All are the real,
  gitignored per-family IR under `platforms/macos/api/<F>/`.
- **The codec (candidate).** A hand-written, non-preserving **JSON-in-KDL (JiK) codec over
  `serde_json::Value`** — the same bijective mapping k17's correctness bridge used (objects/arrays
  carry `(object)`/`(array)` type annotations; array elements are `-`-named child nodes; scalars are
  a single positional argument), but with a **streaming emitter** and a **hand-rolled tokenizer for
  the restricted JiK subset** instead of the document model. It always-quotes keys/strings and emits
  KDL-2.0 keyword syntax (`#null`/`#true`/`#false`), which sidesteps k17's bare-keyword footgun **by
  construction**. This is exactly what a production machine-KDL serde back-end would be.
- **The anchor.** k17's document-model path (verbatim), behind `--docmodel`, to re-confirm k17 on
  current tooling and extend it to the `resolved` shape.
- **Correctness oracle (per k17):** `value == parse(emit(value))` — serde structural
  (order-independent) equality on the whole `Value` tree. Plus a **spec-validity cross-check**: the
  *official* `kdl` crate parses our emitted text and decodes back to the identical `Value`.
- **Production-path honesty (`--typed`).** The pipeline serializes/deserializes the **typed**
  `Framework` (`from_str::<Framework>` / `to_string_pretty`, one serde pass — confirmed in
  `resolve/checkpoint.rs` and `datalog/loading.rs`; both shapes are `Framework`). A `Value`-bridge
  codec adds a `from_value`/`to_value` pass JSON-direct doesn't pay. We measure that tax (with the
  per-iter `Value` clone timed separately and subtracted) so the recommendation reflects the *real*
  production cost, not just the codec's text↔`Value` legs.
- **Perf measure:** release build (`opt-level=3`, LTO, 1 codegen unit); each leg run 7× (5× / 3× for
  the largest files) after a warm-up; **median** reported (min tracked). Host: arm64, rustc 1.93.1.

Source: [`kdl-machine-codec.rs`](./kdl-machine-codec.rs) · [`Cargo.toml.txt`](./Cargo.toml.txt).

## Results

### Correctness — ✅ lossless on **both** shapes, spec-valid KDL 2.0

| | round-trip (`value == parse(emit(value))`) | official-crate cross-check |
|-|-|-|
| **extracted** (7 families) | **PASS ✅** all | **PASS ✅** (spec-valid KDL 2.0) |
| **resolved** (7 families, incl. the full provenance ladder) | **PASS ✅** all | **PASS ✅** |

k17 proved `extracted` round-trips; this spike **newly confirms `resolved`** — the larger,
provenance-carrying shape the generate loop actually re-reads — also round-trips losslessly. No
footgun surfaced: always-quoting strings/keys makes keyword-valued strings (`"null"`, `"true"`) a
non-issue by construction (the exact defect k17 had to force-quote around in the document-model
writer).

### Performance — ✅ the machine codec is at parity with `serde_json`

**Raw codec (text ↔ `Value`), median ms** — the apples-to-apples anchor vs k17:

| fixture | `serde_json` parse | **jik parse** | ratio | `kdl` doc-model parse (k17 path) | vs json |
|---|---:|---:|---:|---:|---:|
| Foundation `extracted` (8.7 MB) | 12.72 | 15.78 | **1.24×** | 1071.9 | 84× |
| AppKit `extracted` (12.7 MB) | 18.68 | 23.12 | **1.24×** | 1604.3 | 86× |
| Foundation `resolved` (17.8 MB) | 26.70 | 33.14 | **1.24×** | 2261.4 | 85× |
| AppKit `resolved` (92.2 MB) | 143.37 | 184.97 | **1.29×** | *(skipped — memory)* | — |

| fixture | `serde_json` emit (pretty) | **jik emit** | ratio |
|---|---:|---:|---:|
| Foundation `extracted` | 6.24 | 7.96 | **1.28×** |
| AppKit `extracted` | 9.56 | 11.82 | **1.24×** |
| Foundation `resolved` | 14.12 | 17.92 | **1.27×** |
| AppKit `resolved` | 75.97 | 94.94 | **1.25×** |

Across the full **7-family × both-shape** sample (≥2 MB files; sub-MB files are sub-ms noise) the
parse ratio holds in a **tight 1.23–1.31× band, size- and content-independent**, and the doc-model
anchor holds at **84–86×** — a clean re-confirmation of k17. **The 80–100× cost k17 rejected was
entirely the format-preserving document model, not KDL-the-format.**

**Production path (typed `Framework` ↔ text), median ms** — what the pipeline actually pays:

| fixture | json direct read | Value-bridge read¹ | ratio | json direct write | Value-bridge write² | ratio |
|---|---:|---:|---:|---:|---:|---:|
| Foundation `extracted` | 8.5 | 20.2 | 2.38× | 5.8 | 16.6 | 2.84× |
| AppKit `extracted` | 12.0 | 29.8 | 2.48× | 8.4 | 25.1 | 2.99× |
| Foundation `resolved` | 17.5 | 43.1 | 2.47× | 11.9 | 37.0 | 3.10× |
| AppKit `resolved` | 87.1 | 213.5 | 2.45× | 60.9 | 194.1 | 3.19× |

¹ `jik_parse + from_value` (net of the per-iter `Value` clone). ² `to_value + jik_emit`.

The `Value`-bridge — the *cheapest* implementation (reuse the existing serde derives, add a
~300-line codec) — costs **~2.4–2.5× read / ~2.9–3.2× write** vs `serde_json`'s direct typed path.
**Both under the D2 ≤5× bar with ~2× headroom.** A **native serde JiK format** (a `Serializer`/
`Deserializer` over the JiK tokenizer, no `Value` intermediate) would recover the raw-codec ~1.3–1.5×
at more implementation cost.

### Size — a wash (unchanged from k17)

The machine JiK text is **0.96× pretty-JSON** (slightly *smaller*, no per-node autoformat bloat) and
**~1.65× compact-JSON**. gzip-9 (Foundation `resolved`): KDL **584 KB** vs pretty-JSON **589 KB** —
KDL marginally smaller. **Size does not drive the decision.**

### Ecosystem survey — still no drop-in fast serde-KDL-2.0 codec (2026-07)

Every candidate falls into one of two disqualifying buckets:

| crate | latest / date | why it doesn't clear the bar |
|---|---|---|
| `serde_kdl` | 0.1.0 · 2021-09 | abandoned, KDL-1.0-era, no `to_string`/`from_str` |
| `kaydle` | 0.2.0 · 2022-07 | abandoned, KDL-1.0-era |
| `knurdy` | 0.2.0 · 2023-07 | serde deser-only, but parses **through** `kdl` doc-model (`kdl ^4.5`) → inherits the ~84× tax; stale |
| `facet-kdl` | 0.42.0 · 2026-01 | `facet` derive (not serde) + `kdl ^6.5` doc-model → inherits the tax; **needs rustc > 1.93** |
| `knus` | 3.4.0 · 2026-06 | live, own `chumsky` parser (not doc-model) — but **own non-serde `Decode` derive**, span-heavy AST, deser-only → a full IR re-derive, not a back-end swap |

The serde-compatible bridges (`serde_kdl`/`kaydle`/`knurdy`) all route through the format-preserving
`kdl` document model and so **structurally inherit k17's parse tax**; the only live non-doc-model
crate (`knus`) requires re-deriving the entire `Framework`/`TypeRef` tree on a non-serde trait (the
`#[serde(flatten)]` `TypeRef` landmine included). So the **hand-written non-preserving codec is the
production path** — which is also the fastest and the one this spike measures.

## Full-corpus extrapolation & the incremental generate-loop delta

The parse ratio is size-invariant, so extrapolation is robust. Measured typed-read throughput
(D2-critical `resolved` shape): `serde_json` direct **~1050 MB/s**, `Value`-bridge **~430 MB/s**.
Only 7 of the ~153 families are currently materialized (the heavy hitters, 144.9 MB `resolved`
total); the full corpus is estimated at a labelled range. The generate loop re-reads every
`resolved.json` **once per target** (4 live targets), so a full regenerate ≈ 4× a full-corpus read —
the friction the "regenerate aggressively" habit (and D2) cares about most:

| resolved corpus (assumed) | 1-target read: json → bridge | **full 4-target regenerate: json → bridge (delta)** |
|---|---|---|
| 300 MB | 0.29 s → 0.70 s | 1.14 s → **2.80 s (+1.66 s)** |
| **400 MB** (mid estimate) | 0.38 s → 0.93 s | 1.52 s → **3.73 s (+2.21 s)** |
| 500 MB | 0.48 s → 1.17 s | 1.90 s → **4.67 s (+2.76 s)** |
| 800 MB (pessimistic) | 0.76 s → 1.87 s | 3.04 s → **7.47 s (+4.42 s)** |

A native serde JiK format (~1.4× typed) would cut the 400 MB full-regenerate delta from +2.21 s to
**+0.61 s**. Either way the inner loop stays in **low single-digit seconds** — versus k17's
document-model path, which at ~84× would have turned the same re-read into **minutes** (the killer
k17 correctly rejected). The write side (analyze/collect emitting the corpus) is similar: +~3× on a
sub-second-to-low-seconds emit total.

## Recommendation — **GO** (un-retreat the machine IR to KDL), subject to the user's D2 call

- **Recommendation:** move `extracted.json` / `resolved.json` to a machine-oriented KDL codec. It
  clears D2 (~2.4–3.2× ≤ 5×; full round-trip in low seconds), is lossless on both shapes, emits
  spec-valid KDL 2.0, and — the ws8 payoff — **collapses "formal validation of every artifact" to
  one schema language** (KDL-Schema) reusing the **generic engine that already exists**
  (`apianyware-spec-format::validate_against_schema`). The machine-JSON-Schema seam disappears.
- **Codec = hand-written non-preserving JiK over `serde_json::Value`** (no crate clears the bar).
  Natural home: `semantic/tools/spec-format` (already the KDL-Schema engine + the `json→kdl`
  converter k18 was slated to ship). **Effort to productionize:** the codec is ~300 lines and is
  **already prototyped, round-trip-validated, and cross-checked spec-valid** here — the remaining
  work is packaging it as a spec-format module with the round-trip test as a standing guard, and
  swapping the ~2 call-sites (`resolve/checkpoint.rs` write, `datalog/loading.rs` read) plus
  collect's extracted writer. **Implementation choice for `02`/the user:**
  - **Value-bridge (cheapest):** reuse existing serde derives via `to_value`/`from_value`. ~2.4–3.2×,
    clears the bar today.
  - **Native serde JiK format (optional optimization):** ~1.3–1.5×, more code — worth it only if the
    generate-loop delta is ever felt (it is fractions of a second at realistic corpus sizes).
- **Golden-neutral invariant:** the migration is golden-neutral **at the emit layer** — the
  generator output must stay byte-identical (it reads the same `Framework`). Only the on-disk IR
  encoding changes. That invariant is `02`'s follow-on to hold; this leaf moved no emit path.
- **ADR:** the user's D2 go/no-go was **GO** (2026-07-04). Per the grove's ADR policy (current-state,
  in-place, no supersession chains), `02-build-plan-k151` folded the decision **into
  [ADR-0046](../../../../adr/0046-spec-interchange-format-kdl-everywhere.md) in place** (§5 + status:
  the machine IR is KDL via a non-preserving codec) rather than raising a separate superseding ADR.
  ("KDL everywhere" is literally true again.)

## Caveats (research discipline)

- **Median-of-7 (of-3 for 92 MB), one host** (arm64, rustc 1.93.1, release+LTO). Tighter than k17's
  single-run method, but still directional — the decision rests on ratios that are stable to ~±5%
  across a 0.74 MB → 92 MB range, an order of magnitude clear of the 5× bar either way.
- **Corpus total is estimated**, not measured — only 7 of ~153 families are materialized (gitignored,
  recomputable). The *ratio* (size-invariant, 1.24× raw / 2.4–3.2× typed) is the decision statement
  and does **not** depend on the total; the table labels its corpus-size assumption explicitly.
- **The prototype codec is a prototype**, not production code — sufficient to benchmark and to prove
  losslessness + spec-validity, per this leaf's scope. Productionizing (a proper spec-format module,
  full escaping-edge-case tests, the native-serde-format option) is `02`'s follow-on if the user says
  GO.

## Reproduce

```
# Fixtures are the gitignored real IR; regenerate if absent (SDKROOT=macosx per the repo workaround):
#   SDKROOT=macosx cargo run --release -p apianyware-collect -- --only AppKit,Foundation
#   cargo run --release -p apianyware-analyze -- --only Foundation,AppKit   # deps loaded together
# The spike (standalone crate; this dir's kdl-machine-codec.rs is src/main.rs, Cargo.toml.txt is Cargo.toml):
cargo run --release -- --docmodel --typed \
  platforms/macos/api/Foundation/extracted.json platforms/macos/api/AppKit/extracted.json \
  platforms/macos/api/Foundation/resolved.json  platforms/macos/api/AppKit/resolved.json
```
