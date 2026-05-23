# grove bundles its convention files rather than depending on them

grove's `CONTEXT-FORMAT.md`, `ADR-FORMAT.md`, and `grilling.md` are copied in
from `mattpocock/skills` (MIT) — with origin headers and the upstream licence
in `LICENSES/` — rather than depended on as a separately-installed plugin. This
follows directly from materialisation (ADR-0001): a materialised, git-pinned
grove must be self-contained and reproducible, and cannot reach a live,
separately-versioned plugin. `mattpocock/skills` is a recorded *source*,
refreshed deliberately when a new grove version is cut.

See `docs/specs/2026-05-22-grove-skill-design.md` (decision D2).
