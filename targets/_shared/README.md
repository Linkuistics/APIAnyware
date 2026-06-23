# targets/_shared/ — cross-target machinery (not a target)

The shared projection machinery consumed by every target but owned by none
(ADR-0044). The leading underscore is intentional: `_shared` sorts and reads as
"not a target", so a directory listing of `targets/` cleanly separates the live
languages from the common substrate. Hermetic per-target isolation (ADR-0011)
governs generated runtime artifacts and outputs — not this shared emitter *code*,
which by "code lives with its consumers" is target-domain expression machinery
shared across all four emitters (ADR-0043 Consequences).

TODO: the shared `tools/` crates (`emit` incl. the `naming` acronym table,
`stub-launcher`, `generate-cli`) relocate here in `move-target-crates-k7`. No
content this leaf.
