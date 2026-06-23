# move-semantic-k5

**Kind:** work

## Goal

`git mv` the semantic-graph-builder crates into `semantic/tools/`:

```text
collection/crates/types   → semantic/tools/types
analysis/crates/datalog   → semantic/tools/datalog
analysis/crates/resolve   → semantic/tools/resolve
analysis/crates/enrich    → semantic/tools/enrich
analysis/crates/cli       → semantic/tools/analyze-cli   (bin apianyware-analyze)
```

Update root `Cargo.toml`: `members` paths + `[workspace.dependencies]` `path` values
for these five crates. Fix any in-crate path strings these crates use (e.g. enrich
fixtures/tests, analyze-cli IR paths). `types` is depended on by *everything*, so its
move + dep-path update is the load-bearing edit — verify the whole workspace still
resolves.

## Context

See node brief — crate→domain map, SC2 (the platform-producer vs semantic-builder
split puts `types`/`datalog`/`resolve`/`enrich` here, `annotate` in platforms),
SC3 (`analyze`-cli → semantic), SC5 (build green per leaf). Names already renamed (k4).

## Done when

The five crates live under `semantic/tools/`; `cargo build` (and their tests) green;
committed as `move-semantic-k5`.

## Notes

Move crate-by-crate, building between each so no intermediate state breaks. `analysis/`
will be partly emptied (annotate + collect-era leftovers remain until k6); don't delete
`analysis/` yet (k10).
