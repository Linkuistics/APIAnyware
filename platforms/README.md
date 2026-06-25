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

Status: `platforms/macos/` is populated and **workstream 4 (platform model) is
complete** — the per-family spec triad relocated here in `move-platforms-k6`; the
`platform.apiw` manifest, the app-kinds (`app-kinds/`), the platform-level semantic
tests (`tests/`), and the platform docs (`docs/`) all landed across ws4's four
children. See [`macos/docs/overview.md`](macos/docs/overview.md).
