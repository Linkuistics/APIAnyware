# platforms/macos/ — the macOS source platform

The macOS source-platform truth (REFACTOR.md §14). Holds the platform manifest
(`platform.yaml`), per-API-family specs under `api/<family>/`, app-kind
definitions under `app-kinds/`, and platform-level semantic tests under `tests/`.
The extractor / annotate / collect Rust crates that produce this material live
under `platforms/macos/tools/` (crate-home convention — the tool lives where its
output lands, ADR-0043).

The `tools/` crates (`extract-objc`, `extract-swift`, `annotate`, `collect-cli`)
landed here in `move-platforms-k6`, alongside the LLM-annotation operational scripts
(`tools/scripts/`) and the git-tracked annotation data (`api/_llm-annotations/`).

TODO: `platform.yaml`, the per-family API specs (`extracted.yaml` / `resolved.yaml`),
app-kinds, and platform-level tests are filled by workstream 4 (platform model); the
existing emitted/extracted material relocates in `move-target-material-k8`.
