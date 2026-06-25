# platforms/ — source platform truth

The `platforms/` domain holds per-platform formal API specifications (REFACTOR.md
§8, §13). Platform specs state what a platform's APIs *mean* and are kept
**projection-free** — no statement about how any target exposes them (§7.1,
§45.10). macOS is the only live platform today; the shape generalizes to
`platforms/linux/` and `platforms/dotnet/` without redesign (§45.8).

A platform is described by an authored, policy-only **`platform.apiw` manifest** (SDK,
source-availability floor, framework include/ignore policy) plus its per-family API
specs, app-kinds, and platform-level tests. The manifest format is contracted by
`schemas/spec-format/platform.kdl-schema` and is platform-neutral — a future
`platforms/linux/platform.apiw` reuses the same shape.

Status: `platforms/macos/` is populated — the per-family spec triad relocated here in
`move-platforms-k6`, and the `platform.apiw` manifest landed in `platform-manifest-k33`
(workstream 4 child 1). The remaining workstream-4 children (app-kinds, platform-level
tests, platform docs) grow `platforms/macos/` further.
