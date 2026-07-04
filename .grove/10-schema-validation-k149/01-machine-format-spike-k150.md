# machine-format-spike-k150

**Kind:** work (spike / measurement — the deliverable is a report + a recommendation, not a
production cutover)

## Goal

Re-measure whether the machine IR (`extracted.json` / `resolved.json`) can move to **KDL** at
acceptable performance, using a **machine-oriented (non-format-preserving) codec** — the path
k17 never tested. Produce a numbers table + a recommendation against the D2 soft target. **Do
not** cut the pipeline over; this session only *decides whether* to (the user makes the final
go/no-go on the numbers, D2). If go, its follow-on leaves are grown by `02-build-plan-k151`.

## Context

- **This reverses-or-reconfirms ADR-0046's k17 Update** (the JSON retreat). Read it and k17's
  report `semantic/docs/research/2026-06-24-kdl-machine-serde-spike/` first: k17 proved the IR
  round-trips JSON↔KDL **losslessly** (correctness is *settled* — don't re-litigate it) and
  measured the **format-preserving** `kdl` crate (=6.3.4) at ~80–100× `serde_json`
  (AppKit 1795 ms vs 23 ms; Foundation 1205 ms vs 12 ms). k17 noted no fast serde-KDL path
  existed *then* (`serde_kdl` abandoned on KDL 1.0; derive crates 0.x non-serde).
- **The IR shape + the serde types**: `semantic/tools/types` (`ir`, `annotation`,
  `pattern_instance`); collect writes `extracted.json` (`platforms/macos/tools/collect-cli`),
  analyze writes `resolved.json`. Both under `platforms/macos/api/<F>/`, gitignored.
- **Fixtures** (same as k17, apples-to-apples): AppKit (~12.7 MB) + Foundation (~8.7 MB)
  extracted-shape IR, plus their `resolved.json` (larger — carries the provenance ladder). The
  `resolved.json` files are gitignored + recomputable: regenerate them first
  (`apianyware-collect` then `apianyware-analyze --only Foundation,AppKit`, loading deps together
  per [[resolved_regen_load_deps_together]]) or point the bench at whatever families are present.
- **Toolchain drift watch**: k17 pinned `kdl = "=6.3.4"` (6.7.1 needed rustc 1.95; repo was on
  1.93.1). Re-check the current rustc before pulling a newer `kdl`/codec.

## Approach (the search space — survey current, don't assume)

My library knowledge predates this grove's timeline; **survey the *current* KDL-2.0 Rust
ecosystem** rather than trusting memory (cite what you find; flag what you can't verify). Candidate
machine-KDL paths, fastest-to-slowest-effort:

1. **A serde-KDL codec** if a production-grade one now exists (parses to plain data, not a
   format-preserving document model). Search crates.io / docs.rs for current KDL-2.0 serde support.
2. **The `kdl` crate in a non-preserving mode**, if it exposes one (parse without owned spans /
   whitespace), or a lighter sibling from the kdl-org ecosystem.
3. **A hand-written streaming reader+writer** specialized to the IR shape — guaranteed fast,
   most work; the fallback if no crate clears the bar. A serde `Serializer`/`Deserializer` over a
   minimal KDL tokenizer is the likely form.

For each viable path: **prove round-trip losslessness** against the current `serde_json` IR
(reuse/adapt k17's bijective `serde_json::Value ⇄ KDL` bridge as the correctness oracle — structural
equality on both fixtures), then **benchmark** parse + emit. A path that isn't lossless is
disqualified regardless of speed.

## Done when

A spike report is written (suggest `semantic/docs/research/<date>-kdl-machine-codec-spike/` beside
k17's, for easy comparison) containing:

- a **numbers table**: `serde_json` vs each viable machine-KDL codec, **parse + emit**, on AppKit
  and Foundation, for **both** `extracted` and `resolved` shapes;
- a **full-corpus extrapolation** (parse all ~153 families) and an **incremental
  generate-loop delta** (the cost a pure emit-iteration pays re-reading `resolved` each run — the
  friction D2 cares about most);
- a **correctness statement** (lossless round-trip confirmed, per path);
- a **recommendation** against the D2 soft target (~≤5× `serde_json`, full-corpus round-trip in the
  low seconds), naming the best codec and its effort-to-productionize;
- an **ADR draft** (or enough for `02` to raise one) that supersedes the ADR-0046 k17 Update —
  either "un-retreat to KDL, codec = X" or "k17 reconfirmed with current tooling, keep JSON".

Then **surface the numbers to the user for the go/no-go call** (D2) — do not cut the pipeline over
in this leaf. Bench code lands in a throwaway/bench location, not the production serde path.

## Notes

- Golden-neutral: this leaf writes benchmarks + a report, touches no emit path. The eventual
  *migration* (if go) is golden-neutral at the emit layer (generator output byte-identical) — but
  that's `02`'s follow-on, not here.
- If the survey finds the ecosystem still has no fast codec and a hand-written one is the only path,
  that effort estimate is itself a key input to the user's go/no-go — report it plainly rather than
  silently building the hand-written codec to completion (that would exceed this leaf's scope; a
  *prototype* sufficient to benchmark is enough).
