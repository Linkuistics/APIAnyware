# adr/ — central Architecture Decision Record log

The single central ADR log lives in this small, focused top-level `adr/`. ADRs are
the one artifact that resists co-location: the decision log is a connected graph
crossing every target and domain (later targets cite earlier ones), so it keeps a
single central home with global numbering rather than being scattered per-domain
(ADR-0024, REFACTOR §10). A small, single-purpose top-level directory is *not* the
"large top-level `docs/`" §10 forbids.

Filenames are `NNNN-<slug>.md` with global, stable numbering; the number is a stable
handle, not a position — retiring an ADR leaves a numbering gap rather than
renumbering the rest. Add a new ADR with the next free number.

Each ADR states the decision **as it currently stands** — no supersession chains, no
dated "Status"/update/history sections. When a decision changes, its ADR is edited in
place, merged, or deleted (git holds the prior version); the set is kept to a minimum
coherent description of the current design.
