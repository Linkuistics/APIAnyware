# platforms/macos/api/ — per-API-family source specs

One directory per macOS API family (REFACTOR.md §14), named conventionally
(`CoreFoundation`, `Foundation`, `AppKit`, … — §41 keeps conventional API-family
names rather than kebab-case). Each family holds the three-stage spec:
`extracted.yaml` (mechanical extraction), `annotations.apiw` (the reviewable LLM
side-channel), and `resolved.yaml` (the merged source-of-truth), plus a `docs/`
subtree.

The git-tracked LLM annotation side-channel relocated here in `move-platforms-k6` as
the transitional staging dir `_llm-annotations/` (flat `*.llm.json`, as-is — see its
README).

TODO: the per-family `<Family>/` directories and their `extracted.yaml` / `resolved.yaml`
relocate from `analysis/ir/` in workstream 4 (platform model); the `_llm-annotations/`
staging reshapes into per-family `annotations.apiw` in workstream 5 (LLM analysis).
