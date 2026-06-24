# adr/ — central Architecture Decision Record log

The single central ADR log, relocated from the former `docs/adr/` to this small,
focused top-level `adr/` (ADR-0045, refining ADR-0024). ADRs are the one artifact
that resists co-location: the decision log is a connected graph crossing every
target (supersession chains; later targets cite earlier ones), so it keeps global
numbering and a single home rather than being scattered per-domain (§10). A small
top-level directory is *not* the "large top-level `docs/`" §10 forbids.

All ADRs (`0001`–`0045`) live here, moved in `co-locate-docs-k9` with their
`docs/adr/NNNN…` cross-references rewritten to `adr/NNNN…`. Global sequential
numbering and filenames are unchanged — only the parent path moved. Add new ADRs
here with the next free number.
