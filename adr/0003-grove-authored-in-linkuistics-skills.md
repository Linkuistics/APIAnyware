# grove is authored in Linkuistics/skills under the linkuistics namespace

grove's upstream home is `github.com/Linkuistics/skills` — a Claude Code
marketplace whose single plugin, `linkuistics`, gives every Linkuistics skill
the `linkuistics:` namespace. That repo is the generalisation of the former
`Linkuistics/coding-standards`; the existing `coding-style` and related skills
moved under it, and it adopted an Apache-2.0 licence. Authoring grove in a
shared, versioned, permissively-licensed repo — not inside this project — is
what makes materialisation (ADR-0001) and independent per-project version pins
possible.

See `process/2026-05-22-grove-skill-design.md` (decision D3).
