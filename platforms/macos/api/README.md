# platforms/macos/api/ — per-API-family source specs

One directory per macOS API family (REFACTOR.md §14), named conventionally
(`CoreFoundation`, `Foundation`, `AppKit`, … — §41 keeps conventional API-family
names rather than kebab-case). Each family holds the three-stage spec:
`extracted.yaml` (mechanical extraction), `annotations.apiw` (the reviewable LLM
side-channel), and `resolved.yaml` (the merged source-of-truth), plus a `docs/`
subtree.

TODO: family directories and the extracted/resolved material relocate from
`analysis/ir/` in workstream 4 + `move-platforms-k6`; the `annotations.apiw`
side-channel is workstream 5 (LLM analysis). No content this leaf.
