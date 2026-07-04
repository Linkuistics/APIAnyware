# platforms/macos/ — the macOS source platform

The macOS source-platform truth (REFACTOR.md §14). Holds the **platform manifest**
(`platform.apiw`), per-API-family specs under `api/<family>/`, app-kind definitions
under `app-kinds/`, and platform-level semantic tests under `tests/`. The extractor /
annotate / collect / manifest Rust crates that produce or read this material live
under `platforms/macos/tools/` (crate-home convention — the tool lives where its
output lands, ADR-0043).

The **`platform.apiw` manifest** (`platform-manifest-k33`, ws4 child 1) is the
authored, **policy-only** description of the platform itself: the SDK name, the
source-availability `deployment-target` floor (the digester's macOS target), and the
framework roster as an include/ignore *policy*. It is `.apiw` (KDL), **not**
`platform.yaml` — REFACTOR §14's literal name predates ADR-0046's no-YAML retreat
(authored overlays are `.apiw`, machine files JSON). The resolved 153-family roster and
the cross-family dependency graph are **derived** (recomputed from the SDK scan + the
`api/<F>/` triad), so they are not committed. Read/validated by the
`platforms/macos/tools/platform-manifest` crate against
`schemas/spec-format/platform.kdl-schema`.

The `tools/` crates (`extract-objc`, `extract-swift`, `annotate`, `collect-cli`)
landed here in `move-platforms-k6`, alongside the LLM-annotation operational scripts
(`tools/scripts/`). The git-tracked annotation data now lives as the per-family
authored overlay `api/<family>/annotations.apiw` (the flat `api/_llm-annotations/`
staging dir was folded in and retired by `pipeline-cutover-k20`; the LLM side-channel
*workflow* over the overlay is workstream 5). The per-family API specs are the spec
triad under `api/<family>/` (`extracted.kdl` / `annotations.apiw` / `resolved.kdl`,
ADR-0046) — landed and live as of `pipeline-cutover-k20`.

Workstream 4 (platform model) is **complete**: the manifest (`platform.apiw`),
the app-kinds (`app-kinds/`, ADR-0049), the platform-level semantic tests
(`tests/`), and the platform docs (`docs/`) all landed. The conceptual entry
point is [`docs/overview.md`](docs/overview.md) (indexed by [`docs/README.md`](docs/README.md)).
