# machine-kdl-codec-k152

**Kind:** work

## Goal

Flip the machine IR from JSON to **KDL** (the D3 GO). Productionize the non-preserving JSON-in-KDL
(JiK) codec — **Value-bridge depth** (D4) — in `semantic/tools/spec-format`, replace the JSON
`machine.rs` read/write seam with it, rename `extracted.json`/`resolved.json` → `extracted.kdl`/
`resolved.kdl` (D7), swap the pipeline call-sites, update `.gitignore` + any docs naming the files,
and land the round-trip + spec-validity test as a standing guard. **Hard invariant: golden-neutral
at the emit layer** — the generator reads the same typed `Framework`, so every emit golden
(racket/chez/gerbil/sbcl) must stay byte-identical; only the on-disk IR encoding changes.

## Context

The load-bearing, only golden-sensitive ws8 leaf — everything downstream validates KDL, so it goes
first. The codec is **already prototyped, round-trip-validated on both `extracted` and `resolved`,
and cross-checked spec-valid KDL 2.0** in the spike:
`semantic/docs/research/2026-07-04-kdl-machine-codec-spike/kdl-machine-codec.rs` (~300 lines) +
`README.md` (numbers). Read them.

- **Current seam to replace:** `semantic/tools/spec-format/src/machine.rs`
  (`read_framework`/`write_framework`/`framework_from_json`) + its test `tests/machine_roundtrip.rs`
  (both still JSON-worded).
- **Call-sites to rewire:** the resolve write (`resolve/checkpoint.rs`), the datalog read
  (`datalog/loading.rs`), and collect's `extracted` writer. Both shapes are the same typed
  `apianyware_types::ir::Framework` (one serde pass), so the Value-bridge (`to_value`/`from_value`
  + the JiK codec) drops in at exactly these points.
- **Decision record:** ADR-0046 §5 (amended in place — the machine IR uses the non-preserving codec)
  + the node BRIEF running log D3/D4/D7.

## Done when

- The machine IR is written and read as KDL via the productionized codec; files are
  `extracted.kdl` / `resolved.kdl`; `.gitignore` (`platforms/macos/api/*/extracted.json` →
  `*.kdl`) and any doc/string naming the files are updated.
- A round-trip + spec-validity test (`value == parse(emit(value))` + the official `kdl` crate parses
  the emitted text back to the identical value) is a standing guard in the crate.
- **Emit goldens are byte-identical** across all four targets, verified via `cargo test` (the
  golden-neutral gate); the full pipeline builds.

## Notes

- The golden-neutral-at-emit invariant is the gate — flag loudly if anything moves a golden.
- **Value-bridge now**, native serde JiK format deferred (D4) as a documented trigger — only worth
  it if the generate-loop delta is ever felt (fractions of a second at realistic corpus sizes).
- The format-preserving `kdl` crate stays for authored `.apiw` **only** — do **not** route the
  machine IR through it (that was the k17 ~84× tax). The machine codec is `serde_json::Value`-based.
- The spike's always-quote-keys/strings + KDL-2.0 keyword syntax (`#null`/`#true`/`#false`)
  sidesteps the k17 bare-keyword footgun by construction — keep that in the production codec.
