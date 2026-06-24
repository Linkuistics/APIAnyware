# platforms/macos/ — the macOS source platform

The macOS source-platform truth (REFACTOR.md §14). Holds the platform manifest
(`platform.yaml`), per-API-family specs under `api/<family>/`, app-kind
definitions under `app-kinds/`, and platform-level semantic tests under `tests/`.
The extractor / annotate / collect Rust crates that produce this material live
under `platforms/macos/tools/` (crate-home convention — the tool lives where its
output lands, ADR-0043).

The `tools/` crates (`extract-objc`, `extract-swift`, `annotate`, `collect-cli`)
landed here in `move-platforms-k6`, alongside the LLM-annotation operational scripts
(`tools/scripts/`). The git-tracked annotation data now lives as the per-family
authored overlay `api/<family>/annotations.apiw` (the flat `api/_llm-annotations/`
staging dir was folded in and retired by `pipeline-cutover-k20`; the LLM side-channel
*workflow* over the overlay is workstream 5).

TODO: `platform.yaml`, app-kinds, and platform-level tests are filled by workstream 4
(platform model). The per-family API specs are the spec triad under `api/<family>/`
(`extracted.json` / `annotations.apiw` / `resolved.json`, ADR-0046) — landed and live
as of `pipeline-cutover-k20`.
