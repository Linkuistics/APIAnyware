# domains-skeleton-k3

**Kind:** work

## Goal

Create the empty five-domain home tree with placeholder READMEs + TODO markers —
**no crate or material moves**, so the JSON-IR pipeline keeps building untouched.
This realizes the homes that §45.13 ("an obvious place exists") demands; later leaves
move material in. SC6: zero new content artifacts.

Create (each new dir gets a one-paragraph `README.md` stating what it holds + a
`TODO:` for what later workstreams will fill):

```text
semantic/{docs,pattern-kinds}/
platforms/macos/{docs,api,app-kinds,tests}/
apps/macos/
targets/_shared/tools/        (empty — emit/stub-launcher/generate-cli arrive in k7)
schemas/docs/
adr/                          (empty — ADRs arrive in k9 via ADR-0045)
```

Use §14 (platform shape) and §18 (target shape) as the README vocabulary; do not
pre-create per-target dirs beyond what the moves need (targets/<t>/ trees are formed
as material arrives in k7/k8).

## Context

See the node brief (`grove-llm brief-chain`) — SC1–SC7 + the crate→domain map.
`REFACTOR.md` §9/§10/§14/§18/§41/§45. This is the **realizing node** for the new
structural vocabulary, so add the resolved terms (the five domains, `targets/_shared`,
the `tools/` crate-home convention) to `CONTEXT.md` here (root brief defers
new-domain-vocab glossary to the node that realizes it).

## Done when

The home tree + READMEs + TODO markers exist; `CONTEXT.md` carries the new structural
terms; `cargo build` is green (nothing moved); committed as `domains-skeleton-k3`.

## Notes

Leading-underscore `targets/_shared/` is intentional (ADR-0044) — sorts/reads as
"not a target". Kebab-case dirs (§41); conventional API-family names (`CoreFoundation`)
come later with the platform material.
