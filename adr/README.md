# adr/ — central Architecture Decision Record log

The single central ADR log, relocated from `docs/adr/` to a small, focused
top-level `adr/` (ADR-0045, refining ADR-0024). ADRs are the one artifact that
resists co-location: the decision log is a connected graph crossing every target
(supersession chains; later targets cite earlier ones), so it keeps global
numbering and a single home rather than being scattered per-domain (§10). A small
top-level directory is *not* the "large top-level `docs/`" §10 forbids.

TODO: the existing ADRs relocate from `docs/adr/` here in `co-locate-docs-k9`,
with all ~45 `docs/adr/NNNN…` cross-references rewritten (ADR-0045). Empty until
then.
