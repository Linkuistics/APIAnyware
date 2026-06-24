# Spike: KDL machine-serialization of the large IR — perf + round-trip

**Date:** 2026-06-24 · **Context:** `structural-refactoring` grove, workstream 2
(`spec-format-k16`), leaf `kdl-serde-spike-k17` · **Gates:**
[ADR-0046](../../../../adr/0046-spec-interchange-format-kdl-everywhere.md) §5 (the
machine-side KDL decision).

## Question

ADR-0046 makes KDL 2.0 the single spec format — authored *and* machine. The **authored**
side is backed by the [authoring eval](../2026-06-24-kdl-authoring-eval/README.md). The
**machine** side was left explicitly **unproven and spike-gated** (ADR-0046 §5): the official
`kdl` crate is a *document model*, not a serde-derive backend, and the IR is **tens of MB per
framework**. Two sub-risks, bundled in the ADR as one:

1. **Correctness** — can the large IR round-trip JSON↔KDL **losslessly**?
2. **Performance** — is KDL parse/emit of that IR **fast enough** for a pipeline whose core
   habit is "regenerate aggressively"?

The retreat ADR-0046 §5 pre-authorized: if the machine side fails, `extracted`/`resolved` fall
back to **JSON** (a serde back-end swap — the IR is serde-based), while authored `.apiw` stays
KDL regardless.

## Method

- **Real input, not synthetic.** Regenerated two genuinely large frameworks' `collected`
  (extracted-shape) IR with the live extractor — `apianyware-collect --only AppKit,Foundation`
  (ObjC headers + Swift module merge): **AppKit 12.7 MB** (313 classes / 149 protocols / 335
  enums / 91 functions / 1459 constants), **Foundation 8.7 MB** (277 / 73 / 173 / 125 / 825).
  The on-disk JSON is `serde_json::to_string_pretty` (what collect writes).
- **Path B — the decision-grade probe.** A generic, **bijective `serde_json::Value ⇄
  kdl::KdlDocument` bridge** over the *official* `kdl` crate (`=6.3.4`, KDL 2.0, pinned for
  rustc 1.93). This is the canonical **JSON-in-KDL (JiK)** mapping: objects/arrays carry an
  `(object)`/`(array)` type annotation, array elements are `-`-named child nodes, scalars are a
  single positional argument whose KDL value type carries string/int/float/bool/null.
  It sidesteps the IR's one serde landmine — `TypeRef` is `#[serde(flatten)]` over an
  internally-tagged enum, the case generic serde adapters choke on — because
  `Framework → serde_json::Value` already works (it's the production format) and the bridge
  operates on `Value`. **This is also exactly the `json→kdl` converter the spec-format crate
  (k18) would ship.** Source: [`kdl-spike.rs`](./kdl-spike.rs).
- **Correctness measure:** `original_value == kdl_to_value(parse(emit(value)))` — serde
  structural (order-independent) equality of the whole `Value` tree.
- **Perf measure:** `std::time::Instant` around each leg (release build); sizes on disk; gzip -9
  to normalize formatting.
- **Path A — the serde-adapter probe.** Checked whether a *non-document-model* (i.e. potentially
  faster) KDL-2.0 serde adapter exists that works with our existing `#[derive(Serialize,
  Deserialize)]` types.

## Results

### Correctness — ✅ lossless (both frameworks), modulo one library footgun

Both AppKit and Foundation round-trip with **full structural equality**. The IR's data model
is faithfully expressible in KDL 2.0. **But** the round-trip only passes after fixing a
**round-trip-safety defect in the official `kdl` crate's emit path**:

> The crate's `is_plain_ident` accepts the strings `null` / `true` / `false` / `nan` / `inf`
> / `-inf` as bare identifier-strings, so it **emits them bare** (`selector null`, `name true`,
> `name nan`) — and then its **own parser rejects them** as keywords. These are real IR values
> (a method whose selector is literally `"null"`; params named `"true"`/`"false"`/`"nan"`).

The crate emits text it cannot re-parse. The spike works around it by force-quoting exactly that
keyword set (`KdlEntryFormat { value_repr: "\"null\"", autoformat_keep: true, .. }`). A
production KDL writer **must** carry this fix — a latent corruption-on-write bug for arbitrary
string content. AppKit happens not to contain a keyword-valued string and so never triggered it;
Foundation does. (This is a write-side concern only — *reading* authored `.apiw` is unaffected.)

### Performance — ❌ the document-model crate is ~80–100× slower to parse than JSON

| leg | AppKit (12.7 MB) | Foundation (8.7 MB) |
|-----|---:|---:|
| **json parse** (text→Value) | **23.4 ms** | **11.6 ms** |
| **kdl parse** (text→doc) | **1795.2 ms** | **1204.8 ms** |
| → KDL/JSON parse ratio | **~77×** | **~104×** |
| json emit (Value→pretty) | 12.1 ms | 6.9 ms |
| kdl serialize (Value→text, build+emit) | 278.6 ms | 189.8 ms |
| → KDL/JSON emit ratio | ~23× | ~28× |
| kdl decode (doc→Value, *our* code) | 39.3 ms | 25.9 ms |

The cost is almost entirely **inside the `kdl` crate's parser** — the bridge's own decode is
~40 ms. The crate is *format-preserving*: it keeps source spans plus per-node/per-entry leading
& trailing whitespace as owned `String`s so it can round-trip comments and layout. That is
exactly what you want for *authored* files and exactly what makes it far too heavy for *bulk
machine* artifacts.

### Size — a wash (not a factor)

| | AppKit | Foundation |
|-|---:|---:|
| json pretty / compact / **kdl** | 12.7 / 7.5 / **15.4** MB | 8.7 / 4.9 / **10.6** MB |
| kdl ÷ pretty / ÷ compact | 1.21× / 2.06× | 1.22× / 2.16× |
| **gzip-9** kdl ÷ pretty / ÷ compact | 1.06× / 1.28× | 1.06× / 1.31× |

KDL is ~1.2× larger than pretty-JSON uncompressed and ~1.06× gzipped. Size does not drive the
decision.

### Path A — no viable fast serde adapter exists

There is **no mature, fast, KDL-2.0 serde adapter** for our existing serde types:

- **`serde_kdl` 0.1.0** — abandoned: depends on `kdl = "3.0"` (the old KDL **1.0** document
  model, not 2.0), edition 2018, and exposes **no `to_string`/`from_str`** entry points.
- **`club-kdl` / `unison-kdl`** — young 0.x crates with their *own* derive macros (not serde);
  they don't compose with the existing `#[derive(Serialize, Deserialize)]` types and don't
  operate on `serde_json::Value`. Adopting one means re-deriving the entire IR on a 0.x trait.

So the only production-grade KDL-2.0 path is the official document-model crate — the one measured
above.

## Decision — NO-GO for machine KDL; invoke the JSON retreat (ADR-0046 §5)

- **`extracted` and `resolved` stay JSON** (status-quo `serde_json`). The machine artifacts are
  never hand-edited and gain little from KDL, at an ~80–100× parse tax that directly degrades the
  "regenerate aggressively" inner loop (≈200 frameworks, each IR parsed several times per run:
  seconds → minutes).
- **Authored `annotations.apiw` stays KDL** — small, human/LLM-authored, format-preservation and
  `miette` diagnostics are a real win there, and the [authoring eval](../2026-06-24-kdl-authoring-eval/README.md)
  backs it. This is the genuinely hard-to-reverse choice and it proceeds unaffected.

The spike thus *confirms* the split the ADR's §5 anticipated: **KDL where humans write, JSON where
machines write.**

### Caveats (honesty per the research discipline)

- **Single-run timings, one host (arm64, rustc 1.93.1, release).** Directional, not a benchmark
  suite — but the gap is ~2 orders of magnitude, far beyond run-to-run noise.
- The `kdl` crate's `span` feature is on (default). Disabling it might speed parsing somewhat, but
  even a 2× win leaves KDL ~40–50× slower than JSON — the verdict is robust to it.

## Reproduce

```
# 1. real IR (needs macOS SDK; SDKROOT=macosx per the repo workaround)
SDKROOT=macosx cargo run --release -p apianyware-collect -- --only AppKit,Foundation --output-dir /tmp/ir

# 2. the spike (standalone crate; this dir's kdl-spike.rs is src/main.rs, Cargo.toml.txt is Cargo.toml)
#    deps: kdl = "=6.3.4", serde_json, apianyware-types (path)
cargo run --release -- /tmp/ir/AppKit.json /tmp/out
cargo run --release -- /tmp/ir/Foundation.json /tmp/out
```
