# LLM authoring eval: KDL vs YAML vs JSON for `.apiw` annotations

**Date:** 2026-06-24 · **Context:** `structural-refactoring` grove, workstream 2
(`spec-format-k16`) · **Decision it informed:** [ADR-0046](../../../../adr/0046-spec-interchange-format-kdl-everywhere.md)
(KDL as the single spec interchange format).

## Question

REFACTOR §29 splits "a human-editable DSL" from "a canonical interchange format".
During grilling the design moved toward **KDL for both** (one format, no YAML). The
load-bearing objection: the `.apiw` annotation overlay is **LLM-authored at scale**
(per-framework subagents — see the project's LLM-annotation constraint), and YAML's one
real advantage over JSON is *authoring ergonomics* (no escaping/quoting noise). So:
**can LLMs author KDL at least as reliably as YAML, for realistic annotation content?**

This is empirical, not a matter of opinion — so we measured it rather than speculating.

## Method

Three arms — **KDL 2.0, YAML, JSON** — each authored by **2 fresh, independent subagents**
(same model, no shared context), all given the **identical** task:

- `inputs/methods.md` — 20 real-shape macOS API methods (chosen to stress the format):
  ObjC colon selectors (`setObject:forKey:`), Swift paren selectors (`combineLatest(_:_:_:_:)`,
  `data(for:delegate:)`, `async(execute:)`), nested block-parameter / param-ownership lists,
  and a mandate to write genuine free-text `rationale` prose **with** apostrophes, colons,
  quoted "terms", em-dashes (—), and arrows (->) — i.e. the punctuation that forces escaping.
- `inputs/vocab.md` — the neutral annotation vocabulary (format-independent).
- `inputs/shape-<fmt>.md` — the target format's rules + **two** worked examples (the same two
  methods in each arm, so no arm gets a content advantage). Each arm's shape guide gives that
  format its *best shot* (YAML: "quote colon-strings and bool-like values"; KDL: "use raw
  strings `#"…"#` for prose"; JSON: "escape `"`/`\`").

Validation (`validate.py`, `kdlcheck.rs`):

- **KDL** — parsed with the actual `kdl` Rust crate (KDL 2.0; pinned `=6.3.4` for rustc 1.93),
  the crate the implementation will adopt. Selectors decoded via `KdlValue::as_string()`.
- **YAML** — `yaml.safe_load` (PyYAML), plus a **type-coercion scan** (did a string field
  silently become a bool/number/null? — YAML 1.1's Norway/`NO`→false class of footgun).
- **JSON** — `json.loads`.
- **Fidelity** (all arms): all 20 selectors present and **exact**, `is_instance` stayed bool,
  `source=="llm"`, no string field coerced to a non-string type.

## Results

All raw outputs are under `outputs/`. Every arm produced 20 annotations.

| Format | Well-formed | Selector + type fidelity | Escaped `\"` (2 runs) | Free-text strategy |
|--------|:-----------:|:------------------------:|:---------------------:|--------------------|
| **KDL**  | **2/2** | **clean** | **0** (40× raw-string `#"…"#`) | natural prose verbatim — `"`, `'`, —, `*`, `->` all unescaped |
| YAML | 2/2 | clean | 34 | escapes embedded `"` in free text |
| JSON | 2/2 | clean | 96 | escapes the most |

### Findings

1. **LLMs author KDL reliably.** 2/2 well-formed; every selector survived exactly
   (incl. the paren and colon selectors); no type coercion. Parse-validity did **not**
   discriminate — *all three* formats parsed in all runs.
2. **The decisive difference is escaping, and it favors KDL.** The user's premise —
   "YAML beats JSON on escaping" — holds only for *structural* strings (colons). For the
   realistic payload (quote-heavy `rationale` prose), **YAML still escapes embedded
   double-quotes**, only ~2.8× less than JSON. KDL's **raw strings eliminate escaping
   entirely**: the models reached for `#"…"#` 40/40 times and wrote completely natural
   prose with zero escape sequences. So for this content KDL is *better* than YAML, not
   worse — refuting the worry that motivated the eval.

### Caveats (honesty per the research discipline)

- **Small sample:** one model, one task shape, 20 methods × 2 runs/arm. A strong
  **directional** signal, not a proof. Re-run at framework scale if confidence is needed.
- **Scope:** this measured **authoring** only. The separate, still-open risk is KDL
  **machine-serialization** (the `kdl` crate is document-model, not serde-derive) — perf
  + serde-adapter maturity on the large IR. That is gated to a spike in the first
  implementation leaf (ADR-0046), with JSON as the documented machine-side retreat.

## Reproduce

```
# KDL validator (kdl crate, KDL 2.0)
cargo new kdlcheck && cd kdlcheck   # add: kdl = "=6.3.4"; copy kdlcheck.rs to src/main.rs
cargo build
./target/debug/kdlcheck < outputs/kdl-1.kdl          # -> OK methods=20 ; SEL ...
SP=<dir-with-eval> python3 validate.py               # validates all six outputs
```
