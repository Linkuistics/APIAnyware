# grove is consumed by materialisation into this repo, not as a shared plugin

The `grove` workstream methodology is copied into this repo at
`.claude/skills/grove/` and committed, rather than installed as a global Claude
Code plugin. A global plugin is one version per machine and cannot give many
concurrent, long-lived workstreams independent, reproducible version pins; a
committed copy pins the methodology to this repo's own git history, isolated
per repo. The trade-off is a per-repo copy to maintain —
`.claude/skills/grove/VERSION.md` records the upstream correspondence
and the one-command update.

See `docs/specs/2026-05-22-grove-skill-design.md` (decision D1).
