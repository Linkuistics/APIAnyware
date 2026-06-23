# platforms/ — source platform truth

The `platforms/` domain holds per-platform formal API specifications (REFACTOR.md
§8, §13). Platform specs state what a platform's APIs *mean* and are kept
**projection-free** — no statement about how any target exposes them (§7.1,
§45.10). macOS is the only live platform today; the shape generalizes to
`platforms/linux/` and `platforms/dotnet/` without redesign (§45.8).

TODO: `platforms/macos/` is populated by workstream 4 (platform model) and the
relocation leaves `move-platforms-k6` / `move-target-material-k8`. No content this
leaf (skeleton-only).
