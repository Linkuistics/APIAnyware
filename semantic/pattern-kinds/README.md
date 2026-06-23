# semantic/pattern-kinds/ — first-class multi-API pattern entities

Multi-API patterns are semantic entities, not generator flags (REFACTOR.md §7.5,
§32). Each pattern kind — `bracket`, `builder`, `observer`, `delegate`,
`callback`, `subscription`, `typestate`, `buffer-fill`, `two-call-sizing`,
`error-side-channel`, `refcounted`, parent-child / collection-element ownership —
is defined once here as a reusable semantic shape that platform specs reference
and targets project.

TODO: `.apiw` pattern-kind definitions are authored in workstream 3 (semantic
model); the `.apiw` DSL they are written in is workstream 2 (spec-format). No
content this leaf (SC6 forbids new content artifacts in the skeleton).
