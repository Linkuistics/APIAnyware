# platforms/macos/ — the macOS source platform

The macOS source-platform truth (REFACTOR.md §14). Holds the platform manifest
(`platform.yaml`), per-API-family specs under `api/<family>/`, app-kind
definitions under `app-kinds/`, and platform-level semantic tests under `tests/`.
The extractor / annotate / collect Rust crates that produce this material live
under `platforms/macos/tools/` (crate-home convention — the tool lives where its
output lands, ADR-0043).

TODO: `platform.yaml`, API families, app-kinds, and tests are filled by
workstream 4 (platform model); the `tools/` crates (`extract-objc`,
`extract-swift`, `annotate`, `collect-cli`) and the existing extracted material
relocate here in `move-platforms-k6` / `move-target-material-k8`. No content this
leaf.
