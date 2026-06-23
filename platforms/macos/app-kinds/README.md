# platforms/macos/app-kinds/ — macOS app-kind definitions

The kinds of macOS application a target can be asked to build (REFACTOR.md §14):
`cli-tool`, `gui-app`, `menu-bar-daemon`, `launch-agent`, `spotlight-importer`,
`quicklook-extension`, `finder-sync-extension`. Each kind is one directory with a
`kind.apiw` definition plus `docs/` describing its lifecycle, bundle structure,
and test obligations. App-kinds are platform truth (process model, bundle shape) —
distinct from the target-independent app *specs* under `apps/macos/`.

TODO: `kind.apiw` definitions authored in workstream 4 (platform model); the
`.apiw` DSL is workstream 2. No content this leaf (SC6).
