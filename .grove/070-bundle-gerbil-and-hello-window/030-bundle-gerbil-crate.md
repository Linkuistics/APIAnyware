# 030-bundle-gerbil-crate

**Kind:** work

## Goal

Build the `bundle-gerbil` crate: package the hello-window `gxc -exe` binary into a
self-contained `.app` (ADR-0009) with the openssl@3 dylib deps vendored + relocated,
so `otool -L` shows no Homebrew dylib dependency remains.

## Context

Distribution recipe is CHARACTERIZED (FINDINGS §5, spec §7) and APPLIED here:
`gxc -exe` against the static toolchain embeds the Gerbil/Gambit runtime statically;
the ONLY self-containment gap is the Gerbil stdlib's **openssl@3** (libssl/libcrypto)
Homebrew dylib dep. The `.app` bundler vendors those into the bundle and rewrites
their load paths via `install_name_tool` / `@executable_path`, exactly the
dylib-staging `bundle-chez` does.

Reference: `generation/crates/bundle-chez/` (`src/standalone.rs`, `src/bundle.rs`,
`src/deps.rs`, `examples/bundle_app.rs`, `tests/bundle_apps.rs`). The
language-agnostic `apianyware-macos-stub-launcher` crate provides the `.app`
skeleton + codesigning. Gerbil is SIMPLER than chez: no boot image / kernel embed —
the `gxc -exe` binary is already self-contained except for the dylib relocation.

## Done when

- `generation/crates/bundle-gerbil/` crate exists, compiles, `cargo test` passes;
  added to workspace members + deps.
- Building hello-window via the crate yields `<App>.app` with the exe at
  `Contents/MacOS/<App>`, `Info.plist` (`CFBundleName`), Resources, and the
  relocated openssl dylibs.
- `otool -L Contents/MacOS/<App>` shows NO `/opt/homebrew/...` dylib deps (only
  system `/usr/lib/*` + frameworks + `@executable_path` relocations).
- Bundle id is `com.linkuistics.<NoSpaceTitle>` (never `com.apianyware.*`); display
  name from the app spec H1.

## Notes

Build invocation parallels chez: `cargo run --example bundle_app -p
apianyware-macos-bundle-gerbil -- hello-window`. The actual GUI verification is
040 (VM); this leaf's bar is a correctly-assembled, dylib-clean `.app`.
